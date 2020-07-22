TITLE Program Template     (template.asm)

; Author: Lachlan Sinclair
; Last Modified:6/4/20129
; OSU email address: sinclala@oregonstate.edu
; Course number/section: CS271_400
; Project Number: 6B                Due Date: 6/9/2019
; Description: Randomly generates the a set size, and number of elements to choose from 
; that set, the user then enters the number of combinations they think is are possible. The 
; code validates there response.
; **EC: The problems are numbered, and a small report on how the user did is displayed at the end

INCLUDE Irvine32.inc

; (insert constant definitions here)



;protoypes used by INVOKE
Introduction PROTO

ShowProblem PROTO,
	nVal:PTR DWORD,
	rVal:PTR DWORD,
	question:PTR DWORD

Combinations PROTO,
	nValue:DWORD,
	rValue:DWORD,
	Result:PTR DWORD

GetData PROTO,
	answer:PTR DWORD

ShowResults PROTO,
	nVal:DWORD,
	rVal:DWORD,
	Result:DWORD,
	Answer:DWORD,
	amount:PTR DWORD

UserPrompt PROTO,

GoodBye PROTO,
	question:DWORD,
	amount:DWORD

;-------------------------------------------------
;mWriteString
;macro that takes an offset of a string as a parameter and outputs the string to the console
;uses edx but does not alter it
;-------------------------------------------------
mWriteString MACRO buffer
	push edx
	mov	edx, OFFSET buffer
	call WriteString
	pop  edx
ENDM

.data
	prompt			BYTE "Combinations calculator            By Lachlan Sinclair",0dh, 0ah
					BYTE "**EC: The problems are numbered, and a small report on how the user did is displayed at the end.",0dh, 0ah
					BYTE "I",27h, "ll give you a combinations problem. You enter your answer,",0dh, 0ah
					BYTE "and I",27h, "ll let you know if you",27h, "re right.",0
	setSize			BYTE "Number of elements in the set: ",0
	numElement		BYTE "Number of elements to choose from the set: ",0
	question		BYTE "How many ways can you choose? ",0
	answerBuffer	BYTE 40 DUP(0)

	correct			BYTE "You are correct!",0
	incorrect		BYTE "You need more practice.",0

	repeatMes		BYTE "Another problem? (y/n): ",0
	error			BYTE "Invalid response. ",0
	againBuffer		BYTE 40 DUP(0)

	there			BYTE "There are ",0
	combs			BYTE " combinations of ",0
	items			BYTE " items from a set of ",0

	report1			BYTE "You correctly answered ",0
	report2			BYTE " out of ",0
	report3			BYTE " questions correctly.",0

	goodbyeMes		BYTE "Ok  ... Goodbye.",0

	problemDis		BYTE "Problem ",0
	


.code

;-------------------------------------------------
; Main
; Description: Contains all of the data and calls
; the other procedures.
; Recieves: nothing
; Returns: nothing
;-------------------------------------------------
main PROC

	.data

	;data section used to pass values to other methods

	result			DWORD ?			;the calculated correct value
	nVal			DWORD ?			;n value
	rVal			DWORD ?			;r value
	answer			DWORD 0			;answer value from the user
	questionNum		DWORD 1			;question number
	amountCor		DWORD 0			;number of correct answers

	.code

	call Randomize

	INVOKE Introduction

;loop used to repeat the procedure calls until the user decides to quit
RepeatProblem:
	INVOKE ShowProblem, ADDR nVal, ADDR rVal, ADDR questionNum	

	INVOKE GetData, ADDR answer

	INVOKE Combinations, nVal, rVal, ADDR result
	
	INVOKE ShowResults, nVal, rVal, answer, result, addr amountCor

	;sets eax to either 0 or 1 depending on whether or not they would like to answer another question
	INVOKE UserPrompt

	cmp		eax, 1				;check if they would like another question
	JE		RepeatProblem		;loop to go through another question

	INVOKE GoodBye, amountCor, questionNum
	
	exit	
main ENDP

; (insert additional procedures here)

