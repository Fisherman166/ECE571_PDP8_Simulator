/ Date : Feb 15, 2015
/
/ Desc : Tests the group 2 micro instructions
/ Should take 25 cycles total
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main,			/ Test combos sma sza snl at the same time
	cla cll cma	/ clear AC and link, load AC with -1
	sma	sza snl	/ skip on minus AC, zero AC, non-zero link
	dca B		/ overwrite B if SMA sza snl fails, should not run
	cla cll 	/ clear AC and link
	sma	sza snl	/ skip on minus AC, zero AC, non-zero link
	dca C		/ overwrite C if SMA SZA snl fails, should not run
	cla cll iac cml	/ clear AC and link, set AC to 1, set link to 1
	sma	sza snl	/ skip on minus AC, zero AC, non-zero link
	dca D		/ overwrite C if SMA SZA snl fails, should not run

	cla cll iac	/ clear AC and link, load AC with 1
	sma	sza snl	/ skip on minus AC, zero AC, non-zero link
	dca E		/ overwrite E if sma snl fails, should run

	hlt			/ Halt the system
	jmp Main	/ In case something goes wrong	
/
/ Data Section
/
*0250 			/ place data at address 0250
B, 0 			/ will get -1 if sma sza snl fails
C, 1			/ will get 0 if sma sza snl fails
D, 2			/ will get 1 if sma sza snl fails
E, 3			/ will get 1 when sma sza snl fails


$Main 			/ End of Program; Main is entry point
