/ Program : JMP_test.as
/ Date : Feb 11, 2015
/ Should take 7 cycles
/-------------------------------------------
/
/ Code Section
/
*0200			/ start at address 0200
Main, 	
	tad A		/ Put 2 in accum
	jmp Add	/ Goto add

Halt,
	hlt 		/ Halt program
	jmp Main	/ To continue - goto Main


ADD, 
	tad B		/ Add 3 to accum
	jmp Halt / Goto Halt
	tad B		/ Should never execute this instruction
/
/ Data Section
/
*0250 			/ place data at address 0250
A, 	2 		/ A equals 2
B, 	3 		/ B equals 3

$Main 			/ End of Program; Main is entry point
