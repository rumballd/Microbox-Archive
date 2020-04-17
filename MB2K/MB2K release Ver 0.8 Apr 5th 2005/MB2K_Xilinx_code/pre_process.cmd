setMode -pff
setSubmode -pffserial
setAttribute -configdevice -attr name -value "PFFConfigDevice"
setAttribute -configdevice -attr size -value "0"
addCollection -name "MB2K"
setAttribute -collection -attr dir -value "UP"
addDesign -version 0 -name "0000"
addDeviceChain -index 0
addDevice -position 1 -file "mb2k.bit"
setMode -pff
setAttribute -configdevice -attr fillValue -value "FF"
setAttribute -configdevice -attr fileFormat -value "mcs"
setAttribute -collection -attr dir -value "UP"
setAttribute -collection -attr name -value "MB2K"
generate -generic
quit


