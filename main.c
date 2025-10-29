#include <msp430.h>
#include <cs.h>
#include <lcd.h>
#include <syst.h>
//;------------------------------------------------
//; Frias Muñoz, Ruben
//; Grupo: L3
//;--------------------------------------------------
char mensaje[] = " Realizado por: Ruben Frias Munoz ";
void pausa_debounce(void)
{
//pausas para rebotes
    // volatile es para que el compilador no elimine el bucle.
    volatile int i;
    i = 0;
    for (i = 0; i < 20000; i++)
    {
    }
}
void pausa(void)
{
    volatile int i;
    for (i = 0; i < 30000; i++)
    {
    }
}
void pausa_milisegundos(unsigned int ms)
{
    long tiempo_inicial = systTim();
    while ((systTim() - tiempo_inicial) < ms);
}
void CambiaLCD(long numero, int estado) {
    int char1, char2;
    if (numero < 0) {
        numero = -numero;
    }
    char2 = '0' + (numero % 10);
    char1 = '0' + ((numero / 10) % 10);
    Pintar(char1, char2, estado);
}

long GeneraNum()
{
    long objetivo;
    int variable_local_para_aleatoriedad = 0;

    objetivo = (systTim() & 0xFFFF) + (long)&variable_local_para_aleatoriedad;
    objetivo = objetivo & 0xFF;

    while (objetivo > 99)
    {
        objetivo = (objetivo / 2) + (systTim() & 0x01);
    }
    if (objetivo < 10)
    {
        objetivo = objetivo + 10;
    }
    return objetivo;
}

long Midetsw2 (){
    long TpulsacionS2;
    TpulsacionS2 = systTim();
    return TpulsacionS2;
}
void AnimaIco(void) {
    static char *p = mensaje;
    static int contador = 0;

            lcdLPut(p[contador]);
            contador++;
            if (p[contador] == 0)
            {
             lcdClear();
             contador = 0;
             }
}

int main(void)
{
    WDTCTL = WDTPW | WDTHOLD;
    PM5CTL0 &= ~LOCKLPM5;

    pulsIni();
    systIni(256);
    lcdIni();
    csIniLf();

    // Bucle de bienvenida
    while (puls() != 1){
        AnimaIco();
        pausa();
    }
    // Una pausa aqu  para limpiar el primer evento de SW1
    pausa_debounce();

    while (1){
        long objetivo, tfinal, tinicial, Diferencia, Resultado;

        // numero aleatorio
        lcdClearAll();
        objetivo = GeneraNum();
        CambiaLCD(objetivo, 1);
        //pausa_debounce(); // Pausa  para estabilizar la primera generaci n

        // varios intentos
        while(1) {

            //  SW1 para nuevo n mero, SW2 para medir
            while(1) {
                int estado_pulsador = puls();
                if (estado_pulsador == 1) { // SW1: Generar nuevo n mero
                    //pausa_debounce;
                    pausa_milisegundos(10);
                    objetivo = GeneraNum();
                    CambiaLCD(objetivo, 1);
                    lcdClearSW(); // Borramos los resultados anterior

                    // Pausa para evitar que el rebote al soltar genere otro n mero.
                    //pausa_debounce();
                    pausa_milisegundos(10);
                } else if (estado_pulsador == 3) { // SW2: Empezar a medir
                    //pausa_debounce();
                    pausa_milisegundos(10);
                    break; // Salimos para iniciar la medici n
                }
            }

            // Inicia la medici n con SW2
            tinicial = Midetsw2();
            lcdClearSW();

            // Espera a que se suelte SW2
            while (puls() != 2){
            }
            //pausa_debounce();
            pausa_milisegundos(10);
            tfinal = Midetsw2();
            Diferencia = (tfinal - tinicial) / 128;
            Resultado = (Diferencia - objetivo);
            if (Resultado < 0){
                LCDM11 = 0b00000100;
            }

            CambiaLCD(Diferencia, 2);
            CambiaLCD(Resultado, 3);
        }
    }
    return 0;
}
