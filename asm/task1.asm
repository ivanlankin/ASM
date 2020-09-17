stak segment stack 'stack'      ;Начало сегмента стека
db 256 dup (?)                  ;Резервируем 256 байт для стека
stak ends                       ;Конец сегмента стека
data segment 'data'             ;Начало сегмента данных
Hello db 'Lankin Ivan 251$'     ;Строка для вывода
data ends                       ;Конец сегмента данных
code segment 'code'             ;Начало сегмента кода
assume CS:code,DS:data,SS:stak  ;Сегментный регистр CS будет указывать на сегмент команд,
                                ;регистр DS - на сегмент данных, SS – на стек
start:                          ;Точка входа в программу start
;Обязательная инициализация регистра DS в начале программы
mov AX,data                     ;Адрес сегмента данных сначала загрузим в AX,
mov DS,AX                       ;а затем перенесем из AX в DS
mov AH,09h                      ;Функция DOS 9h вывода на экран
mov DX,offset Hello             ;Адрес начала строки 'Hello, World!' записывается в регистр DX
int 21h                         ;Вызов функции DOS
mov AX,4C00h                    ;Функция 4Ch завершения программы с кодом возврата 0
int 21h                         ;Вызов функции DOS
code ends                       ;Конец сегмента кода
end start                       ;Конец текста программы с точкой входа