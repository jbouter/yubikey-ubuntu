# Yubikey on Ubuntu (KDE Neon) 18.04

**BEFORE YOU START: IT IS HIGHLY RECOMMENDED TO HAVE A BACK-UP YUBIKEY**

My setup is specific to my desires/needs/wants. Feel free to copy.

Basic idea of my setup:

* Require password + Yubikey for all login sessions (TTY, sddm, gdm, lock screen)
* Require **only** yubikey for sudo

All files mentioned below are included in full in the `files` directory within this repository

## Installation
Following the [regular installation](https://support.yubico.com/support/solutions/articles/15000011356-ubuntu-linux-login-guide-u2f)

Add the ppa:
```bash
sudo add-apt-repository ppa:yubico/stable && sudo apt update
```

Add the package:
```bash
apt install libpam-u2f
```

Configure yubikey for your account according to the [installation manual]()

For more packages (such as OTP), see [here](https://support.yubico.com/support/solutions/articles/15000010964-enabling-the-yubico-ppa-on-ubuntu)

## pam.d configuration
My setup is specific to my desires/needs/wants. Feel free to copy

### All logins
In order to require password + yubikey for all my logins, I've modified `/etc/pam.d/common-auth`. At the bottom of the file, add:
```
# u2f
auth required pam_u2f.so cue
```

### Sudo specific
In order to only require yubikey for sudo, I've modified `/etc/pam.d/sudo`. I've commented out `@include common-auth` because I don't want the pam_u2f requirement, and have added the yubikey line. It looks as follows:

```
#@include common-auth
auth   sufficient pam_u2f.so cue
```

Obviously, leave the rest of the file untouched.


## udev.d configuration
Sources:

* [0day.work](https://0day.work/locking-the-screen-when-removing-a-yubikey/)

I also wanted to lock my screen the moment my yubikey is removed from the USB port. To do this, I've created udev rules.

The udev rule in `/etc/udev/rules.d/20-yubico-u2f.rules`:
```
ACTION=="remove", ENV{ID_BUS}=="usb", ENV{ID_MODEL_ID}=="0407", ENV{ID_VENDOR_ID}=="1050", RUN+="/usr/local/sbin/lockscreen.sh"
```

Check your `MODEL_ID` and `VENDOR_ID` by running `udevadm monitor --environment --udev` and unplugging your yubikey. 

Then, create `/usr/local/sbin/lockscreen.sh` where `$username` is your own username:

```bash
#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin

loginctl lock-sessions
```

Mark the script as executable:
```bash
chmod 755 /usr/local/sbin/lockscreen.sh
```

Check that the script works by running it (either as root as your own user. udev RUN commands are executed by root, so it should work as root).

If everything works as desired, let's reload udev: 

```bash
sudo udevadm control --reload-rules
```
