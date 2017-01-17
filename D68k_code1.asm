;
;	D68k.code1 von Denis Ahrens 1992
;

;************************************
;	Pass 3: Code DisAssemblieren
;************************************

Labelcode_1
	tst.l	CodeSize-x(a5)		;Check für CodeLength = 0
	beq.b	LabelcodeE		;Wenn CodeSize = 0 dann RTS

	clr.l	PCounter-x(a5)	;bei NULL anfangen

Labelcode_2
	bsr	LabelcodeSearch		;Labels in Tabelle eintragen
	move.l	PCounter-x(a5),d0
	cmp.l	CodeSize-x(a5),d0
	blt.b	Labelcode_2

LabelcodeE:
	rts

GetNewLabel:
3$	tst.l	SprungPointer-x(a5)	;sind noch welche da ???
	beq.b	2$
	move.l	SprungMem-x(a5),a2
	subq.l	#4,SprungPointer-x(a5)
	add.l	SprungPointer-x(a5),a2
	move.l	(a2),d7				;DAS nächste Label

	bmi.b	3$	;minus darf es nicht sein (kann es auch nicht!)

	btst	#0,d7	;ungerade darf es nicht sein
	bne.b	3$

	move.l	HunkAnzahl-x(a5),d4
	beq.b	3$			;keine Hunks ???
	subq.l	#1,d4

	move.l	HunkMem-x(a5),a2
	moveq	#0,d5

1$	move.l	d5,d6
	lsl.l	#TabSize,d6
	cmp.l	d4,d5
	beq.b	4$

	cmp.l	64+8(a2,d6.l),d7	;des Nächsten Hunks
	bcs.b	4$
	addq.l	#1,d5
	bra.b	1$

4$	sub.l	8(a2,d6.l),d7		;negativ darf es nicht sein
	bmi.b	3$

	cmp.l	HunkAnzahl-x(a5),d5	;mit HunkAnzahl vergleichen
	bge.b	3$

	cmp.l	4(a2,d6.l),d7		;mit Hunkgröße vergleichen
	bge.b	3$

	move.l	4(a2,d6.l),CodeSize-x(a5)
	move.l	36(a2,d6.l),CodeAnfang-x(a5)
	move.l	d5,CurrHunk-x(a5)
	move.l	d7,PCounter-x(a5)
	rts

2$	addq.l	#4,SP
	rts

;**********************************
;	Erkennungsroutine
;**********************************

LabelcodeSearch:

	clr.l	ToAdd-x(a5)
	clr.b	Springer-x(a5)
	clr.b	WallPoint-x(a5)
	move.w	CodeID-x(a5),LastCodeID-x(a5)
	clr.w	CodeID-x(a5)

	move.l	CodeAnfang-x(a5),a0
	add.l	PCounter-x(a5),a0
	move.l	a0,Pointer-x(a5)	;WICHTIG !!!

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$

	move.l	PCounter-x(a5),d5	;waren wir bei dem Befehl schon ?
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a2
	move.l	32(a2,d6.l),a2		;BitMem
	lsr.l	#1,d5		;Testen ob Adresse schon im BitFeld
	move.w	d5,d7		;gesetzt war, wenn das der Fall ist dann
	lsr.l	#3,d5		;brauch die Adresse nicht abgearbeitet werden.
	btst	d7,0(a2,d5.w)
	bne	GetNewLabel

1$	move.b	(a0),d7

	and.w	#$00f0,d7
	lsr.b	#3,d7
	cmp.w	#16,d7			;ist eigentlich unnoetig!
	move.w	Liste2(PC,d7.w),d7
	jmp	Liste2(PC,d7.w)

Liste2:	dc.w	c2_gr0000-Liste2	;0000
	dc.w	c2_move_b-Liste2	;0001	MOVE.B
	dc.w	c2_move_l-Liste2	;0010	MOVE.L
	dc.w	c2_move_w-Liste2	;0011	MOVE.W
	dc.w	c2_gr0100-Liste2	;0100
	dc.w	c2_gr0101-Liste2	;0101
	dc.w	c2_bcc-Liste2		;0110	BCC
	dc.w	c2_moveq-Liste2		;0111
	dc.w	c2_gr1000-Liste2	;1000
	dc.w	c2_gr1001-Liste2	;1001	SUBx
	dc.w	c2_iNULL-Liste2		;1010	A-LINE
	dc.w	c2_gr1011-Liste2	;1011
	dc.w	c2_gr1100-Liste2	;1100
	dc.w	c2_gr1101-Liste2	;1101	ADDx
	dc.w	c2_gr1110-Liste2	;1110
	dc.w	c2_fline-Liste2		;1111	F-LINE

c2_gr0000
	move.w	(a0),d0

	cmp.w	#%0000000000111100,d0	;($003C) ORI to CCR
	beq	c2_ori_to_ccr
	cmp.w	#%0000000001111100,d0	;($007C) ORI to SR
	beq	c2_ori_to_sr
	cmp.w	#%0000001000111100,d0	;($023C) ANDI to CCR
	beq	c2_andi_to_ccr
	cmp.w	#%0000001001111100,d0	;($027C) ANDI to SR
	beq	c2_andi_to_sr
	cmp.w	#%0000101000111100,d0	;($0A3C) EORI to CCR
	beq	c2_eori_to_ccr
	cmp.w	#%0000101001111100,d0	;($0A7C) EORI to SR
	beq	c2_eori_to_sr

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq.b	1$

;	move.w	(a0),d0
	andi.w	#%1111110111111111,d0
	cmp.w	#%0000110011111100,d0	;CAS2 68020...
	beq	c2_cas2

	move.w	(a0),d0
	andi.w	#%1111111111110000,d0
	cmp.w	#%0000011011000000,d0	;RTM 68020 only
	beq	c2_rtm
1$
;	move.w	(a0),d0
	andi.w	#%1111111111000000,d0
	cmp.w	#%0000110000000000,d0	;CMPI.b
	beq	c2_cmpib
	cmp.w	#%0000110001000000,d0	;CMPI.w
	beq	c2_cmpiw
	cmp.w	#%0000110010000000,d0	;CMPI.l
	beq	c2_cmpil
	cmp.w	#%0000100000000000,d0	;BTST #data
	beq	c2_btstk
	cmp.w	#%0000100001000000,d0	;BCHG #data
	beq	c2_bitk
	cmp.w	#%0000100010000000,d0	;BCLR #data
	beq	c2_bitk
	cmp.w	#%0000100011000000,d0	;BSET #data
	beq	c2_bitk

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq.b	2$

	cmp.w	#%0000000011000000,d0	;CHK2.b 68020...
	beq	c2_chk2
	cmp.w	#%0000001011000000,d0	;CHK2.w 68020...
	beq	c2_chk2
	cmp.w	#%0000010011000000,d0	;CHK2.l 68020...
	beq	c2_chk2
	cmp.w	#%0000011011000000,d0	;CALLM 68020 only
	beq	c2_callm

	move.w	(a0),d0
	andi.w	#%1111100111000000,d0
	cmp.w	#%0000100011000000,d0	;CAS 68020...
	beq	c2_cas
