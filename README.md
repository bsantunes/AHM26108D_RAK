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

