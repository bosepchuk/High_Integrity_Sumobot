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


with System.Storage_Elements;
with MicroBit.Time;
with View.Display;


package body Last_Chance_Handler is




   procedure Last_Chance_Handler
     (Msg : System.Address; Line : Integer)
   is
      --  This code is roughly based on the answer here:
      --  https://stackoverflow.com/questions/47275867/printing-the-exception-message-in-an-ada-last-chance-handler
      use System.Storage_Elements; -- make "+" visible for System.Address

      Addr : System.Address;

      pragma Unreferenced (Line);
   begin
      loop --  loop forever
         Addr := Msg;
         while Peek (Addr) /= ASCII.NUL loop
            View.Display.Write (Peek (Addr));
            MicroBit.Time.Delay_Ms (900);
            Addr := Addr + 1;
         end loop;
         View.Display.Write (' ');
         MicroBit.Time.Delay_Ms (1500);
      end loop;
   end Last_Chance_Handler;




   function Peek (Addr : System.Address) return Character
   is
      C : Character with Address => Addr;
   begin
      return C;
   end Peek;
end Last_Chance_Handler;
