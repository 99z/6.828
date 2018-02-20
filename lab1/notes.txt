# Lab 1 notes

## Environment

Vultr VPS, Ubuntu 16.04
Installed `gcc-multilib libsdl1.2-dev libtool-bin libglib2.0-dev libz-dev libpixman-1-dev`
Compiled MIT's qemu from https://pdos.csail.mit.edu/6.828/2017/tools.html

## Physical address space

+------------------+  <- 0xFFFFFFFF (4GB)
|      32-bit      |
|  memory mapped   |
|     devices      |
|                  |
/\/\/\/\/\/\/\/\/\/\

/\/\/\/\/\/\/\/\/\/\
|                  |
|      Unused      |
|                  |
+------------------+  <- depends on amount of RAM
|                  |
|                  |
| Extended Memory  |
|                  |
|                  |
+------------------+  <- 0x00100000 (1MB)
|     BIOS ROM     |
+------------------+  <- 0x000F0000 (960KB)
|  16-bit devices, |
|  expansion ROMs  |
+------------------+  <- 0x000C0000 (768KB)
|   VGA Display    |
+------------------+  <- 0x000A0000 (640KB)
|                  |
|    Low Memory    |
|                  |
+------------------+  <- 0x00000000

* Intel 8088-based processors could only address 1MB of physical memory
	* 0x00000000 - 0x000FFFFF
	* 640KB was max possible RAM
* Basic Input/Output System (BIOS) originally in true RAM, now usually in updateable flash memory
	* Responsible for device initialization and hardware checks
	* Loads operating system from some location then passes over control to it
* Modern PCs preserve original 1MB layout for backwards-compatibility
	* Because of this, 0x000A0000 - 0x00100000 is a "hole" in physical memory
		* First 640KB is "conventional" memory, everything else is "extended"

