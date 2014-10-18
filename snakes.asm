#Nicole Daniels
#nld24@pitt.edu
.data
gameOver: .asciiz "Game over. \n"
playingTime: .asciiz "The playing time was: "
ms: .asciiz " ms. \n"
score: .asciiz "The game score was "
frogs: .asciiz " frogs."
wall: .asciiz "****************************************************************",
	      "*                                                              *",
	      "*                                                              *",
	      "**************                           ***********************",
	      "             *                           *                      ",
	      "***********  *                           * *********************",
	      "*         *  *                           * *                   *",
 	      "*         *  *                           * *                   *",
 	      "*                                        * *                   *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
 	      "*                        ****************                      *",
 	      "*                        *              *                      *",
	      "*                        *  **********  *                      *",
	      "*                        *  *        *  *                      *",
	      "*                        *  *        *  *                      *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
 	      "*                                                              *",
 	      "*                                                              *",
	      "*        ******************                                    *",
	      "*        *                *                                    *",
	      "*        *   *******      *                                    *",
	      "*        *   *******      *                                    *",
	      "*        *   *******      *                                    *",
	      "*                         *                                    *",
 	      "*               ***********                                    *",
 	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
 	      "*                                                              *",
 	      "*                                ***************               *",
	      "*                                              *               *",
	      "*                                ************* *               *",
	      "*                                            * *               *",
              "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
 	      "*                                                              *",
 	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                *           *                 *",
	      "*                                *           *                 *",
	      "*                                *           *                 *",
	      "*                                *           *                 *",
 	      "*                                *************                 *",
 	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
	      "*                                                              *",
              "*                                                              *",
 	      "****************************************************************",
snakeBuffer: .byte 4,31,5,31,6,31,7,31,8,31,9,31,10,31,11,31
snakeBufferExt: .space 512

.text
la $t4,wall

assembleBoard: #main function for assembling the board (walls)
lb $t5,0($t4)
beq $t5,0x2a,foundAsterik
beq $t5,0,nextLine
addi $t6,$t6,1
addi $t4,$t4,1
j assembleBoard

foundAsterik: #if the loop encounters an asterik, set the LED to red
move $a0,$t6
move $a1,$t7
li $a2,1
jal _setLED
addi $t4,$t4,1
addi $t6,$t6,1
j assembleBoard

nextLine: #if the loop encounters a /0 character, increment the y coordinate so we can search the next line
addi $v0,$v0,1
beq $v0,64,end
addi $t7,$t7,1
li $t6,0
addi $t4,$t4,1
j assembleBoard

end: #reset the variables
li $t0,0
li $t1,0
li $t2,0
li $t3,0
li $t4,0 #counter for frog placement attempts
li $t5,0 #stores random x value
li $t6,0 #stores random y value
li $t7,0 #stores the final amount of frogs successfully placed on the board

placeFrogs: #routine for placing frogs on the board
bgt $t4,32,getAddresses #32 possible snakes
addi $t4,$t4,1
li $v0,42
li $a0,5
li $a1,63
syscall
move $t5,$a0
li $v0,42
li $a0,5
li $a1,63
syscall
move $t6,$a0
move $a0,$t5
move $a1,$t6
li $a2,3
jal _getLED
beq $v0,0,validPosition
j placeFrogs

validPosition: #frog can be placed on the board. No wall, snake, or other frog already exists on location
jal _setLED
addi $t7,$t7,1 #counts number of frogs successfully placed on board
j placeFrogs

getAddresses:
la $t4,snakeBuffer
la $t5,snakeBufferExt

initializeSnake: #places the snake in the snakeBufferExt and makes it appear on the board
beq $t9,8,setHeadAndTail
lb $t6,0($t4) #x-coordinate
sb $t6,0($t5)
lb $t8,1($t4)#y-coordinate
sb $t8,1($t5)
move $a0,$t6
move $a1,$t8
li $a2,2
jal _setLED
addi $t4,$t4,2
addi $t5,$t5,2
addi $t9,$t9,1
j initializeSnake

setHeadAndTail: #set the address of the starting head and tail addresses, starts game timer
la $t5,snakeBufferExt #starting tail
addi $t6,$t5,14 #starting head
li $v0,30
syscall
move $t4,$a0

gameLoop: #main play loop, game starts when user pressed a vaiid key
li $v0,30
move $t8,$a1
syscall
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j gameLoop

moveUp: #moves snake in the up direction
jal _queue_peek_end
addi $s4,$s1,-1
move $a0,$s0
move $a1,$s4
jal _getLED
beq $v0,3,moveUpHitFrog
beq $v0,2,exit
beq $v0,1,handleWallUp
jal _queue_insert
jal _queue_remove
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j moveUp

handleWallUp: #handles what the snake should do if it's moving up and there's a wall at the next position
addi $a0,$a0,1
addi $a1,$a1,1
jal _getLED
beq $v0,1,moveLeft
j moveRight

moveUpHitFrog: #handles what the snake should do if it's moving up and there's a frog in the next position
jal _queue_insert
addi $s7,$s7,1
beq $s7,$t7,exit
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j moveUp