2$
b2_cas	move.w	(a0),d0
	andi.w	#%1111111100000000,d0
	cmp.w	#%0000010000000000,d0	;SUBI.x
	beq	c2_subi
	cmp.w	#%0000011000000000,d0	;ADDI.x
	beq	c2_addi
	cmp.w	#%0000000000000000,d0	;ORI.x
	beq	c2_ori
	cmp.w	#%0000001000000000,d0	;ANDI.x
	beq	c2_andi
	cmp.w	#%0000101000000000,d0	;EORI.x
	beq	c2_eori
	cmp.w	#%0000111000000000,d0	;MOVES 68010
	beq	c2_moves

	move.w	(a0),d0
	andi.w	#%1111000100111000,d0
	cmp.w	#%0000000100001000,d0	;MOVEP
	beq	c2_movep

	move.w	(a0),d0
	andi.w	#%1111000111000000,d0
	cmp.w	#%0000000100000000,d0	;BTST
	beq	c2_btst
	cmp.w	#%0000000101000000,d0	;BCHG
	beq	c2_bit
	cmp.w	#%0000000110000000,d0	;BCLR
	beq	c2_bit
	cmp.w	#%0000000111000000,d0	;BSET
	beq	c2_bit

	bra	c2_iNULL		;Mir fällt nichts ein

c2_gr0100
	move.w	(a0),d0

	cmp.w	#$4e75,d0	;RTS
	beq	c2_rts
	cmp.w	#$4afc,d0	;ILLEGAL
	beq	c2_illegal
	cmp.w	#$4e70,d0	;RESET
	beq	QWERTYUIOPA
	cmp.w	#$4e71,d0	;NOP
	beq	QWERTYUIOPA
	cmp.w	#$4e72,d0	;STOP
	beq	c2_stop
	cmp.w	#$4e73,d0	;RTE
	beq	c2_rte
	cmp.w	#$4e74,d0	;RTD 68010...
	beq	c2_rtd
	cmp.w	#$4e76,d0	;TRAPV
	beq	QWERTYUIOPA
	cmp.w	#$4e77,d0	;RTR
	beq	c2_rtr

;	move.w	(a0),d0
	andi.w	#%1111111111111110,d0
	cmp.w	#%0100111001111010,d0	;MOVEC 68010...
	beq	c2_movec

;	move.w	(a0),d0
	andi.w	#%1111111111111000,d0
	cmp.w	#%0100100001000000,d0	;SWAP
	beq	QWERTYUIOPA
	cmp.w	#%0100111001010000,d0	;LINK.W
	beq	c2_link_w
	cmp.w	#%0100111001011000,d0	;UNLK
	beq	QWERTYUIOPA
	cmp.w	#%0100100001001000,d0	;BKPT 68010...
	beq	QWERTYUIOPA

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq.b	3$

	cmp.w	#%0100100000001000,d0	;LINK.L 68020...
	beq	c2_link_l
3$
;	move.w	(a0),d0
	andi.w	#%1111111111110000,d0
	cmp.w	#%0100111001000000,d0	;TRAP
	beq	QWERTYUIOPA
	cmp.w	#%0100111001100000,d0	;MOVE USP
	beq	QWERTYUIOPA

;	move.w	(a0),d0
	andi.w	#%1111111111000000,d0
	cmp.w	#%0100111010000000,d0	;JSR
	beq	c2_jsr
	cmp.w	#%0100111011000000,d0	;JMP
	beq	c2_jmp
	cmp.w	#%0100100000000000,d0	;NBCD
	beq	c2_nbcd
	cmp.w	#%0100100001000000,d0	;PEA
	beq	c2_pea
	cmp.w	#%0100101011000000,d0	;TAS
	beq	c2_tas
	cmp.w	#%0100000011000000,d0	;MOVE FROM SR
	beq	c2_movefromsr
	cmp.w	#%0100001011000000,d0	;MOVE FROM CCR
	beq	c2_movefromccr
	cmp.w	#%0100010011000000,d0	;MOVE TO CCR
	beq	c2_movetoccr
	cmp.w	#%0100011011000000,d0	;MOVE TO SR
	beq	c2_movetosr

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq.b	4$

	cmp.w	#%0100110001000000,d0	;DIVx.L 68020...
	beq	c2_divx
	cmp.w	#%0100110000000000,d0	;MULx.L 68020...
	beq	c2_mulx
4$
	move.w	(a0),d0
	andi.w	#%1111111010111000,d0
	cmp.w	#%0100100010000000,d0	;EXT & EXTB 68020...
	beq	c2_ext			;muss vor movem stehen

	move.w	(a0),d0
	andi.w	#%1111111100000000,d0
	cmp.w	#%0100101000000000,d0	;TST.x
	beq	c2_tst
	cmp.w	#%0100001000000000,d0	;CLR.x
	beq	c2_clr
	cmp.w	#%0100000000000000,d0	;NEGX.x
	beq	c2_negx
	cmp.w	#%0100010000000000,d0	;NEG.x
	beq	c2_neg
	cmp.w	#%0100011000000000,d0	;NOT.x
	beq	c2_not

	move.w	(a0),d0
	andi.w	#%1111101110000000,d0
	cmp.w	#%0100100010000000,d0	;MOVEM
	beq	c2_movem

	move.w	(a0),d0
	andi.w	#%1111000111000000,d0
	cmp.w	#%0100000111000000,d0	;LEA
	beq	c2_lea
	cmp.w	#%0100000110000000,d0	;CHK.w
	beq	c2_chk

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq.b	5$

	cmp.w	#%0100000100000000,d0	;CHK.l  68020...
	beq	c2_chkl
5$
	bra	c2_iNULL		;Mir fällt nichts ein

