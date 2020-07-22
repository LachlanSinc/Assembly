
; Author: Lachlan Sinclair
; Last Modified:5/4/20129
; OSU email address: sinclala@oregonstate.edu
; Course number/section: CS271_400
; Project Number: 3                Due Date: 5/5/2019
; Description: Sums the valid entries provided by the user(-1 to -100)
; then displays how many valid entries were given, the average of the valid numbers,
; and also displays the sum of the valid entries
; EC1: Numbers the lines that are used to accept user input
; EC2: Also displays the average as a rounded floating point number

INCLUDE Irvine32.inc



;constants

LOW_BOUND = -100			;used to insure input is not less than -100
ROUNDING_VALUE = -2			;used to check if rounding is needed

.data

;this section contains all of the Bytes used to display the output correctly.
header			BYTE "The Integer Accumulator            Author: Lachlan Sinclair",0
EC1				BYTE "**EC: The prompt for user input is numbered.",0
EC2				BYTE "**EC: Displays the floating point format of the average rounded to the nearest .001.",0

intro			BYTE "What is your name? ", 0
userName		BYTE 21 DUP(0)		;stores the username
greeting		BYTE "Hello, ", 0

instructions	BYTE "Please enter numbers in [-100,-1].", 0dh, 0ah 
				BYTE "Enter a non-negative number when you are finished to see results.",0

enterPrompt		BYTE ". Enter Number: ",0
amountEntered	BYTE "You entered ",0 
amountEntered2	BYTE " valid numbers.",0
sumDisplay		BYTE "The sum of your valid numbers is ",0
averageDisplay	BYTE "The rounded average is ",0

floatDisplay	BYTE "The average in floating point format, rounded to the nearest .001 is ",0

errorMsg		BYTE "No valid numbers were entered.",0

goodbyeMsg		BYTE "Thank you for playing Integer Accumulator! It's been a pleasure to meet you, ",0
period			BYTE ".",0				;used to add a period after the username


validCount		DWORD	0				;keeps track of the number of valid entries
promptCount		DWORD	1				;used to number prompt for the user
total			SDWORD	0				;keeps track of the total
quotient		SDWORD	?				;holds the quotient value


;floating point values used for EC
floatRound		REAL8	1000.0			;used to shift sigfigs of the float number to the left and right
floatQuo		REAL8	?				;holds the float quotient
	


.code
main proc


;------------Introduction---------------	
	mov		edx, OFFSET header
	call	WriteString					;display name and author details
	call	CrLf

	mov		edx, OFFSET EC1
	call	WriteString					;display EC information
	call	CrLf

	mov		edx, OFFSET EC2
	call	WriteString					;display EC information
	call	CrLf


	mov		edx, OFFSET intro
	call	WriteString					;ask for the users name
	
	mov		edx, OFFSET userName		;set up edx for the readstring
	mov		ecx, SIZEOF userName		;set up ecx for the readstring
	call	ReadString					;read the string into the username

	mov		edx, OFFSET greeting
	call	WriteString					;display the greeting message
	mov		edx, OFFSET userName
	call	WriteString					;display the username after the greeting
	call	CrLf
	call	CrLf						;formating


;------------Instructions---------------	

	mov		edx, OFFSET instructions
	call	WriteString					;display the instructions
	call	CrLf


;------------getUserData---------------	
;this section loops until the user inputs a positive number
;it sums valid entries, and counts how many valid entries have been given

NumberPrompt:
	mov		eax, promptCount			;print the display counter
	call	WriteDec
	inc		eax							;increment and store the display counter
	mov		promptCount, eax			

	mov		edx, OFFSET enterPrompt
	call	WriteString					;display user input message prompt
	call	ReadInt

	JNS		Calcs						;check the sign flag and jump if the number is not negative
	cmp		eax, LOW_BOUND				;check to see if it is greater than -100(a valid entry)
	JL		NumberPrompt				;to small of a number, jump to allow the user to enter another number

	;if code makes it to here the user entered a valid negative number
	add		eax, total					;add entry to the running sum
	mov		total, eax					;add the value to the sum

	mov		ebx, validCount				;move the count tracker to ebx
	inc		ebx
	mov		validCount, ebx				;increment the valid count

	jmp		NumberPrompt				;allow the user to enter another number

;----------Calculations--------------------
;this section contains the logic used in to calculate the sum
;it also checks to insure proper input was provided

Calcs:

	mov		eax, validCount				;checks to make sure valid input was provided
	cmp		eax, 0						
	JE		Error						;jumps if no valid entries were provided

;section to calculate the floating point value

	fild	total						;push the total onto the stack then divide by the count
	fidiv	validCount
	fmul	floatRound					;multiply by 10^3 to all for rounding
	frndint								;round the value up to t he decimal (found reference to this call online)
	fdiv	floatRound					;shift the sigfigs back to the right spot
	fstp	floatQuo					;store the value to be displayed later

;section used when valid input was provided
	
	mov		eax, total					;move total to eax and prep edx for div call
	cdq
	mov		ebx, validCount				;prep ebx with the number of valid entries
	idiv	ebx							;signed divison of total/#of valid entries
	mov		quotient, eax				;store the quotient for later

	cmp		edx, 0						;compare remainder to 0 to prevent divison by 0
	JE		Skipround					

;check to see if rounding is needed
	mov		eax, validCount				;divide the number of entries by remainder to determine
	mov		ebx, edx					;the fractional value of the quotient
	cdq
	idiv	ebx							;signed division #of entries/remainder

	cmp		eax, ROUNDING_VALUE			;compare to -2 to see if rounding is needed
	JLE		Skipround					;fractional portion was smaller than .5 no rounding needed

	mov		eax, quotient				;the values fractional value was greater than .5
	dec		eax							;quotient deincremented to account for rounding
	mov		quotient, eax				;store correct quotient

Skipround:

	jmp		Display						;jump to the displaying of correct entries

;------------Display---------------	
;displayes either the error message, or the messages contain all of the 
;calculated values


Error:
;code will go to error section if no valid input was provided
	mov		edx, OFFSET errorMsg		;display the error message
	call	WriteString					
	call	CrLf
	jmp		Goodbye						;jump to the end of the program

Display:
;section to display number of valid entries
	mov		eax, validCount
	mov		edx, OFFSET amountEntered	
	call	WriteString					;displays the lead up to number of valid entries
	call	WriteDec					;display number of valid entries
	mov		edx, OFFSET amountEntered2
	call	WriteString					;displays the later part of the number of entries message
	call	CrLf

;section for displaying the sum
	mov		eax, total
	mov		edx, OFFSET sumDisplay		;dislays the string before the sum
	call	WriteString					
	call	WriteInt					;displays the sum value
	call	CrLf

;displays the rounded average
	mov		eax, quotient
	mov		edx, OFFSET averageDisplay	;displays the message for the average
	call	WriteString					
	call	WriteInt					;displays the average
	call	CrLf

;display the floating point average

	fld		floatQuo					;push the float onto the float stack
	mov		edx, OFFSET floatDisplay
	call	WriteString					;display the floating point message
	call	WriteFloat					;display the floating point value
	call	CrLf

	
;------------Farewell---------------	
Goodbye:
	
	mov		edx, OFFSET goodbyeMsg
	call	WriteString					;display the farewell message
	mov		edx, OFFSET userName
	call	WriteString					;display the username after the greeting
	mov		edx, OFFSET period			;append a period after the username
	call	WriteString	
	call	CrLf



	exit								;exit to OS
main endp
end main