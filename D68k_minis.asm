;
;	D68k.minis von Denis Ahrens 1990-1994
;

;**********************************
;	Ausgabe des PC + TAB
;**********************************

PLine:	movem.l	d0-d3/a0-a1,-(SP)

	move.l	#$7fffffff,NextLabel-x(a5)

	bsr	SymbolLabel

	move.l	PCounter-x(a5),d2
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0
	add.l	8(a0,d6.l),d2		;theo. Labeladresse

	move.l	LabelMem-x(a5),a1	;LabelTab. faengt hier an
	move.l	LabelPointer-x(a5),d3
	bra.b	PCheck

PChecke	addq.l	#4,d3
	clr.b	DataRem-x(a5)
PCheck:	cmp.l	0(a1,d3.l),d2		;gibt es ein Label?
	beq.b	PLabel
	bcc.b	PChecke

;NoLabel
		move.l	8(a0,d6.l),d1	;Ende des aktuellen Hunks in D1
		add.l	28(a0,d6.l),d1	;sichern

		cmp.l	0(a1,d3.l),d1	;ist das Ende naeher als das naechste Label?
		bcs.b	1$		;wenn ja dann springen

		move.l	0(a1,d3.l),d1	;Abstand bis zum naechsten Label
1$		sub.l	d2,d1		;abspeichern
		cmp.l	NextLabel-x(a5),d1
		bge.b	Pline2
		move.l	d1,NextLabel-x(a5)

Pline2:	move.l	d3,LabelPointer-x(a5)
	tst.b	Argu3-x(a5)		;NOPC/S
	bne.b	1$

	move.l	PCounter-x(a5),d2	;PC ausgeben

	tst.b	KICK-x(a5)	;Fuer Kickanfang ausgleichen?
	beq	2$
	add.l	ROMaddress-x(a5),d2

2$	bsr	HexL
	lea	HexBufferL+2-x(a5),a0
	lea	Befehl2-x(a5),a1
	move.l	(a0)+,(a1)+
	move.w	(a0),(a1)+
	move.b	#9,(a1)

	tst.b	ArguC-x(a5)		;NEXTLABEL/S
	beq.b	1$

	move.l	NextLabel-x(a5),d2
	bsr	HexOutPutW

1$	movem.l	(SP)+,d0-d3/a0-a1
	rts

PLabel:		move.l	8(a0,d6.l),d1	;Ende des aktuellen Hunks in D1
		add.l	28(a0,d6.l),d1	;sichern

		cmp.l	4(a1,d3.l),d1	;ist das Ende naeher als das naechste Label?
		bcs.b	1$		;wenn ja dann springen

		move.l	4(a1,d3.l),d1	;Abstand bis zum naechsten Label
1$		sub.l	d2,d1		;abspeichern
		cmp.l	NextLabel-x(a5),d1
		bge.b	3$
		move.l	d1,NextLabel-x(a5)

3$	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	2$
	bsr	TAB4
2$	move.l	d3,d2		;LabelPointer,d2
	lsr.l	#2,d2
	addq.l	#1,d2
	bsr	HexL
	move.b	#'L',HexBufferL+2-x(a5)
	move.b	#':',Hexplus-x(a5)
	move.l	#HexBufferL+2,d1
	moveq	#8,d2
	move.b	#10,Hexplus2-x(a5)
	bsr	Print
	addq.l	#4,d3		;LabelPointer
	clr.b	DataRem-x(a5)
	bra	Pline2

SymbolLabel:
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0	;HunkTabelle laden

	tst.l	16(a0,d6.l)	;Auf SymbolHunk testen
	beq.b	1$

	move.l	16(a0,d6.l),a0		;SymbolHunkAnfang in A0
	cmp.l	#$3f0,(a0)+	;Testen ob wirklich Symbol-Hunk
	bne.b	1$
	
	move.l	PCounter-x(a5),d2
	move.l	NextLabel-x(a5),d4

	bra.b	2$

3$	lsl.l	#2,d0		;anzahl der Langwoerter
	add.l	d0,a0

		move.l	(a0),d1		;NextLabel berechnen
		sub.l	d2,d1
		ble.b	4$
		cmp.l	d4,d1
		bge.b	4$
		move.l	d1,d4		;und wenn noetig sichern

4$	cmp.l	(a0)+,d2	;testen ob Adresse uebereinstimmt
	beq.b	5$
2$	move.l	a0,d3		;retten (nach d3) fuer PrintSymbolLabel
	move.l	(a0)+,d0	;testen ob Label folgt
	bne.b	3$

	move.l	d4,NextLabel-x(a5)
1$	rts

5$	movem.l	d2/d4/a0,-(SP)		;PrintSymbolLabel
	move.l	d3,a1

	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	6$
	movem.l	d0/a1,-(SP)
	bsr	TAB4
	movem.l	(SP)+,d0/a1

6$	move.l	(a1)+,d1
	bsr	qqq2

	move.l	#ColonReturn,d1
	moveq	#2,d2
	bsr	Print

	movem.l	(SP)+,d2/d4/a0
	clr.b	DataRem-x(a5)
	bra.b	2$

;**********************************
;	erst die lables sortieren
;	dann doppelte eintraege entfernen
;**********************************

SortLabel:
	bsr.b	QuickLabel

	move.l	LabelMem-x(a5),a0	;Anfang der LabelTabelle
	move.l	a0,d6

	move.l	LabelPointer-x(a5),d7
	beq.b	2$

	add.l	a0,d7

	move.l	(a0)+,d0
	move.l	a0,a1

1$	move.l	(a0)+,d1

	cmp.l	a0,d7
	bcs.b	2$

	cmp.l	d0,d1
	beq.b	1$

	move.l	d1,(a1)+
	move.l  d1,d0
	bra.b	1$

2$	move.l	a1,d7
	sub.l	d6,d7
	move.l	d7,LabelPointer-x(a5)

	move.l	#$7fffffff,d0
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)+
	move.l	d0,(a1)
	rts

QuickLabel:
	move.l	LabelMem-x(a5),a1
	move.l	LabelPointer-x(a5),d7
	beq	QuickEnd

QuickSort:
	subq.l	#4,d7	;(1 Langwort)
	beq	QuickEnd

	move.l	a1,a2
	lea	0(a1,d7.l),a3
	move.l	a3,a0

QuickStart:
	move.l	a0,d2
	add.l	a1,d2
	lsr.l	#1,d2
	andi.b	#-4,d2	; durch vier teilbar machen
	move.l	d2,a4
	move.l	(a4),d2		;pivot festlegen

