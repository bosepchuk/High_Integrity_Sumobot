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


with Model;


private package Controller.Utils with SPARK_Mode => On is
   use type Model.States;




   procedure Loop_Forever_On_Error (Has_Error : in Boolean := True)
     with Global => null;




   procedure Reset_First_Scan_Of_Match (Current_State : in Model.States;
                                        Is_First_Scan_Of_Match : in out Boolean)
     with Global => null,
     Depends => (Is_First_Scan_Of_Match =>+ (Current_State)),
     Contract_Cases =>
       (Current_State = Model.Waiting => Is_First_Scan_Of_Match,
        others => Is_First_Scan_Of_Match'Old = Is_First_Scan_Of_Match);
end Controller.Utils;
