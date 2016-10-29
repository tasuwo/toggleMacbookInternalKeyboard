#!/bin/sh

IS_CONNECTED=`ioreg -p IOUSB -w0 | sed 's/[^o]*o //; s/@.*$//' | grep -v '^Root.*' | grep "USB Keyboard"`
IS_LOADED=`kextstat -a | grep AppleUSBTCKeyboard`
if [ -n "${IS_CONNECTED}" ]; then
    if [ -n "${IS_LOADED}" ]; then
        `echo "your password" | sudo -S kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/`
        `open /usr/local/bin/notifyDisableInternalKeyboard.app`
    fi
else
    if [ -z "${IS_LOADED}" ]; then
        `echo "your passowrd" | sudo -S kextload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/`
        `open /usr/local/bin/notifyEnableInternalKeyboard.app`
   fi
fi
