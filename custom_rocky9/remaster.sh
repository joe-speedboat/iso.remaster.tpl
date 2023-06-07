#!/bin/bash

PROJ=custom_rocky9
PROJ_NAME="INSTALL CUSTOM Rocky 9 OS"
BASE_DIR=/srv/remaster.tpl
ISO=Rocky-9.2-x86_64-minimal.iso

cd $BASE_DIR/$PROJ || (echo project dir not found ; exit 1)
test -f $BASE_DIR/$PROJ/inject/ks-$PROJ.cfg || ( echo kickstart not found ; exit 1)
test -f $BASE_DIR/$PROJ/inject/ks_efi-$PROJ.cfg || ( echo kickstart not found ; exit 1)

umount -fl $BASE_DIR/$PROJ/iso-mount/ || true
test -f $BASE_DIR/iso/$ISO || bash $BASE_DIR/iso/download_iso.sh
mount -o loop $BASE_DIR/iso/$ISO $BASE_DIR/$PROJ/iso-mount/

echo ROCKY REMASTER SCRIPT
echo have you reviewed and modified scripts as needed, press enter or ctrl-c

ls -l $BASE_DIR/$PROJ/inject/*

read x

rm -fr iso-remaster 
mkdir iso-remaster

shopt -s dotglob
cp -avRf iso-mount/* iso-remaster/
rsync -av inject iso-remaster/

ISO_NAME="$(cat iso-remaster/EFI/BOOT/grub.cfg | grep no-floppy | cut -d\' -f2)"
#old: sed -i "/^menuentry /i menuentry '$PROJ_NAME' --class fedora --class gnu-linux --class gnu --class os {\n        linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=$ISO_NAME inst.ks=cdrom:/inject/ks-$PROJ.cfg\n        initrdefi /images/pxeboot/initrd.img\n}\n" iso-remaster/EFI/BOOT/grub.cfg
awk -v proj="$PROJ_NAME" -v iso="$ISO_NAME" -v proj_cfg="$PROJ" 'flag==0 && /^menuentry / {print "menuentry '\''"proj"'\'' --class fedora --class gnu-linux --class gnu --class os {\n        linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=''"iso"'' inst.ks=cdrom:/inject/ks_efi-''"proj_cfg"''.cfg\n        initrdefi /images/pxeboot/initrd.img\n}\n"; print; flag=1; next} 1' iso-remaster/EFI/BOOT/grub.cfg > temp && mv -f temp iso-remaster/EFI/BOOT/grub.cfg

sed -i "/^label linux/i label linux-$PROJ\n  menu label ^$PROJ_NAME\n  kernel vmlinuz\n  append initrd=initrd.img inst.stage2=hd:LABEL=$ISO_NAME inst.ks=cdrom:/inject/ks-$PROJ.cfg\n" iso-remaster/isolinux/isolinux.cfg


cd $BASE_DIR/$PROJ/iso-remaster
mkisofs -o ../iso-result/remastered-$PROJ-$(date +%Y%m%d).iso -b isolinux/isolinux.bin -J -R -l -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e images/efiboot.img -no-emul-boot -graft-points -joliet-long -V "$ISO_NAME" .

isohybrid --uefi ../iso-result/remastered-$PROJ-$(date +%Y%m%d).iso
implantisomd5 ../iso-result/remastered-$PROJ-$(date +%Y%m%d).iso


ls -altrh $BASE_DIR/$PROJ/iso-result/*
umount -fl $BASE_DIR/$PROJ/iso-mount/ || true
echo done
