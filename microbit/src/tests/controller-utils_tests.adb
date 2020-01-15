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


with HAL; use HAL;
with Controller.Utils;
with Model;


package body Controller.Utils_Tests with SPARK_Mode => Off is




   function Reset_First_Scan_Of_Match_Test return Natural is
      Num_Assertions : Natural := 0;
      Is_First_Scan_Of_Match : Boolean;
   begin

      --  Is_First_Scan_Of_Match is set to True only when
      --  Current_State = Waiting.
      Is_First_Scan_Of_Match := False;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Battery_Critical, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match = False);
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := False;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Pausing, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match = False);
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := False;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Waiting, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match); --  This is the only case the value becomes True
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := False;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Scanning, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match = False);
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := False;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Driving, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match = False);
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := False;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Reversing, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match = False);
      Num_Assertions := Num_Assertions + 1;


      --  But if you start with Is_First_Scan_Of_Match = True, it stays
      --  that way no matter what.
      Is_First_Scan_Of_Match := True;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Battery_Critical, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match);
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := True;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Pausing, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match);
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := True;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Waiting, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match);
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := True;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Scanning, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match);
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := True;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Driving, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match);
      Num_Assertions := Num_Assertions + 1;

      Is_First_Scan_Of_Match := True;
      Controller.Utils.Reset_First_Scan_Of_Match (Model.Reversing, Is_First_Scan_Of_Match);
      pragma Assert (Is_First_Scan_Of_Match);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Reset_First_Scan_Of_Match_Test;
end Controller.Utils_Tests;
