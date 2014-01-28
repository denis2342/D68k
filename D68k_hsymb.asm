;
;	Routine um die SymbolNamen auszugeben
;
;	(- Wenn HunkLab (Argu5) aktiviert ist -)
;

DisSymbol:

	tst.l	(a2)	;wenn kein Symbol dann zurück
	bne.b	1$
	addq.l	#4,a2
	rts

1$	bsr	Return	;erst mal 'ne Zwischenzeile
	bra.b	4$

3$	lea	Befehl-x(a5),a1
	move.l	d0,(a1)+	;Anzahl der Langwörter (des Textes)

	move.l	a2,(a1)+	;und Anfang des Textes nach a1 (Befehl)

	lsl.l	#2,d0
	add.l	d0,a2

	move.l	(a2)+,(a1)	;und die Adresse auf den der Text zeigt
	bsr.b	XXX
4$	bsr	CheckC
	move.l	(a2)+,d0	;wenn null dann keine Symbole
	bne.b	3$
	rts

XXX:	move.l	a2,-(SP)
	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	1$
	bsr	TAB4
1$	move.b	#9,Hexminus2-x(a5)
	move.b	#'$',Hexminus-x(a5)
	move.b	#9,Hexplus-x(a5)
	move.l	Befehl+8-x(a5),d2
	bsr	HexL
	move.l	#HexBufferL-2,d1
	moveq	#11,d2
	bsr	Print
	bsr.b	qqq
	bsr	Return
	move.l	(SP)+,a2
	rts

qqq:	move.l	Befehl-x(a5),d1		;Anzahl der Langwörter
	move.l	Befehl+4-x(a5),a1	;Adresse des Textes

qqq2:	move.l	a1,d7
	lsl.l	#2,d1
	subq.l	#1,d1
	bcs.b	3$		;Wenn NULL Langwörter dann keine Ausgabe
	moveq	#0,d2
	bra.b	2$

1$	addq.w	#1,d2	;länge des Textes bis NULL ausrechnen
2$	tst.b	(a1)+
	dbeq	d1,1$
	beq.b	4$

	addq.w	#1,d2

4$	tst.w	d2	;wenn kein Symboltext dann keine Ausgabe
	beq.b	3$

	move.l	d7,d1	;und Ausgeben
	bsr	Print
3$	rts

;	d1 = Anzahl der Langwoerter
;	a1 = Adresse des Textes

qqq3:	cmp.l	#0,a1
	beq	3$
	move.l	-4(a1),d1

	lsl.l	#2,d1
	subq.l	#1,d1
	bcs.b	3$		;Wenn NULL Langwörter dann keine Ausgabe

1$	move.b	(a1)+,(a4)+
	dbeq	d1,1$
	bne.b	3$

	subq.l	#1,a4

3$	rts

	; kopiert von A1 nach A4 bis in A1 eine NULL erscheint

;qqq4:
;1$	move.b	(a1)+,(a4)+
;	bne	1$
;	subq.l	#1,a4
;	rts

	; kopiert von A1 nach A4 bis D1 abgelaufen ist...

qqq5x:	move.b	(a1)+,(a4)+
qqq5:	dbra	d1,qqq5x
	rts