moveLeft: #moves the snake left
jal _queue_peek_end
addi $s4,$s0,-1
andi $s4,$s4,63
move $a0,$s4
move $a1,$s1
jal _getLED
beq $v0,3,moveLeftHitFrog
beq $v0,2,exit
beq $v0,1,handleWallLeft
jal _queue_insert
jal _queue_remove
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
j moveLeft

handleWallLeft: #handles what the snake should do if there's a wall in the next position while moving left
addi $a0,$a0,1
addi $a1,$a1,-1
jal _getLED
beq $v0,1,moveDown
j moveUp

moveLeftHitFrog: #handles what the snake should do if there's a frog in the next position while moving left
jal _queue_insert
addi $s7,$s7,1
beq $s7,$t7,exit
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
j moveLeft

moveDown: #moves the frog down
jal _queue_peek_end
addi $s4,$s1,1
move $a0,$s0
move $a1,$s4
jal _getLED
beq $v0,3,moveDownHitFrog
beq $v0,2,exit
beq $v0,1,handleWallDown
jal _queue_insert
jal _queue_remove
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j moveDown

handleWallDown: #handles what the snake should do if there's a wall in the next position while moving down
addi $a0,$a0,-1
addi $a1,$a1,-1
jal _getLED
beq $v0,1,moveRight
j moveLeft

moveDownHitFrog: #handles what the snake should do if it's moving down and encounters a frog
jal _queue_insert
addi $s7,$s7,1
beq $t7,$s7,exit
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j moveDown

moveRight: #moves the snake right
jal _queue_peek_end
addi $s4,$s0,1
andi $s4,$s4,63
move $a0,$s4
move $a1,$s1
jal _getLED
beq $v0,3,moveRightHitFrog
beq $v0,2,exit
beq $v0,1,handleWallRight
jal _queue_insert
jal _queue_remove
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
j moveRight

handleWallRight: #handles what the snake should do if there's a wall in the next position while moving right
addi $a0,$a0,-1
addi $a1,$a1,-1
jal _getLED
beq $v0,1,moveDown
j moveUp

moveRightHitFrog: #handles what the snake should do if it's moving right and it encounters a frog
jal _queue_insert
addi $s7,$s7,1
beq $s7,$t7,exit
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
j moveRight

_queue_insert: #inserts coordinates at the end of the queue(head), changes address of the head, sets to yellow
addi $sp,$sp,-4
sw $ra,0($sp)
addi $t6,$t6,2
sb $a0,0($t6) #x coordinate we want to insert
sb $a1,1($t6) #y coordinate we want to insert
li $a2,2
jal _setLED
lw $ra,0($sp)
addi $sp,$sp,4
jr $ra

_queue_remove: #removes coordinates at the beginning of the queue(tail), changes address of the tail, sets to black
addi $sp,$sp,-4
sw $ra,0($sp)
lb $s2,0($t5) #x coordinate we want to remove
lb $s3,1($t5) #y coordinate we want to remove
addi $t5,$t5,2
move $a0,$s2
move $a1,$s3
li $a2,0
jal _setLED
lw $ra,0($sp)
addi $sp,$sp,4
jr $ra

_queue_peek_end: #finds the coordinates at the end of the queue(head)
lb $s0,0($t6) #returns x-value
lb $s1,1($t6) #returns y-value
jr $ra

keyPress: #detects if a key is pressed
la $t1,0xffff0000							
lw $t0,0($t1)			
beq $t0,$zero,keyPressJump	
lw $v0,4($t1)
keyPressJump:
jr $ra

exit: #handles game over conditions, prints game over screen, and terminates game
li $v0,30
syscall
move $t9,$a0
sub $t9,$t9,$t4
li $v0,4
la $a0, gameOver
syscall
li $v0,4
la $a0,playingTime
syscall
li $v0,1
move $a0,$t9
syscall
li $v0,4
la $a0,ms
syscall
li $v0,4
la $a0,score
syscall
la $v0,1
move $a0,$s7
syscall
li $v0,4
la $a0,frogs
syscall
li $v0,10
syscall

# _setLED and _getLED functions for Keypad and LED Display Simulator (64x64)
#
# These functions may be used in your CS/CoE 0447 Project 1.
# They provide a convenient interface to the Keypad and LED Display Simulator
# extension (64x64) in MARS 4.4-Pitt.1.  For arguments and return values,
# read the comments above each; call them like any other MIPS function.
#
# If you're really interested, look through the code to show yourself
# how it works, or even practice writing these yourself!  You know
# all the pieces; try fitting them together!


	# void _setLED(int x, int y, int color)
	#   sets the LED at (x,y) to color
	#   color: 0=off, 1=red, 2=yellow, 3=green
	#
	# arguments: $a0 is x, $a1 is y, $a2 is color
	# trashes:   $t0-$t3
	# returns:   none
	#
_setLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008 # base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display
	jr	$ra
	
	# int _getLED(int x, int y)
	#   returns the value of the LED at position (x,y)
	#
	#  arguments: $a0 holds x, $a1 holds y
	#  trashes:   $t0-$t2
	#  returns:   $v0 holds the value of the LED (0, 1, 2 or 3)
	#
_getLED:
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits
	jr   $ra
