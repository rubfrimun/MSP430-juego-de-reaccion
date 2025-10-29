;--------------------------------------------------
; Frias Muñoz, Ruben
; Grupo: L3
;--------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
;--------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.
			.global lcdIni
			.global lcd2aseg
			.global lcdClearAll
			.global lcdClear
			.global lcdLPut

			.global Pintar
			.global lcdClearSW

DIG1 		.equ 	LCDM10
DIG1H		.equ 	LCDM11
DIG2 		.equ 	LCDM6
DIG2H		.equ 	LCDM7
DIG3 		.equ 	LCDM4
DIG3H		.equ 	LCDM5
DIG4 		.equ 	LCDM19
DIG4H		.equ 	LCDM20
DIG5 		.equ 	LCDM15
DIG5H		.equ 	LCDM16
DIG6 		.equ 	LCDM8
DIG6H		.equ 	LCDM9

;--------------------------------------------------
; void lcdIni (void)
;--------------------------------------------------
lcdIni	mov.w	#0xFFD0, &LCDCPCTL0
		mov.w	#0xFC3F, &LCDCPCTL1
		mov.w	#0x00F8, &LCDCPCTL2 	;Reloj=ACLK, Divisor=1, Predivisor=16, 4MUX, Low power
		mov.w	#LCDDIV_1 | LCDPRE__16 | LCD4MUX | LCDLP, &LCDCCTL0 ;VLCD=2'6 interno, V2-V5 interno, V5=0, charge pump con referencia interna
 		mov.w	#VLCD_1 | VLCDREF_0 | LCDCPEN, &LCDCVCTL         	;Habilitar sincronizaciÃ³n de reloj
 		mov.w	#LCDCPCLKSYNC, &LCDCCPCTL
 		mov.w	#LCDCLRM, &LCDCMEMCTL	;Borra memoria del LCD
		bis.w	#LCDON, &LCDCCTL0		;Encender LCD_C
		ret
;-------------------------------------------------------------------------------
; Subrutina de conversion ASCII a 14 sgm
;-------------------------------------------------------------------------------
lcd2aseg	sub.w #32, R12
		jlo   lcd2Err			;Por debajo de 32?
		cmp.w #127-32, R12 		;No, compara con 128
		jhs   lcd2Err			;Si esta por encima, fuera
		rla.w R12
		mov.w Tab14Seg(R12), R12;Direccion de memoria a r12
		jmp   lcdR13
lcd2Err	mov.w #-1, R12			;Pone a 0 el registro
lcdR13	sub.w #32, R13			;Esta por debajo?
		jlo   lcd2Err			;Si, fuera
		cmp.w #127-32, R13 		;No, mira si sale por arriba
		jhs   lcd2Er2			;Si es mayor, fuera
		rla.w R13
		mov.w Tab14Seg(R13), R13;Direccion de memoria a r12
		jmp   lcdFin
lcd2Er2	mov.w #-1, R13			;Registro a 0
lcdFin  ret
;--------------------------------------------------
;Borrar toda la pantalla
;--------------------------------------------------
lcdClearAll	bis.b #BIT1, &LCDCMEMCTL
			ret
;--------------------------------------------------
;Borrar digitos
;--------------------------------------------------
lcdClear	clr.b &LCDM10
			clr.b &LCDM11
			clr.b &LCDM6
			clr.b &LCDM7
			clr.b &LCDM4
			clr.b &LCDM5
			clr.b &LCDM19
			clr.b &LCDM20
			clr.b &LCDM15
			clr.b &LCDM16
			clr.b &LCDM8
			clr.b &LCDM9
			ret
;--------------------------------------------------
; Pone digitos
;--------------------------------------------------
Pintar	call  #lcd2aseg		;Llama lcd2seg
		cmp.w #-1, r12
		jeq   finPintar		;sale
		cmp.w #-1, r13
		jeq   finPintar		;sale
		cmp.w #1, r14
		jne   pinCent
;PintDer, pinta digito de la derecha
		mov.b r13, &DIG6	;Parte baja a digito 6
		and.b #101b, &DIG6H	;Mascara a bit 0 y 2 de parte alta
		swpb  r13
		add.b r13, &DIG6H   ;Suma parte baja con alta y la dejamos en la alta
		mov.b r12, &DIG5	;Parte baja
		and.b #101b, &DIG5H	;Mascara a bit 0 y 2 de parte alta
		swpb  r12
		add.b r12, &DIG5H   ;Suma parte alta y la deja en la alta
    	jmp   finPintar
