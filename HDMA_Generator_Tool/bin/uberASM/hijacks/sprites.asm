sprite_code:
	LDX #$0C
	-
		DEX
		LDA !sprite_RAM,x
		ORA !sprite_RAM+12,x
		ORA !sprite_RAM+24,x
	BNE +
		CPX #$00
		BNE -
		BRA .return
	+
		LDA $14C8,x 
		BEQ .clear
		LDA !sprite_RAM,x
		STA $00
		LDA !sprite_RAM+12,x
		STA $01
		LDA !sprite_RAM+24,x
		STA $02
		PHK
		PEA.w .next
		JMP [$0000]
	.next
		CPX #$00
		BNE -
	.return
		RTS
	.clear
		LDA #$00
		STA !sprite_RAM,x
		STA !sprite_RAM+24,x
		STA !sprite_RAM+12,x
		BRA -
