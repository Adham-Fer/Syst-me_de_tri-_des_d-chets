#line 1 "C:/Users/adham/Music/code_dechet/dechet.c"

sbit LCD_RS at RD4_bit;
sbit LCD_EN at RD5_bit;
sbit LCD_D4 at RD0_bit;
sbit LCD_D5 at RD1_bit;
sbit LCD_D6 at RD2_bit;
sbit LCD_D7 at RD3_bit;

sbit LCD_RS_Direction at TRISD4_bit;
sbit LCD_EN_Direction at TRISD5_bit;
sbit LCD_D4_Direction at TRISD0_bit;
sbit LCD_D5_Direction at TRISD1_bit;
sbit LCD_D6_Direction at TRISD2_bit;
sbit LCD_D7_Direction at TRISD3_bit;


sbit SERVO_PWM at RC2_bit;
sbit SERVO_PWM_Direction at TRISC2_bit;

sbit LED_GREEN at RC5_bit;
sbit LED_RED at RC6_bit;
sbit LED_GREEN_Direction at TRISC5_bit;
sbit LED_RED_Direction at TRISC6_bit;


sbit BUTTON_START at RB0_bit;
sbit BUTTON_CANCEL at RB4_bit;
sbit BUTTON_PAUSE at RB5_bit;
sbit BUTTON_ALERTE at RB6_bit;
sbit BUTTON_VEILLE at RB7_bit;

sbit BUTTON_START_Direction at TRISB0_bit;
sbit BUTTON_CANCEL_Direction at TRISB4_bit;
sbit BUTTON_PAUSE_Direction at TRISB5_bit;
sbit BUTTON_ALERTE_Direction at TRISB6_bit;
sbit BUTTON_VEILLE_Direction at TRISB7_bit;

sbit BUTTON_CONFIRM at RA4_bit;
sbit BUTTON_CONFIRM_Direction at TRISA4_bit;

sbit BUTTON_EEPROM at RB3_bit;
sbit BUTTON_EEPROM_Direction at TRISB3_bit;


sbit BUZZER at RC7_bit;
sbit BUZZER_Direction at TRISC7_bit;


char *messages[] = {
 "SYS PRET", "TRI COURS", "TRI ANNULE", "SYS PAUSE",
 "ERR:VERIF", "SYS VEILLE", "CONFIRMER", "TRI OK"
};
char *material[] = {"METAL", "PLAST"};

unsigned int adc_value_P, adc_value_M;
float tensionP, tensionM;
unsigned char affichage = 0, timer_counter = 0;
bit awaiting_confirmation;
unsigned int alert_count;

void setup_pwm() {
 SERVO_PWM_Direction = 0;
 PR2 = 249;
 CCP1CON = 0x0C;
 CCPR1L = 0;
 T2CON = 0x06;
 TMR2ON_bit = 1;
}

void set_servo_angle(unsigned char angle) {
 unsigned char duty;
 switch (angle) {
 case 0: duty = 31; break;
 case 90: duty = 94; break;
 case 180: duty = 156; break;
 default: duty = 94; break;
 }
 CCPR1L = duty >> 2;
 CCP1CON = 0x0C | ((duty & 0x03) << 4);
}

void save_alert_count_to_eeprom() {
 EEPROM_Write(0x00, alert_count >> 8);
 EEPROM_Write(0x01, alert_count & 0xFF);
}

void load_alert_count_from_eeprom() {
 unsigned char high_byte = EEPROM_Read(0x00);
 unsigned char low_byte = EEPROM_Read(0x01);
 alert_count = (high_byte << 8) | low_byte;
}

void interrupt() {
 if (INTCON.T0IF && INTCON.T0IE) {
 if (++timer_counter >= 76) {
 if (awaiting_confirmation) {
 affichage = 0;
 awaiting_confirmation = 0;
 }
 timer_counter = 0;
 INTCON.T0IE = 0;
 }
 TMR0 = 0;
 INTCON.T0IF = 0;
 }

 if (INTCON.INTF && INTCON.INTE) {
 affichage = 1;
 INTCON.INTF = 0;
 }

if (INTCON.RBIF && INTCON.RBIE) {
 PORTB;
 if (BUTTON_CANCEL) affichage = 2;
 else if (BUTTON_PAUSE) affichage = 3;
 else if (BUTTON_ALERTE) {
 affichage = 4;
 alert_count++;
 save_alert_count_to_eeprom();
 } else if (BUTTON_VEILLE) affichage = 5;
 else if (BUTTON_EEPROM) affichage = 8;

 INTCON.RBIF = 0;
}
}

