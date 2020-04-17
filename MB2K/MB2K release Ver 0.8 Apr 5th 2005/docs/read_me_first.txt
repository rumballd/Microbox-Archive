Microbox 2000 distribution 0.8  05-04-2005
-----------------------------------------

History
-------

05-04-2005	ver 0.8	First release to the outside world.




Contents
--------

This package should contain the following files and folders :-

* display char sets      - the display character set definition file and formatting tools

* docs                   - hardware data sheets and manuals including the MB2K user notes,
			   quick start guide and read_me docs. Essential bedtime reading!

* flex9 v3.01 image      - flex.cor and formatting tools

* FlexNet                - FLEXNet_421B from Michael Evenson  <www.evenson-consulting.com>

* MB2K Utilities         - a .dsk file with the MB2K specific utilities and header files

* MB2K Xilinx code       - The project folder to build the MB2K design and load it into the
			   Xilinx Spartan starter kit

* mon09 for MB2K         - the source of mon09 and formatting tools

* PROMdisk               - an example PROMdisk and formatting tools

* PS-2 keyboard mapping  - table of scan codes to ASCII for the keyboard interface and formatting tools

* floppymaint.exe        - a tools for examining and modifying Flex image .dsk files 
			   (from Michael Evenson?)

* 


	


To Do
-----
	The MB2K design is not yet complete, and because of a lack of space in the FPGA, I have had to leave out the hardware graphics subsystem and one of the serial ports. At the moment, the 6809 core is HUGE, representing >75% of the on chip resources. I hope to reduce the size of that in the near future to make room for the missing features. I also have to finish the drivers and Flex utilities for the MMC card. Lastly, the design needs to be tied down for FPGA net timing. I have looked at the net delays for the critical paths and they are not too bad, but will need to be properly specified for guaranteed operation over temperature/part spread etc.



Disclaimer
----------
	This project was undertaken entirely for fun and as such does not contain polished or shipping quality code, so use entirely at you own risk. Also as this is the first release, there may be some unknown dependences on my particular build environment. So if you have any problems with the build, find any bugs, have suggestions for features and improvements etc, send me an email :-

rumball.d@virgin.net

Have Fun!

Dave Rumball
Hinxworth, UK.  31/3/05
