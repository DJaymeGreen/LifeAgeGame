###################################
#
#
# D Jayme Green
#
# File deals with creation of the board Nodes
# and linking them together, as well as access
# those links
###################################

#syscalls
PRINT_INT=1
PRINT_STRING=4

	.data 
	.align 2

root_Node:
	.word	0	# "root" node of graph (at 0,0)

	.text
	.align 2
	.globl	input_array
	.globl	allocate_mem
	.globl	mainDone
	.globl	space
	.globl	deBugPrint
	.globl	getNeighborsAlive
	.globl	root_Node
	#.globl

createGraph:
	addi	$sp, $sp, 4
	sw	$ra, 0($sp)

####### Attach Left & Right ##################
	
	li	$s0, 0		#check for later 
	li	$s5, 0		#r=0
	la	$t3, input_array
	lw	$s7, 0($t3)	#DIM
RCN:
	beq	$s5, $s7, endRCN	#if r = DIM, endCCN
	li	$s6, 0			#c=0
CCN:
	beq	$s6, $s7, endCCN	#if c = DIM, endCCN

	li	$a0, 12		#12 words needed for a Node
	jal	allocate_mem		#$v0, ptr to new Node

	sw	$zero,0($v0)
	sw	$zero,4($v0)
	sw	$s5,8($v0)
	sw	$s6,12($v0)
	bne	$s0,$zero,haveBeginningNode
	la	$t3, root_Node
	sw	$v0,0($t3)	#store first node as "root"
	move	$s0,$v0
	move	$s1, $v0
	j	endCCNSoon
haveBeginningNode:
	move	$s2,$v0
	sw	$s2,40($s1)	#s1.right = s2
	sw	$s1,24($s2)	#s2.left = s1
	move	$s1,$s2
endCCNSoon:
	addi	$s6,$s6,1	#$t1++
	j	CCN
endCCN:
	addi	$s5,$s5,1	#$t0++
	j	RCN
endRCN:
	#jal	printFirstGrid

######## Feed attachNeighbors ###########
	
	move	$s1, $s0
	li	$s5, 0		#r=0
anRow:
	beq	$s5, $s7, endANRow
	li	$s6,0		#c=0
anCol:
	beq	$s6, $s7, endANCol

	jal	attachNeighbors
	lw	$t3,40($s1)	#getRight
	move	$s1,$t3		#Current=curr.right
	addi	$s6,$s6,1	#c++
	j	anCol
endANCol:
	addi	$s5,$s5,1	#r++
	j	anRow
endANRow:
	#jal	printSecondGrid
	#jal	wrapPrint

	jal	fixLeftRight
	#jal	wrapRightPrint

	lw	$ra,0($sp)
	addi	$sp,$sp,4
	jr	$ra


######## attachNeighbors ###########

attachNeighbors:
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

	li	$s6,16		#loop starts at 16
	li	$t3,48		#ending value
	move	$s7,$s1		#use $s1 later. $s7=Curr
aNeighLoop:
	li	$t3,48		#ending value
	slt	$t7,$s6,$t3	#if $s6<$t3, $t7=1
	beq	$t7,$zero,endANeigh

	lw	$s3,8($s7)	#row of Current
	lw	$s4,12($s7)	#col of Current
	li	$t4,24		#Left
	beq	$s6,$t4,aNeighEnd
	li	$t4,40		#Right
	beq	$s6,$t4,aNeighEnd
Sixteen:
	li	$t4,16		#Check for 16
	bne	$s6,$t4,Twenty
	addi	$s3, $s3, -1	#Row-1
Twenty:
	addi	$t4,$t4,4	#Check for 20
	bne	$s6,$t4,TwentyEight
	addi	$s3,$s3,-1	#Row--
	addi	$s4,$s4,-1	#Col--
TwentyEight:
	li	$t4,28		#Chek for 28
	bne	$s6,$t4,ThirtyTwo
	addi	$s3,$s3,1	#Row++
	addi	$s4,$s4,-1	#Col--
