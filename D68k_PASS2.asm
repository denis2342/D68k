;
;	D68k.hunk1 von Denis Ahrens 1993
;

ExePASS2:
	move.l	(a2)+,d7
;	andi.l	#$0fffffff,d7
	cmp.w	#$03e7,d7	;Hunk_Unit
	beq	HUnit1
	cmp.w	#$03e8,d7	;Hunk_Name
	beq	HName1
	cmp.w	#$3e9,d7	;Hunk_Code
	beq	HCode1
	cmp.w	#$03ea,d7	;Hunk_Data
	beq	HData1
	cmp.w	#$03eb,d7	;Hunk_BSS
	beq	HBSS1
	cmp.w	#$03ec,d7	;Hunk_Reloc32
	beq	HReloc32_1
	cmp.w	#$03ed,d7	;Hunk_Reloc16
	beq	HReloc16_1
	cmp.w	#$03ee,d7	;Hunk_Reloc8
	beq	HReloc08_1
	cmp.w	#$03ef,d7	;Hunk_Ext
	beq	HExt1
	cmp.w	#$03f0,d7	;Hunk_Symbol
	beq	HSymbol1
	cmp.w	#$03f1,d7	;Hunk_Debug
	beq	HDebug1
	cmp.w	#$03f2,d7	;Hunk_End
	beq	HEnd1
	cmp.w	#$03f3,d7	;Hunk_Header
	beq	HHeader1
	cmp.w	#$03f5,d7	;Hunk_Overlay
	beq	HOverlay1
	cmp.w	#$03f6,d7	;Hunk_Break
	beq	HBreak1
	cmp.w	#$03f7,d7	;Hunk_DRel32
	beq	Hdrel321
	cmp.w	#$03f8,d7	;Hunk_DRel16
	beq	Hdrel161
	cmp.w	#$03f9,d7	;Hunk_DRel08
	beq	Hdrel081
	cmp.w	#$03fa,d7	;Hunk_Lib
	beq	HLib1
	cmp.w	#$03fb,d7	;Hunk_Index
	beq	HIndex1

	tst.b	KICK-x(a5)	;Kickstartkennung
	bne	KickStart1
	clr.b	d7
	cmp.l	#$444f5300,d7	;"DOS",0
	beq	Bootblock1

	bra	Unknown_Hunk1

HCode1:	move.l	(a2)+,d0	;CodeSize in Longwords
	lsl.l	#2,d0

	move.l	d0,CodeSize-x(a5)
	move.l	a2,CodeAnfang-x(a5)
	move.l	#'CODE',HunkForm1-x(a5)

	move.l	-8(a2),d0

	bsr	ChipOrFast
	bsr	PrintHunkName

	tst.b	Argu7-x(a5)
	bne.b	1$
	bsr	Dissa4_1	;Code ausgeben oder nicht ???

1$	move.l	CodeAnfang-x(a5),a2
	move.l	CodeSize-x(a5),d0
	add.l	d0,a2
	rts

HData1:	addq.l	#4,a2

	move.l	HunkMem-x(a5),a1	;Anfangsadresse der Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	28(a1,d0.l),CodeSize-x(a5)

	move.l	a2,CodeAnfang-x(a5)
	move.l	#'DATA',HunkForm1-x(a5)

	move.l	-8(a2),d0

	bsr	ChipOrFast
	bsr	PrintHunkName

	tst.b	Argu8-x(a5)
	bne.b	1$
	bsr	DisData		;DATA ausgeben oder nicht ???

1$	move.l	CodeAnfang-x(a5),a2

	move.l	HunkMem-x(a5),a1	;Anfangsadresse der Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	4(a1,d0.l),d0			;Groesse des Hunks

	add.l	d0,a2
	rts

HBSS1:	move.l	(a2)+,d0
	lsl.l	#2,d0
	move.l	d0,CodeSize-x(a5)
	move.l	a2,CodeAnfang-x(a5)
	move.l	#'BSS ',HunkForm1-x(a5)

	move.l	-8(a2),d0

	bsr	ChipOrFast
	bsr	PrintHunkName

	tst.b	Argu9-x(a5)
	bne.b	1$
	bsr	DisBSS		;BSS ausgeben oder nicht ???

1$	move.l	CodeAnfang-x(a5),a2
	move.l	CodeSize-x(a5),d0
	rts

ChipOrFast:
	move.l	#'    ',HunkForm2-x(a5)
	move.w	#'  ',HunkForm3-x(a5)

	btst	#30,d0
	beq.b	2$
	move.l	#',CHI',HunkForm2-x(a5)
	move.b	#'P',HunkForm3-x(a5)
	bra.b	3$

2$	tst.l	d0		; war btst #31,d0 mit beq.b 3$
	bpl.b	3$
	move.l	#',FAS',HunkForm2-x(a5)
	move.b	#'T',HunkForm3-x(a5)

3$	rts

