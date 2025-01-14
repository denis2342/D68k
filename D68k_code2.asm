;
; ***************************************
; *					*
; *	Disassembler-Routine fuer D68k	*
; *					*
; *	Von Denis Ahrens (C) 1991-1994	*
; *					*
; ***************************************
;

;************************************
;	Pass 4: Code DisAssemblieren
;************************************

Dissa4_1:
	clr.b	JumpTableOn-x(a5)	;Sicherheitshalber !!!

	clr.l	PCounter-x(a5)
	tst.l	CodeSize-x(a5)	;Check fuer CodeLength = 0
	beq.b	DissaE		;Wenn CodeSize = 0 dann RTS
	bsr	Return		;Ein Return ausgeben
	clr.b	DataRem-x(a5)

Dissa4_2:
	bsr	CheckC
	bsr.b	DissaCode	;Code ausgeben

	move.l	PCounter-x(a5),d0
	cmp.l	CodeSize-x(a5),d0
	bcs.b	Dissa4_2
DissaE:	bsr	PLine		;letztes (oder erstes) Label ohne Befehl
	rts

DissaCode:
	lea	Relocmarke-x(a5),a4
	move.l	#'    ',d0
	move.l	d0,(a4)+
	move.l	d0,(a4)+
	move.w	d0,(a4)

	lea	Befehl-x(a5),a4
	clr.w	CodeID-x(a5)

	move.l	CodeAnfang-x(a5),a0
	add.l	PCounter-x(a5),a0
	move.l	a0,Pointer-x(a5)	;WICHTIG !!!

	bsr	PLine		;Ausgabe des LABEL's und PC + TAB

	btst	#0,PCounter+3-x(a5)
	bne	ByteData

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	3$

	move.l	PCounter-x(a5),d5	;waren wir bei dem Befehl schon ?
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a2
	move.l	32(a2,d6.l),a2		;BitMem
	lsr.l	#1,d5		;Testen ob Adresse schon im BitFeld
	move.w	d5,d7		;gesetzt war, wenn das der Fall ist dann
	lsr.l	#3,d5		;braucht die Adresse nicht abgearbeitet werden.
	btst	d7,0(a2,d5.w)
	beq	OpCode1

3$	bsr	CheckOnReloc32
	tst.b	LabelYes-x(a5)
	beq.b	2$

	move.w	ExternSize-x(a5),d0
	subq.w	#1,d0			; test d0 for 1
	beq	ByteData
	subq.w	#1,d0			; test d0 for 2
	beq	WordData2
	subq.w	#2,d0			; test d0 for 4
	beq	LongData2

2$	clr.l	ToAdd-x(a5)

	tst.b	ArguD-x(a5)	;TRACE ?
	bne.b	1$

		tst.b	ArguA-x(a5)	;DATALOGICOFF ?
		bne.b	1$

			tst.b	DataRem-x(a5)
			bne	OpCode1

1$	clr.b	JumpTableOn-x(a5)

	move.l	Pointer-x(a5),a0
	move.b	(a0),d7

	and.w	#$00f0,d7
	lsr.b	#3,d7
	cmp.w	#16,d7			;eigentlich unnoetig !!!
	move.w	Liste(PC,d7.w),d7
	jmp	Liste(PC,d7.w)

Liste:	dc.w	c_gr0000-Liste		;0000
	dc.w	c_move_b-Liste		;0001	move.b
	dc.w	c_move_l-Liste		;0010	move.l
	dc.w	c_move_w-Liste		;0011	move.w
	dc.w	c_gr0100-Liste		;0100
	dc.w	c_gr0101-Liste		;0101
	dc.w	c_bcc-Liste		;0110	bcc
	dc.w	c_moveq-Liste		;0111	moveq
	dc.w	c_gr1000-Liste		;1000
	dc.w	c_gr1001-Liste		;1001	SUBx
	dc.w	OpCodeError-Liste	;1010	A-LINE
	dc.w	c_gr1011-Liste		;1011
	dc.w	c_gr1100-Liste		;1100
	dc.w	c_gr1101-Liste		;1101	ADDx
	dc.w	c_gr1110-Liste		;1110
	dc.w	c_fline-Liste		;1111	F-LINE

c_gr0000
	move.w	(a0),d7
	move.w	d7,d0

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq.b	1$

	cmp.w	#%0000110011111100,d0	;CAS2.w 68020...
	beq	c_cas2_w
	cmp.w	#%0000111011111100,d0	;CAS2.l 68020...
	beq	c_cas2_l
1$
	cmp.w	#$003c,d0	;ORI to CCR
	beq	c_ori_to_ccr
	cmp.w	#$007c,d0	;ORI to SR
	beq	c_ori_to_sr
	cmp.w	#$023c,d0	;ANDI to CCR
	beq	c_andi_to_ccr
	cmp.w	#$027c,d0	;ANDI to SR
	beq	c_andi_to_sr
	cmp.w	#$0a3c,d0	;EORI to CCR
	beq	c_eori_to_ccr
	cmp.w	#$0a7c,d0	;EORI to SR
	beq	c_eori_to_sr

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq.b	2$

	move.w	d7,d0
	andi.w	#%1111111111110000,d0
	cmp.w	#%0000011011000000,d0	;RTM 68020 only
	beq	c_rtm
2$
	move.w	d7,d0
	andi.w	#%1111111111000000,d0
	cmp.w	#%0000110000000000,d0	;CMPI.b
	beq	c_cmpi
	cmp.w	#%0000110001000000,d0	;CMPI.w
	beq	c_cmpi
	cmp.w	#%0000110010000000,d0	;CMPI.l
	beq	c_cmpi

	andi.w	#%1111111100000000,d0
	cmp.w	#%0000100000000000,d0	;BTST... #
	beq	c_bit_dynamic

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq.b	3$

	cmp.w	#%0000000011000000,d0	;CHK2.b 68020...
	beq	c_chk2_b
	cmp.w	#%0000001011000000,d0	;CHK2.w 68020...
	beq	c_chk2_w
	cmp.w	#%0000010011000000,d0	;CHK2.l 68020...
	beq	c_chk2_l
	cmp.w	#%0000011011000000,d0	;CALLM 68020 only
	beq	c_callm

	move.w	d7,d0
	andi.w	#%1111100111000000,d0
	cmp.w	#%0000100011000000,d0	;CAS 68020...
	beq	c_cas
3$
b_cas	move.w	d7,d0
	andi.w	#%1111111100000000,d0
	cmp.w	#%0000010000000000,d0	;SUBI.x
	beq	c_subi
	cmp.w	#%0000011000000000,d0	;ADDI.x
	beq	c_addi
	cmp.w	#%0000000000000000,d0	;ORI.x
	beq	c_ori
	cmp.w	#%0000001000000000,d0	;ANDI.x
	beq	c_andi
	cmp.w	#%0000101000000000,d0	;EORI.x
	beq	c_eori
	cmp.w	#%0000111000000000,d0	;MOVES 68010...
	beq	c_moves

	move.w	d7,d0
	andi.w	#%1111000100111000,d0
	cmp.w	#%0000000100001000,d0	;MOVEP
	beq	c_movep

	move.w	d7,d0
	andi.w	#%1111000100000000,d0
	cmp.w	#%0000000100000000,d0	;BTST, BCHG, BCLR and BSET
	beq	c_bit_dynamic

	bra	OpCodeError

;****************************************************

c_gr0100
	move.w	(a0),d7
;	move.w	d7,d0

	cmp.w	#$4e75,d7	;RTS
	beq	c_rts
	cmp.w	#$4afc,d7	;ILLEGAL
	beq	c_illegal
	cmp.w	#$4e70,d7	;RESET
	beq	c_reset
	cmp.w	#$4e71,d7	;NOP
	beq	c_nop
	cmp.w	#$4e72,d7	;STOP
	beq	c_stop
	cmp.w	#$4e73,d7	;RTE
	beq	c_rte
	cmp.w	#$4e74,d7	;RTD 68010...
	beq	c_rtd
	cmp.w	#$4e76,d7	;TRAPV
	beq	c_trapv
	cmp.w	#$4e77,d7	;RTR
	beq	c_rtr

	move.w	d7,d0
	andi.w	#%1111111111111110,d0
	cmp.w	#%0100111001111010,d0	;MOVEC 68010...
	beq	c_movec

;	move.w	d7,d0
	andi.w	#%1111111111111000,d0
	cmp.w	#%0100100001000000,d0	;SWAP
	beq	c_swap
	cmp.w	#%0100111001010000,d0	;LINK.w
	beq	c_link_w
	cmp.w	#%0100111001011000,d0	;UNLK
	beq	c_unlk

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq.b	4$

	cmp.w	#%0100100001001000,d0	;BKPT 68010...
	beq	c_bkpt
	cmp.w	#%0100100000001000,d0	;LINK.l 68020...
	beq	c_link_l
4$
	move.w	d7,d0
	andi.w	#%1111111111110000,d0
	cmp.w	#%0100111001000000,d0	;TRAP
	beq	c_trap
	cmp.w	#%0100111001100000,d0	;MOVE USP
	beq	c_move_usp

;	move.w	d7,d0
	andi.w	#%1111111111000000,d0
	cmp.w	#%0100111010000000,d0	;JSR
	beq	c_jsr
	cmp.w	#%0100111011000000,d0	;JMP
	beq	c_jmp
	cmp.w	#%0100100000000000,d0	;NBCD
	beq	c_nbcd
	cmp.w	#%0100100001000000,d0	;PEA
	beq	c_pea
	cmp.w	#%0100101011000000,d0	;TAS
	beq	c_tas
	cmp.w	#%0100000011000000,d0	;MOVE FROM SR
	beq	c_movefromsr
	cmp.w	#%0100001011000000,d0	;MOVE FROM CCR
	beq	c_movefromccr
	cmp.w	#%0100010011000000,d0	;MOVE TO CCR
	beq	c_movetoccr
	cmp.w	#%0100011011000000,d0	;MOVE TO SR
	beq	c_movetosr

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq.b	5$

	cmp.w	#%0100110001000000,d0	;DIVxL 68020...
	beq	c_divxl
	cmp.w	#%0100110000000000,d0	;MULx 68020...
	beq	c_mulxl

5$	move.w	d7,d0
	andi.w	#%1111111010111000,d0
	cmp.w	#%0100100010000000,d0	;EXT & EXTB 68020...
	beq	c_ext			;muss vor MOVEM stehen

	move.w	d7,d0
	andi.w	#%1111111100000000,d0
	cmp.w	#%0100001000000000,d0	;CLR.x
	beq	c_clr
	cmp.w	#%0100101000000000,d0	;TST.x
	beq	c_tst
	cmp.w	#%0100000000000000,d0	;NEGX.x
	beq	c_negx
	cmp.w	#%0100010000000000,d0	;NEG.x
	beq	c_neg
	cmp.w	#%0100011000000000,d0	;NOT.x
	beq	c_not

	move.w	d7,d0
	andi.w	#%1111101110000000,d0
	cmp.w	#%0100100010000000,d0	;MOVEM
	beq	c_movem

	move.w	d7,d0
	andi.w	#%1111000111000000,d0
	cmp.w	#%0100000111000000,d0	;LEA
	beq	c_lea
	cmp.w	#%0100000110000000,d0	;CHK.w
	beq	c_chk

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq.b	6$

	cmp.w	#%0100000100000000,d0	;CHK.l  68020...
	beq	c_chkl
6$
	bra	OpCodeError

;****************************************************

c_gr0101
	move.w	(a0),d7
	move.w	d7,d0
	andi.w	#%1111000011111000,d0
	cmp.w	#%0101000011001000,d0	;DBcc
	beq	c_dbcc

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq.b	7$

	move.w	d7,d0
	andi.w	#%1111000011111111,d0
	cmp.w	#%0101000011111100,d0	;TRAPCC 68020...
	beq	c_trapcc
	cmp.w	#%0101000011111010,d0	;TRAPCC.w 68020...
	beq	c_trapcc_w
	cmp.w	#%0101000011111011,d0	;TRAPCC.l 68020...
	beq	c_trapcc_l
7$
	move.w	d7,d0
	andi.w	#%1111000011000000,d0
	cmp.w	#%0101000011000000,d0	;SCC
	beq	c_scc

	move.w	d7,d0
	andi.w	#%1111000100000000,d0
	cmp.w	#%0101000000000000,d0	;ADDQ
	beq	c_addq
	cmp.w	#%0101000100000000,d0	;SUBQ
	beq	c_subq

	bra	OpCodeError

;****************************************************

