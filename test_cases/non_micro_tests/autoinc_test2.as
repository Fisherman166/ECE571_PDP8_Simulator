/Similar the the other Effective address 
/ calcualion test but on this one we are not using 
/ indirect mode so address 10 -17 
/ should not be incremented
*7
var1,	Array
Ptr0,	2
Ptr1,	2
Ptr2,	2
Ptr3,	2
Ptr4,	2
Ptr5,	2
Ptr6,	2
Ptr7,	2
Ptr8,	Array

*50 
C,	0               / C=0 to start C=6 at the end



*0200			/ start at address 0200
Main, 	cla cll 	/ clear AC and Link
	tad  Ptr0 	/ Auto inc. add Array[1] to Accumulator 
	tad  Ptr1 	/ Auto inc. add Array[1]to Accumulator
	tad  Ptr2 	/ Auto inc. add Array[1] to Accumulator
	tad  Ptr3 	/ Auto inc. add Array[1] to Accumulator
	tad  Ptr4 	/ Auto inc. add Array[1] to Accumulator
	tad  Ptr5 	/ Auto inc. add Array[1] to Accumulator
	tad  Ptr6 	/ Auto inc. add Array[1] to Accumulator
	tad  Ptr7 	/ Auto inc. add Array[1] to Accumulator
        
	dca  A		/ Current page direct 
        tad i B         / current page indirect
	tad i Ptr8 	/ NOT Auto inc. add Array to Accumulator
	tad i var1 	/ Not Auto inc. add Array to Accumulator
	dca C 		/ Direct Zero page
	hlt 		/ Halt program
	jmp Main	/ To continue - goto Main
/
/ Data Section
/


*0250 			/ place data at address 0250
A, 	0 		/ A=0 at start A=20 at the end
B, 	300 		/ B used as address to array

/ auto incremented
*300
Array,	2
	0

$Main 			/ End of Program; Main is entry point
