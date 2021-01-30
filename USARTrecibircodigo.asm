radix	    DEC
LIST	    P=16F877A,F=INHX8M		; change also: Configure->SelectDevice from Mplab 

#include    "p16f877A.inc"		;Librería de MPLAB
	    
__CONFIG  _HS_OSC & _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _LVP_OFF & _DEBUG_OFF	    
;oscilador de alta velocidad
;Protección de EEPROM off
;WatchDog Timer off
;BrownOut reset off (reseteo de bajo V)
;PWRTE ON, inserta un delay cuando se enciende el UC
;LVP off
;Debug off
        
ORG	    0x0000	    ;reset

inicio 
clrf	    STATUS	    ;banco0
bsf	    STATUS,RP0	    ;banco1
movlw	    b'00000100'	    ;
movwf	    TRISB	    ;El puerto B como salida excepto B2
    

movlw	    b'00100100'	    ;w=00100100
movwf	    TXSTA	    ;Transmit enabled y BRGH
movlw	    D'25'	    ;w=25
movwf	    SPBRG	    ;SPBRG=25D, (4000000/9600*16)-1
clrf	    STATUS	    ;banco0	    
movlw	    b'10010000'	    ;w=10010000			
movwf	    RCSTA	    ;RX y TX on,CREN on	(recepción continua)

leer
btfss	    PIR1,RCIF	    ;test RX, si ha recibido configuración USART
goto	    no
goto	    si
     
no
movlw	    b'11111000'	   
movwf	    PORTB
goto	    leer
    
si
movlw	    b'11111011'	   
movwf	    PORTB
goto	    inicio   
    
end			
			
	