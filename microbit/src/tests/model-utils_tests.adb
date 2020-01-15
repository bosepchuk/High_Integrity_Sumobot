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
with Model;
with Model.Utils;


package body Model.Utils_Tests with SPARK_Mode => Off is




   function Change_State_Test return Natural is
      Num_Assertions : Natural := 0;
      New_State : Model.States;
      S_In : Model.State_In_Record;
      S_In_Out : Model.State_In_Out_Record;
   begin
      S_In_Out.Current_State := Model.Pausing;
      S_In_Out.State_Start_Time := 0;

      --  Confirm initial state.
      pragma Assert (S_In_Out.Current_State = Model.Pausing);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (S_In_Out.State_Start_Time = 0);
      Num_Assertions := Num_Assertions + 1;

      --  Change state.
      New_State := Model.Waiting;
      S_In.Clock_Ms := 10;
      Model.Utils.Change_State (New_State, S_In, S_In_Out);

      --  Confirm the state changed.
      pragma Assert (S_In_Out.Current_State = New_State);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (S_In_Out.State_Start_Time = S_In.Clock_Ms);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Change_State_Test;




   function Get_Countdown_Test return Natural is
      Num_Assertions : Natural := 0;
      Wait_Time : constant MicroBit.Time.Time_Ms := 5000;
   begin
      --  Check all the boundaries.
      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 0) = '5');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 999) = '5');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 1000) = '4');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 1999) = '4');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 2000) = '3');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 2999) = '3');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 3000) = '2');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 3999) = '2');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 4000) = '1');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 4999) = '1');
      Num_Assertions := Num_Assertions + 1;

      --  Correctly handles Time > Wait_Time.
      pragma Assert (Model.Utils.Get_Countdown (Wait_Time, 6000) = '1');
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Get_Countdown_Test;




   function Get_Initial_Scan_Direction_Test return Natural is
      Num_Assertions : Natural := 0;
      Scan_Dir : Model.Scan_Direction;
   begin
      Scan_Dir := Model.Utils.Get_Initial_Scan_Direction (Prox_Sensors.Unknown);
      pragma Assert (Scan_Dir = Model.Left);
      Num_Assertions := Num_Assertions + 1;

      Scan_Dir := Model.Utils.Get_Initial_Scan_Direction (Prox_Sensors.Left);
      pragma Assert (Scan_Dir = Model.Left);
      Num_Assertions := Num_Assertions + 1;

      Scan_Dir := Model.Utils.Get_Initial_Scan_Direction (Prox_Sensors.Slightly_Left);
      pragma Assert (Scan_Dir = Model.Left);
      Num_Assertions := Num_Assertions + 1;

      Scan_Dir := Model.Utils.Get_Initial_Scan_Direction (Prox_Sensors.Front_Close);
      pragma Assert (Scan_Dir = Model.Straight);
      Num_Assertions := Num_Assertions + 1;

      Scan_Dir := Model.Utils.Get_Initial_Scan_Direction (Prox_Sensors.Front_Far);
      pragma Assert (Scan_Dir = Model.Straight);
      Num_Assertions := Num_Assertions + 1;

      Scan_Dir := Model.Utils.Get_Initial_Scan_Direction (Prox_Sensors.Slightly_Right);
      pragma Assert (Scan_Dir = Model.Right);
      Num_Assertions := Num_Assertions + 1;

      Scan_Dir := Model.Utils.Get_Initial_Scan_Direction (Prox_Sensors.Right);
      pragma Assert (Scan_Dir = Model.Right);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Get_Initial_Scan_Direction_Test;




   function Get_Pausing_Char_Test return Natural is
      Num_Assertions : Natural := 0;
   begin

      pragma Assert (Model.Utils.Get_Pausing_Char (Battery.Ok) = 'P');
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Get_Pausing_Char (Battery.Low) = 'B');
      Num_Assertions := Num_Assertions + 1;

      --  Critical battery voltages are handled in another part of the
      --  code. So, returning 'P' here is reasonable.
      pragma Assert (Model.Utils.Get_Pausing_Char (Battery.Critical) = 'P');
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Get_Pausing_Char_Test;




   function Should_Ram_Test return Natural is
      Num_Assertions : Natural := 0;
   begin
      --  5999 ms (should never ram).
      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Unknown, 5999) = False);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Left, 5999) = False);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Slightly_Left, 5999) = False);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Front_Close, 5999));
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Front_Far, 5999) = False);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Slightly_Right, 5999) = False);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Right, 5999) = False);
      Num_Assertions := Num_Assertions + 1;


      --  6000 ms (should ram if target is "ahead").
      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Unknown, 6000) = False);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Left, 6000) = False);
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Slightly_Left, 6000));
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Front_Close, 6000));
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Front_Far, 6000));
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Slightly_Right, 6000));
      Num_Assertions := Num_Assertions + 1;

      pragma Assert (Model.Utils.Should_Ram (Prox_Sensors.Right, 6000) = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Should_Ram_Test;
end Model.Utils_Tests;
