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


package Prox_Sensors with SPARK_Mode => On is
   type Prox_Sensor_Byte is new Integer range 0 .. 255;
   subtype Prox_Sensor_Type is Prox_Sensor_Byte range 0 .. 6;
   type Target_Direction is (Unknown, Left, Slightly_Left, Front_Close, Front_Far, Slightly_Right, Right);




   function Is_Target_Ahead (Target_Dir : Target_Direction)
                             return Boolean
     with Global => null,
     Contract_Cases => (Target_Dir = Front_Close => Is_Target_Ahead'Result,
                        Target_Dir = Front_Far => Is_Target_Ahead'Result,
                        Target_Dir = Slightly_Left => Is_Target_Ahead'Result,
                        Target_Dir = Slightly_Right => Is_Target_Ahead'Result,
                        others => Is_Target_Ahead'Result = False);




   function Is_Target_Front (Target_Dir : Target_Direction)
                             return Boolean
     with Global => null,
     Contract_Cases => (Target_Dir = Front_Close => Is_Target_Front'Result,
                        Target_Dir = Front_Far => Is_Target_Front'Result,
                        others => Is_Target_Front'Result = False);




   function Is_Target_Left (Target_Dir : Target_Direction)
                            return Boolean
     with Global => null,
     Contract_Cases => (Target_Dir = Left => Is_Target_Left'Result,
                        Target_Dir = Slightly_Left => Is_Target_Left'Result,
                        others => Is_Target_Left'Result = False);




   function Is_Target_Right (Target_Dir : Target_Direction)
                             return Boolean
     with Global => null,
     Contract_Cases => (Target_Dir = Right => Is_Target_Right'Result,
                        Target_Dir = Slightly_Right => Is_Target_Right'Result,
                        others => Is_Target_Right'Result = False);
end Prox_Sensors;