;-------------------------------------------------
; Introduction 
; Outputs the instructions to the console
; Recieves: nothing
; Returns: nothing
; Registers: edx is used in the macro but not changed
;-------------------------------------------------
Introduction PROC,

	mWriteString prompt			;call the write string macro, providing it with the offset of the prompt string
	call		CrLf
	call		CrLf

	ret
Introduction ENDP

;-------------------------------------------------
; GetData 
; gets the user input, and validates that they entered a number
; Recieves: address of the users answer address DWORD
; Returns: nothing
; Registers: no registers are changed, uses eax, ecx, ebx, edx, esi
;-------------------------------------------------
GetData PROC USES eax ecx ebx edx esi,
	answerVal:PTR DWORD

PromptUser:
	mWriteString question

	mov		edx, OFFSET answerBuffer		;move the offset of the buffer into edx
	mov		ecx, SIZEOF answerBuffer		;put the size of the buffer into ecx
	call	ReadString						;read in the user input

	mov		ecx, eax						;move the total number of character entered to ecx
	push	ecx								;store number of character on the stack for clean up later

	cmp		ecx, 1							;check to make sure one value was entered
	JB		ErrorMessage					;jump if the user just  pressed enter

	mov		ebx, 10							;move 10 into ebx to be used in multipication 
	mov		eax, 0							;set eax to zero "blacnk slate"
	mov		esi, OFFSET answerBuffer		;set esi to the user inputs offset

L1:
	mov		dl, [esi]						;move next byte from the input into dl
	movzx	edx, dl							;sero extend it into edx
	
	cmp		edx, 0							;compare it to 0 to see if string is over
	JE		EndOfString						;break out of loop

	push	edx								;temporarily store edx on the stack
	mul		ebx								;multiply the current value in eax by 10, shifting the decimal place
	pop		edx								;restore edx, since it gets changed in the mul

	cmp		edx, 48							;make sure the byte has an ascii value between 48 and 57
	JB		ErrorMessage					;display error and reprompt if its to small

	cmp		edx, 57							;check if its to big
	JA		ErrorMessage					;if code doesnt jump here it is a valid integer value

	sub		edx, 48							;subtract the ascii shift from the value
	add		eax, edx						;add it to the lowest decimal place of the current total


	inc esi									;increment esi, to allow next byte to be accessed during next run
	loop L1									;loop for the length of the buffer or until a jump occurs

;all bytes represents number if this code is reached
EndOfString:
	mov		ebx, answerVal					;move the answerval offset into ebx
	mov		[ebx], eax						;store the converted number into answerval

	JMP CleanBuffer

ErrorMessage:
	mWriteString error						;display the error message
	pop ecx									;restore ecx
	mov		eax,0							;reset eax
	mov		esi, OFFSET answerBuffer		;move the starting offset of the buffer back into esi
L3:
	mov		[esi], eax						;loop reseting the buffer to all zeros
	inc		esi
	Loop L3

	JMP	PromptUser							;jump to reprompt the user for a new value

;this code resets the buffer after a good value has been given, for the next potential question. A little redundant but time is short.
CleanBuffer:
	pop ecx
	mov		eax,0
	mov		esi, OFFSET answerBuffer
L2:
	mov		[esi], eax		;reset the buffer to all zeros
	inc esi
	Loop L2
	
	ret	
GetData ENDP

;-------------------------------------------------
; ShowProblem
; Displays the problem, including the random numbers it calculates
; Recieves: address of the n value, address of the r value, and the 
; current problem number(for display).
; Returns: nothing
; Registers: no registers are changed, eax, ebx, ecx, esi registers are used
;-------------------------------------------------

