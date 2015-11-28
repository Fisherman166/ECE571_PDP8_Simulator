/ Program : JMS_DCA_test.as
/ Date : Feb 2, 2015
/ 12 cycles in total
/ C = 5 at the end of the program and accum = 0
/-------------------------------------------
/ Code Section
/
*0200			/ start at address 0200
Main, 	
	cla cll 	/ clear AC and Link
	jms Add	/ Go to sub
	hlt 		/ Halt program
	jmp Main	/ To continue - goto Main

Add, 			/ C = A + B
	nop			/ Space for return address
	tad A 		/ add A to Accumulator
	tad B 		/ add B
	dca C 		/ store sum at C
	jmp i ADD	/ Return to main
/
/ Data Section
/
*0250 			/ place data at address 0250
A, 	2 		/ A equals 2
B, 	3 		/ B equals 3
C, 	0
$Main 			/ End of Program; Main is entry point
