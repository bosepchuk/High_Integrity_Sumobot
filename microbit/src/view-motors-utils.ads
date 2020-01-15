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


with HAL; use HAL;
with View.Zumo_I2C;


private package View.Motors.Utils with SPARK_Mode => On is




   function Convert_Left_Speed (Speed : in Motor_Speed) return UInt8
     with Global => null,
     Post => (Convert_Left_Speed'Result >= 0 and Convert_Left_Speed'Result <= 100);




   function Convert_Right_Speed (Speed : in Motor_Speed) return UInt8
     with Global => null,
     Post => (Convert_Right_Speed'Result >= 110 and Convert_Right_Speed'Result <= 210);




   procedure Set_Motor_Speed (Motor_Setting : in UInt8;
                              Is_Successful : out Boolean)
     with Pre => View.Zumo_I2C.Is_Initialized;
end View.Motors.Utils;
