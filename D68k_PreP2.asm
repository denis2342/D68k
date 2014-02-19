;**********************************
;	No Code-Hunk 3
;**********************************

;
;	Ist dafür da um die HunkTabelle anzulegen
;

; 1(00) = *Anfang des Reloc32 Hunks	NULL=KEINER
; 2(04) =  Größe des Hunks selbst
; 3(08) =  Addierter Anfang des Hunks (Alle vorherigen zusammen)
; 4(12) = *Anfang des Extern Hunks	NULL=KEINER
; 5(16) = *Anfang des Symbol Hunks	NULL=KEINER
; 6(20) = *Anfang des Reloc16 Hunks	NULL=KEINER
; 7(24) = *Anfang des Reloc08 Hunks	NULL=KEINER
; 8(28) =  Größe des Hunks aus dem HUNK_HEADER
; 9(32) = *BitMemtabelle
;10(36) = *Anfang des Code, Data oder BSS Hunks im Speicher (pure Daten!)
;11(40) = *Anfang des DRel32 Hunks
;12(44) = *Anfang des DRel16 Hunks
;12(48) = *Anfang des DRel08 Hunks
;13(52) = *Zeiger auf die JumpListEintragstabelle
;14(56) = *Zeiger auf den Hunknamen

PrePASS2:
;NoCode3:
	clr.l	CurrHunk-x(a5)	;Erster Hunk fängt jetzt an
	move.l	Memory-x(a5),a2
1$	bsr.b	NoCode3Main
	move.l	FileSize-x(a5),d0
	add.l	Memory-x(a5),d0
	cmp.l	a2,d0
	bhi.b	1$
	rts

NoCode3Main
	move.l	(a2)+,d7
	cmp.w	#$03e7,d7	;Hunk_Unit
	beq	HUnit3
	cmp.w	#$03e8,d7	;Hunk_Name
	beq	HName3
	cmp.w	#$03e9,d7	;Hunk_Code
	beq	HCode3
	cmp.w	#$03ea,d7	;Hunk_Data
	beq	HData3
	cmp.w	#$03eb,d7	;Hunk_BSS
	beq	HBSS3
	cmp.w	#$03ec,d7	;Hunk_Reloc32
	beq	HReloc32_3
	cmp.w	#$03ed,d7	;Hunk_Reloc16
	beq	HReloc16_3
	cmp.w	#$03ee,d7	;Hunk_Reloc8
	beq	HReloc08_3
	cmp.w	#$03ef,d7	;Hunk_Ext
	beq	HExt3
	cmp.w	#$03f0,d7	;Hunk_Symbol
	beq	HSymbol3
	cmp.w	#$03f1,d7	;Hunk_Debug
	beq	HDebug3
	cmp.w	#$03f2,d7	;Hunk_End
	beq	HEnd3
	cmp.w	#$03f3,d7	;Hunk_Header
	beq	HHeader3
	cmp.w	#$03f5,d7	;Hunk_Overlay
	beq	HOverlay3
	cmp.w	#$03f6,d7	;Hunk_Break
	beq	HBreak3
	cmp.w	#$03f7,d7	;Hunk_drel32
	beq	Hdrel323
	cmp.w	#$03f8,d7	;Hunk_drel16
	beq	Hdrel163
	cmp.w	#$03f9,d7	;Hunk_drel08
	beq	Hdrel083
	cmp.w	#$03fa,d7	;Hunk_Lib
	beq	HLib3
	cmp.w	#$03fb,d7	;Hunk_Index
	beq	HIndex3

	cmp.l	#$11144ef9,d7	;Kickstartkennung
	beq	KickStart3
	clr.b	d7
	cmp.l	#$444f5300,d7	;"DOS",0
	beq	Bootblock3

	bra	Unknown_Hunk3

HBSS3:	move.l	(a2)+,d0	;Größe des BSS-Hunks addieren
	lsl.l	#2,d0		;soviele Langworte ist BSS lang
	move.l	HunkMem-x(a5),a1	;Anfangsadresse der Hunktabelle
	move.l	CurrHunk-x(a5),d7
	lsl.l	#TabSize,d7
	move.l	d0,4(a1,d7.l)			;Größe des Hunks

	tst.l	28(a1,d7.l)	;Wenn kein HEADER-Eintrag da ist, dann sorgen
	bne.b	1$		;wir eben selbst dafuer !!!
	move.l	d0,28(a1,d7.l)
1$
	move.l	a2,36(a1,d7.l)			;Anfang des Hunks
	move.l	HunkAdd-x(a5),8(a1,d7.l)	;Anfang des Hunk-Inhalts als 2. Longword
	addq.l	#4,d0				;wegen HunkEndLabel
	add.l	d0,HunkAdd-x(a5)
	rts