ThirtyTwo:
	li	$t4,32		#Check for 32
	bne	$s6,$t4,ThirtySix
	addi	$s3,$s3,1	#Row++
ThirtySix:
	li	$t4,36		#Check for 36
	bne	$t4,$s6,FortyFour
	addi	$s3,$s3,1	#Row++
	addi	$s4,$s4,1	#Col++
FortyFour:
	li	$t4,44		#Check for 44
	bne	$t4,$s6,findNeigh
	addi	$s3,$s3,-1	#Row--
	addi	$s4,$s4,1	#Col++
findNeigh:
	li	$t7,-1
	la	$s0, input_array
	lw	$t6,0($s0)	#get DIM
colBig:
	bne	$s4,$t6, colSmall	#if col==DIM, make 0
	li	$s4,0
colSmall:
	bne	$s4,$t7, rowBig		#if col==-1, make DIM-1
	addi	$s4,$t6,-1
rowBig:
	bne	$s3, $t6, rowSmall	#if row==DIM, make 0
	li	$s3, 0
rowSmall:
	bne	$s3,$t7,goodCords	#if row==-1, make DIM-1
	addi	$s3,$t6,-1
goodCords:
	move	$s0, $s3		#$s0 = row to look for
	move	$s1, $s4		#$s1 = col to look for

	jal	findNeighbors		#$v0 = ptr to other Node

	move	$s2,$s7
	add	$s2,$s2,$s6
	sw	$v0,0($s2)		#Add to approiate spot
aNeighEnd:
	addi	$s6,$s6,4		#counter+=4 (increment by a word)

	j	aNeighLoop
endANeigh:
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

######### findNeighbors #############################


findNeighbors:
	addi	$sp,$sp,-40
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)
	sw	$t2,36($sp)

	li	$t0,0			#row = 0
	la	$t1,input_array
	lw	$t2,0($t1)		#DIM
	la	$t3,root_Node
	lw	$s2,0($t3)		#startNode(0,0)
beginFindNeigh:
	lw	$s3,8($s2)		#curr row
	lw	$s4,12($s2)		#curr col
	#beq	$t0,$t2,endfNeigh
	#li	$t1,0			#col=0
	#beq	$t1,$t2,endfNeigh
	bne	$s3,$s0,noMatch		#currRow != findRow
	beq	$s4,$s1,neighMatch	#currCol == findCol
noMatch:
	lw	$s5,40($s2)		#getRight
	move	$s2,$s5
	j	beginFindNeigh
neighMatch:
	move	$v0,$s2			#$v0 = matched Neigh of Node

endfNeigh:
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	lw	$t2,36($sp)
	addi	$sp,$sp,40
	jr	$ra



########### fixLeftRight ##################

fixLeftRight:
	addi	$sp,$sp,-40
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)
	sw	$t2,36($sp)

	la	$t0,root_Node
	lw	$s0,0($t0)	#Curr

	la	$t0,input_array
	lw	$s4,0($t0)	#DIM
	addi	$s5,$s4,-1	#DIM-1

	li	$s3,0		#i=0

fixLeftRightLoop:
	slt	$t7,$s3,$s4	#if i<DIM,$t7=1
	beq	$t7,$zero,endLeftRight

	bne	$s3,$zero,noStoreLeftRight
	lw	$t0,32($s0)	#store Down
	move	$s7,$t0
	move	$s6,$s0		#store firstNode
noStoreLeftRight:
	lw	$s1,8($s0)	#Row
	lw	$s2,12($s0)	#Col
	bne	$s2,$s5, goRightLeftRight
	sw	$s0,24($s6)	#firstNode.left =Curr
	sw	$s6,40($s0)	#Curr.right = firstNode
	move	$s0,$s7		#Curr = Down
	li	$s3,0		#i=0
	beq	$s1,$s5,endLeftRight
	j	fixLeftRightLoop
goRightLeftRight:
	lw	$t0,40($s0)	#getRight
	move	$s0,$t0		#Curr = Curr.right
	addi	$s3,$s3,1	#++i
	j	fixLeftRightLoop
