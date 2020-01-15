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


with MicroBit.Time;
with Battery;
with Line_Sensors;
with Model;
with Prox_Sensors;


package Model_Tests with SPARK_Mode => On is




   function Combine_Speeds_Test return Natural;
   function Get_Display_Char_Test return Natural;
   function Get_Line_Detected_Direction_Test return Natural;
   function Get_Next_Move_Part_One_Test return Natural;
   function Get_Next_Move_Part_Two_Test return Natural;
   function Has_Too_Many_Parse_Errors_Test return Natural;
   function Set_Initial_Scan_Direction_Test return Natural;
   function Time_In_This_State_Test return Natural;




   --  Initializes the state variables for the Get_Next_Move_Part_XXX_Test tests.
   procedure Init_State (Button_B_Is_Pressed : in Boolean;
                         Clock_Ms : in MicroBit.Time.Time_Ms;
                         Battery_Status : in Battery.Status;
                         Target_Dir : in Prox_Sensors.Target_Direction;
                         Line_Dir : in Line_Sensors.Line_Detected_Direction;
                         Scan_Dir : in Model.Scan_Direction;
                         Current_State : in Model.States;
                         S_In : out Model.State_In_Record;
                         S_In_Out : out Model.State_In_Out_Record);
end Model_Tests;
