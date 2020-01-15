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


--  Send motor commands to the Zumo via I2C.

with View.Zumo_I2C;


package View.Motors with SPARK_Mode => On is
   --  This is the combined range of Motor_Speed and UInt8.
   type Working_Speed is new Integer range -50 .. 255;

   --  This is the actual speed the motor can take.
   subtype Motor_Speed is Working_Speed range -50 .. 50;

   type Motor_Speeds is record
      Left : Motor_Speed := 0;
      Right : Motor_Speed := 0;
   end record;




   --  Command the motors to run at Motor_Speeds.
   procedure Set_Speed (Speeds : in Motor_Speeds; Is_Successful : out Boolean)
     with Pre => View.Zumo_I2C.Is_Initialized;
end View.Motors;
