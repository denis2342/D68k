;
;	D68k - Disassembler von Denis Ahrens (C) 2014
;
;	Only for OS 2.0 and higher
;
;	Assembliert mit A68k 2.71 ,SLink 6.58 und small.lib
;
; vasm -nosym -Fhunkexe D68k.asm -o D68k -I include -esc

 include 'exec/exec_lib.i'
 include 'dos/dos_lib.i'

D68k_Version	MACRO
			dc.b	'2.1.2'
		ENDM

D68k_Datum	MACRO
			dc.b	'17.01.2017'
		ENDM

TabSize		equ	6	;2^6 (#64 or $40)= groesse der Tabelle pro Hunk
LabelMemSize	equ	256*1024	;Speicher fuer Labeltabelle
SprungMemSize	equ	064*1024	;Speicher fuer Sprungmerker

JumpTablePointerListSize	equ	1024

	SECTION "D68k_Main",CODE

_main:	lea	x,a5

	move.l	SP,GoBack-x(a5)	;Stack fuer Ruecksprung retten
	move.b	#10,Buffer+10-x(a5)

	move.l	(4).w,a6		;DosLib oeffnen
	lea	DosName,a1
	moveq	#37,d0		;Version 37
	jsr	_LVOOpenLibrary(a6)
	move.l	d0,DosBase-x(a5)
	beq	Error		;wenn nicht gelungen abbrechen

	move.l	#Intro,d1
	moveq	#IntroE-Intro,d2
	bsr	PrintText

	bsr	GetOptions

;--------------------------------

	bsr	DateiO1		;Datei1 oeffnen
	bsr	Speicher	;Speicher fuer File
	bsr	Einladen	;File wird in den Speicher geladen
	bsr	DateiCloseHD1	;Datei1 schliessen
	bsr	MakeIDFile	;Nur wenn Trace an ist, ID-File erstellen

	bsr	PrePASS1	;Hunks zaehlen
	bsr	PrePASS2	;Hunktabelle mit den Werten fuellen
	bsr	PASS1		;Erstmal die Adressen aller Labels speichern

	bsr	DateiO2		;Datei2 fuer Ausgabe oeffnen (eventuell)
	bsr	PASS2		;Disassembler mit Ausgabe

;--------------------------------

Error4:	bsr	SpeicherBack

Error2:	move.l	#IntroE-1,d1	;Cursor setzen
	moveq	#4,d2
	bsr	PrintText

	move.l  FileHD2-x(a5),d1        ;File zum saven
	bsr	DateiClose		;SaveFile schliessen

4$	move.l	DosBase-x(a5),a6
	move.l	ArgsBack-x(a5),d1
	jsr	_LVOFreeArgs(a6)

	move.l	DosBase-x(a5),a6
	move.l	Output_fh-x(a5),d1	;ev. Output schliessen
	beq.b	2$
	jsr	_LVOClose(a6)

2$	move.l	4,a6

	move.l	DosBase-x(a5),a1		;DosLib schliessen
	jsr	_LVOCloseLibrary(a6)

Error:	move.l	GoBack-x(a5),SP
	rts			;und Ende

;********************************************************

;**********************************
;	Pass2	DisAssemblieren
;**********************************

PASS2:	move.l	HunkAnzahl-x(a5),d2	;Anzahl der Hunks
	bsr	HexOutPutL
	bsr	Space

	move.l	HunkMem-x(a5),d2	;HunkTab Adresse
	bsr	HexOutPutL
	bsr	Space

	move.l	HunkMemLen-x(a5),d2	;HunkTab Laenge
	bsr	HexOutPutL
	bsr	Space

	move.l	HunkAnzahl-x(a5),d3
	lsl.l	#2,d3
	move.l	HunkAdd-x(a5),d2	;Laenge von HunkAdd
	sub.l	d3,d2
	bsr	HexOutPutL
	bsr	Space

	move.l	LabelMem-x(a5),d2	;LabelTabellen Adresse
	bsr	HexOutPutL
	bsr	Space

	move.l	LabelMax-x(a5),d2	;LabelTabellen Max Eintraege
	bsr	HexOutPutL
	bsr	Space

	move.l	LabelMin-x(a5),d2	;LabelTabellen Min Eintraege
	bsr	HexOutPutL
	bsr	Space

	move.l	HunkMem-x(a5),a2
	move.l	52(a2),d2		;direkt vom ersten Hunk !!
	bsr	HexOutPutL
	bsr	Return

	move.l	Memory-x(a5),a2
	clr.l	CurrHunk-x(a5)		;Erster Hunk faengt jetzt an
	clr.l	LabelPointer-x(a5)

NextHunk
	move.l	FileSize-x(a5),d0
	add.l	Memory-x(a5),d0
	cmp.l	a2,d0
	bls.b	EndCode		;Normales Ende
	bsr	CheckC		;Control C Check
	bsr	ExePASS2
	bra.b	NextHunk

EndCode	rts

;**********************************
;	Ende der Umsetzung
;**********************************

DoublePrint:
	clr.b	Vorzeichen-x(a5)	;erstmal loeschen
	move.b	#10,(a4)+
	move.l	a4,ErrorNumber-x(a5)
	lea	Befehl2-x(a5),a4

	tst.b	Argu3-x(a5)		;NOPC/S
	bne.b	1$

	addq.l	#7,a4	; platz fuer den PC schaffen

	moveq	#-1,d1
	cmp.l	ToAdd-x(a5),d1
	beq	DoubleOdd

	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	bsr	HexWDip		;auf jeden Fall ein WORD fuer Mnemonic

1$	move.l	PCounter-x(a5),d1	;Befehl(ToAdd+2) darf nicht groesser
	addq.l	#2,d1			;sein als der Rest des Programs
	add.l	ToAdd-x(a5),d1
	cmp.l	CodeSize-x(a5),d1
	bgt	EndMark		;Routine fuer letztes Fuellbyte

MarkOK:	tst.b	Argu3-x(a5)	;NOPC/S
	bne	MarkNotOK

	move.l	PCounter-x(a5),d4
	move.l	CurrHunk-x(a5),d6
	lsl.l	#TabSize,d6
	move.l	HunkMem-x(a5),a1
	add.l	8(a1,d6.l),d4		;theo. Labeladresse

	move.l	LabelMem-x(a5),a1
	add.l	LabelPointer-x(a5),a1

	move.l	Pointer-x(a5),a0
	addq.l	#2,a0

	tst.l	ToAdd-x(a5)
	beq	JO2

	bsr	PCHexWord0	;einmal fuer alle

	moveq	#2,d2
	cmp.l	ToAdd-x(a5),d2	;testen wieviel daten dazukommen
	bne.b	1$
	move.b	#9,(a4)+
	move.b	#9,(a4)+
	bra	JO

1$	bsr	PCHexWord1	;einmal fuer alle

	moveq	#4,d2
	cmp.l	ToAdd-x(a5),d2
	bne.b	2$
	move.b	#9,(a4)+
	move.b	#9,(a4)+
	bra	JO

2$	bsr	PCHexWord2	;einmal fuer alle

	moveq	#6,d2
	cmp.l	ToAdd-x(a5),d2
	bne.b	3$
	move.b	#9,(a4)+
	bra	JO

3$	bsr	PCHexWord3	;einmal fuer alle

	moveq	#8,d2
	cmp.l	ToAdd-x(a5),d2
	beq	JO

	bsr	PCHexWord4	;einmal fuer alle

	move.l	ToAdd-x(a5),d7
	lsr.l	#1,d7
	subq	#5,d7
	bra	loopd

loop	bsr	PCHexWord5
loopd	dbra	d7,loop
	bra	JO

JO2:	moveq	#9,d1
	move.b	d1,(a4)+		;drei TAB's ausgeben
	move.b	d1,(a4)+
	move.b	d1,(a4)+
JO:

MarkNotOK:
	move.b	#9,(a4)+	;Ein TAB mindestens !!

	lea	Befehl-x(a5),a0
	move.l	ErrorNumber-x(a5),d2
	sub.l	a0,d2
	bra.b	2$

1$	move.b	(a0)+,(a4)+
2$	dbra	d2,1$

	move.l	#Befehl2,d1	;und ausgeben
	move.l	a4,d2
	sub.l	d1,d2
	bsr	Print

	moveq	#2,d2		;naechsten Befehlsanfang ausrechnen
	add.l	ToAdd-x(a5),d2
	add.l	d2,PCounter-x(a5)
	rts

PCHexWord0:
	move.b	Relocmarke+0-x(a5),(a4)+	;erstmal ein Space

PCHexWordx:
	addq.l	#2,d4
	cmp.l	(a1),d4			;Label mit PCounter+2 vergleichen
	bne.b	1$
	move.b	#'~',-1(a4)		;anstelle von Space
	addq.l	#4,LabelPointer-x(a5)
	addq.l	#4,a1

1$	move.w	(a0)+,d2
	bra	HexWDip
;	rts		;AUTO RTS

PCHexWord1:
	move.b	Relocmarke+1-x(a5),(a4)+	;erstmal ein Space
	bra	PCHexWordx

PCHexWord2:
	move.b	Relocmarke+2-x(a5),(a4)+	;erstmal ein Space
	bra	PCHexWordx

PCHexWord3:
	move.b	Relocmarke+3-x(a5),(a4)+	;erstmal ein Space
	bra	PCHexWordx

PCHexWord4:
	move.b	Relocmarke+4-x(a5),(a4)+	;erstmal ein Space
	bra	PCHexWordx

PCHexWord5:
PCHexWord6:
PCHexWord7:
PCHexWord8:
PCHexWord9:
	move.b	Relocmarke+5-x(a5),(a4)+	;erstmal ein Space
	bra	PCHexWordx

EndMark:
	move.l	a4,-(SP)
	clr.l	ToAdd-x(a5)
	lea	Befehl-x(a5),a4
	move.l	#'dc.w',(a4)+
	move.b	#9,(a4)+
	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	bsr	HexWDi
	move.b	#10,(a4)+
	move.l	a4,ErrorNumber-x(a5)
	move.l	(SP)+,a4
	bra	MarkOK

DoubleOdd:
	move.l	Pointer-x(a5),a0
	move.b	(a0),d2
	bsr	HexBDip		;auf jeden Fall ein WORD fuer Mnemonic
	bra	JO2

 include 'D68k_PreP1.asm'
 include 'D68k_PreP2.asm'
 include 'D68k_PASS1.asm'
 include 'D68k_PASS2.asm'
 include 'D68k_ever.asm'
 include 'D68k_minis.asm'
 include 'D68k_init.asm'
 include 'D68k_code2.asm'
 include 'D68k_code1.asm'
 include 'D68k_fline.asm'
 include 'D68k_hdata.asm'
 include 'D68k_hbss.asm'
 include 'D68k_hsymb.asm'
 include 'D68k_hextern.asm'
 include 'D68k_hrel32.asm'

 DATA

pwrof10	dc.l	1000000000	;10   Es duerfen nur soviele
	dc.l	100000000	;09   Zeilen hier sein
	dc.l	10000000	;08   wie ausgegeben werden
	dc.l	1000000		;07   sollen.
	dc.l	100000		;06
	dc.l	10000		;05   Den Rest mit einem
	dc.l	1000		;04   Semikolon wegstreichen
	dc.l	100		;03   und nicht loeschen.
	dc.l	10		;02
	dc.l	1		;01

DosName		dc.b	'dos.library',0

ColonReturn:	dc.b	':'
RETURN:
FileLine1:	dc.b	10,10,';Disassembled File  : ',0
FileLine2:	dc.b	10,';FileSize in Bytes  : ',0
FileLinex:	dc.b	10,10,';',0

Tabulator:	dc.b	9,9,9,9

Intro:	dc.b	$9b,$30,$20,$70
InfoT:	dc.b	$9b,'33mD68k',$9b,'0m V'
	D68k_Version
	dc.b	' MC680x0,MC68881/82,MC68851 Disassembler',10
	dc.b	'Copyright '
	D68k_Datum
	dc.b	' by Denis Ahrens',10,10
IntroE:	dc.b	$9b,$20,$70

CheckID:	dc.b	0
		dc.b	'$VER: D68k '
		D68k_Version			;MACRO: "1.xx" vier Zeichen
SPACE:		dc.b	' ('
		D68k_Datum			;MACRO: "xx.xx.9x"
		dc.b	')'
CheckIDE:	dc.b	0

Argument:	dc.b	'FILE/A,TO/K,NOPC/S,INFO/S,HUNKLAB/S,RLO=RTSLOGICOFF/S,'
		dc.b	'NC=NOCODE/S,ND=NODATA/S,NB=NOBSS/S,DLO=DATALOGICOFF/S,'
		dc.b	'OLO=ORILOGICOFF/S,NL=NEXTLABEL/S,TRACE/S,JL=JUMPLIST/S,'
		dc.b	'68020/S,HEXDATA/S',0

;HunkEndText:	dc.b	10,9,9,9,9,';Hunk-END',10,10
;HunkEndTextEnd:
;HunkEndText2:	dc.b	10,';Hunk-END',10,10
;HunkEndTextEnd2:

Status1T	dc.b	'File-Size   : '
Status2T	dc.b	'Hunks       : '
Status3T	dc.b	'Labels max  : '
Status4T	dc.b	'Labels      : '
Status5T	dc.b	'Ill. Codes  : '
Status6T	dc.b	'Code-Labels : '
Status7T	dc.b	'JumpList    : '
Status8T	dc.b	'Reloc32     : '
Status9T	dc.b	'Reloc16     : '
StatusAT	dc.b	'Reloc08     : '
StatusBT	dc.b	'Symbols     : '
StatusCT	dc.b	'Ill. Addr.  : '
StatusDT	dc.b	'Reloc32short: '
StatusET	dc.b	'Reloc16short: '
StatusFT	dc.b	'Reloc08short: '
StatusGT

Boot1T	dc.b	'Disk-Type  : '
Boot2T	dc.b	'CheckSum   : '
Boot3T	dc.b	'RootBlock  : '
Boot4T

Error1T	dc.b	"Can't load the File: "
Error2T	dc.b	"Can't get the Memory I need: "
Error3T	dc.b	"^C ** Aborted by USER"
Error4T	dc.b	"Too much Labels for allocated LabelMem !"
Error5T dc.b	10,"I found an unknown-Hunk (4) Internal Error",10
Error6T dc.b	10,"I found an unknown-Hunk (1)",10
Error7T dc.b	10,"I found an unknown-Hunk (2) Internal Error",10
Error8T dc.b	10,"I found an unknown-Hunk (3) Internal Error",10
Error9T	dc.b	"File too small for the described Hunks (POINTER OUT OF RANGE?)",10
ErrorAT dc.b	"FileID of the File is not equal with the loaded JumpList.",10
	dc.b	"No Adresses were added to the internal JumpList.",10
ErrorBT dc.b	"FileID of the File is not equal with the loaded JumpList",10

FileIDText:	dc.b	";",10,"; D68k V"
		D68k_Version
		dc.b	" JumpList for '"
FileIDText1:
		dc.b	"' Vx.x",10,";",10,10
FileIDText2:

 BSS

x:
DosBase:	dc.l	0	;Zeiger auf DosBase

FileHD:		dc.l	0	;FileHD auf File zum einladen
FileHD2:	dc.l	0	;FileHD auf File zum saven
FileHD3:	dc.l	0	;FileHD auf Jumplist-File
FileID:		dc.l	0	;ID des Files fuer Jumplist-File
Memory:		dc.l	0	;Speicher in den das File geladen wird
JLMem:		dc.l	0	;Speicher fuer das Jumplist-File
FileSize:	dc.l	0	;FileLaenge

Output_fh:	dc.l	0
PRGName:	dc.l	0	;Zeiger auf Programmname

Argu:
Argu1:		dc.l	0	;FILE
Argu2:		dc.l	0	;TO/K
Argu3:		dc.l	0	;NOPC/S
Argu4:		dc.l	0	;INFO/S
Argu5:		dc.l	0	;HUNKLAB/S
Argu6:		dc.l	0	;RLO=RTSLOGICOFF/S
Argu7:		dc.l	0	;NC=NOCODE/S
Argu8:		dc.l	0	;ND=NODATA/S
Argu9:		dc.l	0	;NB=NOBSS/S
ArguA:		dc.l	0	;DLO=DATALOGICOFF/S
ArguB:		dc.l	0	;OLO=ORILOGICOFF/S
ArguC:		dc.l	0	;NL=NEXTLABEL/S
ArguD:		dc.l	0	;TRACE/S
ArguE:		dc.l	0	;JL=JUMPLIST/S
ArguF:		dc.l	0	;68020/S
ArguG:		dc.l	0	;HEXDATA/S

ArgsBack:	dc.l	0	;Zeiger fuer FreeArgs()

LabelMem:	dc.l	0	;Speicher fuer die Labeltabelle
SprungMem:	dc.l	0	;Speicher fuer die Sprungtabelle
LabelPointer:	dc.l	0	;Zeiger auf freien Platz in der Labeltabelle
SprungPointer:	dc.l	0	;Zeiger auf freien Platz in der Sprungtabelle
LabelMin:	dc.l	0	;sortierte Anzahl der Label
LabelMax:	dc.l	0	;unsortierte Anzahl der Label
NextLabel:	dc.l	0	;Laenge in Bytes bis zum naechsten Label/HunkEnde
LastLabel:	dc.l	0	;Label der Jumptabelle

HunkAnzahl:	dc.l	0	;Anzahl der Hunks
HunkMem:	dc.l	0	;Speicher fuer HunkTabelle
HunkMemLen:	dc.l	0	;Laenge der HunkTabelle
HunkAdd:	dc.l	0

CurrHunk:	dc.l	0	;Aktueller Hunk (fuer Ausgabe)
HunkForm1:	dc.l	0	;Speicher1 fuer HunkNamenausgabe
HunkForm2:	dc.l	0	;Speicher2 fuer HunkNamenausgabe
HunkForm3:	dc.l	0	;Speicher3 fuer HunkNamenausgabe

CodeSize:	dc.l	0	;CodeLaenge
CodeAnfang:	dc.l	0	;Zeiger auf CodeAnfang

PCounter:	dc.l	0	;Zeiger auf (PC)
Pointer:	dc.l	0	;CodeAnfang+PCounter
ToAdd:		dc.l	0	;Zwischenspeicher fuer Befehlslaenge

RelocXAdress:	dc.l	0	;Adresse des Relocs im Hunk

Mnemonic:	dc.l	0	;Zwischenspeicher fuer Befehlstext
ErrorNumber:	dc.l	0	;Speicher fuer ReturnCode
GoBack:		dc.l	0	;A7 {SP} fuer Ruecksprung von ueberall

ICodesP1:	dc.l	0	;Anzahl der illeg. Befehle im ersten LOOP
IllPC:		dc.l	0	;Adresse des letzten illegalen Befehls
Symbole:	dc.l	0	;Anzahl der Symbole

Relocs32:	dc.l	0	;Anzahl der Reloc32-Einträge
Relocs16:	dc.l	0	;Anzahl der Reloc16-Einträge
Relocs08:	dc.l	0	;Anzahl der Reloc08-Einträge

DRelocs32:	dc.l	0	;Anzahl der DReloc32-Einträge
DRelocs16:	dc.l	0	;Anzahl der DReloc16-Einträge
DRelocs08:	dc.l	0	;Anzahl der DReloc08-Einträge

NULL:		dc.l	0	;Da wird ev. ein Zeiger draufgelenkt!

ROMaddress:	dc.l	0	;Adresse wo das ROM hingemappt wird (z.B. $F80000 fuer Kickroms)

Label:		dc.l	0	;Label Zwischenspeicher
Adressposs:	dc.w	0	;Erlaubte Adressierungsarten
AdMode:		dc.w	0	;AdressingModeWORD Zwischenspeicher

CodeID:		dc.w	0	;Zahlen zur internen schnellen Befehlserkennung
LastCodeID:	dc.w	0	;Vorheriger Befehl war: LastCodeID
Jumps:		dc.w	0	;Die fuer die Laenge der Jumptables (hoffentlich)
		dc.w	0

LastMove:	dc.l	0	;
LastMoveAdress:	dc.l	0	;Adresse des letzten Movebefehls

ExternSize:	dc.w	0

ToAdd:		dc.l	0	;Zwischenspeicher fuer Befehlslaenge

Hexminus2:	dc.b	0
Hexminus:	dc.b	0
HexBufferL:	dc.b	0,0,0,0	;muss immer gerade sein
HexBufferW:	dc.b	0,0
HexBufferB:	dc.b	0,0
Hexplus:	dc.b	0
Hexplus2:	dc.b	0

	dc.b	0,0			;eins muss vor Buffer sein
Buffer:	dc.b	0,0,0,0,0,0,0,0,0,0	;muss immer gerade sein
	dc.b	0

 CNOP 0,4
		ds.b	3
Befehltab:	dc.b	0
Befehl:		ds.b	200	;muss immer gerade sein
Befehl2:	ds.b	200
SizeBWL:	dc.b	0
RegArt:		ds.b	2
Vorzeichen:	dc.b	0
DataRem:	dc.b	0
LabelYes:	dc.b	0
Springer:	dc.b	0
WallPoint:	dc.b	0
JumpTableOn:	dc.b	0
Libby:		dc.b	0
KICK:		dc.b	0

 CNOP 0,4

Relocmarke:	ds.b	10

 CNOP 0,4

FIB:		ds.b	260	;FileInfoBlock
FIB2:		ds.b	260	;FileInfoBlock

 CNOP 0,4

Name:		ds.b	1024

 END
