
; Author: Lachlan Sinclair
; Last Modified:4/21/20129
; OSU email address: sinclala@oregonstate.edu
; Course number/section: CS271_400
; Project Number: 2                Due Date: 4/21/2019
; Description: Code prompts the user for a number between 1 and 46,
; then it displays all of the fibbonacci numbers up to the number entered
; EC: the program formats the output into columns

INCLUDE Irvine32.inc



;constants
UPPER_LIMIT = 46		;upper limit of user input
LOWER_LIMIT = 1			;lower limit of user input
TWO = 2					;used to set ecx in the calculation loop
COLUMNS = 6				;number of coloumns+1 to be used in formatting
TAB = 9					;value used as to format columns
FORMAT_TABS = 36		;at 36 the number of tabs to be used in formatting gets reduced by 1

.data
	
	;strings for intro
	header			BYTE "Fibonacci Numbers            Author: Lachlan Sinclair",0
	EC				BYTE "**EC: The output is displayed in aligned columns.",0
	intro			BYTE "What is your name? ", 0
	greeting		BYTE "Hello, ", 0
	instructions	BYTE "Enter the number of Fibonacci terms to be dispayed", 0dh, 0ah
					BYTE "Give the number as an integer in the range [1 .. 46].",0
	prompt			BYTE "How many Fibonacci terms do you want? ",0
	outOfRange		BYTE "Out of range. Enter a number in [1 .. 46]",0
	userName		BYTE 21 DUP(0)		;stores the username

	;strings for displaying data
	spaces			BYTE "     ",0

	;strings for exiting messages
	certified		BYTE "Results certified by Lachlan Sinclair.", 0dh, 0ah
					BYTE "Goodbye, ",0
	period			BYTE ".",0
	;testArr			BYTE 21 DUP(0)

	;numbers used throughout the program
	iterations		DWORD ?		;the desired number of fibonacci numbers inputted by the user
	tempValue		DWORD ?		;used to temporarly store values
	secondTemp		DWORD ?		;used to hold temp sotrage if first temp is being used
	lastValue		DWORD ?		;holds the previous value from the sequence
	counter			DWORD 2		;holds a counter used to determine return lines
	formatCount		DWORD 2		;holds a counter used for formating tabs


.code
main proc


;------------Introduction---------------	
	mov		edx, OFFSET header
	call	WriteString					;display name and author details
	call	CrLf

	mov		edx, OFFSET EC
	call	WriteString					;display the extra credit information
	call	CrLf

	mov		edx, OFFSET intro
	call	WriteString					;ask for the users name
	;call	CrLf

	mov		edx, OFFSET userName		;set up edx for the readstring
	mov		ecx, SIZEOF userName		;set up ecx for the readstring
	call	ReadString					;read the string into the username

	mov		edx, OFFSET greeting
	call	WriteString					;display the greeting message
	mov		edx, OFFSET userName
	call	WriteString					;display the username after the greeting
	call	CrLf


;------------Instructions---------------	
	mov		edx, OFFSET  instructions
	call	WriteString					;display the instructions
	call	CrLf
	call	CrLf

	mov		edx, OFFSET prompt
	call	WriteString					;ask the user how many numbers they would like to calculate
	;call	CrLf


;------------getUserData---------------	
;obtains input from the user

	call	ReadInt						;read in the integer provided
	cmp		eax, UPPER_LIMIT			;compare user input to 46
	JLE		checkLowerBound				;if the input is good jump to displaying the sequence

;section used if the user input was incorrect
;uses a post test loop

getUserData:
	mov		edx, OFFSET outOfRange
	call	WriteString					;displays a message that the input was out of range
	call	CrLf

	mov		edx, OFFSET prompt
	call	WriteString					;ask the user how many numbers they would like to calculate

	call	ReadInt						;read in the new value
	cmp		eax, UPPER_LIMIT			;compare user input to 46
	JG		getUserData					;if the input is good jump to displaying the sequence

;section to make sure the number is atleast one
;also detects the two special cases of 1 and 2 iterations

checkLowerBound:
	cmp		eax, LOWER_LIMIT		;compare to make sure the value is greater than one
	JL		getUserData

	cmp		eax, 1					;jumps to the special cases where the sequence is just one or two
	JE		justOne					;using the loop format we have to check if it is one or two
	cmp		eax, 2					;due to the special nature of the seqeunce
	JE		justTwo

;------------Display---------------	
displayFibs:	
	sub		eax, TWO				;subtract two to correct its value for the counter
	mov		iterations, eax			;move the correct number to iterations value
	mov		ecx, iterations			;set up ecx with the number of required iterations

	mov		eax, 1					;set eax to the first value in the sequence
	mov		lastValue, eax			;move 1 into the lastvalue variable

	call	WriteDec				;display the first element

	mov		tempValue, eax			;temporarily save eax
	mov		al, TAB					
	call	WriteChar				;output two tabs
	call	WriteChar
	mov		eax, tempValue			;restore eax

	call	WriteDec				;display the first element

	mov		tempValue, eax			;temporarily save eax
	mov		al, TAB			
	call	WriteChar				;output two tabs
	call	WriteChar
	mov		eax, tempValue			;restore eax
	
;loop used to calculate the sequence values that are above the 2nd iteration
L1:

	mov		ebx, lastValue			;move the previous value to ebx to add to eax
	mov		lastValue, eax			;save the newest value to the previous variable
	add		eax, ebx
	

	mov		ebx, counter			;increment the counter used to track line returns
	inc		ebx

	mov		tempValue, eax			;store eax temporarily
	mov		eax, formatCount		;increment the counter
	inc		eax
	mov		formatCount, eax
	mov		eax, tempValue			;restore eax
	
	cmp		ebx, COLUMNS			;check if a line return is needed
	JNE		noNewRow				;jump if not needed
	call	CrLf					
	mov		ebx, 1					;reset the counter
	

noNewRow:
	Call	WriteDec				;write the integer of this sequence values
	
	mov		tempValue, eax			;format the columns with the tab char
	mov		al, TAB			
	call	WriteChar
	
	mov		secondTemp, ebx			;use a check to determine if one or two tabs are needed
	mov		ebx, formatCount
	cmp		ebx, FORMAT_TABS

	JGE		NoSecondTab				;skip adding the second tab for the larger numbers

	call	WriteChar
NoSecondTab:	
	mov		eax, tempValue			;reset the EAX register to pre formating value

	mov		ebx, secondTemp			;reset ebx to pre formatting value
	mov		counter, ebx			;update the counter used for newlines

	loop	L1						;loop used to calculate and display the sequence



	Call CrLf
	jmp		farewell				;jump to the farewell

;special case used when the user only wants one iteration
justOne:
	mov		eax, 1					;set eax to the first value in the sequence
	call	WriteDec				;display the first element
	call	CrLf
	jmp		fareWell				;jump to the goodbye message

;special case when the user only wants two iterations
justTwo:
	mov		eax, 1					;set eax to the first value in the sequence
	call	WriteDec				;display the first element

	mov		tempValue, eax			;temporarily save eax
	mov		al, TAB					
	call	WriteChar				;double tab for formatting
	call	WriteChar
	mov		eax, tempValue			;restore eax

	call	WriteDec				;display one again
	call	CrLf

	
;------------Farewell---------------	
fareWell:
	mov		edx, OFFSET  certified
	call	WriteString					;display the certified message
	mov		edx, OFFSET userName
	call	WriteString					;display the users name
	mov		edx, OFFSET period
	call	WriteString					;attach a period to the end
	call	CrLf




	exit								;exit to OS
main endp
end main