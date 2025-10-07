# Morse Micro 6108
Compiling instructions for kernel, MM6108 driver and patches with CM5 or RPi5

## 1. Prepare and configure the Kernel Source

Define your woking directory: `WORKING_DIR="/home/rak"`

Clone and checkout kernel 6.6:

```
cd $WORKING_DIR
sudo apt install git bc bison flex libssl-dev make libncurses-dev -y
git clone --depth=1 --branch rpi-6.6.y https://github.com/raspberrypi/linux
cd linux
make -j$(nproc) KERNEL=kernel_2712 bcm2712_defconfig
```
Now, you can customise what features you want in your kernel. Do this by running:

```
cd $WORKING_DIR
cd linux
vi .config # Enable CONFIG_CRYPTO_CCM=y and CONFIG_CRYPTO_GCM=y
make -j$(nproc) KERNEL=kernel_2712 menuconfig
```

## 2. Extract the Morse Micro Driver
Extract the driver archive:

```
cd $WORKING_DIR
curl -L -O https://github.com/bsantunes/MM6108_RPi5_CM5/raw/refs/heads/main/morsemicro_driver_rel_1_12_4_2024_Jun_11.zip
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

**Option 1:** Use `menuconfig`:
Run:

```
cd $WORKING_DIR
cd linux
make -j$(nproc) KERNEL=kernel_2712 menuconfig
```
Navigate to:

`Device Drivers -> Network device support -> Wireless LAN`

Enable:

`Morse Micro wireless LAN support` as `M` (module) for `CONFIG_WLAN_VENDOR_MORSE=m`.

`Morse Micro SDIO support` for `CONFIG_MORSE_SDIO=y`.

`Morse Micro user access support` for `CONFIG_MORSE_USER_ACCESS=y`.

`Morse Micro vendor command support` for `CONFIG_MORSE_VENDOR_COMMAND=y`. 

**Option 2:** Manually edit `.config`:

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

Finally, ensure wireless dependencies are enabled sincet the Morse driver depends on cfg80211 and mac80211.

Ensure these are enabled:
```
CONFIG_CFG80211=m
CONFIG_MAC80211=m
```
If they’re set to y (built-in), you may need to set CONFIG_WLAN_VENDOR_MORSE=y instead of m, but m is preferred for modules. Use menuconfig to confirm:

`Networking support -> Wireless -> cfg80211 - wireless configuration API`

`Networking support -> Wireless -> Generic IEEE 802.11 Networking Stack (mac80211)`

Save and exit.

## 6. Apply Kernel Patches
```
cd $WORKING_DIR
curl -L -O https://github.com/bsantunes/MM6108_RPi5_CM5/raw/refs/heads/main/Patches_6.6.x.zip
unzip Patches_6.6.x.zip
cat 6.6.x/*.patch | patch -g0 -p1 -E -d linux/
```

## 7. Build the Kernel and Driver
Build the modules and kernel:

```
cd $WORKING_DIR
cd linux
make -j$(nproc) KERNEL=kernel_2712 Image.gz modules dtbs
```

Install the kernel

```
cd $WORKING_DIR
cd linux
sudo make -j$(nproc) KERNEL=kernel_2712 modules_install
KERNEL=kernel_2712
sudo cp /boot/firmware/$KERNEL.img /boot/firmware/$KERNEL-backup.img
sudo cp arch/arm64/boot/Image.gz /boot/firmware/$KERNEL.img
sudo cp arch/arm64/boot/dts/broadcom/*.dtb /boot/firmware/
sudo cp arch/arm64/boot/dts/overlays/*.dtb* /boot/firmware/overlays/
sudo cp arch/arm64/boot/dts/overlays/README /boot/firmware/overlays/
```

Now reboot the board

## 8. Install Morse Micro tools
Download and run the deb install script

```
cd $WORKING_DIR
curl -L -O https://raw.githubusercontent.com/bsantunes/MM6108_RPi5_CM5/refs/heads/main/install_deb_morse.sh
chmod +x install_deb_morse.sh
./install_deb_morse.sh
```

## 9. Run wpa\_supplicant\_s1g
Download and run wifi-connect script

```
curl -L -O https://raw.githubusercontent.com/bsantunes/MM6108_RPi5_CM5/refs/heads/main/wifi-connect.sh
chmod +x wifi-connect.sh
curl -L -O https://raw.githubusercontent.com/bsantunes/MM6108_RPi5_CM5/refs/heads/main/wpa_supplicant_eu.conf
./wifi-connect.sh wlan1 wpa_supplicant_eu.conf
```
or use US regulatory domain

```
curl -L -O https://raw.githubusercontent.com/bsantunes/MM6108_RPi5_CM5/refs/heads/main/wifi-connect.sh
chmod +x wifi-connect.sh
curl -L -O https://raw.githubusercontent.com/bsantunes/MM6108_RPi5_CM5/refs/heads/main/wpa_supplicant_us.conf
./wifi-connect.sh wlan1 wpa_supplicant_us.conf
```
