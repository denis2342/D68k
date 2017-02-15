;
;	F-LINE Befehle fuer D68k von Denis Ahrens
;

; F-Line fuer Ausgabe

c_fline:
	tst.b	ArguF-x(a5)
	beq	OpCode1

	move.w	(a0),d0
;	andi.w	#%1111111111111111,d0
	cmp.w	#%1111001001111010,d0	;FTRAPcc 68881/2 68040
	beq	f_ftrapcc
	cmp.w	#%1111001001111011,d0	;FTRAPcc 68881/2 68040
	beq	f_ftrapcc
	cmp.w	#%1111001001111100,d0	;FTRAPcc 68881/2 68040
	beq	f_ftrapcc
	cmp.w	#%1111100000000000,d0	;LPSTOP 68060 !!!
	beq	x_lpstop

	move.w	d0,d7
	andi.w	#%1111111111111000,d0
	cmp.w	#%1111011000100000,d0	;MOVE16 68040
	beq	f_move16_1
	cmp.w	#%1111000001111000,d0	;PTRAPcc 68851
	beq	f_ptrapcc
	cmp.w	#%1111001001001000,d0	;FDBcc 6888x
	beq	f_fdbcc
	cmp.w	#%1111000001001000,d0	;PDBcc 68851
	beq	f_pdbcc
	cmp.w	#%1111010101101000,d0	;PTESTR 68040
	beq	p_ptestr
	cmp.w	#%1111010101001000,d0	;PTESTW 68040
	beq	p_ptestw
	cmp	#%1111010110001000,d0	;PLPAW
	beq	p_plpaw
	cmp	#%1111010111001000,d0	;PLPAR
	beq	p_plpar

;	move.w	d7,d0
	andi.w	#%1111111111100000,d0
	cmp.w	#%1111011000000000,d0	;MOVE16 68040
	beq	f_move16_2
	cmp.w	#%1111010100000000,d0	;PFLUSH 68040
	beq	p_pflush040

;	move.w	d7,d0
	andi.w	#%1111111111000000,d0
	cmp.w	#%1111001000000000,d0	;FLINE STANDARD
	beq	f_fcom
	cmp.w	#%1111000000000000,d0	;PMMU  STANDARD
	beq	p_pcom
	cmp.w	#%1111001100000000,d0	;FSAVE 6888x/68040
	beq	f_fsave
	cmp.w	#%1111000100000000,d0	;PSAVE 68851
	beq	p_psave
	cmp.w	#%1111001101000000,d0	;FRESTORE 6888x/68040
	beq	f_frestore
	cmp.w	#%1111000101000000,d0	;PRESTORE 68851
	beq	p_prestore
	cmp.w	#%1111001001000000,d0	;FScc 6888x
	beq	f_fscc
	cmp.w	#%1111000001000000,d0	;PScc 68851
	beq	f_pscc

	move.w	d7,d0
	andi.w	#%1111111100100000,d0
	cmp.w	#%1111010000000000,d0	;CINV 68040
	beq	f_cinv
	cmp.w	#%1111010000100000,d0	;CPUSH 68040
	beq	f_cpush

	move.w	d7,d0
	andi.w	#%1111111110000000,d0
	cmp.w	#%1111001010000000,d0	;FBcc 6888x
	beq	f_fbcc
	cmp.w	#%1111000010000000,d0	;PBcc 68851
	beq	f_pbcc

	bra	OpCodeError	;doch kein F-Line Befehl

p_pcom
	move.w	2(a0),d0
;	and.w	#%1111111111111111,d0
	cmp.w	#%1010000000000000,d0	;PFLUSHR 68851
	beq	p_pflushr
	cmp.w	#%0010100000000000,d0	;PVALID VAL 68851
	beq	p_pvalidv

;	move.w	2(a0),d0
	and.w	#%1111111111111000,d0
	cmp.w	#%0010110000000000,d0	;PVALID Ax 68851
	beq	p_pvalida

;	move.w	2(a0),d0
	and.w	#%1111110111100000,d0
	cmp.w	#%0010000000000000,d0	;PLOAD 68851 & 68030
	beq	p_pload

	move.w	2(a0),d0
	and.w	#%1111100111111111,d0
	cmp.w	#%0110000000000000,d0	;PMOVE 68851
	beq	p_pmove3_851

;	move.w	2(a0),d0
	and.w	#%1111000111111111,d0
	cmp.w	#%0100000100000000,d0	;PMOVEFD 68030
	beq	p_pmove1_030

;	move.w	2(a0),d0
	and.w	#%1110000111111111,d0
	cmp.w	#%0100000000000000,d0	;PMOVE 68851
	beq	p_pmove1_851

	move.w	2(a0),d0
	and.w	#%1111100011111111,d0
	cmp.w	#%0000100000000000,d0	;PMOVE 68030
	beq	p_pmove2_030

	move.w	2(a0),d0
	and.w	#%1111100111100011,d0
	cmp.w	#%0111000000000000,d0	;PMOVE 68851
	beq	p_pmove2_851

	move.w	2(a0),d0
	and.w	#%1110001000000000,d0
	cmp.w	#%0010000000000000,d0	;PFLUSH 68851 (68030)
	beq	p_pflush

;	move.w	2(a0),d0
	and.w	#%1110000000000000,d0
	cmp.w	#%1000000000000000,d0	;PTEST 68851 & 68030
	beq	p_ptest

	bra	OpCodeError	;doch kein F-Line Befehl

f_fcom:
	move.w	2(a0),d0
	and.w	#%1111110000000000,d0
	cmp.w	#%0101110000000000,d0	;FMOVE CONSTANT ROM
	beq	f_fmovecrom

	move.w	2(a0),d0
	and.w	#%1010000001111111,d0
	cmp.w	#%0000000000000000,d0	;FMOVE (memory to register)
	beq	f_fmove
	cmp.w	#%0000000000000001,d0	;FINT
	beq	f_fint
	cmp.w	#%0000000000000010,d0	;FSINH
	beq	f_fsinh
	cmp.w	#%0000000000000011,d0	;FINTRZ
	beq	f_fintrz
	cmp.w	#%0000000000000100,d0	;FSQRT
	beq	f_fsqrt
	cmp.w	#%0000000000000110,d0	;FLOGNP1
	beq	f_flognp1
	cmp.w	#%0000000000001000,d0	;FETOXM1
	beq	f_fetoxm1
	cmp.w	#%0000000000001001,d0	;FTANH
	beq	f_ftanh
	cmp.w	#%0000000000001010,d0	;FATAN
	beq	f_fatan
	cmp.w	#%0000000000001100,d0	;FASIN
	beq	f_fasin
	cmp.w	#%0000000000001101,d0	;FATANH
	beq	f_fatanh
	cmp.w	#%0000000000001110,d0	;FSIN
	beq	f_fsin
	cmp.w	#%0000000000001111,d0	;FTAN
	beq	f_ftan
	cmp.w	#%0000000000010000,d0	;FETOX
	beq	f_fetox
	cmp.w	#%0000000000010001,d0	;FTWOTOX
	beq	f_ftwotox
	cmp.w	#%0000000000010010,d0	;FTENTOX
	beq	f_ftentox
	cmp.w	#%0000000000010101,d0	;FLOG10
	beq	f_flog10
	cmp.w	#%0000000000010110,d0	;FLOG2
	beq	f_flog2
	cmp.w	#%0000000000010100,d0	;FLOGN
	beq	f_flogn
	cmp.w	#%0000000000011000,d0	;FABS
	beq	f_fabs
	cmp.w	#%0000000000011001,d0	;FCOSH
	beq	f_fcosh
	cmp.w	#%0000000000011010,d0	;FNEG
	beq	f_fneg
	cmp.w	#%0000000000011100,d0	;FACOS
	beq	f_facos
	cmp.w	#%0000000000011101,d0	;FCOS
	beq	f_fcos
	cmp.w	#%0000000000011110,d0	;FGETEXP
	beq	f_fgetexp
	cmp.w	#%0000000000011111,d0	;FGETMAN
	beq	f_fgetman
	cmp.w	#%0000000000100000,d0	;FDIV
	beq	f_fdiv
	cmp.w	#%0000000000100001,d0	;FMOD
	beq	f_fmod
	cmp.w	#%0000000000100010,d0	;FADD
	beq	f_fadd
	cmp.w	#%0000000000100011,d0	;FMUL
	beq	f_fmul
	cmp.w	#%0000000000100100,d0	;FSGLDIV
	beq	f_fsgldiv
	cmp.w	#%0000000000100101,d0	;FREM
	beq	f_frem
	cmp.w	#%0000000000100110,d0	;FSCALE
	beq	f_fscale
	cmp.w	#%0000000000100111,d0	;FSGLMUL
	beq	f_fsglmul
	cmp.w	#%0000000000101000,d0	;FSUB
	beq	f_fsub
	cmp.w	#%0000000000111000,d0	;FCMP
	beq	f_fcmp
	cmp.w	#%0000000000111010,d0	;FTST
	beq	f_ftst
	cmp.w	#%0000000001000000,d0	;FSMOVE
	beq	f_fsmove
	cmp.w	#%0000000001000001,d0	;FSSQRT
	beq	f_fssqrt
	cmp.w	#%0000000001000100,d0	;FDMOVE
	beq	f_fdmove
	cmp.w	#%0000000001000101,d0	;FDSQRT
	beq	f_fdsqrt
	cmp.w	#%0000000001011000,d0	;FSABS
	beq	f_fsabs
	cmp.w	#%0000000001011010,d0	;FSNEG
	beq	f_fsneg
	cmp.w	#%0000000001011100,d0	;FDABS
	beq	f_fdabs
	cmp.w	#%0000000001011110,d0	;FDNEG
	beq	f_fdneg
	cmp.w	#%0000000001100000,d0	;FSDIV
	beq	f_fsdiv
	cmp.w	#%0000000001100010,d0	;FSADD
	beq	f_fsadd
	cmp.w	#%0000000001100011,d0	;FSMUL
	beq	f_fsmul
	cmp.w	#%0000000001100100,d0	;FDDIV
	beq	f_fddiv
	cmp.w	#%0000000001100110,d0	;FDADD
	beq	f_fdadd
	cmp.w	#%0000000001100111,d0	;FDMUL
	beq	f_fdmul
	cmp.w	#%0000000001101000,d0	;FSSUB
	beq	f_fssub
	cmp.w	#%0000000001101100,d0	;FDSUB
	beq	f_fdsub

	move.w	2(a0),d0
	and.w	#%1010000001111000,d0
	cmp.w	#%0000000000110000,d0	;FSINCOS
	beq	f_fsincos

	move.w	2(a0),d0
	and.w	#%1100001111111111,d0
	cmp.w	#%1000000000000000,d0	;FMOVEM system control register
	beq	f_fmovescr

	move.w	2(a0),d0
	and.w	#%1100011100000000,d0
	cmp.w	#%1100000000000000,d0	;FMOVEM data
	beq	f_fmovem

	move.w	2(a0),d0
	and.w	#%1110000000000000,d0
	cmp.w	#%0110000000000000,d0	;FMOVE (register to memory)
	beq	f_fmove2

	bra	OpCodeError

;****************************************************************

f_fsin:	move.l	#"FSIN",(a4)+
	bra	f_standard2

f_fsinh	move.l	#"FSIN",(a4)+
	move.b	#"H",(a4)+
	bra	f_standard2

f_fasin	move.l	#"FASI",(a4)+
	move.b	#"N",(a4)+
	bra	f_standard2

f_ftan	move.l	#"FTAN",(a4)+
	bra	f_standard2

f_ftanh	move.l	#"FTAN",(a4)+
	move.b	#"H",(a4)+
	bra	f_standard2

f_fatan	move.l	#"FATA",(a4)+
	move.b	#"N",(a4)+
	bra	f_standard2

f_fatanh
	move.l	#"FATA",(a4)+
	move.w	#"NH",(a4)+
	bra	f_standard2

f_fcos:	move.l	#"FCOS",(a4)+
	bra	f_standard2

f_fcosh	move.l	#"FCOS",(a4)+
	move.b	#"H",(a4)+
	bra	f_standard2

f_facos	move.l	#"FACO",(a4)+
	move.b	#"S",(a4)+
	bra	f_standard2

f_fcmp:	move.l	#"FCMP",(a4)+
	bra	f_standard

f_fetox	move.l	#"FETO",(a4)+
	move.b	#"X",(a4)+
	bra	f_standard2

f_fetoxm1
	move.l	#"FETO",(a4)+
	move.w	#"XM",(a4)+
	move.b	#"1",(a4)+
	bra	f_standard2

f_fgetexp
	move.l	#"FGET",(a4)+
	move.w	#"EX",(a4)+
	move.b	#"P",(a4)+
	bra	f_standard2

f_fgetman
	move.l	#"FGET",(a4)+
	move.w	#"MA",(a4)+
	move.b	#"N",(a4)+
	bra	f_standard2

f_fint	move.l	#"FINT",(a4)+
	bra	f_standard2

f_fintrz
	move.l	#"FINT",(a4)+
	move.w	#"RZ",(a4)+
	bra	f_standard2

f_flog10
	move.l	#"FLOG",(a4)+
	move.w	#"10",(a4)+
	bra	f_standard2

f_flog2	move.l	#"FLOG",(a4)+
	move.b	#"2",(a4)+
	bra	f_standard2

f_flogn	move.l	#"FLOG",(a4)+
	move.b	#"N",(a4)+
	bra	f_standard2

f_flognp1
	move.l	#"FLOG",(a4)+
	move.w	#"NP",(a4)+
	move.b	#"1",(a4)+
	bra	f_standard2

f_fmod	move.l	#"FMOD",(a4)+
	bra	f_standard

f_frem	move.l	#"FREM",(a4)+
	bra	f_standard

f_fscale
	move.l	#"FSCA",(a4)+
	move.w	#"LE",(a4)+
	bra	f_standard

f_fsgldiv
	move.l	#"FSGL",(a4)+
	move.w	#"DI",(a4)+
	move.b	#"V",(a4)+
	bra	f_standard

f_fsglmul
	move.l	#"FSGL",(a4)+
	move.w	#"MU",(a4)+
	move.b	#"L",(a4)+
	bra	f_standard

f_ftentox
	move.l	#"FTEN",(a4)+
	move.w	#"TO",(a4)+
	move.b	#"X",(a4)+
	bra	f_standard2

f_ftwotox
	move.l	#"FTWO",(a4)+
	move.w	#"TO",(a4)+
	move.b	#"X",(a4)+
	bra	f_standard2

f_fabs	move.l	#"FABS",(a4)+
	bra	f_standard2

f_fsabs	move.l	#"FSAB",(a4)+
	move.b	#"S",(a4)+
	bra	f_standard2

f_fdabs	move.l	#"FDAB",(a4)+
	move.b	#"S",(a4)+
	bra	f_standard2

f_fadd	move.l	#"FADD",(a4)+
	bra	f_standard

f_fsadd	move.l	#"FSAD",(a4)+
	move.b	#"D",(a4)+
	bra	f_standard

f_fdadd	move.l	#"FDAD",(a4)+
	move.b	#"D",(a4)+
	bra	f_standard

f_fsub	move.l	#"FSUB",(a4)+
	bra	f_standard

f_fssub	move.l	#"FSSU",(a4)+
	move.b	#"B",(a4)+
	bra	f_standard

f_fdsub	move.l	#"FDSU",(a4)+
	move.b	#"B",(a4)+
	bra	f_standard

f_fmul	move.l	#"FMUL",(a4)+
	bra	f_standard

f_fsmul	move.l	#"FSMU",(a4)+
	move.b	#"L",(a4)+
	bra	f_standard

f_fdmul	move.l	#"FDMU",(a4)+
	move.b	#"L",(a4)+
	bra	f_standard

f_fdiv	move.l	#"FDIV",(a4)+
	bra	f_standard

f_fsdiv	move.l	#"FSDI",(a4)+
	move.b	#"V",(a4)+
	bra	f_standard

f_fddiv	move.l	#"FDDI",(a4)+
	move.b	#"V",(a4)+
	bra	f_standard

f_fneg	move.l	#"FNEG",(a4)+
	bra	f_standard2

f_fsneg	move.l	#"FSNE",(a4)+
	move.b	#"G",(a4)+
	bra	f_standard2

f_fdneg	move.l	#"FDNE",(a4)+
	move.b	#"G",(a4)+
	bra	f_standard2

f_fsqrt	move.l	#"FSQR",(a4)+
	move.b	#"T",(a4)+
	bra	f_standard2

f_fssqrt
	move.l	#"FSSQ",(a4)+
	move.w	#"RT",(a4)+
	bra	f_standard2

f_fdsqrt
	move.l	#"FDSQ",(a4)+
	move.w	#"RT",(a4)+
	bra	f_standard2

f_fmove	move.l	#"FMOV",(a4)+
	move.b	#"E",(a4)+
	bra	f_standard

f_fsmove
	move.l	#"FSMO",(a4)+
	move.w	#"VE",(a4)+
	bra	f_standard

f_fdmove
	move.l	#"FDMO",(a4)+
	move.w	#"VE",(a4)+
	bra	f_standard

;**********************************
;	FSTANDARD 6888x/68040	Dyadic
;**********************************

f_standard
	addq.l	#2,ToAdd-x(a5)
	move.b	#".",(a4)+
	bsr	GetFSSP
	move.b	#9,(a4)+
	move.l	Pointer-x(a5),a0
	btst	#6,2(a0)
	bne.b	f_standard_sub

1$	move.b	#"X",-2(a4)				;R/M=0
	bsr	GetFSreg
	move.b	#',',(a4)+
	bsr	GetFDreg
	bra	DoublePrint

f_standard_sub:
	move.w	#%111111111101,d0		;R/M=1

	bsr	addressbitcheck

	move.w	d0,Adressposs-x(a5)
	bsr	GetSEA		;<ea> to register
	move.b	#',',(a4)+
	bsr	GetFDreg
	bra	DoublePrint

;**********************************
;	the possible addressmodes are already set in d0
;**********************************

addressbitcheck:
	move.b	SizeBWL-x(a5),d2

	cmp.b	#"B",d2
	beq.b	1$
	cmp.b	#"W",d2
	beq.b	1$
	cmp.b	#"L",d2
	beq.b	1$
	cmp.b	#"S",d2
	beq.b	1$

	bclr	#0,d0	; clear addressregister direct mode
	move.w	d0,Adressposs-x(a5)

1$	rts

;**********************************
;	FSTANDARD 6888x/68040 Monadic
;**********************************

