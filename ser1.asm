; Embedded Systems Mini Project 
; Project : Network Based Home Automation and Security
; Members : Ankur Shrivastava
;	    Prashant Raghav
;	    Disha Agrawal
;	    Kanika Singh
;
; Details -> this is the assembly code for 8051
;	this code recieves serial data (UART) from a computer
;	and responds accordingly by enabling/disabling ports, sending 
;	port status.
; 
; Protocol ->
;	*recieved by 8051* 	|	*action taken*
;				|
;	0x1z			|	sets all the bits set in z
;				|
;	0x2z			|	clears all the bits set in z
;				|
;	0xff			|	set whole port 0
;				|
;	0xez			|	return status of bits set in z
;				|
;	0x00			|	clear whole port 0
;				|

	org	0		; for reset
	ajmp	main		; jump to main code

	org	23h		; for serial interrupt
	ajmp	int_s		; jump to serial interrupt handler code

	org	30h		; for main code
welcome_msg1:	db	'Welcome TO NBHA', 0
welcome_msg2:	db	'     N.B.H.A ', 0
msg_a_l_on:	db	'All Lights ON', 0
msg_a_l_off:	db	'All Lights OFF', 0
msg_1_l_on:	db	'Light 1 ON', 0
msg_1_l_off:	db	'Light 1 OFF', 0
msg_2_l_on:	db	'Light 2 ON', 0
msg_2_l_off:	db	'Light 2 OFF', 0
msg_3_l_on:	db	'Light 3 ON', 0
msg_3_l_off:	db	'Light 3 OFF', 0
msg_4_l_on:	db	'Light 4 ON', 0
msg_4_l_off:	db	'Light 4 OFF', 0

main:
	acall	lcd_init	; initialize the lcd
	MOV	DPTR, #welcome_msg1	; set welcome message 1
	acall	lcd_send_string	; display welcome message 1
	acall	lcd_set_line2	; move to line 2
	MOV	DPTR, #welcome_msg2	;  set welcome message 2
	acall	lcd_send_string	; display welcome message 2
	acall	lcd_set_line1	; move back to line 1
	; other initialization
	mov	tmod, #20h	; set timer1 in mode 2
	mov	scon, #50h	; set serial communication mode 1
	mov	ie, #10010000b	; just enable serial interrupt
	mov	th1, #0FAH	; set timer to over flow after 6 inc for baud of 4800
	setb	tr1		; start timer1

prg_end:
	ajmp	prg_end		; busy waiting for interrupt

int_s:
;	cpl	p1.0		; compliment p1.0 for info of received data
	mov	a, sbuf		; copy data to Acc
	mov	r2, a		; copy data to R2 for future use
	cjne	r2, #0ffH, check_on	; check if we need to set all the bits or not
	mov	p0, #0ffh	; set all bits
	acall	lcd_clear
	MOV	DPTR, #msg_a_l_on	;  move pointer for message
	acall	lcd_send_string	; display the message
	ajmp	int_s_end	; return from iterrupt
check_on:
	cjne	r2, #00h, check_done	; check if  we need to clear all the bits
	mov	p0, #00h	; clear all bits
	acall	lcd_clear
	MOV	DPTR, #msg_a_l_off	;  move pointer for message
	acall	lcd_send_string	; display the message
	ajmp	int_s_end	; return from iterrupt
check_done:
	anl	a, #0f0h	; and with f0h as we want to check for the first 4 bits

; handel all the other instructions

; handel all the status requests
	cjne	a, #0e0h, for1	; if we recieve a status request (0xEa)
	mov	a, r2		; restore a
	jb	acc.0, ret_stat_0	; return port0.0's status
	jb	acc.1, ret_stat_1	; return port0.1's status
	jb	acc.2, ret_stat_2	; return port0.2's status
	jb	acc.3, ret_stat_3	; return port0.3's status
	ajmp	int_s_end	; just finish this interrupt
; return port status from here
ret_stat_0:			;  code for returning status of p0.0
	jnb	p0.0, stat_0_0	; check value
	mov	sbuf, #0ffh	; return  1
	ajmp	int_s_end	; go back and return 
stat_0_0:
	mov	sbuf, #00h	; return  0
	ajmp	int_s_end	; go back and return 

ret_stat_1:			;  code for returning status of p0.1
	jnb	p0.1, stat_0_1	; check value
	mov	sbuf, #0ffh	; return  1
	ajmp	int_s_end	; go back and return 
stat_0_1:
	mov	sbuf, #00h	; return  0
	ajmp	int_s_end	; go back and return 

ret_stat_2:			;  code for returning status of p0.2
	jnb	p0.2, stat_0_2	; check value
	mov	sbuf, #0ffh	; return  1
	ajmp	int_s_end	; go back and return 
stat_0_2:
	mov	sbuf, #00h	; return  0
	ajmp	int_s_end	; go back and return 

