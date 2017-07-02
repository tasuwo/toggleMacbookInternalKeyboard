# Toggle Macbook Internal Keyboard

## WARNING: These scripts are no longer worked

`kextunload` to `AppleUSBTCKeyboard.kext` is not working.

> https://github.com/tekezo/Karabiner-Elements/issues/95#issuecomment-255989636

Instead of this repository, you can use [tekezo/Karabiner-Elements](https://github.com/tekezo/Karabiner-Elements).

## What is this?

Because Karabiner does not work on macOS Sierra, we cannot disable macbook's internal keyboard automatically at the time of external keyboard connection.
So I wrote some scripts and realize the automation.

My solution's rough procedure is as follows:

1. Prepare the script to checking the external keyboard connection
2. Launch daemon. The daemon execute above script at evely second
3. If exeternal keyboard connected, the script detect it and disable internal keyboard
4. If external keyboard disconnected, the script detect it too and enable internal keyboard

## How to use

1．Edit the script (`toggleInternalKeyboard.sh`') to insert your password

``` shell
...
if [ -n "${IS_CONNECTED}" ]; then
    if [ -n "${IS_LOADED}" ]; then
              # ↓ Here!   #
        `echo "your passowrd" | sudo -S kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/`
    fi
else
    if [ -z "${IS_LOADED}" ]; then
              # ↓ Here!   #
        `echo "your password" | sudo -S kextload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/`
   fi
fi
```

2．Move files to suitable place

``` shell
$ chmod +x toggleInternalKeyboard.sh

$ mv toggleInternalKeyboard.sh /usr/local/bin/
$ mv notifyDisableInternalKeyboard.app /usr/local/bin/
$ mv notifyEnableInternalKeyboard.app /usr/local/bin/

$ sudo mv com.example.toggleInternalKeyboard.plist /Library/LaunchDaemons/
```

3．Launch daemon

``` shell
$ sudo launchctl load -w /Library/LaunchDaemons/com.example.toggleInternalKeyboard.plist
```

If you want to unload daemon, execute the following from a terminal.

``` shell
$ sudo launchctl unload -w /Library/LaunchDaemons/com.example.toggleInternalKeyboard.plist
```

## When that does not work

### Cannot detect external keyboard connection

The script (`toggleInternalKeyboard.sh`) check an external keyboard connection by `ioreg` command. We can retrieve the list of connected USB devices by this command like the following.

``` shell
$ ioreg -p IOUSB -w0 | sed 's/[^o]*o //; s/@.*$//' | grep -v '^Root.*' 
IOUSBHostDevice
IOUSBHostDevice
IR Receiver
Apple Internal Keyboard / Trackpad
BRCM20702 Hub
Bluetooth USB Host Controller
IOUSBHostDevice
FaceTime HD Camera (Built-in)
iPhone
ThinkPad Compact USB Keyboard with TrackPoint
```

In my case, external keyboard name is `ThinkPad Compact USB Keyboard with TrackPoint`, so my script detect it's connection by grep `USB Keyboard` from the above result. But your external keyboard's display name may be different to mine.

If my script doesn' work well, you can execute `ioreg` command like above, confirm your exeternal keyboard's display name, and edit the grep portion of the script.

``` shell
...
                                                                                          #    Here!   #
IS_CONNECTED=`ioreg -p IOUSB -w0 | sed 's/[^o]*o //; s/@.*$//' | grep -v '^Root.*' | grep "USB Keyboard"` 
...
```

### Cannot disable internal keyboard

My script use `kextunload` command to disable internal keyboard. This command is introduced at [Disable Mac OS X Keyboard (built-in only)](https://gist.github.com/JohnMurray/1869020). But, this command sometimes doesn't work well.

If your internal keyboard is still enabled despite the notification, you'd better try the command as follows and check the result.

``` shell
$ sudo kextunload /System/Library/Extensions/AppleUSBTopCase.kext/Contents/PlugIns/AppleUSBTCKeyboard.kext/
(kernel) Can't unload kext com.apple.driver.AppleUSBTCKeyboard; classes have instances:
(kernel)     Kext com.apple.driver.AppleUSBTCKeyboard class AppleUSBTCKeyboard has 1 instance.
Failed to unload com.apple.driver.AppleUSBTCKeyboard - (libkern/kext) kext is in use or retained (cannot unload).
```

In above case, we get the error. I don't know the cause of this error...
But I tried restart macbook, I can disable internal keyboard without error again.
So if you get above error, you'd better restart laptop and try again.

## LICENSE

MIT
