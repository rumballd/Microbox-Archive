 NAM Mon09
 STTL Ver 5.0B    Ph. Roehr   27/04/2025
;******************************************
;******************************************
;** MON09  Ver 5.0B                      **
;** Original design Micro Concepts 1985  **
;**                                      **
;** Compact Flash adaptation 2025        **
;** by Ph. Roehr                         **
;**                                      **
;******************************************
;******************************************
;*
;******************************************
;* This program is the core section of a  *
;* general 6809(E) system monitor. It can *
;* be configured to a particular system   *
;* at assembly time by including on the   *
;* source disk libary files containing    *
;* the system specific code for the disk  *
;* and console drivers and extra commands *
;* and subroutines. These files are:-     *
;*  SCRATCH.....Contains RMB's for extra  *
;*              temp storage.             *
;*  FDB.........Contains the jump table   *
;*              entries for extra subs.   *
;*  COMTABLE....Contains the extra jump   *
;*              table entries for commands*
;*  MINIT.......Contains the power on     *
;*              and reset code.           *
;*  CONSOLE.....Contains the console      *
;*              driver code.              *
;*  DISK........Contains the disk driver  *
;*              code.                     *
;*  SUBS........Contains the code for any *
;*              extra system subroutines. *
;*  BOOT........Contains the boot routine.*
;*  COMMANDS....Contains the code for any *
;*              extra commands.           *
;******************************************
;*
;*
;*
;**************************
;* Common System Equates  *
;**************************
;*
;* LIB STARTADD
;*
;* FLEX variables ?
;*
TTYBS   EQU   $CC00
CINCHN  EQU   $D3E5        ; FLEX ?
;*
;* Other addresses
;*
PROM    EQU   $E000        ; Start of PROM
COLDS   EQU   $CD00        ; FLEX Cold Start
TXTRAM  EQU   $CA00        ; TEXT RAM
MCA02   EQU   $CA02        ; ?
;*
RAM     EQU   $DE00        ; Scratch ram + stack space.
IO      EQU   $FF00        ; base address.
SSTACK  EQU   (RAM+127-16) ; Top of system stack.
SCRAT   EQU   (RAM+384)    ; Start of scratch space.
;*
;* I/O
;*
PIA1    EQU   IO           ; $FF00
SYSREG  EQU   PIA1+2       ; $FF02
ACIA2   EQU   IO+4         ; $FF04
ACIA1   EQU   IO+8         ; $FF08
BAUD    EQU   IO+12        ; $FF0C
COMREG  EQU   IO+16        ; $FF10 : FDC Control register
DATREG  EQU   COMREG+3     ; $FF13 : FDC Data register
GDC     EQU   IO+20        ; $FF14
RTC     EQU   IO+24        ; $FF18
PIA2    EQU   IO+28        ; $FF1C
;*
;* SAM Registers
;*
CLR_R0  EQU   $FFD6
SET_R0  EQU   $FFD7
CLR_R1  EQU   $FFD8
SET_R1  EQU   $FFD9

;*********************************
;* Compact Flash System Equates  *
;*********************************

;* ABSOLUTE PIA PORT ADDRESSES

PORTA               EQU     PIA2
PORTB               EQU     PIA2+1
PORTC               EQU     PIA2+2
PORTCTRL            EQU     PIA2+3

;* PIA CONTROL BYTES FOR READ AND WRITE TO IDE DRIVE

RD_IDE_8255         EQU     $92     ; %10010010 PORT C CTRL OUT, PORT A/B DATA INPUT
WR_IDE_8255         EQU     $80     ; %10000000 ALL 3 PORTS OUTPUT

;* PIA CTRL PORT BIT FUNCTIONS

IDE_A0              EQU     $01
IDE_A1              EQU     $02
IDE_A2              EQU     $04
IDE_CS0             EQU     $08     ; INVERTED ON BOARD - SO SET FOR SELECT
IDE_CS1             EQU     $10     ; INVERTED - SO SET FOR SELECT
IDE_WR              EQU     $20     ; INVERTED - SO SET FOR WRITE
IDE_RD              EQU     $40     ; INVERTED - SO SET FOR READ
IDE_RST             EQU     $80     ; INVERTED - SO SET FOR RESET

; COMPACT FLASH REGISTER CONSTANTS FOR A BETTER READING OF THE CODE

IDE_DATA            EQU     IDE_CS0                      ; DATA R/W
IDE_ERR             EQU     IDE_CS0+IDE_A0               ; READ ERROR CODE
IDE_SET_FEAT        EQU     IDE_CS0+IDE_A0               ; WRITE FEATURE
IDE_SEC_CNT         EQU     IDE_CS0+IDE_A1               ; NUMBER OF SECTORS TO TRANSFER
IDE_LBA0            EQU     IDE_CS0+IDE_A1+IDE_A0        ; SECTOR ADDRESS LBA 0 [BITS 0:7]
IDE_LBA1            EQU     IDE_CS0+IDE_A2               ; SECTOR ADDRESS LBA 1 [BITS 8:15]
IDE_LBA2            EQU     IDE_CS0+IDE_A2+IDE_A0        ; SECTOR ADDRESS LBA 2 [BITS 16:23]
IDE_LBA3            EQU     IDE_CS0+IDE_A2+IDE_A1        ; SECTOR ADDRESS LBA 3 [BITS 24:27 (LSB)]
IDE_COMMAND         EQU     IDE_CS0+IDE_A2+IDE_A1+IDE_A0 ; WRITE COMMAND
IDE_STATUS          EQU     IDE_CS0+IDE_A2+IDE_A1+IDE_A0 ; READ CF STATUS

;* IDE COMMAND CONSTANTS. THESE SHOULD NEVER CHANGE.

IDE_CMD_READ        EQU     $20                 ; READ A LBA
IDE_CMD_WRITE       EQU     $30                 ; WRITE A LBA
IDE_CMD_SET_FEAT    EQU     $EF                 ; SET FEATURES

;* FEATURE REQUESTS

IDE_FEA_16BIT       EQU     $81
LBA3MST             EQU     $E0                 ; LBA3 FOR IDE MASTER
LBA3SLV             EQU     $F0                 ; LBA3 FOR IDE SLAVE

; CF CONTROL BITS

DRQBIT              EQU     %00001000           ; DATA REQUEST BIT = CF STATUS BIT 3
RDYBIT              EQU     %01000000           ; READY BIT = BIT 6
BSYBIT              EQU     %10000000           ; BUSY BIT = BIT 7
ERRBIT              EQU     %00000001           ; ERROR BIT = BIT 0

;**************************
;* scratch storage space  *
;**************************

;* PARAMS TABLE FOR CF

        ORG   (RAM+128-8)

SETFEA  RMB   1          ; SET FEATURE 16 BITS MODE
SCTCNT  RMB   1          ; SECTOR COUNT FOR R/W (ALWAYS 1)
LBA0    RMB   1          ; LBA7 TO LBA0
LBA1    RMB   1          ; LBA15 TO LBA8
LBA2    RMB   1          ; LBA23 TO LBA 16
LBA3    RMB   1          ; B7=1 / B6=1 FOR LBA / B5=1 / B4=0 MASTER B4=1 SLAVE / B3->B0 LBA27 TO LBA24
MSTCFOK RMB   1          ; CF PRESENT FLAGS BY DEFAULT NOT
SLVCFOK RMB   1          ; BOTH SET BY INITCF ROUTINE

        ORG   (RAM+128)

BUFFER  RMB   256          ; Floppy interface sector buffer.

        ORG   SCRAT

STACK   RMB   2            ; User system stack.
NMIV    RMB   2            ; NMI interrupt vector.
IRQV    RMB   2            ; IRQ interrupt vector.
FIRQV   RMB   2            ; FIRQ interrupt vector.
SWI2V   RMB   2            ; SWI2 interrupt vector.
SWI3V   RMB   2            ; SWI3 interrupt vector.
IPORT   RMB   1            ; Active input port.
OPORT   RMB   1            ; Active output port.
DRIVE   RMB   1            ; Format drive value.
TRACK   RMB   1            ; Format track value.
SECTOR  RMB   1            ; Format sector value.
TEMP    RMB   1
XTEMP   RMB   2
YTEMP   RMB   2
TTO     RMB   2
RNDM    RMB   4            ; Random number storage.
WARMS   RMB   1            ; Warm start flag.
DDSTAB  RMB   4            ; Disc driver type table.
REAVEC  RMB   2            ; Disc driver jump tables.
WRIVEC  RMB   2
VERVEC  RMB   2
RSTVEC  RMB   2
DRVVEC  RMB   2
CHKVEC  RMB   2
QUIVEC  RMB   2
INIVEC  RMB   2
WARVEC  RMB   2
SEEVEC  RMB   2

;*********************************************
;* Extra scratch space for system dependant  *
;* routines fits here.                       *
;*********************************************
;* LIB SCRATCH
;*
RTCFAIL EQU   $DFB5        ; ?
CURDRV  EQU   $DFB6        ; ?
XCOORD  EQU   $DFB7        ; ?
YCOORD  EQU   $DFB9        ; ?
PART1   EQU   $DFBB        ; ?
PART2   EQU   $DFBF        ; ?
GPARAM  EQU   $DFC3        ; ?
MDFC4   EQU   $DFC4        ; ?
GMODE   EQU   $DFCB        ; ?
GZOOM   EQU   $DFCC        ; ?
GFIGS   EQU   $DFCD        ; ?
DN      EQU   $DFCE        ; ?
D0      EQU   $DFD0        ; ?
D1      EQU   $DFD1        ; ?
D2      EQU   $DFD2        ; ?
D4      EQU   $DFD4        ; ?
DM      EQU   $DFD6        ; ?
CONST   EQU   $DFD8        ; ?
ROW     EQU   $DFD9        ; ?
COL     EQU   $DFDA        ; ?
ATTRI   EQU   $DFE1        ; ?
CURSOR  EQU   $DFE5        ; ?
CTYPE   EQU   $DFEA        ; ?
ESCFLG  EQU   $DFEB        ; ?
TS1     EQU   $DFEC        ; ?
TS2     EQU   $DFEE        ; ?
TL1     EQU   $DFF0        ; ?
TL2     EQU   $DFF2        ; ?
DEN     EQU   $DFF4        ; Density
DEN1    EQU   $DFF5
STEP    EQU   $DFF6        ; Floppy stepping speed
SPEED   EQU   $DFF7        ; SAM speed setting
TSTEP   EQU   $DFF8        ; ?
PSPEED  EQU   $DFF9        ; ?
MDFFA   EQU   $DFFA        ; ?
DROMSZ  EQU   $DFFB        ; !!! NOT RELEVANT IN THIS VERSION !!!
REGDP   EQU   $DFFC        ; Current DP Register
FLASH   EQU   $DFFD        ; ?
BLANKD  EQU   $DFFF        ; ?
;*
;*********************************
;* Monitor part of PROM, disabled when FLEX is running
;*********************************

        ORG     PROM

;* LIB MINIT
HDR     FCB     $0A,$0D
        FCC     '+++ Mon09 v5.0B Ph. Roehr 2025 +++'
        FCB     $04
PROMPT  FCB     $0A,$0D
        FCC     '=>'
        FCB     $04
NOTTHS  FCB     $07
        FCC     ' Unknown command! '
        FCB     $04
UNMESS  FCB     $07,$07,$07,$07,$07,$07
        FCB     $07,$07,$07,$07
        FCC     'UNEXPECTED INTERUPT!!!!!!!!!!'
        FCB     $04
PFAIL   FCB     $07,$07,$07
        FCC     'Power failure in RTC, reloading defaults'
        FCB     $04
CFMST   FCC     'Master CF detected'
        FCB     $04
CFSLV   FCC     'Slave CF detected'
        FCB     $04
;*
;* default values for RTC RAM
;*
TCONST  FCB     $50,$FF,$01,$00,$02
        FCB     $03,$08,$00,$3A,$00
        FCB     $50,$00,$00,$08,$00
        FCB     $00,$1B,$00,$01,$1F
        FCB     $2E,$65,$08,$06,$04
        FCB     $20,$41,$00,$00,$00
        FCB     $00,$00,$00,$00,$00
        FCB     $00,$00,$00,$00,$00
        FCB     $00,$00,$00,$00,$00
        FCB     $00,$00,$00,$00,$00
;*
;* System dependant init : part 2 of RESET routine
;*
MINIT1  STX     RNDM
        LDB     #$0D
        JSR     GETRTC     ; read D-reg
        ANDA    #$80       ; mask off bit 0-6
        STA     RTCFAIL    ; =0 if no power
        LDA     SYSREG
        COMA
        LSRA
        LSRA
        LSRA
        LSRA
        TFR     A,B
        ANDB    #$01
        STB     IPORT
        TFR     A,B
        LSRB
        ANDB    #$01
        STB     OPORT
        TST     RTCFAIL
        BNE     INIT2      ; RTC data valid ?
        LDX     #TCONST    ; no, so get default values
        LDB     #$0E
IRTC    LDA     ,X+
        JSR     PUTRTC
        INCB
        CMPB    #$40
        BNE     IRTC
INIT2   LDB     #$0E       ; get RTC saved data
        JSR     GETRTC
        TFR     A,B
        ANDA    #$80
        STA     PSPEED     ; init cpu speed (?)
        TFR     B,A
        ANDA    #$40
        STA     MDFFA      ; init ?
        TFR     B,A
        ANDA    #$30
        ASLA
        ASLA
        ANDA    #$C0
        STA     DROMSZ     ; !!! NOT RELEVANT IN THIS VERSION !!!
        TFR     B,A
        ANDA    #$0C
        LSRA
        LSRA
        STA     SPEED      ; init cpu speed
        TFR     B,A
        ANDA    #$03
        STA     TSTEP      ; init disc step speed
        CLRA
        ADDA    SPEED
        STA     COMREG
        TST     PSPEED
        BEQ     INIT3
        STA     SET_R1     ; init SAM values for FAST/SLOW
INIT3   LDA     #$CE
        STA     ACIA1+1    ; init acia 1 and 2
        STA     ACIA2+1    ; 2 stop bits,no parity,8 bits,baud rate factor=X16
        LDA     #$27
        STA     ACIA1+1    ; enable reciever & transmitter
        STA     ACIA2+1
        LDB     #$0F
        JSR     GETRTC
        STA     BAUD       ; 9600 baud
        LSRA
        LSRA
        LSRA
        LSRA
        STA     BAUD+1
        JSR     GDCINI     ; init graphic controler
        LDA     #$9B
        STA     PIA2+3
        LDB     #$10
        LDX     #DDSTAB    ; load disc drive table
INIT4   JSR     GETRTC
        STA     ,X+
        INCB
        CMPB    #$14
        BNE     INIT4
        TST     RTCFAIL    ; message if RTC data not valid
        BNE     RTCOK
        LDX     #PFAIL
        JSR     PSTRNG

;* IDE/CF detection and init
RTCOK   LDA     #25
        JSR     WAIT1MS    ; wait 25 ms after power on
        LDA     #RD_IDE_8255
        STA     PORTCTRL   ; set port C as output
        LDA     #IDE_RST   ; do a ide bus reset
        STA     PORTC
        LDA     #10        ; keep reset low > 25 µs
LOOPRST DECA
        BNE     LOOPRST
        CLR     PORTC
        LDA     #5
        JSR     WAIT1MS    ; wait 5 ms for cf to complete init
        LDD     #$0000     ; init ram cf table
        STD     MSTCFOK    ; clear both cf present flags
        LDA     #IDE_FEA_16BIT      ; prepare for 16 bits mode
        STA     SETFEA
        LDA     #$01       ; prepare for rw 1 sector at a time
        STA     SCTCNT
        LDA     #LBA3MST   ; prepare for master cf
        STA     LBA3
        CLR     LBA2       ; set all lba's to 0
        CLR     LBA1
        CLR     LBA0
        JSR     INIDT2     ; init typ 2/3 disk
        TST     MSTCFOK    ; master cf ok ?
        BEQ     CONTINI    ; no continue init
        LDX     #CFMST     ; display master cf message
        JSR     PSTRNG
        TST     SLVCFOK    ; slave cf ok ?
        BEQ     CONTINI    ; no continue init
        LDX     #CFSLV     ; display slave cf message
        JSR     PSTRNG
;* End of IDE/CF init

CONTINI LDA     SYSREG
        COMA               ; autoboot ?
        LBMI    BO         ; yes, boot FLEX
        JMP     MINITR     ; no, go to monitor
;*
;***************************
;* Jump table for commands *
;***************************
COMTAB  FCC     'HD' ; Hex dump .
        FDB     HD
        FCC     'DR' ; Display cpu registers.
        FDB     DR
*
        FCC     'SB' ; Set baud rate for acia's.
        FDB     SB
        FCC     'SI' ; Set input port.
        FDB     SI
        FCC     'SO' ; Set output port.
        FDB     SO
        FCC     'CD' ; Calculate two's complement branch length.
        FDB     CD
