# High Integrity Sumobot
This mini-sumobot is an advanced-level project programmed in Ada/SPARK and Arduino (C++).

[![High Integrity Sumobot - Fighting Demo](/images/youtube_sumobot_fighting_demo_cover.png)](https://youtu.be/GyEZLSxFQtE "High Integrity Sumobot - Fighting Demo")


# Story
I created the *High Integrity Sumobot* using Ada/SPARK and high integrity software engineering techniques. I wanted to make it easy for people interested in Ada/SPARK to see how all the pieces fit together in a small embedded project.

I did my best to write simple, clean, and maintainable code throughout. It's extensively commented and it's [open source](https://github.com/bosepchuk/High_Integrity_Sumobot/blob/master/LICENSE.txt) so you can use it almost any way you want.


# System overview
I started with a [Zumo 32U4](https://www.pololu.com/product/3126) sumobot. But instead of programming it directly as a microcontroller like most people do, I turned it into an I2C slave device, which I control with a microbit I programmed in Ada/SPARK.

The zumo continuously collects sensor data and stores it in a buffer. The microbit periodically requests sensor data from the zumo over I2C and the zumo sends the data it most recently collected. The microbit validates the sensor data, decides how the zumo should move, and sends motor commands back to the zumo (also over I2C). The zumo validates the motor commands and then executes them. And then the process repeats (at least 50 times per second).

![describes the communications between the zumo and the microbit](/images/high_integrity_sumobot_comms_overview.png)

The main job of a sumobot is to fight in sumo competitions. So the bulk of the code on the microbit is related to the fighting algorithm. Here's a simplified state table for it:

![state table for the fighting algorithm](/images/state_table.png)

The 5 x 5 display on the microbit shows a character representing the current top-level state of the system (see the "Display" column of the state table above):

![high integrity sumobot showing the top-level state on the 5 x 5 display](/images/IMG_1967-compressor.jpg)

You can see the most important zumo parameters on the zumo's LCD, which is helpful for development and debugging. It shows the following information:

![overview of the LCD display](/images/zumo_lcd_normal_display.png)


# More information and build instructions
You can find the [full documentation and build instructions for this project on my website](https://smallbusinessprogramming.com/high-integrity-sumobot-build-instructions/). I've included everything you need to create your own *High Integrity Sumobot*:

* written requirements
* full parts list
* wiring diagram
* detailed build instructions (with photos)
* detailed software installation instructions (with screenshots)
* instructions for how to run the automated unit tests
* compile/build and upload/flashing instructions (with screenshots)
* end-to-end testing plan linked to each requirement
