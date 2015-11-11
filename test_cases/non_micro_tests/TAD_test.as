/ Date : Feb 7, 2015
/ 26 cycles in total
/ Desc : Tests the TAD instruction
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main,	
	cll cla				/ Clear link and accum
	tad A					/ 0 + 5 = 5 octal
	tad B					/ 5 + 10 = 15 decimal or 17 octal
	tad C					/ 15 + -20 = -5 decimal or 7773 octal
	and zero				/ Zero out accum
	tad E					/ 0 + -7 = -7 decimal or 7771 octal
	tad F					/ -7 + -19 = -26 or 7746 octal. Produces carry out. Compliment link
	and zero				/ Zero out accum
	tad D					/ 0 + 2047 = 2047 decimal or 3777 octal
	tad A					/ 2047 + 5 = -2044 decimal or 4004 octal. No carry out. Link = 1 still
	and zero				/ Zero out accum
	tad E					/ 0 + -7 = -7 decimal or 7771 octal
	tad F					/ -7 + -19 = -26 or 7746 octal. Produces carry out. Compliment link
	hlt					/ Halt the system
	jmp Main				/Incase something goes wrong
		
/
/ Data Section
/
*0250 					/ place data at address 0250
A, 5						/ 5 in decimal
B, 12						/ 10 in decimal
C, 7754					/ -20 in decimal
D, 3777					/ 2047 in decimal - largest positive number
E, 7771					/ -7 in decimal
F, 7755					/ -19 in decimal
zero, 0

$Main 			/ End of Program; Main is entry point