*
        FCC     'RP' ; Run program .
        FDB     RP
        FCC     'JU' ; Jump to program .
        FDB     JU
        FCC     'JF' ; Jump to flex warm start ($CD03).
        FDB     JF
        FCC     'CP' ; Continue program after SWI.
        FDB     CP
*
        FCC     'ME' ; Memory examine and alter .
        FDB     ME
        FCC     'PM' ; Poke memory with value (no verify of data).
        FDB     PM
        FCC     'LK' ; Load ascii text from keyboard .
        FDB     LK
        FCC     'SM' ; Shift a block of memory .
        FDB     SM
        FCC     'FM' ; Fill memory with a constant value.
        FDB     FM
        FCC     'FI' ; Find ascii string.
        FDB     FI
*
        FCC     'TM' ; Quick memory test.
        FDB     TM
        FCC     'TS' ; Drive stepping and select test.
        FDB     TS
        FCC     'TD' ; Test random read on drive.
        FDB     TD
*
        FCC     'BO' ; Boot FLEX.COR or FLEX.SYS from logical drive 0
        FDB     BO
        FCC     'RS' ; Read sector from floppy.
        FDB     RS
        FCC     'WS' ; Write sector to floppy.
        FDB     WS
        FCC     'DF' ; Format disc to FLEX format.
        FDB     DF
;*
;*************************************
;* Extra system dependant command    *
;* entries fit here.                 *
;*************************************
;* LIB COMTABLE
;*
        FCC     'BF' ; Boot Flex from floppy 0 regardless of allocation
        FDB     BF
        FCC     'DC' ; Display RTC contents
        FDB     DC
        FCC     'MC' ; RTC examine and alter
        FDB     MC
;*
        FCB     $FF  ; End of table flag.
;*
;***************************
;* Common system commands. *
;***************************
;*
;* Jump to program.
JUMES   FCB     $0D,"Jump to program at ",4

JU      LDX     #JUMES
        JSR     PDATA1
        JSR     BADDR
        JMP     MAPOUT
;*
;* Jump to flex warm start.
JFMES   FCB     $0D,"Jump to flex warm start.",4

JF      LDX     #JFMES
        JSR     PDATA1
        LDX     #$CD03
        JMP     MAPOUT
;*
;* Set input port.
SIMES   FCB     $0D,"Set input port to ",4

SI      LDX     #SIMES
        JSR     PDATA1
        JSR     INHEX
        ANDA    #$03
        STA     IPORT
        JMP     CONTRL
;*
;* Set output port.
SOMES   FCB     $0D,"Set output port to ",4

SO      LDX     #SOMES
        JSR     PDATA1
        JSR     INHEX
        ANDA    #$03
        STA     OPORT
        JMP     CONTRL
;*
;********************************
;*    System specific Boot      *
;*    command goes here.        *
;********************************
;* LIB BOOT
BOMES   FCB     $0D
        FCC     "Booting FLEX...."
        FCB     $04
NOFLX   FCB     $0A,$0D,$07
        FCC     "Can't find FLEX!" ; Can't find FLex
        FCB     $04
BODIS   FCC     "FLEX"
        FCB     $00,$00,$00,$00

;* Action BO (BOot flex from logical drive 0)
BO      LDX     #BOMES     ; send message
        JSR     PDATA1
        CLR     DRIVE      ; select drive 0
        LDX     #DRIVE-3
        JSR     RST        ; drive select and track 0
        LDB     #$05       ; sector 5
        STB     SECTOR
        CLRA
        STA     TRACK      ; (start of directory)
BO1     LDB     SECTOR
        LDA     TRACK
        LDX     #BUFFER    ; point to buffer
        JSR     READ       ; read sector
        LDX     #BUFFER+16 ; point to 1st name
        LDB     #$0A       ; names per sector
BO2     LDY     #BODIS     ; (compare template)
        PSHS    X          ; save addr of name
BO3     LDA     ,X+        ; compare characters
        CMPA    ,Y+
        BNE     BO4        ; match ?
        CMPY    #BO        ; yes,all done ?
        BNE     BO3        ; no,compare next
        LDD     $05,X      ; yes,get start addr
        STD     YTEMP      ; of file & store it
        BRA     RDSEC      ; go and load it
BO4     DECB               ; no match.next name
        BEQ     BO5        ; end of sector ?
        PULS    X          ; no,recover name addr
        LEAX    $18,X      ; point to next name
        BRA     BO2        ; and try again
BO5     LDD     BUFFER     ; next dir sector
        BEQ     BOFAIL     ; end of directory ?
        STD     TRACK      ; no,update T/S addr
        BRA     BO1        ; and try again
BOFAIL  LDX     #NOFLX     ; yes,failed !
        JSR     PSTRNG     ; send error message
        JMP     CONTRL     ; and back to Mono9
* Load Flex.sys
RDSEC   LDD     YTEMP      ; (T/S adr. of file)
        STD     BUFFER     ; put in buffer
        LDY     #BUFFER+256
BOFL1   BSR     NEXTB
        CMPA    #$02       ; binary record ?
        BEQ     BOFL2      ; yes,go set TTO
        CMPA    #$16       ; transfer addr ?
        BNE     BOFL1      ; cont.until 02 or 16
        BSR     NEXTB      ; it was a transfer addr
        BSR     NEXTB      ; Discard it and
        BRA     BOFL1      ; find next record
BOFL2   BSR     NEXTB      ; get load adr.Hi
        STA     TTO
        BSR     NEXTB      ; get load adr.Lo
        STA     TTO+1
        BSR     NEXTB      ; get byte count
        TFR     A,B        ; put it in ACC B
        TSTB               ; if 0, end of record
        BEQ     BOFL1      ; go find next rec
        LDX     TTO        ; else,copy to [TTO]
BOFL3   PSHS    X,B        ; save count & adr
        BSR     NEXTB      ; get a byte
        PULS    X,B        ; recall cnt.& adr skip
        CMPX    #RAM       ; Microbox loads
        BHI     BOFL4      ; this area from tables
        STA     ,X+
BOFL4   DECB               ; end of record ?
        BNE     BOFL3      ; no,continue
        BRA     BOFL1      ; yes,find next rec

;* This subroutine gets the next byte from the buffer
;* into ACC A. If the buffer is empty,the next sector
;* is first read into the buffer. If all sectors have
;* been read,a branch to 'Read tables & Exit' occures.
;*
NEXTB   CMPY    #BUFFER+256
        BNE     NEXT2      ; buffer empty ?
        LDX     #BUFFER    ; yes,read next sector
        LDD     ,X         ; look at link adr
        BEQ     LDTBL      ; no more, do tables
        JSR     READ
;* If read error,density setting is toggled so try again
        BNE     RDSEC      ; error if not 0
        LDY     #BUFFER+4  ; point to name
NEXT2   LDA     ,Y+
        RTS
;*
;* Read Tables & Exit
;*
LDTBL   LDX     #CINCHN    ; load table 1
        LDY     #TABLE1
LDTB1   LDD     ,Y++
        STD     ,X++
        CMPX    #$D3FD
        BNE     LDTB1
        LDX     #RAM
        LDY     #TABLE2    ; load table 2
LDTB2   LDD     ,Y++
        STD     ,X++
        CMPX    #$DE1E
        BNE     LDTB2
        LDA     #$39
        STA     MCA02
        TST     RTCFAIL    ; valid data ?
        BEQ     GOFLX      ; no,ignore
        LDX     #TTYBS     ; else,copy in
        LDB     #$14       ; TTYSET & ASN options
CPRTC   JSR     GETRTC
        STA     ,X+
        INCB
        CMPB    #$21
        BNE     CPRTC
GOFLX   LDX     #COLDS     ; select Cold Start
        JMP     MAPOUT     ; and jump to it
;*
;* Table 1 : console I/O
;*
TABLE1  FDB     INCH1
        FDB     DUMMY
        FDB     VCRST
        FDB     VCRST
        FDB     DUMMY
        FDB     DUMMY
        FDB     DUMMY
        FDB     CONTRL
        FDB     DUMMY
        FDB     STATUS
        FDB     OUTCH
        FDB     INCH
;*
;* Table 2 : disk I/O
TABLE2  JMP     READ
        JMP     WRITE
        JMP     VERIFY
        JMP     RST
        JMP     DRV
        JMP     CHKRDY
        JMP     QUICK
        JMP     DINIT
        JMP     WARM
        JMP     SEEK
;*
;*         Calculate displacement.
CALDIS  FCB     $0D,"Calculate displacement from ",4
TOS     FCB     " to ",4
CALD1   FCB     $0D,$0A," Long or short branch (L/S)? ",4
VALUES  FCB     " value ",4

CD      LDX     #CALDIS
        JSR     PDATA1
        JSR     BADDR      ; get 'from'
        LEAX    2,X        ; add 2
        PSHS    X          ; save it
        LDX     #TOS
        JSR     PDATA1
        JSR     BADDR      ; get 'to'
        TFR     X,Y        ; save in Y
        LDX     #CALD1
        JSR     PDATA1
        JSR     INCH       ; get 'L/S'
        CMPA    #'L'       ; was it L ?
        BNE     CD1        ; no,branch
        PULS    X          ; recall 'from'
        LEAX    2,X        ; add 2
        PSHS    X          ; save again
CD1     TFR     Y,D        ; D = 'to'
        SUBD    ,S         ; subtract 'from'
        STD     ,S         ; 'offset' now TO S
        LDX     #VALUES
        JSR     PDATA1
        PULS    X
        JSR     PRINTX     ; 'offset'
        JMP     CONTRL
;*(its not format, the program just send a reset command and configure the cf, no relation with the datas stored)
;* Continue program. [There is a BUG in this routine]
CONPRS  FCB     $0D,"Continue from SWI....",4

CP      LDX     #CONPRS
        JSR     PDATA1
        INC     11,S       ; (PC-low)
        JMP     RP1        ; recover SP & RTI.
;* BUG here? What if PC-low = $FF ???
;* why not  LDX   10,S
;* LEAX   1,X
;* STX   10,S   ie. Increment PC.
;*
;* Fill memory with constant.
FILMES  FCB     $0D,"Fill memory with constant from ",4

FM      LDX     #FILMES
        JSR     PDATA1
        JSR     BADDR      ; get 'from'
        TFR     X,Y        ; save in Y
        LDX     #TOS
        JSR     PDATA1
        JSR     BADDR      ; get 'to'
        PSHS    X          ; save in X
        LDX     #VALUES
        JSR     PDATA1
        JSR     BYTE       ; get 'value'
FM1     STA     ,Y+        ; fill until
        CMPY    ,S         ; from = to
        BNE     FM1        ; then
        PULS    X          ; tidy stack
        JMP     CONTRL
;*
;* Go to user routine at XXXX.
RUNPRS  FCB     $0D,"Run program from ",4

RP      LDX     #RUNPRS
        JSR     PDATA1
        JSR     BADDR      ; input start addr
        STX     10,S       ; stack it as PC
        LDA     #$FF
        STA     ,S         ; stack as CC
RP1     LDS     STACK      ; recover SP
        RTI                ; load all registers
;*
;* SWI return from user program.
SWI     STS     STACK      ; save SP
        LDX     10,S       ; get PC
        LEAX    -1,X       ; decrement it
        STX     10,S       ; and put it back
        JMP     DR1        ; display registers
;*
;* Hexdump of memory starting at XXXX.
;* @@ Modified 04/2025 PhR to get also ascii display on each line
HEXDUS  FCB     $0D,"Hex dump of memory from ",4
HDMES1  FCB     "     0  1  2  3  4  5  6  7   8  9  A  B  C  D  E  F  ",4

HD      LDX     #HEXDUS
        JSR     PDATA1
        JSR     BADDR      ; get start addr
        JSR     PCRLF
HD4     LDY     #16
        JSR     PCRLF
        PSHS    X
        LDX     #HDMES1
        JSR     PSTRNG     ; print header
        PULS    X
HD1     JSR     PCRLF
        JSR     PRINTX     ; print address
        LDB     #16        ; byte counter
HD2     JSR     OUT2HS     ; print a byte
        DECB
        BEQ     HD3        ; end of line ?
        CMPB    #8         ; half way ?
        BNE     HD2
        JSR     OUTS       ; yes,print a space
        BRA     HD2
; @@ BEGIN ASCII DUMP ADD
HD3     JSR     OUTS       ; @@ print space
        LDB     #-16       ; @@ prepare for 16 loops
ASCLOOP LDA     B,X        ; @@ load byte
        CMPA    #$20       ; @@ printable ?
        BLT     NOTPRT     ; @@ no
        CMPA    #$7F       ; @@ printable ?
        BLT     HDCONT     ; @@ yes
NOTPRT  LDA     #'.'       ; @@ if not printable print a dot
HDCONT  JSR     OUTCH      ; @@ now print
        INCB               ; @@ next byte
        BNE     ASCLOOP    ; @@ 16 bytes printed ? no do again
; @@ END ASCII DUMP ADD
        LEAY    -1,Y       ; end of page ?
        BNE     HD1        ; no,do another line
        JSR     INCH       ; yes,input a char
        CMPA    #$0D       ; if char == CR
        BEQ     HD4        ; do another page
        CMPA    #'-'       ; if char == '-'
        LBNE    CONTRL
        LEAX    -512,X     ; do previous page
        BRA     HD4
;*
;* Poke memory.
POKMES  FCB     $0D,"Poke memory at ",4

PM      LDX     #POKMES
        JSR     PDATA1
        JSR     BADDR      ; input addr
        TFR     X,Y
        LDX     #VALUES
        JSR     PDATA1
        JSR     BYTE       ; input 'value'
        STA     ,Y         ; store at addr
        JMP     CONTRL
;*
;* Keyboard to memory.
LOAKES  FCB     $0D,"Load memory with text from keyboard to ",4

LK      LDX     #LOAKES
        JSR     PDATA1
        JSR     BADDR      ; input addr
        TFR     X,Y
        LDX     #VALUES
        JSR     PDATA1
LK1     JSR     INCH       ; input a character
        STA     ,Y+        ; store it
        CMPA    #$04       ; was it EOT ?
        BNE     LK1        ; no,input another
        JMP     CONTRL
;*
;* Memory load and examine.
MEMEXS   FCB    $0D,"Memory examine and modify from ",4
NORAM    FCB    7,"  No ram at that address!",4

ME      LDX     #MEMEXS
        JSR     PDATA1
        JSR     BADDR      ; input addr
ME1     JSR     PCRLF
        JSR     PRINTX     ; display addr
        JSR     OUT2HS     ; and content
        JSR     INCH       ; input a char
        CMPA    #'-'       ; was it a '-' ?
        BNE     ME2
        LEAX    -2,X       ; yes,back 2 locations
        BRA     ME1
ME2     CMPA    #$0D       ; was it CR ?
        BEQ     ME1        ; yes,display next
        CMPA    #$20       ; was it a space ?
MED     LBNE    CONTRL     ; no,abort
        JSR     BYTE       ; yes,input byte
        STA     -1,X       ; overwrite old byte
        CMPA    -1,X       ; read it back
        BEQ     ME1        ; OK,display it
        LDX     #NORAM     ; cant read,send
        JSR     PDATA1     ; error message
        JMP     CONTRL
;*
;* Print registers.
DISRES  FCB     $0D,"Display CPU registers.",4
RSTRNG  FCB     $0A,$0D,"CC  A  B DP    X    Y    U   PC    S",$0A,$0D,4

DR      LDX     #DISRES
        JSR     PDATA1
DR1     LDX     #RSTRNG
        JSR     PDATA1     ; print header
        TFR     S,X
        JSR     OUT2HS     ; print registers
        JSR     OUT2HS
        JSR     OUT2HS
        JSR     OUT2HS
        JSR     OUT4HS
        JSR     OUT4HS
        JSR     OUT4HS
        JSR     OUT4HS
        LDX     #STACK     ; get Stack Pointer
        JSR     OUT4HS     ; print it
        JMP     CONTRL
;*
;* Shift blocks of memory.
SHIMES  FCB     $0D,"Shift block of memory from ",4
LENGHS  FCB     " Length ",4

SM      LDX     #SHIMES
        JSR     PDATA1
        JSR     BADDR      ; get 'from' addr
        PSHS    U
        TFR     X,U        ; store it in U
        LDX     #TOS
        JSR     PDATA1
        JSR     BADDR      ; get 'to' addr
        TFR     X,Y        ; store it in Y
        LDX     #LENGHS
        JSR     PDATA1
        JSR     BADDR      ; get length of block
SM1     LDA     ,U+        ; move a byte
        STA     ,Y+
        LEAX    -1,X       ; dec. length
        BNE     SM1        ; repeat 'till end
        PULS    U
        JMP     CONTRL
;*
;* Test memory.
TESMES  FCB     $0D,"Test memory from ",4
TMS1    FCB     7,$0A,$0D,"Error at location ",4
TMS2    FCB     "changed to ",4
TMS3    FCB     " Testing now with ",4

TM      LDX     #TESMES
        JSR     PDATA1
        JSR     BADDR      ; get 'from'
        TFR     X,Y        ; put in Y
        LDX     #TOS
        JSR     PDATA1
        JSR     BADDR      ; get 'to'
        STX     XTEMP      ; store it
        CLRB
        LDX     #TMS3
        JSR     PDATA1
