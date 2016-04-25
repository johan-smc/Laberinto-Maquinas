
	.eqv INICIO_PANTALLA 0xffff0000
	.eqv COLOR_JUGADOR 0x000000FF
	.eqv COLOR_META 0x00006400
	.eqv NEGRO 0x00000000
	.eqv BASE 0x00ffffff
	.eqv COLOR_BORDE 0x00000000
	.eqv AMARILLO 0x00ffff00
	.eqv BLANCO 0x00ffffff
	.eqv ROJO 0x00ff0000


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



.macro jugarMapa1(%t0,%t3)
	#li $t3,BASE
	mapa($t0,$t3)

.end_macro
.macro jugarMapa2(%t0,%t3)
	#li $t3,BASE
	mapados($t0,$t3)
.end_macro
.macro imprimirWinner()
	li $t3,BASE
	li $a0,1
	borrarPantalla($t0,$t3,$a0)
	#####################
	li $t0, INICIO_PANTALLA
	eltriunfo($t0)
	####################
	li $t0,0
.end_macro
#t0-inicioPantalla,k1-PosicionJugador,v0-movimiento,t3-color
.macro moverJugador(%t0,%k1,%v0,%t3,%t9)
	add $t1,$k1,$v0
	add $t4,$zero,$t3
	li $t3,BASE
	validar($t0,$t1,$s0,$t3)
	add $t5,$s0,$zero
	add $t3,$zero,$t4	###BUENA


	add $t1,$k1,$v0
	add $t4,$zero,$t3
	li $t3,COLOR_JUGADOR
	validar($t0,$t1,$s0,$t3)
	add $t6,$s0,$zero
	add $t3,$zero,$t4	#JUGADOR

	add $t1,$k1,$v0
	add $t4,$zero,$t3
	li $t3,COLOR_META
	validar($t0,$t1,$s0,$t3)
	add $t3,$zero,$t4	##GANO


	add $t2,$t3,$zero
	li $t3,BASE
	add $t1,$k1,$zero
	puntoColor($t0,$k1,$t3)
	add $t3,$t2,$zero
	add $k1,$k1,$v0
	add $t1,$k1,$zero
	puntoColor($t0,$k1,$t3)
	beq $t6,0,sal
	beq $s0,0,winner
	bne $t5,0,reiniciar
	j sal
reiniciar:
	beq $t9,1,rMapa1
	jugarMapa2($t0,$t3)
	j sal
rMapa1:
	jugarMapa1($t0,$t3)
	j sal
winner:
	imprimirWinner()
sal:
.end_macro

.macro jugar()
re:
	leerDireccion()
	calcularMovimiento($v0)
	li $t3,COLOR_JUGADOR
	moverJugador($t0,$k1,$v0,$t3,$t9)
	bne $t0,0,re
.end_macro

.macro principal(%t0,%a1)
	add $a3,$t0,$zero
inicio:
	add $t0,$a3,$zero
	li $v0,4
	add $a0,$a1,$zero
	syscall
	li $v0,5
	syscall
	add $t9,$zero,$v0
	bne $t9,1,mapa2
	jugarMapa1($t0,$t3)
	j seguirJugando
mapa2:
	jugarMapa2($t0,$t3)
seguirJugando:
	jugar()
	j inicio
.end_macro


.macro mapa(%t0,%t3)

	li $t3,BASE
	li $a0,2
	borrarPantalla($t0,$t3,$a0)

	li $t3,COLOR_BORDE
	borde($t0,$t3)

	##############  2  ####################
	li $t2,43
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,50
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,54
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  3  ####################
	li $t2,64
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,67
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,69
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##########
	li $t2,69
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	##########
	li $t2,72
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,73
	li $t4,5
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,80
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,88
	li $t4,8
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,88
	li $t4,6
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,91
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,93
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  4  ####################
	li $t2,107
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,107
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,109
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,114
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,116
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	######################################
	##############  5  ####################
	li $t2,130
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,130
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,133
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,135
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,154
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,154
	li $t4,5
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  6  ####################
	li $t2,173
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,175
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,178
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,178
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,182
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  7  ####################
	li $t2,192
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,196
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,201
	li $t4,5
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,220
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,220
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  8  ####################
	li $t2,228
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,228
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,229
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,234
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,235
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,241
	li $t4,6
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,241
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,245
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  9  ####################
	li $t2,258
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,267
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,269
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,272
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,272
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,284
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  10  ####################
	li $t2,288
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,289
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,295
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,297
	li $t4,6
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,307
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,307
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,311
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  11  ####################
	li $t2,324
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,324
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,331
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,332
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,335
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,338
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,346
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,346
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,349
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  12  ####################
	li $t2,355
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,355
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,359
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,373
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,373
	li $t4,6
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,376
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  13  ####################
	li $t2,386
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,386
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,390
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,395
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,395
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,399
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,401
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,403
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,403
	li $t4,5
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,408
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,412
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,412
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,414
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  14  ####################
	li $t2,421
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,421
	li $t4,5
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,425
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,439
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,443
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,443
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  15  ####################
	li $t2,450
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,451
	li $t4,6
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,453
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,456
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,461
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,463
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,474
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,474
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  16  ####################
	li $t2,487
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,487
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,493
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,503
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,505
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,509
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  17  ####################
	li $t2,513
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,521
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,523
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,523
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,529
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,530
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,540
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  18  ####################
	li $t2,559
	li $t4,5
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,567
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,571
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,571
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  19  ####################
	li $t2,591
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,593
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,596
	li $t4,5
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,596
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,598
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,600
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,602
	li $t4,6
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,602
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,606
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  20  ####################
	li $t2,611
	li $t4,7
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,613
	li $t4,5
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,617
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,619
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,637
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,637
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  21  ####################
	li $t2,668
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,668
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  22  ####################
	li $t2,672
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,674
	li $t4,6
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,677
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,681
	li $t4,9
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,691
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,693
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,693
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,698
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  23  ####################
	li $t2,734
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  24  ####################
	li $t2,740
	li $t4,6
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,745
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,747
	li $t4,9
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,749
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,750
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,757
	li $t4,6
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,764
	li $t4,7
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,766
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  25  ####################
	##############  26  ####################
	li $t2,804
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,806
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,808
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,811
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,817
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,821
	li $t4,8
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,821
	li $t4,7
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,825
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,830
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  27  ####################
	li $t2,834
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,835
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,847
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,849
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,851
	li $t4,4
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  28  ####################
	li $t2,870
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,874
	li $t4,6
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,877
	li $t4,5
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,878
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,887
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,889
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,892
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	##############  29  ####################
	li $t2,913
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	##############  30  ####################
	li $t2,928
	li $t4,5
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,929
	li $t4,2
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,934
	li $t4,3
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,936
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,938
	li $t4,3
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t2,938
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,944
	li $t4,4
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,951
	li $t4,6
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,958
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t2,975
	li $t4,2
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $k1,33
	li $t3,COLOR_JUGADOR
	inicioJugador($t0,$k1,$t3)
	li $t1,971
	li $t3,COLOR_META
	puntoColor($t0,$t1,$t3)
