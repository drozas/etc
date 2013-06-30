***************************************
* Subrutina FADDS: emula el comportamiento del coprocesador M68882, permitiendo la
* suma de numeros en coma flotante, con el estandar IEE754
***************************************

	SYMBOLS

***************************************
* DEFINICIÓN DE SÍMBOLOS EXPORTADOS
*************************************
		XDEF	FADDS

***************************************
* SUBRUTINA DE SUMA DE DOS NÚMEROS EN COMA FLOTANTE IEEE 754 DE PRECISIÓN SIMPLE
***************************************
FADDS		EQU	*
* Parámetros
FADDS_SUM1	SET	16
FADDS_SUM2	SET	12
FADDS_RES	SET	8
* Variables locales: se reserva espacio mediante la instrucción link
EXP_S1		EQU     -1
EXP_S2		EQU     -2
MAN_S1		EQU	-6
MAN_S2		EQU	-10
                                            
                LINK A6,#-10                	Preparamos marco de pila
* Descomposición del primer sumando en IEE754 en sus campos:

		MOVEM.L D0-D4,-(SP)		Salvaguardamos los registros
                MOVE.L  FADDS_SUM1(A6),-(SP)	Metemos el sumando1 en la pila
                PEA     MAN_S1(A6)		En MAN_S1 se guardara la mantisa del primero, una vez descompuesto
                PEA     EXP_S1(A6)		Y en EXP_S1 el exponente, una vez descompuesto
                JSR     FSPLITS			Y llamamos a FSPLITS, para descomponerlo
                ADDA.L  #12,SP			Limpiamos la pila

* Descomposición del segundo sumando en IEE754 en sus campos:

                MOVE.L  FADDS_SUM2(A6),-(SP)	Metemos el sumando2 en la pila
                PEA     MAN_S2(A6)		En MAN_S2 se guardara la mantisa del segundo
                PEA     EXP_S2(A6)		En EXP_S2 la exponente del segundo
                JSR     FSPLITS			Llamada a FSPLITS, para descomponerlo
                ADDA.L  #12,SP			Y limpiamos la pila.

