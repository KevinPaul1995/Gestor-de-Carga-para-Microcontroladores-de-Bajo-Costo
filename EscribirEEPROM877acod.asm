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

CBLOCK	0x20
DATA_EE_ADDR:	1
DATA_EE_DATA:	1	
ENDC
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

    
org		0x0

		
banco0
movlw	    0x2
movwf	    DATA_EE_ADDR
movlw	    0x5
movwf	    DATA_EE_DATA
    
    
banco3
BTFSC		EECON1,WR
GOTO		$-1
banco0
MOVF		DATA_EE_ADDR,W ;Data Memory
banco2
MOVWF		EEADR		;EEADR=W=direcciòn
banco0
MOVF		DATA_EE_DATA,W	;Data Memory Value
banco2
MOVWF		EEDATA		;EEDATA= datos
banco3

BCF		EECON1,EEPGD 
BSF		EECON1,WREN     
BCF		INTCON,GIE
MOVLW		55h
MOVWF		EECON2
MOVLW		0xAA
		
MOVWF		EECON2

BSF		EECON1,WR
BSF		INTCON,GIE
BCF		EECON1,WREN
end