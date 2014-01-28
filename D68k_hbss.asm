;
;	D68k.bss von Denis Ahrens 1990-1994
;

DisBSS:
	clr.l	PCounter-x(a5)
	tst.l	CodeSize-x(a5)	;Check für DataLength = 0
	beq.b	DisBSSE		;Wenn CodeSize = 0 dann RTS
	bsr	Return		;Ein Return ausgeben

DisBSS2:
	bsr	CheckC
	bsr.b	DissaBSS		;BSS ausgeben
	move.l	PCounter-x(a5),d0
	cmp.l	CodeSize-x(a5),d0
	blt.b	DisBSS2
DisBSSE	bsr	PLine		;letztes Label (oder erstes) ohne alles
	rts

DissaBSS:
	lea.l	Befehl-x(a5),a4
	clr.l	ToAdd-x(a5)
	move.l	CodeAnfang-x(a5),a0
	add.l	PCounter-x(a5),a0
	move.l	a0,Pointer-x(a5)

	bsr	PLine		;Ausgabe des PC + TAB

	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	1$

	move.l	#Befehl2,d1	;und ausgeben
	moveq	#7,d2
	bsr	Print

1$	move.l	NextLabel-x(a5),d3

	btst.l	#0,d3
	bne	b_dc_b

	btst.l	#1,d3
	bne	b_dc_w

b_dc_l:	move.l	d3,d7
	lsr.l	#2,d7
	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	1$

	moveq	#9,d2
	move.b	d2,(a4)+
	move.b	d2,(a4)+
	move.b	d2,(a4)+

1$	move.b	#$9,(a4)+
	move.b	#'d',(a4)+
	move.b	#'s',(a4)+
	move.b	#'.',(a4)+
	move.b	#'l',(a4)+
	move.b	#9,(a4)+
	move.l	d7,d2
	bsr	DecL

	lea	Buffer+3-x(a5),a0
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+

	move.b	#10,(a4)+	;RETURN hinten ranhängen
	move.l	#Befehl,d1	;und ausgeben
	move.l	a4,d2
	sub.l	d1,d2
	bsr	Print
	lsl.l	#2,d7
	add.l	d7,PCounter-x(a5)
	rts

b_dc_w:	move.l	d3,d7
	lsr.l	#1,d7
	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	1$

	moveq	#9,d2
	move.b	d2,(a4)+
	move.b	d2,(a4)+
	move.b	d2,(a4)+

1$	move.b	#$9,(a4)+
	move.b	#'d',(a4)+
	move.b	#'s',(a4)+
	move.b	#'.',(a4)+
	move.b	#'w',(a4)+
	move.b	#9,(a4)+
	move.l	d7,d2
	bsr	DecL

	lea	Buffer+3-x(a5),a0
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+

	move.b	#10,(a4)+	;RETURN hinten ranhängen
	move.l	#Befehl,d1	;und ausgeben
	move.l	a4,d2
	sub.l	d1,d2
	bsr	Print
	lsl.l	#1,d7
	add.l	d7,PCounter-x(a5)
	rts

b_dc_b:	move.l	d3,d7
	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	1$

	moveq	#9,d2
	move.b	d2,(a4)+
	move.b	d2,(a4)+
	move.b	d2,(a4)+

1$	move.b	#9,(a4)+
	move.b	#'d',(a4)+
	move.b	#'s',(a4)+
	move.b	#'.',(a4)+
	move.b	#'b',(a4)+
	move.b	#9,(a4)+
	move.l	d7,d2
	bsr	DecL

	lea	Buffer+3-x(a5),a0
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+
	move.b	(a0)+,(a4)+

	move.b	#10,(a4)+	;RETURN hinten ranhängen
	move.l	#Befehl,d1	;und ausgeben
	move.l	a4,d2
	sub.l	d1,d2
	bsr	Print
	add.l	d7,PCounter-x(a5)
	rts
