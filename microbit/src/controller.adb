----------------------------------------------------------------------------
--  High Integrity Sumobot                                                --
--  Copyright (C) 2019-2020 Blaine Osepchuk <bosepchuk@gmail.com>         --
--                                                                        --
--  This program is free software: you can redistribute it and/or modify  --
--  it under the terms of the GNU General Public License as published by  --
--  the Free Software Foundation, either version 3 of the License, or     --
--  (at your option) any later version.                                   --
--                                                                        --
--  This program is distributed in the hope that it will be useful,       --
--  but WITHOUT ANY WARRANTY; without even the implied warranty of        --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         --
--  GNU General Public License for more details.                          --
--                                                                        --
--  You should have received a copy of the GNU General Public License     --
--  along with this program (LICENSE.txt).                                --
--  If not, see <https://www.gnu.org/licenses/>.                          --
----------------------------------------------------------------------------


with HAL;
with HAL.I2C;
with MicroBit.Buttons;
with MicroBit.Time;
with Controller.Utils;
with Battery;
with Model;
with Payload;
with View.Button; use View.Button;
with View.Display;
with View.Motors;


package body Controller with SPARK_Mode => On is
   Initialized : Boolean := False;

   --  The following variables represent the state of the system.
   S_In : Model.State_In_Record;
   S_In_Out : Model.State_In_Out_Record;
   Button_B : View.Button.Button_Type;
   Display_Char : Character;
   Last_Parse_Error_Time : MicroBit.Time.Time_Ms := 0;

   Zumo_Data : HAL.I2C.I2C_Data (1 .. Payload.Num_Raw_Bytes);
   Zumo_Payload : Payload.Payload;
   Is_First_Scan_Of_Match : Boolean := False;




   procedure Initialize is
   begin
      --  The microbit must wait for the zumo's I2C subsystem to come online
      --  before it attempts to establish communications.
      --  If you change this value, you must also change it in the zumo's
      --  setup function to be 20 MS less than this value.
      MicroBit.Time.Delay_Ms (120);
      View.Zumo_I2C.Initialize;
      if not View.Zumo_I2C.Is_Initialized then
         --  Could not initialize the I2C connection. Display 'E' forever.
         View.Display.Write ('E');
         Controller.Utils.Loop_Forever_On_Error;
      end if;
      Initialized := True;
   end Initialize;




   function Is_Initialized return Boolean is
   begin
      return Initialized;
   end Is_Initialized;




   procedure Run is
      Is_Read_Successful : Boolean;
      Is_Parse_Successful : Boolean;
      Is_Motor_Cmd_Successful : Boolean;
      Has_Error : Boolean := False;
   begin
      S_In.Clock_Ms := MicroBit.Time.Clock;

      --  Deal with button presses.
      Poll (Is_Momentarily_Pressed (MicroBit.Buttons.State (MicroBit.Buttons.Button_B)), Button_B);
      S_In.Button_B_Is_Pressed := Is_Pressed (Button_B);
      if S_In.Button_B_Is_Pressed then
         Clear (Button_B);
      end if;

      --  Update motor speed.
      --  Note: the bot sets the motor speeds before it gets the sensor data
      --  below because I want the first call to the motors to be a stop command
      --  to make sure the bot can't move on start-up.
      View.Motors.Set_Speed (S_In_Out.Speeds, Is_Motor_Cmd_Successful);

      if Is_Motor_Cmd_Successful then
         View.Zumo_I2C.Read (Zumo_Data, Is_Read_Successful);
         if Is_Read_Successful then
            Payload.Parse (Zumo_Data, Zumo_Payload, Is_Parse_Successful);
            if Is_Parse_Successful then
               --  Prepare the S_In record.
               S_In.Target_Dir := Model.Get_Target_Direction (Zumo_Payload, S_In.Target_Dir);
               S_In.Line_Dir := Model.Get_Line_Detected_Direction (Zumo_Payload);
               S_In.Battery_Status := Battery.Get_Status (Zumo_Payload.Is_Usb_Present,
                                                          Zumo_Payload.Batt_Volts_Tenths);

               --  Housekeeping for initial scan direction.
               Controller.Utils.Reset_First_Scan_Of_Match (S_In_Out.Current_State,
                                                           Is_First_Scan_Of_Match);
               Model.Set_Initial_Scan_Direction (S_In, S_In_Out, Is_First_Scan_Of_Match);

               --  Figure out the next move and determine the display char.
               Model.Get_Next_Move (S_In, S_In_Out);
               Display_Char := Model.Get_Display_Char (S_In, S_In_Out);
            else
               --  Parse of payload failed but the I2C read was successful.
               --  This is not unexpected with I2C communications, but it
               --  should be rare.
               if Model.Has_Too_Many_Parse_Errors (Last_Parse_Error_Time, S_In.Clock_Ms) then
                  Display_Char := 'F'; --  Parse of payload failed too often
                  Has_Error := True;
               end if;
               Last_Parse_Error_Time := S_In.Clock_Ms;
            end if;
         else
            Display_Char := 'N'; --  No data read (because the I2C read failed)
            Has_Error := True;
         end if;
      else
         Display_Char := 'U'; --  Unable to set motor speed
         Has_Error := True;
      end if;
      View.Display.Write (Display_Char);
      Controller.Utils.Loop_Forever_On_Error (Has_Error);
   end Run;
end Controller;