c_gr1000
	move.w	(a0),d7
	move.w	d7,d0
	andi.w	#%1111000111110000,d0
	cmp.w	#%1000000100000000,d0	;SBCD
	beq	c_sbcd

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq.b	8$

	cmp.w	#%1000000101000000,d0	;PACK 68020...
	beq	c_pack
	cmp.w	#%1000000110000000,d0	;UNPK 68020...
	beq	c_unpk
8$
	move.w	d7,d0
	andi.w	#%1111000111000000,d0
	cmp.w	#%1000000011000000,d0	;DIVU
	beq	c_divu
	cmp.w	#%1000000111000000,d0	;DIVS
	beq	c_divs

;	move.w	d7,d0
	andi.w	#%1111000000000000,d0
	cmp.w	#%1000000000000000,d0	;OR.x
	beq	c_or

	bra	OpCodeError

;****************************************************

c_gr1101
c_gr1001
	move.w	(a0),d7
	move.w	d7,d0
	andi.w	#%1111000011000000,d0
	cmp.w	#%1101000011000000,d0	;ADDA.x
	beq	c_adda
	cmp.w	#%1001000011000000,d0	;SUBA.x
	beq	c_suba

	move.w	d7,d0
	andi.w	#%1111000100110000,d0
	cmp.w	#%1101000100000000,d0	;ADDX.x
	beq	c_addx
	cmp.w	#%1001000100000000,d0	;SUBX.x
	beq	c_subx

;	move.w	d7,d0
	andi.w	#%1111000000000000,d0
	cmp.w	#%1101000000000000,d0	;ADD.x
	beq	c_add
	cmp.w	#%1001000000000000,d0	;SUB.x
	beq	c_sub

	bra	OpCodeError

;****************************************************

c_gr1011
	move.w	(a0),d7
	move.w	d7,d0
	andi.w	#%1111000111111000,d0
	cmp.w	#%1011000100001000,d0	;CMPM.b
	beq	c_cmpm_b
	cmp.w	#%1011000101001000,d0	;CMPM.w
	beq	c_cmpm_w
	cmp.w	#%1011000110001000,d0	;CMPM.l
	beq	c_cmpm_l

;	move.w	d7,d0
	andi.w	#%1111000111000000,d0
	cmp.w	#%1011000100000000,d0	;EOR.b
	beq	c_eor_b
	cmp.w	#%1011000101000000,d0	;EOR.w
	beq	c_eor_w
	cmp.w	#%1011000110000000,d0	;EOR.l
	beq	c_eor_l
	cmp.w	#%1011000000000000,d0	;CMP.b
	beq	c_cmp_b
	cmp.w	#%1011000001000000,d0	;CMP.w
	beq	c_cmp_w
	cmp.w	#%1011000010000000,d0	;CMP.l
	beq	c_cmp_l
	cmp.w	#%1011000011000000,d0	;CMPA.w
	beq	c_cmpa_w
	cmp.w	#%1011000111000000,d0	;CMPA.l
	beq	c_cmpa_l

	bra	OpCodeError

;****************************************************

c_gr1100
	move.w	(a0),d7
	move.w	d7,d0
	andi.w	#%1111000111111000,d0
	cmp.w	#%1100000101000000,d0	;EXG DATA
	beq	c_exgd
	cmp.w	#%1100000101001000,d0	;EXG ADRESS
	beq	c_exga
	cmp.w	#%1100000110001000,d0	;EXG DATA & ADRESS
	beq	c_exgda

;	move.w	d7,d0
	andi.w	#%1111000111110000,d0
	cmp.w	#%1100000100000000,d0	;ABCD
	beq	c_abcd

;	move.w	d7,d0
	andi.w	#%1111000111000000,d0
	cmp.w	#%1100000011000000,d0	;MULU
	beq	c_mulu
	cmp.w	#%1100000111000000,d0	;MULS
	beq	c_muls

;	move.w	d7,d0
	andi.w	#%1111000000000000,d0
	cmp.w	#%1100000000000000,d0	;AND.x
	beq	c_and

	bra	OpCodeError

;****************************************************

c_gr1110
	move.w	(a0),d7

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq.b	9$

	move.w	d7,d0
	andi.w	#%1111111111000000,d0
	cmp.w	#%1110100011000000,d0	;BFTST 68020...
	beq	c_bftst
	cmp.w	#%1110101011000000,d0	;BFCHG 68020...
	beq	c_bfchg
	cmp.w	#%1110110011000000,d0	;BFCLR 68020...
	beq	c_bfclr
	cmp.w	#%1110111011000000,d0	;BFSET 68020...
	beq	c_bfset
	cmp.w	#%1110100111000000,d0	;BFEXTU 68020...
	beq	c_bfextu
	cmp.w	#%1110101111000000,d0	;BFEXTS 68020...
	beq	c_bfexts
	cmp.w	#%1110110111000000,d0	;BFFFO 68020...
	beq	c_bfffo
	cmp.w	#%1110111111000000,d0	;BFINS 68020...
	beq	c_bfins
9$
	move.w	d7,d0
	andi.w	#%1111111011000000,d0
	cmp.w	#%1110000011000000,d0	;ASLREA
	beq	c_aslrea
	cmp.w	#%1110001011000000,d0	;LSLREA
	beq	c_lslrea
	cmp.w	#%1110010011000000,d0	;ROXLREA
	beq	c_roxlrea
	cmp.w	#%1110011011000000,d0	;ROLREA
	beq	c_rolrea

	move.w	d7,d0
	andi.w	#%1111000000011000,d0
	cmp.w	#%1110000000000000,d0	;ASL oder ASR
	beq	c_aslr
	cmp.w	#%1110000000001000,d0	;LSL oder LSR
	beq	c_lslr
	cmp.w	#%1110000000011000,d0	;ROL oder ROR
	beq	c_rolr
	cmp.w	#%1110000000010000,d0	;ROXL oder ROXR
	beq	c_roxlr

;	bra	OpCodeError

;**********************************
;	Die einzelnen Routinen
;**********************************

OpCodeError:
	bsr	DochFalsch
OpCode1:

	bsr	JumpTableListTest		;L00001-L00002

	moveq	#1,d2
	cmp.l	NextLabel-x(a5),d2		;gibt es ein ungerades Label?
	beq	ByteData

	tst.b	ArguA-x(a5)	;DLO/S
	bne.b	WordData

	moveq	#3,d2
	cmp.l	NextLabel-x(a5),d2
	bcs	LongData

WordData:
	tst.b	JumpTableOn-x(a5)
	bne	LabelTab

	addq.l	#1,PCounter-x(a5)
	bsr	NotPrintExternXX
	subq.l	#1,PCounter-x(a5)

	tst.b	LabelYes-x(a5)
	beq.b	4$
	bra	ByteData
4$
WordData2:
	tst.b	JumpTableOn-x(a5)
	bne	LabelTab

	st	DataRem-x(a5)	;Data-Logic ON/OFF
	move.l	#'dc.w',(a4)+	;Ich kann nicht erkennen was das fuer
	move.b	#9,(a4)+	;ein Befehl sein soll (also dc.w ...)

	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	move.w	d2,d5
	moveq	#-2,d7
	move.l	d7,ToAdd-x(a5)		;!!!

	bsr	LabelPrint16

	tst.b	LabelYes-x(a5)	;wenn LABEL dann kein ASCII-Text
	bne	ExternAddDouble

	bsr	PrintWordData

	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

3$	moveq	#0,d0
	move.w	ExternSize-x(a5),d0
	add.l	d0,ToAdd-x(a5)
	bra	DoublePrint

LongData:
	tst.b	JumpTableOn-x(a5)
	bne	LabelTab

	addq.l	#1,PCounter-x(a5)
	bsr	NotPrintExternXX
	subq.l	#1,PCounter-x(a5)

	tst.b	LabelYes-x(a5)
	beq.b	6$
	bra	ByteData
6$
	addq.l	#2,PCounter-x(a5)
	bsr	CheckOnReloc32
	subq.l	#2,PCounter-x(a5)

	tst.b	LabelYes-x(a5)
	beq.b	5$
	bra	WordData
5$
	addq.l	#3,PCounter-x(a5)
	bsr	NotPrintExternXX
	subq.l	#3,PCounter-x(a5)

	tst.b	LabelYes-x(a5)
	beq.b	4$
	bra	WordData
4$
	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$

	move.l	PCounter-x(a5),d5	;waren wir bei dem Befehl schon ?
	addq.l	#2,d5
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a2
	move.l	32(a2,d6.l),a2		;BitMem
	lsr.l	#1,d5		;Testen ob Adressen schon im BitFeld
	move.w	d5,d7		;gesetzt war, wenn das der Fall ist, dann
	lsr.l	#3,d5		;brauch die Adresse nicht abgearbeitet werden.
	btst	d7,0(a2,d5.w)
	bne	WordData
1$
LongData2:
	tst.b	JumpTableOn-x(a5)
	bne	LabelTab

	st	DataRem-x(a5)	;Data-Logic ON/OFF

	move.l	#'dc.l',(a4)+
	move.b	#9,(a4)+

	move.l	Pointer-x(a5),a0
	move.l	(a0),d2
	move.l	d2,d5

	moveq	#-2,d7
	move.l	d7,ToAdd-x(a5)		;!!!
	bsr	LabelPrint32

	tst.b	LabelYes-x(a5)	;wenn LABEL dann kein ASCII-Text
	bne	ExternAddDouble

	bsr	PrintLongData

	addq.l	#4,ToAdd-x(a5)
	bra	DoublePrint

ByteData:
	st	DataRem-x(a5)	;Data-Logic ON/OFF
	move.l	#'dc.b',(a4)+
	move.b	#9,(a4)+

	move.l	Pointer-x(a5),a0
	move.b	(a0),d2
	move.b	d2,d5
	moveq	#-2,d7
	move.l	d7,ToAdd-x(a5)		;!!!

	bsr	LabelPrint08

	tst.b	LabelYes-x(a5)	;wenn LABEL dann kein ASCII-Text
	bne	ExternAddDouble

	bsr	PrintByteData

	addq.l	#1,ToAdd-x(a5)
	bra	DoublePrint

LabelTab:
	move.l	#'dc.w',(a4)+
	move.b	#9,(a4)+

	move.l	LastLabel-x(a5),d2
	move.l	Pointer-x(a5),a0
	move.w	(a0),d1
	ext.l	d1
	add.l	d1,d2
	bsr	PrintLabelNormal

	move.b	#'-',(a4)+

	move.l	LastLabel-x(a5),d2
	bsr	PrintLabelNormal

	subq.w	#1,Jumps-x(a5)
	bne.b	1$

	clr.b	JumpTableOn-x(a5)
1$	clr.l	ToAdd-x(a5)
	bra	DoublePrint

ExternAddDouble:
	move.w	ExternSize-x(a5),d0
	ext.l	d0
	add.l	d0,ToAdd-x(a5)
	bra	DoublePrint

JumpTableListTest:

	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a2
	move.l	52(a2,d6.l),d6		;Zeiger auf JumpTableListMemory
	beq	1$

	move.l	d6,a0
	move.l	PCounter-x(a5),d1

	subq	#8,a0		; preloop kludge

2$	addq	#8,a0
	move.l	(a0)+,d6
	beq	1$
	cmp.l	d6,d1
	bne	2$

	move.l	(a0)+,LastLabel-x(a5)
	move.l	(a0),Jumps-x(a5)
	sne	JumpTableOn-x(a5)

1$	rts

;**********************************

c_rts:	move.l	#'RTS\n',(a4)+

	tst.b	Argu6-x(a5)
	seq	DataRem-x(a5)	;Data-Logic ON/OFF
	bra	DoublePrint

;**********************************

c_rtr:	move.l	#'RTR\n',(a4)+

	tst.b	Argu6-x(a5)
	seq	DataRem-x(a5)	;Data-Logic ON/OFF
	bra	DoublePrint

;**********************************

c_nop:	move.w	#'NO',(a4)+
	move.b	#'P',(a4)+
	bra	DoublePrint

;**********************************

c_rte:	move.l	#'RTE\n',(a4)+

	tst.b	Argu6-x(a5)
	seq	DataRem-x(a5)	;Data-Logic ON/OFF
	bra	DoublePrint

;**********************************

c_reset	move.l	#'RESE',(a4)+
	move.b	#'T',(a4)+
	bra	DoublePrint

;**********************************

c_illegal:
	move.l	#'ILLE',(a4)+	;illegal ist ein off. Befehl
	move.w	#'GA',(a4)+
	move.b	#'L',(a4)+
	bra	DoublePrint

;**********************************

c_trapv	move.l	#'TRAP',(a4)+
	move.b	#'V',(a4)+
	bra	DoublePrint

;**********************************