f_standard2:
	addq.l	#2,ToAdd-x(a5)
	move.b	#".",(a4)+
	bsr	GetFSSP
	move.b	#9,(a4)+
	move.l	Pointer-x(a5),a0
	btst	#6,2(a0)
	bne.b	f_standard_sub

	move.b	#"X",-2(a4)				;R/M=0
	bsr	GetFSreg
	move.b	#',',(a4)+
	bsr	GetFDreg
	move.b	-1(a4),d0
	cmp.b	-5(a4),d0
	bne.b	3$
	subq.l	#4,a4
3$	bra	DoublePrint

;**********************************
;	FTST	6888x/68040
;**********************************

f_ftst:	move.l	#"FTST",(a4)+
	addq.l	#2,ToAdd-x(a5)
	move.b	#".",(a4)+
	bsr	GetFSSP
	move.b	#9,(a4)+
	move.l	Pointer-x(a5),a0
	btst	#6,2(a0)
	beq.b	1$

	move.w	#%111111111101,d0		;R/M=1

	bsr	addressbitcheck

	bsr	GetSEA		;<ea> to register
	bra	DoublePrint

1$	move.b	#"X",-2(a4)				;R/M=0
	bsr	GetFSreg
	bra	DoublePrint

;**********************************
;	FSINCOS	6888x/68040
;**********************************

f_fsincos
	addq.l	#2,ToAdd-x(a5)
	move.l	#"FSIN",(a4)+
	move.l	#"COS.",(a4)+
	bsr	GetFSSP
	move.b	#9,(a4)+
	move.l	Pointer-x(a5),a0
	btst	#6,2(a0)
	beq.b	1$

	move.w	#%111111111101,d0		;R/M=1

	bsr	addressbitcheck

	bsr	GetSEA		;<ea> to register
	bsr	GetFD2reg
	move.b	#':',(a4)+
	bsr	GetFDreg
	bra	DoublePrint

1$	move.b	#"X",-2(a4)				;R/M=0
	bsr	GetFSreg
	bsr	GetFD2reg
	move.b	#':',(a4)+
	bsr	GetFDreg
	bra	DoublePrint

;**********************************
;	FMOVE 2 (register to memory) 6888x/68040
;**********************************

f_fmove2:
	addq.l	#2,ToAdd-x(a5)
	move.l	#"FMOV",(a4)+
	move.w	#'E.',(a4)+
	bsr	GetFSSP

	move.w	#%000111111101,d0		;R/M=1

	bsr	addressbitcheck


	tst.b	-1(a4)
	beq.b	1$

	cmp.b	#"P",-1(a4)
	beq.b	2$

	move.b	#9,(a4)+	;no Factor
	bsr	GetFDreg
	move.b	#',',(a4)+
	bsr	GetSEA
	bra	DoublePrint

1$	move.b	#"P",-1(a4)	;Dynamic k Factor
	move.b	#9,(a4)+
	bsr	GetFDreg
	move.b	#',',(a4)+
	bsr	GetSEA
	move.b	#'{',(a4)+
	move.b	#'D',(a4)+
	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	lsr.b	#4,d2
	andi.b	#%00000111,d2
	add.b	#"0",d2
	move.b	d2,(a4)+
	move.b	#'}',(a4)+
	bra	DoublePrint

2$	move.b	#"P",-1(a4)	;Static k Factor
	move.b	#9,(a4)+
	bsr	GetFDreg
	move.b	#',',(a4)+
	bsr	GetSEA
	move.b	#'{',(a4)+
	move.b	#'#',(a4)+
	move.b	#'+',(a4)+

	move.l	Pointer-x(a5),a0
	move.l	(a0),d2
	btst	#6,d2
	beq.b	3$
	move.b	#'-',-1(a4)
3$	andi.l	#%00111111,d2
	bsr	DecL
	move.b	Buffer+8-x(a5),(a4)+
	move.b	Buffer+9-x(a5),(a4)+
	move.b	#'}',(a4)+
	bra	DoublePrint

;**********************************
;	FMOVEM.X	6888x/68040
;**********************************

f_fmovem:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)		;from memory

	move.l	#'FMOV',(a4)+
	move.l	#'EM.X',(a4)+
	move.b	#9,(a4)+

	move.w	2(a0),d2
	btst	#13,d2
	bne.b	2$

	move.w	#%011111101100,Adressposs-x(a5)
	bsr	GetSEA			;fuer Quell-Operand
	move.b	#',',(a4)+

	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	btst	#11,d2
	beq.b	1$

	move.b	#'D',(a4)+
	andi.b	#%01110000,d2
	lsr.b	#4,d2
	add.b	#"0",d2
	move.b	d2,(a4)+
	bra	DoublePrint

1$	bsr.b	fmmask
	bra	DoublePrint

2$	btst	#11,d2
	beq.b	3$

	move.b	#'D',(a4)+
	andi.b	#%01110000,d2
	lsr.b	#4,d2
	add.b	#"0",d2
	move.b	d2,(a4)+
	bra.b	4$

3$	bsr.b	fmmask

4$	move.b	#',',(a4)+
	move.w	#%000111110100,Adressposs-x(a5)
	bsr	GetSEA		;fuer Ziel-Operand
	bra	DoublePrint

fmmask:	move.l	Pointer-x(a5),a0
	clr.l	d0
	move.b	3(a0),d0		;get mask

	move.l	Pointer-x(a5),a0
	moveq	#%00111000,D1
	and.w	(a0),d1		;if '-(An)', reverse bits
	cmp.b	#%00100000,D1
	beq.b	fm20
	moveq	#7,d3
	moveq	#0,d1

fm10:	roxr.b	#1,d0
	roxl.b	#1,d1
	dbf	d3,fm10
	move.b	d1,d0

fm20:	clr.b	d2	;last bit not set
	moveq	#0,d1	;start with bit 0
	clr.b	d3	;no bytes deposited yet

fm1:	btst	d1,d0
	bne.b	fm2
	clr.b	d2
	bra.b	fm4

fm2:	addq.b	#1,D1	;glance next bit

	tst.b	D2	;last bit set?
	beq.b	fm3

	cmp.b	#8,D1	;was last register?
	beq.b	fm3

	btst	D1,D0	;end of range?
	beq.b	fm3

	cmp.b	#'-',D2	;already have hyphen?
	beq.b	fm5

	moveq	#'-',D2
	move.b	D2,(A4)+
	addq.b	#1,D3
	bra.b	fm5

fm3:	subq.b	#1,D1
	bsr.b	fmdepreg
	st	D2
fm4:	addq.b	#1,D1
fm5:	cmp.b	#8,D1
	blt.b	fm1
	rts

fmdepreg:
	movem.l	D0/D1,-(SP)
	tst.b	D3
	beq.b	fmd1
	cmp.b	#'-',D2
	beq.b	fmd1
	move.b	#'/',(a4)+
fmd1:	move.b	#"F",(A4)+
	move.b	#"P",(A4)+
	addq.b	#1,D3
	and.b	#%0111,D1
	moveq	#'0',D0
	add.b	D1,D0
	move.b	d0,(a4)+
	movem.l	(SP)+,D0/D1
	rts

;**********************************
;	FMOVE CONSTANT ROM	6888x/SW040
;**********************************

f_fmovecrom:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	move.l	#"FMOV",(a4)+
	move.l	#'ECR.',(a4)+
	move.w	#$5809,(a4)+	;'X' + TAB
	moveq	#%01111111,d2
	and.w	2(a0),d2
	move.b	#'#',(a4)+
	bsr	HexBDi
	move.b	#',',(a4)+
	bsr	GetFDreg
	bra	DoublePrint

;**********************************
;	FMOVE/M	6888x/68040
;**********************************

; fuer den normalen FMOVE oder falls mehere bits gesetzt sind dann FMOVEM

f_fmovescr:

	move.l	#"FMOV",(a4)+

;	move.l	Pointer-x(a5),a0
	clr.l	d7
	move.l	(a0),d2

	btst	#12,d2
	beq.b	1$
	addq.b	#1,d7		;fuer jedes REGISTER wird d7 um eins erhoeht

1$	btst	#11,d2
	beq.b	2$
	addq.b	#1,d7

2$	btst	#10,d2
	beq.b	3$
	addq.b	#1,d7

3$	cmp.b	#2,d7
	bge.b	f_fmovemcr

	move.w	#"E.",(a4)+
	move.b	#"L",(a4)+
	bra.b	f_fmovecr2

f_fmovemcr:			;fuer mehrere SYSTEM CONTROL REGISTER
	move.l	#"EM.L",(a4)+

f_fmovecr2:
	move.b	#"L",SizeBWL-x(a5)
	move.b	#9,(a4)+
	addq.l	#2,ToAdd-x(a5)
	btst	#13,d2
	beq.b	f_fmovecr3

	move.w	#%000111111100,d0
	cmp.b	#1,d7
	bhi.b	1$
	bset	#0,d0		;Dx nur bei einem EINZIGEM Register setzen
	btst	#10,d2
	beq.b	1$
	bset	#1,d0		;NUR wenn FPIAR als EINZIGER gesetzt ist !!!
1$
	move.w	d0,Adressposs-x(a5)
	bsr	FPREGS
	move.b	#',',(a4)+
	bsr	GetSEA
	bra	DoublePrint

f_fmovecr3:
	move.w	#%111111111100,d0
	cmp.b	#1,d7
	bhi.b	1$
	bset	#0,d0		;Dx nur bei einem EINZIGEM Register setzen
	btst	#10,d2
	beq.b	1$
	bset	#1,d0		;NUR wenn FPIAR als EINZIGER gesetzt ist !!!
