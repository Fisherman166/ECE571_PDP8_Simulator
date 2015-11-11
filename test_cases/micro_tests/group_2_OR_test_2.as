/ Date : Feb 15, 2015
/
/ Desc : Tests the group 2 micro instructions
/ Should take 25 cycles total
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main,			/ Test combos of sma and sza
	cla cll cma	/ clear AC and link, load AC with -1
	sma	sza		/ skip on minus AC, zero AC
	dca B		/ overwrite B if SMA sza fails, should not run
	cla cll 	/ clear AC and link
	sma sza		/ skip on minus AC, zero AC
	dca C		/ overwrite C if SMA SZA fails, should not run
	cla cll iac	/ clear AC and link, set AC to 1
	sma sza		/ skip on minus AC, zero AC
	dca D		/ overwrite C if SMA SZA fails, should run

	cla cll cma	/ clear AC and link, load AC with -1
	sma	snl		/ skip on minus AC, non-zero link
	dca E		/ overwrite E if sma snl fails, should not run
	cla cll cml	/ clear AC and link, set link high
	sma snl		/ skip on minus AC, non-zero link
	dca F		/ overwrite F if sma snl fails, should not run
	cla cll iac	/ clear AC and link, set AC to 1
	sma snl		/ 
	dca G		/ overwrite G if sma snl fails, should run

	cla cll		/ clear AC and link, load AC with -1
	sza	snl		/ skip on minus AC, non-zero link
	dca H		/ overwrite H if sma snl fails, should not run
	cla cll cml	/ clear AC and link, set link high
	sza snl		/ skip on minus AC, non-zero link
	dca I		/ overwrite I if sma snl fails, should not run
	cla cll iac	/ clear AC and link, set AC to 1
	sza snl		/ 
	dca J		/ overwrite J if sma snl fails, should run

	hlt			/ Halt the system
	jmp Main	/ In case something goes wrong	
/
/ Data Section
/
*0250 			/ place data at address 0250
B, 0 			/ will get -1 if sma sza fails
C, 1			/ will get 0 if sma sza fails
D, 2			/ will get 1 if sma sza fails
E, 3			/ will get -1 when sma snl fails
F, 4			/ will get 0 when sma snl fails	
G, 5			/ will get 1 when sma snl fails
H, 6
I, 7
J, 10

$Main 			/ End of Program; Main is entry point
