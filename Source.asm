extrn ExitProcess :proc,	;����������� ��� ����������� �������
	  GetStdHandle :proc,
	  WriteConsoleA :proc,
	  ReadConsoleA :proc,
	  lstrlenA :proc

STACKALLOC macro arg		;������ ��� ������������ �����
  push R15
  mov R15, RSP
  sub RSP, 8*4
  if arg
    sub RSP, 8*arg
  endif
  and SPL, 0F0h
endm

STACKFREE macro				;������ ������ ��� STACKALLOC. ����������� ���������� ������.
  mov RSP, R15
  pop R15
endm

NULL_FIFTH_ARG macro arg	;�������� ������ ��� ��������� ������ ��������� � ����
  mov qword ptr [RSP + 32], 0
endm

STD_OUTPUT_HANDLE equ -11	;������ �����������
STD_INPUT_HANDLE equ -10


.data
hStdInput dq ?, 0				;�������������� qword-�������� ��� ������������ ����� � ������.
hStdOutput dq ?, 0
amt db 'a = ', 0				;����������, ���������� ������ ����������������� ����������
bmt db 'b = ', 0
cmt db 'F = ', 0
inv db 0Ah, 'Invalid character', 0
emt db 0Ah, 'Press any key to exit...', 0


.code
PrintString proc uses RAX RCX RDX R8 R9, string: qword
	local bytesWritten :qword	;������ ��������� ���������� bytesWritten ��� ��������� lpNumberOfCharsWritten ������� ������
	STACKALLOC 1				;������� ����� � ����� ��� 4 �������� WriteConsoleA � ��� ��� ���� qword ��� ������ ���������
	mov RCX, string				;�������� � ������� ������� ��������� ��������� �� ��������� ������
	call lstrlenA				;� ������� �� ����� ��� ������ ������ lstrlenA.
	mov RCX, hStdOutput			;�������� ��� ����������� ��������� � ��������������� ��������.
	mov RDX, string
	mov R8, RAX
	lea R9, bytesWritten
	NULL_FIFTH_ARG
	call WriteConsoleA			;������� WriteConsoleA.
	STACKFREE					;��������� ����
	ret 8						;�������� � �������� ���������, ������ ���� �� ������ ���������
PrintString endp

ReadString proc uses RBX RCX RDX R8 R9 R11
	local readStr[64]	:byte,	;������ ��������� ����������: readStr[64] - ������, � ������� ����� �������� ��������� �������
		  bytesRead		:dword	; bytesRead - ����� ����������� ��������.
	STACKALLOC 1				;������� ����� � ����� ��� �������� ReadConsoleA � ��� ��� ���� qword
	mov RCX, hStdInput			;��������� ��� ����������� ��������� ��� ������ ReadConsoleA. lpInputControl (����� ��������) ��������� � 0.
	lea RDX, readStr
	mov R8, 64
	lea R9, bytesRead
	NULL_FIFTH_ARG
	call ReadConsoleA			;������� ReadConsoleA
								;������ ������ ���������� ����� ������.
	xor RCX, RCX				;������� RCX.
	mov ECX, bytesRead			;���������� � ECX ����� ����������� ����.
	sub RCX, 2					;������ �� ���� 2: ��������� �� �������� �������� ������ � �������� �������.
	mov readStr[RCX], 0			;������� ������ ����-���������������: � ����� ������� 0
	xor RBX, RBX				;������� RBX
	mov R8, 1					;� R8 ������� 1
	met_str:					;��������� ����� ������� �� ������.
	dec RCX						;�������� RCX �� 1.
	cmp RCX, -1					;���� RCX ���� ����� -1, �� �������� �� ����� scanningComplete
	je scanningComplete
	xor RAX, RAX				;����� ��������� RAX � 0 � ����� ������� ��� ��������� �����.
	mov AL, readStr[RCX]		;� AL �������� ��������� ������
	cmp AL, '-'					;���� �� ����� '-', �� �������� �� ����� scanningComplete2
	je scanningComplete2
	eval:						;����� �������� �� ����� eval.
	cmp AL, 30h					;��������, �������� �� ������ ���������� ������
	jl error					;���� ���, �� �������� �� ����� error
	cmp AL, 39h
	jg error
	sub RAX, 30h				;����� ������� ����� �� ���� ������� 
	mul R8
	add RBX, RAX				;� �������� ��� � RBX.
	mov RAX, 10
	mul R8
	mov R8, RAX					;�������� R8 � 10 ���
	jmp met_str					;����� �������� �� ����� ������� �� ������.
	error:						;����� ��� ������
	mov R10, 0					;������� � R10 0 
	STACKFREE					;������� ���� � ������
	ret
	scanningComplete2:			;���� ��������� '-'
	cmp RCX, 0					;��������� ��� �� �� ������� �����
	jne error					;���� ��� ���-�� � ������ ����� ��������� � ����� error
	neg RBX						;����� ������ ���� ����� � RBX
	scanningComplete:			;���� ����� �� ����� �����
	mov R10, 1					;������� � R10 1
	mov RAX, RBX				;� RAX �������� �������� RBX
	STACKFREE					;������� ���� � ������
	ret
ReadString endp

