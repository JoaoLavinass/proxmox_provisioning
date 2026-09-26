# Proxmox Initialization

Proxmox VE (Virtual Environment) is a platform that allows you to run virtual machines and containers. It is based in Debian GNU/Linux distribution and opent source. In order to give full flexibility to the user, Proxmox VE provides two kinds of virtualization - kernel-based and Linux Container. 

This repository documents my journey learning Proxmox. Rather than serving as a comprehensive manual, it tracks my progress using Proxmox as a means to an end for a larger goal.

In the following sections, I will describe the setup process for installing Proxmox on my mini PC using these parameters::
- RAM Memory: 24GB LPDDR5 (Low Power Double Data Rate)
- Storge Memory: 1TB SSD
- CPU Model: AMD Ryzen 7
 
## Download the ISO image file

An ISO image file is a disk image file that behaves like an optical disk (CD, DVD...). The ISO image serves as bootable installation media used to install the Proxmox onto your hardware.

Download the appropriate Proxmox ISO installer for your machine's system architecture to your local drive.

(https://www.proxmox.com/en/downloads/proxmox-virtual-environment/iso)


## Write proxmox image into a drive

The next step is writing the Proxmox ISO image into a drive, which in my case is a pen-drive. Usually, the recommended USB size is 8GB, even though the ISo size is not more than 2GB. 

I recommend firt list all partitions, hard-drives and SSD just to make sure that your drive is available:

```lsblk -o NAME,SIZE,TRAN,MOUNTPOINTS```
You will search for something like this:

```
sda          SIZE usb    
├─sda1       SIZE        mounting_point
```
As you can tell, the TRAN, which is the transport layer, it is USB and is my pen-drive.

Once you identify your target drive, unmount it to ensure no active processes or open files interfere with the flashing process (since Linux treats almost everything, including block devices, as files).

```umount dev/sda*```

And then, this is one of the most critical phases, you must rewrite the entire USB disk, running the following command:

``` sudo dd if=/<download_directory>/proxmox-ve<downloaded_version>.iso of=/dev/sda bs=1M conv=fdatasync status=progress ```

This only takes a couple of minutes. In the end you will see:
```
1706178560 bytes (1.7 GB, 1.6 GiB) copied, 203 s, 8.4 MB/s 
1627+1 records in
1627+1 records out
```

I recommend to do a synchronization just to make sure that everything is stored in the storage device.

## Install Proxmox

Having the ISO image, you only need to insert your device, select it as a boot and follow the instalation steps.

