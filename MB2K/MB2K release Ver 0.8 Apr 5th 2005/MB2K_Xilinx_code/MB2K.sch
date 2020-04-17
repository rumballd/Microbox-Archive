VERSION 6
BEGIN SCHEMATIC
    BEGIN ATTR DeviceFamilyName "spartan3"
        DELETE all:0
        EDITNAME all:0
        EDITTRAIT all:0
    END ATTR
    BEGIN NETLIST
        SIGNAL LO
        SIGNAL A(15:0)
        SIGNAL ROM
        SIGNAL RW
        SIGNAL ROMDO(7:0)
        SIGNAL INT_RAM
        SIGNAL RAMDO(7:0)
        SIGNAL ACIADO(7:0)
        SIGNAL X_RAMDO(7:0)
        SIGNAL EXT_RAM
        SIGNAL RAM_WE
        SIGNAL RAM_OE
        SIGNAL RAM1_CE
        SIGNAL RAM1_UB
        SIGNAL RAM1_LB
        SIGNAL RAM2_CE
        SIGNAL RAM2_UB
        SIGNAL RAM2_LB
        SIGNAL RAM_A(17:0)
        SIGNAL RAM1_D(15:0)
        SIGNAL RAM2_D(15:0)
        SIGNAL RAM_PAGE(11:0)
        SIGNAL A(15:4)
        SIGNAL VMA
        SIGNAL SYSREG
        SIGNAL CPUDI(7:0)
        SIGNAL DMAREGS
        SIGNAL KEYDO(7:0)
        SIGNAL KEYBD
        SIGNAL VDUDO(7:0)
        SIGNAL PRRD
        SIGNAL PRRDD(7:0)
        SIGNAL SW3,SW2,SW1,SW0,BELL,SPARE,SCL_IN,SDA_IN
        SIGNAL RST_SW
        SIGNAL ACIA1
        SIGNAL SYSCLK
        SIGNAL TXD
        SIGNAL RXD
        SIGNAL KBDCLK
        SIGNAL KBDDAT
        SIGNAL DISPLAY
        SIGNAL A(2:0)
        SIGNAL A(12:0)
        SIGNAL R
        SIGNAL G
        SIGNAL B
        SIGNAL HS
        SIGNAL VS
        SIGNAL DIN
        SIGNAL A(1:0)
        SIGNAL CCLK
        SIGNAL RSTPROM
        SIGNAL CPUDO(7:0)
        SIGNAL A(0)
        SIGNAL SDA_OUT
        SIGNAL SCL_OUT
        SIGNAL SPARE
        SIGNAL BELL
        SIGNAL PIXCLK
        SIGNAL CLK50M
        SIGNAL SW3
        SIGNAL SW2
        SIGNAL SW1
        SIGNAL SW0
        SIGNAL SDA_PAD
        SIGNAL SCL_PAD
        SIGNAL SCL_IN
        SIGNAL SDA_IN
        SIGNAL PROBE
        SIGNAL BELL_PAD
        PORT Output RAM_WE
        PORT Output RAM_OE
        PORT Output RAM1_CE
        PORT Output RAM1_UB
        PORT Output RAM1_LB
        PORT Output RAM2_CE
        PORT Output RAM2_UB
        PORT Output RAM2_LB
        PORT Output RAM_A(17:0)
        PORT BiDirectional RAM1_D(15:0)
        PORT BiDirectional RAM2_D(15:0)
        PORT Output SYSREG
        PORT Input RST_SW
        PORT Output TXD
        PORT Input RXD
        PORT BiDirectional KBDCLK
        PORT BiDirectional KBDDAT
        PORT Output R
        PORT Output G
        PORT Output B
        PORT Output HS
        PORT Output VS
        PORT Input DIN
        PORT Output CCLK
        PORT Output RSTPROM
        PORT Input CLK50M
        PORT Input SW3
        PORT Input SW2
        PORT Input SW1
        PORT Input SW0
        PORT BiDirectional SDA_PAD
        PORT BiDirectional SCL_PAD
        PORT Output PROBE
        PORT Output BELL_PAD
        BEGIN BLOCKDEF gnd
            TIMESTAMP 2001 2 2 12 37 29
            LINE N 64 -64 64 -96 
            LINE N 76 -48 52 -48 
            LINE N 68 -32 60 -32 
            LINE N 88 -64 40 -64 
            LINE N 64 -64 64 -80 
            LINE N 64 -128 64 -96 
        END BLOCKDEF
        BEGIN BLOCKDEF buf
            TIMESTAMP 2001 2 2 12 35 54
            LINE N 0 -32 64 -32 
            LINE N 224 -32 128 -32 
            LINE N 64 0 128 -32 
            LINE N 128 -32 64 -64 
            LINE N 64 -64 64 0 
        END BLOCKDEF
        BEGIN BLOCKDEF cpu09
            TIMESTAMP 2005 3 21 11 19 32
            RECTANGLE N 64 -512 320 0 
            LINE N 64 -480 0 -480 
            LINE N 64 -416 0 -416 
            LINE N 64 -352 0 -352 
            LINE N 64 -288 0 -288 
            LINE N 64 -224 0 -224 
            LINE N 64 -160 0 -160 
            LINE N 64 -96 0 -96 
            LINE N 64 -32 0 -32 
            RECTANGLE N 0 -44 64 -20 
            LINE N 320 -480 384 -480 
            LINE N 320 -336 384 -336 
            LINE N 320 -192 384 -192 
            RECTANGLE N 320 -204 384 -180 
            LINE N 320 -64 384 -64 
            RECTANGLE N 320 -76 384 -52 
        END BLOCKDEF
        BEGIN BLOCKDEF scratch_ram
            TIMESTAMP 2005 1 24 23 44 27
            RECTANGLE N 64 -384 320 0 
            LINE N 64 -352 0 -352 
            LINE N 64 -288 0 -288 
            LINE N 64 -224 0 -224 
            LINE N 64 -160 0 -160 
            LINE N 64 -96 0 -96 
            RECTANGLE N 0 -108 64 -84 
            LINE N 64 -32 0 -32 
            RECTANGLE N 0 -44 64 -20 
            LINE N 320 -352 384 -352 
            RECTANGLE N 320 -364 384 -340 
        END BLOCKDEF
        BEGIN BLOCKDEF decode_data_mux
            TIMESTAMP 2005 3 21 11 18 6
            LINE N 64 176 0 176 
            RECTANGLE N 0 164 64 188 
            LINE N 64 128 0 128 
            RECTANGLE N 0 116 64 140 
            LINE N 64 80 0 80 
            RECTANGLE N 0 68 64 92 
            LINE N 64 32 0 32 
            RECTANGLE N 0 20 64 44 
            LINE N 64 -416 0 -416 
            LINE N 64 -352 0 -352 
            LINE N 64 -288 0 -288 
            RECTANGLE N 0 -300 64 -276 
            LINE N 64 -224 0 -224 
            RECTANGLE N 0 -236 64 -212 
            LINE N 64 -160 0 -160 
            RECTANGLE N 0 -172 64 -148 
            LINE N 64 -96 0 -96 
            RECTANGLE N 0 -108 64 -84 
            LINE N 64 -32 0 -32 
            RECTANGLE N 0 -44 64 -20 
            RECTANGLE N 64 -448 320 320 
            LINE N 320 -416 384 -416 
            LINE N 320 -320 384 -320 
            LINE N 320 -224 384 -224 
            LINE N 320 -368 384 -368 
            LINE N 320 -272 384 -272 
            LINE N 320 -176 384 -176 
            LINE N 320 -128 384 -128 
            LINE N 320 -80 384 -80 
            LINE N 320 -32 384 -32 
            LINE N 320 224 384 224 
            RECTANGLE N 320 212 384 236 
        END BLOCKDEF
        BEGIN BLOCKDEF external_ram
            TIMESTAMP 2005 1 30 13 6 48
            RECTANGLE N 64 -768 320 0 
            LINE N 64 -736 0 -736 
            LINE N 64 -608 0 -608 
            LINE N 64 -480 0 -480 
            LINE N 64 -352 0 -352 
            RECTANGLE N 0 -364 64 -340 
            LINE N 320 -736 384 -736 
            LINE N 320 -672 384 -672 
            LINE N 320 -608 384 -608 
            LINE N 320 -544 384 -544 
            LINE N 320 -480 384 -480 
            LINE N 320 -416 384 -416 
            LINE N 320 -352 384 -352 
            LINE N 320 -288 384 -288 
            LINE N 320 -224 384 -224 
            RECTANGLE N 320 -236 384 -212 
            LINE N 320 -160 384 -160 
            RECTANGLE N 320 -172 384 -148 
            LINE N 320 -96 384 -96 
            RECTANGLE N 320 -108 384 -84 
            LINE N 320 -32 384 -32 
            RECTANGLE N 320 -44 384 -20 
            LINE N 64 -128 0 -128 
            RECTANGLE N 0 -140 64 -116 
            LINE N 64 -256 0 -256 
            RECTANGLE N 0 -268 64 -244 
        END BLOCKDEF
        BEGIN BLOCKDEF keyboard
            TIMESTAMP 2005 2 1 16 7 28
            RECTANGLE N 64 -384 320 0 
            LINE N 64 -352 0 -352 
            LINE N 64 -288 0 -288 
            LINE N 64 -224 0 -224 
            LINE N 64 -160 0 -160 
            LINE N 64 -96 0 -96 
            LINE N 64 -32 0 -32 
            RECTANGLE N 0 -44 64 -20 
            LINE N 320 -352 384 -352 
            LINE N 320 -256 384 -256 
            RECTANGLE N 320 -268 384 -244 
            LINE N 320 -160 384 -160 
            LINE N 320 -64 384 -64 
        END BLOCKDEF
        BEGIN BLOCKDEF mon09_rom
            TIMESTAMP 2005 2 1 20 17 19
            RECTANGLE N 64 -384 320 0 
            LINE N 64 -352 0 -352 
            LINE N 64 -288 0 -288 
            LINE N 64 -224 0 -224 
            LINE N 64 -160 0 -160 
            LINE N 64 -96 0 -96 
            RECTANGLE N 0 -108 64 -84 
            LINE N 64 -32 0 -32 
            RECTANGLE N 0 -44 64 -20 
            LINE N 320 -352 384 -352 
            RECTANGLE N 320 -364 384 -340 
        END BLOCKDEF
        BEGIN BLOCKDEF vdu
            TIMESTAMP 2005 3 21 10 2 27
            LINE N 368 -32 432 -32 
            RECTANGLE N 368 -44 432 -20 
            RECTANGLE N 112 -448 368 64 
            LINE N 368 -416 432 -416 
            LINE N 368 -352 432 -352 
            LINE N 368 -288 432 -288 
            LINE N 368 -224 432 -224 
            LINE N 368 -160 432 -160 
            LINE N 112 -352 48 -352 
            LINE N 112 -288 48 -288 
            LINE N 112 -224 48 -224 
            LINE N 112 -96 48 -96 
            RECTANGLE N 48 -108 112 -84 
            LINE N 112 -416 48 -416 
            LINE N 112 32 48 32 
            RECTANGLE N 48 20 112 44 
        END BLOCKDEF
        BEGIN BLOCKDEF prom_reader
            TIMESTAMP 2005 2 14 21 54 21
            RECTANGLE N 64 -384 320 0 
            LINE N 64 -352 0 -352 
            LINE N 64 -288 0 -288 
            LINE N 64 -224 0 -224 
            LINE N 64 -160 0 -160 
            LINE N 64 -96 0 -96 
            LINE N 64 -32 0 -32 
            RECTANGLE N 0 -44 64 -20 
            LINE N 320 -352 384 -352 
            LINE N 320 -192 384 -192 
            LINE N 320 -32 384 -32 
            RECTANGLE N 320 -44 384 -20 
        END BLOCKDEF
        BEGIN BLOCKDEF acia
            TIMESTAMP 2005 3 21 19 14 51
            LINE N 64 -544 0 -544 
            LINE N 64 -480 0 -480 
            LINE N 64 -416 0 -416 
            LINE N 64 -352 0 -352 
            LINE N 320 -544 384 -544 
            LINE N 384 -480 320 -480 
            LINE N 64 -224 0 -224 
            RECTANGLE N 0 -236 64 -212 
            LINE N 320 -224 384 -224 
            RECTANGLE N 320 -236 384 -212 
            LINE N 320 -352 384 -352 
            RECTANGLE N 64 -576 320 -192 
            LINE N 64 -288 0 -288 
            RECTANGLE N 0 -300 64 -276 
        END BLOCKDEF
        BEGIN BLOCKDEF system_regs
            TIMESTAMP 2005 3 21 16 57 19
            LINE N 352 32 416 32 
            RECTANGLE N 352 20 416 44 
            LINE N 352 -352 416 -352 
            LINE N 96 -352 32 -352 
            LINE N 96 -288 32 -288 
            LINE N 96 -224 32 -224 
            LINE N 96 -160 32 -160 
            LINE N 96 -32 32 -32 
            LINE N 96 32 32 32 
            LINE N 352 -288 416 -288 
            LINE N 352 -224 416 -224 
            LINE N 352 -160 416 -160 
            LINE N 96 96 32 96 
            RECTANGLE N 32 84 96 108 
            RECTANGLE N 96 -384 352 128 
        END BLOCKDEF
        BEGIN BLOCKDEF iobuf
            TIMESTAMP 2001 11 14 15 13 3
            LINE N 224 -128 128 -128 
            LINE N 160 -64 128 -64 
            LINE N 160 -128 160 -64 
            LINE N 0 -64 64 -64 
            LINE N 96 -140 96 -192 
            LINE N 0 -192 96 -192 
            LINE N 64 -96 64 -160 
            LINE N 128 -128 64 -96 
            LINE N 64 -160 128 -128 
            LINE N 128 -96 128 -32 
            LINE N 64 -64 128 -96 
            LINE N 128 -32 64 -64 
            LINE N 0 -128 64 -128 
        END BLOCKDEF
        BEGIN BLOCKDEF clocks
            TIMESTAMP 2005 3 22 21 4 16
            LINE N 64 -160 0 -160 
            LINE N 320 -96 384 -96 
            RECTANGLE N 64 -192 320 -64 
            LINE N 320 -160 384 -160 
        END BLOCKDEF
        BEGIN BLOCKDEF copy_of_title
            TIMESTAMP 2005 4 3 19 22 23
            LINE N -112 -176 -1140 -176 
            LINE N -1136 -128 -80 -128 
            BEGIN LINE W -80 -80 -352 -80 
            END LINE
            BEGIN LINE W -1136 -80 -352 -80 
            END LINE
            BEGIN LINE W -1136 -224 -1136 -80 
            END LINE
            BEGIN LINE W -144 -80 -152 -80 
            END LINE
            BEGIN LINE W -80 -224 -80 -80 
            END LINE
            LINE N -780 -128 -780 -80 
            LINE N -112 -176 -80 -176 
            LINE N -176 -128 -144 -128 
            BEGIN LINE W -1136 -224 -80 -224 
            END LINE
        END BLOCKDEF
        BEGIN BLOCK XLXI_39 external_ram
            PIN clk SYSCLK
            PIN rw RW
            PIN ce EXT_RAM
            PIN addr(15:0) A(15:0)
            PIN ram1_data(15:0) RAM1_D(15:0)
            PIN ram2_data(15:0) RAM2_D(15:0)
            PIN ram_wen RAM_WE
            PIN ram_oen RAM_OE
            PIN ram1_cen RAM1_CE
            PIN ram1_ubn RAM1_UB
            PIN ram1_lbn RAM1_LB
            PIN ram2_cen RAM2_CE
            PIN ram2_ubn RAM2_UB
            PIN ram2_lbn RAM2_LB
            PIN data_out(7:0) X_RAMDO(7:0)
            PIN ram_addr(17:0) RAM_A(17:0)
            PIN data_in(7:0) CPUDO(7:0)
            PIN map_addr(11:0) RAM_PAGE(11:0)
        END BLOCK
        BEGIN BLOCK XLXI_89 decode_data_mux
            PIN vma VMA
            PIN rw RW
            PIN addr(15:4) A(15:4)
            PIN rom_data(7:0) ROMDO(7:0)
            PIN int_ram_data(7:0) RAMDO(7:0)
            PIN ext_ram_data(7:0) X_RAMDO(7:0)
            PIN sysreg_data(7:0) SW3,SW2,SW1,SW0,BELL,SPARE,SCL_IN,SDA_IN
            PIN keybrd_data(7:0) KEYDO(7:0)
            PIN acia_data(7:0) ACIADO(7:0)
            PIN display_data(7:0) VDUDO(7:0)
            PIN prom_data(7:0) PRRDD(7:0)
            PIN rom ROM
            PIN int_ram INT_RAM
            PIN ext_ram EXT_RAM
            PIN sysreg SYSREG
            PIN keybrd KEYBD
            PIN acia ACIA1
            PIN dma DMAREGS
            PIN promrd PRRD
            PIN display DISPLAY
            PIN cpu_data(7:0) CPUDI(7:0)
        END BLOCK
        BEGIN BLOCK XLXI_80 keyboard
            PIN clk SYSCLK
            PIN rst RST_SW
            PIN cs KEYBD
            PIN rw RW
            PIN addr A(0)
            PIN data_in(7:0) CPUDO(7:0)
            PIN irq
            PIN data_out(7:0) KEYDO(7:0)
            PIN kbd_clk KBDCLK
            PIN kbd_data KBDDAT
        END BLOCK
        BEGIN BLOCK XLXI_86 vdu
            PIN vdu_data_out(7:0) VDUDO(7:0)
            PIN vga_red_o R
            PIN vga_green_o G
            PIN vga_blue_o B
            PIN vga_hsync_o HS
            PIN vga_vsync_o VS
            PIN vdu_rst RST_SW
            PIN vdu_cs DISPLAY
            PIN vdu_rw RW
            PIN vdu_data_in(7:0) CPUDO(7:0)
            PIN vdu_clk PIXCLK
            PIN vdu_addr(2:0) A(2:0)
        END BLOCK
        BEGIN BLOCK XLXI_23 scratch_ram
            PIN clk SYSCLK
            PIN rst RST_SW
            PIN cs INT_RAM
            PIN rw RW
            PIN addr(12:0) A(12:0)
            PIN wdata(7:0) CPUDO(7:0)
            PIN rdata(7:0) RAMDO(7:0)
        END BLOCK
        BEGIN BLOCK XLXI_85 mon09_rom
            PIN clk SYSCLK
            PIN rst RST_SW
            PIN cs ROM
            PIN rw RW
            PIN addr(12:0) A(12:0)
            PIN wdata(7:0) CPUDO(7:0)
            PIN rdata(7:0) ROMDO(7:0)
        END BLOCK
        BEGIN BLOCK XLXI_15 cpu09
            PIN clk SYSCLK
            PIN rst RST_SW
            PIN halt LO
            PIN hold LO
            PIN irq LO
            PIN firq LO
            PIN nmi LO
            PIN data_in(7:0) CPUDI(7:0)
            PIN rw RW
            PIN vma VMA
            PIN address(15:0) A(15:0)
            PIN data_out(7:0) CPUDO(7:0)
        END BLOCK
        BEGIN BLOCK XLXI_87 prom_reader
            PIN clk SYSCLK
            PIN rst RST_SW
            PIN cs PRRD
            PIN rw RW
            PIN din DIN
            PIN addr(1:0) A(1:0)
            PIN cclk CCLK
            PIN reset_prom RSTPROM
            PIN rdata(7:0) PRRDD(7:0)
        END BLOCK
        BEGIN BLOCK XLXI_163 gnd
            PIN G LO
        END BLOCK
        BEGIN BLOCK XLXI_170 acia
            PIN clk SYSCLK
            PIN rst RST_SW
            PIN cs ACIA1
            PIN rw RW
            PIN RxD RXD
            PIN datain(7:0) CPUDO(7:0)
            PIN TxD TXD
            PIN baudx16
            PIN dataout(7:0) ACIADO(7:0)
            PIN addr(1:0) A(1:0)
        END BLOCK
        BEGIN BLOCK XLXI_169 system_regs
            PIN a0 A(0)
            PIN clk SYSCLK
            PIN rst RST_SW
            PIN rw RW
            PIN mapr DMAREGS
            PIN sysr SYSREG
            PIN datain(7:0) CPUDO(7:0)
            PIN bell BELL
            PIN scl SCL_OUT
            PIN sda SDA_OUT
            PIN spare SPARE
            PIN mapout(11:0) RAM_PAGE(11:0)
        END BLOCK
        BEGIN BLOCK XLXI_185 clocks
            PIN clk50M CLK50M
            PIN sysclk SYSCLK
            PIN pixclk PIXCLK
        END BLOCK
        BEGIN BLOCK XLXI_174 iobuf
            PIN I SCL_OUT
            PIN IO SCL_PAD
            PIN O SCL_IN
            PIN T SCL_OUT
        END BLOCK
        BEGIN BLOCK XLXI_173 iobuf
            PIN I SDA_OUT
            PIN IO SDA_PAD
            PIN O SDA_IN
            PIN T SDA_OUT
        END BLOCK
        BEGIN BLOCK XLXI_159 buf
            PIN I VMA
            PIN O PROBE
        END BLOCK
        BEGIN BLOCK XLXI_179 buf
            PIN I BELL
            PIN O BELL_PAD
        END BLOCK
        BEGIN BLOCK XLXI_187 copy_of_title
            ATTR TitleFieldText "Microbox 2000   ver 0.8"
            ATTR SheetNumber "1"
            ATTR NumberOfSheets "1"
            ATTR NameFieldText "D.A.Rumball"
            ATTR DateFieldText "31-3-2005"
        END BLOCK
    END NETLIST
    BEGIN SHEET 1 3520 2720
        BEGIN BRANCH RW
            WIRE 2880 224 2896 224
            BEGIN DISPLAY 2880 224 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH EXT_RAM
            WIRE 2880 352 2896 352
            BEGIN DISPLAY 2880 352 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH A(15:0)
            WIRE 2880 480 2896 480
            BEGIN DISPLAY 2880 480 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RAM_OE
            WIRE 3280 160 3312 160
        END BRANCH
        BEGIN BRANCH RAM1_CE
            WIRE 3280 224 3312 224
        END BRANCH
        BEGIN BRANCH RAM1_UB
            WIRE 3280 288 3312 288
        END BRANCH
        BEGIN BRANCH RAM1_LB
            WIRE 3280 352 3312 352
        END BRANCH
        BEGIN BRANCH RAM2_CE
            WIRE 3280 416 3312 416
        END BRANCH
        BEGIN BRANCH RAM2_UB
            WIRE 3280 480 3312 480
        END BRANCH
        BEGIN BRANCH RAM2_LB
            WIRE 3280 544 3312 544
        END BRANCH
        BEGIN BRANCH X_RAMDO(7:0)
            WIRE 3280 608 3312 608
            BEGIN DISPLAY 3312 608 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RAM_A(17:0)
            WIRE 3280 672 3312 672
        END BRANCH
        BEGIN BRANCH RAM2_D(15:0)
            WIRE 3280 800 3312 800
        END BRANCH
        BEGIN BRANCH RAM_PAGE(11:0)
            WIRE 2880 576 2896 576
            BEGIN DISPLAY 2880 576 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RAMDO(7:0)
            WIRE 208 432 272 432
            BEGIN DISPLAY 208 432 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH ROMDO(7:0)
            WIRE 208 368 272 368
            BEGIN DISPLAY 208 368 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH ACIADO(7:0)
            WIRE 208 560 272 560
            BEGIN DISPLAY 208 560 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH A(15:4)
            WIRE 208 304 272 304
            BEGIN DISPLAY 208 304 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RW
            WIRE 208 240 272 240
            BEGIN DISPLAY 208 240 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH VMA
            WIRE 208 176 272 176
            BEGIN DISPLAY 208 176 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH X_RAMDO(7:0)
            WIRE 208 624 272 624
            BEGIN DISPLAY 208 624 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH CPUDI(7:0)
            WIRE 656 816 832 816
            WIRE 832 816 1040 816
            BEGIN DISPLAY 832 816 ATTR Name
                ALIGNMENT SOFT-BCENTER
            END DISPLAY
        END BRANCH
        BEGIN BRANCH KEYDO(7:0)
            WIRE 208 672 272 672
            BEGIN DISPLAY 208 672 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH VDUDO(7:0)
            WIRE 208 720 272 720
            BEGIN DISPLAY 208 720 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SW3,SW2,SW1,SW0,BELL,SPARE,SCL_IN,SDA_IN
            WIRE 240 496 272 496
            WIRE 240 496 240 960
            WIRE 240 960 256 960
            BEGIN DISPLAY 256 960 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN INSTANCE XLXI_89 272 592 R0
        END INSTANCE
        BEGIN BRANCH PRRDD(7:0)
            WIRE 208 768 272 768
            BEGIN DISPLAY 208 768 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SYSCLK
            WIRE 2880 96 2896 96
            BEGIN DISPLAY 2880 96 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH TXD
            WIRE 3280 1008 3312 1008
        END BRANCH
        BEGIN BRANCH RXD
            WIRE 3280 1072 3312 1072
        END BRANCH
        BEGIN BRANCH ACIADO(7:0)
            WIRE 3280 1328 3312 1328
            BEGIN DISPLAY 3312 1328 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH KBDCLK
            WIRE 3280 2288 3312 2288
        END BRANCH
        BEGIN BRANCH KBDDAT
            WIRE 3280 2384 3312 2384
        END BRANCH
        BEGIN BRANCH KEYDO(7:0)
            WIRE 3280 2192 3312 2192
            BEGIN DISPLAY 3312 2192 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        IOMARKER 3312 672 RAM_A(17:0) R0 28
        BEGIN BRANCH RAM_WE
            WIRE 3280 96 3312 96
        END BRANCH
        IOMARKER 3312 544 RAM2_LB R0 28
        IOMARKER 3312 480 RAM2_UB R0 28
        IOMARKER 3312 416 RAM2_CE R0 28
        IOMARKER 3312 352 RAM1_LB R0 28
        IOMARKER 3312 288 RAM1_UB R0 28
        IOMARKER 3312 224 RAM1_CE R0 28
        IOMARKER 3312 160 RAM_OE R0 28
        IOMARKER 3312 96 RAM_WE R0 28
        BEGIN BRANCH RAM1_D(15:0)
            WIRE 3280 736 3312 736
        END BRANCH
        IOMARKER 3312 736 RAM1_D(15:0) R0 28
        IOMARKER 3312 800 RAM2_D(15:0) R0 28
        BEGIN INSTANCE XLXI_39 2896 832 R0
        END INSTANCE
        BEGIN BRANCH SYSCLK
            WIRE 2880 1008 2896 1008
            BEGIN DISPLAY 2880 1008 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RST_SW
            WIRE 2880 1072 2896 1072
            BEGIN DISPLAY 2880 1072 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH ACIA1
            WIRE 2880 1136 2896 1136
            BEGIN DISPLAY 2880 1136 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RW
            WIRE 2880 1200 2896 1200
            BEGIN DISPLAY 2880 1200 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH A(1:0)
            WIRE 2880 1264 2896 1264
            BEGIN DISPLAY 2880 1264 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH KEYBD
            WIRE 2864 2224 2896 2224
            BEGIN DISPLAY 2864 2224 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RW
            WIRE 2864 2288 2896 2288
            BEGIN DISPLAY 2864 2288 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH A(0)
            WIRE 2864 2352 2896 2352
            BEGIN DISPLAY 2864 2352 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RST_SW
            WIRE 2864 2160 2896 2160
            BEGIN DISPLAY 2864 2160 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SYSCLK
            WIRE 2864 2096 2896 2096
            BEGIN DISPLAY 2864 2096 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN INSTANCE XLXI_80 2896 2448 R0
        END INSTANCE
        IOMARKER 3312 1008 TXD R0 28
        IOMARKER 3312 1072 RXD R0 28
        IOMARKER 3312 2288 KBDCLK R0 28
        IOMARKER 3312 2384 KBDDAT R0 28
        BEGIN BRANCH PIXCLK
            WIRE 1952 2080 1968 2080
            BEGIN DISPLAY 1952 2080 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH A(2:0)
            WIRE 1936 2528 1968 2528
            BEGIN DISPLAY 1936 2528 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RST_SW
            WIRE 1952 2144 1968 2144
            BEGIN DISPLAY 1952 2144 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH DISPLAY
            WIRE 1952 2208 1968 2208
            BEGIN DISPLAY 1952 2208 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RW
            WIRE 1952 2272 1968 2272
            BEGIN DISPLAY 1952 2272 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SYSCLK
            WIRE 1888 192 1952 192
            WIRE 1952 192 1968 192
            WIRE 1952 192 1952 816
            WIRE 1952 816 1968 816
            BEGIN DISPLAY 1888 192 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RST_SW
            WIRE 1888 256 1936 256
            WIRE 1936 256 1968 256
            WIRE 1936 256 1936 880
            WIRE 1936 880 1968 880
            BEGIN DISPLAY 1888 256 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RW
            WIRE 1888 384 1920 384
            WIRE 1920 384 1968 384
            WIRE 1920 384 1920 1008
            WIRE 1920 1008 1968 1008
            BEGIN DISPLAY 1888 384 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH A(12:0)
            WIRE 1888 448 1904 448
            WIRE 1904 448 1968 448
            WIRE 1904 448 1904 1072
            WIRE 1904 1072 1968 1072
            BEGIN DISPLAY 1888 448 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH ROM
            WIRE 1888 320 1968 320
            BEGIN DISPLAY 1888 320 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH INT_RAM
            WIRE 1888 944 1968 944
            BEGIN DISPLAY 1888 944 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH VDUDO(7:0)
            WIRE 2352 2464 2384 2464
            BEGIN DISPLAY 2384 2464 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH R
            WIRE 2352 2080 2384 2080
        END BRANCH
        BEGIN BRANCH G
            WIRE 2352 2144 2384 2144
        END BRANCH
        BEGIN BRANCH B
            WIRE 2352 2208 2384 2208
        END BRANCH
        BEGIN BRANCH HS
            WIRE 2352 2272 2384 2272
        END BRANCH
        BEGIN BRANCH VS
            WIRE 2352 2336 2384 2336
        END BRANCH
        BEGIN BRANCH ROMDO(7:0)
            WIRE 2352 192 2384 192
            BEGIN DISPLAY 2384 192 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RAMDO(7:0)
            WIRE 2352 816 2384 816
            BEGIN DISPLAY 2384 816 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN INSTANCE XLXI_86 1920 2496 R0
        END INSTANCE
        BEGIN INSTANCE XLXI_23 1968 1168 R0
        END INSTANCE
        BEGIN INSTANCE XLXI_85 1968 544 R0
        END INSTANCE
        IOMARKER 2384 2336 VS R0 28
        IOMARKER 2384 2272 HS R0 28
        IOMARKER 2384 2208 B R0 28
        IOMARKER 2384 2144 G R0 28
        IOMARKER 2384 2080 R R0 28
        BEGIN BRANCH SYSREG
            WIRE 656 368 688 368
            BEGIN DISPLAY 688 368 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH INT_RAM
            WIRE 656 272 688 272
            BEGIN DISPLAY 688 272 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH ROM
            WIRE 656 176 688 176
            BEGIN DISPLAY 688 176 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH EXT_RAM
            WIRE 656 320 688 320
            BEGIN DISPLAY 688 320 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH ACIA1
            WIRE 656 224 688 224
            BEGIN DISPLAY 688 224 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH DMAREGS
            WIRE 656 416 688 416
            BEGIN DISPLAY 688 416 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH KEYBD
            WIRE 656 464 688 464
            BEGIN DISPLAY 688 464 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH PRRD
            WIRE 656 512 688 512
            BEGIN DISPLAY 688 512 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH DISPLAY
            WIRE 656 560 688 560
            BEGIN DISPLAY 688 560 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RW
            WIRE 1424 368 1456 368
            BEGIN DISPLAY 1456 368 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH A(15:0)
            WIRE 1424 656 1456 656
            BEGIN DISPLAY 1456 656 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH VMA
            WIRE 1424 512 1456 512
            BEGIN DISPLAY 1456 512 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH LO
            WIRE 1008 496 1008 560
            WIRE 1008 560 1008 624
            WIRE 1008 624 1008 688
            WIRE 1008 688 1008 752
            WIRE 1008 752 1040 752
            WIRE 1008 752 1008 848
            WIRE 1008 688 1040 688
            WIRE 1008 624 1040 624
            WIRE 1008 560 1040 560
            WIRE 1008 496 1040 496
        END BRANCH
        BEGIN BRANCH RST_SW
            WIRE 1024 432 1040 432
            BEGIN DISPLAY 1024 432 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SYSCLK
            WIRE 1008 368 1040 368
            BEGIN DISPLAY 1008 368 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN INSTANCE XLXI_15 1040 848 R0
        END INSTANCE
        BEGIN BRANCH PRRD
            WIRE 240 1264 272 1264
            BEGIN DISPLAY 240 1264 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RW
            WIRE 240 1328 272 1328
            BEGIN DISPLAY 240 1328 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH DIN
            WIRE 240 1392 272 1392
        END BRANCH
        BEGIN BRANCH A(1:0)
            WIRE 240 1456 272 1456
            BEGIN DISPLAY 240 1456 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH CCLK
            WIRE 656 1136 688 1136
        END BRANCH
        BEGIN BRANCH RSTPROM
            WIRE 656 1296 688 1296
        END BRANCH
        BEGIN BRANCH PRRDD(7:0)
            WIRE 656 1456 688 1456
            BEGIN DISPLAY 688 1456 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RST_SW
            WIRE 240 1200 272 1200
            BEGIN DISPLAY 240 1200 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SYSCLK
            WIRE 240 1136 272 1136
            BEGIN DISPLAY 240 1136 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN INSTANCE XLXI_87 272 1488 R0
        END INSTANCE
        IOMARKER 688 1296 RSTPROM R0 28
        IOMARKER 688 1136 CCLK R0 28
        IOMARKER 240 1392 DIN R180 28
        INSTANCE XLXI_163 944 976 R0
        BEGIN BRANCH CPUDO(7:0)
            WIRE 1424 784 1552 784
            WIRE 1552 784 1744 784
            WIRE 1744 784 1744 1136
            WIRE 1744 1136 1968 1136
            WIRE 1744 1136 1744 1280
            WIRE 1744 1280 2640 1280
            WIRE 2640 1280 2640 1328
            WIRE 2640 1328 2896 1328
            WIRE 2640 1328 2640 1952
            WIRE 2640 1952 2640 2416
            WIRE 2640 2416 2896 2416
            WIRE 1744 1280 1744 1872
            WIRE 1744 1872 1744 2400
            WIRE 1744 2400 1968 2400
            WIRE 1744 1872 1968 1872
            WIRE 1744 512 1968 512
            WIRE 1744 512 1744 784
            WIRE 2640 704 2896 704
            WIRE 2640 704 2640 1280
            BEGIN DISPLAY 1552 784 ATTR Name
                ALIGNMENT SOFT-BCENTER
            END DISPLAY
        END BRANCH
        BEGIN INSTANCE XLXI_170 2896 1552 R0
        END INSTANCE
        BEGIN INSTANCE XLXI_169 1936 1776 R0
        END INSTANCE
        BEGIN BRANCH SYSREG
            WIRE 1936 1808 1968 1808
            BEGIN DISPLAY 1936 1808 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RST_SW
            WIRE 1936 1616 1968 1616
            BEGIN DISPLAY 1936 1616 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH A(0)
            WIRE 1936 1552 1968 1552
            BEGIN DISPLAY 1936 1552 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH DMAREGS
            WIRE 1936 1744 1968 1744
            BEGIN DISPLAY 1936 1744 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RW
            WIRE 1936 1488 1968 1488
            BEGIN DISPLAY 1936 1488 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SYSCLK
            WIRE 1936 1424 1968 1424
            BEGIN DISPLAY 1936 1424 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH RAM_PAGE(11:0)
            WIRE 2352 1808 2384 1808
            BEGIN DISPLAY 2384 1808 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SDA_OUT
            WIRE 2352 1616 2384 1616
            BEGIN DISPLAY 2384 1616 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SCL_OUT
            WIRE 2352 1552 2384 1552
            BEGIN DISPLAY 2384 1552 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SPARE
            WIRE 2352 1488 2384 1488
            BEGIN DISPLAY 2384 1488 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH BELL
            WIRE 2352 1424 2384 1424
            BEGIN DISPLAY 2384 1424 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN INSTANCE XLXI_185 176 2768 R0
        END INSTANCE
        BEGIN BRANCH CLK50M
            WIRE 144 2608 176 2608
        END BRANCH
        BEGIN BRANCH PIXCLK
            WIRE 560 2608 592 2608
            BEGIN DISPLAY 592 2608 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SYSCLK
            WIRE 560 2672 592 2672
            BEGIN DISPLAY 592 2672 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        IOMARKER 144 2608 CLK50M R180 28
        BEGIN BRANCH RST_SW
            WIRE 176 2192 208 2192
            BEGIN DISPLAY 208 2192 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SW3
            WIRE 128 2256 208 2256
            BEGIN DISPLAY 208 2256 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SW2
            WIRE 128 2320 208 2320
            BEGIN DISPLAY 208 2320 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SW1
            WIRE 128 2384 208 2384
            BEGIN DISPLAY 208 2384 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SW0
            WIRE 128 2448 208 2448
            BEGIN DISPLAY 208 2448 ATTR Name
                ALIGNMENT SOFT-LEFT
            END DISPLAY
        END BRANCH
        IOMARKER 176 2192 RST_SW R180 28
        IOMARKER 128 2256 SW3 R180 28
        IOMARKER 128 2320 SW2 R180 28
        IOMARKER 128 2384 SW1 R180 28
        IOMARKER 128 2448 SW0 R180 28
        INSTANCE XLXI_174 944 2528 R0
        INSTANCE XLXI_173 944 2288 R0
        BEGIN BRANCH SDA_OUT
            WIRE 768 2160 848 2160
            WIRE 848 2160 944 2160
            WIRE 848 2096 848 2160
            WIRE 848 2096 944 2096
            BEGIN DISPLAY 768 2160 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SCL_OUT
            WIRE 768 2400 848 2400
            WIRE 848 2400 944 2400
            WIRE 848 2336 944 2336
            WIRE 848 2336 848 2400
            BEGIN DISPLAY 768 2400 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SDA_PAD
            WIRE 1168 2160 1248 2160
        END BRANCH
        BEGIN BRANCH SCL_PAD
            WIRE 1168 2400 1184 2400
            WIRE 1184 2400 1248 2400
        END BRANCH
        BEGIN BRANCH SCL_IN
            WIRE 768 2464 944 2464
            BEGIN DISPLAY 768 2464 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH SDA_IN
            WIRE 768 2224 944 2224
            BEGIN DISPLAY 768 2224 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        INSTANCE XLXI_159 944 2592 R0
        BEGIN BRANCH VMA
            WIRE 912 2560 944 2560
            BEGIN DISPLAY 912 2560 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH PROBE
            WIRE 1168 2560 1200 2560
        END BRANCH
        INSTANCE XLXI_179 944 2704 R0
        BEGIN BRANCH BELL
            WIRE 912 2672 944 2672
            BEGIN DISPLAY 912 2672 ATTR Name
                ALIGNMENT SOFT-RIGHT
            END DISPLAY
        END BRANCH
        BEGIN BRANCH BELL_PAD
            WIRE 1168 2672 1200 2672
        END BRANCH
        IOMARKER 1248 2160 SDA_PAD R0 28
        IOMARKER 1200 2560 PROBE R0 28
        IOMARKER 1248 2400 SCL_PAD R0 28
        IOMARKER 1200 2672 BELL_PAD R0 28
        BEGIN INSTANCE XLXI_187 3600 2800 R0
        END INSTANCE
    END SHEET
END SCHEMATIC
