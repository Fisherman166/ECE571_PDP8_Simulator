/ Date : Feb 15, 2015
/
/ Desc : Tests the group 2 micro instructions, AND subgroup
/ Should take 19 cycles total
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main,			/ Test skips working first
	cla cll iac	/ clear AC and link, set AC to 1
	spa			/ skip on positive AC
	dca A		/ overwrite A if spa fails, should not run
	cla cll iac	/ clear AC and link, set AC to 1
	sna			/ skip on non-zero AC
	dca B		/ overwrite B if sna fails, should not run
	cla cll iac	/ clear AC and link, set AC to 1
	szl			/ skip on zero link
	dca C		/ overwrite C if szl fails, should not run

				/ Test skips failing
	cla cll cma	/ clear AC and link
	spa			/ skip on positive AC
	dca D		/ overwrite D if spa fails, should run
	cla cll		/ clear AC and link
	sna			/ skip on non-zero AC
	dca E		/ overwrite E if sna fails, should run
	cla cll cml	/ clear AC and link, set link to 1
	szl			/ skip on zero link
	dca F		/ overwrite F if szl fails, should run

	hlt			/ Halt the system
	jmp Main	/ In case something goes wrong	
/
/ Data Section
/
*0250 			/ place data at address 0250
A, 0	 		/ will get 1 if spa fails
B, 0 			/ will get 1 if sna fails
C, 0			/ will get 1 if szl fails
D, 77			/ will get 7777 when spa fails
E, 77			/ will get 0 when sna fails
F, 77			/ will get 0 when szl fails	

$Main 			/ End of Program; Main is entry point
