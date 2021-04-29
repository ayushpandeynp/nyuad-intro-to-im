# Mini MIDI Keyboard with Loopstation
I am thinking of building a Mini MIDI Keyboard that uses Switches to play notes and a Potentiometer to change the scales from lower to higher. The interface will also support Looping of audio using beats.

The player will need to move around the octave / 2 (because we only have 4 switches) area using Potentiometer and play the notes. On the computer screen, there will be an interface to see notes, add tracks and create beats. All the generated music will be played in one loop; therefore, the player will be able to generate their own audio.

This is a very general idea of the project, so a lot of things might change. Anyway, I will document my journey of the project in this document.

### Idea Sketch
![](images/sketch.jpg)

### Schematic
Most of the work will be handled in Processing but the Arduino will be used to retrieve information on which keys were pressed (using switches) and where to move the octave / 2 range on screen (using the potentiometer). I am also thinking about showing some result in Arduino too, but need to brainstorm about it. Here's my initial schematic:

![](images/schematic.jpg)

# Journal

### APR 19, 2021
The most challenging part of the project is to keep track of the notes played at a certain timestamp and play it altogether. Therefore, I wanted to create a framework to record the notes, add it to tracks, and play all of them together. I decided to create a ```LoopStation``` class to handle it.

First, I was using ```millis()``` to keep track of the timestamp, but it appears that it skips certain milliseconds since the framerate is very high. This led to a problem where processing skipped notes at the exact timestamp. So, I worked around this problem with ```frameRate()``` and ```frameCount```.

If there is a framerate of 60fps and loop duration of 8s (8 * 60 frames), I can find the exact point of note to be played by comparing ```frameCount % loopDuration == timestamp```. This resolved my issue.

Right now, I have a good framework for the project ready where I can pass in any Note object and add it to the loop tracks. I can also create multiple tracks and the ```LoopStation``` class will handle everything for me.


To be continued...
