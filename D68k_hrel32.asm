;
;	Labels von Reloc erstellen
;
;	(und testen ob es sie als Symbol gibt (wenn ja fallen sie weg))
;
;	a0 muss richtig hochgez�hlt werden !!!
;

SearchReloc32Label:		;F�r Reloc32 eintr�ge
	move.l	HunkMem-x(a5),a1

	move.l	CurrHunk-x(a5),d5	;Nummer der Reloc-Hunks
	lsl.l	#TabSize,d5
Search4$
	move.l	(a0)+,d7	;Anzahl der Offsets in d7
	bne.b	1$
	rts

1$	subq.l	#1,d7		;1 abziehen wegen dbra

	move.l	(a0)+,d6	;Nummer des Hunks auf den die Offsets zeigen
	lsl.l	#TabSize,d6

Search3$
	move.l	36(a1,d5.l),a2		;Anfang des Hunks im Speicher
	add.l	(a0)+,a2		;Stelle des Reloc32
	move.l	(a2),d3			;Label nach D3

LabelCalcSymbol2$:			;in D6 wird der Hunk �bergeben
	tst.l	16(a1,d6.l)		;Testen ob Zeiger auf Symbol = NULL ?
	beq.b	5$			;Wenn ja Ausstieg

	move.l	16(a1,d6.l),a2		;SymbolHunkAnfang in A0
	cmp.l	#$3f0,(a2)+		;Testen ob mit Symbol-Hunk gef�llt
	bne.b	5$

	bra.b	2$

3$	lsl.l	#2,d1		;anzahl der Langw�rter
	add.l	d1,a2
	cmp.l	(a2)+,d3	;testen ob Adresse �bereinstimmt
	beq.b	4$
2$	move.l	(a2)+,d1	;testen ob Symbol folgt
	bne.b	3$

5$	move.l	8(a1,d6.l),d2	;PC des ZielHunks (insgesamt)
	add.l	d3,d2		;Label zu dem Anfang des Hunks addieren
	bsr	AddLabelPointer

4$	dbra	d7,Search3$
	bra.b	Search4$

;******************************************************************

SearchReloc16Label:		;F�r Reloc16 eintr�ge
	move.l	HunkMem-x(a5),a1

	move.l	CurrHunk-x(a5),d5	;Nummer der Reloc-Hunks
	lsl.l	#TabSize,d5
Search4$
	move.l	(a0)+,d7	;Anzahl der Offsets in d7
	bne.b	1$
	rts

1$	subq.l	#1,d7		;1 abziehen wegen dbra

	move.l	(a0)+,d6	;Nummer des Hunks
	lsl.l	#TabSize,d6

Search3$
	move.l	36(a1,d5.l),a2		;Anfang des Hunks im Speicher
	add.l	(a0)+,a2		;Stelle des Reloc32
	move.l	(a2),d3			;Label nach D3
	ext.l	d3

LabelCalcSymbol2$:			;in D6 wird der Hunk �bergeben
	tst.l	16(a1,d6.l)		;Testen ob Zeiger NULL
	beq.b	5$			;Wenn ja Ausstieg

	move.l	16(a1,d6.l),a2		;SymbolHunkAnfang in A0
	cmp.l	#$3f0,(a2)+	;Testen ob mit Symbol-Hunk gef�llt
	bne.b	5$

	bra.b	2$

3$	lsl.l	#2,d1		;anzahl der Langw�rter
	add.l	d1,a2
	cmp.l	(a2)+,d3	;testen ob Adresse �bereinstimmt
	beq.b	4$
2$	move.l	(a2)+,d1	;testen ob Symbol folgt
	bne.b	3$

5$	move.l	8(a1,d6.l),d2	;PC des ZielHunks (insgesamt)
	add.l	d3,d2		;Label zu dem Anfang des Hunks addieren
	bsr	AddLabelPointer

4$	dbra	d7,Search3$
	bra.b	Search4$

;******************************************************************

SearchReloc08Label:		;F�r Reloc08 eintr�ge
	move.l	HunkMem-x(a5),a1

	move.l	CurrHunk-x(a5),d5	;Nummer der Reloc-Hunks
	lsl.l	#TabSize,d5
Search4$
	move.l	(a0)+,d7	;Anzahl der Offsets in d7
	bne.b	1$
	rts

1$	subq.l	#1,d7		;1 abziehen wegen dbra

	move.l	(a0)+,d6	;Nummer des Hunks
	lsl.l	#TabSize,d6

Search3$
	move.l	36(a1,d5.l),a2		;Anfang des Hunks im Speicher
	add.l	(a0)+,a2		;Stelle des Reloc32
	move.l	(a2),d3			;Label nach D3
	ext.w	d3
	ext.l	d3

LabelCalcSymbol2$:			;in D6 wird der Hunk �bergeben
	tst.l	16(a1,d6.l)		;Testen ob Zeiger auf Symbol = NULL
	beq.b	5$			;Wenn ja Ausstieg

	move.l	16(a1,d6.l),a2		;SymbolHunkAnfang in A0
	cmp.l	#$3f0,(a2)+		;Testen ob mit Symbol-Hunk gef�llt
	bne.b	5$

	bra.b	2$

3$	lsl.l	#2,d1		;anzahl der Langw�rter
	add.l	d1,a2
	cmp.l	(a2)+,d3	;testen ob Adresse �bereinstimmt
	beq.b	4$
2$	move.l	(a2)+,d1	;testen ob Symbol folgt
	bne.b	3$

5$	move.l	8(a1,d6.l),d2	;PC des ZielHunks (insgesamt)
	add.l	d3,d2		;Label zu dem Anfang des Hunks addieren
	bsr	AddLabelPointer

4$	dbra	d7,Search3$
	bra.b	Search4$
