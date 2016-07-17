HEADER
LOROM

!level_freespace = $158000
!OW_freespace = $168000
!nmi_freespace = $16D000
!statusbar_freespace = $16E000
!global_freespace = $16F000
!sprite_freespace = $178000
!gamemode_freespace = $178100

!protect_bank1 = $158000     ;\ These should be the banks of code you wish to protect.
!protect_bank2 = $168000     ; | They should protect all of the freespace befined above
!protect_bank3 = $178000     ;/

macro origin(address)
	ORG <address>
endmacro

macro clean(code)
	<code>
endmacro

macro sprite_code_conditional(code)
	<code>
endmacro

!sprite_RAM = $7FAC80
!previous_mode = !sprite_RAM+36

ORG !protect_bank1
db "STAR"
dw Ratlabel1-Ratlabel2-$01
dw Ratlabel1-Ratlabel2-$01^$FFFF
Ratlabel2:

	incsrc hijacks/level.asm
	incsrc code/level_code.asm
	incsrc code/level_init_code.asm

Ratlabel1:

ORG !protect_bank2
db "STAR"
dw Ratlabel3-Ratlabel4-$01
dw Ratlabel3-Ratlabel4-$01^$FFFF
Ratlabel4:

	incsrc hijacks/overworld.asm
	incsrc code/ow_code.asm
	incsrc code/ow_init_code.asm

	incsrc hijacks/nmi.asm
	incsrc code/nmi_code.asm

	incsrc hijacks/statusbar.asm
	incsrc code/statusbar_code.asm

	incsrc hijacks/global.asm
	incsrc code/global_code.asm
	incsrc hijacks/sprites.asm  ;THIS INCLUDE MUST BE IN THE SAME BANK AS GLOBAL.ASM
Ratlabel3:

ORG !protect_bank3
db "STAR"
dw Ratlabel5-Ratlabel6-$01
dw Ratlabel5-Ratlabel6-$01^$FFFF
Ratlabel6:
	incsrc hijacks/gamemode.asm
	incsrc code/gamemode_code.asm
	incsrc code/gamemode_init_code.asm

Ratlabel5:


