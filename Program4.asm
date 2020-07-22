
; Author: Lachlan Sinclair
; Last Modified:5/12/20129
; OSU email address: sinclala@oregonstate.edu
; Course number/section: CS271_400
; Project Number: 4                Due Date: 5/12/2019
; Description: Accept a number for the user between
;1 and 400, then print that many composite numbers
; EC1: The output is displayed in alligned columns
; EC2: The program uses an array of prime numbers it generates
; to detect composite numbers


INCLUDE Irvine32.inc

DWORD_SHIFT = 4
UPPER_LIMIT = 400
LOWER_LIMIT = 1
TAB = 9

.data

header			BYTE "Composite Numbers        Author: Lachlan Sinclair",0
EC1				BYTE "**EC: The output uses aligned columns.",0
EC2				BYTE "**EC: The program uses an array of prime numbers found to find composite numbers.",0
instructions	BYTE "Enter the number of composite numbers you would like to see.", 0dh, 0ah
				BYTE "I'll accept orders for up to 400 composites.",0
prompt			BYTE "Enter the number of composites to display [1 .. 400]: ",0
rangeError		BYTE "Out of range. Try again.",0

exitMessage		BYTE "Results certified by Lachlan. Goodbye.",0





numberOfComp	DWORD	?				;number of composites to display
sizePrime		DWORD	2				;holds the amount of values in the prime array, defaulted to 2(2 and 3)
indexPrime		DWORD	1
primeArr		DWORD   400 DUP(?)
;primeArr		DWORD   1,2,3,4,5

counter			DWORD	4				;number used to check for composite numbers, it counts up starting at 4
newLineCount	DWORD	1				;used to track when a new line is needed
currentComp		DWORD	?				;holds the current composite number
compCount		DWORD	?				;counts the number of composites found


.code
main proc
	
	call	Introduction				;the main procedure just calls the other 4 procedures
	call	getUserData					
	call	showComposites
	call	fareWell

	invoke ExitProcess,0
main endp

Introduction PROC

	mov		edx, OFFSET header
	call	WriteString					;display program name and author details
	call	CrLf

	mov		edx, OFFSET EC1
	call	WriteString					;display the first EC information
	call	CrLf

	mov		edx, OFFSET Ec2
	call	WriteString					;display the second EC information
	call	CrLf
	call	CrlF						;double return lines for formatting


	mov		edx, OFFSET instructions
	call	WriteString					;display programs instructions
	call	CrLf
	call	CrLf						;line returns for formating
		
	ret									;return to main

Introduction ENDP

getUserData PROC
;this procedure prompts the user for data, then reads it in, it then 
;calls the validate procedure to make sure the data was good, if not it 
;loops again until user provides good data
promptUser:

	mov		edx, OFFSET prompt
	call	WriteString					;display the user input prompt

	call	ReadInt
	mov		numberOfComp, eax			;read in the number of composites the users wants

	call	validate					;call the validate subroutine to insure the input was good

	cmp		ecx, 0						;check to to see if the user input was good
	JE		promptUser					;if ecx 0 display the prompt again and revalidate

	ret									;return to main
getUserData ENDP


validate PROC
;this procedure checks to see if the user input is between 1 and 400, 
;it uses the ecx as a boolean value, which getUserData checks to confirm that
;data is valid

	mov		ecx, 0						;set ecx to 0 to be used as a Bool
	cmp		eax, UPPER_LIMIT			;compare to the upper limit
	JA		errorMessage				;jump to display error message
	cmp		eax, LOWER_LIMIT			;compare to lower bound
	JB		errorMessage				;jump to display error message

	mov		ecx, 1						;the given value is in the range
	JMP		exitVal						;jump to exit out of the validate proc

errorMessage:
	
	mov		edx, OFFSET rangeError
	call	WriteString					;display the range error message
	call	CrLf

exitVal:
	ret									;return to get UserData
validate ENDP

showComposites PROC
;this procedure calculates the number of composites the user asked for, it displays
;them as it finds them. It does this by checking to see if any primes divide into the 
;current number, if yes it is a composite, if not it is a prime and is added to the array
		
	call	CrLf						;formatting newline
	mov		esi, OFFSET primeArr		;move the address of the prime array in to esi
	mov		eax, 2
	mov		[esi], eax					;add 2 and 3 to the array of primes
	mov		eax, 3
	mov		[esi+DWORD_SHIFT], eax

	mov		ecx, numberOfComp			;set ecx to the set to the number of composites requested, it will
										;be used as a loop counter
L1:
	push	ecx							;push ecx onto the stack to preserve the counter
	call	isComposite					;call the iscomposite procedure to get the next composite number
	pop		ecx							;in the counter vairable

	mov		eax, counter				;print the counter variable which holds the next composite number
	call	WriteDec
	
	inc		eax							;increment counter to be used in the next call of is composite
	mov		counter, eax

	mov		al, TAB					
	call	WriteChar				     ;output a tab to allign the data into columns

	mov		eax, newLineCount			;check to see if a newline is needed
	cmp		eax, 9						
	JBE		noNewLine					;if line count is 9 or lower, a newline is not needed
	call	CrLf						;use a newline in the output

	mov		eax, 0						;reset the newline counter
	mov		newLineCount, eax
	JMP		nextIteration				;skip the nonewline code

noNewLine:	
	mov		al, TAB					
	call	WriteChar				    ;output a tab

nextIteration:
	inc		newLineCount				;increment the counter used to track newlines

	loop	L1							;loop using ecx to loop the amount of times requested by the user
						
	ret									;return to main
showComposites ENDP

isComposite PROC
;this procedure is user to determine if the current value in the counter variable is a composite,
;if it is not it will add it to the array of primes

findComp:
	mov		ecx, sizePrime				;move the tracker of number of values of primes into ecx
	mov		esi, OFFSET primeArr		;load the primeArr address into esi
L2:										
	mov		eax, DWORD_SHIFT			;move a prime number into ebx
	mov		ebx, ecx					;copy ecx into ebx
	dec		ebx							;subtract one off of ebx to fix indexing
	mul		ebx							;mutiply eax(the size of a dword, by the index)ebx

	mov		ebx, [esi+eax]				;retrive the number at the calculated address 

	mov		eax, counter				;move the counter to eax
	cdq
	div		ebx							;divide eax by the retrieved prime

	cmp		edx, 0						;if remainder is 0, the counter is a composite
	JE found							;break out of loop

	loop L2								;repeat the loop to check next prime

	;code will reach this area if the current value of counter is prim
	mov		eax, indexPrime				;move the index of the next position in the prime array
	inc		eax							
	mov		ebx, 4						;multiply it by the dword value
	mul		ebx

	mov		ebx, counter				;add the counter to the prime array
	mov		[esi+eax], ebx

	inc		ebx							;increment and save the counter
	mov		counter, ebx

	mov		eax, sizePrime				;increment the size tracker of the array
	inc		eax
	mov		sizePrime, eax	
	
	mov		eax, indexPrime				;increment the prime index value
	inc		eax
	mov		indexPrime, eax	

	JMP		findComp					;jump to the loop throuh again on the new number

found:	
	
	ret									;return to showComposites
isComposite ENDP


fareWell PROC

	call	CrLf						;newlines for fomratting
	call	CrLf
	mov		edx, OFFSET exitMessage
	call	WriteString					;display program name and author details
	call	CrLf
	ret									;return to main

fareWell ENDP

end main