ret_stat_3:			;  code for returning status of p0.3
	jnb	p0.3, stat_0_3	; check value
	mov	sbuf, #0ffh	; return  1
	ajmp	int_s_end	; go back and return 
stat_0_3:
	mov	sbuf, #00h	; return  0
	ajmp	int_s_end	; go back and return 

; handelling all switch on requests
for1:
	cjne	a, #010h, for2	; if we recieve a switch on request (0x10)
	mov	a, r2		; restore a
	jnb	acc.0, f_s_on_0	; switch on port0.0
	setb	p0.0		; set value
	acall	lcd_clear
	MOV	DPTR, #msg_1_l_on	;  move pointer for message
	acall	lcd_send_string	; display the message
f_s_on_0:
	jnb	acc.1, f_s_on_1	; switch on port0.1
	setb	p0.1		; set value
	acall	lcd_clear
	MOV	DPTR, #msg_2_l_on	;  move pointer for message
	acall	lcd_send_string	; display the message
f_s_on_1:
	jnb	acc.2, f_s_on_2	; switch on port0.2
	setb	p0.2		; set value
	acall	lcd_clear
	MOV	DPTR, #msg_3_l_on	;  move pointer for message
	acall	lcd_send_string	; display the message
f_s_on_2:
	jnb	acc.3, f_s_on_3	; switch on port0.3
	setb	p0.3		; set value
	acall	lcd_clear
	MOV	DPTR, #msg_4_l_on	;  move pointer for message
	acall	lcd_send_string	; display the message
f_s_on_3:
	ajmp	int_s_end	; just finish this interrupt

; handelling all switch off request	
for2:
	cjne	a, #20h, for3	; if we recieve a switch off request (0x2a)
	mov	a, r2		; restore a
	jnb	acc.0, f_s_off_0	; switch on port0.0
	clr	p0.0		; set value
	acall	lcd_clear
	MOV	DPTR, #msg_1_l_off	;  move pointer for message
	acall	lcd_send_string	; display the message
f_s_off_0:
	jnb	acc.1, f_s_off_1	; switch on port0.1
	clr	p0.1		; set value
	acall	lcd_clear
	MOV	DPTR, #msg_2_l_off	;  move pointer for message
	acall	lcd_send_string	; display the message
f_s_off_1:
	jnb	acc.2, f_s_off_2	; switch on port0.2
	clr	p0.2		; set value
	acall	lcd_clear
	MOV	DPTR, #msg_3_l_off	;  move pointer for message
	acall	lcd_send_string	; display the message
f_s_off_2:
	jnb	acc.3, f_s_off_3	; switch on port0.3
	clr	p0.3		; set value
	acall	lcd_clear
	MOV	DPTR, #msg_4_l_off	;  move pointer for message
	acall	lcd_send_string	; display the message
f_s_off_3:
	ajmp	int_s_end	; just finish this interrupt

; default request handler	
for3:
	mov	p0, R2		; copy arrived data to p0 for debug
int_s_end:
	clr	ti		; clear ti
	clr	ri		; clear ri
	reti			; return from interrupt


; FOR LCD

; RS - > set it to port pin connected to RS pin of LCD
; R/W -> set it to port pin connected to R/W pin of LCD
; E -> set it to port pin connected to E pin of LCD
; DAT -> set it to port connected to Data pins of LCD

RS	EQU	P1.2
RW	EQU	P1.3
E	EQU	P1.4
DAT	EQU	P2


delay2:
	mov	r3, #0fh	; loop
D_here:	mov	r4, #0ffh	; nested loop
D_here2:	djnz	r4, D_here2	; decrement and jump
	djnz	r3, D_here	; decrement and jump
	ret


; * some functions to be used for LCD *

; we call delay to give delay for lcd to read data properly
; here value in 0ffH which is large but works!!!
delay:
	mov	r3, #050h	; loop
here:	mov	r4, #0ffh	; nested loop
here2:	djnz	r4, here2	; decrement and jump
	djnz	r3, here	; decrement and jump
	ret

; sends command to LCD
; command to be send should be placed in A
lcd_cmd:
	MOV	DAT, A		; send command to data port
	clr	RS		; for command
	clr	RW		; for write
	setb	E		; enable
	acall	delay		; delay for pulse
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
	acall	delay		; call delay
	clr	E		; h-l pulse
	acall	delay		; some time for lcd
	ret

; clears the lcd
lcd_clear:
	mov	A, #01H		; command for LCD clear
	acall	lcd_cmd		; send the command
	ret

; init the LCD by setting the mode
lcd_init:
	MOV	A, #38H		; select 3x7 mode for LCD
	acall	lcd_cmd
	MOV	A, #0EH		; display on , cursor on
	acall	lcd_cmd
	MOV	A, #06h		; entry mode
	acall	lcd_cmd
	MOV	A, #42H
	acall	lcd_cmd
	MOV	A, #02H		; reset screen
	acall	lcd_cmd
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