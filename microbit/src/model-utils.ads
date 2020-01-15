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


private package Model.Utils with SPARK_Mode => On is




   --  Update Current_State and State_Start_Time.
   procedure Change_State (New_State : in States;
                           S_In : in State_In_Record;
                           S_In_Out : in out State_In_Out_Record)
     with Global => null,
     Depends => (S_In_Out =>+ (New_State, S_In)),
     Post => (S_In_Out.Current_State = New_State and S_In_Out.State_Start_Time = S_In.Clock_Ms);




   --  Returns the number of seconds until the bot can start fighting.
   --
   --  A Wait_Time > 5000 will break this code.
   function Get_Countdown (Wait_Time : in MicroBit.Time.Time_Ms;
                           Time_In_Current_State : in MicroBit.Time.Time_Ms)
                           return Model.Countdown_Char
     with Global => null,
     Pre => Wait_Time <= 5000;




   function Get_Initial_Scan_Direction (Target_Dir : in Target_Direction)
                                        return Scan_Direction
     with Global => null,
     Contract_Cases => (Target_Dir = Prox_Sensors.Unknown => Get_Initial_Scan_Direction'Result = Left,
                        Target_Dir = Prox_Sensors.Left => Get_Initial_Scan_Direction'Result = Left,
                        Target_Dir = Prox_Sensors.Slightly_Left => Get_Initial_Scan_Direction'Result = Left,
                        Target_Dir = Prox_Sensors.Front_Close => Get_Initial_Scan_Direction'Result = Straight,
                        Target_Dir = Prox_Sensors.Front_Far => Get_Initial_Scan_Direction'Result = Straight,
                        Target_Dir = Prox_Sensors.Slightly_Right => Get_Initial_Scan_Direction'Result = Right,
                        Target_Dir = Prox_Sensors.Right => Get_Initial_Scan_Direction'Result = Right);




   procedure Get_Next_Driving_Move (S_In : in State_In_Record;
                                    Time_In_Current_State : in MicroBit.Time.Time_Ms;
                                    S_In_Out : in out State_In_Out_Record)
     with Global => null,
     Depends => (S_In_Out =>+ (S_In, Time_In_Current_State)),
     Pre => S_In_Out.Current_State = Driving;




   procedure Get_Next_Scanning_Move (S_In : in State_In_Record;
                                     Time_In_Current_State : in MicroBit.Time.Time_Ms;
                                     S_In_Out : in out State_In_Out_Record)
     with Global => null,
     Depends => (S_In_Out =>+ (S_In, Time_In_Current_State)),
     Pre => S_In_Out.Current_State = Scanning,
     Post => ((if S_In_Out.Current_State = Scanning then S_In_Out.Scan_Dir /= Straight) and
                  (if Time_In_Current_State > Scan_Time_Max then S_In_Out.Current_State = Driving));




   function Get_Pausing_Char (Battery_Status : in Battery.Status)
                              return Character
     with Global => null,
     Contract_Cases => (Battery_Status = Battery.Low => Get_Pausing_Char'Result = 'B',
                        others => Get_Pausing_Char'Result = 'P');




   --  Returns True if the bot should use ramming speed.
   function Should_Ram (Target_Dir : Target_Direction;
                        Time_In_Current_State : in MicroBit.Time.Time_Ms)
                        return Boolean
     with Global => null;
end Model.Utils;
