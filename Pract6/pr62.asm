* Programa principal
		SYMBOLS
		ORG	$400
INICIO
                CLR.L   D0              Borramos el contenido de los registros
                CLR.L   D1
                CLR.L   D2
                CLR.L   D3
                MOVE.W  B,D0            D0.W:=M(B)
                ADD.W   C,D0            D0.W:=D0.W+M(C)
                MOVE.W  A,D1            D1.W:=M(A)
                MULS.W  D0,D1           D1.L:=D1.W*D0.W
                MOVE.W  A,D2            D2.W:=M(A)
                DIVS.W  #20,D1          D1.L:=D1.W/20
                ADD.W   D2,D1           D1.W:=D2.W+D1.W
                MOVE.W  C,D3            D3.W:=M(C)
                MULS.W  D,D3            D3.L:=D*D3.W
                SUB.L  D3,D1           D1.L:=D1.L-D3.L
                MOVE.L  D1,E            M(E):=D1
                MOVE.B  '-',SIGNO       SIGNO:='-'
                TST.L   D1
                BMI     ESNEG           Si es negativo ya tiene el signo, si no hay q cambiarlo
                MOVE.B  '+',SIGNO
ESNEG           EQU     *
* Zona de datos del programa principal
		ORG	$1000
A		DW	10001
B		DW	-30
C		DW	-5
D		DW	55
E		DS	4
SIGNO		DS	1
		END	INICIO