TM5     STB     TEMP       ; store 'with'
        LDX     #TEMP
        JSR     OUT2H      ; display 'with'
        TFR     Y,X
TM1     STB     ,Y         ; write/read test
        CMPB    ,Y
        BNE     TM2        ; test fails,branch
TM4     LEAY    1,Y        ; else,next location
        CMPY    XTEMP      ; all done ?
        BNE     TM1
        INCB               ; yes,next 'with' byte
        BEQ     TM3        ; done 'em all.Exit
        LDA     #$08       ; else,update 'with'
        JSR     OUTCH      ; byte,return to
        JSR     OUTCH      ; first location
        TFR     X,Y        ; and continue
        BRA     TM5
TM3     JMP     CONTRL
TM2     LDX     #TMS1      ; error message
        JSR     PDATA1
        STY     XTEMP
        LDX     #XTEMP     ; (faulty location)
        JSR     OUT4HS
        JSR     OUTS
        JSR     OUTS
        STB     TEMP       ; (test byte)
        LDX     #TEMP
        JSR     OUT2HS
        LDX     #TMS2
        JSR     PDATA1
        LDA     ,Y         ; (byte read back)
        STA     TEMP
        LDX     #TEMP
        JSR     OUT2HS
        BRA     TM3        ; exit
;*
;*
;* Read floppy sector.
REASES  FCB     $0D,"Read from sector on drive ",4
TRACS   FCB     " track ",4
SECS    FCB     " sector ",4
ERR1    FCB     $0D,$0A,7,"FDC error code = ",4

RS      LDX     #REASES
        JSR     PDATA1
        JSR     INHEX      ; get drive No
        STA     DRIVE
        LDX     #(DRIVE-3)
        JSR     DRV        ; get drive
        LDX     #TRACS
        JSR     PDATA1
        JSR     BYTE       ; get track
        STA     TRACK
        LDX     #SECS
        JSR     PDATA1
        JSR     BYTE       ; get sector
        STA     SECTOR
        LDX     #TOS
        JSR     PDATA1
        JSR     BADDR      ; get load addr
        LDA     TRACK
        LDB     SECTOR
        JSR     READ       ; read it in
        LBEQ    CONTRL     ; if no read error
        LDX     #ERR1
        JSR     PDATA1     ; else,error message
        STB     TEMP       ; (status,masked)
        LDX     #TEMP
        JSR     OUT2HS     ; error No
        JMP     CONTRL
;*
;* Write floppy sector
WRIMES  FCB     $0D,"Write to sector on drive ",4
FROMS   FCB     " from ",4

WS      LDX     #WRIMES
        JSR     PDATA1
        JSR     INHEX      ; get drive No
        STA     DRIVE
        LDX     #(DRIVE-3)
        JSR     DRV        ; get drive
        LDX     #TRACS
        JSR     PDATA1
        JSR     BYTE       ; get track
        STA     TRACK
        LDX     #SECS
        JSR     PDATA1
        JSR     BYTE       ; get sector
        STA     SECTOR
        LDX     #FROMS
        JSR     PDATA1
        JSR     BADDR      ; get data addr
        LDA     TRACK
        LDB     SECTOR
        JSR     WRITE      ; write sector
        LBEQ    CONTRL     ; if no write error
        LDX     #ERR1
        JSR     PDATA1     ; else,error message
        STB     TEMP
        LDX     #TEMP
        JSR     OUT2HS
        JMP     CONTRL
;*
;* Format disc to FLEX standard.
DISFOS  FCB     $0D,"Format disc to flex standard on drive ",4
SURES   FCB     " scratch disc in drive? ",4

DF      LDX     #DISFOS
        JSR     PDATA1
        JSR     INHEX      ; get drive No
        STA     DRIVE
        LDX     #DRIVE-3
        JSR     RST        ; restore to 00
        CLR     DEN        ; set single density
        LDX     #SURES     ; prompt for scratch
        JSR     PDATA1     ; disc in drive
        JSR     INCH       ; get reply
        CMPA    #'Y'       ; if not 'Y'
        LBNE    CONTRL     ; then abort
FMT     LDA     #$FF       ; else,initialise
        STA     TRACK      ; (01-1)
        LDY     #$0002     ; (track/sector)
FMT1    CLRA
        STA     SECTOR     ; (01-1)
        INC     TRACK
        LDA     TRACK
        LDB     #1
        JSR     SEEK
;* This is written to all tracks
        CLRA
        LDX     #0400      ; starting this addr
        LDB     #6
        LBSR    WABT       ; 6 bytes---00
        LDA     #$FC
        STA     ,X+        ; 1 bytes---FC
        LDD     #$FF07
        LBSR    WABT       ; 7 bytes---FF
;* This written to all sectors
FMT2    CLRA
        INC     SECTOR
        LDB     #6
        LBSR    WABT       ; 6 bytes---00
        LDA     #$FE
        STA     ,X+        ; 1 bytes---FE
        LDA     TRACK
        STA     ,X+        ; 1 bytes---[TRACK]
        CLRA
        STA     ,X+        ; 1 bytes---00
        LDA     SECTOR
        STA     ,X+        ; 1 bytes---[SECTOR]
        LDA     #1
        STA     ,X+        ; 1 bytes---01
        LDA     #$F7
        STA     ,X+        ; 1 bytes---F7
        LDD     #$FF0B
        LBSR    WABT       ; 11 bytes---FF
        CLRA
        LDB     #6
        LBSR    WABT       ; 6 bytes---00
        LDA     #$FB
        STA     ,X+        ; 1 bytes---FB
;* Enter track/sector link, clear data bytes,
;* update track/sector link.
        TFR     Y,D        ; get T/S link addr
        STD     ,X++       ; enter it
        INCB
        CMPB    #11        ; all sectors done ?
        BNE     FMT3       ; no,continue
        INCA               ; yes,update T/S
        LDB     #1         ; link address
        CMPA    #40        ; all tracks done ?
        BNE     FMT3       ; no,continue
        LDD     #0         ; yes,clear T/S link
FMT3    TFR     D,Y        ; save updated link
        CLRA               ; clear data bytes
        LDB     #254       ; 254 bytes---00
        LBSR    WABT
        LDA     #$F7
        STA     ,X+        ; 1 bytes---F7
        LDD     #$FF0E
        LBSR    WABT       ; 14 bytes---FF
        LDA     SECTOR
        CMPA    #10        ; last sector ?
        BNE     FMT2       ; no,do next
        LDA     #$FF
        CLRB
        LBSR    WABT       ; 256 bytes---FF
;* Write a track to disc
        LDX     #0400
        LDA     #$F4       ; write track cmd.
        LBSR    FCMD
FMT4    LDA     COMREG     ; get status
        BITA    #2         ; D-reg empty ?
        BEQ     FMT5
        LDA     ,X+        ; yes,load it
        STA     DATREG
FMT5    LDA     COMREG
        BITA    #1         ; busy ?
        BNE     FMT4       ; yes,wait
        LDA     TRACK
        CMPA    #39        ; last track ?
        LBNE    FMT1       ; no,do next
;* Remove link addr.from final directory sector
        LDX     #DRIVE-3
        JSR     RST
        LDX     #BUFFER    ; read T/S 00/0A
        CLRA               ; into buffer
        LDB     #10        ; zero the link addr
        JSR     READ       ; (no more directory sectors)
        LDX     #BUFFER
        CLR     ,X
        CLR     1,X
        CLRA
        LDB     #10        ; and write it
        JSR     WRITE      ; back to disc
;* Enter data to Sys.Information sector
        LDX     #BUFFER
        CLRA
        LDB     #3
        JSR     READ       ; read T/S 00/03
        LDX     #BUFFER
        CLR     ,X         ; clear link addr
        CLR     1,X
        LDD     #$5343     ; enter name of disc
        STD     16,X
        LDD     #$5241     ; (SCRATCH!)
        STD     18,X
        LDD     #$5443
        STD     20,X
        LDD     #$4821
        STD     22,X
        LDD     #1         ; enter Vol. No
        STD     27,X
        LDD     #$0101     ; enter start of
        STD     29,X       ; free chain
        LDD     #$270A     ; enter end of
        STD     31,X       ; free chain and
        STD     38,X       ; highest sector adr
        LDD     #$0186     ; enter length of
        STD     33,X       ; free chain. (ie.
        CLRA               ; sectors left)
        LDB     #3
        JSR     WRITE      ; write it back
        JMP     CONTRL
;*
;* This subroutine stores ACCA in [B] locations
;* starting at location [X]
WABT    PSHS    B
WABT1   STA     ,X+
        DECB
        BNE     WABT1
        PULS    B,PC
;*
;* Random read test on drive.
TDMES   FCB     $0D,"Random sector read on drive ",4
TDMES1  FCB     "Hit any key to stop.",4
ERR2    FCB     "at track/sector ",4

TD      LDX     #TDMES
        JSR     PDATA1
        JSR     INHEX      ; get drive No
        STA     DRIVE
        LDX     #TDMES1
        JSR     PSTRNG
        LDX     #(DRIVE-3)
        JSR     RST
TDLOOP  JSR     RANDOM     ; get a random No
        ANDA    #$0F       ; 15 max
        ADDA    #1         ; >0
        CMPA    #10        ; >10 ?
        BGT     TDLOOP     ; yes,get another
        STA     SECTOR     ; else,store it
TDLP2   JSR     RANDOM     ; get a random No
        ANDA    #$3F       ; 63 max
        CMPA    #39        ; >39 ?
        BGT     TDLP2      ; yes,get another
        STA     TRACK      ; else,set random
        LDB     SECTOR     ; track and sector
        LDX     #BUFFER
        JSR     READ       ; read into buffer
        BNE     TDLP9      ; read error if <> 0
        JSR     STATUS     ; key pressed ?
        BEQ     TDLOOP     ; no,continue
        LDX     #(DRIVE-3) ; yes,
        JSR     RST        ; restore to 00
        JMP     CONTRL     ; and abort
TDLP9   LDX     #ERR1      ; report ----
        JSR     PDATA1
        STB     TEMP
        LDX     #TEMP
        JSR     OUT2HS     ; error No.'x', at
        LDX     #ERR2
        JSR     PDATA1
        LDX     #TRACK
        JSR     OUT4HS     ; 'track/sector'
        BRA     TDLOOP     ; continue
;*
;* Test drive stepping.
TSMESS  FCB     $0D,"Test stepping on drive ",4

TS      LDX     #TSMESS
        JSR     PDATA1
        JSR     INHEX      ; get drive No
        STA     DRIVE
        LDX     #(DRIVE-3)
        JSR     DRV        ; select drive
TSLOOP  LDA     #40        ; track 40,sector 1
        LDB     #1
        JSR     SEEK
        JSR     RST        ; restore to 00
        JSR     STATUS     ; key pressed ?
        LBNE    CONTRL     ; yes,abort
        BRA     TSLOOP     ; no,do it again
;*
;*
;********************************************
;* Extra system dependant commands go here. *
;********************************************
;* LIB COMMANDS
;* Boot Flex from floppy 0 regardless of allocation
BF      CLR     DDSTAB     ; set Drv.0=floppy 0
        LBRA    BO         ; jump to loader
        JMP     CONTRL     ; this appears to be redundant ?
;*
;* Display RTC non volatile data
DCMES   FCB     $0D
        FCC     "Display RTC contents."
        FCB     $04

DC      LDX     #DCMES     ; print header
        JSR     PDATA1
        JSR     PCRLF
        CLRB               ; point to 1st byte
        LDX     #$000E
        BSR     PBLIN      ; time, date & regs (14 bytes)
        LDX     #$0001
        BSR     PBLIN      ; configuration SW (1byte)
        LDX     #$0001
        BSR     PBLIN      ; baudrates (1 byte)
        LDX     #$0004
        BSR     PBLIN      ; disc allocations (4 bytes)
        LDX     #$000B
        BSR     PBLIN      ; ttyset (11 bytes)
        LDX     #$0002
        BSR     PBLIN      ; asn (2 bytes)
        LDX     #$0008
        BSR     PBLIN      ; GDC defaults (8 bytes)
        LDX     #$0007
        BSR     PBLIN      ; reserved (7 bytes)
        LDX     #$0010
        BSR     PBLIN      ; not used (16 bytes available)
        JMP     CONTRL
;*
;* Prints a line of bytes
PBLIN   JSR     GETRTC     ; get byte
        INCB               ; point to next
        STA     TEMP
        PSHS    X
        LDX     #TEMP      ; output bytes
        JSR     OUT2HS
        PULS    X
        LEAX    -$01,X
        BNE     PBLIN      ; until line finished
        JSR     PCRLF
        RTS
;*
;* Modify RTC non volatile data
MCMES   FCB     $0D
        FCC     "RTC examine and alter"
        FCC     " from "
        FCB     $04

MC      LDX     #MCMES
        JSR     PDATA1     ; print header
        JSR     BYTE       ; input offset
        TFR     A,B
MC1     ANDB    #$3F
        JSR     PCRLF
        STB     TEMP
        LDX     #TEMP
        JSR     OUT2HS     ; print offset
        JSR     GETRTC     ; get that byte
        STA     TEMP
        LDX     #TEMP
        JSR     OUT2H      ; and print it
        JSR     INCH       ; input a char
        CMPA    #$20       ; was it a space ?
        BNE     MC2
        JSR     BYTE       ; yes,input a byte
        JSR     PUTRTC     ; put in RTC
        INCB               ; point to next
        BRA     MC1        ; and jump to it
MC2     CMPA    #$0D       ; was it <cr> ?
        BNE     MC3
        INCB               ; yes,point to next
        BRA     MC1
MC3     CMPA    #$2D       ; was it a '-' ?
        LBNE    CONTRL     ; no,exit
        DECB               ; yes,backpeddle 1
        BRA     MC1
;*
;* Find byte string [There is a BUG in this routine ?]
;*
FIMES   FCB     $0D
        FCC     "Find byte string from"
        FCC     " "
        FCB     $04
EBSMS   FCB     $0D,$0A
        FCC     "enter byte string  "
        FCB     $04
;* Get start & end addresses and load the string templet
FI      LDX     #FIMES
        JSR     PDATA1
        JSR     BADDR      ; input 'from'
        STX     YTEMP      ; store it
        LDX     #TOS
        JSR     PDATA1
        JSR     BADDR      ; input 'to'
        STX     TTO        ; store it
        LDX     #EBSMS
        JSR     PDATA1
        LDX     #BUFFER
        CLRB               ; clr. count
FI1     JSR     BYTE       ; input a byte
        STA     ,X+        ; put in buffer
        INCB               ; inc. count
        JSR     INCH       ; input a char
        CMPA    #$20       ; was it a space ?
        BEQ     FI1        ; yes,get next byte
;* Search for a match with the templet
        STB     TEMP       ; length of templet
        LDX     YTEMP      ; point to start adr
        LDY     #BUFFER    ; & start of templet
FI2     LDA     ,X+        ; compare charater
        CMPA    ,Y+
        BNE     FI3        ; no match, branch
        DECB               ; end of string ?
        BNE     FI2        ; no, try next char
        JSR     PCRLF      ; yes,do CRLF
        BSR     FI5        ; print out result
FI3     LDB     TEMP       ; reset count
        LDY     #BUFFER    ; point to 1st char
        CMPX    TTO        ; end of search block ?
        BEQ     FI4        ; yes,exit
;* BUG here. Should LEAX -1,X first...
        BRA     FI2        ; no,continue search
FI4     JMP     CONTRL
;* Print results (if any)
FI5     PSHS    Y,X,D
        LDA     TEMP       ; get length of string
        NEGA
        LEAX    A,X        ; sub.from current adr
        TFR     X,Y        ; copy to Y
        LEAY    -$06,Y     ; Y points to string-6
        STX     XTEMP
        LDX     #XTEMP     ; get addr.of string
        JSR     OUT4HS     ; print it
        TFR     Y,X        ; point to string-6
        LDB     #$10       ; print out 16 bytes
FI6     LDA     ,Y+
        STA     XTEMP
        LDX     #XTEMP
        JSR     OUT2HS
        DECB
        BNE     FI6
        JSR     OUTS       ; followed by 2 spaces
        JSR     OUTS
        LEAY    -$10,Y     ; back to string-6
        LDB     #$10       ; now print ascii
FI7     LDA     ,Y+
        CMPA    #$20       ; is it printable ?
        BGE     FI8        ; yes,print it
        LDA     #$2E       ; no,substitute dot
FI8     JSR     OUTCH
        DECB
        BNE     FI7
        PULS    PC,Y,X,D
;*
;* Set baud Rate
;*
SBMES   FCB     $0D
        FCC     "Set baud rate for acia "
        FCB     $04
SBRMS   FCC     " baud rate = "
        FCB     $04
EBRNK   FCC     " Baud rate not known."
        FCB     $04