1$	cmp.l	(a2)+,d2	; wert groesser als pivot finden
	bhi.b	1$

	subq.l	#4,a2
	addq.l	#4,a3

2$	cmp.l	-(a3),d2	; wert kleiner als pivot finden
	blo.b	2$

	cmp.l	a3,a2
	bhi.b	3$

	move.l	(a3),d5		; beide werte tauschen
	move.l	(a2),(a3)
	move.l	d5,(a2)+
	subq.l	#4,a3

	cmp.l	a3,a2		; ueberkreuzen sich die ranges schon?
	blo.b	1$

3$	cmp.l	a3,a1		; unterer range schon zu klein zum teilen?
	bhs.b	4$

	move.l	a0,-(SP)
	move.l	a3,a0
	move.l	a1,a2
	bsr.b	QuickStart
	move.l	(SP)+,a0

4$	cmp.l	a0,a2		; oberer range schon zu klein zum teilen?
	bhs.b	QuickEnd

	move.l	a1,-(SP)
	move.l	a2,a1
	move.l	a0,a3
	bsr.b	QuickStart
	move.l	(SP)+,a1
QuickEnd:
	rts

;**********************************
;	Filtert Steuerzeichen aus einem Text
;**********************************

TextSort:
	lea	Mnemonic-x(a5),a0	;Filtert aus Texten Steuerzeichen
	moveq	#3,d7			;raus (leider auch Umlaute)
1$	move.b	(a0)+,d0
	cmp.b	#31,d0
	bls.b	3$
	cmp.b	#126,d0
	bls.b	2$
3$	move.b	#' ',-1(a0)	;Steuerzeichen werden gegen ein
2$	dbra	d7,1$		;Space eingetauscht
	rts

;**********************************
;	Labelberechnung
;**********************************

; Veraendert werden:

; a0
; a1
; a2
; a3
; d2
; d3
; d6
; d7

; uebergeben werden
;
; d2,d0,a3 ???

LabelCalcRelocX32:
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	tst.l	0(a0,d6.l)	;Wenn kein Reloc32 dann auch nicht testen
	beq	LabelCalcS
	move.l	0(a0,d6.l),a1
	cmp.l	#$03ec,(a1)+	;Reloc32-kennung testen und ueberspringen
	bne	LabelCalcS

	move.l	PCounter-x(a5),a3	;Adresse
	add.l	RelocXAdress-x(a5),a3

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	LabelCalc2
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,a3	;Eintraege '(a2)' mit richtiger Adresse 'a3'
	dbls	d7,3$
	bne.b	2$

	move.l	Pointer-x(a5),a3	;Inhalt
	add.l	RelocXAdress-x(a5),a3
	move.l	(a3),d2		; L wegen Reloc32

	bra	LabelCalc3

LabelCalcRelocX16:
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	move.l	20(a0,d6.l),d7	;Wenn kein Reloc16 dann auch nicht testen
	beq	LabelCalcS
	move.l	d7,a1
	cmp.l	#$03ed,(a1)+	;Reloc16-kennung testen und ueberspringen
	bne	LabelCalcS

	move.l	PCounter-x(a5),a3
	add.l	RelocXAdress-x(a5),a3

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	LabelCalc2
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,a3	;Eintraege '(a2)' mit richtiger Adresse 'a3'
	dbls	d7,3$
	bne.b	2$

	move.l	Pointer-x(a5),a3
	add.l	RelocXAdress-x(a5),a3
	moveq	#0,d2
	move.w	(a3),d2		; W wegen Reloc16
	ext.l	d2

	bra	LabelCalc3

LabelCalcRelocX08:
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	move.l	24(a0,d6.l),d7	;Wenn kein Reloc08 dann auch nicht testen
	beq	LabelCalcS
	move.l	d7,a1
	cmp.l	#$03ee,(a1)+	;Reloc08-kennung testen und ueberspringen
	bne	LabelCalcS

	move.l	PCounter-x(a5),a3
	add.l	RelocXAdress-x(a5),a3

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	LabelCalc2
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,a3	;Eintraege '(a2)' mit richtiger Adresse 'a3'
	dbls	d7,3$
	bne.b	2$

	move.l	Pointer-x(a5),a3
	add.l	RelocXAdress-x(a5),a3
	moveq	#0,d2
	move.b	(a3),d2		; B wegen Reloc08
	ext.w	d2
	ext.l	d2

;	bra	LabelCalc3

; LabelCalc3 ist nur fuer PASS1 !!!!

LabelCalc3:
	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$
	tst.b	Springer-x(a5)	;ist es Sprungbefehl gewesen ??
	beq.b	1$

	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0
	cmp.l	28(a0,d6.l),d2	;wenn das Label groesser als der Hunk ist
	bhi.b	1$		;dann KEIN Label

	move.l	d2,d5
	add.l	8(a0,d6.l),d2	;Pos. des Hunks addieren

	cmp.l	28(a0,d6.l),d5	;wenn der Sprung groesser ODER gleich als der Hunk ist
	bge.b	1$

	bsr	SprungMemFueller

1$	rts

; LabelCalc2 ist nur fuer PASS1 !!!!!

LabelCalc2:
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0
LabelCalcS:
	cmp.l	28(a0,d6.l),d2	;wenn das Label groesser als der Hunk ist
	bhi.b	1$		;dann KEIN Label

	move.l	d2,d5
	add.l	8(a0,d6.l),d2	;Pos. des Hunks addieren (File-relativ)

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	3$
	tst.b	Springer-x(a5)	;ist es ein Sprungbefehl gewesen ???
	beq.b	3$

	cmp.l	28(a0,d6.l),d5	;wenn der Sprung groesser ODER gleich als der Hunk ist
	bge.b	3$

	movem.l	d2/d5,-(SP)
	bsr	SprungMemFueller	;Label in der Sprungmemtabelle eintragen !!
	movem.l	(SP)+,d2/d5
3$
	move.l	16(a0,d6.l),d1	;wenn kein Symbol_Hunk dann kein Symbol
	beq	2$
	move.l	d1,a0		;SymbolHunkAnfang in A0
	cmp.l	#$3f0,(a0)+	;Testen ob wirklich Symbol-Hunk
	bne.b	2$
	
	bra.b	5$

6$	lsl.l	#2,d1		;Anzahl der Langwoerter
	add.l	d1,a0
	cmp.l	(a0)+,d5	;testen ob Adresse uebereinstimmt
	beq.b	1$		;Symbol, also kein Label
5$	move.l	(a0)+,d1	;testen ob Label folgt
	bne.b	6$

2$	bsr	AddLabelPointer

1$	rts

