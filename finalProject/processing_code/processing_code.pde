import processing.serial.*;
import processing.sound.SoundFile;
import java.util.ArrayList;
import java.util.HashMap;

Serial serial;
final int loopDuration = 5 * 60;

public class Button {
  private color buttonColor;
  private String text;
  private PVector position;
  private PVector dimensions;

  private int triggered;

  public Button(PVector position, color buttonColor, String text, boolean bigButton) {
    this.position = position;
    this.buttonColor = buttonColor;
    this.text = text;

    this.dimensions = new PVector(width - this.position.x - 30, bigButton? 45: 30);
  }

  public void display() {
    noStroke();
    fill(this.buttonColor);
    rect(this.position.x, this.position.y, this.dimensions.x, this.dimensions.y, 5);

    fill(255);
    textAlign(CENTER);
    textSize(20);
    text(this.text, this.position.x + this.dimensions.x / 2, this.position.y + this.dimensions.y / 2 + 7);

    this.handleClick();
  }

  public void handleClick() {
    int delay = frameCount - this.triggered;
    if (mousePressed && abs((this.position.x + this.dimensions.x / 2) - mouseX) < (this.dimensions.x / 2) && abs((this.position.y + this.dimensions.y / 2) - mouseY) < (this.dimensions.y / 2) && delay >= 60) {
      this.triggered = frameCount;

      if (this.text == "RECORD") {
        this.text = "STOP";
        midi.loopStation.toggleRecord();
      } else if (this.text == "STOP") {
        this.text = "RECORD";
        midi.loopStation.toggleRecord();
      } else if (this.text == "RESET") {
        midi = new Midi();
      } else if (this.text == "SWITCH") {
        midi.beats = !midi.beats;
      } else if (this.text == "UNDO") {
        midi.loopStation.undo();
      }
    }
  }
}
public class Note {
  private PVector position;
  private float noteWidth, noteHeight;
  private SoundFile sound;
  private char type;
  private int index;

  private int prevMillis = 0;

  public Note(int index, char type, PVector position) {
    this.noteWidth = type == 'd' ? 80: width / (15 * (type == 'b' ? 2: 1));
    this.noteHeight = type == 'd' ? 80: 220 / (type == 'b' ? 1.8: 1);

    this.type = type;
    this.index = index;

    this.position = position == null ? new PVector(index * this.noteWidth, height - this.noteHeight) : position;
    this.sound = new SoundFile(processing_code.this, "sounds/" + type + index + ".mp3");
  }

  public void play() {
    this.sound.play();
  }

  public void playNote() {
    int delayed = millis() - this.prevMillis;
    if (delayed > 250) {
      if (midi.loopStation.recording) {
        midi.loopStation.add(this.sound, this.index);
      } else {
        this.play();
      }
      this.prevMillis = millis();
    }
  }

  public void display() {
    int overlayed = millis() - this.prevMillis;
    if (this.type == 'd') {
      fill(overlayed > 200 ? 48: 100);
      stroke(80);
      rect(this.position.x, this.position.y, 80, 80, 7);
    } else {
      fill(this.type == 'b' ? (overlayed > 200? 0: 48): (overlayed > 200 ? 255 : 224));
      strokeWeight(1);
      stroke(200);

      rect(this.position.x, this.position.y, this.noteWidth, this.noteHeight);
    }
  }

  public void hover(int colorIndex) {
    color[] colors = {color(168, 35, 35), color(57, 148, 47), color(27, 142, 204), color(252, 177, 3)};
    fill(colors[colorIndex]);
    noStroke();
    ellipse(this.position.x + this.noteWidth / 2, this.position.y + this.noteHeight - 20, 9, 9);
  }
}

public class LoopStation {
  public boolean recording;
  public ArrayList<ArrayList<HashMap<String, Object>>> loops;

  public LoopStation() {
    this.recording = false;
    this.loops = new ArrayList<ArrayList<HashMap<String, Object>>>();
  }

  private void cleanEmptyTracks() {
    for (int i = 0; i < this.loops.size(); i++) {
      if (this.loops.get(i).size() == 0) {
        this.loops.remove(this.loops.get(i));
      }
    }
  }
  
  public void toggleRecord() {
    this.cleanEmptyTracks();

    if (!this.recording) {
      this.loops.add(new ArrayList<HashMap<String, Object>>());
    }
    this.recording = !this.recording;
  }

  public void add(SoundFile sound, int index) {
    HashMap<String, Object> data = new HashMap<String, Object>();
    data.put("sound", sound);
    data.put("timestamp", float(frameCount % loopDuration));
    data.put("intensity", index);

    if (this.loops.size() == 0) {
      this.loops.add(new ArrayList<HashMap<String, Object>>());
    }
    this.loops.get(this.loops.size() - 1).add(data);
  }

  public void playAll() {
    for (ArrayList<HashMap<String, Object>> loop : this.loops) {
      for (int i = 0; i < loop.size(); i++) {
        HashMap<String, Object> data = loop.get(i);
        if (float(frameCount % loopDuration) == (float) data.get("timestamp")) {
          ((SoundFile) (data.get("sound"))).play();
        }
      }
    }
  }