HOverlay1:
	move.l	(a2),d0
	addq.l	#1,(a2)
	lsl.l	#2,d0
	move.l	d0,CodeSize-x(a5)
	move.l	a2,-(a7)
	bsr	Return
	bsr	Return
	move.l	(a7)+,a2
	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
	rts

HUnit1:
;	move.l	#'UNIT',HunkForm1-x(a5)
;	move.l	#'    ',HunkForm2-x(a5)
;	move.w	#'  ',HunkForm3-x(a5)
;	bsr	PrintHunkName3

;	move.l	-4(a2),d1	;Anzahl der Langwoerter des Textes
;	move.l	a2,a1		;Anfang des Textes

;	move.l	a2,-(SP)
;	bsr	qqq2
;	bsr	Return
;	move.l	(SP)+,a2

	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
	rts

HLib1:	move.l	(a2)+,CodeSize-x(a5)
	move.l	a2,CodeAnfang-x(a5)
	move.l	CodeAnfang-x(a5),a2
	rts

HIndex1:
	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
	move.l	d0,CodeSize-x(a5)
	move.l	a2,CodeAnfang-x(a5)
	move.l	CodeAnfang-x(a5),a2
	move.l	CodeSize-x(a5),d0
	rts

HDebug1:
	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
	move.l	d0,CodeSize-x(a5)
	move.l	a2,CodeAnfang-x(a5)
	move.l	CodeAnfang-x(a5),a2
	move.l	CodeSize-x(a5),d0
	rts

HName1:
;	move.l	#'NAME',HunkForm1-x(a5)
;	move.l	#'    ',HunkForm2-x(a5)
;	move.w	#'  ',HunkForm3-x(a5)
;	bsr	PrintHunkName3

;	move.l	(a2)+,d1	;Anzahl der Langwoerter des Textes
;	move.l	a2,a1		;Anfang des Textes

;	move.l	a2,-(SP)
;	bsr	qqq2
;	bsr	Return
;	move.l	(SP)+,a2

	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2
	rts

HEnd1:
;	bsr	CheckC		;Control Abort by USER
	addq.l	#1,CurrHunk-x(a5)
;	bsr	PrintHEnd
	rts

HBreak1:
	rts

HExt1:	clr.l	CodeSize-x(a5)
	move.l	a2,-(SP)
	bra.b	3$
1$	tst.l	d0		; war btst #31,d0 mit beq.b 2$
	bpl.b	2$

	addq.l	#1,CodeSize-x(a5)
	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a2
	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2

3$	move.l	(a2)+,d0
	bne.b	1$
;	move.l	#'EXTE',HunkForm1-x(a5)
;	move.l	#'RN  ',HunkForm2-x(a5)
;	move.w	#'  ',HunkForm3-x(a5)
;	bsr	PrintHunkName2

	tst.b	Argu5-x(a5)	;HUNKLAB/S
	bne.b	6$
	addq.l	#4,SP
	rts

6$	move.l	(SP)+,a2
	bsr	DisExt
	rts

2$	addq.l	#1,CodeSize-x(a5)
	and.l	#$ffffff,d0	;kleiner als $80
	lsl.l	#2,d0
	add.l	d0,a2
	addq.l	#4,a2
	bra.b	3$

HReloc32_1:
HReloc16_1:
HReloc08_1:
	clr.l	CodeSize-x(a5)	;Anzahl der Einraege wird ausgegeben
	bra.b	2$
1$	add.l	d0,CodeSize-x(a5)
	lsl.l	#2,d0
	add.l	d0,a2
	addq.l	#4,a2		;Location of the Label (Symbol)
2$	move.l	(a2)+,d0	;Laenge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende
	rts

Hdrel321:
Hdrel081:
	bra.b	2$

1$	addq.l	#2,a2		;Location from the Label (Symbol)
	add.l	d0,d0
	add.l	d0,a2
2$	clr.l	d0
	move.w	(a2)+,d0	;Laenge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende

	move.l	a2,d0
	add.l	#2,d0
	bclr	#1,d0
	move.l	d0,a2

	rts

Hdrel161:
	bra.b	2$
1$	lsl.l	#2,d0
	addq.l	#4,d0
	add.l	d0,a2		;Location of the Label (Symbol)
2$	move.l	(a2)+,d0	;Laenge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende
	rts

HSymbol1:
	move.l	a2,-(SP)
	clr.l	CodeSize-x(a5)
	bra.b	2$
1$	addq.l	#1,CodeSize-x(a5)
	lsl.l	#2,d0
	add.l	d0,a2
	addq.l	#4,a2		;Location of the Label (Symbol)
2$	move.l	(a2)+,d0	;Laenge des Labels in LONGWORDS
	bne.b	1$		;Wenn NULL dann Ende

	tst.b	Argu5-x(a5)	;HUNKLAB/S
	bne.b	6$
	addq.l	#4,SP
	rts

6$	move.l	(SP)+,a2
	bsr	DisSymbol
	rts

HHeader1:
	bra.b	2$
1$	lsl.l	#2,d0
	add.l	d0,a2
