	.include  "MacroParcial.asm"
	.data
	.eqv INICIO_PANTALLA 0xffff0000
	.eqv NEGRO 0x00000000
	.eqv COLOR_BORDE 0x00ff0000
	.eqv COLOR_JUGADOR 0x000000FF
	.eqv COLOR_META 0x00006400
frase:	.asciiz "\nLaberinto 1 o 2 \n" 
	.text
main:
	li $t0,INICIO_PANTALLA
	la $a1,frase
	principal($t0,$a1)
	
	
