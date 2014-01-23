;
;	D68k.minis2 von Denis Ahrens 1990-1994
;

;*****************************************************

GetOptions:

	move.l	DosBase-x(a5),a6
	move.l	#Argument,d1	;FILE/A,TO/K,NOPC/S
	move.l	#Argu,d2
	moveq	#0,d3
	jsr	_LVOReadArgs(a6)
	move.l	d0,ArgsBack-x(a5)
	beq	FehlerMeldung
2$	rts

;*****************************************************

FehlerMeldung:
	move.l	DosBase-x(a5),a6
	jsr	_LVOIoErr(a6)	;Falls keine Argumente da sind
	move.l	d0,d1
	beq.b	1$
	moveq	#0,d2
	jsr	_LVOPrintFault(a6)	;den grund des Fehlers ausgeben
1$	bra	Error4

;**********************************
;	Konnte Datei nicht laden
;**********************************

ErrorDatei2:
	bsr	DateiC1
ErrorDatei:
	move.l	#Error1T,d1
	moveq	#Error2T-Error1T,d2
	bsr	PrintText
	bra	FehlerMeldung

;**********************************
;	Konnte nicht genug Mem kriegen
;**********************************

ErrorMemory:
	move.l	#Error2T,d1
	moveq	#Error3T-Error2T,d2
	bsr	PrintText
	bra	FehlerMeldung

;**********************************
;	Wurde vom Benutzer abgebrochen
;**********************************

Aborted	move.l	#Error3T,d1
	moveq	#Error4T-Error3T,d2
	bsr	PrintText
	bra	Error4

;**********************************
;	Zuviele Labels wurden gefunden
;**********************************

LabelMemSizeError:
;	eor.b	#2,$bfe001		;LED zurückflippen
	move.l	#Error4T,d1
	moveq	#Error5T-Error4T,d2
	bsr	PrintText
	bra	FehlerMeldung

;**********************************
;	Ausgabe-Routine
;**********************************

PrintText:
	move.l	DosBase-x(a5),a6
	jsr	_LVOWriteChars(a6)
	tst.l	d0
	bmi.b	Aborted
	rts

;**********************************
;	Ausgabe-Routine
;**********************************

Print:	tst.l	FileHD2-x(a5)
	beq.b	PrintText

	movem.l	d3-d4,-(SP)

	move.l	d2,d3
	move.l	d1,d2

	moveq	#1,d4		;anzahl der buffer

	move.l	FileHD2-x(a5),d1

	move.l	DosBase-x(a5),a6
	jsr	_LVOFWrite(a6)
	tst.l	d0
	bmi	Aborted

	movem.l	(SP)+,d3-d4
	rts

;**********************************
;	File für Arbeit öffnen
;**********************************

DateiO1:
	move.l	Argu1-x(a5),d1	;Argument von der Optionszeile holen
	beq	ErrorDatei	;konnte nicht geöffnet werden

2$	move.l	#1005,d2	;Modus 'Lesen'
	move.l	DosBase-x(a5),a6
	jsr	_LVOOpen(a6)
	move.l	d0,FileHD-x(a5)
	beq	ErrorDatei	;konnte nicht geöffnet werden

	bsr	DateiL		;Dateilänge holen

	rts

DateiO2:
	move.l	Argu2-x(a5),d1	;File für ausgabe öffnen
	beq	1$

	move.l	DosBase-x(a5),a6
	move.l	#1006,d2	;Modus 'Neu'
	jsr	_LVOOpen(a6)	;Name kommt durchs Argument
	move.l	d0,FileHD2-x(a5)
	beq	ErrorDatei	;konnte nicht geöffnet werden

	moveq	#';',d0
	move.b	d0,CheckID

	move.l	#CheckID,d1
	moveq	#CheckIDE-CheckID,d2
	bsr	Print

	move.l	FileHD2-x(a5),d1
	move.l	#FileLine1,d2
	jsr	_LVOFPuts(a6)

	move.l	FileHD2-x(a5),d1
	lea	FIB+8-x(a5),a0
	move.l	a0,d2			;FileName
	jsr	_LVOFPuts(a6)

	move.l	FileHD2-x(a5),d1
	move.l	#FileLine2,d2
	jsr	_LVOFPuts(a6)

	move.l	FileSize-x(a5),d2
	bsr	DecL
	clr.b	Buffer+10-x(a5)
	move.l	FileHD2-x(a5),d1
	move.l	#Buffer+3,d2		;Filelänge
	jsr	_LVOFPuts(a6)

	move.l	FileHD2-x(a5),d1
	move.l	#FileLinex,d2
	jsr	_LVOFPuts(a6)

	move.l	FileHD2-x(a5),d1
	clr.l	d2			;keinen eigenen Buffer
	moveq	#1,d3
	move.l	#65536,d4
	jsr	_LVOSetVBuf(a6)

	move.l	Argu2-x(a5),d1		;File
	moveq	#2,d2			;Maske = 1 Bit für 'Not Executable'
	jsr	_LVOSetProtection(a6)
