;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;True LevelASM Code lies ahead.
;If you are too lazy to search for a level
;Use CTRL+F. The format is as following:
;levelx - Levels 0-F
;levelxx - Levels 10-FF
;levelxxx - Levels 100-1FF
;Should be pretty obvious...
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

level0:
	RTS
level1:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Level INIT Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;----------------------------------------------------------------------------------------------------
; Window is set to work on BG1, BG2, BG3, OBJ, Color
;----------------------------------------------------------------------------------------------------

LDA #$CC		; \ Enable BG1, BG2 for Window2
STA $41			; /
LDA #$0C		; \ Enable BG3,  for Window2
STA $42			; /
LDA #$CC		; \ Enable OBJ, Color for Window2
STA $43			; /
LDA #$22		; \  Set main screen black: Never
STA $44			;  | Disable color math on window: Inside
			; /  Use subscreen, Don't Use direct color mode
REP #$20		;\
LDA #$2801		; | Use Mode 1 on register 2128
STA $4330		; | 4330 = Mode, 4331 = Register
LDA #$9F00		; | Address of HDMA table
STA $4332		; | 4332 = Low-Byte of table, 4333 = High-Byte of table
LDY.b #$7F		; | Address of HDMA table, get bank byte
STY $4334		; | 4334 = Bank-Byte of table
SEP #$20		;/
LDA #$08		;\
TSB $0D9F		;/ Enable HDMA channel 3

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Level MAIN Code
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	LDX #$00
	STZ $00
	
	REP #$20
	LDA $80
	SEC : SBC #$0111
	CMP #$FEA1
	BCC .black
	
	LDA $80
	SBC #$FFB2
	CMP #$007D
	BCS .index			;C = set, wenn im bereich
	INC $00				;$00 = 1 wenn index benutzt werden soll
.index
	LDA #$0000
	SEP #$20
	LDA $80
	SEC : SBC #$2E
	LDY $00
	BNE .useindex
				
	CMP #$81
	BCC .somelabel
	SBC #$80
	STA $7F9F03
	LDA #$FF
	STA $7F9F04
	LDA #$00
	STA $7F9F05
	LDX #$03
	LDA #$80
	
.somelabel
	STA $7F9F00		; | Calculation result = number of blank scanlines before the cirle
				;/The calculations before made sure that if the circle (Mario) it to high, no blank lines are being drawn

	INX : INX : INX		;/  indexing needs to be updated 
	LDA #$FF		;\  Left position of the window need to be bigger than right to be blank
	STA $7F9F01		; | Store to freeRAM table
	LDA #$00		; | Right position of the window need to be smaller than left to be blank
	STA $7F9F02		; | Store to freeRAM table

.useindex
	EOR #$FF		;\  calculate A * -1	

INC A			; | so we start indexing at the table where circle needs to start in case it' too high
	REP #$30		; Indexing will be larger than #$FF so 16bit is needed	
ASL			;/  times two, since the table has two bytes per scanline
TAY			; Transfer A to Y for indexing
SEP #$20
;LDX $00			; Load X with the index stored in $00

.Loop			; Label to repeat the loop

LDA #$01		;\  Set scanline count to 1
STA $7F9F00,x		; | Store to freeRAM table

LDA .WindowTable,y	; |  Load left position from table
CLC : ADC $7E		; | Add Mario's X-position onscreen
BCS .skipleft		; | The addidtion should cause an overflow. If it does, skip next command
LDA #$00		; | If no overflow happens, than Mario's to far to the left, the result would be bigger than the right position
.skipleft		; | thus, the result is set back to start at #$00
STA $7F9F01,x		;/  Store left position to freeRAM table

LDA .WindowTable+1,y	;\  Load right position from table
CLC : ADC $7E		; | Add Mario's X-position onscreen
BCC .skipright		; | The addidtion shouldn't cause an overflow. If it doesn't, skip next command
LDA #$FF		; | If an overflow happens, than Mario's to far to the right, the result would be smaller than the left position
.skipright		; | thus, the result is set back to start at #$FF
STA $7F9F02,x		;/  Store right position to freeRAM table