  public void undo() {
    this.cleanEmptyTracks();
    if (this.loops.size() > 0) {
      this.loops.remove(this.loops.get(this.loops.size() - 1));
    }
  }
}

public class Midi {
  private Note[] whiteNotes;
  private Note[] blackNotes;
  private Note[] drums;

  private Button[] buttons;

  private PFont font;

  public LoopStation loopStation;

  public int maxNoteIndex;
  public char currentNoteType;

  public boolean beats;

  public Midi() {
    font = createFont("fonts/big_noodle_titling.ttf", 32);
    textFont(font);

    this.loopStation = new LoopStation();

    this.buttons = new Button[4];
    this.buttons[0] = new Button(new PVector(580, 30), color(201, 38, 38), "RECORD", true);
    this.buttons[1] = new Button(new PVector(580, 85), color(36, 78, 117), "RESET", true);
    this.buttons[2] = new Button(new PVector(580, 150), color(48), "SWITCH", false);
    this.buttons[3] = new Button(new PVector(580, 184), color(48), "UNDO", false);

    this.whiteNotes = new Note[15];
    this.blackNotes = new Note[10];

    this.drums = new Note[4];
    this.drums[0] = new Note(0, 'd', new PVector(30, 30));
    this.drums[1] = new Note(1, 'd', new PVector(130, 30));
    this.drums[2] = new Note(2, 'd', new PVector(30, 130));
    this.drums[3] = new Note(3, 'd', new PVector(130, 130));

    for (int i = 0; i < this.whiteNotes.length; i++) {
      this.whiteNotes[i] = new Note(i, 'w', null);
    }

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

    this.maxNoteIndex = 3;
    this.currentNoteType = 'w';
    this.beats = false;
  }

  public void display() {
    background(20);

    visualization();

    noStroke();
    fill(28);
    rect(0, height - 241, width, 20);

    for (Note note : this.whiteNotes) {
      note.display();
    }

    for (Note note : this.blackNotes) {
      note.display();
    }

    for (Note note : this.drums) {
      note.display();
    }

    for (Button button : this.buttons) {
      button.display();
    }

    int colorIndex = 0;
    for (int i = this.maxNoteIndex - 3; i <= this.maxNoteIndex; i++) {
      switch(currentNoteType) {
      case 'w':
        this.whiteNotes[i].hover(colorIndex);
        break;

      case 'b':
        this.blackNotes[i].hover(colorIndex);
        break;

      case 'd':
        this.drums[colorIndex].hover(colorIndex);
        break;
      }

      colorIndex++;
    }
  }

  public void play(int noteIndex) {
    if (noteIndex >= 0 && noteIndex < 4) {
      int playIndex = this.maxNoteIndex - 3 + noteIndex;
      switch(currentNoteType) {
      case 'w':
        this.whiteNotes[playIndex].playNote();
        break;

      case 'b':
        this.blackNotes[playIndex].playNote();
        break;

      case 'd':
        this.drums[noteIndex].playNote();
        break;
      }
    }
  }

  private void visualization() {
    int left = 250;
    int right = 550;

    fill(30);
    rect(left, 30, right - left, 150, 4);

    for (ArrayList<HashMap<String, Object>> loop : loopStation.loops) {
      for (int i = 0; i < loop.size(); i++) {
        HashMap<String, Object> data = loop.get(i);
        float pos = constrain(map((float) data.get("timestamp"), 0, loopDuration, left, right), left, right - 20);

        float single = 100 / 15;
        float barHeight = single * ((int) data.get("intensity") + 1);

        fill(60);
        stroke(30);
        strokeWeight(2);
        rect(pos, 175 - barHeight, 6, barHeight, 5);
      }
    }
    noStroke();
    fill(97, 194, 242);
    rect(left, height - 220 - 51, right - left, 2, 4);
    ellipse(map(frameCount % loopDuration, 0, loopDuration, left, right), height - 220 - 50, 10, 10);
  }
}

Midi midi;

void setup() {
  frameRate(60);
  size(750, 480);

  midi = new Midi();
  // for serial communication with arduino
  serial = new Serial(this, Serial.list()[0], 9600);
  serial.clear();
  serial.bufferUntil('\n');
}

void draw() {
  midi.display();
  midi.loopStation.playAll();
}

// serial event for communication with arduino
void serialEvent(Serial serial) {
  // received message
  String message = trim(serial.readStringUntil('\n'));
  if (message != null) {
    String[] values = split(message, ',');
    if (values.length == 3) {
      midi.maxNoteIndex = constrain(int(values[0]), 3, 14);
      midi.play(constrain(int(values[1]), -1, 3));

      if (midi.beats) {
        midi.currentNoteType = 'd';
      } else if (values[2].contains("SHARP")) {
        midi.currentNoteType = 'b';
      } else {
        midi.currentNoteType = 'w';
      }
    }
  }
}
