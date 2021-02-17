;programa que lee un darto por seria, escribe el mismo dato y pone el valor
;recibido en el puerto B
;Kevin Rojas 1/2/21
    
 
__CONFIG  _HS_OSC & _CP_OFF & _WDT_OFF & _BODEN_ON & _PWRTE_ON & _LVP_OFF & _DEBUG_OFF	    
;oscilador de alta velocidad
;Protección de EEPROM off
;WatchDog Timer off
;BrownOut reset off (reseteo de bajo V)
;PWRTE ON, inserta un delay cuando se enciende el UC
;LVP off
;Debug off
  
List		p=16F877A		;Pic que se está usando
include		"P16F877A.INC"		;Registros del PIC
    

centena		EQU	    0x20
decena		EQU	    0x21
unidad		EQU	    0x22
udc	    	EQU	    0x23	;detrmina si es u, d o c

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  RESET  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;   
org		0x00			;Cuando inicia el PIC
goto		Inicio			;Ir a Inicio
org		0x04			;Cuando ocurre una interrupción
goto		recibir

movlw		0
movwf		udc

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ENVIAR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
enviar
bcf		PIR1,TXIF		;Bit TXIF = 0; Se apaga flag de envío 
movwf		TXREG			;TXREG=W; se enviará TXREG
bsf		STATUS,RP0		;Banco 1
esperaenviar	
btfss		TXSTA,TRMT		;Byte transmitido ??
goto		esperaenviar		;No, esperar
bcf		STATUS,RP0
return					;Si

recibir		
btfss		PIR1,RCIF		;Ha sido interrupción en la recepción ??
nop					;Nop; no hace nada, retfie; return
bcf		PIR1,RCIF		;Si, apaga flag de recepción
movf		RCREG,W			;Lee el dato recibido
movwf		PORTB			;Lo saca por la puerta B
call		enviar		        ;Lo retransmite a modo de eco
retfie

;*******************************************************************************************
;Programa principal

Inicio 
bcf		STATUS,RP0		;Selecciona banco 0
clrf		PORTC      
clrf		PORTB
bsf		STATUS,RP0		;Selecciona banco 1
clrf		TRISB			;TRIS B como salida
movlw		b'10111111'		
movwf		TRISC			;RC7/Rx entrada, RC6/Tx salida
movlw		b'00100100'   
movwf		TXSTA			;TX, sincrono, 8 bits, alta velocidad
movlw		.25			;;SPBRG=25D, (4000000/9600*16)-1
movwf		SPBRG			;9600 baudios con Fosc=4MHz
bsf		PIE1,RCIE		;Habilita flag de recepción
bcf	    	STATUS,RP0		;Selecciona banco 0
movlw		b'10010000'
movwf		RCSTA			;USART en On, recepción contínua
bsf		INTCON,PEIE		;Banderas UART ON
bsf		INTCON,GIE		;Todas las banderas ON

Loop      
;AQUI TU PROGRAMA
;para enviar datos sólo carga W con el valor a enviar y llama a la subrutina Tx_Dato
; Por ejemplo
MOVLW		0x55
;call Tx_Dato

;Lo recibido te lo guarda automáticamente en el registro RCREG y te lo muestra por puerto B

goto   Loop

end         ;Fin del programa fuente