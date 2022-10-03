#! /bin/sh
if [ "$EUID" -ne 0 ]
    then
    echo "This can only be run as root"
    exit
fi

if [[ ! -d /Volumes/EFI ]]
    then
        mkdir /Volumes/EFI
fi
mount -t msdos /dev/disk0s1 /Volumes/EFI
echo "EFI partition mounted in /Volumes/EFI/"
