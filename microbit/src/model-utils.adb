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


package body Model.Utils with SPARK_Mode => On is




   procedure Change_State (New_State : in States;
                           S_In : in State_In_Record;
                           S_In_Out : in out State_In_Out_Record) is
   begin
      S_In_Out.Current_State := New_State;
      S_In_Out.State_Start_Time := S_In.Clock_Ms;
   end Change_State;




   function Get_Countdown (Wait_Time : in MicroBit.Time.Time_Ms;
                           Time_In_Current_State : in MicroBit.Time.Time_Ms)
                           return Model.Countdown_Char is
      Time_Remaining_Ms : MicroBit.Time.Time_Ms;
   begin
      if Time_In_Current_State > Wait_Time then
         --  The bot could be in the current state a few milliseconds longer
         --  than wait time. But this data type is unsigned so just set the
         --  time remaining to zero.
         Time_Remaining_Ms := 0;
      else
         Time_Remaining_Ms := Wait_Time - Time_In_Current_State;
      end if;

      if Time_Remaining_Ms <= 1000 then
         return '1';
      elsif Time_Remaining_Ms <= 2000 then
         return '2';
      elsif Time_Remaining_Ms <= 3000 then
         return '3';
      elsif Time_Remaining_Ms <= 4000 then
         return '4';
      else
         return '5';
      end if;
   end Get_Countdown;




   function Get_Initial_Scan_Direction (Target_Dir : in Target_Direction)
                                        return Scan_Direction is
      Scan_Dir : Scan_Direction;
   begin
      case Target_Dir is
         when Front_Far | Front_Close => Scan_Dir := Straight;
         when Unknown | Left | Slightly_Left => Scan_Dir := Left;
         when Right | Slightly_Right => Scan_Dir := Right;
      end case;
      return Scan_Dir;
   end Get_Initial_Scan_Direction;




   procedure Get_Next_Driving_Move (S_In : in State_In_Record;
                                    Time_In_Current_State : in MicroBit.Time.Time_Ms;
                                    S_In_Out : in out State_In_Out_Record) is
   begin
      --  ### Driving: drive forward looking for a target ###
      if S_In.Line_Dir = Left then
         --  Line detected left. Reverse and then scan right.
         S_In_Out.Scan_Dir := Right;
         Change_State (Reversing, S_In, S_In_Out);
      elsif S_In.Line_Dir = Center or S_In.Line_Dir = Right then
         --  Line detected center or right. Reverse and then scan left.
         S_In_Out.Scan_Dir := Left;
         Change_State (Reversing, S_In, S_In_Out);
      elsif Should_Ram (S_In.Target_Dir, Time_In_Current_State) then
         S_In_Out.Speeds := Combine_Speeds (Ramming_Speed, Ramming_Speed);
      elsif S_In.Target_Dir = Left then
         S_In_Out.Speeds := Combine_Speeds (Veer_Speed_Slow, Veer_Speed_Very_Fast);
      elsif S_In.Target_Dir = Right then
         S_In_Out.Speeds := Combine_Speeds (Veer_Speed_Very_Fast, Veer_Speed_Slow);
      elsif S_In.Target_Dir = Slightly_Left then
         S_In_Out.Speeds := Combine_Speeds (Veer_Speed_Slow, Veer_Speed_Fast);
      elsif S_In.Target_Dir = Slightly_Right then
         S_In_Out.Speeds := Combine_Speeds (Veer_Speed_Fast, Veer_Speed_Slow);
      else
         --  Both readings are equal or are too weak to be
         --  accurate, so just drive forward.
         S_In_Out.Speeds := Combine_Speeds (Forward_Speed, Forward_Speed);
      end if;
   end Get_Next_Driving_Move;




   procedure Get_Next_Scanning_Move (S_In : in State_In_Record;
                                     Time_In_Current_State : in MicroBit.Time.Time_Ms;
                                     S_In_Out : in out State_In_Out_Record) is
      Speed : View.Motors.Motor_Speed := Scan_Speed;
   begin
      --  ### Scanning: turn in place to look for a target ###
      if Time_In_Current_State > Scan_Time_Max then
         --  The bot can't locate the target. Just drive somewhere.
         S_In_Out.Scan_Dir := Straight;
      elsif Time_In_Current_State >= Scan_Time_Min then
         --  It's time to find the target.
         if Prox_Sensors.Is_Target_Front (S_In.Target_Dir) then
            S_In_Out.Scan_Dir := Straight;
         elsif Is_Target_Left (S_In.Target_Dir) then
            S_In_Out.Scan_Dir := Left;
         elsif Is_Target_Right (S_In.Target_Dir) then
            S_In_Out.Scan_Dir := Right;
         end if;
      end if;

      --  Scan faster if the target direction is unknown (to minimize the
      --  amount of time the target is potentially behind the bot).
      if S_In.Target_Dir = Unknown then
         Speed := Scan_Speed_Fast;
      end if;

      case S_In_Out.Scan_Dir is
         when Left =>
            S_In_Out.Speeds := Combine_Speeds ((-Speed), Speed);
         when Straight =>
            Change_State (Driving, S_In, S_In_Out);
         when Right =>
            S_In_Out.Speeds := Combine_Speeds (Speed, (-Speed));
      end case;
   end Get_Next_Scanning_Move;




   function Get_Pausing_Char (Battery_Status : in Battery.Status)
                              return Character is
   begin
      if Battery_Status = Battery.Low then
         return 'B'; --  Battery is low - cannot start match
      end if;
      return 'P'; --  Pausing (waiting for a button press to start the match)
   end Get_Pausing_Char;




   function Should_Ram (Target_Dir : Target_Direction;
                        Time_In_Current_State : in MicroBit.Time.Time_Ms)
                        return Boolean is
   begin
      --  If the front sensors are getting a strong signal or the bot has been
      --  driving forward for a while now and the target is "ahead", then
      --  there is probably a target in front the bot and it should switch to
      --  ramming speed to try to push the target out of the ring.
      return Target_Dir = Front_Close or
        (Time_In_Current_State >= Stalemate_Time and Is_Target_Ahead (Target_Dir));
   end Should_Ram;
end Model.Utils;