AddLabelPointer:
	movem.l	a0/d2,-(SP)

	move.l	LabelMem-x(a5),a0
	add.l	LabelPointer-x(a5),a0
	move.l	d2,(a0)
	addq.l	#4,LabelPointer-x(a5)

	move.l	#LabelMemSize-8,d2
	cmp.l	LabelPointer-x(a5),d2
	bcs	LabelMemSizeError

	movem.l	(SP)+,a0/d2
	rts

; Fuer die TRACE-Methode !!!

SprungMemFueller:

; in D2 muss die ???
; in D5 muss die Sprungadresse uebergeben werden
; in D6 muss die Hunknummer uebergeben werden

	btst	#0,d2	;Adresse auf gerade testen
	bne.b	2$

	move.l	HunkMem-x(a5),a0
	move.l	32(a0,d6.l),a2		;BitMem des Hunks von D6

	lsr.l	#1,d5		;Testen ob Adresse schon im BitFeld
	move.w	d5,d7		;gesetzt war, wenn das der Fall ist, dann
	lsr.l	#3,d5		;brauch die Adresse nicht im SprungMem eingetragen
	btst	d7,0(a2,d5.w)	;werden.
	bne.b	2$

	move.l	SprungMem-x(a5),a2
	move.l	a2,a3
	move.l	SprungPointer-x(a5),d7
	beq.b	1$
	add.l	d7,a3
	lsr.l	#2,d7
	subq.w	#1,d7

1$	cmp.l	(a2)+,d2	;Testen ob Adresse in Liste schon vorhanden
	dbeq	d7,1$		;ist. Wenn ja dann ist der Eintrag unnoetig
	beq.b	2$

;	movem.l	d2/a3,-(SP)

;	bsr	HexOutPutL
;	bsr	Space
;	move.l	a3,d2
;	bsr	HexOutPutL
;	bsr	Return

;	movem.l	(SP)+,d2/a3

	move.l	d2,(a3)		;Sprungpointer zur Liste addieren
	addq.l	#4,SprungPointer-x(a5)

2$	rts

;**********************************
;	Label in (a4)+ ausgeben mit Reloc32
;**********************************

LabelPrint32:
	move.b	#4,ExternSize-x(a5)
	bsr	PrintExternXX
	tst.b	LabelYes-x(a5)
	bne.b	4$

	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	move.l	0(a0,d6.l),d7	;Wenn kein Reloc32 dann auch nicht testen
	beq	4$
	move.l	d7,a1
	cmp.l	#$03ec,(a1)+	;Reloc32-kennung testen und ueberspringen
	bne	4$

	move.l	PCounter-x(a5),d0	;richtige Adresse
	add.l	ToAdd-x(a5),d0		;fuer andere sachen
	addq.l	#2,d0			;fuer den Mnemonic

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	4$
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,d0	;Eintraege '(a2)' mit richtiger Adresse 'd0'
	dbls	d7,3$
	bne.b	2$

	move.l	ToAdd-x(a5),d0		;fuer andere sachen
	asr.l	#1,d0
	lea	Relocmarke-x(a5),a3
	move.b	#'_',1(a3,d0.l)

	bra	PrintRelocXLabel

4$	rts

LabelPrint16:
	move.b	#2,ExternSize-x(a5)
	bsr	PrintExternXX
	tst.b	LabelYes-x(a5)
	bne.b	4$

	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	move.l	20(a0,d6.l),d0	;Wenn kein Reloc16 dann auch nicht testen
	beq	4$
	move.l	d0,a1
	cmp.l	#$03ed,(a1)+	;Reloc16-kennung testen und ueberspringen
	bne	4$

	move.l	PCounter-x(a5),d0	;richtige Adresse
	add.l	ToAdd-x(a5),d0		;fuer andere sachen
	addq.l	#2,d0			;fuer den Mnemonic

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	4$
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,d0	;Eintraege '(a2)' mit richtiger Adresse 'd0'
	dbls	d7,3$
	bne.b	2$

	bra	PrintRelocXLabel

4$	rts

LabelPrint08:
	move.b	#1,ExternSize-x(a5)
	bsr	PrintExternXX
	tst.b	LabelYes-x(a5)
	bne.b	4$

	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	move.l	24(a0,d6.l),d0	;Wenn kein Reloc08 dann auch nicht testen
	beq	4$
	move.l	d0,a1
	cmp.l	#$03ee,(a1)+	;Reloc08-kennung testen und ueberspringen
	bne	4$

	move.l	PCounter-x(a5),d0	;richtige Adresse
	add.l	ToAdd-x(a5),d0		;fuer andere sachen
	addq.l	#2,d0			;fuer den Mnemonic

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	4$
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,d0	;Eintraege '(a1)' mit richtiger Adresse 'd0'
	dbls	d7,3$
	bne.b	2$

	bra	PrintRelocXLabel

4$	rts

LabelPrintReloc32:
	bsr	PrintExternXX
	tst.b	LabelYes-x(a5)
	beq.b	1$
	rts

1$	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	tst.l	0(a0,d6.l)	;Wenn kein Reloc32 dann auch nicht testen
	beq	PrintLabelNormal

	move.l	0(a0,d6.l),a1
	cmp.l	#$03ec,(a1)+	;Reloc32-kennung testen und ueberspringen
	bne	PrintLabelNormal

	move.l	PCounter-x(a5),a3
	add.l	RelocXAdress-x(a5),a3

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	PrintLabelNormal
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,a3	;Eintraege '(a2)' mit richtiger Adresse 'a3'
	dbls	d7,3$
	bne.b	2$

	move.l	RelocXAdress-x(a5),d2
	asr.l	#1,d2
	lea	Relocmarke-x(a5),a3
	move.b	#'_',0(a3,d2.l)

	move.l	Pointer-x(a5),a3
	add.l	RelocXAdress-x(a5),a3
	move.l	(a3),d2		; L wegen Reloc32

	bra	PrintRelocXLabel

LabelPrintReloc16:
	bsr	PrintExternXX
	tst.b	LabelYes-x(a5)
	beq.b	1$
	rts

1$	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	tst.l	20(a0,d6.l)	;Wenn kein Reloc16 dann auch nicht testen
	beq	PrintLabelNormal

	move.l	20(a0,d6.l),a1
	cmp.l	#$03ed,(a1)+	;Reloc16-kennung testen und ueberspringen
	bne	PrintLabelNormal

	move.l	PCounter-x(a5),a3
	add.l	RelocXAdress-x(a5),a3

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	PrintLabelNormal
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,a3	;Eintraege '(a2)' mit richtiger Adresse 'a3'
	dbls	d7,3$
	bne.b	2$

	move.l	Pointer-x(a5),a3
	add.l	RelocXAdress-x(a5),a3
	move.w	(a3),d2		; W wegen Reloc16
	ext.l	d2

	bra	PrintRelocXLabel

