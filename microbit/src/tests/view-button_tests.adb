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


with View.Button;


package body View.Button_Tests with SPARK_Mode => Off is




   function Tests return Natural is
      Num_Assertions : Natural := 0;
      Sub : View.Button.Button_Type;
   begin
      --  The button doesn't start pressed.
      pragma Assert (View.Button.Is_Pressed (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      --  No number of polls without a button press will make Is_Pressed = True.
      View.Button.Poll (False, Sub);
      View.Button.Poll (False, Sub);
      View.Button.Poll (False, Sub);
      pragma Assert (View.Button.Is_Pressed (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      --  Any number of polls with button presses will not make Is_Pressed = True.
      View.Button.Poll (True, Sub);
      View.Button.Poll (True, Sub);
      View.Button.Poll (True, Sub);
      pragma Assert (View.Button.Is_Pressed (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      --  The first non-press after a press makes Is_Pressed = True.
      View.Button.Poll (False, Sub);
      pragma Assert (View.Button.Is_Pressed (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      --  Is_Pressed stays true for any number of non-press polls.
      View.Button.Poll (False, Sub);
      View.Button.Poll (False, Sub);
      View.Button.Poll (False, Sub);
      pragma Assert (View.Button.Is_Pressed (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      --  Registering another press doesn't change Is_Pressed.
      View.Button.Poll (True, Sub);
      pragma Assert (View.Button.Is_Pressed (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      --  Registering a release doesn't change Is_Pressed.
      View.Button.Poll (False, Sub);
      pragma Assert (View.Button.Is_Pressed (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      --  Clearing the Button makes Is_Pressed = False.
      View.Button.Clear (Sub);
      pragma Assert (View.Button.Is_Pressed (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Tests;
end View.Button_Tests;