SB      LDX     #SBMES
        JSR     PDATA1
        JSR     INHEX      ; get acia No
        ANDA    #$01       ; NB.if acia2,A=0
        STA     TEMP       ; store it
        LDX     #SBRMS     ; ask for baud rate
        JSR     PDATA1
        JSR     INCH       ; input first 2 digits
        TFR     A,B        ; (ascii/decimal),of
        JSR     INCH       ; reqd.baud rate
        EXG     A,B        ; put them in order
        EXG     D,Y        ; and store in Y
        LDX     #TBAUD     ; use look-up table
SB1     CMPY    ,X         ; found it ?
        BEQ     SB2
        LEAX    $06,X      ; no,try next
        CMPX    #EBAUD
        BNE     SB1        ; all tried ?
        LDX     #EBRNK     ; yes,error exit
        JSR     PDATA1
        JMP     CONTRL
SB2     LDA     $02,X      ; print out last 3 digits
        JSR     OUTCH      ; of baud rate
        LDA     $03,X
        JSR     OUTCH
        LDA     $04,X
        JSR     OUTCH
        LDA     $05,X      ; pick-up RTC code and set baud rate
        LDX     #BAUD      ; select register for
        LDB     TEMP       ; nominated acia
        STB     XTEMP
        ABX
        STA     ,X         ; load code
        STA     TEMP       ; save code
        LDB     #$0F       ; get existing RTC
        JSR     GETRTC
        TST     XTEMP      ; which acia ?
        BNE     SB3        ; acia1,branch
        ANDA    #$F0       ; erase acia2 code
        ADDA    TEMP       ; subs. new code
        BRA     SB4        ; go put in clock
SB3     LDB     TEMP       ; was acia1. get code
        ASLB               ; shift into high nibble
        ASLB
        ASLB
        ASLB
        ANDB    #$F0
        ANDA    #$0F       ; erase acia1 code
        STB     TEMP
        ADDA    TEMP       ; subs. new code
SB4     LDB     #$0F       ; store in RTC
        JSR     PUTRTC
        JMP     CONTRL
* Look-up table
TBAUD   FCC     "50   "
        FCB     $00
        FCC     "75   "
        FCB     $01
        FCC     "110  "
        FCB     $02
        FCC     "135  "
        FCB     $03
        FCC     "150  "
        FCB     $04
        FCC     "300  "
        FCB     $06
        FCC     "600  "
        FCB     $07
        FCC     "1200 "
        FCB     $08
        FCC     "1800 "
        FCB     $09
        FCC     "2400 "
        FCB     $0A
        FCC     "3600 "
        FCB     $0B
        FCC     "4800 "
        FCB     $0C
        FCC     "7200 "
        FCB     $0D
        FCC     "9600 "
        FCB     $0E
        FCC     "19200"
        FCB     $0F
;*
;* Seems to be not used...
;*
EBAUD   FCB     $FF,$29,$FF,$AB,$00,$52  ;EEFE: FF 29 FF AB 00 52 '.)...R'
        FCB     $FF,$A9,$02,$50,$FF,$AB  ;EF04: FF A9 02 50 FF AB '...P..'
        FCB     $00,$12,$FF,$AB,$02,$10  ;EF0A: 00 12 FF AB 02 10 '......'
        FCB     $FF,$AB,$00,$10,$FF,$AB  ;EF10: FF AB 00 10 FF AB '......'
        FCB     $02,$50,$FF,$AB,$02,$12  ;EF16: 02 50 FF AB 02 12 '.P....'
        FCB     $FF,$AB,$00,$50,$FF,$A9  ;EF1C: FF AB 00 50 FF A9 '...P..'
        FCB     $02,$52,$FF,$AB,$00,$50  ;EF22: 02 52 FF AB 00 50 '.R...P'
        FCB     $FF,$A9,$02,$12,$FF,$AB  ;EF28: FF A9 02 12 FF AB '......'
        FCB     $02,$50,$FF,$EB,$00,$10  ;EF2E: 02 50 FF EB 00 10 '.P....'
        FCB     $FF,$AB,$00,$10,$FF,$AB  ;EF34: FF AB 00 10 FF AB '......'
        FCB     $00,$50,$FF,$0B,$00,$10  ;EF3A: 00 50 FF 0B 00 10 '.P....'
        FCB     $00,$00,$FB,$FF,$00,$00  ;EF40: 00 00 FB FF 00 00 '......'
        FCB     $FB,$FF,$00,$00,$FB,$FF  ;EF46: FB FF 00 00 FB FF '......'
        FCB     $00,$00,$FB,$FF,$00,$00  ;EF4C: 00 00 FB FF 00 00 '......'
        FCB     $FB,$FF,$00,$00,$FF,$FF  ;EF52: FB FF 00 00 FF FF '......'
        FCB     $00,$00,$FB,$FF,$00,$00  ;EF58: 00 00 FB FF 00 00 '......'
        FCB     $FF,$FF,$00,$00,$FB,$FF  ;EF5E: FF FF 00 00 FB FF '......'
        FCB     $00,$00,$FF,$FF,$00,$00  ;EF64: 00 00 FF FF 00 00 '......'
        FCB     $FB,$FF,$00,$00,$FB,$FF  ;EF6A: FB FF 00 00 FB FF '......'
        FCB     $00,$00,$FF,$FF,$00,$00  ;EF70: 00 00 FF FF 00 00 '......'
        FCB     $FB,$FF,$00,$00,$FF,$FF  ;EF76: FB FF 00 00 FF FF '......'
        FCB     $08,$00,$FF,$FF,$A9,$FF  ;EF7C: 08 00 FF FF A9 FF '......'
        FCB     $10,$00,$A9,$FF,$50,$00  ;EF82: 10 00 A9 FF 50 00 '....P.'
        FCB     $AB,$FF,$10,$00,$A9,$FD  ;EF88: AB FF 10 00 A9 FD '......'
        FCB     $50,$00,$A9,$FF,$50,$00  ;EF8E: 50 00 A9 FF 50 00 'P...P.'
        FCB     $A9,$FF,$52,$00,$A9,$FF  ;EF94: A9 FF 52 00 A9 FF '..R...'
        FCB     $52,$00,$A9,$FD,$50,$02  ;EF9A: 52 00 A9 FD 50 02 'R...P.'
        FCB     $A9,$FF,$12,$00,$A9,$FD  ;EFA0: A9 FF 12 00 A9 FD '......'
        FCB     $10,$02,$A9,$FF,$50,$00  ;EFA6: 10 02 A9 FF 50 00 '....P.'
        FCB     $A9,$FD,$50,$02,$A1,$FF  ;EFAC: A9 FD 50 02 A1 FF '..P...'
        FCB     $52,$00,$A9,$FD,$12,$02  ;EFB2: 52 00 A9 FD 12 02 'R.....'
        FCB     $A9,$FF,$52,$00,$A9,$FD  ;EFB8: A9 FF 52 00 A9 FD '..R...'
        FCB     $52,$02,$00,$00,$FF,$FF  ;EFBE: 52 02 00 00 FF FF 'R.....'
        FCB     $00,$00,$FF,$FB,$00,$00  ;EFC4: 00 00 FF FB 00 00 '......'
        FCB     $FF,$FB,$00,$00,$FF,$FB  ;EFCA: FF FB 00 00 FF FB '......'
        FCB     $00,$00,$FF,$FB,$00,$00  ;EFD0: 00 00 FF FB 00 00 '......'
        FCB     $FF,$FB,$00,$00,$FF,$FB  ;EFD6: FF FB 00 00 FF FB '......'
        FCB     $00,$00,$FF,$FB,$00,$00  ;EFDC: 00 00 FF FB 00 00 '......'
        FCB     $FF,$FF,$00,$00,$FF,$FB  ;EFE2: FF FF 00 00 FF FB '......'
        FCB     $00,$00,$FF,$FB,$00,$00  ;EFE8: 00 00 FF FB 00 00 '......'
        FCB     $FF,$FB,$00,$00,$FF,$FB  ;EFEE: FF FB 00 00 FF FB '......'
        FCB     $00,$08,$FF,$FB,$00,$00  ;EFF4: 00 08 FF FB 00 00 '......'
        FCB     $FF,$FF,$00,$38,$FF,$C9  ;EFFA: FF FF 00 38 FF C9 '...8..'
;*
;* Wait 1ms routine
;* Input A = number of ms to wait
WAIT1MS LDB     #200
LOOPW   DECB
        BNE     LOOPW
        DECA
        BNE     WAIT1MS
        RTS
;*
;*
       ORG   PROM+$1000
;*
;*
;********************************************
;* Table of jump addresses for subroutines. *
;* To use these subroutines use the         *
;* indirect jump to subroutine thus:-       *
;*        DELAY EQU $F014                   *
;*        JSR [DELAY]                       *
;********************************************
       FDB   RESET        ; Cold start.
       FDB   CONTRL       ; Warm  start.
       FDB   INCH1        ; Input char without an echo.
       FDB   INCH         ; Input char.
       FDB   STATUS       ; Check for char.
       FDB   OUTCH        ; Output char.
       FDB   PDATA1       ; Print string terminated by hex(04).
       FDB   PCRLF        ; Print a cr followed by a lf.
       FDB   PSTRNG       ; PCRLF followed by PDATA1.
       FDB   DUMMY        ; No init code.
       FDB   DELAY        ; Delay for (XREG) m/S.
       FDB   BADDR        ; Get a four digit hex address into X.
       FDB   BYTE         ; Get a two hex digit number into A.
       FDB   INHEX        ; Get a one digit hex char into A.
       FDB   OUT2H        ; Output two hex chars pointed to by X.
       FDB   OUT2HS       ; OUT2H plus a space.
       FDB   OUT4HS       ; Output four hex chars etc.
       FDB   OUTHR        ; Output right hex digit in A.
       FDB   OUTHL        ; Output left hex digit in A.
       FDB   OUTS         ; Output a space.
       FDB   RANDOM       ; Returns a random number in the range 0-255.
       FDB   PRINTA       ; Output the contents of A.
       FDB   PRINTX       ; Output the contents of X.
       FDB   READ         ; Read sector routine.
       FDB   WRITE        ; Write sector routine.
       FDB   VERIFY       ; Verify sector routine.
       FDB   RST          ; Restore to track 00.
       FDB   DRV          ; Drive select.
       FDB   CHKRDY       ; Check for drive ready.
       FDB   QUICK        ; Quick check for drive ready.
       FDB   DINIT        ; Drive cold start.
       FDB   WARM         ; Drive warm start.
       FDB   SEEK         ; Seek to track.
;*************************************
;* Extra FDB'S for system dependant  *
;* subroutines fit here.             *
;*************************************
;* LIB FDB
       FDB   GETTIM
       FDB   PUTTIM
       FDB   GETRTC
       FDB   PUTRTC
       FDB   BEEP
       FDB   GCOM
       FDB   GPRM
       FDB   GPRMI
       FDB   MASK
       FDB   SETPEN
       FDB   SETPAT
       FDB   FIGSF
       FDB   FIGSG
       FDB   SETPAR
       FDB   SETCRG
       FDB   GETCRG
       FDB   SETCRT
       FDB   GETCRT
       FDB   OFF
       FDB   ON
       FDB   GRAPH
       FDB   TEXT
       FDB   MODE
       FDB   ZOOM
       FDB   FILL
       FDB   CLEARX
       FDB   CLEAR
       FDB   CLEART
       FDB   GDCINI
       FDB   VIDCH
       FDB   INKEY
       FDB   POINT
       FDB   LINE
       FDB   RECT
       FDB   CIRCLE
       FDB   ARC
       FDB   CLINK
       FDB   VSYNC
;*
;**************************************
;* Start of monitor  Entered on reset *
;**************************************
;*
RESET  STA   $FFDD         ; Set up SAM for 64k dynamic ram.
       STA   $FFDF         ; Set up SAM for map type 1.
;*
       LDA   WARMS
       CMPA  #$AA          ; Test for power down.
       BEQ   U1
;*
       CLRA
       LDX   #SCRAT
L1     STA   ,X+           ; Clear out scratch storage.
       CMPX   #(RAM+512)
       BNE   L1
       LDA   #$AA
       STA   WARMS
;*
       LDS   #SSTACK       ; Set initial stack pointer.
       STS   STACK         ; Same for user stack location.
;*
U1     LDY   #UNEXP
       LDX   #NMIV
U1L    STY   ,X++
       CMPX  #NMIV+10
       BNE   U1L
;*
;***********************************
;* System dependant init code goes *
;* here. It should set the initial *
;* input and output ports then     *
;* check for auto boot.            *
;***********************************
;* LIB MINIT1
;*
       LDA   #$4F
       STA   SYSREG        ; set DDRA
       LDA   #$3C          ; Hi-nib=in
       STA   SYSREG+1      ; Lo-nib=out
       LDA   #$34
       STA   PIA1+1        ; setup keyboard port
       LDA   #$06          ; set Drv 0,SD,and
       STA   SYSREG        ; Rom at $E000
       JMP   MINIT1        ; do rest of setup
;* (jump back here)
MINITR LDX   #HDR          ; Print header after reset.
       JSR   PDATA1
;* Action control (Warm start entry)
CONTRL LDA   SYSREG
       ORA   #4            ; Map in bottom 4k of eprom.
       STA   SYSREG
       LDX   #PROMPT
       JSR   PDATA1
       BSR   INCH          ; Get two byte command into Y.
       TFR   A,B
       BSR   INCH
       EXG   A,B
       TFR   D,Y
PARSE  LDX   #COMTAB       ; Point to start of command table.
NEXT   CMPY  ,X++          ; Look for match.
       BNE   NOPE          ; No match.
       JMP   [,X]          ; Found it, so jump to routine.
NOPE   LEAX  2,X           ; If no match then jump over address.
       LDA   ,X            ; Check for end of table.
       CMPA  #$FF
       BNE   NEXT          ; If not the end then try next entry.
WHAT   LDX   #NOTTHS       ; No match so print message.
       JSR   PDATA1
       BRA   CONTRL
*
UNEXP  LDX   #UNMESS       ; Unexpected interrupt ... Don't Panic!
       JSR   PSTRNG
       ORCC  #%01010000    ; Set interupt masks.
       JMP   RESET
;*
;* Interrupt vector routines.
;*
NMI    JMP   [NMIV]
IRQ    JMP   [IRQV]
FIRQ   JMP   [FIRQV]
SWI2   JMP   [SWI2V]
SWI3   JMP   [SWI3V]
;* No action goes here
DUMMY  RTS
;*
;*****************************************************
;* Console drivers                                   *
;* ---------------                                   *
;* The system dependant code for the console drivers *
;* fits here. The entries in the jump tables INITAB  *
;* INTAB,OUTTAB and STATAB should be changed to suit *
;* these routines. For a description of the drivers  *
;* for an 6850 acia see section 3 of the general     *
;* Flex adaptation guide (pp6-8).                    *
;*****************************************************
;*
;* LIB CONSOLE
;*
;* Check for character
STATUS  PSHS    X,D
        TST     OPORT      ; video monitor ?
        BNE     STAT2      ; no,skip flash routine
        LDX     FLASH      ; used here as counter
        BNE     STAT1      ; if <> 0,go decrement
        JSR     FLCUR      ; else toggle cursor
        LDX     #$0FA0     ; & reset counter
STAT1   LEAX    -$01,X
        STX     FLASH
STAT2   LDX     #TQINT
        LDB     IPORT
        ASLB
        JSR     [B,X]      ; check for interrupt
        PULS    PC,X,D     ; Z=1 if no interrupt
;* Input char without echo
INCH1   PSHS    X,B
INC1    BSR     STATUS     ; wait for interrupt
        BEQ     INC1
        TST     BLANKD     ; cursor blanked ?
        BEQ     INC2       ; no,skip
        JSR     FLCUR      ; yes,toggle again
INC2    LDX     #TABIN
        LDB     IPORT
        ASLB
        JSR     [B,X]      ; get char.into ACCA
        PULS    PC,X,B
;* Input character
INCH    BSR     INCH1
;* Output character
OUTCH   PSHS    X,B
        LDX     #TABOUT
        LDB     OPORT
        ASLB
        JSR     [B,X]
        PULS    PC,X,B
;* Console I/O function table
TABIN   FDB     INKEY
        FDB     GETA1
        FDB     GETA2
TABOUT  FDB     PUTVID
        FDB     PUTA1
        FDB     PUTA2
TQINT   FDB     QINT0
        FDB     QINT1
        FDB     QINT2
;* Get char from keyboard
INKEY   LDA     PIA1
        ANDA    #$7F
        RTS
;* Get char from acia port 1
GETA1   LDA     ACIA1
        ANDA    #$7F
        RTS
;* Get char from acia port 2
GETA2   LDA     ACIA2
        ANDA    #$7F
        RTS
;* Send char to video
PUTVID  JMP     VIDCH
;* Send char to acia port 1
PUTA1   LDB     ACIA1+1    ; check status
        BITB    #$01       ; TX ready ?
        BEQ     PUTA1      ; no,wait
        STA     ACIA1      ; yes,send char
        RTS