.end_macro

.macro mapados(%t0,%t3)

	li $t3,BASE
	li $a0,2
	borrarPantalla($t0,$t3,$a0)

	li $t3,COLOR_BORDE
	borde($t0,$t3)

	li $t1,0
        puntoColor($t0,$t1,$t3)
        li $t1,1
        puntoColor($t0,$t1,$t3)
        li $t1,2
        puntoColor($t0,$t1,$t3)
        li $t1,3
        puntoColor($t0,$t1,$t3)
        li $t1,4
        puntoColor($t0,$t1,$t3)
        li $t1,5
        puntoColor($t0,$t1,$t3)
        li $t1,6
        puntoColor($t0,$t1,$t3)
        li $t1,7
        puntoColor($t0,$t1,$t3)
        li $t1,8
        puntoColor($t0,$t1,$t3)
        li $t1,9
        puntoColor($t0,$t1,$t3)
        li $t1,10
        puntoColor($t0,$t1,$t3)
        li $t1,11
        puntoColor($t0,$t1,$t3)
        li $t1,12
        puntoColor($t0,$t1,$t3)
        li $t1,13
        puntoColor($t0,$t1,$t3)
        li $t1,14
        puntoColor($t0,$t1,$t3)
        li $t1,15
        puntoColor($t0,$t1,$t3)
        li $t1,16
        puntoColor($t0,$t1,$t3)
        li $t1,17
        puntoColor($t0,$t1,$t3)
        li $t1,18
        puntoColor($t0,$t1,$t3)
        li $t1,19
        puntoColor($t0,$t1,$t3)
        li $t1,20
        puntoColor($t0,$t1,$t3)
        li $t1,21
        puntoColor($t0,$t1,$t3)
        li $t1,22
        puntoColor($t0,$t1,$t3)
        li $t1,23
        puntoColor($t0,$t1,$t3)
        li $t1,24
        puntoColor($t0,$t1,$t3)
        li $t1,25
        puntoColor($t0,$t1,$t3)
        li $t1,26
        puntoColor($t0,$t1,$t3)
        li $t1,27
        puntoColor($t0,$t1,$t3)
        li $t1,28
        puntoColor($t0,$t1,$t3)
        li $t1,29
        puntoColor($t0,$t1,$t3)
        li $t1,30
        puntoColor($t0,$t1,$t3)
        li $t1,31
        puntoColor($t0,$t1,$t3)
        li $t1,32
        puntoColor($t0,$t1,$t3)
        li $t1,35
        puntoColor($t0,$t1,$t3)
        li $t1,43
        puntoColor($t0,$t1,$t3)
        li $t1,51
        puntoColor($t0,$t1,$t3)
        li $t1,53
        puntoColor($t0,$t1,$t3)
        li $t1,54
        puntoColor($t0,$t1,$t3)
        li $t1,63
        puntoColor($t0,$t1,$t3)
        li $t1,64
        puntoColor($t0,$t1,$t3)
        li $t1,65
        puntoColor($t0,$t1,$t3)
        li $t1,67
        puntoColor($t0,$t1,$t3)
        li $t1,69
        puntoColor($t0,$t1,$t3)
        li $t1,70
        puntoColor($t0,$t1,$t3)
        li $t1,72
        puntoColor($t0,$t1,$t3)
        li $t1,73
        puntoColor($t0,$t1,$t3)
        li $t1,75
        puntoColor($t0,$t1,$t3)
        li $t1,76
        puntoColor($t0,$t1,$t3)
        li $t1,77
        puntoColor($t0,$t1,$t3)
        li $t1,78
        puntoColor($t0,$t1,$t3)
        li $t1,80
        puntoColor($t0,$t1,$t3)
        li $t1,83
        puntoColor($t0,$t1,$t3)
        li $t1,85
        puntoColor($t0,$t1,$t3)
        li $t1,86
        puntoColor($t0,$t1,$t3)
        li $t1,87
        puntoColor($t0,$t1,$t3)
        li $t1,88
        puntoColor($t0,$t1,$t3)
        li $t1,89
        puntoColor($t0,$t1,$t3)
        li $t1,90
        puntoColor($t0,$t1,$t3)
        li $t1,91
        puntoColor($t0,$t1,$t3)
        li $t1,92
        puntoColor($t0,$t1,$t3)
        li $t1,93
        puntoColor($t0,$t1,$t3)
        li $t1,95
        puntoColor($t0,$t1,$t3)
        li $t1,96
        puntoColor($t0,$t1,$t3)
        li $t1,99
        puntoColor($t0,$t1,$t3)
        li $t1,101
        puntoColor($t0,$t1,$t3)
        li $t1,105
        puntoColor($t0,$t1,$t3)
        li $t1,107
        puntoColor($t0,$t1,$t3)
        li $t1,110
        puntoColor($t0,$t1,$t3)
        li $t1,112
        puntoColor($t0,$t1,$t3)
        li $t1,118
        puntoColor($t0,$t1,$t3)
        li $t1,120
        puntoColor($t0,$t1,$t3)
        li $t1,123
        puntoColor($t0,$t1,$t3)
        li $t1,125
        puntoColor($t0,$t1,$t3)
        li $t1,127
        puntoColor($t0,$t1,$t3)
        li $t1,128
        puntoColor($t0,$t1,$t3)
        li $t1,130
        puntoColor($t0,$t1,$t3)
        li $t1,131
        puntoColor($t0,$t1,$t3)
        li $t1,133
        puntoColor($t0,$t1,$t3)
        li $t1,134
        puntoColor($t0,$t1,$t3)
        li $t1,135
        puntoColor($t0,$t1,$t3)
        li $t1,137
        puntoColor($t0,$t1,$t3)
        li $t1,139
        puntoColor($t0,$t1,$t3)
        li $t1,140
        puntoColor($t0,$t1,$t3)
        li $t1,142
        puntoColor($t0,$t1,$t3)
        li $t1,144
        puntoColor($t0,$t1,$t3)
        li $t1,145
        puntoColor($t0,$t1,$t3)
        li $t1,146
        puntoColor($t0,$t1,$t3)
        li $t1,148
        puntoColor($t0,$t1,$t3)
        li $t1,152
        puntoColor($t0,$t1,$t3)
        li $t1,154
        puntoColor($t0,$t1,$t3)
        li $t1,155
        puntoColor($t0,$t1,$t3)
        li $t1,157
        puntoColor($t0,$t1,$t3)
        li $t1,159
        puntoColor($t0,$t1,$t3)
        li $t1,160
        puntoColor($t0,$t1,$t3)
        li $t1,162
        puntoColor($t0,$t1,$t3)
        li $t1,167
        puntoColor($t0,$t1,$t3)
        li $t1,169
        puntoColor($t0,$t1,$t3)
        li $t1,176
        puntoColor($t0,$t1,$t3)
        li $t1,178
        puntoColor($t0,$t1,$t3)
        li $t1,180
        puntoColor($t0,$t1,$t3)
        li $t1,181
        puntoColor($t0,$t1,$t3)
        li $t1,182
        puntoColor($t0,$t1,$t3)
        li $t1,184
        puntoColor($t0,$t1,$t3)
        li $t1,191
        puntoColor($t0,$t1,$t3)
        li $t1,192
        puntoColor($t0,$t1,$t3)
        li $t1,194
        puntoColor($t0,$t1,$t3)
        li $t1,196
        puntoColor($t0,$t1,$t3)
        li $t1,198
        puntoColor($t0,$t1,$t3)
        li $t1,199
        puntoColor($t0,$t1,$t3)
        li $t1,201
        puntoColor($t0,$t1,$t3)
        li $t1,202
        puntoColor($t0,$t1,$t3)
        li $t1,203
        puntoColor($t0,$t1,$t3)
        li $t1,204
        puntoColor($t0,$t1,$t3)
        li $t1,205
        puntoColor($t0,$t1,$t3)
        li $t1,207
        puntoColor($t0,$t1,$t3)
        li $t1,208
        puntoColor($t0,$t1,$t3)
        li $t1,210
        puntoColor($t0,$t1,$t3)
        li $t1,212
        puntoColor($t0,$t1,$t3)
        li $t1,216
        puntoColor($t0,$t1,$t3)
        li $t1,218
        puntoColor($t0,$t1,$t3)
        li $t1,220
        puntoColor($t0,$t1,$t3)
        li $t1,221
        puntoColor($t0,$t1,$t3)
        li $t1,223
        puntoColor($t0,$t1,$t3)
        li $t1,224
        puntoColor($t0,$t1,$t3)
        li $t1,226
        puntoColor($t0,$t1,$t3)
        li $t1,227
        puntoColor($t0,$t1,$t3)
        li $t1,228
        puntoColor($t0,$t1,$t3)
        li $t1,230
        puntoColor($t0,$t1,$t3)
        li $t1,231
        puntoColor($t0,$t1,$t3)
        li $t1,233
        puntoColor($t0,$t1,$t3)
        li $t1,237
        puntoColor($t0,$t1,$t3)
        li $t1,239
        puntoColor($t0,$t1,$t3)
        li $t1,242
        puntoColor($t0,$t1,$t3)
        li $t1,243
        puntoColor($t0,$t1,$t3)
        li $t1,244
        puntoColor($t0,$t1,$t3)
        li $t1,245
        puntoColor($t0,$t1,$t3)
        li $t1,246
        puntoColor($t0,$t1,$t3)
        li $t1,248
        puntoColor($t0,$t1,$t3)
        li $t1,249
        puntoColor($t0,$t1,$t3)
        li $t1,250
        puntoColor($t0,$t1,$t3)
        li $t1,252
        puntoColor($t0,$t1,$t3)
        li $t1,255
        puntoColor($t0,$t1,$t3)
        li $t1,256
        puntoColor($t0,$t1,$t3)
        li $t1,259
        puntoColor($t0,$t1,$t3)
        li $t1,263
        puntoColor($t0,$t1,$t3)
        li $t1,281
        puntoColor($t0,$t1,$t3)
        li $t1,284
        puntoColor($t0,$t1,$t3)
        li $t1,285
        puntoColor($t0,$t1,$t3)
        li $t1,286
        puntoColor($t0,$t1,$t3)
        li $t1,287
        puntoColor($t0,$t1,$t3)
        li $t1,288
        puntoColor($t0,$t1,$t3)
        li $t1,289
        puntoColor($t0,$t1,$t3)
        li $t1,291
        puntoColor($t0,$t1,$t3)
        li $t1,293
        puntoColor($t0,$t1,$t3)
        li $t1,294
        puntoColor($t0,$t1,$t3)
        li $t1,295
        puntoColor($t0,$t1,$t3)
        li $t1,297
        puntoColor($t0,$t1,$t3)
        li $t1,298
        puntoColor($t0,$t1,$t3)
        li $t1,304
        puntoColor($t0,$t1,$t3)
        li $t1,310
        puntoColor($t0,$t1,$t3)
        li $t1,311
        puntoColor($t0,$t1,$t3)
        li $t1,313
        puntoColor($t0,$t1,$t3)
        li $t1,319
        puntoColor($t0,$t1,$t3)
        li $t1,320
        puntoColor($t0,$t1,$t3)
        li $t1,321
        puntoColor($t0,$t1,$t3)
        li $t1,323
        puntoColor($t0,$t1,$t3)
        li $t1,325
        puntoColor($t0,$t1,$t3)
        li $t1,329
        puntoColor($t0,$t1,$t3)
        li $t1,331
        puntoColor($t0,$t1,$t3)
        li $t1,335
        puntoColor($t0,$t1,$t3)
        li $t1,337
        puntoColor($t0,$t1,$t3)
        li $t1,341
        puntoColor($t0,$t1,$t3)
        li $t1,343
        puntoColor($t0,$t1,$t3)
        li $t1,345
        puntoColor($t0,$t1,$t3)
        li $t1,346
        puntoColor($t0,$t1,$t3)
        li $t1,347
        puntoColor($t0,$t1,$t3)
        li $t1,348
        puntoColor($t0,$t1,$t3)
        li $t1,349
        puntoColor($t0,$t1,$t3)
        li $t1,351
        puntoColor($t0,$t1,$t3)
        li $t1,352
        puntoColor($t0,$t1,$t3)
        li $t1,355
        puntoColor($t0,$t1,$t3)
        li $t1,356
        puntoColor($t0,$t1,$t3)
        li $t1,357
        puntoColor($t0,$t1,$t3)
        li $t1,359
        puntoColor($t0,$t1,$t3)
        li $t1,361
        puntoColor($t0,$t1,$t3)
        li $t1,364
        puntoColor($t0,$t1,$t3)
        li $t1,366
        puntoColor($t0,$t1,$t3)
        li $t1,370
        puntoColor($t0,$t1,$t3)
        li $t1,372
        puntoColor($t0,$t1,$t3)
        li $t1,375
        puntoColor($t0,$t1,$t3)
        li $t1,377
        puntoColor($t0,$t1,$t3)
        li $t1,378
        puntoColor($t0,$t1,$t3)
        li $t1,383
        puntoColor($t0,$t1,$t3)
        li $t1,384
        puntoColor($t0,$t1,$t3)
        li $t1,386
        puntoColor($t0,$t1,$t3)
        li $t1,387
        puntoColor($t0,$t1,$t3)
        li $t1,391
        puntoColor($t0,$t1,$t3)
        li $t1,394
        puntoColor($t0,$t1,$t3)
        li $t1,397
        puntoColor($t0,$t1,$t3)
        li $t1,400
        puntoColor($t0,$t1,$t3)
        li $t1,403
        puntoColor($t0,$t1,$t3)
        li $t1,406
        puntoColor($t0,$t1,$t3)
        li $t1,409
        puntoColor($t0,$t1,$t3)
        li $t1,412
        puntoColor($t0,$t1,$t3)
        li $t1,414
        puntoColor($t0,$t1,$t3)
        li $t1,415
        puntoColor($t0,$t1,$t3)
        li $t1,416
        puntoColor($t0,$t1,$t3)
        li $t1,418
        puntoColor($t0,$t1,$t3)
        li $t1,421
        puntoColor($t0,$t1,$t3)
        li $t1,422
        puntoColor($t0,$t1,$t3)
        li $t1,423
        puntoColor($t0,$t1,$t3)
        li $t1,427
        puntoColor($t0,$t1,$t3)
        li $t1,431
        puntoColor($t0,$t1,$t3)
        li $t1,433
        puntoColor($t0,$t1,$t3)
        li $t1,437
        puntoColor($t0,$t1,$t3)
        li $t1,443
        puntoColor($t0,$t1,$t3)
        li $t1,444
        puntoColor($t0,$t1,$t3)
        li $t1,446
        puntoColor($t0,$t1,$t3)
        li $t1,447
        puntoColor($t0,$t1,$t3)
        li $t1,448
        puntoColor($t0,$t1,$t3)
        li $t1,450
        puntoColor($t0,$t1,$t3)
        li $t1,451
        puntoColor($t0,$t1,$t3)
        li $t1,452
        puntoColor($t0,$t1,$t3)
        li $t1,453
        puntoColor($t0,$t1,$t3)
        li $t1,455
        puntoColor($t0,$t1,$t3)
        li $t1,460
        puntoColor($t0,$t1,$t3)
        li $t1,461
        puntoColor($t0,$t1,$t3)
        li $t1,462
        puntoColor($t0,$t1,$t3)
        li $t1,466
        puntoColor($t0,$t1,$t3)
        li $t1,467
        puntoColor($t0,$t1,$t3)
        li $t1,468
        puntoColor($t0,$t1,$t3)
        li $t1,473
        puntoColor($t0,$t1,$t3)
        li $t1,475
        puntoColor($t0,$t1,$t3)
        li $t1,479
        puntoColor($t0,$t1,$t3)
        li $t1,480
        puntoColor($t0,$t1,$t3)
        li $t1,485
        puntoColor($t0,$t1,$t3)
        li $t1,505
        puntoColor($t0,$t1,$t3)
        li $t1,506
        puntoColor($t0,$t1,$t3)
        li $t1,507
        puntoColor($t0,$t1,$t3)
        li $t1,509
        puntoColor($t0,$t1,$t3)
        li $t1,511
        puntoColor($t0,$t1,$t3)
        li $t1,512
        puntoColor($t0,$t1,$t3)
        li $t1,513
        puntoColor($t0,$t1,$t3)
        li $t1,515
        puntoColor($t0,$t1,$t3)
        li $t1,517
        puntoColor($t0,$t1,$t3)
        li $t1,519
        puntoColor($t0,$t1,$t3)
        li $t1,521
        puntoColor($t0,$t1,$t3)
        li $t1,522
        puntoColor($t0,$t1,$t3)
        li $t1,523
        puntoColor($t0,$t1,$t3)
        li $t1,524
        puntoColor($t0,$t1,$t3)
        li $t1,525
        puntoColor($t0,$t1,$t3)
        li $t1,527
        puntoColor($t0,$t1,$t3)
        li $t1,528
        puntoColor($t0,$t1,$t3)
        li $t1,529
        puntoColor($t0,$t1,$t3)
        li $t1,530
        puntoColor($t0,$t1,$t3)
        li $t1,531
        puntoColor($t0,$t1,$t3)
        li $t1,533
        puntoColor($t0,$t1,$t3)
        li $t1,535
        puntoColor($t0,$t1,$t3)
        li $t1,536
        puntoColor($t0,$t1,$t3)
        li $t1,537
        puntoColor($t0,$t1,$t3)
        li $t1,538
        puntoColor($t0,$t1,$t3)
        li $t1,541
        puntoColor($t0,$t1,$t3)
        li $t1,543
        puntoColor($t0,$t1,$t3)
        li $t1,544
        puntoColor($t0,$t1,$t3)
        li $t1,545
        puntoColor($t0,$t1,$t3)
        li $t1,547
        puntoColor($t0,$t1,$t3)
        li $t1,549
        puntoColor($t0,$t1,$t3)
        li $t1,550
        puntoColor($t0,$t1,$t3)
        li $t1,551
        puntoColor($t0,$t1,$t3)
        li $t1,553
        puntoColor($t0,$t1,$t3)
        li $t1,555
        puntoColor($t0,$t1,$t3)
        li $t1,557
        puntoColor($t0,$t1,$t3)
        li $t1,559
        puntoColor($t0,$t1,$t3)
        li $t1,562
        puntoColor($t0,$t1,$t3)
        li $t1,565
        puntoColor($t0,$t1,$t3)
        li $t1,572
        puntoColor($t0,$t1,$t3)
        li $t1,575
        puntoColor($t0,$t1,$t3)
        li $t1,576
        puntoColor($t0,$t1,$t3)
        li $t1,577
        puntoColor($t0,$t1,$t3)
        li $t1,579
        puntoColor($t0,$t1,$t3)
        li $t1,587
        puntoColor($t0,$t1,$t3)
        li $t1,591
        puntoColor($t0,$t1,$t3)
        li $t1,593
        puntoColor($t0,$t1,$t3)
        li $t1,594
        puntoColor($t0,$t1,$t3)
        li $t1,596
        puntoColor($t0,$t1,$t3)
        li $t1,597
        puntoColor($t0,$t1,$t3)
        li $t1,598
        puntoColor($t0,$t1,$t3)
        li $t1,599
        puntoColor($t0,$t1,$t3)
        li $t1,600
        puntoColor($t0,$t1,$t3)
        li $t1,602
        puntoColor($t0,$t1,$t3)
        li $t1,604
        puntoColor($t0,$t1,$t3)
        li $t1,606
        puntoColor($t0,$t1,$t3)
        li $t1,607
        puntoColor($t0,$t1,$t3)
        li $t1,608
        puntoColor($t0,$t1,$t3)
        li $t1,609
        puntoColor($t0,$t1,$t3)
        li $t1,611
        puntoColor($t0,$t1,$t3)
        li $t1,612
        puntoColor($t0,$t1,$t3)
        li $t1,613
        puntoColor($t0,$t1,$t3)
        li $t1,614
        puntoColor($t0,$t1,$t3)
        li $t1,615
        puntoColor($t0,$t1,$t3)
        li $t1,616
        puntoColor($t0,$t1,$t3)
        li $t1,617
        puntoColor($t0,$t1,$t3)
        li $t1,619
        puntoColor($t0,$t1,$t3)
        li $t1,620
        puntoColor($t0,$t1,$t3)
        li $t1,621
        puntoColor($t0,$t1,$t3)
        li $t1,623
        puntoColor($t0,$t1,$t3)
        li $t1,625
        puntoColor($t0,$t1,$t3)
        li $t1,629
        puntoColor($t0,$t1,$t3)
        li $t1,632
        puntoColor($t0,$t1,$t3)
        li $t1,634
        puntoColor($t0,$t1,$t3)
        li $t1,636
        puntoColor($t0,$t1,$t3)
        li $t1,639
        puntoColor($t0,$t1,$t3)
        li $t1,640
        puntoColor($t0,$t1,$t3)
        li $t1,645
        puntoColor($t0,$t1,$t3)
        li $t1,649
        puntoColor($t0,$t1,$t3)
        li $t1,655
        puntoColor($t0,$t1,$t3)
        li $t1,659
        puntoColor($t0,$t1,$t3)
        li $t1,661
        puntoColor($t0,$t1,$t3)
        li $t1,663
        puntoColor($t0,$t1,$t3)
        li $t1,664
        puntoColor($t0,$t1,$t3)
        li $t1,668
        puntoColor($t0,$t1,$t3)
        li $t1,671
        puntoColor($t0,$t1,$t3)
        li $t1,672
        puntoColor($t0,$t1,$t3)
        li $t1,673
        puntoColor($t0,$t1,$t3)
        li $t1,674
        puntoColor($t0,$t1,$t3)
        li $t1,675
        puntoColor($t0,$t1,$t3)
        li $t1,677
        puntoColor($t0,$t1,$t3)
        li $t1,678
        puntoColor($t0,$t1,$t3)
        li $t1,679
        puntoColor($t0,$t1,$t3)
        li $t1,681
        puntoColor($t0,$t1,$t3)
        li $t1,682
        puntoColor($t0,$t1,$t3)
        li $t1,683
        puntoColor($t0,$t1,$t3)
        li $t1,684
        puntoColor($t0,$t1,$t3)
        li $t1,685
        puntoColor($t0,$t1,$t3)
        li $t1,686
        puntoColor($t0,$t1,$t3)
        li $t1,687
        puntoColor($t0,$t1,$t3)
        li $t1,688
        puntoColor($t0,$t1,$t3)
        li $t1,689
        puntoColor($t0,$t1,$t3)
        li $t1,691
        puntoColor($t0,$t1,$t3)
        li $t1,693
        puntoColor($t0,$t1,$t3)
        li $t1,696
        puntoColor($t0,$t1,$t3)
        li $t1,698
        puntoColor($t0,$t1,$t3)
        li $t1,700
        puntoColor($t0,$t1,$t3)
        li $t1,701
        puntoColor($t0,$t1,$t3)
        li $t1,702
        puntoColor($t0,$t1,$t3)
        li $t1,703
        puntoColor($t0,$t1,$t3)
        li $t1,704
        puntoColor($t0,$t1,$t3)
        li $t1,706
        puntoColor($t0,$t1,$t3)
        li $t1,709
        puntoColor($t0,$t1,$t3)
        li $t1,717
        puntoColor($t0,$t1,$t3)
        li $t1,723
        puntoColor($t0,$t1,$t3)
        li $t1,725
        puntoColor($t0,$t1,$t3)
        li $t1,726
        puntoColor($t0,$t1,$t3)
        li $t1,730
        puntoColor($t0,$t1,$t3)
        li $t1,734
        puntoColor($t0,$t1,$t3)
        li $t1,735
        puntoColor($t0,$t1,$t3)
        li $t1,736
        puntoColor($t0,$t1,$t3)
        li $t1,738
        puntoColor($t0,$t1,$t3)
        li $t1,740
        puntoColor($t0,$t1,$t3)
        li $t1,741
        puntoColor($t0,$t1,$t3)
        li $t1,742
        puntoColor($t0,$t1,$t3)
        li $t1,743
        puntoColor($t0,$t1,$t3)
        li $t1,744
        puntoColor($t0,$t1,$t3)
        li $t1,745
        puntoColor($t0,$t1,$t3)
        li $t1,747
        puntoColor($t0,$t1,$t3)
        li $t1,748
        puntoColor($t0,$t1,$t3)
        li $t1,749
        puntoColor($t0,$t1,$t3)
        li $t1,750
        puntoColor($t0,$t1,$t3)
        li $t1,751
        puntoColor($t0,$t1,$t3)
        li $t1,752
        puntoColor($t0,$t1,$t3)
        li $t1,753
        puntoColor($t0,$t1,$t3)
        li $t1,754
        puntoColor($t0,$t1,$t3)
        li $t1,755
        puntoColor($t0,$t1,$t3)
        li $t1,757
        puntoColor($t0,$t1,$t3)
        li $t1,758
        puntoColor($t0,$t1,$t3)
        li $t1,759
        puntoColor($t0,$t1,$t3)
        li $t1,760
        puntoColor($t0,$t1,$t3)
        li $t1,761
        puntoColor($t0,$t1,$t3)
        li $t1,762
        puntoColor($t0,$t1,$t3)
        li $t1,764
        puntoColor($t0,$t1,$t3)
        li $t1,767
        puntoColor($t0,$t1,$t3)
        li $t1,768
        puntoColor($t0,$t1,$t3)
        li $t1,770
        puntoColor($t0,$t1,$t3)
        li $t1,777
        puntoColor($t0,$t1,$t3)
        li $t1,782
        puntoColor($t0,$t1,$t3)
        li $t1,787
        puntoColor($t0,$t1,$t3)
        li $t1,796
        puntoColor($t0,$t1,$t3)
        li $t1,798
        puntoColor($t0,$t1,$t3)
        li $t1,799
        puntoColor($t0,$t1,$t3)
        li $t1,800
        puntoColor($t0,$t1,$t3)
        li $t1,802
        puntoColor($t0,$t1,$t3)
        li $t1,804
        puntoColor($t0,$t1,$t3)
        li $t1,806
        puntoColor($t0,$t1,$t3)
        li $t1,807
        puntoColor($t0,$t1,$t3)
        li $t1,808
        puntoColor($t0,$t1,$t3)
        li $t1,809
        puntoColor($t0,$t1,$t3)
        li $t1,811
        puntoColor($t0,$t1,$t3)
        li $t1,812
        puntoColor($t0,$t1,$t3)
        li $t1,813
        puntoColor($t0,$t1,$t3)
        li $t1,817
        puntoColor($t0,$t1,$t3)
        li $t1,821
        puntoColor($t0,$t1,$t3)
        li $t1,822
        puntoColor($t0,$t1,$t3)
        li $t1,823
        puntoColor($t0,$t1,$t3)
        li $t1,824
        puntoColor($t0,$t1,$t3)
        li $t1,825
        puntoColor($t0,$t1,$t3)
        li $t1,826
        puntoColor($t0,$t1,$t3)
        li $t1,828
        puntoColor($t0,$t1,$t3)
        li $t1,829
        puntoColor($t0,$t1,$t3)
        li $t1,830
        puntoColor($t0,$t1,$t3)
        li $t1,831
        puntoColor($t0,$t1,$t3)
        li $t1,832
        puntoColor($t0,$t1,$t3)
        li $t1,834
        puntoColor($t0,$t1,$t3)
        li $t1,835
        puntoColor($t0,$t1,$t3)
        li $t1,836
        puntoColor($t0,$t1,$t3)
        li $t1,840
        puntoColor($t0,$t1,$t3)
        li $t1,845
        puntoColor($t0,$t1,$t3)
        li $t1,847
        puntoColor($t0,$t1,$t3)
        li $t1,849
        puntoColor($t0,$t1,$t3)
        li $t1,850
        puntoColor($t0,$t1,$t3)
        li $t1,851
        puntoColor($t0,$t1,$t3)
        li $t1,853
        puntoColor($t0,$t1,$t3)
        li $t1,857
        puntoColor($t0,$t1,$t3)
        li $t1,860
        puntoColor($t0,$t1,$t3)
        li $t1,863
        puntoColor($t0,$t1,$t3)
        li $t1,864
        puntoColor($t0,$t1,$t3)
        li $t1,867
        puntoColor($t0,$t1,$t3)
        li $t1,870
        puntoColor($t0,$t1,$t3)
        li $t1,871
        puntoColor($t0,$t1,$t3)
        li $t1,872
        puntoColor($t0,$t1,$t3)
        li $t1,874
        puntoColor($t0,$t1,$t3)
        li $t1,875
        puntoColor($t0,$t1,$t3)
        li $t1,876
        puntoColor($t0,$t1,$t3)
        li $t1,878
        puntoColor($t0,$t1,$t3)
        li $t1,879
        puntoColor($t0,$t1,$t3)
        li $t1,885
        puntoColor($t0,$t1,$t3)
        li $t1,887
        puntoColor($t0,$t1,$t3)
        li $t1,888
        puntoColor($t0,$t1,$t3)
        li $t1,889
        puntoColor($t0,$t1,$t3)
        li $t1,890
        puntoColor($t0,$t1,$t3)
        li $t1,891
        puntoColor($t0,$t1,$t3)
        li $t1,892
        puntoColor($t0,$t1,$t3)
        li $t1,893
        puntoColor($t0,$t1,$t3)
        li $t1,895
        puntoColor($t0,$t1,$t3)
        li $t1,896
        puntoColor($t0,$t1,$t3)
        li $t1,902
        puntoColor($t0,$t1,$t3)
        li $t1,913
        puntoColor($t0,$t1,$t3)
        li $t1,914
        puntoColor($t0,$t1,$t3)
        li $t1,915
        puntoColor($t0,$t1,$t3)
        li $t1,920
        puntoColor($t0,$t1,$t3)
        li $t1,923
        puntoColor($t0,$t1,$t3)
        li $t1,927
        puntoColor($t0,$t1,$t3)
        li $t1,928
        puntoColor($t0,$t1,$t3)
        li $t1,929
        puntoColor($t0,$t1,$t3)
        li $t1,930
        puntoColor($t0,$t1,$t3)
        li $t1,931
        puntoColor($t0,$t1,$t3)
        li $t1,932
        puntoColor($t0,$t1,$t3)
        li $t1,934
        puntoColor($t0,$t1,$t3)
        li $t1,935
        puntoColor($t0,$t1,$t3)
        li $t1,936
        puntoColor($t0,$t1,$t3)
        li $t1,938
        puntoColor($t0,$t1,$t3)
        li $t1,939
        puntoColor($t0,$t1,$t3)
        li $t1,940
        puntoColor($t0,$t1,$t3)
        li $t1,941
        puntoColor($t0,$t1,$t3)
        li $t1,943
        puntoColor($t0,$t1,$t3)
        li $t1,944
        puntoColor($t0,$t1,$t3)
        li $t1,945
        puntoColor($t0,$t1,$t3)
        li $t1,946
        puntoColor($t0,$t1,$t3)
        li $t1,947
        puntoColor($t0,$t1,$t3)
        li $t1,949
        puntoColor($t0,$t1,$t3)
        li $t1,951
        puntoColor($t0,$t1,$t3)
        li $t1,952
        puntoColor($t0,$t1,$t3)
        li $t1,953
        puntoColor($t0,$t1,$t3)
        li $t1,955
        puntoColor($t0,$t1,$t3)
        li $t1,957
        puntoColor($t0,$t1,$t3)
        li $t1,958
        puntoColor($t0,$t1,$t3)
        li $t1,959
        puntoColor($t0,$t1,$t3)
        li $t1,960
        puntoColor($t0,$t1,$t3)
        li $t1,961
        puntoColor($t0,$t1,$t3)
        li $t1,968
        puntoColor($t0,$t1,$t3)
        li $t1,970
        puntoColor($t0,$t1,$t3)
        li $t1,975
        puntoColor($t0,$t1,$t3)
        li $t1,981
        puntoColor($t0,$t1,$t3)
        li $t1,991
        puntoColor($t0,$t1,$t3)
        li $t1,992
        puntoColor($t0,$t1,$t3)
        li $t1,993
        puntoColor($t0,$t1,$t3)
        li $t1,994
        puntoColor($t0,$t1,$t3)
        li $t1,995
        puntoColor($t0,$t1,$t3)
        li $t1,996
        puntoColor($t0,$t1,$t3)
        li $t1,997
        puntoColor($t0,$t1,$t3)
        li $t1,998
        puntoColor($t0,$t1,$t3)
        li $t1,999
        puntoColor($t0,$t1,$t3)
	li $k1,33
	li $t3,COLOR_JUGADOR
	inicioJugador($t0,$k1,$t3)
	li $t1,861
	li $t3,COLOR_META
	puntoColor($t0,$t1,$t3)