1$	rts

;**********************************
;	File wieder schließen
;**********************************

DateiC1	move.l	DosBase-x(a5),a6	;geladenes File
	move.l	FileHD-x(a5),d1
	beq.b	1$
	jsr	_LVOClose(a6)
1$	rts

DateiC2	move.l	DosBase-x(a5),a6
	move.l	FileHD2-x(a5),d1	;File zum saven
	beq.b	1$
	jsr	_LVOClose(a6)
1$	rts

;**********************************
;	FileSize ermitteln
;**********************************

DateiL:	move.l	DosBase-x(a5),a6
	move.l	FileHD-x(a5),d1
	move.l	#FIB,d2
	jsr	_LVOExamineFH(a6)	;Examine mit FileHandle
	tst.l	d0
	beq	ErrorDatei
	lea	FIB-x(a5),a0
	move.l	124(a0),FileSize-x(a5)
	beq	ErrorDatei2

	lea	8(a0),a1

3$	tst.b	(a1)+
	bne.b	3$

	subq.l	#1,a1

	cmp.b	#"y",-(a1)		;muß auch noch mit großen Buchstaben
	bne.b	2$			;klarkommen.
	cmp.b	#"r",-(a1)
	bne.b	2$
	cmp.b	#"a",-(a1)		;NOTLOESUNG !!!
	bne.b	2$
	cmp.b	#"r",-(a1)
	bne.b	2$
	cmp.b	#"b",-(a1)
	bne.b	2$
	cmp.b	#"i",-(a1)
	bne.b	2$
	cmp.b	#"l",-(a1)
	bne.b	2$
	cmp.b	#".",-(a1)
	bne.b	2$

	move.b	#1,Libby-x(a5)

	move.l	#1,ArguD-x(a5)		;TRACE-Mode einschalten !!!

2$	tst.b	Argu4-x(a5)	;INFO/S
	beq.b	1$

		move.l	#Status1T,d1		;Dateilänge ausgeben
		moveq	#Status2T-Status1T,d2
		bsr	PrintText
		move.l	FileSize-x(a5),d2
		bsr	WriteInfoText

1$	rts

;**********************************
;	Speicher für File
;**********************************

Speicher:
	move.l	4,a6

	move.l	FileSize-x(a5),d0
	moveq	#0,d1
	jsr	_LVOAllocVec(a6)
	move.l	d0,Memory-x(a5)
	beq	ErrorMemory

	move.l	#LabelMemSize,d0
	move.l	#$10000,d1		;Egal welcher aber NULL
	jsr	_LVOAllocVec(a6)
	move.l	d0,LabelMem-x(a5)
	beq	ErrorMemory

	tst.b	ArguD-x(a5)	;TRACE/S
	beq.b	1$

	move.l	#SprungMemSize,d0
	move.l	#$10000,d1		;Egal welcher aber NULL
	jsr	_LVOAllocVec(a6)
	move.l	d0,SprungMem-x(a5)
	beq	ErrorMemory

1$	rts

;**********************************
;	Speicher freigeben
;**********************************

SpeicherBack:
	move.l	4,a6

	tst.l	HunkMem-x(a5)
	beq.b	1$

	move.l	HunkMem-x(a5),a2
	move.l	HunkAnzahl-x(a5),d7
	subq.l	#1,d7

6$	move.l	d7,d6
	lsl.l	#TabSize,d6
	move.l	32(a2,d6.l),a1
	jsr	_LVOFreeVec(a6)		;und ein 1/16 freigeben

	move.l	52(a2,d6.l),a1
	jsr	_LVOFreeVec(a6)

	dbf	d7,6$

	move.l	HunkMem-x(a5),a1	;Für die Hunktabelle
	jsr	_LVOFreeVec(a6)

1$	move.l	Memory-x(a5),a1		;Für das File
	jsr	_LVOFreeVec(a6)

	move.l	LabelMem-x(a5),a1	;Für die Labeltabelle
	jsr	_LVOFreeVec(a6)

	move.l	SprungMem-x(a5),a1	;Für die Labeltabelle
	jsr	_LVOFreeVec(a6)

	rts

;**********************************
;	File in den Speicher laden
;**********************************

Einladen:
	move.l	FileHD-x(a5),d1		;Dieses File
	move.l	Memory-x(a5),d2		;in diesen Speicher
	move.l	FileSize-x(a5),d3	;mit dieser Länge
	move.l	DosBase-x(a5),a6
	jsr	_LVORead(a6)		;und los geht's
	moveq	#-1,d3
	cmp.l	d3,d0
	beq	ErrorDatei

	bsr	GetFileID	;Ergebnis wird in FileID übergeben

	rts

