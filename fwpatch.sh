#!/bin/sh

unzip -j iPhone3,1_7.1.2_11D257_Restore.ipsw \
    kernelcache.release.n90 \
    Firmware/dfu/iBEC.n90ap.RELEASE.dfu \
    Firmware/dfu/iBSS.n90ap.RELEASE.dfu \
    Firmware/all_flash/all_flash.n90ap.production/DeviceTree.n90ap.img3

# Decrypt the DeviceTree
xpwntool DeviceTree.n90ap.img3 DeviceTree.n90ap.img3.dec \
    -iv d2f224a2d7e04461ec12ac81f91d657a \
    -k b93c3a564dc36e184871e246fa8df725ecebafb38c042b6302b333c39e7d1787 \
    -decrypt

# Decrypt the kernel:
xpwntool kernelcache.release.n90 kernelcache.release.n90.dec \
    -iv a1aee41423e11a44135233dd345433ce \
    -k 9b05ef79c63c59e71f253219ffaa952f25f6810d3863aac2b49628e64f9f0869 \
    -decrypt

# Extract and patch iBSS
xpwntool iBSS.n90ap.RELEASE.dfu iBSS.n90ap.RELEASE.dec \
    -iv a5854328e525031dc205d6e476a8b1bb \
    -k 23dda7990807b4225d589dc11099a4a8bd122089b93759d6356e9525f986584c
iboot_patcher iBSS.n90ap.RELEASE.dec iBSS.n90ap.RELEASE.pwn

# Extract, patch and repack iBEC
xpwntool iBEC.n90ap.RELEASE.dfu iBEC.n90ap.RELEASE.dec \
    -iv ca528426065da305c19476477a39ed18 \
    -k 3273904a1cfd111a20d6a53f2636902db1193dad5f0acf3837dd7c79fb3b795f
iboot_patcher iBEC.n90ap.RELEASE.dec iBEC.n90ap.RELEASE.patched

#Add header back to iBEC
xpwntool iBEC.n90ap.RELEASE.patched iBEC.n90ap.RELEASE.pwn \
    -t iBEC.n90ap.RLEASE.dfu

# Create batchfile for irecovery:
cat <<EOF > bootstrap.irs
/send DeviceTree.n90ap.img3.dec
devicetree
/send kernelcache.release.n90.dec
bootx
/exit
EOF
