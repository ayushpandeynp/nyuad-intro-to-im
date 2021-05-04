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


### Apr 22, 2021
I had made the basic framework ready by just using the major & flat notes (the white ones on the keyboard). Now I had to add sharp notes and drums. It did not satisfy me to manually provide positions and render the black keys on screen. So, I used figured out something like this:

```java
int blackNoteCount = 0, marginOffset = 0;
int whiteNoteWidth = width / 15;
int whiteNoteHeight = 220;

int c = 2; 
boolean sequenceSwitcher = true;
int limit = this.blackNotes.length;
while (blackNoteCount < limit) {
  if (marginOffset % c == 0 && marginOffset > 0) {
    marginOffset++;
    c += sequenceSwitcher ? 4 : 3;
    sequenceSwitcher = !sequenceSwitcher;
    continue;
  }

  this.blackNotes[blackNoteCount] = new Note(blackNoteCount, 'b', new PVector(whiteNoteWidth * (marginOffset + 1) - (width / (15 * 2)) / 2, height - whiteNoteHeight));
      
  blackNoteCount++;
  marginOffset++;
}
```

I set up the drums as well and now everything was working the way I expected.

### APR 23, 2021
I still needed to add the visualization. I would've skipped it but it was the only thing that would indicate a musician which point in the loop has what kind of note. So, I decided to use every note's ```index``` variable to render the bars on screen. The ```index``` is used to position the notes and get the filename of these notes. The more index, the higher frequency of notes. Therefore, it would be a better indicator of intensity than anything else.

I then added a method ```visualization()``` that renders bars at the exact point where notes are recorded. Here's how the bars are rendered:

```java
for (ArrayList < HashMap < String, Object >> loop: loopStation.loops) {
    for (int i = 0; i < loop.size(); i++) {
        HashMap < String, Object > data = loop.get(i);
        float pos = constrain(map((float) data.get("timestamp"), 0, loopDuration, left, right), left, right - 20);

        float single = 100 / 15;
        float barHeight = single * ((int) data.get("intensity") + 1);

        fill(60);
        stroke(30);
        strokeWeight(2);
        rect(pos, 175 - barHeight, 6, barHeight, 5);
    }
}
```

### APR 24, 2021
I added buttons to RECORD, RESET and UNDO. As I had already thought of it in the beginning and had created a good framework, the task became really easy. Any last minute modification wouldn't have been a tedious task because of having a strong framework setup.

### APR 27, 2021
Now, I had to connect everything with the controller hardware. I wrote code for Arduino and tested out everything so that there was no issue in the Serial communication. I also added the circular indicators that changes as the value of potentiometer changes.

### APR 28, 2021
Added some final touchups and experimented with the loopstation. It turned out to be more than what I had expected. I was able to play all the notes smoothly and create weird as well as smooth tracks.

I have created a demonstration video that plays Shape of You by Ed Sheeran through my loopstation.

PROJECT COMPLETE! CHEERS!

Thank you!
