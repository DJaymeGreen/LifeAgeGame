# Author: D Jayme Green
#
# Game of Life with Age
# Project
#

#syscall codes
PRINT_INT = 1
PRINT_STRING = 4
READ_INT = 5
EXIT = 10

.data
.align 2

genNum:
	.space 4		#stores integer of current generation 

input_array:
	.space 30*30*4+12	# room for input values, size of max words

#print constants for the code
.align 0

sizePrompt:
	.asciiz	"\nEnter board size: "

genPrompt:
	.asciiz	"\nEnter number of generations to run: "

numCellsPrompt:
	.asciiz	"\nEnter number of live cells: "

startPrompt:
	.asciiz	"\nStart entering locations \n"

illegalBoard:
	.asciiz	"\nWARNING: illegal board size, try again:"

illegalGen:
	.asciiz	"\nWARNING: illegal number of generations, try again: "

illegalCellCount:
	.asciiz	"\nWARNING: illegal number of live cells, try again: "

illegalCellCord:
	.asciiz	"\nWARNING: illegal point location"

bannerStars:
	.asciiz	"\n*************************************\n"

fourStars:
	.asciiz	"****"

bannerTitle:
	.asciiz	"Game of Life with Age"

fourSpaces:
	.asciiz	"    "

fourEquals:
	.asciiz	"===="

generation:
	.asciiz	"GENERATION "

boardPlus:
	.asciiz	"+"

boardDash:
	.asciiz	"-"

boardVert:
	.asciiz	"|"

newLine:
	.asciiz	"\n"

space:
	.asciiz	" "

deBugPrint:
	.asciiz	"\nEcho: "




.text
.align 2

#.globl's here
	.globl	allocate_mem
	.globl	createGraph
	.globl	mainDone
	.globl  space
	.globl	deBugPrint
	.globl	getNeighborsAlive
	.globl	root_Node

main:
	addi	$sp, $sp, -12		#allocate space for the return address
	sw	$ra, 8($sp)
	sw	$s1, 4($sp)
	sw	$s0, 0($sp)



########## Print Banner ################

	li	$v0, PRINT_STRING	#Banner start
	la	$a0, bannerStars
	syscall

	la	$a0, fourStars
	syscall

	la	$a0, fourSpaces
	syscall

	la	$a0, bannerTitle
	syscall

	la	$a0, fourSpaces
	syscall

	la	$a0, fourStars
	syscall

	la	$a0, bannerStars	#Banner complete
	syscall

	li	$t4, 30*30+3		#max size of array
	la	$t5, input_array	#ptr to input_array
	li	$t6, 0 			#counter

	la	$t7, genNum
	sw	$zero,0($t7)		#store 0 into genNum 

######## Get Board Size ###########

	li	$v0, PRINT_STRING
	la	$a0, sizePrompt
	syscall

	li	$t0, 4	#bottom grid boundary
	li	$t1, 30 #trop grid boundary 

getGridSize:
	li	$v0, READ_INT
	syscall

	slt	$t7, $v0, $t0		#if $v0<$t0,$t7=1
	beq	$t7, $zero, goodLow
invalidSize:
	li	$v0, PRINT_STRING
	la	$a0, illegalBoard
	syscall
	j	getGridSize
goodLow:
	slt	$t7, $t1, $v0		#if $t1<$v0, $t7 =1
	bne	$t7, $zero, invalidSize
	sw	$v0, 0($t5)		#save val in array

	addi	$t6, $t6, 1		#counter++
	addi	$t5, $t5, 4		#array ptr++

	#jal	printBoardSize		#FOR DEBUGGING

####### Get Generations to Run ############

	li	$v0, PRINT_STRING
	la	$a0, genPrompt
	syscall

	li	$t0, 20			#top boundary
getGenNum:
	li	$v0, READ_INT
	syscall

	slt	$t7, $v0, $zero		#if $v0<$zero, $t7=1
	beq	$t7, $zero, goodGenNum