1$
	move.w	d0,Adressposs-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	bsr	FPREGS
	bra	DoublePrint

FPREGS:
	move.l	Pointer-x(a5),a0
	move.l	(a0),d2

	btst	#12,d2
	beq.b	21$

	move.b	#"F",(a4)+	;wenn bit 12 gesetzt ist
	move.b	#"P",(a4)+
	move.b	#"C",(a4)+
	move.b	#"R",(a4)+

21$	btst	#11,d2
	beq.b	22$
	btst	#12,d2
	beq.b	211$

	move.b	#'/',(a4)+

211$	move.b	#"F",(a4)+	;wenn bit 11 gesetzt ist
	move.b	#"P",(a4)+
	move.b	#"S",(a4)+
	move.b	#"R",(a4)+

22$	btst	#10,d2
	beq.b	23$

	cmp.b	#'R',-1(a4)
	bne	221$

	move.b	#'/',(a4)+

221$	move.b	#"F",(a4)+	;wenn bit 10 gesetzt ist
	move.b	#"P",(a4)+
	move.b	#"I",(a4)+
	move.b	#"A",(a4)+
	move.b	#"R",(a4)+
23$	rts

;**********************************
;	FSAVE	6888x/68040
;	PSAVE	68881
;**********************************

f_fsave:
	move.l	#"FSAV",d2
	bra.b	p_save

p_psave:
	move.l	#"PSAV",d2
;	bra.b	p_save

p_save:
	move.l	d2,(a4)+
	move.w	#$4509,(a4)+	;'E' + TAB
	move.w	#%000111110100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	F & PRESTORE
;**********************************

p_prestore:
	move.l	#"PRES",(a4)+
	bra.b	fp_restore

f_frestore:
	move.l	#"FRES",(a4)+
;	bra.b	fp_restore

fp_restore:
	move.l	#"TORE",(a4)+
	move.b	#9,(a4)+
	move.w	#%011111101100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	PFLUSH	68040
;**********************************

p_pflush040:
	move.l	#"PFLU",(a4)+
	move.w	#"SH",(a4)+
;	move.l	Pointer-x(a5),a0
	moveq	#%00011000,d2
	and.w	(a0),d2
	lsr.b	#3,d2
	subq.b	#1,d2	; test d2 for 1
	beq.b	1$
	subq.b	#1,d2	; test d2 for 2
	beq.b	2$
	subq.b	#1,d2	; test d2 for 3
	beq.b	3$

	move.b	#"N",(a4)+
1$	move.b	#9,(a4)+
	move.b	#'(',(a4)+
	move.b	#"A",(a4)+
	move.l	Pointer-x(a5),a0
	moveq	#%00000111,d2
	and.w	(a0),d2
	add.b	#"0",d2
	move.b	d2,(a4)+
	move.b	#')',(a4)+
	bra	DoublePrint

2$	move.w	#"AN",(a4)+	;VORSICHT MUSS GERADE SEIN
	bra	DoublePrint

3$	move.l	#$4109093b,(a4)+	;'A' + TAB2 + ';'
	move.l	#'MC68',(a4)+		;VORSICHT MUSS GERADE SEIN
	move.w	#"04",(a4)+
	move.b	#"0",(a4)+
	bra	DoublePrint

;**********************************
;	PTEST R/W 68040
;**********************************

p_ptestr:
	move.l 	#$54520928,d2	;'TR' + TAB '('
	bra	p_ptestx

p_ptestw:
	move.l 	#$54570928,d2	;'TW' + TAB '('
;	bra	p_ptestx

p_ptestx:
	move.l	#"PTES",(a4)+
	move.l 	d2,(a4)+
	bsr	RegNumD_A
	move.b	#')',(a4)+
	bra	DoublePrint

;**********************************
;	PLPA R/W 68060
;**********************************

p_plpar:
	move.w 	#$5209,d2	;'R' + TAB
	bra	p_plpa

p_plpaw:
	move.w 	#$5709,d2	;'T' + TAB
;	bra	p_plpa

p_plpa:
	move.l	#"PLPA",(a4)+
	move.w 	d2,(a4)+
	bsr	RegNumD_Bracket_A
	move.b	#')',(a4)+
	bra	DoublePrint

;**********************************
;	CINV	68040
;**********************************

cinv_sector:
	dc.b	0	;0
	dc.b	"L"	;1
	dc.b	"P"	;2
	dc.b	"A"	;3

cinv_cache:
	dc.b	"N"	;0
	dc.b	"D"	;1
	dc.b	"I"	;2
	dc.b	"B"	;3

f_cpush:
	move.l	#"CPUS",(a4)+
	move.b	#"H",(a4)+
	bra	f_cachelines

f_cinv:	move.l	#"CINV",(a4)+
;	bra	f_cachelines

f_cachelines:
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	lsr.b	#3,d2
	andi.w	#%11,d2
	beq	OpCodeError

	move.b	cinv_sector(PC,d2.w),(a4)+	; setting sector

	move.b	#9,(a4)+

;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	lsr.b	#6,d2
	andi.w	#%11,d2

	move.b	cinv_cache(PC,d2.w),(a4)+	; setting cache
	move.b	#"C",(a4)+

	cmp.b	#"A",-4(a4)	; was it CINVA (or CPUSHA)
	beq.b	1$

	move.b	#',',(a4)+
	bsr	RegNumD_Bracket_A
	move.b	#')',(a4)+

1$	bra	DoublePrint

;**********************************
;	FBcc	6888x
;**********************************

f_pbcc	move.w	#"PB",(a4)+
;	move.l	Pointer-x(a5),a0
	move.w	(a0),d2
	bsr	GetmmuCoCo
	bra	f_xbcc

f_fbcc:
;	move.l	Pointer-x(a5),a0
	move.l	(a0),d2
	tst.w	d2
	bne.b	2$

	swap	d2
	andi.b	#%01111111,d2
	beq	f_fnop

2$	move.w	#'FB',(a4)+
	swap	d2
	bsr	GetcpCoCo

f_xbcc	move.b	#'.',(a4)+
	move.l	Pointer-x(a5),a0
	btst	#6,1(a0)
	beq.b	1$

	move.b	#'L',(a4)+	;LONG
	move.b	#9,(a4)+
	move.l	2(a0),d2
	move.l	d2,d5			;retten
	addq.l	#2,d2			;wie bei bcc
	add.l	PCounter-x(a5),d2

	moveq	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelPrintReloc32
	addq.l	#4,ToAdd-x(a5)

	tst.b	LabelYes-x(a5)
	bne	DoublePrint
	move.l	d5,d2
	bsr	HexLs		;SOLLTE MIT PLUS SEIN
	bra	DoublePrint

1$	move.b	#'W',(a4)+	;WORD
	move.b	#9,(a4)+
	move.w	2(a0),d2
	ext.l	d2
	move.w	d2,d5
	addq.l	#2,d2			;wie bei bcc
	add.l	PCounter-x(a5),d2

	moveq	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelPrintReloc16
	addq.l	#2,ToAdd-x(a5)

	tst.b	LabelYes-x(a5)
	bne	DoublePrint
	move.w	d5,d2
	bsr	HexWs		;SOLLTE MIT PLUS SEIN
	bra	DoublePrint

f_fnop:	move.l	#"FNOP",(a4)+
	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

;**********************************
;	FDBcc	6888x 68040
;**********************************

f_pdbcc:
;	move.l	Pointer-x(a5),a0
	move.w	#'PD',(a4)+
	move.b	#'B',(a4)+
	move.w	2(a0),d2
	bsr	GetmmuCoCo
	bra	f_xdbcc

f_fdbcc:
;	move.l	Pointer-x(a5),a0
	move.w	#'FD',(a4)+
	move.b	#'B',(a4)+
	move.w	2(a0),d2
	bsr	GetcpCoCo

f_xdbcc	move.b	#9,(a4)+
	move.b	#'D',(a4)+
	bsr	RegNumD
	move.b	#',',(a4)+
	move.l	Pointer-x(a5),a0
	move.w	4(a0),d2
	ext.l	d2
	move.l	d2,d5
	addq.l	#4,d2
	add.l	PCounter-x(a5),d2

	moveq	#4,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelPrintReloc16
	addq.l	#4,ToAdd-x(a5)

	tst.b	LabelYes-x(a5)
	bne	DoublePrint
	move.l	d5,d2
	bsr	HexWs		;SOLLTE MIT PLUS SEIN
	bra	DoublePrint

;**********************************
;	FScc & PScc	6888x 68040 68851
;**********************************

f_pscc:	move.w	#'PS',(a4)+		;MMU
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	bsr	GetmmuCoCo
	bra	f_xscc

f_fscc:	move.w	#'FS',(a4)+		;FPCP
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	bsr	GetcpCoCo
;	bra	f_xscc

f_xscc:
	move.b	#9,(a4)+
	addq.l	#2,ToAdd-x(a5)
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	PFLUSHR	68851
;**********************************

p_pflushr:
	addq.l	#2,ToAdd-x(a5)
	move.l	#'PFLU',(a4)+		;MMU
	move.l	#$53485209,(a4)+	;'SHR' + TAB
	move.w	#%111111111100,Adressposs-x(a5)
	move.b	#"D",SizeBWL-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	PFLUSH	68851 (68030)
;**********************************

