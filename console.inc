include stack.inc

extrn GetStdHandle :proc,
	  WriteConsoleA :proc,
	  ReadConsoleA :proc,
	  lstrlenA :proc

STD_OUTPUT_HANDLE equ -11	;Делаем макрозамены
STD_INPUT_HANDLE equ -10

.data
hStdInput dq ?				;неопределенные qword-значения для дескрипторов ввода и вывода.
hStdOutput dq ?
emt db 0Ah, 'Press any key to exit...', 0

.code
PrintString proc uses RAX RCX RDX R8 R9, string: qword
	local bytesWritten :qword	;Введем локальную переменную bytesWritten для аргумента lpNumberOfCharsWritten функции записи
	STACKALLOC 1				;Выделим место в стеке под 4 регистра WriteConsoleA и ещё под один qword для пятого аргумента
	mov RCX, string				;Поместим в регистр первого аргумента указатель на выводимую строку
	call lstrlenA				;и получим ее длину при помощи вызова lstrlenA.
	mov RCX, hStdOutput			;Поместим все необходимые аргументы в соответствующие регистры.
	mov RDX, string
	mov R8, RAX
	lea R9, bytesWritten
	NULL_FIFTH_ARG
	call WriteConsoleA			;Вызовем WriteConsoleA.
	STACKFREE					;Освободим стек
	ret 8						;Вернемся в основную программу, очищая стек от одного аргумента
PrintString endp

WaitEnter proc uses RAX RCX RDX R8 R9 R10 R11
	local	readStr		:byte,	;Введем локальные переменные: readStr и bytesRead размером байт и двойное слово соответственно.
			bytesRead	:dword
	STACKALLOC 1				;Выровняем стек
	mov RCX, hStdOutput			;Передадим в регистры все необходимы параметры для вывода сообщения 'Press any key to exit...'.
	lea RDX, emt
	mov R8, 24
	lea R9, bytesRead
	NULL_FIFTH_ARG
	call WriteConsoleA			;Вызовем WriteConsoleA.
	mov RCX, hStdInput			;Установим значения всех аргументов для вызова ReadConsoleA
	lea RDX, readStr
	mov R8, 1
	lea R9, bytesRead
	NULL_FIFTH_ARG
	call ReadConsoleA			;Вызовем данную функцию.
	STACKFREE					;Освободим стек и закроем программу
	
	ret 8
WaitEnter endp

InitConsole proc uses RAX RCX RDX R8 R9 R10 R11
	STACKALLOC					;Выделим место в стеке под аргументы по соглашению __fastcall
	mov RCX, STD_OUTPUT_HANDLE	;Установим номер потока ввода как первый аргумент функции
	call GetStdHandle			;Вызовем GetStdHandle (возвращаемое значение окажется в RAX).
	mov hStdOutput, RAX			;Переместим значение дескриптора в переменную hStdOutput.
	mov RCX, STD_INPUT_HANDLE	;Повторим для потока ввода и hStdInput.
	call GetStdHandle
	mov hStdInput, RAX
	STACKFREE
	ret
InitConsole endp