c2_gr0101
	move.w	(a0),d0
	andi.w	#%1111000011111000,d0
	cmp.w	#%0101000011001000,d0	;DBcc
	beq	c2_dbcc

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq.b	6$

	move.w	(a0),d0
	andi.w	#%1111000011111111,d0
	cmp.w	#%0101000011111100,d0	;TRAPCC 68020...
	beq	QWERTYUIOPA
	cmp.w	#%0101000011111010,d0	;TRAPCC.w 68020...
	beq	c2_trapcc_w
	cmp.w	#%0101000011111011,d0	;TRAPCC.l 68020...
	beq	c2_trapcc_l
6$
	move.w	(a0),d0
	andi.w	#%1111000011000000,d0
	cmp.w	#%0101000011000000,d0	;SCC
	beq	c2_scc

;	move.w	(a0),d0
	andi.w	#%1111000000000000,d0
	cmp.w	#%0101000000000000,d0	;ADDQ & SUBQ
	beq	c2_addsubq

	bra	c2_iNULL		;Mir fällt nichts ein

c2_gr1000
	move.w	(a0),d0
	andi.w	#%1111000111110000,d0
	cmp.w	#%1000000100000000,d0	;SBCD
	beq	QWERTYUIOPA

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq.b	7$

	cmp.w	#%1000000101000000,d0	;PACK 68020...
	beq	c2_pack
	cmp.w	#%1000000110000000,d0	;UNPK 68020...
	beq	c2_unpk
7$
	move.w	(a0),d0
	andi.w	#%1111000011000000,d0
	cmp.w	#%1000000011000000,d0	;DIVU & DIVS
	beq	c2_div

;	move.w	(a0),d0
	andi.w	#%1111000000000000,d0
	cmp.w	#%1000000000000000,d0	;OR.x
	beq	c2_or

	bra	c2_iNULL		;Mir fällt nichts ein

c2_gr1001
	move.w	(a0),d0
	andi.w	#%1111000100110000,d0
	cmp.w	#%1001000100000000,d0	;SUBX
	beq	c2_subx
b2_subx
	move.w	(a0),d0
	andi.w	#%1111000000000000,d0
	cmp.w	#%1001000000000000,d0	;SUB.x
	beq	c2_sub

	bra	c2_iNULL		;Mir fällt nichts ein

c2_gr1011
	move.w	(a0),d0
	andi.w	#%1111000111111000,d0
	cmp.w	#%1011000100001000,d0	;CMPM.b
	beq	QWERTYUIOPA
	cmp.w	#%1011000101001000,d0	;CMPM.w
	beq	QWERTYUIOPA
	cmp.w	#%1011000110001000,d0	;CMPM.l
	beq	QWERTYUIOPA

;	move.w	(a0),d0
	andi.w	#%1111000111000000,d0
	cmp.w	#%1011000100000000,d0	;EOR.b
	beq	c2_eor_b
	cmp.w	#%1011000101000000,d0	;EOR.w
	beq	c2_eor_w
	cmp.w	#%1011000110000000,d0	;EOR.l
	beq	c2_eor_l
	cmp.w	#%1011000000000000,d0	;CMP.b
	beq	c2_cmp_b
	cmp.w	#%1011000001000000,d0	;CMP.w
	beq	c2_cmp_w
	cmp.w	#%1011000010000000,d0	;CMP.l
	beq	c2_cmp_l
	cmp.w	#%1011000011000000,d0	;CMPA.w
	beq	c2_cmpa_w
	cmp.w	#%1011000111000000,d0	;CMPA.l
	beq	c2_cmpa_l

	bra	c2_iNULL		;Mir fällt nichts ein

c2_gr1100
	move.w	(a0),d0
	andi.w	#%1111000111111000,d0
	cmp.w	#%1100000101000000,d0	;EXG DATA
	beq	QWERTYUIOPA
	cmp.w	#%1100000101001000,d0	;EXG ADRESS
	beq	QWERTYUIOPA
	cmp.w	#%1100000110001000,d0	;EXG DATA & ADRESS
	beq	QWERTYUIOPA

;	move.w	(a0),d0
	andi.w	#%1111000111110000,d0
	cmp.w	#%1100000100000000,d0	;ABCD
	beq	QWERTYUIOPA

;	move.w	(a0),d0
	andi.w	#%1111000011000000,d0
	cmp.w	#%1100000011000000,d0	;MULU & MULS
	beq	c2_mul

;	move.w	(a0),d0
	andi.w	#%1111000000000000,d0
	cmp.w	#%1100000000000000,d0	;AND.x
	beq	c2_and

	bra	c2_iNULL		;Mir fällt nichts ein

c2_gr1101
	move.w	(a0),d0
	andi.w	#%1111000100110000,d0
	cmp.w	#%1101000100000000,d0	;ADDX
	beq	c2_addx

b2_addx	move.w	(a0),d0
	andi.w	#%1111000000000000,d0
	cmp.w	#%1101000000000000,d0	;ADD.x
	beq	c2_add

	bra	c2_iNULL		;Mir fällt nichts ein

c2_gr1110
	move.w	(a0),d0
	andi.w	#%1111100011000000,d0
	cmp.w	#%1110000011000000,d0	;ASL, ROL, LSL, ROXL mit _EA_
	beq	c2_shift_ea

;	move.w	(a0),d0
	andi.w	#%1111000011000000,d0
	cmp.w	#%1110000000000000,d0	;ASL, ROL, LSL, ROXL
	beq	QWERTYUIOPA
	cmp.w	#%1110000001000000,d0	;ASL, ROL, LSL, ROXL mit _Dx_
	beq	QWERTYUIOPA
	cmp.w	#%1110000010000000,d0	;ASL, ROL, LSL, ROXL
	beq	QWERTYUIOPA

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq.b	8$

	move.w	(a0),d0
	andi.w	#%1111111111000000,d0
	cmp.w	#%1110100011000000,d0	;BFTST 68020...
	beq	c2_bftst
	cmp.w	#%1110101011000000,d0	;BFCHG 68020...
	beq	c2_bfchg
	cmp.w	#%1110110011000000,d0	;BFCLR 68020...
	beq	c2_bfclr
	cmp.w	#%1110111011000000,d0	;BFSET 68020...
	beq	c2_bfset
	cmp.w	#%1110100111000000,d0	;BFEXTU 68020...
	beq	c2_bfextu
	cmp.w	#%1110101111000000,d0	;BFEXTS 68020...
	beq	c2_bfexts
	cmp.w	#%1110110111000000,d0	;BFFFO 68020...
	beq	c2_bfffo
	cmp.w	#%1110111111000000,d0	;BFINS 68020...
	beq	c2_bfins
