#!/bin/bash

PROJ=custom_rocky9
PROJ_NAME="INSTALL CUSTOM Rocky 9 OS"
BASE_DIR=/srv/remaster.tpl
ISO=Rocky-9.2-x86_64-minimal.iso

cd $BASE_DIR/$PROJ || (echo project dir not found ; exit 1)

umount -fl $BASE_DIR/$PROJ/iso-mount/ || true

echo REMOVE ALL UNNEEDED FILES TO BE READY FOR GIT CHECK-IN
echo press enter or ctrl-c
read x

rm -frv iso-remaster 
mkdir iso-remaster

rm -fv $BASE_DIR/$PROJ/iso-result/*
rm -fv $BASE_DIR/iso/$ISO

echo done
