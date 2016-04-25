	.include  "MacroParcial.asm"
	.data
	.eqv INICIO_PANTALLA 0xffff0000
frase:	.asciiz "\nLaberinto 1 o 2 \n" 
	.text
main:
	li $t0,INICIO_PANTALLA
	la $a1,frase
	principal($t0,$a1)
	
	
