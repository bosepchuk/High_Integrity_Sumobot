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
with View.Motors.Utils;


package body View.Motors.Utils_Tests with SPARK_Mode => Off is




   function Convert_Left_Speed_Test return Natural is
      Num_Assertions : Natural := 0;
   begin
      pragma Assert (View.Motors.Utils.Convert_Left_Speed (-50) = 0);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (View.Motors.Utils.Convert_Left_Speed (0) = 50);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (View.Motors.Utils.Convert_Left_Speed (50) = 100);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Convert_Left_Speed_Test;




   function Convert_Right_Speed_Test return Natural is
      Num_Assertions : Natural := 0;
   begin
      pragma Assert (View.Motors.Utils.Convert_Right_Speed (-50) = 110);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (View.Motors.Utils.Convert_Right_Speed (0) = 160);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (View.Motors.Utils.Convert_Right_Speed (50) = 210);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Convert_Right_Speed_Test;
end View.Motors.Utils_Tests;
