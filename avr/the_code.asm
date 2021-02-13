.DEVICE attiny85
.equ PowerReductionRegister = 0x20;
.equ CLKPR = 0x26; clock prescaler
.equ PINB  = 0x16;
.equ DDRB  = 0x17;
.equ PORTB = 0x18;

.equ CLKPR_DIV_1   = 0x00;
.equ CLKPR_DIV_2 = 0b00000001;
.equ CLKPR_DIV_4 = 0b00000010;
.equ CLKPR_DIV_8 = 0b00000100;
.equ CLKPR_DIV_32  = 0b00000101;
.equ CLKPR_DIV_256 = 0b00001000;

.equ PIN_SER        = 0b00000001; shared serial pin for both shift registers
.equ PIN_SHARED     = 0b00000010;
.equ PIN_CLK        = 0b00000100; clock pin for top shift register
.equ PIN_BRIGHTNESS       = 0b00001000;
.equ PIN_POWER            = 0b00010000;

.def cache = r16;
.def Oned_Reg = r17;
.def portb_parody = r18;
.def shift_parody = r19;
.def tmp          = r22;
.def cache2       = r23;
.def MAT_BRIGHTNESS = r24; matrix brightness value
.def cathode_parody = r25;
.def double_cache_b0   = r30; 16 bit cache byte 0
.def double_cache_b1   = r31; 16 bit cache byte 1
.macro Scale_Clock
	Load CLKPR, 0b10000000;
	Load CLKPR, @0
.endmacro

.macro Load
	ldi cache, @1
	out @0, cache;
.endmacro

.macro Simple_Delay; @0: number of cycles/4 -1
	ldi cache2, @0;
	for3:
		dec cache2;
		breq endfor3;
		rjmp for3;
	endfor3:
.endmacro

.macro Raster_Line; @0: register byte
	Load PORTB, 0x00;
	mov shift_parody, @0;
	ldi cache2, 8;

	for:
		dec cache2;
		;cpi cache2, 0x00;
		breq endfor;
		
		mov cache, shift_parody;
		andi cache, PIN_SER;
		out PORTB, cache;
		ori cache, PIN_CLK;
		out PORTB, cache;
		lsr shift_parody;

		rjmp for;
	endfor:
		lsl cathode_parody;
		breq reload;
		Load PORTB, 0x00;
		Load PORTB, PIN_SHARED; latch pin
		rjmp end;
	reload:
		ldi cathode_parody, 0x01;
		Load PORTB, PIN_SER;
		Load PORTB, PIN_SER | PIN_SHARED; latch pin
	end:

.endmacro

.macro Raster_Matrix
	;ldi cache2, 0xff;
	;eor tmp, cache2;
	;ldi tmp, 0b11010101;
	;Raster_Line tmp;
	;rjmp end2;
	ldi cathode_parody, 0x00;

	full_brightness:
		ldi double_cache_b0, 40;;low(FRAME_BUFFER_PTR);
		ldi double_cache_b1, 0x00;
		for2:
			inc double_cache_b0;
			cpi double_cache_b0, 40+8;low(FRAME_BUFFER_PTR)+8;
			breq endfor2;
			lpm tmp, Z;
			Raster_Line tmp;
			Scale_Clock CLKPR_DIV_256;
			Simple_Delay 10;
			Scale_Clock CLKPR_DIV_1;
			rjmp for2;
		endfor2:
			rjmp end2;
	end2:
		nop;
.endmacro

.org 20
FRAME_BUFFER_PTR: ; current displayed frame stored in program memory
	;.dw 0b1010101001010101;
	;.dw 0b1010101001010101;
	;.dw 0b1010101001010101;
	;.dw 0b1010101001010101;
	.dw 0xffff;
	.dw 0xffff;
	.dw 0xffff;
	.dw 0xffff;
	

.org 0
init:
	Load PowerReductionRegister, 0b00001111; turn things off
	Load DDRB,  0b00000111; output on port B
	ldi Oned_Reg, 0xff;
	ldi tmp, 0x01;
	ldi cache, 0xff;
	Scale_Clock CLKPR_DIV_4;
	rjmp loop;

.org 256
loop:
	Raster_Matrix;
	;inc portb_parody;
	;brvs state_change;

	rjmp loop;

state_change:
	ldi cache2, 0xff;
	eor tmp, cache2;
	Raster_Line tmp;
	rjmp loop;

	;lsl tmp;
	;cpi tmp, 0x00;
	;breq reload_shift;
	;Raster_Line tmp;
	;rjmp loop;

reload_shift:
	ldi tmp, 0x01;
	Raster_Line tmp;
	rjmp loop

.org 3500
FRAME_STORAGE_PTR: ; all of the frame storage
	.dw 0x0000; blah blah
