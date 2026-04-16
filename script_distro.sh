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

Kernel: arch/x86/boot/bzImage is ready  (#1)