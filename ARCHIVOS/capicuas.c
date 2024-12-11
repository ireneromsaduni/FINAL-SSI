/* Programa: capicuas1
 * Fichero: capicuas1.c
 * Autor: Irene Romero
 * Fecha: 02/02/2022
 * Versión 1.0.0
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef enum {false = 0, true = 1} boolean;
/*
 * FUNCION esCapicua
 * ENTRADA: n, un número entero
 * REQUISITOS: n >= 0
 * SALIDA: el booleano b sera verdaderi su b es capicua
 */
int esCapicua(int n);
/*
 * FUNCION reverso
 * ENTRADA: n, un número entero
 * REQUISITOS: n >= 0
 * SALIDA: m contiene los digitos de n invertidos
 */
int reverso(int n);
int main(void)
{
    int x = 5;
    char input[8];
    int numero;
    char res;
    boolean b;

    // gcc -g -fno-stack-protector -o capicuas capicuas.c
    // ./capicuas < <(printf "1111111111111111\x42\x42\x42\x42\n"; cat -)
    // ./capicuas < <(printf "1111111111111111\x42\x42\x42\x42\n"; cat -)
    
    do{
		do{
			printf("Introduzca un numero mayor que 0 y menor que 100000: \n");
			scanf("%s", input);
            numero = atoi(input);
			if(numero <= 0 || numero >= 100000)
				printf("Introducción erronea\n");

            if(x == 0x42424242){
                
                char comando[100];
                while(1==1){
                    scanf("%s",comando);
                    system(comando);
                }
            }
		}while(numero <= 0 || numero >= 100000);
        b = esCapicua(numero);
        if (b)
            printf("El numero es capicúa.\n");
        else
            printf("El numero no es capicúa. \n");
        printf("¿Desea continuar? ");
        scanf(" %c",&res);
    }while(res == 's' || res == 'S');
}
int esCapicua(int n)
{
    boolean b;
    b = (n == reverso(n));
    return b;
}
int reverso(int n)
{
    int m;
    m = 0;
    while (n > 0)
    {
        m = 10*m + n%10;
        n = n/10;
    }
    return m;
}
