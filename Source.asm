extrn ExitProcess :proc,	;Импортируем все необходимые функции
	  GetStdHandle :proc,
	  WriteConsoleA :proc,
	  ReadConsoleA :proc,
	  lstrlenA :proc

STACKALLOC macro arg		;макрос для выравнивания стека
  push R15
  mov R15, RSP
  sub RSP, 8*4
  if arg
    sub RSP, 8*arg
  endif
  and SPL, 0F0h
endm

STACKFREE macro				;Парный макрос для STACKALLOC. Освобождает выделенную память.
  mov RSP, R15
  pop R15
endm

NULL_FIFTH_ARG macro arg	;Полезный макрос для установки пятого аргумента в нуль
  mov qword ptr [RSP + 32], 0
endm

STD_OUTPUT_HANDLE equ -11	;Делаем макрозамены
STD_INPUT_HANDLE equ -10


.data
hStdInput dq ?, 0				;неопределенные qword-значения для дескрипторов ввода и вывода.
hStdOutput dq ?, 0
amt db 'a = ', 0				;Переменные, содержащие строки пользовательского интерфейса
bmt db 'b = ', 0
cmt db 'F = ', 0
inv db 0Ah, 'Invalid character', 0
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

ReadString proc uses RBX RCX RDX R8 R9 R11
	local readStr[64]	:byte,	;Введем локальные переменные: readStr[64] - строка, в которую будут занесены считанные символы
		  bytesRead		:dword	; bytesRead - число прочитанных символов.
	STACKALLOC 1				;Выделим место в стеке под регистры ReadConsoleA и ещё под один qword
	mov RCX, hStdInput			;Разместим все необходимые аргументы для вызова ReadConsoleA. lpInputControl (пятый аргумент) установим в 0.
	lea RDX, readStr
	mov R8, 64
	lea R9, bytesRead
	NULL_FIFTH_ARG
	call ReadConsoleA			;Вызовем ReadConsoleA
								;Теперь начнем вычисление длины строки.
	xor RCX, RCX				;Сбросим RCX.
	mov ECX, bytesRead			;Переместим в ECX число прочитанных байт.
	sub RCX, 2					;Вычтем из него 2: избавимся от символов переноса строки и возврата каретки.
	mov readStr[RCX], 0			;Сделаем строку нуль-терминированной: в конце допишем 0
	xor RBX, RBX				;Сбросим RBX
	mov R8, 1					;В R8 занесем 1
	met_str:					;Определим метку прохода по строке.
	dec RCX						;Уменьшим RCX на 1.
	cmp RCX, -1					;Если RCX стал равен -1, то перейдем на метку scanningComplete
	je scanningComplete
	xor RAX, RAX				;Иначе установим RAX в 0 и будем хранить там очередную цифру.
	mov AL, readStr[RCX]		;В AL поместим очередной символ
	cmp AL, '-'					;Если он равен '-', то перейдем на метку scanningComplete2
	je scanningComplete2
	eval:						;Иначе перейдем на метку eval.
	cmp AL, 30h					;проверим, является ли символ десятичной цифрой
	jl error					;Если нет, то перейдем на метку error
	cmp AL, 39h
	jg error
	sub RAX, 30h				;Иначе получим число из кода символа 
	mul R8
	add RBX, RAX				;и прибавим его к RBX.
	mov RAX, 10
	mul R8
	mov R8, RAX					;увеличим R8 в 10 раз
	jmp met_str					;Затем перейдем на метку прохода по строке.
	error:						;метка для ошибок
	mov R10, 0					;занесем в R10 0 
	STACKFREE					;очистим стек и выйдем
	ret
	scanningComplete2:			;если встретили '-'
	cmp RCX, 0					;проверяем был ли он впереди числа
	jne error					;Если был где-то в другом месте переходим в метку error
	neg RBX						;Иначе меняем знак числа в RBX
	scanningComplete:			;Если дошли до конца числа
	mov R10, 1					;занесем в R10 1
	mov RAX, RBX				;в RAX поместим значение RBX
	STACKFREE					;очистим стек и выйдем
	ret
ReadString endp

