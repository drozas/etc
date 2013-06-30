* Declaración de variables 

		ORG	$400		
XC		DW	100		Coordenada X del centro de la circunferencia
YC		DW	120		Coordenada Y del centro de la circunferencia
R		DW	175		Radio
XZ		DW	55		Coordenada X del punto Z	
YZ		DW	45		Coordenada Y del punto Z		
POSICION	DS	0
		SYMBOLS

* Registros:
* - D0:  sqr(XC-Xz)
* - D1:  sqr(YC-YZ)
* - D2:  sqr(R)		


* Programa principal
		
		ORG	$500
INICIO		CLR.L	D0		Borramos contenido de los registros
		CLR.L	D1
		CLR.L	D2
* Primero realizamos todos los calculos necesarios...
		MOVE.W	XC,D0
		MOVE.W	YC,D1
		SUB.W	XZ,D0
		SUB.W	YZ,D1
		MULS	D0,D0
		MULS	D1,D1
		ADD.L	D1,D0
		MOVE.W	R,D2
		MULS	D2,D2
* Ahora en D0 tenemos el resultado total de las operaciones; en D2 el radio al cuadrado,  y solo nos queda comparar...
		CMP.L	D2,D0
		BGT	EXTERIOR
		BLT	INTERIOR
*Si no es exterior ni interior, entonces esta sobre la circunferencia...
		MOVE.B	#'P',POSICION	Colocamos una P y saltamos
		BRA	FINCOMP
EXTERIOR	EQU	*
		MOVE.B	#'E',POSICION	Si es exterior colocamos una E y saltamos
		BRA	FINCOMP
INTERIOR	EQU	*
		MOVE.B	#'I',POSICION	Y si es interior colocamos una I
FINCOMP		EQU	*
		STOP	#$2000		Parar

		END	INICIO