;* Send char to acia port 2
PUTA2   LDB     ACIA2+1
        BITB    #$01
        BEQ     PUTA2
        STA     ACIA2
        RTS
;* Check for interrupt, port 0 (keyboard)
QINT0   LDA     PIA1+1
        BITA    #$80       ; test flag
        RTS                ; if not,Z=1
;* Check for interrupt, port 1 (acia 1)
QINT1   LDA     ACIA1+1
        ANDA    #$02
        RTS
;* Check for interrupt, port 2 (acia 2)
QINT2   LDA     ACIA2+1
        ANDA    #$02
        RTS
;*
;* Disc drive vector table (1 read, 2 write, 3 verify,
;* 4 reset, 5 select, 6 check, 7 quick, 8 init, 9 warm, 10 seek)
;*
TABSRT  FDB     RDFLP      ; floppy drive 0
        FDB     WRFLP
        FDB     VRFLP
        FDB     RSFLP
        FDB     SELD0
        FDB     NVC0Z1
        FDB     NVC0Z1
        FDB     NVC0Z1
        FDB     NVC0Z1
        FDB     SKFLP

        FDB     RDFLP      ; floppy drive 1
        FDB     WRFLP
        FDB     VRFLP
        FDB     RSFLP
        FDB     SELD1
        FDB     NVC0Z1
        FDB     NVC0Z1
        FDB     NVC0Z1
        FDB     NVC0Z1
        FDB     SKFLP

        FDB     RDDT2      ; Disk typ 2
        FDB     WRDT2      ; 2 is master CF
        FDB     NVC0Z1     ; 3 is slave CF
        FDB     DRVDT2
        FDB     DRVDT2
        FDB     CHKDT2
        FDB     NVC0Z1
        FDB     INIDT2
        FDB     NVC0Z1
        FDB     NVC0Z1

        FDB     RDDT2      ; Disk typ 3
        FDB     WRDT2      ; 2 is master CF
        FDB     NVC0Z1     ; 3 is slave CF
        FDB     DRVDT2
        FDB     DRVDT2
        FDB     CHKDT2
        FDB     NVC0Z1
        FDB     INIDT2
        FDB     NVC0Z1
        FDB     NVC0Z1

;*
;* DISC I/O
;*
;* Query FDC busy status
QBUSY   LDB     COMREG     ; get status register
        BITB    #$01       ; inspect bit 0
        BNE     QBUSY      ; if busy, wait
        RTS

* Load FDC command
FCMD    BSR     QBUSY      ; wait until ready
        STA     COMREG     ; load command

;* Twiddle your thumbs for 100 micro-Secs
PAUSE   LBSR    PAUS1
PAUS1   LBSR    PAUS2
PAUS2   LBSR    PAUS3
PAUS3   RTS

;* Read a sector from floppy drive 0/1
RDFLP   LBSR    SKFLP      ; seek track/sector
        LDA     #$FF       ; set DP = $FF
        EXG     A,DP
        PSHS    A          ; save old DP
        LDA     #$84       ; read sector cmd
        BSR     FCMD       ; load command
        CLRB
RDFL1   LDA     <COMREG    ; COMREG (status)
        BITA    #$02       ; data reg full ?
        BNE     RDFL3      ; yes,branch
        BITA    #$01       ; cmd executed ?
        BNE     RDFL1      ; no,wait
        BRA     RDFL4
RDFL2   LDA     <COMREG    ; status
        BITA    #$06       ; ready ?
        BEQ     RDFL2      ; no,wait
RDFL3   LDA     <DATREG    ; data reg
        STA     ,X+
        DECB               ; last byte done ?
        BNE     RDFL2      ; no,continue
        BRA     RDFL1      ; yes,check status
RDFL4   TFR     A,B        ; ACCB = status
        PULS    A          ; restore DP
        EXG     A,DP
        BITB    #$10       ; record found ?
        BEQ     RDFL5      ; yes,exit
        LDA     SYSREG     ; no,toggle DEN
        EORA    #$02
        STA     SYSREG
        COM     DEN        ; toggle DEN
RDFL5   ANDB    #$1C       ; Z=1 if no error
        RTS

;* Write a sector to floppy drive 0/1
WRFLP   BSR     SKFLP      ; seek track/sector
        LDA     #$FF       ; change DP
        EXG     A,DP
        PSHS    A          ; save old DP
        LDA     #$A4       ; write sector cmd
        BSR     FCMD       ; load cmd
        CLRB
WRFL1   LDA     <COMREG    ; get status
        BITA    #$02       ; data reg.empty ?
        BNE     WRFL3      ; yes,branch
        BITA    #$01       ; busy ?
        BNE     WRFL1      ; yes,wait
        BRA     WRFL4      ; else,branch
WRFL2   LDA     <COMREG    ; check status
        BITA    #$06       ; ready ?
        BEQ     WRFL2      ; no,wait
WRFL3   LDA     ,X+        ; send byte
        STA     <DATREG
        DECB               ; all done ?
        BNE     WRFL2      ; no,continue
        BRA     WRFL1      ; yes,check status
WRFL4   TFR     A,B        ; put status in B
        PULS    A          ; restore DP
        EXG     A,DP
        ANDB    #$5C       ; test status
        RTS                ; Z=1 if no error

;* Verify a sector on floppy drive 0/1
VRFLP   LDA     #$84       ; (read sector cmd)
        LBSR    FCMD       ; load cmd
        LBSR    QBUSY      ; wait 'till finished
        ANDB    #$18
        RTS                ; Z=1 if no error

;* Restore to track 00 floppy drive 0/1
RSFLP   LDA     SYSREG
        ORA     #$02       ; set single density
        STA     SYSREG
        LDA     #$00       ; restore cmd
        ADDA    STEP       ; adjust for step rate
        LBSR    FCMD       ; load cmd
        LBSR    QBUSY      ; wait 'till finished
        ANDB    #$58
        RTS                ; z=1 if no error

;* Seek to track/sector floppy drive 0/1
SKFLP   STB     COMREG+2   ; rqud. sector
        STA     DATREG     ; reqd. track
        LDA     SYSREG
        TST     DEN        ; double density ?
        BEQ     SDEN       ; no,set single
        TST     DATREG     ; yes,set double except if
        BEQ     SDEN       ; track 0 => single density
        ANDA    #$FD
        CMPB    #$12       ; sector/track
        BRA     DDEN
SDEN    ORA     #$02       ; single density
        CMPB    #$0A       ; sector/track
DDEN    BLE     SKFL1
        ANDA    #$BF
        BRA     SKFL2
SKFL1   ORA     #$40
SKFL2   STA     SYSREG
        LDA     #$10       ; seek sector cmd
        ADDA    STEP       ; adjusted for step rate
        LBSR    FCMD       ; load cmd
        LBSR    QBUSY      ; wait 'till finished
        BITB    #$10       ; check status
        LBRA    PAUSE      ; exit via pause

;* Select floppy drive 0
SELD0   LDA     SYSREG
        ANDA    #$FE       ; set DRV 0
        LDB     SPEED
        BRA     SETD

;* Select floppy drive 1
SELD1   LDA     SYSREG
        ORA     #$01
        LDB     TSTEP
SETD    STA     SYSREG
        STB     STEP
        LDB     $03,X      ; get drive No
        CMPB    CURDRV     ; same as current ?
        BEQ     NVC0Z1     ; yes,branch
        STB     CURDRV     ; else,update current
        LDA     COMREG+1   ; set TRACK & DEN
        LDB     TRACK
        STA     TRACK
        STB     COMREG+1
        LDA     DEN
        LDB     DEN1
        STA     DEN1
        STB     DEN

;* Return with N,V,C clear, Z set
;* No error
NVC0Z1  CLRB
        TSTB
        ANDCC   #$FE
        RTS

;* Return with N,V,Z clear, C set
;* Error
NVZ0C1  LDB     #$40
        TSTB
        ORCC    #$01
        RTS

;* Set DP to $FF,speed to fast
FAST    EXG     A,DP       ; save present DP
        STA     REGDP
        LDA     #$FF       ; set DP = $FF
        EXG     A,DP
        STA     SET_R1     ; set Fast speed
        RTS

;* Restore DP,speed to slow
SLOW    LDA     REGDP      ; restore former DP
        EXG     A,DP
        TST     PSPEED     ; test current speed
        BNE     SLOW2
        STA     SET_R0     ; set slow speed
        STA     CLR_R1
        TST     >$0000
        BRN     SLOW
        STA     CLR_R0
SLOW2   RTS

;* =====================================================================
;* VARIOUS IDE / 8255 DISK ROUTINES
;* =====================================================================

;*
;* Select master / slave CF
DRVDT2      PSHS    A,X
            TST     MSTCFOK             ; check if master cf present ?
            BEQ     DRVERR              ; no exit with error
            LDA     3,X                 ; get Flex disk number
            LDX     #DDSTAB
            LDB     A,X                 ; get physical disk number
            LDA     #LBA3MST            ; master cf by default
            CMPB    #$02                ; master asked ?
            BEQ     ENDDRVDT2           ; yes exit ok
            TST     SLVCFOK             ; if not master then its slave - present ?
            BEQ     DRVERR              ; no exit with error
            LDA     #LBA3SLV

ENDDRVDT2   STA     LBA3                ; update LBA3 in ram
            BSR     NVC0Z1              ; no error
            PULS    A,X,PC

DRVERR      BSR     NVZ0C1              ; error
            PULS    A,X,PC
;*
;* Compute lba number from flex track/sector
;* Check if flex disk number stored at 3,x is master ($02) or slave ($03) cf
;* and set cf master or slave select bit in lba3 accordingly
;*
;* The cf disk is assumed to be 122 tracks (00$ to $79) of 256 sectors ($00 to $ff)
;* This is a 15990784 bytes disk in 31232 lba of 512 bytes
;*
;* A*256+B IS SAME AS PUT REG A INTO MSB OF A WORD THEN ADD REG B
;* SO REG A CAN BE DIRECTLY USED AS LBA1 AND REG B AS LBA0
;
;* Input : A = flex track
;*         B = flex sector
;*         X = flex fcb address
;*
;* Output : lba0 and lba1 updated in ram storage zone
SETLBA      STA     LBA1                ; store lba in table
            STB     LBA0                ; fall into transfer routine
;*
;* Transfer params table from memory to cf
;* and enable data
TFRPARM     PSHS    A,B,X,Y
            LDX     #LBA3+1             ; load table address + 1
            LDY     #IDE_LBA3           ; load 1st cf register to write

PARMLOP     BSR     CMDWAIT
            TFR     Y,D                 ; get Y lsb into B
            LDA     ,-X                 ; with pre decr load param from table
            BSR     WRT_IDE             ; write param in cf
            LEAY    -1,Y                ; change cf register
            CMPY    #IDE_SET_FEAT-1     ; check if 6 params loaded in cf
            BNE     PARMLOP             ; if 6 params not loaded do again

            BSR     CMDWAIT
            LDA     #IDE_CMD_SET_FEAT   ; now enable features
            LDB     #IDE_COMMAND
            BSR     WRT_IDE
            PULS    A,B,X,Y,PC
;*
;* Check cf error status
;CFERR       LDB     #IDE_STATUS         ; ask status register
;            BSR     READ_IDE
;            BITA    #ERRBIT             ; read error bit
;            RTS                         ; return with z clear if error
;*
;* Wait cf card command ready
CMDWAIT     BSR     DATWAIT             ; wait data ready
CWLOOP      LDB     #IDE_STATUS         ; ask status register
            BSR     READ_IDE
            BITA    #RDYBIT             ; read ready bit
            BEQ     CWLOOP              ; wait ready bit set
            RTS
;*
;* Wait cf card data ready with time out
DATWAIT     LDB     #IDE_STATUS         ; ask status register
            BSR     READ_IDE            ; A receive status register
            BITA    #BSYBIT             ; read busy bit
            BNE     DATWAIT             ; not clear ? yes do again
            RTS
;*
;* Do a one byte write cycle to ide
;* B = cf register where to write
;* A = byte to write
WRT_IDE     PSHS    A
            LDA     #WR_IDE_8255        ; set 8255 A/B/C for output
            STA     PORTCTRL
            PULS    A
            STA     PORTA               ; prepare lsb on output d0-d7
            STB     PORTC               ; set cf register address
            ORB     #IDE_WR             ; assert wr line
            STB     PORTC
            EORB    #IDE_WR             ; prepare for release wr line
            BRA     ENDIDERW
;*
;* Do a one byte read cycle from ide
;* B = cf register to read
;* A = byte read
READ_IDE    LDA     #RD_IDE_8255        ; set 8255 A/B for input C for output
            STA     PORTCTRL
            STB     PORTC               ; set cf register address
            ORB     #IDE_RD             ; assert rd line
            STB     PORTC
            LDA     PORTA               ; read lsb from d0-d7
            EORB    #IDE_RD             ; prepare for rd line release

ENDIDERW    STB     PORTC               ; release line
            CLR     PORTC               ; release ide device
            RTS
;*
;* Read sector from disk typ 8255 / ide
;* (A=track,B=sector,X=addr of a sector buffer)
RDDT2       PSHS    Y,X,B,A

            BSR     SETLBA              ; compute lba and set params in cf

            BSR     CMDWAIT
            LDA     #IDE_CMD_READ       ; send read command to the cf card
            LDB     #IDE_COMMAND        ; load command register address
            BSR     WRT_IDE             ; send command to the cf card

RDLOOP      BSR     CHKDRQ
            BEQ     RWEXIT              ; Z set ? yes end of loop
            BSR     DATWAIT
            LDB     #IDE_DATA
            BSR     READ_IDE            ; read the data byte from cf
            STA     ,X+                 ; write it to the buffer
            BRA     RDLOOP
;*
;* Write a sector to disk typ 8255 / ide
;* (A=track,B=sector,X=addr of a sector buffer)
WRDT2       PSHS    Y,X,B,A

            JSR     SETLBA              ; compute lba and set params in cf

            BSR     CMDWAIT
            LDA     #IDE_CMD_WRITE      ; send write command to the cf card
            LDB     #IDE_COMMAND        ; load command register address
            BSR     WRT_IDE             ; send command to the cf card

WRLOOP      BSR     CHKDRQ
            BEQ     RWEXIT              ; Z set ? yes end of loop
            BSR     DATWAIT
            LDA     ,X+                 ; read the byte from the buffer
            LDB     #IDE_DATA           ; write the data byte to cf
            BSR     WRT_IDE
            BRA     WRLOOP

RWEXIT      JSR     NVC0Z1              ;  set cc with no error & rts
            PULS    Y,X,B,A,PC
;*
;* Check cf DRQ bit
;* Return Z=0 if DRQ set
;*        Z=1 if DRQ not set
CHKDRQ      BSR     DATWAIT
            LDB     #IDE_STATUS
            BSR     READ_IDE
            BITA    #DRQBIT
            RTS
;*
;* Chkrdy disk typ 2 & 3
;* We just check if CF has been detected by init routine
CHKDT2      PSHS    X,A
            TST     MSTCFOK
            BEQ     NOTRDY              ; no master then also no slave exit not ready

            LDA     3,X                 ; load flex disk number
            LDX     #DDSTAB
            LDB     A,X                 ; load physical disk number
            CMPB    #$02                ; master cf asked ?
            BEQ     RDY                 ; yes all ok
            TST     SLVCFOK             ; if master cf not asked then it is slave
            BEQ     NOTRDY              ; slave present ? no exit not ready

RDY         JSR     NVC0Z1              ; no error - clear C - set Z
            PULS    X,A,PC

NOTRDY      JSR     NVZ0C1              ; error - clear Z - set C
            PULS    X,A,PC
;*
;* Detect and init disk typ 2 & 3 CF on 8255 ide port
INIDT2      LDB     #IDE_LBA3           ; set lba3 for master cf
            LDA     #LBA3MST
            STA     LBA3                ; keep ram table sync
            JSR     WRT_IDE

            LDD     #$0000
            STD     MSTCFOK             ; clear cf present flags

            LDX     #$FFFE              ; prepare for time out
ILOOP1      LDB     #IDE_STATUS         ; ask status register
            JSR     READ_IDE
            BITA    #BSYBIT             ; read busy bit
            BEQ     MSTOK               ; if clear master cf ok
            LEAX    -1,X                ; countdown
            BEQ     ENDINI              ; time out end cf int (no master no slave)
            BRA     ILOOP1              ; do again
MSTOK       BITA    #RDYBIT             ; must also check ready bit set
            BEQ     ENDINI              ; error set ? yes end cf init
            INC     MSTCFOK             ; set master flag

            LDB     #IDE_LBA3           ; set lba3 for slave cf
            LDA     #LBA3SLV
            JSR     WRT_IDE

            LDX     #$FFFE              ; prepare for time out
ILOOP2      LDB     #IDE_STATUS         ; ask status register
            JSR     READ_IDE
            BITA    #RDYBIT             ; read ready bit
            BNE     SLVOK               ; wait ready bit set
            LEAX    -1,X                ; countdown
            BEQ     ENDINI              ; time out no slave cf
            BRA     ILOOP2              ; do again
