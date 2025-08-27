# AHM26108D
Compiling instructions for kernel and driver on RAK 7391

## 1. Prepare and configure the Kernel Source
Clone and checkout kernel 6.6:
```
WORKING_DIR="/home/rak"
cd $WORKING_DIR
git clone --depth=1 --branch rpi-6.6.y https://github.com/raspberrypi/linux
cd linux
make -j4 KERNEL=kernel8 bcm2711_defconfig
```
Now, you can customise what features you want in your kernel. Do this by running:
```
cd $WORKING_DIR
cd linux
vi .config # Enable CONFIG_CRYPTO_CCM=y and CONFIG_CRYPTO_GCM=y
make -j4 KERNEL=kernel8 menuconfig  # Add options as needed
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
