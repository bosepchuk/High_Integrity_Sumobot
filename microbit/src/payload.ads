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


with Ada.Unchecked_Conversion;
with System;
with HAL;
with HAL.I2C;
with Battery; use Battery;
with Line_Sensors; use Line_Sensors;
with Prox_Sensors; use Prox_Sensors;


package Payload with SPARK_Mode => On is
   --  WARNING: you must keep this package internally consistent. If you
   --  want to add a new component to the payload, you must update it in
   --  multiple places in this package.

   --  WARNING: you must keep this package in sync with the Payload struct
   --  in the arduino code.

   ----------------------------------------------------------------------
   --  WARNING  ---------------------------------------------------------
   --  You must change Num_Raw_Bytes if the Raw_Payload size changes.  --
   ----------------------------------------------------------------------
   Num_Raw_Bytes : constant Integer := 10;

   --  The bytes received over I2C are converted to this record. The data types
   --  of each component accept any possible bit pattern received (0 - 255).
   --
   --  See the Spark Proof Manual (section 6.5.2) for details of why this
   --  is necessary.
   --  http://docs.adacore.com/sparkdocs-docs/Proof_Manual.htm
   type Raw_Payload is record
      Prox_Left : Prox_Sensors.Prox_Sensor_Byte;
      Prox_Front_Left : Prox_Sensors.Prox_Sensor_Byte;
      Prox_Front_Right : Prox_Sensors.Prox_Sensor_Byte;
      Prox_Right : Prox_Sensors.Prox_Sensor_Byte;

      Line_Left : Line_Sensors.Line_Sensor_Byte;
      Line_Center : Line_Sensors.Line_Sensor_Byte;
      Line_Right : Line_Sensors.Line_Sensor_Byte;

      Batt_Volts_Tenths : Battery.Battery_Volts_Tenths_Byte;
      Is_Usb_Present : Battery.Is_Usb_Present_Byte;

      Checksum : HAL.UInt8;
   end record
     with Size => 80, Alignment => 1, Bit_Order => System.Low_Order_First;

   for Raw_Payload use record
      Prox_Left at 0 range 0 .. 7;
      Prox_Front_Left at 0 range 8 .. 15;
      Prox_Front_Right at 0 range 16 .. 23;
      Prox_Right at 0 range 24 .. 31;

      Line_Left at 0 range 32 .. 39;
      Line_Center at 0 range 40 .. 47;
      Line_Right at 0 range 48 .. 55;

      Batt_Volts_Tenths at 0 range 56 .. 63;
      Is_Usb_Present at 0 range 64 .. 71;

      Checksum at 0 range 72 .. 79;
   end record;


   --  The Raw_Payload record is converted into this record if and only if all
   --  the values received via I2C are valid for the given types.
   type Payload is record
      Prox_Left : Prox_Sensors.Prox_Sensor_Type;
      Prox_Front_Left : Prox_Sensors.Prox_Sensor_Type;
      Prox_Front_Right : Prox_Sensors.Prox_Sensor_Type;
      Prox_Right : Prox_Sensors.Prox_Sensor_Type;

      Line_Left : Line_Sensors.Line_Sensor_Type;
      Line_Center : Line_Sensors.Line_Sensor_Type;
      Line_Right : Line_Sensors.Line_Sensor_Type;

      Batt_Volts_Tenths : Battery.Battery_Volts_Tenths_Type;
      Is_Usb_Present : Battery.Is_Usb_Present_Type;
   end record;




   --  Converts Zumo_Data to Zumo_Payload (a valid record we can use).
   procedure Parse (Zumo_Data : in HAL.I2C.I2C_Data;
                    Zumo_Payload : out Payload;
                    Is_Successful : out Boolean)
     with Global => null,
     Depends => ((Zumo_Payload, Is_Successful) => Zumo_Data);
end Payload;