SLVOK       BITA    #ERRBIT             ; must also check error bit clear
            BNE     ENDINI              ; error ser ? end cf init
            INC     SLVCFOK             ; set slave flag

ENDINI      LDB     #IDE_LBA3           ; set lba3 for master cf
            LDA     #LBA3MST
            JSR     WRT_IDE
            RTS

;* =====================================================================
;* END OF VARIOUS IDE / 8255 DISK ROUTINES
;* =====================================================================

;*
;*****************************************
;* Disk drivers                          *
;* ------------                          *
;* The system dependant code for the     *
;* disc drivers fits here. Two tables    *
;* must be included. These are DDSTAB a  *
;* four byte table that defines which of *
;* the (up to four) following sets of    *
;* jump tables to use, and TABSRT the    *
;* jump tables themselves. For a full    *
;* description of the floppy drivers see *
;* section 4 (pp9-14) of the general     *
;* Flex adaptation guide.                *
;*****************************************
;*
;* LIB DISK
;* Read sector routine.
;* Entry: (X) = address where sector is to be placed.
;*        (A) = Track  number.
;*        (B) = Sector number.
;* Exit:  (B) = Error code  (z)=1 if no error.
READ    JMP     [REAVEC]
;*
;* Write track routine.
;* Entry: (X) = Address of area of memory from which the data will be taken.
;*        (A) = Track number.
;*        (B) = Sector number.
;* Exit:  (B) = Error condition, (Z)=1 no an error.
WRITE   JMP     [WRIVEC]
;*
;* Verify sector routine.
;* Entry: no parameters.
;* Exit:  (B) = Error condition (Z)=1 if no error.
VERIFY  JMP     [VERVEC]
;*
;* Restore drive to track 00.
;* Entry: (X) = FCB address (3,X contains drive number).
;* Exit:  (B) = Error condition, (Z)=1 if no error.
RST     BSR     DRV        ; Select drive first.
        BEQ     RST1
        RTS
RST1    JMP     [RSTVEC]
;*
;* Select current drive.
;* Entry: (X) = FCB address (3,X contains drive number).
;* Exit:  (B) = Error condition, (Z)=0 and (c)=1 if error.
;*        (B) = $0F if non existant drive.
DRV     PSHS    X,Y
        LDB     3,X        ; Get driver type.
        LDX     #DDSTAB
        LDA     B,X
        CMPA    #$FF       ; Is the drive nonexistant?
        BNE     DRIVE1
        PULS    X,Y
        LDB     #$0F
        TSTB
        ORCC    #$01
        RTS
DRIVE1  LDB     #20        ; Get correct table start address.
        MUL
        LDX     #TABSRT
        LEAX    D,X
        LDY     #REAVEC    ; Copy table into ram.
        LDB     #20
DRIVE2  LDA     ,X+
        STA     ,Y+
        DECB
        BNE     DRIVE2
        PULS    X,Y
        JMP     [DRVVEC]
;*
;* Check for drive ready.
;* Entry: (X) = FCB address (3,X contains drive number)>
;* Exit:  (B) = Error condition, (Z)=0 AND (C)=1 if drive is not ready.
CHKRDY  JMP     [CHKVEC]
;*
;* Quick drive ready check.
;* Entry: (X) = FCB address (3,X contains drive number).
;* Exit:  (B) = Error condition, (Z)=0 AND (c)=1 if drive not ready.
QUICK   JMP     [QUIVEC]
;*
;* Init (cold start).
;* Entry: no parameters.
;* Exit: no change.
DINIT   CLRA
DINIT1  STA     DRIVE      ; Init each valid drive in turn.
        LDX     #(DRIVE-3)
        BSR     DRV
        BCS     DINIT2
        JSR     [INIVEC]
DINIT2  LDA     DRIVE
        INCA
        CMPA    #3
        BNE     DINIT1
        RTS
;*
;* Warm start.
;* Entry: no parameters.
;* Exit: no change.
WARM    JMP     [WARVEC]
;*
;* Seek track.
;* Entry: (A) = Track number.
;*        (B) = Sector number.
;* Exit:  (B) = Error condition, (Z)=1 if no error.
SEEK    JMP     [SEEVEC]
;*
;*******************************
;* Common monitor subroutines. *
;*******************************
;*
;* Print a CR followed by a LF.
;* Entry: no parameters.
;* Exit: (A) destroyed.
CRLFS   FCB     $0A,$0D,4
PCRLF   PSHS    X
        LDX     #CRLFS     ; Get CR,LF string,
        BSR     PDATA1     ; and print it.
        PULS    X,PC
;*
;* Print character string .
;* Entry: (X) = Pointer to character string.
;* Exit:  (X) = Pointer to end of string token Hex(04).
;*        (A)   Destroyed.
P       JSR     OUTCH      ; Print char.
PDATA1  LDA     ,X+        ; Get character pointed to by X.
        CMPA    #$04       ; End of string token?
        BNE     P          ; If not then print char.
        RTS
;*
;* Print character string preceded by a CR,LF.
;* Entry: (X) = Pointer to character string.
;* Exit:  (X) = Pointer to end of string token Hex(04).
;*        (A) = Destroyed.
PSTRNG  BSR     PCRLF
        BSR     PDATA1
        RTS
;*
;* Print the A reg.
;* Entry :- (A) = Data to be printed.
PRINTA  PSHS    D,X
        STA     TEMP
        LDX     #TEMP
        BSR     OUT2HS
        PULS    D,X,PC
;*
;* Print the X reg.
;* Entry :- (X) = Data to be printed.
PRINTX  PSHS    D,X
        STX     XTEMP
        LDX     #XTEMP
        BSR     OUT4HS
        PULS    D,X,PC
;*
;* Delay routine.
;* Entry: (X) = Delay time in milli seconds.
;* Exit:  no change.
DELAY   PSHS    D,X,Y
DELAY1  LDY     #52 Delay
        TST     PSPEED
        BEQ     DELAY2
        LDY     #104       ; Twice delay for 2Mhz.
DELAY2  MUL
        LEAY    -1,Y
        BNE     DELAY2
        LEAX    -1,X
        BNE     DELAY1
        PULS    D,X,Y,PC
;*
;* Build a four hex digit address.
;* Entry: no parameters.
;* Exit:  (X) = Address.
;*        (A) = Destroyed.
;*        (B) = Destroyed.
BADDR   BSR     BYTE       ; Get 1st char.
        TFR     A,B
        BSR     BYTE       ; and next.
        EXG     A,B
        TFR     D,X                    Put in X.
        RTS
;*
;* Get a two digit hex byte.
;* Entry: no parameters.
;* Exit:  (A) = Byte.
BYTE    PSHS    B
        BSR     INHEX      ; Get hex digit.
        ASLA
        ASLA               ; Shift to msb.
        ASLA
        ASLA
        TFR     A,B        ; Save in B.
        BSR     INHEX      ; Get next digit.
        PSHS    B
        ADDA    ,S+        ; Add together bytes.
 PULS B,PC
;*
;* Print left hex digit.
;* Entry: (A) = Byte containing digit.
;* Exit:  (A) = Byte containing shifted digit.
OUTHL   LSRA
        LSRA
        LSRA
        LSRA
;*
;* Output right hex digit.
;* Entry: (A) = Byte containing digit.
;* Exit:  (A) = Ascii coded digit.
OUTHR   ANDA    #$0F       ; Get four bits only.
        ADDA    #$30       ; Add ascii zero.
        CMPA    #$39       ; Numeric overflow?
        LBLS    OUTCH
        ADDA    #$07       ; Must be hex.
        JMP    OUTCH
;*
;* Input a valid hex character (If not hex then backspace).
;* Entry: no parameters.
;* Exit:  (A) = Valid hex char.
INHEX   JSR     INCH
        SUBA    #$30       ; Remove ascii bias.
        BMI     NOTHEX
        CMPA    #$09       ; Number?
        BLE     INHEX1     ; Yes.
        CMPA    #$11       ; Keep testing.
        BMI     NOTHEX
        CMPA    #$16
        BGT     NOTHEX
        SUBA    #$07
INHEX1  RTS
NOTHEX  LDA     #$08       ; If not a number
        JSR     OUTCH      ; Print a backspace and try again.
        BRA     INHEX
;*
;* Hex print routines.
;* Entry: (X) = Pointer to a one or two byte hex number.
;* Exit:  (A) = Destroyed.
OUT2H   LDA     ,X         ;Output two hex chars.
OUT2HA  BSR     OUTHL
        LDA     ,X+
        BRA     OUTHR
OUT4HS  BSR     OUT2H      ; Output 4 hex chars + space.
OUT2HS  BSR     OUT2H      ; Output 2 hex chars + space.
;*
;* Output a space.
;* Entry: no parameters.
;* Exit   (A) = Destroyed.
OUTS    LDA     #' '       ; Output space.
        JMP    OUTCH
;*
;* Random number generator.
;* Entry: no parameters.
;* Exit:  (A) = Random number from 0 to 255.
RANDOM  PSHS B
        LDB #8
RPT     LDA RNDM+3
        ASLA
        ASLA
        ASLA
        EORA RNDM+3
        ASLA
        ASLA
        ROL RNDM
        ROL RNDM+1
        ROL RNDM+2
        ROL RNDM+3
        DECB
        BNE RPT
        LDA RNDM
        PULS B,PC
;*
;**************************************
;* Extra system subroutines fit here. *
;**************************************
;* LIB SUBS
;*
;* Get Time string from RTC
GETTIM  PSHS    X,D
        LDB     #$0A
GTIM2   BSR     GETRTC
        STA     ,X+
        DECB
        BNE     GTIM2
        PULS    PC,X,D
;* Get a byte from RTC
GETRTC  LDA     #$0A
        STA     RTC
        LDA     RTC+1
        BMI     GETRTC
        STB     RTC
        LDA     RTC+1
        RTS
;* Put time string to RTC
PUTTIM  PSHS    X,D
        LDB     #$0A
PTIM2   LDA     ,X+
        BSR     PUTRTC
        DECB
        BNE     PTIM2
        PULS    PC,X,D
;* Put a byte to RTC
PUTRTC  PSHS    A
PRTC2   LDA     #$0A
        STA     RTC
        LDA     RTC+1
        BMI     PRTC2
        STB     RTC
        PULS    A
        STA     RTC+1
        RTS
;* Sound a tone
BEEP    PSHS    X,A
        LDA     SYSREG
        ORA     #$08
        STA     SYSREG
        LDX     #$0064
        JSR     DELAY
        LDA     SYSREG
        ANDA    #$F7
        STA     SYSREG
        PULS    PC,X,A
;* Enter from monitor JF cmd. on entry X=CD00 or CD03
MAPOUT  LDA     SYSREG
        ANDA    #$FB
        STA     SYSREG
        JMP     ,X

;*************************************
;* Graphic functions for the NEC7220A
;*************************************
;*
;* Send a command to GDC
GCOM    TSTA               ; reset ?
        BEQ     GCOM2      ; yes, send at once
        PSHS    A          ; else, savec cmd
GCOM1   LDA     GDC        ; get status
        BITA    #$04       ; FIFO empty ?
        BEQ     GCOM1      ; no, wait
        PULS    A          ; recover command
GCOM2   STA     GDC+1      ; send it
        RTS
;*
;* Send a parameter to GDC
;*
GPRM    PSHS    A          ; store parameter
GPRM2   LDA     GDC        ; wait until FIFO empty
        BITA    #$04
        BEQ     GPRM2
        PULS    A
        STA     GDC        ; send parameter
        RTS
;*
;* Get a parameter from GDC
;*
GPRMI   LDA     GDC        ; get status
        BITA    #$01       ; data ready ?
        BEQ     GPRMI      ; no, wait
        LDA     GDC+1      ; read FIFO
        RTS
;*
;* Load the mask register
;*
MASK    PSHS    D
        LDA     #$4A       ; send 'mask' command
        BSR     GCOM
        TFR     X,D        ; get mask bytes
        EXG     A,B        ; reverse for FIFO
        BSR     GPRM       ; send 2nd
        EXG     A,B
        BSR     GPRM       ; send 1st
        PULS    PC,D
;*
;* Define drawing mode
;*
SETPEN  PSHS    X,D
        ANDA    #$03       ; setup 'w.data' cmd
        ORA     #$20
        BSR     GCOM       ; send it
        TFR     X,D        ; get profile word
        STB     MDFC4      ; save it
        STA     GPARAM
        LDX     #PART1+2
        BSR     SETPAT
        PULS    PC,X,D
;*
;* Define graphics pattern
;*
SETPAT  PSHS    X,D
        LDA     #$78       ; 'pram' cmd starting
        BSR     GCOM       ; with param.No.8
        LDB     #$08       ; load 8 parameters,
        LEAX    $08,X      ; taken from ram
SETP2   LDA     ,-X        ; pointed to by X,
        BSR     GPRM       ; in reverse order (FIFO)
        DECB
        BNE     SETP2
        PULS    PC,X,D
;*
;* Start figure drawing
;*
FIGSF   PSHS    X,D
        LDA     #$4C       ; 'figs' command
        BSR     GCOM       ; Load [B] drawing parameters
        LDX     #GFIGS     ; from scratch ram to GDCRAM
        LDA     ,X         ; NB. All 2-byte parameters are
        BSR     GPRM       ; loaded low byte first to
        DECB               ; maintain Fifo stack.
        BEQ     FIGS3
FIGS2   LDA     $02,X
        BSR     GPRM
        LDA     $01,X
        LEAX    $02,X
        BSR     GPRM
        DECB
        DECB
        BNE     FIGS2
; Load the GDCRAM into the drawing processor & draw.
FIGS3   LDA     #$6C       ; 'figd' command
        LBSR    GCOM
        PULS    PC,X,D
;*
;* Start graphics drawing
;*
FIGSG   PSHS    X,D        ; Load [B] drawing parameters
        LDA     #$4C       ; from scratch ram to GDCRAM
        LBSR    GCOM       ; NB. All 2-byte parameters are
        LDX     #GFIGS     ; loaded low byte first to
        LDA     ,X         ; maintain Fifo stack.
        LBSR    GPRM
        DECB
        BEQ     FIGG3
FIGG2   LDA     $02,X
        LBSR    GPRM
        LDA     $01,X
        LEAX    $02,X
        LBSR    GPRM
        DECB
        DECB
        BNE     FIGG2
FIGG3   LDA     #$68       ; 'gchrd' command
        LBSR    GCOM       ; Fill area to pattern stored in GDCRAM
        PULS    PC,X,D     ; (ie. Draw graphics character)
;*
;* Define display partitions. On entry,
;*     X=Pt.1 start
;*     D=Pt.2 start
;*     Y=Pt.1 length
;*     U=Pt.2 length
;*
SETPAR  PSHS    U,Y,X,D
        EXG     A,B
        STD     PART2
        TFR     X,D
        EXG     A,B
        STD     PART1
        TFR     Y,D
        ANDB    #$0F       ; mask off Hi nibble
        LDA     #$10       ; shift into Hi nibble to
        MUL                ; form Lo field of length
        STB     PART1+2
        TFR     Y,D        ; recover length
        LSRA               ; shove the last 4 bits overboard
        RORB               ; (we have already dealt with these)
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB               ; use the remaining bits as
        STB     PART1+3    ; Hi field of length
        TFR     U,D        ; get Pt.2 length & treat as above
        ANDB    #$0F
        LDA     #$10
        MUL
        STB     PART2+2
        TFR     U,D
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB
        LSRA
        RORB
        STB     PART2+3
        BSR     VSYNC      ; wait for sync
        LDA     #$70       ; 'pram' cmd.
        LBSR    GCOM
        LDX     #PART1     ; transfer 8 params
        LDB     #$08       ; from scratch to GDC
SPRM2   LDA     ,X+
        LBSR    GPRM
        DECB
        BNE     SPRM2
        PULS    PC,U,Y,X,D
;*
;* Sync to vertical blanking
;*
VSYNC   PSHS    A
VSYN2   LDA     GDC
        BITA    #$20
        BNE     VSYN2
VSYN3   LDA     GDC
        BITA    #$20
        BEQ     VSYN3
        PULS    PC,A
;*
;* Set graphics cursor
;*
SETCRG  PSHS    Y,X,D
        STX     XCOORD
        STY     YCOORD
        LDA     #$49       ; 'curs' cmd
        LBSR    GCOM
        TFR     Y,D
        ASLB               ; mult Y-coord by 48
        ROLA               ; to yield number of
        ASLB               ; words,(16 bit), in
        ROLA               ; previous lines
        ASLB
        ROLA
        ASLB
        ROLA
        TFR     D,Y
        ASLB
        ROLA
        LEAY    D,Y
        TFR     X,D
        LSRA               ; divide X-coord by 16
        RORB               ; to yield number of
        LSRA               ; complete words on
        RORB               ; this line.Add addr
        LSRA               ; of 1st word in
        RORB               ; Partition,to get
        LSRA               ; addr of current word
        RORB
        LEAY    D,Y
        LEAY    $5E00,Y
        ASLB               ; recover X-coord but
        ROLA               ; with l.s. nibble
        ASLB               ; set to 0. Subtract
        ROLA               ; to yield number of
        ASLB               ; bits in current word
        ROLA
        ASLB
        ROLA
        COMA
        COMB
        ADDD    #$0001
        LEAX    D,X
        TFR     Y,D        ; format to suit GDC
        EXG     A,B        ; parameter ram and
        LBSR    GPRM       ; load parameters
        EXG     A,B
        LBSR    GPRM
        TFR     X,D
        LDA     #$10
        MUL
        ANDB    #$F0
        TFR     B,A
        LBSR    GPRM
        PULS    PC,Y,X,D
