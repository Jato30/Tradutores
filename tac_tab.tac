.table
float pontoX1
float pontoY1
char str0[] = "Meu ponto: "
int size0 = 11
char str1[] = "(x: "
int size1 = 4
char str2[] = ", y: "
int size2 = 5
char str3[] = ")"
int size3 = 1
.code
main:
// constroiPoint()
mov pontoX1, 5.3
mov pontoY1, 15.2
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
print pontoX1
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
print pontoY1
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
println 0
