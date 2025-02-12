;
;	D68k.extern von Denis Ahrens 1992
;

DisExt:	tst.l	(a2)
	bne.b	1$
	addq.l	#4,a2
	rts

1$	bsr	Return	;erstmal 'ne zwischenzeile
	bra.b	4$		;und direkt reinspringen

3$	lea	Befehl-x(a5),a1
	tst.l	d0		; war btst #31,d0 mit beq.b 2$
	bpl.b	2$

	and.l	#$ffffff,d0	;gr��er als $80
	lsl.l	#2,d0
	add.l	d0,a2
	move.l	(a2)+,d0
	lsl.l	#2,d0
	add.l	d0,a2

4$	bsr	CheckC
	move.l	(a2)+,d0
	bne.b	3$
	rts

2$	and.l	#$ffffff,d0	;kleiner als $80

	move.l	d0,(a1)+	;Anzahl der Langw�rter (des Textes)
	move.l	a2,(a1)+	;und Anfang des Textes nach a1 (Befehl)

	lsl.l	#2,d0
	add.l	d0,a2

	move.l	(a2)+,(a1)	;jetzt das OffSet zum Text

	bsr	PrintExt
	bra.b	4$

PrintExt:
	move.l	a2,-(SP)
	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	1$
	bsr	TAB4
1$	bsr	PrintExtText

	move.l	Befehl+8-x(a5),d2	;Offset oder Adresse (hier offset)
	lea	HexBufferL-2-x(a5),a4

	cmp.w	#23,CodeID-x(a5)
	bhi.b	2$
	cmp.w	#15,CodeID-x(a5)
	bhi.b	3$
	cmp.w	#7,CodeID-x(a5)
	bhi.b	4$
	move.b	#9,(a4)+
4$	move.b	#9,(a4)+
3$	move.b	#9,(a4)+
2$	move.b	#9,(a4)+
	move.b	#'e',(a4)+
	move.b	#'q',(a4)+
	move.b	#'u',(a4)+
	move.b	#' ',(a4)+
	bsr	HexLs
	move.b	#10,(a4)+

	move.l	#HexBufferL-2,d1
	move.l	a4,d2
	sub.l	d1,d2
	bsr	Print
	move.l	(SP)+,a2
	rts

PrintExtText:
	move.l	Befehl-x(a5),d1
	move.l	Befehl+4-x(a5),a1
	lsl.l	#2,d1
	subq.l	#1,d1
	moveq	#0,d2
	bra.b	2$

1$	addq.w	#1,d2	;l�nge des Textes bis NULL ausrechnen
2$	tst.b	(a1)+
	dbeq	d1,1$
	beq.b	4$

	addq.w	#1,d2

4$	tst.w	d2	;wenn kein Symboltext dann keine Ausgabe
	beq.b	3$

	move.w	d2,CodeID-x(a5)

	move.l	Befehl+4-x(a5),d1	;und Ausgeben
	bsr	Print
3$	rts
