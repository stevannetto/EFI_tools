#! /bin/sh

################################################################
# Automated OpenCore EFI boot partition updater.
# Written by Stevan Netto - github.com/stevannetto/EFI_tools
################################################################

TMP_DIR="/tmp/EFIUpdater"
EFI_PARTITION="/dev/disk0s1"
EFI_MOUNTPOINT="/Volumes/EFI"
EFI_BACKUP_FILE="${EFI_MOUNTPOINT}/EFI_BACKUP.tgz"

OC_CONFIG="EFI/OC/config.plist"
OC_BOOT="EFI/BOOT/BOOTx64.efi"
OC_LOADER="EFI/OC/OpenCore.efi"

# Some sanity checks before we proceed.
if [ "$EUID" -ne 0 ]; then
    echo "This can only be run as root"
    exit
fi

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <EFI_file_to_be_updated.tgz>"
    exit
fi

if [[ ! -f $1 ]]; then
    echo "$1 doesn't seem to exist."
    exit
fi

if [[ ! -d $EFI_MOUNTPOINT ]]; then
    mkdir $EFI_MOUNTPOINT
fi

# Mount the EFI partition
mount -t msdos $EFI_PARTITION $EFI_MOUNTPOINT
if [[ ! -f "${EFI_MOUNTPOINT}/${OC_CONFIG}" ]]; then
    echo "Failed to mount EFI partition or EFI isn't an OpenCore boot partition."
    exit
fi

if [[ ! -d $TMP_DIR ]]; then
    mkdir -p $TMP_DIR
    if [[ ! -d $TMP_DIR ]]; then
        echo "Can't create a temporary dir to extract the EFI file in $TMP_DIR"
        echo "Operation aborted."
        exit
    fi
else
    if [[ -d "${TMP_DIR}/EFI" ]]; then
        echo "Removing temporary EFI dir from a previous run"
        rm -rf "${TMP_DIR}/EFI"
    fi
fi


# Extract the new EFI contents to a temporary dir
tar -zxf $1 -C $TMP_DIR
if [[ ! -f "${TMP_DIR}/${OC_CONFIG}" ]] || [[ ! -f "${TMP_DIR}/${OC_LOADER}" ]]|| [[ ! -f "${TMP_DIR}/${OC_BOOT}" ]]; then
    echo "The specifyed EFI file doesn't seem to be correctly structured. Aborting operation."
    exit
fi

if [[ -f "$EFI_BACKUP_FILE" ]]; then
    echo "Found a EFI backup file from a previous run of updateEFI. Moving it to ${HOME}"
    mv $EFI_MACKUP_FILE $HOME
fi

tar -czf $EFI_BACKUP_FILE -C $EFI_MOUNTPOINT "EFI/BOOT" "EFI/OC" 
echo "A backup of your current EFI/BOOT and EFI/OC has been saved in ${EFI_BACKUP_FILE}"
rm -rf "${EFI_MOUNTPOINT}/BOOT ${EFI_MOUNTPOINT}/OC"
cp -RP "${TMP_DIR}/EFI/BOOT" "${EFI_MOUNTPOINT}/EFI/"
cp -RP "${TMP_DIR}/EFI/OC" "${EFI_MOUNTPOINT}/EFI/"

diskutil umount /Volumes/EFI
echo "Operation completed."

