TITLE Program Template     (template.asm)

; Author: Lachlan Sinclair
; Last Modified:5/26/20129
; OSU email address: sinclala@oregonstate.edu
; Course number/section: CS271_400
; Project Number: 5                Due Date: 5/26/2019
; Description: Generate an array of random integers of a size the user requests
; recursively sort the random array, displaying it before and after the sort.
; Also display the median value

INCLUDE Irvine32.inc

; (insert constant definitions here)

MIN = 10			
MAX = 200
LO = 100
HI = 999
TAB = 9
DWORD_SIZE = 4

;protoypes used by INVOKE
Introduction PROTO,
	promptMes:PTR BYTE

GetData PROTO,
	pRequest:PTR DWORD,
	dataPrompt:PTR BYTE,
	invalid:PTR BYTE

FillArray PROTO,
	valRequest:DWORD,
	pArray:PTR DWORD

DisplayList PROTO,
	valRequest:DWORD,
	pArray:PTR DWORD,
	titleMes:PTR BYTE

SortList PROTO,
	valRequest:DWORD,
	aArray:PTR DWORD,
	bArray:PTR DWORD


CopyArray PROTO,
	aArray:PTR DWORD,
	lowInd:DWORD,
	valRequest:DWORD,
	bArray:PTR DWORD

SplitMerge PROTO,
	aArray:PTR DWORD,
	splitLowInd:DWORD,
	splitHighInd:DWORD,
	bArray:PTR DWORD

Merge PROTO,
	aArray:PTR DWORD,
	mergeLowInd:DWORD,
	middleInd:DWORD,
	mergeHighInd:DWORD,
	bArray:PTR DWORD

 DisplayMedian PROTO,
	valRequest:DWORD,
	Array:PTR DWORD,
	Message:PTR BYTE,
	



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

	prompt			BYTE "Sorting Random Integers            By Lachlan Sinclair",0dh, 0ah
					BYTE "**EC: The program sorts recursively using merge sort.",0dh, 0ah
					BYTE "This program generates random numbers in the range [100 .. 999],", 0dh, 0ah
					BYTE "displays the orginal list, sorts the list, and calculatates the", 0dh, 0ah
					BYTE "median value. Finally, it displays the list sorted in descending order.",0

	dataPrompt		BYTE "How many numbers should be generated? [10 .. 200]: ",0
	invalid			BYTE "Invalid input",0

	unsorted		BYTE "The unsorted random numbers: ",0
	sorted			BYTE "The sorted list:",0

	medianMess		BYTE "The median is ",0

	request			DWORD ?			;holds the user input for number of values requested
	randomInt		DWORD MAX DUP(?)	;array for the random integers
	interArray		DWORD MAX DUP(?)	;holds and intermediate array
	median			DWORD ?
	

	.code

	call Randomize

	INVOKE Introduction, ADDR prompt

	INVOKE GetData, ADDR request, ADDR dataPrompt, ADDR invalid			;call the GetData passing the address of request
	
	INVOKE FillArray, request, ADDR randomInt							;fill the array with random integers
	
	INVOKE DisplayList, request, ADDR randomInt, ADDR unsorted			;display the unsorted array

	INVOKE SortList, request, ADDR randomInt, ADDR interArray			;sort the array using mergesort

	INVOKE DisplayMedian, request, ADDR randomInt, ADDR medianMess		;display the median

	INVOKE DisplayList, request, ADDR randomInt, ADDR sorted			;display the sorted array

	



	exit	
main ENDP

; (insert additional procedures here)


;-------------------------------------------------
; Introduction 
; Outputs the instructions to the console
; Recieves: an offset of the string it prints
; Returns: nothing
; Registers: edx is changed
;-------------------------------------------------
Introduction PROC USES edx,
	promptMes:PTR BYTE

	mov		edx, promptMes
	call	WriteString					;display program name and author details
	call	CrLf
	call	CrLf

	ret
Introduction ENDP

;-------------------------------------------------
; GetData procedure
; Gets data and validates it from the user.
; Recieves: request (reference)
; Returns: value entered by the user via altering the reference
; Registers: eax, edx, esi are changed
;-------------------------------------------------

GetData PROC USES eax edx esi,
	pRequest:PTR DWORD,					;pointer to the variable used to store request amount
	dataPromptMes:PTR BYTE,
	invalidMes:PTR BYTE

PromptUser:
	mov		edx, dataPromptMes
	call	WriteString					;display prompt to get user data
	call ReadDec						;read the user input
	
	cmp eax, MIN
	JB Declined							;user input was to small
	
	cmp eax, MAX
	JA Declined							;user input was to large

	JMP accepted						;user input was in valid bounds

Declined:
	mov		edx, invalidMes
	call	WriteString					;display error message
	call CrLf
	
	JMP PromptUser

