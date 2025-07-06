
_setup_pwm:

;dechet.c,61 :: 		void setup_pwm() {
;dechet.c,62 :: 		SERVO_PWM_Direction = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;dechet.c,63 :: 		PR2 = 249;
	MOVLW      249
	MOVWF      PR2+0
;dechet.c,64 :: 		CCP1CON = 0x0C;
	MOVLW      12
	MOVWF      CCP1CON+0
;dechet.c,65 :: 		CCPR1L = 0;
	CLRF       CCPR1L+0
;dechet.c,66 :: 		T2CON = 0x06;
	MOVLW      6
	MOVWF      T2CON+0
;dechet.c,67 :: 		TMR2ON_bit = 1;
	BSF        TMR2ON_bit+0, BitPos(TMR2ON_bit+0)
;dechet.c,68 :: 		}
L_end_setup_pwm:
	RETURN
; end of _setup_pwm

_set_servo_angle:

;dechet.c,70 :: 		void set_servo_angle(unsigned char angle) {
;dechet.c,72 :: 		switch (angle) {
	GOTO       L_set_servo_angle0
;dechet.c,73 :: 		case 0: duty = 31; break;
L_set_servo_angle2:
	MOVLW      31
	MOVWF      R3+0
	GOTO       L_set_servo_angle1
;dechet.c,74 :: 		case 90: duty = 94; break;
L_set_servo_angle3:
	MOVLW      94
	MOVWF      R3+0
	GOTO       L_set_servo_angle1
;dechet.c,75 :: 		case 180: duty = 156; break;
L_set_servo_angle4:
	MOVLW      156
	MOVWF      R3+0
	GOTO       L_set_servo_angle1
;dechet.c,76 :: 		default: duty = 94; break;
L_set_servo_angle5:
	MOVLW      94
	MOVWF      R3+0
	GOTO       L_set_servo_angle1
;dechet.c,77 :: 		}
L_set_servo_angle0:
	MOVF       FARG_set_servo_angle_angle+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_set_servo_angle2
	MOVF       FARG_set_servo_angle_angle+0, 0
	XORLW      90
	BTFSC      STATUS+0, 2
	GOTO       L_set_servo_angle3
	MOVF       FARG_set_servo_angle_angle+0, 0
	XORLW      180
	BTFSC      STATUS+0, 2
	GOTO       L_set_servo_angle4
	GOTO       L_set_servo_angle5
L_set_servo_angle1:
;dechet.c,78 :: 		CCPR1L = duty >> 2;
	MOVF       R3+0, 0
	MOVWF      R0+0
	RRF        R0+0, 1
	BCF        R0+0, 7
	RRF        R0+0, 1
	BCF        R0+0, 7
	MOVF       R0+0, 0
	MOVWF      CCPR1L+0
;dechet.c,79 :: 		CCP1CON = 0x0C | ((duty & 0x03) << 4);
	MOVLW      3
	ANDWF      R3+0, 0
	MOVWF      R2+0
	MOVF       R2+0, 0
	MOVWF      R0+0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	RLF        R0+0, 1
	BCF        R0+0, 0
	MOVLW      12
	IORWF      R0+0, 0
	MOVWF      CCP1CON+0
;dechet.c,80 :: 		}
L_end_set_servo_angle:
	RETURN
; end of _set_servo_angle

_save_alert_count_to_eeprom:

;dechet.c,82 :: 		void save_alert_count_to_eeprom() {
;dechet.c,83 :: 		EEPROM_Write(0x00, alert_count >> 8);
	CLRF       FARG_EEPROM_Write_Address+0
	MOVF       _alert_count+1, 0
	MOVWF      R0+0
	CLRF       R0+1
	MOVF       R0+0, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;dechet.c,84 :: 		EEPROM_Write(0x01, alert_count & 0xFF);
	MOVLW      1
	MOVWF      FARG_EEPROM_Write_Address+0
	MOVLW      255
	ANDWF      _alert_count+0, 0
	MOVWF      FARG_EEPROM_Write_data_+0
	CALL       _EEPROM_Write+0
;dechet.c,85 :: 		}
L_end_save_alert_count_to_eeprom:
	RETURN
; end of _save_alert_count_to_eeprom

_load_alert_count_from_eeprom:

;dechet.c,87 :: 		void load_alert_count_from_eeprom() {
;dechet.c,88 :: 		unsigned char high_byte = EEPROM_Read(0x00);
	CLRF       FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
	MOVF       R0+0, 0
	MOVWF      load_alert_count_from_eeprom_high_byte_L0+0
;dechet.c,89 :: 		unsigned char low_byte = EEPROM_Read(0x01);
	MOVLW      1
	MOVWF      FARG_EEPROM_Read_Address+0
	CALL       _EEPROM_Read+0
;dechet.c,90 :: 		alert_count = (high_byte << 8) | low_byte;
	MOVF       load_alert_count_from_eeprom_high_byte_L0+0, 0
	MOVWF      _alert_count+1
	CLRF       _alert_count+0
	MOVF       R0+0, 0
	IORWF      _alert_count+0, 1
	MOVLW      0
	IORWF      _alert_count+1, 1
;dechet.c,91 :: 		}
L_end_load_alert_count_from_eeprom:
	RETURN
; end of _load_alert_count_from_eeprom

_interrupt:
	MOVWF      R15+0
	SWAPF      STATUS+0, 0
	CLRF       STATUS+0
	MOVWF      ___saveSTATUS+0
	MOVF       PCLATH+0, 0
	MOVWF      ___savePCLATH+0
	CLRF       PCLATH+0

;dechet.c,93 :: 		void interrupt() {
;dechet.c,94 :: 		if (INTCON.T0IF && INTCON.T0IE) {
	BTFSS      INTCON+0, 2
	GOTO       L_interrupt8
	BTFSS      INTCON+0, 5
	GOTO       L_interrupt8
L__interrupt63:
;dechet.c,95 :: 		if (++timer_counter >= 76) {
	INCF       _timer_counter+0, 1
	MOVLW      76
	SUBWF      _timer_counter+0, 0
	BTFSS      STATUS+0, 0
	GOTO       L_interrupt9
;dechet.c,96 :: 		if (awaiting_confirmation) {
	BTFSS      _awaiting_confirmation+0, BitPos(_awaiting_confirmation+0)
	GOTO       L_interrupt10
;dechet.c,97 :: 		affichage = 0;
	CLRF       _affichage+0
;dechet.c,98 :: 		awaiting_confirmation = 0;
	BCF        _awaiting_confirmation+0, BitPos(_awaiting_confirmation+0)
;dechet.c,99 :: 		}
L_interrupt10:
;dechet.c,100 :: 		timer_counter = 0;
	CLRF       _timer_counter+0
;dechet.c,101 :: 		INTCON.T0IE = 0;
	BCF        INTCON+0, 5
;dechet.c,102 :: 		}
L_interrupt9:
;dechet.c,103 :: 		TMR0 = 0;
	CLRF       TMR0+0
;dechet.c,104 :: 		INTCON.T0IF = 0;
	BCF        INTCON+0, 2
;dechet.c,105 :: 		}
L_interrupt8:
;dechet.c,107 :: 		if (INTCON.INTF && INTCON.INTE) {
	BTFSS      INTCON+0, 1
	GOTO       L_interrupt13
	BTFSS      INTCON+0, 4
	GOTO       L_interrupt13
L__interrupt62:
;dechet.c,108 :: 		affichage = 1;
	MOVLW      1
	MOVWF      _affichage+0
;dechet.c,109 :: 		INTCON.INTF = 0;
	BCF        INTCON+0, 1
;dechet.c,110 :: 		}
L_interrupt13:
;dechet.c,112 :: 		if (INTCON.RBIF && INTCON.RBIE) {
	BTFSS      INTCON+0, 0
	GOTO       L_interrupt16
	BTFSS      INTCON+0, 3
	GOTO       L_interrupt16
L__interrupt61:
;dechet.c,114 :: 		if (BUTTON_CANCEL) affichage = 2;
	BTFSS      RB4_bit+0, BitPos(RB4_bit+0)
	GOTO       L_interrupt17
	MOVLW      2
	MOVWF      _affichage+0
	GOTO       L_interrupt18
L_interrupt17:
;dechet.c,115 :: 		else if (BUTTON_PAUSE) affichage = 3;
	BTFSS      RB5_bit+0, BitPos(RB5_bit+0)
	GOTO       L_interrupt19
	MOVLW      3
	MOVWF      _affichage+0
	GOTO       L_interrupt20
L_interrupt19:
;dechet.c,116 :: 		else if (BUTTON_ALERTE) {
	BTFSS      RB6_bit+0, BitPos(RB6_bit+0)
	GOTO       L_interrupt21
;dechet.c,117 :: 		affichage = 4;
	MOVLW      4
	MOVWF      _affichage+0
;dechet.c,118 :: 		alert_count++;
	INCF       _alert_count+0, 1
	BTFSC      STATUS+0, 2
	INCF       _alert_count+1, 1
;dechet.c,119 :: 		save_alert_count_to_eeprom();
	CALL       _save_alert_count_to_eeprom+0
;dechet.c,120 :: 		} else if (BUTTON_VEILLE) affichage = 5;
	GOTO       L_interrupt22
L_interrupt21:
	BTFSS      RB7_bit+0, BitPos(RB7_bit+0)
	GOTO       L_interrupt23
	MOVLW      5
	MOVWF      _affichage+0
	GOTO       L_interrupt24
L_interrupt23:
;dechet.c,121 :: 		else if (BUTTON_EEPROM) affichage = 8;  // <--- Ajout ici
	BTFSS      RB3_bit+0, BitPos(RB3_bit+0)
	GOTO       L_interrupt25
	MOVLW      8
	MOVWF      _affichage+0
L_interrupt25:
L_interrupt24:
L_interrupt22:
L_interrupt20:
L_interrupt18:
;dechet.c,123 :: 		INTCON.RBIF = 0;
	BCF        INTCON+0, 0
;dechet.c,124 :: 		}
L_interrupt16:
;dechet.c,125 :: 		}
L_end_interrupt:
L__interrupt72:
	MOVF       ___savePCLATH+0, 0
	MOVWF      PCLATH+0
	SWAPF      ___saveSTATUS+0, 0
	MOVWF      STATUS+0
	SWAPF      R15+0, 1
	SWAPF      R15+0, 0
	RETFIE
