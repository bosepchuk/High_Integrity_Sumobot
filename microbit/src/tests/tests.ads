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


--  How to use:
--    Set Is_Unit_Tests := True in main.adb, flash the microbit, and the
--    test suite will run on the microbit.
--
--
--  TODO replace homemade test suite with gnattest
--
--  I'm well aware of the existence of gnattest and it was my first
--  choice for this project's testing needs. However, I couldn't get it to
--  work with the microbit no matter what I tried
--  (see: https://stackoverflow.com/questions/59364077/how-do-i-make-gnattest-
--  only-consider-code-in-my-src-dir).
--
--  Since having no tests was unacceptable to me, I rolled my own test suite
--  (with all the ugliness that entails).
package Tests with SPARK_Mode => On is




   --  Returns the number of assertions tested or throws an exception
   --  on the first failed assertion.
   function Run return Natural;
end Tests;
