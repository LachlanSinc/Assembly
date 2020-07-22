TITLE Program Template     (assignment1.asm)

; Author: Lachlan Sinclair
; Last Modified:4/13/20129
; OSU email address: sinclala@oregonstate.edu
; Course number/section: CS271_400
; Project Number: 1                Due Date: 4/14/2019
; Description: Code prompts the user to input two numbers,
; the program then performs basic arthimic on the two numbers.
; EC: the program repeats until the user chooses to quit
; EC: Validates that the 2nd number is less than the 1st
; EC: Calculates the quotient as a floating point number rounded to the nearest .001


INCLUDE Irvine32.inc

; Constant definitions

SIG_DIGITS = 10000;
MODULUS = 10;
ROUNDING = 5;
NINE = 9;

.data

;variables for user input
firstNumber		DWORD ?		;first number entered by the user
secondNumber	DWORD ?		;second number entered by the user

;values used in arthimetic and logic
continueNumber  DWORD ?		;number to determine if the user wants to continue 
quotient		DWORD ?		;quotient from first division
remainderInc	DWORD ?		;remainder increased to caclulate floating points
decimalVals		DWORD ?		;holds the 3 decimals values for after the .
additionVal		DWORD ?		;stores the result from addition
subtractionVal	DWORD ?		;stores the result from subtraction
multiVal		DWORD ?		;stores the result from multiplication

;variables used for floating point calculatio
first_digit		DWORD ?		;first digit used for the floating point values
second_digit	DWORD ?		;second digit used for the floating point values
third_digit		DWORD ?		;third digit used for the floating point values
fourth_digit	DWORD ?		;fourth digit used for the floating point values

;this section contains all of the Bytes used to display the output correctly.
header			BYTE "Some Simple Arithmetic            Author: Lachlan Sinclair",0
EC1				BYTE "**EC: The program insures the second values is smaller than the first.",0
EC2				BYTE "**EC: The program can be repeated until the users chooses to quit.",0
EC3				BYTE "**EC: The Program displays the quotient as a rounded flointing point.",0

intro			BYTE "Enter 2 numbers, and I'll show you the sum, difference,product, quotient, and remainder.", 0
firstPrompt		BYTE "First number: ", 0
secondPrompt	BYTE "Second number: ", 0
remainder		BYTE " remainder: ", 0
goodbye			BYTE "Goodbye.", 0
sizeWarning		BYTE "The second number must be less than the first. Try again.", 0
continue_1		BYTE "Would you like to enter another set of numbers?", 0
continue_2		BYTE "Enter 0 to end the program, or any other number to continue: ", 0
quotientMess	BYTE "The value of the quotient as a floating point: ",0

addition		BYTE " + ", 0
subtraction		BYTE " - ", 0
multiplication	BYTE " x ", 0
division		BYTE 246, 0
space			BYTE " ",0
equals			BYTE " = ", 0
period			BYTE ".", 0

.code
main PROC
;------Introduction------------------
	mov		edx, OFFSET header
	call	WriteString					;display name and authord details
	call	CrLf

	mov		edx, OFFSET  EC1
	call	WriteString					;display the message for the first EC
	call	CrLf

	mov		edx, OFFSET EC2
	call	WriteString					;display the message for the second EC
	call	CrLf

	mov		edx, OFFSET EC3
	call	WriteString					;display the message for the third EC
	call	CrLf

NumberPrompt:
	mov		edx, OFFSET intro
	call	WriteString					;intro that displays instructions, will repeat upon user request at the end
	call	CrLf

;------Get the Data------------------
;get first number

	mov		edx, OFFSET firstPrompt
	call	WriteString					;prompt for the first integer and save it to the first number
	call	ReadInt
	mov		firstNumber, eax

	;get second number
	mov		edx, OFFSET secondPrompt
	call	WriteString					;prompt for the second integer and save it to the second number
	call	ReadInt
	mov		secondNumber, eax

;compare the inputs to insure the first is larger

	mov		eax, firstNumber
	cmp		eax, secondNumber			;compare the two user inputs

	ja		goodSize					;jump to goodsize if the first number is larger than the second

	

;warning for incorrect size enteries
badSize:
	mov		edx, OFFSET sizeWarning		;display the warning then jump to the repeating prompt chunk of code
	call	WriteString
	call	CrLf
	jmp		Continuation

;--------Calculate the required Values---------------
goodSize:								;used when the check of the user inputs is returns the values are good.
;addition code
	
	mov		eax, firstNumber
	mov		ebx, secondNumber			;this section actually performs the addition then outputs 
	add		eax, ebx					;the result at the end of the line previously generated.
	mov		additionVal, eax			;store the result for displaying later

;subtraction code

	mov		eax, firstNumber
	mov		ebx, secondNumber			;this section actually performs the subtraction then outputs 
	sub		eax, ebx					;the result at the end of the line previously generated.
	mov		subtractionVal, eax			;store the result for displaying later


;multiplication code

	mov		eax, firstNumber		
	mov		ebx, secondNumber			;this section actually performs the multiplication then outputs 
	mul		ebx							;the result at the end of the line previously generated.
	mov		multiVal, eax				;store the result for displaying later

;division code

	mov		eax, firstNumber
	cdq
	mov		ebx, secondNumber
	div		ebx
	mov		quotient, eax				;this section actually performs the division then outputs 
	mov		eax,edx						;the result at the end of the line previously generated.
	mov		remainderInc, eax			;use cdq to clear edx(which will be the remainder).
	