invalidGenNum:
	li	$v0, PRINT_STRING
	la	$a0, illegalGen
	syscall
	j	getGenNum
goodGenNum:
	slt	$t7, $t0, $v0		#if $t0<$v0, $t7=1
	bne	$t7,$zero,invalidGenNum

	sw	$v0,0($t5)		#store onto array
	addi	$t5, $t5, 4		#array ptr++
	addi	$t6, $t6, 1		#counter++

	#jal	printGenToRun		#FOR DEBUGGING

######## Get Num of Live Cells #########

	li	$v0, PRINT_STRING
	la	$a0, numCellsPrompt
	syscall

	la	$t0, input_array
	lw	$t1, 0($t0)		#get size
	mul	$t0, $t1, $t1		#num of cells on board
getNumOfLiveCells:
	li	$v0, READ_INT
	syscall

	slt	$t7, $v0, $zero		#if $v0<0, $t7=1
	beq	$t7, $zero, goodNumOfLiveCells
invalidNumOfLiveCells:
	li	$v0, PRINT_STRING
	la	$a0, illegalCellCount
	syscall
	j	getNumOfLiveCells
goodNumOfLiveCells:
	slt	$t7, $t0, $v0		#if $t0<$v0, $t7=1
	bne	$t7, $zero, invalidNumOfLiveCells
	
	sw	$v0, 0($t5)		#store onto array
	addi	$t5, $t5, 4		#array ptr++
	addi	$t6, $t6, 1		#counter++

	#jal	printNumOfLiveCells

########## Get Starting Locations #################

	li	$v0, PRINT_STRING
	la	$a0, startPrompt
	syscall

	la	$t1, input_array
	lw	$t0, 0($t1)		#board size
	lw	$t2, 8($t1)		#num of Alive cells
	mul	$t1, $t2, 2		#Num of inputs

	li	$t8, 0			# i = 0
getStartingLocations:
	slt	$t7, $t8, $t1		#if i<numOfInputs, $t7 =1 
	beq	$t7, $zero, noMoreInputs
	
	li	$v0, READ_INT
	syscall
	move	$s0, $v0		# row input
	li	$v0, READ_INT
	syscall
	move	$s1, $v0		# col input

	slt	$t7, $s0, $zero		#if $s0<0,$t7=1
	bne	$t7, $zero, invalidateLoc
	slt	$t7, $s0, $t0		#if $s0<$t0,$t7=1
	beq	$t7, $zero, invalidateLoc
	slt	$t7, $s1, $zero		#if $s1<0, $t7=1
	bne	$t7, $zero, invalidateLoc
	slt	$t7, $s1, $t0		#if $s1<$t0, $t7=1
	beq	$t7, $zero, invalidateLoc
	j	validLoc
invalidateLoc:
	li	$v0, PRINT_STRING
	la	$a0, illegalCellCord
	syscall
mainDone:
	lw	$ra, 8($sp)
	lw	$s1, 4($sp)
	lw	$s0, 0($sp)
	addi	$sp, $sp, 12

	li	$v0, EXIT		#Exit gracefully
	syscall

validLoc:
	la	$t9, input_array
	addi	$t9, $t9, 12		#get to start of locations
checkVals:
	beq	$t9, $t5, addLoc	#end address of array == our position
	lw	$t2, 0($t9)		#row in array to check
	lw	$t3, 4($t9)		#col in array to check
	addi	$t9, $t9, 8		#update array pointer
	bne	$t2, $s0, uniqueLoc	#if $t2 != $s0
	beq	$t3, $s1, invalidateLoc	#if $t3 == $s1
uniqueLoc:
	j	checkVals
addLoc:
	sw	$s0, 0($t5)		#add r to array
	sw	$s1, 4($t5)		#add c to array
	addi	$t5, $t5, 8		#update array ptr
	addi	$t8, $t8, 2		#update numOfInputs
	j	getStartingLocations

############ All Correct Prompts, Game Begins ################

noMoreInputs:
	j	playGame

