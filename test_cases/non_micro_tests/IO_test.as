/ Date : Feb 7, 2015
/
/-------------------------------------------
/ Code Section
*0200			/ start at address 0200
Main, 	
	cll cla
	/jms printText	/ Print out "Enter text:\n" without quotes

readchars,
	ksf				/ Skip if there is a char to read
	jmp readchars
	krb				/ Read in the char to accumulator
	tpc
	isz numchars	/ Increment number of chars written
	jmp readchars
	hlt


printText,
	NOP
enter,
	tad i Epnt			/ Put next character in accumulator
	tpc					/ Print the text
	cla					/ Clear accumulator
	isz Epnt				/ Move to the next character
	isz printEnter		/ Used to end loop
	jmp enter			/ Loop until done printing enter

	tad lowt				/ Put T in accumulator
	tpc
	cla
	tad lowe
	tpc
	cla
	tad lowx
	tpc
	cla
	tad lowt
	tpc
	cla
	tad colon
	tpc
	cla
	tad newline
	tpc
	cla
	jmp i printText	/Return to main
	
/
/ Data Section
/
*0310
Epnt, 0312				/ Pointer to capE
printEnter, 7772		/ -6 to countdown to escape loop
capE, 2120				/ Capital E
lown, 3340				/ lowercase n
lowt, 3500				/ lowercase t
lowe, 3120				/ lowercase e
lowr, 3440				/ lowercase r
space, 1000
lowx, 3600				/ lowercase x
colon, 1640				
newline, 240
numchars, 7774			/ -4 to hold char num
$Main 			/ End of Program; Main is entry point
