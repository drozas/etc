		SYMBOLS

***************************************
* DEFINICIÓN DE SÍMBOLOS EXPORTADOS
***************************************
		XDEF	ORD_VECT
* Registros:
* - A0: se mantiene durante toda la subrutina apuntando al primer elemento del vector
* - A1: apunta al elemento 'X' del vector
* - A2: apunta al elemento 'X+1' del vector
* - D0: Contiene el numero de elementos
* - D1: Actúa en la subrutina como indice del bucle externo
* - D2: Actúa en la subrutina como indice del bucle interno
* - D3 y D4: Almacenan temporalmente los valores del vector, para su comparacion y posible intercambio


***************************************
* SUBRUTINA DE ORDENACIÓN DE UN VECTOR DE TAMAÑO POTENCIA DE 2 MEDIANTE ALGORITMO DEL MÉTODO BURBUJA
***************************************
ORD_VECT	EQU	*
		MOVEA.L	6(SP),A0	Apuntamos con el puntero A0 al vector
		MOVE.W	4(SP),D0	Metemos en D0 el numero de elementos
		SUB.W	#1,D0		Restamos 1 al numero de elementos (los bucles son hasta N-1)
		CLR.L	D1		Inicializamos D1, que será el indice i 
* Bucle externo:
FOR1		EQU	*
		CMP.W	D0,D1		
		BHI	FINFOR1		Si D1 es mayor que N-1 elementos, salimos del bucle externo
		CLR.L	D2		Inicializamos D2, que será el indice j
		MOVEA.L	A0,A1		Ponemos los punteros A1 apuntando al primer elemento del vector
		MOVEA.L	A0,A2		Apuntamos con A2 al vector
		ADDA.L	#4,A2		Apuntamos al segundo elemento del vector [A1 apuntara al elemento 'X', y A2 al 'X+1']
* Bucle interno
FOR2		EQU	*
		CLR.L	D3		Inicializamos los registros D3 y D4. Aquí se almacenaran temporalmente los valores del vector, para su comparación
		CLR.L	D4		
		CMP.W	D0,D2
		BHI	FINFOR2		Si D2 (indice j) es mayor que N-1 elementos, salimos del bucle interno
		MOVE.L	(A1),D3		Metemos el elemento de posicion 'X' en D3
		MOVE.L	(A2),D4		Y el elemento de posicion 'X+1' en D4
		CMP.L	D4,D3
		BLE	NOINTER		Si [X]<=[X+1], entonces ya está ordenado
		MOVE.L	D4,(A1)		Y si no hay que intercambiarlo
		MOVE.L	D3,(A2)
NOINTER		EQU	*
		ADDA.L	#4,A1		Haya o no intercambio, hay que aumentar los punteros
		ADDA.L	#4,A2
		ADD.W	#1,D2		Y el indice j
		BRA	FOR2
FINFOR2		EQU	*
		ADD.W	#1,D1		Y cuando salgamos del bucle interno; hay que aumentar también el índice el bucle externo
		BRA	FOR1
FINFOR1		EQU	*
		RTS
		END
