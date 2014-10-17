#andi $a0,$a0,63
#$a0 is x or y value
#x + whatever and then do an andi
.data
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
	      "*        *   *     *      *                                    *",
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

assembleBoard:
lb $t5,0($t4)
beq $t5,0x2a,foundAsterik
beq $t5,0,nextLine
addi $t6,$t6,1
addi $t4,$t4,1
j assembleBoard

foundAsterik:
move $a0,$t6
move $a1,$t7
li $a2,1
jal _setLED
addi $t4,$t4,1
addi $t6,$t6,1
j assembleBoard

nextLine:
addi $v0,$v0,1
beq $v0,64,end
addi $t7,$t7,1
li $t6,0
addi $t4,$t4,1
j assembleBoard

end:
li $t0,0
li $t1,0
li $t2,0
li $t3,0
li $t4,4 #counter for frog placements
li $t5,31 #stores random x value
li $t6,0 #stores random y value
li $t7,0

placeFrogs:
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

validPosition:
jal _setLED
addi $t7,$t7,1 #counts number of frogs on board
j placeFrogs

getAddresses:
la $t4,snakeBuffer
la $t5,snakeBufferExt

initializeSnake:
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

setHeadAndTail:
la $t5,snakeBufferExt #starting tail
addi $t6,$t5,14 #starting head

gameLoop:
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j gameLoop

moveUp:
jal _queue_peek_end
addi $s4,$s1,-1
#andi $s4,$s4,63
move $a0,$s0
move $a1,$s4
jal _getLED
beq $v0,3,moveUpHitFrog
beq $v0,2,exit
jal _queue_insert
jal _queue_remove
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j moveUp

moveUpHitFrog:
addi $s7,$s7,1
beq $s7,$t7,exit
jal _queue_insert
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j moveUp

moveLeft:
jal _queue_peek_end
addi $s4,$s0,-1
andi $s4,$s4,63
move $a0,$s4
move $a1,$s1
jal _getLED
beq $v0,3,moveLeftHitFrog
beq $v0,2,exit
jal _queue_insert
jal _queue_remove
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
j moveLeft

moveLeftHitFrog:
addi $s7,$s7,1
beq $s7,$t7,exit
jal _queue_insert
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
j moveLeft

moveDown:
jal _queue_peek_end
addi $s4,$s1,1
move $a0,$s0
move $a1,$s4
jal _getLED
beq $v0,3,moveDownHitFrog
beq $v0,2,exit
jal _queue_insert
jal _queue_remove
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j moveDown

moveDownHitFrog:
addi $s7,$s7,1
beq $t7,$s7,exit
jal _queue_insert
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE2,moveLeft
beq $v0,0xE3,moveRight
j moveDown

moveRight:
jal _queue_peek_end
addi $s4,$s0,1
andi $s4,$s4,63
move $a0,$s4
move $a1,$s1
jal _getLED
beq $v0,3,moveRightHitFrog
jal _queue_insert
jal _queue_remove
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
j moveRight


moveRightHitFrog:
addi $s7,$s7,1
beq $s7,$t7,exit
jal _queue_insert
li $v0,32
li $a0,200
syscall
jal keyPress
beq $v0,0xE0,moveUp
beq $v0,0xE1,moveDown
j moveRight

_queue_insert:
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

_queue_remove:
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

_queue_peek_end:
lb $s0,0($t6) #returns x-value
lb $s1,1($t6) #returns y-value
jr $ra

keyPress:
la $t1,0xffff0000			
#li $v0,0				
lw $t0,0($t1)			
beq $t0,$zero,keyPressJump	
lw $v0,4($t1)
keyPressJump:
jr $ra

exit:
li $v0,10
syscall
#ateFrog:
#addi $t9,$t9,1



#jal gameLoop

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
