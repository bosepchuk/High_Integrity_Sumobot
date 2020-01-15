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


package Line_Sensors with SPARK_Mode => On is
   type Line_Sensor_Byte is new Integer range 0 .. 255;
   subtype Line_Sensor_Type is Line_Sensor_Byte range 0 .. 200; --  White to black

   type Line_Detected_Direction is (Left, Center, Right, None);

   --  Anything less than this value is considered a line (such as
   --  the white border of the sumo ring).
   Line_Sensor_Threshold : constant Line_Sensor_Type := 30;




   --  Returns True if a line is detected for Line_Sensor_Reading.
   function Is_Line (Line_Sensor_Value : in Line_Sensor_Type) return Boolean
     with Global => null,
     Contract_Cases => (Line_Sensor_Value < Line_Sensor_Threshold => Is_Line'Result,
                        others => Is_Line'Result = False);
end Line_Sensors;
