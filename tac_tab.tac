.table
float per2
int x3
int i4
.code
main:
mov x3, 2
mov per2, 9153.2
// Laco FOR
mov i4, 0
CONDFOR0:
// Comparacao: Menor que
slt $0, i4, 10
brz $0, FIMFOR0
jump CORPOFOR0
INCRFOR0:
add $0, i4, 1
mov i4, $0
jump CONDFOR0
CORPOFOR0:
mov $0, x3
inttofl x3, $0
div $0, per2, x3
mov per2, $0
jump INCRFOR0
FIMFOR0:
// Comparacao: diferente de
seq $1, per2, 3.71293
not $0, $1
// Instrucao if
brz $0, IF0
param "per = "
param per2
call printFloat, 2
pop $0
IF0:
// Fim if
println 0
