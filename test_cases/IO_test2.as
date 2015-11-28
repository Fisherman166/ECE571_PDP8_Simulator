/ Date : Feb 13, 2015
/
/ This tests the I/O function of the PDP8
/ The program will ask for your name (up to 8 characters long).
/ It will then say "Nice to meet you name"
/
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main, 	
	cll cla
	jms printGreeting	/ Greets the user and asks for name
	jms getName			/ Gets name from user
	jms printResponse / Prints out response plus name
	hlt

printGreeting,
	NOP
	cla
printLoop,
	tad i gPtr			/ Put next character in accumulator
	tpc					/ Print the character
	cla					/ Clear accumulator
	isz gPtr				/ Move to the next character
	isz gLen				/ Used to end loop
	jmp printLoop		/ Loop until done printing greeting
	jmp i printGreeting	/Return to main

getName,
	NOP
	cla
	tad namePtr			/ Load pointer of char1 into accum
	dca tempPtr			/ Make copy of the pointer
nameLoop,
	ksf					/ Skip only if char inputted
	jmp nameLoop
	krb					/ Read in the char to accum
	dca i tempPtr		/ Deposit char into memory

	tad numChars		/ Put in accum
	tad negOne			/ Decrement the number
	dca numChars		/ Store back

	tad numChars		/ Reload in accum
	tad maxLen			/ Add 8 to number
	spa					/ Skip if (numChars + 8) > 0
	jmp i getName		/ Return to main

	cla					/ Clear accum
	tad i tempPtr		/ Load the inputted char
	tad enterChk		/ Subtract the ascii value of enter
	sna					/ Skip if (character - enter) != 0
	jmp i getName		/ Return to main

	cla					/ Clear accum
	isz tempPtr			/ Increment char ptr
	jmp nameLoop		/ Grab another char

printResponse,
	NOP
	cla
resLoop,
	tad i oPtr			/ Put next character in accumulator
	tpc					/ Print the character
	cla					/ Clear accumulator
	isz oPtr				/ Move to the next character
	isz oLen				/ Used to end loop
	jmp resLoop			/ Loop until done printing hard coded responseo

	tad namePtr			/ Load in nameptr to Accum
	dca tempPtr			/ Make copy of the pointer
	
printName,
	tad i tempPtr		/ Load in name char
	tpc					/ Print the char
	cla					/ Clear accum
	isz tempPtr			/ Increment character address
	isz numChars		/ Check to see if all chars printed
	jmp printName		/ Continue printing name
	jmp i printResponse	/Return to main

/
/ Data Section
/
*0300
gPtr, 0302				/ Ptr to starting address of greeting 
gLen, 7745				/ -27 to print all characters in greeting
2560						/ W
3200						/ h
3020						/ a
3500						/ t
1000						/ space
3220						/ i
3460						/ s
1000						/ space
3620						/ y
3360						/ o
3520						/ u
3440						/ r
1000						/ space
3340						/ n
3020						/ a
3320						/ m
3120						/ e
1000						/ space
1200						/ (
3320						/ m
3020						/ a
3600						/ x
1000						/ space
1600						/ 8
1220						/ )
1760						/ ?
1000						/space

negOne, 7777			/ -1 Decimal
numChars, 0				/ Decrement when char entered
maxLen, 0010			/ Maximum of 8 characters allowed
namePtr, 0343			/ Ptr to char1
tempPtr, 0				/ Copy of ptr for filling letters
enterChk, 7540			/ -160 in decimal to check for enter keypress
char1, 0					/ Letter 1
char2, 0					/ Letter 2
char3, 0					/ Letter 3
char4, 0					/ Letter 4
char5, 0					/ Letter 5
char6, 0					/ Letter 6
char7, 0					/ Letter 7
char8, 0					/ Letter 8
char9, 240				/ Newline

oPtr, 0356				/Pointer for output message
oLen, 7756				/ -18 - increment to print out message
240						/ Newline
2340						/ N
3220						/ i
3060						/ c
3120						/ e
1000						/ space
3500						/ t
3360						/ o
1000						/ space
3320						/ m
3120						/ e
3120						/ e
3500						/ t
1000						/ space
3620						/ y
3360						/ o
3520						/ u
1000						/ space
$Main 			/ End of Program; Main is entry point
