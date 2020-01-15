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


with Prox_Sensors;


package body Prox_Sensors_Tests with SPARK_Mode => Off is




   function Is_Target_Ahead_Test return Natural is
      Num_Assertions : Natural := 0;
      Sub : Prox_Sensors.Target_Direction;
   begin
      --  Check all the options.
      Sub := Prox_Sensors.Unknown;
      pragma Assert (Prox_Sensors.Is_Target_Ahead (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Left;
      pragma Assert (Prox_Sensors.Is_Target_Ahead (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Slightly_Left;
      pragma Assert (Prox_Sensors.Is_Target_Ahead (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Front_Close;
      pragma Assert (Prox_Sensors.Is_Target_Ahead (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Front_Far;
      pragma Assert (Prox_Sensors.Is_Target_Ahead (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Slightly_Right;
      pragma Assert (Prox_Sensors.Is_Target_Ahead (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Right;
      pragma Assert (Prox_Sensors.Is_Target_Ahead (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Is_Target_Ahead_Test;




   function Is_Target_Front_Test return Natural is
      Num_Assertions : Natural := 0;
      Sub : Prox_Sensors.Target_Direction;
   begin
      --  Check all the options.
      Sub := Prox_Sensors.Unknown;
      pragma Assert (Prox_Sensors.Is_Target_Front (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Left;
      pragma Assert (Prox_Sensors.Is_Target_Front (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Slightly_Left;
      pragma Assert (Prox_Sensors.Is_Target_Front (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Front_Close;
      pragma Assert (Prox_Sensors.Is_Target_Front (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Front_Far;
      pragma Assert (Prox_Sensors.Is_Target_Front (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Slightly_Right;
      pragma Assert (Prox_Sensors.Is_Target_Front (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Right;
      pragma Assert (Prox_Sensors.Is_Target_Front (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Is_Target_Front_Test;




   function Is_Target_Left_Test return Natural is
      Num_Assertions : Natural := 0;
      Sub : Prox_Sensors.Target_Direction;
   begin
      --  Check all the options.
      Sub := Prox_Sensors.Unknown;
      pragma Assert (Prox_Sensors.Is_Target_Left (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Left;
      pragma Assert (Prox_Sensors.Is_Target_Left (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Slightly_Left;
      pragma Assert (Prox_Sensors.Is_Target_Left (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Front_Close;
      pragma Assert (Prox_Sensors.Is_Target_Left (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Front_Far;
      pragma Assert (Prox_Sensors.Is_Target_Left (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Slightly_Right;
      pragma Assert (Prox_Sensors.Is_Target_Left (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Right;
      pragma Assert (Prox_Sensors.Is_Target_Left (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Is_Target_Left_Test;




   function Is_Target_Right_Test return Natural is
      Num_Assertions : Natural := 0;
      Sub : Prox_Sensors.Target_Direction;
   begin
      --  Check all the options.
      Sub := Prox_Sensors.Unknown;
      pragma Assert (Prox_Sensors.Is_Target_Right (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Left;
      pragma Assert (Prox_Sensors.Is_Target_Right (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Slightly_Left;
      pragma Assert (Prox_Sensors.Is_Target_Right (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Front_Close;
      pragma Assert (Prox_Sensors.Is_Target_Right (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Front_Far;
      pragma Assert (Prox_Sensors.Is_Target_Right (Sub) = False);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Slightly_Right;
      pragma Assert (Prox_Sensors.Is_Target_Right (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      Sub := Prox_Sensors.Right;
      pragma Assert (Prox_Sensors.Is_Target_Right (Sub) = True);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Is_Target_Right_Test;
end Prox_Sensors_Tests;
