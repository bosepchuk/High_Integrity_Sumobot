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


// This file contains non-critical code. By that I mean code that is not
// essential to the safe operation of the bot.


// VARIABLES
volatile unsigned long ledStartTime = 0;
unsigned long lcdLastUpdateTime = 0;
unsigned long serialLastUpdateTime = 0;
unsigned long frameRateLastUpdateTime = 0;
unsigned long motorCmdsFrameRate = 0;
Zumo32U4LCD lcd;


// turn the led on and set a variable so we can use another
// function to turn it off after its been on long enough
void blinkLed()
{
  digitalWrite(LED_PIN, HIGH);
  ledStartTime = millis();
}


// return the battery voltage capped at 99 for display purposes
byte getBattVoltsTenthsForLcd(byte battVoltsTenths)
{
  if(battVoltsTenths > 99)
  {
    return 99;
  }
  return battVoltsTenths;
}


// returns the frequency (in Hz) at which motor commands are received for display on the LCD
unsigned int getFrameRateForLcd(unsigned long numMotorCmdsReceived, unsigned long durationMs)
{
  if(durationMs == 0)
  {
    // protect from div by zero
    return 0;
  }
  // the zumo receives 2 motor commands for every "frame" (one for the left and one for
  // the right motor). That's why there's a divide by 2 below.
  unsigned long frameRate = numMotorCmdsReceived / 2 * 1000 / durationMs;
  if(frameRate > 999)
  {
    // don't allow the frame rate to take more than 3 chars on the display
    return 999;
  }
  return frameRate;
}


void ledOffIfNecessary()
{
  unsigned long LED_ON_DURATION_MS = 6;
  if(duration(ledStartTime, millis()) > LED_ON_DURATION_MS)
  {
    digitalWrite(LED_PIN, LOW);
  }
}


void updateFrameRateForLcdIfNecessary()
{
  unsigned long FRAME_RATE_UPDATE_TIME_MS = 2500;
  unsigned long timeNow = millis();
  unsigned long durationMs = duration(frameRateLastUpdateTime, timeNow);
  if(durationMs >= FRAME_RATE_UPDATE_TIME_MS)
  {
    motorCmdsFrameRate = getFrameRateForLcd(numMotorCmdsReceived, durationMs);
    numMotorCmdsReceived = 0;
    frameRateLastUpdateTime = timeNow;
  }
}


// helper function intended to be called from updateLcdIfNecessary()
void updateLcd()
{
  unsigned int battVoltsTenthsDisplay;
  lcd.clear();
  if(hasError)
  {
    lcd.print("Error");
    lcd.gotoXY(0, 1);
    lcd.print(errorMsg);
  }
  else
  {
    lcd.gotoXY(0, 0);
    lcd.print(payload.proxLeft);
    lcd.print("  ");
    lcd.print(payload.proxFrontLeft);
    lcd.print(payload.proxFrontRight);
    lcd.print("  ");
    lcd.print(payload.proxRight);

    // print the frame rate on the left side of the second line
    lcd.gotoXY(0, 1);
    lcd.print(motorCmdsFrameRate);
    lcd.print("F");

    // print the voltage on the right side of the second line
    byte displayVolts = getBattVoltsTenthsForLcd(payload.battVoltsTenths);
    // ensure the volts display on the right side of the LCD
    if(displayVolts < 10)
    {
      lcd.gotoXY(6, 1);
    }
    else
    {
      lcd.gotoXY(5, 1);
    }
    lcd.print(displayVolts);
    lcd.print("V");
  }
}


void updateLcdIfNecessary()
{
  unsigned long LCD_UPDATE_TIME_MS = 100;
  unsigned long timeNow = millis();
  if(duration(lcdLastUpdateTime, timeNow) >= LCD_UPDATE_TIME_MS)
  {
    updateLcd();
    lcdLastUpdateTime = timeNow;
  }
}


// helper function intended to be called from updateSerialMonitorIfNecessary()
void updateSerialMonitor()
{
  if(hasError)
  {
    Serial.println(errorMsg);
  }
  else
  {
    Serial.print("motors: ");
    Serial.print(leftMotorSpeed);
    Serial.print(":");
    Serial.print(rightMotorSpeed);

    Serial.print("  prox: ");
    Serial.print(payload.proxLeft);
    Serial.print(" : ");
    Serial.print(payload.proxFrontLeft);
    Serial.print(":");
    Serial.print(payload.proxFrontRight);
    Serial.print(" : ");
    Serial.print(payload.proxRight);

    Serial.print("  line: ");
    Serial.print(payload.lineLeft);
    Serial.print(":");
    Serial.print(payload.lineCenter);
    Serial.print(":");
    Serial.print(payload.lineRight);

    Serial.print(" batt volts tenths: ");
    Serial.print(payload.battVoltsTenths);
    Serial.print("  usb is ");
    if(payload.isUsbPowerPresent == 0)
    {
      Serial.print("not ");
    }
    Serial.println("present");
  }
}


void updateSerialMonitorIfNecessary()
{
  if(IS_SERIAL_ENABLED == true)
  {
    unsigned long SERIAL_UPDATE_TIME_MS = 500;
    unsigned long timeNow = millis();
    if(duration(serialLastUpdateTime, timeNow) >= SERIAL_UPDATE_TIME_MS)
    {
      serialLastUpdateTime = timeNow;
      updateSerialMonitor();
    }
  }
}


// updates all the visible indicators of the zumo's status
void updateViewIfNecessary()
{
  ledOffIfNecessary();
  updateFrameRateForLcdIfNecessary();
  updateLcdIfNecessary();
  updateSerialMonitorIfNecessary();
}