LabelPrintReloc08:
	bsr	PrintExternXX
	tst.b	LabelYes-x(a5)
	beq.b	1$
	rts

1$	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	tst.l	24(a0,d6.l)	;Wenn kein Reloc08 dann auch nicht testen
	beq	PrintLabelNormal

	move.l	24(a0,d6.l),a1
	cmp.l	#$03ee,(a1)+	;Reloc08-kennung testen und ueberspringen
	bne	PrintLabelNormal

	move.l	PCounter-x(a5),a3
	add.l	RelocXAdress-x(a5),a3

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	PrintLabelNormal
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,a3	;Eintraege '(a2)' mit richtiger Adresse 'a3'
	dbls	d7,3$
	bne.b	2$

	move.l	Pointer-x(a5),a3
	add.l	RelocXAdress-x(a5),a3
	move.b	(a3),d2		; B wegen Reloc08
	ext.w	d2
	ext.l	d2

	bra	PrintRelocXLabel

PrintLabelNormal
	move.l	CurrHunk-x(a5),d6
PrintRelocXLabel:
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0

	bsr	LabelPrintSymbol	;wenn Symbol dann kommt er nicht wieder
	add.l	8(a0,d6.l),d2		;LabelAdresse

	move.l	LabelMem-x(a5),a0
	move.l	LabelMin-x(a5),d0
	beq	1$

	move.l	d2,d1
	bsr	BinSearch		;MUCH MORE TURBO !!!
	tst.l	d0
	beq	1$

	addq.l	#4,d0
	move.l	d0,d2
	sub.l	LabelMem-x(a5),d2
	lsr.l	#2,d2
	bsr	HexL
	move.b	#'L',(a4)+
	lea	HexBufferL+3-x(a5),a0
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0),(a4)+
	st	LabelYes-x(a5)
1$	rts

LabelPrintSymbol:			;in D6 wird der Hunk uebergeben
	tst.l	16(a0,d6.l)	;wenn kein Symbol-Hunk dann auch nicht testen
	beq.b	1$

	move.l	16(a0,d6.l),a2		;SymbolHunkAnfang in A0

	move.l	a2,d1
	btst	#0,d1
	beq.b	4$
	rts

4$	cmp.l	#$3f0,(a2)+	;Testen ob wirklich Symbol-Hunk
	bne.b	1$

	bra.b	2$

3$	lsl.l	#2,d1		;Anzahl der Langwoerter
	add.l	d1,a2
	cmp.l	(a2)+,d2	;testen ob Adresse uebereinstimmt
	beq.b	PrintSymbolLabela4
2$	move.l	a2,a1
	move.l	(a2)+,d1	;testen ob Symbol folgt
	bne.b	3$

1$	rts

PrintSymbolLabela4:
	move.l	(a1)+,d1		;Anzahl der Langwoerter
	lsl.l	#2,d1
	subq.l	#1,d1

1$	move.b	(a1)+,(a4)+		;Anfang des Symbols
	dbeq	d1,1$
	bne.b	2$

	subq.l	#1,a4

2$	addq.l	#4,SP			;vier fuer RTS
	move.b	#4,ExternSize-x(a5)	;vier wegen reloc32
	st	LabelYes-x(a5)
	rts

;**********************************
;	testen ob ExternXX UND AUSGEBEN
;**********************************

PrintExternXX:
	movem.l	d0/d6/a0,-(SP)

	move.l	CurrHunk-x(a5),d6	;aktueller Hunk
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0

	tst.l	12(a0,d6.l)		;auf inhalt testen
	beq	NoExternXX		;wenn null dann ende

	move.l	12(a0,d6.l),a0		;inhalt holen
	cmp.l	#$03ef,(a0)+		;auf extern testen
	bne.b	NoExternXX

	move.l	PCounter-x(a5),d6	;zu suchende Adresse einladen
	add.l	ToAdd-x(a5),d6
	addq.l	#2,d6

	bra.b	ExXX_3

ExXX_1	tst.l	d0		;testen ob > oder < als $80
	bpl.b	ExXX_2

	rol.l	#8,d0

	move.b	#4,ExternSize-x(a5)
	cmp.b	#$81,d0
	beq.b	YesExternXX	;mit Extern_Ref32 vergleichen

;	move.b	#4,ExternSize-x(a5)
	cmp.b	#$82,d0
	beq.b	YesExternXX	;mit Extern_common (32) vergleichen

;	move.b	#4,ExternSize-x(a5)
	cmp.b	#$85,d0
	beq.b	YesExternXX	;mit Extern_Dext32 vergleichen

	move.b	#2,ExternSize-x(a5)
	cmp.b	#$83,d0
	beq.b	YesExternXX	;mit Extern_Ref16 vergleichen

;	move.b	#2,ExternSize-x(a5)
	cmp.b	#$86,d0
	beq.b	YesExternXX	;mit Extern_Dext16 vergleichen

	move.b	#1,ExternSize-x(a5)
	cmp.b	#$84,d0
	beq.b	YesExternXX	;mit Extern_Ref08 vergleichen

;	move.b	#1,ExternSize-x(a5)
	cmp.b	#$87,d0
	beq.b	YesExternXX	;mit Extern_Dext08 vergleichen

	ror.l	#8,d0

	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0

ExXX_3	move.l	a0,a1
	move.l	(a0)+,d0
	bne.b	ExXX_1
NoExternXX
	clr.b	LabelYes-x(a5)
	movem.l	(SP)+,d0/d6/a0
	rts

ExXX_2	and.l	#$ffffff,d0	;kleiner als $80
	lsl.l	#2,d0
	add.l	d0,a0
	addq.l	#4,a0
	bra.b	ExXX_3

YesExternXX:
	ror.l	#8,d0
	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0		;Anzahl der Langwoerter

	move.l	(a0)+,d0	;Anzahl der Adressen
	beq.b	ExXX_3
	subq.w	#1,d0

1$	cmp.l	(a0)+,d6	;Adressen vergleichen
	dbeq	d0,1$
	bne.b	ExXX_3

3$	st	LabelYes-x(a5)
	bsr	FoundExternxx
	movem.l	(SP)+,d0/d6/a0
	rts

;**********************************
;	testen ob Extern32 und ausgeben sonst nichts
;**********************************

