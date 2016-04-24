	.include  "MacroParcial.asm"
	.data
	.eqv INICIO_PANTALLA 0xffff0000
	.eqv NEGRO 0x00000000
	.eqv COLOR_BORDE 0x00ff0000
	.eqv COLOR_JUGADOR 0x00ffffff
	.eqv COLOR_META 0x00FFFACD
	.text
main:
	
	li $t0,INICIO_PANTALLA
	li $t3,COLOR_JUGADOR
	inicioJugador($t0,$k1,$t3)
	li $t0,INICIO_PANTALLA
	li $t1,1
	li $t3,COLOR_BORDE
	puntoColor($t0,$t1,$t3)
	li $t0,INICIO_PANTALLA
	li $t1,65
	li $t3,COLOR_META
	puntoColor($t0,$t1,$t3)
	jugar()
	
	
