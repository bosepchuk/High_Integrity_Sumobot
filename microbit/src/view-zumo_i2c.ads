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


--  Read sensor data from the Zumo over I2C.


with HAL.I2C; use HAL.I2C;


package View.Zumo_I2C with SPARK_Mode => On is




   --  Initialize the connection to the zumo sensors over I2C.
   procedure Initialize with Post => Is_Initialized;




   --  Returns True if the I2C connection to the zumo sensors is initialized.
   function Is_Initialized return Boolean with Global => null;




   --  Read the sensor data from the zumo.
   procedure Read (Data : out HAL.I2C.I2C_Data; Is_Successful : out Boolean)
     with Pre => Is_Initialized;




   --  Write motor commands to the zumo.
   procedure Write (Data : in HAL.I2C.I2C_Data; Is_Successful : out Boolean)
     with Pre => Is_Initialized;
end View.Zumo_I2C;