.end_macro

.macro eltriunfo(%t0)

	li $t1,0
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,2
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,3
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,4
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,5
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,6
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,7
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,8
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,9
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,10
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,11
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,12
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,13
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,14
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,15
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,16
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,17
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,18
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,19
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,20
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,21
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,22
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,23
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,24
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,25
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,26
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,27
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,28
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,29
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,30
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,31
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,32
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,33
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,34
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,35
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,36
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,37
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,38
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,39
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,40
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,41
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,42
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,43
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,44
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,45
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,46
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,47
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,48
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,49
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,50
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,51
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,52
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,53
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,54
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,55
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,56
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,57
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,58
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,59
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,60
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,61
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,62
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,63
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,64
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,65
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,66
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,67
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,68
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,69
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,70
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,71
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,72
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,73
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,74
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,75
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,76
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,77
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,78
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,79
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,80
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,81
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,82
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,83
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,84
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,85
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,86
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,87
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,88
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,89
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,90
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,91
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,92
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,93
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,94
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,95
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,96
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,97
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,98
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,99
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,100
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,101
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,102
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,103
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,104
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,105
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,106
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,107
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,108
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,109
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,110
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,111
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,112
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,113
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,114
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,115
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,116
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,117
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,118
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,119
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,120
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,121
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,122
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,123
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,124
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,125
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,126
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,127
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,128
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,129
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,130
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,131
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,132
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,133
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,134
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,135
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,136
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,137
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,138
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,139
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,140
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,141
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,142
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,143
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,144
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,145
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,146
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,147
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,148
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,149
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
	li $t1,150
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,151
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,152
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,153
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,154
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,155
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,156
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,157
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,158
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,159
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,160
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,161
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,162
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,163
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,164
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,165
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,166
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,167
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,168
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,169
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,170
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,171
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,172
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,173
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,174
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,175
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,176
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,177
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,178
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,179
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,180
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,181
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,182
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,183
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,184
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,185
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,186
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,187
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,188
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,189
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,190
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,191
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,192
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,193
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,194
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,195
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,196
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,197
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,198
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,199
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,200
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,201
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,202
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,203
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,204
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,205
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,206
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,207
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,208
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,209
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,210
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,211
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,212
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,213
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,214
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,215
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,216
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,217
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,218
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,219
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,220
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,221
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,222
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,223
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,224
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,225
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,226
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,227
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,228
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,229
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,230
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,231
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,232
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,233
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,234
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,235
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,236
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,237
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,238
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,239
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,240
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,241
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,242
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,243
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,244
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,245
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,246
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,247
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,248
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,249
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,250
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,251
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,252
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,253
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,254
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,255
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,256
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,257
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,258
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,259
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,260
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,261
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,262
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,263
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,264
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,265
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,266
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,267
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,268
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,269
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,270
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,271
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,272
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,273
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,274
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,275
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,276
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,277
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,278
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,279
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,280
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,281
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,282
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,283
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,284
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,285
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,286
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,287
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,288
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,289
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,290
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,291
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,292
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,293
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,294
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,295
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,296
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,297
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,298
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,299
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,300
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,301
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,302
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,303
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,304
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,305
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,306
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,307
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,308
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,309
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,310
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,311
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,312
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,313
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,314
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,315
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,316
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,317
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,318
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,319
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,320
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,321
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,322
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,323
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,324
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,325
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,326
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,327
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,328
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,329
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,330
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,331
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,332
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,333
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,334
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,335
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,336
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,337
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,338
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,339
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,340
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,341
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,342
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,343
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,344
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,345
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,346
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,347
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,348
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,349
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,350
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,351
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,352
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,353
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,354
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,355
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,356
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,357
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,358
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,359
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,360
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,361
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,362
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,363
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,364
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,365
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,366
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,367
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,368
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,369
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,370
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,371
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,372
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,373
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,374
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,375
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,376
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,377
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,378
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,379
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,380
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,381
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,382
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,383
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,384
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,385
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,386
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,387
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,388
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,389
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,390
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,391
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,392
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,393
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,394
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,395
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,396
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,397
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,398
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,399
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,400
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,401
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,402
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,403
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,404
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,405
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,406
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,407
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,408
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,409
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,410
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,411
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,412
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,413
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,414
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,415
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,416
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,417
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,418
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,419
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,420
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,421
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,422
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,423
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,424
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,425
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,426
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,427
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,428
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,429
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,430
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,431
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,432
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,433
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,434
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,435
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,436
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,437
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,438
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,439
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,440
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,441
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,442
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,443
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,444
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,445
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,446
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,447
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,448
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,449
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,450
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,451
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,452
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,453
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,454
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,455
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,456
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,457
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,458
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,459
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,460
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,461
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,462
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,463
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,464
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,465
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,466
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,467
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,468
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,469
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,470
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,471
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,472
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,473
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,474
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,475
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,476
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,477
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,478
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,479
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,480
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,481
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,482
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,483
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,484
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,485
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,486
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,487
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,488
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,489
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,490
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,491
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,492
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,493
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,494
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,495
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,496
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,497
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,498
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,499
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,500
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,501
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,502
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,503
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,504
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,505
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,506
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,507
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,508
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,509
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,510
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,511
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,512
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,513
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,514
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,515
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,516
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,517
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,518
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,519
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,520
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,521
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,522
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,523
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,524
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,525
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,526
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,527
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,528
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,529
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,530
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,531
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,532
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,533
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,534
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,535
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,536
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,537
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,538
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,539
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,540
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,541
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,542
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,543
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,544
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,545
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,546
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,547
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,548
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,549
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,550
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,551
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,552
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,553
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,554
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,555
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,556
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,557
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,558
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,559
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,560
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,561
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,562
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,563
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,564
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,565
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,566
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,567
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,568
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,569
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,570
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,571
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,572
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,573
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,574
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,575
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,576
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,577
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,578
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,579
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,580
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,581
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,582
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,583
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,584
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,585
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,586
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,587
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,588
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,589
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,590
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,591
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,592
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,593
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,594
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,595
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,596
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,597
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,598
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,599
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,600
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,601
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,602
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,603
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,604
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,605
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,606
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,607
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,608
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,609
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,610
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,611
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,612
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,613
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,614
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,615
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,616
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,617
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,618
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,619
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,620
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,621
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,622
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,623
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,624
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,625
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,626
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,627
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,628
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,629
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,630
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,631
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,632
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,633
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,634
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,635
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,636
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,637
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,638
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,639
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,640
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,641
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,642
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,643
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,644
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,645
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,646
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,647
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,648
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,649
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,650
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,651
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,652
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,653
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,654
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,655
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,656
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,657
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,658
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,659
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,660
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,661
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,662
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,663
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,664
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,665
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,666
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,667
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,668
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,669
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,670
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,671
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,672
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,673
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,674
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,675
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,676
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,677
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,678
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,679
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,680
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,681
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,682
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,683
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,684
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,685
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,686
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,687
        li $t3,ROJO
        puntoColor($t0,$t1,$t3)
        li $t1,688
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,689
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,690
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,691
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,692
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,693
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,694
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,695
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,696
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,697
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,698
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,699
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,700
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,701
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,702
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,703
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,704
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,705
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,706
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,707
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,708
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,709
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,710
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,711
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,712
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,713
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,714
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,715
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,716
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,717
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,718
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,719
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,720
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,721
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,722
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,723
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,724
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,725
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,726
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,727
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,728
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,729
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,730
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,731
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,732
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,733
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,734
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,735
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,736
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,737
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,738
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,739
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,740
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,741
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,742
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,743
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,744
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,745
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,746
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,747
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,748
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,749
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,750
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,751
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,752
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,753
        li $t3,AMARILLO
        puntoColor($t0,$t1,$t3)
        li $t1,754
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,755
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,756
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,757
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,758
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,759
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,760
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,761
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,762
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,763
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,764
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,765
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,766
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,767
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,768
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,769
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,770
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,771
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,772
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,773
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,774
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,775
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,776
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,777
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,778
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,779
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,780
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,781
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,782
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,783
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,784
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,785
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,786
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,787
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,788
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,789
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,790
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,791
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,792
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,793
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,794
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,795
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,796
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,797
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,798
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,799
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,800
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,801
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,802
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,803
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,804
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,805
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,806
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,807
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,808
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,809
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,810
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,811
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,812
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,813
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,814
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,815
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,816
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,817
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,818
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,819
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,820
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,821
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,822
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,823
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,824
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,825
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,826
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,827
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,828
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,829
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,830
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,831
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,832
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,833
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,834
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,835
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,836
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,837
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,838
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,839
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,840
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,841
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,842
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,843
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,844
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,845
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,846
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,847
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,848
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,849
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,850
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,851
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,852
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,853
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,854
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,855
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,856
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,857
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,858
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,859
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,860
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,861
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,862
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,863
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,864
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,865
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,866
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,867
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,868
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,869
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,870
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,871
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,872
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,873
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,874
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,875
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,876
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,877
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,878
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,879
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,880
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,881
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,882
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,883
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,884
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,885
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,886
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,887
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,888
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,889
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,890
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,891
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,892
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,893
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,894
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,895
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,896
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,897
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,898
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,899
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,900
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,901
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,902
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,903
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,904
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,905
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,906
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,907
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,908
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,909
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,910
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,911
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,912
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,913
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,914
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,915
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,916
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,917
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,918
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,919
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,920
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,921
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,922
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,923
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,924
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,925
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,926
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,927
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,928
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,929
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,930
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,931
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,932
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,933
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,934
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,935
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,936
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,937
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,938
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,939
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,940
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,941
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,942
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,943
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,944
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,945
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,946
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,947
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,948
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,949
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,950
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,951
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,952
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,953
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,954
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,955
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,956
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,957
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,958
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,959
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,960
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,961
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,962
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,963
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,964
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,965
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,966
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,967
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,968
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,969
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,970
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,971
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,972
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,973
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,974
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,975
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,976
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,977
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,978
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,979
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,980
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,981
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,982
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,983
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,984
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,985
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,986
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,987
        li $t3,NEGRO
        puntoColor($t0,$t1,$t3)
        li $t1,988
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,989
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,990
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,991
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,992
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,993
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,994
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,995
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,996
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,997
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,998
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,999
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1000
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1001
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1002
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1003
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1004
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1005
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1006
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1007
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1008
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1009
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1010
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1011
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1012
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1013
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1014
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1015
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1016
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1017
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1018
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1019
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1020
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1021
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1022
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
        li $t1,1023
        li $t3,BLANCO
        puntoColor($t0,$t1,$t3)
	li $t3,AMARILLO
	borde ($t0,$t3)
.end_macro