c_rtd:	move.l	#"RTD\t",(a4)+

	tst.b	Argu6-x(a5)
	seq	DataRem-x(a5)	;Data-Logic ON/OFF
	move.b	#'#',(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	bsr	HexWDi
	addq.l	#2,ToAdd-x(a5)
	move.b	#10,(a4)+
	bra	DoublePrint

;**********************************

c_stop:	move.l	#'STOP',(a4)+
	move.w	#"\t#",(a4)+

;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	bsr	HexWDi
	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

;**********************************

c_ori_to_sr:
	move.l	#'ORI.',(a4)+
	move.b	#'W',(a4)+
	bra	c_to_sr

c_andi_to_sr:
	move.l	#'ANDI',(a4)+
	move.w	#'.W',(a4)+
	bra	c_to_sr

c_eori_to_sr:
	move.l	#'EORI',(a4)+
	move.w	#'.W',(a4)+
;	bra	c_to_sr

c_to_sr	move.w	#"\t#",(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	bsr	HexWDi
	move.b	#',',(a4)+
	move.b	#'S',(a4)+
	move.b	#'R',(a4)+
	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

;**********************************

c_ori_to_ccr:
	move.l	#'ORI.',(a4)+
	move.b	#'B',(a4)+
	bra	c_to_ccr

c_andi_to_ccr:
	move.l	#'ANDI',(a4)+
	move.w	#'.B',(a4)+
	bra	c_to_ccr

c_eori_to_ccr:
	move.l	#'EORI',(a4)+
	move.w	#'.B',(a4)+
;	bra	c_to_ccr

c_to_ccr
	move.w	#"\t#",(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	bsr	HexBDi
	move.b	#',',(a4)+
	move.b	#'C',(a4)+
	move.b	#'C',(a4)+
	move.b	#'R',(a4)+
	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

;**********************************

c_moveq
;	move.l	Pointer-x(a5),a0

	tst.b	ArguD-x(a5)	;TRACE ?
	bne.b	2$

	cmp.l	#"util",(a0)	;utility.library
	bne.b	1$
	cmp.l	#"ity.",4(a0)
	beq	OpCodeError

1$	cmp.l	#"work",(a0)	;workbench.library
	bne.b	2$
	cmp.l	#"benc",4(a0)
	beq	OpCodeError

2$	move.l	#'MOVE',(a4)+	;MOVE
	move.w	#"Q\t",(a4)+	;Q + TAB
	move.b	#'#',(a4)+
	move.w	(a0),d2
	bsr	HexBs
	bsr	RegNumD2_K_D
	bra	DoublePrint

;**********************************

c_trap	move.l	#'TRAP',(a4)+
	move.w	#"\t#",(a4)+	;TAB + '#'
;	move.l	Pointer-x(a5),a0
	moveq	#%00001111,d2
	and.w	(a0),d2
	bsr	DecL
	move.b	Buffer+8-x(a5),(a4)+
	move.b	Buffer+9-x(a5),(a4)+
	bra	DoublePrint

;**********************************

c_bkpt	move.l	#'BKPT',(a4)+
	move.w	#"\t#",(a4)+	;TAB + '#'
	bsr	RegNumD
	bra	DoublePrint

;**********************************

c_swap	move.l	#'SWAP',(a4)+
	move.w	#"\tD",(a4)+	;TAB + '#'
	bsr	RegNumD
	bra	DoublePrint

;**********************************

c_ext:	move.w	#'EX',(a4)+
	move.b	#'T',(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	btst	#8,d2
	beq.b	1$

	tst.b	ArguF-x(a5)		;68020 Option ??
	beq	OpCodeError

	move.b	#'B',(a4)+

1$	move.b	#'.',(a4)+
	moveq	#'L',d0
	btst	#6,d2
	bne.b	2$
	moveq	#'W',d0
2$	move.b	d0,(a4)+
	move.b	#9,(a4)+
	move.b	#'D',(a4)+
	bsr	RegNumD
	bra	DoublePrint

;**********************************

c_rtm	move.l	#"RTM\t",(a4)+	;'RTM' + TAB
	move.b	#'D',(a4)+
;	move.l	Pointer-x(a5),a0
	btst	#3,1(a0)
	beq.b	1$
	move.b	#'A',-1(a4)
1$	bsr	RegNumD
	tst.b	Argu6-x(a5)
	seq	DataRem-x(a5)	;Data-Logic ON/OFF
	bra	DoublePrint

;**********************************

c_move_usp
	move.l	#'MOVE',(a4)+
	move.b	#9,(a4)+		;TAB

;	move.l	Pointer-x(a5),a0
	btst	#3,1(a0)
	beq.b	1$

	move.b	#'U',(a4)+
	move.b	#'S',(a4)+
	move.b	#'P',(a4)+
	move.b	#',',(a4)+

1$	bsr	RegNumD_A

;	move.l	Pointer-x(a5),a0
	btst	#3,1(a0)
	bne	DoublePrint

	move.b	#',',(a4)+
	move.b	#'U',(a4)+
	move.b	#'S',(a4)+
	move.b	#'P',(a4)+
	bra	DoublePrint

;**********************************

c_link_w:
	move.l	#'LINK',(a4)+	;'LINK'
	move.w	#"\tA",(a4)+	;TAB + 'A'
	bsr	RegNumD
	move.b	#',',(a4)+	;','
	move.b	#'#',(a4)+	;'#'
	move.b	#'-',(a4)+	;'-'

;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	neg.w	d2
	bsr	HexWDi

	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

c_link_l:
	move.l	#'LINK',(a4)+	;'LINK'
	move.l	#'.L\tA',(a4)+
	bsr	RegNumD
	move.b	#',',(a4)+	;','
	move.b	#'#',(a4)+	;'#'
	move.b	#'-',(a4)+	;'-'

;	move.l	Pointer-x(a5),a0
	move.l	2(a0),d2
	neg.l	d2
	bsr	HexLDi

	addq.l	#4,ToAdd-x(a5)
	bra	DoublePrint

;**********************************

c_unlk	move.l	#'UNLK',(a4)+
	move.w	#"\tA",(a4)+	;TAB + 'A'
	bsr	RegNumD
	bra	DoublePrint

;**********************************

c_bcc:	;move.l	Pointer-x(a5),a0

	tst.b	ArguD-x(a5)	;TRACE ?
	bne.b	6$

	cmp.l	#"grap",(a0)	;graphics.library
	bne.b	1$
	cmp.l	#"hics",4(a0)
	beq	OpCodeError

1$	cmp.l	#"intu",(a0)	;intuition.library
	bne.b	2$
	cmp.l	#"itio",4(a0)
	beq	OpCodeError

2$	cmp.l	#"loca",(a0)	;locale.library
	bne.b	3$
	cmp.l	#"le.l",4(a0)
	beq	OpCodeError

3$	cmp.l	#"iffp",(a0)	;iffparse.library
	bne.b	4$
	cmp.l	#"arse",4(a0)
	beq	OpCodeError

4$	cmp.l	#"expa",(a0)	;expansion.library
	bne.b	5$
	cmp.l	#"nsio",4(a0)
	beq	OpCodeError

5$	cmp.l	#"exec",(a0)	;exec.library
	bne.b	6$
	cmp.l	#".lib",4(a0)
	beq	OpCodeError

6$	move.b	#'B',(a4)+	;Bcc
	bsr	GetCoCo
	move.b	#'.',(a4)+

;	move.l	Pointer-x(a5),a0
	move.b	1(a0),d2
	beq.b	bxx1		;auf WORD testen
	btst	#0,d2		;Test ob Sprung ungerade
	bne.b	bxx2

	move.b	#'B',(a4)+	;bcc.B
	move.b	#9,(a4)+

	ext.w	d2
	ext.l	d2
	move.b	d2,d5		;retten
	addq.l	#2,d2		;das ist bei bcc nun mal so
	add.l	PCounter-x(a5),d2

	moveq	#1,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelPrintReloc08

	tst.b	LabelYes-x(a5)
	bne	DoublePrint

	move.b	d5,d2
	bsr	HexBs		;SOLLTE MIT PLUS SEIN
	bra	DoublePrint

bxx1	move.b	#'W',(a4)+	;bcc.W
	move.b	#9,(a4)+

HexWpm:
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	btst	#0,d2		;Test ob Sprung ungerade
	bne	OpCodeError
	ext.l	d2
	move.w	d2,d5		;retten
	addq.l	#2,d2		;das ist bei bcc nun mal so
	add.l	PCounter-x(a5),d2

	moveq	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelPrintReloc16
	addq.l	#2,ToAdd-x(a5)

	tst.b	LabelYes-x(a5)
	bne	DoublePrint
	move.w	d5,d2
	bsr	HexWs		;SOLLTE MIT PLUS SEIN
	bra	DoublePrint

bxx2	cmp.b	#$ff,d2
	bne	OpCodeError

;	move.l	Pointer-x(a5),a0
	move.l	2(a0),d2
	btst	#0,d2		;Test ob Sprung ungerade
	bne	OpCodeError

	move.b	#'L',(a4)+	;bcc.L
	move.b	#9,(a4)+

	move.l	d2,d5		;retten
	addq.l	#2,d2		;das ist bei bcc nun mal so
	add.l	PCounter-x(a5),d2

	moveq	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelPrintReloc32
	addq.l	#4,ToAdd-x(a5)

	tst.b	LabelYes-x(a5)
	bne	DoublePrint

	move.l	d5,d2
	bsr	HexLs		;SOLLTE MIT PLUS SEIN
	bra	DoublePrint

;**********************************

c_abcd:	move.l	#'ABCD',(a4)+
	bra.b	c_bcdx

c_sbcd:	move.l	#'SBCD',(a4)+
	bra.b	c_bcdx

c_subx:	move.l	#'SUBX',(a4)+
	bsr	GetBWL
	bra.b	c_bcdx2

c_addx:	move.l	#'ADDX',(a4)+
	bsr	GetBWL
	bra.b	c_bcdx2

c_bcdx:	bsr	GetBWL
;	tst.b	SizeBWL-x(a5)
	beq	OpCodeError
c_bcdx2:
	move.b	#'.',(a4)+
	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+

;	move.l	Pointer-x(a5),a0
	btst	#3,1(a0)
	beq.b	addxd

	move.b	#'-',(a4)+
	bsr	RegNumD_Bracket_A
	move.b	#')',(a4)+
	move.w	#',-',(a4)+
	move.b	#'(',(a4)+
	move.b	#'A',(a4)+
	bsr	RegNumD2
	move.b	#')',(a4)+
	bra	DoublePrint

addxd:	move.b	#'D',(a4)+
	bsr	RegNumD
	bsr	RegNumD2_K_D
	bra	DoublePrint

;**********************************

c_roxlr:
	move.l	#'ROXL',(a4)+
	bra	LinksRechts2
c_rolr:	move.w	#'RO',(a4)+
	bra	LinksRechts
c_lslr:	move.w	#'LS',(a4)+
	bra	LinksRechts
c_aslr:	move.w	#'AS',(a4)+
;	bra	LinksRechts

LinksRechts:
	move.b	#"L",(a4)+
LinksRechts2:
	bsr	GetBWL
;	tst.b	SizeBWL-x(a5)
	beq	OpCodeError

;	move.l	Pointer-x(a5),a0
	btst	#0,(a0)
	bne.b	2$
	move.b	#'R',-1(a4)		;Also doch nach rechts

2$	move.b	#'.',(a4)+
	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+

;	move.l	Pointer-x(a5),a0
	btst	#5,1(a0)
	bne.b	3$

	move.b	#'#',(a4)+		;Konstante
	bsr	RegNumD2
	cmp.b	#'0',-1(a4)
	bne.b	4$
	addq.b	#8,-1(a4)		;Dann wird "8" draus
	bra.b	4$

3$	bsr	RegNumD2_D		;DataReg
4$	move.b	#',',(a4)+
	move.b	#'D',(a4)+
	bsr	RegNumD
	bra	DoublePrint

;**********************************

c_roxlrea:
	move.w	#'RO',(a4)+
	move.b	#'X',(a4)+
	bra	EALinksRechts
c_lslrea:
	move.w	#'LS',(a4)+
	bra	EALinksRechts
c_rolrea:
	move.w	#'RO',(a4)+
	bra	EALinksRechts
c_aslrea:
	move.w	#'AS',(a4)+
;	bra	EALinksRechts

EALinksRechts
	move.b	#'L',(a4)+		;erstmal Links (erstmal !!!)
;	move.l	Pointer-x(a5),a0
	btst	#0,(a0)
	bne	4$
	move.b	#'R',-1(a4)	;also doch rechts
4$	move.b	#'.',(a4)+
	move.b	#'W',(a4)+
	move.b	#9,(a4)+
	move.w	#%000111111100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************

c_cmpm_b:
	move.l	#'CMPM',(a4)+
	move.w	#'.B',(a4)+
	bra	c_cmpm_x
