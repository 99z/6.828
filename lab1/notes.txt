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

## ROM BIOS

* IBM PC begins execution at 0x000ffff0, the top of the 64KB ROM BIOS
	* BIOS in a PC is hard-wired to be between 0x000f0000 - 0x000fffff
	* Having the PC start at this physical address ensures the BIOS always gets control first
* PC starts in real mode, during which address translation is calculated by `physical address = 16 * segment + offset`
	* CS:IP is segment and offset, gdb stops with CS:IP set to f000:fff0
		* Using the formula, we get the physical address 0xffff0, 16 bytes before end of BIOS

### Walking through instructions with GDB

0xffff0: Jump to 0xfe05b, earlier location in BIOS
0xfe05b: Compare 0 to f000:0x6ac8
0xfe062: Jump to 0xfd2e1 if the previously compared values are different
0xfe066: XOR the data register dx with itself
0xfe068: Copy contents of data register to the stack
0xfe06a: Copy (location?) 0x7000 to the stack pointer register
	* This might be VRAM
0xfe070: Copy (location?) 0xf34c2 to data register edx
	* Are the mov calls some sort of initialization for hardware?
0xfe076: Jump to 0xfd15c
0xfd15c: Copy value in eax (accumulator) to ecx (counter)
	* Probably setup for string operations
0xfd15f: Clear interrupt flag (disables interrupts from occurring)
0xfd160: Clear direction flag
0xfd161: Copy 0x8f to eax
0xfd167: Copy contents of al to I/O port address 0x70

Appears that ROM BIOS is probing for/initializing hardware.

## Boot loader

* Floppy/ hard disks are segmented into 512-byte regions called sectors
	* All read/writes need to be at least the size of one sector
	* When a disk is bootable, first sector is the boot sector
		* Boot loader code lives here
* 0x7c00 through 0x7dff (difference of 511 bytes) is loaded into memory
* 0000:7c00, is jumped to, giving control over to the boot loader
* `boot/boot.S` and `boot/main.c` comprise the entirety of the bootloader
	* We need to switch into 32-bit protected mode to use C
		* Wikipedia: "[Protected mode] allows system software to use features such as virtual memory, paging and safe multi-tasking designed to increase an operating system's control over application software."
	* `main.c` handles the booting of the ELF kernel image

### Questions

1. At what point does the processor start executing 32-bit code? What exactly causes the switch from 16- to 32-bit mode?
	* `ljmp    $PROT_MODE_CSEG, $protcseg` is the last 16-bit instruction
	* After this call, gdb notes: `The target architecture is assumed to be i386` for all subsequent instructions
2. What is the last instruction of the boot loader executed, and what is the first instruction of the kernel it just loaded?
	* Last instruction is at `0x00007d6b`. It is `call   *0x10018`
	* First instruction of the kernel is `movw   $0x1234,0x472`
3. Where is the first instruction of the kernel?
	* `0x0010000c`, 12 bytes above the BIOS ROM location
4. How does the boot loader decide how many sectors it must read in order to fetch the entire kernel from disk? Where does it find this information?
	* The kernel starts reading from sector 1 with an offset of 0
	* `end_pa` is set to `pa + count`, and `count` is `p_memsz`, so I believe it reads as many sectors as memory can store
		* Not sure how to check the size of memory at this point
			* Register esi at `0x00007cf0` is set to `69632`, could mean ~64KB of RAM?
			* I think esi is the value of `end_pa` which handles the loop

