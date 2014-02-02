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

1$	move.l	NextLabel-x(a5),d2
	add.l	d2,PCounter-x(a5)

	btst	#0,d2
	bne	b_dc_b

	btst	#1,d2
	bne	b_dc_w

b_dc_l:
	lsr.l	#2,d2
	moveq	#"l",d4
	bra		subr
;	rts

b_dc_w:
	lsr.l	#1,d2
	moveq	#"w",d4
	bra		subr
;	rts

b_dc_b:
	moveq	#"b",d4
;	bra		subr
;	rts

subr:
	moveq	#9,d7		; TAB
	tst.b	Argu3-x(a5)	;NOPC/S
	bne.b	1$

	move.b	d7,(a4)+	; TAB
	move.b	d7,(a4)+	; TAB
	move.b	d7,(a4)+	; TAB

1$	move.b	d7,(a4)+	; TAB
	move.b	#'d',(a4)+
	move.b	#'s',(a4)+
	move.b	#'.',(a4)+
	move.b	d4,(a4)+	; size (b,w,l)
	move.b	d7,(a4)+	; TAB
	bsr	DecL

	lea	Buffer+3-x(a5),a0
	moveq	#7-1,d1
2$	move.b	(a0)+,(a4)+
	dbf		d1,2$

	move.b	#10,(a4)+	;RETURN hinten ranhaengen
	move.l	#Befehl,d1	;und ausgeben
	move.l	a4,d2
	sub.l	d1,d2
	bra	Print			; AUTO RTS