playGame:
	#jal	printStartLocations
	jal	createGraph
	jal	putInStartLocs
	
	la	$t0, input_array
	lw	$s0, 4($t0)		#Generations to run
	addi	$s0,$s0,1		#GentoRun++
	la	$t0, genNum
	lw	$s1,0($t0)		#Current Generation

playGameLoop:	
	slt	$t7,$s1,$s0		#if genNum<GentoRun,$t7=1
	beq	$t7,$zero,mainDone
	jal	printLifeAgeBoard
	jal	updateGame

	addi	$s1,$s1,1		#genNum++
	la	$t0,genNum
	sw	$s1,0($t0)		#store new genNum
	j	playGameLoop


############ Update Game ######################

updateGame:
	addi	$sp,$sp,-36
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)

	la	$t0,input_array
	lw	$s0,0($t0)		#getDim
	addi	$s1,$s0,-1		#DIM-1

	la	$t0,root_Node
	lw	$s2,0($t0)		#get 0,0 Node

	li	$s3,0			#i=0

updateAgeLoop:
	#beq	$s3,$s0,ageReturn	#if i==DIM,doneAge
	bne	$s3,$zero,notFirstNodeAge
	lw	$s7,32($s2)		#Store down
notFirstNodeAge:
	move	$a0,$s2
	jal	getNeighborsAlive	#$v0 = # of alive Neighbors
	lw	$t0,0($s2)		#isAlive
	bne	$t0,$zero,aliveNode

	li	$t0,3			#DeadNode alive check
	bne	$v0,$t0,checkAgeLoop

	#lw	$t0,4($s2)		#Current Age
	li	$t0,1			#Age =1
	sw	$t0,4($s2)		#NewAge stored
	j	checkAgeLoop
aliveNode:
	slti	$t7,$v0,2		#if numAliveNeigh<2,$t7=1
	beq	$t7,$zero,checkAgeNAlive
	sw	$zero,4($s2)
	j	checkAgeLoop
checkAgeNAlive:
	slti	$t7,$v0,4		#if numAliveNigh<4,$t7=1
	beq	$t7,$zero,willDieAge
	lw	$t0,4($s2)		#getAge
	addi	$t0,$t0,1		#Age++
	sw	$t0,4($s2)		#NewAge stored
	j	checkAgeLoop
willDieAge:
	sw	$zero,4($s2)		#Age=0, overpop

checkAgeLoop:
	lw	$t0,12($s2)		#getCol
	lw	$t1,8($s2)		#getRow

	bne	$t0,$s1,goAgeRight	#if col!=DIM-1
	move	$s2,$s7			#Current = Down
	li	$s3,0			#i=0
	beq	$t1,$s1,ageReturn	#break
	j	updateAgeLoop
goAgeRight:
	lw	$t0,40($s2)		#getRight
	move	$s2,$t0			#Curr=Curr.right
	addi	$s3,$s3,1		#i++
	j	updateAgeLoop

ageReturn:
	jal	fixAliveStatus

	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	addi	$sp,$sp,36
	jr	$ra


######### Fix Alive Status ###################

fixAliveStatus:
	addi	$sp,$sp,-36
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)

	la	$t0,input_array
	lw	$s5,0($t0)		#DIM
	addi	$s6,$s5,-1		#DIM-1
	li	$s4,0			#i=0
	
	la	$t0,root_Node
	lw	$s0,0($t0)		#Curr

fixAliveStatusLoop:
	beq	$s4,$s5,fixAliveStatusDone
	bne	$s4,$zero,dontStoreDownfAS
	lw	$s7,32($s0)		#Store down
dontStoreDownfAS:
	lw	$t0,4($s0)		#getAge

	beq	$t0,$zero,deadNodefAS
	li	$t0,1
	sw	$t0,0($s0)		#makeAlive
	j	checkLoopfAS
deadNodefAS:
	sw	$zero,0($s0)		#makeDead
