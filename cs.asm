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
			;.global</template></templates>
			.global csIniLf
;--------------------------------------------------
; Pines como entrada y salida. Oscilador a baja frecuencia
;--------------------------------------------------
csIniLf	bis.b #BIT0, &P4DIR			;PIN como salida
		bis.b #BIT1, &P4DIR
		bis.b #BIT0, &P4SEL0		;P4SEL10 a 1
		bis.b #BIT1, &P4SEL0
		bic.b #BIT1, &P4SEL1		;P4SEL11 a 0
		bic.b #BIT0, &P4SEL1
		mov.b #CSKEY_H,  &CSCTL0_H	;Contraseña en parte alta
		bic.b #BIT4, &PJSEL1		;Habilitar LFXT
		bis.b #BIT4, &PJSEL0
		bic.b #BIT4, &CSCTL4		;LFXT con oscilador externo
		bic.b #BIT0, &CSCTL4		;Inicia LFXT
csIniLFXTbuc
		bic.b #LFXTOFFG, &CSCTL5	;Borra flag
		bic.b #OFIFG, &SFRIFG1		;Borra flag conjunto
		bit.b #LFXTOFFG, &CSCTL5	;Mira si sigue activo
		jnz csIniLFXTbuc
		clr.b &CSCTL0_H				;Limpia contraseña
		ret
