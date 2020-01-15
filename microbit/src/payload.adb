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


with Payload.Utils; use Payload.Utils;


package body Payload with SPARK_Mode => On is




   procedure Parse (Zumo_Data : in HAL.I2C.I2C_Data;
                    Zumo_Payload : out Payload;
                    Is_Successful : out Boolean) is
      use type HAL.UInt8;
      Raw : Raw_Payload;
      Num_Errors : Natural := 0;

      --  This checksum simply adds up all the values in the Raw_Payload.
      --  It rolls over if the value overflows so it will work for any
      --  conceivable combination of values in the Raw_Payload.
      Checksum : HAL.UInt8 := 0;
   begin
      Raw := Convert_To_Payload (Zumo_Data);

      --  The following code ensures that the components of Raw_Payload
      --  contain valid values given the range of their types before
      --  converting Raw_Payload to Zumo_Payload.
      --  This is required for spark to prove this code.

      --  Prox sensors.
      if Raw.Prox_Left <= Prox_Sensor_Type'Last then
         Zumo_Payload.Prox_Left := Raw.Prox_Left;
         Checksum := Checksum + HAL.UInt8 (Raw.Prox_Left);
      else
         Zumo_Payload.Prox_Left := 0;
         Num_Errors := Num_Errors + 1;
      end if;

      if Raw.Prox_Front_Left <= Prox_Sensor_Type'Last then
         Zumo_Payload.Prox_Front_Left := Raw.Prox_Front_Left;
         Checksum := Checksum + HAL.UInt8 (Raw.Prox_Front_Left);
      else
         Zumo_Payload.Prox_Front_Left := 0;
         Num_Errors := Num_Errors + 1;
      end if;

      if Raw.Prox_Front_Right <= Prox_Sensor_Type'Last then
         Zumo_Payload.Prox_Front_Right := Raw.Prox_Front_Right;
         Checksum := Checksum + HAL.UInt8 (Raw.Prox_Front_Right);
      else
         Zumo_Payload.Prox_Front_Right := 0;
         Num_Errors := Num_Errors + 1;
      end if;

      if Raw.Prox_Right <= Prox_Sensor_Type'Last then
         Zumo_Payload.Prox_Right := Raw.Prox_Right;
         Checksum := Checksum + HAL.UInt8 (Raw.Prox_Right);
      else
         Zumo_Payload.Prox_Right := 0;
         Num_Errors := Num_Errors + 1;
      end if;

      --  Line sensors.
      if Raw.Line_Left <= Line_Sensor_Type'Last then
         Zumo_Payload.Line_Left := Raw.Line_Left;
         Checksum := Checksum + HAL.UInt8 (Raw.Line_Left);
      else
         Zumo_Payload.Line_Left := 0;
         Num_Errors := Num_Errors + 1;
      end if;

      if Raw.Line_Center <= Line_Sensor_Type'Last then
         Zumo_Payload.Line_Center := Raw.Line_Center;
         Checksum := Checksum + HAL.UInt8 (Raw.Line_Center);
      else
         Zumo_Payload.Line_Center := 0;
         Num_Errors := Num_Errors + 1;
      end if;

      if Raw.Line_Right <= Line_Sensor_Type'Last then
         Zumo_Payload.Line_Right := Raw.Line_Right;
         Checksum := Checksum + HAL.UInt8 (Raw.Line_Right);
      else
         Zumo_Payload.Line_Right := 0;
         Num_Errors := Num_Errors + 1;
      end if;

      --  Battery.
      if Raw.Batt_Volts_Tenths <= Battery_Volts_Tenths_Type'Last then
         Zumo_Payload.Batt_Volts_Tenths := Raw.Batt_Volts_Tenths;
         Checksum := Checksum + HAL.UInt8 (Raw.Batt_Volts_Tenths);
      else
         Zumo_Payload.Batt_Volts_Tenths := 0;
         Num_Errors := Num_Errors + 1;
      end if;

      if Raw.Is_Usb_Present <= Is_Usb_Present_Type'Last then
         Zumo_Payload.Is_Usb_Present := Raw.Is_Usb_Present;
         Checksum := Checksum + HAL.UInt8 (Raw.Is_Usb_Present);
      else
         Zumo_Payload.Is_Usb_Present := 0;
         Num_Errors := Num_Errors + 1;
      end if;

      Is_Successful := Num_Errors = 0 and Checksum = Raw.Checksum;
   end Parse;
end Payload;