PrintExtern32:
	move.l	CurrHunk-x(a5),d6	;aktueller Hunk
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0

	tst.l	12(a0,d6.l)		;auf inhalt testen
	beq.b	NoExtern32		;wenn null dann ende

	move.l	12(a0,d6.l),a0		;inhalt holen
	cmp.l	#$03ef,(a0)+		;auf extern testen
	bne.b	NoExtern32

	move.l	PCounter-x(a5),d6	;zu suchende Adresse einladen
	add.l	ToAdd-x(a5),d6
	addq.l	#2,d6

	bra.b	Ex32_3

Ex32_1	tst.l	d0		;testen ob > oder < als $80
	bpl.b	Ex32_2

	rol.l	#8,d0
	cmp.b	#$81,d0		;mit Extern_Ref32 vergleichen
	beq.b	YesExtern32
	cmp.b	#$85,d0		;mit Extern_Dext32 vergleichen
	beq.b	YesExtern32
	ror.l	#8,d0

	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0

Ex32_3	move.l	a0,a1
	move.l	(a0)+,d0
	bne.b	Ex32_1
NoExtern32
	tst.b	Vorzeichen-x(a5)	;mit vorzeichen ?
	bne	HexLs	;AUTO RTS
	bra	HexLDi	;AUTO RTS

Ex32_2	and.l	#$ffffff,d0	;kleiner als $80
	lsl.l	#2,d0
	add.l	d0,a0
	addq.l	#4,a0
	bra.b	Ex32_3

YesExtern32:
	ror.l	#8,d0
	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0		;Anzahl der Langwoerter

	move.l	(a0)+,d0	;Anzahl der Adressen
	beq.b	Ex32_3
	subq.w	#1,d0

1$	cmp.l	(a0)+,d6	;Adressen vergleichen
	dbeq	d0,1$

	beq	FoundExternxx
	bra	Ex32_3

;**********************************
;	testen ob Extern16 und ausgeben sonst normal HexWs
;**********************************

PrintExtern16:
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0

	tst.l	12(a0,d6.l)		;testen ob Extern-Eintrag
	beq.b	NoExtern16

	move.l	12(a0,d6.l),a0
	cmp.l	#$03ef,(a0)+	;testen ob Eintrag = ExternHunk
	bne.b	NoExtern16

	move.l	PCounter-x(a5),d6
	add.l	ToAdd-x(a5),d6
	addq.l	#2,d6			;in D6 jetzt vergleichsAdresse

	bra.b	Ex16_3

Ex16_1	tst.l	d0		;testen ob > oder < als $80
	bpl.b	Ex16_2

	rol.l	#8,d0
	cmp.b	#$83,d0		;mit Extern_Ref16 vergleichen
	beq.b	YesExtern16
	cmp.b	#$86,d0		;mit Extern_Dext16 vergleichen
	beq.b	YesExtern16
	ror.l	#8,d0

	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0

Ex16_3	move.l	a0,a1
	move.l	(a0)+,d0
	bne.b	Ex16_1
NoExtern16
	tst.b	Vorzeichen-x(a5)	;mit vorzeichen ?
	bne	HexWs	;AUTO RTS
	bra	HexWDi	;AUTO RTS

Ex16_2	and.l	#$ffffff,d0	;kleiner als $80
	lsl.l	#2,d0
	add.l	d0,a0
	addq.l	#4,a0
	bra.b	Ex16_3

YesExtern16:
	ror.l	#8,d0
	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0		;Anzahl der Langwoerter

	move.l	(a0)+,d0	;Anzahl der Adressen
	beq.b	Ex16_3
	subq.w	#1,d0

1$	cmp.l	(a0)+,d6	;Adressen vergleichen
	dbeq	d0,1$

	beq	FoundExternxx
	bra	Ex16_3

;**********************************
;	testen ob Extern08 und ausgeben sonst normal HexBs
;**********************************

PrintExtern08:
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0

	tst.l	12(a0,d6.l)
	beq.b	NoExtern08

	move.l	12(a0,d6.l),a0
	cmp.l	#$03ef,(a0)+
	bne.b	NoExtern08

	move.l	PCounter-x(a5),d6
	add.l	ToAdd-x(a5),d6
	addq.l	#3,d6			;in D6 jetzt vergleichsAdresse
					;3 anstatt 2 wegen ungerade
	bra.b	Ex08_3

Ex08_1	tst.l	d0		;testen ob > oder < als $80
	bpl.b	Ex08_2

	rol.l	#8,d0
	cmp.b	#$84,d0		;mit Extern_Ref08 vergleichen
	beq.b	YesExtern08
	cmp.b	#$87,d0		;mit Extern_Dext08 vergleichen
	beq.b	YesExtern16
	ror.l	#8,d0

	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0

Ex08_3	move.l	a0,a1
	move.l	(a0)+,d0
	bne.b	Ex08_1
NoExtern08
	tst.b	Vorzeichen-x(a5)	;mit vorzeichen ?
	bne	HexBs	;AUTO RTS
	bra	HexBDi	;AUTO RTS

Ex08_2	and.l	#$ffffff,d0	;kleiner als $80
	lsl.l	#2,d0
	add.l	d0,a0
	addq.l	#4,a0
	bra.b	Ex08_3

YesExtern08:
	ror.l	#8,d0
	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0		;Anzahl der Langwoerter

	move.l	(a0)+,d0	;Anzahl der Adressen
	beq.b	Ex08_3		;Wenn NULL dann nicht checken
	subq.w	#1,d0

1$	cmp.l	(a0)+,d6	;Adressen vergleichen
	dbeq	d0,1$
	bne.b	Ex08_3		;Wenn sie ungleich waren dann weiter

;**********************************
;	ExternText nach (a4)+ kopieren
;**********************************

FoundExternxx:
	move.l	d1,-(SP)
	move.l	(a1)+,d1		;Anzahl der Langwoerter
	lsl.l	#2,d1
	subq.l	#1,d1

1$	move.b	(a1)+,(a4)+	;Text kopieren stoppen wenn NULL
	dbeq	d1,1$
	bne.b	2$
	subq.l	#1,a4		;Wenn NULL dann eins vom zaehler abziehen
2$	move.l	(SP)+,d1
	rts

;**********************************
;	Label NUR SUCHEN mit Reloc32
;**********************************

CheckOnReloc32:
	bsr	NotPrintExternXX
	tst.b	LabelYes-x(a5)
	beq.b	1$
	rts