endLeftRight:
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	lw	$t2,36($sp)
	addi	$sp,$sp,40
	jr	$ra

############# getNeighborsAlive ########

getNeighborsAlive:
	addi	$sp,$sp,-40
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)
	sw	$a0,36($sp)

	#$a0 Node to check neighbors

	move	$s0,$a0		#$s0, node to find neighbors
	li	$s1,0		#Num of alive neighbors
	li	$s2,16		#Top
	li	$s3,48		#NorthEast

	#add	$s0,$s0,$s2	#first Neigh to check

getNeighAliveLoop:
	slt	$t7,$s2,$s3	#if CurrNeigh<LastNeigh,$t7=1
	beq	$t7,$zero,getNeighAliveEnd
	add	$s0,$s0,$s2	#first Neigh to check
	lw	$s4,0($s0)	#get next neighbor

	lw	$t0,0($s4)	#get isAlive for neighbor

	beq	$t0,$zero,notAlive
	addi	$s1,$s1,1	#Num of alive neighs++
notAlive:
	move	$s0,$a0		#Reset $s0
	addi	$s2,$s2,4	#Position+=4
	j	getNeighAliveLoop
getNeighAliveEnd:

	move	$v0,$s1		#Put into $v0 for return

	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	lw	$a0,36($sp)
	addi	$sp,$sp,40
	jr	$ra


############ Debug Functions ###########



printFirstGrid:
	addi	$sp,$sp,-36
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$v0,28($sp)
	sw	$a0,32($sp)
	
	la	$s1, root_Node
	lw	$s0,0($s1)	#"Root" Node is $s0

	la	$s1, input_array
	lw	$s2, 0($s1)	#DIM
	mul	$s2, $s2, $s2	#DIM*DIM

	li	$v0, 1		#PRINT_INT
	
	li	$s1, 0		#counter
begPrint:
	beq	$s1, $s2, printReturn

	lw	$s3,8($s0)	#$s3 = r
	move	$a0, $s3
	syscall

	lw	$s3,12($s0)	#$s3 = c
	move	$a0, $s3	
	syscall

	lw	$s3, 40($s0)	#$s3 = $s0.right
	move	$s0, $s3
	addi	$s1, $s1, 1	#couter++
	j	begPrint
printReturn:
	lw	$a0, 32($sp)
	lw	$v0, 28($sp)
	lw	$s5, 24($sp)
	lw	$s4, 20($sp)
	lw	$s3, 16($sp)
	lw	$s2, 12($sp)
	lw	$s1, 8($sp)
	lw	$s0, 4($sp)
	lw	$ra, 0($sp)
	addi	$sp, $sp, 36
	jr	$ra



printSecondGrid:
	addi	$sp,$sp,-48
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)
	sw	$t2,36($sp)
	sw	$v0,40($sp)
	sw	$a0,44($sp)		#Save everything just in case

	li	$v0, PRINT_STRING
	la	$a0,deBugPrint
	syscall

	la	$s1, root_Node
	lw	$s0,0($s1)	#"Root" Node is $s0

	la	$s1, input_array
	lw	$s2, 0($s1)	#DIM
	mul	$s2, $s2, $s2	#DIM*DIM

	li	$v0, 1		#PRINT_INT
	
	li	$s1, 0		#counter
begDownPrint:
	beq	$s1, $s2, printDownReturn

	lw	$s4,32($s0)	#$s4 = down

	lw	$s3,8($s4)	#$s3 = r
	move	$a0, $s3
	syscall

	lw	$s3,12($s4)	#$s3 = c
	move	$a0, $s3	
	syscall

	lw	$s3, 40($s0)	#$s3 = $s0.right
	move	$s0, $s3
	addi	$s1, $s1, 1	#couter++
	j	begDownPrint
printDownReturn:	
	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	lw	$t2,36($sp)
	lw	$v0,40($sp)
	lw	$a0,44($sp)
	addi	$sp,$sp,48
	jr	$ra


