/*;--------------------------------------------------
; Frias Muñoz, Ruben
; Grupo: L3
;--------------------------------------------------
*/
#ifndef LCD_H_
#define LCD_H_

void            lcdIni (void);
unsigned int    lcd2aseg (char c, char e);
void            lcdClearAll (void);
void            lcdClear (void);
void            Pintar (char c, char d, int e);
void            lcdClearSW (void);
void            lcdLPut (char c);

#endif /* LCD_H_ */
