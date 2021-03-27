;-------------------------------------------------------------------------------
;   Archivo	: Bootloader.
;   Fecha	: 26/03/2021.
;   Autor	: Kevin Rojas		 kerojas95@gmail.com kprojast@utn.edu.ec
;   Discpositivo: PIC16F877A.
;-------------------------------------------------------------------------------
		
;-------------------------------------------------------------------------------		
;   Descripción:
;   Si el estado lógico de RB7 es 0 después  de un reinicio el  Microcontrolador
;   entra en modo de Carga, esperando a que un  nuevo  firmware  llegue a través 	
;   de comunicación UART.  Mientras el microcontrolador se encuentra  en modo de 		
;   carga  RC6 y  RB6 funcionan como salidas,  mientras que  RC7 y RB7 funcionan 
;   como entradas. Después de recibir el nuevo firmware  es necesario cambiar el
;   estado lógico de RB7 a 1, para que se ejecute el nuevo firmware.
;   Los nuevos vectores de  RESET e  INTERRUPCIÓN se  encuentran en  0x03 y 0x04
;   respectivamente.
;   Toda la información del proyecto se encuentra disponible en:
;   https://github.com/KevinPaul1995/ 
;-------------------------------------------------------------------------------
	
;-------------------------------------------------------------------------------
;   Hardware: FT232, Oscilador externo de 16000000,57600 bauds	
;-------------------------------------------------------------------------------		

;palabra de configuración
__CONFIG	b'11111110110010'	    

;tipo de dispositivo
List		p=16F877A		;Pic que se está usando
include		"P16F877A.INC"		;Registros del PIC
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  MACROS ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
banco0		MACRO			;macro to select data RAM bank 0
		bcf	STATUS,RP0
		bcf	STATUS,RP1
		ENDM

banco1		MACRO			;macro to select data RAM bank 1
		bsf	STATUS,RP0
		bcf	STATUS,RP1
		ENDM

banco2		MACRO			;macro to select data RAM bank 2
		bcf	STATUS,RP0
		bsf	STATUS,RP1
		ENDM

banco3		MACRO			;macro to select data RAM bank 3
		bsf	STATUS,RP0
		bsf	STATUS,RP1
		ENDM
iniciobl	EQU	0x1FB0
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;  RESET  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
    org		0x00			;Cuando inicia el PIC
reinicio
    PAGESEL	configuracion
    goto	configuracion		;Ir a Inicio


;****************************  PROGRAMA PRINCIPAL  *****************************

    org		iniciobl		;Cuando inicia el PIC
configuracion				; solo se ejecuta una vez 
    movlw	b'10000000'
    banco1
    movwf	TRISB		;	TRIS B como salida, exepto b7
    movlw	b'10111111'		
    movwf	TRISC			;RC7/Rx entrada, RC6/Tx salida
    movlw	b'00100100'   
    movwf	TXSTA			;TX, sincrono, 8 bits, alta velocidad
    movlw	.16			;;SPBRG=16D, (16000000/57600*16)-1
    movwf	SPBRG			;
    bcf		STATUS,RP0		;de banco1 a banco 0
    movlw	b'10010000'
    movwf	RCSTA			;USART en On, recepción contínua
    movlw	b'01000000'		; enciende indicador 
    movwf	PORTB
    MOVLW	0x30
    MOVWF	FSR			;empieza el direccionamiento en ram 30
   
bootloader  
    btfsc	PORTB,7
    goto	$+3			;si RB7=1
    goto	recibir			;si RB7=0
    goto	bootloader
    goto	usuario			;bootloader off, va al goto del usuario
     
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; RECIBIR ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
recibir
    btfss	PIR1,RCIF		;test RX, si hay datos en el puerto
    goto	bootloader		;si esque no ha recibido regresa 
    movf	RCREG,w			;Mueve lo del puerto a w     
    MOVWF	0x00			;muevo a 0x0 o INDF, que es lo mismo
    
; revisar si está en el número de datos (30h)
    movf	FSR,W			;muevo la posición a w
    sublw	30			;le resto 30 a w
    btfsc	STATUS,2		;si la bandera de cero es 0
    goto	cargatama
datos
    INCF	FSR,1			;fsr++ para llenar los datos desde 30h
    decfsz	30			;si ya recibió todos los datos 
    goto	bootloader		;mientras no se llenen todas las líneas
    goto	escribeflash

cargatama				;aumenta en dos INDF y mueve w a 20h
    movf	0x00,W
    movwf	0x20			;para mantener guardado el tam de linea
    incf	0x00			;posiciones extra para la dirección
    incf	0x00			;posiciones extra para la dirección
    incf	0x00			;posiciones extra para la dirección
    goto	datos
    
;;;;;;;;;;;;;;;;;;;;;;;;;;; ESCRIBE FLASH ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
escribeflash
;Apunta a los datos guardados en RAM
    MOVLW	0x31
    MOVWF	FSR			;inicia FSR con 33h
    movf	INDF,W			;Lee el dato recibido
    
banco2
;Escribe dirección
    movwf	EEADR
    incf	FSR,1			;FSR++	    
    movf	INDF,W			;Lee el dato recibido
    movwf	EEADRH

;escribe datos
escribedatos
banco2
    
;datos L    
    incf	FSR,1			;FSR++	    
    movf	INDF,W			;Lee el dato de RAM Low
    movwf	EEDATA			;datos LOW
    
;datos H
    incf	FSR,1			;FSR++	    
    movf	INDF,W			;Lee el dato de RAM High
    movwf	0x10E			;datos HIGH
    
;ciclo de escritura
    BSF		STATUS,RP0		;banco3  
    BSF	        EECON1,EEPGD		;accesamos al bloque de memoria Flash
    BSF		EECON1,WREN		;habilita el ciclo de escritura  
    MOVLW	0x55			;damos la secuencia de escritura
    MOVWF	EECON2
    MOVLW	0xAA
    MOVWF	EECON2    
    BSF		EECON1,WR		;inicia el ciclo de escritura
    NOP
    NOP 
    BCF		EECON1,WREN		;deshabilita el ciclo de escritura  
    BCF		STATUS,RP0		;banco2  
    INCF	EEADR,1			;incrementa direccion de FLASH
    clrf	STATUS			;banco0
    decf	0x20
    decfsz	0x20			;ya se escribió toda la linea?
    goto	escribedatos		;mientras no se termine
    goto	configuracion	

; GOTO del Usuario
    org		iniciobl-4
usuario
    nop
    nop
    nop
    end		;Fin de Gestor de Carga