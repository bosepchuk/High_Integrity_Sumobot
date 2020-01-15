// **********************************************************************
// High Integrity Sumobot                                               *
// Copyright (C) 2020 Blaine Osepchuk <bosepchuk@gmail.com>             *
//                                                                      *
// This program is free software: you can redistribute it and/or modify *
// it under the terms of the GNU General Public License as published by *
// the Free Software Foundation, either version 3 of the License, or    *
// (at your option) any later version.                                  *
//                                                                      *
// This program is distributed in the hope that it will be useful,      *
// but WITHOUT ANY WARRANTY; without even the implied warranty of       *
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the        *
// GNU General Public License for more details.                         *
//                                                                      *
// You should have received a copy of the GNU General Public License    *
// along with this program (LICENSE.txt).                               *
// If not, see <https://www.gnu.org/licenses/>.                         *
// **********************************************************************


// This program runs the zumo sumobot. It collects data from its sensors,
// sends it to the microbit for processing, receives motor commands
// from the microbit that tell it how to move, and it uses them to move.

// I have placed additional code in the file: non_critical_code.ino.


#include <Wire.h>
#include <Zumo32U4.h>

// The zumo will not work unless this line is commented out.
//#include <ArduinoUnit.h>

// CONSTANTS
const bool IS_UNIT_TESTS = false; // toggle unit tests
const bool IS_SERIAL_ENABLED = false; // toggle the serial output
const int NUM_LINE_SENSORS = 3;  // left, center, and right
const int NULL_MOTOR_SPEED = -51;



// A note about I2C addresses:
// The microbit is looking for the slave on address 16
// but this code says the slave is on address 8.
// What's happening?
// As best as I can tell it works like this:
// 16 in binary is 10000. But arduino strips the read/write bit
// off of the address so 10000 becomes 1000 in binary.
// And 1000 in binary is 8.
const int I2C_SLAVE_ADDRESS = 8;


// PIN ASSIGNMENTS
const int LED_PIN = 13; // yellow LED


// VARIABLES
volatile bool isPayloadReady = false;
volatile int leftMotorSpeed = 0;   // range -400..400
volatile int rightMotorSpeed = 0;  // range -400..400
volatile bool hasError = false;
String errorMsg = "";  // 8 chars max
volatile unsigned long lastI2CReceivedTime = 0;
volatile unsigned long numMotorCmdsReceived = 0;
unsigned int lineSensorValues[NUM_LINE_SENSORS];

Zumo32U4ProximitySensors proxSensors;
Zumo32U4Motors motors;
Zumo32U4LineSensors lineSensors;


// Define the data structure for the packet of sensor data.
// WARNING: you must keep this record in sync with the Raw_Payload record
// in the microbit's Ada code.
// WARNING: you must update the getChecksum() function (and its tests)
// if you change this data structure.
typedef struct
{
  byte proxLeft = 0;
  byte proxFrontLeft = 0;
  byte proxFrontRight = 0;
  byte proxRight = 0;
  byte lineLeft = 0;
  byte lineCenter = 0;
  byte lineRight = 0;
  byte battVoltsTenths = 0;
  byte isUsbPowerPresent = 0;
  byte checksum = 0;
} Payload;

Payload payload;
Payload oldPayload;


// temporary struct to hold the calculated microbit motor speeds
typedef struct
{
  // valid range -50 .. 50
  volatile int left = NULL_MOTOR_SPEED;
  volatile int right = NULL_MOTOR_SPEED;
} MicrobitMotorSpeed;


void setup()
{
  pinMode(LED_PIN, OUTPUT);
  if(IS_UNIT_TESTS)
  {
    Serial.begin(9600); // ArduinoUnit will only display output at 9600
    while(!Serial) {} // wait for Serial to start
  }
  else
  {
    proxSensors.initThreeSensors();
    lineSensors.initThreeSensors();
    if(IS_SERIAL_ENABLED == true)
    {
      Serial.begin(115200);
      Serial.println("beginning");
    }
    // The bot needs a little delay before initializing the I2C system.
    // Without a delay, the battery reports a critically low voltage as the bot
    // powers up.
    //
    // We also need a slightly longer delay in the microbit's Controller.Init
    // procedures so that the zumo's I2C system is online before the microbit
    // attempts to establish a connection.
    delay(100);
    i2cInit();
    blinkLed();
  }
}


