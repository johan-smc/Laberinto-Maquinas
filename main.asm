	.include  "MacroParcial.asm"
	.data
	.eqv INICIO_PANTALLA 0xffff0000
	.eqv NEGRO 0x00000000
	.eqv COLOR_BORDE 0x00ff0000
	.eqv COLOR_JUGADOR 0x00ffffff
	.eqv COLOR_META 0x00FFFACD
pal:	.asciiz "Laberinto 1 o 2 \n" 
	.text
main:
	li $t0,INICIO_PANTALLA
	li $a1,pal
	principal()
	
	