c_cmpm_w:
	move.l	#'CMPM',(a4)+
	move.w	#'.W',(a4)+
	bra	c_cmpm_x
c_cmpm_l:
	move.l	#'CMPM',(a4)+
	move.w	#'.L',(a4)+
;	bra	c_cmpm_x

c_cmpm_x
	move.b	#9,(a4)+
	bsr	RegNumD_Bracket_A
	move.l	#')+,(',(a4)+
	move.b	#'A',(a4)+
	bsr	RegNumD2
	move.w	#')+',(a4)+
	bra	DoublePrint

;**********************************

c_movep	move.l	#'MOVE',(a4)+
	move.w	#'P.',(a4)+
	move.b	#'L',(a4)+

	addq.l	#2,ToAdd-x(a5)

;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2

;	tst.b	d2		;war btst #7,d2 mit beq.b $1
	bpl.b	1$

3$	btst	#6,d2
	bne.b	4$

	move.b	#'W',-1(a4)

4$	move.b	#9,(a4)+
	bsr	RegNumD2_D
	move.b	#',',(a4)+
	move.w	2(a0),d2
	bsr	HexWDi
	bsr	RegNumD_Bracket_A
	move.b	#')',(a4)+
	bra	DoublePrint

1$	btst	#6,d2
	bne.b	2$

	move.b	#'W',-1(a4)

2$	move.b	#9,(a4)+
	move.w	2(a0),d2
	bsr	HexWDi
	bsr	RegNumD_Bracket_A
	move.b	#')',(a4)+
	bsr	RegNumD2_K_D
	bra	DoublePrint

;**********************************

c_dbcc:	move.w	#'DB',(a4)+
	bsr	GetCoCo2
	move.b	#9,(a4)+
	move.b	#'D',(a4)+
	bsr	RegNumD
	move.b	#',',(a4)+
	bra	HexWpm		;Springt zu Xcc

;**********************************

c_exgda	moveq	#'D',d1
	moveq	#'A',d2
	bra	exgpr
c_exga	moveq	#'A',d1
	moveq	#'A',d2
	bra	exgpr
c_exgd	moveq	#'D',d1
	moveq	#'D',d2
;	bra	exgpr

exgpr	move.l	#$45584709,(a4)+	;EXG + TABs
	move.b	d1,(a4)+
	bsr	RegNumD2
	move.b	#',',(a4)+
	move.b	d2,(a4)+
	bsr	RegNumD
	bra	DoublePrint

;**********************************

c_move_b:
	move.b	#'B',SizeBWL-x(a5)	;For byte size operation, adress register
	move.l	#'MOVE',(a4)+		;direct is not allowed
	move.w	#'.B',(a4)+
	move.b	#9,(a4)+
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetDEA
	bra	DoublePrint

c_move_w:
	cmp.l	#"6804",(a0)	;68040.library
	bne.b	1$
	cmp.l	#"0.li",4(a0)
	beq	OpCodeError

1$	cmp.l	#"0123",(a0)	;0123456789abcdef
	bne.b	3$
	cmp.l	#"4567",4(a0)
	bne.b	3$
	cmp.l	#"89ab",8(a0)
	bne.b	2$
	cmp.l	#"cdef",12(a0)
	beq	OpCodeError

2$	cmp.l	#"0123",(a0)	;0123456789ABCDEF
	bne.b	3$
	cmp.l	#"4567",4(a0)
	bne.b	3$
	cmp.l	#"89AB",8(a0)
	bne.b	3$
	cmp.l	#"CDEF",12(a0)
	beq	OpCodeError

3$	move.b	#'W',SizeBWL-x(a5)
	bra	c_movex

c_move_l:
	move.b	#'L',SizeBWL-x(a5)
;	bra	c_movex

c_movex	move.w	#%000111111101,HunkForm1-x(a5)
	move.l	#'MOVE',(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	andi.w	#%111000000,d2
	cmp.w	#%001000000,d2
	bne.b	1$
	move.b	#'A',(a4)+
	move.w	#%000111111111,HunkForm1-x(a5)
1$	move.b	#'.',(a4)+
	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+

	move.w	#%111111111111,Adressposs-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	move.w	HunkForm1-x(a5),Adressposs-x(a5)
	bsr	GetDEA
	bra	DoublePrint

;**********************************

c_cmp_b	move.l	#'CMP.',(a4)+		;CMP.B
	move.w	#$4209,(a4)+		;'B' + TAB
	move.b	#"B",SizeBWL-x(a5)
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA
	bsr	RegNumD2_K_D
	bra	DoublePrint

c_cmp_w	move.l	#'CMP.',(a4)+
	move.b	#'W',(a4)+		;CMP.W
	moveq	#'D',d4
	bra	c_cmp_y

c_cmp_l	move.l	#'CMP.',(a4)+
	move.b	#'L',(a4)+		;CMP.L
	moveq	#'D',d4
	bra	c_cmp_y

c_cmpa_w
	move.l	#'CMPA',(a4)+
	move.w	#'.W',(a4)+
	bra	c_cmp_z

c_cmpa_l
	move.l	#'CMPA',(a4)+
	move.w	#'.L',(a4)+

c_cmp_z	moveq	#'A',d4
c_cmp_y	move.b	-1(a4),SizeBWL-x(a5)

	move.b	#9,(a4)+
	move.w	#%111111111111,Adressposs-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	d4,(a4)+
	bsr	RegNumD2
	bra	DoublePrint

;**********************************

c_moves	move.w	#%000111111100,Adressposs-x(a5)
	move.b	#'A',RegArt-x(a5)
	bsr	GetBWL
	beq	OpCodeError
	move.l	#'MOVE',(a4)+
	move.w	#'S.',(a4)+
	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+
	addq.l	#2,ToAdd-x(a5)

;	move.l	Pointer-x(a5),a0
	moveq	#0,d2
	move.b	2(a0),d2
	lsr.w	#4,d2
	add.b	#'0',d2
	move.b	d2,Mnemonic-x(a5)
;	move.l	Pointer-x(a5),a0
	move.b	2(a0),d2
;	tst.b	d2		; war btst #7,d2 mit bne.b 1$
	bmi.b	1$
	move.b	#'D',RegArt-x(a5)

1$	btst	#3,d2
	bne.b	2$
	move.b	RegArt-x(a5),(a4)+
	move.b	Mnemonic-x(a5),(a4)+
	move.b	#',',(a4)+
	bsr	GetSEA
	bra	DoublePrint

2$	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	RegArt-x(a5),(a4)+
	move.b	Mnemonic-x(a5),(a4)+
	bra	DoublePrint

;**********************************

c_addi	move.l	#'ADDI',(a4)+
	bra	c_addi2

c_subi	move.l	#'SUBI',(a4)+
;	bra	c_subi2

c_addi2
c_subi2
	bsr	GetBWL
	beq	OpCodeError
	move.b	#'.',(a4)+
	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+
	move.b	#'#',(a4)+

;	move.l	Pointer-x(a5),a0

	move.b	SizeBWL-x(a5),d2
	cmp.b	#'L',d2
	beq	AddL
	cmp.b	#'W',d2
	beq	AddW
	cmp.b	#'B',d2
	bne	OpCodeError

AddB:	tst.b	2(a0)
	beq.b	1$
	cmp.b	#$ff,2(a0)
	bne	OpCodeError
1$	move.w	2(a0),d2
	bsr	HexBDi
	bra	AddEnd

AddW:	move.w	2(a0),d2
	bsr	HexWDi
	bra	AddEnd

AddL:	addq.l	#2,ToAdd-x(a5)
	move.l	2(a0),d2
	bsr	HexLDi

AddEnd	addq.l	#2,ToAdd-x(a5)
	move.b	#',',(a4)+
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************

c_suba	move.l	#'SUBA',(a4)+	;SUBA
	bra	c_addasuba

c_adda	move.l	#'ADDA',(a4)+	;SUBA
;	bra	c_addasuba

c_addasuba:
	moveq	#"W",d7
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	btst	#8,d2
	beq	1$

	moveq	#"L",d7

1$	move.b	#".",(a4)+
	move.b	d7,(a4)+
	move.b	d7,SizeBWL-x(a5)
	move.b	#9,(a4)+
	move.w	#%111111111111,Adressposs-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	#'A',(a4)+
	bsr	RegNumD2
	bra	DoublePrint

c_sub	move.l	#'SUB.',(a4)+	;SUB
	bra	c_AddSub

c_add	move.l	#'ADD.',(a4)+	;ADD
;	bra	c_AddSub

c_AddSub
	bsr	GetBWL
;	move.l	Pointer-x(a5),a0

	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+
	btst	#8,(a0)
	bne	2$

	; ADD.?  EA,D0

	move.w	#%111111111111,Adressposs-x(a5)
	bsr	GetSEA
	bsr	RegNumD2_K_D
	bra	DoublePrint

	; ADD.?	D0,EA

2$	bsr	RegNumD2_D
	move.b	#',',(a4)+
	move.w	#%000111111100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************

c_ori:	tst.b	ArguB-x(a5)	;OLO=ORILOGICOFF/S
	bne.b	1$

		move.l	PCounter-x(a5),d3	;Adresse
		move.l	CurrHunk-x(a5),d6
		lsl.l	#TabSize,d6
		move.l	HunkMem-x(a5),a1
		add.l	8(a1,d6.l),d3		; + HunkAnfang = Label

		move.l	LabelMem-x(a5),a1
		add.l	LabelPointer-x(a5),a1

		addq.l	#2,d3
		cmp.l	(a1),d3
		beq	OpCodeError

1$	move.w	#'OR',(a4)+
	move.b	#'I',(a4)+
	bra	c_ori2

c_eori:	move.l	#'EORI',(a4)+
	bra	c_eori2

c_andi:	move.l	#'ANDI',(a4)+
	bra	c_andi2

c_cmpi:	move.l	#'CMPI',(a4)+
	move.w	#%011111111101,Adressposs-x(a5)
	bra	c_cmpi2

c_eori2
c_ori2
c_andi2
	move.w	#%000111111101,Adressposs-x(a5)
c_cmpi2
	bsr	GetBWL
	beq	OpCodeError
	move.b	#'.',(a4)+
	move.b	SizeBWL-x(a5),d2
	move.b	d2,(a4)+

	move.b	#9,(a4)+
	move.b	#'#',(a4)+

;	move.l	Pointer-x(a5),a0

	cmp.b	#'L',d2
	beq.b	immL
	cmp.b	#'W',d2
	beq.b	immW
;	cmp.b	#'B',d2
;	bne	OpCodeError

immB:	tst.b	2(a0)
	beq.b	1$
	cmp.b	#$ff,2(a0)
	bne	OpCodeError
1$	move.w	2(a0),d2
	bsr	HexBDi
	bra.b	immEnd

immW:	move.w	2(a0),d2
	bsr	HexWDi
	bra.b	immEnd

immL:	addq.l	#2,ToAdd-x(a5)
	move.l	2(a0),d2
	bsr	HexLDi
;	bra.b	immEnd

immEnd	addq.l	#2,ToAdd-x(a5)
	move.b	#',',(a4)+
	bsr	GetSEA
	bra	DoublePrint

;**********************************

c_eor_b	move.l	#'EOR.',(a4)+
	moveq	#'B',d4
	bra	c_eor_x

c_eor_w	move.l	#'EOR.',(a4)+
	moveq	#'W',d4
	bra	c_eor_x

c_eor_l	move.l	#'EOR.',(a4)+
	moveq	#'L',d4
;	bra	c_eor_x

c_eor_x	move.b	d4,(a4)+
	move.b	d4,SizeBWL-x(a5)
	move.b	#9,(a4)+
	bsr	RegNumD2_D
	move.b	#',',(a4)+
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************

c_or	move.w	#'OR',(a4)+
	move.b	#'.',(a4)+
	bra	c_OrAnd

c_and	move.l	#'AND.',(a4)+
;	bra	c_OrAnd

c_OrAnd
;	move.l	Pointer-x(a5),a0

	bsr	GetBWL
	beq	OpCodeError

	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+

	btst	#8,(a0)
	bne	1$

	;xxx.x  EA,D0

	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA
	bsr	RegNumD2_K_D
	bra	DoublePrint

1$	bsr	RegNumD2_D		;xxx.x	D0,EA
	move.b	#',',(a4)+
	move.w	#%000111111100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************

c_subq	move.l	#'SUBQ',(a4)+
	bra	c_subqaddq

c_addq	move.l	#'ADDQ',(a4)+
;	bra	c_subqaddq

c_subqaddq
	move.b	#'.',(a4)+
	bsr	GetBWL
	beq	OpCodeError
	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+
	move.b	#'#',(a4)+

	bsr	RegNumD2
	cmp.b	#'0',-1(a4)
	bne.b	1$
	addq.b	#8,-1(a4)	;daraus wird "8"

