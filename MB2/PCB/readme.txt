Design files for the new version of the MB2 PCB created by Philippe Roehr 
<ph-roehr@orange.fr>

Today (20/12/2021) the main pcb is still under test. Files can be updated if required.

Gerber_41256.zip              Gerber files from main pcb
Gerber_rom_27128              Gerber files for 27128 eprom disk pcb
Gerber_rom_27C256             Gerber files for 27256 eprom disk pcb
Gerber_rom_27C256_AT28C256    Gerber files for 27256 or AT28C256 eprom disk pcb without 27526 programming capability

This PCB is ready for double side floppy and 256 kb video ram.

MODIFICATIONS :

J1 and J2 are for ds floppy fonction. Leave J1 open and populate J2 for ds floppy. If you want use an old version of MON09 with step rate on PB6 then leave J2 open and populate J1.

J3 is for connecting SK1/17 to SK2/15 or SK1/17 to IC19/18 or both...

J4 and J5 can invert Hsync and Vsync on SK8 connector. Normal position for composite video (SK9) use is J4 2-3 and J5 1-2. If you invert Hsync and / or Vsync only SK8 can be used. Video out SK9 will not works correctly.

On SK8 +5V and PCLK has been added in case of.

IC69 is for using 41256 dram on IC47 to IC62, not required if you use 4164 dram.

Z1 and R58 are for increasing rtc disable speed at power off, protecting stored datas against crazy bus... Use 4.3 V zener + 470 R résistor.

