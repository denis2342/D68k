;
;	D68k.data von Denis Ahrens 1990-1994
;

DisData:
	tst.b	ArguD-x(a5)
	bne	Dissa4_1

	clr.l	PCounter-x(a5)
	tst.l	CodeSize-x(a5)	;Check fuer DataLength = 0
	beq.b	DisDaE		;Wenn CodeSize = 0 dann RTS
	bsr	Return		;Ein Return ausgeben

DisData2:
	bsr	CheckC
	bsr.b	DissaData	;Data ausgeben
	move.l	PCounter-x(a5),d0
	cmp.l	CodeSize-x(a5),d0
	blt.b	DisData2
DisDaE:	bsr	PLine
	rts

DissaData:
	lea.l	Befehl-x(a5),a4
	move.l	CodeAnfang-x(a5),a0
	add.l	PCounter-x(a5),a0

	move.l	HunkMem-x(a5),a1	;Anfangsadresse der Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	4(a1,d0.l),d0			;Groesse des Hunks
	cmp.l	PCounter-x(a5),d0
	bhi.b	3$
	lea	NULL-x(a5),a0

3$	move.l	a0,Pointer-x(a5)

	bsr	PLine		;Ausgabe des PC + TAB

	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	1$
	move.l	#Befehl2,d1
	moveq	#7,d2
	bsr	Print

1$	btst	#0,PCounter+3-x(a5)	;test auf gerade
	bne.b	d_dc_b

	bsr	CheckOnReloc32
	tst.b	LabelYes-x(a5)
	beq.b	2$

	move.w	ExternSize-x(a5),d0
	subq.w	#1,d0			;test d0 for 1
	beq	d_dc_b
	subq.w	#1,d0			;test d0 for 2
	beq	d_dc_w2
	subq.w	#2,d0			;test d0 for 4
	beq	d_dc_l2
2$
	move.l	NextLabel-x(a5),d3

	moveq	#4,d2
	cmp.l	d2,d3		;erst LONG
	bcc	d_dc_l

	moveq	#2,d2
	cmp.l	d2,d3		;dann WORD
	bcc	d_dc_w

d_dc_b:	move.l	#'dc.b',(a4)+	;dann BYTE
	move.b	#9,(a4)+

	moveq	#0,d2
	move.l	Pointer-x(a5),a0
	move.b	(a0),d2
	move.b	d2,d5
	moveq	#-2,d7
	move.l	d7,ToAdd-x(a5)

	bsr	LabelPrint08

	tst.b	LabelYes-x(a5)
	bne.b	2$

	bsr	PrintByteData

2$	tst.b	Argu3-x(a5)	;NOPC/S
	bne	1$

		move.l	Pointer-x(a5),a0
		move.b	(a0),d2
		bsr	HexOutPutB
		bsr	TAB3

1$	move.b	#9,Befehltab-x(a5)
	move.b	#10,(a4)+	;RETURN hinten ranhaengen
	move.l	#Befehl-1,d1	;und ausgeben
	move.l	a4,d2
	sub.l	d1,d2
	bsr	Print

	tst.b	LabelYes-x(a5)
	bne.b	7$

	addq.l	#1,PCounter-x(a5)
	rts

7$	moveq	#0,d0
	move.w	ExternSize-x(a5),d0
	add.l	d0,PCounter-x(a5)
	rts

d_dc_w:	addq.l	#1,PCounter-x(a5)
	bsr	NotPrintExternXX
	subq.l	#1,PCounter-x(a5)

	tst.b	LabelYes-x(a5)
	beq.b	4$
	bra	d_dc_b
4$
d_dc_w2
	move.l	#'dc.w',(a4)+
	move.b	#9,(a4)+

	moveq	#0,d2
	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	move.w	d2,d5
	moveq	#-2,d7
	move.l	d7,ToAdd-x(a5)

	bsr	LabelPrint16

	tst.b	LabelYes-x(a5)
	bne.b	2$

	bsr	PrintWordData

