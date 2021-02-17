; configuracion de bit de el uP
    
    processor pic16f877A
    include<p16F877A.inc>
    
    __config 2F41h    ;0010 1111 0100 0001 
    
    org 0x00
    
    GOTO INICIA       ;saltamos vector de interrupcion
    NOP
    NOP
    NOP
    BCF INTCON,GIE    ;deshabilita interrupciones
    GOTO INTERR       ;salta al procedimiento de servicio de interrupcion


;configuracion de puertos
INICIA  

    CLRF PORTA
    CLRF PORTB
    CLRF PORTC   
    CLRF PORTD    
    CLRF PORTE

    MOVLW 0x90        ;1001 0000
    MOVWF RCSTA       ;SP=on; 8bit; CR=on; ADr=off; 
 
    BSF STATUS,RP0    ;01=bank1

    CLRF TRISA
    CLRF TRISB
    CLRF TRISC
    CLRF TRISD
    CLRF TRISE

    MOVLW 0x07
    MOVWF ADCON1      ;coloca los bits analogos en digital I/O
    
    MOVLW 0x24        ;0000 0100
    MOVWF TXSTA       ;TXSTA: 8bits; Tx=off; Modo asíncrono; BRGH=1 
    MOVLW 0x19
    MOVWF SPBRG       ;BAUD RATE: para 9600=4MHZ/(16(SPBRG+1))=25d=19h

    BSF PIR1,RCIF     ;activamos bandera de interrupcion para RX-UART

    BCF STATUS,RP1    ;00=bank0
    BCF STATUS,RP0

; programa principal MAIN

    CLRF 7F           ;registro usado para banderas de proceso
    
    MOVLW 0xC0	      ;1100000000
    MOVWF INTCON      ;activamos interrupcion general y perifericos: GIE,PEIE=1

MAIN1
    MOVLW 0x30
    MOVWF FSR         ;inicia FSR con 30h 30h es el nuevo 0x00

    MOVLW 0x0A	      ;w=10
    MOVWF 20          ;inicia contador de datos de entrada=10 


MAIN2
    BTFSS 7F,0        ;verifica bandera de DATOS-IN
    GOTO  MAIN2
    BCF 7F,0          ;borra bandera DATOS-IN

    MOVF 7E,W	      ; w=lo recibido en UART
    MOVWF 00          ;almacena datos en la memoria RAM a partir de la localidad (30)
    INCF FSR,1	      ;fsr++

    DECFSZ 20,1       ;contador de datos de entrada
    GOTO MAIN2

    BCF INTCON,GIE    ;deshabilita interrupciones
   

    BCF STATUS,RP1    ;b0
    BCF STATUS,RP0
    MOVLW 0X08
    MOVWF 20          ;cargamos reg(20) bank2 con 4 repeticiones

    BSF STATUS,RP1    ;b2
    BCF STATUS,RP0
    
    BCF STATUS,RP1    ;b0
    MOVF 30,W         ;coloca la direccion FLASH=RAM(31)(30)
    BSF STATUS,RP1    ;b2
    MOVWF EEADR
    BCF STATUS,RP1    ;b0
    MOVF 31,W
    BSF STATUS,RP1    ;b2
    MOVWF EEADRH

    MOVLW 0x32
    MOVWF FSR         ;inicia FSR con 32h

LOOP
    BSF STATUS,RP1    ;b2
    MOVF INDF,W       ;carga dato bajo de RAM
    MOVWF EEDATA
    INCF FSR,1        ;incrementa apuntador de RAM
    MOVF INDF,W       ;carga dato alto de RAM
    MOVWF EEDATH
    
    BSF STATUS,RP0    ;11=bank3
    
    BSF EECON1,EEPGD  ;accesamos al bloque de memoria Flash
    BSF EECON1,WREN   ;habilita el ciclo de escritura
    
; inicia secuencia de escritura
    
    MOVLW 0x55        ;damos la secuencia de escritura
    MOVWF EECON2
    MOVLW 0xAA
    MOVWF EECON2
    
    BSF EECON1,WR     ;inicia el ciclo de escritura
    NOP
    NOP
  
    BCF EECON1,WREN   ;deshabilita el ciclo de escritura
    
    BCF STATUS,RP0    ;10=bank2
    
    INCF EEADR,1      ;incrementa direccion de FLASH
    
    
     BCF STATUS,RP1    ;b0
    BCF STATUS,RP0
    
    
    
    DECFSZ 20,1       ;decrementamos registro (20)bank2
    GOTO LOOP
    
    BCF STATUS,RP0    ;00=bank0
    GOTO MAIN1


    
INTERR                 ;  ************* interrupcion Rx UART ********************

    MOVWF 70          ;almacena W
    SWAPF STATUS,W
    MOVWF 71          ;almacena Status
    MOVF FSR,W
    MOVWF 72          ;almacena apuntador FSR
    MOVF RCSTA,W
    MOVWF 73          ;almacena Rx status
    
    
BCF STATUS,RP1    ;b0
BCF STATUS,RP0
    
    MOVF RCREG,W      ;lee Rx Data
    MOVWF PORTB
    MOVWF 7E          ;almacena Dato 8bits en registro(7E)
    
    BSF 7F,0          ;prende bandera DATOS-IN
    BTFSS 73,1        ;verifica overrun error
    GOTO OVR
    BCF RCSTA,4
    BSF RCSTA,4       ;reset overrun error
OVR 
    MOVF 72,W
    MOVWF FSR         ;restaura apuntador FSR
    SWAPF 71,W
    MOVWF STATUS      ;restaura Status
    SWAPF 70,F
    SWAPF 70,W        ;restaura W
    BSF INTCON,GIE    ;habilita interrupciones
    RETFIE


   
    END


