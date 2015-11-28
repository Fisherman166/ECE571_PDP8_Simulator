/ Date : Feb 15, 2015
/
/ Desc : Tests the group 2 micro instructions, AND subgroup
/ Should take 15 cycles total
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main,			/ Test skips working first
	cla cll iac	/ clear AC and link, set AC to 1
	spa	sna szl	/ skip on positive AC, non-zero AC, zero link
	dca A		/ overwrite A if spa sna fails, should not run

				/ Test skips failing
	cla cll cma	/ clear AC and link, set AC to 7777
	spa	sna szl	/ skip on positive AC, non-zero AC, zero link
	dca B		/ overwrite B if spa sna fails, should run

	cla cll 	/ clear AC and link
	spa	sna szl	/ skip on positive AC, non-zero AC, zero link
	dca C		/ overwrite C if spa sna fails, should run

	cla cll iac	cml	/ clear AC and link, set AC to 1, set link to 1
	spa	sna szl	/ skip on positive AC, non-zero AC, zero link
	dca D		/ overwrite D if spa sna fails, should not run

	hlt			/ Halt the system
	jmp Main	/ In case something goes wrong	
/
/ Data Section
/
*0250 			/ place data at address 0250
A, 0	 		/ will get 1 if spa fails
B, 77 			/ will get 7777 when sna fails
C, 77			/ will get 0 when szl fails
D, 77			/ will get 1 when spa fails

$Main 			/ End of Program; Main is entry point
