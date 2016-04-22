	.include  "MacroParcial.asm"
	.data
	.eqv INICIO_PANTALLA 0xffff0000
	.eqv NEGRO 0x00000000
	.eqv COLOR_BORDE 0x00ff0000
	#.eqv COLOR_JUGADOR
	#.eqv COLOR_META
	.text
main:
	li $t0,INICIO_PANTALLA
	li $t3,0x00fffdfd
	inicioJugador($t0,$k1,$t3)
	leerDireccion()
	calcularMovimiento($v0)
	moverJugador($t0,$k1,$v0,$t3)
	