2$	move.l	(a2)+,d0
	bne.b	1$

	move.l	(a2)+,d0	;HunkAnzahl
	move.l	(a2)+,d0	;Erster Hunk
	move.l	(a2)+,d7	;Letzter Hunk
	addq.l	#1,d7
	sub.l	d0,d7
	lsl.l	#2,d7
	add.l	d7,a2		;Einzelnen Hunknummern ueberspringen
	rts

Bootblock1:
	addq.l	#8,a2

	move.l	#1012,d0		;BootblockSize
	move.l	d0,CodeSize-x(a5)
	move.l	a2,CodeAnfang-x(a5)
	move.l	#'BOOT',HunkForm1-x(a5)
	move.l	#'BLOC',HunkForm2-x(a5)
	move.w	#'K ',HunkForm3-x(a5)

	bsr	PrintHunkName

	tst.b	Argu7-x(a5)	;NC=NOCODE/S
	bne.b	1$

	bsr	Return

	move.l	#Boot1T,d1
	move.l	#Boot2T-Boot1T,d2
	bsr	Print

	tst.b	Argu3-x(a5)	;NOPC
	bne.b	2$
	bsr	TAB
2$	move.l	-12(a2),d2
	bsr	HexOutPutL
	bsr	Return

	move.l	#Boot2T,d1
	move.l	#Boot3T-Boot2T,d2
	bsr	Print

	tst.b	Argu3-x(a5)	;NOPC
	bne.b	3$
	bsr	TAB
3$	move.l	-8(a2),d2
	bsr	HexOutPutL
	bsr	Return

	move.l	#Boot3T,d1
	move.l	#Boot4T-Boot3T,d2
	bsr	Print

	tst.b	Argu3-x(a5)	;NOPC
	bne.b	4$
	bsr	TAB
4$	move.l	-4(a2),d2
	bsr	HexOutPutL
	bsr	Return

	bsr	Dissa4_1	;Code ausgeben oder nicht ???

1$	move.l	CodeAnfang-x(a5),a2
	move.l	CodeSize-x(a5),d0
	add.l	d0,a2
	addq.l	#8,a2
	rts

KickStart1:
	sub.l	#4,a2

	move.l	FileSize-x(a5),d0	;KickstartSize
	move.l	d0,CodeSize-x(a5)
	move.l	a2,CodeAnfang-x(a5)

	tst.b	Argu7-x(a5)	;NC=NOCODE/S
	bne.b	1$

	bsr	Dissa4_1	;Code ausgeben oder nicht ???

1$	move.l	CodeAnfang-x(a5),a2
	move.l	CodeSize-x(a5),d0
	add.l	d0,a2
	rts

Unknown_Hunk1:
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
	move.l	#Error5T,d1		;Internal Error (4)
	moveq	#Error6T-Error5T,d2
	bsr	PrintText
	move.l	HunkForm1-x(a5),FileHD2-x(a5)
	bra	Error4

;**********************************
; Ausgabe des HunkNamens mit Nummer
;**********************************

PrintHunkName:
	movem.l	d0-d1/a2,-(SP)

	lea	Befehl-x(a5),a4
	move.b	#10,(a4)+
	tst.b	Argu3-x(a5)	;NOPC
	bne.b	1$

	move.b	#9,(a4)+
	move.w	#$0909,(a4)+	;ACHTUNG ADRESSE MUSS GERADE SEIN
	move.b	#9,(a4)+

1$	move.b	#9,(a4)+
	move.l	#'SECT',(a4)+
	move.l	#'ION ',(a4)+

	move.b	#'"',(a4)+

	move.l	HunkMem-x(a5),a1	;Anfangsadresse nach Hunktabelle
	move.l	CurrHunk-x(a5),d0
	lsl.l	#TabSize,d0
	move.l	56(a1,d0.l),a1
	bsr	qqq3			;HunkName nach A4 kopieren

	move.b	#'"',(a4)+
	move.b	#',',(a4)+

	lea	HunkForm1-x(a5),a1
	moveq	#10-1,d1
2$	move.b	(a1)+,(a4)+
	dbra	d1,2$

	move.b	#' ',(a4)+
	move.b	#';',(a4)+

	move.l	CurrHunk-x(a5),d2	;Nummer des Hunks ausgeben (in Dez.)
	bsr	DecL
	move.b	Buffer+7-x(a5),(a4)+
	move.b	Buffer+8-x(a5),(a4)+
	move.b	Buffer+9-x(a5),(a4)+

	move.b	#' ',(a4)+

	move.l	CodeSize-x(a5),d2	;und Angabe der Laenge in Dez.
	bsr	DecL
	lea	Buffer+4-x(a5),a1
	moveq	#6-1,d1
3$	move.b	(a1)+,(a4)+
	dbra	d1,3$

	move.b	#10,(a4)+

	move.l	#Befehl,d1
	move.l	a4,d2
	sub.l	d1,d2
	bsr	Print

	movem.l	(SP)+,d0-d1/a2
	rts
