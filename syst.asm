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

			.bss SystemTimer, 4
			.bss systPeriodo, 2

			.global systIni
			.global systTim
			.global systComp
			.global pulsIni
			.global puls

SW1			.equ BIT1
SW2			.equ BIT2

;--------------------------------------------------
;Inicializa el System Timer
;--------------------------------------------------
systIni		mov.w #TASSEL__ACLK|ID__1|MC__CONTINUOUS|TACLR, &TA2CTL	;Modo continuo, fuente aclk, divisor 1 y  reseteo el contador
			mov.w r12, &systPeriodo
			bic.w #CCIFG, &TA2CCTL0
			bis.w #CCIE, &TA2CCTL0			;Interrupcionrs del CCR
			mov.w &systPeriodo, &TA2CCR0
			bis.w #GIE, sr					;Interrupciones CPU
			ret
;--------------------------------------------------
;Vector de interrupcion
;--------------------------------------------------
systA2ISR	inc.w &SystemTimer 				;Incremento del timer
		   	adc.w &SystemTimer+2			;Parte alta
			add.w &systPeriodo, &TA2CCR0 	;Guarda en el CCR0
			reti

			.intvec  	TIMER2_A0_VECTOR, systA2ISR
			.text							;Para seguir escribiendo
;--------------------------------------------------
;Valor de timer
;--------------------------------------------------
systTim mov.w sr, r14				;Estado actual
		bic.w #GIE, sr				;Deshabilita interrupciones
		mov.w &SystemTimer, R12		;Actualiza timer
		mov.w &SystemTimer+2, R13
		mov.w r14, sr				;Vuelve al estado inicial
		ret
timCmp	cmp.w r12, &SystemTimer		;Comparo timer
		jeq   cmpAlta				;Miro parte alta
		cmp.w r12, &SystemTimer		;Vuelvo a comparar
		jlo   stmay					;El timer es mayor
		mov.w #1, r12				;Saco un numero mayor a cero
		jmp   timefin				;Fuera
stmay	mov.w #-1, r12,				;Si no, numero negativo
		jmp   timefin
cmpAlta	cmp.w r13, &SystemTimer+2	;Mira parte alta
		jeq   cero					;Si es igual, cero
		cmp.w r13, &SystemTimer+2
		jlo   stmayor				;Si no, es mayor
		mov.w #1, r12				;Saca numero psoitivo
		jmp   timefin
stmayor	mov.w #-1, r12,				;Si no, negativo
		jmp   timefin
cero	mov.w #0, r12
timefin	ret
;--------------------------------------------------
;Iinicia pulsadores
;--------------------------------------------------
pulsIni	bis.b #SW1|SW2, &P1REN
	    bis.b #SW1|SW2, &P1OUT		;Como entradas
		ret
;--------------------------------------------------
;Interrupciones y subrutina
;--------------------------------------------------
puls    bic.w #0, R12
		bic.b #SW1|SW2, &P1IFG
		bis.b #SW1|SW2, &P1IES
		bis.b #SW1|SW2, &P1IE
		bis.w #GIE, sr				;Habilita interrupciones
		ret
P1ISR	add.w &P1IV, PC
		reti
		reti
		jmp P1_1

		xor.b #SW2, &P1IES		;Conmuta flanco
		bit.b #SW2, &P1IN
		jz 	  pulsado			;Esta pulsado
		mov.w #2, R12			;Essra a pulsar
		jmp finpuls
pulsado	mov.w #3, R12 			;espera a que se suelte
finpuls	reti
P1_1 	mov.w #1, R12			;numero aletorio
		reti

		.intvec PORT1_VECTOR, P1ISR
