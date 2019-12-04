.table
float per1
int x2
int i3
point pX4
point pY4
float quadrado5
char str0[] = "meu p: "
int size0 = 7
char str1[] = "per = "
int size1 = 6
.code
main:
mov pX4, 1
mov pY4, 3.2
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
mov x2, 2
mov per1, 9153.2
// Laco FOR
mov i3, 0
CONDFOR0:
// Comparacao: Menor que
slt $0, i3, 10
brz FIMFOR0, $0
jump CORPOFOR0
INCRFOR0:
add $0, i3, 1
mov i3, $0
jump CONDFOR0
CORPOFOR0:
mov $0, x2
inttofl x2, $0
div $0, per1, x2
mov per1, $0
jump INCRFOR0
FIMFOR0:
mul $0, x2, x2
mov quadrado5, $0
// Comparacao: diferente de
seq $1, per1, 3.71293
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
println per1
// Fim print
IF0:
// Fim if
println 0
