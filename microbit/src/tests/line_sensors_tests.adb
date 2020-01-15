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


with Line_Sensors;


package body Line_Sensors_Tests with SPARK_Mode => Off is




   function Is_Line_Test return Natural is
      use type Line_Sensors.Line_Sensor_Type;
      Num_Assertions : Natural := 0;
   begin
      --  29 is a line.
      pragma Assert (Line_Sensors.Is_Line (Line_Sensors.Line_Sensor_Threshold - 1));
      Num_Assertions := Num_Assertions + 1;

      --  30 is not a line.
      pragma Assert (Line_Sensors.Is_Line (Line_Sensors.Line_Sensor_Threshold) = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Is_Line_Test;
end Line_Sensors_Tests;
