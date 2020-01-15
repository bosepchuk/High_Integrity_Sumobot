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


package Battery with SPARK_Mode => On is
   type Status is (Ok, Low, Critical);

   type Battery_Volts_Tenths_Byte is new Integer range 0 .. 255;
   subtype Battery_Volts_Tenths_Type is Battery_Volts_Tenths_Byte range 0 .. 80; --  0 to 8 Volts

   type Is_Usb_Present_Byte is new Integer range 0 .. 255;
   subtype Is_Usb_Present_Type is Is_Usb_Present_Byte range 0 .. 1; --  False or True


   --  The following thresholds are designed for NiMH batteries.
   --  The bot will not start a match with a voltage <= this value.
   --  The voltage will drop significantly if you run the motors at full power.
   --  So adjust Low_Threshold downwards at your own peril.
   Low_Threshold : constant Battery_Volts_Tenths_Type := 50; --  5.0 volts

   --  The bot will shutdown immediately with a voltage <= this value.
   Critical_Threshold : constant Battery_Volts_Tenths_Type := 42; --  4.2 volts




   function Get_Status (Is_Usb_Present : in Is_Usb_Present_Type;
                        Volts_Tenths : in Battery_Volts_Tenths_Type)
                        return Status
     with Global => null,
     Pre => Critical_Threshold < Low_Threshold,
     Contract_Cases => (Is_Usb_Present = 1 => Get_Status'Result = Ok,
                        Is_Usb_Present = 0 and Volts_Tenths <= Critical_Threshold
                        => Get_Status'Result = Critical,
                        Is_Usb_Present = 0 and Volts_Tenths > Critical_Threshold and Volts_Tenths <= Low_Threshold
                        => Get_Status'Result = Low,
                        others => Get_Status'Result = Ok);
end Battery;
