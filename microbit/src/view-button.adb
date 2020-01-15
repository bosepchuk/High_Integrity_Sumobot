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


package body View.Button with SPARK_Mode => On is




   procedure Clear (This : out Button_Type) is
   begin
      This.Is_Button_Pressed := False;
      This.Position := Off;
   end Clear;




   function Is_Momentarily_Pressed (State : in MicroBit.Buttons.Button_State)
                                    return Boolean is
      use type MicroBit.Buttons.Button_State;
   begin
      return State = MicroBit.Buttons.Pressed;
   end Is_Momentarily_Pressed;




   function Is_Pressed (This : in Button_Type) return Boolean is
   begin
      return This.Position = On;
   end Is_Pressed;




   procedure Poll (Is_Momentarily_Pressed : in Boolean;
                   This : in out Button_Type) is
   begin
      --  Because the microbit buttons are momentary and run in a loop we
      --  need the button to be pressed and then released to
      --  consider it 'pressed.'
      if Is_Momentarily_Pressed then
         This.Is_Button_Pressed := True;
      elsif not Is_Momentarily_Pressed and This.Is_Button_Pressed then
         --  If the button is not pressed right now but was pressed before
         --  we can consider the button pressed and released aka 'pressed'.
         This.Position := On;
         This.Is_Button_Pressed := False;
      end if;
   end Poll;
end View.Button;