ShowProblem PROC USES eax ebx ecx esi,
	nValue:PTR DWORD,
	rValue:PTR DWORD,
	problem:PTR DWORD

	mov		eax, 12							;move the high limit of random numbers into edx
	inc		eax								;fix for the constant being 999
	sub		eax, 3							;subtract the lower limit off of edx
	cld									    ;clear the direction flag

	call RandomRange						;call randomize to get the random number
	add		eax, 3							;shift it up based off the low bound

	mov		esi, nValue						;move n values offset into esi
	mov		[esi], eax						;store the random number in nValue

	;display the question number
	push eax								;temporarily store eax on the stack
	push esi								;also store esi on the stack
	mWriteString problemDis					;display "Problem "
	mov		esi, problem					;move the problems numbers offset into esi
	mov		eax, [esi]						;move the problem number into eax
	call	WriteDec						;print the problem number
	inc		eax								;increment the problem number for the next problem
	mov		[esi], eax						;store the incremented number back into the problem number
	mov		al, 58							;move ":" ascii value into al
	call	WriteChar						;print the :
	call	CrLf
	pop esi									;restore eax and esi to pre problem number values
	pop eax

	mWriteString setSize					;use the macro to display the next part of the string
	call WriteDec							;display the set size
	call crlf								

	cld
	call RandomRange						;call random range again, upper bound is already the correct value
	inc		eax								;increment the random number to account for the lower bound

	mov		esi, rValue						;set r values offset to esi
	mov		[esi], eax						;store the random number in rvalue

	mWriteString numElement					;write the next string using the macro
	call WriteDec							;append the r value to it
	call crlf

	ret
ShowProblem ENDP

;-------------------------------------------------
; Combinations
; calls the factorial procedure 3 times, then calculates
; then calculate the number of combinations and stores that value
; current problem number(for display).
; Recieves: nVal, rVal, and a pointer to the result variable
; Returns: nothing, alters the resultVal variable via direct access
; Registers: no registers are changed
;-------------------------------------------------
Combinations PROC USES eax ebx edx ecx esi,
	nValue:DWORD,
	rValue:DWORD,
	resultVal:PTR DWORD

	mov		eax, nValue						;mov the n and r values into eax and ebx
	mov		ebx, rValue

	sub		eax, ebx						;calculate the difference
	mov		ecx, eax						;store in ebx to be used later

	push		nValue						;push the n value to be used in the factorial equation
	call factorial							;call factorial on n value
	mov		nValue, eax						;store the result back into n value

	push		rValue						;push the r value to be used in the factorial equation
	call factorial							;call factorial on r value
	mov		rValue, eax						;the result back into r value

	push		ecx							;push the n-r value to be used in the factorial equation
	call factorial							;call factorial on n-r value. leave the value in eax

	mov		ebx, rValue						;calculate the denominator for equation
	mul		ebx								;r!*(n-r)!

	mov		ebx, eax						;store the result in ebx
 
	mov		eax, nValue						;move n to eax, and clear edx
	cdq
	div		ebx								;n!/(r!*(n-r)!)

	mov		esi, resultVal					;use to address of the result val to store eax
	mov		[esi], eax

	ret
Combinations ENDP

;-------------------------------------------------
; factorial
; This procedure checks for speical cases, and sets up the stack for the recursive
; procedure call. I choose to use a helper function to make it different than the example in the text book.
; Recieves: the number to calculate factorial on, from the stack
; Returns: the total value in eax
; Registers: eax is changed. ebx, edx, ebp are used
;-------------------------------------------------
factorial PROC
	push	ebp
	push	ebx						;save ebx on the stack
	push	edx						;save edx on the stack, it get alterd in the factioral recursion procedure due to the mul operation. I choose to store it here to prevent every recursive call from having to store it.
	mov		ebp, esp

	mov		eax, [ebp+16]			;move desired number into eax
	mov		ebx, eax				;move the same number into ebx
	dec		ebx						;get the next number in the factorial series by deincrementing

	cmp		eax, 1					;check for the special cases where eax is one or less, the r value can be 1, this prevent multiplying by 0
	JLE		One

	push	ebx						;store the next number on the stack
	push	eax						;store the "running total" on the stack

	call    factorialRecursion		;call the recusive proc
	JMP		Finish

One:
	mov		eax, 1					;handling the special cases, simply set the result to one

Finish:
	pop		edx						;restore edx
	pop		ebx						;restore ebx from the stack
	pop		ebp
	ret	4							;return, note eax now contains the result

factorial ENDP