p_pflush:
;	move.l	Pointer-x(a5),a0
	move.l	#'PFLU',(a4)+		;MMU
	move.w	#'SH',(a4)+
	addq.l	#2,ToAdd-x(a5)
	move.w	2(a0),d2
	and.w	#%1110001000000000,d2
	cmp.w	#%0010000000000000,d2
	bne	OpCodeError

	moveq	#%00011100,d2
	and.b	2(a0),d2
	lsr.b	#2,d2
	cmp.b	#%001,d2	;PFLUSHA
	beq.b	2$
	cmp.b	#%100,d2	;PFLUSH <fc>,#mask
	beq.b	3$
	cmp.b	#%101,d2	;PFLUSHS <fc>,#mask
	beq.b	4$
	cmp.b	#%110,d2	;PFLUSH <fc>,#mask,<ea>
	beq.b	5$
	cmp.b	#%111,d2	;PFLUSHS <fc>,#mask,<ea>>
	beq.b	6$

	bra	OpCodeError

2$	move.b	#'A',(a4)+
	move.w	2(a0),d2
	bclr	#10,d2
	bclr	#13,d2
	tst.w	d2		;MASK and FC MUST be NULL
	bne	OpCodeError
	bra	DoublePrint

4$	move.b	#'S',(a4)+
3$	move.b	#9,(a4)+
	bsr	p_getflushfc
	move.b	#',',(a4)+
	bsr	p_getflushmask
	bra	DoublePrint

6$	move.b	#'S',(a4)+
5$	move.b	#9,(a4)+
	bsr	p_getflushfc
	move.b	#',',(a4)+
	bsr	p_getflushmask
	move.b	#',',(a4)+
	move.w	#%000111100100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

p_getflushfc:
	move.l	Pointer-x(a5),a0
	moveq	#%00011111,d2
	and.w	2(a0),d2
	btst	#4,d2
	bne.b	1$
	btst	#3,d2
	bne.b	2$
	tst.b	d2
	beq.b	3$
	cmp.b	#1,d2
	beq.b	4$

	addq.l	#4,SP		;wegen Unterroutine
	bra	DoublePrint

1$	bclr	#4,d2
	move.b	#'#',(a4)+
	move.b	#'$',(a4)+
	bsr	HexB
	move.b	HexBufferB+1-x(a5),(a4)+
	rts

2$	bclr	#3,d2
	add.b	#"0",d2
	move.b	#'D',(a4)+
	move.b	D2,(a4)+
	rts

3$	move.b	#'S',(a4)+
	move.b	#'F',(a4)+
	move.b	#'C',(a4)+
	rts

4$	move.b	#'D',(a4)+
	move.b	#'F',(a4)+
	move.b	#'C',(a4)+
	rts

p_getflushmask:
	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	and.w	#%0000000111100000,d2
	lsr.w	#5,d2
	move.b	#'#',(a4)+
	bsr	HexBDi
	rts

p_getflushlevel:
	move.l	Pointer-x(a5),a0	;von 1-7
	moveq	#%00011100,d2
	and.b	2(a0),d2
	lsr.b	#2,d2
	move.b	#'#',(a4)+
	bsr	HexB
	move.b	HexBufferB+1-x(a5),(a4)+
	rts

;**********************************
;	PLOAD	68851 & 68030
;**********************************

p_pload:
;	move.l	Pointer-x(a5),a0
	move.l	#'PLOA',(a4)+
	move.w	#'DR',(a4)+
	btst	#1,2(a0)
	bne.b	1$
	move.b	#"W",-1(a4)
1$	addq.l	#2,ToAdd-x(a5)
	move.b	#9,(a4)+
	bsr	p_getflushfc
	move.b	#',',(a4)+
	move.w	#%000111100100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	PMOVEFD	68030
;**********************************

p_pmove1_030:
;	move.l	Pointer-x(a5),a0
	move.l	#'PMOV',(a4)+
	move.l	#$45464409,(a4)+	;'EFD' + TAB
	move.w	#%000111100100,Adressposs-x(a5)
	addq.l	#2,ToAdd-x(a5)
	btst	#1,2(a0)		;TO or FROM register ?
	beq.b	2$

	bsr	p_getmmureg
	move.b	#',',(a4)+
	bsr	GetSEA
	bra	DoublePrint

2$	bsr	GetSEA
	move.b	#',',(a4)+
	bsr	p_getmmureg
	bra	DoublePrint

;**********************************
;	PMOVE	TT0 & TT1 68030
;**********************************

p_pmove2_030:
;	move.l	Pointer-x(a5),a0
	move.l	#'PMOV',(a4)+
	move.b	#'E',(a4)+

	addq.l	#2,ToAdd-x(a5)

	move.w	2(a0),d2
	btst	#8,d2		;Flush Disabled ?
	beq.b	0$

	move.b	#'F',(a4)+	;Yes
	move.b	#'D',(a4)+

0$	move.b	#9,(a4)+

	move.w	#%000111100100,Adressposs-x(a5)

	btst	#9,d2		;TO or FROM register ?
	beq.b	2$

	move.b	#'T',(a4)+
	move.b	#'T',(a4)+
	move.b	#'0',(a4)+
	btst	#10,d2
	beq.b	1$
	move.b	#'1',-1(a4)
1$	move.b	#',',(a4)+
	bsr	GetSEA
	bra	DoublePrint

2$	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	#'T',(a4)+
	move.b	#'T',(a4)+
	move.b	#'0',(a4)+
	move.l	Pointer-x(a5),a0
	btst	#2,2(a0)
	beq.b	3$
	move.b	#'1',-1(a4)
3$	bra	DoublePrint

;**********************************
;	PMOVE	68851
;**********************************

p_pmove1_851:
;	move.l	Pointer-x(a5),a0
	move.l	#'PMOV',(a4)+
	move.w	#$4509,(a4)+	;'E' + TAB
	addq.l	#2,ToAdd-x(a5)
	btst	#1,2(a0)		;TO or FROM register ?
	beq.b	2$

	move.w	#%000111111111,Adressposs-x(a5)
	bsr	p_getmmureg
	move.b	#',',(a4)+
	bsr	GetSEA
	bra	DoublePrint

2$	move.w	#%111111111111,Adressposs-x(a5)

	move.l	a4,d7		;retten
	bsr	p_getmmureg	;SizeBWL holen
	move.l	d7,a4		;und zurueckholen

	bsr	GetSEA
	move.b	#',',(a4)+
	bsr	p_getmmureg
	bra	DoublePrint

;**********************************
;	PMOVE	BADx & BACx 68851
;**********************************

p_pmove2_851:
;	move.l	Pointer-x(a5),a0
	move.l	#'PMOV',(a4)+
	move.w	#$4509,(a4)+	;'E' + TAB
	addq.l	#2,ToAdd-x(a5)

	move.b	2(a0),d2
	btst	#1,d2		;TO or FROM register ?
	beq.b	2$

	move.w	#%000111111111,Adressposs-x(a5)
	move.w	#'BA',(a4)+	;ACHTUNG !!! GERADE
	move.b	#'D',(a4)+
	btst	#2,d2
	beq.b	1$
	move.b	#'C',-1(a4)

1$	andi.b	#%00011100,d2
	lsr.b	#2,d2
	add.b	#"0",d2
	move.b	d2,(a4)+
	move.b	#',',(a4)+
	bsr	GetSEA
	bra	DoublePrint

2$	move.w	#%111111111111,Adressposs-x(a5)
	move.b	#"W",SizeBWL-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+
	move.b	#'B',(a4)+
	move.b	#'A',(a4)+
	move.b	#'D',(a4)+
	move.l	Pointer-x(a5),a0
	move.b	2(a0),d2
	btst	#2,d2
	beq.b	3$
	move.b	#'C',-1(a4)

3$	andi.b	#%00011100,d2
	lsr.b	#2,d2
	add.b	#"0",d2
	move.b	d2,(a4)+
	bra	DoublePrint

;**********************************
;	PMOVE	PSR & PCSR 68851
;**********************************

p_pmove3_851:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	move.l	#'PMOV',(a4)+
	move.w	#$4509,(a4)+	;'E' + TAB

	btst	#1,2(a0)		;TO or FROM register ?
	beq.b	2$

	move.w	#%000111111111,Adressposs-x(a5)
	move.l	#'PSR,',(a4)+	;ACHTUNG !!! GERADE
	bsr	GetSEA
	bra	DoublePrint

2$	move.w	#%111111111111,Adressposs-x(a5)
	move.b	#"W",SizeBWL-x(a5)
	bsr	GetSEA
	move.b	#',',(a4)+

	move.l	Pointer-x(a5),a0
	btst	#2,2(a0)
	beq.b	1$

	move.b	#'P',(a4)+
	move.b	#'C',(a4)+
	move.b	#'S',(a4)+
	move.b	#'R',(a4)+
	bra.b	4$

1$	move.b	#'P',(a4)+
	move.b	#'S',(a4)+
	move.b	#'R',(a4)+

4$	bra	DoublePrint

p_getmmureg:
	move.l	Pointer-x(a5),a0
	moveq	#%00011100,d2
	and.b	2(a0),d2

	lea	MMUREG(PC,d2.w),a0

	move.b	(a0)+,SizeBWL-x(a5)

	moveq	#2,d2

1$	move.b	(a0)+,(a4)+
	dbeq	d2,1$

	bne	2$
	subq	#1,a4

2$	rts

MMUREG:	dc.b	"L","TC",0
	dc.b	"D","DRP"
	dc.b	"D","SRP"
	dc.b	"D","CRP"
	dc.b	"B","CAL"
	dc.b	"B","VAL"
	dc.b	"B","SCC"
	dc.b	"W","AC",0