1$	move.b	#',',(a4)+
	move.w	#%000111111111,Adressposs-x(a5)
	cmp.b	#'B',SizeBWL-x(a5)
	bne.b	2$
	move.w	#%000111111101,Adressposs-x(a5)
2$	bsr	GetSEA
	bra	DoublePrint

;**********************************

c_lea	move.l	#"LEA\t",(a4)+	;'LEA' + TAB
	move.w	#%011111100100,Adressposs-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	#'A',(a4)+
	bsr	RegNumD2
	bra	DoublePrint

;**********************************

c_chk	move.l	#'CHK.',(a4)+
	move.w	#$5709,(a4)+		;'W' + TAB
	move.b	#'W',SizeBWL-x(a5)
	bra.b	c_chkx

c_chkl	move.l	#'CHK.',(a4)+
	move.w	#$4c09,(a4)+		;'L' + TAB
	move.b	#'L',SizeBWL-x(a5)

c_chkx	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA
	bsr	RegNumD2_K_D
	bra	DoublePrint

;**********************************
;	Nur EA Befehle
;**********************************

c_jmp	move.l	#$4a4d5009,(a4)+		;'JMP' + TAB
	move.w	#%011111100100,Adressposs-x(a5)
	bsr	GetSEA
	tst.b	Argu6-x(a5)
	seq	DataRem-x(a5)	;Data-Logic ON/OFF
	bra	DoublePrint

c_tas	move.l	#$54415309,(a4)+		;'TAS' + TAB
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

c_pea	move.l	#$50454109,(a4)+		;'PEA' + TAB
	move.w	#%011111100100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

c_nbcd	move.l	#'NBCD',(a4)+
	move.w	#'.B',(a4)+
	move.w	#%000111111101,Adressposs-x(a5)
	move.b	#9,(a4)+
	bsr	GetSEA
	bra	DoublePrint

c_jsr	move.l	#$4a535209,(a4)+		;'JSR' + TAB
	move.w	#%011111100100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	CALLM	68020 only
;**********************************

c_callm	move.l	#'CALL',(a4)+
	move.w	#$4d09,(a4)+
;	move.l	Pointer-x(a5),a0
	moveq	#0,d2
	move.b	3(a0),d2
	bsr	DecL
	move.b	#'#',(a4)+
	move.b	Buffer+7-x(a5),(a4)+
	move.b	Buffer+8-x(a5),(a4)+
	move.b	Buffer+9-x(a5),(a4)+
	move.b	#',',(a4)+
	addq.l	#2,ToAdd-x(a5)
	move.w	#%011111100100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	CAS	68020...
;**********************************

c_cas:	move.l	#'CAS.',(a4)+

;	move.l	Pointer-x(a5),a0
	moveq	#%00000110,d2
	and.b	(a0),d2
	moveq	#'?',d4
	cmp.b	#%00000010,d2
	bne.b	1$
	moveq	#'B',d4
1$	cmp.b	#%00000100,d2
	bne.b	2$
	moveq	#'W',d4
2$	cmp.b	#%00000110,d2
	bne.b	3$
	moveq	#'L',d4
3$
	cmp.b	#'?',d4
	bne.b	4$
	bsr	DochFalsch
	bra	b_cas

4$	move.b	d4,(a4)+
	move.b	#9,(a4)+
	move.b	#'D',(a4)+
;	move.l	Pointer-x(a5),a0
	moveq	#%00000111,d2
	and.w	2(a0),d2
	add.b	#'0',d2
	move.b	d2,(a4)+

	move.b	#',',(a4)+

	move.b	#'D',(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	and.w	#%111000000,d2
	lsr.w	#6,d2
	add.b	#'0',d2
	move.b	d2,(a4)+

	move.b	#',',(a4)+

	addq.l	#2,ToAdd-x(a5)
	move.w	#%000111111100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	CAS2.x	68020...
;**********************************

c_cas2_w
	move.l	#'CAS2',(a4)+
	move.w	#'.W',(a4)+
	bra	c_cas2x

c_cas2_l
	move.l	#'CAS2',(a4)+
	move.w	#'.L',(a4)+
;	bra	c_cas2x

c_cas2x	move.b	#9,(a4)+

;	move.l	Pointer-x(a5),a0
	moveq	#%00000111,d2
	and.w	2(a0),d2
	add.b	#'0',d2
	move.b	#'D',(a4)+
	move.b	d2,(a4)+

	move.b	#':',(a4)+

;	move.l	Pointer-x(a5),a0
	moveq	#%00000111,d2
	and.w	4(a0),d2
	add.b	#'0',d2
	move.b	#'D',(a4)+
	move.b	d2,(a4)+

	move.b	#',',(a4)+

;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	and.w	#%111000000,d2
	lsr.w	#6,d2
	add.b	#'0',d2
	move.b	#'D',(a4)+
	move.b	d2,(a4)+

	move.b	#':',(a4)+

;	move.l	Pointer-x(a5),a0
	move.w	4(a0),d2
	and.w	#%111000000,d2
	lsr.w	#6,d2
	add.b	#'0',d2
	move.b	#'D',(a4)+
	move.b	d2,(a4)+

	move.b	#',',(a4)+

	move.b	#'(',(a4)+
	move.b	#'A',(a4)+
;	move.l	Pointer-x(a5),a0
	move.b	2(a0),d2
;	tst.b	d2		; war btst #7,d2 mit bne.b 1$
	bmi	1$
	move.b	#'D',-1(a4)
1$	and.b	#%1110000,d2
	lsr.b	#4,d2
	add.b	#'0',d2
	move.b	d2,(a4)+
	move.b	#')',(a4)+

	move.b	#':',(a4)+

	move.b	#'(',(a4)+
	move.b	#'A',(a4)+
;	move.l	Pointer-x(a5),a0
	move.b	4(a0),d2
;	tst.b	d2		; war btst #7,d2 mit bne.b 1$
	bmi	2$
	move.b	#'D',-1(a4)
2$	and.b	#%1110000,d2
	lsr.b	#4,d2
	add.b	#'0',d2
	move.b	d2,(a4)+
	move.b	#')',(a4)+

	addq.l	#4,ToAdd-x(a5)
	bra	DoublePrint

;**********************************
;	CHK2.x	68020...
;**********************************

;Klappt auch mit CMP2 (c_cmp2)

c_chk2_b
	move.l	#'CHK2',(a4)+
	move.w	#'.B',(a4)+
	bra	c_chk2x
c_chk2_w
	move.l	#'CHK2',(a4)+
	move.w	#'.W',(a4)+
	bra	c_chk2x
c_chk2_l
	move.l	#'CHK2',(a4)+
	move.w	#'.L',(a4)+
;	bra	c_chk2x

c_chk2x	move.b	#9,(a4)+
	addq.l	#2,ToAdd-x(a5)
	move.w	#%011111100100,Adressposs-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	#'A',(a4)+
	move.l	Pointer-x(a5),a0
	move.b	2(a0),d2
	btst	#3,d2
	bne	1$
	move.b	#'M',Befehl+1-x(a5)
	move.b	#'P',Befehl+2-x(a5)
1$	tst.b	d2		; war btst #7,d2 mit bne.b 1$
	bmi	2$
	move.b	#'D',-1(a4)
2$	bclr	#7,d2
	lsr.b	#4,d2
	add.b	#'0',d2
	move.b	d2,(a4)+
	bra	DoublePrint

;**********************************
;	PACK / UNPK 68020...
;**********************************

c_pack	move.l	#'PACK',(a4)+
	bra	c_packets

c_unpk	move.l	#'UNPK',(a4)+
	bra	c_packets

c_packets
	move.b	#9,(a4)+
;	move.l	Pointer-x(a5),a0
	btst	#3,1(a0)
	bne.b	1$

	move.b	#'D',(a4)+	;(UN)PACK	d1,d2,#1234
	bsr	RegNumD
	bsr	RegNumD2_K_D

	move.b	#',',(a4)+
	move.b	#'#',(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	bsr	HexWDi
	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

1$	move.b	#'-',(a4)+	(UN)PACK	-(a1),-(a2),#1234
	bsr	RegNumD_Bracket_A
	move.b	#')',(a4)+
	move.b	#',',(a4)+
	move.b	#'-',(a4)+
	move.b	#'(',(a4)+
	move.b	#'A',(a4)+
	bsr	RegNumD2
	move.b	#')',(a4)+

	move.b	#',',(a4)+
	move.b	#'#',(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	bsr	HexWDi
	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

;**********************************
;	MOVE FROM CCR or TO CCR
;**********************************

c_movefromccr
	move.l	#'MOVE',(a4)+
	move.l	#$09434352,(a4)+	;TAB + 'CCR'
	move.b	#',',(a4)+
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

c_movetoccr
	move.l	#'MOVE',(a4)+
	move.b	#9,(a4)+
	move.w	#%111111111101,Adressposs-x(a5)
	move.b	#'W',SizeBWL-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	#'C',(a4)+
	move.b	#'C',(a4)+
	move.b	#'R',(a4)+
	bra	DoublePrint

c_movefromsr
	move.l	#'MOVE',(a4)+
	move.l	#$0953522c,(a4)+	;TAB + 'SR,'
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

c_movetosr
	move.l	#'MOVE',(a4)+
	move.b	#9,(a4)+
	move.w	#%111111111101,Adressposs-x(a5)
	move.b	#'W',SizeBWL-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	#'S',(a4)+
	move.b	#'R',(a4)+
	bra	DoublePrint

;**********************************
;	Nur EA und BWL Befehle
;**********************************

c_clr	move.l	#'CLR.',(a4)+
	bra	NurEAundBWL
c_not	move.l	#'NOT.',(a4)+
	bra	NurEAundBWL
c_negx	move.l	#'NEGX',(a4)+
	move.b	#'.',(a4)+
	bra	NurEAundBWL
c_neg	move.l	#'NEG.',(a4)+
;	bra	NurEAundBWL

NurEAundBWL
	bsr	GetBWL
	beq	OpCodeError
	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************

c_tst	move.l	#'TST.',(a4)+
	bsr	GetBWL
	beq	OpCodeError
	move.b	SizeBWL-x(a5),(a4)+
	move.b	#9,(a4)+
	move.w	#%111111111111,Adressposs-x(a5)
	cmp.b	#'B',SizeBWL-x(a5)
	bne.b	1$
	move.w	#%111111111101,Adressposs-x(a5)
1$	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	Set if Condition Code
;**********************************

c_scc:	move.b	#'S',(a4)+
	bsr	GetCoCo2
	move.b	#9,(a4)+
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	Punktrechnung WORD
;**********************************

c_divs	move.l	#'DIVS',(a4)+	;Punktrechnung
	st	Vorzeichen-x(a5)
	bra	c_pure

c_divu	move.l	#'DIVU',(a4)+
	bra	c_pure

c_muls	move.l	#'MULS',(a4)+
	st	Vorzeichen-x(a5)
	bra	c_pure

c_mulu	move.l	#'MULU',(a4)+
;	bra	c_pure

c_pure
	move.b	#'W',SizeBWL-x(a5)
	move.w	#'.W',(a4)+
	move.b	#9,(a4)+	;Punktrechnung
	move.w	#%111111111101,Adressposs-x(a5)
	bsr	GetSEA
	bsr	RegNumD2_K_D
	bra	DoublePrint

;**********************************
;	Punktrechnung LONG 68020...
;**********************************

c_mulxl
;	move.l	Pointer-x(a5),a0
	btst	#3,2(a0)
	beq.b	c_mulul

c_mulsl	move.l	#'MULS',(a4)+
	bra.b	c_calclongvz

c_mulul	move.l	#'MULU',(a4)+
	bra.b	c_calclong

c_divxl
;	move.l	Pointer-x(a5),a0
	btst	#3,2(a0)
	bne.b	c_divsl

c_divul	move.l	#'DIVU',(a4)+
	bra.b	c_calclong

c_divsl	move.l	#'DIVS',(a4)+

c_calclongvz:
	st	Vorzeichen-x(a5)

c_calclong
	move.w	2(a0),d2
	andi.w	#%1000001111111000,d2
	bne	OpCodeError

	addq.l	#2,ToAdd-x(a5)
	move.w	#%111111111101,Adressposs-x(a5)
	move.b	#'L',SizeBWL-x(a5)
;	move.l	Pointer-x(a5),a0
	move.b	3(a0),d2
	add.b	#'0',d2
	move.b	d2,RegArt-x(a5)		; register Di/Dr
	move.b	2(a0),d2
	bclr	#7,d2
	lsr.b	#4,d2
	add.b	#'0',d2
	move.b	d2,RegArt+1-x(a5)	; register Dh/Dq

	btst	#2,2(a0)	; test size bit
	bne.b	1$

