# AHM26108D
Compiling instructions for kernel and driver on RAK 7391 with CM5

## 1. Prepare and configure the Kernel Source
Clone and checkout kernel 6.6:
```
WORKING_DIR="/home/rak"
cd $WORKING_DIR
sudo apt install git bc bison flex libssl-dev make
git clone --depth=1 --branch rpi-6.6.y https://github.com/raspberrypi/linux
cd linux
make -j$(nproc) KERNEL=kernel8 bcm2711_defconfig
make -j$(nproc) KERNEL=kernel_2712 bcm2712_defconfig
```
Now, you can customise what features you want in your kernel. Do this by running:
```
cd $WORKING_DIR
cd linux
vi .config # Enable CONFIG_CRYPTO_CCM=y and CONFIG_CRYPTO_GCM=y
make -j$(nproc) KERNEL=kernel8 menuconfig  # Add options as needed
```

## 2. Extract the Morse Micro Driver
Extract the driver archive:
```
cd $WORKING_DIR
curl -L -O https://github.com/bsantunes/AHM26108D_RAK/raw/refs/heads/main/morsemicro_driver_rel_1_12_4_2024_Jun_11.zip
unzip morsemicro_driver_rel_1_12_4_2024_Jun_11.zip
```
## 3. Integrate the Driver into the Kernel Source
Create the target directory
```
cd $WORKING_DIR
cd linux
mkdir -p drivers/net/wireless/morse
```
Copy the driver files
```
cd $WORKING_DIR
cp -r morsemicro_driver_rel_1_12_4_2024_Jun_11/* linux/drivers/net/wireless/morse/
```
## 4. Update the Kernel’s Build System
Modify the `drivers/net/wireless/` directory’s `Kconfig` and `Makefile` to include the Morse driver.
Edit `drivers/net/wireless/Kconfig`:
```
cd $WORKING_DIR
cd linux
vi drivers/net/wireless/Kconfig
```
Add the following line, preferably after other vendor-specific drivers (e.g., `ti`, `qcom`):
```
source "drivers/net/wireless/morse/Kconfig"
```
This includes the Morse driver’s `Kconfig` file, which defines `CONFIG_WLAN_VENDOR_MORSE`, `CONFIG_MORSE_SDIO`, etc.
Edit `drivers/net/wireless/Makefile`:
```
cd $WORKING_DIR
cd linux
vi drivers/net/wireless/Makefile
```
Add:
```
obj-$(CONFIG_WLAN_VENDOR_MORSE) += morse/
```
This instructs the kernel to build the `morse/` directory if `CONFIG_WLAN_VENDOR_MORSE` is enabled.
## 5. Configure the Kernel with Morse Options
Add the required configuration options to the kernel’s `.config` file.
Option 1: Use `menuconfig`:
Run:
```
cd $WORKING_DIR
cd linux
make menuconfig
```
Navigate to:

`Device Drivers -> Network device support -> Wireless LAN`

Enable:

`Morse Micro wireless LAN support` as `M` (module) for `CONFIG_WLAN_VENDOR_MORSE=m`.

`Morse Micro SDIO support` for `CONFIG_MORSE_SDIO=y`.

`Morse Micro user access support` for `CONFIG_MORSE_USER_ACCESS=y`.

`Morse Micro vendor command support` for `CONFIG_MORSE_VENDOR_COMMAND=y`. Ensure dependencies are enabled:

`Wireless LAN` -> `cfg80211` (`CONFIG_CFG80211=m` or `y`).

`Wireless LAN` -> `Generic IEEE 802.11 Networking Stack` `(mac80211)` (`CONFIG_MAC80211=m` or `y`). Save and exit.

Option 2: Manually edit `.config`:
```
cd $WORKING_DIR
cd linux
vi .config
```
Add or modify:
```
CONFIG_WLAN_VENDOR_MORSE=m
CONFIG_MORSE_SDIO=y
CONFIG_MORSE_USER_ACCESS=y
CONFIG_MORSE_VENDOR_COMMAND=y
CONFIG_CFG80211=m
CONFIG_MAC80211=m
```
Save and exit.
## 6. Apply Kernel Patches
```
cd $WORKING_DIR
curl -L -O https://github.com/bsantunes/AHM26108D_RAK/raw/refs/heads/main/morsemicro_kernel_patches_rel_1_12_4_2024_Jun_11.zip
unzip morsemicro_kernel_patches_rel_1_12_4_2024_Jun_11.zip

curl -L -O https://raw.githubusercontent.com/bsantunes/AHM26108D_RAK/refs/heads/main/0010-sdio_18v_quirk.patch
cp 0010-sdio_18v_quirk.patch  morsemicro_kernel_patches_rel_1_12_4_2024_Jun_11/6.6.x/0010-sdio_18v_quirk.patch

cat morsemicro_kernel_patches_rel_1_12_4_2024_Jun_11/6.6.x/*.patch | patch -g0 -p1 -E -d linux/


mkdir patches
cd patches
curl -L -O https://raw.githubusercontent.com/bsantunes/AHM26108D_RAK/refs/heads/main/debug.h.patch
curl -L -O https://raw.githubusercontent.com/bsantunes/AHM26108D_RAK/refs/heads/main/firmware.h.patch
curl -L -O https://raw.githubusercontent.com/bsantunes/AHM26108D_RAK/refs/heads/main/morse.h.patch
cd ..
patch -p1 < patches/debug.h.patch
patch -p1 < patches/firmware.h.patch
patch -p1 < patches/morse.h.patch
curl -L -O https://raw.githubusercontent.com/bsantunes/AHM26108D_RAK/refs/heads/main/morse_types.h
cp morse_types.h linux/drivers/net/wireless/morse/
```
## 7. Build the Kernel and Driver
Build the modules and kernel:
```
cd $WORKING_DIR
cd linux
make -j$(nproc) KERNEL=kernel8 Image.gz modules dtbs
```
Install the kernel
```
cd $WORKING_DIR
cd linux
sudo make -j$(nproc) KERNEL=kernel8 modules_install
cp /boot/firmware/$KERNEL.img /boot/firmware/$KERNEL-backup.img
cp arch/arm64/boot/Image.gz /boot/firmware/$KERNEL.img
cp arch/arm64/boot/dts/broadcom/*.dtb /boot/firmware/
cp arch/arm64/boot/dts/overlays/*.dtb* /boot/firmware/overlays/
cp arch/arm64/boot/dts/overlays/README /boot/firmware/overlays/
```
