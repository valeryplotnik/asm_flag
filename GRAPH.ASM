.MODEL TINY

.CODE
ORG 100H

X = 40
Y = 80
H = 90
W = 2*H
BACK EQU 9

MAIN PROC
LOCALS @@
	MOV     AX, 0A000H
	MOV     ES, AX

	MOV     AX, 13H
	INT     10H


	CALL    PAINT_TITLE
@@CYCL:
	CALL    CLR_BUFF
	CALL    DRAW_FLAG
	CALL    COPY_BUFF
	CALL    DELAY
	INC     T

	MOV     AH, 01H
	INT     16H

	JZ      @@CYCL

	MOV     AX, 00H
	INT     16H

	CMP     AL, 13
	JNE     @@CYCL


	MOV     AX, 3
	INT     10H

	MOV		AX, 04C00H
	INT		21H
MAIN ENDP

DRAW_FLAG PROC
LOCALS @@
	PUSH    SI
	PUSH    DI

	MOV     SI, X
@@CYCL:
	MOV     DI, Y

	PUSH    DI
	PUSH    SI
	CALL    GET_Y
	ADD     SP, 4

	MOV     DI, AX

	PUSH    12
	PUSH    2*H/3
	PUSH    DI
	PUSH    SI
	CALL    DRAW_VERTICAL_LINE
	ADD     SP, 8

	PUSH    10
	PUSH    H/3
	MOV     AX, DI
	ADD		AX, 2*H/3
	PUSH    AX
	PUSH    SI
	CALL    DRAW_VERTICAL_LINE
	ADD     SP, 8

	INC     SI
	CMP     SI, X+W
	JB      @@CYCL

	POP     DI
	POP     SI
	RET
DRAW_FLAG ENDP

DRAW_VERTICAL_LINE PROC
LOCALS @@
	PUSH    BP
	MOV     BP, SP
	PUSH    SI

	;SI = X + Y * 320
	MOV     AX, 320
	MUL     WORD PTR [BP+6]
	MOV     SI, AX
	ADD     SI, [BP+4]

	MOV     CX, [BP+8]
	MOV     AL, [BP+10]
@@CYCL:
	MOV     BYTE PTR BUFF[SI], AL
	ADD     SI, 320
	DEC     CX
	JNZ     @@CYCL

	POP     SI
	POP     BP
	RET
DRAW_VERTICAL_LINE ENDP

GET_Y PROC
	PUSH    BP
	MOV     BP, SP

	SUB     WORD PTR [BP+4], X

.386
	FINIT
	FILD    WORD PTR [BP+4]
	MOV     TMP, 20
	FIDIV   TMP
	FIADD   T

	FSIN

	FIMUL   WORD PTR [BP+4]

	MOV     TMP, 2*H
	FIDIV   TMP

	MOV     TMP, 10
	FIMUL   TMP

	FIST    TMP

	MOV     DX, TMP
	ADD     DX, [BP+6]

	MOV     AX, [BP+4]
	MOV     BL, 5
	DIV     BL
	MOV     AH, 0

	SUB     DX, AX
	MOV     AX, DX

	POP     BP
	RET
GET_Y ENDP

PAINT_TITLE PROC
LOCALS @@
	PUSH    SI

	MOV     AH, 09H
	MOV     DX, OFFSET TEXT
	INT     21H

	MOV     SI, -1
@@CYCL:
	INC     SI
	CMP     SI, 320*8
	JAE     @@END
	CMP     BYTE PTR ES:[SI], 0
	JNE     @@CYCL
	MOV     BYTE PTR ES:[SI], BACK
	JMP     @@CYCL

@@END:
	POP     SI
	RET	
PAINT_TITLE ENDP

CLR_BUFF PROC
	PUSH    DI
	PUSH    ES

	PUSH    DS
	POP     ES

	MOV     DI, OFFSET BUFF
	MOV     CX, 320*200
	MOV     AL, BACK
	REP     STOSB

	POP     ES
	POP     DI
	RET
CLR_BUFF ENDP

COPY_BUFF PROC
LOCALS @@
	PUSH    SI
	PUSH    DI

@@CHK1:
	MOV     DX, 03DAh
	IN      AL, DX
	TEST    AL, 1000b ;VERTICAL RETRACE CHECK
	JNZ     @@CHK1

@@CHK2:
	MOV     DX, 03DAh
	IN      AL, DX
	TEST    AL, 1000b ;VERTICAL RETRACE CHECK
	JZ      @@CHK2

	MOV     SI, OFFSET BUFF 
	MOV     DI, 320*8
	MOV     CX, 320*192
	REP     MOVSB

	POP     DI
	POP     SI
	RET
COPY_BUFF ENDP

DELAY PROC
	MOV     CX, 0
	MOV     DX, 40000
	MOV     AH, 86H
	INT     15H

	RET
DELAY ENDP

TEXT          DB '6a6kin, cyberforum.ru','$'
T             DW 0
TMP           DW 0
BUFF          DB 64000 DUP (?)

END MAIN