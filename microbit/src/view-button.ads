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


--  Model a microbit button where a press and release are
--  required to consider a button 'pressed.'
--
--  How to use:
--  Create a Button_Type variable.
--  Call the Poll procedure in your main loop like this:
--  Poll (Is_Momentarily_Pressed (MicroBit.Buttons.State (MicroBit.Buttons.Button_B)), Button_B);
--  Then call "Is_Pressed (Button_B)" whenever you want to know the state of the button.
--  And call Clear (Button_B) to clear the state.
--
--  See the unit tests for more details of how this package behaves.


with MicroBit.Buttons;


package View.Button with SPARK_Mode => On is
   type Button_Type is private;




   procedure Clear (This : out Button_Type)
     with Global => null,
     Depends => (This => null);




   --  Returns True if the button is pressed.
   --
   --  This function exists to create a test point that allows the rest of the
   --  package to be tested without the actual button hardware.
   function Is_Momentarily_Pressed (State : in MicroBit.Buttons.Button_State)
                                    return Boolean
     with Global => null;




   function Is_Pressed (This : in Button_Type) return Boolean
     with Global => null;




   procedure Poll (Is_Momentarily_Pressed : in Boolean;
                   This : in out Button_Type)
     with Global => null,
     Depends => (This =>+ Is_Momentarily_Pressed);




private
   type Button_Position is (On, Off);
   type Button_Type is
      record
         --  Changing the Button_Position occurs in two steps.
         --  First, the button has to be pressed and then it must be released.
         --  This variable keeps track of whether or not the button has been
         --  pressed.
         Is_Button_Pressed : Boolean := False;
         Position : Button_Position := Off;
      end record;
end View.Button;
