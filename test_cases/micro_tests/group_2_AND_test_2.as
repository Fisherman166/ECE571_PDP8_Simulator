/ Date : Feb 15, 2015
/
/ Desc : Tests the group 2 micro instructions, AND subgroup
/ Should take 31 cycles total
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main,			/ Test skips working first
	cla cll iac	/ clear AC and link, set AC to 1
	spa	sna		/ skip on positive AC, non-zero AC
	dca A		/ overwrite A if spa sna fails, should not run
	cla cll iac	/ clear AC and link, set AC to 1
	sna	szl		/ skip on non-zero AC, zero link
	dca B		/ overwrite B if sna szl fails, should not run
	cla cll iac	/ clear AC and link, set AC to 1
	spa szl		/ skip on positive AC, zero link
	dca C		/ overwrite C if szl fails, should not run

				/ Test skips failing
	cla cll cma	/ clear AC and link, load AC with 7777
	spa	sna		/ skip on positive AC, non-zero AC
	dca D		/ overwrite D if spa fails, should run
	cla cll		/ clear AC and link
	spa	sna		/ skip on positive AC, non-zero AC
	dca E		/ overwrite E if spa fails, should run

	cla cll		/ clear AC and link
	sna	szl		/ skip on non-zero AC, zero link
	dca F		/ overwrite F if sna szl fails, should run
	cla cll iac cml	/ clear AC and link, set AC to 1, set link to 1
	sna	szl		/ skip on non-zero AC, zero link
	dca G		/ overwrite G if sna fails, should run

	cla cll cml	/ clear AC and link, set link to 1
	spa szl		/ skip on positive AC, skip on zero link
	dca H		/ overwrite H if szl fails, should run
	cla cll iac cml	/ clear AC and link, set AC to 1, set link to 1
	spa szl		/ skip on positive AC, skip on zero link
	dca I		/ overwrite I if szl fails, should run

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
G, 77			/ will get 1 when szl fails	
H, 77			/ will get 0 when szl fails	
I, 77			/ will get 1 when szl fails	

$Main 			/ End of Program; Main is entry point
