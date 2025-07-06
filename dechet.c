// =============================================================================
//                             SMART ENERGY MONITOR
//          (Version ajustée selon le code de référence fonctionnel)
// =============================================================================
// MCU: PIC16F877
// Oscillator: 4.0 MHz
// =============================================================================

// -- LCD Module Connections --
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

// -- Pin Declarations --
sbit BUZZER at RC0_bit;
sbit AUTO_MODE_BTN at RB0_bit;
sbit DEVICE_SWITCH at RB4_bit;
sbit REPORT_BTN at RA4_bit; // Bouton rapport, comme demandé

// -- Thresholds --
#define CONSUMPTION_THRESHOLD 70 // 70%
#define HIGH_TEMP_THRESHOLD 30.0 // 30.0 degrés Celsius
#define LOW_TEMP_THRESHOLD  20.0 // 20.0 degrés Celsius

// -- Global Variables --
unsigned int current_consumption = 0;
unsigned int alert_count = 0;
float temperature = 0.0;
unsigned int adc_result;

// -- Flags --
bit auto_mode_enabled;
bit device_status;

// -- Function Prototypes --
void initialize_system();
void read_sensors();
void handle_logic_and_alerts();
void update_display();
void display_report();
void save_alert_count_to_eeprom();
void load_alert_count_from_eeprom();
void display_auto_mode_message();
void handle_buttons();


// =============================================================================
//                               MAIN FUNCTION
// =============================================================================
void main() {
    initialize_system();

    while (1) {
        // Tâche 1: Lire les capteurs de manière séquentielle et simple
        read_sensors();

        // Tâche 2: Gérer les appuis sur les boutons
        handle_buttons();

        // Tâche 3: Gérer la logique du programme (seuils, alertes)
        // seulement si l'appareil est activé
        if(device_status) {
           handle_logic_and_alerts();
        }

        // Tâche 4: Mettre à jour l'écran LCD
        update_display();

        Delay_ms(250); // Délai principal de la boucle
    }
}


// =============================================================================
//                          SYSTEM INITIALIZATION
// =============================================================================
void initialize_system() {
    // Configuration des ports
    TRISA = 0b00010011; // RA0 (courant), RA1 (temp), RA4 (rapport) en entrée
    TRISB = 0b00010001; // RB0 (auto), RB4 (switch) en entrée
    TRISC = 0b00000000; // RC0 (Buzzer) en sortie
    TRISD = 0b00000000; // PORTD (LCD) en sortie

    // Configuration de l'ADC.
    // ADCON1 = 0x85 configure RA0/AN0 et RA1/AN1 en analogique,
    // et garde RA4 comme une entrée digitale. C'est essentiel.
    ADCON1 = 0x85;

    // Initialisation des variables
    device_status = 1;      // Appareil activé par défaut
    auto_mode_enabled = 0;
    BUZZER = 0;

    // Initialisation du LCD
    Lcd_Init();
    Lcd_Cmd(_LCD_CLEAR);
    Lcd_Cmd(_LCD_CURSOR_OFF);
    Lcd_Out(1, 3, "SMART ENERGY");
    Delay_ms(2000);

    // Chargement du nombre d'alertes depuis l'EEPROM
    load_alert_count_from_eeprom();
}

// =============================================================================
//                       LECTURE DES CAPTEURS (Style simple)
// =============================================================================
void read_sensors() {
    // Lecture du capteur de courant (Canal 0, RA0)
    adc_result = ADC_Read(0);
    current_consumption = (unsigned long)adc_result * 100 / 1023;

    // Lecture du capteur de température (Canal 1, RA1)
    adc_result = ADC_Read(1);
    // Formule pour LM35: (ADC_Value * 5000mV / 1024) / 10mV/°C
    temperature = (adc_result * 4.88) / 10.0;
}

// =============================================================================
//                            GESTION DES BOUTONS
// =============================================================================
void handle_buttons(){
    // Gestion de l'interrupteur ON/OFF (RB4)
    if (!DEVICE_SWITCH) {
        if(device_status == 1){ // Si on vient de le basculer
           Lcd_Cmd(_LCD_CLEAR);
           Lcd_Out(1, 1, "Appareil OFF");
           Delay_ms(1000);
        }
        device_status = 0;
    } else {
        device_status = 1;
    }

    // Gestion du bouton Mode Auto (RB0)
    if (!AUTO_MODE_BTN && device_status) {
        Delay_ms(100); // Anti-rebond
        auto_mode_enabled = !auto_mode_enabled; // Basculer le mode
        while(!AUTO_MODE_BTN); // Attendre le relâchement
    }

    // Gestion du double appui sur le bouton Rapport (RA4)
    if (!REPORT_BTN && device_status) {
        Delay_ms(200); // Anti-rebond
        // Vérifie un 2ème appui dans une fenêtre de 300ms
        if(Button(&PORTA, 4, 300, 0)){
            display_report();
        }
        while(!REPORT_BTN);
    }
}


