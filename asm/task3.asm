.model tiny               ;Модель памяти TINY, в которой код, данные и стек
                          ;размещаются в одном и том же сегменте размером до 64Кб
.code                     ;Начало сегмента кода
org 100h                  ;Устанавливает значение программного счетчика в 100h
                          ;Начало необходимое для COM-программы,
                          ;которая загружается в память с адреса PSP:100h

start:
mov AH,09h
mov DX,offset Hello
int 21h
mov AX,4C00h
int 21h
;===== Data =====
Hello db 'Lankin Ivan 251$'
end start