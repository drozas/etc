		SYMBOLS

***************************************
* DEFINICIÓN DE SÍMBOLOS IMPORTADOS
***************************************

		XREF	LEE_ENT,ESC_RES

***************************************
* DEFINICIÓN DE SÍMBOLOS EXPORTADOS
***************************************
		XDEF	DIVIDENDO,DIVISOR,COCIENTE,RESTO

***************************************
* ZONA DE DATOS GLOBALES DEL PROGRAMA
***************************************
		ORG	$1000
VAR		EQU	*
DIVIDENDO	DS	2
DIVISOR		DS	2
COCIENTE	DS	2
RESTO		DS	2
I		DS	2
* Registros:
* - D0 se utiliza como variable temporal (TMP del pseudocódigo en Pascal)
* - D1 contiene el valor absoluto del divisor (DVSR_ABS del pseudocódigo en Pascal)
* - D2 contiene el valor absoluto del dividendo 
***************************************
* PROGRAMA PRINCIPAL
***************************************

* Código de inicio del programa
*    1. Asignar etiqueta
		ORG	$1000
BEGIN		EQU	*
*    2. Iniciar puntero de pila
		LEA	$0000A000,SP

* Pedir el dividendo y el divisor por teclado
		JSR	LEE_ENT
* Obtención del valor absoluto de divisor
		CLR.L	D0
		CLR.L	D1
		CLR.L	D2
		MOVE.W	DIVISOR,D1
		TST.W 	D1
		BPL	ESPOS
		NEG.w	D1
ESPOS		EQU	*
* Obtención del valor absoluto del dividendo
		MOVE.W	DIVIDENDO,D2
		TST.W	D2
		BPL	ESPOS2
		NEG.w	D2
ESPOS2		EQU	*
*Paso de valores al registro temporal: pasamos el dividendo absoluto a la parte 0..15; y la parte 16..31 ya esta a 0
		MOVE.W	D2,D0
*Inicializacion de i, y comienzo del bucle
		CLR.W	I
FOR		EQU	*
		CMP.W	#15,I
		BHI	FINFOR
		ASL.L	#1,D0
		SWAP	D0
		SUB.W	D1,D0
IF		EQU	*
		TST.W	D0
		BPL	ELSE

		SWAP	D0
		BCLR	#0,D0
		SWAP	D0
		ADD.W	D1,D0
		SWAP	D0
		BRA	ENDIF
ELSE		EQU	*
		SWAP	D0
		BSET	#0,D0
ENDIF		EQU	*
		ADD.W	#1,I
		BRA	FOR
FINFOR		EQU	*

* Paso de los valores de la variable temporal, a las variables cociente y resto
		MOVE.W	D0,COCIENTE
		SWAP	D0
		MOVE.W	D0,RESTO

* Y ahora falta hacer las comprobaciones de los signos
* El signo del resto es igual que el del dividendo, luego...
		TST.W	DIVIDENDO
		BPL	NOCAMRESTO	si es positivo, saltamos para dejarlo igual
		NEG.W	RESTO		Y si no, lo cambiamos
NOCAMRESTO	EQU	*
* Respecto al signo del cociente, si son iguales permanece igual, y si no hay que invertirlo...
		TST.W	DIVIDENDO
		BPL	DIVDPOS		Si el dividendo es positivo, saltamos
		TST.W	DIVISOR		Si no, el dividendo es negativo. Y hay q comprobar el signo del divisor
		BMI	IGUALES		Si tambien es negativo, entonces ambos son iguales
		NEG.W	COCIENTE	Si no, tenemos que invertirlos...
		BRA	FINCOMP
DIVDPOS		EQU	*		Si hemos llegado a este punto, es porque el dividendo es positivo
		TST.W	DIVISOR		Asi que, comprobamos el divisor
		BPL	IGUALES		Si tambien es positivo, son iguales, y no hay que modificarlo
		NEG.W	COCIENTE	Si no el divisor es negativo, luego los signos son diferentes. Asi que hay que cambiar el signo del cociente
		BRA	FINCOMP
IGUALES		EQU 	*		Si son iguales, no hay que hacer inversiones...
FINCOMP		EQU	*

	

* Escribir el resultado por pantalla
		JSR	ESC_RES

* Código de finalización del programa
		MOVE.B	#9,D0
		TRAP	#15

		END	BEGIN