;-------------------------------------------------
; factorialRecursion
; Recursively calculates the factorial of the provided number and stores the value in eax
; Recieves: the total value, the next value in the series vai the stack
; Returns: the total in eax
; Registers: edx, and eax are changed. ebx, ebp, are used but not changed
;-------------------------------------------------
factorialRecursion PROC
	push	ebp						;standard storing of ebp, and moving esp
	mov		ebp, esp

	mov		ebx, [ebp+12]			;pull the next two values off the stack to multiply
	mov		eax, [ebp+8]

	cmp		ebx, 1					;if the lower number is one, no need to multiply
	JE		quit					;break out of recursion, base case has been met

	mul		ebx						;multiply the two numbers
	dec		ebx						;decrement ebx by one,
		
	push	ebx						;push the current value onto the stack
	push	eax						;pushing the running total onto the stack

	call	factorialRecursion		;recursively call the procedure again

quit:
	pop ebp							;restore ebp
	ret	8							;return 
factorialRecursion  ENDP

;-------------------------------------------------
; ShowResults
; Outputs the instructions to the console
; Recieves: n value,  r value, answer value, result value, number
; Returns: nothing
; Registers: edx, eax, esi are used but not changed
;-------------------------------------------------
ShowResults PROC,
	nValue:DWORD,
	rValue:DWORD,
	answerVal:DWORD,
	resultVal:DWORD,
	amount:PTR DWORD

	call CrLf

	mWriteString there				;display the first part of the sentence
	mov		eax, resultVal			;print the nubmber of combinations
	call	WriteDec

	mWriteString combs				;display the next part of the sentence
	mov		eax, rValue				;display the rvalue
	call	WriteDec

	mWriteString items				;display another part of the sentence
	mov		eax, nValue				;display the value of n
	call	WriteDec

	mov		al, 46					;add a period to the end of the sentence			
	call	WriteChar
	call	CrLf

	mov		eax, resultVal			;check to see if the value provided was correct
	cmp		eax, answerVal
	JE		correctAns				;jump if correct

	mWriteString incorrect			;display incorrect message
	call CrLf
	JMP ExitShow					;jump to end of procedure

correctAns:
	mWriteString correct			;display the correct screen
	call CrLf

	mov		esi, amount				;increment the amount of correct answers by 1
	mov		eax, [esi]				;using the address of amount
	inc		eax
	mov		[esi], eax

ExitShow:
	ret
ShowResults ENDP


;-------------------------------------------------
; UserPrompt
; Used to ask the user if they would like to do another problem
; Recieves: nothing
; Returns: eax as a bool value, 1 true, 0 false
; Registers: edx, ecx, eax, are used. eax is changed
;-------------------------------------------------

UserPrompt PROC USES ecx edx,
	
	call	CrLf
Again:
	mWriteString repeatMes					;ask the user if they would like another problem
	mov		edx, OFFSET againBuffer				
	mov		ecx, SIZEOF againBuffer
	call	ReadString						;read in the string to the againbuffer

	cmp		eax, 1							;see if they entered more than one character
	JG		Invalid							;jump if more than one was entered

	mov		al, [edx]						;move the first char into al

	;code block checking for yes
	cmp		al, 89							;compare al to ascii value of upper and lowercase y
	JE		againY							
	cmp		al, 121
	JE		againY

	;code block checking for no
	cmp		al, 78							;compare al to ascii value of upper and lowercase n
	JE		againN
	cmp		al, 110
	JE		againN

Invalid:									;code for handling invalid entries
	;invalid input section
	mWriteString error						;display error message and loop
	JMP		Again

againY:
	mov		eax, 1							;set eax to 1 for another problem
	jmp	exitShow

againN:
	mov		eax, 0							;set eax to 0 to end the program

exitShow:
	call CrLf
	
	ret
UserPrompt ENDP

;-------------------------------------------------
; GoodBye
; Dislpays the goodbye message, with a small report of how the user did
; Recieves: correctnum, totalnum
; Returns: nothing
; Registers: eax is used but not changed
;-------------------------------------------------

GoodBye PROC USES eax,
	correctNum:DWORD,
	totalNum:DWORD

	mWriteString report1				;display the rport message
	mov		eax, correctNum				;display the number of problems the user got correct
	call	WriteDec

	mWriteString report2				;display the out of portion of the message
	mov		eax, totalNum				;display the total number of problems, -1 for the auto increment
	dec		eax
	call	WriteDec

	mWriteString report3				;last part of the report message
	call CrLf

	mWriteString goodbyeMes				;goodbye message
	call CrLf

	ret
GoodBye ENDP

END main