void loop()
{
  if(IS_UNIT_TESTS)
  {
    // To run the unit tests you must:
    //  - uncomment "include <ArduinoUnit.h>" at the top of the file
    //  - set "IS_UNIT_TESTS = true;" at the top of the file
    //  - and uncomment "Test::run()" below
    //  - uncomment the unit tests from the bottom of this file
    //  - upload this file to the zumo and open the serial monitor to see the test results

    //Test::run();  // unit test output is sent to the serial monitor
  }
  else
  {
    microbitCommsWatchdog();
    readSensorsAndUpdatePayload();
    motors.setSpeeds(leftMotorSpeed, rightMotorSpeed);
    updateViewIfNecessary();
  }
}


// converts the byte coming from the microbit into the left or right
// motor speed (with the other speed set to NULL_MOTOR_SPEED)
MicrobitMotorSpeed calculateMotorSpeed(byte microbitSpeedByte)
{
  // Note: these offsets must match the microbit offsets. See motors.adb
  int LEFT_MOTOR_OFFSET = -50;
  int RIGHT_MOTOR_OFFSET = -160;
  MicrobitMotorSpeed speedStruct;

  // The microbitSpeedByte is a byte and we can tell if it is for
  // the left or the right motor by its value.
  if(microbitSpeedByte >= 0 && microbitSpeedByte <= 100)
  {
    speedStruct.left = microbitSpeedByte + LEFT_MOTOR_OFFSET;
  }
  else if(microbitSpeedByte >= 110 && microbitSpeedByte <= 210)
  {
    speedStruct.right = microbitSpeedByte + RIGHT_MOTOR_OFFSET;
  }
  return speedStruct;
}


// returns the number of milliseconds elapsed between timeStart and
// timeNow (while accounting for millis() rollover)
unsigned long duration(unsigned long timeStart, unsigned long timeNow)
{
  if(timeNow >= timeStart)
  {
    return timeNow - timeStart;
  }

  // see: https://www.arduino.cc/reference/en/language/functions/time/millis/
  // see: https://www.arduino.cc/reference/en/language/variables/data-types/unsignedlong/
  unsigned long timeMax = 4294967295;

  // rollover has occurred
  return (timeNow + (1 + timeMax - timeStart));
}


byte getChecksum(Payload thisPayload)
{
  // The checksum is just the sum of all the payload values (excluding the checksum).
  // Checksum is a number between 0 and 255 and will rollover if it overflows.
  byte checksum = 0;
  checksum += thisPayload.proxLeft;
  checksum += thisPayload.proxFrontLeft;
  checksum += thisPayload.proxFrontRight;
  checksum += thisPayload.proxRight;
  checksum += thisPayload.lineLeft;
  checksum += thisPayload.lineCenter;
  checksum += thisPayload.lineRight;
  checksum += thisPayload.battVoltsTenths;
  checksum += thisPayload.isUsbPowerPresent;
  return checksum;
}


void i2cInit()
{
  Wire.begin(I2C_SLAVE_ADDRESS);    // join i2c bus
  Wire.onRequest(requestEvent);     // register event
  Wire.onReceive(receiveEvent);     // register event
}


// throw an error if it has been too long since the zumo has received
// a command from the microbit
void microbitCommsWatchdog()
{
  unsigned long MAX_COMMS_INTERVAL_MS = 100;
  if(lastI2CReceivedTime == 0)
  {
    // Allow a long communications gap on startup
    // do nothing
  }
  else
  {
    // The zumo has received at least one motor command.
    // The commands must continue to arrive regularly from now on.
    if(hasError == false && duration(lastI2CReceivedTime, millis()) > MAX_COMMS_INTERVAL_MS)
    {
      registerError("COMMS");
    }
  }
}