;*
;* Get graphics cursor
;*
GETCRG  PSHS    D
        LDA     #$E0       ; 'curd' cmd
        LBSR    GCOM
        LBSR    GPRMI      ; get cursor word adr
        TFR     A,B
        LBSR    GPRMI
        LDY     #$0000     ; zero line count
        SUBD    #$5E00     ; convert to word #
GCRG1   SUBD    #$0030     ; count lines
        BMI     GCRG2
        LEAY    $01,Y
        BRA     GCRG1
GCRG2   ADDD    #$0030
        ASLB               ; convert 'words on
        ROLA               ; current line' to
        ASLB               ; 'bits on current line'
        ROLA
        ASLB
        ROLA
        ASLB
        ROLA
        TFR     D,X        ; save in X
        LBSR    GPRMI      ; Hi adr.bits.Discard
        LBSR    GPRMI      ; get dot addr
        TFR     A,B        ; (in 1 of 16 form)
        LBSR    GPRMI
        ANDCC   #$FE       ; clear carry
GCRG3   LSRA               ; count buckshee bits and
        RORB               ; increment X accordingly
        BCS     GCRG4
        LEAX    $01,X
        BRA     GCRG3
GCRG4   STX     XCOORD     ; store coordinates
        STY     YCOORD
        PULS    PC,D
;*
;* Turn display off
;*
OFF     PSHS    A
        JSR     VSYNC
        LDA     #$0C
        LBSR    GCOM
        PULS    PC,A
;*
;* Turn display on
;*
ON      PSHS    A
        JSR     VSYNC
        LDA     #$0D
        LBSR    GCOM
        PULS    PC,A
;*
;* Set display to graphics
;*
GRAPH   PSHS    U,Y,X,D
        CLRB
        BSR     MODE
        ORA     #$09
        DECB
        BSR     MODE       ; set interlaced
        LDX     #$5E00     ; set Partitions
        LDY     #$0240
        LDD     #$0000
        TFR     D,U
        JSR     SETPAR
        PULS    PC,U,Y,X,D
;*
;* Set GDC mode
;*
MODE    TSTB
        BEQ     MODE1
        STA     GMODE
        PSHS    A
        LDA     #$0F       ; 'sync' mode
        LBSR    GCOM
        PULS    A
        LBSR    GPRM
        RTS
MODE1   LDA     GMODE
        RTS
;*
;* Set zoom factor
;*
ZOOM    TSTB
        BEQ     ZOOM1
        STA     GZOOM
        PSHS    A
        LDA     #$46       ; 'zoom'command
        LBSR    GCOM
        PULS    A
        LBSR    GPRM
        RTS
ZOOM1   LDA     GZOOM
        RTS
;*
;* Area fill (On entry, A holds init dir)
;*
FILL    PSHS    Y,X,D
        ANDA    #$87       ; set 'figs' P1 for graphics char
        ORA     #$10
        STA     GFIGS
        LEAY    -$01,Y     ; DN=(No.of pixels at
        TFR     Y,D        ; Rt.Angles to initial
        STD     DN         ; direction - 1)
        TFR     X,D        ; D0 & D2=(No.of pixels
        STD     D0         ; in initial direction)
        STD     D2
        LDB     #$07       ; load 7 bytes from
        LBSR    FIGSG      ; scratch,then draw
        PULS    PC,Y,X,D
;*
;* Clear graphics display
;*
CLEAR   PSHS    Y,X,D
        LDX     #$0000     ; set cursor 0,0
        TFR     X,Y
        JSR     SETCRG
        LDX     #$4000     ; (DN max=$3FFF)
        LDA     #$02       ; pen type 'reset'
        BSR     CLEARX     ; clear this block
        LDX     #$2C30     ; now do rest
        LDA     #$02
        BSR     CLEARX
        LDX     #$0000     ; and reset cursor to 0,0
        TFR     X,Y
        JSR     SETCRG
        PULS    PC,Y,X,D
;*
;* Clear (Xreg) words of display memory
;*
CLEARX  PSHS    X,A
        PSHS    A
        LEAX    -$01,X     ; (DN=W-1)
        PSHS    X
        LDX     #$FFFF     ; enable all bits
        JSR     MASK
        LDA     #$4C       ; 'figs' command
        LBSR    GCOM
        LDA     #$02       ; P1.wdata mode,dir 2
        LBSR    GPRM
        PULS    D
        EXG     A,B
        LBSR    GPRM       ; P2.DN-low
        EXG     A,B
        LBSR    GPRM       ; P3.DN-hi
        PULS    A          ; (pen type 02)
        ORA     #$20       ; 'wdat' command
        LBSR    GCOM
        LDA     #$FF
        LBSR    GPRM       ; data word all 1's
        LBSR    GPRM
        PULS    PC,X,A
;*
;* Initialise GDC
;*
GDCINI  PSHS    X,D
        CLRA
        LBSR    GCOM       ; 'reset' command
        LDB     #$21
GDCI2   JSR     GETRTC     ; Load parameter ram from RTC
        JSR     GPRM
        INCB
        CMPB    #$29
        BNE     GDCI2
        LDA     #$6F       ; 'vsync' command
        LBSR    GCOM
        LDA     #$47       ; 'pitch' command
        LBSR    GCOM
        LDA     #$30
        LBSR    GPRM
        LDA     #$4B       ; 'cchar' command
        LBSR    GCOM
        CLRA
        LBSR    GPRM
        LDA     #$C0
        LBSR    GPRM
        CLRA
        LBSR    GPRM
        LDB     #$01
        CLRA
        LBSR    ZOOM
        LDA     #$1F
        STA     GMODE
        LDA     #$6B       ; 'start' command
        LBSR    GCOM
        JSR     CLEART
        JSR     TEXT
        PULS    PC,X,D
;*
;* Plot a point
;*
POINT   PSHS    B
        CLR     GFIGS
        LDB     #$01
        LBSR    FIGSF
        PULS    PC,B
;*
;* Plot a line
;*
LINE    PSHS    U,X,D
        LDU     #P1TBL     ; base adr.of P1 table
        TFR     X,D        ; calc X' (delta X)
        SUBD    XCOORD
        CMPD    #$0000
        BGT     LINE1      ; branch if X'>0
        LEAU    $04,U      ; else,reverse dir &
        COMA               ; change sign of X'
        COMB
        ADDD    #$0001
LINE1   TFR     D,X        ; X=|X'|
        TFR     Y,D        ; repeat for Y-axis
        SUBD    YCOORD
        CMPD    #$0000
        BGT     LINE2
        LEAU    $02,U
        COMA
        COMB
        ADDD    #$0001
LINE2   STD     YTEMP
        STX     XTEMP
        CMPX    YTEMP
        BGT     LINE3
        LEAU    $01,U
        STX     YTEMP
        STD     XTEMP
;* At this point,XTEMP=delta large,YTEMP=delta small
LINE3   LDA     ,U         ; get P1
        STA     GFIGS      ; put it in scratch
        LDD     YTEMP      ; calc ---
        SUBD    XTEMP      ; 2(delta min - delta max)
        ASLB
        ROLA
        ANDA    #$3F       ; NOT > 63
        STD     D2         ; store it
        LDD     YTEMP
        ASLB
        ROLA
        STD     D4         ; = 2(delta min)
        SUBD    XTEMP      ; 2xdelta min-delta max
        ANDA    #$3F       ; NOT > 63
        STD     D0         ; store it
        LDD     XTEMP
        STD     DN         ; = delta max
        LDB     #$09       ; load 9 params & draw line
        LBSR    FIGSF
        PULS    U,X,D
        STX     XCOORD     ; recover new coordinates
        STY     YCOORD     ; and update cursor
        LBSR    SETCRG
        RTS
;*
;* 'figs' P1 table. (Select initial direction)
;*                1   0   2   3   6   7   5   4
P1TBL   FCB     $09,$08,$0A,$0B,$0E,$0F,$0D,$0C
;*
;* Plot a rectangle
;*
RECT    PSHS    Y,X,D
        ANDA    #$07       ; init.dir. (7 max)
        ORA     #$40       ; set 'rectangle' bit
        STA     GFIGS      ; store as P1 for 'figs'
        LDD     #$0003     ; sides - 1
        STD     DN
        LEAX    -$01,X
        LEAY    -$01,Y
        TFR     X,D        ; pix.in init dir. -1
        STD     D0
        STD     DM
        TFR     Y,D        ; pix at Rt.A -1
        STD     D2
        LDD     #$FFFF     ; (-1)
        STD     D4
        LDB     #$0B       ; load 11 params & draw rectangle
        LBSR    FIGSF
        PULS    PC,Y,X,D
;*
;* Plot a circle
;*
CIRCLE  PSHS    Y,X,D
        LDX     XCOORD     ; get coordinates of
        LDY     YCOORD     ; centre point
        STX     XTEMP      ; save them
        STY     YTEMP
        LEAX    A,X        ; add rad to X-coord
        LDB     #$04       ; dir = 4
        BSR     ARC        ; 0-45 degrees
        LDB     #$07       ; dir = 7
        BSR     ARC        ; 0-315 degrees
        LDX     XTEMP      ; set X-coord to centre
        LEAY    A,Y        ; add rad to Y-coord
        LDB     #$02       ; dir = 2
        BSR     ARC        ; 270-315 degrees
        LDB     #$05       ; dir = 5
        BSR     ARC        ; 270-225 degrees
        LDY     YTEMP      ; set Y-coord to centre
        NEGA
        LEAX    A,X        ; sub rad from X-coord
        NEGA
        CLRB
        BSR     ARC        ; 180-225 degrees
        LDB     #$03       ; dir = 3
        BSR     ARC        ; 180-135 degrees
        LDX     XTEMP      ; set X-coord to centre
        NEGA
        LEAY    A,Y        ; sub rad from Y-coord
        NEGA
        LDB     #$01       ; dir = 1
        BSR     ARC        ; 90-45 degrees
        LDB     #$06       ; dir = 6
        BSR     ARC        ; 90-135 degrees
        LDX     XTEMP      ; recover coordinates
        LDY     YTEMP      ; of centre point &
        LBSR    SETCRG     ; set cursor
        PULS    PC,Y,X,D
;*
;* Plot an arc (on entry, A = radius, B = initial direction)
;*
ARC     PSHS    D
        LBSR    SETCRG
        PSHS    D
        LDB     #$B5       ; (0.707 X 256)
        MUL
        STA     CONST      ; 256(R X 0.707).[Hi byte]
        PULS    D
        ANDB    #$07       ; dir not > 7
        ORB     #$20       ; set 'arc' mode
        STB     GFIGS
        DECA               ; radius - 1
        CLRB
        STA     D1         ; Lo-byte of D = rad-1
        STB     D0         ; Hi-byte of D = 0
        EXG     A,B
        ASLB
        ROLA
        STD     D2         ; = 2(radius - 1)
        LDB     CONST
        CLRA
        STD     DN         ; = R x 0.707
        LDD     #$FFFF
        STD     D4         ; = -1
        LDD     #$0000
        STD     DM
        LDB     #$0B       ; load 11 params & draw arc
        LBSR    FIGSF
        PULS    PC,D
;*
;* Set text cursor
;*
SETCRT  PSHS    X,D
        STX     CURSOR
        LDA     #$49       ; 'curs' command
        LBSR    GCOM
        TFR     X,D
        EXG     A,B
        LBSR    GPRM       ; P1/2=cursor word
        EXG     A,B        ; adr. Lo/Hi
        LBSR    GPRM
        LDA     #$08
        LBSR    GPRM
        PULS    PC,X,D
;*
;* Get text cursor
;*
GETCRT  PSHS    D
        LDA     #$E0       ; 'curd' command
        LBSR    GCOM
        LBSR    GPRMI      ; P1=word adr. Lo
        TFR     A,B
        LBSR    GPRMI      ; P2=word adr. Hi
        TFR     D,X
        STX     CURSOR     ; curs.word adr
        LBSR    GPRMI      ; P3=adr.Hi(not used)
        LBSR    GPRMI      ; P4/5=dot adr.Lo/Hi not
        LBSR    GPRMI      ; used in text mode,discard
        PULS    PC,D
;*
;* Set display to text
;*
TEXT    PSHS    U,Y,X,D
        CLRB
        LBSR    MODE       ; get mode
        ANDA    #$F6
        INCB
        LBSR    MODE       ; set noninterlaced
        LDX     TS1        ; get text
        LDD     TS2        ; Partition params
        LDY     TL1
        LDU     TL2
        JSR     SETPAR     ; load them
        PULS    PC,U,Y,X,D
;*
;* Clear text display (Partition data in scratch ram)
;*
CLEART  PSHS    X,D
        LDX     #TXTRAM    ; point to text ram
        BSR     SETCRT
        LDX     #$3600     ; 288 lines X 48 words
        LDA     #$02
        JSR     CLEARX     ; clear text
        BSR     INITXT     ; setup initial text
        CLR     COL        ; home cursor
        CLR     ROW
        CLR     ESCFLG
        LDA     #$01
        STA     CTYPE      ; solid cursor
        LDA     #$04
        STA     ATTRI
        BSR     TEXT       ; set text mode
        TST     BLANKD     ; cursor blanked ?
        BEQ     CLTXT      ; no,skip
        BSR     FLCUR      ; yes,toggle it
CLTXT   PULS    PC,X,D
CLINK   RTS                ; link text parameters
;*
;* Init text mode Partitions
;*
INITXT  LDX     #TXTRAM    ; initialise text mode
        TFR     X,D        ; Partition parameters
        LDY     #$0120
        LDU     #$0000
UPDPA   STX     TS1        ; update Partitions
        STD     TS2
        STY     TL1
        STU     TL2
        PSHS    A
        LDA     GMODE
        BITA    #$09       ; if text mode set
        BEQ     ITRET      ; load these params
        PULS    PC,A       ; else,return
ITRET   PULS    A
        JSR     SETPAR
        RTS
;*
;* Send a char to video
;*
VIDCH   PSHS    U,Y,X,D
        JSR     FAST
        TST     BLANKD     ; cursor blanked ?
        BEQ     VIDC1      ; if so,
        BSR     FLCUR      ; toggle it
VIDC1   TST     ESCFLG     ; set ?
        BEQ     VIDC2      ; no, continue
        JSR     CMOVE      ; else, deal with it
        BRA     VIDC3      ; and exit
VIDC2   CMPA    #$20       ; is it a control chr ?
        BCS     VIDCC      ; yes,go do it
        ANDA    #$7F       ; else,make sure its
        BSR     GPCHR      ; ascii & do it
        LDA     COL
        INCA
        CMPA    #$6C       ; end of line ?
        BEQ     VIDC3      ; yes,exit
        STA     COL        ; no,update col
VIDC3   JSR     SLOW
        PULS    PC,U,Y,X,D
;*
;* Flashing cursor
;*
FLCUR   PSHS    U,Y,X,D
        TST     CTYPE
        BMI     FLC2       ; cursor off,skip
        LDA     #$01       ; (complement mode)
        JSR     SETPEN
        LDA     CTYPE
        ORA     #$80       ; adjust for use as index
        DECA               ; to char table
        BSR     GPCH2      ; toggle cursor
        COM     BLANKD     ; toggle 'blanked' flag
FLC2    PULS    PC,U,Y,X,D
;*
;* Deal with printable character. (7 bit ascii in ACCA)
;*
GPCHR   PSHS    D
        CLRA               ; (replace mode)
        JSR     SETPEN
        PULS    D          ; peek & put back
GPCH2   PSHS    D
        BSR     CCT2G      ; adjust coordinates
        SUBA    #$20       ; use as index
        LDX     #CSETB     ; (char set,Normal)
        LDB     #$05       ; find character
        MUL
        LEAX    D,X
        JSR     SETPAT     ; set it up
        LDA     ATTRI
        LDY     #$0005     ; pixels in init dir
        LDX     #$0008     ; pixels at Rt.Angles
        JSR     FILL       ; and print it
        PULS    PC,D
;*
;* Convert coordinates,text to graphic
;*
CCT2G   PSHS    Y,X,D
        LDA     ROW        ; row No
        LDB     #$0C       ; lines per row
        MUL
        ADDD    TL2        ; + overwritten lines
        TFR     D,Y
        CMPY    #$0120     ; 2nd time round ?
        BLT     CCT2       ; no,skip
        LEAY    $FEE0,Y    ; yes,-len of T ram
