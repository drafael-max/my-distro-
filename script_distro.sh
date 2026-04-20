#Step 1: Create the Codespace

#Step 2: Install dependencies
#This command updates the package list in the repositories to ensure that we install the latest versions of the tools.
sudo apt update

#What is each package for?
gcc, make #To compile the kernel and BusyBox
libncurses-dev #For the settings menus
flex, bison, bc #Required by the kernel build
cpio #To create the initramfs file system
libelf-dev, libssl-dev #Kernel security dependencies
syslinux #The boot manager
dosfstools #To create the FAT file system
qemu-system-x86 #To test the image without real hardware

sudo apt install -y git vim make gcc libncurses-dev flex bison bc \
cpio libelf-dev libssl-dev syslinux dosfstools qemu-system-x86

#Step 3: Compile the Linux kernel
#Download the Linux kernel source code using a shallow clone to save time and space
git clone --depth 1 https://github.com/torvalds/linux.git
cd linux

#Open the interactive configuration menu and ensure '64-bit kernel' is selected
make menuconfig

#The make -j 2 command starts the compilation process of the source code.
#The -j 2 flag allows the system to use 2 CPU cores simultaneously, which speeds up the build process significantly.
make -j 2

#Creates the main workspace directory to store the distribution's components.
sudo mkdir /boot-files

#Copies the compiled Linux kernel (the "engine" of the OS) to the workspace.
sudo cp arch/x86/boot/bzImage /boot-files/

#Exits the kernel source directory to return to the main project folder.
cd ..

#Step 4: Compile BusyBox
#Downloads the BusyBox source code using a shallow clone to save space.
git clone --depth 1 https://git.busybox.net/busybox

#Changes the current directory to the busybox folder.
cd busybox

#We configured the busybox.
make menuconfig 

#This command starts the compilation of BusyBox using 2 CPU cores to speed up the process
make -j 2

#Creates the destination directory for the initial RAM filesystem
sudo mkdir -p /boot-files/initramfs

#Installs BusyBox and creates the basic directory structure (bin, sbin, usr) inside the initramfs folder
sudo make CONFIG_PREFIX=/boot-files/initramfs install

#Step 5: Create the initramfs
#Change to the /boot-files/initramfs directory.
cd /boot-files/initramfs

#Open (or create) the init file with the Vi editor with administrator privileges.
sudo vi init

#It tells the Kernel that this file should be read using the command interpreter (Shell).
#!/bin/sh

#It is the command that opens the terminal
/bin/sh

#Removes the default linuxrc file to avoid conflicts with our custom init script.
sudo rm linuxrc

#Grants execution permissions to the init script.
sudo chmod +x init

#Create an init.cpio file containing all the files in the current directory:
#find .:lists files
#cpio -o -H newc: packages them in cpio format
#> ../init.cpio: saves the file in the parent directory
sudo find . | cpio -o -H newc > ../init.cpio

#Go up to the parent directory (one level up).
cd ..

#Step 6: Create the boot image
#Switch to the root (administrator) user with full privileges.
sudo su

#Creates a 50MB empty file named 'boot' to act as a virtual disk image.
dd if=/dev/zero of=boot bs=1M count=50

#Formats the virtual disk image with a FAT filesystem, compatible with the bootloader.
mkfs -t fat boot

#Installs the Syslinux bootloader onto the disk image to make it bootable.
syslinux boot

#Create a directory called m.
mkdir m

#Mounts the virtual disk image into the 'm' directory to allow file copying.
mount boot m

#Copies the Linux Kernel and the initramfs package into the virtual disk.
cp bzImage init.cpio m

#Unmounts the image to finalize changes and ensure data is correctly written.
umount m

#Step 7: Try with QEMU
#qemu-system-x86_64	"Initiates the hardware emulator for the x86_64 architecture."
#-nographic	"Command to run QEMU without a GUI, using the current terminal for I/O."
#-append "console=ttyS0" "Kernel parameter that redirects all boot messages to the first serial port."
#-kernel bzImage "Directs QEMU to use the custom-compiled Linux kernel image."
#-initrd init.cpio	"Loads the initial RAM disk containing our root filesystem into memory."
#-drive file=boot,format=raw	"Attaches the 50MB virtual disk as a raw storage device to the system."

qemu-system-x86_64 -nographic -append "console=ttyS0" \
 -kernel bzImage -initrd init.cpio -drive file=boot,format=raw

#Exit the qemu
#We press ctrl + a and then we press x

