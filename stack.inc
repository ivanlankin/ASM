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
