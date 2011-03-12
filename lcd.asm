; lcd test code for JHD 162a
; Author :- Ankur Shrivastava
; License : GPLv3

; RS - > set it to port pin connected to RS pin of LCD
; R/W -> set it to port pin connected to R/W pin of LCD
; E -> set it to port pin connected to E pin of LCD
; DAT -> set it to port connected to Data pins of LCD

RS EQU P1.2
RW EQU P1.3
E EQU P1.4
DAT EQU P2


delay2:
mov r3, #0fh ; loop
D_here: mov r4, #0ffh ; nested loop
D_here2: djnz r4, D_here2 ; decrement and jump
djnz r3, D_here ; decrement and jump
ret


; * some functions to be used for LCD *

; we call delay to give delay for lcd to read data properly
; here value in 0ffH which is large but works!!!
delay:
mov r3, #050h ; loop
here: mov r4, #0ffh ; nested loop
here2: djnz r4, here2 ; decrement and jump
djnz r3, here ; decrement and jump
ret

; sends command to LCD
; command to be send should be placed in A
lcd_cmd:
MOV DAT, A ; send command to data port
clr RS ; for command
clr RW ; for write
setb E ; enable
acall delay ; delay for pulse
clr E ; high-to-low pulse pulse
acall delay ; some time for lcd
ret

; sends data to LCD
; data (single ASCII value) to be sent must be placed in A
lcd_send_char:
MOV DAT, A ; data to be send
setb RS ; for data
clr RW ; for write
setb E ; enable
acall delay ; call delay
clr E ; h-l pulse
acall delay ; some time for lcd
ret

; clears the lcd
lcd_clear:
mov A, #01H ; command for LCD clear
acall lcd_cmd ; send the command
ret

; init the LCD by setting the mode
lcd_init:
MOV A, #38H ; select 3x7 mode for LCD
acall lcd_cmd
MOV A, #0EH ; display on , cursor on
acall lcd_cmd
MOV A, #06h ; entry mode
acall lcd_cmd
MOV A, #42H
acall lcd_cmd
MOV A, #02H ; reset screen
acall lcd_cmd
acall lcd_clear ; clear the LCD
ret

; set line 1 as position for new char(s)
lcd_set_line1:
mov A, #80H ; line 1 starts at 0x80
acall lcd_cmd
ret

; set line 2 as position for new char(s)
lcd_set_line2:
mov A, #0c0H ; line 2 starts at 0xC0
acall lcd_cmd
ret

; sends string data to lcd
; string should be null terminated and not longer then 16
; DPTR should be initialised to first char of string
; uses R7 for holding chars, value of R7 is set to number of chars printed
lcd_send_string:
MOV R7, #00H ; clear R7
CLR A ; clear A
clr p1.0 ; for busy light on
lcd_send_string_next:
MOV A, R7 ; move value of R7 to A
MOVC A, @A+DPTR ; move data from address to A
JZ lcd_send_string_fin ; if A is zero we have null char, finish the function
acall lcd_send_char ; if A not zero write it to LCD
inc R7 ; increment R7
ajmp lcd_send_string_next ; take next char
lcd_send_string_fin:
setb p1.0 ; for busy light off
ret ; done return control

; * all functions end *

main:
acall lcd_init ; initialize the lcd
MOV A, #'A'
acall lcd_send_char ; send char out to LCD
MOV A, #'N'
acall lcd_send_char ; send char out to LCD
MOV A, #'K'
acall lcd_send_char ; send char out to LCD
MOV A, #'U'
acall lcd_send_char ; send char out to LCD
MOV A, #'R'
acall lcd_send_char ; send char out to LCD

abc: sjmp abc ; busy waiting