; end of _interrupt

_main:

;dechet.c,127 :: 		void main() {
;dechet.c,128 :: 		TRISA = 0xFF;
	MOVLW      255
	MOVWF      TRISA+0
;dechet.c,129 :: 		TRISB = 0xFF;
	MOVLW      255
	MOVWF      TRISB+0
;dechet.c,130 :: 		TRISC = 0x00;
	CLRF       TRISC+0
;dechet.c,131 :: 		TRISD = 0x00;
	CLRF       TRISD+0
;dechet.c,133 :: 		LCD_RS_Direction = 0;
	BCF        TRISD4_bit+0, BitPos(TRISD4_bit+0)
;dechet.c,134 :: 		LCD_EN_Direction = 0;
	BCF        TRISD5_bit+0, BitPos(TRISD5_bit+0)
;dechet.c,135 :: 		LCD_D4_Direction = 0;
	BCF        TRISD0_bit+0, BitPos(TRISD0_bit+0)
;dechet.c,136 :: 		LCD_D5_Direction = 0;
	BCF        TRISD1_bit+0, BitPos(TRISD1_bit+0)
;dechet.c,137 :: 		LCD_D6_Direction = 0;
	BCF        TRISD2_bit+0, BitPos(TRISD2_bit+0)
;dechet.c,138 :: 		LCD_D7_Direction = 0;
	BCF        TRISD3_bit+0, BitPos(TRISD3_bit+0)
;dechet.c,140 :: 		SERVO_PWM_Direction = 0;
	BCF        TRISC2_bit+0, BitPos(TRISC2_bit+0)
;dechet.c,141 :: 		LED_GREEN_Direction = 0;
	BCF        TRISC5_bit+0, BitPos(TRISC5_bit+0)
;dechet.c,142 :: 		LED_RED_Direction = 0;
	BCF        TRISC6_bit+0, BitPos(TRISC6_bit+0)
;dechet.c,143 :: 		BUZZER_Direction = 0;
	BCF        TRISC7_bit+0, BitPos(TRISC7_bit+0)
;dechet.c,145 :: 		BUTTON_START_Direction = 1;
	BSF        TRISB0_bit+0, BitPos(TRISB0_bit+0)
;dechet.c,146 :: 		BUTTON_CONFIRM_Direction = 1;
	BSF        TRISA4_bit+0, BitPos(TRISA4_bit+0)
;dechet.c,147 :: 		BUTTON_CANCEL_Direction = 1;
	BSF        TRISB4_bit+0, BitPos(TRISB4_bit+0)
;dechet.c,148 :: 		BUTTON_PAUSE_Direction = 1;
	BSF        TRISB5_bit+0, BitPos(TRISB5_bit+0)
;dechet.c,149 :: 		BUTTON_ALERTE_Direction = 1;
	BSF        TRISB6_bit+0, BitPos(TRISB6_bit+0)
;dechet.c,150 :: 		BUTTON_VEILLE_Direction = 1;
	BSF        TRISB7_bit+0, BitPos(TRISB7_bit+0)
;dechet.c,151 :: 		BUTTON_EEPROM_Direction = 1;
	BSF        TRISB3_bit+0, BitPos(TRISB3_bit+0)
;dechet.c,153 :: 		LED_GREEN = 0;
	BCF        RC5_bit+0, BitPos(RC5_bit+0)
;dechet.c,154 :: 		LED_RED = 0;
	BCF        RC6_bit+0, BitPos(RC6_bit+0)
;dechet.c,155 :: 		BUZZER = 0;
	BCF        RC7_bit+0, BitPos(RC7_bit+0)
;dechet.c,156 :: 		awaiting_confirmation = 0;
	BCF        _awaiting_confirmation+0, BitPos(_awaiting_confirmation+0)
;dechet.c,158 :: 		OPTION_REG = 0x07;
	MOVLW      7
	MOVWF      OPTION_REG+0
;dechet.c,159 :: 		INTCON.INTEDG = 1;
	BSF        INTCON+0, 6
;dechet.c,160 :: 		INTCON.GIE = 1;
	BSF        INTCON+0, 7
;dechet.c,161 :: 		INTCON.INTE = 1;
	BSF        INTCON+0, 4
;dechet.c,162 :: 		INTCON.RBIE = 1;
	BSF        INTCON+0, 3
;dechet.c,163 :: 		INTCON.T0IE = 0;
	BCF        INTCON+0, 5
;dechet.c,164 :: 		INTCON.T0IF = 0;
	BCF        INTCON+0, 2
;dechet.c,166 :: 		ADCON1 = 0x80;
	MOVLW      128
	MOVWF      ADCON1+0
;dechet.c,167 :: 		ADCON0 = 0x09;
	MOVLW      9
	MOVWF      ADCON0+0
;dechet.c,169 :: 		Lcd_Init();
	CALL       _Lcd_Init+0
;dechet.c,170 :: 		setup_pwm();
	CALL       _setup_pwm+0
;dechet.c,172 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;dechet.c,173 :: 		Lcd_Cmd(_LCD_CURSOR_OFF);
	MOVLW      12
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;dechet.c,175 :: 		load_alert_count_from_eeprom();
	CALL       _load_alert_count_from_eeprom+0
;dechet.c,176 :: 		Lcd_Out(1, 1, messages[0]);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _messages+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,177 :: 		Delay_ms(200);
	MOVLW      3
	MOVWF      R11+0
	MOVLW      8
	MOVWF      R12+0
	MOVLW      119
	MOVWF      R13+0
L_main26:
	DECFSZ     R13+0, 1
	GOTO       L_main26
	DECFSZ     R12+0, 1
	GOTO       L_main26
	DECFSZ     R11+0, 1
	GOTO       L_main26
;dechet.c,179 :: 		while (1) {
L_main27:
;dechet.c,180 :: 		adc_value_P = ADC_Get_Sample(2);
	MOVLW      2
	MOVWF      FARG_ADC_Get_Sample_channel+0
	CALL       _ADC_Get_Sample+0
	MOVF       R0+0, 0
	MOVWF      _adc_value_P+0
	MOVF       R0+1, 0
	MOVWF      _adc_value_P+1
;dechet.c,181 :: 		tensionP = (adc_value_P * 5.0) / 1023.0;
	CALL       _word2double+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      32
	MOVWF      R4+2
	MOVLW      129
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      192
	MOVWF      R4+1
	MOVLW      127
	MOVWF      R4+2
	MOVLW      136
	MOVWF      R4+3
	CALL       _Div_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      _tensionP+0
	MOVF       R0+1, 0
	MOVWF      _tensionP+1
	MOVF       R0+2, 0
	MOVWF      _tensionP+2
	MOVF       R0+3, 0
	MOVWF      _tensionP+3
;dechet.c,182 :: 		adc_value_M = ADC_Get_Sample(3);
	MOVLW      3
	MOVWF      FARG_ADC_Get_Sample_channel+0
	CALL       _ADC_Get_Sample+0
	MOVF       R0+0, 0
	MOVWF      _adc_value_M+0
	MOVF       R0+1, 0
	MOVWF      _adc_value_M+1
;dechet.c,183 :: 		tensionM = (adc_value_M * 5.0) / 1023.0;
	CALL       _word2double+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      32
	MOVWF      R4+2
	MOVLW      129
	MOVWF      R4+3
	CALL       _Mul_32x32_FP+0
	MOVLW      0
	MOVWF      R4+0
	MOVLW      192
	MOVWF      R4+1
	MOVLW      127
	MOVWF      R4+2
	MOVLW      136
	MOVWF      R4+3
	CALL       _Div_32x32_FP+0
	MOVF       R0+0, 0
	MOVWF      _tensionM+0
	MOVF       R0+1, 0
	MOVWF      _tensionM+1
	MOVF       R0+2, 0
	MOVWF      _tensionM+2
	MOVF       R0+3, 0
	MOVWF      _tensionM+3
;dechet.c,185 :: 		if (BUTTON_CONFIRM) {
	BTFSS      RA4_bit+0, BitPos(RA4_bit+0)
	GOTO       L_main29
;dechet.c,186 :: 		if (!awaiting_confirmation) {
	BTFSC      _awaiting_confirmation+0, BitPos(_awaiting_confirmation+0)
	GOTO       L_main30
;dechet.c,187 :: 		affichage = 6;
	MOVLW      6
	MOVWF      _affichage+0
;dechet.c,188 :: 		awaiting_confirmation = 1;
	BSF        _awaiting_confirmation+0, BitPos(_awaiting_confirmation+0)
;dechet.c,189 :: 		timer_counter = 0;
	CLRF       _timer_counter+0
;dechet.c,190 :: 		TMR0 = 0;
	CLRF       TMR0+0
;dechet.c,191 :: 		INTCON.T0IE = 1;
	BSF        INTCON+0, 5
;dechet.c,192 :: 		} else {
	GOTO       L_main31
L_main30:
;dechet.c,193 :: 		affichage = 7;
	MOVLW      7
	MOVWF      _affichage+0
;dechet.c,194 :: 		awaiting_confirmation = 0;
	BCF        _awaiting_confirmation+0, BitPos(_awaiting_confirmation+0)
;dechet.c,195 :: 		INTCON.T0IE = 0;
	BCF        INTCON+0, 5
;dechet.c,196 :: 		timer_counter = 0;
	CLRF       _timer_counter+0
;dechet.c,197 :: 		}
L_main31:
;dechet.c,198 :: 		while (BUTTON_CONFIRM);
L_main32:
	BTFSS      RA4_bit+0, BitPos(RA4_bit+0)
	GOTO       L_main33
	GOTO       L_main32
L_main33:
;dechet.c,199 :: 		}
L_main29:
;dechet.c,201 :: 		if (BUTTON_EEPROM) {
	BTFSS      RB3_bit+0, BitPos(RB3_bit+0)
	GOTO       L_main34
;dechet.c,202 :: 		affichage = 8;
	MOVLW      8
	MOVWF      _affichage+0
;dechet.c,203 :: 		}
L_main34:
;dechet.c,205 :: 		if (affichage != 7 || (tensionM >= 3.5 && tensionP > 2 && tensionP < 3.5)) {
	MOVF       _affichage+0, 0
	XORLW      7
	BTFSS      STATUS+0, 2
	GOTO       L__main65
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      96
	MOVWF      R4+2
	MOVLW      128
	MOVWF      R4+3
	MOVF       _tensionM+0, 0
	MOVWF      R0+0
	MOVF       _tensionM+1, 0
	MOVWF      R0+1
	MOVF       _tensionM+2, 0
	MOVWF      R0+2
	MOVF       _tensionM+3, 0
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSS      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L__main66
	MOVF       _tensionP+0, 0
	MOVWF      R4+0
	MOVF       _tensionP+1, 0
	MOVWF      R4+1
	MOVF       _tensionP+2, 0
	MOVWF      R4+2
	MOVF       _tensionP+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      0
	MOVWF      R0+2
	MOVLW      128
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L__main66
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      96
	MOVWF      R4+2
	MOVLW      128
	MOVWF      R4+3
	MOVF       _tensionP+0, 0
	MOVWF      R0+0
	MOVF       _tensionP+1, 0
	MOVWF      R0+1
	MOVF       _tensionP+2, 0
	MOVWF      R0+2
	MOVF       _tensionP+3, 0
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L__main66
	GOTO       L__main65
L__main66:
	GOTO       L_main39
L__main65:
;dechet.c,206 :: 		Lcd_Cmd(_LCD_CLEAR);
	MOVLW      1
	MOVWF      FARG_Lcd_Cmd_out_char+0
	CALL       _Lcd_Cmd+0
;dechet.c,207 :: 		}
L_main39:
;dechet.c,209 :: 		switch (affichage) {
	GOTO       L_main40
;dechet.c,210 :: 		case 0:
L_main42:
;dechet.c,211 :: 		Lcd_Out(1, 1, messages[0]);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _messages+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,212 :: 		BUZZER = 0;
	BCF        RC7_bit+0, BitPos(RC7_bit+0)
;dechet.c,213 :: 		break;
	GOTO       L_main41
;dechet.c,214 :: 		case 1:
L_main43:
;dechet.c,215 :: 		Lcd_Out(1, 1, messages[1]);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _messages+1, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,216 :: 		BUZZER = 0;
	BCF        RC7_bit+0, BitPos(RC7_bit+0)
;dechet.c,217 :: 		LED_GREEN = 1;
	BSF        RC5_bit+0, BitPos(RC5_bit+0)
;dechet.c,218 :: 		LED_RED = 0;
	BCF        RC6_bit+0, BitPos(RC6_bit+0)
;dechet.c,219 :: 		break;
	GOTO       L_main41
;dechet.c,220 :: 		case 2:
L_main44:
;dechet.c,221 :: 		Lcd_Out(1, 1, messages[2]);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _messages+2, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,222 :: 		LED_GREEN = 0;
	BCF        RC5_bit+0, BitPos(RC5_bit+0)
;dechet.c,223 :: 		LED_RED = 0;
	BCF        RC6_bit+0, BitPos(RC6_bit+0)
;dechet.c,224 :: 		BUZZER = 0;
	BCF        RC7_bit+0, BitPos(RC7_bit+0)
;dechet.c,225 :: 		break;
	GOTO       L_main41
;dechet.c,226 :: 		case 3:
L_main45:
;dechet.c,227 :: 		Lcd_Out(1, 1, messages[3]);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _messages+3, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,228 :: 		BUZZER = 0;
	BCF        RC7_bit+0, BitPos(RC7_bit+0)
;dechet.c,229 :: 		LED_GREEN = 0;
	BCF        RC5_bit+0, BitPos(RC5_bit+0)
;dechet.c,230 :: 		LED_RED = 0;
	BCF        RC6_bit+0, BitPos(RC6_bit+0)
;dechet.c,231 :: 		break;
	GOTO       L_main41
;dechet.c,232 :: 		case 4:
L_main46:
;dechet.c,233 :: 		Lcd_Out(1, 1, "ALERTE");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr11_dechet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,234 :: 		LED_GREEN = 1;
	BSF        RC5_bit+0, BitPos(RC5_bit+0)
;dechet.c,235 :: 		LED_RED = 1;
	BSF        RC6_bit+0, BitPos(RC6_bit+0)
;dechet.c,236 :: 		BUZZER = 1;
	BSF        RC7_bit+0, BitPos(RC7_bit+0)
;dechet.c,237 :: 		Delay_ms(50);
	MOVLW      130
	MOVWF      R12+0
	MOVLW      221
	MOVWF      R13+0
L_main47:
	DECFSZ     R13+0, 1
	GOTO       L_main47
	DECFSZ     R12+0, 1
	GOTO       L_main47
	NOP
	NOP
;dechet.c,238 :: 		LED_GREEN = 0;
	BCF        RC5_bit+0, BitPos(RC5_bit+0)
;dechet.c,239 :: 		LED_RED = 0;
	BCF        RC6_bit+0, BitPos(RC6_bit+0)
;dechet.c,240 :: 		break;
	GOTO       L_main41
;dechet.c,241 :: 		case 5:
L_main48:
;dechet.c,242 :: 		Lcd_Out(1, 1, messages[5]);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _messages+5, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,243 :: 		BUZZER = 0;
	BCF        RC7_bit+0, BitPos(RC7_bit+0)
;dechet.c,244 :: 		LED_GREEN = 0;
	BCF        RC5_bit+0, BitPos(RC5_bit+0)
;dechet.c,245 :: 		LED_RED = 0;
	BCF        RC6_bit+0, BitPos(RC6_bit+0)
;dechet.c,246 :: 		break;
	GOTO       L_main41
;dechet.c,247 :: 		case 6:
L_main49:
;dechet.c,248 :: 		Lcd_Out(1, 1, messages[6]);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _messages+6, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,249 :: 		BUZZER = 0;
	BCF        RC7_bit+0, BitPos(RC7_bit+0)
;dechet.c,250 :: 		break;
	GOTO       L_main41
;dechet.c,251 :: 		case 7:
L_main50:
;dechet.c,252 :: 		Lcd_Out(1, 1, messages[7]);
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _messages+7, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,253 :: 		BUZZER = 0;
	BCF        RC7_bit+0, BitPos(RC7_bit+0)
;dechet.c,254 :: 		if (tensionM >= 3.5) {
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      96
	MOVWF      R4+2
	MOVLW      128
	MOVWF      R4+3
	MOVF       _tensionM+0, 0
	MOVWF      R0+0
	MOVF       _tensionM+1, 0
	MOVWF      R0+1
	MOVF       _tensionM+2, 0
	MOVWF      R0+2
	MOVF       _tensionM+3, 0
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSS      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main51
;dechet.c,255 :: 		set_servo_angle(180);
	MOVLW      180
	MOVWF      FARG_set_servo_angle_angle+0
	CALL       _set_servo_angle+0
;dechet.c,256 :: 		Lcd_Out(2, 1, material[0]);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _material+0, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,257 :: 		} else if (tensionP > 2 && tensionP < 3.5) {
	GOTO       L_main52
L_main51:
	MOVF       _tensionP+0, 0
	MOVWF      R4+0
	MOVF       _tensionP+1, 0
	MOVWF      R4+1
	MOVF       _tensionP+2, 0
	MOVWF      R4+2
	MOVF       _tensionP+3, 0
	MOVWF      R4+3
	MOVLW      0
	MOVWF      R0+0
	MOVLW      0
	MOVWF      R0+1
	MOVLW      0
	MOVWF      R0+2
	MOVLW      128
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main55
	MOVLW      0
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVLW      96
	MOVWF      R4+2
	MOVLW      128
	MOVWF      R4+3
	MOVF       _tensionP+0, 0
	MOVWF      R0+0
	MOVF       _tensionP+1, 0
	MOVWF      R0+1
	MOVF       _tensionP+2, 0
	MOVWF      R0+2
	MOVF       _tensionP+3, 0
	MOVWF      R0+3
	CALL       _Compare_Double+0
	MOVLW      1
	BTFSC      STATUS+0, 0
	MOVLW      0
	MOVWF      R0+0
	MOVF       R0+0, 0
	BTFSC      STATUS+0, 2
	GOTO       L_main55
L__main64:
;dechet.c,258 :: 		set_servo_angle(0);
	CLRF       FARG_set_servo_angle_angle+0
	CALL       _set_servo_angle+0
;dechet.c,259 :: 		Lcd_Out(2, 1, material[1]);
	MOVLW      2
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVF       _material+1, 0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,260 :: 		} else {
	GOTO       L_main56
L_main55:
;dechet.c,261 :: 		set_servo_angle(90);
	MOVLW      90
	MOVWF      FARG_set_servo_angle_angle+0
	CALL       _set_servo_angle+0
;dechet.c,262 :: 		}
L_main56:
L_main52:
;dechet.c,263 :: 		Delay_ms(2000);
	MOVLW      21
	MOVWF      R11+0
	MOVLW      75
	MOVWF      R12+0
	MOVLW      190
	MOVWF      R13+0
L_main57:
	DECFSZ     R13+0, 1
	GOTO       L_main57
	DECFSZ     R12+0, 1
	GOTO       L_main57
	DECFSZ     R11+0, 1
	GOTO       L_main57
	NOP
;dechet.c,264 :: 		affichage = 0;
	CLRF       _affichage+0
;dechet.c,265 :: 		break;
	GOTO       L_main41
;dechet.c,266 :: 		case 8:
L_main58:
;dechet.c,267 :: 		Lcd_Out(1, 1, "ALERT COUNT:");
	MOVLW      1
	MOVWF      FARG_Lcd_Out_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Out_column+0
	MOVLW      ?lstr12_dechet+0
	MOVWF      FARG_Lcd_Out_text+0
	CALL       _Lcd_Out+0
;dechet.c,268 :: 		Lcd_Chr(2, 1, (alert_count / 10) + '0');
	MOVLW      2
	MOVWF      FARG_Lcd_Chr_row+0
	MOVLW      1
	MOVWF      FARG_Lcd_Chr_column+0
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _alert_count+0, 0
	MOVWF      R0+0
	MOVF       _alert_count+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      FARG_Lcd_Chr_out_char+0
	CALL       _Lcd_Chr+0
;dechet.c,269 :: 		Lcd_Chr_CP((alert_count % 10) + '0');
	MOVLW      10
	MOVWF      R4+0
	MOVLW      0
	MOVWF      R4+1
	MOVF       _alert_count+0, 0
	MOVWF      R0+0
	MOVF       _alert_count+1, 0
	MOVWF      R0+1
	CALL       _Div_16X16_U+0
	MOVF       R8+0, 0
	MOVWF      R0+0
	MOVF       R8+1, 0
	MOVWF      R0+1
	MOVLW      48
	ADDWF      R0+0, 0
	MOVWF      FARG_Lcd_Chr_CP_out_char+0
	CALL       _Lcd_Chr_CP+0
;dechet.c,270 :: 		LED_GREEN = 0;
	BCF        RC5_bit+0, BitPos(RC5_bit+0)
;dechet.c,271 :: 		LED_RED = 0;
	BCF        RC6_bit+0, BitPos(RC6_bit+0)
;dechet.c,272 :: 		Delay_ms(2000);
	MOVLW      21
	MOVWF      R11+0
	MOVLW      75
	MOVWF      R12+0
	MOVLW      190
	MOVWF      R13+0
L_main59:
	DECFSZ     R13+0, 1
	GOTO       L_main59
	DECFSZ     R12+0, 1
	GOTO       L_main59
	DECFSZ     R11+0, 1
	GOTO       L_main59
	NOP
;dechet.c,273 :: 		affichage = 0;
	CLRF       _affichage+0
;dechet.c,274 :: 		break;
	GOTO       L_main41
;dechet.c,275 :: 		}
L_main40:
	MOVF       _affichage+0, 0
	XORLW      0
	BTFSC      STATUS+0, 2
	GOTO       L_main42
	MOVF       _affichage+0, 0
	XORLW      1
	BTFSC      STATUS+0, 2
	GOTO       L_main43
	MOVF       _affichage+0, 0
	XORLW      2
	BTFSC      STATUS+0, 2
	GOTO       L_main44
	MOVF       _affichage+0, 0
	XORLW      3
	BTFSC      STATUS+0, 2
	GOTO       L_main45
	MOVF       _affichage+0, 0
	XORLW      4
	BTFSC      STATUS+0, 2
	GOTO       L_main46
	MOVF       _affichage+0, 0
	XORLW      5
	BTFSC      STATUS+0, 2
	GOTO       L_main48
	MOVF       _affichage+0, 0
	XORLW      6
	BTFSC      STATUS+0, 2
	GOTO       L_main49
	MOVF       _affichage+0, 0
	XORLW      7
	BTFSC      STATUS+0, 2
	GOTO       L_main50
	MOVF       _affichage+0, 0
	XORLW      8
	BTFSC      STATUS+0, 2
	GOTO       L_main58
L_main41:
;dechet.c,277 :: 		Delay_ms(100);
	MOVLW      2
	MOVWF      R11+0
	MOVLW      4
	MOVWF      R12+0
	MOVLW      186
	MOVWF      R13+0
L_main60:
	DECFSZ     R13+0, 1
	GOTO       L_main60
	DECFSZ     R12+0, 1
	GOTO       L_main60
	DECFSZ     R11+0, 1
	GOTO       L_main60
	NOP
;dechet.c,278 :: 		}
	GOTO       L_main27
;dechet.c,279 :: 		}
L_end_main:
	GOTO       $+0
; end of _main