INY : INY		;\  Increase Y by two for next table indexing
INX : INX : INX		;/  Increase X by three for next freeRAM indexing
CPY #$00F9		;\  Compare Y with length of table
BCC .Loop		;/  If less, we gotta continue

.black
SEP #$20
LDA #$01		;\  Scanline counter (lenght doesn't really matter here)
STA $7F9F00,x		; | Store to freeRAM table
LDA #$FF		; | After circle is put into freeRAM table
STA $7F9F01,x		; | Another blank scanline is added
LDA #$00		; | After the HDMA table reaches its end, it will draw the last line all the way to the bottom
STA $7F9F02,x		; | Thus drawing a blank below the circle all the way to the bottom
STA $7F9F03,x		;/ Store $00 as next scanline count to freeRAM table to indicate end of HDMA

SEP #$10		; X/Y back to 8bit or giant cookie monster will pop uo and eat your face :>
RTS

.WindowTable
	db $F6, $0B
	db $F1, $10
	db $ED, $14
	db $EB, $16
	db $E8, $19
	db $E6, $1B
	db $E4, $1D
	db $E2, $1F
	db $E0, $21
	db $DF, $23
	db $DD, $24
	db $DC, $25
	db $DA, $27
	db $D9, $28
	db $D8, $29
	db $D7, $2A
	db $D6, $2B
	db $D5, $2D
	db $D4, $2E
	db $D3, $2E
	db $D2, $2F
	db $D1, $30
	db $D0, $31
	db $CF, $32
	db $CE, $33
	db $CE, $33
	db $CD, $34
	db $CC, $35
	db $CC, $35
	db $CB, $36
	db $CA, $37
	db $CA, $37
	db $C9, $38
	db $C9, $38
	db $C8, $39
	db $C8, $39
	db $C7, $3A
	db $C7, $3A
	db $C6, $3B
	db $C6, $3B
	db $C6, $3B
	db $C5, $3C
	db $C5, $3C
	db $C4, $3D
	db $C4, $3D
	db $C4, $3D
	db $C4, $3D
	db $C3, $3E
	db $C3, $3E
	db $C3, $3E
	db $C3, $3E
	db $C3, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C1, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C2, $3F
	db $C3, $3F
	db $C3, $3E
	db $C3, $3E
	db $C3, $3E
	db $C3, $3E
	db $C4, $3D
	db $C4, $3D
	db $C4, $3D
	db $C4, $3D
	db $C5, $3C
	db $C5, $3C
	db $C6, $3B
	db $C6, $3B
	db $C6, $3B
	db $C7, $3A
	db $C7, $3A
	db $C8, $39
	db $C8, $39
	db $C9, $38
	db $C9, $38
	db $CA, $37
	db $CA, $37
	db $CB, $36
	db $CB, $36
	db $CC, $35
	db $CD, $34
	db $CE, $33
	db $CE, $33
	db $CF, $32
	db $D0, $31
	db $D1, $30
	db $D2, $2F
	db $D3, $2E
	db $D3, $2E
	db $D4, $2D
	db $D6, $2B
	db $D7, $2A
	db $D8, $29
	db $D9, $28
	db $DA, $27
	db $DC, $25
	db $DD, $24
	db $DF, $23
	db $E0, $21
	db $E2, $1F
	db $E4, $1D
	db $E6, $1B
	db $E8, $19
	db $EB, $16
	db $ED, $14
	db $F1, $10
	db $F5, $0C
level2:
	RTS
level3:
	RTS
level4:
	RTS
level5:
	RTS
level6:
	RTS
level7:
	RTS
level8:
	RTS
level9:
	RTS
levelA:
	RTS
levelB:
	RTS
levelC:
	RTS
levelD:
	RTS
levelE:
	RTS
levelF:
	RTS
level10:
	RTS
level11:
	RTS
level12:
	RTS
level13:
	RTS
level14:
	RTS
level15:
	RTS
level16:
	RTS
level17:
	RTS
level18:
	RTS
level19:
	RTS
level1A:
	RTS
level1B:
	RTS
level1C:
	RTS
level1D:
	RTS
level1E:
	RTS
level1F:
	RTS
