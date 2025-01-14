;
;	Ist da um die Anzahl der Hunks zu Z�hlen (sonst nichts)
;

;**********************************
;	PrePass1
;**********************************

PrePASS1:
	bsr	HunkInit	;Hunks z�hlen
	move.l	CurrHunk-x(a5),d0
	beq.b	1$			;falls null Hunks
	move.l	d0,HunkAnzahl-x(a5)
	lsl.l	#TabSize,d0
	move.l	d0,HunkMemLen-x(a5)	;pro Hunk
	move.l	#$10000,d1		;Speicher l�schen egal welchen
	move.l	4,a6
	jsr	_LVOAllocVec(a6)
	move.l	d0,HunkMem-x(a5)	;Speicherzuweisung retten
	beq	Error4
1$	rts

;**********************************
;	PrePass1: HunkInit		Hier werden die Hunks gez�hlt
;**********************************

HunkInit:
	move.l	Memory-x(a5),a2	;Fileanfang
	clr.l	CurrHunk-x(a5)

NHunk2	move.l	FileSize-x(a5),d0
	add.l	Memory-x(a5),d0		;d0=MemoryEnde a2=DaBinIch
	cmp.l	a2,d0
	ble.b	1$			;schon am ende des files ?
	bsr.b	NoCode2

	move.l	a2,d0
	sub.l	Memory-x(a5),d0
	cmp.l	FileSize-x(a5),d0
	bhi	FileTooSmall

	bra.b	NHunk2

1$		tst.b	Argu4-x(a5)	;INFO/S
		beq.b	2$

		move.l	#Status2T,d1		;HunkAnzahl ausgeben
		moveq	#Status3T-Status2T,d2
		bsr	PrintText
		move.l	CurrHunk-x(a5),d2
		bsr	WriteInfoText

2$	rts

NoCode2:
	move.l	a2,d7
	sub.l	Memory-x(a5),d7
	cmp.l	FileSize-x(a5),d7
	bcc	FileTooSmall

	move.l	(a2)+,d7	;a2=Memory mitten im File
	cmp.w	#$03e7,d7	;Hunk_Unit
	beq	HUnit2
	cmp.w	#$03e8,d7	;Hunk_Name
	beq	HName2
	cmp.w	#$03e9,d7	;Hunk_Code
	beq	HCode2
	cmp.w	#$03ea,d7	;Hunk_Data
	beq	HData2
	cmp.w	#$03eb,d7	;Hunk_BSS
	beq	HBSS2
	cmp.w	#$03ec,d7	;Hunk_Reloc32
	beq	HReloc32_2
	cmp.w	#$03ed,d7	;Hunk_Reloc16
	beq	HReloc16_2
	cmp.w	#$03ee,d7	;Hunk_Reloc8
	beq	HReloc08_2
	cmp.w	#$03ef,d7	;Hunk_Ext
	beq	HExt2
	cmp.w	#$03f0,d7	;Hunk_Symbol
	beq	HSymbol2
	cmp.w	#$03f1,d7	;Hunk_Debug
	beq	HDebug2
	cmp.w	#$03f2,d7	;Hunk_End
	beq	HEnd2
	cmp.w	#$03f3,d7	;Hunk_Header
	beq	HHeader2
	cmp.w	#$03f5,d7	;Hunk_Overlay
	beq	HOverlay2
	cmp.w	#$03f6,d7	;Hunk_Break
	beq	HBreak2
	cmp.w	#$03f7,d7	;Hunk_DRel32
	beq	Hdrel322
	cmp.w	#$03f8,d7	;Hunk_DRel16
	beq	Hdrel162
	cmp.w	#$03f9,d7	;Hunk_DRel08
	beq	Hdrel082
	cmp.w	#$03fa,d7	;Hunk_Lib
	beq	HLib2
	cmp.w	#$03fb,d7	;Hunk_Index
	beq	HIndex2

	cmp.l	#$11114ef9,d7	;OLDROM Kickstartkennung
	beq	KickStart2
	cmp.l	#$11144ef9,d7	;512KB ROM Kickstartkennung
	beq	KickStart2
	cmp.l	#$00008000,d7	;Zyxel Firmware 6.22
	beq	Zyxel
	clr.b	d7		;FileSystem ist egal
	cmp.l	#$444f5300,d7	;"DOS",0
	beq	Bootblock2

	bra	Unknown_Hunk2

HExt2:	bra	3$
1$	tst.l	d0		; war btst #31,d0 mit beq.b 2$
	bpl	2$
	and.l	#$ffffff,d0	;gr��er als $80
	lsl.l	#2,d0
	add.l	d0,a2
	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
3$	move.l	(a2)+,d0
	bne	1$
	rts

