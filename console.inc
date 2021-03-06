include stack.inc

extrn GetStdHandle :proc,
	  WriteConsoleA :proc,
	  ReadConsoleA :proc,
	  lstrlenA :proc

STD_OUTPUT_HANDLE equ -11	;������ �����������
STD_INPUT_HANDLE equ -10

.data
hStdInput dq ?				;�������������� qword-�������� ��� ������������ ����� � ������.
hStdOutput dq ?
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
	STACKFREE					;��������� ���� � ������� ���������
	
	ret 8
WaitEnter endp

InitConsole proc uses RAX RCX RDX R8 R9 R10 R11
	STACKALLOC					;������� ����� � ����� ��� ��������� �� ���������� __fastcall
	mov RCX, STD_OUTPUT_HANDLE	;��������� ����� ������ ����� ��� ������ �������� �������
	call GetStdHandle			;������� GetStdHandle (������������ �������� �������� � RAX).
	mov hStdOutput, RAX			;���������� �������� ����������� � ���������� hStdOutput.
	mov RCX, STD_INPUT_HANDLE	;�������� ��� ������ ����� � hStdInput.
	call GetStdHandle
	mov hStdInput, RAX
	STACKFREE
	ret
InitConsole endp