8$
	bra	c2_NULL		;Mir fällt nichts ein

;**********************************
;	WallPoint Befehle
;**********************************

c2_rts:
c2_rte:
c2_rtm:
c2_rtr:
c2_illegal:
	st	WallPoint-x(a5)
	bra	QWERTYUIOPA

;**********************************
;	Die einzelnen Routinen
;**********************************

c2_rtd:
	st	WallPoint-x(a5)

c2_stop:
c2_ori_to_sr:
c2_andi_to_sr:
c2_eori_to_sr:
c2_ori_to_ccr:	
c2_andi_to_ccr:	
c2_eori_to_ccr:	
c2_link_w
c2_to_ccr
c2_movec
c2_movep
c2_pack
c2_unpk
c2_trapcc_w
	addq.l	#2,ToAdd-x(a5)
	bra	QWERTYUIOPA

;**********************************

c2_shift_ea:

	move.w	#%000111111100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_movetoccr:
c2_movetosr:
c2_chk:
c2_div:
c2_mul:
	move.b	#'W',SizeBWL-x(a5)
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_chkl:
	move.b	#'L',SizeBWL-x(a5)
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_tas:
c2_nbcd:
c2_scc:
c2_movefromccr:
c2_movefromsr:
c2_eor_b
c2_eor_w
c2_eor_l
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_jmp:
	move.w	#1,CodeID-x(a5)
	st	WallPoint-x(a5)
c2_jsr:
	st	Springer-x(a5)
c2_lea:
c2_pea:
	move.w	#%011111100100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;********************************************

c2_cas:
;	move.l	Pointer-x(a5),a0
	move.b	(a0),d2
	and.b	#%00000110,d2
	bne.b	1$
	bsr	DochFalsch2
	bra	b2_cas

1$	move.w	#%011001111100,Adressposs-x(a5)
	addq.l	#2,ToAdd-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;********************************************

c2_link_l:
c2_trapcc_l:
c2_cas2:
	addq.l	#4,ToAdd-x(a5)
	bra	QWERTYUIOPA

;********************************************

;Dies klappt auch mit CMP2 (c2_cmp2)

c2_callm
c2_chk2	addq.l	#2,ToAdd-x(a5)
	move.w	#%011111100100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;********************************************

c2_mulx
c2_divx	addq.l	#2,ToAdd-x(a5)
	move.w	#%111111111101,Adressposs-x(a5)
	move.b	#'L',SizeBWL-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;********************************************

c2_moveq:
;	move.l	Pointer-x(a5),a0

	tst.b	ArguD-x(a5)	;TRACE ?
	beq	3$

	clr.w	d0
	move.b	1(a0),d0
	move.w	d0,Jumps-x(a5)
	bra	QWERTYUIOPA

3$	cmp.l	#"util",(a0)	;utility.library
	bne.b	1$
	cmp.l	#"ity.",4(a0)
	bne.b	1$
	moveq	#16-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

1$	cmp.l	#"work",(a0)	;workbench.library
	bne.b	2$
	cmp.l	#"benc",4(a0)
	bne.b	2$
	moveq	#18-2,d0
	add.l	d0,ToAdd-x(a5)

2$	bra	QWERTYUIOPA

;********************************************

c2_bcc:

;	move.l	Pointer-x(a5),a0

	tst.b	ArguD-x(a5)	;TRACE ?
	bne	99$

	cmp.l	#"grap",(a0)	;graphics.library
	bne.b	1$
	cmp.l	#"hics",4(a0)
	bne.b	1$
	moveq	#18-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

1$	cmp.l	#"intu",(a0)	;intuition.library
	bne.b	2$
	cmp.l	#"itio",4(a0)
	bne.b	2$
	moveq	#18-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

2$	cmp.l	#"dos.",(a0)	;dos.library
	bne.b	3$
	cmp.l	#"libr",4(a0)
	bne.b	3$
	moveq	#12-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

3$	cmp.l	#"loca",(a0)	;locale.library
	bne.b	4$
	cmp.l	#"le.l",4(a0)
	bne.b	4$
	moveq	#16-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

4$	cmp.l	#"gadt",(a0)	;gadtools.library
	bne.b	5$
	cmp.l	#"ools",4(a0)
	bne.b	5$
	moveq	#18-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

5$	cmp.l	#"asl.",(a0)	;asl.library
	bne.b	6$
	cmp.l	#"libr",4(a0)
	bne.b	6$
	moveq	#12-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

6$	cmp.l	#"iffp",(a0)	;iffparse.library
	bne.b	7$
	cmp.l	#"arse",4(a0)
	bne.b	7$
	moveq	#18-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

7$	cmp.l	#"disk",(a0)	;diskfont.library
	bne.b	8$
	cmp.l	#"font",4(a0)
	bne.b	8$
	moveq	#18-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

8$	cmp.l	#"bull",(a0)	;bullet.library
	bne.b	9$
	cmp.l	#"et.l",4(a0)
	bne.b	9$
	moveq	#16-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

9$	cmp.l	#"comm",(a0)	;commodities.library
	bne.b	10$
	cmp.l	#"odit",4(a0)
	bne.b	10$
	moveq	#20-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

10$	cmp.l	#"expa",(a0)	;expansion.library
	bne.b	11$
	cmp.l	#"nsio",4(a0)
	bne.b	11$
	moveq	#18-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

11$	cmp.l	#"icon",(a0)	;icon.library
	bne.b	12$
	cmp.l	#".lib",4(a0)
	bne.b	12$
	moveq	#14-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

12$	cmp.l	#"exec",(a0)	;exec.library
	bne.b	13$
	cmp.l	#".lib",4(a0)
	bne.b	13$
	moveq	#14-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

13$	cmp.l	#"libr",(a0)	;library
	bne.b	14$
	cmp.l	#$61727900,4(a0)	;'ary',0
	bne.b	14$
	moveq	#8-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

14$	cmp.l	#"devi",(a0)	;device
	bne.b	15$
	cmp.w	#"ce",4(a0)
	bne.b	15$
	moveq	#8-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

15$
99$	st	Springer-x(a5)

	move.b	(a0),d2
	and.b	#%00001111,d2
	seq	WallPoint-x(a5)
	move.b	1(a0),d2
	beq.b	bxx12

	btst	#0,d2		;Test ob Sprung ungerade
	bne.b	bxx22
	ext.w	d2
	ext.l	d2
	add.l	PCounter-x(a5),d2
	addq.l	#2,d2
	bmi.b	c2_bccfail	;wenn sprung ins Minus

	moveq	#1,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX08
	bra	QWERTYUIOPA

