;Enciende RB0
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
bsf	    PORTB, 0		;RB0=1
bsf	    PORTB, 1		;RB1=1	    
	    
end