level20:
	RTS
level21:
	RTS
level22:
	RTS
level23:
	RTS
level24:
	RTS
level25:
	RTS
level26:
	RTS
level27:
	RTS
level28:
	RTS
level29:
	RTS
level2A:
	RTS
level2B:
	RTS
level2C:
	RTS
level2D:
	RTS
level2E:
	RTS
level2F:
	RTS
level30:
	RTS
level31:
	RTS
level32:
	RTS
level33:
	RTS
level34:
	RTS
level35:
	RTS
level36:
	RTS
level37:
	RTS
level38:
	RTS
level39:
	RTS
level3A:
	RTS
level3B:
	RTS
level3C:
	RTS
level3D:
	RTS
level3E:
	RTS
level3F:
	RTS
level40:
	RTS
level41:
	RTS
level42:
	RTS
level43:
	RTS
level44:
	RTS
level45:
	RTS
level46:
	RTS
level47:
	RTS
level48:
	RTS
level49:
	RTS
level4A:
	RTS
level4B:
	RTS
level4C:
	RTS
level4D:
	RTS
level4E:
	RTS
level4F:
	RTS
level50:
	RTS
level51:
	RTS
level52:
	RTS
level53:
	RTS
level54:
	RTS
level55:
	RTS
level56:
	RTS
level57:
	RTS
level58:
	RTS
level59:
	RTS
level5A:
	RTS
level5B:
	RTS
level5C:
	RTS
level5D:
	RTS
level5E:
	RTS
level5F:
	RTS
level60:
	RTS
level61:
	RTS
level62:
	RTS
level63:
	RTS
level64:
	RTS
level65:
	RTS
level66:
	RTS
level67:
	RTS
level68:
	RTS
level69:
	RTS
level6A:
	RTS
level6B:
	RTS
level6C:
	RTS
level6D:
	RTS
level6E:
	RTS
level6F:
	RTS
level70:
	RTS
level71:
	RTS
level72:
	RTS
level73:
	RTS
level74:
	RTS
level75:
	RTS
level76:
	RTS
level77:
	RTS
level78:
	RTS
level79:
	RTS
level7A:
	RTS
level7B:
	RTS
level7C:
	RTS
level7D:
	RTS
level7E:
	RTS
level7F:
	RTS
level80:
	RTS
level81:
	RTS
level82:
	RTS
level83:
	RTS
level84:
	RTS
level85:
	RTS
level86:
	RTS
level87:
	RTS
level88:
	RTS
level89:
	RTS
level8A:
	RTS
level8B:
	RTS
level8C:
	RTS
level8D:
	RTS
level8E:
	RTS
level8F:
	RTS
level90:
	RTS
level91:
	RTS
level92:
	RTS
level93:
	RTS
level94:
	RTS
level95:
	RTS
level96:
	RTS
level97:
	RTS
level98:
	RTS
level99:
	RTS
level9A:
	RTS
level9B:
	RTS
level9C:
	RTS
level9D:
	RTS
level9E:
	RTS
level9F:
	RTS
levelA0:
	RTS
levelA1:
	RTS
levelA2:
	RTS
levelA3:
	RTS
levelA4:
	RTS
levelA5:
	RTS
levelA6:
	RTS
levelA7:
	RTS
levelA8:
	RTS
levelA9:
	RTS
levelAA:
	RTS
levelAB:
	RTS
levelAC:
	RTS
levelAD:
	RTS
levelAE:
	RTS
levelAF:
	RTS
levelB0:
	RTS
levelB1:
	RTS
levelB2:
	RTS
levelB3:
	RTS
levelB4:
	RTS
levelB5:
	RTS
levelB6:
	RTS
levelB7:
	RTS
levelB8:
	RTS
levelB9:
	RTS
levelBA:
	RTS
levelBB:
	RTS
levelBC:
	RTS
levelBD:
	RTS
levelBE:
	RTS
levelBF:
	RTS
levelC0:
	RTS
levelC1:
	RTS
levelC2:
	RTS
levelC3:
	RTS
levelC4:
	RTS
levelC5:
	RTS
levelC6:
	RTS