;	move.l  Pointer-x(a5),a0
	btst    #6,1(a0)		; muls/mulu command?
	beq	2$

	move.b	RegArt-x(a5),d7
	cmp.b	RegArt+1-x(a5),d7	;xxxxl.l
	beq.b	2$

	move.b	#'L',(a4)+		;DIVSL.L #1234,D1:D2
1$	move.b	#'.',(a4)+		;DIVS.L #1234,D1:D2
	move.b	#'L',(a4)+
	move.b	#9,(a4)+
	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	#'D',(a4)+
	move.b	RegArt-x(a5),(a4)+
	move.b	#':',(a4)+
	move.b	#'D',(a4)+
	move.b	RegArt+1-x(a5),(a4)+
	bra	DoublePrint

2$	move.w	#'.L',(a4)+		;DIVS.L #1234,D1
	move.b	#9,(a4)+
	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	#'D',(a4)+
	move.b	RegArt+1-x(a5),(a4)+
	bra	DoublePrint

;**********************************
;	TRAPcc 68020...
;**********************************

c_trapcc
	move.l	#'TRAP',(a4)+
	bsr	GetCoCo2
	bra	DoublePrint

c_trapcc_w
	move.l	#'TRAP',(a4)+
	bsr	GetCoCo2
	move.b	#'.',(a4)+
	move.b	#'W',(a4)+
	move.b	#9,(a4)+
	move.b	#'#',(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	bsr	HexWDi
	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

c_trapcc_l
	move.l	#'TRAP',(a4)+
	bsr	GetCoCo2
	move.b	#'.',(a4)+
	move.b	#'L',(a4)+
	move.b	#9,(a4)+
	move.b	#'#',(a4)+
;	move.l	Pointer-x(a5),a0
	move.l	2(a0),d2
	bsr	HexLDi
	addq.l	#4,ToAdd-x(a5)
	bra	DoublePrint

;**********************************
;	Bit-Manipulation mit EA		;BTST	d0,EA
;**********************************

c_bit_dynamic:
	move.w	(a0),d2
	and.w	#%11000000,d2
	lsr.w	#3,d2
	lea	c_bitmode(PC,d2.w),a1
	move.l	(a1)+,(a4)+
	move.w  (a1)+,Adressposs-x(a5)
	move.b  (a1)+,SizeBWL-x(a5)

	btst	#8,(a0)
	beq	c_bit_constant

	move.w	#$0944,(a4)+
	bsr	RegNumD2
	move.b	#',',(a4)+
	bsr	GetSEA
	bra	DoublePrint

c_bitmode:
	dc.w	"BT","ST",%111111111101,"BB"
	dc.w	"BC","HG",%000111111101,0
	dc.w	"BC","LR",%000111111101,0
	dc.w	"BS","ET",%000111111101,0

;**********************************
;	Bit-Manipulation mit Kons.	;BTST	#1,EA
;**********************************

c_bit_constant
	move.w	#$0923,(a4)+		;TAB + '#'
	moveq	#$1f,d2		; modulo 32
	and.b	3(a0),d2
	bsr	DecL
	move.l	Pointer-x(a5),a0
	cmp.b	#7,3(a0)
	bls.b	1$
	move.b	Buffer+8-x(a5),(a4)+
1$	move.b	Buffer+9-x(a5),(a4)+
	move.b	#',',(a4)+
	addq.l	#2,ToAdd-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************

c_bftst:
	move.l	#'BFTS',(a4)+
	move.b	#'T',(a4)+
	move.w	#%011111100101,Adressposs-x(a5)
	bra	c_bfxx2
c_bfchg:
	move.l	#'BFCH',(a4)+
	move.b	#'G',(a4)+
	bra	c_bfxx
c_bfclr:
	move.l	#'BFCL',(a4)+
	move.b	#'R',(a4)+
	bra	c_bfxx
c_bfset:
	move.l	#'BFSE',(a4)+
	move.b	#'T',(a4)+
;	bra	c_bfxx

c_bfxx:
	move.w	#%000111100101,Adressposs-x(a5)
c_bfxx2:
;	move.l	Pointer-x(a5),a0
	move.b	2(a0),d2
	andi.b	#%11110000,d2
	bne	OpCodeError

	move.b	#9,(a4)+
	addq.l	#2,ToAdd-x(a5)
	bsr	GetSEA
	bsr	c_bfea
	bra	DoublePrint

;**********************************

c_bfins:			;SPEZIAL
	move.l	#'BFIN',(a4)+
	move.w	#$5309,(a4)+	;'S' + TAB

;	move.l	Pointer-x(a5),a0
	tst.b	2(a0)		; war btst #7,2(a0) mit bne
	bmi	OpCodeError

	bsr.b	c_bfreg
	move.b	#',',(a4)+
	addq.l	#2,ToAdd-x(a5)
	move.w	#%000111100101,Adressposs-x(a5)
	bsr	GetSEA
	bsr.b	c_bfea
	bra	DoublePrint

c_bfexts:			;NORMAL
	move.l	#'BFEX',(a4)+
	move.w	#'TS',(a4)+
	bra.b	c_bfrxx
c_bfextu:
	move.l	#'BFEX',(a4)+
	move.w	#'TU',(a4)+
	bra.b	c_bfrxx
c_bfffo:
	move.l	#'BFFF',(a4)+
	move.b	#'O',(a4)+
;	bra.b	c_bfrxx

c_bfrxx:
;	move.l	Pointer-x(a5),a0
	tst.b	2(a0)		; war btst #7,2(a0) mit bne
	bmi	OpCodeError
	move.b	#9,(a4)+
	addq.l	#2,ToAdd-x(a5)
	move.w	#%011111100101,Adressposs-x(a5)
	bsr	GetSEA
	bsr.b	c_bfea
	move.b	#',',(a4)+
	bsr.b	c_bfreg
	bra	DoublePrint

c_bfreg	move.l	Pointer-x(a5),a0
	move.b	2(a0),d2
	lsr.b	#4,d2
	add.b	#'0',d2
	move.b	#'D',(a4)+
	move.b	d2,(a4)+
	rts

c_bfea:	move.b	#'{',(a4)+

	move.l	Pointer-x(a5),a0	;Offset of Bit-Field
	move.w	2(a0),d2
	btst	#11,d2
	beq.b	1$

	and.w	#%0000000111000000,d2	;Offset = Register Nr.
	lsr.w	#6,d2
	add.b	#'0',d2
	move.b	#'D',(a4)+
	move.b	d2,(a4)+
	bra.b	2$

1$	and.w	#%0000011111000000,d2	;Offset = five-bit Value
	lsr.w	#6,d2
	bsr	DecL
	move.b	Buffer+8-x(a5),(a4)+
	cmp.b	#'0',-1(a4)
	bne.b	11$
	subq	#1,a4
11$	move.b	Buffer+9-x(a5),(a4)+

2$	move.b	#':',(a4)+

	moveq	#0,d2
	move.l	Pointer-x(a5),a0	;Width of Bit-Field
	move.w	2(a0),d2
	btst	#5,d2
	beq.b	3$

	and.w	#%00000111,d2	;Width = Register Nr.
	add.b	#'0',d2
	move.b	#'D',(a4)+
	move.b	d2,(a4)+
	bra.b	4$

3$	and.w	#%00011111,d2	;Width = five-bit Value
	bne.b	31$
	moveq	#32,d2
31$	bsr	DecL
	move.b	Buffer+8-x(a5),(a4)+
	cmp.b	#'0',-1(a4)
	bne.b	32$
	subq	#1,a4
32$	move.b	Buffer+9-x(a5),(a4)+
4$	move.b	#'}',(a4)+
	rts

;**********************************

c_movem	move.l	#'MOVE',(a4)+
	move.w	#'M.',(a4)+

	moveq	#'L',d0
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	btst	#6,d2
	bne	1$
	moveq	#'W',d0
1$	move.b	d0,SizeBWL-x(a5)
	move.b	d0,(a4)+

	addq.l	#2,ToAdd-x(a5)

	move.b	#9,(a4)+
	btst	#10,d2
	beq.b	2$

3$	move.w	#%011111101100,Adressposs-x(a5)
	bsr	GetSEA		;fuer Quell-Operand
	move.b	#',',(a4)+
	bsr	mmask
	bra	DoublePrint

2$	bsr	mmask
	move.b	#',',(a4)+
	move.w	#%000111110100,Adressposs-x(a5)
	bsr	GetSEA		;fuer Ziel-Operand
	bra	DoublePrint

;**********************************
;	Umrechnen von MOVEM Reg.
;**********************************

mmask:	move.l	Pointer-x(a5),a0
	move.w	2(a0),d0		;get mask

	moveq	#%0000000000111000,D1
	and.w	(a0),d1		;if '-(An)', reverse bits
	cmp.w	#%0000000000100000,D1
	bne.b	m20
	moveq	#15,d3

m10:	roxr.w	#1,d0
	roxl.w	#1,d1
	dbf	d3,m10
	move.w	d1,d0
m20:	clr.b	d2	;last bit not set
	moveq	#0,d1	;start with bit 0
	clr.b	d3	;no bytes deposited yet
m1:	btst	d1,d0
	bne.b	m2
	clr.b	d2
	bra.b	m4

m2:	addq.b	#1,D1	;glance next bit
	tst.b	D2	;last bit set?
	beq.b	m3
	cmp.b	#8,D1	;last D-register?
	beq.b	m3
	cmp.b	#9,D1	;first A-register?
	beq.b	m3
	cmp.b	#16,D1	;was last register?
	beq.b	m3
	btst	D1,D0	;end of range?
	beq.b	m3
	cmp.b	#'-',D2	;already have hyphen?
	beq.b	m5
	moveq	#'-',D2
	move.b	D2,(A4)+
	addq.b	#1,D3
	bra.b	m5

m3:	subq.b	#1,D1
	bsr.b	mdepreg
	st	D2
m4:	addq.b	#1,D1
m5:	cmp.b	#16,D1
	blt.b	m1
	rts

mdepreg	movem.l	D0/D1,-(SP)
	tst.b	D3
	beq.b	md1
	cmp.b	#'-',D2
	beq.b	md1
	move.b	#'/',(a4)+
md1:	moveq	#'D',d0
	cmp.b	#8,D1
	blt.b	md2
	moveq	#"A",d0
md2:	move.b	d0,(a4)+
	addq.b	#1,d3
	and.b	#%0111,D1
	add.b	#"0",d1
	move.b	d1,(a4)+
	movem.l	(SP)+,D0/D1
	rts

;**********************************

c_movec	move.l	#'MOVE',(a4)+	;MOVEC
	move.w	#$4309,(a4)+	;'C' + TAB

;	move.l	Pointer-x(a5),a0
	move.b	#'D',RegArt-x(a5)
	move.b	2(a0),d2
;	tst.b	d2		; war btst #7,d2 mit beq
	bpl.b	1$
	move.b	#'A',RegArt-x(a5)
1$	lsr.w	#4,d2
	andi.b	#%111,d2
	add.b	#'0',d2
	move.b	d2,Mnemonic-x(a5)

	addq.l	#2,ToAdd-x(a5)

;	move.l	Pointer-x(a5),a0
	btst	#0,1(a0)
	beq.b	2$

	move.b	RegArt-x(a5),(a4)+
	move.b	Mnemonic-x(a5),(a4)+
	move.b	#',',(a4)+
	bsr	GetKoRe
	bra	DoublePrint

2$	bsr	GetKoRe
	move.b	#',',(a4)+
	move.b	RegArt-x(a5),(a4)+
	move.b	Mnemonic-x(a5),(a4)+
	bra	DoublePrint

;**********************************
;	Umrechnen des Kontroll-Reg.
;**********************************

GetKoRe	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2

	moveq	#%0000000000001111,d7
	and.w	d2,d7

	btst	#11,d2			; ist es $80x ?
	bne	1$

	cmp.w	#8,d7			;eigentlich unnoetig !!!
	beq	5$
	bgt	4$
	lsl.b	#1,d7
	move.w	KoReListe1(PC,d7.w),d7
	lea	KoReListe1(PC,d7.w),a0
	bra	2$

3$:	lea	PrPCR,a0	;808  68060...
	bra	2$

5$	lea	PrBUSCR,a0	;008  68060...
	bra	2$

4$	lea	unknown_kore,a0
	bra	2$

1$	cmp.w	#8,d7			;eigentlich unnoetig !!!
	beq	3$
	bgt	4$
	lsl.b	#1,d7
	move.w	KoReListe2(PC,d7.w),d7
	lea	KoReListe2(PC,d7.w),a0

