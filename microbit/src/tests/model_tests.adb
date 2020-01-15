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
with Payload;
with View.Motors;


package body Model_Tests with SPARK_Mode => Off is




   function Combine_Speeds_Test return Natural is
      use type View.Motors.Motor_Speed;
      use type View.Motors.Motor_Speeds;
      Num_Assertions : Natural := 0;
      Motor_Speeds : View.Motors.Motor_Speeds;
   begin
      Motor_Speeds.Left := -50;
      Motor_Speeds.Right := 50;
      pragma Assert (Model.Combine_Speeds (-50, 50) = Motor_Speeds);
      Num_Assertions := Num_Assertions + 1;

      Motor_Speeds.Left := 50;
      Motor_Speeds.Right := -50;
      pragma Assert (Model.Combine_Speeds (50, -50) = Motor_Speeds);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Combine_Speeds_Test;




   function Get_Display_Char_Test return Natural is
      use type Model.States;
      Num_Assertions : Natural := 0;
      S_In : Model.State_In_Record;
      S_In_Out : Model.State_In_Out_Record;
   begin
      --  The following line silences a warning about S_In
      --  being 'read but never assigned'.
      S_In.Button_B_Is_Pressed := False;

      S_In_Out.Current_State := Model.Battery_Critical;
      pragma Assert (Model.Get_Display_Char (S_In, S_In_Out) = 'C');
      Num_Assertions := Num_Assertions + 1;

      --  Pausing is tested in Model_Utils_Tests.Get_Pausing_Char_Test.

      --  Waiting is tested in Model_Utils_Tests.Get_Countdown_Test.

      S_In_Out.Current_State := Model.Scanning;
      pragma Assert (Model.Get_Display_Char (S_In, S_In_Out) = 'S');
      Num_Assertions := Num_Assertions + 1;

      S_In_Out.Current_State := Model.Driving;
      pragma Assert (Model.Get_Display_Char (S_In, S_In_Out) = 'D');
      Num_Assertions := Num_Assertions + 1;

      S_In_Out.Current_State := Model.Reversing;
      pragma Assert (Model.Get_Display_Char (S_In, S_In_Out) = 'R');
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Get_Display_Char_Test;




   function Get_Line_Detected_Direction_Test return Natural is
      use type Line_Sensors.Line_Detected_Direction;
      Num_Assertions : Natural := 0;
      Sensors : Payload.Payload;
   begin

      --  Returns Left when all the line sensors are triggered.
      Sensors.Line_Left := 0;
      Sensors.Line_Center := 0;
      Sensors.Line_Right := 0;
      pragma Assert (Model.Get_Line_Detected_Direction (Sensors) = Line_Sensors.Left);
      Num_Assertions := Num_Assertions + 1;

      --  Returns Right when the Center and Left line sensors are triggered.
      Sensors.Line_Left := 200;
      Sensors.Line_Center := 0;
      Sensors.Line_Right := 0;
      pragma Assert (Model.Get_Line_Detected_Direction (Sensors) = Line_Sensors.Right);
      Num_Assertions := Num_Assertions + 1;

      --  Returns Center only when it's the only line sensors that is triggered.
      Sensors.Line_Left := 200;
      Sensors.Line_Center := 0;
      Sensors.Line_Right := 200;
      pragma Assert (Model.Get_Line_Detected_Direction (Sensors) = Line_Sensors.Center);
      Num_Assertions := Num_Assertions + 1;

      --  Returns None if no line sensors are triggered.
      Sensors.Line_Left := 200;
      Sensors.Line_Center := 200;
      Sensors.Line_Right := 200;
      pragma Assert (Model.Get_Line_Detected_Direction (Sensors) = Line_Sensors.None);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Get_Line_Detected_Direction_Test;




   --  Testing the "Model.Get_Next_Move" code is complicated. Hand crafting
   --  the test cases is problematic.
   --    How does one know how many test cases are required?
   --    How does one know if a test case is missing or duplicated?
   --
   --  My solution was to use ACTS (free software released by NIST to help
   --  software developers write test cases for combinatoric testing) to
   --  programatically generate my test cases.
   --
   --  See: https://csrc.nist.gov/projects/automated-combinatorial-testing-for-software
   --
   --  Test cases required for various scenarios:
   --    - exhaustive testing: infinite
   --    - exhaustive testing with equivalence classes: 30,240
   --    - initial 6-way coverage: 15,120
   --    - 6-way coverage with constraints: 56
   --
   --  Here's what I did:
   --    - broke my inputs into equivalence classes (for example, only
   --        testing number boundaries).
   --    - entered my inputs into ACTS.
   --    - then added constraints to eliminate test cases that wouldn't be
   --    - helpful (for example, the reversing state doesn't read the line
   --        sensors so having test cases for each of the line sensors while
   --        reversing is of limited value).
   --    - I kept adding constraints until I was left with a tractable and
   --        effective set of test cases (note: it's much easier to review a
   --        handful of constraints than it is to manually review over 50 test
   --        cases looking for missing or duplicated test).
   --    - Then I exported them from ACTS and pasted them into the test
   --        suite.
   --    - Finally, I evaluated each test case by hand and wrote Ada for them
   --        here so they can act as regression tests.
   --
   --  I saved the ACTS data and the exported test cases in:
   --    scr/tests/acts_test_case_generation_tool/
   --
   --  Note: I arbitrarily broke these tests into two parts because the
   --  microbit was completely unresponsive when I had them all
   --  in one function. I don't know why splitting the code into two
   --  functions works but it does.
   function Get_Next_Move_Part_One_Test return Natural is
      use Battery;
      use Line_Sensors;
      use Model;
      use Prox_Sensors;
      use View.Motors;
      Num_Assertions : Natural := 0;
      S_In : Model.State_In_Record;
      S_In_Out : Model.State_In_Out_Record;
   begin


      --  false,199,Ok,Unknown,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 199,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 199);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (1, 2));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Unknown,None,Left,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Left,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Keep scanning for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (-Scan_Speed_Fast, Scan_Speed_Fast));
      Num_Assertions := Num_Assertions + 4;


      --  true,200,Ok,Unknown,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => True,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Pausing);
      pragma Assert (S_In_Out.State_Start_Time = 200);
      --  Stop the motors when entering the pausing state.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Unknown,None,Right,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Right,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Right);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Keep scanning for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Scan_Speed_Fast, -Scan_Speed_Fast));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Critical,Unknown,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Critical,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Battery_Critical);
      pragma Assert (S_In_Out.State_Start_Time = 200);
      --  Stop everything because the battery is critical.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Left,None,Left,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Left,
                  Line_Dir            => None,
                  Scan_Dir            => Left,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan left for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (-Scan_Speed, Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Left,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Left,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan left for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (-Scan_Speed, Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Left,None,Right,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Left,
                  Line_Dir            => None,
                  Scan_Dir            => Right,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan left for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (-Scan_Speed, Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Front_Close,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Front_Close,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 200);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (1, 2));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Right,None,Left,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Right,
                  Line_Dir            => None,
                  Scan_Dir            => Left,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Right);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan right for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Scan_Speed, -Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Right,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Right,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Right);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan right for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Scan_Speed, -Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Right,None,Right,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 200,
                  Battery_Status      => Ok,
                  Target_Dir          => Right,
                  Line_Dir            => None,
                  Scan_Dir            => Right,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Right);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan right for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Scan_Speed, -Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,219,Ok,Unknown,None,Straight,Reversing
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 219,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Reversing,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Reversing);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Reverse blindly.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Reverse_Speed, Reverse_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  true,220,Ok,Unknown,None,Straight,Reversing
      Init_State (Button_B_Is_Pressed => True,
                  Clock_Ms            => 220,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Reversing,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Pausing);
      pragma Assert (S_In_Out.State_Start_Time = 220);
      --  Stop the motors when entering the pausing state.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,220,Critical,Unknown,None,Straight,Reversing
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 220,
                  Battery_Status      => Critical,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Reversing,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Battery_Critical);
      pragma Assert (S_In_Out.State_Start_Time = 220);
      --  Stop everything because the battery is critical.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Unknown,None,Left,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Left,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Keep scanning for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (-Scan_Speed_Fast, Scan_Speed_Fast));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Unknown,None,Left,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Left,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Keep scanning for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (-Scan_Speed_Fast, Scan_Speed_Fast));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Unknown,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 1300);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (1, 2));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Unknown,None,Right,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Right,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Right);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Keep scanning for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Scan_Speed_Fast, -Scan_Speed_Fast));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Left,None,Left,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Left,
                  Line_Dir            => None,
                  Scan_Dir            => Left,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan left for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (-Scan_Speed, Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Left,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Left,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan left for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (-Scan_Speed, Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Left,None,Right,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Left,
                  Line_Dir            => None,
                  Scan_Dir            => Right,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan left for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (-Scan_Speed, Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Front_Close,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Front_Close,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 1300);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (1, 2));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Right,None,Left,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Right,
                  Line_Dir            => None,
                  Scan_Dir            => Left,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Right);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan right for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Scan_Speed, -Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,1300,Ok,Right,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Right,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Right);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan right for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Scan_Speed, -Scan_Speed));
      Num_Assertions := Num_Assertions + 4;




      return Num_Assertions;
   end Get_Next_Move_Part_One_Test;




   --  See: documentation for Get_Next_Move_Part_One_Test
   function Get_Next_Move_Part_Two_Test return Natural is
      use Battery;
      use Line_Sensors;
      use Model;
      use View.Motors;
      use Prox_Sensors;
      Num_Assertions : Natural := 0;
      S_In : Model.State_In_Record;
      S_In_Out : Model.State_In_Out_Record;
   begin
      --  false,1300,Ok,Right,None,Right,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1300,
                  Battery_Status      => Ok,
                  Target_Dir          => Right,
                  Line_Dir            => None,
                  Scan_Dir            => Right,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Right);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Scan right for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Scan_Speed, -Scan_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  true,1301,Ok,Unknown,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => True,
                  Clock_Ms            => 1301,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Pausing);
      pragma Assert (S_In_Out.State_Start_Time = 1301);
      --  Stop the motors when entering the pausing state.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,1301,Critical,Unknown,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1301,
                  Battery_Status      => Critical,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Battery_Critical);
      pragma Assert (S_In_Out.State_Start_Time = 1301);
      --  Stop everything because the battery is critical.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,1999,Ok,Unknown,None,Straight,Waiting
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1999,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Waiting,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Waiting);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Motors are stopped in the waiting state.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  true,2000,Ok,Unknown,None,Straight,Waiting
      Init_State (Button_B_Is_Pressed => True,
                  Clock_Ms            => 2000,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Waiting,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Pausing);
      pragma Assert (S_In_Out.State_Start_Time = 2000);
      --  Stop the motors when entering the pausing state.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,2000,Critical,Unknown,None,Straight,Waiting
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 2000,
                  Battery_Status      => Critical,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Waiting,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Battery_Critical);
      pragma Assert (S_In_Out.State_Start_Time = 2000);
      --  Stop everything because the battery is critical.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,5999,Ok,Unknown,Left,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 5999,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => Left,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Right);
      pragma Assert (S_In_Out.Current_State = Reversing);
      pragma Assert (S_In_Out.State_Start_Time = 5999);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (1, 2));
      Num_Assertions := Num_Assertions + 4;


      --  false,5999,Ok,Unknown,Center,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 5999,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => Center,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Reversing);
      pragma Assert (S_In_Out.State_Start_Time = 5999);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (1, 2));
      Num_Assertions := Num_Assertions + 4;


      --  false,5999,Ok,Unknown,Right,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 5999,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => Right,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Left);
      pragma Assert (S_In_Out.Current_State = Reversing);
      pragma Assert (S_In_Out.State_Start_Time = 5999);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (1, 2));
      Num_Assertions := Num_Assertions + 4;


      --  false,5999,Ok,Unknown,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 5999,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Drive forward looking for the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Forward_Speed, Forward_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,5999,Ok,Left,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 5999,
                  Battery_Status      => Ok,
                  Target_Dir          => Left,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Veer left towards the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Veer_Speed_Slow, Veer_Speed_Very_Fast));
      Num_Assertions := Num_Assertions + 4;


      --  false,5999,Ok,Slightly_Left,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 5999,
                  Battery_Status      => Ok,
                  Target_Dir          => Slightly_Left,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Veer left towards the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Veer_Speed_Slow, Veer_Speed_Fast));
      Num_Assertions := Num_Assertions + 4;


      --  false,5999,Ok,Front_Close,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 5999,
                  Battery_Status      => Ok,
                  Target_Dir          => Front_Close,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Use ramming speed.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Ramming_Speed, Ramming_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,5999,Ok,Slightly_Right,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 5999,
                  Battery_Status      => Ok,
                  Target_Dir          => Slightly_Right,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Veer right towards the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Veer_Speed_Fast, Veer_Speed_Slow));
      Num_Assertions := Num_Assertions + 4;


      --  false,5999,Ok,Right,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 5999,
                  Battery_Status      => Ok,
                  Target_Dir          => Right,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Veer right towards the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Veer_Speed_Very_Fast, Veer_Speed_Slow));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Critical,Unknown,None,Straight,Battery_Critical
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Critical,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Battery_Critical,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Battery_Critical);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Stop everything because the battery is critical.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  true,6000,Ok,Unknown,None,Straight,Pausing
      Init_State (Button_B_Is_Pressed => True,
                  Clock_Ms            => 6000,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Pausing,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Waiting);
      pragma Assert (S_In_Out.State_Start_Time = 6000);
      --  The motors are stopped before entering the waiting state.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Low,Unknown,None,Straight,Pausing
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Low,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Pausing,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Pausing);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Motors are stopped in the pausing state.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Critical,Unknown,None,Straight,Pausing
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Critical,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Pausing,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Battery_Critical);
      pragma Assert (S_In_Out.State_Start_Time = 6000);
      --  Stop everything because the battery is critical.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  true,6000,Ok,Unknown,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => True,
                  Clock_Ms            => 6000,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Pausing);
      pragma Assert (S_In_Out.State_Start_Time = 6000);
      --  Stop the motors when entering the pausing state.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Critical,Unknown,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Critical,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Battery_Critical);
      pragma Assert (S_In_Out.State_Start_Time = 6000);
      --  Stop everything because the battery is critical.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Ok,Left,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Ok,
                  Target_Dir          => Left,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Veer left towards the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Veer_Speed_Slow, Veer_Speed_Very_Fast));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Ok,Slightly_Left,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Ok,
                  Target_Dir          => Slightly_Left,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Use ramming speed.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Ramming_Speed, Ramming_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Ok,Front_Close,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Ok,
                  Target_Dir          => Front_Close,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Use ramming speed.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Ramming_Speed, Ramming_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Ok,Slightly_Right,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Ok,
                  Target_Dir          => Slightly_Right,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Use ramming speed.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Ramming_Speed, Ramming_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Ok,Right,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Ok,
                  Target_Dir          => Right,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Veer right towards the target.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Veer_Speed_Very_Fast, Veer_Speed_Slow));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Ok,Unknown,None,Straight,Pausing
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Pausing,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Pausing);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  Motors are stopped in the pausing state.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,2000,Ok,Unknown,None,Straight,Waiting
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 2000,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Waiting,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 2000);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (0, 0));
      Num_Assertions := Num_Assertions + 4;


      --  false,1301,Ok,Unknown,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 1301,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 1301);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (1, 2));
      Num_Assertions := Num_Assertions + 4;


      --  false,220,Ok,Unknown,None,Straight,Reversing
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 220,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Reversing,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      --  It's a bit weird to have a Scan_Dir = Straight when
      --  Target_Dir = Unknown. I don't know if this can happen in the code but
      --  if it does, nothing bad will happen.
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Scanning);
      pragma Assert (S_In_Out.State_Start_Time = 220);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Reverse_Speed, Reverse_Speed));
      Num_Assertions := Num_Assertions + 4;


      --  false,200,Ok,Unknown,None,Straight,Scanning
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 220,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Scanning,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      --  It's a bit weird to have a Scan_Dir = Straight when
      --  Target_Dir = Unknown. I don't know if this can happen in the code but
      --  if it does, nothing bad will happen.
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 220);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (1, 2));
      Num_Assertions := Num_Assertions + 4;


      --  false,6000,Ok,Unknown,None,Straight,Driving
      Init_State (Button_B_Is_Pressed => False,
                  Clock_Ms            => 6000,
                  Battery_Status      => Ok,
                  Target_Dir          => Unknown,
                  Line_Dir            => None,
                  Scan_Dir            => Straight,
                  Current_State       => Driving,
                  S_In                => S_In,
                  S_In_Out            => S_In_Out);

      Model.Get_Next_Move (S_In, S_In_Out);
      --  It's a bit weird to have a Scan_Dir = Straight when
      --  Target_Dir = Unknown. I don't know if this can happen in the code but
      --  if it does, nothing bad will happen.
      pragma Assert (S_In_Out.Scan_Dir = Straight);
      pragma Assert (S_In_Out.Current_State = Driving);
      pragma Assert (S_In_Out.State_Start_Time = 0);
      --  The motors speeds will change on the next iteration.
      pragma Assert (S_In_Out.Speeds = Combine_Speeds (Forward_Speed, Forward_Speed));
      Num_Assertions := Num_Assertions + 4;

      return Num_Assertions;
   end Get_Next_Move_Part_Two_Test;




   function Has_Too_Many_Parse_Errors_Test return Natural is
      Num_Assertions : Natural := 0;
   begin
      --  Zero is the default start time. This always returns false,
      --  regardless of the time of Current_Parse_Error_Time.
      pragma Assert (Model.Has_Too_Many_Parse_Errors (0, 1) = False);
      Num_Assertions := Num_Assertions + 1;

      --  Two errors in 99 ms is NOT ok.
      pragma Assert (Model.Has_Too_Many_Parse_Errors (1, 100) = True);
      Num_Assertions := Num_Assertions + 1;

      --  Two errors in 100 ms is ok.
      pragma Assert (Model.Has_Too_Many_Parse_Errors (1, 101) = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Has_Too_Many_Parse_Errors_Test;




   function Set_Initial_Scan_Direction_Test return Natural is
      use type Model.Scan_Direction;
      use type Prox_Sensors.Target_Direction;
      Num_Assertions : Natural := 0;
      S_In : Model.State_In_Record;
      S_In_Out : Model.State_In_Out_Record;
      Is_First_Scan_Of_Match : Boolean;
   begin

      --  This is the only case where the Scan_Dir is changed. All other
      --  combinations of inputs will not change it.
      S_In.Target_Dir := Prox_Sensors.Front_Close;
      S_In_Out.Scan_Dir := Model.Right;
      S_In_Out.Current_State := Model.Scanning;
      Is_First_Scan_Of_Match := True;
      Model.Set_Initial_Scan_Direction (S_In, S_In_Out, Is_First_Scan_Of_Match);
      pragma Assert (S_In_Out.Scan_Dir = Model.Straight);
      pragma Assert (Is_First_Scan_Of_Match = False);
      Num_Assertions := Num_Assertions + 2;

      --  Scan_Dir is not changed because Is_First_Scan_Of_Match = False.
      S_In.Target_Dir := Prox_Sensors.Front_Close;
      S_In_Out.Scan_Dir := Model.Right;
      S_In_Out.Current_State := Model.Scanning;
      Is_First_Scan_Of_Match := False;
      Model.Set_Initial_Scan_Direction (S_In, S_In_Out, Is_First_Scan_Of_Match);
      pragma Assert (S_In_Out.Scan_Dir = Model.Right);
      pragma Assert (Is_First_Scan_Of_Match = False);
      Num_Assertions := Num_Assertions + 2;

      --  Scan_Dir is not changed because Current_State = Driving.
      --  Is_First_Scan_Of_Match is not changed.
      S_In.Target_Dir := Prox_Sensors.Front_Close;
      S_In_Out.Scan_Dir := Model.Right;
      S_In_Out.Current_State := Model.Driving;
      Is_First_Scan_Of_Match := True;
      Model.Set_Initial_Scan_Direction (S_In, S_In_Out, Is_First_Scan_Of_Match);
      pragma Assert (S_In_Out.Scan_Dir = Model.Right);
      pragma Assert (Is_First_Scan_Of_Match);
      Num_Assertions := Num_Assertions + 2;

      return Num_Assertions;
   end Set_Initial_Scan_Direction_Test;




   function Time_In_This_State_Test return Natural is
      Num_Assertions : Natural := 0;
      Result : MicroBit.Time.Time_Ms;
   begin
      --  Test zero ms.
      Result := Model.Time_In_This_State (State_Start_Time => 0, Clock_Ms => 0);
      pragma Assert (Result = 0);
      Num_Assertions := Num_Assertions + 1;

      --  Test 1 ms.
      Result := Model.Time_In_This_State (State_Start_Time => 0, Clock_Ms => 1);
      pragma Assert (Result = 1);
      Num_Assertions := Num_Assertions + 1;

      --  Test max possible time.
      Result := Model.Time_In_This_State (State_Start_Time => 0, Clock_Ms => MicroBit.Time.Time_Ms'Last);
      pragma Assert (Result = MicroBit.Time.Time_Ms'Last);
      Num_Assertions := Num_Assertions + 1;

      --  Test both inputs at max time.
      Result := Model.Time_In_This_State (State_Start_Time => MicroBit.Time.Time_Ms'Last,
                                          Clock_Ms => MicroBit.Time.Time_Ms'Last);
      pragma Assert (Result = 0);
      Num_Assertions := Num_Assertions + 1;

      --  Test rollover.
      Result := Model.Time_In_This_State (State_Start_Time => MicroBit.Time.Time_Ms'Last, Clock_Ms => 0);
      pragma Assert (Result = 1);
      Num_Assertions := Num_Assertions + 1;

      --  Test rollover with a longer duration.
      Result := Model.Time_In_This_State (State_Start_Time => MicroBit.Time.Time_Ms'Last, Clock_Ms => 9);
      pragma Assert (Result = 10);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Time_In_This_State_Test;




   procedure Init_State (Button_B_Is_Pressed : in Boolean;
                         Clock_Ms : in MicroBit.Time.Time_Ms;
                         Battery_Status : in Battery.Status;
                         Target_Dir : in Prox_Sensors.Target_Direction;
                         Line_Dir : in Line_Sensors.Line_Detected_Direction;
                         Scan_Dir : in Model.Scan_Direction;
                         Current_State : in Model.States;
                         S_In : out Model.State_In_Record;
                         S_In_Out : out Model.State_In_Out_Record) is
   begin
      S_In.Button_B_Is_Pressed := Button_B_Is_Pressed;
      S_In.Clock_Ms := Clock_Ms;
      S_In.Battery_Status := Battery_Status;
      S_In.Target_Dir := Target_Dir;
      S_In.Line_Dir := Line_Dir;

      S_In_Out.Scan_Dir := Scan_Dir;
      S_In_Out.Current_State := Current_State;
      S_In_Out.State_Start_Time := 0;

      --  I use a weird speed so I can detect if it is changed in the tests.
      S_In_Out.Speeds := Model.Combine_Speeds (1, 2);
   end Init_State;
end Model_Tests;
