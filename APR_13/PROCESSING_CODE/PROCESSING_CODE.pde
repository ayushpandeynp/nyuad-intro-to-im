import java.util.ArrayList;
import processing.serial.*;

// Serial object
Serial serial;

// individual block size
final int blockSize = 30;

// all color options for block
ArrayList<Integer> colors = new ArrayList<Integer>();

public class Block {
  public int row, col, fillColor;

  // constructor
  public Block(int row, int col) {
    this.row = row;
    this.col = col;
    this.fillColor = color(64);
  }
  
  // to display block on screen
  public void display() {
    
    // instead of using lines, using stroke to show grid layout
    strokeWeight(1);
    stroke(115);
    
    // drawing on screen
    fill(this.fillColor);
    rect(this.col * blockSize, this.row * blockSize, blockSize, blockSize);
  }
}


// main Game class
public class Game {
  private int speed, score;
  private int[] active;
  private boolean gameOver;

  // 2d-ArrayList of all blocks
  private ArrayList<ArrayList<Block>> blockList;
  
  // constructor
  public Game() {
    
    // adding color options
    colors.add(color(64));
    colors.add(color(36, 130, 201));
    colors.add(color(224, 190, 16));  // yellow
    colors.add(color(25, 179, 71));  // green
    colors.add(color(201, 39, 14));  // red

    // basic parameters for the game
    this.speed = 0;
    this.score = 0;
    this.active = null;
    this.gameOver = false;
    
    this.blockList = new ArrayList<ArrayList<Block>>();

    // initializing empty block objects on the 2d-ArrayList
    for (int i = 0; i < height / blockSize; i++) {
      ArrayList<Block> blocks = new ArrayList<Block>();

      for (int j = 0; j < width / blockSize; j++) {
        blocks.add(new Block(i, j));
      }

      blockList.add(blocks);
    }
  }

  // method to update the game screen
  private void update() {
    
    // controlling speed of game
    if (frameCount % (max(1, int(8 - this.speed))) == 0 || frameCount == 1) {
      
      // if game is not over
      if (!this.gameOver) {
        
        // if there is no active block
        if (this.active == null) {
          
          // create a new block
          this.newBlock();
        } else {
          // otherwise, swap block to 1 step down vertically
          this.swapBlock(0);
        }

        // display block on screen
        for (ArrayList<Block> row : blockList) {
          for (Block block : row) {
            block.display();
          }
        }
  
        
        // score
        textSize(15);
        fill(255);
        text("Score: " + this.score, width - 70, 20);
        
      } else {
        
        // game over screen
        background(64);
        fill(255);
        textSize(20);
        text("GAME OVER", 15, 30);
        
        textSize(13);
        text("SCORE: " + this.score + "\nClick anywhere to\nrestart the game.", 15, 60);
      }
    }
  }
  
  // method to create a new block
  private void newBlock() {
    // getting random horizontal position on top of the blockList
    int position = (int) random(0, 10);

    // checking if block already exists at the top, also making sure all positions are not filled
    int count = 0;
    while (this.getBlock(0, position).fillColor != colors.get(0) && count < 10) {
      position = (int) random(0, 10);
      count++;
    }
    
    // if all positions are filled, game is over
    if (count == 10) {
      this.gameOver = true;
    } else {
      // otherwise, change color of the block on generated random position
      int randomChoice = (int) random(1, 5);

      this.getBlock(0, position).fillColor = colors.get(randomChoice);
      this.active = new int[]{0, position};

      // increase the speed of game
      this.speed += 0.5;
    }
  }
  
  // method to check if 4 blocks are on top of eachother
  private void check(int row, int col) {
    if (row + 3 < height / blockSize) {
      int count = row;
      int activeColor = this.getBlock(row, col).fillColor;

      ArrayList<int[]> blocks = new ArrayList<int[]>();

      while (count < row + 4) {
        if (this.getBlock(count, col).fillColor == activeColor) {
          blocks.add(new int[]{count, col});
        } else {
          return;
        }

        count++;
      }
      
      for(int[] b: blocks){
        this.getBlock(b[0], b[1]).fillColor = colors.get(0);
      }
      
      this.speed = 0;
      this.score++;
    }
  }
  
  
  // helper method to swap block vertically up, down and horizontally left, right
  private void swapBlock(int horizontal) {
    int maxY = height / blockSize;
    int maxX = height / blockSize;
    
    // making sure the block don't go off limits
    if (this.active != null && this.active[0] + 1 < maxY) {
      if (this.getBlock(this.active[0] + 1, this.active[1]).fillColor == colors.get(0)) {
        if (this.active[1] + horizontal >= 0 && this.active[1] + horizontal < maxX) {
          if (this.getBlock(this.active[0] + 1, this.active[1] + horizontal).fillColor != colors.get(0)) {
            horizontal = 0;
          }
        } else {
          horizontal = 0;
        }
        
        // getting two block objects to swap
        Block block1 = this.getBlock(this.active[0], this.active[1]);
        Block block2 = this.getBlock(this.active[0] + 1, this.active[1] + horizontal);
  
        // swapping block colors instead of swapping rows and column indexes
        block2.fillColor = block1.fillColor;
        block1.fillColor = colors.get(0);
        
        // marking swapped block as active
        this.active = new int[]{this.active[0] + 1, this.active[1] + horizontal};
      } else {
        this.check(this.active[0], this.active[1]);
        this.active = null;
      }
    } else {
      if (this.active != null) {
        this.check(this.active[0], this.active[1]);
      }

      this.active = null;
    }
  }
  
  
  // helper method to get block object using row and column
  private Block getBlock(int r, int c) {
    // find block using linear search
    for (ArrayList<Block> row : this.blockList) {
      for (Block block : row) {
        if (r == block.row && c == block.col) {
          return block;
        }
      }
    }

    return null;
  }
  
  // method to start/restart the game
  private void newGame() {
    this.gameOver = false;
    this.score = 0;
    this.speed = 0;
    this.active = null;
    
    // clearing colors from all blocks
    for (ArrayList<Block> row : this.blockList) {
      for (Block block : row) {
        block.fillColor = colors.get(0);
      }
    }
  }
}

// game object
Game game;

void setup() {
  size(300, 600);
  background(210);

  game = new Game();
  
  // for serial communication with arduino
  serial = new Serial(this, Serial.list()[0], 9600);
  serial.clear();
  serial.bufferUntil('\n');
}

// updating game screen
void draw() {
  game.update();
}

// if keys are pressed from Keyboard
void keyPressed() {
  if (keyCode == LEFT) {
    game.swapBlock(-1);
  } else if (keyCode == RIGHT) {
    game.swapBlock(1);
  }
}

// if mouse clicked when game is over, restart the game
void mousePressed() {
  if (game.gameOver) {
    game.newGame();
  }
}

// serial event for communication with arduino
void serialEvent(Serial serial) {
  // received message
  String message = trim(serial.readStringUntil('\n'));
  if (message != null) {

    // if message is LEFT, move block to LEFT 
    if (message.contains("LEFT")) {
      game.swapBlock(-1);
    } else if (message.contains("RIGHT")) {  // else move to RIGHT
      game.swapBlock(1);
    }
  }
}