// =============================================================================
//                   LOGIQUE DU SYSTÈME ET GESTION DES ALERTES
// =============================================================================
void handle_logic_and_alerts() {
    static bit alert_active = 0;

    // 1. Gestion de la surconsommation
    if (current_consumption > CONSUMPTION_THRESHOLD) {
        if (!alert_active) {
            BUZZER = 1;
            Lcd_Cmd(_LCD_CLEAR);
            Lcd_Out(1, 1, "Limite atteinte!");
            Delay_ms(1000);
            BUZZER = 0;
            alert_count++;
            save_alert_count_to_eeprom();
            alert_active = 1;
        }
    } else {
        alert_active = 0; // Réinitialise le flag d'alerte
    }

    // 2. Gestion du mode automatique
    if (auto_mode_enabled) {
        display_auto_mode_message();
    }
}

// =============================================================================
//                       AFFICHAGE SUR L'ÉCRAN LCD
// =============================================================================
void update_display() {
    char cons_txt[] = "   %";
    char temp_txt[] = "  . C";
    int temp_int = temperature * 10;

    if(!device_status) return; // Ne rien afficher si l'appareil est éteint

    Lcd_Cmd(_LCD_CLEAR);

    // Affichage de la consommation (conversion manuelle)
    cons_txt[0] = (current_consumption / 100) % 10 + '0';
    cons_txt[1] = (current_consumption / 10) % 10 + '0';
    cons_txt[2] = current_consumption % 10 + '0';
    if(cons_txt[0] == '0') { cons_txt[0] = ' '; if(cons_txt[1] == '0') cons_txt[1] = ' '; }

    Lcd_Out(1, 1, "Conso:");
    Lcd_Out(1, 8, cons_txt);

    // Affichage de la température (conversion manuelle)
    temp_txt[0] = (temp_int / 100) % 10 + '0';
    temp_txt[1] = (temp_int / 10) % 10 + '0';
    temp_txt[3] = temp_int % 10 + '0';
    if(temp_txt[0] == '0') temp_txt[0] = ' ';

    Lcd_Out(2, 1, "Temp:");
    Lcd_Out(2, 7, temp_txt);
    Lcd_Chr(2,13,223); // Symbole degré
}

void display_auto_mode_message() {
    Lcd_Cmd(_LCD_CLEAR);
    if (temperature > HIGH_TEMP_THRESHOLD && current_consumption < CONSUMPTION_THRESHOLD) {
        Lcd_Out(1, 1, "Ouvrir climatiseur");
    } else if (temperature < LOW_TEMP_THRESHOLD && current_consumption < CONSUMPTION_THRESHOLD) {
        Lcd_Out(1, 1, "Ouvrir chauffage");
    } else {
        Lcd_Out(1, 1, "Mode auto");
    }
    Delay_ms(1500); // Montrer le message pendant 1.5s
}

void display_report() {
    char count_txt[] = "  "; // Pour 2 chiffres max
    Lcd_Cmd(_LCD_CLEAR);
    Lcd_Out(1, 1, "Nb Alertes:");

    count_txt[0] = (alert_count / 10) % 10 + '0';
    count_txt[1] = alert_count % 10 + '0';
    Lcd_Out(1, 13, count_txt);

    Delay_ms(2500);
}

// =============================================================================
//                           GESTION DE L'EEPROM
// =============================================================================
// Correction selon votre code de référence : sauvegarde sur 2 octets
void save_alert_count_to_eeprom() {
    EEPROM_Write(0x00, alert_count >> 8);   // Octet de poids fort
    EEPROM_Write(0x01, alert_count & 0xFF); // Octet de poids faible
}

void load_alert_count_from_eeprom() {
    unsigned char high_byte, low_byte;
    high_byte = EEPROM_Read(0x00);
    low_byte = EEPROM_Read(0x01);
    alert_count = (high_byte << 8) | low_byte;
}