wrapPrint:
	addi	$sp,$sp,-48
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)
	sw	$t2,36($sp)
	sw	$v0,40($sp)
	sw	$a0,44($sp)		#Save everything just in case

	li	$v0,PRINT_STRING
	la	$a0,deBugPrint
	syscall

	la	$t0, root_Node
	lw	$s0,0($t0)		#Curr

	la	$t0, input_array
	lw	$s5,0($t0)		#DIM
	addi	$s6,$s5,-1		#DIM-1

	li	$s4,0			#i=0
wrapPrintLoop:
	slt	$t7,$s4,$s5		#if i<DIM, $t7=1
	beq	$t7,$zero,wrapPrintEnd
	bne	$s4,$zero,noStore	#if i!=0, noStore
	lw	$s7,32($s0)		#getDown
noStore:
	lw	$s1,8($s0)		#Row
	lw	$s2,12($s0)		#Col

	li	$v0,PRINT_INT		#Print Row,Col
	move	$a0,$s1
	syscall
	move	$a0,$s2
	syscall

	bne	$s2,$s6,wrapRight	#if Col!=DIM-1, wrapRight
	move	$s0,$s7			#Make Curr, Down set previously
	li	$s4,0
	beq	$s1,$s6,wrapPrintEnd
	j	wrapPrintLoop
wrapRight:
	lw	$t0,40($s0)		#Right
	move	$s0,$t0			#Curr = Curr.right
	addi	$s4,$s4,1
	j	wrapPrintLoop
wrapPrintEnd:

	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	lw	$t2,36($sp)
	lw	$v0,40($sp)
	lw	$a0,44($sp)
	addi	$sp,$sp,48
	jr	$ra



wrapRightPrint:
	addi	$sp,$sp,-48
	sw	$ra,0($sp)
	sw	$s0,4($sp)
	sw	$s1,8($sp)
	sw	$s2,12($sp)
	sw	$s3,16($sp)
	sw	$s4,20($sp)
	sw	$s5,24($sp)
	sw	$s6,28($sp)
	sw	$s7,32($sp)
	sw	$t2,36($sp)
	sw	$v0,40($sp)
	sw	$a0,44($sp)		#Save everything just in case

	li	$v0,PRINT_STRING
	la	$a0,deBugPrint
	syscall

	la	$t0, root_Node
	lw	$s0,0($t0)		#Curr

	la	$t0, input_array
	lw	$s5,0($t0)		#DIM
	addi	$s6,$s5,-1		#DIM-1

	li	$s4,0			#i=0
wrapRightPrintLoop:
	slt	$t7,$s4,$s5		#if i<DIM, $t7=1
	beq	$t7,$zero,wrapRightPrintEnd
	bne	$s4,$zero,noRightStore	#if i!=0, noStore
	lw	$s7,32($s0)		#getDown
noRightStore:
	lw	$s1,8($s0)		#Row
	lw	$s2,12($s0)		#Col

	lw	$t0,40($s0)		#getRight

	li	$v0,PRINT_INT		#Print Row,Col
	#move	$a0,$s1
	lw	$a0,8($t0)
	syscall
	#move	$a0,$s2
	lw	$a0,12($t0)
	syscall

	bne	$s2,$s6,wrapRightRight	#if Col!=DIM-1, wrapRight
	move	$s0,$s7			#Make Curr, Down set previously
	li	$s4,0
	beq	$s1,$s6,wrapRightPrintEnd
	j	wrapRightPrintLoop
wrapRightRight:
	lw	$t0,40($s0)		#Right
	move	$s0,$t0			#Curr = Curr.right
	addi	$s4,$s4,1
	j	wrapRightPrintLoop
wrapRightPrintEnd:

	lw	$ra,0($sp)
	lw	$s0,4($sp)
	lw	$s1,8($sp)
	lw	$s2,12($sp)
	lw	$s3,16($sp)
	lw	$s4,20($sp)
	lw	$s5,24($sp)
	lw	$s6,28($sp)
	lw	$s7,32($sp)
	lw	$t2,36($sp)
	lw	$v0,40($sp)
	lw	$a0,44($sp)
	addi	$sp,$sp,48
	jr	$ra







