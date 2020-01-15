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


--  Represents the 'controller' in the MVC pattern.
--
--  In this system MVC works like this:
--
--  The view is responsible for inputs and outputs. That includes the incoming
--  zumo I2C sensor readings, microbit button presses, the 5 x 5 display, and
--  outgoing I2C motor commands. The view shouldn't know anything about the
--  controller or model.
--
--  The model is responsible for running the state machine (deciding what to do
--  next). It shouldn't know anything about the controller or the view.
--
--  The controller co-ordinates all the action. It requests data from the view,
--  asks the model for the next motor commands, and passes them to
--  the view. The controller is responsible for ensuring that the model and the
--  view don't need to know the other exists.


with View.Zumo_I2C;


package Controller with SPARK_Mode => On is





   --  Should be the first call inside the main procedure.
   procedure Initialize;




   function Is_Initialized return Boolean;




   --  Call from the main loop.
   procedure Run with Pre => Is_Initialized and View.Zumo_I2C.Is_Initialized;
end Controller;