levelC7:
	RTS
levelC8:
	RTS
levelC9:
	RTS
levelCA:
	RTS
levelCB:
	RTS
levelCC:
	RTS
levelCD:
	RTS
levelCE:
	RTS
levelCF:
	RTS
levelD0:
	RTS
levelD1:
	RTS
levelD2:
	RTS
levelD3:
	RTS
levelD4:
	RTS
levelD5:
	RTS
levelD6:
	RTS
levelD7:
	RTS
levelD8:
	RTS
levelD9:
	RTS
levelDA:
	RTS
levelDB:
	RTS
levelDC:
	RTS
levelDD:
	RTS
levelDE:
	RTS
levelDF:
	RTS
levelE0:
	RTS
levelE1:
	RTS
levelE2:
	RTS
levelE3:
	RTS
levelE4:
	RTS
levelE5:

LDA #$00
STA $211B
LDA #$02
STA $211B

	LDA $13
	AND #$03
	BNE .return
	INC $36
.return
	RTS

levelE6:
	RTS
levelE7:
	RTS
levelE8:
	RTS
levelE9:
	RTS
levelEA:
	RTS
levelEB:
	RTS
levelEC:
	RTS
levelED:
	RTS
levelEE:
	RTS
levelEF:
	RTS
levelF0:
	RTS
levelF1:
	RTS
levelF2:
	RTS
levelF3:
	RTS
levelF4:
	RTS
levelF5:
	RTS
levelF6:
	RTS
levelF7:
	RTS
levelF8:
	RTS
levelF9:
	RTS
levelFA:
	RTS
levelFB:
	RTS
levelFC:
	RTS
levelFD:
	RTS
levelFE:
	RTS
levelFF:
	RTS
level100:
	RTS
level101:
	RTS
level102:
	RTS
level103:
	RTS
level104:
	RTS
level105:
	RTS
level106:
	LDA #%01100111			;| Affect layer 1,2,3
	STA $40				;/ and back enable
	RTS
level107:
	RTS
level108:
	RTS
level109:
	RTS
level10A:
	RTS
level10B:
	RTS
level10C:
	RTS
level10D:
	RTS
level10E:
	RTS
level10F:
	RTS
level110:
	RTS
level111:
	RTS
level112:
	RTS
level113:
	RTS
level114:
	RTS
level115:
	RTS
level116:
	RTS
level117:
	RTS
level118:
	RTS
level119:
	RTS
level11A:
	RTS
level11B:
	RTS
level11C:
	RTS
level11D:
	RTS
level11E:
	RTS
level11F:
	RTS
level120:
	RTS
level121:
	RTS
level122:
	RTS
level123:
	RTS
level124:
	RTS
level125:
	RTS
level126:
	RTS
level127:
	RTS
level128:
	RTS
level129:
	RTS
level12A:
	RTS
level12B:
	RTS
level12C:
	RTS
level12D:
	RTS
level12E:
	RTS
level12F:
	RTS
level130:
	RTS
level131:
	RTS
level132:
	RTS
level133:
	RTS
level134:
	RTS
level135:
	RTS
level136:
	RTS
level137:
	RTS
level138:
	RTS
level139:
	RTS
level13A:
	RTS
level13B:
	RTS
level13C:
	RTS
level13D:
	RTS
level13E:
	RTS
level13F:
	RTS
level140:
	RTS
level141:
	RTS
level142:
	RTS
level143:
	RTS
level144:
	RTS
level145:
	RTS
level146:
	RTS
level147:
	RTS
level148:
	RTS
level149:
	RTS
level14A:
	RTS
level14B:
	RTS
level14C:
	RTS
level14D:
	RTS
level14E:
	RTS
level14F:
	RTS
level150:
	RTS
level151:
	RTS
level152:
	RTS
level153:
	RTS
level154:
	RTS
level155:
	RTS
level156:
	RTS
level157:
	RTS
level158:
	RTS
level159:
	RTS
level15A:
	RTS
level15B:
	RTS
level15C:
	RTS
level15D:
	RTS
level15E:
	RTS
level15F:
	RTS
level160:
	RTS
level161:
	RTS