2$	tst.b	Argu3-x(a5)	;NOPC/S
	bne	1$

		move.l	Pointer-x(a5),a0
		move.w	(a0),d2
		bsr	HexOutPutW	;auf jeden Fall ein WORD fuer Mnemonic
		bsr	TAB3		;am ende noch vier TAB

1$	move.b	#9,Befehltab-x(a5)
	move.b	#10,(a4)+	;RETURN hinten ranhaengen
	move.l	#Befehl-1,d1	;und ausgeben
	move.l	a4,d2
	sub.l	d1,d2
	bsr	Print

	tst.b	LabelYes-x(a5)
	bne.b	7$

	addq.l	#2,PCounter-x(a5)
	rts

7$	moveq	#0,d0
	move.w	ExternSize-x(a5),d0
	add.l	d0,PCounter-x(a5)
	rts

d_dc_l:	addq.l	#1,PCounter-x(a5)
	bsr	NotPrintExternXX
	subq.l	#1,PCounter-x(a5)

	tst.b	LabelYes-x(a5)
	beq.b	6$
	bra	d_dc_b
6$
	addq.l	#2,PCounter-x(a5)
	bsr	CheckOnReloc32
	subq.l	#2,PCounter-x(a5)

	tst.b	LabelYes-x(a5)
	beq.b	5$
	bra	d_dc_w
5$
	addq.l	#3,PCounter-x(a5)
	bsr	NotPrintExternXX
	subq.l	#3,PCounter-x(a5)

	tst.b	LabelYes-x(a5)
	beq.b	4$
	bra	d_dc_w
4$
d_dc_l2
	move.l	#'dc.l',(a4)+
	move.b	#9,(a4)+

	move.l	Pointer-x(a5),a0
	move.l	(a0),d2
	move.l	d2,d5

	moveq	#-2,d7
	move.l	d7,ToAdd-x(a5)
	bsr	LabelPrint32

	tst.b	LabelYes-x(a5)	;wenn LABEL dann kein ASCII-Text
	bne	2$

	bsr	PrintLongData

2$	tst.b	Argu3-x(a5)	;NOPC/S
	bne	1$

		move.l	Pointer-x(a5),a0
		move.w	(a0),d2
		bsr	HexOutPutW
		bsr	Space
		move.l	Pointer-x(a5),a0
		move.w	2(a0),d2
		bsr	HexOutPutW
		bsr	TAB2

1$	move.b	#9,Befehltab-x(a5)
	move.b	#10,(a4)+	;RETURN hinten ranhaengen
	move.l	#Befehl-1,d1	;und ausgeben
	move.l	a4,d2
	sub.l	d1,d2
	bsr	Print

	tst.b	LabelYes-x(a5)
	bne.b	7$

	addq.l	#4,PCounter-x(a5)
	rts

7$	moveq	#0,d0
	move.w	ExternSize-x(a5),d0
	add.l	d0,PCounter-x(a5)
	rts


PrintLongData:
	tst.b	ArguG-x(a5)	;HEXDATA/S
	bne.b	4$

	move.l	Pointer-x(a5),a0	;wenn zu klein dann kein ASCII-Text
	cmp.b	#31,(a0)
	bls.b	4$
	cmp.b	#31,1(a0)
	bls.b	4$
	cmp.b	#31,2(a0)
	bls.b	4$
	cmp.b	#31,3(a0)
	bls.b	4$

	cmp.b	#126,(a0)		;wenn zu gross dann kein ASCII-Text
	bhi.b	4$
	cmp.b	#126,1(a0)
	bhi.b	4$
	cmp.b	#126,2(a0)
	bhi.b	4$
	cmp.b	#126,3(a0)
	bhi.b	4$

	move.l	d5,Mnemonic-x(a5)
	move.b	#'"',(a4)+
	bsr	TextSort
	move.b	Mnemonic+0-x(a5),(a4)+
	move.b	Mnemonic+1-x(a5),(a4)+
	move.b	Mnemonic+2-x(a5),(a4)+
	move.b	Mnemonic+3-x(a5),(a4)+
	move.b	#'"',(a4)+
	rts