void main() {
 TRISA = 0xFF;
 TRISB = 0xFF;
 TRISC = 0x00;
 TRISD = 0x00;

 LCD_RS_Direction = 0;
 LCD_EN_Direction = 0;
 LCD_D4_Direction = 0;
 LCD_D5_Direction = 0;
 LCD_D6_Direction = 0;
 LCD_D7_Direction = 0;

 SERVO_PWM_Direction = 0;
 LED_GREEN_Direction = 0;
 LED_RED_Direction = 0;
 BUZZER_Direction = 0;

 BUTTON_START_Direction = 1;
 BUTTON_CONFIRM_Direction = 1;
 BUTTON_CANCEL_Direction = 1;
 BUTTON_PAUSE_Direction = 1;
 BUTTON_ALERTE_Direction = 1;
 BUTTON_VEILLE_Direction = 1;
 BUTTON_EEPROM_Direction = 1;

 LED_GREEN = 0;
 LED_RED = 0;
 BUZZER = 0;
 awaiting_confirmation = 0;

 OPTION_REG = 0x07;
 INTCON.INTEDG = 1;
 INTCON.GIE = 1;
 INTCON.INTE = 1;
 INTCON.RBIE = 1;
 INTCON.T0IE = 0;
 INTCON.T0IF = 0;

 ADCON1 = 0x80;
 ADCON0 = 0x09;

 Lcd_Init();
 setup_pwm();

 Lcd_Cmd(_LCD_CLEAR);
 Lcd_Cmd(_LCD_CURSOR_OFF);

 load_alert_count_from_eeprom();
 Lcd_Out(1, 1, messages[0]);
 Delay_ms(200);

 while (1) {
 adc_value_P = ADC_Get_Sample(2);
 tensionP = (adc_value_P * 5.0) / 1023.0;
 adc_value_M = ADC_Get_Sample(3);
 tensionM = (adc_value_M * 5.0) / 1023.0;

 if (BUTTON_CONFIRM) {
 if (!awaiting_confirmation) {
 affichage = 6;
 awaiting_confirmation = 1;
 timer_counter = 0;
 TMR0 = 0;
 INTCON.T0IE = 1;
 } else {
 affichage = 7;
 awaiting_confirmation = 0;
 INTCON.T0IE = 0;
 timer_counter = 0;
 }
 while (BUTTON_CONFIRM);
 }

 if (BUTTON_EEPROM) {
 affichage = 8;
 }

 if (affichage != 7 || (tensionM >= 3.5 && tensionP > 2 && tensionP < 3.5)) {
 Lcd_Cmd(_LCD_CLEAR);
 }

 switch (affichage) {
 case 0:
 Lcd_Out(1, 1, messages[0]);
 BUZZER = 0;
 break;
 case 1:
 Lcd_Out(1, 1, messages[1]);
 BUZZER = 0;
 LED_GREEN = 1;
 LED_RED = 0;
 break;
 case 2:
 Lcd_Out(1, 1, messages[2]);
 LED_GREEN = 0;
 LED_RED = 0;
 BUZZER = 0;
 break;
 case 3:
 Lcd_Out(1, 1, messages[3]);
 BUZZER = 0;
 LED_GREEN = 0;
 LED_RED = 0;
 break;
 case 4:
 Lcd_Out(1, 1, "ALERTE");
 LED_GREEN = 1;
 LED_RED = 1;
 BUZZER = 1;
 Delay_ms(50);
 LED_GREEN = 0;
 LED_RED = 0;
 break;
 case 5:
 Lcd_Out(1, 1, messages[5]);
 BUZZER = 0;
 LED_GREEN = 0;
 LED_RED = 0;
 break;
 case 6:
 Lcd_Out(1, 1, messages[6]);
 BUZZER = 0;
 break;
 case 7:
 Lcd_Out(1, 1, messages[7]);
 BUZZER = 0;
 if (tensionM >= 3.5) {
 set_servo_angle(180);
 Lcd_Out(2, 1, material[0]);
 } else if (tensionP > 2 && tensionP < 3.5) {
 set_servo_angle(0);
 Lcd_Out(2, 1, material[1]);
 } else {
 set_servo_angle(90);
 }
 Delay_ms(2000);
 affichage = 0;
 break;
 case 8:
 Lcd_Out(1, 1, "ALERT COUNT:");
 Lcd_Chr(2, 1, (alert_count / 10) + '0');
 Lcd_Chr_CP((alert_count % 10) + '0');
 LED_GREEN = 0;
 LED_RED = 0;
 Delay_ms(2000);
 affichage = 0;
 break;
 }

 Delay_ms(100);
 }
}
