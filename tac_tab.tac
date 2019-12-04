.table
int x1
int x3
int per6
int x7
char str0[] = "per = "
int size0 = 6
.code
func:
mov x3, 3
return x3
main:
call func, 0
pop $0
mov x7, $0
mov per6, 53
// Comparacao: diferente de
seq $1, per6, 3.71293
not $0, $1
// Instrucao if
brz IF0, $0
// Ini print
mov $0, 0
sub $1, size0, 1
IMPRIME0:
slt $2, $0, size0 = 6
brz IMPRIME0p0, $2
mov $2, &str0
mov $2, $2[$0]
print $2
add $0, $0, 1
jump IMPRIME0
IMPRIME0p0:
println 2.2
// Fim print
param "per = "
param 2.2
call printFloat, 2
pop $0
IF0:
// Fim if
println 0
