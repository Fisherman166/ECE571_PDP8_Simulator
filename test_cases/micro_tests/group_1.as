/ Date : Feb 15, 2015
/
/ Desc : Tests the group 1 micro instructions
/ Should take 27 cycles total
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main, 	
	cla cll 	/ clear AC and Link
	nop			/ no operation
	dca A		/ overwrite A, should change to zero
	cma cml		/ complement AC and link, should be all 1's
	dca B		/ store in B, should be 1's
	cla			/ clear AC, but link is still 1
	rar			/ link bit rotates to bit 0 of AC
	dca C		/ store in C, should be 4000 octal
	cml rtr		/ set link, link bit rotates to bit 1 of AC
	dca D		/ store in D, should be 2000 octal
	cml ral		/ set link, link bit rotates to bit 11 of AC
	dca E		/ store in E, should be 1 octal
	cml rtl		/ set link, link bit rotates to bit 10 of AC
	dca F		/ store in E, should be 2 octal
	iac			/ increment AC
	dca G		/ should be 1
	cma iac		/ complement AC, then increment AC
	dca H		/ should be 0
	hlt			/ Halt the system
	jmp Main	/ In case something goes wrong	
/
/ Data Section
/
*0250 			/ place data at address 0250
A, 7777	 		/ cla will change this to zero
B, 0 			/ cma will change this to 1's
C, 0			/ rar will change this to 04000	
D, 0			/ rtr will change this to 02000	
E, 0			/ ral will change this to 01	
F, 0			/ rtl will change this to 02	
G, 0			/ iac will change this to 01	
H, 7777			/ iac will change this to 0	

$Main 			/ End of Program; Main is entry point