2$	move.b	(a0)+,(a4)+
	bne	2$
	subq	#1,a4		; we don't need the ending zero
	rts

KoReListe1:
	dc.w	PrSFC-KoReListe1	;000 68010
	dc.w	PrDFC-KoReListe1	;001 68010
	dc.w	PrCACR-KoReListe1	;002 68020
	dc.w	PrTC-KoReListe1		;003 68040
	dc.w	PrITT0-KoReListe1	;004 68040
	dc.w	PrITT1-KoReListe1	;005 68040
	dc.w	PrDTT0-KoReListe1	;006 68040
	dc.w	PrDTT1-KoReListe1	;007 68040

KoReListe2:
	dc.w	PrUSP-KoReListe2	;800 68000
	dc.w	PrVBR-KoReListe2	;801 68010
	dc.w	PrCAAR-KoReListe2	;802 68020 (not 68040)
	dc.w	PrMSP-KoReListe2	;803 68020
	dc.w	PrISP-KoReListe2	;804 68020
	dc.w	PrPSR-KoReListe2	;805 68040
	dc.w	PrURP-KoReListe2	;806 68040
	dc.w	PrSRP-KoReListe2	;807 68040

unknown_kore:
	dc.b	'???',0

PrSFC:	dc.b	'SFC',0		;68010
PrDFC:	dc.b	'DFC',0		;68010
PrCACR:	dc.b	'CACR',0	;68020
PrUSP:	dc.b	'USP',0		;68000
PrVBR:	dc.b	'VBR',0		;68010
PrCAAR:	dc.b	'CAAR',0	;68020 not for 68040 (?)
PrMSP:	dc.b	'MSP',0		;68020
PrISP:	dc.b	'ISP',0		;68020
PrTC:	dc.b	'TC',0		;68040
PrITT0:	dc.b	'ITT0',0	;68040
PrITT1:	dc.b	'ITT1',0	;68040
PrDTT0:	dc.b	'DTT0',0	;68040
PrDTT1:	dc.b	'DTT1',0	;68040
PrPSR	dc.b	'PSR',0		;68040
PrURP:	dc.b	'URP',0		;68040
PrSRP:	dc.b	'SRP',0		;68040

PrBUSCR:
	dc.b	'BUSCR',0	;68060
PrPCR:
	dc.b	'PCR',0		;68060

	cnop	0,2

;**********************************
;	Umrechnen der RegNum		Bits -2.1.0-
;**********************************

RegNumD_Bracket_A:
	move.b	#'(',(a4)+
RegNumD_A:
	move.b	#'A',(a4)+
RegNumD:
	move.l	Pointer-x(a5),a0
	moveq	#%00000111,d7
	and.w	(a0),d7
	add.b	#'0',d7
	move.b	d7,(a4)+
	rts

;**********************************
;	Umrechnen der RegNumD2
;**********************************

RegNumD2_K_D:
	move.b	#',',(a4)+
RegNumD2_D:
	move.b	#'D',(a4)+
RegNumD2:
	move.l	Pointer-x(a5),a0
	moveq	#%00001110,d7
	and.b	(a0),d7
	lsr.b	#1,d7
	add.b	#'0',d7		;direkt in (a4)+ reinschreiben
	move.b	d7,(a4)+
	rts

;**********************************
;	Umrechnen von Dest EA
;**********************************

GetDEA:	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	lsr.w	#3,d2
	move.w	d2,d7
	lsr.w	#6,d7
	bra.b	GetDEA2

;**********************************
;	Umrechnen von Source EA
;**********************************

GetSEA:	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	move.w	d2,d7
GetDEA2:
	move.w	Adressposs-x(a5),d0

	andi.w	#%00000111,d7		;111 xxx
	andi.w	#%00111000,d2

;	tst.b	d2			;000 rrr
	beq	DataDirekt
	cmp.b	#%001000,d2		;001 rrr
	beq	AdreDirekt
	cmp.b	#%010000,d2		;010 rrr
	beq	AdreInDirekt
	cmp.b	#%011000,d2		;011 rrr
	beq	AdreInDirektPostin
	cmp.b	#%100000,d2		;100 rrr
	beq	AdreInDirektPrede
	cmp.b	#%101000,d2		;101 rrr
	beq	AdreInDirektDis
	cmp.b	#%110000,d2		;110 rrr
	beq	AdreInDirektDisIndex

	tst.b	d7			;111 000 Absolute Short
	beq	AbsoShort
	cmp.b	#1,d7			;111 001 Absolute Long
	beq	AbsoLong
	cmp.b	#2,d7			;111 010 (PC)indirekt mit Dis
	beq	PCInDirektDis
	cmp.b	#3,d7			;111 011 (PC)indirekt mit Index und Dis
	beq	PCIndexDis
	cmp.b	#4,d7			;111 100 Konstante 16 oder 32
	beq	Konstante

	bra	AdressIll

DataDirekt:				;000rrr
	btst	#0,d0
	beq	AdressIll

	move.b	#'D',(a4)+		;D0
	add.b	#'0',d7
	move.b	d7,(a4)+
	rts

AdreDirekt:				;001rrr
	btst	#1,d0
	beq	AdressIll

	move.b	#'A',(a4)+		;A0
	add.b	#'0',d7
	move.b	d7,(a4)+
	rts

AdreInDirekt:				;010rrr
	btst	#2,d0
	beq	AdressIll

	move.b	#'(',(a4)+		;(A0)
	move.b	#'A',(a4)+
	add.b	#'0',d7
	move.b	d7,(a4)+
	move.b	#')',(a4)+
	rts

AdreInDirektPostin:			;011rrr
	btst	#3,d0
	beq	AdressIll

	move.b	#'(',(a4)+		;(A0)+
	move.b	#'A',(a4)+
	add.b	#'0',d7
	move.b	d7,(a4)+
	move.b	#')',(a4)+
	move.b	#'+',(a4)+
	rts

AdreInDirektPrede:			;100rrr
	btst	#4,d0
	beq	AdressIll

	move.b	#'-',(a4)+		;-(A0)
	move.b	#'(',(a4)+
	move.b	#'A',(a4)+
	add.b	#'0',d7
	move.b	d7,(a4)+
	move.b	#')',(a4)+
	rts

AdreInDirektDis:			;101rrr
	btst	#5,d0
	beq	AdressIll

	move.l	Pointer-x(a5),a0	;+-$2134(A0)
	add.l	ToAdd-x(a5),a0
	move.w	2(a0),d2
	st	Vorzeichen-x(a5)
	bsr	PrintExtern16

	move.b	#'(',(a4)+
	move.b	#'A',(a4)+
	add.b	#'0',d7
	move.b	d7,(a4)+
	move.b	#')',(a4)+
	addq.l	#2,ToAdd-x(a5)
	rts

AdreInDirektDisIndex:			;110rrr
	btst	#6,d0
	beq	AdressIll

	move.l	Pointer-x(a5),d2
	add.l	ToAdd-x(a5),d2
	addq.l	#4,d2
	move.l	d2,Label-x(a5)

	move.l	Pointer-x(a5),a0
	add.l	ToAdd-x(a5),a0
	move.w	2(a0),d2
	move.w	d2,AdMode-x(a5)

	btst	#8,d2
	bne	AdreInDirektBaseDisIndex	;--> 68020... modes

;	move.b	AdMode+1-x(a5),d2		;+-$21(a0.d1.l)
	st	Vorzeichen-x(a5)
	bsr	PrintExtern08

	move.b	#'(',(a4)+
	move.b	#'A',(a4)+
	add.b	#'0',d7
	move.b	d7,(a4)+
	move.b	#',',(a4)+

	move.b	#'D',(a4)+	;erstmal
	tst.b	AdMode-x(a5)	; war btst #7,AdMode-x(a5) mit beq
	bpl.b	1$
	move.b	#'A',-1(a4)	;na denn eben doch nicht D, sondern A

1$	move.b	AdMode-x(a5),d2
	andi.b	#%01110000,d2	;register nr. von Ax oder Dx
	lsr.b	#4,d2
	add.b	#'0',d2
	move.b	d2,(a4)+
	move.b	#'.',(a4)+

	move.b	#'W',(a4)+		;erstmal
	btst	#3,AdMode-x(a5)
	beq.b	4$
	move.b	#'L',-1(a4)	;dann eben doch nicht W, sondern L

4$	moveq	#%00000110,d2		;Skalierung
	and.b	AdMode-x(a5),d2
	lsr.b	#1,d2
	beq.b	5$		;1 als Skalierung weglassen

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq	AdressIll

	moveq	#1,d6
	lsl.b	d2,d6
	add.b	#'0',d6
	move.b	#'*',(a4)+
	move.b	d6,(a4)+

5$	move.b	#')',(a4)+
	addq.l	#2,ToAdd-x(a5)
	rts

AdreInDirektBaseDisIndex:			;110rrr
	tst.b	ArguF-x(a5)		;68020 Option ???
	beq	AdressIll

	addq.l	#2,ToAdd-x(a5)
	move.b	#'(',(a4)+

	moveq	#%00001111,d2
	and.b	AdMode+1-x(a5),d2
	beq.b	1$

	move.b	#'[',(a4)+

1$	move.w	AdMode-x(a5),d2
	btst	#5,d2
	beq.b	NoBaseDisplacement

	move.l	Label-x(a5),a0

	move.w	AdMode-x(a5),d2
	btst	#4,d2
	bne.b	AXD

	addq.l	#2,ToAdd-x(a5)
	move.w	(a0),d2
	bsr	HexWs
	bra.b	ACD

AXD:	addq.l	#4,ToAdd-x(a5)
	move.l	(a0),d2
	bsr	HexLs

ACD:	move.b	#',',(a4)+

NoBaseDisplacement:
	move.b	AdMode+1-x(a5),d2	;NoReg erkennen
	tst.b	d2		; war btst #7,d2 mit bne
	bmi.b	2$

	move.b	#'A',(a4)+
	add.b	#"0",d7
	move.b	d7,(a4)+

	move.b	AdMode+1-x(a5),d2
2$	btst	#2,d2
	beq.b	8$

	moveq	#%00001111,d2
	and.b	AdMode+1-x(a5),d2
	beq.b	8$
	move.b	AdMode+1-x(a5),d2

	move.b	#',',d2
	cmp.b	-1(a4),d2
	bne	7$
	subq	#1,a4
7$	move.b	#']',(a4)+

8$
	btst	#6,d2		;Index ?
	bne.b	NoIndex

	tst.b	d2		;xReg ? (wegen dem Komma)
	bpl.b	6$
	btst	#5,d2			;Base ? (wegen dem Komma)
	beq.b	3$

6$	move.b	#',',d2
	cmp.b	-1(a4),d2	;war vorher auch schon ein Komma ??
	beq	3$
	move.b	d2,(a4)+

3$	move.b	#'D',(a4)+
	move.b	AdMode-x(a5),d2		;PC Index und Scale
	tst.b	d2		; war btst #7,d2 mit beq
	bpl.b	1$
	move.b	#'A',-1(a4)

1$	andi.b	#%01110000,d2
	lsr.b	#4,d2
	add.b	#'0',d2
	move.b	d2,(a4)+
	move.b	#'.',(a4)+

	move.b	#'W',(a4)+
	btst	#3,AdMode-x(a5)
	beq.b	4$
	move.b	#'L',-1(a4)

4$	moveq	#%00000110,d2		;Skalierung
	and.b	AdMode-x(a5),d2
	beq.b	5$
	lsr.b	#1,d2
	moveq	#1,d6
	lsl.b	d2,d6
	add.b	#'0',d6
	move.b	#'*',(a4)+
	move.b	d6,(a4)+
5$

NoIndex:
	move.b	AdMode+1-x(a5),d2
	btst	#2,d2
	bne.b	9$

;	move.b	AdMode+1-x(a5),d2
	andi.b	#%00001111,d2
	beq.b	9$

	move.b	#',',d2
	cmp.b	-1(a4),d2
	bne	7$
	subq	#1,a4
7$	move.b	#']',(a4)+

	move.b	AdMode+1-x(a5),d2

9$	btst	#1,d2
	beq.b	3$

	move.b	#',',(a4)+		;Outer Displacement WORD
	move.l	Pointer-x(a5),a0
	add.l	ToAdd-x(a5),a0
	btst	#0,d2
	bne.b	6$

	move.w	2(a0),d2
	ext.l	d2
	bsr	HexWs
	addq.l	#2,ToAdd-x(a5)
	bra.b	3$

6$	move.l	2(a0),d2
	bsr	HexLs
	addq.l	#4,ToAdd-x(a5)

3$	move.b	#')',(a4)+
	rts

