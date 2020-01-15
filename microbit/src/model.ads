--  Represents the 'model' in the MVC pattern.
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


with HAL; use HAL;
with MicroBit.Time;
with Battery;
with Line_Sensors; use Line_Sensors;
with Payload;
with Prox_Sensors; use Prox_Sensors;
with View.Motors;


package Model with SPARK_Mode => On is
   use type Battery.Status;
   use type View.Motors.Motor_Speeds;
   use type View.Motors.Working_Speed;

   --  Top-level states in the state machine.
   type States is (Battery_Critical, Pausing, Waiting, Scanning, Driving, Reversing);

   type Scan_Direction is (Left, Straight, Right);

   --  The characters that may be displayed during the Waiting State countdown.
   subtype Countdown_Char is Character range '1' .. '5';

   --  Read-only record encapsulating the state machine state.
   type State_In_Record is record
      Button_B_Is_Pressed : Boolean;
      Clock_Ms : MicroBit.Time.Time_Ms;
      --  The number of milliseconds that the bot's been in the current
      --  top-level state.
      Battery_Status : Battery.Status;
      Target_Dir : Target_Direction := Unknown;
      Line_Dir : Line_Detected_Direction;
   end record;

   --  Read-write record encapsulating the state machine state.
   type State_In_Out_Record is record
      Scan_Dir : Scan_Direction := Straight;
      Current_State : States := Pausing;
      --  The clock time, in milliseconds, that the bot entered the current
      --  top-level state.
      State_Start_Time : MicroBit.Time.Time_Ms;
      Speeds : View.Motors.Motor_Speeds;
   end record;


   ----------------
   --  CONSTANTS --
   ----------------

   --  The speed that the bot usually uses when moving forward.
   --  You don't want this to be too fast because then the bot
   --  might fail to stop when it detects the white border.
   Forward_Speed : constant View.Motors.Motor_Speed := 25;

   --  The speed that the bot drives when it detects a target in
   --  front of it, either with the proximity sensors or by noticing
   --  that it is caught in a stalemate (driving forward for several
   --  seconds without reaching a border). 50 is full speed.
   Ramming_Speed : constant View.Motors.Motor_Speed := 33;

   --  The speed that the bot uses when scanning.
   Scan_Speed : constant View.Motors.Motor_Speed := 25;
   Scan_Speed_Fast : constant View.Motors.Motor_Speed := 40;

   --  These three variables specify the speeds to apply to the motors
   --  when veering left or veering right.  While the bot is
   --  driving forward, it uses its proximity sensors to scan for
   --  targets ahead of it and tries to veer towards them.
   Veer_Speed_Slow : constant View.Motors.Motor_Speed := 0;
   Veer_Speed_Fast : constant View.Motors.Motor_Speed := 31;
   Veer_Speed_Very_Fast : constant View.Motors.Motor_Speed := 40;

   --  The speed that the bot uses when backing up.
   Reverse_Speed : constant View.Motors.Motor_Speed := -35;

   --  The amount of time to wait between detecting a button press
   --  and actually starting to move, in milliseconds. Typical robot
   --  sumo rules require 5 seconds of waiting.
   --  Setting this constant > 5000 will break this code.
   Wait_Time : constant MicroBit.Time.Time_Ms := 2000;

   --  The amount of time to spend backing up after detecting a
   --  border, in Milliseconds.
   Reverse_Time : constant MicroBit.Time.Time_Ms := 220;

   --  The minimum and maximum amount of time to spend scanning for nearby
   --  targets, in milliseconds.
   Scan_Time_Min : constant MicroBit.Time.Time_Ms := 200;
   Scan_Time_Max : constant MicroBit.Time.Time_Ms := 1300;

   --  If the bot has been driving forward for this amount of time,
   --  in milliseconds, without reaching a border, the bot decides
   --  that it must be pushing on another bot and this is a
   --  stalemate, so it increases its motor speed.
   Stalemate_Time : constant MicroBit.Time.Time_Ms := 6000;




   --  Convenience function that allows us to set both speeds in
   --  one line of code.
   function Combine_Speeds (Left : in View.Motors.Motor_Speed;
                            Right : in View.Motors.Motor_Speed)
                            return View.Motors.Motor_Speeds
     with Global => null,
     Post => (Combine_Speeds'Result.Left = Left and then
                Combine_Speeds'Result.Right = Right);




   function Get_Display_Char (S_In : in State_In_Record;
                              S_In_Out : in State_In_Out_Record)
                              return Character
     with Global => null, Pre => Wait_Time <= 5000;




   --  Returns the direction of the line sensor that was triggered.
   function Get_Line_Detected_Direction (Sensors : in Payload.Payload)
                                         return Line_Detected_Direction
     with Global => null;




   --  Determine what the bot should do next (AKA - update the state machine).
   --
   --  This algorithm is inspired by the zumo 32U4
   --  SumoProximitySensors demo which can be found here:
   --  https://github.com/pololu/zumo-32u4-arduino-library/blob/master
   --     /examples/SumoProximitySensors/SumoProximitySensors.ino
   procedure Get_Next_Move (S_In : in State_In_Record;
                            S_In_Out : in out State_In_Out_Record)
     with Global => null,
     Depends => (S_In_Out =>+ S_In),
     Post => (if S_In_Out.Current_State'Old = Battery_Critical then
                S_In_Out.Speeds = Combine_Speeds (0, 0) and
                  (if S_In.Battery_Status = Battery.Critical then
                       S_In_Out.Speeds = Combine_Speeds (0, 0) and
                         S_In_Out.Current_State = Battery_Critical));




   --  Returns the estimated target direction based on the prox sensor readings.
   function Get_Target_Direction (Sensors : in Payload.Payload;
                                  Previous_Target_Dir : in Target_Direction)
                                  return Target_Direction
     with Global => null;




   function Has_Too_Many_Parse_Errors (Last_Parse_Error_Time : in MicroBit.Time.Time_Ms;
                                       Current_Parse_Error_Time : in MicroBit.Time.Time_Ms)
                                       return Boolean
     with Global => null;




   procedure Set_Initial_Scan_Direction (S_In : in State_In_Record;
                                         S_In_Out : in out State_In_Out_Record;
                                         Is_First_Scan_Of_Match : in out Boolean)
     with Global => null,
     Depends => (S_In_Out =>+ (S_In, Is_First_Scan_Of_Match),
                 Is_First_Scan_Of_Match =>+ S_In_Out);




   --  Returns the number of milliseconds the bot has been in this state.
   function Time_In_This_State (State_Start_Time : in MicroBit.Time.Time_Ms;
                                Clock_Ms : in MicroBit.Time.Time_Ms)
                                return MicroBit.Time.Time_Ms
     with Global => null;
end Model;