checkLoopfAS:
	lw	$t0,12($s0)		#getCol
	lw	$t1,8($s0)		#getRow
	bne	$t0,$s6,goRightfAS
	move	$s0,$s7			#curr=down
	li	$s4,0			#i=0
	beq	$t1,$s6,fixAliveStatusDone
	j	fixAliveStatusLoop
goRightfAS:
	lw	$t0,40($s0)		#getRight
	move	$s0,$t0			#Curr=Curr.right
	addi	$s4,$s4,1		#i++
	j	fixAliveStatusLoop
fixAliveStatusDone:
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	addi	$sp,$sp,36
	jr	$ra


########### Put in correct start locations ##############

putInStartLocs:
	addi	$sp,$sp,-36
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)

	la	$t0,input_array
	lw	$s0,8($t0)	#get num of live cells
	addi	$s3,$t0,12	#Address of first cell row

	la	$t0,root_Node
	lw	$s1,0($t0)	#get 0,0 nod

	li	$s2,0		#Counter=0

putInStartLocsLoop:
	beq	$s2,$s0,doneWithStartLocs

	lw	$t0,0($s3)	#Row
	lw	$t1,4($s3)	#Col
	addi	$s3,$s3,8	#Next position
	addi	$s2,$s2,1	#Counter++

	li	$t2,0		#Row Counter
	li	$t3,0		#Col Counter
goDownStartLocs:
	beq	$t2,$t0,goRightStartLocs
	lw	$t4,32($s1)
	move	$s1,$t4		#Move down
	addi	$t2,$t2,1	#RowCounter++
	j	goDownStartLocs
goRightStartLocs:
	beq	$t3,$t1, foundStartLoc
	lw	$t4,40($s1)
	move	$s1,$t4		#Move Right
	addi	$t3,$t3,1	#ColCounter++
	j	goRightStartLocs
foundStartLoc:
	li	$t0,1	
	sw	$t0,0($s1)	#Make alive 
	sw	$t0,4($s1)	#Age=1

	la	$t0,root_Node
	lw	$s1,0($t0)	#Reset to 0,0 node
	j	putInStartLocsLoop
doneWithStartLocs:
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	addi	$sp,$sp,36
	jr	$ra

############## Print Board ####################

printLifeAgeBoard:
	addi	$sp,$sp,-36
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)

	jal	generationGen
	jal	printTopBotBoard

	la	$t0,input_array
	lw	$s0,0($t0)		#getDIM
	addi	$s6,$s0,-1		#DIM-1

	la	$t0,root_Node
	lw	$s1,0($t0)		#Curr

	li	$s4,0			#i=0
printLifeAgeBoardLoop:
	beq	$s4,$s0,endPrintLABoard
	bne	$zero,$s4,checkNumbersPrintLABoard
	lw	$s7,32($s1)		#getDown
	li	$v0,PRINT_STRING	#Print '|'
	la	$a0,boardVert
	syscall
checkNumbersPrintLABoard:
	lw	$t0,0($s1)		#get Age for Curr
	bne	$t0,$zero,printLetterLABoard
	li	$v0,PRINT_STRING
	la	$a0,space		#Print a space
	syscall
	j	checkCordsPrintLABoard
printLetterLABoard:
	lw	$t0,4($s1)		#get Age for Curr
	addi	$t0,$t0,64		#to get correct Ascii
	li	$v0,11			#Print Character Vector(Ascii)
	move	$a0,$t0	
	syscall
	
checkCordsPrintLABoard:
	lw	$t2,12($s1)		#get Col
	lw	$t1,8($s1)		#get Row
	bne	$t2,$s6,printLABoardGoRight
	move	$s1,$s7			#Curr = Down
	li	$s4,0			#i=0
	li	$v0,PRINT_STRING
	la	$a0,boardVert		#Print '|'
	syscall
	la	$a0,newLine		#Print '/n'
	syscall
	beq	$t1,$s6,endPrintLABoard
	j	printLifeAgeBoardLoop