1$	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	tst.l	0(a0,d6.l)	;Wenn kein Reloc32 dann auch nicht testen
	beq	5$

	move.l	0(a0,d6.l),a1
	cmp.l	#$03ec,(a1)+	;Reloc32-kennung testen und ueberspringen
	bne	5$

	move.l	PCounter-x(a5),d0		;richtige Adresse
	btst	#0,d0
	bne	5$

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	5$
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,d0	;Eintraege '(a2)' mit richtiger Adresse 'd0'
	dbls	d7,3$
	bne.b	2$

4$	move.b	#4,ExternSize-x(a5)
	st	LabelYes-x(a5)
5$	rts

;**********************************
;	testen ob ExternXX sonst nichts
;**********************************

NotPrintExternXX:
	move.l	CurrHunk-x(a5),d6	;aktueller Hunk
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0

	tst.l	12(a0,d6.l)		;auf inhalt testen
	beq	xNoExternXX		;wenn null dann ende

	move.l	12(a0,d6.l),a0		;inhalt holen
	cmp.l	#$03ef,(a0)+		;auf extern testen
	bne.b	xNoExternXX

	move.l	PCounter-x(a5),d6	;zu suchende Adresse einladen

	bra.b	xExXX_3

xExXX_1	tst.l	d0		;testen ob > oder < als $80
	bpl.b	xExXX_2

	rol.l	#8,d0

	move.b	#4,ExternSize-x(a5)
	cmp.b	#$81,d0
	beq.b	xYesExternXX	;mit Extern_Ref32 vergleichen

;	move.b	#4,ExternSize-x(a5)
	cmp.b	#$82,d0
	beq.b	xYesExternXX	;mit Extern_common (32) vergleichen

;	move.b	#4,ExternSize-x(a5)
	cmp.b	#$85,d0
	beq.b	xYesExternXX	;mit Extern_Dext32 vergleichen

	move.b	#2,ExternSize-x(a5)
	cmp.b	#$83,d0
	beq.b	xYesExternXX	;mit Extern_Ref16 vergleichen

;	move.b	#2,ExternSize-x(a5)
	cmp.b	#$86,d0
	beq.b	xYesExternXX	;mit Extern_Dext16 vergleichen

	move.b	#1,ExternSize-x(a5)
	cmp.b	#$84,d0
	beq.b	xYesExternXX	;mit Extern_Ref08 vergleichen

;	move.b	#1,ExternSize-x(a5)
	cmp.b	#$87,d0
	beq.b	xYesExternXX	;mit Extern_Dext08 vergleichen

	ror.l	#8,d0

	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0
	move.l	(a0)+,d0
	lsl.l	#2,d0
	add.l	d0,a0

xExXX_3	move.l	a0,a1
	move.l	(a0)+,d0
	bne.b	xExXX_1
xNoExternXX
	clr.b	LabelYes-x(a5)
	rts

xExXX_2	and.l	#$ffffff,d0	;kleiner als $80
	lsl.l	#2,d0
	add.l	d0,a0
	addq.l	#4,a0
	bra.b	xExXX_3

xYesExternXX:
	ror.l	#8,d0
	and.l	#$ffffff,d0	;groesser als $80
	lsl.l	#2,d0
	add.l	d0,a0		;Anzahl der Langwoerter

	move.l	(a0)+,d0	;Anzahl der Adressen
	beq.b	xExXX_3
	subq.w	#1,d0

1$	cmp.l	(a0)+,d6	;Adressen vergleichen
	dbeq	d0,1$
	bne.b	xExXX_3

3$	st	LabelYes-x(a5)
	rts

;**********************************
;	Jumplist aus File einladen
;**********************************

LoadJumplist:

	tst.b	ArguD-x(a5)	;TRACE/S
	beq	1$

	tst.l	ArguE-x(a5)		;JL/K
	beq	1$

	move.l	DosBase-x(a5),a6

	lea	Buffer-x(a5),a2
	move.l	a2,d1			;FileName fuer unten

	move.l	#'PROG',(a2)+
	move.l	#'DIR:',(a2)+
	move.l	#'D68K',(a2)+
	move.l	#'_Jum',(a2)+	; "JumpLists/Jumplist."
	move.l	#'plis',(a2)+
	move.l	#'ts/J',(a2)+
	move.l	#'umpl',(a2)+
	move.l	#'ist.',(a2)+

	lea	FIB+8-x(a5),a3

5$	move.b	(a3)+,(a2)+
	bne.b	5$

	move.l	#1005,d2		;Filename siehe oben
	jsr	_LVOOpen(a6)
	move.l	d0,FileHD3-x(a5)
	beq	1$

	move.l	d0,d1
	move.l	#FIB2,d2
	jsr	_LVOExamineFH(a6)	;Examine mit FileHandle
	tst.l	d0
	beq	ErrorDatei

	lea	FIB2-x(a5),a0
	move.l	124(a0),d0	;FileSize der Jumplist
	addq.l	#8,d0
	move.l	#$10000,d1
	move.l	4,a6
	jsr	_LVOAllocVec(a6)
	move.l	d0,JLMem-x(a5)
	beq	ErrorMemory

;	lea	FIB2-x(a5),a0
;	move.l	124(a0),d3		;mit dieser Laenge
;	move.l	JLMem-x(a5),a0
;	clr.b	0(a0,d3.l)		;END-kennung setzen !!!

	move.l	DosBase-x(a5),a6

	move.l	FileHD3-x(a5),d1	;Dieses File
	move.l	JLMem-x(a5),d2	;in diesen Speicher
	lea	FIB2-x(a5),a0
	move.l	124(a0),d3		;mit dieser Laenge
	jsr	_LVORead(a6)		;und los geht's
	moveq	#-1,d3
	cmp.l	d3,d0
	beq	ErrorDatei

	move.l	FileHD3-x(a5),d1
	jsr	_LVOClose(a6)

	move.l	JLMem-x(a5),a2

	bsr	GetHexDatas
	moveq	#-1,d2
	cmp.l	d7,d2
	beq.b	2$

	cmp.l	FileID-x(a5),d7
	bne	9$

	cmp.l	FileSize-x(a5),d6
	bne	9$

3$	bsr	GetHexDatas
	moveq	#-1,d2
	cmp.l	d7,d2
	beq.b	2$
	move.l	a2,-(SP)

	btst	#0,d6			;ungerade Adresse?
	bne.b	4$

	tst.b	KICK-x(a5)
	beq	7$

	sub.l	ROMaddress-x(a5),d6	;wegen Kickstart abziehen

