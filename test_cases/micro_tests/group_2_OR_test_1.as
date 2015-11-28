/ Date : Feb 15, 2015
/
/ Desc : Tests the group 2 micro instructions
/ Should take 21 cycles total
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main,			/ Test skips working first
	cla cll 	/ clear AC and link
	tad A		/ load AC with -1
	sma			/ skip on minus AC
	dca B		/ overwrite B if SMA fails, should not run
	cla cll 	/ clear AC and link
	sza			/ skip on zero AC
	dca C		/ overwrite C if SZA fails, should not run
	cla cll cml	/ clear AC and link, set link high
	snl			/ skip on nonzero link
	dca D		/ overwrite D if SZA fails, should not run

				/ Test skips failing
	cla cll 	/ clear AC and link
	sma			/ skip on minus AC
	dca E		/ overwrite E if SMA fails, should run
	cla cll cma 	/ clear AC and link
	sza			/ skip on zero AC
	dca F		/ overwrite F if SZA fails, should run
	cla cll 	/ clear AC and link, set link high
	snl			/ skip on nonzero link
	dca G		/ overwrite G if SZA fails, should run

	hlt			/ Halt the system
	jmp Main	/ In case something goes wrong	
/
/ Data Section
/
*0250 			/ place data at address 0250
A, 7777	 		/ -1
B, 0 			/ will get -1 if sma fails
C, 1			/ will get 0 if sza fails
D, 2			/ will get 0 if snl fails
E, 3			/ will get 0 when sma fails
F, 4			/ will get 7777 when sza fails	
G, 5			/ will get 0 when snl fails

$Main 			/ End of Program; Main is entry point
