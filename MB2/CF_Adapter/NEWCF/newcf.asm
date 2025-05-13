;*********************************************************
;*                                                       *
;* COMPACT FLASH FORMAT UTILITY                          *
;*                                                       *
;* WRITED FOR MICROBOX][ BY PH. ROEHR 05/2025            *
;*                                                       *
;* THIS VERSION IS FOR CF CONNECTED TO 8255 VIA          *
;* AND 16 BITS DATA TRANSFER                             *
;*                                                       *
;*********************************************************

SECSZ   EQU     $FF         ; 256 BYTES/SECTORS FOR FLEX (0->FF)
SECBUF  EQU     $800        ; BUFFER FOR PREPARING SECTOR IN MEMORY
ENDBUF  EQU     SECBUF+SECSZ

;* STANDARD PRE-NAMED LABEL EQUATES
SYSMTH  EQU     $CC0E       ; SYSTEM DATE MONTH
SYSDAY  EQU     $CC0F       ; DAY
SYSYR   EQU     $CC10       ; YEAR
WARMS   EQU     $CD03
GETCHR  EQU     $CD15
PUTCHR  EQU     $CD18
INBUFF  EQU     $CD1B
PSTRNG  EQU     $CD1E
PCRLF   EQU     $CD24
GETFIL  EQU     $CD2D
OUTDEC  EQU     $CD39
OUTHEX  EQU     $CD3C
GETHEX  EQU     $CD42
OUTADR  EQU     $CD45
INDEC   EQU     $CD48
ASNPRM  EQU     $CC0B       ; ASN PARAMETERS

;* ASCII CODE EQUATES
EOT     EQU     $04
SPC     EQU     $20

;* MICROBOX][ ADDRESSES

IO      EQU   $FF00        ; BASE IO ADDRESS
PIA2    EQU   IO+28        ; $FF1C

;*********************************
;* COMPACT FLASH SYSTEM EQUATES  *
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
IDE_CMD_ID          EQU     $EC                 ; CF ID COMMAND

;* FEATURE REQUESTS

IDE_FEA_16BIT       EQU     $81
IDE_FEA_8BIT        EQU     $01
LBA3MST             EQU     $E0                 ; LBA3 FOR IDE MASTER
LBA3SLV             EQU     $F0                 ; LBA3 FOR IDE SLAVE

;* CF CONTROL BITS

DRQBIT              EQU     %00001000           ; DATA REQUEST BIT = CF STATUS BIT 3
RDYBIT              EQU     %01000000           ; READY BIT = BIT 6
BSYBIT              EQU     %10000000           ; BUSY BIT = BIT 7
ERRBIT              EQU     %00000001           ; ERROR BIT = BIT 0

;* FLEX PARAMS

MSTCFOK EQU     $DE7E       ; CF PRESENT FLAGS
SLVCFOK EQU     $DE7F
DDSTAB  EQU     $DF9D       ; PHYS -> FLEX DISK TABLE


        ORG     $0100

;* VARIOUS PARAM IN RAM

SETFEA  RMB     1          ; SET FEATURE 8 OR 16 BITS MODE
SCTCNT  RMB     1          ; SECTOR COUNT FOR R/W (ALWAYS 1)
LBA0    RMB     1          ; LBA7 TO LBA0
LBA1    RMB     1          ; LBA15 TO LBA8
LBA2    RMB     1          ; LBA23 TO LBA 16
LBA3    RMB     1          ; B7=1 / B6=1 FOR LBA / B5=1 / B4=0 MASTER B4=1 SLAVE / B3->B0 LBA27 TO LBA24

FAKMS   FCB     $00        ; FAKE MSB MAX SECTOR
MAXS    FCB     255        ; 256 SECTORS ON TRACK (0-FF)
FAKMT   FCB     $00        ; FAKE MSB MAX TRACK
MAXT    FCB     122        ; MAX 256 TRACKS (0-FF) / 122 DEFAULT
TRACK   RMB     1
SECT    RMB     1
LBA10   RMB     2
MAXLBA  RMB     2
FKFCB   RMB     4
VOLNAM  FCB     0,0,0,0,0,0,0,0,0,0,0
VOLNUM  FCB     0,0

        ORG     $1000

NEWCF   BRA     FORM1       ; BEGIN
VN      FCB     1           ; VERSION

OUTIN   JSR     PSTRNG      ; DISPLAY STRING
OUTIN2  JSR     GETCHR      ; GET RESPONSE
        ANDA    #$5F        ; UPPER CASE
        CMPA    #'Y'        ; COMPARE TO Y SO Z IS SET IF YES
        RTS
;*
;* PROGRAM START
FORM1   JSR     PCRLF
        JSR     GETHEX      ; GET FLEX DRIVE NUMBER FROM COMMAND LINE
        LBCS    EXIT        ; EXIT ON ERROR
        TFR     X,D

        TST     MSTCFOK     ; MASTER CF PRESENT ?
        LBEQ    EXIT        ; NO THEN EXIT
        LDX     #DDSTAB
        LDA     B,X         ; LOAD PHYS DISK NUMBER
        CMPA    #$02        ; MASTER ?
        BNE     TSTSLV      ; NO GO TO TEST SLAVE
        LDA     #LBA3MST
        BRA     CONTIN0     ; CONTINUE
TSTSLV  CMPA    #$03        ; SLAVE ?
        LBNE    EXIT        ; NO EXIT
        LDA     #LBA3SLV

CONTIN0 STA     LBA3        ; STORE LBA3 IN RAM

        CMPB    ASNPRM      ; ENSURE COMPACT FLASH ASKED IS NOT SYSTEM DISK
        BNE     CONTIN      ; COMPARE ASN-SYSTEM TO CF DISK NUMBER
        LDX     #MSGCFS     ; IF YES DISPLAY MSG AND EXIT
        JMP     EXIT2

CONTIN  JSR     PCRLF
        JSR     INICF8      ; INIT COMPACT FLASH
        BEQ     CONTIN1     ; GO TO FORMAT IF OK (Z SET)
        LDX     #CFINIER    ; ERROR AFTER CF INIT - DISPLAY
        JMP     EXIT2       ; AND EXIT

CONTIN1 LDX     #CFINIOK    ; DISPLAY MSG CF INIT OK
        JSR     PSTRNG
        LDX     #SECBUF     ; BUFFER ADDRESS
        JSR     RDCF        ; READ CF PARAMETERS
        LDX     #MSGLBA     ; DISPLAY MSG PARAM OK
        JSR     PSTRNG
        JSR     INICF16     ; SWITCH CF BACK TO 16 BITS MODE
        BEQ     CONTIN2     ; GO TO FORMAT IF OK (Z SET)
        LDX     #CFINIER    ; ERROR AFTER CF INIT - DISPLAY
        JMP     EXIT2       ; AND EXIT

CONTIN2 LDX     #SECBUF
        LEAX    123,X       ; GET MAX LBA IN BUFFER (MSW H)
        JSR     OUTHEX      ; DISPLAY IT
        LEAX    -1,X        ; GET MAX LBA IN BUFFER (MSW L)
        JSR     OUTHEX      ; DISPLAY IT
        LEAX    -1,X        ; GET MAX LBA IN BUFFER (LSW H)
        JSR     OUTHEX      ; DISPLAY IT
        LEAX    -1,X        ; GET MAX LBA IN BUFFER (LSW L)
        JSR     OUTHEX      ; DISPLAY IT
        JSR     PCRLF

        LDX     #SURES      ; ASK IF SURE
        LBSR    OUTIN
        LBNE    EXIT        ; EXIT IF NOT
        LDX     #SCRDS      ; ASK IF SCRATCH DISK SURE
        JSR     PSTRNG
        LBSR    OUTIN2      ; GET RESPONSE
        LBNE    EXIT        ; EXIT IF SCRATCH NOT SURE

FORM20  JSR     PCRLF
        LDX     #SECNUM     ; SECTOR NUMBER MSG
        JSR     PSTRNG
        LDX     #255        ; WE USE 256 SECTORS (0-255)
        STX     FAKMS

FORM30  LDX     #TRKNUM     ; ASK TRACK NUMBER
        JSR     PSTRNG
        JSR     INBUFF
        JSR     INDEC
        BCS     FORM30
        CMPX    #$0002      ; CHECK IF >= 2
        BLE     FORM30
        CMPX    #$00FF      ; CHECK IF <= 255
        BHI     FORM30
        LEAX    -1,X        ; SUBSTRACT 1 BECAUSE TRACK ARE NUMBERED 0 TO MAXT
        STX     FAKMT

FORM40  LDX     #MNSTR      ; ASK VOLUME NAME
        JSR     PSTRNG
        JSR     INBUFF
        LDX     #FKFCB
        JSR     GETFIL

FORM27  LDX     #NUMSTR     ; ASK VOLUME NUMBER
        JSR     PSTRNG
        JSR     INBUFF
        JSR     INDEC
        BCS     FORM27
        STX     VOLNUM

        LDA     MAXT
        INCA
        LDB     #$00
        STD     MAXLBA      ; STORE TOTAL LBA ON DISK
        JSR     PCRLF
        JMP     FORMAT      ; GO TO FORMAT IF OK
;*
;* EXIT ROUTINES
EXIT    LDX     #ABORTS
EXIT2   JSR     PSTRNG
        JSR     PCRLF
        JMP     WARMS       ; EXIT
;*
;* MAIN FORMATTING LOOP
FORMAT  LDX     #SECBUF     ; CLEAR BUFFER
CLRBUF  CLR     ,X+
        CMPX    #ENDBUF+1   ; FLEX SECTOR IS 256 BYTES
        BNE     CLRBUF

        LDX     #INITRK     ; DISPLAY WRITE TR/SECTOR MESSAGE
        JSR     PSTRNG

        CLR     TRACK       ; SET TRACK 0
        CLR     SECT        ; SET SECTOR 0
        LDD     #$0000
        STD     LBA10       ; SET LBA NUM AT 0

        LDA     TRACK
        LDX     LBA10       ; X STORE THE CURRENT LBA NUMBER
FLOOP1  STA     SECBUF      ; STORE TRACK IN FIRST BUFFER BYTE
        LDB     SECT        ; LOAD SECTOR
        INCB                ; POINT TO THE NEXT SECTOR
        STB     SECBUF+1    ; STORE SECTOR+1 IN SECOND BUFFER BYTE

        JSR     WTSECT      ; WRITE SECTOR TO CF
        LEAX    1,X         ; INC LBA NUMBER
        STX     LBA10       ; STORE INTO RAM

        STB     SECT        ; STORE NEXT SECT IN RAM
        CMPB    MAXS        ; IS SECTOR = $FF
        BNE     FLOOP1      ; NO DO AGAIN FOR NEXT SECTOR

        CLR     SECT        ; RESET SECTOR TO 0
        INCA                ; NEXT TRACK
;* LAST SECTOR OF EACH TRACK MUST BE WRITE 2X
        STA     SECBUF      ; STORE TRACK IN FIRST BUFFER BYTE
        LDB     SECT
        INCB
        STB     SECBUF+1    ; STORE SECTOR IN SECOND BUFFER BYTE
        JSR     WTSECT      ; WRITE SECTOR TO CF
        LEAX    1,X         ; INC LBA NUMBER
        STX     LBA10       ; STORE INTO RAM10

        CMPA    MAXT        ; IS TRACK N° > MAX TRACK
        BHI     ENDFORM     ; YES END FORMAT
        STA     TRACK       ; NO STORE
        BRA     FLOOP1      ; AND DO AGAIN FOR NEXT TRACK

ENDFORM CLR     SECBUF      ; SET 00-00 INTO LAST SECTOR OF LAST TRACK (END FREE CHAIN)
        CLR     SECBUF+1
        LDA     MAXT
        LDB     MAXS
        STD     LBA10
        JSR     WTSECT

        JMP     SETSIR      ; END OF FORMATTING LOOP - GO TO SETUP SIR
;*
;* WRITE SECTOR TO CF
WTSECT  PSHS    A,B,X
        LDD     LBA10       ; UPDATE LBA TABLE IN RAM
        STA     LBA1
        STB     LBA0
        LDA     #$08        ; LOAD BACKSPACE
        RPT     13          ; ERASE FROM PREVIOUS
        JSR     PUTCHR
        LDX     #TRACK
        JSR     OUTADR      ; DISPLAY TRACK AND SECTOR
        LDA     #SPC
        JSR     PUTCHR      ; DISPLAY SPC
        LDX     #LBA3
        JSR     OUTHEX      ; DISPLAY LBA3
        LDX     #LBA2
        JSR     OUTHEX      ; DISPLAY LBA2
        LDX     #LBA1
        JSR     OUTHEX      ; DISPLAY LBA1
        LDX     #LBA0
        JSR     OUTHEX      ; DISPLAY LBA0
        JSR     WRCF        ; WRITE SECTOR TO CF
        PULS    A,B,X,PC
;*
;* SETUP THE SIR IN BUFFER THEN WRITE IT INTO TR 0 / SEC 3
SETSIR  LDX     #SECBUF     ; POINT TO BUFFER
CLRL    CLR     ,X+         ; CLEAR 16 FIRST BYTES
        CMPX    #SECBUF+16
        BNE     CLRL
        LDY     #VOLNAM     ; TRANSFERT 11 BYTES AS VOLUME NAME
NAML    LDB     ,Y+
        STB     ,X+         ; WRITE TO BUFFER
        CMPY    #VOLNAM+11
        BNE     NAML
        LDD     ,Y          ; LOAD TWO BYTES AS VOLUME NUMBER
        STD     ,X++        ; WRITE TO BUFFER
        LDB     #01         ; SET 01 FOR FIRST FREE TRACK AND SECTOR
        STB     ,X+
        STB     ,X+
        LDB     MAXT        ; SET MAX TRACK AS LAST FREE TRACK
        STB     ,X+
        LDB     MAXS        ; SET MAX SECTOR AS LAST FREE SECTOR
        STB     ,X+
        LDD     MAXLBA      ; LOAD MAX SECTORS ON CF
        SUBD    FAKMS       ; SUBSTRACT TRACK 0 SECTORS (EXCEPT S0)
        SUBD    FAKMT       ; SUBSTRACT SECTOR 0 OF EACH TRACK
        DECD                ; BECAUSE WE HAVE MAXT+1 TRACKS
        STD     ,X++        ; WRITE HOW MANY FREE SECTORS ON DISK
        LDB     SYSMTH      ; SET MONTH
        STB     ,X+
        LDB     SYSDAY      ; SET DAY
        STB     ,X+
        LDB     SYSYR       ; SET YEAR
        STB     ,X+
        LDB     MAXT        ; SET MAX TRACK
        STB     ,X+
        LDB     MAXS        ; SET MAX SECTOR
        STB     ,X
        CLRA                ; SIR LAY IN TR 0
        LDB     #$03        ; SEC 3
        STD     LBA10
        JSR     WTSECT      ; WRITE SIR BUFFER TO CF
        LDX     #MSGSIR     ; DISPLAY SIR MESSAGE
        JSR     PSTRNG
        JMP     SETDIR      ; GO TO DIR SETUP
;*
;* DIR SETUP (NOT REALLY REQUIRED, FOR CLARITY ONLY)
;* HERE WE HAVE JUST TO PUT 00-00 INTO LAST SECTOR
;* OF TRACK 0 TO END THE DIRECTORY SECTORS CHAIN
SETDIR  CLR     SECBUF      ; SET 00-00 INTO LAST SECTOR OF TRACK 0 (END DIR CHAIN)
        CLR     SECBUF+1
        CLRA
        LDB     MAXS
        STD     LBA10
        JSR     WTSECT
        LDX     #MSGDIR     ; DISPLAY DIR MESSAGE
        JSR     PSTRNG
;*
;* ALL DONE
        JSR     PCRLF
        LDX     #SECST      ; DISPLAY SECTOR NUMBER MESSAGE
        JSR     PSTRNG
        LDX     #MAXLBA
        JSR     OUTDEC      ; DISPLAY NUMBER OF SECTORS
;*
;* EXIT AFTER FORMAT
ENDMSG  LDX     #CMPLTE     ; SET MESSAGE FORMAT COMPLETE
        JMP     EXIT2       ; NOW EXIT
;*
;* DISPLAYED MESSAGES
SURES   FCC     "ARE YOU SURE ? "
        FCB     EOT
CFINIOK FCC     "COMPACT FLASH INITIALIZED."
        FCB     EOT
MSGLBA  FCC     "TOTAL LBA ON COMPACT FLASH (HEX) : "
        FCB     EOT
MSGCFS  FCC     "COMPACT FLASH SET AS SYSTEM DISK - CAN'T FORMAT."
        FCB     EOT
CFINIER FCC     "ERROR INITIALIZING COMPACT FLASH."
        FCB     EOT
SCRDS   FCC     "SCRATCH COMPACT FLASH ? "
        FCB     EOT
ABORTS  FCC     "FORMAT ABORTED !"
        FCB     EOT
MSGSIR  FCC     "SIR BUILD AND WRITE."
        FCB     EOT
MSGDIR  FCC     "DIR BUILD AND WRITE."
        FCB     EOT
CMPLTE  FCC     "FORMAT COMPLETE."
        FCB     EOT
SECST   FCC     "TOTAL SECTORS = "
        FCB     EOT
MNSTR   FCC     "VOLUME NAME ? "
        FCB     EOT
NUMSTR  FCC     "VOLUME NUMBER ? "
        FCB     EOT
INITRK  FCC     "WRITE TRACK/SECTOR + LBA3-2-1-0 :              "
        FCB     EOT
SECNUM  FCC     "SECTORS PER TRACK IS FIXED TO 256 (0 TO 255) "
        FCB     EOT
TRKNUM  FCC     "HOW MANY TRACKS (2 TO 255, 122 RECOMMENDED FOR 16 MB CF) ? "
        FCB     EOT
;*
;* INITIALIZE CF CARD IN 8 BITS MODE
INICF8  CLR     LBA2            ; CLR ALL LBA (BUT NOT LBA3)
        CLR     LBA1
        CLR     LBA0
        LDA     #IDE_FEA_8BIT   ; PREPARE THE CF FOR 8 BITS MODE
        STA     SETFEA          ; SET CF CARD FEATURES
        LDA     #$01
        STA     SCTCNT          ; 1X LBA R/W DATA TRANSFER
        JSR     TFRPARM         ; TRANSFER PARAMS IN MASTER CF AND ENABLE
        JSR     CFERR           ; CHECK IF CF ERROR
        RTS
;*
;* INITIALIZE BOTH CF CARDS IN 16 BITS MODE
;* DUE TO IDE BUS RESET WE RELOAD PARAMS FOR MST AND SLV CF
INICF16 LDA     #RD_IDE_8255
        STA     PORTCTRL        ; SET PORT C AS OUTPUT
        LDA     #IDE_RST        ; DO A IDE BUS RESET
        STA     PORTC
        LDA     #10             ; KEEP RESET LOW > 25 ΜS
LOOPRST DECA
        BNE     LOOPRST
        CLR     PORTC
        LDA     #50
        JSR     WAIT1MS         ; WAIT > 50 MS FOR CF TO COMPLETE INIT

        CLR     LBA2            ; CLR ALL LBA (BUT NOT LBA3)
        CLR     LBA1
        CLR     LBA0
        LDA     #IDE_FEA_16BIT  ; PREPARE THE CF FOR 16 BITS MODE
        STA     SETFEA          ; SET CF CARD FEATURES
        LDA     #$01
        STA     SCTCNT          ; 1X LBA R/W DATA TRANSFER
        LDA     LBA3
        PSHS    A               ; SAVE LBA3
        LDA     #LBA3MST
        STA     LBA3
        JSR     TFRPARM         ; TRANSFER PARAMS IN MASTER CF AND ENABLE
        LDA     #LBA3SLV
        STA     LBA3
        JSR     TFRPARM         ; TRANSFER PARAMS IN SLAVE CF AND ENABLE
        PULS    A
        STA     LBA3            ; RESTORE LBA3
        JSR     CFERR           ; CHECK IF CF ERROR
        RTS
;*
;* WAIT 1MS ROUTINE
;* INPUT A = NUMBER OF MS TO WAIT
WAIT1MS LDB     #200
LOOPW   DECB
        BNE     LOOPW
        DECA
        BNE     WAIT1MS
        RTS
;*
;* TRANSFER PARAMS TABLE FROM MEMORY TO CF
;* AND ENABLE DATA
TFRPARM     PSHS    A,B,X,Y
            LDX     #LBA3+1             ; LOAD TABLE ADDRESS + 1
            LDY     #IDE_LBA3           ; LOAD 1ST CF REGISTER TO WRITE

PARMLOP     BSR     CMDWAIT
            TFR     Y,D                 ; GET Y LSB INTO B
            LDA     ,-X                 ; WITH PRE DECR LOAD PARAM FROM TABLE
            BSR     WRT_IDE             ; WRITE PARAM IN CF
            LEAY    -1,Y                ; CHANGE CF REGISTER
            CMPY    #IDE_SET_FEAT-1     ; CHECK IF 6 PARAMS LOADED IN CF
            BNE     PARMLOP             ; IF 6 PARAMS NOT LOADED DO AGAIN

            BSR     CMDWAIT
            LDA     #IDE_CMD_SET_FEAT   ; NOW ENABLE FEATURES
            LDB     #IDE_COMMAND
            BSR     WRT_IDE
            PULS    A,B,X,Y,PC
;*
;* CHECK CF ERROR
;* RETURN   Z=0 ERROR
;*          Z=1 NO ERROR
CFERR       BSR     DATWAIT             ; STATUS REGISTER VALID ONLY IF BUSY BIT CLEAR
            LDB     #IDE_STATUS         ; ASK STATUS REGISTER
            BSR     READ_IDE
            BITA    #ERRBIT             ; READ ERROR BIT
            RTS
;*
;* WAIT CF CARD COMMAND READY
CMDWAIT     BSR     DATWAIT             ; STATUS REGISTER VALID ONLY IF BUSY BIT CLEAR
CWLOOP      LDB     #IDE_STATUS         ; ASK STATUS REGISTER
            BSR     READ_IDE
            BITA    #RDYBIT             ; READ READY BIT
            BEQ     CWLOOP              ; WAIT READY BIT SET
            RTS
;*
;* WAIT CF CARD DATA READY
DATWAIT     LDB     #IDE_STATUS         ; ASK STATUS REGISTER
            BSR     READ_IDE            ; A RECEIVE STATUS REGISTER
            BITA    #BSYBIT             ; READ BUSY BIT
            BNE     DATWAIT             ; NOT CLEAR ? YES DO AGAIN
            RTS
;*
;* READ CF PARAMETERS
;* (X=ADDR OF BUFFER)
RDCF        PSHS    Y,X,B,A

            BSR     CMDWAIT
            LDA     #IDE_CMD_ID         ; SEND ID COMMAND TO CF
            LDB     #IDE_COMMAND
            BSR     WRT_IDE

RDLOOP      BSR     CHKDRQ
            BEQ     RWEXIT              ; Z SET ? YES END OF LOOP
            BSR     DATWAIT
            LDB     #IDE_DATA
            BSR     READ_IDE            ; READ THE DATA BYTE FROM CF
            STA     ,X+                 ; WRITE IT TO THE BUFFER
            BRA     RDLOOP
;*
;* WRITE A SECTOR TO DISK TYP 8255 / IDE
WRCF        PSHS    Y,X,B,A

            BSR     TFRPARM             ; SET PARAMS IN CF

            BSR     CMDWAIT
            LDA     #IDE_CMD_WRITE      ; SEND WRITE COMMAND TO THE CF CARD
            LDB     #IDE_COMMAND        ; LOAD COMMAND REGISTER ADDRESS
            BSR     WRT_IDE             ; SEND COMMAND TO THE CF CARD

            LDX     #SECBUF
WRLOOP      BSR     CHKDRQ
            BEQ     RWEXIT              ; Z SET ? YES END OF LOOP
            BSR     DATWAIT
            LDA     ,X+                 ; READ THE BYTE FROM THE BUFFER
            LDB     #IDE_DATA           ; WRITE THE DATA BYTE TO CF
            BSR     WRT_IDE
            BRA     WRLOOP

RWEXIT      PULS    Y,X,B,A,PC
;*
;* CHECK CF DRQ BIT
;* RETURN Z=0 IF DRQ SET
;*        Z=1 IF DRQ NOT SET
CHKDRQ      BSR     DATWAIT
            LDB     #IDE_STATUS
            BSR     READ_IDE
            BITA    #DRQBIT
            RTS
;*
;* DO A ONE BYTE WRITE CYCLE TO IDE
;* B = CF REGISTER WHERE TO WRITE
;* A = BYTE TO WRITE
WRT_IDE     PSHS    A
            LDA     #WR_IDE_8255        ; SET 8255 A/B/C FOR OUTPUT
            STA     PORTCTRL
            PULS    A
            STA     PORTA               ; PREPARE LSB ON OUTPUT D0-D7
            STB     PORTC               ; SET CF REGISTER ADDRESS
            ORB     #IDE_WR             ; ASSERT WR LINE
            STB     PORTC
            EORB    #IDE_WR             ; PREPARE FOR WR LINE RELEASE
            BRA     ENDIDERW
;*
;* DO A ONE BYTE READ CYCLE FROM IDE
;* B = CF REGISTER TO READ
;* A = BYTE READ
READ_IDE    LDA     #RD_IDE_8255        ; SET 8255 A/B FOR INPUT C FOR OUTPUT
            STA     PORTCTRL
            STB     PORTC               ; SET CF REGISTER ADDRESS
            ORB     #IDE_RD             ; ASSERT RD LINE
            STB     PORTC
            LDA     PORTA               ; READ LSB FROM D0-D7
            EORB    #IDE_RD             ; PREPARE FOR RD LINE RELEASE

ENDIDERW    STB     PORTC               ; RELEASE LINE
            CLR     PORTC               ; RELEASE IDE DEVICE
            RTS

;* COMPACT FLASH FLEX LOADER
;* !!! NO NEED OF A BOOT SECTOR ON THE MICROBOX !!!

            END    NEWCF
