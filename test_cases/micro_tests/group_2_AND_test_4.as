/ Date : Feb 15, 2015
/
/ Desc : Tests the group 2 micro instructions, AND subgroup
/ Should take 15 cycles total
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main,			/ Test SKP
	cla cll iac	/ clear AC and link, set AC to 1
	skp			/ skip
	dca A		/ overwrite A if skp fails, should not run

				/ Test CLA
	cla cll iac	/ clear AC and link, set AC 1
	sma cla		/ skip, clear AC
	dca B		/ overwrite B if sma fails, should run

	cla cll 	/ clear AC and link
	osr			/ OR switch register with AC
	dca C		/ overwrite C, should run

	cla cll	iac cml	/ clear AC and link, set AC to 1, set link to 1
	spa cla hlt	/ skip on positive AC, clear AC
	dca D		/ overwrite D if spa sna fails, should not run
	dca E		/ overwrite E if spa sna fails, should not run

	hlt			/ Halt the system
	jmp Main	/ In case something goes wrong	
/
/ Data Section
/
*0250 			/ place data at address 0250
A, 0	 		/ will get 1 if spa fails
B, 77 			/ will get 0 when sma fails
C, 77			/ will get OCR contents
D, 77			/ will not change due to halt
E, 77			/ will not change due to halt

$Main 			/ End of Program; Main is entry point