void readSensorsAndUpdatePayload()
{
  if(hasError == false)
  {
    proxSensors.read(); // range 0 (far) .. 6 (near)
    lineSensors.read(lineSensorValues); // range 0 (white) .. 2000 (black)

    // protect the payload from being read while being updated
    // see: https://forum.arduino.cc/index.php?topic=447090.0
    oldPayload = payload;
    isPayloadReady = false;
    payload.proxLeft = (byte) proxSensors.countsLeftWithLeftLeds();
    payload.proxFrontLeft = (byte) proxSensors.countsFrontWithLeftLeds();
    payload.proxFrontRight = (byte) proxSensors.countsFrontWithRightLeds();
    payload.proxRight = (byte) proxSensors.countsRightWithRightLeds();
    payload.lineLeft = toMicrobitLineSensorValue(lineSensorValues[0]);
    payload.lineCenter = toMicrobitLineSensorValue(lineSensorValues[1]);
    payload.lineRight = toMicrobitLineSensorValue(lineSensorValues[2]);
    payload.battVoltsTenths = toMicrobitBattVoltsValue(readBatteryMillivolts());
    payload.isUsbPowerPresent = (byte) usbPowerPresent();
    payload.checksum = getChecksum(payload);
    isPayloadReady = true;
  }
}


// receives a motor command from the microbit whenever it decides to send one
//
// Executes whenever data is received from master.
// This function is registered as an event, see setup().
void receiveEvent(int numBytes)
{
  while(hasError == false && Wire.available())
  {
    byte microbitSpeedByte = Wire.read();
    setMotorSpeed(calculateMotorSpeed(microbitSpeedByte));
    lastI2CReceivedTime = millis();
    numMotorCmdsReceived++;
    blinkLed();
  }
}


void registerError(String errMsg)
{
  hasError = true;
  errorMsg = errMsg;
  leftMotorSpeed = 0;
  rightMotorSpeed = 0;
}


// send payload to the microbit whenever the microbit requests it
//
// Executes whenever data is requested by master.
// This function is registered as an event, see setup().
void requestEvent()
{
  if(hasError == false)
  {
    if(isPayloadReady == true)
    {
      sendSensorData(payload);
    }
    else
    {
      sendSensorData(oldPayload);
    }
    blinkLed();
  }
}


// sends sensor data to the microbit over I2C
void sendSensorData(Payload thisPayload)
{
  // Send the struct and then rebuild it on the other side.
  // See: https://stackoverflow.com/questions/13775893/converting-struct-to-byte-and-back-to-struct
  char bytesArray[sizeof(thisPayload)];
  memcpy(bytesArray, &thisPayload, sizeof(thisPayload));
  Wire.write(bytesArray, sizeof(bytesArray));
}


// sets either the left or the right motor speed (which are global variables)
void setMotorSpeed(MicrobitMotorSpeed speedStruct)
{
  if(speedStruct.left <= NULL_MOTOR_SPEED && speedStruct.right <= NULL_MOTOR_SPEED)
  {
    // at least one speed should be set
    registerError("MTRSPED1");
  }
  else if(speedStruct.left > NULL_MOTOR_SPEED && speedStruct.right > NULL_MOTOR_SPEED)
  {
    // this should never execute. Only one speed should be set unless you break the code.
    registerError("MTRSPED2");
  }
  else if(speedStruct.left > NULL_MOTOR_SPEED)
  {
    leftMotorSpeed = toZumoMotorSpeed(speedStruct.left);
  }
  else if(speedStruct.right > NULL_MOTOR_SPEED)
  {
    rightMotorSpeed = toZumoMotorSpeed(speedStruct.right);
  }
  else
  {
    // this should never execute. All options should be covered above unless you break the code.
    registerError("MTRSPED3");
  }
}


// returns the battery level in tenths of volts
//
// Example: 4853 mv becomes 48
byte toMicrobitBattVoltsValue(unsigned int batteryMillivolts)
{
  // ensure it fits in a byte
  unsigned int battVoltsTenths = batteryMillivolts / 100;

  // Note: 80 is the max value for this parameter on the microbit side.
  // Something is wrong with the bot if this function returns a number > 80.
  return constrain(battVoltsTenths, 0, 255);
}


