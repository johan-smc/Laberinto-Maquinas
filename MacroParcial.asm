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

	

.macro jugarMapa1(%t0,%t3)
	mapa($t0,$t3)
	
.end_macro
.macro jugarMapa2(%t0,%t3)
	mapados($t0,$t3)
.end_macro
.macro imprimirWinner()
	li $t3,NEGRO
	li $a0,1
	borrarPantalla($t0,$t3,$a0)
	#####################
	
	
	####################
	li $t0,0
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
	beq $s0,0,winner
	bne $t5,0,reiniciar
	j sal
reiniciar:
	beq $t9,1,rMapa1
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
	li $t3,COLOR_JUGADOR
	moverJugador($t0,$k1,$v0,$t3,$t9)
	bne $t0,0,re
.end_macro

.macro principal(%t0,%a1)
inicio:
	li $v0,4
	add $a0,$a1,$zero
	syscall
	li $v0,5
	syscall
	add $t9,$zero,$v0
	jugar()
	j inicio
.end_macro


.macro mapa(%t0,%t3)

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
.end_macro

.macro mapados(%t0,%t3)

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

.end_macro
