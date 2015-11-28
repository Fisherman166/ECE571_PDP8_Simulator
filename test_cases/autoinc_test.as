/It has a pointer before 10 and past 10
/ it should only out increment 10-17
/ not the other 
/ Also access the same array using zero 
/ page indirect
*7
var1,	Array
Ptr0,	Array-1
Ptr1,	Array-1
Ptr2,	Array-1
Ptr3,	Array-1
Ptr4,	Array-1
Ptr5,	Array-1
Ptr6,	Array-1
Ptr7,	Array-1
Ptr8,	Array

*50 
C,	0               / C=0 to start C=6 at the end



*0200			/ start at address 0200
Main, 	cla cll 	/ clear AC and Link
	tad i Ptr0 	/ Auto inc. add Array[1] to Accumulator 
	tad i Ptr1 	/ Auto inc. add Array[1]to Accumulator
	tad i Ptr2 	/ Auto inc. add Array[1] to Accumulator
	tad i Ptr3 	/ Auto inc. add Array[1] to Accumulator
	tad i Ptr4 	/ Auto inc. add Array[1] to Accumulator
	tad i Ptr5 	/ Auto inc. add Array[1] to Accumulator
	tad i Ptr6 	/ Auto inc. add Array[1] to Accumulator
	tad i Ptr7 	/ Auto inc. add Array[1] to Accumulator
        
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
