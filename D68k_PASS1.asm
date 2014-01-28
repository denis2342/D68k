;**********************************
;	Label suchen
;**********************************

PASS1:	bsr	LoadJumplist	;JumpList einlesen und checken (wenn vorhanden)
	clr.l	CurrHunk-x(a5)	;Erster Hunk fängt jetzt an

	bsr	LibraryInit	;wenn nötig ev. ein paar Adressen einfügen

	tst.b	Argu4-x(a5)	;INFO/S
	beq	1$

		move.l	Relocs32-x(a5),d7
		beq.b	11$
		move.l	#Status8T,d1		;Relocs32 ausgeben
		moveq	#Status9T-Status8T,d2
		bsr	PrintText
		move.l	d7,d2
		bsr	WriteInfoText
11$
		move.l	Relocs16-x(a5),d7
		beq.b	12$
		move.l	#Status9T,d1		;Relocs16 ausgeben
		moveq	#StatusAT-Status9T,d2
		bsr	PrintText
		move.l	d7,d2
		bsr	WriteInfoText
12$
		move.l	Relocs08-x(a5),d7
		beq.b	13$
		move.l	#StatusAT,d1		;Relocs08 ausgeben
		moveq	#StatusBT-StatusAT,d2
		bsr	PrintText
		move.l	d7,d2
		bsr	WriteInfoText
13$
		move.l	DRelocs32-x(a5),d7
		beq.b	21$
		move.l	#StatusDT,d1		;Relocs32 ausgeben
		moveq	#StatusET-StatusDT,d2
		bsr	PrintText
		move.l	d7,d2
		bsr	WriteInfoText
21$
		move.l	DRelocs16-x(a5),d7
		beq.b	22$
		move.l	#StatusET,d1		;Relocs16 ausgeben
		moveq	#StatusFT-StatusET,d2
		bsr	PrintText
		move.l	d7,d2
		bsr	WriteInfoText
22$
		move.l	DRelocs08-x(a5),d7
		beq.b	23$
		move.l	#StatusFT,d1		;Relocs08 ausgeben
		moveq	#StatusGT-StatusFT,d2
		bsr	PrintText
		move.l	d7,d2
		bsr	WriteInfoText
23$
		move.l	Symbole-x(a5),d7
		beq.b	14$
		move.l	#StatusBT,d1		;Symbole ausgeben
		moveq	#StatusCT-StatusBT,d2
		bsr	PrintText
		move.l	d7,d2
		bsr	WriteInfoText
14$
1$
	move.l	Memory-x(a5),a0

NextHunk4:
	move.l	FileSize-x(a5),d0
	add.l	Memory-x(a5),d0
	cmp.l	a0,d0
	ble.b	2$
	bsr	ExePASS1	;PASS1 - Label Tabelle anlegen
	bra.b	NextHunk4

2$	move.l	LabelPointer-x(a5),d2	;unso. LabelTabellen Einträge
	lsr.l	#2,d2
	move.l	d2,LabelMax-x(a5)

	tst.b	Argu4-x(a5)	;INFO/S
	beq.b	3$

		move.l	ICodesP1-x(a5),d7
		beq.b	11$
		move.l	#Status5T,d1		;ICodes-Anzahl ausgeben
		moveq	#Status6T-Status5T,d2
		bsr	PrintText
		move.l	d7,d2
		bsr	WriteInfoText

		move.l	IllPC-x(a5),d7
		beq.b	11$
		move.l	#StatusCT,d1		;Adresse des letzten illegalen Codes ausgeben
		moveq	#StatusDT-StatusCT,d2
		bsr	PrintText
		move.l	d7,d2
		bsr	WriteInfoText

11$
		move.l	#Status3T,d1		;max Labelanzahl ausgeben
		moveq	#Status4T-Status3T,d2
		bsr	PrintText
		move.l	LabelMax-x(a5),d2
		bsr	WriteInfoText

3$	bsr	SortLabel

	move.l	LabelPointer-x(a5),d2	;sort. LabelTabellen Einträge
	lsr.l	#2,d2
	move.l	d2,LabelMin-x(a5)

	tst.b	Argu4-x(a5)	;INFO/S
	beq.b	4$

		move.l	#Status4T,d1		;min Labelanzahl ausgeben
		moveq	#Status5T-Status4T,d2
		bsr	PrintText
		move.l	LabelMin-x(a5),d2
		bsr	WriteInfoText

4$	rts

ExePASS1:
	move.l	(a0)+,d7
	cmp.w	#$03e7,d7	;Hunk_Unit
	beq	HUnit4
	cmp.w	#$03e8,d7	;Hunk_Name
	beq	HName4
	cmp.w	#$3e9,d7	;Hunk_Code
	beq	HCode4
	cmp.w	#$03ea,d7	;Hunk_Data
	beq	HData4
	cmp.w	#$03eb,d7	;Hunk_BSS
	beq	HBSS4
	cmp.w	#$03ec,d7	;Hunk_Reloc32
	beq	HReloc32_4
	cmp.w	#$03ed,d7	;Hunk_Reloc16
	beq	HReloc16_4
	cmp.w	#$03ee,d7	;Hunk_Reloc8
	beq	HReloc08_4
	cmp.w	#$03ef,d7	;Hunk_Ext
	beq	HExt4
	cmp.w	#$03f0,d7	;Hunk_Symbol
	beq	HSymbol4
	cmp.w	#$03f1,d7	;Hunk_Debug
	beq	HDebug4
	cmp.w	#$03f2,d7	;Hunk_End
	beq	HEnd4
	cmp.w	#$03f3,d7	;Hunk_Header
	beq	HHeader4
	cmp.w	#$03f5,d7	;Hunk_Overlay
	beq	HOverlay4
	cmp.w	#$03f6,d7	;Hunk_Break
	beq	HBreak4
	cmp.w	#$03f7,d7	;Hunk_DRel32
	beq	Hdrel324
	cmp.w	#$03f8,d7	;Hunk_DRel16
	beq	Hdrel164
	cmp.w	#$03f9,d7	;Hunk_DRel08
	beq	Hdrel084
	cmp.w	#$03fa,d7	;Hunk_Lib
	beq	HLib4
	cmp.w	#$03fb,d7	;Hunk_Index
	beq	HIndex4

	cmp.l	#$11144ef9,d7	;Kickstartkennung
	beq	KickStart4
	clr.b	d7
	cmp.l	#$444f5300,d7	;"DOS",0
	beq	Bootblock4

	bra	Unknown_Hunk4

