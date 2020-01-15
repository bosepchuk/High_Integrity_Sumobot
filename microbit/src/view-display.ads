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


--  Controls the 5x5 LED display on the microbit.


package View.Display with SPARK_Mode => On is




   --  Scroll Int across the display.
   --  WARNING: this procedure blocks I2C IO. Only use for debugging.
   procedure Scroll (Int : in Integer)
     with Global => null;




   --  Scroll Text across the display.
   --  WARNING: this procedure blocks I2C IO. Only use for debugging.
   procedure Scroll (Text : in String)
     with Global => null;




   --  Write Char to the display (clearing the display is necessary first).
   procedure Write (Char : in Character)
     with Global => null;
end View.Display;
