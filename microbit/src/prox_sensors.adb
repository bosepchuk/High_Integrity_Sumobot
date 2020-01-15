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


package body Prox_Sensors with SPARK_Mode => On is




   function Is_Target_Ahead (Target_Dir : Target_Direction)
                             return Boolean is
   begin
      return Target_Dir = Slightly_Left or
        Target_Dir = Slightly_Right or
        Is_Target_Front (Target_Dir);
   end Is_Target_Ahead;




   function Is_Target_Front (Target_Dir : Target_Direction)
                             return Boolean is
   begin
      return Target_Dir = Front_Close or Target_Dir = Front_Far;
   end Is_Target_Front;




   function Is_Target_Left (Target_Dir : Target_Direction)
                            return Boolean is
   begin
      return Target_Dir = Slightly_Left or Target_Dir = Left;
   end Is_Target_Left;




   function Is_Target_Right (Target_Dir : Target_Direction)
                             return Boolean is
   begin
      return Target_Dir = Slightly_Right or Target_Dir = Right;
   end Is_Target_Right;
end Prox_Sensors;