CCT2    LEAY    $0248,Y    ; +len of G ram
        LDA     COL
        LDB     #$07       ; (width of box col)
        MUL
        TFR     D,X
        LEAX    $0C,X      ; +initial offset
        JSR     SETCRG
        PULS    PC,Y,X,D
;*
;* Deal with control character (entered from send chr to video)
;*
VIDCC   PSHS    X,D
        LDX     #TCCACT
        ASLA               ; char X 2 is used
        JSR     [A,X]      ; as index to table
        PULS    X,D
        BRA     VIDC3      ; return to sender
;*
;* Table of control code action routines
;*
TCCACT  FDB     IGNORE
        FDB     IGNORE
        FDB     IGNORE
        FDB     IGNORE
        FDB     IGNORE
        FDB     IGNORE
        FDB     IGNORE
        FDB     BEEP       ; bell
        FDB     CLEFT      ; cursor left
        FDB     CRIGHT     ; cursor right
        FDB     CDOWN      ; cursor down
        FDB     CUP        ; cursor up
        FDB     CLEART     ; clear screen
        FDB     CCR        ; CR
        FDB     CMOVE      ; cursor move
        FDB     CHOME      ; cursor home
        FDB     ON         ; screen on
        FDB     OFF        ; screen off
        FDB     CURON      ; cursor on
        FDB     CUROFF     ; cursor off
        FDB     CURSOL     ; cursor solid
        FDB     CURBOX     ; cursor box
        FDB     ATTON      ; attributes on
        FDB     ATTOFF     ; attributes off
        FDB     IGNORE     ; (clear to end of line)
        FDB     IGNORE     ; (clear to end of screen)
        FDB     CLINE      ; clear line
        FDB     IGNORE
        FDB     IGNORE
        FDB     IGNORE
        FDB     IGNORE
        FDB     IGNORE
;*
;* Action routines for control char
;*
;* Cursor left
CLEFT   LDA     COL
        DECA
        BMI     CLEF1      ; if fully left, ignore
        STA     COL
CLEF1   RTS
;* Cursor right
CRIGHT  LDA     COL
        INCA
        CMPA    #$6C       ; if fully right, ignore
        BEQ     CRIG1
        STA     COL
CRIG1   RTS
;* Cursor down
CDOWN   LDA     ROW
        INCA
        CMPA    #$18       ; 24? (N.B. rows=0-23)
        BNE     CRET
        BSR     SCRUP      ; scroll up
        JMP     CLINE      ; clear line.(Btm)
CRET    STA     ROW
;* Control char ignored
IGNORE  RTS                ; no action
;* Cursor up
CUP     LDA     ROW
        DECA
        BPL     CRET
        BSR     SCRDWN     ; scroll down
        JMP     CLINE      ; clear line.(Top)
;* Cursor home (top-left)
CHOME   CLR     ROW
;* CR (cursor begin of line)
CCR     CLR     COL
        RTS
;* Cursor off
CUROFF  LDA     CTYPE
        ORA     #$80
        STA     CTYPE
        RTS
;* Cursor on
CURON   LDA     CTYPE
        ANDA    #$7F
        STA     CTYPE
        RTS
;* Solid cursor
CURSOL  LDA     #$01
        STA     CTYPE
        RTS
;* Box cursor
CURBOX  LDA     #$02
        STA     CTYPE
        RTS
;* Attributes on
ATTON   LDA     ATTRI
        ORA     #$81
        STA     ATTRI
        RTS
;* Attributes off
ATTOFF  LDA     ATTRI
        ANDA    #$7E
        STA     ATTRI
        RTS
;*
;* Move cursor (3 pass escape sequence)
;*
CMOVE   LDB     ESCFLG
        TSTB               ; is it set ?
        BNE     CMOV1      ; yes,branch
        LDB     #$02       ; no,set it
        STB     ESCFLG
        RTS
CMOV1   CMPB    #$02       ; is it 2 ?
        BNE     CMOV2      ; no,branch
        SUBA    #$20       ; yes,update row
        STA     ROW
        DEC     ESCFLG
        RTS
CMOV2   SUBA    #$20       ; update col and
        STA     COL
        DEC     ESCFLG     ; clear flag
        RTS
;*
;* Scroll up
SCRUP   LDY     TL1        ; reduce TL1 by one row
        LEAY    -$0C,Y
        BNE     SCRUP1
        LBRA    INITXT     ; init Part.params
SCRUP1  LDD     TS2
        LDX     TS1
        LEAX    $0240,X    ; 12 lines X 48 words
        LDU     TL2        ; (ie. advance 1 row)
        LEAU    $0C,U      ; increment TL2 by one row
        LBRA    UPDPA      ; update Part.params
;*
;* Scroll down
SCRDWN  LDU     TL2        ; if zero,apply
        BEQ     SCRD1      ; cooking factor
        LDX     TS1
        LEAX    -$0240,X   ; retreat one row
        LDD     TS2
        LDY     TL1        ; increase TL1 by one row
        LEAY    $0C,Y
        LDU     TL2        ; reduce TL2 by one row
        LEAU    -$0C,U
        LBRA    UPDPA      ; update Part.params
SCRD1   LDX     #$FDC0     ; TS1
        LDD     #TXTRAM    ; TS2
        LDY     #$000C     ; TL1 (1 row)
        LDU     #$0114     ; TL2 (23 rows)
        LBRA    UPDPA
;*
;* Clear line
CLINE   PSHS    Y,X,D
        LDD     ROW
        LDB     #$0C       ; convert to lines
        MUL
        ADDD    TL2        ; +overwritten lines
        TFR     D,Y
        CMPY    #$0120     ; 2nd time round ?
        BLT     CLIN1      ; skip if not
        LEAY    $FEE0,Y    ; -len of text ram
CLIN1   LEAY    $0240,Y    ; +len of graphics ram
        LDX     #$0000
        JSR     SETCRG     ; (to start of row)
        LDX     #$0240     ; clear one row
        LDA     #$02
        JSR     CLEARX
        PULS    PC,Y,X,D
;*
;* Normal charset bitmap (graphic char as ASCII
;* 7 bits stored as 5 columns x 8 bits images
;*
CSETB   FCB     $00,$00,$00,$00,$00 ; space
        FCB     $00,$00,$FA,$00,$00 ; !
        FCB     $00,$E0,$00,$E0,$00 ; "
        FCB     $50,$F8,$50,$F8,$50 ; #
        FCB     $48,$54,$FE,$54,$24 ; $
        FCB     $46,$26,$10,$68,$64 ; %
        FCB     $0A,$44,$AA,$92,$6C ; &
        FCB     $00,$E0,$D0,$00,$00 ; '
        FCB     $00,$82,$44,$38,$00 ; (
        FCB     $00,$38,$44,$82,$00 ; )
        FCB     $54,$38,$FE,$38,$54 ; *
        FCB     $10,$10,$7C,$10,$10 ; +
        FCB     $00,$0E,$0D,$00,$00 ; ,
        FCB     $10,$10,$10,$10,$10 ; -
        FCB     $00,$00,$06,$06,$00 ; .
        FCB     $40,$20,$10,$08,$04 ; /
        FCB     $00,$7C,$82,$82,$7C ; 0
        FCB     $00,$00,$FE,$40,$00 ; 1
        FCB     $62,$92,$92,$8A,$46 ; 2
        FCB     $CC,$B2,$92,$82,$82 ; 3
        FCB     $10,$FE,$10,$10,$F0 ; 4
        FCB     $9C,$A2,$A2,$A2,$E2 ; 5
        FCB     $0C,$92,$92,$52,$3C ; 6
        FCB     $C0,$A0,$90,$88,$86 ; 7
        FCB     $6C,$92,$92,$92,$6C ; 8
        FCB     $78,$94,$92,$92,$60 ; 9
        FCB     $00,$00,$6C,$6C,$00 ; :
        FCB     $00,$00,$6E,$6D,$00 ; ;
        FCB     $00,$82,$44,$28,$10 ; <
        FCB     $28,$28,$28,$28,$28 ; =
        FCB     $10,$28,$44,$82,$00 ; >
        FCB     $60,$90,$8A,$80,$40 ; ?
        FCB     $7A,$AA,$BA,$82,$7C ; @
        FCB     $7E,$90,$90,$90,$7E ; A
        FCB     $6C,$92,$92,$92,$FE ; B
        FCB     $44,$82,$82,$82,$7C ; C
        FCB     $7C,$82,$82,$82,$FE ; D
        FCB     $82,$92,$92,$92,$FE ; E
        FCB     $80,$90,$90,$90,$FE ; F
        FCB     $5E,$92,$92,$82,$7C ; G
        FCB     $FE,$10,$10,$10,$FE ; H
        FCB     $00,$82,$FE,$82,$00 ; I
        FCB     $FC,$02,$02,$02,$04 ; J
        FCB     $82,$44,$28,$10,$FE ; K
        FCB     $02,$02,$02,$02,$FE ; L
        FCB     $FE,$40,$20,$40,$FE ; M
        FCB     $FE,$10,$20,$40,$FE ; N
        FCB     $7C,$82,$82,$82,$7C ; O
        FCB     $60,$90,$90,$90,$FE ; P
        FCB     $7A,$84,$8A,$82,$7C ; Q
        FCB     $62,$94,$98,$90,$FE ; R
        FCB     $4C,$92,$92,$92,$64 ; S
        FCB     $80,$80,$FE,$80,$80 ; T
        FCB     $FC,$02,$02,$02,$FC ; U
        FCB     $F8,$04,$02,$04,$F8 ; V
        FCB     $FE,$04,$18,$04,$FE ; W
        FCB     $C6,$28,$10,$28,$C6 ; X
        FCB     $E0,$10,$0E,$10,$E0 ; Y
        FCB     $C2,$A2,$92,$8A,$86 ; Z
        FCB     $00,$82,$82,$FE,$00 ; [
        FCB     $04,$08,$10,$20,$40 ; \
        FCB     $00,$FE,$82,$82,$00 ; ]
        FCB     $20,$40,$FE,$40,$20 ; ^
        FCB     $01,$01,$01,$01,$01 ; _
        FCB     $00,$00,$D0,$E0,$00 ; `
        FCB     $02,$1E,$2A,$2A,$0E ; a
        FCB     $3C,$22,$22,$FE,$02 ; b
        FCB     $12,$22,$22,$1C,$00 ; c
        FCB     $02,$FE,$22,$22,$1C ; d
        FCB     $12,$2A,$2A,$1C,$00 ; e
        FCB     $40,$50,$3E,$10,$00 ; f
        FCB     $3E,$25,$25,$19,$00 ; g
        FCB     $1E,$20,$20,$FE,$00 ; h
        FCB     $00,$00,$5E,$00,$00 ; i
        FCB     $00,$2E,$01,$02,$00 ; j
        FCB     $22,$14,$08,$7E,$00 ; k
        FCB     $00,$02,$7E,$40,$00 ; l
        FCB     $1E,$20,$3E,$20,$3E ; m
        FCB     $1E,$20,$20,$3E,$00 ; n
        FCB     $1C,$22,$22,$1C,$00 ; o
        FCB     $18,$24,$24,$3F,$00 ; p
        FCB     $01,$3F,$24,$24,$18 ; q
        FCB     $20,$20,$10,$3E,$00 ; r
        FCB     $24,$2A,$2A,$12,$00 ; s
        FCB     $04,$22,$7C,$20,$00 ; t
        FCB     $02,$3E,$02,$02,$3C ; u
        FCB     $30,$0C,$02,$0C,$30 ; v
        FCB     $3C,$02,$0C,$02,$3C ; w
        FCB     $22,$12,$1C,$24,$22 ; x
        FCB     $3F,$05,$04,$38,$00 ; y
        FCB     $20,$32,$2A,$26,$02 ; z
        FCB     $82,$82,$6C,$10,$00 ; {
        FCB     $00,$00,$EE,$00,$00 ; |
        FCB     $10,$6C,$82,$82,$00 ; }
        FCB     $1C,$10,$10,$10,$10 ; ~
        FCB     $AA,$55,$AA,$55,$AA ; chess pattern
        FCB     $FF,$FF,$FF,$FF,$FF ; bloc pattern
        FCB     $C3,$81,$00,$81,$C3 ; angle pattern
        FCB     $F8,$FF,$29         ; void...
;*
;* SAM space : not used, except $FFF0-$FFFF (vectors)
;* $FF60-$FFBF is readable too (boot ROM) but seems not used
;*

        ORG     $FF00

        FDB     $FFBB                    ;FF00: FF BB
        FDB     $0216                    ;FF02: 02 16
        FDB     $FFB9                    ;FF04: FF B9
        FDB     $0216                    ;FF06: 02 16
        FDB     $FFB3                    ;FF08: FF B3
        FDB     $0216                    ;FF0A: 02 16
        FDB     $FFBB                    ;FF0C: FF BB
        FDB     $0216                    ;FF0E: 02 16
        FDB     $FFBB                    ;FF10: FF BB
        FDB     $0014                    ;FF12: 00 14
        FDB     $FFBB                    ;FF14: FF BB
        FDB     $0214                    ;FF16: 02 14
        FDB     $FFBB                    ;FF18: FF BB
        FDB     $0216,$FFBB              ;FF1A: 02 16 FF BB
        FDB     $0014                    ;FF1E: 00 14
        FDB     $FFB9,$0216,$FFBB,$0016  ;FF20: FF B9 02 16 FF BB 00 16
        FDB     $FFB3,$0212,$FFB3,$0216  ;FF28: FF B3 02 12 FF B3 02 16
        FDB     $FFF3,$0016,$FFBB,$0014  ;FF30: FF F3 00 16 FF BB 00 14
        FDB     $FFB3,$0014,$FFB3,$001C  ;FF38: FF B3 00 14 FF B3 00 1C
        FDB     $1000,$BFFF,$1000,$BFFF  ;FF40: 10 00 BF FF 10 00 BF FF
        FDB     $1000,$BFFF,$1000,$BFFF  ;FF48: 10 00 BF FF 10 00 BF FF
        FDB     $1000,$BFFF,$1000,$FFFF  ;FF50: 10 00 BF FF 10 00 FF FF
        FDB     $1000,$BFFF,$1000,$FFFF  ;FF58: 10 00 BF FF 10 00 FF FF
        FDB     $1000,$BFFF,$1000,$BFFF  ;FF60: 10 00 BF FF 10 00 BF FF
        FDB     $1000,$FFFF,$1000,$BFFF  ;FF68: 10 00 FF FF 10 00 BF FF
        FDB     $1000,$FFFF,$1000,$BFFF  ;FF70: 10 00 FF FF 10 00 BF FF
        FDB     $1000,$BFFF,$1000,$FFFF  ;FF78: 10 00 BF FF 10 00 FF FF
        FDB     $B9FF,$1400,$B8FF,$1600  ;FF80: B9 FF 14 00 B8 FF 16 00
        FDB     $BBFF,$1600,$B9FD,$1402  ;FF88: BB FF 16 00 B9 FD 14 02
        FDB     $B9FF,$1600,$B1FD,$1602  ;FF90: B9 FF 16 00 B1 FD 16 02
        FDB     $B9FF,$1600,$B9FD,$1402  ;FF98: B9 FF 16 00 B9 FD 14 02
        FDB     $B1FF,$1600,$B9FD,$1602  ;FFA0: B1 FF 16 00 B9 FD 16 02
        FDB     $BBFF,$1600,$B8FF,$1602  ;FFA8: BB FF 16 00 B8 FF 16 02
        FDB     $B9FF,$1600,$B9FD,$1602  ;FFB0: B9 FF 16 00 B9 FD 16 02
        FDB     $B9FF,$1600,$B9FD,$1602  ;FFB8: B9 FF 16 00 B9 FD 16 02
        FDB     $0010,$FFBF,$0010,$FFBF  ;FFC0: 00 10 FF BF 00 10 FF BF
        FDB     $0010,$FFBF,$0010,$FFBF  ;FFC8: 00 10 FF BF 00 10 FF BF
        FDB     $0010,$FFBF,$0010        ;FFD0: 00 10 FF BF 00 10
        FDB     $FFBF                    ;FFD6: FF BF
        FDB     $0010                    ;FFD8: 00 10
        FDB     $FFBF                    ;FFDA: FF BF
        FDB     $0010                    ;FFDC: 00 10
        FDB     $FFFF                    ;FFDE: FF FF
        FDB     $0010,$FFBF,$0010,$FFBF  ;FFE0: 00 10 FF BF 00 10 FF BF
        FDB     $0010,$FFBF,$0010,$FFBF  ;FFE8: 00 10 FF BF 00 10 FF BF
;*
;* Restart control vectors.
;*
          ORG (PROM+$1FF0)

          FDB      RESET               Not implemented in 6809.
          FDB      SWI3                Software interupt three.
          FDB      SWI2                Software interupt two.
          FDB      FIRQ                Fast interupt request.
          FDB      IRQ                 Interupt request.
          FDB      SWI                 Software interupt.
          FDB      NMI                 Non-maskable interupt.
VCRST     FDB      RESET               Cold start.
;*
;*
          END