;divison with a decimal. I tried with FPU and rounding from page 521 but couldnt get it to work
;droping leading zeros was an issue so I had to create 4 numbers and modulus through them to be
;sure I kept leading zeros after the . and also to deal with rounding into 9's
	
	mov		ebx, SIG_DIGITS
	mov		eax, remainderInc			;Multiply the remainder by 10,000.
	mul		ebx
	
	cdq
	mov		ebx, secondNumber			;Divide the remainder*10000 by the second number
	div		ebx							;to get the floating points to the .0000 place.
	
	cdq
	mov		ebx, MODULUS
	div		ebx							;take the modulus 10 off of the previously calculated
	mov		fourth_digit,edx			;place it in the fourth digit

	cdq
	mov		ebx, MODULUS
	div		ebx							;take the modulus 10 off of the previously calculated
	mov		third_digit,edx				;place it in the third digit

	cdq
	mov		ebx, MODULUS
	div		ebx							;take the modulus 10 off of the previously calculated
	mov		second_digit,edx			;place it in the second digit

	cdq
	mov		ebx, MODULUS
	div		ebx							;take the modulus 10 off of the previously calculated
	mov		first_digit,edx				;place it in the first digit

;section to round all needed numbers
	mov		eax, fourth_digit
	cmp		eax, ROUNDING				;check if the fourth decimal place is less than 5, if it is
	jb		display						;jump to display

;code will only go here if rounding needs to be used
	mov		eax, third_digit		
	cmp		eax, NINE					;check to see if the third digit is nine and will need to be
	je		thirdequal9					;dealt with specially.

;increment the value and jump to displaying the output if not equal to 9
	inc		eax
	mov		third_digit, eax
	jmp		display

thirdequal9:							;third digit equaled 9 during rounding
	mov		third_digit, 0
	mov		eax, second_digit		
	cmp		eax, NINE					;check to see if the third digit is nine and will need to be
	je		secondequal9				;dealt with specially.Otherwise increment the second digit and display.
	
	inc		eax
	mov		second_digit, eax
	jmp		display

secondequal9:							;second digit equaled 9 during rounding
	mov		second_digit, 0
	mov		eax, first_digit		
	cmp		eax, NINE					;check to see if the third digit is nine and will need to be
	je		firstequal9					;dealt with specially. Otherwise increment the first digit and display.
	
	inc		eax
	mov		first_digit, eax
	jmp		display

firstequal9:							;first digit equaled 9 during rounding
	mov		first_digit, 0				;set the first decimal value to 0 then 
	mov		eax, quotient				;increment the value that comes before the dot in the floating point
	inc		eax
	mov		quotient, eax
	
;-------------Display Section--------------------
display:
;display addition
	mov		eax, firstNumber		
	call	WriteDec
	mov		edx, OFFSET addition		;this section sets up the display for the addition line, it
	call	WriteString					;uses eax to print both numbers, and the addition string to
	mov		eax, secondNumber			;show the +.
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, additionVal
	call	WriteDec
	call	CrLf


;display subtraction

	mov		eax, firstNumber
	call	WriteDec
	mov		edx, OFFSET subtraction		;this section sets up the display for the subtraction line, it
	call	WriteString					;uses eax to print both numbers, and the subtraction string to
	mov		eax, secondNumber			;show the -.
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, subtractionVal
	call	WriteDec
	call	CrLf

;display multiplication
	mov		eax, firstNumber
	call	WriteDec
	mov		edx, OFFSET multiplication
	call	WriteString					;this section sets up the display for the multiplication line, it
	mov		eax, secondNumber			;uses eax to print both numbers, and the multiplication string to
	call	WriteDec					;show the x.
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, multiVal
	call	WriteDec
	call	CrLf

;display division

	mov		eax, firstNumber
	call	WriteDec
	mov		edx, OFFSET space			;this section sets up the display for the division line, it
	call	WriteString					;uses eax to print both numbers, and the division string to
	mov		edx, OFFSET division		;show the divsion symbol using the ASCII value.
	call	WriteString
	mov		edx, OFFSET space
	call	WriteString
	mov		eax, secondNumber
	call	WriteDec
	mov		edx, OFFSET equals
	call	WriteString
	mov		eax, quotient
	call	WriteDec

	mov		edx, OFFSET remainder
	call	WriteString					;this section displays the remainder of the division operation
	mov		eax, remainderInc
	call	WriteDec
	call	CrLf

;section to display the pre dot portion of the float

	;display the value
	mov		edx, OFFSET quotientMess
	call	WriteString					;this section displays the floating point display up to the dot
	mov		eax, quotient
	call	WriteDec
	mov		edx, OFFSET period
	call	WriteString
	
;display all of the post dot values	

	mov		eax, first_digit			;this uses the 3 decimal values to display the post dot values
	call	WriteDec

	mov		eax, second_digit
	call	WriteDec

	mov		eax, third_digit
	call	WriteDec
	call	CrLf


;loop the entire program

continuation:
	mov		edx, OFFSET continue_1
	call	WriteString					;promt asking if the user would like to run the program again
	call	CrLf

	mov		edx, OFFSET continue_2		;displays the repeat message
	call	WriteString
	call	ReadInt			

	cmp		eax, 0						;compare the input to 0
	jne		NumberPrompt				;jump to the start if the number entered doesnt equal 0


;----------Say Goodbye------------------
	mov		edx, OFFSET goodbye			;displays goodbye message
	call	WriteString

	exit								; exit to operating system
main ENDP

; (insert additional procedures here)

END main
