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


with Battery_Tests;
with Controller.Utils_Tests;
with Line_Sensors_Tests;
with Model;
with Model_Tests;
with Model.Utils_Tests;
with Payload_Tests;
with Prox_Sensors_Tests;
with View.Button_Tests;
with View.Motors;
with View.Motors.Utils_Tests;


package body Tests with SPARK_Mode => Off is




   function Run return Natural is
      Num : Natural := 0;  -- The number of assertions tested
   begin
      --  Order tests alphabetically (by package then test name).
      Num := Num + Battery_Tests.Get_Status_Test;

      Num := Num + Controller.Utils_Tests.Reset_First_Scan_Of_Match_Test;

      Num := Num + Line_Sensors_Tests.Is_Line_Test;

      Num := Num + Model.Utils_Tests.Change_State_Test;
      Num := Num + Model.Utils_Tests.Get_Countdown_Test;
      Num := Num + Model.Utils_Tests.Get_Initial_Scan_Direction_Test;
      Num := Num + Model.Utils_Tests.Get_Pausing_Char_Test;
      Num := Num + Model.Utils_Tests.Should_Ram_Test;

      Num := Num + Model_Tests.Combine_Speeds_Test;
      Num := Num + Model_Tests.Get_Display_Char_Test;
      Num := Num + Model_Tests.Get_Line_Detected_Direction_Test;
      Num := Num + Model_Tests.Get_Next_Move_Part_One_Test;
      Num := Num + Model_Tests.Get_Next_Move_Part_Two_Test;
      Num := Num + Model_Tests.Has_Too_Many_Parse_Errors_Test;
      Num := Num + Model_Tests.Set_Initial_Scan_Direction_Test;
      Num := Num + Model_Tests.Time_In_This_State_Test;

      Num := Num + Payload_Tests.Parse_All_Different_Values_Test;
      Num := Num + Payload_Tests.Parse_All_Max_Values_Test;
      Num := Num + Payload_Tests.Parse_All_Zeros_Test;
      Num := Num + Payload_Tests.Parse_Bad_Checksum_Test;
      Num := Num + Payload_Tests.Parse_Single_Out_Of_Range_Value_Test;
      Num := Num + Payload_Tests.Parse_Too_Little_Data_Test;
      Num := Num + Payload_Tests.Parse_Too_Much_Data_Test;

      Num := Num + Prox_Sensors_Tests.Is_Target_Ahead_Test;
      Num := Num + Prox_Sensors_Tests.Is_Target_Front_Test;
      Num := Num + Prox_Sensors_Tests.Is_Target_Left_Test;
      Num := Num + Prox_Sensors_Tests.Is_Target_Right_Test;

      Num := Num + View.Button_Tests.Tests;

      Num := Num + View.Motors.Utils_Tests.Convert_Left_Speed_Test;
      Num := Num + View.Motors.Utils_Tests.Convert_Right_Speed_Test;
      return Num;
   end Run;
end Tests;
