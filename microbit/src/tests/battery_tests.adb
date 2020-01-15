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


with Battery;


package body Battery_Tests with SPARK_Mode => Off is




   function Get_Status_Test return Natural is
      use type Battery.Status;
      use type Battery.Battery_Volts_Tenths_Type;
      Num_Assertions : Natural := 0;
   begin
      --  Status = Ok, even if the voltage reported is zero.
      pragma Assert (Battery.Get_Status (1, 0) = Battery.Ok);
      Num_Assertions := Num_Assertions + 1;

      --  Status = Critical when the battery voltage is zero.
      pragma Assert (Battery.Get_Status (0, 0) = Battery.Critical);
      Num_Assertions := Num_Assertions + 1;

      --  Status = Critical when the battery voltage = the critical threshold.
      pragma Assert (Battery.Get_Status (0, Battery.Critical_Threshold) = Battery.Critical);
      Num_Assertions := Num_Assertions + 1;

      --  Status = Low when the battery voltage is 1 point above the critical threshold.
      pragma Assert (Battery.Get_Status (0, Battery.Critical_Threshold + 1) = Battery.Low);
      Num_Assertions := Num_Assertions + 1;

      --  Status = Low when the battery voltage = the low threshold.
      pragma Assert (Battery.Get_Status (0, Battery.Low_Threshold) = Battery.Low);
      Num_Assertions := Num_Assertions + 1;

      --  Status = Ok when the battery voltage is 1 point above the low threshold.
      pragma Assert (Battery.Get_Status (0, Battery.Low_Threshold + 1) = Battery.Ok);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Get_Status_Test;
end Battery_Tests;