HCode4:	move.l	(a0)+,d0	;CodeSize in Longwords
	lsl.l	#2,d0

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	2$

	cmp.l	#-1,SprungPointer-x(a5)
	beq.b	1$

2$	move.l	a0,CodeAnfang-x(a5)
	move.l	d0,CodeSize-x(a5)
	move.l	CurrHunk-x(a5),d1
	movem.l	a0/d0-d1,-(SP)

	bsr	Labelcode_1

	movem.l	(SP)+,a0/d0-d1
	move.l	d1,CurrHunk-x(a5)
	move.l	a0,CodeAnfang-x(a5)
	move.l	d0,CodeSize-x(a5)

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$
	move.l	#-1,SprungPointer-x(a5)

1$	add.l	d0,a0
	rts

HBSS4:	move.l	(a0)+,d0
	move.l	a0,CodeAnfang-x(a5)
	lsl.l	#2,d0
	rts

HIndex4:
HUnit4:
HName4:
HDebug4:
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0
	rts

HLib4:	move.l	(a0)+,d0
	rts

HData4:	move.l	(a0)+,d0
	lsl.l	#2,d0
	move.l	a0,CodeAnfang-x(a5)
	move.l	d0,CodeSize-x(a5)
	add.l	d0,a0
	rts

HOverlay4:
	move.l	(a0)+,d0
	lsl.l	#2,d0
	addq.l	#4,a0
	add.l	d0,a0
	rts

HEnd4:	addq.l	#1,CurrHunk-x(a5)
;	rts

HBreak4:
	rts

HExt4:	bra.b	3$
1$	tst.l	d0		; war btst #31,d0 mit beq.b 2$
	bpl.b	2$

	and.l	#$ffffff,d0	;größer als $80
	lsl.l	#2,d0
	add.l	d0,a0
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0

3$	move.l	(a0)+,d0
	bne.b	1$
	rts

2$	and.l	#$ffffff,d0	;kleiner als $80
	lsl.l	#2,d0
	add.l	d0,a0
	addq.l	#4,a0
	bra.b	3$

HReloc32_4:
	bra	SearchReloc32Label
HReloc16_4:
	bra	SearchReloc16Label
HReloc08_4:
	bra	SearchReloc08Label

Hdrel324:
Hdrel084:
	bra.b	2$

1$	addq.l	#2,a0		;Location from the Label (Symbol)
	add.l	d0,d0
	add.l	d0,a0
2$	clr.l	d0
	move.w	(a0)+,d0	;Länge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende

	move.l	a0,d0
	add.l	#2,d0
	bclr	#1,d0
	move.l	d0,a0

	rts

Hdrel164:
HSymbol4:
	bra.b	2$
1$	lsl.l	#2,d0
	add.l	d0,a0
	move.l	(a0)+,d2	;Location of the Label (Symbol)
2$	move.l	(a0)+,d0	;Länge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende
	rts

HHeader4:
	bra.b	2$
1$	lsl.l	#2,d0
	add.l	d0,a0
2$	move.l	(a0)+,d0
	bne.b	1$

	move.l	(a0)+,d0	;HunkAnzahl
	move.l	(a0)+,d0	;Erster Hunk
	move.l	(a0)+,d7	;Letzter Hunk
	addq.l	#1,d7
	sub.l	d0,d7
	lsl.l	#2,d7
	add.l	d7,a0		;Einzelnen Hunknummern überspringen
	rts

Bootblock4:

	addq.l	#8,a0			;Anfangen
	move.l	#1012,d0		;Länge
	move.l	d0,CodeSize-x(a5)
	move.l	a0,CodeAnfang-x(a5)

	movem.l	a0/d0,-(SP)

	bsr	Labelcode_1

	movem.l	(SP)+,a0/d0

	add.l	CodeSize-x(a5),a0
	rts

KickStart4:

	subq.l	#4,a0			;Anfangen
	move.l	#$80000,d0		;Länge
	move.l	d0,CodeSize-x(a5)
	move.l	a0,CodeAnfang-x(a5)

	movem.l	a0/d0,-(SP)

	bsr	Labelcode_1

	movem.l	(SP)+,a0/d0

	add.l	CodeSize-x(a5),a0
	rts

Unknown_Hunk4
	move.l	FileHD2-x(a5),HunkForm1-x(a5)
	clr.l	FileHD2-x(a5)
	move.l	-(a0),Mnemonic-x(a5)
	move.l	a0,d2
	move.l	Memory-x(a5),d1
	sub.l	d1,d2
	bsr	HexOutPutL	;an dieser stelle war er
	bsr	Space
	move.l	Mnemonic-x(a5),d2
	bsr	HexOutPutL	;diesen kenn ich nicht
	move.l	#Error8T,d1		;Internal Error (3)
	moveq	#Error9T-Error8T,d2
	bsr	PrintText
	move.l	HunkForm1-x(a5),FileHD2-x(a5)
	bra	Error4
