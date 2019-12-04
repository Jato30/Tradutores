.table
int x1
int x3
int per6
int x7
char str[]0[] = "per = "
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
brz $0, IF0
// Ini print
mema $2, 1
mov $2, '\0'
mov $1, str0[]
IMPRIME0:
print $1
add $1, 1
sec $0, $2, $1
brnz $0, IMPRIME0
println 2.2
// Fim print
param "per = "
param 2.2
call printFloat, 2
pop $0
IF0:
// Fim if
println 0