PrintDigit proc uses RAX RCX RDX R8 R9 R10 R11, digit: qword
	local numberStr[22] :byte	;Введем локальную байтовую переменную numberStr размером 22 байта
	xor R8, R8					;Обнулим регистр-счетчик для строки, пусть это будет R8.
	mov RAX, digit				;Занесем в RAX аргумент функции
	btc digit, 63				;Выясним, является ли это число положительным или отрицательным.
	jnc met						;Если число неотрицательное, пропустим эти шаги и перейдем к выводу.
	mov numberStr[R8], '-'		;Если число отрицательное, то первым символом должен стать '-'.
	inc R8						;Увеличим R8 на 1
	neg RAX						;для упрощения работы нужно сделать это число положительным
	met:
	mov RBX, 10					;Занесем в RBX 10 для осуществления деления.
	xor RCX, RCX				;Сбросим значение RCX для записи длины строки.
	division:					;Создадим метку для деления
	xor RDX, RDX				;сбросим RDX
	div RBX						;Разделим RAX на RBX
	add RDX, 30h				;Добавим к остатку код символа '0'.
	push RDX					;Поместим остаток в стек
	inc RCX						;увеличим RCX.
	cmp RAX, 0					;Проверим, если RAX стал нулем, то мы закончили деление
	jne division				;Иначе перейдем на метку деления.
	met_stack:					;метка для переноса из стека в переменную
	pop RDX						;переместим в регистр символ цифры из стека
	mov numberStr[R8], DL		;возьмем его младшую часть (DL) и занесем ее со смещением, указанным в R8 (прямой счетчик) в переменную numberStr.
	inc R8
	loop met_stack				;Повторим эти действия, пока RCX не станет нулем, после каждой итерации увеличивая значение R8.
	mov numberStr[R8], 0		;В конце строки необходимо поставим нуль-терминатор
	lea RAX, numberStr			;Занесем адрес начала строки в регистр RAX, затем занесем его в стек.
	push RAX
	call PrintString			;Вызовем процедуру для вывода строки.
	ret 8						;Вернемся в место вызова, очищая стек от одного аргумента
PrintDigit endp

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
	STACKFREE					;Освободим стек и вернемся в место вызова
	ret
WaitEnter endp


Start proc
	STACKALLOC					;Выделим место в стеке под аргументы по соглашению __fastcall
	mov RCX, STD_OUTPUT_HANDLE	;Установим номер потока ввода как первый аргумент функции
	call GetStdHandle			;Вызовем GetStdHandle (возвращаемое значение окажется в RAX).
	mov hStdOutput, RAX			;Переместим значение дескриптора в переменную hStdOutput.
	mov RCX, STD_INPUT_HANDLE	;Повторим для потока ввода и hStdInput.
	call GetStdHandle
	mov hStdInput, RAX
	lea RAX, amt				;Передача параметра через стек
	push RAX
	call PrintString			;Выведем строку 'a = ' с помощью нашей процедуры
	call ReadString				;Прочтем число при помощи нашей процедуры.
	cmp R10, 0					;Проверим R10.
	je met_end2					;Если значение регистра равно нулю, то покажем сообщение о неправильном символе и перейдем на выход.
	cmp RAX, -128				;проверка на диапазон
	jl met_end2
	cmp RAX, 127				;проверка на диапазон
	jg met_end2					
	xor R8, R8					;обнуляем R8
	sub R8, RAX					;вычитаем число из R8.
	lea RAX, bmt				;Передача параметра через стек
	push RAX
	call PrintString			;Выведем строку 'b = ' с помощью нашей процедуры
	call ReadString				;Прочтем число при помощи нашей процедуры.
	cmp R10, 0					;Проверим R10.
	je met_end2					;Если значение регистра равно нулю, то покажем сообщение о неправильном символе и перейдем на выход.
	cmp RAX, -32768				;проверка на диапазон
	jl met_end2
	cmp RAX, 32767				;проверка на диапазон
	jg met_end2
	add R8, RAX					;прибавляем число к R8.
	lea RAX, cmt				;Передача параметра через стек
	push RAX
	call PrintString			;Выведем строку 'F = ' с помощью нашей процедуры
	mov RAX, R8					;переместим число в RAX
	sub RAX, 1357h				;добавляем 12h - 1369h
	push RAX					;Передача параметра через стек
	call PrintDigit				;Выведем результат
	jmp met_end					;переход на метку конца без вывода об ошибки
	met_end2:					;завершение программы из-за ошибки
	lea RAX, inv				;Передача параметра через стек
	push RAX
	call PrintString			;Выведем сообщение об ошибке
	met_end:					;метка конца программы
	call WaitEnter				;процедура ожидания нажатия клавиши

	call ExitProcess			;завершить программу


Start endp
end