* Transformaciones de formato en los exponentes: 

                MOVE.B  EXP_S1(A6),D2		Movemos el exponente1 a D2 (donde se tiene que albergar para la subrutina
                JSR     E127_C2_B		Lo transformamos A C2
                MOVE.W  D2,D7			Y lo guardamos temporalmente en D7 (.w, porque es el tamaño en el q se devuelve)
                MOVE.B  EXP_S2(A6),D2		Movemos el exponente2 a D2 (donde se tiene que albergar para la subrutina)
                JSR     E127_C2_B		Lo tranformamos a C2
		MOVE.W	D2,D3			Guardamos el exponente del S2 en D3.W
		MOVE.W	D7,D2			Y el exponente del S1 en D3

* Movimiento de las mantisas a los registros:
                MOVE.L  MAN_S1(A6),D0		Guardamos la primera mantisa en D0
                MOVE.L  MAN_S2(A6),D1		Y la segunda en D1

* Llegados a este punto, el contenido de los registros es:
* D0.L-> mantisa del N1; D1.L-> mantisa del N2; D2.W-> exponente del N1; D3.W-> exponente del N2

* Comparación de exponentes:
                CMP.W   D3,D2 
                BGE     EXP1_MAYOR		Si el primer exponente es mayor o igual, saltamos.
                MOVE.L  D0,D4			Si no, intercambiamos las mantisas utilizando D4 como auxiliar.
                MOVE.L  D1,D0
                MOVE.L  D4,D1
                MOVE.W  D3,D4			E intercambiamos los exponentes: usando D4 de nuevo como auxiliar
                MOVE.W  D2,D3
                MOVE.W  D4,D2

* Llegados a este punto, el contenido de los registros es:
* D0.L -> mantisa del num de mayor exponente; D1.L -> mantisa del num de menor exponente;
* D2.W -> exponente del num de mayor exponente; D3.W -> exponente del num de menor exponente

EXP1_MAYOR      EQU	*
		MOVE.W  D2,D4               	Movemos D2 a D4
                CMPI.B  #$80,D3             	Comprobamos el exponente del menor, para ver si es un infinito o un NAN
                BNE     NI_INF_NI_NAN       	Si no lo es, saltamos 
                MOVE.W  D3,D2               	Si es un NAN, movemos el exponente a D2
                BRA     COMPONER_RES        	Y saltamos para componer el resultado
NI_INF_NI_NAN	EQU	*
                AND.L   #$0000FFFF,D4       	Borramos los bits a 0 de D4
                SUB.W   D3,D4               	Obtenemos la diferencia de exponentes
                SUB.W   #1,D4               	Y le restamos uno
                BLT     FIN_ALIN          	Si es menor que 0, no hay que alinear
                JSR     SALV_SIGN_L       	Y si hay que desplazar, guardamos el signo
FOR_ALIN	EQU	*
                LSR.L   D1              	Desplazamos la mantisa del menor
                DBF     D4,FOR_ALIN     	
                JSR     RES_SIG_L       	Llamamos a RES_SIG_L
FIN_ALIN	EQU	*
                MOVE.L  D0,D4           	Movemos D0 a D4
                JSR     MS_C2_B         	LLamamos a MS_C2_B
                MOVE.L  D1,D0           	Movemos D1 a D0
                MOVE.L  D4,D1           	Movemos D4 a D1
                JSR     MS_C2_B         	Llamamos a MS_C2_b
                ADD.L   D0,D1           	Sumamos, y ya tenemos en D1 la mantisa
                JSR     MS_C2_B         	Llamamos a MS_C2_B

* Normalización y redondeo de mantisa
                JSR     NORM_MANT_L     
                JSR     ROUND_MANT_L    

* Llegados a este punto se procede a la recomposición del numero.
* El contenido de los registros es: D2.W-> exponente del resultado (en C2!); D1.L-> mantisa del resultado
COMPONER_RES    EQU	*
		JSR     C2_E127_B       	Tenemos que pasar el exponente a Ea127
                MOVE.L  D1,-(SP)        	Guardamos la mantisa en la pila
                MOVE.W  D2,-(SP)       		Guardamos el exponente en la pila
                MOVE.L  FADDS_RES(A6),-(SP)  	Metemos en la pila la variable resultado
                JSR     FMERGES         	Hacemos la llamada a la subrutina de recomposicion
                ADDA.L  #10,SP         		Limpiamos la pila 
                MOVEM.L (SP)+,D0-D4     	Recuperamos los registros
                UNLK    A6              	Cerramos el marco de pila
		RTS
                
**********************
*
*A continuación se incluye el código de las subrutinas FSPLITS y FMERGES
* No es obligatorio usarlas si no se desea
*
**********************
**********************
*
*PROCEDIMIENTO PARA DESCOMPONER UN NUMERO EN IEEE 754 DE PRECISIÓN SIMPLE
* DADO EN NOTACIÓN COMPACTA HEXADECIMAL EN SUS CAMPOS DE MANTISA Y EXPONENTE
*
**********************
* Argumentos
*   1: número en binario con todos sus campos (4 octetos)
* 2: dirección donde se guardarán la mantisa y el signo en módulo y signo (4 octetos)
*   3: dirección donde se almacenará el exponente en exceso a 127 (4 octetos)
*********************
* La mantisa ocupará 32 bits, y estará en la forma s0X'bbbbbbb...b, donde
*     s es el bit de signo
*   X es el bit de la parte entera (si la mantisa está normalizada, X=1;
*                                     si está sin normalizar, X=0)
*     Hay 29 dígitos fraccionarios
**********************
FSPLITS         EQU     *
COMPACTO        SET     16
MANTISA         SET     12
EXPONENTE       SET     8
                LINK    A6,#0
		MOVEM.L	A5/D4/D5/D6/D7,-(SP)
* Extraer exponente y ponerlo en D7
		MOVE.L	COMPACTO(A6),D7
		ANDI.L	#$7F800000,D7
		MOVE.L	#23,D5
		LSR.L	D5,D7
* Extraer modulo de la mantisa y ponerlo en D6 y D5
		MOVE.L	COMPACTO(A6),D6
		ANDI.L	#$007FFFFF,D6
		LSL.L	#6,D6
		MOVE.L	D6,D5
* Poner bit de signo si el número es negativo
		MOVE.L	COMPACTO(A6),D4
		BTST	#31,D4
		BEQ	TST_EXP
		BSET	#31,D6
* Si el exponente es nulo, estamos ante un caso especial
TST_EXP		EQU	*
		TST.B	D7
		BNE	EXP_NO_NULO
*Si el exponente es nulo y la mantisa también, devolvemos todo a 0 excepto quiza el signo
EXP_NULO	EQU	*
		TST.L	D5
		BEQ	SEGUIR
*Si el exponente es nulo y la mantisa no, sumamos 1 al exponente para dejarlo en E127
		ADDQ.B	#1,D7
		BRA	SEGUIR
* Si el exponente es no nulo, añadir bit implícito en la mantisa
EXP_NO_NULO	EQU	*
		BSET	#29,D6
* Actualizar parametros de salida
SEGUIR		MOVEA.L	MANTISA(A6),A5
		MOVE.L	D6,(A5)
		MOVEA.L	EXPONENTE(A6),A5
		MOVE.B	D7,(A5)
		MOVEM.L	(SP)+,A5/D4/D5/D6/D7
                UNLK    A6
		RTS
**********************
*
* PROCEDIMIENTO PARA COMPONER UN NUMERO EN IEEE 754 DE PRECISIÓN SIMPLE
* EN NOTACIÓN COMPACTA HEXADECIMAL A PARTIR DE SUS CAMPOS DE MANTISA Y EXPONENTE
*
**********************
* Argumentos
*   1: conjunto signo-mantisa en módulo y signo (4 octetos)
*   2: exponente en exceso a 127 (1 octeto más otro de sobra)
*   3: dirección donde se almacenará el número en binario con todos sus campos (4 octetos)
**********************
* La mantisa ocupará 32 bits, y estará en la forma s0X'bbbbbbb...b, donde
*     s es el bit de signo
*     X es el bit de la parte entera (si la mantisa está normalizada, X=1;
*                                     si está sin normalizar, X=0)
*     Hay 29 dígitos fraccionarios
* Esta rutina hace truncamiento, así que si se pretende hacer redondeo al más próximo,
* habrá que modificarla o bien pasar una mantisa previamente redondeada
* Se supone que los datos en la mantisa y en el exponente son correctos y no se
* comprueban casos especiales
**********************
FMERGES		EQU	*
MANTISA		SET	14
EXPONENTE	SET	12
COMPACTO	SET	8
		LINK	A6,#0
		MOVEM.L	A5/D5/D6/D7,-(SP)
* Copiar exponente en D6 (le sobra el octeto más significativo)
                CLR.L   D6
		MOVE.B	EXPONENTE+1(A6),D6
* Desplazar el exponente a la izquierda para colocarlo en su sitio
		MOVE.L	#23,D5
		LSL.L	D5,D6
* Copiar mantisa en D7
		MOVE.L	MANTISA(A6),D7
* Desplazar aritméticamente la mantisa a la derecha para colocarla en su sitio
		ASR.L	#6,D7
* Limpiar en la mantisa los bits que corresponden al exponente
		ANDI.L	#$807FFFFF,D7
* Unir mantisa y exponente
		OR.L	D6,D7
* Almacenar resultado
		MOVEA.L	COMPACTO(A6),A5
		MOVE.L	D7,(A5)

* Salir
		MOVEM.L	(SP)+,A5/D5/D6/D7
		UNLK	A6
		RTS
**********************
*
* SUBRUTINAS AUXILIARES:
* ======================
***********************
MS_C2_B		EQU	*
                TST.L   D1
                BGE     ESPOS		Si el numero es positivo, no hace falta cambiarlo.
                NEG.L   D1             	Si no hay que hacer el C2 del numero
                EOR.L   #$80000000,D1	Y después invertir del bit de signo con una máscara de bits
ESPOS		EQU	*
FIN_M2_C2_B     RTS
******************************
E127_C2_B	EQU	*
                ADDQ.B  #1,D2		Primero le sumamos uno para que esté en exceso a 128
                EOR.B   #$80,D2		Cambiamos el bit más signficativo, ya lo tenemos en C2
                EXT.W   D2		Realizamos una extensión de signo
		RTS    
**************************
C2_E127_B	EQU	*
            
                EOR.B   #$80,D2        	Invertimos el bit más significativo mediante una máscara de bits
                SUB.B   #1,D2          	Le restamos uno al exponente
		RTS
****************************
NORM_MANT_L	EQU	*
                MOVEM.L D3/D0,-(SP)    	Salvaguardamos los registros
                JSR     SALV_SIGN_L     Llamamos a SALV_SIGN_L

* Comprobación de si la mantisa son todo ceros
                TST.L   D1             
                BEQ     TODO_CERO      	Si es todo ceros, saltamos

                BTST    #30,D1         	Si no, miramos el bit 30 de la mantisa
                BNE     DESP_DRCHA     	Si es distinto de 0, a DESP_DRCHA
                BTST    #29,D1         	Ahora testeamos el bit29
                BNE     FIN_NORM       	Si es <>, ya está normalizado. Si no, hay que encontrar el bit
                CLR.L   D3             	Borramos D3
                MOVE.L  #28,D0          
ENCONTRAR_BIT   ADDI.B  #1,D3           En D3 guardamos el desplaz_izdo
                BTST    D0,D1         	Testeamos el bit de la mantisa
                BEQ     NO_ENCONT_BIT  	Si es igual, saltamos a NO_ENCONT_BIT
                SUB.W   D3,D2          	Restamos al exponente D3
                SUB.W   #1,D3         	Restamos 1 al desplaz_izdo 
DESP_IZQ        LSL.L   D1             	Desp_lógico de la mantisa a la izda.
                DBF     D3,DESP_IZQ     Decrementamos D3, y saltamos a DESP_IZQ 
                BRA     FIN_NORM        Saltamos a FIN_NORM
NO_ENCONT_BIT   DBF     D0,ENCONTRAR_BIT Decrementamos D0, y salto a ENCONTRAR_BIT

TODO_CERO       EQU	*
		CMPI.W  #$FF80,D2       Comprobamos si se trata de un infinito
                BEQ     FIN_NORM        Si lo es, saltamos a FIN_NORM
                MOVE.W  #$FF81,D2      	Si no, poner 0 en exponente
                BRA     FIN_NORM        Y saltamos a FIN_NORM

DESP_DRCHA      EQU	*
		ADD.W  #1,D2           	Sumamos 1 al exponente. 
                LSR.L   D1              Desplazamiento a la derecha d la mantisa

FIN_NORM        EQU  	*
		EXT.W   D2             	Extensión de signo del exponente
                CMP.W  #$FF80,D2      	Si se produjo algún desbordamiento, como infinito. ANTES CMPI
                BGT     FIN_NORM2       
                CLR.L   D1              Borramos D1
                MOVE.W  #$FF80,D2      
FIN_NORM2       JSR     RES_SIG_L      	LLamar a RES_SIG_L
                MOVEM.L (SP)+,D3/D0    	Restauración de los registros
            	RTS
**************************
ROUND_MANT_L	EQU	*
                MOVEM.L D0,-(SP)        Salvaguardamos el registro en la pila
                MOVE.L  D1,D0           La mantisa a D0
                ANDI.L  #$0000003F,D0   Borramos los bits del 6 al 32, con una máscara de bits
                CMP     #%100000,D0     Comparamos D0 con el binario 100000
                BLO     NO_REDOND       Si es menor, saltamos a NO_REDOND
                BHI     REDOND          Si es mayor, saltamos a REDOND
                BTST    #6,D1           Testeamos el bit 6 de la mantisa
                BEQ     NO_REDOND       Si es igual a 0, saltamos a NO_REDON
REDOND	        EQU	*
		ADDI.L  #$00000040,D1   Si no, hay que sumar $00000040 a la mantisa
                ANDI.L  #$FFFFFFC0,D1   Poner a 0 los bits de redondeo
                JSR     NORM_MANT_L     Y comprobar que no se haya desnormalizado

NO_REDOND       EQU	*
		MOVEM.L (SP)+,D0        Recuperación de los registros
		RTS
********************
SALV_SIGN_L       EQU     *
                * USAMOS EL BIT + SIGNIFICATIVO DE D2 (4 OCTETOS), PARA
                * GUARDAR EL BIT DE SIGNO
                BTST    #31,D1          Testear el bit 31 de la mantisa
                BNE     NEGAT           Si es <> 0, es negativo
                BCLR    #31,D2          Si no, ponemos a 0 el bit 31 de D2
                BRA     BORRA_BIT_SIG   Saltamos a BORRA_BIT_SIG
NEGAT	        EQU	*
		BSET    #31,D2          Ponemos a 1 el bit 31 de D2

BORRA_BIT_SIG 	EQU	*
		BCLR    #31,D1          Ponemos a 0 el bit 31 de la mantisa
		RTS
***************************
RES_SIG_L	EQU	*
                BTST    #31,D2          Ponemos a 1 el bit 1 de D2
                BNE     RES_NEGAT       Si es distinto, saltar a RES_NEGAT
                BCLR    #31,D1          Ponemos a 0 el bit 31 de la mantisa
                BRA     LIMP_D2      	Y saltamos a LIMP_D2
RES_NEGAT      	EQU	*
		BSET    #31,D1         Ponemos a 1 el bit d la mantisa

LIMP_D2      	EQU	*
		ANDI.L  #$0000FFFF,D2   	Y borramos el bit de de signo

            	RTS
            	END

