	.eqv NEGRO 0x00000000
	.eqv COLOR_BORDE 0x00ff0000
	.eqv COLOR_JUGADOR 0x00ffffff
	.eqv COLOR_META 0x00FFFACD
	.text
.macro puntoColor(%t0,%t1,%t2,%t3)
	sll $t1,$t1,2
	sll $t2,$t2,7
	add $t1,$t1,$t2
	add $t1,$t0,$t1
	sw $t3,0($t1) 
.end_macro
#t0-inicioPantalla,t1-adonde,t3-Color
.macro puntoColor(%t0,%t1,%t3)
	mul $t1,$t1,4
	add $t1,$t0,$t1
	sw $t3,0($t1) 
.end_macro

.macro sleep(%a0)
	li $v0,32
	syscall 
.end_macro
.macro borrarPantalla(%t0,%t3,%a0)
	add $t1,$t0,$zero
	add $t2,$t0,4096
loop:
	sleep($a0)
	sw $t3,0($t1)
	add $t1,$t1,4
	bne $t1,$t2,loop	
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

.macro leerDireccion()
	li $v0,12
	syscall
.end_macro

.macro calcularMovimiento(%v0)
	beq $v0,'d',mRight
	beq $v0,'a',mLeft
	beq $v0,'w',mUp
	beq $v0,'s',mDown
	li $v0,0
	j exit
mRight:
	li $v0,1
	j exit
mLeft:
	li $v0,-1
	j exit
mUp:
	li $v0,-32
	j exit
mDown:
	li $v0,32
	j exit
exit:
.end_macro

.macro inicioJugador(%t0,%k1,%t3)
	li $k1,33
	add $t1,$k1,$zero
	puntoColor($t0,$t1,$t3)
.end_macro

.macro validar(%t0,%t1,%s0,%t3)
	mul $t1,$t1,4
	add $t1,$t0,$t1
	lw  $s0,0($t1)
	sub $s0,$s0,$t3
.end_macro
.macro  menu()
	li $t0,0
.end_macro
.macro jugarMapa1()
	li $t3,NEGRO
	borrarPantalla($t0,$t3,$a0)
	li $t3,COLOR_JUGADOR
	inicioJugador($t0,$k1,$t3)
.end_macro
.macro jugarMapa2()
	li $t3,COLOR_BORDE
	borrarPantalla($t0,$t3,$a0)
.end_macro
.macro imprimirWinner()
	li $t3,NEGRO
	borrarPantalla($t0,$t3,$a0)
	li $t1,55
	li $t3,COLOR_BORDE
	puntoColor($t0,$t1,$t3)
	menu()
.end_macro
#t0-inicioPantalla,k1-PosicionJugador,v0-movimiento,t3-color
.macro moverJugador(%t0,%k1,%v0,%t3,%t9)
	add $t1,$k1,$v0
	add $t4,$zero,$t3
	li $t3,NEGRO
	validar($t0,$t1,$s0,$t3)
	add $t5,$s0,$zero
	add $t3,$zero,$t4	###BUENA
	
	add $t1,$k1,$v0
	add $t4,$zero,$t3
	li $t3,COLOR_META
	validar($t0,$t1,$s0,$t3)
	add $t3,$zero,$t4	##GANO
	
	add $t2,$t3,$zero
	li $t3,NEGRO
	add $t1,$k1,$zero
	puntoColor($t0,$k1,$t3)
	add $t3,$t2,$zero
	add $k1,$k1,$v0
	add $t1,$k1,$zero
	puntoColor($t0,$k1,$t3)
	li $a0,4
	sleep($a0)
	beq $s0,0,winner
	bne $t5,0,reiniciar
	j sal
reiniciar:
	beq $t9,0,rMapa1
	jugarMapa2()
	j sal
rMapa1:
	jugarMapa1()
	j sal
winner:
	imprimirWinner()
sal:
.end_macro

.macro jugar()
re:
	leerDireccion()
	calcularMovimiento($v0)
	li $t9,0
	li $t3,COLOR_JUGADOR
	moverJugador($t0,$k1,$v0,$t3,$t9)
	bne $t0,0,re
.end_macro
