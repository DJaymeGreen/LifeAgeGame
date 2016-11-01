# LifeAgeGame
MIPS Assembly program utilizing a graph data structure in order to play a game based on neighbor health. If two neighbors (including wrapped diagonals) are infected, then the node is infected. If there are greater than 4 or less than 2 infected neighbors next to it, the node becomes healthy again. 
The program design was to create a graph of all of the nodes connected with pointers to all the neighbors. While the setup was hard, a function can be used to get the number of infected neighbors making the game very easy and fast. 
Unfortunately, the assembler used for this project is owned by RIT and not readily available. Have fun looking at it though :)

Allocate.asm contains code that allocates a register to memory and returns the memory address. This code was written by someone else (not mine!).

Graph.asm contains code that sets up the graph infrastructure in assembly with wrapped edges and neighbors established. This entire file was written by me.

Life_age.asm contains code that reads user input, runs the game, and outputs the results. This is the main file. The entire file was written by me. 
