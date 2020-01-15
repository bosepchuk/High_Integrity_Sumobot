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


with MicroBit.Display;


package body View.Display with SPARK_Mode => Off is
   Previous_Char : Character;




   procedure Scroll (Int : in Integer) is
   begin
      Scroll (Int'Image);
   end Scroll;




   procedure Scroll (Text : in String) is
   begin
      MicroBit.Display.Display (Text);
   end Scroll;




   procedure Write (Char : in Character) is
   begin
      if Previous_Char /= Char then
         MicroBit.Display.Clear;
      end if;
      MicroBit.Display.Display (Char);
      Previous_Char := Char;
   end Write;
end View.Display;