Accepted:
	mov		esi, pRequest
	mov		[esi], eax

	Call CrLf

	ret
GetData ENDP

;-------------------------------------------------
;FillArray
; Fills the array with random integers
; Recieves:  request (value), array (reference)
; Returns: the array filled with random integers, it changes
; it by reference though
; Registers: eax, edi, ecx, edx are changed
;-------------------------------------------------
FillArray PROC USES eax edi ecx edx,
	valRequest:DWORD,
	pArray:PTR DWORD

	mov	edi, pArray
	mov	ecx,valRequest
	mov	edx, HI							;move the high limit of random numbers into edx
	inc	edx								;fix for the constant being 999
	sub	edx, LO							;subtract the lower limit off of edx
	cld									;clear the direction flag

L1: 
	mov  eax, edx
	call RandomRange			

	add	eax, LO							;correct the offset for the random numbers
	stosd								;store EAX into [edi]
	loop L1

	ret
FillArray ENDP

;-------------------------------------------------
; SortList
; uses merge sort to recursively sort the random array
; Recieves:  request (value), array (reference), array (reference)
; Returns: nothing
; Registers: eax, ecx, esi are changed
;-------------------------------------------------
SortList PROC USES eax ecx esi,
	valRequest:DWORD,
	aArray:PTR DWORD,
	bArray:PTR DWORD

	;subtract 1 from val request to allow it to be used in indexing
	;dec		valRequest

	INVOKE CopyArray, aArray, 0, valRequest, bArray		;copy a array into b
	INVOKE SplitMerge, bArray, 0, valRequest, aArray

	ret
SortList ENDP

;-------------------------------------------------
; CopyArray 
; creates a copy of the orginal array, this will be used by merge sort
; Recieves:  aArray (reference), lowIndex (value), high index (value), bArray (reference)
; Returns: nothing
; Registers: eax, ecx, esi, edi, ebx are changed
;-------------------------------------------------
CopyArray PROC USES eax ecx esi edi ebx,
	aArray:PTR DWORD,
	copylowInd:DWORD,
	copyhighInd:DWORD,
	bArray:PTR DWORD

	mov		esi, aArray
	mov		ecx, copyhighInd
	sub		ecx, copylowInd					;subtract the low index for ecx to iterate through the right amount of elements
	mov		edi, bArray
	mov		eax, copylowInd					;move low index to eax to use in tracking position inside the array

L1: 
	mov		ebx, [esi+eax]					;move value at this index to ebx
	mov		[edi+eax], ebx					;store the value in the second array
	
	add		eax, DWORD_SIZE					;increment the index by the size of DWORD

	loop L1

	;remove after testing
	;INVOKE DisplayList, copyhighInd, bArray

	ret
CopyArray ENDP

;-------------------------------------------------
; SplitMerge
; recursively split the array until only single values are left in the "sub arrays"
; Recieves:  bArray (reference), lowIndex (value), high index (value),  aArray (reference)
; Returns: nothing
; Registers: eax, ecx, ebx are changed
;-------------------------------------------------
SplitMerge PROC USES eax ecx ebx,
	bArray:PTR DWORD,
	splitLowInd:DWORD,
	splitHighInd:DWORD,
	aArray:PTR DWORD


	;If statement
	mov		eax, splitHighInd					;this section of code is if(end-start<2) {return}

	mov			ebx, splitLowInd
	sub			eax, ebx						;this section checks to see if another split can take place
	mov			ebx, 1							;if it cannot the sub arrays are of size one and it will
	cmp			eax, ebx						; return to the function that called it
	JLE			ReturnS


	;find the middle of the current range
	mov		eax, splitHighInd					;reset eax to the high index
	add		eax, splitLowInd					;add the low index
	cdq
	mov		ebx, 2
	div		ebx									;eax now equals the midpoint

	;recursively call split merge twice to sort the upper and lower half of the current range
	INVOKE SplitMerge, aArray, splitLowInd, eax, bArray			;lower half call
	INVOKE SplitMerge, aArray, eax, splitHighInd, bArray		;upper half call

	INVOKE Merge, bArray, splitLowInd, eax, splitHighInd, aArray		;merge the results from the two halfs


ReturnS:
	ret
SplitMerge ENDP

;-------------------------------------------------
; Merge
; Merges the already sorted sub arrays into a larger also sorted array
; Recieves:  aArray (reference), lowIndex (value), middle index (value), high index (value), bArray (reference)
; Returns: nothing
; Registers: eax, ecx, ebx, edx, esi, edi are changed
;-------------------------------------------------
Merge PROC USES eax ecx ebx edx esi edi,
	aArray:PTR DWORD,
	mergeLowInd:DWORD,
	middleInd:DWORD,
	mergeHighInd:DWORD,
	bArray:PTR DWORD

	mov		ebx, mergeLowInd				;store the low index of the array section
	mov		edx, middleInd					;store the index of the end of the array section

	mov		esi, aArray
	mov		edi, bArray

	mov		ecx, mergeLowInd				;set up ecx as the counter


	;loop through the provided section for the array sorting it