c2_bccfail
	bra	c2_iNULL

c2_dbcc:
	st	Springer-x(a5)
;	move.l	Pointer-x(a5),a0
bxx12
	move.w	2(a0),d2
	beq.b	2$		;falls sprung = null
	btst	#0,d2		;Test ob Sprung ungerade
	bne.b	c2_bccfail
	ext.l	d2
	add.l	PCounter-x(a5),d2
	addq.l	#2,d2
	bmi.b	c2_bccfail		;wenn sprung ins Minus

	moveq	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX16
2$	addq.l	#2,ToAdd-x(a5)
	bra	QWERTYUIOPA

bxx22	cmp.b	#$ff,d2
	bne.b	c2_bccfail
	move.l	2(a0),d2
	beq.b	2$		;falls sprung = null
	btst	#0,d2		;Test ob Sprung ungerade
	bne.b	c2_bccfail
	add.l	PCounter-x(a5),d2
	addq.l	#2,d2		;das ist bei bcc nun mal so
	bmi.b	c2_bccfail		;wenn sprung ins Minus

	moveq	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX32
2$	addq.l	#4,ToAdd-x(a5)
	bra	QWERTYUIOPA

;**********************************

c2_subx:
	bsr	GetBWL
	cmp.b	#'?',SizeBWL-x(a5)
	bne	QWERTYUIOPA
	bsr	DochFalsch2
	bra	b2_subx

;**********************************

c2_addx:
	bsr	GetBWL
	cmp.b	#'?',SizeBWL-x(a5)
	bne	QWERTYUIOPA
	bsr	DochFalsch2
	bra	b2_addx

;**********************************

c2_ext:
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	btst	#8,d2
	beq	QWERTYUIOPA

	tst.b	ArguF-x(a5)		;68020 Option ??
	bne	QWERTYUIOPA

	bsr	DochFalsch2
	bra	c2_iNULL

;**********************************

c2_move_b
	move.b	#'B',SizeBWL-x(a5)
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA2
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetDEA2_1
	bra	QWERTYUIOPA

c2_move_w
	tst.b	ArguD-x(a5)	;TRACE ?
	bne.b	3$

	cmp.l	#"6804",(a0)	;68040.library
	bne.b	1$
	cmp.l	#"0.li",4(a0)
	bne.b	1$
	moveq	#14-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

1$	cmp.l	#"0123",(a0)	;0123456789abcdef
	bne.b	3$
	cmp.l	#"4567",4(a0)
	bne.b	3$
	cmp.l	#"89ab",8(a0)
	bne.b	2$
	cmp.l	#"cdef",12(a0)
	bne.b	2$
	moveq	#16-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

2$	cmp.l	#"89AB",8(a0)	;0123456789abcdef
	bne.b	3$
	cmp.l	#"CDEF",12(a0)
	bne.b	3$
	moveq	#16-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

3$	move.w	#2,CodeID-x(a5)		; 2 = move.w !!!
	move.b	#'W',SizeBWL-x(a5)
	bra	c2_movex

c2_move_l
	tst.b	ArguD-x(a5)	;TRACE ?
	bne.b	2$

	cmp.l	#".lib",(a0)	;.library
	bne.b	1$
	cmp.l	#"rary",4(a0)
	bne.b	1$
	moveq	#10-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

1$	cmp.l	#".dev",(a0)	;.device
	bne.b	2$
	cmp.l	#$69636500,4(a0)
	bne.b	2$
	moveq	#8-2,d0
	add.l	d0,ToAdd-x(a5)
	bra	QWERTYUIOPA

2$	move.b	#'L',SizeBWL-x(a5)
;	bra	c2_movex

c2_movex
	move.w	#%111111111111,Adressposs-x(a5)
	bsr	GetSEA2
	move.w	#%000111111111,Adressposs-x(a5)
	bsr	GetDEA2_1
	bra	QWERTYUIOPA

;**********************************

c2_cmp_b
	move.b	#'B',SizeBWL-x(a5)
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

c2_cmpa_w
c2_cmp_w
	move.b	#'W',SizeBWL-x(a5)
	bra	c2_cmp_x
c2_cmpa_l
c2_cmp_l
	move.b	#'L',SizeBWL-x(a5)
;	bra	c2_cmp_x

c2_cmp_x
	move.w	#%111111111111,Adressposs-x(a5)
	move.w	#3,CodeID-x(a5)	;Anzahl der Sprünge der JumpTable
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_moves
	bsr	GetBWL
	cmp.b	#'?',SizeBWL-x(a5)
	beq	c2_iNULL
	addq.l	#2,ToAdd-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_addi:
c2_subi:
c2_eori:
c2_ori:
c2_andi:
	bsr	GetBWL

	move.w	#%000111111101,Adressposs-x(a5)

	cmp.b	#'L',SizeBWL-x(a5)
	beq.b	immL2

	cmp.b	#'W',SizeBWL-x(a5)
	beq.b	immW2

	cmp.b	#'B',SizeBWL-x(a5)
	bne	c2_iNULL

	move.l	Pointer-x(a5),a0
	tst.b	2(a0)
	beq.b	1$
	cmp.b	#$ff,2(a0)
	bne	c2_iNULL

1$
immW2:	addq.l	#2,ToAdd-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

immL2:	addq.l	#4,ToAdd-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_cmpib:
	move.l	Pointer-x(a5),a0
	tst.b	2(a0)
	beq.b	1$
	cmp.b	#$ff,2(a0)
	bne	c2_iNULL
1$	addq.l	#2,ToAdd-x(a5)
	move.w	#%011111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

c2_cmpiw:
	move.w	2(a0),Jumps-x(a5)	;Anzahl der Sprünge der JumpTable
	addq.l	#2,ToAdd-x(a5)
	move.w	#%011111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

c2_cmpil:
	move.w	4(a0),Jumps-x(a5)	;Anzahl der Sprünge der JumpTable
	addq.l	#4,ToAdd-x(a5)
	move.w	#%011111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_sub
c2_add
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	lsr.w	#6,d2
	andi.w	#%111,d2

;	tst.b	d2
	beq.b	1$
	cmp.b	#%001,d2
	beq.b	2$
	cmp.b	#%010,d2
	beq.b	3$

	cmp.b	#%011,d2
	beq.b	2$
	cmp.b	#%111,d2
	beq.b	3$

	;was sonst (%100,%101,%110)

	move.w	#%000111111100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

