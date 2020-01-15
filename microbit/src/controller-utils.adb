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


package body Controller.Utils with SPARK_Mode => On is




   procedure Loop_Forever_On_Error (Has_Error : in Boolean := True)
     with SPARK_Mode => Off is
      --  Spark complains that this subprogram has no effect, which is sort
      --  of true--but also intentional--so I've turned spark off here.
   begin
      if Has_Error then
         loop
            --  Normally, I'd want the bot to recover from errors. But since
            --  this is a prototype system under development, I'd rather the
            --  bot fails loudly by stopping all activity on any error.
            --
            --  You must cycle power the zumo's power switch to clear the error.
            null;
         end loop;
      end if;
   end Loop_Forever_On_Error;




   procedure Reset_First_Scan_Of_Match (Current_State : in Model.States;
                                        Is_First_Scan_Of_Match : in out Boolean)
   is
   begin
      if Current_State = Model.Waiting then
         --  Reset the flag every time the bot is in the Waiting state (the
         --  state immediately before the match begins).
         Is_First_Scan_Of_Match := True;
      end if;
   end Reset_First_Scan_Of_Match;
end Controller.Utils;