PrintDigit proc uses RAX RCX RDX R8 R9 R10 R11, digit: qword
	local numberStr[22] :byte	;������ ��������� �������� ���������� numberStr �������� 22 �����
	xor R8, R8					;������� �������-������� ��� ������, ����� ��� ����� R8.
	mov RAX, digit				;������� � RAX �������� �������
	btc digit, 63				;�������, �������� �� ��� ����� ������������� ��� �������������.
	jnc met						;���� ����� ���������������, ��������� ��� ���� � �������� � ������.
	mov numberStr[R8], '-'		;���� ����� �������������, �� ������ �������� ������ ����� '-'.
	inc R8						;�������� R8 �� 1
	neg RAX						;��� ��������� ������ ����� ������� ��� ����� �������������
	met:
	mov RBX, 10					;������� � RBX 10 ��� ������������� �������.
	xor RCX, RCX				;������� �������� RCX ��� ������ ����� ������.
	division:					;�������� ����� ��� �������
	xor RDX, RDX				;������� RDX
	div RBX						;�������� RAX �� RBX
	add RDX, 30h				;������� � ������� ��� ������� '0'.
	push RDX					;�������� ������� � ����
	inc RCX						;�������� RCX.
	cmp RAX, 0					;��������, ���� RAX ���� �����, �� �� ��������� �������
	jne division				;����� �������� �� ����� �������.
	met_stack:					;����� ��� �������� �� ����� � ����������
	pop RDX						;���������� � ������� ������ ����� �� �����
	mov numberStr[R8], DL		;������� ��� ������� ����� (DL) � ������� �� �� ���������, ��������� � R8 (������ �������) � ���������� numberStr.
	inc R8
	loop met_stack				;�������� ��� ��������, ���� RCX �� ������ �����, ����� ������ �������� ���������� �������� R8.
	mov numberStr[R8], 0		;� ����� ������ ���������� �������� ����-����������
	lea RAX, numberStr			;������� ����� ������ ������ � ������� RAX, ����� ������� ��� � ����.
	push RAX
	call PrintString			;������� ��������� ��� ������ ������.
	ret 8						;�������� � ����� ������, ������ ���� �� ������ ���������
PrintDigit endp

WaitEnter proc uses RAX RCX RDX R8 R9 R10 R11
	local	readStr		:byte,	;������ ��������� ����������: readStr � bytesRead �������� ���� � ������� ����� ��������������.
			bytesRead	:dword
	STACKALLOC 1				;��������� ����
	mov RCX, hStdOutput			;��������� � �������� ��� ���������� ��������� ��� ������ ��������� 'Press any key to exit...'.
	lea RDX, emt
	mov R8, 24
	lea R9, bytesRead
	NULL_FIFTH_ARG
	call WriteConsoleA			;������� WriteConsoleA.
	mov RCX, hStdInput			;��������� �������� ���� ���������� ��� ������ ReadConsoleA
	lea RDX, readStr
	mov R8, 1
	lea R9, bytesRead
	NULL_FIFTH_ARG
	call ReadConsoleA			;������� ������ �������.
	STACKFREE					;��������� ���� � �������� � ����� ������
	ret
WaitEnter endp


Start proc
	STACKALLOC					;������� ����� � ����� ��� ��������� �� ���������� __fastcall
	mov RCX, STD_OUTPUT_HANDLE	;��������� ����� ������ ����� ��� ������ �������� �������
	call GetStdHandle			;������� GetStdHandle (������������ �������� �������� � RAX).
	mov hStdOutput, RAX			;���������� �������� ����������� � ���������� hStdOutput.
	mov RCX, STD_INPUT_HANDLE	;�������� ��� ������ ����� � hStdInput.
	call GetStdHandle
	mov hStdInput, RAX
	lea RAX, amt				;�������� ��������� ����� ����
	push RAX
	call PrintString			;������� ������ 'a = ' � ������� ����� ���������
	call ReadString				;������� ����� ��� ������ ����� ���������.
	cmp R10, 0					;�������� R10.
	je met_end2					;���� �������� �������� ����� ����, �� ������� ��������� � ������������ ������� � �������� �� �����.
	cmp RAX, -128				;�������� �� ��������
	jl met_end2
	cmp RAX, 127				;�������� �� ��������
	jg met_end2					
	xor R8, R8					;�������� R8
	sub R8, RAX					;�������� ����� �� R8.
	lea RAX, bmt				;�������� ��������� ����� ����
	push RAX
	call PrintString			;������� ������ 'b = ' � ������� ����� ���������
	call ReadString				;������� ����� ��� ������ ����� ���������.
	cmp R10, 0					;�������� R10.
	je met_end2					;���� �������� �������� ����� ����, �� ������� ��������� � ������������ ������� � �������� �� �����.
	cmp RAX, -32768				;�������� �� ��������
	jl met_end2
	cmp RAX, 32767				;�������� �� ��������
	jg met_end2
	add R8, RAX					;���������� ����� � R8.
	lea RAX, cmt				;�������� ��������� ����� ����
	push RAX
	call PrintString			;������� ������ 'F = ' � ������� ����� ���������
	mov RAX, R8					;���������� ����� � RAX
	sub RAX, 1357h				;��������� 12h - 1369h
	push RAX					;�������� ��������� ����� ����
	call PrintDigit				;������� ���������
	jmp met_end					;������� �� ����� ����� ��� ������ �� ������
	met_end2:					;���������� ��������� ��-�� ������
	lea RAX, inv				;�������� ��������� ����� ����
	push RAX
	call PrintString			;������� ��������� �� ������
	met_end:					;����� ����� ���������
	call WaitEnter				;��������� �������� ������� �������

	call ExitProcess			;��������� ���������


Start endp
end