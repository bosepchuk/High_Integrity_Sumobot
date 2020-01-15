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


with Last_Chance_Handler; --  Handle uncaught exceptions
pragma Unreferenced (Last_Chance_Handler);


with Controller;
with Tests;
with View.Display;


procedure Main is
   --  Set "Is_Unit_Tests := True" to run the unit tests.
   --  Build and flash to the microbit.
   --  You'll either see the number of assertions passed or the file and
   --  line number of the first assertion that failed.
   Is_Unit_Tests : constant Boolean := False;
   Num_Assertions : Natural;
begin
   if Is_Unit_Tests then
      Num_Assertions := Tests.Run;
      View.Display.Scroll (Num_Assertions);
   else
      Controller.Initialize;
      loop
         Controller.Run;
      end loop;
   end if;
end Main;