7$	cmp.l	HunkAnzahl-x(a5),d7	;groesser als HunkAnzahl
	bge.b	4$

	lsl.l	#TabSize,d7
	move.l	HunkMem-x(a5),a0

	cmp.l	28(a0,d7.l),d6		;mit Hunkgroesse vergleichen
	bge.b	4$

	add.l	8(a0,d7.l),d6		;Anfang des Hunks addieren

	move.l	SprungMem-x(a5),a3
	add.l	SprungPointer-x(a5),a3
	move.l	d6,(a3)
	addq.l	#4,SprungPointer-x(a5)

;	move.l	d7,d2		;Hunk und Adresse ausgeben
;	bsr	HexOutPutL	;nur zum testen !!!
;	bsr	Space
;	move.l	d6,d2
;	bsr	HexOutPutL
;	bsr	Return

4$	move.l	(SP)+,a2
	bra.b	3$

2$	move.l	JLMem-x(a5),a1		;Fuer das Jumplist-File
	move.l	4,a6
	jsr	_LVOFreeVec(a6)

	tst.b	Argu4-x(a5)	;INFO/S
	beq.b	1$

		move.l	#Status7T,d1		;Dateilaenge ausgeben
		moveq	#Status8T-Status7T,d2
		bsr	PrintText

		move.l	SprungPointer-x(a5),d2
		lsr.l	#2,d2
		bsr	DecL
		lea	Buffer+3-x(a5),a0
		move.b	#10,7(a0)
		move.l	a0,d1
		moveq	#8,d2
		bsr	PrintText

1$	rts

9$	move.l	#ErrorAT,d1
	moveq	#ErrorBT-ErrorAT,d2
	bsr	PrintText
	bra.b	2$

GetHexDatas:
1$	move.b	(a2)+,d2
	beq.b	EOF

	cmp.b	#';',d2
	beq.b	4$

	cmp.b	#'$',d2
	bne.b	1$

	bsr	hex2bin
	tst.b	d2
	beq.b	1$
	move.l	d1,d7		;In diesem Hunk (D7)

	move.b	(a2)+,d2
	beq.b	EOF
	cmp.b	#',',d2
	bne.b	1$
	cmp.b	#';',d2
	beq.b	3$

	move.b	(a2)+,d2
	beq.b	EOF
	cmp.b	#'$',d2
	bne.b	1$
	cmp.b	#';',d2
	beq.b	3$

	bsr	hex2bin
	tst.b	d2
	beq.b	1$
	move.l	d1,d6		;An dieser Stelle (D6)

3$	move.b	(a2)+,d2
	beq.b	EOF
	cmp.b	#10,d2
	bne.b	3$
	rts

4$	move.b	(a2)+,d2
	beq.b	EOF
	cmp.b	#10,d2
	beq	1$
	bra.b	4$

EOF2:	addq.l	#8,SP		;Fuer zwei rts-back
EOF:	moveq	#-1,d7		;End of File indentifier
	rts

hex2bin:
	moveq	#0,d1
	moveq	#-1,d2
hexinloop:
	bsr.b	nibblein
	cmp.b	#$10,d0
	bcc.b	1$
	lsl.l	#4,d1
	or.b	d0,d1
	bra.b	hexinloop
1$	subq.l	#1,a2
	rts

nibblein:
	moveq	#0,d0
	move.b	(a2)+,d0
	beq.b	EOF2
	addq.b	#1,d2
	cmp.b	#"a",d0
	bcs.b	1$
	cmp.b	#"f",d0
	bhi.b	1$
	sub.b	#$20,d0
1$	sub.b	#"A",d0
	bcc.b	2$
	addq.b	#07,d0
2$	add.b	#10,d0
	rts

;**********************************
;	File-ID abspeichern
;**********************************

MakeIDFile:

	tst.b	ArguD-x(a5)	;TRACE/S
	beq	9$

	tst.l	ArguE-x(a5)	;JUMPLIST/S
	bne	9$

	lea	Buffer-x(a5),a2
	move.l	#"T:Ju",(a2)+
	move.l	#"mpLi",(a2)+
	move.w	#"st",(a2)+
	move.b	#".",(a2)+

	lea	FIB-x(a5),a3
	addq.l	#8,a3

3$	move.b	(a3)+,(a2)+
	bne.b	3$

	move.l	DosBase-x(a5),a6

	lea	Buffer-x(a5),a2
	move.l	a2,d1
	move.l	#1006,d2
	jsr	_LVOOpen(a6)
	move.l	d0,d7
	beq	9$

	lea	Buffer-x(a5),a2
	move.l	a2,d1		;File
	moveq	#2,d2			;Maske = 1 Bit fuer 'Not Executable'
	jsr	_LVOSetProtection(a6)

	move.l	d7,d1
	move.l	#FileIDText,d2
	moveq	#FileIDText1-FileIDText,d3
	jsr	_LVOWrite(a6)

	lea	Buffer-x(a5),a2
	lea	FIB-x(a5),a4
	addq.l	#8,a4
	moveq	#-1,d3

4$	addq.l	#1,d3
	move.b	(a4)+,(a2)+
	bne.b	4$

	move.l	d7,d1
	lea	Buffer-x(a5),a2
	move.l	a2,d2
	jsr	_LVOWrite(a6)

	move.l	d7,d1
	move.l	#FileIDText1,d2
	moveq	#FileIDText2-FileIDText1,d3
	jsr	_LVOWrite(a6)

	lea	Buffer-x(a5),a4
	move.l	FileID-x(a5),d2
	bsr	HexLDi
	move.b	#',',(a4)+
	move.l	FileSize-x(a5),d2
	bsr	HexLDi
	move.b	#$0A,(a4)+
	move.b	#$0A,(a4)+

	move.l	d7,d1
	lea	Buffer-x(a5),a4
	move.l	a4,d2
	moveq	#21,d3
	jsr	_LVOWrite(a6)

	move.l	d7,d1
	jsr	_LVOClose(a6)

9$	rts

;**********************************
;	File-ID errechen
;**********************************

GetFileID:
	move.l	Memory-x(a5),a0

	move.l	FileSize-x(a5),d0
	move.l	d0,d1
	cmp.l	#2048,d0
	ble.b	1$
	move.l	#2048,d0

1$	subq.w	#1,d0
	moveq	#0,d2

2$	move.b	(a0)+,d2
	add.l	d2,d1
	dbra	d0,2$

	move.l	d1,FileID-x(a5)
	rts

;*****************************************

LibraryInit:

	tst.b	Libby-x(a5)
	bne.b	2$
	rts

