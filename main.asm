	.include  "MacroParcial.asm"
	.data
	.eqv INICIO_PANTALLA 0xffff0000
	.text
main:
	li $t0,INICIO_PANTALLA
	li $t1,3
	li $t2,4
	li $t3,0x00fffdfd
	puntoColor($t0,$t1,$t3)
	li $t0,INICIO_PANTALLA
	li $t1,31
	li $t2,31
	li $t3,0x00fffdfd
	puntoColor($t0,$t1,$t2,$t3)
	li $t0,INICIO_PANTALLA
	li $t2,5
	li $t4,100
	li $t3,0x00fffdfd
	imprimirLineaH($t0,$t2,$t3,$t4)
	li $t0,INICIO_PANTALLA
	li $t1,2
	li $t3,0x00fffdfd
	puntoColor($t0,$t1,$t3)
	li $t0,INICIO_PANTALLA
	li $t2,10
	li $t4,10
	li $t3,0x0000FF00
	imprimirLineaV($t0,$t2,$t3,$t4)
	li $t0,INICIO_PANTALLA
	li $t3,0x00FF4500
	borde($t0,$t3)
	li $t0,3000
	sleep($t0)
	li $t0,INICIO_PANTALLA
	borrarPantalla($t0)
