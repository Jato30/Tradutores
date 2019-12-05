.table
float per1
int x2
int i3
float pX4
float pY4
float quadrado5
char str0[] = "meu p: "
int size0 = 7
char str1[] = "(x: "
int size1 = 4
char str2[] = ", y: "
int size2 = 5
char str3[] = ")"
int size3 = 1
char str4[] = "quad: "
int size4 = 6
char str5[] = "per = "
int size5 = 6
.code
main:
// constroiPoint()
mov pX4, 7.0
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
print pX4
// Ini print
mov $0, 0
sub $1, size2, 1
IMPRIME2:
slt $2, $0, size2
brz IMPRIME2p0, $2
mov $2, &str2
mov $2, $2[$0]
print $2
add $0, $0, 1
jump IMPRIME2
IMPRIME2p0:
print pY4
// Ini print
mov $0, 0
sub $1, size3, 1
IMPRIME3:
slt $2, $0, size3
brz IMPRIME3p0, $2
mov $2, &str3
mov $2, $2[$0]
print $2
add $0, $0, 1
jump IMPRIME3
IMPRIME3p0:
println
// Fim print
fltoint $8, 2.2
mov x2, $8
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
inttofl $6, x2
div $0, per1, $6
mov per1, $0
jump INCRFOR0
FIMFOR0:
mul $0, x2, x2
inttofl $8, 4
mov quadrado5, $8
// Ini print
mov $0, 0
sub $1, size4, 1
IMPRIME4:
slt $2, $0, size4
brz IMPRIME4p0, $2
mov $2, &str4
mov $2, $2[$0]
print $2
add $0, $0, 1
jump IMPRIME4
IMPRIME4p0:
println quadrado5
// Fim print
// Comparacao: diferente de
seq $1, per1, 3.71293
not $0, $1
// Instrucao if
brz IF0, $0
// Ini print
mov $0, 0
sub $1, size5, 1
IMPRIME5:
slt $2, $0, size5
brz IMPRIME5p0, $2
mov $2, &str5
mov $2, $2[$0]
print $2
add $0, $0, 1
jump IMPRIME5
IMPRIME5p0:
println per1
// Fim print
IF0:
// Fim if
println 0
