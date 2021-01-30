;archivo que envía datos por UART

list	    p=16F877a
include	    "P16F877a.INC"
 
cblock	    0x20	;Directiva para crear variables
char			;variable en 0x20
C1			;variable en 0x21
C2			;variable en 0x22
endc			;Fin de la directiva
 
org	    0x00	;Origen en 0x00, vector de reset
goto	    inicio	;Ssalta a inicio
    
inicio			;Etiqueta inicio
clrf	    PORTB	;PORTB=00000000
bsf	    STATUS,RP0  ;Banco 1
movlw	    B'00000100'	;w=00000100
movwf	    TRISB	;make all PORTB pins output except RB2
movlw	    D'25'	;w=25
movwf	    SPBRG	;SPBRG=25D, para osc=4000000
movlw	    B'00100100'
movwf	    TXSTA	;Com asíncrona de 8 bits, alta velocidad, activada
bcf	    STATUS,RP0  ;Banco cero
movlw	    B'10000000'
movwf	    RCSTA	;Activa los pines de puerto serial
movlw	    0x2A 
movwf	    char	;Char=w
    
main	    
btfss	    PORTB,2	;Si RB2 es 1
goto	    main	;Si no está presionado
movf	    char,W	;W=char
movwf	    TXREG	;TXREG=char
goto	    wthere
call	    delay
goto	    main
 
wthere	    
btfss	    TXSTA,TRMT	;check if TRMT is empty
goto	    wthere	;if not, check again
bcf	    STATUS, RP0 ;bank 0, if TRMT is empty then the character has been sent
return
 
delay
loop1	    decfsz C1,1
goto	    loop1
decfsz	    C2,1
goto	    loop1
return

end