// converts a zumo line sensor value to a microbit line sensor value and returns it
byte toMicrobitLineSensorValue(unsigned int zumoLineSensorValue)
{
  // zumo range: 0 .. 2000
  // microbit range: 0 .. 200
  return map(zumoLineSensorValue, 0, 2000, 0, 200);
}


// converts the microbit motor speed to the zumo motor speed and returns it
int toZumoMotorSpeed(int microbitMotorSpeed)
{
  // microbit range: -50 .. 50
  // zumo range: -400 .. 400
  return map(microbitMotorSpeed, -50, 50, -400, 400);
}


// ############################################################################
// ###                           Unit Tests                                 ###
// ############################################################################

/*
test(duration_0_0)
{
  assertEqual(duration(0, 0), 0);
}

test(duration_0_10)
{
  assertEqual(duration(0, 10), 10);
}

test(duration_0_2147483647)
{
  // max long value
  assertEqual(duration(0, 2147483647), 2147483647);
}

// This test won't compile. I believe there's a defect in the ArduinoUnit
// that prevents it from working with unsigned longs. But if it did
// compile, this test should pass as should a test of unsigned long max.
// Even if a signed long was the max value duration could handle that
// would still allow duration to register something like 25 days, which
// should be plenty long for a battery powered robot.
//test(duration_0_2147483648)
//{
//  // 2147483648 = long max + 1
//  assertEqual(duration(0, 2147483648), 2147483648);
//}

test(duration_4294967295_0)
{
  assertEqual(duration(4294967295, 0), 1);
}

test(duration_4294967290_9)
{
  // 5 seconds before rollover, plus one second for the rollover + 4 = 10
  assertEqual(duration(4294967290, 4), 10);
}

test(calculateMotorSpeed_0)
{
  // min left speed
  MicrobitMotorSpeed microbitMotorSpeed = calculateMotorSpeed(0);
  assertEqual(microbitMotorSpeed.left, -50);
  assertEqual(microbitMotorSpeed.right, NULL_MOTOR_SPEED);
}

test(calculateMotorSpeed_50)
{
  // zero left speed
  MicrobitMotorSpeed microbitMotorSpeed = calculateMotorSpeed(50);
  assertEqual(microbitMotorSpeed.left, 0);
  assertEqual(microbitMotorSpeed.right, NULL_MOTOR_SPEED);
}

test(calculateMotorSpeed_100)
{
  // max left speed
  MicrobitMotorSpeed microbitMotorSpeed = calculateMotorSpeed(100);
  assertEqual(microbitMotorSpeed.left, 50);
  assertEqual(microbitMotorSpeed.right, NULL_MOTOR_SPEED);
}

test(calculateMotorSpeed_101)
{
  // beyond max left speed
  MicrobitMotorSpeed microbitMotorSpeed = calculateMotorSpeed(101);
  assertEqual(microbitMotorSpeed.left, NULL_MOTOR_SPEED);
  assertEqual(microbitMotorSpeed.right, NULL_MOTOR_SPEED);
}

test(calculateMotorSpeed_109)
{
  // invalid motor speed
  MicrobitMotorSpeed microbitMotorSpeed = calculateMotorSpeed(109);
  assertEqual(microbitMotorSpeed.left, NULL_MOTOR_SPEED);
  assertEqual(microbitMotorSpeed.right, NULL_MOTOR_SPEED);
}

test(calculateMotorSpeed_110)
{
  // min right speed
  MicrobitMotorSpeed microbitMotorSpeed = calculateMotorSpeed(110);
  assertEqual(microbitMotorSpeed.left, NULL_MOTOR_SPEED);
  assertEqual(microbitMotorSpeed.right, -50);
}

test(calculateMotorSpeed_160)
{
  // zero right speed
  MicrobitMotorSpeed microbitMotorSpeed = calculateMotorSpeed(160);
  assertEqual(microbitMotorSpeed.left, NULL_MOTOR_SPEED);
  assertEqual(microbitMotorSpeed.right, 0);
}

test(calculateMotorSpeed_210)
{
  // max right speed
  MicrobitMotorSpeed microbitMotorSpeed = calculateMotorSpeed(210);
  assertEqual(microbitMotorSpeed.left, NULL_MOTOR_SPEED);
  assertEqual(microbitMotorSpeed.right, 50);
}

test(calculateMotorSpeed_211)
{
  // beyond max right speed
  MicrobitMotorSpeed microbitMotorSpeed = calculateMotorSpeed(211);
  assertEqual(microbitMotorSpeed.left, NULL_MOTOR_SPEED);
  assertEqual(microbitMotorSpeed.right, NULL_MOTOR_SPEED);
}

test(getChecksum_payloadWithNoValues)
{
  Payload testPayload; // payload with no values should have a checksum of zero
  assertEqual(getChecksum(testPayload), 0);
}

test(getChecksum_payloadAllOnes)
{
  Payload testPayload;
  testPayload.proxLeft = 1;
  testPayload.proxFrontLeft = 1;
  testPayload.proxFrontRight = 1;
  testPayload.proxRight = 1;
  testPayload.lineLeft = 1;
  testPayload.lineCenter = 1;
  testPayload.lineRight = 1;
  testPayload.battVoltsTenths = 1;
  testPayload.isUsbPowerPresent = 1;
  assertEqual(getChecksum(testPayload), 9);
}

test(getChecksum_payloadAllMaxValues)
{
  Payload testPayload;
  testPayload.proxLeft = 6;
  testPayload.proxFrontLeft = 6;
  testPayload.proxFrontRight = 6;
  testPayload.proxRight = 6;
  testPayload.lineLeft = 200;
  testPayload.lineCenter = 200;
  testPayload.lineRight = 200;
  testPayload.battVoltsTenths = 255;
  testPayload.isUsbPowerPresent = 1;
  assertEqual(getChecksum(testPayload), 112);
}

test(getChecksum_payloadWithExistingChecksum)
{
  Payload testPayload;
  testPayload.proxLeft = 0;
  testPayload.proxFrontLeft = 0;
  testPayload.proxFrontRight = 0;
  testPayload.proxRight = 0;
  testPayload.lineLeft = 0;
  testPayload.lineCenter = 0;
  testPayload.lineRight = 0;
  testPayload.battVoltsTenths = 0;
  testPayload.isUsbPowerPresent = 1;
  testPayload.checksum = 1; // this value should never be counted towards the checksum
  assertEqual(getChecksum(testPayload), 1);
}

test(getBattVoltsTenthsForLcd_0)
{
  assertEqual(getBattVoltsTenthsForLcd(0), 0);
}

test(getBattVoltsTenthsForLcd_99)
{
  assertEqual(getBattVoltsTenthsForLcd(99), 99);
}

test(getBattVoltsTenthsForLcd_100)
{
  assertEqual(getBattVoltsTenthsForLcd(100), 99);
}

test(getFrameRateForLcd_18_10000)
{
  // 18 commands in 10 seconds is 0.9 frames per second which is truncated to 0
  assertEqual(getFrameRateForLcd(18, 10000), 0);
}

test(getFrameRateForLcd_100_0)
{
  // protect from div by zero
  assertEqual(getFrameRateForLcd(100, 0), 0);
}

test(getFrameRateForLcd_200_1000)
{
  // 200 commands in 1 second is 100 frames per second
  assertEqual(getFrameRateForLcd(200, 1000), 100);
}

test(getFrameRateForLcd_1996_1000)
{
  // 1,996 commands in 1 second is 998 frames per second, which is the max - 1
  assertEqual(getFrameRateForLcd(1996, 1000), 998);
}

test(getFrameRateForLcd_1998_1000)
{
  // 1,998 commands in 1 second is 999 frames per second, which is the max allowed
  assertEqual(getFrameRateForLcd(1998, 1000), 999);
}

test(getFrameRateForLcd_2000_1000)
{
  // 2,000 commands in 1 second is 1,000 frames per second, which is capped at 999
  assertEqual(getFrameRateForLcd(2000, 1000), 999);
}
*/