pinCent	cmp.w #2, r14		;Pinta digitos del centro
		jne   pinIzq
		mov.b r13, &DIG4	;parte baja en parte baja de digito 6
		and.b #101b, &DIG4H	;Mascara a bit 0 y 2 de parte alta
		swpb  r13
		add.b r13, &DIG4H   ;Suma parte alta y la deja en la alta
		mov.b r12, &DIG3	;Parte baja
		and.b #101b, &DIG3H	;Mascara a bit 0 y 2 de parte alta
		swpb  r12
		add.b r12, &DIG3H   ;Suma parte alta y la deja en la alta
		jmp   finPintar
pinIzq	cmp.w #3, r14		;Pinta los digitos de la ziquierda
		jne   finPintar
		mov.b r13, &DIG2	;parte baja en parte baja de digito 6
		and.b #101b, &DIG2H	;Mascara a bit 0 y 2 de parte alta
		swpb  r13
		add.b r13, &DIG2H   ;Suma parte alta y la deja en la alta
		mov.b r12, &DIG1	;Parte baja
		and.b #101b, &DIG1H	;Mascara a bit 0 y 2 de parte alta
		swpb  r12
		add.b r12, &DIG1H   ;Suma parte alta y la deja en la alta
finPintar
		ret					;Sale

;--------------------------------------------------
; Borrar todo menos a5 y a6
;--------------------------------------------------
lcdClearSW
		clr.b &LCDM10
		clr.b &LCDM11
		clr.b &LCDM6
		clr.b &LCDM7
		clr.b &LCDM4
		clr.b &LCDM5
		clr.b &LCDM19
		clr.b &LCDM20
		ret
;--------------------------------------------------
; Escribe
;--------------------------------------------------
lcdLPut call  #lcd2aseg
		cmp.w #-1, r12		;Si no esta, fin
		jeq   SWfin
;Pasar digito 2 al 1
		mov.b &DIG2, &DIG1	;Muevo parte baja del digito 2 al 1
		mov.b &DIG2H, R11	;Guarda la parte alta del registro
		bic.b #101b, R11	;Mascara de parte alta
		and.b #101b, &DIG1H	;Digito a cero menos mascra
		add.b R11, &DIG1H
;Pasar digito 3 al 2
		mov.b &DIG3, &DIG2  ;Muevo parte baja del digito 3 al 2
		mov.b &DIG3H, R11   ;Guarda la parte alta del registro
		bic.b #101b, R11    ;Mascara de parte alta
		and.b #101b, &DIG2H	;Digito a cero menos mascra
		add.b R11, &DIG2H
;Pasar digito 4 al 3
		mov.b &DIG4, &DIG3  ;Muevo parte baja del digito 4 al 3
		mov.b &DIG4H, R11   ;Guarda la parte alta del registro
		bic.b #101b, R11    ;Mascara de parte alta
		and.b #101b, &DIG3H ;TDigito a cero menos mascara
		add.b R11, &DIG3H
;Pasar digito 5 al 4
		mov.b &DIG5, &DIG4  ;Muevo parte baja del digito 5 al 4
		mov.b &DIG5H, R11   ;Guarda la parte alta del registro
		bic.b #101b, R11    ;Mascara de parte alta
		and.b #101b, &DIG4H ;Digito a cero menos mascra
		add.b R11, &DIG4H
;Pasar digito 6 al 5
		mov.b &DIG6, &DIG5  ;Muevo parte baja del digito 6 al 5
		mov.b &DIG6H, R11   ;Guarda la parte alta del registro
		bic.b #101b, R11    ;Mascara de parte alta
		and.b #101b, &DIG5H ;Digito a cero menos mascara
		add.b R11, &DIG5H
;De cadena de caracteres al dig 6
		mov.b r12, &DIG6	;Ponemos la parte baja de r12 a la parte baja del digito 6
		and.b #101b, &DIG6H	;Mascara de parte alta
		swpb r12
		add.b r12, &DIG6H
SWfin   ret
;-------------------------------------------------------------------------------
; Tabla de conversion de 14 segmentos
;-------------------------------------------------------------------------------
			;       abcdefgm   hjkpq-n-