4$	move.l	d5,d2
	bsr	HexLDi

	move.l	Pointer-x(a5),a0	;wenn zu klein dann kein ASCII-Text
	cmp.b	#31,(a0)
	bls.b	5$
	cmp.b	#126,(a0)
	bls.b	3$

5$	cmp.b	#31,1(a0)
	bls.b	6$
	cmp.b	#126,1(a0)
	bls.b	3$

6$	cmp.b	#31,2(a0)
	bls.b	7$
	cmp.b	#126,2(a0)
	bls.b	3$

7$	cmp.b	#31,3(a0)
	bls.b	2$
	cmp.b	#126,3(a0)
	bhi.b	2$

3$	move.l	d5,Mnemonic-x(a5)
	move.b	#9,(a4)+
	move.b	#';',(a4)+
	move.b	#'"',(a4)+
	bsr	TextSort
	move.b	Mnemonic+0-x(a5),(a4)+
	move.b	Mnemonic+1-x(a5),(a4)+
	move.b	Mnemonic+2-x(a5),(a4)+
	move.b	Mnemonic+3-x(a5),(a4)+
	move.b	#'"',(a4)+
2$	rts


PrintWordData:
	tst.b	ArguG-x(a5)	;HEXDATA/S
	bne.b	4$

	move.l	Pointer-x(a5),a0	;wenn zu klein dann kein ASCII-Text
	cmp.b	#31,(a0)
	bls.b	4$
	cmp.b	#31,1(a0)
	bls.b	4$

	cmp.b	#126,(a0)		;wenn zu gross dann kein ASCII-Text
	bhi.b	4$
	cmp.b	#126,1(a0)
	bhi.b	4$

	move.w	d5,Mnemonic-x(a5)
	move.b	#'"',(a4)+
	bsr	TextSort
	move.b	Mnemonic+0-x(a5),(a4)+
	move.b	Mnemonic+1-x(a5),(a4)+
	move.b	#'"',(a4)+
	rts

4$	move.w	d5,d2
	bsr	HexWDi

	move.l	Pointer-x(a5),a0	;wenn zu klein dann kein ASCII-Text
	cmp.b	#31,(a0)
	bls.b	5$
	cmp.b	#126,(a0)
	bls.b	3$

5$	cmp.b	#31,1(a0)
	bls.b	2$
	cmp.b	#126,1(a0)
	bhi.b	2$

3$	move.w	d5,Mnemonic-x(a5)
	move.b	#9,(a4)+
	move.b	#9,(a4)+
	move.b	#';',(a4)+
	move.b	#'"',(a4)+
	bsr	TextSort
	move.b	Mnemonic+0-x(a5),(a4)+
	move.b	Mnemonic+1-x(a5),(a4)+
	move.b	#'"',(a4)+
2$	rts


PrintByteData:
	tst.b	ArguG-x(a5)	;HEXDATA/S
	bne.b	4$

	move.l	Pointer-x(a5),a0	;wenn NULL dann kein ASCII-Text
	cmp.b	#31,(a0)
	bls.b	4$
	cmp.b	#126,(a0)
	bhi.b	4$

	move.b	d5,Mnemonic-x(a5)
	move.b	#'"',(a4)+
	bsr	TextSort
	move.b	Mnemonic+0-x(a5),(a4)+
	move.b	#'"',(a4)+
	rts

4$	move.b	d5,d2
	bsr	HexBDi

	move.l	Pointer-x(a5),a0	;wenn NULL dann kein ASCII-Text
	cmp.b	#31,(a0)
	bls.b	2$
	cmp.b	#126,(a0)
	bhi.b	2$

	move.b	d5,Mnemonic-x(a5)
	move.b	#9,(a4)+
	move.b	#9,(a4)+
	move.b	#';',(a4)+
	move.b	#'"',(a4)+
	bsr	TextSort
	move.b	Mnemonic+0-x(a5),(a4)+
	move.b	#'"',(a4)+
2$	rts
