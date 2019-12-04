.table
float per2
int x3
int i4
point pX5
point pY5
char str0[] = "meu p: "
int size0 = 7
char str1[] = "per = "
int size1 = 6
.code
main:
mov pX5, 1
mov pY5, 3.2
// Ini print
mov $0, 0
sub $1, size0, 1
IMPRIME0:
slt $2, $0, size0
brz IMPRIME0p0, $2
mov $2, &str0
mov $2, $2[$0]
print $2
add $0, $0, 1
jump IMPRIME0
IMPRIME0p0:
println (x: 1, y: 3.2)
// Fim print
mov x3, 2
mov per2, 9153.2
// Laco FOR
mov i4, 0
CONDFOR0:
// Comparacao: Menor que
slt $0, i4, 10
brz FIMFOR0, $0
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
brz IF0, $0
// Ini print
mov $0, 0
sub $1, size1, 1
IMPRIME1:
slt $2, $0, size1
brz IMPRIME1p0, $2
mov $2, &str1
mov $2, $2[$0]
print $2
add $0, $0, 1
jump IMPRIME1
IMPRIME1p0:
println per2
// Fim print
IF0:
// Fim if
println 0
