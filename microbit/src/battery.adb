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


package body Battery with SPARK_Mode => On is




   function Get_Status (Is_Usb_Present : in Is_Usb_Present_Type;
                        Volts_Tenths : in Battery_Volts_Tenths_Type)
                        return Status is
   begin
      if Is_Usb_Present = 1 then
         --  The battery voltage returned by the bot while on usb is not
         --  reliable even if you have the battery switched to the on position.
         --  So the safest thing to do is just say the battery is ok when the
         --  usb cable is plugged in.
         return Ok;
      elsif Volts_Tenths <= Critical_Threshold then
         return Critical;
      elsif Volts_Tenths <= Low_Threshold then
         return Low;
      else
         return Ok;
      end if;
   end Get_Status;
end Battery;
