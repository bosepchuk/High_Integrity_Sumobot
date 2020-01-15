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


with HAL.I2C;
with MicroBit.Time;


package body View.Motors.Utils with SPARK_Mode => On is




   function Convert_Left_Speed (Speed : in Motor_Speed) return UInt8 is
      --  Motor speeds are -50 .. 50 and we need to map them to the
      --  lower end of a Uint8 (0-255).
      --  So we add 50 to Speed.
      --  Note: this offset must match the offset on the zumo.
      Left_Motor_Offset : constant Working_Speed := 50;
      Temp_Speed : Working_Speed;
   begin
      Temp_Speed := Speed + Left_Motor_Offset;
      return UInt8 (Temp_Speed);
   end Convert_Left_Speed;




   function Convert_Right_Speed (Speed : in Motor_Speed) return UInt8 is
      --  Motor speeds are -50 .. 50 and we need to map them to the
      --  upper end of a UInt8 (0-255) which starts at 110.
      --  So we add 160 to Speed (50 + 110)
      --  Note: this offset must match the offset on the zumo.
      Right_Motor_Offset : constant Working_Speed := 160;
      Temp_Speed : Working_Speed;
   begin
      Temp_Speed := Speed + Right_Motor_Offset;
      return UInt8 (Temp_Speed);
   end Convert_Right_Speed;




   procedure Set_Motor_Speed (Motor_Setting : in UInt8;
                              Is_Successful : out Boolean) is
      --  Send one byte (0-255) for each motor.
      --  0-100: left motor
      --  110-210: right motor
      Send_Data : HAL.I2C.I2C_Data (1 .. 1);
   begin
      --  This loop proves to spark that the entire array is initialized. This
      --  is required even though there is only one element and it is assigned
      --  below.
      for Index in Send_Data'Range loop
         Send_Data (Index) := 0;
      end loop;

      Send_Data (1) := Motor_Setting;
      View.Zumo_I2C.Write (Send_Data, Is_Successful);
      --  If you make this delay too short, you risk causing an interrupt on
      --  the zumo before it's finished processing the previous interrupt,
      --  which would be bad.
      MicroBit.Time.Delay_Ms (8);
   end Set_Motor_Speed;
end View.Motors.Utils;