;**********************************
;	PVALID VAL	68851
;**********************************

p_pvalidv:
	addq.l	#2,ToAdd-x(a5)
	move.l	#'PVAL',(a4)+
	move.l	#$49440956,(a4)+	;'ID' + TAB + 'V'
	move.w	#'AL',(a4)+
	move.b	#',',(a4)+
	move.w	#%000111100100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	PVALID VAL	68851
;**********************************

p_pvalida:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	move.l	#'PVAL',(a4)+
	move.l	#$49440941,(a4)+	;'ID' + TAB + 'A'
	move.w	2(a0),d2
	add.b	#"0",d2
	move.b	d2,(a4)+
	move.b	#',',(a4)+
	move.w	#%000111100100,Adressposs-x(a5)
	bsr	GetSEA
	bra	DoublePrint

;**********************************
;	PTEST	68851 & 68030
;**********************************

p_ptest:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	move.l	#'PTES',(a4)+
	move.w	#'TR',(a4)+
	btst	#1,2(a0)
	bne.b	1$
	move.b	#"W",-1(a4)

1$	move.b	#9,(a4)+
	bsr	p_getflushfc
	move.b	#',',(a4)+
	move.w	#%000111100100,Adressposs-x(a5)
	bsr	GetSEA

	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	andi.w	#%0001110000000000,d2
	bne.b	2$
	move.w	2(a0),d2		;A and reg field MUST be NULL
	andi.w	#%0000000111100000,d2	;sonst gibts ne F-Line Exeption
	bne	DoublePrint

2$	move.b	#',',(a4)+
	bsr	p_getflushlevel

	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2

	btst	#8,d2
	beq	DoublePrint	;kein Adressregister

	move.b	#',',(a4)+		;AdressRegister
	move.b	#'A',(a4)+
	andi.b	#%11100000,d2
	lsr.b	#5,d2
	add.b	#"0",d2
	move.b	D2,(a4)+
	bra	DoublePrint

;**********************************
;	FTRAPcc	6888x 68040
;**********************************

f_ptrapcc:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	move.l	#'PTRA',(a4)+
	move.b	#'P',(a4)+
	move.w	2(a0),d2
	bsr	GetmmuCoCo
	bra	f_xtrapcc

f_ftrapcc:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	move.l	#'FTRA',(a4)+
	move.b	#'P',(a4)+
	move.w	2(a0),d2
	bsr	GetcpCoCo

f_xtrapcc
	move.l	Pointer-x(a5),a0
	moveq	#%111,d2
	and.w	(a0),d2
	cmp.b	#%100,d2
	beq	DoublePrint
	cmp.b	#%010,d2
	beq.b	2$
	cmp.b	#%011,d2
	beq.b	3$
	bra	OpCodeError

2$	move.b	#'.',(a4)+
	move.b	#'W',(a4)+
	move.b	#9,(a4)+
	move.b	#'#',(a4)+
	move.l	Pointer-x(a5),a0
	move.w	4(a0),d2
	bsr	HexWDi
	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

3$	move.b	#'.',(a4)+
	move.b	#'L',(a4)+
	move.b	#9,(a4)+
	move.b	#'#',(a4)+
	move.l	Pointer-x(a5),a0
	move.l	4(a0),d2
	bsr	HexLDi
	addq.l	#4,ToAdd-x(a5)
	bra	DoublePrint

;**********************************
;	MOVE16 68040			;MOVE16 (Ax)+,(Ay)+
;**********************************

f_move16_1:
	move.l	#'MOVE',(a4)+
	move.l	#$31360928,(a4)+	;'16' + TAB + '('
	bsr	RegNumD_A
	move.l	#')+,(',(a4)+
	move.b	#'A',(a4)+
	move.l	Pointer-x(a5),a0
	move.b	2(a0),d2
	and.b	#%01110000,d2
	lsr.b	#4,d2
	add.b	#'0',d2		; das zweite adressregister
	move.b	d2,(a4)+
	move.w	#')+',(a4)+
	addq.l	#2,ToAdd-x(a5)
	bra	DoublePrint

;**********************************
;	MOVE16 68040			;MOVE16 xxx.L,(Ay)
;**********************************

f_move16_2
;	move.l	Pointer-x(a5),a0
	move.l	#'MOVE',(a4)+
	move.w	#'16',(a4)+
	move.b	#9,(a4)+
	addq.l	#4,ToAdd-x(a5)

	move.w	(a0),d6
	btst	#3,d6
	beq	02$

13$
	move.l	2(a0),d2	;MOVE16 xxx.L,(Ay)+
	bsr	HexLDi
	move.b	#',',(a4)+
	bsr	RegNumD_Bracket_A
	move.b	#')',(a4)+
	btst	#4,d6
	bne	3$
	move.b	#'+',(a4)+
3$	bra	DoublePrint

02$	bsr	RegNumD_Bracket_A	;MOVE16 (Ay),xxx.L
	move.b	#')',(a4)+
	btst	#4,d6
	bne	2$
	move.b	#'+',(a4)+
2$	move.b	#',',(a4)+
	move.l	Pointer-x(a5),a0
	move.l	2(a0),d2
	bsr	HexLDi
	bra	DoublePrint

;**********************************
;	LPSTOP	68060 !!!
;**********************************

x_lpstop:
;	move.l	Pointer-x(a5),a0
	cmp.w	#%0000000111000000,2(a0)
	bne	OpCodeError
	move.l	#"LPST",(a4)+
	move.l	#$4f500923,(a4)+	;'OP' + TAB + '#'

	move.w	4(a0),d2
	bsr	HexWDi

	addq.l	#4,ToAdd-x(a5)
	bra	DoublePrint

;****************************************************************************
;****************************************************************************

; F-Line fuer Labelberechnung

c2_fline

	tst.b	ArguF-x(a5)		;68020 ???
	beq	c2_iNULL

	lea	Befehl-x(a5),a4		;WICHTIG !!!

	move.w	(a0),d0
;	andi.w	#%1111111111111111,d0
	cmp.w	#%1111000001111010,d0	;PTRAPcc 68851
	beq	p2_ptrapcc
	cmp.w	#%1111000001111011,d0	;PTRAPcc 68851
	beq	p2_ptrapcc
	cmp.w	#%1111000001111100,d0	;PTRAPcc 68851
	beq	p2_ptrapcc
	cmp.w	#%1111100000000000,d0	;LPSTOP 68060
	beq	x2_lpstop

	move.w	d0,d7
;	move.w	d7,d0
	andi.w	#%1111111111111000,d0
	cmp.w	#%1111011000100000,d0	;MOVE16 68040
	beq	f2_move16_1
	cmp.w	#%1111001001111000,d0	;FTRAPcc 68881/2 68040
	beq	f2_ftrapcc
	cmp.w	#%1111001001001000,d0	;FDBcc 6888x
	beq	f2_fdbcc
	cmp.w	#%1111000001001000,d0	;PDBcc 68851
	beq	f2_pdbcc
	cmp.w	#%1111010101101000,d0	;FTESTR 68040
	beq	c2_NULL
	cmp.w	#%1111010101001000,d0	;FTESTW 68040
	beq	c2_NULL
	cmp.w	#%1111010110001000,d0	;FPLPAW 68060
	beq	c2_NULL
	cmp.w	#%1111010111001000,d0	;FPLPAR 68060
	beq	c2_NULL

;	move.w	d7,d0
	andi.w	#%1111111111000000,d0
	cmp.w	#%1111001000000000,d0	;FLINE STANDARD
	beq	f2_fcom
	cmp.w	#%1111000000000000,d0	;PMMU  STANDARD
	beq	p2_pcom
	cmp.w	#%1111001100000000,d0	;FSAVE 6888x/68040
	beq	f2_fsave
	cmp.w	#%1111000100000000,d0	;PSAVE 68851
	beq	p2_psave
	cmp.w	#%1111001101000000,d0	;FRESTORE 6888x/68040
	beq	f2_frestore
	cmp.w	#%1111000101000000,d0	;PRESTORE 68851
	beq	p2_prestore

;	move.w	d7,d0
	andi.w	#%1111111111100000,d0
	cmp.w	#%1111011000000000,d0	;MOVE16 68040
	beq	f2_move16_2
	cmp.w	#%1111010100000000,d0	;PFLUSH 68040
	beq	c2_NULL

;	move.w	d7,d0
	andi.w	#%1111111100100000,d0
	cmp.w	#%1111010000000000,d0	;CINV 68040
	beq	c2_NULL
	cmp.w	#%1111010000100000,d0	;CPUSH 68040
	beq	c2_NULL

	move.w	d7,d0
	andi.w	#%1111111111000000,d0
	cmp.w	#%1111001001000000,d0	;FScc 6888x
	beq	f2_fscc
	cmp.w	#%1111000001000000,d0	;PScc 68851
	beq	p2_pscc

;	move.w	d7,d0
	andi.w	#%1111111110000000,d0
	cmp.w	#%1111001010000000,d0	;FBcc 6888x
	beq	f2_fbcc
	cmp.w	#%1111000010000000,d0	;PBcc 68851
	beq	p2_pbcc

	bra	c2_iNULL		;doch kein F-Line Befehl

;******************************************************************

p2_pcom:
	move.w	2(a0),d0