printLABoardGoRight:
	lw	$t0,40($s1)		#getRight
	move	$s1,$t0			#Curr = Curr.right
	addi	$s4,$s4,1		#i++
	j	printLifeAgeBoardLoop

endPrintLABoard:
	jal	printTopBotBoard

	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	addi	$sp,$sp,36
	jr	$ra

########## Print Top/Bottom of Board ############

printTopBotBoard:
	la	$t0,input_array
	lw	$s0,0($t0)		#getDIM
	
	li	$v0,PRINT_STRING
	la	$a0,boardPlus
	syscall

	li	$s1,0			#counter=0
topBotBoardLoop:
	beq	$s1,$s0,endTopBot
	la	$a0, boardDash
	syscall
	addi	$s1,$s1,1		#counter++
	j	topBotBoardLoop
endTopBot:
	la	$a0, boardPlus
	syscall
	la	$a0, newLine
	syscall

	jr	$ra

################ Generations N ##########################

generationGen:
	addi	$sp, $sp, -20
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$v0, 12($sp)
	sw	$a0, 16($sp)

	li	$v0, PRINT_STRING
	la	$a0, newLine
	syscall

	la	$a0, fourEquals
	syscall

	la	$a0, fourSpaces
	syscall

	la	$a0, generation
	syscall

	li	$v0, PRINT_INT
	la	$s0, genNum
	lw	$a0,0($s0)
	syscall

	li	$v0, PRINT_STRING
	la	$a0, fourSpaces
	syscall

	la	$a0, fourEquals
	syscall

	la	$a0, newLine
	syscall


	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$v0,0($sp)
	lw	$a0,0($sp)
	addi	$sp, $sp, 20
	jr	$ra
	


########### Debug Functions #############################

printBoardSize:
	addi	$sp, $sp, -12
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	sw	$v0, 8($sp)

	la	$t0, input_array
	lw	$t1, 0($t0)	#board size stored

	li	$v0, PRINT_STRING
	la	$a0, deBugPrint
	syscall

	li	$v0, PRINT_INT
	move	$a0, $t1
	syscall

	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	lw	$v0, 8($sp)
	jr	$ra

printGenToRun:
	addi	$sp, $sp, -12
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	sw	$v0, 8($sp)

	la	$t0, input_array
	lw	$t1, 4($t0)	#NumOfGens stored

	li	$v0, PRINT_STRING
	la	$a0, deBugPrint
	syscall

	li	$v0, PRINT_INT
	move	$a0, $t1
	syscall

	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	lw	$v0, 8($sp)
	jr	$ra

printNumOfLiveCells:
	addi	$sp, $sp, -12
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	sw	$v0, 8($sp)

	la	$t0, input_array
	lw	$t1, 8($t0)	#Num of Starting locations

	li	$v0, PRINT_STRING
	la	$a0, deBugPrint
	syscall

	li	$v0, PRINT_INT
	move	$a0, $t1
	syscall

	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	lw	$v0, 8($sp)
	jr	$ra

printStartLocations:
	addi	$sp, $sp, -16
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)
	sw	$v0, 12($sp)

	la	$t0, input_array
	lw	$t1, 8($t0)		#Number of live cells
	mul	$t1, $t1, 2		#Number of words in array
	mul	$t1, $t1, 4		#Convert to bytes
	addi	$t0, $t0, 12		#Point to beginning of start locals
	add	$t1, $t1, $t0		#End of Array

	li	$v0, PRINT_STRING
	la	$a0, deBugPrint
	syscall

printStartLocLoop:
	beq	$t1, $t0, noMorePrintStartLoc

	lw	$t2, 0($t0)
	li	$v0, PRINT_INT
	move	$a0, $t2
	syscall

	addi	$t0, $t0, 4		#update array pointer
	j	printStartLocLoop

noMorePrintStartLoc:
	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	lw	$t2, 8($sp)
	lw	$v0, 12($sp)
	addi	$sp, $sp, 16
	jr	$ra