1$	move.b	#'B',SizeBWL-x(a5)	;ADD.B	EA,D0
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

2$	moveq	#'W',d2		;ADD.W	EA,D0
	bra.b	7$
3$	moveq	#'L',d2		;ADD.L	EA,D0
;	bra.b	7$

7$	move.b	d2,SizeBWL-x(a5)
	move.w	#%111111111111,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_or
c2_and
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	lsr.w	#6,d2
	andi.w	#%111,d2

;	tst.b	d2
	beq.b	1$
	cmp.b	#%001,d2
	beq.b	2$
	cmp.b	#%010,d2
	beq.b	3$

	cmp.b	#%100,d2
	beq.b	8$
	cmp.b	#%101,d2
	beq.b	8$
	cmp.b	#%110,d2
	beq.b	8$

	bsr	DochFalsch2
	bra	c2_iNULL

1$	moveq	#'B',d2
	bra	7$
2$	moveq	#'W',d2
	bra	7$
3$	moveq	#'L',d2
;	bra	7$

7$	move.b	d2,SizeBWL-x(a5)
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

8$	move.w	#%000111111100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_addsubq
	bsr	GetBWL
	cmp.b	#'?',SizeBWL-x(a5)
	beq	c2_iNULL
	move.w	#%000111111111,Adressposs-x(a5)
	cmp.b	#'B',SizeBWL-x(a5)
	bne.b	1$
	move.w	#%000111111101,Adressposs-x(a5)
1$	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_neg:
c2_negx:
c2_not:
c2_clr:
	bsr	GetBWL
	cmp.b	#'?',SizeBWL-x(a5)
	beq	c2_iNULL
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_tst:
	bsr	GetBWL
	cmp.b	#'?',SizeBWL-x(a5)
	beq	c2_iNULL
	move.w	#%111111111111,Adressposs-x(a5)
	cmp.b	#'B',SizeBWL-x(a5)
	bne.b	1$
	move.w	#%111111111101,Adressposs-x(a5)
1$	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_bitk	addq.l	#2,ToAdd-x(a5)
c2_bit	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_btstk
	addq.l	#2,ToAdd-x(a5)
c2_btst	move.b	#'B',SizeBWL-x(a5)
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

; BFCHG, BFCLR, BFSET, BFTST

c2_bfchg
c2_bfclr
c2_bfset
	move.w	#%000111100101,Adressposs-x(a5)
	bra	c2_bitfield1
c2_bftst
	move.w	#%011111100101,Adressposs-x(a5)
;	bra	c2_bitfield1

c2_bitfield1:
;	move.l	Pointer-x(a5),a0
	move.b	2(a0),d2
	andi.b	#%11110000,d2
	bne	c2_iNULL

	addq.l	#2,ToAdd-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

; BFEXTS, BFEXTU, BFFFO, BFINS

c2_bfexts
c2_bfextu
c2_bfffo
	move.w	#%011111100101,Adressposs-x(a5)
	bra	c2_bitfield2
c2_bfins
	move.w	#%000111100101,Adressposs-x(a5)
;	bra	c2_bitfield2

c2_bitfield2:
;	move.l	Pointer-x(a5),a0
	tst.b	2(a0)		; war btst #7,2(a0) mit bne
	bmi	c2_iNULL

	addq.l	#2,ToAdd-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

c2_movem:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	btst	#2,(a0)
	beq.b	2$

3$	move.w	#%011111101100,Adressposs-x(a5)
	bsr	GetSEA2		;für Quell-Operand
	bra	QWERTYUIOPA

2$	move.w	#%000111110100,Adressposs-x(a5)
	bsr	GetSEA2		;für Ziel-Operand
	bra	QWERTYUIOPA

;**********************************
;	Umrechnen von Dest EA
;**********************************

GetDEA2_1:
	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	lsr.w	#3,d2
	move.w	d2,d7
	lsr.w	#6,d7
	bra.b	GetDEA2_2

;**********************************
;	Umrechnen von Source EA
;**********************************

GetSEA2:
	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	move.b	d2,d7
GetDEA2_2:

	move.w	Adressposs-x(a5),d0

	andi.b	#%00111000,d2

;	tst.b	d2			;000 rrr
	beq	DataDirekt2
	cmp.b	#%001000,d2		;001 rrr
	beq	AdreDirekt2
	cmp.b	#%010000,d2		;010 rrr
	beq	AdreInDirekt2
	cmp.b	#%011000,d2		;011 rrr
	beq	AdreInDirektPostin2
	cmp.b	#%100000,d2		;100 rrr
	beq	AdreInDirektPrede2
	cmp.b	#%101000,d2		;101 rrr
	beq	AdreInDirektDis2
	cmp.b	#%110000,d2		;110 rrr
	beq	AdreInDirektDisIndex2

	andi.b	#%00000111,d7

;	tst.b	d7			;111 000 Absolute Short
	beq	AbsoShort2
	cmp.b	#1,d7			;111 001 Absolute Long
	beq	AbsoLong2
	cmp.b	#2,d7			;111 010 (PC)indirekt mit Dis
	beq	PCInDirektDis2
	cmp.b	#3,d7			;111 011 (PC)indirekt mit Index und Dis
	beq	PCIndexDis2
	cmp.b	#4,d7			;111 100 Konstante 16 oder 32
	beq	Konstante2

	bra	AdressIll2

DataDirekt2:				;000rrr D0
	btst	#0,d0
	beq	AdressIll2
	rts

AdreDirekt2:				;001rrr A0
	btst	#1,d0
	beq	AdressIll2
	rts

AdreInDirekt2:				;010rrr (A0)
	btst	#2,d0
	beq	AdressIll2
	rts

AdreInDirektPostin2:			;011rrr (A0)+
	btst	#3,d0
	beq	AdressIll2
	rts

AdreInDirektPrede2:			;100rrr -(A0)
	btst	#4,d0
	beq	AdressIll2
	rts

AdreInDirektDis2:			;101rrr $1234(A0)
	btst	#5,d0
	beq	AdressIll2
	addq.l	#2,ToAdd-x(a5)
	rts

AdreInDirektDisIndex2:			;110rrr $12(A0,D0.l)
	btst	#6,d0
	beq	AdressIll2