;	and.w	#%1111111111111111,d0
	cmp.w	#%1010000000000000,d0	;PFLUSHR 68851
	beq	p2_pflushr
	cmp.w	#%0010100000000000,d0	;PVALID VAL 68851
	beq	p2_pvalidv

;	move.w	2(a0),d0
	and.w	#%1111111111111000,d0
	cmp.w	#%0010110000000000,d0	;PVALID Ax 68851
	beq	p2_pvalida

;	move.w	2(a0),d0
	and.w	#%1111110111100000,d0
	cmp.w	#%0010000000000000,d0	;PLOAD 68851 & 68030
	beq	p2_pload

	move.w	2(a0),d0
	and.w	#%1111000111111111,d0
	cmp.w	#%0100000100000000,d0	;PMOVEFD 68030
	beq	p2_pmove1_030

;	move.w	2(a0),d0
	and.w	#%1110000111111111,d0
	cmp.w	#%0100000000000000,d0	;PMOVE 68851
	beq	p2_pmove1_851

	move.w	2(a0),d0
	and.w	#%1111100011111111,d0
	cmp.w	#%0000100000000000,d0	;PMOVE 68030
	beq	p2_pmove2_030

	move.w	2(a0),d0
	and.w	#%1111100111111111,d0
	cmp.w	#%0110000000000000,d0	;PMOVE 68851
	beq	p2_pmove3_851

;	move.w	2(a0),d0
	and.w	#%1111100111100011,d0
	cmp.w	#%0111000000000000,d0	;PMOVE 68851
	beq	p2_pmove2_851

	move.w	2(a0),d0
	and.w	#%1110001000000000,d0
	cmp.w	#%0010000000000000,d0	;PFLUSH 68851 (68030)
	beq	p2_pflush

;	move.w	2(a0),d0
	and.w	#%1110000000000000,d0
	cmp.w	#%1000000000000000,d0	;PTEST 68851 & 68030
	beq	p2_ptest

	bra	c2_iNULL		;doch kein F-Line Befehl

f2_fcom:
	move.w	2(a0),d0
	and.w	#%1111110000000000,d0
	cmp.w	#%0101110000000000,d0	;FMOVE CONSTANT ROM
	beq	f2_fmovecrom

;	move.w	2(a0),d0
	and.w	#%1110000000000000,d0
	cmp.w	#%0110000000000000,d0	;FMOVE (register to memory)
	beq	f2_fmove2

	move.w	2(a0),d0
	and.w	#%1010000001111111,d0
	cmp.w	#%0000000000000000,d0	;FMOVE
	beq	f2_fmove
	cmp.w	#%0000000000000001,d0	;FINT
	beq	f2_fint
	cmp.w	#%0000000000000010,d0	;FSINH
	beq	f2_fsinh
	cmp.w	#%0000000000000011,d0	;FINTRZ
	beq	f2_fintrz
	cmp.w	#%0000000000000100,d0	;FSQRT
	beq	f2_fsqrt
	cmp.w	#%0000000000000110,d0	;FLOGNP1
	beq	f2_flognp1
	cmp.w	#%0000000000001000,d0	;FETOXM1
	beq	f2_fetoxm1
	cmp.w	#%0000000000001001,d0	;FTANH
	beq	f2_ftanh
	cmp.w	#%0000000000001010,d0	;FATAN
	beq	f2_fatan
	cmp.w	#%0000000000001100,d0	;FASIN
	beq	f2_fasin
	cmp.w	#%0000000000001101,d0	;FATANH
	beq	f2_fatanh
	cmp.w	#%0000000000001110,d0	;FSIN
	beq	f2_fsin
	cmp.w	#%0000000000001111,d0	;FTAN
	beq	f2_ftan
	cmp.w	#%0000000000010000,d0	;FETOX
	beq	f2_fetox
	cmp.w	#%0000000000010001,d0	;FTWOTOX
	beq	f2_ftwotox
	cmp.w	#%0000000000010010,d0	;FTENTOX
	beq	f2_ftentox
	cmp.w	#%0000000000010101,d0	;FLOG10
	beq	f2_flog10
	cmp.w	#%0000000000010110,d0	;FLOG2
	beq	f2_flog2
	cmp.w	#%0000000000010100,d0	;FLOGN
	beq	f2_flogn
	cmp.w	#%0000000000011000,d0	;FABS
	beq	f2_fabs
	cmp.w	#%0000000000011001,d0	;FCOSH
	beq	f2_fcosh
	cmp.w	#%0000000000011010,d0	;FNEG
	beq	f2_fneg
	cmp.w	#%0000000000011100,d0	;FACOS
	beq	f2_fcosh
	cmp.w	#%0000000000011101,d0	;FCOS
	beq	f2_fcos
	cmp.w	#%0000000000011110,d0	;FGETEXP
	beq	f2_fgetexp
	cmp.w	#%0000000000011111,d0	;FGETMAN
	beq	f2_fgetman
	cmp.w	#%0000000000100000,d0	;FDIV
	beq	f2_fdiv
	cmp.w	#%0000000000100001,d0	;FMOD
	beq	f2_fmod
	cmp.w	#%0000000000100010,d0	;FADD
	beq	f2_fadd
	cmp.w	#%0000000000100011,d0	;FMUL
	beq	f2_fmul
	cmp.w	#%0000000000100100,d0	;FSGLDIV
	beq	f2_fsgldiv
	cmp.w	#%0000000000100101,d0	;FREM
	beq	f2_frem
	cmp.w	#%0000000000100110,d0	;FSCALE
	beq	f2_fscale
	cmp.w	#%0000000000100111,d0	;FSGLMUL
	beq	f2_fsglmul
	cmp.w	#%0000000000101000,d0	;FSUB
	beq	f2_fsub
	cmp.w	#%0000000000111000,d0	;FCMP
	beq	f2_fcmp
	cmp.w	#%0000000000111010,d0	;FTST
	beq	f2_ftst
	cmp.w	#%0000000001000000,d0	;FSMOVE
	beq	f2_fsmove
	cmp.w	#%0000000001000001,d0	;FSSQRT
	beq	f2_fssqrt
	cmp.w	#%0000000001000100,d0	;FDMOVE
	beq	f2_fdmove
	cmp.w	#%0000000001000101,d0	;FDSQRT
	beq	f2_fdsqrt
	cmp.w	#%0000000001011000,d0	;FSABS
	beq	f2_fsabs
	cmp.w	#%0000000001011010,d0	;FSNEG
	beq	f2_fsneg
	cmp.w	#%0000000001011100,d0	;FDABS
	beq	f2_fdabs
	cmp.w	#%0000000001011110,d0	;FDNEG
	beq	f2_fdneg
	cmp.w	#%0000000001100000,d0	;FSDIV
	beq	f2_fsdiv
	cmp.w	#%0000000001100010,d0	;FSADD
	beq	f2_fsadd
	cmp.w	#%0000000001100011,d0	;FSMUL
	beq	f2_fsmul
	cmp.w	#%0000000001100100,d0	;FDDIV
	beq	f2_fddiv
	cmp.w	#%0000000001100110,d0	;FDADD
	beq	f2_fdadd
	cmp.w	#%0000000001100111,d0	;FDMUL
	beq	f2_fdmul
	cmp.w	#%0000000001101000,d0	;FSSUB
	beq	f2_fssub
	cmp.w	#%0000000001101100,d0	;FDSUB
	beq	f2_fdsub

	move.w	2(a0),d0
	and.w	#%1100001111111111,d0
	cmp.w	#%1000000000000000,d0	;FMOVE/M SYSTEM CONTROL REGISTER
	beq	f2_fmovescr

	move.w	2(a0),d0
	and.w	#%1010000001111000,d0
	cmp.w	#%0000000000110000,d0	;FSINCOS
	beq	f2_fsincos

	move.w	2(a0),d0
	and.w	#%1100011100000000,d0
	cmp.w	#%1100000000000000,d0	;FMOVEM DATA
	beq	f2_fmovem

	bra	c2_iNULL

;***********************************************************

;**********************************
;	FSTANDARD 6888x/68040
;**********************************

f2_fsin
f2_fsinh
f2_fasin
f2_ftan
f2_ftanh
f2_fatan
f2_fatanh
f2_fcos
f2_fcosh
f2_facos
f2_fcmp
f2_fetox
f2_fetoxm1
f2_fgetexp
f2_fgetman
f2_fint
f2_fintrz
f2_flog10
f2_flog2
f2_flogn
f2_flognp1
f2_fmod
f2_frem
f2_fscale
f2_fsgldiv
f2_fsglmul
f2_ftentox
f2_ftwotox
f2_fabs
f2_fsabs
f2_fdabs
f2_fadd
f2_fsadd
f2_fdadd
f2_fsub
f2_fssub
f2_fdsub
f2_fmul
f2_fsmul
f2_fdmul
f2_fdiv
f2_fsdiv
f2_fddiv
f2_fneg
f2_fsneg
f2_fdneg
f2_fsqrt
f2_fssqrt
f2_fdsqrt
f2_fmove
f2_fsmove
f2_fdmove
f2_fsincos
f2_ftst

f2_standard
	addq.l	#2,ToAdd-x(a5)
	bsr	GetFSSP
	move.l	Pointer-x(a5),a0
	btst	#6,2(a0)
	beq	QWERTYUIOPA

	move.w	#%111111111101,d0		;R/M=1

	bsr	addressbitcheck

	bsr	GetSEA2		;<ea> to register
	bra	QWERTYUIOPA

;**********************************

