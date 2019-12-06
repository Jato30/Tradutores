.table
int i1
char str0[] = "i = 3: "
int size0 = 7
char str1[] = "i = 3: "
int size1 = 7
.code
main:
mov i1, 1
// Comparacao: Menor que
slt $0, i1, 4
// Instrucao if
brz IF0, $0
// Comparacao: Maior que
sleq $1, i1, 2
not $0, $1
// Instrucao if
brz IF0, $0
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
println i1
// Fim print
IF0:
// Fim if
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
println i1
// Fim print
IF1:
// Fim if
println 0
