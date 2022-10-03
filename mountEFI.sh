#! /bin/sh
if [ "$EUID" -ne 0 ]
    then
    echo "This can only be run as root"
    exit 1
fi

if [[ ! -d /Volumes/EFI ]]
    then
        mkdir /Volumes/EFI
fi
mount -t msdos /dev/disk0s1 /Volumes/EFI
if [ $? -ne 0 ]
    then
    echo "Failed to mount EFI partition"
    exit 1
else
    if [[ ! -d /Volumes/EFI/EFI ]]
    then
        echo "Partition doesn't look like an EFI system. Unmounting it."
        diskutil umount /Volumes/EFI
        exit 1
    fi
    echo "EFI partition mounted in /Volumes/EFI/"
fi