f2_fmove2
	addq.l	#2,ToAdd-x(a5)
	bsr	GetFSSP
	tst.b	-1(a4)
	bne.b	1$
	move.b	#"P",SizeBWL-x(a5)
1$	move.l	Pointer-x(a5),a0
	btst	#6,2(a0)
	beq	QWERTYUIOPA

	move.w	#%111111111101,d0		;R/M=1

	bsr	addressbitcheck

	bsr	GetSEA2		;<ea> to register
	bra	QWERTYUIOPA

;**********************************

f2_fmovecrom
f2_move16_1
	addq.l	#2,ToAdd-x(a5)
	bra	QWERTYUIOPA

f2_fmovem:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	move.w	#%000111110100,d0	;to memory
	btst	#5,2(a0)
	bne.b	2$

	move.w	#%011111101100,d0	;from memory

2$	move.w	d0,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

p2_pvalida:
p2_pvalidv:
	addq.l	#2,ToAdd-x(a5)
	move.w	#%000111100100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

f2_fsave:
p2_psave:
	move.w	#%000111110100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

f2_frestore:
p2_prestore:
	move.w	#%011111101100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

f2_move16_2:
	addq.l	#4,ToAdd-x(a5)
	bra	QWERTYUIOPA

;********************************************

p2_pbcc:
f2_fbcc:
;	move.l	Pointer-x(a5),a0

	st	Springer-x(a5)		;fuer Trace-Methode

	btst	#6,1(a0)
	beq.b	1$

	move.l	2(a0),d2	;LONG
	beq.b	3$		;wenn Sprung NULL dann kein Label
	addq.l	#2,d2
	add.l	PCounter-x(a5),d2

	moveq	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX32
3$	addq.l	#4,ToAdd-x(a5)
	bra	QWERTYUIOPA

1$	move.w	2(a0),d2	;WORD
	beq.b	2$		;FNOP abfangen !!!
	ext.l	d2
	addq.l	#2,d2
	add.l	PCounter-x(a5),d2

	moveq	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX16
2$	addq.l	#2,ToAdd-x(a5)
	bra	QWERTYUIOPA

;********************************************

f2_pdbcc:
f2_fdbcc:
;	move.l	Pointer-x(a5),a0
	move.w	4(a0),d2	;WORD
	beq.b	1$		;wenn Sprung NULL dann kein Label
	ext.l	d2
	addq.l	#4,d2
	add.l	PCounter-x(a5),d2

	moveq	#2,d0
	move.l	d0,RelocXAdress-x(a5)

	bsr	LabelCalcRelocX16
1$	addq.l	#4,ToAdd-x(a5)
	bra	QWERTYUIOPA

;********************************************

f2_fscc:
p2_pscc:
	addq.l	#2,ToAdd-x(a5)
	move.w	#%000111111101,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;********************************************

p2_pflushr
	addq.l	#2,ToAdd-x(a5)
	move.w	#%111111111100,Adressposs-x(a5)
	move.b	#"D",SizeBWL-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

p2_ptest
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	and.w	#%1110000000000000,d2
	cmp.w	#%1000000000000000,d2
	bne	c2_iNULL
	addq.l	#2,ToAdd-x(a5)
	move.w	#%000111100100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

p2_pload
;	move.l	Pointer-x(a5),a0
	move.w	2(a0),d2
	and.w	#%1111110111100000,d2
	cmp.w	#%0010000000000000,d2
	bne	c2_iNULL
	addq.l	#2,ToAdd-x(a5)
	move.w	#%000111100100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

p2_pflush
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	move.w	2(a0),d2
	and.w	#%1110001000000000,d2
	cmp.w	#%0010000000000000,d2
	bne	c2_iNULL
	btst	#11,d2
	beq	QWERTYUIOPA
	move.w	#%000111100100,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

p2_pmove1_030:
	move.w	#%000111100100,Adressposs-x(a5)
	addq.l	#2,ToAdd-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

p2_pmove2_030:
p2_pmove1_851:
p2_pmove2_851:
p2_pmove3_851:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	moveq	#-1,d0			;all addressmodes
	btst	#1,2(a0)		;TO or FROM register ?
	beq.b	2$

	move.w	#%000111111111,d0

2$	move.w	d0,Adressposs-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

p2_ptrapcc:
f2_ftrapcc:
;	move.l	Pointer-x(a5),a0
	addq.l	#2,ToAdd-x(a5)
	moveq	#%111,d2
	and.w	(a0),d2

	cmp.b	#%100,d2
	beq.b	1$
	cmp.b	#%010,d2
	beq.b	2$
	cmp.b	#%011,d2
	beq.b	3$
	bra	c2_iNULL

2$	addq.l	#2,ToAdd-x(a5)
	bra	QWERTYUIOPA

3$	addq.l	#4,ToAdd-x(a5)
1$	bra	QWERTYUIOPA

;**********************************

f2_fmovescr:
	addq.l	#2,ToAdd-x(a5)
	move.w	#%111111111101,d2

	btst	#5,2(a0)
	beq.b	1$

	move.w	#%000111111101,d2

1$	btst	#2,2(a0)	;FPIAR ???
	beq.b	2$

	bset	#1,d2	;wenn ja, dann auch A-Reg erlauben !!!

2$	move.w	d2,Adressposs-x(a5)
	move.b	#"L",SizeBWL-x(a5)
	bsr	GetSEA2
	bra	QWERTYUIOPA

;**********************************

x2_lpstop:
;	move.l	Pointer-x(a5),a0
	cmp.w	#%0000000111000000,2(a0)
	bne	c2_iNULL
	addq.l	#4,ToAdd-x(a5)
	bra	QWERTYUIOPA

;***************************************************************

;**********************************
;	FPx reg Direkt
;**********************************

GetFDreg:
	move.l	Pointer-x(a5),a0
	move.w	2(a0),d0
	andi.w	#%0000001110000000,d0
	lsr.w	#7,d0
	bra	GetFxreg

GetFD2reg:
	move.b	#',',(a4)+
	move.l	Pointer-x(a5),a0
	moveq	#%00000111,d0
	and.w	2(a0),d0
	bra	GetFxreg

GetFSreg:
	move.l	Pointer-x(a5),a0
	moveq	#%00011100,d0
	and.b	2(a0),d0
	lsr.b	#2,d0
;	bra	GetFxreg

GetFxreg:
	add.b	#"0",d0
	move.b	#"F",(a4)+
	move.b	#"P",(a4)+
	move.b	d0,(a4)+
	rts

;**********************************
;	<fmt-size> Direkt
;**********************************

GetFSSP:
	move.l	Pointer-x(a5),a0
	moveq	#%00011100,d0
	and.b	2(a0),d0
	lsr.b	#2,d0

	lea	SSPlist(PC,d0.w),a0
	move.b	(a0),d0
	move.b	d0,(a4)+
	move.b	d0,SizeBWL-x(a5)
	rts

; 000 long-word integer
; 001 single-precision real
; 010 extended-precision real
; 011 packed-decimal real
; 100 word integer
; 101 double-precision real
; 110 byte integer
; 111 ?

SSPlist:
	dc.b	"LSXPWDB",0

;**********************************
;	Speichert die Co. Codes vom CoProzessor
;**********************************

GetcpCoCo
	andi.w	#%00111111,d2

	cmp.w	#32,d2
	blt	2$

	moveq	#32,d2

2$	lsl.w	#2,d2
	lea	FCoCo(PC,d2.w),a0

	moveq	#3,d2

1$	move.b	(a0)+,(a4)+
	dbeq	d2,1$

	bne	3$
	subq	#1,a4

3$	rts

FCoCo:
	dc.b	"F",0,0,0	; 0
	dc.b	"EQ",0,0	; 1
	dc.b	"OGT",0		; 2
	dc.b	"OGE",0		; 3
	dc.b	"OLT",0		; 4
	dc.b	"OLE",0		; 5
	dc.b	"OGL",0		; 6
	dc.b	"OR",0,0	; 7

	dc.b	"UN",0,0	; 8
	dc.b	"UEQ",0		; 9
	dc.b	"UGT",0		; 10
	dc.b	"UGE",0		; 11
	dc.b	"ULT",0		; 12
	dc.b	"ULE",0		; 13
	dc.b	"NE",0,0	; 14
	dc.b	"T",0,0,0	; 15

	dc.b	"SF",0,0	; 16
	dc.b	"SEQ",0		; 17
	dc.b	"GT",0,0	; 18
	dc.b	"GE",0,0	; 19
	dc.b	"LT",0,0	; 20
	dc.b	"LE",0,0	; 21
	dc.b	"GL",0,0	; 22
	dc.b	"GLE",0		; 23

	dc.b	"NGLE"		; 24
	dc.b	"NGL",0		; 25
	dc.b	"NLE",0		; 26
	dc.b	"NLT",0		; 27
	dc.b	"NGE",0		; 28
	dc.b	"NGT",0		; 29
	dc.b	"SNE",0		; 30
	dc.b	"ST",0,0	; 31

	dc.b	"???",0		; 32

;**********************************
;	Speichert die Co. Codes vom 68851 PMMU
;**********************************

GetmmuCoCo
	andi.w	#%00001111,d2

	add.b	d2,d2

	lea	FBCCx(PC,d2.w),a1
	move.b	(a1)+,(a4)+
	move.b	(a1),(a4)+
	rts

FBCCx:	dc.b	"BSBCLSLCSSSCASACWSWCISICGSGCCSCC"

