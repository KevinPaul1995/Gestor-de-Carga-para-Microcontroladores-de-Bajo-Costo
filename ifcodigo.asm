;lee RB2 y segun eso prende RB0 o RB1
; si RB2=1 RB0=1 RB1=0 si RB2=0 RB0=0 RB1=1
;Autor: Kevin Rojas
;14/12/2020
list	    p=16f877a
include	    "P16F877a.INC"

org	    0x00		;Inicia en 0x00
goto	    start		;Apunta a start
start				;Start
bsf	    STATUS, RP0		;banco1
movlw	    0xFC		;w=252,b11111100
movwf	    TRISB		;TRISB=b11111100
bcf	    STATUS, RP0		;Banco 0
    
main				;main
btfsc	    PORTB, 2		;lee RB2, si no salta dos líneas
call	    encendido
btfss	    PORTB, 2		;lee RB2, si sí salta dos líneas
call	    apagado
goto	    main		;Apunta a main

encendido
bsf	    PORTB, 0		;RB0=1
bcf	    PORTB, 1		;RB1=0
return
    
apagado
bcf	    PORTB, 0		;RB0=0
bsf	    PORTB, 1		;RB1=1
return
end