HData3:	move.l	(a2)+,d0
	lsl.l	#2,d0
	move.l	HunkMem-x(a5),a1	;Anfangsadresse der Hunktabelle
	move.l	CurrHunk-x(a5),d7
	lsl.l	#TabSize,d7
	move.l	d0,4(a1,d7.l)			;Größe des Hunks

	move.l	a2,36(a1,d7.l)			;Anfang des Hunks
	add.l	d0,a2

	tst.l	28(a1,d7.l)	;Wenn kein HEADER-Eintrag da ist, dann sorgen
	bne.b	2$		;wir eben selbst dafuer !!!
	move.l	d0,28(a1,d7.l)
2$
	tst.l	28(a1,d7.l)
	beq.b	3$
	move.l	28(a1,d7.l),d0
3$
	move.l	HunkAdd-x(a5),8(a1,d7.l)	;Anfang des Hunk-Inhalts als 2. Longword
	addq.l	#4,d0			;wegen HunkEndLabel
	add.l	d0,HunkAdd-x(a5)	;Größe des DataHunks addieren

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$

	lsr.l	#4,d0		;d0 geteilt durch 16
	addq.l	#1,d0
	move.l	#$10000,d1
	move.l	4,a6
	jsr	_LVOAllocVec(a6)

	move.l	d0,32(a3,d7.l)	;Adresse von BitMem sichern
	beq	ErrorMemory

1$	rts

HCode3:	move.l	(a2)+,d0
	lsl.l	#2,d0
	move.l	HunkMem-x(a5),a3	;Anfangsadresse der Hunktabelle
	move.l	CurrHunk-x(a5),d7
	lsl.l	#TabSize,d7
	move.l	d0,4(a3,d7.l)			;Größe des Hunks

	tst.l	28(a3,d7.l)	;Wenn kein HEADER-Eintrag da ist, dann sorgen
	bne.b	2$		;wir eben selbst dafuer !!!
	move.l	d0,28(a3,d7.l)
2$
	move.l	a2,36(a3,d7.l)			;Anfang des Hunks
	add.l	d0,a2
	move.l	HunkAdd-x(a5),8(a3,d7.l)	;Anfang des Hunk-Inhalts als 2. Longword
	addq.l	#4,d0			;wegen HunkEndLabel
	add.l	d0,HunkAdd-x(a5)	;Größe des CodeHunks addieren

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$

	lsr.l	#4,d0		;d0 geteilt durch 16
	addq.l	#1,d0
	move.l	#$10000,d1
	move.l	4,a6
	jsr	_LVOAllocVec(a6)
	move.l	d0,32(a3,d7.l)	;Adresse von BitMem eintragen
	beq	ErrorMemory

	move.l	#JumpTablePointerListSize,d0
	move.l	#$10000,d1
	jsr	_LVOAllocVec(a6)
	move.l	d0,52(a3,d7.l)	;Zeiger auf JumpTableMemory eintragen
	beq	ErrorMemory

1$	rts

HReloc32_3:
	move.l	HunkMem-x(a5),a1	;Anfangsadresse nach Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	a2,0(a1,d0.l)
	subq.l	#4,0(a1,d0.l)
	bsr	HunkJumpOver
	add.l	d6,Relocs32-x(a5)
	rts

HReloc16_3:
	move.l	HunkMem-x(a5),a1	;Anfangsadresse nach Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	a2,20(a1,d0.l)
	subq.l	#4,20(a1,d0.l)
	bsr	HunkJumpOver
	add.l	d6,Relocs16-x(a5)
	rts

HReloc08_3:
	move.l	HunkMem-x(a5),a1	;Anfangsadresse nach Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	a2,24(a1,d0.l)
	subq.l	#4,24(a1,d0.l)
	bsr	HunkJumpOver
	add.l	d6,Relocs08-x(a5)
	rts

HExt3:	move.l	HunkMem-x(a5),a1	;Anfangsadresse nach Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	a2,12(a1,d0.l)
	subq.l	#4,12(a1,d0.l)

	bra.b	3$
1$	tst.l	d0		; war btst #31,d0 mit beq.b 2$
	bpl.b	2$
	and.l	#$ffffff,d0	;größer als $80
	lsl.l	#2,d0
	add.l	d0,a2
	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
3$	move.l	(a2)+,d0
	bne.b	1$
	rts

2$	and.l	#$ffffff,d0	;kleiner als $80
	lsl.l	#2,d0
	add.l	d0,a2
	addq.l	#4,a2
	move.l	(a2)+,d0
	bne.b	1$
	rts

HName3:
	move.l	HunkMem-x(a5),a1	;Anfangsadresse nach Hunktabelle
	move.l	CurrHunk-x(a5),d1
	lsl.l	#TabSize,d1
	move.l	(a2)+,d0
	move.l	a2,56(a1,d1.l)
	lsl.l	#2,d0
	add.l	d0,a2
	rts

HIndex3:
HUnit3:
HDebug3:
	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
	rts

HLib3:	move.l	(a2)+,d0
	rts

HOverlay3:
	move.l	(a2)+,d0
	lsl.l	#2,d0
	addq.l	#4,a2
	add.l	d0,a2
	rts

HEnd3:	addq.l	#1,CurrHunk-x(a5)
;	rts

HBreak3:
	rts

Hdrel323:
	bra.b	2$

