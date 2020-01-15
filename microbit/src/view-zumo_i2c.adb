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


with MicroBit.I2C;
with MicroBit.Time;


package body View.Zumo_I2C with SPARK_Mode => Off is
   Initialized : Boolean := False;
   I2C_Controller : constant HAL.I2C.Any_I2C_Port := MicroBit.I2C.Controller;
   I2C_Slave_Address : constant HAL.I2C.I2C_Address := 16;




   procedure Initialize is
   begin
      if Is_Initialized then
         return;
      end if;
      MicroBit.I2C.Initialize (MicroBit.I2C.S100kbps);
      if MicroBit.I2C.Initialized then
         Initialized := True;
      end if;
      --  The I2C system needs a little delay before the next call.
      MicroBit.Time.Delay_Ms (60);
   end Initialize;




   function Is_Initialized return Boolean is
   begin
      return Initialized;
   end Is_Initialized;




   procedure Read (Data : out HAL.I2C.I2C_Data; Is_Successful : out Boolean) is
      Status : HAL.I2C.I2C_Status;
   begin
      I2C_Controller.Master_Receive (I2C_Slave_Address, Data, Status);
      if Status = Ok then
         Is_Successful := True;
      else
         Is_Successful := False;
      end if;
   end Read;




   procedure Write (Data : in HAL.I2C.I2C_Data; Is_Successful : out Boolean) is
      Status : HAL.I2C.I2C_Status;
   begin
      I2C_Controller.Master_Transmit (I2C_Slave_Address, Data, Status);
      if Status = Ok then
         Is_Successful := True;
      else
         Is_Successful := False;
      end if;
   end Write;
end View.Zumo_I2C;
