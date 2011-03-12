	org	0
	ajmp	main

	org	23h
	ajmp	int_s

; FOR LCD

; RS - > set it to port pin connected to RS pin of LCD
; R/W -> set it to port pin connected to R/W pin of LCD
; E -> set it to port pin connected to E pin of LCD
; DAT -> set it to port connected to Data pins of LCD

; for LCD
RS	EQU	P1.2
RW	EQU	P1.3
E	EQU	P1.4
DAT	EQU	P2

; for buttons
B1 EQU p1.7
B2 EQU p1.6
B3 EQU p1.5


delay2:
	mov	r4, #040h	; nested loop
D_here2:	djnz	r4, D_here2	; decrement and jump
	ret


delay_button:
	mov	r3, #0ffh	; loop
here_button:	mov	r4, #0ffh	; nested loop
here2_button:	djnz	r4, here2_button	; decrement and jump
	djnz	r3, here_button	; decrement and jump
	ret


; * some functions to be used for LCD *
	
; we call delay to give delay for lcd to read data properly
; here value in 0ffH which is large but works!!!
delay:
	mov	r3, #010h	; loop
here:	mov	r4, #0ffh	; nested loop
here2:	djnz	r4, here2	; decrement and jump
	djnz	r3, here	; decrement and jump
	ret

delay_init:
	mov	r3, #030h	; loop
here_init:	mov	r4, #0ffh	; nested loop
here2_init:	djnz	r4, here2_init	; decrement and jump
	djnz	r3, here_init	; decrement and jump
	ret

; sends command to LCD for init
; command to be send should be placed in A
lcd_cmd_init:
	MOV	DAT, A		; send command to data port
	clr	RS		; for command
	clr	RW		; for write
	setb	E		; enable
	clr	E		; high-to-low pulse pulse
	acall	delay_init		; some time for lcd
	ret

; sends command to LCD
; command to be send should be placed in A
lcd_cmd:
	MOV	DAT, A		; send command to data port
	clr	RS		; for command
	clr	RW		; for write
	setb	E		; enable
	clr	E		; high-to-low pulse pulse
	acall	delay		; some time for lcd
	ret

; sends data to LCD
; data (single ASCII value) to be sent must be placed in A
lcd_send_char:
	MOV	DAT, A		; data to be send
	setb	RS		; for data
	clr	RW		; for write
	setb	E		; enable
	clr	E		; h-l pulse
	acall	delay2		; some time for lcd
	ret

; clears the lcd
lcd_clear:
	mov	A, #01H		; command for LCD clear
	acall	lcd_cmd		; send the command
	ret

; init the LCD by setting the mode
lcd_init:
	MOV	A, #38H		; select 3x7 mode for LCD
	acall	lcd_cmd_init
	MOV	A, #0EH		; display on , cursor on
	acall	lcd_cmd_init
	MOV	A, #06h		; entry mode
	acall	lcd_cmd_init
	MOV	A, #42H
	acall	lcd_cmd
	MOV	A, #02H		; reset screen
	acall	lcd_cmd_init
	acall	lcd_clear	; clear the LCD
	ret

; set line 1 as position for new char(s)
lcd_set_line1:
	mov	A, #80H		; line 1 starts at 0x80
	acall	lcd_cmd
	ret

; set line 2 as position for new char(s)
lcd_set_line2:
	mov	A, #0c0H	; line 2 starts at 0xC0
	acall	lcd_cmd
	ret

; sends string data to lcd
; string should be null terminated and not longer then 16
; DPTR should be initialised to first char of string
; uses R7 for holding chars, value of R7 is set to number of chars printed
lcd_send_string:
	MOV	R7, #00H	; clear R7
	CLR	A		; clear A
	clr	p1.0		; for busy light on
lcd_send_string_next:
	MOV	A, R7		; move value of R7 to A
	MOVC	A, @A+DPTR	; move data from address to A
	JZ	lcd_send_string_fin	; if A is zero we have null char, finish the function
	acall	lcd_send_char	; if A not zero write it to LCD
	inc	R7		; increment R7
	ajmp	lcd_send_string_next	; take next char
lcd_send_string_fin:
	setb	p1.0		; for busy light off
	ret			; done return control

; * all functions end *	

msg: db 'Ready To Rock!!!',0

main:
; main here
mov	tmod, #20h	; set timer1 in mode 2
	mov	scon, #50h	; set serial communication mode 1
	mov	ie, #10010000b	; just enable serial interrupt
	mov	th1, #0FDH	; set timer to over flow after 3 inc for baud of 9600
	; set pcon.7 to 1 to doulbe baud rate to 19200
	mov a, pcon	; move pcon to Acc
	setb acc.7	; set Acc.7
	mov pcon,a	; move back A to Pcon 
	setb	tr1		; start timer1
acall lcd_init
MOV DPTR,#msg
acall lcd_send_string

abc:	
setb B1
setb B2
setb B3
acall delay_button ; for delay b/w button presses
jnb B1, event_b1
jnb B2, event_b2
jnb B3, event_b3
sjmp	abc

event_b1: ; handels button 1 press event
	mov SBUF,#20h
	acall delay_button
	sjmp abc ; jump back

event_b2: ; handels button 2 press event
	mov SBUF,#30h
	acall delay_button	
	sjmp abc ; jump back

event_b3: ; handels button 3 press event
	mov SBUF,#40h
	acall delay_button	
	sjmp abc ; jump back	


int_s:				; serial interrupt
	jb ti,int_s_fin
	cpl p1.0	; for debug
	mov	a, sbuf		; copy data to Acc
	mov	r2, a		; copy data to R2 for future use
	cjne A, #00H, for1
	acall lcd_clear
	sjmp int_s_end
for1:
	cjne A,#0ffH, for_l
	acall lcd_init
	MOV DPTR,#msg
acall lcd_send_string
	sjmp int_s_end
for_l:
	acall lcd_send_char
int_s_end:
	MOV sbuf,#0ffH
int_s_fin:
	clr	ti		; clear ti
	clr	ri		; clear ri
	reti			; return from interrupt

end	