1$	addq.l	#2,a2		;Location from the Label (Symbol)
	add.l	d0,DRelocs32-x(a5)
	add.l	d0,d0
	add.l	d0,a2
2$	clr.l	d0
	move.w	(a2)+,d0	;Länge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende

	move.l	a2,d0
	add.l	#2,d0
	bclr	#1,d0
	move.l	d0,a2

	rts

Hdrel163:
	move.l	HunkMem-x(a5),a1	;Anfangsadresse der Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	a2,44(a1,d0.l)
	subq.l	#4,44(a1,d0.l)
	bsr	HunkJumpOver
	add.l	d7,DRelocs16-x(a5)
	rts

Hdrel083:
	bra.b	2$

1$	addq.l	#2,a2		;Location from the Label (Symbol)
	add.l	d0,DRelocs08-x(a5)
	add.l	d0,d0
	add.l	d0,a2
2$	clr.l	d0
	move.w	(a2)+,d0	;Länge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende

	move.l	a2,d0
	add.l	#2,d0
	bclr	#1,d0
	move.l	d0,a2

	rts

HSymbol3:
	move.l	HunkMem-x(a5),a1	;Anfangsadresse der Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	a2,16(a1,d0.l)
	subq.l	#4,16(a1,d0.l)
	bsr	HunkJumpOver
	add.l	d7,Symbole-x(a5)
	rts

HunkJumpOver:
	moveq	#0,d7
	moveq	#0,d6
	bra.b	2$
1$	addq.l	#1,d7
	addq.l	#4,a2		;Location from the Label (Symbol)
	add.l	d0,d6
	lsl.l	#2,d0
	add.l	d0,a2
2$	move.l	(a2)+,d0	;Länge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende
	rts

HHeader3:
	bra.b	2$

1$	lsl.l	#2,d0		;wenn HunkName vorhanden, dann
	add.l	d0,a2		;länge des HunkNamens überspringen
2$	move.l	(a2)+,d0
	bne.b	1$		;testen ob HunkName vorhanden

	move.l	(a2)+,d0	;HunkAnzahl
	move.l	(a2)+,d0	;Erster Hunk
	move.l	(a2)+,d7	;Letzter Hunk

	move.l	HunkMem-x(a5),a1	;Anfangsadresse der Hunktabelle

3$	move.l	d0,d6		;einzelnen Hunkgroessen aus dem HUNKHEADER
	lsl.l	#TabSize,d6	;in die Tabelle sichern.
	move.l	(a2)+,d1
	lsl.l	#2,d1
	move.l	d1,28(a1,d6.l)

	addq.l	#1,d0

	cmp.l	d7,d0
	bls.b	3$

	rts

KickStart3:
	subq.l	#4,a2
	move.l	#$80000,d0
	bra	rawCode3

Bootblock3:
	addq.l	#8,a2		;CheckSumme und Rootblock überspringen
	move.l	#1012,d0

rawCode3:
	move.l	HunkMem-x(a5),a3	;Anfangsadresse der Hunktabelle
	move.l	CurrHunk-x(a5),d7
	lsl.l	#TabSize,d7
	move.l	d0,4(a3,d7.l)		;Größe des Bootblocks
	move.l	d0,28(a3,d7.l)		;Größe des Bootblocks
	move.l	HunkAdd-x(a5),8(a3,d7.l)	;Anfang des Hunk-Inhalts als 2. Longword

	addq.l	#4,d0			;wegen HunkEndLabel
	move.l	d0,HunkAdd-x(a5)
	move.l	a2,36(a3,d7.l)			;Anfang des Hunks

	add.l	d0,a2

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$

	lsr.l	#4,d0		;d0 geteilt durch 16
	addq.l	#1,d0
	move.l	#$10000,d1
	move.l	4,a6
	jsr	_LVOAllocVec(a6)
	move.l	d0,32(a3,d7.l)	;Adresse von BitMem sichern
	beq	ErrorMemory

	move.l	#JumpTablePointerListSize,d0
	move.l	#$10000,d1
	jsr	_LVOAllocVec(a6)
	move.l	d0,52(a3,d7.l)	;Zeiger auf JumpTableMemory eintragen
	beq	ErrorMemory

1$	move.l	#1,CurrHunk-x(a5)
	rts

Unknown_Hunk3:
	move.l	FileHD2-x(a5),HunkForm1-x(a5)
	clr.l	FileHD2-x(a5)		;FileHD retten (wegen CLI-Text)

	move.l	-(a2),Mnemonic-x(a5)
	move.l	a2,d2
	move.l	Memory-x(a5),d1
	sub.l	d1,d2
	bsr	HexOutPutL		;an dieser stelle war er

	bsr	Space

	move.l	Mnemonic-x(a5),d2
	bsr	HexOutPutL		;diesen Hunk kenne ich nicht

	move.l	#Error7T,d1		;Internal Error (2)
	moveq	#Error8T-Error7T,d2
	bsr	PrintText

	move.l	HunkForm1-x(a5),FileHD2-x(a5)	;FileHD wiederholen
	bra	Error4