;	move.l	Pointer-x(a5),d2	;????
;	add.l	ToAdd-x(a5),d2
;	addq.l	#4,d2
;	move.l	d2,Label-x(a5)

	move.l	Pointer-x(a5),a0
	add.l	ToAdd-x(a5),a0
	move.w	2(a0),d2
	move.w	d2,AdMode-x(a5)
	btst	#8,d2
	bne.b	AdreInDirektBaseDisIndex2	;--> 68020... modes

	addq.l	#2,ToAdd-x(a5)
	rts

AdreInDirektBaseDisIndex2:			;111 011
	tst.b	ArguF-x(a5)		;68020 Option ???
	beq	AdressIll2

	addq.l	#2,ToAdd-x(a5)

	btst	#5,AdMode+1-x(a5)
	beq.b	NoBaseDisplacement2

	btst	#4,AdMode+1-x(a5)
	bne.b	AXD2

	addq.l	#2,ToAdd-x(a5)
	bra.b	ACD2

AXD2:	addq.l	#4,ToAdd-x(a5)

ACD2:
NoBaseDisplacement2:
	btst	#1,AdMode+1-x(a5)
	beq.b	3$

	btst	#0,AdMode+1-x(a5)
	bne.b	6$

	addq.l	#2,ToAdd-x(a5)
	bra.b	3$

6$	addq.l	#4,ToAdd-x(a5)

3$	rts