2$	and.l	#$ffffff,d0	;kleiner als $80
	lsl.l	#2,d0
	add.l	d0,a2
	addq.l	#4,a2
	move.l	(a2)+,d0
	bne	1$
	rts

HBSS2:	move.l	(a2)+,d0
	lsl.l	#2,d0
	rts

HDebug2:
HData2:
HCode2:
HName2:
HUnit2:
HIndex2:
	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
	rts

HLib2:	move.l	(a2)+,d0
	rts

HOverlay2:
	move.l	(a2)+,d0
	lsl.l	#2,d0
	addq.l	#4,a2
	add.l	d0,a2
	rts

HEnd2	addq.l	#1,CurrHunk-x(a5)
;	rts

HBreak2:
	rts

HReloc32_2:
HReloc16_2:
HReloc08_2:
	bra.b	2$
1$	addq.l	#4,a2		;auf diesen Hunk bezogen
	lsl.l	#2,d7
	bsr.b	Reloc32Sort
	add.l	d7,a2
2$	move.l	(a2)+,d7	;Anzahl der Offsets
	bne.b	1$		;Wenn NULL dann Ende
	rts

Reloc32Sort:
	movem.l	d7/a2,-(SP)
	move.l	a2,a1
	bsr	QuickSort	;jede einzelne RelocTabelle wird vorsortiert
	movem.l	(SP)+,d7/a2
	rts

Hdrel162:
HSymbol2:
	bra.b	2$
1$	addq.l	#4,a2		;Location from the Label (Symbol)
	lsl.l	#2,d0
	add.l	d0,a2
2$	move.l	(a2)+,d0	;L�nge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende
	rts

Hdrel322:
Hdrel082:
	bra.b	2$

1$	addq.l	#2,a2		;Location from the Label (Symbol)
	add.l	d0,d0
	add.l	d0,a2
2$	clr.l	d0
	move.w	(a2)+,d0	;L�nge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende

	move.l	a2,d0
	add.l	#2,d0
	bclr	#1,d0
	move.l	d0,a2

	rts

HHeader2:
	bra.b	2$

1$	lsl.l	#2,d0		;wenn HunkName vorhanden, dann
	add.l	d0,a2		;l�nge des HunkNamens �berspringen
2$	move.l	(a2)+,d0
	bne.b	1$		;testen ob HunkName vorhanden

	move.l	(a2)+,d0	;HunkAnzahl
	move.l	(a2)+,d0	;Erster Hunk
	move.l	(a2)+,d7	;Letzter Hunk
	addq.l	#1,d7
	sub.l	d0,d7
	lsl.l	#2,d7
	add.l	d7,a2		;Eintr�ge der Hunkl�ngen �berspringen
	rts

Bootblock2:
	add.l	#1024-4,a2
	move.l	#1,CurrHunk-x(a5)
	rts

Zyxel:	add.l	FileSize-x(a5),a2
	subq.l	#4,a2
	move.l	#1,CurrHunk-x(a5)

	move.l	#$80000,ROMaddress-x(a5)
	subq.l	#4,ROMaddress-x(a5)
	st	KICK-x(a5)
	rts

KickStart2:
	; load the baseaddress from location $4 in the ROM
	move.l	(a2),d0
	move.w	#$0000,d0	; clear lower half of address
	move.l	d0,ROMaddress-x(a5)

	add.l	FileSize-x(a5),a2	; kickstart filesize
	subq.l	#4,a2
	move.l	#1,CurrHunk-x(a5)

	st	KICK-x(a5)
;	st	Libby-x(a5)		;muss noch mal gecheckt werden, ob kick wirklich libcode enthaelt !?!

	rts

Unknown_Hunk2
	move.l	FileHD2-x(a5),HunkForm1-x(a5)
	clr.l	FileHD2-x(a5)

	move.l	-(a2),Mnemonic-x(a5)
	move.l	a2,d2
	move.l	Memory-x(a5),d1
	sub.l	d1,d2
	bsr	HexOutPutL	;an dieser stelle war er
	bsr	Space

	move.l	Mnemonic-x(a5),d2
	bsr	HexOutPutL	;diesen kenn ich nicht
	move.l	#Error6T,d1
	moveq	#Error7T-Error6T,d2
	bsr	PrintText

	move.l	HunkForm1-x(a5),FileHD2-x(a5)
	bra	Error4

FileTooSmall:
	move.l	FileHD2-x(a5),HunkForm1-x(a5)
	clr.l	FileHD2-x(a5)

	move.l	#Error9T,d1
	moveq	#ErrorAT-Error9T,d2
	bsr	PrintText

	move.l	HunkForm1-x(a5),FileHD2-x(a5)
	bra	Error4
