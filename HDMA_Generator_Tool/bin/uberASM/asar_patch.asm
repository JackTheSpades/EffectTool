HEADER
LOROM

!true = 1
!false = 0

;Hihack list
!level     = !true
!OW        = !true
!nmi       = !true
!statusbar = !true
!global    = !true
!sprite    = !true
!gamemode  = !true

;ignore these -- they are dummy labels that are not used.
;only change freespace in the xkas patch (if you are using xkas_
!level_freespace = $000000
!OW_freespace = $000000
!nmi_freespace = $000000
!statusbar_freespace = $000000
!global_freespace = $000000
!sprite_freespace = $000000
!gamemode_freespace = $000000

macro origin(address)
	freecode
endmacro

macro clean(code)
	autoclean <code>
endmacro

macro sprite_code_conditional(code)
	if !sprite
		<code>
	endif
endmacro

!sprite_RAM = $7FAC80
!previous_mode = !sprite_RAM+36

	if !level
		incsrc hijacks/level.asm
		incsrc code/level_code.asm
		incsrc code/level_init_code.asm
	endif

	if !OW
		incsrc hijacks/overworld.asm
		incsrc code/ow_code.asm
		incsrc code/ow_init_code.asm
	endif
	
	if !nmi
	incsrc hijacks/nmi.asm
	incsrc code/nmi_code.asm
	endif
	
	if !statusbar
		incsrc hijacks/statusbar.asm
		incsrc code/statusbar_code.asm
	endif

	if !global
		incsrc hijacks/global.asm
		incsrc code/global_code.asm
	endif
	
	if !sprite
		incsrc hijacks/sprites.asm
	endif

	if !gamemode
		incsrc hijacks/gamemode.asm
		incsrc code/gamemode_code.asm
		incsrc code/gamemode_init_code.asm
	endif
