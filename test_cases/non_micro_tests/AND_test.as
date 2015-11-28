/ Date : Feb 7, 2015
/
/ Desc : Tests the AND instruction
/ Should take 8 cycles total
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main, 	
	cla cll 				/ clear AC and Link
	tad fillAccum		/ Fill accum with 1s
	and andMask			/ Keep 731
	and zero				/ Zero out accum
	hlt					/ Halt the system
	jmp Main				/Incase something goes wrong	
/
/ Data Section
/
*0250 					/ place data at address 0250
fillAccum, 7777	 	/ All 1s
andMask, 731 			/ Bitmask for the and test
zero, 0					

$Main 			/ End of Program; Main is entry point
