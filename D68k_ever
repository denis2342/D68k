;
;	D68k.ever von Denis Ahrens 1990-1994
;

WriteInfoText:

	bsr	DecL			;Sammelroutine zum Schreiben des
	lea	Buffer+3-x(a5),a0	;Textes der INFO Option !!!
	move.b	#10,7(a0)
	move.l	a0,d1
	moveq	#8,d2
	bra	PrintText	;AUTO RTS
;	rts

;**********************************
;	.L$ Zahl ausgeben
;**********************************

HexOutPutL:
	bsr	HexL
	move.l	#HexBufferL,d1
	moveq	#8,d2
	bra	Print		;RTS AUTO

HexOutPutW:
	bsr	HexW
	move.l	#HexBufferW,d1
	moveq	#4,d2
	bra	Print		;RTS AUTO

HexOutPutB:
	bsr	HexB
	move.l	#HexBufferB,d1
	moveq	#2,d2
	bra	Print		;RTS AUTO

;**********************************
;	D2 Registerwert in ASCII umw.
;**********************************

DecL:	movem.l	d0-d2/a0-a1,-(SP)
	moveq	#10-1,d0	;10 Digits konnvertieren
	lea	Buffer-x(a5),a0
	lea	pwrof10,a1
nex:	moveq	#'0',d1		;Fange mit Digit '0' an
dec:	addq.b	#1,d1		;Digit + 1
	sub.l	(a1),d2		;noch drin?
	bcc.b	dec		;wenn so
	subq.b	#1,d1		;korrigiere Digit
	add.l	(a1)+,d2	;den auch
	move.b	d1,(a0)+	;Digit -> Buffer
	dbra	d0,nex		;for 8 Digits
done:	movem.l	(SP)+,d0-d2/a0-a1
	rts

;**********************************
;	Ausgabe eines Returns
;**********************************

Return:	moveq	#1,d2
	move.l	#RETURN,d1
	bra	Print		;AUTO RTS
;	rts

;**********************************
;	Ausgabe eines Space
;**********************************

Space:	moveq	#1,d2
	move.l	#SPACE,d1
	bra	Print		;AUTO RTS
;	rts

;**********************************
;	Ausgabe eines Tabulators
;**********************************

TAB:		moveq	#1,d2
TABX:		move.l	#Tabulator,d1
		bra	Print		;AUTO RTS
;		rts

;**********************************
;	Ausgabe von TABS
;**********************************

TAB4:	moveq	#4,d2
	bra.b	TABX
TAB3:	moveq	#3,d2
	bra.b	TABX
TAB2:	moveq	#2,d2
	bra.b	TABX

;**********************************
;	$ Reg. in ASCII umw.
;**********************************

HexL:	lea	HexBufferL-x(a5),a0	;Wandelt #$24 in D2
	moveq	#7,d0			;nach "24" in HexPuffer um
1$	rol.l	#4,d2
	move.b	d2,d1
	and.w	#$0f,d1
	move.b	HexDigits-x(a5,d1.w),(a0)+
	dbra	d0,1$
	rts

HexW:	lea	HexBufferW-x(a5),a0	;Wandelt #$24 in D2
	moveq	#3,d0			;nach "24" in HexPuffer um
1$	rol.w	#4,d2
	move.b	d2,d1
	and.w	#$0f,d1
	move.b	HexDigits-x(a5,d1.w),(a0)+
	dbra	d0,1$
	rts

HexB:	lea	HexBufferB-x(a5),a0	;Wandelt #$24 in D2
	moveq	#1,d0			;nach "24" in HexPuffer um
1$	rol.b	#4,d2
	move.b	d2,d1
	and.w	#$0f,d1
	move.b	HexDigits-x(a5,d1.w),(a0)+
	dbra	d0,1$
	rts

;**********************************
;	DirektHexOutput nach (a4)+ (mit und ohne Vorz.)
;**********************************

HexDDi:	move.l	(a0)+,d2
	bsr.b	HexLDi
	move.l	(a0),d2
	bsr.b	HexDD
	rts

HexXDi:	move.l	(a0)+,d2
	bsr.b	HexLDi
	move.l	(a0)+,d2
	bsr.b	HexDD
	move.l	(a0),d2
	bsr.b	HexDD
	rts

HexLs:	tst.l	d2
	bpl.b	HexLDi
	move.b	#'-',(a4)+
	neg.l	d2
HexLDi:	move.b	#'$',(a4)+
HexDD:	moveq	#7,d0
1$	rol.l	#4,d2
	move.b	d2,d1
	and.w	#$0f,d1
	move.b	HexDigits-x(a5,d1.w),(a4)+
	dbra	d0,1$
	rts

HexWs:	tst.w	d2
	bpl.b	HexWDi
	move.b	#'-',(a4)+
	neg.w	d2
HexWDi:	move.b	#'$',(a4)+
HexWDip	moveq	#3,d0
1$	rol.w	#4,d2
	move.b	d2,d1
	and.w	#$0f,d1
	move.b	HexDigits-x(a5,d1.w),(a4)+
	dbra	d0,1$
	rts

HexBs:	tst.b	d2
	bpl.b	HexBDi
	move.b	#'-',(a4)+
	neg.b	d2
HexBDi:	move.b	#'$',(a4)+
HexBDip	moveq	#1,d0
1$	rol.b	#4,d2
	move.b	d2,d1
	and.w	#$0f,d1
	move.b	HexDigits-x(a5,d1.w),(a4)+
	dbra	d0,1$
	rts

;**********************************
;	Control-C Check
;**********************************

CheckC:	movem.l	d1/a6,-(SP)
	move.l	4,a6
	moveq	#0,d0			;keine Signale ändern
	moveq	#0,d1			;Maske auch auf NULL
	jsr	_LVOSetSignal(a6)	;test auf CTRL-C
	movem.l	(SP)+,d1/a6
	btst	#12,d0
	bne	Aborted		;END: Aborted by USER
	rts

