.macro puntoColor(%t0,%t1,%t2,%t3)
	sll $t1,$t1,2
	sll $t2,$t2,7
	add $t1,$t1,$t2
	add $t1,$t0,$t1
	sw $t3,0($t1) 
.end_macro

.macro puntoColor(%t0,%t1,%t3)
	mul $t1,$t1,4
	add $t1,$t0,$t1
	sw $t3,0($t1) 
.end_macro

.macro borrarPantalla(%t0)
	add $t1,$t0,$zero
	add $t2,$t0,4096
	li $t3,0x00000000
loop:
	sw $t3,0($t1)
	add $t1,$t1,4
	bne $t1,$t2,loop	
.end_macro

.macro sleep(%t0)
	add $a0,$a0,$t0
	li $v0,32
	syscall 
.end_macro
#t0-inicio,t2-pos,t3-color,t4-longitud
.macro imprimirLineaH(%t0,%t2,%t3,%t4)
	add $t1,$t2,$zero
	add $t2,$t2,$t4
	beq $t4,0,salir
loop2: 
	add $t4,$t1,$zero
	puntoColor($t0,$t1,$t3)
	add $t1,$t4,1
	bne $t1,$t2,loop2
salir:
.end_macro

.macro imprimirLineaV(%t0,%t2,%t3,%t4)
	add $t1,$t2,$zero
	mul $t4,$t4,32
	add $t2,$t2,$t4
	beq $t4,0,salir
loop2: 
	add $t4,$t1,$zero
	puntoColor($t0,$t1,$t3)
	add $t1,$t4,32
	bne $t1,$t2,loop2
salir:
.end_macro

.macro borde(%t0,%t3)
	li $t2,0
	li $t4,31
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,992
	li $t4,31
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,0
	li $t4,32
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,31
	li $t4,32
	imprimirLineaV($t0,$t2,$t3,$t4)
.end_macro