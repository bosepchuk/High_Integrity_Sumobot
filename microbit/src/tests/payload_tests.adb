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


with HAL.I2C;
with Battery;
with Line_Sensors;
with Payload;
with Prox_Sensors;


package body Payload_Tests with SPARK_Mode => Off is




   function Parse_All_Different_Values_Test return Natural is
      use type Prox_Sensors.Prox_Sensor_Type;
      use type Line_Sensors.Line_Sensor_Type;
      use type Battery.Battery_Volts_Tenths_Type;
      use type Battery.Is_Usb_Present_Type;
      Num_Assertions : Natural := 0;
      Sub : constant HAL.I2C.I2C_Data := (2, 3, 4, 5, 6, 7, 8, 9, 1, 45);
      Zumo_Payload : Payload.Payload;
      Is_Successful : Boolean;
   begin
      --  Ensure none of the values are transposed.
      Payload.Parse (Sub, Zumo_Payload, Is_Successful);

      pragma Assert (Is_Successful);
      pragma Assert (Zumo_Payload.Prox_Left = 2);
      pragma Assert (Zumo_Payload.Prox_Front_Left = 3);
      pragma Assert (Zumo_Payload.Prox_Front_Right = 4);
      pragma Assert (Zumo_Payload.Prox_Right = 5);
      pragma Assert (Zumo_Payload.Line_Left = 6);
      pragma Assert (Zumo_Payload.Line_Center = 7);
      pragma Assert (Zumo_Payload.Line_Right = 8);
      pragma Assert (Zumo_Payload.Batt_Volts_Tenths = 9);
      pragma Assert (Zumo_Payload.Is_Usb_Present = 1);
      Num_Assertions := Num_Assertions + 10;

      return Num_Assertions;
   end Parse_All_Different_Values_Test;




   function Parse_All_Max_Values_Test return Natural is
      use type Prox_Sensors.Prox_Sensor_Type;
      use type Line_Sensors.Line_Sensor_Type;
      use type Battery.Battery_Volts_Tenths_Type;
      use type Battery.Is_Usb_Present_Type;
      Num_Assertions : Natural := 0;
      Sub : constant HAL.I2C.I2C_Data := (6, 6, 6, 6, 200, 200, 200, 80, 1, 193);
      Zumo_Payload : Payload.Payload;
      Is_Successful : Boolean;
   begin
      Payload.Parse (Sub, Zumo_Payload, Is_Successful);

      pragma Assert (Is_Successful);
      pragma Assert (Zumo_Payload.Prox_Left = 6);
      pragma Assert (Zumo_Payload.Prox_Front_Left = 6);
      pragma Assert (Zumo_Payload.Prox_Front_Right = 6);
      pragma Assert (Zumo_Payload.Prox_Right = 6);
      pragma Assert (Zumo_Payload.Line_Left = 200);
      pragma Assert (Zumo_Payload.Line_Center = 200);
      pragma Assert (Zumo_Payload.Line_Right = 200);
      pragma Assert (Zumo_Payload.Batt_Volts_Tenths = 80);
      pragma Assert (Zumo_Payload.Is_Usb_Present = 1);
      Num_Assertions := Num_Assertions + 10;

      return Num_Assertions;
   end Parse_All_Max_Values_Test;




   function Parse_All_Zeros_Test return Natural is
      use type Prox_Sensors.Prox_Sensor_Type;
      use type Line_Sensors.Line_Sensor_Type;
      use type Battery.Battery_Volts_Tenths_Type;
      use type Battery.Is_Usb_Present_Type;
      Num_Assertions : Natural := 0;
      Sub : constant HAL.I2C.I2C_Data := (0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
      Zumo_Payload : Payload.Payload;
      Is_Successful : Boolean;
   begin
      Payload.Parse (Sub, Zumo_Payload, Is_Successful);

      pragma Assert (Is_Successful);
      pragma Assert (Zumo_Payload.Prox_Left = 0);
      pragma Assert (Zumo_Payload.Prox_Front_Left = 0);
      pragma Assert (Zumo_Payload.Prox_Front_Right = 0);
      pragma Assert (Zumo_Payload.Prox_Right = 0);
      pragma Assert (Zumo_Payload.Line_Left = 0);
      pragma Assert (Zumo_Payload.Line_Center = 0);
      pragma Assert (Zumo_Payload.Line_Right = 0);
      pragma Assert (Zumo_Payload.Batt_Volts_Tenths = 0);
      pragma Assert (Zumo_Payload.Is_Usb_Present = 0);
      Num_Assertions := Num_Assertions + 10;

      return Num_Assertions;
   end Parse_All_Zeros_Test;




   function Parse_Bad_Checksum_Test return Natural is
      Num_Assertions : Natural := 0;
      Sub : constant HAL.I2C.I2C_Data := (2, 3, 4, 5, 6, 7, 8, 9, 1, 0);
      Zumo_Payload : Payload.Payload;
      Is_Successful : Boolean;
   begin
      Payload.Parse (Sub, Zumo_Payload, Is_Successful);
      pragma Assert (Is_Successful = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Parse_Bad_Checksum_Test;




   function Parse_Single_Out_Of_Range_Value_Test return Natural is
      Num_Assertions : Natural := 0;
      --  Is_Usb_Present is out of range which makes Parse
      --  unsuccessful, even though the checksum is correct.
      Sub : constant HAL.I2C.I2C_Data := (0, 0, 0, 0, 0, 0, 0, 0, 2, 2);
      Zumo_Payload : Payload.Payload;
      Is_Successful : Boolean;
   begin
      Payload.Parse (Sub, Zumo_Payload, Is_Successful);
      pragma Assert (Is_Successful = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Parse_Single_Out_Of_Range_Value_Test;





   function Parse_Too_Little_Data_Test return Natural is
      Num_Assertions : Natural := 0;
      Sub : constant HAL.I2C.I2C_Data := (1, 2, 3, 4);
      Zumo_Payload : Payload.Payload;
      Is_Successful : Boolean;
   begin
      Payload.Parse (Sub, Zumo_Payload, Is_Successful);
      pragma Assert (Is_Successful = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Parse_Too_Little_Data_Test;




   function Parse_Too_Much_Data_Test return Natural is
      Num_Assertions : Natural := 0;
      Sub : constant HAL.I2C.I2C_Data := (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 0);
      Zumo_Payload : Payload.Payload;
      Is_Successful : Boolean;
   begin
      Payload.Parse (Sub, Zumo_Payload, Is_Successful);
      pragma Assert (Is_Successful = False);
      Num_Assertions := Num_Assertions + 1;

      return Num_Assertions;
   end Parse_Too_Much_Data_Test;
end Payload_Tests;