AbsoShort2:				;111 000
	tst.b	d0		;$1234 (Adresse) (war btst #7,d0 mit beq)
	bpl	AdressIll2

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$
	tst.b	Springer-x(a5)
	beq.b	1$

	move.l	Pointer-x(a5),a0

	move.l	ToAdd-x(a5),d0
	addq.l	#2,d0

	add.l	d0,a0
	moveq	#0,d2
	move.w	(a0),d2

	move.l	d0,RelocXAdress-x(a5)
	bsr	LabelCalcRelocX16

1$	addq.l	#2,ToAdd-x(a5)
	rts

AbsoLong2:				;111 001
	btst	#8,d0		;$12345678 (Adresse)
	beq	AdressIll2

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$
	tst.b	Springer-x(a5)
	beq.b	1$

	move.l	Pointer-x(a5),a0

	move.l	ToAdd-x(a5),d0
	addq.l	#2,d0

	add.l	d0,a0
	move.l	(a0),d2

	tst.b	KICK-x(a5)
	beq	2$

	sub.l	ROMaddress-x(a5),d2
	bmi	1$
	bsr	LabelCalc2
	bra	1$

2$	move.l	d0,RelocXAdress-x(a5)
	bsr	LabelCalcRelocX32

1$	addq.l	#4,ToAdd-x(a5)
	rts

PCInDirektDis2:				;111 010
	btst	#9,d0
	beq	AdressIll2

	move.l	Pointer-x(a5),a0		;+-$1234(PC)
	add.l	ToAdd-x(a5),a0
	move.w	2(a0),d2
	ext.l	d2
	add.l	ToAdd-x(a5),d2
	addq.l	#2,d2
	add.l	PCounter-x(a5),d2

	move.l	ToAdd-x(a5),d0
	addq.l	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX16

1$	addq.l	#2,ToAdd-x(a5)
	rts

PCIndexDis2:				;111 011
	btst	#10,d0
	beq	AdressIll2

	move.l	Pointer-x(a5),d2
	add.l	ToAdd-x(a5),d2
	addq.l	#4,d2
	move.l	d2,Label-x(a5)

	move.l	Pointer-x(a5),a0
	add.l	ToAdd-x(a5),a0
	move.w	2(a0),d2
	move.w	d2,AdMode-x(a5)
	btst	#8,d2
	bne	PCIndexBaseDis2			;--> 68020... modes

	move.b	AdMode+1-x(a5),d2		;+-$12(PC,D1.L)
	ext.w	d2
	ext.l	d2
	add.l	ToAdd-x(a5),d2
	addq.l	#2,d2
	add.l	PCounter-x(a5),d2

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	2$
	bsr	JumpTable2

2$	clr.b	Springer-x(a5)		;weil nicht verfolgbar

	move.l	ToAdd-x(a5),d0
	addq.l	#3,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX08

1$	addq.l	#2,ToAdd-x(a5)
	rts

PCIndexBaseDis2				;111 011
	tst.b	ArguF-x(a5)		;68020 Option ???
	beq	AdressIll2

	move.b	AdMode+1-x(a5),d2

	addq.l	#2,ToAdd-x(a5)

	btst	#5,d2
	beq.b	NoPCBaseDisplacement2

	move.l	Label-x(a5),a0		;Base Displacement

	btst	#4,d2
	bne.b	PXD2

	addq.l	#2,ToAdd-x(a5)
	move.w	(a0),d2
	ext.l	d2
	beq.b	NoPCBaseDisplacement2	;wenn NULL dann kein Label

	tst.b	AdMode+1-x(a5)		;ZeroPC erkennen (war btst #7,AdMode+1-x(a5) mit bne)
	bmi.b	1$

	move.l	Label-x(a5),d3		;relative Adresse umrechnen
	sub.l	Pointer-x(a5),d3
	add.l	PCounter-x(a5),d3
	add.l	d3,d2

1$	move.l	ToAdd-x(a5),d0
	subq.l	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX16
	bra.b	NoPCBaseDisplacement2

PXD2:	addq.l	#4,ToAdd-x(a5)
	move.l	(a0),d2
	beq.b	NoPCBaseDisplacement2	;wenn NULL dann kein Label

	tst.b   AdMode+1-x(a5)          ;ZeroPC erkennen (war btst #7,AdMode+1-x(a5) mit bne)
	bmi.b	1$

	move.l	Label-x(a5),d3		;relative Adresse umrechnen
	sub.l	Pointer-x(a5),d3
	add.l	PCounter-x(a5),d3
	add.l	d3,d2

1$	move.l	ToAdd-x(a5),d0
;	subq.l	#0,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX32
;	bra.b	NoPCBaseDisplacement2

NoPCBaseDisplacement2:
	btst	#1,AdMode+1-x(a5)
	beq.b	3$

	btst	#0,AdMode+1-x(a5)
	bne.b	6$

	addq.l	#2,ToAdd-x(a5)
	rts

6$	addq.l	#4,ToAdd-x(a5)
3$	rts

Konstante2:				;111 100
	btst	#11,d0
	beq	AdressIll2

	cmp.b	#'B',SizeBWL-x(a5)	;byte integer
	beq	KonsB2
	cmp.b	#'W',SizeBWL-x(a5)	;word integer
	beq	KonsW2
	cmp.b	#'L',SizeBWL-x(a5)	;long-word integer
	beq	KonsL2

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq	AdressIll2

	cmp.b	#'S',SizeBWL-x(a5)	;single-precision real
	beq	KonsS2
	cmp.b	#'P',SizeBWL-x(a5)	;packed-decimal real
	beq	KonsX2
	cmp.b	#'D',SizeBWL-x(a5)	;double-precision real
	beq	KonsD2
	cmp.b	#'X',SizeBWL-x(a5)	;extended-precision real
	beq	KonsX2

	bra.b	AdressIll2

KonsB2:	move.l	Pointer-x(a5),a0
	add.l	ToAdd-x(a5),a0
	tst.b	2(a0)
	beq.b	1$
	cmp.b	#$ff,2(a0)
	bne	AdressIll2
1$	addq.l	#2,ToAdd-x(a5)
	rts

KonsW2:	addq.l	#2,ToAdd-x(a5)

	cmp.w	#3,CodeID-x(a5)		; war es ein cmp command?
	bne.b	1$
	move.l	Pointer-x(a5),a0
	add.l	ToAdd-x(a5),a0
	move.w	(a0),Jumps-x(a5)

1$	rts

KonsL2:	tst.b	Springer-x(a5)
	beq.b	1$

	move.l	ToAdd-x(a5),d0
	addq.l	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX32

1$	cmp.w	#3,CodeID-x(a5)		; war es ein cmp command?
	bne.b	2$
	move.l	Pointer-x(a5),a0
	add.l	ToAdd-x(a5),a0
	move.w	4(a0),Jumps-x(a5)

2$

KonsS2:	addq.l	#4,ToAdd-x(a5)
	rts
KonsD2:	addq.l	#8,ToAdd-x(a5)
	rts
KonsX2:	moveq	#12,d0
	add.l	d0,ToAdd-x(a5)
	rts

AdressIll2:
	addq.l	#4,SP
	clr.l	ToAdd-x(a5)
;	bra	c2_iNULL

;******************************************************

c2_iNULL:
	addq.l	#1,ICodesP1-x(a5)
	move.l	PCounter-x(a5),IllPC-x(a5)
	bra	c2_NoCode
c2_NULL:
QWERTYUIOPA:
	bsr	BitSetter
c2_NoCode:
	move.l	PCounter-x(a5),d1	;Befehl(ToAdd) darf nicht groesser
	addq.l	#2,d1			;sein als der Rest des Programs
	add.l	ToAdd-x(a5),d1
	cmp.l	CodeSize-x(a5),d1
	bgt.b	EndMark2
MarkOK2:
	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$
	tst.b	WallPoint-x(a5)		;Ein RoutinenEnde ??
	bne	GetNewLabel
1$
MarkOK3:
	moveq	#2,d2		;nächsten Befehlsanfang ausrechnen
	add.l	ToAdd-x(a5),d2
	add.l	d2,PCounter-x(a5)
	rts
EndMark2:
	bsr	DochFalsch2
	bra.b	MarkOK3

BitSetter:
	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$

	move.l	CurrHunk-x(a5),d7
	lsl.l	#TabSize,d7
	move.l	HunkMem-x(a5),a2
	move.l	32(a2,d7.l),a2		;BitMem
	move.l	PCounter-x(a5),d7	;Adresse

	lsr.l	#1,d7		;d7/2
	move.w	d7,d6
	lsr.l	#3,d7		;d7/8
	bset	d6,0(a2,d7.w)
1$	rts

;**********************************
;	Zurücksetzen der Werte PASS3
;**********************************

DochFalsch2:			;für falsche Aussortierungen
	clr.l	ToAdd-x(a5)	;in der DissAssembler-Routine
	clr.b	Springer-x(a5)
	clr.b	WallPoint-x(a5)
	clr.w	CodeID-x(a5)
	move.l	Pointer-x(a5),a0
	move.w	(a0),d0
	rts

JumpTable2:
	cmp.w	#2,CodeID-x(a5)		;war es ein move.w Befehl?
	bne.b	5$

	move.l	PCounter-x(a5),LastMoveAdress-x(a5)	;JA!
	move.l	d2,LastMove-x(a5)
	move.w	#2,LastCodeID-x(a5)
	rts

5$	cmp.w	#1,CodeID-x(a5)		;war es ein jmp Befehl ???
	bne	1$

	cmp.w	#2,LastCodeID-x(a5)	;ja, war der davor ein move.w?
	bne	1$

	move.l	PCounter-x(a5),d3
	sub.l	LastMoveAdress-x(a5),d3
	cmp.l	#4,d3			;wenn davor kein move.w war
	bne	1$			;dann abbrechen !!!

	move.l	LastMove-x(a5),a1
	move.l	a1,DD1		;<---- Das 1. Langwort !!!
	add.l	CodeAnfang-x(a5),a1
	move.l	d2,d3
	move.l	d2,DD2		;<---- Das 2. Langwort !!!

	clr.l	d4
	move.w	Jumps-x(a5),d4	;Anzahl der JumpTableWORDS
	beq.b	1$
	bmi.b	1$

	cmp.w	#64,d4
	bgt	1$

	move.l	d4,DD3		;<---- Das 3. Langwort !!!
	subq.w	#1,d4

	movem.l	d2/a0,-(SP)

3$	move.w	(a1)+,d2
	btst	#0,d2
	bne.b	4$		;ungerade dürfen sie nicht sein

	ext.l	d2	;alle checks werden in LabelCalc2 durchgeführt !!!
	add.l	d3,d2
	bmi.b	4$

	movem.l	d3-d4/a1,-(SP)
	bsr	LabelCalc2
	movem.l	(SP)+,d3-d4/a1
	dbf	d4,3$

	bsr	FillJumpTableList

4$	movem.l	(SP)+,d2/a0
1$	rts

FillJumpTableList:

	move.l	CurrHunk-x(a5),d2
	lsl.l	#TabSize,d2
	move.l	HunkMem-x(a5),a2
	move.l	52(a2,d2.l),d2
	beq	3$

	move.l	d2,a0

1$	tst.l	(a0)+		;erstmal eine freie Stelle suchen !!
	beq	2$
	addq.l	#8,a0
	bra	1$

2$	move.l	DD1(PC),-4(a0)	;An welcher Stelle
	move.l	DD2(PC),(a0)+	;relativ zu dieser Adresse
	move.l	DD3(PC),(a0)	;Anzahl der relativen Einträge

3$	rts

DD1	dc.l	0
DD2	dc.l	0
DD3	dc.l	0