AbsoShort:				;111 000
	tst.b	d0		; war btst #7,d0 mit beq
	bpl	AdressIll

	move.l	Pointer-x(a5),a0		;$1234 (Adresse)
	add.l	ToAdd-x(a5),a0
	move.w	2(a0),d2
	st	Vorzeichen-x(a5)
	bsr	PrintExtern16
	move.b	#'.',(a4)+
	move.b	#'W',(a4)+
	addq.l	#2,ToAdd-x(a5)
	rts

AbsoLong:				;111 001
	btst	#8,d0
	beq	AdressIll

	move.l	Pointer-x(a5),a0		;$12345678 (Adresse)
	add.l	ToAdd-x(a5),a0
	move.l	2(a0),d2
	move.l	d2,d5
	bsr	LabelPrint32

	tst.b	LabelYes-x(a5)
	bne.b	1$
	move.l	d5,d2
	bsr	HexLDi

1$	addq.l	#4,ToAdd-x(a5)
	rts

PCInDirektDis:				;111 010
	btst	#9,d0
	beq	AdressIll

	move.l	Pointer-x(a5),a0		;+-$1234(PC)
	add.l	ToAdd-x(a5),a0
	move.w	2(a0),d2
	ext.l	d2
	move.w	d2,d5
	addq.l	#2,d2
	add.l	ToAdd-x(a5),d2
	add.l	PCounter-x(a5),d2
	bsr	LabelPrintReloc16

	tst.b	LabelYes-x(a5)
	bne	1$
	move.w	d5,d2
	bsr	HexWs		;SOLLTE MIT PLUS SEIN

1$	move.b	#'(',(a4)+
	move.b	#'P',(a4)+
	move.b	#'C',(a4)+
	move.b	#')',(a4)+
	addq.l	#2,ToAdd-x(a5)
	rts

PCIndexDis				;111 011
	btst	#10,d0
	beq	AdressIll

	move.l	Pointer-x(a5),d2
	add.l	ToAdd-x(a5),d2
	addq.l	#4,d2		;zwei fuer Befehl und zwei fuer decoder-word
	move.l	d2,Label-x(a5)

	move.l	Pointer-x(a5),a0
	add.l	ToAdd-x(a5),a0
	move.w	2(a0),d2
	move.w	d2,AdMode-x(a5)
	btst	#8,d2
	bne	PCIndexBaseDis		;--> 68020... modes

;	move.b	AdMode+1-x(a5),d2		;+-$12(PC,D1.L)
	ext.w	d2
	ext.l	d2
	move.b	d2,d5		;retten
	addq.l	#2,d2
	add.l	ToAdd-x(a5),d2
	add.l	PCounter-x(a5),d2
	bsr	LabelPrintReloc08

	tst.b	LabelYes-x(a5)
	bne.b	5$
	move.b	d5,d2
	bsr	HexBs		;SOLLTE MIT PLUS SEIN

5$	move.b	#'(',(a4)+
	move.b	#'P',(a4)+
	move.b	#'C',(a4)+
	move.b	#',',(a4)+

	moveq	#'D',d5		;erstmal D
	move.b	AdMode-x(a5),d2
	bpl.b	1$		; war btst #7,d0 mit beq
	moveq	#'A',d5		;na denn eben doch A

1$	move.b	d5,(a4)+

	andi.b	#%01110000,d2
	lsr.b	#4,d2
	add.b	#'0',d2
	move.b	d2,(a4)+
	move.b	#'.',(a4)+

	moveq	#'W',d5		;erstmal W
	move.b	AdMode-x(a5),d2
	btst	#3,d2
	beq.b	4$
	moveq	#'L',d5		;na denn eben doch L

4$	move.b	d5,(a4)+

	moveq	#%00000110,d2		;Skalierung
	and.b	AdMode-x(a5),d2
	lsr.b	#1,d2
	beq.b	3$		;1 als Skalierung weglassen

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq	AdressIll

	moveq	#1,d6
	lsl.b	d2,d6
	add.b	#'0',d6
	move.b	#'*',(a4)+
	move.b	d6,(a4)+

3$	move.b	#')',(a4)+
	addq.l	#2,ToAdd-x(a5)
	rts

PCIndexBaseDis				;111 011
	tst.b	ArguF-x(a5)		;68020 Option ???
	beq	AdressIll

	addq.l	#2,ToAdd-x(a5)
	move.b	#'(',(a4)+

	moveq	#%00001111,d2
	and.b	AdMode+1-x(a5),d2
	beq.b	1$

	move.b	#'[',(a4)+

1$	move.w	AdMode-x(a5),d2
	btst	#5,d2
	beq.b	NoPCBaseDisplacement

	move.l	Label-x(a5),a0		;Base Displacement

	move.w	AdMode-x(a5),d2
	btst	#4,d2
	bne.b	2$

	addq.l	#2,ToAdd-x(a5)
	move.w	(a0),d2
	ext.l	d2
	move.w	d2,d5

	tst.b	AdMode+1-x(a5)	;ZeroPC erkennen (war btst #7,d0 mit beq)
	bmi.b	7$

	move.l	Label-x(a5),d3		;relative Adresse umrechnen
	sub.l	Pointer-x(a5),d3
	add.l	PCounter-x(a5),d3
	add.l	d3,d2

7$	bsr	LabelPrintReloc16
	tst.b	LabelYes-x(a5)
	bne.b	5$
	move.w	d5,d2
	bsr	HexWs			;SOLLTE MIT PLUS SEIN
	bra.b	5$

2$	addq.l	#4,ToAdd-x(a5)
	move.l	(a0),d2
	move.l	d2,d5

	tst.b   AdMode+1-x(a5)  ;ZeroPC erkennen (war btst #7,d0 mit beq)
	bmi.b	8$

	move.l	Label-x(a5),d3		;relative Adresse umrechnen
	sub.l	Pointer-x(a5),d3
	add.l	PCounter-x(a5),d3
	add.l	d3,d2

8$	move.l	ToAdd-x(a5),d3
	subq.l	#2,d3
	move.l	d3,RelocXAdress-x(a5)

	bsr	LabelPrintReloc32

	tst.b	LabelYes-x(a5)
	bne.b	5$
	move.l	d5,d2
	bsr	HexLs			;SOLLTE MIT PLUS SEIN

5$	move.b	#',',(a4)+

NoPCBaseDisplacement:
	move.b	AdMode+1-x(a5),d2	;ZeroPC erkennen
	tst.b	d2		; war btst #7,d2 mit beq
	bpl.b	2$
	move.b	#'Z',(a4)+	;wenn nicht dann eben kein -Z-

2$	move.b	#'P',(a4)+
	move.b	#'C',(a4)+

	moveq	#%00001111,d2
	and.b	AdMode+1-x(a5),d2
	beq.b	8$
	btst	#2,AdMode+1-x(a5)
	beq.b	8$
	move.b	#']',(a4)+

8$	btst	#6,AdMode+1-x(a5)
	bne.b	NoPCIndex		;Index ?

	move.b	#',',(a4)+

	move.b	AdMode-x(a5),d2		;PC Index and Scale
	move.b	#'D',(a4)+
	tst.b	d2		; war btst #7,d2 mit beq
	bpl.b	1$
	move.b	#'A',-1(a4)

1$	andi.b	#%01110000,d2
	lsr.b	#4,d2
	add.b	#'0',d2
	move.b	d2,(a4)+
	move.b	#'.',(a4)+

	move.b	#'W',(a4)+
	move.b	AdMode-x(a5),d2
	btst	#3,d2
	beq.b	4$
	move.b	#'L',-1(a4)

4$	and.b	#%00000110,d2	;Skalierung
	lsr.b	#1,d2
	beq.b	5$
	moveq	#1,d6
	lsl.b	d2,d6
	add.b	#'0',d6
	move.b	#'*',(a4)+
	move.b	d6,(a4)+
5$

NoPCIndex:
	move.b	AdMode+1-x(a5),d2
	btst	#2,d2
	bne.b	9$

;	move.b	AdMode+1-x(a5),d2
	andi.b	#%00001111,d2
	beq.b	9$

	move.b	#']',(a4)+

9$	btst	#1,d2
	beq.b	3$

	move.b	#',',(a4)+
	move.l	Pointer-x(a5),a0
	add.l	ToAdd-x(a5),a0

	btst	#0,d2
	bne.b	6$

	move.w	2(a0),d2
	bsr	PrintExtern16		;Outer Displacement WORD
	addq.l	#2,ToAdd-x(a5)
	bra.b	3$

6$	move.l	2(a0),d2
	bsr	PrintExtern32		;Outer Displacement LONG
	addq.l	#4,ToAdd-x(a5)

3$	move.b	#')',(a4)+
	rts

Konstante:				;111 100
	btst	#11,d0
	beq	AdressIll
	move.b	#'#',(a4)+		;#$1234 oder #$12345678
					;Plus oder Minus kann man
	move.l	Pointer-x(a5),a0		;nicht wissen !
	add.l	ToAdd-x(a5),a0
	addq.l	#2,a0

	move.b	SizeBWL-x(a5),d0

	cmp.b	#'B',d0		;byte integer
	beq	KonsB
	cmp.b	#'W',d0		;word integer
	beq	KonsW
	cmp.b	#'L',d0		;long-word integer or Label
	beq	KonsL

	tst.b	ArguF-x(a5)		;68020 Option ???
	beq	AdressIll

	cmp.b	#'S',d0		;singe-precision real
	beq	KonsS
	cmp.b	#'P',d0		;packed-decimal real
	beq	KonsX
	cmp.b	#'D',d0		;double-precision real
	beq	KonsD
	cmp.b	#'X',d0		;extended-precision real
	beq	KonsX

	bra	AdressIll

KonsL:	move.l	(a0),d2
	move.l	d2,d5
	bsr	LabelPrint32

	tst.b	LabelYes-x(a5)
	bne.b	2$
	move.l	d5,d2
	bsr	HexLDi

2$	addq.l	#4,ToAdd-x(a5)
	rts

KonsB:	tst.b	(a0)
	beq.b	1$
	cmp.b	#$ff,(a0)
	bne	AdressIll
1$	move.b	1(a0),d2
	bsr	PrintExtern08	;BYTE !!! [move.b 1(a0),d2]
	addq.l	#2,ToAdd-x(a5)
	rts

KonsW:	move.w	(a0),d2
	bsr	PrintExtern16
	addq.l	#2,ToAdd-x(a5)
	rts

KonsS:	move.l	(a0),d2
	bsr	PrintExtern32
	addq.l	#4,ToAdd-x(a5)
	rts

KonsD:	bsr	HexDDi
	addq.l	#8,ToAdd-x(a5)
	rts

KonsX:	bsr	HexXDi
	moveq	#12,d2
	add.l	d2,ToAdd-x(a5)
	rts

AdressIll:
	addq.l	#4,SP
	bra	OpCodeError

;**********************************
;	LONG, WORD oder Byte
;**********************************

GetBWL:
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	andi.w	#%11000000,d2

	lsr.b	#6,d2
	move.b	Size(PC,d2.w),SizeBWL-x(a5)
	rts

Size:	dc.b	"BWL",0

;**********************************
;	Speichert die Co. Codes
;**********************************

GetCoCo:
;	move.l	Pointer-x(a5),a0
	moveq	#%00001111,d2
	and.b	(a0),d2

	add.b	d2,d2

	bne.b	1$
	tst.b	Argu6-x(a5)
	seq	DataRem-x(a5)	;Data-Logic ON/OFF

1$	lea	BCCx(PC,d2.w),a1
	move.b	(a1)+,(a4)+
	move.b	(a1),(a4)+
	rts

BCCx:	dc.b	"RASRHILSCCCSNEEQVCVSPLMIGELTGTLE"

;**********************************
;	Speichert die Co. Codes
;**********************************

GetCoCo2:
;	move.l	Pointer-x(a5),a0
	moveq	#%00001111,d2
	and.b	(a0),d2

	add.b	d2,d2

	lea	DBCCx(PC,d2.w),a1
	move.b	(a1)+,(a4)+
	move.b	(a1),d2
	beq.b	1$
	move.b	d2,(a4)+
1$	rts

DBCCx:	dc.b	"T",0,"F",0,"HILSCCCSNEEQVCVSPLMIGELTGTLE"

;**********************************
;	Zuruecksetzen der Werte PASS2
;**********************************

DochFalsch:			;fuer falsche Aussortierungen
	move.l	#'    ',d0
	move.l	d0,Relocmarke-x(a5)
	move.l	d0,Relocmarke+4-x(a5)
	move.w	d0,Relocmarke+8-x(a5)

	clr.l	ToAdd-x(a5)	;in der DissAssembler-Routine
	lea	Befehl-x(a5),a4
	move.l	Pointer-x(a5),a0
	move.w	(a0),d0
	rts