2$	clr.l	CurrHunk-x(a5)

	move.l	HunkMem-x(a5),a0
	move.l	36(a0),a3		;Anfang (pure Daten!) des (NUR) ersten Hunks
	move.l	a3,a1
	move.l	04(a0),d7		;groesse des (NUR) ersten Hunks

	lsr.l	#1,d7		;durch 2 teilen !!! (weil WORD-Suche!)
	subq.l	#1,d7
	bmi	LibEnd

	move.w	#$4afc,d0	;das ist der resident-erkenner (ILLEGAL!) den wir suchen muessen !!

1$	cmp.w	(a1)+,d0	;ILLEGAL Befehl suchen !!! (resident-erkenner!)
	dbeq	d7,1$
	bne	LibEnd

	move.l	a1,d7	;zusaetzlicher Sicherheitscheck !!!
	sub.l	a3,d7
	subq.l	#2,d7	;Nach dem ILLEGAL muss ein Zeiger auf das Illegal kommen !!
	cmp.l	(a1),d7
	bne	LibEnd

	move.l	32(a0),a2	;BitMemAdresse von Hunk 0 holen

	lsr.l	#1,d7		;d7/2
	move.w	d7,d6
	lsr.l	#3,d7		;d7/8
	bset	d6,0(a2,d7.w)	;und nun Bit setzen !!! (fuer ILLEGAL!)

	;	nun Funktionstabelle eintragen

	clr.l	RelocXAdress-x(a5)	;ist immer null, weil immer direkt!

	lea	20(a1),a1	;*illegal + offset zum InitTable
	move.l	a3,d5
	sub.l	d5,a1
	move.l	a1,a3

	clr.b	Springer-x(a5)	;damit die Offsets NICHT in der SprungMemT. eingetr. werden
	bsr	Libbyspezial

	; 2. Durchgang...

	move.l	d6,CurrHunk-x(a5)
	move.l	HunkMem-x(a5),a0
	lsl.l	#TabSize,d6
	move.l	36(a0,d6),a3

		movem.l	d5/a3,-(SP)

	lea	12(a3,d5.l),a1
	move.l	a3,d5
	sub.l	d5,a1
	move.l	a1,a3

	move.b	#1,Springer-x(a5)	;damit die Offsets in der SprunMemT. eingtr. werden
	bsr	Libbyspezial

		movem.l	(SP)+,d5/a3

	lea	04(a3,d5.l),a1
	move.l	a3,d5
	sub.l	d5,a1
	move.l	a1,a3

	clr.b	Springer-x(a5)	;damit die Offsets NICHT in der SprunMemT. eingtr. werden
	bsr	Libbyspezial

	move.l	d6,CurrHunk-x(a5)
	move.l	HunkMem-x(a5),a0
	lsl.l	#TabSize,d6
	move.l	36(a0,d6),a3

	cmp.l	28(a0,d6.l),d5	;wenn das Label groesser als der Hunk ist
	bhi.b	LibEnd		;dann KEIN Label

	move.l	a3,a0
	move.l	d5,d0

	btst	#0,d0
	bne.b	LibEnd

	add.l	d0,a0

	move.b	#1,Springer-x(a5)	;damit die Offsets in der SprunMemT. eingtr. werden

	cmp.w	#$ffff,(a0)
	beq.b	ShortTable

BigTable:
	move.l	d0,PCounter-x(a5)
	add.l	a3,d0
	move.l	d0,Pointer-x(a5)

1$	move.l	(a0)+,d2		;Zeiger ins SprungMemTable
	beq	LibEnd

	btst	#0,d2		;keine ungeraden Adressen
	bne.b	LibEnd

;	movem.l	d2/a0,-(SP)
;	bsr	HexOutPutL
;	bsr	Space
;	move.l	a0,d2
;	bsr	HexOutPutL
;	bsr	Return
;	movem.l	(SP)+,d2/a0

	move.l	a0,-(SP)
	bsr	LabelCalcRelocX32
	move.l	(SP)+,a0

	addq.l	#4,Pointer-x(a5)
	addq.l	#4,PCounter-x(a5)

	bra.b	1$

ShortTable:
	addq.l	#2,a0

1$	move.w	(a0)+,d2

	btst	#0,d2		;keine ungeraden Adressen
	bne.b	LibEnd

	ext.l	d2
	add.l	d0,d2

	movem.l	d0/a0,-(SP)
	bsr	LabelCalc2
	movem.l	(SP)+,d0/a0

	bra.b	1$

LibEnd:	clr.l	CurrHunk-x(a5)
	rts

Libbyspezial:

; uebergeben wird u.a. a3

	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6		;Anfang in Hunktabelle
	move.l	HunkMem-x(a5),a0

	move.l	0(a0,d6.l),d7	;Wenn kein Reloc32 dann auch nicht testen
	beq	4$
	move.l	d7,a1
	cmp.l	#$03ec,(a1)+	;Reloc32-kennung testen und ueberspringen
	bne	4$

2$	move.l	(a1)+,d7	;Anzahl der Offsets in d7
	beq	1$
	move.l	d7,d3
	subq.w	#1,d7		;1 abziehen wegen dbls
	move.l	(a1)+,d6	;Nummer des Hunks

	move.l	a1,a2		;Zeiger in A1 wieder korrigieren
	lsl.l	#2,d3
	add.l	d3,a1

3$	cmp.l	(a2)+,a3	;Eintraege '(a2)' mit richtiger Adresse 'a3'
	dbls	d7,3$
	bne.b	2$

	add.l	d5,a3

	move.l	(a3),d2		; L wegen Reloc32

	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a0
	cmp.l	28(a0,d6.l),d2	;wenn das Label groesser als der Hunk ist
	bhi.b	1$		;dann KEIN Label

	move.l	d2,d5
	add.l	8(a0,d6.l),d2	;Pos. des Hunks addieren

4$	tst.b	Springer-x(a5)	;ist es Sprungbefehl gewesen ??
	beq.b	1$

	cmp.l	28(a0,d6.l),d5	;wenn der Sprung groesser ODER gleich als der Hunk ist
	bge.b	1$

	bsr	SprungMemFueller

1$	lsr.l	#TabSize,d6
	rts

; *********************************************

; BinSearch von Arno Eigenwillig

BinSearch:
	lsl.l	#2,d0
	moveq	#-4,d3
.loop	move.l	d0,d2
	lsr.l	#1,d2
	and.b	d3,d2		;unteren zwei bits ausblenden
	cmp.l	0(a0,d2.l),d1
	blt	.lower
	beq	.found
	lea	4(a0,d2.l),a0
	subq.l	#4,d0
.lower	sub.l	d2,d0
	tst.l	d2
	bne	.loop
	moveq	#0,d0
	rts

.found	add.l	d2,a0
	move.l	a0,d0
	rts
