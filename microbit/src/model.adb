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


with Model.Utils; use Model.Utils;


package body Model with SPARK_Mode => On is




   function Combine_Speeds (Left : in View.Motors.Motor_Speed;
                            Right : in View.Motors.Motor_Speed)
                            return View.Motors.Motor_Speeds is
      Speeds : View.Motors.Motor_Speeds;
   begin
      Speeds.Left := Left;
      Speeds.Right := Right;
      return Speeds;
   end Combine_Speeds;




   function Get_Display_Char (S_In : in State_In_Record;
                              S_In_Out : in State_In_Out_Record)
                              return Character is
      Char : Character;
      Time_In_Current_State : MicroBit.Time.Time_Ms;
   begin
      Time_In_Current_State := Time_In_This_State (S_In_Out.State_Start_Time, S_In.Clock_Ms);
      case S_In_Out.Current_State is
         when Battery_Critical => Char := 'C'; --  Battery is critically low
         when Pausing => Char := Get_Pausing_Char (S_In.Battery_Status);
         when Waiting => Char := Get_Countdown (Wait_Time, Time_In_Current_State);
         when Scanning => Char := 'S'; --  Scanning
         when Driving => Char := 'D'; --  Driving
         when Reversing => Char := 'R'; -- Reversing
      end case;
      return Char;
   end Get_Display_Char;




   function Get_Line_Detected_Direction (Sensors : in Payload.Payload)
                                         return Line_Detected_Direction is
   begin
      --  It's possible that more than one line sensor could be triggered at
      --  once but for the purposes of this algorithm the following code will
      --  be sufficient.
      if Line_Sensors.Is_Line (Sensors.Line_Left) then
         return Left;
      elsif Line_Sensors.Is_Line (Sensors.Line_Right) then
         return Right;
      elsif Line_Sensors.Is_Line (Sensors.Line_Center) then
         return Center;
      else
         return None;
      end if;
   end Get_Line_Detected_Direction;




   procedure Get_Next_Move (S_In : in State_In_Record;
                            S_In_Out : in out State_In_Out_Record) is

      Time_In_Current_State : MicroBit.Time.Time_Ms;
   begin
      Time_In_Current_State := Time_In_This_State (S_In_Out.State_Start_Time, S_In.Clock_Ms);


      if S_In_Out.Current_State = Battery_Critical then
         S_In_Out.Speeds := Combine_Speeds (0, 0); --  Ensure the motors are stopped
      elsif S_In.Battery_Status = Battery.Critical then
         --  ### Battery_Critical: stop immediately ###
         --  We don't want the bot bouncing between critical and driving as
         --  the battery approaches the critical voltage threshold.
         --  So once the battery hits that point, it stops and the bot
         --  stays in that state.
         S_In_Out.Speeds := Combine_Speeds (0, 0);
         Change_State (Battery_Critical, S_In, S_In_Out);
      elsif S_In_Out.Current_State = Pausing then
         --  ### Pausing: press button B to start waiting (countdown) ###
         S_In_Out.Speeds := Combine_Speeds (0, 0);
         if S_In.Battery_Status /= Battery.Low and S_In.Button_B_Is_Pressed then
            Change_State (Waiting, S_In, S_In_Out);
         end if;
      elsif S_In.Button_B_Is_Pressed then
         S_In_Out.Speeds := Combine_Speeds (0, 0);
         Change_State (Pausing, S_In, S_In_Out);
      elsif S_In_Out.Current_State = Waiting then
         --  ### Waiting: running the countdown. Start scanning when done ###
         S_In_Out.Speeds := Combine_Speeds (0, 0);
         if Time_In_Current_State >= Wait_Time then
            Change_State (Scanning, S_In, S_In_Out);
         end if;
      elsif S_In_Out.Current_State = Scanning then
         Get_Next_Scanning_Move (S_In, Time_In_Current_State, S_In_Out);
      elsif S_In_Out.Current_State = Driving then
         Get_Next_Driving_Move (S_In, Time_In_Current_State, S_In_Out);
      elsif S_In_Out.Current_State = Reversing then
         --  ### Reversing: blindly drive backwards for a fixed amount of time ###
         S_In_Out.Speeds := Combine_Speeds (Reverse_Speed, Reverse_Speed);
         if Time_In_Current_State >= Reverse_Time then
            Change_State (Scanning, S_In, S_In_Out);
         end if;
      end if;
   end Get_Next_Move;




   function Get_Target_Direction (Sensors : in Payload.Payload;
                                  Previous_Target_Dir : in Target_Direction)
                                  return Target_Direction is
      --  I determined the algorithm in this function experimentally by
      --  moving a target near the bot and seeing what the prox sensors
      --  reported.
      --  There's little value in writing unit tests for this function so
      --  I didn't write any.
      Front_Prox_Sum : Integer;
      Front_Prox_Diff : Integer;
   begin
      --  The front sensors report their maximum values about 10-15 cm in front
      --  of the bot. As the gap between the bot and the target decreases, the
      --  front sensor values DECREASE. And they can fall all the way to zero,
      --  depending on the shape of the target. So, once this function
      --  returns Front_Close, it will continue to return Front_Close until
      --  either of the side sensors report a non-zero value.
      --
      --  Without the following if statement the bot behaves erratically
      --  near the target.
      if Previous_Target_Dir = Front_Close and Sensors.Prox_Left = 0 and Sensors.Prox_Right = 0 then
         return Front_Close;
      end if;


      Front_Prox_Sum := Integer (Sensors.Prox_Front_Left);
      Front_Prox_Sum := Front_Prox_Sum + Integer (Sensors.Prox_Front_Right);

      Front_Prox_Diff := Integer (Sensors.Prox_Front_Right);
      Front_Prox_Diff := Front_Prox_Diff - Integer (Sensors.Prox_Front_Left);

      --  I determined these cutoffs by experimenting with the bot and a
      --  training dummy bot.
      --
      --  Note: the sensor behavior is very much influenced by the size, shape,
      --  and color of the target. Adjust these values as required.
      if Sensors.Prox_Left >= 5 then
         return Left;
      elsif Sensors.Prox_Right >= 5 then
         return Right;
      elsif (Sensors.Prox_Left - Sensors.Prox_Front_Left) >= 3 then
         return Left;
      elsif (Sensors.Prox_Right - Sensors.Prox_Front_Right) >= 3 then
         return Right;
      elsif Front_Prox_Sum >= 10 then
         return Front_Close;
      elsif Sensors.Prox_Left > 3 then
         return Left;
      elsif Sensors.Prox_Right > 3 then
         return Right;
      elsif Front_Prox_Diff >= 1 then
         return Slightly_Right;
      elsif Front_Prox_Diff <= -1 then
         return Slightly_Left;
      elsif Front_Prox_Sum > 4 then
         return Front_Far;
      else
         --  The bot is completely blind in the 5, 6, and 7 o'clock positions.
         --  And there are significant weak spots in the 10 and 2 o'clock
         --  positions once you get a little farther from the bot.
         return Unknown;
      end if;
   end Get_Target_Direction;




   function Has_Too_Many_Parse_Errors (Last_Parse_Error_Time : in MicroBit.Time.Time_Ms;
                                       Current_Parse_Error_Time : in MicroBit.Time.Time_Ms)
                                       return Boolean is
      Min_Interval_Between_Parse_Errors : constant MicroBit.Time.Time_Ms := 100;
   begin
      if Last_Parse_Error_Time = 0 then
         --  Zero is the initial value. So there haven't been any parse errors yet.
         return False;
      end if;
      return Time_In_This_State (Last_Parse_Error_Time, Current_Parse_Error_Time) < Min_Interval_Between_Parse_Errors;
   end Has_Too_Many_Parse_Errors;




   procedure Set_Initial_Scan_Direction (S_In : in State_In_Record;
                                         S_In_Out : in out State_In_Out_Record;
                                         Is_First_Scan_Of_Match : in out Boolean) is
   begin
      if S_In_Out.Current_State = Scanning and Is_First_Scan_Of_Match then
         --  Set the scan direction the first time in the bot enters the
         --  scanning state (so the bot drives towards the target as soon
         --  as possible instead of scanning in a predetermined direction
         --  regardless of the sensor readings).
         S_In_Out.Scan_Dir := Get_Initial_Scan_Direction (S_In.Target_Dir);
         Is_First_Scan_Of_Match := False;
      end if;
   end Set_Initial_Scan_Direction;




   function Time_In_This_State (State_Start_Time : in MicroBit.Time.Time_Ms;
                                Clock_Ms : in MicroBit.Time.Time_Ms)
                                return MicroBit.Time.Time_Ms is
   begin
      --  Normal case
      if Clock_Ms >= State_Start_Time then
         return Clock_Ms - State_Start_Time;
      else
         --  Rollover case for MicroBit.Time.Time_Ms
         return (Clock_Ms + (1 + MicroBit.Time.Time_Ms'Last - State_Start_Time));
      end if;
   end Time_In_This_State;
end Model;
