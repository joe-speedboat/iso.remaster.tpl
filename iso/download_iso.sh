#!/bin/bash

cd $(dirname $0)
ISO_URL='https://download.rockylinux.org/pub/rocky/9/isos/x86_64/Rocky-9.2-x86_64-minimal.iso'
ISO_FILE=$(echo $ISO_URL | rev | cut -d/ -f1 | rev)
test -f $ISO_FILE && rm -fv $ISO_FILE
wget $ISO_URL