Sorting:
	;compare used by the loop
	cmp		ecx, mergeHighInd
	JAE		BreakOut

	;if section for when ebx is less than middle AND (edx is less than or equal to HighInd OR A[ebx] is less than or equal to A[edx]
	;copy value from lower section

	cmp		ebx, middleInd					;if ebx is above or equal to the mid index insert value from upper
	JAE		FromUpper			

	cmp		edx, mergeHighInd
	JAE		FromLower

	push ecx								;push ecx very shortly to be used in indexing

	mov		eax, [esi+ebx*4]
	mov		ecx, [esi+edx*4]

	cmp		eax, ecx						;this is the main compare, switching to JBE will make it order from least to greatest
	pop ecx
	JAE		FromLower

	JMP		FromUpper						;if code makes it to here all checks in the if statement have failed, insert from upper

;section to insert value from the lower section
FromLower:

	
	mov		eax, [esi+ebx*4]				;move the highest value from the temp array to eax
	mov		[edi+ecx*4], eax				;move eax into the correct spot in the sorted array
	inc		ebx								;increment the counters
	inc		ecx
	JMP		Sorting							;repeat the loop

;else section, inserts value from upper section
FromUpper:

	mov		eax, [esi+edx*4]				;move the highest value from the temp array to eax
	mov		[edi+ecx*4], eax				;move eax into the correct spot in the sorted array
	inc		edx								;increment the counters
	inc		ecx
	JMP		Sorting							;repeat the loop
	
BreakOut:

	ret
Merge ENDP



;-------------------------------------------------
;DisplayList
; Steps through the array display the values, it also displays the message
; passed before the array
; Recieves: request(value), array(reference), message (reference)
; Returns: nothing
; Registers: eax, ecx, edi, edx, esi are changed
;-------------------------------------------------
DisplayList PROC USES eax ecx edi edx esi, 
	valRequest:DWORD,
	pArray:PTR DWORD,
	titleMes:PTR BYTE

	mov		edx, titleMes
	call	WriteString						;display the message for the median
	call	CrLf

	mov		esi, pArray						;move the offset of the array into esi

	
	mov		ecx, 0							;intialize the counters to 0
	mov		ebx, 0

Print:
	cmp		ecx, ValRequest					;check to see if all values have been printed
	JAE		Finished

	mov		eax,[esi+ecx*4]					;use the offset to print the next value in the array
	call	WriteDec

	mov		al, TAB					
	call	WriteChar						;output a tab to allign the data into columns

	inc		ecx								;increment both counters
	inc		ebx

	cmp		ebx,10							;check to see if a new line is needed
	JB		Print

	call	CrLf							;call for a new line
	mov		ebx, 0							;set the new line counter back to zero
	JMP		Print

Finished:
	call	CrLf
	Ret
DisplayList ENDP

;-------------------------------------------------
; DisplayMedian PROC
; Calculates then displays the median value
; Recieves: request(value), array(reference), message(reference)
; Returns: nothing
; Registers: eax, ecx, edi, edx, ebx are changed
;-------------------------------------------------
DisplayMedian PROC USES eax ecx edi edx ebx, 
	valRequest:DWORD,
	sortedArray:PTR DWORD,
	Message:PTR BYTE

;display the message for displaying the median before calculating it

	call	CrLf
	mov		edx, Message
	call	WriteString					;display the message for the median


;Calculate the median value	
	mov		eax, valRequest
	mov		ebx, 2
	mov		esi, sortedArray

	cdq

	div		ebx

	cmp		edx, 1						;check to see if there is a remainder
	JE		Odd

;section if there is a even number used as median
	mov		ebx, 4
	mul		ebx


	mov		ecx, eax
	sub		ecx, ebx

	mov		eax, [esi+eax]				;eax will be the number that comes first therefor the larger one
	mov		ecx, [esi+ecx]				;ecx will be the smaller number

	add		eax, ecx
	mov		ebx, 2
	cdq	
	div		ebx							;divide the larger number by the smaller number

	cmp		edx, 1
	JE		Rounding

	;code for when no rounding is required

	JMP Return							;jump to displaying the code

Rounding:
	inc		eax							;since division was by 2 we can simple increment here to round
	JMP Return

;code that handles caculating the median when a odd sized array was produced
Odd:
	mov		ebx, 4					
	mul		ebx
	mov		eax, [esi+eax]				;go straight to the index holding the median
	

Return:
	call WriteDec

	mov		al, 46					
	call	WriteChar				     ;output a tab to allign the data into columns

	call CrLf							;formatting
	Call CrLf
	ret
DisplayMedian ENDP


END main


