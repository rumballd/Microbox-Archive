05/05/2025

This folder contain information about a IDE interface that can be used in place of the original MB2 eprom disk.

Zip file is ready for pcb manufacturing. The bom is simple :

    2x20 IDE connector
    1x26 SK7 connector
    74LS04
    C1 100 nF
    C2 220 µF / 16 V
    one 3x jumper header.

With the jumper you can connect pin 20 of ide connector to +5 V or to 0 V. Usually pin 20 is removed from most IDE device but some adapter (not all) can be powered by this way.

In case of external power supply of the CF adapter or the IDE device be careful with this jumper.

This interface has been tested with a Compact Flash boards adapter and with a master and a slave board.

In order to use this board you need a modified monitor (see Monitor).

At boot the CF are automagically detected and initialized. The monitor display what is found.

WARNING : CF are detected even without a suitable Flex file system. Of course in this case nothing good can happen !

The detection routine need a timeout so the monitor need time to come on screen especially if there is no Compact Flash connected.

The eprom and ram disk routines has been removed. With this monitor you cant use these devices.

"Ascii dump" command is also removed and "Hex dump" command has been improved to have hex and ascii display at the same time.

Master CF is disk typ $02 and slave CF is disk typ $03 in RTC table.

For example to have :

    master CF as Flex disk 0
    floppy as Flex disk 1
    slave CF as Flex disk 2
    nothing as Flex disk 3

put 02-00-03-FF into RTC table at address $10.

Anyway even if you ask about a CF as a disk somewhere but that the monitor dont detect it at boot it will be not be used. Accessing this disk under Flex simply give an error.

Slave CF will not be detected if no master CF present.

Last be not least :
- The Flex disk geometry for CF is -HARDCODED- into the monitor to 256 sectors per track.
- Track number can be increased up to 255 without modification, the number of tracks is read from the SIR.

You can find here an empty image with 122 tracks that can be used with Linux dd to set the file system on CF. Put it on the DEVICE (fe /dev/sdb), not into a partition. This image can be used with Michael Evenson 'FloppyMaintenance'.

Please report any problem you get with this system. I will try to help.

Have fun !

Philippe

Ps 1 : !!! I have not do test with different device that Compact Flash card !!!

Ps 2 : RTC default table in this monitor is different from the original monitor. Gdc timing is suitable for a lcd tv with composite video input and serial speed is set to 19200 baud.