level162:
	RTS
level163:
	RTS
level164:
	RTS
level165:
	RTS
level166:
	RTS
level167:
	RTS
level168:
	RTS
level169:
	RTS
level16A:
	RTS
level16B:
	RTS
level16C:
	RTS
level16D:
	RTS
level16E:
	RTS
level16F:
	RTS
level170:
	RTS
level171:
	RTS
level172:
	RTS
level173:
	RTS
level174:
	RTS
level175:
	RTS
level176:
	RTS
level177:
	RTS
level178:
	RTS
level179:
	RTS
level17A:
	RTS
level17B:
	RTS
level17C:
	RTS
level17D:
	RTS
level17E:
	RTS
level17F:
	RTS
level180:
	RTS
level181:
	RTS
level182:
	RTS
level183:
	RTS
level184:
	RTS
level185:
	RTS
level186:
	RTS
level187:
	RTS
level188:
	RTS
level189:
	RTS
level18A:
	RTS
level18B:
	RTS
level18C:
	RTS
level18D:
	RTS
level18E:
	RTS
level18F:
	RTS
level190:
	RTS
level191:
	RTS
level192:
	RTS
level193:
	RTS
level194:
	RTS
level195:
	RTS
level196:
	RTS
level197:
	RTS
level198:
	RTS
level199:
	RTS
level19A:
	RTS
level19B:
	RTS
level19C:
	RTS
level19D:
	RTS
level19E:
	RTS
level19F:
	RTS
level1A0:
	RTS
level1A1:
	RTS
level1A2:
	RTS
level1A3:
	RTS
level1A4:
	RTS
level1A5:
	RTS
level1A6:
	RTS
level1A7:
	RTS
level1A8:
	RTS
level1A9:
	RTS
level1AA:
	RTS
level1AB:
	RTS
level1AC:
	RTS
level1AD:
	RTS
level1AE:
	RTS
level1AF:
	RTS
level1B0:
	RTS
level1B1:
	RTS
level1B2:
	RTS
level1B3:
	RTS
level1B4:
	RTS
level1B5:
	RTS
level1B6:
	RTS
level1B7:
	RTS
level1B8:
	RTS
level1B9:
	RTS
level1BA:
	RTS
level1BB:
	RTS
level1BC:
	RTS
level1BD:
	RTS
level1BE:
	RTS
level1BF:
	RTS
level1C0:
	RTS
level1C1:
	RTS
level1C2:
	RTS
level1C3:
	RTS
level1C4:
	RTS
level1C5:
	RTS
level1C6:
	RTS
level1C7:
	RTS
level1C8:
	RTS
level1C9:
	RTS
level1CA:
	RTS
level1CB:
	RTS
level1CC:
	RTS
level1CD:
	RTS
level1CE:
	RTS
level1CF:
	RTS
level1D0:
	RTS
level1D1:
	RTS
level1D2:
	RTS
level1D3:
	RTS
level1D4:
	RTS
level1D5:
	RTS
level1D6:
	RTS
level1D7:
	RTS
level1D8:
	RTS
level1D9:
	RTS
level1DA:
	RTS
level1DB:
	RTS
level1DC:
	RTS
level1DD:
	RTS
level1DE:
	RTS
level1DF:
	RTS
level1E0:
	RTS
level1E1:
	RTS
level1E2:
	RTS
level1E3:
	RTS
level1E4:
	RTS
level1E5:
	RTS
level1E6:
	RTS
level1E7:
	RTS
level1E8:
	RTS
level1E9:
	RTS
level1EA:
	RTS
level1EB:
	RTS
level1EC:
	RTS
level1ED:
	RTS
level1EE:
	RTS
level1EF:
	RTS
level1F0:
	RTS
level1F1:
	RTS
level1F2:
	RTS
level1F3:
	RTS
level1F4:
	RTS
level1F5:
	RTS
level1F6:
	RTS
level1F7:
	RTS
level1F8:
	RTS
level1F9:
	RTS
level1FA:
	RTS
level1FB:
	RTS
level1FC:
	RTS
level1FD:
	RTS
level1FE:
	RTS
level1FF:
	RTS