Tab14Seg	.byte	00000000b, 00000000b	;Espacio
			.byte	00000000b, 00000000b	;!
			.byte	00000000b, 00000000b	;"
			.byte	00000000b, 00000000b	;#
			.byte	00000000b, 00000000b	;$
			.byte	00000000b, 00000000b	;%
			.byte	00000000b, 00000000b	;&
			.byte	00000000b, 00000000b	;'
			.byte	00000000b, 00000000b	;(
			.byte	00000000b, 00000000b	;)
			.byte	00000011b, 11111010b	;*
			.byte	00000011b, 01010000b	;+
			.byte	00000000b, 00000000b	;,
			.byte	00000011b, 00000000b	;-
			.byte	00000000b, 00000000b	;.
			.byte	00000000b, 00101000b	;/
			;       abcdefgm   hjkpq-n-
			.byte	11111100b, 00101000b	;0
			.byte	01100000b, 00100000b	;1
			.byte	11011011b, 00000000b	;2
			.byte	11110011b, 00000000b	;3
			.byte	01100111b, 00000000b	;4
			.byte	10110111b, 00000000b	;5
			.byte	10111111b, 00000000b	;6
			.byte	10000000b, 00110000b	;7
			.byte	11111111b, 00000000b	;8
			.byte	11100111b, 00000000b	;9
			.byte	00000000b, 00000000b	;:
			.byte	00000000b, 00000000b	;;
			.byte	00000000b, 00100010b	;<
			.byte	00010011b, 00000000b	;=
			.byte	00000000b, 10001000b	;>
			.byte	00000000b, 00000000b	;?
			;       abcdefgm   hjkpq-n-
			.byte	00000000b, 00000000b	;@
			.byte	01100001b, 00101000b	;A
			.byte	11110001b, 01010000b	;B
			.byte	10011100b, 00000000b	;C
			.byte	11110000b, 01010000b	;D
			.byte	10011110b, 00000000b	;E
			.byte	10001110b, 00000000b	;F
			.byte	10111101b, 00000000b	;G
			.byte	01101111b, 00000000b	;H
			.byte	10010000b, 01010000b	;I
			.byte	01111000b, 00000000b	;J
			.byte	00001110b, 00100010b	;K
			.byte	00011100b, 00000000b	;L
			.byte	01101100b, 10100000b	;M
			.byte	01101100b, 10000010b	;N
			.byte	11111100b, 00000000b	;O
			;       abcdefgm   hjkpq-n-
			.byte	11001111b, 00000000b	;P
			.byte	11111100b, 00000010b	;Q
			.byte	11001111b, 00000010b	;R
			.byte	10110111b, 00000000b	;S
			.byte	10000000b, 01010000b	;T
			.byte	01111100b, 00000000b	;U
			.byte	01100000b, 10000010b	;V
			.byte	01101100b, 00001010b	;W
			.byte	00000000b, 10101010b	;X
			.byte	00000000b, 10110000b	;Y
			.byte	10010000b, 00101000b	;Z
			.byte	10011100b, 00000000b	;[
			.byte	00000000b, 10000010b	;\
			.byte	11110000b, 00000000b	;]
			.byte	01000000b, 00100000b	;^
			.byte	00010000b, 00000000b	;_
			;       abcdefgm   hjkpq-n-
			.byte	00000000b, 10000000b	;`
			.byte	00011010b, 00010000b	;a
			.byte	00111111b, 00000000b	;b
			.byte	00011011b, 00000000b	;c
			.byte	01111011b, 00000000b	;d
			.byte	00011010b, 00001000b	;e
			.byte	10001110b, 00000000b	;f
			.byte	11110111b, 00000000b	;g
			.byte	00101111b, 00000000b	;h
			.byte	00000000b, 00010000b	;i
			.byte	01110000b, 00000000b	;j
			.byte	00000000b, 01110010b	;k
			.byte	00000000b, 01010000b	;l
			.byte	00101011b, 00010000b	;m
			.byte	00100001b, 00010000b	;n
			.byte	00111011b, 00000000b	;o
			;       abcdefgm   hjkpq-n-
			.byte	00001110b, 10000000b	;p
			.byte	11100111b, 00000000b	;q
			.byte	00000001b, 00010000b	;r
			.byte	00010001b, 00000010b	;s
			.byte	00000011b, 01010000b	;t
			.byte	00111000b, 00000000b	;u
			.byte	00100000b, 00000010b	;v
			.byte	00101000b, 00001010b	;w
			.byte	00000000b, 10101010b	;x
			.byte	01110001b, 01000000b	;y
			.byte	00010010b, 00001000b	;z
			.byte	00000000b, 00000000b	;{
			.byte	00000000b, 00000000b	;|
			.byte	00000000b, 00000000b	;}
			.byte	00000000b, 00000000b	;~
			.byte	00000000b, 00000000b	;
