# TETRIS RUSH
This project is an inspiration from a popular game Tetris where you need to find gaps in the wall made up of blocks. If your blocks pile up to the top, you lose, otherwise you keep playing.

In this project, the game is displayed in Processing, but you need to control the game through gamepad buttons (made using Arduino).

### INSTRUCTIONS
The game starts with an empty grid where one block is generated at a random horizontal column at the top. The block falls down with a constant speed and when it reaches the bottom, another block is generated. This process continues and for every new block generated, falling speed increased. The goal of the player is to put blocks of same color on top of eachother. If 4 blocks of same color (blue, for example) are on top of each other, they all disappear from the grid and score is increased as well as the speed is reset. This continues, until game is over.

### Schematic
![](images/schematic.jpg)


### Outputs
[See video on YouTube](https://youtu.be/Xj0KbfcmYpQ)


![](images/output_arduino.jpg)


![](images/output_processing.png)



### Learnings
- Instead of swapping blocks at different positions by changing row and color values, it's better and easier to just swap colors.
- Serial communication with Arduino & Processing.

Thank you!