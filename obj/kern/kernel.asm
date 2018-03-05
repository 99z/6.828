
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4                   	.byte 0xe4

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 40 11 00       	mov    $0x114000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 40 11 f0       	mov    $0xf0114000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/pmap.h>

// Test the stack backtrace function (lab 1 only)
void
test_backtrace(int x)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 0c             	sub    $0xc,%esp
f0100047:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("entering test_backtrace %d\n", x);
f010004a:	53                   	push   %ebx
f010004b:	68 00 36 10 f0       	push   $0xf0103600
f0100050:	e8 46 26 00 00       	call   f010269b <cprintf>
	if (x > 0)
f0100055:	83 c4 10             	add    $0x10,%esp
f0100058:	85 db                	test   %ebx,%ebx
f010005a:	7e 11                	jle    f010006d <test_backtrace+0x2d>
		test_backtrace(x-1);
f010005c:	83 ec 0c             	sub    $0xc,%esp
f010005f:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0100062:	50                   	push   %eax
f0100063:	e8 d8 ff ff ff       	call   f0100040 <test_backtrace>
f0100068:	83 c4 10             	add    $0x10,%esp
f010006b:	eb 11                	jmp    f010007e <test_backtrace+0x3e>
	else
		mon_backtrace(0, 0, 0);
f010006d:	83 ec 04             	sub    $0x4,%esp
f0100070:	6a 00                	push   $0x0
f0100072:	6a 00                	push   $0x0
f0100074:	6a 00                	push   $0x0
f0100076:	e8 4b 07 00 00       	call   f01007c6 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 1c 36 10 f0       	push   $0xf010361c
f0100087:	e8 0f 26 00 00       	call   f010269b <cprintf>
}
f010008c:	83 c4 10             	add    $0x10,%esp
f010008f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100092:	c9                   	leave  
f0100093:	c3                   	ret    

f0100094 <i386_init>:

void
i386_init(void)
{
f0100094:	55                   	push   %ebp
f0100095:	89 e5                	mov    %esp,%ebp
f0100097:	83 ec 1c             	sub    $0x1c,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f010009a:	b8 70 69 11 f0       	mov    $0xf0116970,%eax
f010009f:	2d 00 63 11 f0       	sub    $0xf0116300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 63 11 f0       	push   $0xf0116300
f01000ac:	e8 a3 30 00 00       	call   f0103154 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 de 04 00 00       	call   f0100594 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 37 36 10 f0       	push   $0xf0103637
f01000c3:	e8 d3 25 00 00       	call   f010269b <cprintf>

	int x = 1, y = 3, z = 4;
	cprintf("x %d, y %x, z %d\n", x, y, z);
f01000c8:	6a 04                	push   $0x4
f01000ca:	6a 03                	push   $0x3
f01000cc:	6a 01                	push   $0x1
f01000ce:	68 52 36 10 f0       	push   $0xf0103652
f01000d3:	e8 c3 25 00 00       	call   f010269b <cprintf>

	// 0x72 = r, 0x6c = l, 0x64 = d, 0x00 = \0
	// 57616 in hex = e110
	unsigned int i = 0x00646c72;
f01000d8:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
	cprintf("H%x Wo%s\n", 57616, &i);
f01000df:	83 c4 1c             	add    $0x1c,%esp
f01000e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01000e5:	50                   	push   %eax
f01000e6:	68 10 e1 00 00       	push   $0xe110
f01000eb:	68 64 36 10 f0       	push   $0xf0103664
f01000f0:	e8 a6 25 00 00       	call   f010269b <cprintf>

	cprintf("x=%d y=%d\n", 3);
f01000f5:	83 c4 08             	add    $0x8,%esp
f01000f8:	6a 03                	push   $0x3
f01000fa:	68 6e 36 10 f0       	push   $0xf010366e
f01000ff:	e8 97 25 00 00       	call   f010269b <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100104:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f010010b:	e8 30 ff ff ff       	call   f0100040 <test_backtrace>

	// Lab 2 memory management initialization
	mem_init();
f0100110:	e8 82 0f 00 00       	call   f0101097 <mem_init>
f0100115:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100118:	83 ec 0c             	sub    $0xc,%esp
f010011b:	6a 00                	push   $0x0
f010011d:	e8 41 07 00 00       	call   f0100863 <monitor>
f0100122:	83 c4 10             	add    $0x10,%esp
f0100125:	eb f1                	jmp    f0100118 <i386_init+0x84>

f0100127 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100127:	55                   	push   %ebp
f0100128:	89 e5                	mov    %esp,%ebp
f010012a:	56                   	push   %esi
f010012b:	53                   	push   %ebx
f010012c:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010012f:	83 3d 60 69 11 f0 00 	cmpl   $0x0,0xf0116960
f0100136:	75 37                	jne    f010016f <_panic+0x48>
		goto dead;
	panicstr = fmt;
f0100138:	89 35 60 69 11 f0    	mov    %esi,0xf0116960

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f010013e:	fa                   	cli    
f010013f:	fc                   	cld    

	va_start(ap, fmt);
f0100140:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f0100143:	83 ec 04             	sub    $0x4,%esp
f0100146:	ff 75 0c             	pushl  0xc(%ebp)
f0100149:	ff 75 08             	pushl  0x8(%ebp)
f010014c:	68 79 36 10 f0       	push   $0xf0103679
f0100151:	e8 45 25 00 00       	call   f010269b <cprintf>
	vcprintf(fmt, ap);
f0100156:	83 c4 08             	add    $0x8,%esp
f0100159:	53                   	push   %ebx
f010015a:	56                   	push   %esi
f010015b:	e8 15 25 00 00       	call   f0102675 <vcprintf>
	cprintf("\n");
f0100160:	c7 04 24 db 45 10 f0 	movl   $0xf01045db,(%esp)
f0100167:	e8 2f 25 00 00       	call   f010269b <cprintf>
	va_end(ap);
f010016c:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010016f:	83 ec 0c             	sub    $0xc,%esp
f0100172:	6a 00                	push   $0x0
f0100174:	e8 ea 06 00 00       	call   f0100863 <monitor>
f0100179:	83 c4 10             	add    $0x10,%esp
f010017c:	eb f1                	jmp    f010016f <_panic+0x48>

f010017e <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f010017e:	55                   	push   %ebp
f010017f:	89 e5                	mov    %esp,%ebp
f0100181:	53                   	push   %ebx
f0100182:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100185:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100188:	ff 75 0c             	pushl  0xc(%ebp)
f010018b:	ff 75 08             	pushl  0x8(%ebp)
f010018e:	68 91 36 10 f0       	push   $0xf0103691
f0100193:	e8 03 25 00 00       	call   f010269b <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	53                   	push   %ebx
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 d1 24 00 00       	call   f0102675 <vcprintf>
	cprintf("\n");
f01001a4:	c7 04 24 db 45 10 f0 	movl   $0xf01045db,(%esp)
f01001ab:	e8 eb 24 00 00       	call   f010269b <cprintf>
	va_end(ap);
}
f01001b0:	83 c4 10             	add    $0x10,%esp
f01001b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01001b6:	c9                   	leave  
f01001b7:	c3                   	ret    

f01001b8 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001b8:	55                   	push   %ebp
f01001b9:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001bb:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001c0:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001c1:	a8 01                	test   $0x1,%al
f01001c3:	74 0b                	je     f01001d0 <serial_proc_data+0x18>
f01001c5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001ca:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001cb:	0f b6 c0             	movzbl %al,%eax
f01001ce:	eb 05                	jmp    f01001d5 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001d5:	5d                   	pop    %ebp
f01001d6:	c3                   	ret    

f01001d7 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001d7:	55                   	push   %ebp
f01001d8:	89 e5                	mov    %esp,%ebp
f01001da:	53                   	push   %ebx
f01001db:	83 ec 04             	sub    $0x4,%esp
f01001de:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001e0:	eb 2b                	jmp    f010020d <cons_intr+0x36>
		if (c == 0)
f01001e2:	85 c0                	test   %eax,%eax
f01001e4:	74 27                	je     f010020d <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001e6:	8b 0d 24 65 11 f0    	mov    0xf0116524,%ecx
f01001ec:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ef:	89 15 24 65 11 f0    	mov    %edx,0xf0116524
f01001f5:	88 81 20 63 11 f0    	mov    %al,-0xfee9ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001fb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100201:	75 0a                	jne    f010020d <cons_intr+0x36>
			cons.wpos = 0;
f0100203:	c7 05 24 65 11 f0 00 	movl   $0x0,0xf0116524
f010020a:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f010020d:	ff d3                	call   *%ebx
f010020f:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100212:	75 ce                	jne    f01001e2 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100214:	83 c4 04             	add    $0x4,%esp
f0100217:	5b                   	pop    %ebx
f0100218:	5d                   	pop    %ebp
f0100219:	c3                   	ret    

f010021a <kbd_proc_data>:
f010021a:	ba 64 00 00 00       	mov    $0x64,%edx
f010021f:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100220:	a8 01                	test   $0x1,%al
f0100222:	0f 84 f8 00 00 00    	je     f0100320 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100228:	a8 20                	test   $0x20,%al
f010022a:	0f 85 f6 00 00 00    	jne    f0100326 <kbd_proc_data+0x10c>
f0100230:	ba 60 00 00 00       	mov    $0x60,%edx
f0100235:	ec                   	in     (%dx),%al
f0100236:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100238:	3c e0                	cmp    $0xe0,%al
f010023a:	75 0d                	jne    f0100249 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f010023c:	83 0d 00 63 11 f0 40 	orl    $0x40,0xf0116300
		return 0;
f0100243:	b8 00 00 00 00       	mov    $0x0,%eax
f0100248:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100249:	55                   	push   %ebp
f010024a:	89 e5                	mov    %esp,%ebp
f010024c:	53                   	push   %ebx
f010024d:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100250:	84 c0                	test   %al,%al
f0100252:	79 36                	jns    f010028a <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100254:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f010025a:	89 cb                	mov    %ecx,%ebx
f010025c:	83 e3 40             	and    $0x40,%ebx
f010025f:	83 e0 7f             	and    $0x7f,%eax
f0100262:	85 db                	test   %ebx,%ebx
f0100264:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100267:	0f b6 d2             	movzbl %dl,%edx
f010026a:	0f b6 82 00 38 10 f0 	movzbl -0xfefc800(%edx),%eax
f0100271:	83 c8 40             	or     $0x40,%eax
f0100274:	0f b6 c0             	movzbl %al,%eax
f0100277:	f7 d0                	not    %eax
f0100279:	21 c8                	and    %ecx,%eax
f010027b:	a3 00 63 11 f0       	mov    %eax,0xf0116300
		return 0;
f0100280:	b8 00 00 00 00       	mov    $0x0,%eax
f0100285:	e9 a4 00 00 00       	jmp    f010032e <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010028a:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f0100290:	f6 c1 40             	test   $0x40,%cl
f0100293:	74 0e                	je     f01002a3 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100295:	83 c8 80             	or     $0xffffff80,%eax
f0100298:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010029a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010029d:	89 0d 00 63 11 f0    	mov    %ecx,0xf0116300
	}

	shift |= shiftcode[data];
f01002a3:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01002a6:	0f b6 82 00 38 10 f0 	movzbl -0xfefc800(%edx),%eax
f01002ad:	0b 05 00 63 11 f0    	or     0xf0116300,%eax
f01002b3:	0f b6 8a 00 37 10 f0 	movzbl -0xfefc900(%edx),%ecx
f01002ba:	31 c8                	xor    %ecx,%eax
f01002bc:	a3 00 63 11 f0       	mov    %eax,0xf0116300

	c = charcode[shift & (CTL | SHIFT)][data];
f01002c1:	89 c1                	mov    %eax,%ecx
f01002c3:	83 e1 03             	and    $0x3,%ecx
f01002c6:	8b 0c 8d e0 36 10 f0 	mov    -0xfefc920(,%ecx,4),%ecx
f01002cd:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002d1:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002d4:	a8 08                	test   $0x8,%al
f01002d6:	74 1b                	je     f01002f3 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01002d8:	89 da                	mov    %ebx,%edx
f01002da:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002dd:	83 f9 19             	cmp    $0x19,%ecx
f01002e0:	77 05                	ja     f01002e7 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002e2:	83 eb 20             	sub    $0x20,%ebx
f01002e5:	eb 0c                	jmp    f01002f3 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002e7:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002ea:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002ed:	83 fa 19             	cmp    $0x19,%edx
f01002f0:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002f3:	f7 d0                	not    %eax
f01002f5:	a8 06                	test   $0x6,%al
f01002f7:	75 33                	jne    f010032c <kbd_proc_data+0x112>
f01002f9:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002ff:	75 2b                	jne    f010032c <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100301:	83 ec 0c             	sub    $0xc,%esp
f0100304:	68 ab 36 10 f0       	push   $0xf01036ab
f0100309:	e8 8d 23 00 00       	call   f010269b <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010030e:	ba 92 00 00 00       	mov    $0x92,%edx
f0100313:	b8 03 00 00 00       	mov    $0x3,%eax
f0100318:	ee                   	out    %al,(%dx)
f0100319:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010031c:	89 d8                	mov    %ebx,%eax
f010031e:	eb 0e                	jmp    f010032e <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100320:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100325:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100326:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010032b:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f010032c:	89 d8                	mov    %ebx,%eax
}
f010032e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100331:	c9                   	leave  
f0100332:	c3                   	ret    

f0100333 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100333:	55                   	push   %ebp
f0100334:	89 e5                	mov    %esp,%ebp
f0100336:	57                   	push   %edi
f0100337:	56                   	push   %esi
f0100338:	53                   	push   %ebx
f0100339:	83 ec 1c             	sub    $0x1c,%esp
f010033c:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f010033e:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100343:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100348:	b9 84 00 00 00       	mov    $0x84,%ecx
f010034d:	eb 09                	jmp    f0100358 <cons_putc+0x25>
f010034f:	89 ca                	mov    %ecx,%edx
f0100351:	ec                   	in     (%dx),%al
f0100352:	ec                   	in     (%dx),%al
f0100353:	ec                   	in     (%dx),%al
f0100354:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100355:	83 c3 01             	add    $0x1,%ebx
f0100358:	89 f2                	mov    %esi,%edx
f010035a:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010035b:	a8 20                	test   $0x20,%al
f010035d:	75 08                	jne    f0100367 <cons_putc+0x34>
f010035f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100365:	7e e8                	jle    f010034f <cons_putc+0x1c>
f0100367:	89 f8                	mov    %edi,%eax
f0100369:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010036c:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100371:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100372:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100377:	be 79 03 00 00       	mov    $0x379,%esi
f010037c:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100381:	eb 09                	jmp    f010038c <cons_putc+0x59>
f0100383:	89 ca                	mov    %ecx,%edx
f0100385:	ec                   	in     (%dx),%al
f0100386:	ec                   	in     (%dx),%al
f0100387:	ec                   	in     (%dx),%al
f0100388:	ec                   	in     (%dx),%al
f0100389:	83 c3 01             	add    $0x1,%ebx
f010038c:	89 f2                	mov    %esi,%edx
f010038e:	ec                   	in     (%dx),%al
f010038f:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100395:	7f 04                	jg     f010039b <cons_putc+0x68>
f0100397:	84 c0                	test   %al,%al
f0100399:	79 e8                	jns    f0100383 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010039b:	ba 78 03 00 00       	mov    $0x378,%edx
f01003a0:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f01003a4:	ee                   	out    %al,(%dx)
f01003a5:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003aa:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003af:	ee                   	out    %al,(%dx)
f01003b0:	b8 08 00 00 00       	mov    $0x8,%eax
f01003b5:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003b6:	89 fa                	mov    %edi,%edx
f01003b8:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003be:	89 f8                	mov    %edi,%eax
f01003c0:	80 cc 07             	or     $0x7,%ah
f01003c3:	85 d2                	test   %edx,%edx
f01003c5:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01003c8:	89 f8                	mov    %edi,%eax
f01003ca:	0f b6 c0             	movzbl %al,%eax
f01003cd:	83 f8 09             	cmp    $0x9,%eax
f01003d0:	74 74                	je     f0100446 <cons_putc+0x113>
f01003d2:	83 f8 09             	cmp    $0x9,%eax
f01003d5:	7f 0a                	jg     f01003e1 <cons_putc+0xae>
f01003d7:	83 f8 08             	cmp    $0x8,%eax
f01003da:	74 14                	je     f01003f0 <cons_putc+0xbd>
f01003dc:	e9 99 00 00 00       	jmp    f010047a <cons_putc+0x147>
f01003e1:	83 f8 0a             	cmp    $0xa,%eax
f01003e4:	74 3a                	je     f0100420 <cons_putc+0xed>
f01003e6:	83 f8 0d             	cmp    $0xd,%eax
f01003e9:	74 3d                	je     f0100428 <cons_putc+0xf5>
f01003eb:	e9 8a 00 00 00       	jmp    f010047a <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003f0:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f01003f7:	66 85 c0             	test   %ax,%ax
f01003fa:	0f 84 e6 00 00 00    	je     f01004e6 <cons_putc+0x1b3>
			crt_pos--;
f0100400:	83 e8 01             	sub    $0x1,%eax
f0100403:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100409:	0f b7 c0             	movzwl %ax,%eax
f010040c:	66 81 e7 00 ff       	and    $0xff00,%di
f0100411:	83 cf 20             	or     $0x20,%edi
f0100414:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f010041a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010041e:	eb 78                	jmp    f0100498 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100420:	66 83 05 28 65 11 f0 	addw   $0x50,0xf0116528
f0100427:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100428:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f010042f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100435:	c1 e8 16             	shr    $0x16,%eax
f0100438:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043b:	c1 e0 04             	shl    $0x4,%eax
f010043e:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
f0100444:	eb 52                	jmp    f0100498 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100446:	b8 20 00 00 00       	mov    $0x20,%eax
f010044b:	e8 e3 fe ff ff       	call   f0100333 <cons_putc>
		cons_putc(' ');
f0100450:	b8 20 00 00 00       	mov    $0x20,%eax
f0100455:	e8 d9 fe ff ff       	call   f0100333 <cons_putc>
		cons_putc(' ');
f010045a:	b8 20 00 00 00       	mov    $0x20,%eax
f010045f:	e8 cf fe ff ff       	call   f0100333 <cons_putc>
		cons_putc(' ');
f0100464:	b8 20 00 00 00       	mov    $0x20,%eax
f0100469:	e8 c5 fe ff ff       	call   f0100333 <cons_putc>
		cons_putc(' ');
f010046e:	b8 20 00 00 00       	mov    $0x20,%eax
f0100473:	e8 bb fe ff ff       	call   f0100333 <cons_putc>
f0100478:	eb 1e                	jmp    f0100498 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010047a:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f0100481:	8d 50 01             	lea    0x1(%eax),%edx
f0100484:	66 89 15 28 65 11 f0 	mov    %dx,0xf0116528
f010048b:	0f b7 c0             	movzwl %ax,%eax
f010048e:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f0100494:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100498:	66 81 3d 28 65 11 f0 	cmpw   $0x7cf,0xf0116528
f010049f:	cf 07 
f01004a1:	76 43                	jbe    f01004e6 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004a3:	a1 2c 65 11 f0       	mov    0xf011652c,%eax
f01004a8:	83 ec 04             	sub    $0x4,%esp
f01004ab:	68 00 0f 00 00       	push   $0xf00
f01004b0:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004b6:	52                   	push   %edx
f01004b7:	50                   	push   %eax
f01004b8:	e8 e4 2c 00 00       	call   f01031a1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004bd:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f01004c3:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004c9:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004cf:	83 c4 10             	add    $0x10,%esp
f01004d2:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004d7:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004da:	39 d0                	cmp    %edx,%eax
f01004dc:	75 f4                	jne    f01004d2 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004de:	66 83 2d 28 65 11 f0 	subw   $0x50,0xf0116528
f01004e5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004e6:	8b 0d 30 65 11 f0    	mov    0xf0116530,%ecx
f01004ec:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004f1:	89 ca                	mov    %ecx,%edx
f01004f3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004f4:	0f b7 1d 28 65 11 f0 	movzwl 0xf0116528,%ebx
f01004fb:	8d 71 01             	lea    0x1(%ecx),%esi
f01004fe:	89 d8                	mov    %ebx,%eax
f0100500:	66 c1 e8 08          	shr    $0x8,%ax
f0100504:	89 f2                	mov    %esi,%edx
f0100506:	ee                   	out    %al,(%dx)
f0100507:	b8 0f 00 00 00       	mov    $0xf,%eax
f010050c:	89 ca                	mov    %ecx,%edx
f010050e:	ee                   	out    %al,(%dx)
f010050f:	89 d8                	mov    %ebx,%eax
f0100511:	89 f2                	mov    %esi,%edx
f0100513:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100514:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100517:	5b                   	pop    %ebx
f0100518:	5e                   	pop    %esi
f0100519:	5f                   	pop    %edi
f010051a:	5d                   	pop    %ebp
f010051b:	c3                   	ret    

f010051c <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f010051c:	80 3d 34 65 11 f0 00 	cmpb   $0x0,0xf0116534
f0100523:	74 11                	je     f0100536 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100525:	55                   	push   %ebp
f0100526:	89 e5                	mov    %esp,%ebp
f0100528:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010052b:	b8 b8 01 10 f0       	mov    $0xf01001b8,%eax
f0100530:	e8 a2 fc ff ff       	call   f01001d7 <cons_intr>
}
f0100535:	c9                   	leave  
f0100536:	f3 c3                	repz ret 

f0100538 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100538:	55                   	push   %ebp
f0100539:	89 e5                	mov    %esp,%ebp
f010053b:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f010053e:	b8 1a 02 10 f0       	mov    $0xf010021a,%eax
f0100543:	e8 8f fc ff ff       	call   f01001d7 <cons_intr>
}
f0100548:	c9                   	leave  
f0100549:	c3                   	ret    

f010054a <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010054a:	55                   	push   %ebp
f010054b:	89 e5                	mov    %esp,%ebp
f010054d:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100550:	e8 c7 ff ff ff       	call   f010051c <serial_intr>
	kbd_intr();
f0100555:	e8 de ff ff ff       	call   f0100538 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010055a:	a1 20 65 11 f0       	mov    0xf0116520,%eax
f010055f:	3b 05 24 65 11 f0    	cmp    0xf0116524,%eax
f0100565:	74 26                	je     f010058d <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100567:	8d 50 01             	lea    0x1(%eax),%edx
f010056a:	89 15 20 65 11 f0    	mov    %edx,0xf0116520
f0100570:	0f b6 88 20 63 11 f0 	movzbl -0xfee9ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100577:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100579:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010057f:	75 11                	jne    f0100592 <cons_getc+0x48>
			cons.rpos = 0;
f0100581:	c7 05 20 65 11 f0 00 	movl   $0x0,0xf0116520
f0100588:	00 00 00 
f010058b:	eb 05                	jmp    f0100592 <cons_getc+0x48>
		return c;
	}
	return 0;
f010058d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100592:	c9                   	leave  
f0100593:	c3                   	ret    

f0100594 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100594:	55                   	push   %ebp
f0100595:	89 e5                	mov    %esp,%ebp
f0100597:	57                   	push   %edi
f0100598:	56                   	push   %esi
f0100599:	53                   	push   %ebx
f010059a:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010059d:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f01005a4:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005ab:	5a a5 
	if (*cp != 0xA55A) {
f01005ad:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005b4:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005b8:	74 11                	je     f01005cb <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005ba:	c7 05 30 65 11 f0 b4 	movl   $0x3b4,0xf0116530
f01005c1:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005c4:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005c9:	eb 16                	jmp    f01005e1 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005cb:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005d2:	c7 05 30 65 11 f0 d4 	movl   $0x3d4,0xf0116530
f01005d9:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005dc:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005e1:	8b 3d 30 65 11 f0    	mov    0xf0116530,%edi
f01005e7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005ec:	89 fa                	mov    %edi,%edx
f01005ee:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ef:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005f2:	89 da                	mov    %ebx,%edx
f01005f4:	ec                   	in     (%dx),%al
f01005f5:	0f b6 c8             	movzbl %al,%ecx
f01005f8:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005fb:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100600:	89 fa                	mov    %edi,%edx
f0100602:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100603:	89 da                	mov    %ebx,%edx
f0100605:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100606:	89 35 2c 65 11 f0    	mov    %esi,0xf011652c
	crt_pos = pos;
f010060c:	0f b6 c0             	movzbl %al,%eax
f010060f:	09 c8                	or     %ecx,%eax
f0100611:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100617:	be fa 03 00 00       	mov    $0x3fa,%esi
f010061c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100621:	89 f2                	mov    %esi,%edx
f0100623:	ee                   	out    %al,(%dx)
f0100624:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100629:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010062e:	ee                   	out    %al,(%dx)
f010062f:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100634:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100639:	89 da                	mov    %ebx,%edx
f010063b:	ee                   	out    %al,(%dx)
f010063c:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100641:	b8 00 00 00 00       	mov    $0x0,%eax
f0100646:	ee                   	out    %al,(%dx)
f0100647:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010064c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100651:	ee                   	out    %al,(%dx)
f0100652:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100657:	b8 00 00 00 00       	mov    $0x0,%eax
f010065c:	ee                   	out    %al,(%dx)
f010065d:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100662:	b8 01 00 00 00       	mov    $0x1,%eax
f0100667:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100668:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010066d:	ec                   	in     (%dx),%al
f010066e:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100670:	3c ff                	cmp    $0xff,%al
f0100672:	0f 95 05 34 65 11 f0 	setne  0xf0116534
f0100679:	89 f2                	mov    %esi,%edx
f010067b:	ec                   	in     (%dx),%al
f010067c:	89 da                	mov    %ebx,%edx
f010067e:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010067f:	80 f9 ff             	cmp    $0xff,%cl
f0100682:	75 10                	jne    f0100694 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f0100684:	83 ec 0c             	sub    $0xc,%esp
f0100687:	68 b7 36 10 f0       	push   $0xf01036b7
f010068c:	e8 0a 20 00 00       	call   f010269b <cprintf>
f0100691:	83 c4 10             	add    $0x10,%esp
}
f0100694:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100697:	5b                   	pop    %ebx
f0100698:	5e                   	pop    %esi
f0100699:	5f                   	pop    %edi
f010069a:	5d                   	pop    %ebp
f010069b:	c3                   	ret    

f010069c <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010069c:	55                   	push   %ebp
f010069d:	89 e5                	mov    %esp,%ebp
f010069f:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01006a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01006a5:	e8 89 fc ff ff       	call   f0100333 <cons_putc>
}
f01006aa:	c9                   	leave  
f01006ab:	c3                   	ret    

f01006ac <getchar>:

int
getchar(void)
{
f01006ac:	55                   	push   %ebp
f01006ad:	89 e5                	mov    %esp,%ebp
f01006af:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006b2:	e8 93 fe ff ff       	call   f010054a <cons_getc>
f01006b7:	85 c0                	test   %eax,%eax
f01006b9:	74 f7                	je     f01006b2 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006bb:	c9                   	leave  
f01006bc:	c3                   	ret    

f01006bd <iscons>:

int
iscons(int fdnum)
{
f01006bd:	55                   	push   %ebp
f01006be:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006c0:	b8 01 00 00 00       	mov    $0x1,%eax
f01006c5:	5d                   	pop    %ebp
f01006c6:	c3                   	ret    

f01006c7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006c7:	55                   	push   %ebp
f01006c8:	89 e5                	mov    %esp,%ebp
f01006ca:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006cd:	68 00 39 10 f0       	push   $0xf0103900
f01006d2:	68 1e 39 10 f0       	push   $0xf010391e
f01006d7:	68 23 39 10 f0       	push   $0xf0103923
f01006dc:	e8 ba 1f 00 00       	call   f010269b <cprintf>
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 d4 39 10 f0       	push   $0xf01039d4
f01006e9:	68 2c 39 10 f0       	push   $0xf010392c
f01006ee:	68 23 39 10 f0       	push   $0xf0103923
f01006f3:	e8 a3 1f 00 00       	call   f010269b <cprintf>
f01006f8:	83 c4 0c             	add    $0xc,%esp
f01006fb:	68 35 39 10 f0       	push   $0xf0103935
f0100700:	68 52 39 10 f0       	push   $0xf0103952
f0100705:	68 23 39 10 f0       	push   $0xf0103923
f010070a:	e8 8c 1f 00 00       	call   f010269b <cprintf>
	return 0;
}
f010070f:	b8 00 00 00 00       	mov    $0x0,%eax
f0100714:	c9                   	leave  
f0100715:	c3                   	ret    

f0100716 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100716:	55                   	push   %ebp
f0100717:	89 e5                	mov    %esp,%ebp
f0100719:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010071c:	68 5c 39 10 f0       	push   $0xf010395c
f0100721:	e8 75 1f 00 00       	call   f010269b <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100726:	83 c4 08             	add    $0x8,%esp
f0100729:	68 0c 00 10 00       	push   $0x10000c
f010072e:	68 fc 39 10 f0       	push   $0xf01039fc
f0100733:	e8 63 1f 00 00       	call   f010269b <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100738:	83 c4 0c             	add    $0xc,%esp
f010073b:	68 0c 00 10 00       	push   $0x10000c
f0100740:	68 0c 00 10 f0       	push   $0xf010000c
f0100745:	68 24 3a 10 f0       	push   $0xf0103a24
f010074a:	e8 4c 1f 00 00       	call   f010269b <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010074f:	83 c4 0c             	add    $0xc,%esp
f0100752:	68 e1 35 10 00       	push   $0x1035e1
f0100757:	68 e1 35 10 f0       	push   $0xf01035e1
f010075c:	68 48 3a 10 f0       	push   $0xf0103a48
f0100761:	e8 35 1f 00 00       	call   f010269b <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100766:	83 c4 0c             	add    $0xc,%esp
f0100769:	68 00 63 11 00       	push   $0x116300
f010076e:	68 00 63 11 f0       	push   $0xf0116300
f0100773:	68 6c 3a 10 f0       	push   $0xf0103a6c
f0100778:	e8 1e 1f 00 00       	call   f010269b <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010077d:	83 c4 0c             	add    $0xc,%esp
f0100780:	68 70 69 11 00       	push   $0x116970
f0100785:	68 70 69 11 f0       	push   $0xf0116970
f010078a:	68 90 3a 10 f0       	push   $0xf0103a90
f010078f:	e8 07 1f 00 00       	call   f010269b <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100794:	b8 6f 6d 11 f0       	mov    $0xf0116d6f,%eax
f0100799:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010079e:	83 c4 08             	add    $0x8,%esp
f01007a1:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01007a6:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007ac:	85 c0                	test   %eax,%eax
f01007ae:	0f 48 c2             	cmovs  %edx,%eax
f01007b1:	c1 f8 0a             	sar    $0xa,%eax
f01007b4:	50                   	push   %eax
f01007b5:	68 b4 3a 10 f0       	push   $0xf0103ab4
f01007ba:	e8 dc 1e 00 00       	call   f010269b <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01007bf:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c4:	c9                   	leave  
f01007c5:	c3                   	ret    

f01007c6 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007c6:	55                   	push   %ebp
f01007c7:	89 e5                	mov    %esp,%ebp
f01007c9:	57                   	push   %edi
f01007ca:	56                   	push   %esi
f01007cb:	53                   	push   %ebx
f01007cc:	83 ec 58             	sub    $0x58,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01007cf:	89 e8                	mov    %ebp,%eax
f01007d1:	89 c6                	mov    %eax,%esi
	// Your code here.
	uint32_t ebp = read_ebp();
	uint32_t args[5];
	struct Eipdebuginfo eip_debug_info;

	cprintf("Stack backtrace:\n");
f01007d3:	68 75 39 10 f0       	push   $0xf0103975
f01007d8:	e8 be 1e 00 00       	call   f010269b <cprintf>
	// When ebp is 0, we've reached the end of the call stack
	while (ebp != 0) {
f01007dd:	83 c4 10             	add    $0x10,%esp
f01007e0:	eb 70                	jmp    f0100852 <mon_backtrace+0x8c>

static inline uint32_t
read_byte_at_addr(uint32_t *addr)
{
        uint32_t val;
        asm volatile("movl (%1),%0" : "=r" (val) : "r" (addr));
f01007e2:	8b 06                	mov    (%esi),%eax
f01007e4:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f01007e7:	8d 5e 04             	lea    0x4(%esi),%ebx
f01007ea:	8b 1b                	mov    (%ebx),%ebx
		uint32_t prev_ebp = read_byte_at_addr((uint32_t *) ebp);

		// eip is address of the next instruction to be executed
		uint32_t eip = read_byte_at_addr((uint32_t *) (ebp + 1 * sizeof(uint32_t)));
		debuginfo_eip(eip, &eip_debug_info);
f01007ec:	83 ec 08             	sub    $0x8,%esp
f01007ef:	8d 45 bc             	lea    -0x44(%ebp),%eax
f01007f2:	50                   	push   %eax
f01007f3:	53                   	push   %ebx
f01007f4:	e8 ac 1f 00 00       	call   f01027a5 <debuginfo_eip>
f01007f9:	8d 46 08             	lea    0x8(%esi),%eax
f01007fc:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01007ff:	83 c4 10             	add    $0x10,%esp

		for (int i = 0; i < 5; i++) {
			args[i] = read_byte_at_addr((uint32_t *) (ebp + (i + 2) * sizeof(uint32_t)));
f0100802:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
f0100805:	29 f1                	sub    %esi,%ecx
f0100807:	8b 10                	mov    (%eax),%edx
f0100809:	89 54 01 f8          	mov    %edx,-0x8(%ecx,%eax,1)
f010080d:	83 c0 04             	add    $0x4,%eax

		// eip is address of the next instruction to be executed
		uint32_t eip = read_byte_at_addr((uint32_t *) (ebp + 1 * sizeof(uint32_t)));
		debuginfo_eip(eip, &eip_debug_info);

		for (int i = 0; i < 5; i++) {
f0100810:	39 f8                	cmp    %edi,%eax
f0100812:	75 f3                	jne    f0100807 <mon_backtrace+0x41>
			args[i] = read_byte_at_addr((uint32_t *) (ebp + (i + 2) * sizeof(uint32_t)));
		}
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, args[0], args[1], args[2], args[3], args[4]);
f0100814:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100817:	ff 75 e0             	pushl  -0x20(%ebp)
f010081a:	ff 75 dc             	pushl  -0x24(%ebp)
f010081d:	ff 75 d8             	pushl  -0x28(%ebp)
f0100820:	ff 75 d4             	pushl  -0x2c(%ebp)
f0100823:	53                   	push   %ebx
f0100824:	56                   	push   %esi
f0100825:	68 e0 3a 10 f0       	push   $0xf0103ae0
f010082a:	e8 6c 1e 00 00       	call   f010269b <cprintf>
		cprintf("\t%s:%d: %.*s+%d\n", eip_debug_info.eip_file, eip_debug_info.eip_line, eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name, eip - eip_debug_info.eip_fn_addr);
f010082f:	83 c4 18             	add    $0x18,%esp
f0100832:	2b 5d cc             	sub    -0x34(%ebp),%ebx
f0100835:	53                   	push   %ebx
f0100836:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100839:	ff 75 c8             	pushl  -0x38(%ebp)
f010083c:	ff 75 c0             	pushl  -0x40(%ebp)
f010083f:	ff 75 bc             	pushl  -0x44(%ebp)
f0100842:	68 87 39 10 f0       	push   $0xf0103987
f0100847:	e8 4f 1e 00 00       	call   f010269b <cprintf>
f010084c:	83 c4 20             	add    $0x20,%esp
		ebp = prev_ebp;
f010084f:	8b 75 b4             	mov    -0x4c(%ebp),%esi
	uint32_t args[5];
	struct Eipdebuginfo eip_debug_info;

	cprintf("Stack backtrace:\n");
	// When ebp is 0, we've reached the end of the call stack
	while (ebp != 0) {
f0100852:	85 f6                	test   %esi,%esi
f0100854:	75 8c                	jne    f01007e2 <mon_backtrace+0x1c>
		cprintf("\t%s:%d: %.*s+%d\n", eip_debug_info.eip_file, eip_debug_info.eip_line, eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name, eip - eip_debug_info.eip_fn_addr);
		ebp = prev_ebp;
	}

	return 0;
}
f0100856:	b8 00 00 00 00       	mov    $0x0,%eax
f010085b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010085e:	5b                   	pop    %ebx
f010085f:	5e                   	pop    %esi
f0100860:	5f                   	pop    %edi
f0100861:	5d                   	pop    %ebp
f0100862:	c3                   	ret    

f0100863 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100863:	55                   	push   %ebp
f0100864:	89 e5                	mov    %esp,%ebp
f0100866:	57                   	push   %edi
f0100867:	56                   	push   %esi
f0100868:	53                   	push   %ebx
f0100869:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010086c:	68 14 3b 10 f0       	push   $0xf0103b14
f0100871:	e8 25 1e 00 00       	call   f010269b <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100876:	c7 04 24 38 3b 10 f0 	movl   $0xf0103b38,(%esp)
f010087d:	e8 19 1e 00 00       	call   f010269b <cprintf>
f0100882:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100885:	83 ec 0c             	sub    $0xc,%esp
f0100888:	68 98 39 10 f0       	push   $0xf0103998
f010088d:	e8 6b 26 00 00       	call   f0102efd <readline>
f0100892:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100894:	83 c4 10             	add    $0x10,%esp
f0100897:	85 c0                	test   %eax,%eax
f0100899:	74 ea                	je     f0100885 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010089b:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008a2:	be 00 00 00 00       	mov    $0x0,%esi
f01008a7:	eb 0a                	jmp    f01008b3 <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008a9:	c6 03 00             	movb   $0x0,(%ebx)
f01008ac:	89 f7                	mov    %esi,%edi
f01008ae:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01008b1:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008b3:	0f b6 03             	movzbl (%ebx),%eax
f01008b6:	84 c0                	test   %al,%al
f01008b8:	74 63                	je     f010091d <monitor+0xba>
f01008ba:	83 ec 08             	sub    $0x8,%esp
f01008bd:	0f be c0             	movsbl %al,%eax
f01008c0:	50                   	push   %eax
f01008c1:	68 9c 39 10 f0       	push   $0xf010399c
f01008c6:	e8 4c 28 00 00       	call   f0103117 <strchr>
f01008cb:	83 c4 10             	add    $0x10,%esp
f01008ce:	85 c0                	test   %eax,%eax
f01008d0:	75 d7                	jne    f01008a9 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008d2:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008d5:	74 46                	je     f010091d <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008d7:	83 fe 0f             	cmp    $0xf,%esi
f01008da:	75 14                	jne    f01008f0 <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008dc:	83 ec 08             	sub    $0x8,%esp
f01008df:	6a 10                	push   $0x10
f01008e1:	68 a1 39 10 f0       	push   $0xf01039a1
f01008e6:	e8 b0 1d 00 00       	call   f010269b <cprintf>
f01008eb:	83 c4 10             	add    $0x10,%esp
f01008ee:	eb 95                	jmp    f0100885 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008f0:	8d 7e 01             	lea    0x1(%esi),%edi
f01008f3:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008f7:	eb 03                	jmp    f01008fc <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008f9:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008fc:	0f b6 03             	movzbl (%ebx),%eax
f01008ff:	84 c0                	test   %al,%al
f0100901:	74 ae                	je     f01008b1 <monitor+0x4e>
f0100903:	83 ec 08             	sub    $0x8,%esp
f0100906:	0f be c0             	movsbl %al,%eax
f0100909:	50                   	push   %eax
f010090a:	68 9c 39 10 f0       	push   $0xf010399c
f010090f:	e8 03 28 00 00       	call   f0103117 <strchr>
f0100914:	83 c4 10             	add    $0x10,%esp
f0100917:	85 c0                	test   %eax,%eax
f0100919:	74 de                	je     f01008f9 <monitor+0x96>
f010091b:	eb 94                	jmp    f01008b1 <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f010091d:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100924:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100925:	85 f6                	test   %esi,%esi
f0100927:	0f 84 58 ff ff ff    	je     f0100885 <monitor+0x22>
f010092d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100932:	83 ec 08             	sub    $0x8,%esp
f0100935:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100938:	ff 34 85 60 3b 10 f0 	pushl  -0xfefc4a0(,%eax,4)
f010093f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100942:	e8 72 27 00 00       	call   f01030b9 <strcmp>
f0100947:	83 c4 10             	add    $0x10,%esp
f010094a:	85 c0                	test   %eax,%eax
f010094c:	75 21                	jne    f010096f <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f010094e:	83 ec 04             	sub    $0x4,%esp
f0100951:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100954:	ff 75 08             	pushl  0x8(%ebp)
f0100957:	8d 55 a8             	lea    -0x58(%ebp),%edx
f010095a:	52                   	push   %edx
f010095b:	56                   	push   %esi
f010095c:	ff 14 85 68 3b 10 f0 	call   *-0xfefc498(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100963:	83 c4 10             	add    $0x10,%esp
f0100966:	85 c0                	test   %eax,%eax
f0100968:	78 25                	js     f010098f <monitor+0x12c>
f010096a:	e9 16 ff ff ff       	jmp    f0100885 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010096f:	83 c3 01             	add    $0x1,%ebx
f0100972:	83 fb 03             	cmp    $0x3,%ebx
f0100975:	75 bb                	jne    f0100932 <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100977:	83 ec 08             	sub    $0x8,%esp
f010097a:	ff 75 a8             	pushl  -0x58(%ebp)
f010097d:	68 be 39 10 f0       	push   $0xf01039be
f0100982:	e8 14 1d 00 00       	call   f010269b <cprintf>
f0100987:	83 c4 10             	add    $0x10,%esp
f010098a:	e9 f6 fe ff ff       	jmp    f0100885 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010098f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100992:	5b                   	pop    %ebx
f0100993:	5e                   	pop    %esi
f0100994:	5f                   	pop    %edi
f0100995:	5d                   	pop    %ebp
f0100996:	c3                   	ret    

f0100997 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100997:	55                   	push   %ebp
f0100998:	89 e5                	mov    %esp,%ebp
f010099a:	56                   	push   %esi
f010099b:	53                   	push   %ebx
f010099c:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010099e:	83 ec 0c             	sub    $0xc,%esp
f01009a1:	50                   	push   %eax
f01009a2:	e8 8d 1c 00 00       	call   f0102634 <mc146818_read>
f01009a7:	89 c6                	mov    %eax,%esi
f01009a9:	83 c3 01             	add    $0x1,%ebx
f01009ac:	89 1c 24             	mov    %ebx,(%esp)
f01009af:	e8 80 1c 00 00       	call   f0102634 <mc146818_read>
f01009b4:	c1 e0 08             	shl    $0x8,%eax
f01009b7:	09 f0                	or     %esi,%eax
}
f01009b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01009bc:	5b                   	pop    %ebx
f01009bd:	5e                   	pop    %esi
f01009be:	5d                   	pop    %ebp
f01009bf:	c3                   	ret    

f01009c0 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01009c0:	89 d1                	mov    %edx,%ecx
f01009c2:	c1 e9 16             	shr    $0x16,%ecx
f01009c5:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01009c8:	a8 01                	test   $0x1,%al
f01009ca:	74 52                	je     f0100a1e <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01009cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009d1:	89 c1                	mov    %eax,%ecx
f01009d3:	c1 e9 0c             	shr    $0xc,%ecx
f01009d6:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f01009dc:	72 1b                	jb     f01009f9 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01009de:	55                   	push   %ebp
f01009df:	89 e5                	mov    %esp,%ebp
f01009e1:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009e4:	50                   	push   %eax
f01009e5:	68 84 3b 10 f0       	push   $0xf0103b84
f01009ea:	68 01 03 00 00       	push   $0x301
f01009ef:	68 00 43 10 f0       	push   $0xf0104300
f01009f4:	e8 2e f7 ff ff       	call   f0100127 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01009f9:	c1 ea 0c             	shr    $0xc,%edx
f01009fc:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a02:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a09:	89 c2                	mov    %eax,%edx
f0100a0b:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a0e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a13:	85 d2                	test   %edx,%edx
f0100a15:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a1a:	0f 44 c2             	cmove  %edx,%eax
f0100a1d:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100a23:	c3                   	ret    

f0100a24 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a24:	55                   	push   %ebp
f0100a25:	89 e5                	mov    %esp,%ebp
f0100a27:	83 ec 08             	sub    $0x8,%esp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a2a:	83 3d 38 65 11 f0 00 	cmpl   $0x0,0xf0116538
f0100a31:	75 11                	jne    f0100a44 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a33:	ba 6f 79 11 f0       	mov    $0xf011796f,%edx
f0100a38:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a3e:	89 15 38 65 11 f0    	mov    %edx,0xf0116538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.

	// If n > 0, allocate pages for result
	if (n > 0) {
f0100a44:	85 c0                	test   %eax,%eax
f0100a46:	74 43                	je     f0100a8b <boot_alloc+0x67>
		result = KADDR(PADDR(nextfree));
f0100a48:	a1 38 65 11 f0       	mov    0xf0116538,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100a4d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100a52:	77 12                	ja     f0100a66 <boot_alloc+0x42>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100a54:	50                   	push   %eax
f0100a55:	68 a8 3b 10 f0       	push   $0xf0103ba8
f0100a5a:	6a 6a                	push   $0x6a
f0100a5c:	68 00 43 10 f0       	push   $0xf0104300
f0100a61:	e8 c1 f6 ff ff       	call   f0100127 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100a66:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a6c:	89 d1                	mov    %edx,%ecx
f0100a6e:	c1 e9 0c             	shr    $0xc,%ecx
f0100a71:	39 0d 64 69 11 f0    	cmp    %ecx,0xf0116964
f0100a77:	77 17                	ja     f0100a90 <boot_alloc+0x6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a79:	52                   	push   %edx
f0100a7a:	68 84 3b 10 f0       	push   $0xf0103b84
f0100a7f:	6a 6a                	push   $0x6a
f0100a81:	68 00 43 10 f0       	push   $0xf0104300
f0100a86:	e8 9c f6 ff ff       	call   f0100127 <_panic>
	} else {
		result = nextfree + ROUNDUP(n, PGSIZE);
f0100a8b:	a1 38 65 11 f0       	mov    0xf0116538,%eax
	}

	return result;
}
f0100a90:	c9                   	leave  
f0100a91:	c3                   	ret    

f0100a92 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100a92:	55                   	push   %ebp
f0100a93:	89 e5                	mov    %esp,%ebp
f0100a95:	57                   	push   %edi
f0100a96:	56                   	push   %esi
f0100a97:	53                   	push   %ebx
f0100a98:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100a9b:	84 c0                	test   %al,%al
f0100a9d:	0f 85 81 02 00 00    	jne    f0100d24 <check_page_free_list+0x292>
f0100aa3:	e9 8e 02 00 00       	jmp    f0100d36 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100aa8:	83 ec 04             	sub    $0x4,%esp
f0100aab:	68 cc 3b 10 f0       	push   $0xf0103bcc
f0100ab0:	68 42 02 00 00       	push   $0x242
f0100ab5:	68 00 43 10 f0       	push   $0xf0104300
f0100aba:	e8 68 f6 ff ff       	call   f0100127 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100abf:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ac2:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ac5:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ac8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100acb:	89 c2                	mov    %eax,%edx
f0100acd:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0100ad3:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100ad9:	0f 95 c2             	setne  %dl
f0100adc:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100adf:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100ae3:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100ae5:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ae9:	8b 00                	mov    (%eax),%eax
f0100aeb:	85 c0                	test   %eax,%eax
f0100aed:	75 dc                	jne    f0100acb <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100aef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100af2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100af8:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100afb:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100afe:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b00:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b03:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b08:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b0d:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f0100b13:	eb 53                	jmp    f0100b68 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b15:	89 d8                	mov    %ebx,%eax
f0100b17:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100b1d:	c1 f8 03             	sar    $0x3,%eax
f0100b20:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b23:	89 c2                	mov    %eax,%edx
f0100b25:	c1 ea 16             	shr    $0x16,%edx
f0100b28:	39 f2                	cmp    %esi,%edx
f0100b2a:	73 3a                	jae    f0100b66 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b2c:	89 c2                	mov    %eax,%edx
f0100b2e:	c1 ea 0c             	shr    $0xc,%edx
f0100b31:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100b37:	72 12                	jb     f0100b4b <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b39:	50                   	push   %eax
f0100b3a:	68 84 3b 10 f0       	push   $0xf0103b84
f0100b3f:	6a 52                	push   $0x52
f0100b41:	68 0c 43 10 f0       	push   $0xf010430c
f0100b46:	e8 dc f5 ff ff       	call   f0100127 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b4b:	83 ec 04             	sub    $0x4,%esp
f0100b4e:	68 80 00 00 00       	push   $0x80
f0100b53:	68 97 00 00 00       	push   $0x97
f0100b58:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b5d:	50                   	push   %eax
f0100b5e:	e8 f1 25 00 00       	call   f0103154 <memset>
f0100b63:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b66:	8b 1b                	mov    (%ebx),%ebx
f0100b68:	85 db                	test   %ebx,%ebx
f0100b6a:	75 a9                	jne    f0100b15 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b71:	e8 ae fe ff ff       	call   f0100a24 <boot_alloc>
f0100b76:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b79:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b7f:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
		assert(pp < pages + npages);
f0100b85:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0100b8a:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b8d:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100b90:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100b93:	be 00 00 00 00       	mov    $0x0,%esi
f0100b98:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b9b:	e9 30 01 00 00       	jmp    f0100cd0 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100ba0:	39 ca                	cmp    %ecx,%edx
f0100ba2:	73 19                	jae    f0100bbd <check_page_free_list+0x12b>
f0100ba4:	68 1a 43 10 f0       	push   $0xf010431a
f0100ba9:	68 26 43 10 f0       	push   $0xf0104326
f0100bae:	68 5c 02 00 00       	push   $0x25c
f0100bb3:	68 00 43 10 f0       	push   $0xf0104300
f0100bb8:	e8 6a f5 ff ff       	call   f0100127 <_panic>
		assert(pp < pages + npages);
f0100bbd:	39 fa                	cmp    %edi,%edx
f0100bbf:	72 19                	jb     f0100bda <check_page_free_list+0x148>
f0100bc1:	68 3b 43 10 f0       	push   $0xf010433b
f0100bc6:	68 26 43 10 f0       	push   $0xf0104326
f0100bcb:	68 5d 02 00 00       	push   $0x25d
f0100bd0:	68 00 43 10 f0       	push   $0xf0104300
f0100bd5:	e8 4d f5 ff ff       	call   f0100127 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bda:	89 d0                	mov    %edx,%eax
f0100bdc:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100bdf:	a8 07                	test   $0x7,%al
f0100be1:	74 19                	je     f0100bfc <check_page_free_list+0x16a>
f0100be3:	68 f0 3b 10 f0       	push   $0xf0103bf0
f0100be8:	68 26 43 10 f0       	push   $0xf0104326
f0100bed:	68 5e 02 00 00       	push   $0x25e
f0100bf2:	68 00 43 10 f0       	push   $0xf0104300
f0100bf7:	e8 2b f5 ff ff       	call   f0100127 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100bfc:	c1 f8 03             	sar    $0x3,%eax
f0100bff:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c02:	85 c0                	test   %eax,%eax
f0100c04:	75 19                	jne    f0100c1f <check_page_free_list+0x18d>
f0100c06:	68 4f 43 10 f0       	push   $0xf010434f
f0100c0b:	68 26 43 10 f0       	push   $0xf0104326
f0100c10:	68 61 02 00 00       	push   $0x261
f0100c15:	68 00 43 10 f0       	push   $0xf0104300
f0100c1a:	e8 08 f5 ff ff       	call   f0100127 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c1f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c24:	75 19                	jne    f0100c3f <check_page_free_list+0x1ad>
f0100c26:	68 60 43 10 f0       	push   $0xf0104360
f0100c2b:	68 26 43 10 f0       	push   $0xf0104326
f0100c30:	68 62 02 00 00       	push   $0x262
f0100c35:	68 00 43 10 f0       	push   $0xf0104300
f0100c3a:	e8 e8 f4 ff ff       	call   f0100127 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c3f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c44:	75 19                	jne    f0100c5f <check_page_free_list+0x1cd>
f0100c46:	68 24 3c 10 f0       	push   $0xf0103c24
f0100c4b:	68 26 43 10 f0       	push   $0xf0104326
f0100c50:	68 63 02 00 00       	push   $0x263
f0100c55:	68 00 43 10 f0       	push   $0xf0104300
f0100c5a:	e8 c8 f4 ff ff       	call   f0100127 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c5f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c64:	75 19                	jne    f0100c7f <check_page_free_list+0x1ed>
f0100c66:	68 79 43 10 f0       	push   $0xf0104379
f0100c6b:	68 26 43 10 f0       	push   $0xf0104326
f0100c70:	68 64 02 00 00       	push   $0x264
f0100c75:	68 00 43 10 f0       	push   $0xf0104300
f0100c7a:	e8 a8 f4 ff ff       	call   f0100127 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c7f:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c84:	76 3f                	jbe    f0100cc5 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c86:	89 c3                	mov    %eax,%ebx
f0100c88:	c1 eb 0c             	shr    $0xc,%ebx
f0100c8b:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100c8e:	77 12                	ja     f0100ca2 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c90:	50                   	push   %eax
f0100c91:	68 84 3b 10 f0       	push   $0xf0103b84
f0100c96:	6a 52                	push   $0x52
f0100c98:	68 0c 43 10 f0       	push   $0xf010430c
f0100c9d:	e8 85 f4 ff ff       	call   f0100127 <_panic>
f0100ca2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ca7:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100caa:	76 1e                	jbe    f0100cca <check_page_free_list+0x238>
f0100cac:	68 48 3c 10 f0       	push   $0xf0103c48
f0100cb1:	68 26 43 10 f0       	push   $0xf0104326
f0100cb6:	68 65 02 00 00       	push   $0x265
f0100cbb:	68 00 43 10 f0       	push   $0xf0104300
f0100cc0:	e8 62 f4 ff ff       	call   f0100127 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100cc5:	83 c6 01             	add    $0x1,%esi
f0100cc8:	eb 04                	jmp    f0100cce <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100cca:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100cce:	8b 12                	mov    (%edx),%edx
f0100cd0:	85 d2                	test   %edx,%edx
f0100cd2:	0f 85 c8 fe ff ff    	jne    f0100ba0 <check_page_free_list+0x10e>
f0100cd8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100cdb:	85 f6                	test   %esi,%esi
f0100cdd:	7f 19                	jg     f0100cf8 <check_page_free_list+0x266>
f0100cdf:	68 93 43 10 f0       	push   $0xf0104393
f0100ce4:	68 26 43 10 f0       	push   $0xf0104326
f0100ce9:	68 6d 02 00 00       	push   $0x26d
f0100cee:	68 00 43 10 f0       	push   $0xf0104300
f0100cf3:	e8 2f f4 ff ff       	call   f0100127 <_panic>
	assert(nfree_extmem > 0);
f0100cf8:	85 db                	test   %ebx,%ebx
f0100cfa:	7f 19                	jg     f0100d15 <check_page_free_list+0x283>
f0100cfc:	68 a5 43 10 f0       	push   $0xf01043a5
f0100d01:	68 26 43 10 f0       	push   $0xf0104326
f0100d06:	68 6e 02 00 00       	push   $0x26e
f0100d0b:	68 00 43 10 f0       	push   $0xf0104300
f0100d10:	e8 12 f4 ff ff       	call   f0100127 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d15:	83 ec 0c             	sub    $0xc,%esp
f0100d18:	68 90 3c 10 f0       	push   $0xf0103c90
f0100d1d:	e8 79 19 00 00       	call   f010269b <cprintf>
}
f0100d22:	eb 29                	jmp    f0100d4d <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d24:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0100d29:	85 c0                	test   %eax,%eax
f0100d2b:	0f 85 8e fd ff ff    	jne    f0100abf <check_page_free_list+0x2d>
f0100d31:	e9 72 fd ff ff       	jmp    f0100aa8 <check_page_free_list+0x16>
f0100d36:	83 3d 3c 65 11 f0 00 	cmpl   $0x0,0xf011653c
f0100d3d:	0f 84 65 fd ff ff    	je     f0100aa8 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d43:	be 00 04 00 00       	mov    $0x400,%esi
f0100d48:	e9 c0 fd ff ff       	jmp    f0100b0d <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d50:	5b                   	pop    %ebx
f0100d51:	5e                   	pop    %esi
f0100d52:	5f                   	pop    %edi
f0100d53:	5d                   	pop    %ebp
f0100d54:	c3                   	ret    

f0100d55 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d55:	55                   	push   %ebp
f0100d56:	89 e5                	mov    %esp,%ebp
f0100d58:	57                   	push   %edi
f0100d59:	56                   	push   %esi
f0100d5a:	53                   	push   %ebx
f0100d5b:	83 ec 1c             	sub    $0x1c,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	// uintptr_t of page number field of address
	size_t pagenum = PGNUM(PADDR(boot_alloc(0)));
f0100d5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d63:	e8 bc fc ff ff       	call   f0100a24 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d68:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d6d:	77 15                	ja     f0100d84 <page_init+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d6f:	50                   	push   %eax
f0100d70:	68 a8 3b 10 f0       	push   $0xf0103ba8
f0100d75:	68 09 01 00 00       	push   $0x109
f0100d7a:	68 00 43 10 f0       	push   $0xf0104300
f0100d7f:	e8 a3 f3 ff ff       	call   f0100127 <_panic>
f0100d84:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d89:	c1 e8 0c             	shr    $0xc,%eax
	// from pmap.h
	// EXTPHYSMEM - IOPHYSMEM = 394K, the hole for I/O
	// PGSIZE is 4096, so this returns 96
	size_t io_hole_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	// mark physical page 0 as in use
	pages[0].pp_ref = 1;
f0100d8c:	8b 15 6c 69 11 f0    	mov    0xf011696c,%edx
f0100d92:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
	for (i = 1; i < npages; i++) {
		// npages_basemem = amount of base memory in pages
		// don't allocate memory in the io hole
		if ((i >= npages_basemem && i < npages_basemem + io_hole_pages) ||
f0100d98:	8b 3d 40 65 11 f0    	mov    0xf0116540,%edi
f0100d9e:	8d 77 60             	lea    0x60(%edi),%esi
f0100da1:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
	// EXTPHYSMEM - IOPHYSMEM = 394K, the hole for I/O
	// PGSIZE is 4096, so this returns 96
	size_t io_hole_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	// mark physical page 0 as in use
	pages[0].pp_ref = 1;
	for (i = 1; i < npages; i++) {
f0100da7:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100dac:	ba 01 00 00 00       	mov    $0x1,%edx
		// npages_basemem = amount of base memory in pages
		// don't allocate memory in the io hole
		if ((i >= npages_basemem && i < npages_basemem + io_hole_pages) ||
		    // don't allocate memory used by the kernel
		    (i >= npages_basemem + io_hole_pages && i < npages_basemem + io_hole_pages + pagenum)) {
f0100db1:	01 f0                	add    %esi,%eax
f0100db3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	// EXTPHYSMEM - IOPHYSMEM = 394K, the hole for I/O
	// PGSIZE is 4096, so this returns 96
	size_t io_hole_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	// mark physical page 0 as in use
	pages[0].pp_ref = 1;
	for (i = 1; i < npages; i++) {
f0100db6:	eb 48                	jmp    f0100e00 <page_init+0xab>
		// npages_basemem = amount of base memory in pages
		// don't allocate memory in the io hole
		if ((i >= npages_basemem && i < npages_basemem + io_hole_pages) ||
f0100db8:	39 fa                	cmp    %edi,%edx
f0100dba:	72 06                	jb     f0100dc2 <page_init+0x6d>
f0100dbc:	39 f2                	cmp    %esi,%edx
f0100dbe:	72 0b                	jb     f0100dcb <page_init+0x76>
f0100dc0:	eb 04                	jmp    f0100dc6 <page_init+0x71>
f0100dc2:	39 f2                	cmp    %esi,%edx
f0100dc4:	72 13                	jb     f0100dd9 <page_init+0x84>
		    // don't allocate memory used by the kernel
		    (i >= npages_basemem + io_hole_pages && i < npages_basemem + io_hole_pages + pagenum)) {
f0100dc6:	3b 55 e4             	cmp    -0x1c(%ebp),%edx
f0100dc9:	73 0e                	jae    f0100dd9 <page_init+0x84>
			pages[i].pp_ref = 1;
f0100dcb:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
f0100dd0:	66 c7 44 d0 04 01 00 	movw   $0x1,0x4(%eax,%edx,8)
			continue;
f0100dd7:	eb 24                	jmp    f0100dfd <page_init+0xa8>
		}
		pages[i].pp_ref = 0;
f0100dd9:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100de0:	89 c1                	mov    %eax,%ecx
f0100de2:	03 0d 6c 69 11 f0    	add    0xf011696c,%ecx
f0100de8:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100dee:	89 19                	mov    %ebx,(%ecx)
		// page_free_list = PageInfo *
		page_free_list = &pages[i];
f0100df0:	03 05 6c 69 11 f0    	add    0xf011696c,%eax
f0100df6:	89 c3                	mov    %eax,%ebx
f0100df8:	b9 01 00 00 00       	mov    $0x1,%ecx
	// EXTPHYSMEM - IOPHYSMEM = 394K, the hole for I/O
	// PGSIZE is 4096, so this returns 96
	size_t io_hole_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	// mark physical page 0 as in use
	pages[0].pp_ref = 1;
	for (i = 1; i < npages; i++) {
f0100dfd:	83 c2 01             	add    $0x1,%edx
f0100e00:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100e06:	72 b0                	jb     f0100db8 <page_init+0x63>
f0100e08:	84 c9                	test   %cl,%cl
f0100e0a:	74 06                	je     f0100e12 <page_init+0xbd>
f0100e0c:	89 1d 3c 65 11 f0    	mov    %ebx,0xf011653c
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		// page_free_list = PageInfo *
		page_free_list = &pages[i];
	}
}
f0100e12:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e15:	5b                   	pop    %ebx
f0100e16:	5e                   	pop    %esi
f0100e17:	5f                   	pop    %edi
f0100e18:	5d                   	pop    %ebp
f0100e19:	c3                   	ret    

f0100e1a <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e1a:	55                   	push   %ebp
f0100e1b:	89 e5                	mov    %esp,%ebp
f0100e1d:	53                   	push   %ebx
f0100e1e:	83 ec 04             	sub    $0x4,%esp
	if (page_free_list == NULL) {
f0100e21:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f0100e27:	85 db                	test   %ebx,%ebx
f0100e29:	74 68                	je     f0100e93 <page_alloc+0x79>
		return NULL;
	}

	struct PageInfo *pp = page_free_list;
	page_free_list = pp->pp_link;
f0100e2b:	8b 03                	mov    (%ebx),%eax
f0100e2d:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
	pp->pp_link = NULL;
f0100e32:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	// bitwise AND, not &&
	if (alloc_flags & ALLOC_ZERO) {
f0100e38:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e3c:	74 55                	je     f0100e93 <page_alloc+0x79>
		cprintf("alloc_flags is zero\n");
f0100e3e:	83 ec 0c             	sub    $0xc,%esp
f0100e41:	68 b6 43 10 f0       	push   $0xf01043b6
f0100e46:	e8 50 18 00 00       	call   f010269b <cprintf>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e4b:	89 d8                	mov    %ebx,%eax
f0100e4d:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100e53:	c1 f8 03             	sar    $0x3,%eax
f0100e56:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e59:	89 c2                	mov    %eax,%edx
f0100e5b:	c1 ea 0c             	shr    $0xc,%edx
f0100e5e:	83 c4 10             	add    $0x10,%esp
f0100e61:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100e67:	72 12                	jb     f0100e7b <page_alloc+0x61>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e69:	50                   	push   %eax
f0100e6a:	68 84 3b 10 f0       	push   $0xf0103b84
f0100e6f:	6a 52                	push   $0x52
f0100e71:	68 0c 43 10 f0       	push   $0xf010430c
f0100e76:	e8 ac f2 ff ff       	call   f0100127 <_panic>
		// fill physical page with '\0' bytes
		memset(page2kva(pp), '\0', PGSIZE);
f0100e7b:	83 ec 04             	sub    $0x4,%esp
f0100e7e:	68 00 10 00 00       	push   $0x1000
f0100e83:	6a 00                	push   $0x0
f0100e85:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e8a:	50                   	push   %eax
f0100e8b:	e8 c4 22 00 00       	call   f0103154 <memset>
f0100e90:	83 c4 10             	add    $0x10,%esp
	}
	return pp;
}
f0100e93:	89 d8                	mov    %ebx,%eax
f0100e95:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100e98:	c9                   	leave  
f0100e99:	c3                   	ret    

f0100e9a <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100e9a:	55                   	push   %ebp
f0100e9b:	89 e5                	mov    %esp,%ebp
f0100e9d:	83 ec 08             	sub    $0x8,%esp
f0100ea0:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if ((pp->pp_ref != 0) || (pp->pp_link != NULL)) {
f0100ea3:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100ea8:	75 05                	jne    f0100eaf <page_free+0x15>
f0100eaa:	83 38 00             	cmpl   $0x0,(%eax)
f0100ead:	74 17                	je     f0100ec6 <page_free+0x2c>
		panic("pp->pp_ref is nonzero or pp->pp_link is not NULL!\n");
f0100eaf:	83 ec 04             	sub    $0x4,%esp
f0100eb2:	68 b4 3c 10 f0       	push   $0xf0103cb4
f0100eb7:	68 4b 01 00 00       	push   $0x14b
f0100ebc:	68 00 43 10 f0       	push   $0xf0104300
f0100ec1:	e8 61 f2 ff ff       	call   f0100127 <_panic>
	}
	pp->pp_link = page_free_list;
f0100ec6:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
f0100ecc:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ece:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
}
f0100ed3:	c9                   	leave  
f0100ed4:	c3                   	ret    

f0100ed5 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100ed5:	55                   	push   %ebp
f0100ed6:	89 e5                	mov    %esp,%ebp
f0100ed8:	83 ec 08             	sub    $0x8,%esp
f0100edb:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100ede:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100ee2:	83 e8 01             	sub    $0x1,%eax
f0100ee5:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100ee9:	66 85 c0             	test   %ax,%ax
f0100eec:	75 0c                	jne    f0100efa <page_decref+0x25>
		page_free(pp);
f0100eee:	83 ec 0c             	sub    $0xc,%esp
f0100ef1:	52                   	push   %edx
f0100ef2:	e8 a3 ff ff ff       	call   f0100e9a <page_free>
f0100ef7:	83 c4 10             	add    $0x10,%esp
}
f0100efa:	c9                   	leave  
f0100efb:	c3                   	ret    

f0100efc <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100efc:	55                   	push   %ebp
f0100efd:	89 e5                	mov    %esp,%ebp
f0100eff:	56                   	push   %esi
f0100f00:	53                   	push   %ebx
f0100f01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *new_page = NULL;

	// PDX(va) is the page directory index
	// Page directory entry is the address of that index in the dir
	pde_t *pde = &pgdir[PDX(va)];
f0100f04:	89 de                	mov    %ebx,%esi
f0100f06:	c1 ee 16             	shr    $0x16,%esi
f0100f09:	c1 e6 02             	shl    $0x2,%esi
f0100f0c:	03 75 08             	add    0x8(%ebp),%esi

	// PTE_P = page table entry present flag
	// if 0, then we know it is not a valid address for translation
	if (!(*pde & PTE_P) && (create == false)) {
f0100f0f:	f6 06 01             	testb  $0x1,(%esi)
f0100f12:	75 06                	jne    f0100f1a <pgdir_walk+0x1e>
f0100f14:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f18:	74 5d                	je     f0100f77 <pgdir_walk+0x7b>
		return NULL;
	}

	new_page = page_alloc(1);
f0100f1a:	83 ec 0c             	sub    $0xc,%esp
f0100f1d:	6a 01                	push   $0x1
f0100f1f:	e8 f6 fe ff ff       	call   f0100e1a <page_alloc>

	if (new_page == NULL) {
f0100f24:	83 c4 10             	add    $0x10,%esp
f0100f27:	85 c0                	test   %eax,%eax
f0100f29:	74 53                	je     f0100f7e <pgdir_walk+0x82>
		return NULL;
	}

	new_page->pp_ref++;
f0100f2b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f30:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100f36:	c1 f8 03             	sar    $0x3,%eax
f0100f39:	c1 e0 0c             	shl    $0xc,%eax
	// Get physical address to new page
	*pde = page2pa(new_page);
f0100f3c:	89 06                	mov    %eax,(%esi)
	// Get virtual address of physical address pde,
	// which is the new page
	pte_t *base_pte = KADDR(PTE_ADDR(*pde));
f0100f3e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100f43:	89 c2                	mov    %eax,%edx
f0100f45:	c1 ea 0c             	shr    $0xc,%edx
f0100f48:	39 15 64 69 11 f0    	cmp    %edx,0xf0116964
f0100f4e:	77 15                	ja     f0100f65 <pgdir_walk+0x69>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100f50:	50                   	push   %eax
f0100f51:	68 84 3b 10 f0       	push   $0xf0103b84
f0100f56:	68 8c 01 00 00       	push   $0x18c
f0100f5b:	68 00 43 10 f0       	push   $0xf0104300
f0100f60:	e8 c2 f1 ff ff       	call   f0100127 <_panic>
	// PTX(va) is page table index at virtual address
	// Return base table entry at table index of virtual address
	return &base_pte[PTX(va)];
f0100f65:	c1 eb 0a             	shr    $0xa,%ebx
f0100f68:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f0100f6e:	8d 84 18 00 00 00 f0 	lea    -0x10000000(%eax,%ebx,1),%eax
f0100f75:	eb 0c                	jmp    f0100f83 <pgdir_walk+0x87>
	pde_t *pde = &pgdir[PDX(va)];

	// PTE_P = page table entry present flag
	// if 0, then we know it is not a valid address for translation
	if (!(*pde & PTE_P) && (create == false)) {
		return NULL;
f0100f77:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f7c:	eb 05                	jmp    f0100f83 <pgdir_walk+0x87>
	}

	new_page = page_alloc(1);

	if (new_page == NULL) {
		return NULL;
f0100f7e:	b8 00 00 00 00       	mov    $0x0,%eax
	// which is the new page
	pte_t *base_pte = KADDR(PTE_ADDR(*pde));
	// PTX(va) is page table index at virtual address
	// Return base table entry at table index of virtual address
	return &base_pte[PTX(va)];
}
f0100f83:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100f86:	5b                   	pop    %ebx
f0100f87:	5e                   	pop    %esi
f0100f88:	5d                   	pop    %ebp
f0100f89:	c3                   	ret    

f0100f8a <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100f8a:	55                   	push   %ebp
f0100f8b:	89 e5                	mov    %esp,%ebp
f0100f8d:	53                   	push   %ebx
f0100f8e:	83 ec 08             	sub    $0x8,%esp
f0100f91:	8b 5d 10             	mov    0x10(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, false);
f0100f94:	6a 00                	push   $0x0
f0100f96:	ff 75 0c             	pushl  0xc(%ebp)
f0100f99:	ff 75 08             	pushl  0x8(%ebp)
f0100f9c:	e8 5b ff ff ff       	call   f0100efc <pgdir_walk>

	if (pte == NULL) {
f0100fa1:	83 c4 10             	add    $0x10,%esp
f0100fa4:	85 c0                	test   %eax,%eax
f0100fa6:	74 32                	je     f0100fda <page_lookup+0x50>
		return NULL;
	}

	// Store pte_store in addr of pte for this page
	// if it is not null
	if (pte_store != 0) {
f0100fa8:	85 db                	test   %ebx,%ebx
f0100faa:	74 02                	je     f0100fae <page_lookup+0x24>
		*pte_store = pte;
f0100fac:	89 03                	mov    %eax,(%ebx)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fae:	8b 00                	mov    (%eax),%eax
f0100fb0:	c1 e8 0c             	shr    $0xc,%eax
f0100fb3:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f0100fb9:	72 14                	jb     f0100fcf <page_lookup+0x45>
		panic("pa2page called with invalid pa");
f0100fbb:	83 ec 04             	sub    $0x4,%esp
f0100fbe:	68 e8 3c 10 f0       	push   $0xf0103ce8
f0100fc3:	6a 4b                	push   $0x4b
f0100fc5:	68 0c 43 10 f0       	push   $0xf010430c
f0100fca:	e8 58 f1 ff ff       	call   f0100127 <_panic>
	return &pages[PGNUM(pa)];
f0100fcf:	8b 15 6c 69 11 f0    	mov    0xf011696c,%edx
f0100fd5:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	}

	// Get physical address corresponding to page table entry
	physaddr_t pa = PTE_ADDR(*pte);
	// Return page corresponding to physical address
	return pa2page(pa);
f0100fd8:	eb 05                	jmp    f0100fdf <page_lookup+0x55>
	pte_t *pte = pgdir_walk(pgdir, va, false);

	if (pte == NULL) {
		// pgdir_walk failed, there is no page
		// mapped at va
		return NULL;
f0100fda:	b8 00 00 00 00       	mov    $0x0,%eax

	// Get physical address corresponding to page table entry
	physaddr_t pa = PTE_ADDR(*pte);
	// Return page corresponding to physical address
	return pa2page(pa);
}
f0100fdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100fe2:	c9                   	leave  
f0100fe3:	c3                   	ret    

f0100fe4 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100fe4:	55                   	push   %ebp
f0100fe5:	89 e5                	mov    %esp,%ebp
f0100fe7:	53                   	push   %ebx
f0100fe8:	83 ec 18             	sub    $0x18,%esp
f0100feb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte;
	struct PageInfo *page = page_lookup(pgdir, va, &pte);
f0100fee:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100ff1:	50                   	push   %eax
f0100ff2:	53                   	push   %ebx
f0100ff3:	ff 75 08             	pushl  0x8(%ebp)
f0100ff6:	e8 8f ff ff ff       	call   f0100f8a <page_lookup>

	if (page == NULL) {
f0100ffb:	83 c4 10             	add    $0x10,%esp
f0100ffe:	85 c0                	test   %eax,%eax
f0101000:	74 18                	je     f010101a <page_remove+0x36>
		return;
	}

	page_decref(page);
f0101002:	83 ec 0c             	sub    $0xc,%esp
f0101005:	50                   	push   %eax
f0101006:	e8 ca fe ff ff       	call   f0100ed5 <page_decref>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010100b:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va);
	// Set present bit to 0
	*pte = *pte & 0;
f010100e:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101011:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
f0101017:	83 c4 10             	add    $0x10,%esp
}
f010101a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010101d:	c9                   	leave  
f010101e:	c3                   	ret    

f010101f <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010101f:	55                   	push   %ebp
f0101020:	89 e5                	mov    %esp,%ebp
f0101022:	57                   	push   %edi
f0101023:	56                   	push   %esi
f0101024:	53                   	push   %ebx
f0101025:	83 ec 10             	sub    $0x10,%esp
f0101028:	8b 75 08             	mov    0x8(%ebp),%esi
f010102b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	pte_t *pte = pgdir_walk(pgdir, va, true);
f010102e:	6a 01                	push   $0x1
f0101030:	ff 75 10             	pushl  0x10(%ebp)
f0101033:	56                   	push   %esi
f0101034:	e8 c3 fe ff ff       	call   f0100efc <pgdir_walk>

	if (pte == NULL) {
f0101039:	83 c4 10             	add    $0x10,%esp
f010103c:	85 c0                	test   %eax,%eax
f010103e:	74 4a                	je     f010108a <page_insert+0x6b>
f0101040:	89 c7                	mov    %eax,%edi
		return -E_NO_MEM;
	}

	// If prsent bit exists, then a page is already
	// mapped at va
	if (*pte & PTE_P) {
f0101042:	f6 00 01             	testb  $0x1,(%eax)
f0101045:	74 15                	je     f010105c <page_insert+0x3d>
		page_remove(pgdir, va);
f0101047:	83 ec 08             	sub    $0x8,%esp
f010104a:	ff 75 10             	pushl  0x10(%ebp)
f010104d:	56                   	push   %esi
f010104e:	e8 91 ff ff ff       	call   f0100fe4 <page_remove>
f0101053:	8b 45 10             	mov    0x10(%ebp),%eax
f0101056:	0f 01 38             	invlpg (%eax)
f0101059:	83 c4 10             	add    $0x10,%esp
		tlb_invalidate(pgdir, va);
	}

	pp->pp_ref++;
f010105c:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)

	*pte = page2pa(pp) | perm | PTE_P;
f0101061:	2b 1d 6c 69 11 f0    	sub    0xf011696c,%ebx
f0101067:	c1 fb 03             	sar    $0x3,%ebx
f010106a:	c1 e3 0c             	shl    $0xc,%ebx
f010106d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101070:	83 c8 01             	or     $0x1,%eax
f0101073:	09 c3                	or     %eax,%ebx
f0101075:	89 1f                	mov    %ebx,(%edi)

	pgdir[PDX(va)] |= perm;
f0101077:	8b 45 10             	mov    0x10(%ebp),%eax
f010107a:	c1 e8 16             	shr    $0x16,%eax
f010107d:	8b 55 14             	mov    0x14(%ebp),%edx
f0101080:	09 14 86             	or     %edx,(%esi,%eax,4)
	return 0;
f0101083:	b8 00 00 00 00       	mov    $0x0,%eax
f0101088:	eb 05                	jmp    f010108f <page_insert+0x70>
{
	pte_t *pte = pgdir_walk(pgdir, va, true);

	if (pte == NULL) {
		// Page table couldn't be allocated
		return -E_NO_MEM;
f010108a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax

	*pte = page2pa(pp) | perm | PTE_P;

	pgdir[PDX(va)] |= perm;
	return 0;
}
f010108f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101092:	5b                   	pop    %ebx
f0101093:	5e                   	pop    %esi
f0101094:	5f                   	pop    %edi
f0101095:	5d                   	pop    %ebp
f0101096:	c3                   	ret    

f0101097 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101097:	55                   	push   %ebp
f0101098:	89 e5                	mov    %esp,%ebp
f010109a:	57                   	push   %edi
f010109b:	56                   	push   %esi
f010109c:	53                   	push   %ebx
f010109d:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01010a0:	b8 15 00 00 00       	mov    $0x15,%eax
f01010a5:	e8 ed f8 ff ff       	call   f0100997 <nvram_read>
f01010aa:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01010ac:	b8 17 00 00 00       	mov    $0x17,%eax
f01010b1:	e8 e1 f8 ff ff       	call   f0100997 <nvram_read>
f01010b6:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f01010b8:	b8 34 00 00 00       	mov    $0x34,%eax
f01010bd:	e8 d5 f8 ff ff       	call   f0100997 <nvram_read>
f01010c2:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f01010c5:	85 c0                	test   %eax,%eax
f01010c7:	74 07                	je     f01010d0 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f01010c9:	05 00 40 00 00       	add    $0x4000,%eax
f01010ce:	eb 0b                	jmp    f01010db <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f01010d0:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f01010d6:	85 f6                	test   %esi,%esi
f01010d8:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f01010db:	89 c2                	mov    %eax,%edx
f01010dd:	c1 ea 02             	shr    $0x2,%edx
f01010e0:	89 15 64 69 11 f0    	mov    %edx,0xf0116964
	npages_basemem = basemem / (PGSIZE / 1024);
f01010e6:	89 da                	mov    %ebx,%edx
f01010e8:	c1 ea 02             	shr    $0x2,%edx
f01010eb:	89 15 40 65 11 f0    	mov    %edx,0xf0116540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f01010f1:	89 c2                	mov    %eax,%edx
f01010f3:	29 da                	sub    %ebx,%edx
f01010f5:	52                   	push   %edx
f01010f6:	53                   	push   %ebx
f01010f7:	50                   	push   %eax
f01010f8:	68 08 3d 10 f0       	push   $0xf0103d08
f01010fd:	e8 99 15 00 00       	call   f010269b <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101102:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101107:	e8 18 f9 ff ff       	call   f0100a24 <boot_alloc>
f010110c:	a3 68 69 11 f0       	mov    %eax,0xf0116968
	memset(kern_pgdir, 0, PGSIZE);
f0101111:	83 c4 0c             	add    $0xc,%esp
f0101114:	68 00 10 00 00       	push   $0x1000
f0101119:	6a 00                	push   $0x0
f010111b:	50                   	push   %eax
f010111c:	e8 33 20 00 00       	call   f0103154 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101121:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101126:	83 c4 10             	add    $0x10,%esp
f0101129:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010112e:	77 15                	ja     f0101145 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101130:	50                   	push   %eax
f0101131:	68 a8 3b 10 f0       	push   $0xf0103ba8
f0101136:	68 93 00 00 00       	push   $0x93
f010113b:	68 00 43 10 f0       	push   $0xf0104300
f0101140:	e8 e2 ef ff ff       	call   f0100127 <_panic>
f0101145:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010114b:	83 ca 05             	or     $0x5,%edx
f010114e:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.

	// pages = number of elements (npages) * size of the struct we want
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101154:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0101159:	c1 e0 03             	shl    $0x3,%eax
f010115c:	e8 c3 f8 ff ff       	call   f0100a24 <boot_alloc>
f0101161:	a3 6c 69 11 f0       	mov    %eax,0xf011696c
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101166:	83 ec 04             	sub    $0x4,%esp
f0101169:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f010116f:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0101176:	52                   	push   %edx
f0101177:	6a 00                	push   $0x0
f0101179:	50                   	push   %eax
f010117a:	e8 d5 1f 00 00       	call   f0103154 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f010117f:	e8 d1 fb ff ff       	call   f0100d55 <page_init>

	check_page_free_list(1);
f0101184:	b8 01 00 00 00       	mov    $0x1,%eax
f0101189:	e8 04 f9 ff ff       	call   f0100a92 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f010118e:	83 c4 10             	add    $0x10,%esp
f0101191:	83 3d 6c 69 11 f0 00 	cmpl   $0x0,0xf011696c
f0101198:	75 17                	jne    f01011b1 <mem_init+0x11a>
		panic("'pages' is a null pointer!");
f010119a:	83 ec 04             	sub    $0x4,%esp
f010119d:	68 cb 43 10 f0       	push   $0xf01043cb
f01011a2:	68 81 02 00 00       	push   $0x281
f01011a7:	68 00 43 10 f0       	push   $0xf0104300
f01011ac:	e8 76 ef ff ff       	call   f0100127 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011b1:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f01011b6:	bb 00 00 00 00       	mov    $0x0,%ebx
f01011bb:	eb 05                	jmp    f01011c2 <mem_init+0x12b>
		++nfree;
f01011bd:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01011c0:	8b 00                	mov    (%eax),%eax
f01011c2:	85 c0                	test   %eax,%eax
f01011c4:	75 f7                	jne    f01011bd <mem_init+0x126>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01011c6:	83 ec 0c             	sub    $0xc,%esp
f01011c9:	6a 00                	push   $0x0
f01011cb:	e8 4a fc ff ff       	call   f0100e1a <page_alloc>
f01011d0:	89 c7                	mov    %eax,%edi
f01011d2:	83 c4 10             	add    $0x10,%esp
f01011d5:	85 c0                	test   %eax,%eax
f01011d7:	75 19                	jne    f01011f2 <mem_init+0x15b>
f01011d9:	68 e6 43 10 f0       	push   $0xf01043e6
f01011de:	68 26 43 10 f0       	push   $0xf0104326
f01011e3:	68 89 02 00 00       	push   $0x289
f01011e8:	68 00 43 10 f0       	push   $0xf0104300
f01011ed:	e8 35 ef ff ff       	call   f0100127 <_panic>
	assert((pp1 = page_alloc(0)));
f01011f2:	83 ec 0c             	sub    $0xc,%esp
f01011f5:	6a 00                	push   $0x0
f01011f7:	e8 1e fc ff ff       	call   f0100e1a <page_alloc>
f01011fc:	89 c6                	mov    %eax,%esi
f01011fe:	83 c4 10             	add    $0x10,%esp
f0101201:	85 c0                	test   %eax,%eax
f0101203:	75 19                	jne    f010121e <mem_init+0x187>
f0101205:	68 fc 43 10 f0       	push   $0xf01043fc
f010120a:	68 26 43 10 f0       	push   $0xf0104326
f010120f:	68 8a 02 00 00       	push   $0x28a
f0101214:	68 00 43 10 f0       	push   $0xf0104300
f0101219:	e8 09 ef ff ff       	call   f0100127 <_panic>
	assert((pp2 = page_alloc(0)));
f010121e:	83 ec 0c             	sub    $0xc,%esp
f0101221:	6a 00                	push   $0x0
f0101223:	e8 f2 fb ff ff       	call   f0100e1a <page_alloc>
f0101228:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010122b:	83 c4 10             	add    $0x10,%esp
f010122e:	85 c0                	test   %eax,%eax
f0101230:	75 19                	jne    f010124b <mem_init+0x1b4>
f0101232:	68 12 44 10 f0       	push   $0xf0104412
f0101237:	68 26 43 10 f0       	push   $0xf0104326
f010123c:	68 8b 02 00 00       	push   $0x28b
f0101241:	68 00 43 10 f0       	push   $0xf0104300
f0101246:	e8 dc ee ff ff       	call   f0100127 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010124b:	39 f7                	cmp    %esi,%edi
f010124d:	75 19                	jne    f0101268 <mem_init+0x1d1>
f010124f:	68 28 44 10 f0       	push   $0xf0104428
f0101254:	68 26 43 10 f0       	push   $0xf0104326
f0101259:	68 8e 02 00 00       	push   $0x28e
f010125e:	68 00 43 10 f0       	push   $0xf0104300
f0101263:	e8 bf ee ff ff       	call   f0100127 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101268:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010126b:	39 c6                	cmp    %eax,%esi
f010126d:	74 04                	je     f0101273 <mem_init+0x1dc>
f010126f:	39 c7                	cmp    %eax,%edi
f0101271:	75 19                	jne    f010128c <mem_init+0x1f5>
f0101273:	68 44 3d 10 f0       	push   $0xf0103d44
f0101278:	68 26 43 10 f0       	push   $0xf0104326
f010127d:	68 8f 02 00 00       	push   $0x28f
f0101282:	68 00 43 10 f0       	push   $0xf0104300
f0101287:	e8 9b ee ff ff       	call   f0100127 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010128c:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f0101292:	8b 15 64 69 11 f0    	mov    0xf0116964,%edx
f0101298:	c1 e2 0c             	shl    $0xc,%edx
f010129b:	89 f8                	mov    %edi,%eax
f010129d:	29 c8                	sub    %ecx,%eax
f010129f:	c1 f8 03             	sar    $0x3,%eax
f01012a2:	c1 e0 0c             	shl    $0xc,%eax
f01012a5:	39 d0                	cmp    %edx,%eax
f01012a7:	72 19                	jb     f01012c2 <mem_init+0x22b>
f01012a9:	68 3a 44 10 f0       	push   $0xf010443a
f01012ae:	68 26 43 10 f0       	push   $0xf0104326
f01012b3:	68 90 02 00 00       	push   $0x290
f01012b8:	68 00 43 10 f0       	push   $0xf0104300
f01012bd:	e8 65 ee ff ff       	call   f0100127 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01012c2:	89 f0                	mov    %esi,%eax
f01012c4:	29 c8                	sub    %ecx,%eax
f01012c6:	c1 f8 03             	sar    $0x3,%eax
f01012c9:	c1 e0 0c             	shl    $0xc,%eax
f01012cc:	39 c2                	cmp    %eax,%edx
f01012ce:	77 19                	ja     f01012e9 <mem_init+0x252>
f01012d0:	68 57 44 10 f0       	push   $0xf0104457
f01012d5:	68 26 43 10 f0       	push   $0xf0104326
f01012da:	68 91 02 00 00       	push   $0x291
f01012df:	68 00 43 10 f0       	push   $0xf0104300
f01012e4:	e8 3e ee ff ff       	call   f0100127 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f01012e9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01012ec:	29 c8                	sub    %ecx,%eax
f01012ee:	c1 f8 03             	sar    $0x3,%eax
f01012f1:	c1 e0 0c             	shl    $0xc,%eax
f01012f4:	39 c2                	cmp    %eax,%edx
f01012f6:	77 19                	ja     f0101311 <mem_init+0x27a>
f01012f8:	68 74 44 10 f0       	push   $0xf0104474
f01012fd:	68 26 43 10 f0       	push   $0xf0104326
f0101302:	68 92 02 00 00       	push   $0x292
f0101307:	68 00 43 10 f0       	push   $0xf0104300
f010130c:	e8 16 ee ff ff       	call   f0100127 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101311:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0101316:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101319:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f0101320:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101323:	83 ec 0c             	sub    $0xc,%esp
f0101326:	6a 00                	push   $0x0
f0101328:	e8 ed fa ff ff       	call   f0100e1a <page_alloc>
f010132d:	83 c4 10             	add    $0x10,%esp
f0101330:	85 c0                	test   %eax,%eax
f0101332:	74 19                	je     f010134d <mem_init+0x2b6>
f0101334:	68 91 44 10 f0       	push   $0xf0104491
f0101339:	68 26 43 10 f0       	push   $0xf0104326
f010133e:	68 99 02 00 00       	push   $0x299
f0101343:	68 00 43 10 f0       	push   $0xf0104300
f0101348:	e8 da ed ff ff       	call   f0100127 <_panic>

	// free and re-allocate?
	page_free(pp0);
f010134d:	83 ec 0c             	sub    $0xc,%esp
f0101350:	57                   	push   %edi
f0101351:	e8 44 fb ff ff       	call   f0100e9a <page_free>
	page_free(pp1);
f0101356:	89 34 24             	mov    %esi,(%esp)
f0101359:	e8 3c fb ff ff       	call   f0100e9a <page_free>
	page_free(pp2);
f010135e:	83 c4 04             	add    $0x4,%esp
f0101361:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101364:	e8 31 fb ff ff       	call   f0100e9a <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101369:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101370:	e8 a5 fa ff ff       	call   f0100e1a <page_alloc>
f0101375:	89 c6                	mov    %eax,%esi
f0101377:	83 c4 10             	add    $0x10,%esp
f010137a:	85 c0                	test   %eax,%eax
f010137c:	75 19                	jne    f0101397 <mem_init+0x300>
f010137e:	68 e6 43 10 f0       	push   $0xf01043e6
f0101383:	68 26 43 10 f0       	push   $0xf0104326
f0101388:	68 a0 02 00 00       	push   $0x2a0
f010138d:	68 00 43 10 f0       	push   $0xf0104300
f0101392:	e8 90 ed ff ff       	call   f0100127 <_panic>
	assert((pp1 = page_alloc(0)));
f0101397:	83 ec 0c             	sub    $0xc,%esp
f010139a:	6a 00                	push   $0x0
f010139c:	e8 79 fa ff ff       	call   f0100e1a <page_alloc>
f01013a1:	89 c7                	mov    %eax,%edi
f01013a3:	83 c4 10             	add    $0x10,%esp
f01013a6:	85 c0                	test   %eax,%eax
f01013a8:	75 19                	jne    f01013c3 <mem_init+0x32c>
f01013aa:	68 fc 43 10 f0       	push   $0xf01043fc
f01013af:	68 26 43 10 f0       	push   $0xf0104326
f01013b4:	68 a1 02 00 00       	push   $0x2a1
f01013b9:	68 00 43 10 f0       	push   $0xf0104300
f01013be:	e8 64 ed ff ff       	call   f0100127 <_panic>
	assert((pp2 = page_alloc(0)));
f01013c3:	83 ec 0c             	sub    $0xc,%esp
f01013c6:	6a 00                	push   $0x0
f01013c8:	e8 4d fa ff ff       	call   f0100e1a <page_alloc>
f01013cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013d0:	83 c4 10             	add    $0x10,%esp
f01013d3:	85 c0                	test   %eax,%eax
f01013d5:	75 19                	jne    f01013f0 <mem_init+0x359>
f01013d7:	68 12 44 10 f0       	push   $0xf0104412
f01013dc:	68 26 43 10 f0       	push   $0xf0104326
f01013e1:	68 a2 02 00 00       	push   $0x2a2
f01013e6:	68 00 43 10 f0       	push   $0xf0104300
f01013eb:	e8 37 ed ff ff       	call   f0100127 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013f0:	39 fe                	cmp    %edi,%esi
f01013f2:	75 19                	jne    f010140d <mem_init+0x376>
f01013f4:	68 28 44 10 f0       	push   $0xf0104428
f01013f9:	68 26 43 10 f0       	push   $0xf0104326
f01013fe:	68 a4 02 00 00       	push   $0x2a4
f0101403:	68 00 43 10 f0       	push   $0xf0104300
f0101408:	e8 1a ed ff ff       	call   f0100127 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010140d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101410:	39 c7                	cmp    %eax,%edi
f0101412:	74 04                	je     f0101418 <mem_init+0x381>
f0101414:	39 c6                	cmp    %eax,%esi
f0101416:	75 19                	jne    f0101431 <mem_init+0x39a>
f0101418:	68 44 3d 10 f0       	push   $0xf0103d44
f010141d:	68 26 43 10 f0       	push   $0xf0104326
f0101422:	68 a5 02 00 00       	push   $0x2a5
f0101427:	68 00 43 10 f0       	push   $0xf0104300
f010142c:	e8 f6 ec ff ff       	call   f0100127 <_panic>
	assert(!page_alloc(0));
f0101431:	83 ec 0c             	sub    $0xc,%esp
f0101434:	6a 00                	push   $0x0
f0101436:	e8 df f9 ff ff       	call   f0100e1a <page_alloc>
f010143b:	83 c4 10             	add    $0x10,%esp
f010143e:	85 c0                	test   %eax,%eax
f0101440:	74 19                	je     f010145b <mem_init+0x3c4>
f0101442:	68 91 44 10 f0       	push   $0xf0104491
f0101447:	68 26 43 10 f0       	push   $0xf0104326
f010144c:	68 a6 02 00 00       	push   $0x2a6
f0101451:	68 00 43 10 f0       	push   $0xf0104300
f0101456:	e8 cc ec ff ff       	call   f0100127 <_panic>
f010145b:	89 f0                	mov    %esi,%eax
f010145d:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101463:	c1 f8 03             	sar    $0x3,%eax
f0101466:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101469:	89 c2                	mov    %eax,%edx
f010146b:	c1 ea 0c             	shr    $0xc,%edx
f010146e:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0101474:	72 12                	jb     f0101488 <mem_init+0x3f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101476:	50                   	push   %eax
f0101477:	68 84 3b 10 f0       	push   $0xf0103b84
f010147c:	6a 52                	push   $0x52
f010147e:	68 0c 43 10 f0       	push   $0xf010430c
f0101483:	e8 9f ec ff ff       	call   f0100127 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101488:	83 ec 04             	sub    $0x4,%esp
f010148b:	68 00 10 00 00       	push   $0x1000
f0101490:	6a 01                	push   $0x1
f0101492:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101497:	50                   	push   %eax
f0101498:	e8 b7 1c 00 00       	call   f0103154 <memset>
	page_free(pp0);
f010149d:	89 34 24             	mov    %esi,(%esp)
f01014a0:	e8 f5 f9 ff ff       	call   f0100e9a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01014a5:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01014ac:	e8 69 f9 ff ff       	call   f0100e1a <page_alloc>
f01014b1:	83 c4 10             	add    $0x10,%esp
f01014b4:	85 c0                	test   %eax,%eax
f01014b6:	75 19                	jne    f01014d1 <mem_init+0x43a>
f01014b8:	68 a0 44 10 f0       	push   $0xf01044a0
f01014bd:	68 26 43 10 f0       	push   $0xf0104326
f01014c2:	68 ab 02 00 00       	push   $0x2ab
f01014c7:	68 00 43 10 f0       	push   $0xf0104300
f01014cc:	e8 56 ec ff ff       	call   f0100127 <_panic>
	assert(pp && pp0 == pp);
f01014d1:	39 c6                	cmp    %eax,%esi
f01014d3:	74 19                	je     f01014ee <mem_init+0x457>
f01014d5:	68 be 44 10 f0       	push   $0xf01044be
f01014da:	68 26 43 10 f0       	push   $0xf0104326
f01014df:	68 ac 02 00 00       	push   $0x2ac
f01014e4:	68 00 43 10 f0       	push   $0xf0104300
f01014e9:	e8 39 ec ff ff       	call   f0100127 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01014ee:	89 f0                	mov    %esi,%eax
f01014f0:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01014f6:	c1 f8 03             	sar    $0x3,%eax
f01014f9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014fc:	89 c2                	mov    %eax,%edx
f01014fe:	c1 ea 0c             	shr    $0xc,%edx
f0101501:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0101507:	72 12                	jb     f010151b <mem_init+0x484>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101509:	50                   	push   %eax
f010150a:	68 84 3b 10 f0       	push   $0xf0103b84
f010150f:	6a 52                	push   $0x52
f0101511:	68 0c 43 10 f0       	push   $0xf010430c
f0101516:	e8 0c ec ff ff       	call   f0100127 <_panic>
f010151b:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101521:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101527:	80 38 00             	cmpb   $0x0,(%eax)
f010152a:	74 19                	je     f0101545 <mem_init+0x4ae>
f010152c:	68 ce 44 10 f0       	push   $0xf01044ce
f0101531:	68 26 43 10 f0       	push   $0xf0104326
f0101536:	68 af 02 00 00       	push   $0x2af
f010153b:	68 00 43 10 f0       	push   $0xf0104300
f0101540:	e8 e2 eb ff ff       	call   f0100127 <_panic>
f0101545:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101548:	39 d0                	cmp    %edx,%eax
f010154a:	75 db                	jne    f0101527 <mem_init+0x490>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010154c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010154f:	a3 3c 65 11 f0       	mov    %eax,0xf011653c

	// free the pages we took
	page_free(pp0);
f0101554:	83 ec 0c             	sub    $0xc,%esp
f0101557:	56                   	push   %esi
f0101558:	e8 3d f9 ff ff       	call   f0100e9a <page_free>
	page_free(pp1);
f010155d:	89 3c 24             	mov    %edi,(%esp)
f0101560:	e8 35 f9 ff ff       	call   f0100e9a <page_free>
	page_free(pp2);
f0101565:	83 c4 04             	add    $0x4,%esp
f0101568:	ff 75 d4             	pushl  -0x2c(%ebp)
f010156b:	e8 2a f9 ff ff       	call   f0100e9a <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101570:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0101575:	83 c4 10             	add    $0x10,%esp
f0101578:	eb 05                	jmp    f010157f <mem_init+0x4e8>
		--nfree;
f010157a:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f010157d:	8b 00                	mov    (%eax),%eax
f010157f:	85 c0                	test   %eax,%eax
f0101581:	75 f7                	jne    f010157a <mem_init+0x4e3>
		--nfree;
	assert(nfree == 0);
f0101583:	85 db                	test   %ebx,%ebx
f0101585:	74 19                	je     f01015a0 <mem_init+0x509>
f0101587:	68 d8 44 10 f0       	push   $0xf01044d8
f010158c:	68 26 43 10 f0       	push   $0xf0104326
f0101591:	68 bc 02 00 00       	push   $0x2bc
f0101596:	68 00 43 10 f0       	push   $0xf0104300
f010159b:	e8 87 eb ff ff       	call   f0100127 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01015a0:	83 ec 0c             	sub    $0xc,%esp
f01015a3:	68 64 3d 10 f0       	push   $0xf0103d64
f01015a8:	e8 ee 10 00 00       	call   f010269b <cprintf>
	// or page_insert
	page_init();

	check_page_free_list(1);
	check_page_alloc();
	cprintf("Entering check_page\n");
f01015ad:	c7 04 24 e3 44 10 f0 	movl   $0xf01044e3,(%esp)
f01015b4:	e8 e2 10 00 00       	call   f010269b <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015b9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01015c0:	e8 55 f8 ff ff       	call   f0100e1a <page_alloc>
f01015c5:	89 c6                	mov    %eax,%esi
f01015c7:	83 c4 10             	add    $0x10,%esp
f01015ca:	85 c0                	test   %eax,%eax
f01015cc:	75 19                	jne    f01015e7 <mem_init+0x550>
f01015ce:	68 e6 43 10 f0       	push   $0xf01043e6
f01015d3:	68 26 43 10 f0       	push   $0xf0104326
f01015d8:	68 15 03 00 00       	push   $0x315
f01015dd:	68 00 43 10 f0       	push   $0xf0104300
f01015e2:	e8 40 eb ff ff       	call   f0100127 <_panic>
	assert((pp1 = page_alloc(0)));
f01015e7:	83 ec 0c             	sub    $0xc,%esp
f01015ea:	6a 00                	push   $0x0
f01015ec:	e8 29 f8 ff ff       	call   f0100e1a <page_alloc>
f01015f1:	89 c7                	mov    %eax,%edi
f01015f3:	83 c4 10             	add    $0x10,%esp
f01015f6:	85 c0                	test   %eax,%eax
f01015f8:	75 19                	jne    f0101613 <mem_init+0x57c>
f01015fa:	68 fc 43 10 f0       	push   $0xf01043fc
f01015ff:	68 26 43 10 f0       	push   $0xf0104326
f0101604:	68 16 03 00 00       	push   $0x316
f0101609:	68 00 43 10 f0       	push   $0xf0104300
f010160e:	e8 14 eb ff ff       	call   f0100127 <_panic>
	assert((pp2 = page_alloc(0)));
f0101613:	83 ec 0c             	sub    $0xc,%esp
f0101616:	6a 00                	push   $0x0
f0101618:	e8 fd f7 ff ff       	call   f0100e1a <page_alloc>
f010161d:	89 c3                	mov    %eax,%ebx
f010161f:	83 c4 10             	add    $0x10,%esp
f0101622:	85 c0                	test   %eax,%eax
f0101624:	75 19                	jne    f010163f <mem_init+0x5a8>
f0101626:	68 12 44 10 f0       	push   $0xf0104412
f010162b:	68 26 43 10 f0       	push   $0xf0104326
f0101630:	68 17 03 00 00       	push   $0x317
f0101635:	68 00 43 10 f0       	push   $0xf0104300
f010163a:	e8 e8 ea ff ff       	call   f0100127 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010163f:	39 fe                	cmp    %edi,%esi
f0101641:	75 19                	jne    f010165c <mem_init+0x5c5>
f0101643:	68 28 44 10 f0       	push   $0xf0104428
f0101648:	68 26 43 10 f0       	push   $0xf0104326
f010164d:	68 1a 03 00 00       	push   $0x31a
f0101652:	68 00 43 10 f0       	push   $0xf0104300
f0101657:	e8 cb ea ff ff       	call   f0100127 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010165c:	39 c7                	cmp    %eax,%edi
f010165e:	74 04                	je     f0101664 <mem_init+0x5cd>
f0101660:	39 c6                	cmp    %eax,%esi
f0101662:	75 19                	jne    f010167d <mem_init+0x5e6>
f0101664:	68 44 3d 10 f0       	push   $0xf0103d44
f0101669:	68 26 43 10 f0       	push   $0xf0104326
f010166e:	68 1b 03 00 00       	push   $0x31b
f0101673:	68 00 43 10 f0       	push   $0xf0104300
f0101678:	e8 aa ea ff ff       	call   f0100127 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010167d:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0101682:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101685:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f010168c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010168f:	83 ec 0c             	sub    $0xc,%esp
f0101692:	6a 00                	push   $0x0
f0101694:	e8 81 f7 ff ff       	call   f0100e1a <page_alloc>
f0101699:	83 c4 10             	add    $0x10,%esp
f010169c:	85 c0                	test   %eax,%eax
f010169e:	74 19                	je     f01016b9 <mem_init+0x622>
f01016a0:	68 91 44 10 f0       	push   $0xf0104491
f01016a5:	68 26 43 10 f0       	push   $0xf0104326
f01016aa:	68 22 03 00 00       	push   $0x322
f01016af:	68 00 43 10 f0       	push   $0xf0104300
f01016b4:	e8 6e ea ff ff       	call   f0100127 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01016b9:	83 ec 04             	sub    $0x4,%esp
f01016bc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01016bf:	50                   	push   %eax
f01016c0:	6a 00                	push   $0x0
f01016c2:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01016c8:	e8 bd f8 ff ff       	call   f0100f8a <page_lookup>
f01016cd:	83 c4 10             	add    $0x10,%esp
f01016d0:	85 c0                	test   %eax,%eax
f01016d2:	74 19                	je     f01016ed <mem_init+0x656>
f01016d4:	68 84 3d 10 f0       	push   $0xf0103d84
f01016d9:	68 26 43 10 f0       	push   $0xf0104326
f01016de:	68 25 03 00 00       	push   $0x325
f01016e3:	68 00 43 10 f0       	push   $0xf0104300
f01016e8:	e8 3a ea ff ff       	call   f0100127 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01016ed:	6a 02                	push   $0x2
f01016ef:	6a 00                	push   $0x0
f01016f1:	57                   	push   %edi
f01016f2:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01016f8:	e8 22 f9 ff ff       	call   f010101f <page_insert>
f01016fd:	83 c4 10             	add    $0x10,%esp
f0101700:	85 c0                	test   %eax,%eax
f0101702:	78 19                	js     f010171d <mem_init+0x686>
f0101704:	68 bc 3d 10 f0       	push   $0xf0103dbc
f0101709:	68 26 43 10 f0       	push   $0xf0104326
f010170e:	68 28 03 00 00       	push   $0x328
f0101713:	68 00 43 10 f0       	push   $0xf0104300
f0101718:	e8 0a ea ff ff       	call   f0100127 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010171d:	83 ec 0c             	sub    $0xc,%esp
f0101720:	56                   	push   %esi
f0101721:	e8 74 f7 ff ff       	call   f0100e9a <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101726:	6a 02                	push   $0x2
f0101728:	6a 00                	push   $0x0
f010172a:	57                   	push   %edi
f010172b:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101731:	e8 e9 f8 ff ff       	call   f010101f <page_insert>
f0101736:	83 c4 20             	add    $0x20,%esp
f0101739:	85 c0                	test   %eax,%eax
f010173b:	74 19                	je     f0101756 <mem_init+0x6bf>
f010173d:	68 ec 3d 10 f0       	push   $0xf0103dec
f0101742:	68 26 43 10 f0       	push   $0xf0104326
f0101747:	68 2c 03 00 00       	push   $0x32c
f010174c:	68 00 43 10 f0       	push   $0xf0104300
f0101751:	e8 d1 e9 ff ff       	call   f0100127 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101756:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f010175c:	8b 11                	mov    (%ecx),%edx
f010175e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101764:	89 f0                	mov    %esi,%eax
f0101766:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f010176c:	c1 f8 03             	sar    $0x3,%eax
f010176f:	c1 e0 0c             	shl    $0xc,%eax
f0101772:	39 c2                	cmp    %eax,%edx
f0101774:	74 19                	je     f010178f <mem_init+0x6f8>
f0101776:	68 1c 3e 10 f0       	push   $0xf0103e1c
f010177b:	68 26 43 10 f0       	push   $0xf0104326
f0101780:	68 2d 03 00 00       	push   $0x32d
f0101785:	68 00 43 10 f0       	push   $0xf0104300
f010178a:	e8 98 e9 ff ff       	call   f0100127 <_panic>
	//assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
	assert(pp1->pp_ref == 1);
f010178f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101794:	74 19                	je     f01017af <mem_init+0x718>
f0101796:	68 f8 44 10 f0       	push   $0xf01044f8
f010179b:	68 26 43 10 f0       	push   $0xf0104326
f01017a0:	68 2f 03 00 00       	push   $0x32f
f01017a5:	68 00 43 10 f0       	push   $0xf0104300
f01017aa:	e8 78 e9 ff ff       	call   f0100127 <_panic>
	assert(pp0->pp_ref == 1);
f01017af:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01017b4:	74 19                	je     f01017cf <mem_init+0x738>
f01017b6:	68 09 45 10 f0       	push   $0xf0104509
f01017bb:	68 26 43 10 f0       	push   $0xf0104326
f01017c0:	68 30 03 00 00       	push   $0x330
f01017c5:	68 00 43 10 f0       	push   $0xf0104300
f01017ca:	e8 58 e9 ff ff       	call   f0100127 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017cf:	6a 02                	push   $0x2
f01017d1:	68 00 10 00 00       	push   $0x1000
f01017d6:	53                   	push   %ebx
f01017d7:	51                   	push   %ecx
f01017d8:	e8 42 f8 ff ff       	call   f010101f <page_insert>
f01017dd:	83 c4 10             	add    $0x10,%esp
f01017e0:	85 c0                	test   %eax,%eax
f01017e2:	74 19                	je     f01017fd <mem_init+0x766>
f01017e4:	68 44 3e 10 f0       	push   $0xf0103e44
f01017e9:	68 26 43 10 f0       	push   $0xf0104326
f01017ee:	68 33 03 00 00       	push   $0x333
f01017f3:	68 00 43 10 f0       	push   $0xf0104300
f01017f8:	e8 2a e9 ff ff       	call   f0100127 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01017fd:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101802:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101807:	e8 b4 f1 ff ff       	call   f01009c0 <check_va2pa>
f010180c:	89 da                	mov    %ebx,%edx
f010180e:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101814:	c1 fa 03             	sar    $0x3,%edx
f0101817:	c1 e2 0c             	shl    $0xc,%edx
f010181a:	39 d0                	cmp    %edx,%eax
f010181c:	74 19                	je     f0101837 <mem_init+0x7a0>
f010181e:	68 80 3e 10 f0       	push   $0xf0103e80
f0101823:	68 26 43 10 f0       	push   $0xf0104326
f0101828:	68 34 03 00 00       	push   $0x334
f010182d:	68 00 43 10 f0       	push   $0xf0104300
f0101832:	e8 f0 e8 ff ff       	call   f0100127 <_panic>
	assert(pp2->pp_ref == 1);
f0101837:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010183c:	74 19                	je     f0101857 <mem_init+0x7c0>
f010183e:	68 1a 45 10 f0       	push   $0xf010451a
f0101843:	68 26 43 10 f0       	push   $0xf0104326
f0101848:	68 35 03 00 00       	push   $0x335
f010184d:	68 00 43 10 f0       	push   $0xf0104300
f0101852:	e8 d0 e8 ff ff       	call   f0100127 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101857:	83 ec 0c             	sub    $0xc,%esp
f010185a:	6a 00                	push   $0x0
f010185c:	e8 b9 f5 ff ff       	call   f0100e1a <page_alloc>
f0101861:	83 c4 10             	add    $0x10,%esp
f0101864:	85 c0                	test   %eax,%eax
f0101866:	74 19                	je     f0101881 <mem_init+0x7ea>
f0101868:	68 91 44 10 f0       	push   $0xf0104491
f010186d:	68 26 43 10 f0       	push   $0xf0104326
f0101872:	68 38 03 00 00       	push   $0x338
f0101877:	68 00 43 10 f0       	push   $0xf0104300
f010187c:	e8 a6 e8 ff ff       	call   f0100127 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101881:	6a 02                	push   $0x2
f0101883:	68 00 10 00 00       	push   $0x1000
f0101888:	53                   	push   %ebx
f0101889:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010188f:	e8 8b f7 ff ff       	call   f010101f <page_insert>
f0101894:	83 c4 10             	add    $0x10,%esp
f0101897:	85 c0                	test   %eax,%eax
f0101899:	74 19                	je     f01018b4 <mem_init+0x81d>
f010189b:	68 44 3e 10 f0       	push   $0xf0103e44
f01018a0:	68 26 43 10 f0       	push   $0xf0104326
f01018a5:	68 3b 03 00 00       	push   $0x33b
f01018aa:	68 00 43 10 f0       	push   $0xf0104300
f01018af:	e8 73 e8 ff ff       	call   f0100127 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01018b4:	ba 00 10 00 00       	mov    $0x1000,%edx
f01018b9:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01018be:	e8 fd f0 ff ff       	call   f01009c0 <check_va2pa>
f01018c3:	89 da                	mov    %ebx,%edx
f01018c5:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01018cb:	c1 fa 03             	sar    $0x3,%edx
f01018ce:	c1 e2 0c             	shl    $0xc,%edx
f01018d1:	39 d0                	cmp    %edx,%eax
f01018d3:	74 19                	je     f01018ee <mem_init+0x857>
f01018d5:	68 80 3e 10 f0       	push   $0xf0103e80
f01018da:	68 26 43 10 f0       	push   $0xf0104326
f01018df:	68 3c 03 00 00       	push   $0x33c
f01018e4:	68 00 43 10 f0       	push   $0xf0104300
f01018e9:	e8 39 e8 ff ff       	call   f0100127 <_panic>
	assert(pp2->pp_ref == 1);
f01018ee:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01018f3:	74 19                	je     f010190e <mem_init+0x877>
f01018f5:	68 1a 45 10 f0       	push   $0xf010451a
f01018fa:	68 26 43 10 f0       	push   $0xf0104326
f01018ff:	68 3d 03 00 00       	push   $0x33d
f0101904:	68 00 43 10 f0       	push   $0xf0104300
f0101909:	e8 19 e8 ff ff       	call   f0100127 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010190e:	83 ec 0c             	sub    $0xc,%esp
f0101911:	6a 00                	push   $0x0
f0101913:	e8 02 f5 ff ff       	call   f0100e1a <page_alloc>
f0101918:	83 c4 10             	add    $0x10,%esp
f010191b:	85 c0                	test   %eax,%eax
f010191d:	74 19                	je     f0101938 <mem_init+0x8a1>
f010191f:	68 91 44 10 f0       	push   $0xf0104491
f0101924:	68 26 43 10 f0       	push   $0xf0104326
f0101929:	68 41 03 00 00       	push   $0x341
f010192e:	68 00 43 10 f0       	push   $0xf0104300
f0101933:	e8 ef e7 ff ff       	call   f0100127 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101938:	8b 15 68 69 11 f0    	mov    0xf0116968,%edx
f010193e:	8b 02                	mov    (%edx),%eax
f0101940:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101945:	89 c1                	mov    %eax,%ecx
f0101947:	c1 e9 0c             	shr    $0xc,%ecx
f010194a:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f0101950:	72 15                	jb     f0101967 <mem_init+0x8d0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101952:	50                   	push   %eax
f0101953:	68 84 3b 10 f0       	push   $0xf0103b84
f0101958:	68 44 03 00 00       	push   $0x344
f010195d:	68 00 43 10 f0       	push   $0xf0104300
f0101962:	e8 c0 e7 ff ff       	call   f0100127 <_panic>
f0101967:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010196c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f010196f:	83 ec 04             	sub    $0x4,%esp
f0101972:	6a 00                	push   $0x0
f0101974:	68 00 10 00 00       	push   $0x1000
f0101979:	52                   	push   %edx
f010197a:	e8 7d f5 ff ff       	call   f0100efc <pgdir_walk>
f010197f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101982:	8d 51 04             	lea    0x4(%ecx),%edx
f0101985:	83 c4 10             	add    $0x10,%esp
f0101988:	39 d0                	cmp    %edx,%eax
f010198a:	74 19                	je     f01019a5 <mem_init+0x90e>
f010198c:	68 b0 3e 10 f0       	push   $0xf0103eb0
f0101991:	68 26 43 10 f0       	push   $0xf0104326
f0101996:	68 45 03 00 00       	push   $0x345
f010199b:	68 00 43 10 f0       	push   $0xf0104300
f01019a0:	e8 82 e7 ff ff       	call   f0100127 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01019a5:	6a 06                	push   $0x6
f01019a7:	68 00 10 00 00       	push   $0x1000
f01019ac:	53                   	push   %ebx
f01019ad:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01019b3:	e8 67 f6 ff ff       	call   f010101f <page_insert>
f01019b8:	83 c4 10             	add    $0x10,%esp
f01019bb:	85 c0                	test   %eax,%eax
f01019bd:	74 19                	je     f01019d8 <mem_init+0x941>
f01019bf:	68 f0 3e 10 f0       	push   $0xf0103ef0
f01019c4:	68 26 43 10 f0       	push   $0xf0104326
f01019c9:	68 48 03 00 00       	push   $0x348
f01019ce:	68 00 43 10 f0       	push   $0xf0104300
f01019d3:	e8 4f e7 ff ff       	call   f0100127 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019d8:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01019dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01019e0:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019e5:	e8 d6 ef ff ff       	call   f01009c0 <check_va2pa>
f01019ea:	89 da                	mov    %ebx,%edx
f01019ec:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01019f2:	c1 fa 03             	sar    $0x3,%edx
f01019f5:	c1 e2 0c             	shl    $0xc,%edx
f01019f8:	39 d0                	cmp    %edx,%eax
f01019fa:	74 19                	je     f0101a15 <mem_init+0x97e>
f01019fc:	68 80 3e 10 f0       	push   $0xf0103e80
f0101a01:	68 26 43 10 f0       	push   $0xf0104326
f0101a06:	68 49 03 00 00       	push   $0x349
f0101a0b:	68 00 43 10 f0       	push   $0xf0104300
f0101a10:	e8 12 e7 ff ff       	call   f0100127 <_panic>
	assert(pp2->pp_ref == 1);
f0101a15:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101a1a:	74 19                	je     f0101a35 <mem_init+0x99e>
f0101a1c:	68 1a 45 10 f0       	push   $0xf010451a
f0101a21:	68 26 43 10 f0       	push   $0xf0104326
f0101a26:	68 4a 03 00 00       	push   $0x34a
f0101a2b:	68 00 43 10 f0       	push   $0xf0104300
f0101a30:	e8 f2 e6 ff ff       	call   f0100127 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101a35:	83 ec 04             	sub    $0x4,%esp
f0101a38:	6a 00                	push   $0x0
f0101a3a:	68 00 10 00 00       	push   $0x1000
f0101a3f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a42:	e8 b5 f4 ff ff       	call   f0100efc <pgdir_walk>
f0101a47:	83 c4 10             	add    $0x10,%esp
f0101a4a:	f6 00 04             	testb  $0x4,(%eax)
f0101a4d:	75 19                	jne    f0101a68 <mem_init+0x9d1>
f0101a4f:	68 30 3f 10 f0       	push   $0xf0103f30
f0101a54:	68 26 43 10 f0       	push   $0xf0104326
f0101a59:	68 4b 03 00 00       	push   $0x34b
f0101a5e:	68 00 43 10 f0       	push   $0xf0104300
f0101a63:	e8 bf e6 ff ff       	call   f0100127 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101a68:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101a6d:	f6 00 04             	testb  $0x4,(%eax)
f0101a70:	75 19                	jne    f0101a8b <mem_init+0x9f4>
f0101a72:	68 2b 45 10 f0       	push   $0xf010452b
f0101a77:	68 26 43 10 f0       	push   $0xf0104326
f0101a7c:	68 4c 03 00 00       	push   $0x34c
f0101a81:	68 00 43 10 f0       	push   $0xf0104300
f0101a86:	e8 9c e6 ff ff       	call   f0100127 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a8b:	6a 02                	push   $0x2
f0101a8d:	68 00 10 00 00       	push   $0x1000
f0101a92:	53                   	push   %ebx
f0101a93:	50                   	push   %eax
f0101a94:	e8 86 f5 ff ff       	call   f010101f <page_insert>
f0101a99:	83 c4 10             	add    $0x10,%esp
f0101a9c:	85 c0                	test   %eax,%eax
f0101a9e:	74 19                	je     f0101ab9 <mem_init+0xa22>
f0101aa0:	68 44 3e 10 f0       	push   $0xf0103e44
f0101aa5:	68 26 43 10 f0       	push   $0xf0104326
f0101aaa:	68 4f 03 00 00       	push   $0x34f
f0101aaf:	68 00 43 10 f0       	push   $0xf0104300
f0101ab4:	e8 6e e6 ff ff       	call   f0100127 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101ab9:	83 ec 04             	sub    $0x4,%esp
f0101abc:	6a 00                	push   $0x0
f0101abe:	68 00 10 00 00       	push   $0x1000
f0101ac3:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101ac9:	e8 2e f4 ff ff       	call   f0100efc <pgdir_walk>
f0101ace:	83 c4 10             	add    $0x10,%esp
f0101ad1:	f6 00 02             	testb  $0x2,(%eax)
f0101ad4:	75 19                	jne    f0101aef <mem_init+0xa58>
f0101ad6:	68 64 3f 10 f0       	push   $0xf0103f64
f0101adb:	68 26 43 10 f0       	push   $0xf0104326
f0101ae0:	68 50 03 00 00       	push   $0x350
f0101ae5:	68 00 43 10 f0       	push   $0xf0104300
f0101aea:	e8 38 e6 ff ff       	call   f0100127 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101aef:	83 ec 04             	sub    $0x4,%esp
f0101af2:	6a 00                	push   $0x0
f0101af4:	68 00 10 00 00       	push   $0x1000
f0101af9:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101aff:	e8 f8 f3 ff ff       	call   f0100efc <pgdir_walk>
f0101b04:	83 c4 10             	add    $0x10,%esp
f0101b07:	f6 00 04             	testb  $0x4,(%eax)
f0101b0a:	74 19                	je     f0101b25 <mem_init+0xa8e>
f0101b0c:	68 98 3f 10 f0       	push   $0xf0103f98
f0101b11:	68 26 43 10 f0       	push   $0xf0104326
f0101b16:	68 51 03 00 00       	push   $0x351
f0101b1b:	68 00 43 10 f0       	push   $0xf0104300
f0101b20:	e8 02 e6 ff ff       	call   f0100127 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101b25:	6a 02                	push   $0x2
f0101b27:	68 00 00 40 00       	push   $0x400000
f0101b2c:	56                   	push   %esi
f0101b2d:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b33:	e8 e7 f4 ff ff       	call   f010101f <page_insert>
f0101b38:	83 c4 10             	add    $0x10,%esp
f0101b3b:	85 c0                	test   %eax,%eax
f0101b3d:	78 19                	js     f0101b58 <mem_init+0xac1>
f0101b3f:	68 d0 3f 10 f0       	push   $0xf0103fd0
f0101b44:	68 26 43 10 f0       	push   $0xf0104326
f0101b49:	68 54 03 00 00       	push   $0x354
f0101b4e:	68 00 43 10 f0       	push   $0xf0104300
f0101b53:	e8 cf e5 ff ff       	call   f0100127 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101b58:	6a 02                	push   $0x2
f0101b5a:	68 00 10 00 00       	push   $0x1000
f0101b5f:	57                   	push   %edi
f0101b60:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b66:	e8 b4 f4 ff ff       	call   f010101f <page_insert>
f0101b6b:	83 c4 10             	add    $0x10,%esp
f0101b6e:	85 c0                	test   %eax,%eax
f0101b70:	74 19                	je     f0101b8b <mem_init+0xaf4>
f0101b72:	68 08 40 10 f0       	push   $0xf0104008
f0101b77:	68 26 43 10 f0       	push   $0xf0104326
f0101b7c:	68 57 03 00 00       	push   $0x357
f0101b81:	68 00 43 10 f0       	push   $0xf0104300
f0101b86:	e8 9c e5 ff ff       	call   f0100127 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101b8b:	83 ec 04             	sub    $0x4,%esp
f0101b8e:	6a 00                	push   $0x0
f0101b90:	68 00 10 00 00       	push   $0x1000
f0101b95:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101b9b:	e8 5c f3 ff ff       	call   f0100efc <pgdir_walk>
f0101ba0:	83 c4 10             	add    $0x10,%esp
f0101ba3:	f6 00 04             	testb  $0x4,(%eax)
f0101ba6:	74 19                	je     f0101bc1 <mem_init+0xb2a>
f0101ba8:	68 98 3f 10 f0       	push   $0xf0103f98
f0101bad:	68 26 43 10 f0       	push   $0xf0104326
f0101bb2:	68 58 03 00 00       	push   $0x358
f0101bb7:	68 00 43 10 f0       	push   $0xf0104300
f0101bbc:	e8 66 e5 ff ff       	call   f0100127 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101bc1:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101bc6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101bc9:	ba 00 00 00 00       	mov    $0x0,%edx
f0101bce:	e8 ed ed ff ff       	call   f01009c0 <check_va2pa>
f0101bd3:	89 c1                	mov    %eax,%ecx
f0101bd5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101bd8:	89 f8                	mov    %edi,%eax
f0101bda:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101be0:	c1 f8 03             	sar    $0x3,%eax
f0101be3:	c1 e0 0c             	shl    $0xc,%eax
f0101be6:	39 c1                	cmp    %eax,%ecx
f0101be8:	74 19                	je     f0101c03 <mem_init+0xb6c>
f0101bea:	68 44 40 10 f0       	push   $0xf0104044
f0101bef:	68 26 43 10 f0       	push   $0xf0104326
f0101bf4:	68 5b 03 00 00       	push   $0x35b
f0101bf9:	68 00 43 10 f0       	push   $0xf0104300
f0101bfe:	e8 24 e5 ff ff       	call   f0100127 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c03:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c08:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101c0b:	e8 b0 ed ff ff       	call   f01009c0 <check_va2pa>
f0101c10:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101c13:	74 19                	je     f0101c2e <mem_init+0xb97>
f0101c15:	68 70 40 10 f0       	push   $0xf0104070
f0101c1a:	68 26 43 10 f0       	push   $0xf0104326
f0101c1f:	68 5c 03 00 00       	push   $0x35c
f0101c24:	68 00 43 10 f0       	push   $0xf0104300
f0101c29:	e8 f9 e4 ff ff       	call   f0100127 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101c2e:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f0101c33:	74 19                	je     f0101c4e <mem_init+0xbb7>
f0101c35:	68 41 45 10 f0       	push   $0xf0104541
f0101c3a:	68 26 43 10 f0       	push   $0xf0104326
f0101c3f:	68 5e 03 00 00       	push   $0x35e
f0101c44:	68 00 43 10 f0       	push   $0xf0104300
f0101c49:	e8 d9 e4 ff ff       	call   f0100127 <_panic>
	assert(pp2->pp_ref == 0);
f0101c4e:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101c53:	74 19                	je     f0101c6e <mem_init+0xbd7>
f0101c55:	68 52 45 10 f0       	push   $0xf0104552
f0101c5a:	68 26 43 10 f0       	push   $0xf0104326
f0101c5f:	68 5f 03 00 00       	push   $0x35f
f0101c64:	68 00 43 10 f0       	push   $0xf0104300
f0101c69:	e8 b9 e4 ff ff       	call   f0100127 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101c6e:	83 ec 0c             	sub    $0xc,%esp
f0101c71:	6a 00                	push   $0x0
f0101c73:	e8 a2 f1 ff ff       	call   f0100e1a <page_alloc>
f0101c78:	83 c4 10             	add    $0x10,%esp
f0101c7b:	85 c0                	test   %eax,%eax
f0101c7d:	74 04                	je     f0101c83 <mem_init+0xbec>
f0101c7f:	39 c3                	cmp    %eax,%ebx
f0101c81:	74 19                	je     f0101c9c <mem_init+0xc05>
f0101c83:	68 a0 40 10 f0       	push   $0xf01040a0
f0101c88:	68 26 43 10 f0       	push   $0xf0104326
f0101c8d:	68 62 03 00 00       	push   $0x362
f0101c92:	68 00 43 10 f0       	push   $0xf0104300
f0101c97:	e8 8b e4 ff ff       	call   f0100127 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101c9c:	83 ec 08             	sub    $0x8,%esp
f0101c9f:	6a 00                	push   $0x0
f0101ca1:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101ca7:	e8 38 f3 ff ff       	call   f0100fe4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101cac:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101cb1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101cb4:	ba 00 00 00 00       	mov    $0x0,%edx
f0101cb9:	e8 02 ed ff ff       	call   f01009c0 <check_va2pa>
f0101cbe:	83 c4 10             	add    $0x10,%esp
f0101cc1:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101cc4:	74 19                	je     f0101cdf <mem_init+0xc48>
f0101cc6:	68 c4 40 10 f0       	push   $0xf01040c4
f0101ccb:	68 26 43 10 f0       	push   $0xf0104326
f0101cd0:	68 66 03 00 00       	push   $0x366
f0101cd5:	68 00 43 10 f0       	push   $0xf0104300
f0101cda:	e8 48 e4 ff ff       	call   f0100127 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101cdf:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ce4:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101ce7:	e8 d4 ec ff ff       	call   f01009c0 <check_va2pa>
f0101cec:	89 fa                	mov    %edi,%edx
f0101cee:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101cf4:	c1 fa 03             	sar    $0x3,%edx
f0101cf7:	c1 e2 0c             	shl    $0xc,%edx
f0101cfa:	39 d0                	cmp    %edx,%eax
f0101cfc:	74 19                	je     f0101d17 <mem_init+0xc80>
f0101cfe:	68 70 40 10 f0       	push   $0xf0104070
f0101d03:	68 26 43 10 f0       	push   $0xf0104326
f0101d08:	68 67 03 00 00       	push   $0x367
f0101d0d:	68 00 43 10 f0       	push   $0xf0104300
f0101d12:	e8 10 e4 ff ff       	call   f0100127 <_panic>
	assert(pp1->pp_ref == 1);
f0101d17:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101d1c:	74 19                	je     f0101d37 <mem_init+0xca0>
f0101d1e:	68 f8 44 10 f0       	push   $0xf01044f8
f0101d23:	68 26 43 10 f0       	push   $0xf0104326
f0101d28:	68 68 03 00 00       	push   $0x368
f0101d2d:	68 00 43 10 f0       	push   $0xf0104300
f0101d32:	e8 f0 e3 ff ff       	call   f0100127 <_panic>
	assert(pp2->pp_ref == 0);
f0101d37:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d3c:	74 19                	je     f0101d57 <mem_init+0xcc0>
f0101d3e:	68 52 45 10 f0       	push   $0xf0104552
f0101d43:	68 26 43 10 f0       	push   $0xf0104326
f0101d48:	68 69 03 00 00       	push   $0x369
f0101d4d:	68 00 43 10 f0       	push   $0xf0104300
f0101d52:	e8 d0 e3 ff ff       	call   f0100127 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101d57:	6a 00                	push   $0x0
f0101d59:	68 00 10 00 00       	push   $0x1000
f0101d5e:	57                   	push   %edi
f0101d5f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101d62:	e8 b8 f2 ff ff       	call   f010101f <page_insert>
f0101d67:	83 c4 10             	add    $0x10,%esp
f0101d6a:	85 c0                	test   %eax,%eax
f0101d6c:	74 19                	je     f0101d87 <mem_init+0xcf0>
f0101d6e:	68 e8 40 10 f0       	push   $0xf01040e8
f0101d73:	68 26 43 10 f0       	push   $0xf0104326
f0101d78:	68 6c 03 00 00       	push   $0x36c
f0101d7d:	68 00 43 10 f0       	push   $0xf0104300
f0101d82:	e8 a0 e3 ff ff       	call   f0100127 <_panic>
	assert(pp1->pp_ref);
f0101d87:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101d8c:	75 19                	jne    f0101da7 <mem_init+0xd10>
f0101d8e:	68 63 45 10 f0       	push   $0xf0104563
f0101d93:	68 26 43 10 f0       	push   $0xf0104326
f0101d98:	68 6d 03 00 00       	push   $0x36d
f0101d9d:	68 00 43 10 f0       	push   $0xf0104300
f0101da2:	e8 80 e3 ff ff       	call   f0100127 <_panic>
	assert(pp1->pp_link == NULL);
f0101da7:	83 3f 00             	cmpl   $0x0,(%edi)
f0101daa:	74 19                	je     f0101dc5 <mem_init+0xd2e>
f0101dac:	68 6f 45 10 f0       	push   $0xf010456f
f0101db1:	68 26 43 10 f0       	push   $0xf0104326
f0101db6:	68 6e 03 00 00       	push   $0x36e
f0101dbb:	68 00 43 10 f0       	push   $0xf0104300
f0101dc0:	e8 62 e3 ff ff       	call   f0100127 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101dc5:	83 ec 08             	sub    $0x8,%esp
f0101dc8:	68 00 10 00 00       	push   $0x1000
f0101dcd:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101dd3:	e8 0c f2 ff ff       	call   f0100fe4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101dd8:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101ddd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101de0:	ba 00 00 00 00       	mov    $0x0,%edx
f0101de5:	e8 d6 eb ff ff       	call   f01009c0 <check_va2pa>
f0101dea:	83 c4 10             	add    $0x10,%esp
f0101ded:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101df0:	74 19                	je     f0101e0b <mem_init+0xd74>
f0101df2:	68 c4 40 10 f0       	push   $0xf01040c4
f0101df7:	68 26 43 10 f0       	push   $0xf0104326
f0101dfc:	68 72 03 00 00       	push   $0x372
f0101e01:	68 00 43 10 f0       	push   $0xf0104300
f0101e06:	e8 1c e3 ff ff       	call   f0100127 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101e0b:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e10:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e13:	e8 a8 eb ff ff       	call   f01009c0 <check_va2pa>
f0101e18:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e1b:	74 19                	je     f0101e36 <mem_init+0xd9f>
f0101e1d:	68 20 41 10 f0       	push   $0xf0104120
f0101e22:	68 26 43 10 f0       	push   $0xf0104326
f0101e27:	68 73 03 00 00       	push   $0x373
f0101e2c:	68 00 43 10 f0       	push   $0xf0104300
f0101e31:	e8 f1 e2 ff ff       	call   f0100127 <_panic>
	assert(pp1->pp_ref == 0);
f0101e36:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101e3b:	74 19                	je     f0101e56 <mem_init+0xdbf>
f0101e3d:	68 84 45 10 f0       	push   $0xf0104584
f0101e42:	68 26 43 10 f0       	push   $0xf0104326
f0101e47:	68 74 03 00 00       	push   $0x374
f0101e4c:	68 00 43 10 f0       	push   $0xf0104300
f0101e51:	e8 d1 e2 ff ff       	call   f0100127 <_panic>
	assert(pp2->pp_ref == 0);
f0101e56:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101e5b:	74 19                	je     f0101e76 <mem_init+0xddf>
f0101e5d:	68 52 45 10 f0       	push   $0xf0104552
f0101e62:	68 26 43 10 f0       	push   $0xf0104326
f0101e67:	68 75 03 00 00       	push   $0x375
f0101e6c:	68 00 43 10 f0       	push   $0xf0104300
f0101e71:	e8 b1 e2 ff ff       	call   f0100127 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101e76:	83 ec 0c             	sub    $0xc,%esp
f0101e79:	6a 00                	push   $0x0
f0101e7b:	e8 9a ef ff ff       	call   f0100e1a <page_alloc>
f0101e80:	83 c4 10             	add    $0x10,%esp
f0101e83:	39 c7                	cmp    %eax,%edi
f0101e85:	75 04                	jne    f0101e8b <mem_init+0xdf4>
f0101e87:	85 c0                	test   %eax,%eax
f0101e89:	75 19                	jne    f0101ea4 <mem_init+0xe0d>
f0101e8b:	68 48 41 10 f0       	push   $0xf0104148
f0101e90:	68 26 43 10 f0       	push   $0xf0104326
f0101e95:	68 78 03 00 00       	push   $0x378
f0101e9a:	68 00 43 10 f0       	push   $0xf0104300
f0101e9f:	e8 83 e2 ff ff       	call   f0100127 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101ea4:	83 ec 0c             	sub    $0xc,%esp
f0101ea7:	6a 00                	push   $0x0
f0101ea9:	e8 6c ef ff ff       	call   f0100e1a <page_alloc>
f0101eae:	83 c4 10             	add    $0x10,%esp
f0101eb1:	85 c0                	test   %eax,%eax
f0101eb3:	74 19                	je     f0101ece <mem_init+0xe37>
f0101eb5:	68 91 44 10 f0       	push   $0xf0104491
f0101eba:	68 26 43 10 f0       	push   $0xf0104326
f0101ebf:	68 7b 03 00 00       	push   $0x37b
f0101ec4:	68 00 43 10 f0       	push   $0xf0104300
f0101ec9:	e8 59 e2 ff ff       	call   f0100127 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101ece:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f0101ed4:	8b 11                	mov    (%ecx),%edx
f0101ed6:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101edc:	89 f0                	mov    %esi,%eax
f0101ede:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101ee4:	c1 f8 03             	sar    $0x3,%eax
f0101ee7:	c1 e0 0c             	shl    $0xc,%eax
f0101eea:	39 c2                	cmp    %eax,%edx
f0101eec:	74 19                	je     f0101f07 <mem_init+0xe70>
f0101eee:	68 1c 3e 10 f0       	push   $0xf0103e1c
f0101ef3:	68 26 43 10 f0       	push   $0xf0104326
f0101ef8:	68 7e 03 00 00       	push   $0x37e
f0101efd:	68 00 43 10 f0       	push   $0xf0104300
f0101f02:	e8 20 e2 ff ff       	call   f0100127 <_panic>
	kern_pgdir[0] = 0;
f0101f07:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101f0d:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101f12:	74 19                	je     f0101f2d <mem_init+0xe96>
f0101f14:	68 09 45 10 f0       	push   $0xf0104509
f0101f19:	68 26 43 10 f0       	push   $0xf0104326
f0101f1e:	68 80 03 00 00       	push   $0x380
f0101f23:	68 00 43 10 f0       	push   $0xf0104300
f0101f28:	e8 fa e1 ff ff       	call   f0100127 <_panic>
	pp0->pp_ref = 0;
f0101f2d:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101f33:	83 ec 0c             	sub    $0xc,%esp
f0101f36:	56                   	push   %esi
f0101f37:	e8 5e ef ff ff       	call   f0100e9a <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101f3c:	83 c4 0c             	add    $0xc,%esp
f0101f3f:	6a 01                	push   $0x1
f0101f41:	68 00 10 40 00       	push   $0x401000
f0101f46:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101f4c:	e8 ab ef ff ff       	call   f0100efc <pgdir_walk>
f0101f51:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101f54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101f57:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101f5c:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101f5f:	8b 40 04             	mov    0x4(%eax),%eax
f0101f62:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f67:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f0101f6d:	89 c2                	mov    %eax,%edx
f0101f6f:	c1 ea 0c             	shr    $0xc,%edx
f0101f72:	83 c4 10             	add    $0x10,%esp
f0101f75:	39 ca                	cmp    %ecx,%edx
f0101f77:	72 15                	jb     f0101f8e <mem_init+0xef7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f79:	50                   	push   %eax
f0101f7a:	68 84 3b 10 f0       	push   $0xf0103b84
f0101f7f:	68 87 03 00 00       	push   $0x387
f0101f84:	68 00 43 10 f0       	push   $0xf0104300
f0101f89:	e8 99 e1 ff ff       	call   f0100127 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101f8e:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101f93:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101f96:	74 19                	je     f0101fb1 <mem_init+0xf1a>
f0101f98:	68 95 45 10 f0       	push   $0xf0104595
f0101f9d:	68 26 43 10 f0       	push   $0xf0104326
f0101fa2:	68 88 03 00 00       	push   $0x388
f0101fa7:	68 00 43 10 f0       	push   $0xf0104300
f0101fac:	e8 76 e1 ff ff       	call   f0100127 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101fb1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101fb4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101fbb:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101fc1:	89 f0                	mov    %esi,%eax
f0101fc3:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101fc9:	c1 f8 03             	sar    $0x3,%eax
f0101fcc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101fcf:	89 c2                	mov    %eax,%edx
f0101fd1:	c1 ea 0c             	shr    $0xc,%edx
f0101fd4:	39 d1                	cmp    %edx,%ecx
f0101fd6:	77 12                	ja     f0101fea <mem_init+0xf53>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101fd8:	50                   	push   %eax
f0101fd9:	68 84 3b 10 f0       	push   $0xf0103b84
f0101fde:	6a 52                	push   $0x52
f0101fe0:	68 0c 43 10 f0       	push   $0xf010430c
f0101fe5:	e8 3d e1 ff ff       	call   f0100127 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101fea:	83 ec 04             	sub    $0x4,%esp
f0101fed:	68 00 10 00 00       	push   $0x1000
f0101ff2:	68 ff 00 00 00       	push   $0xff
f0101ff7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101ffc:	50                   	push   %eax
f0101ffd:	e8 52 11 00 00       	call   f0103154 <memset>
	page_free(pp0);
f0102002:	89 34 24             	mov    %esi,(%esp)
f0102005:	e8 90 ee ff ff       	call   f0100e9a <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f010200a:	83 c4 0c             	add    $0xc,%esp
f010200d:	6a 01                	push   $0x1
f010200f:	6a 00                	push   $0x0
f0102011:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0102017:	e8 e0 ee ff ff       	call   f0100efc <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010201c:	89 f2                	mov    %esi,%edx
f010201e:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0102024:	c1 fa 03             	sar    $0x3,%edx
f0102027:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010202a:	89 d0                	mov    %edx,%eax
f010202c:	c1 e8 0c             	shr    $0xc,%eax
f010202f:	83 c4 10             	add    $0x10,%esp
f0102032:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f0102038:	72 12                	jb     f010204c <mem_init+0xfb5>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010203a:	52                   	push   %edx
f010203b:	68 84 3b 10 f0       	push   $0xf0103b84
f0102040:	6a 52                	push   $0x52
f0102042:	68 0c 43 10 f0       	push   $0xf010430c
f0102047:	e8 db e0 ff ff       	call   f0100127 <_panic>
	return (void *)(pa + KERNBASE);
f010204c:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102052:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102055:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f010205b:	f6 00 01             	testb  $0x1,(%eax)
f010205e:	74 19                	je     f0102079 <mem_init+0xfe2>
f0102060:	68 ad 45 10 f0       	push   $0xf01045ad
f0102065:	68 26 43 10 f0       	push   $0xf0104326
f010206a:	68 92 03 00 00       	push   $0x392
f010206f:	68 00 43 10 f0       	push   $0xf0104300
f0102074:	e8 ae e0 ff ff       	call   f0100127 <_panic>
f0102079:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010207c:	39 d0                	cmp    %edx,%eax
f010207e:	75 db                	jne    f010205b <mem_init+0xfc4>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102080:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0102085:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f010208b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102091:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102094:	a3 3c 65 11 f0       	mov    %eax,0xf011653c

	// free the pages we took
	page_free(pp0);
f0102099:	83 ec 0c             	sub    $0xc,%esp
f010209c:	56                   	push   %esi
f010209d:	e8 f8 ed ff ff       	call   f0100e9a <page_free>
	page_free(pp1);
f01020a2:	89 3c 24             	mov    %edi,(%esp)
f01020a5:	e8 f0 ed ff ff       	call   f0100e9a <page_free>
	page_free(pp2);
f01020aa:	89 1c 24             	mov    %ebx,(%esp)
f01020ad:	e8 e8 ed ff ff       	call   f0100e9a <page_free>

	cprintf("check_page() succeeded!\n");
f01020b2:	c7 04 24 c4 45 10 f0 	movl   $0xf01045c4,(%esp)
f01020b9:	e8 dd 05 00 00       	call   f010269b <cprintf>

	check_page_free_list(1);
	check_page_alloc();
	cprintf("Entering check_page\n");
	check_page();
	cprintf("Exited check_page\n");
f01020be:	c7 04 24 dd 45 10 f0 	movl   $0xf01045dd,(%esp)
f01020c5:	e8 d1 05 00 00       	call   f010269b <cprintf>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01020ca:	8b 35 68 69 11 f0    	mov    0xf0116968,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01020d0:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f01020d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020d8:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01020df:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01020e4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01020e7:	8b 3d 6c 69 11 f0    	mov    0xf011696c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020ed:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01020f0:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01020f3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01020f8:	eb 55                	jmp    f010214f <mem_init+0x10b8>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01020fa:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102100:	89 f0                	mov    %esi,%eax
f0102102:	e8 b9 e8 ff ff       	call   f01009c0 <check_va2pa>
f0102107:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010210e:	77 15                	ja     f0102125 <mem_init+0x108e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102110:	57                   	push   %edi
f0102111:	68 a8 3b 10 f0       	push   $0xf0103ba8
f0102116:	68 d4 02 00 00       	push   $0x2d4
f010211b:	68 00 43 10 f0       	push   $0xf0104300
f0102120:	e8 02 e0 ff ff       	call   f0100127 <_panic>
f0102125:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f010212c:	39 d0                	cmp    %edx,%eax
f010212e:	74 19                	je     f0102149 <mem_init+0x10b2>
f0102130:	68 6c 41 10 f0       	push   $0xf010416c
f0102135:	68 26 43 10 f0       	push   $0xf0104326
f010213a:	68 d4 02 00 00       	push   $0x2d4
f010213f:	68 00 43 10 f0       	push   $0xf0104300
f0102144:	e8 de df ff ff       	call   f0100127 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102149:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010214f:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102152:	77 a6                	ja     f01020fa <mem_init+0x1063>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102154:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0102157:	c1 e7 0c             	shl    $0xc,%edi
f010215a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010215f:	eb 30                	jmp    f0102191 <mem_init+0x10fa>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102161:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f0102167:	89 f0                	mov    %esi,%eax
f0102169:	e8 52 e8 ff ff       	call   f01009c0 <check_va2pa>
f010216e:	39 c3                	cmp    %eax,%ebx
f0102170:	74 19                	je     f010218b <mem_init+0x10f4>
f0102172:	68 a0 41 10 f0       	push   $0xf01041a0
f0102177:	68 26 43 10 f0       	push   $0xf0104326
f010217c:	68 d9 02 00 00       	push   $0x2d9
f0102181:	68 00 43 10 f0       	push   $0xf0104300
f0102186:	e8 9c df ff ff       	call   f0100127 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010218b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102191:	39 fb                	cmp    %edi,%ebx
f0102193:	72 cc                	jb     f0102161 <mem_init+0x10ca>
f0102195:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010219a:	bf 00 c0 10 f0       	mov    $0xf010c000,%edi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010219f:	89 da                	mov    %ebx,%edx
f01021a1:	89 f0                	mov    %esi,%eax
f01021a3:	e8 18 e8 ff ff       	call   f01009c0 <check_va2pa>
f01021a8:	81 ff ff ff ff ef    	cmp    $0xefffffff,%edi
f01021ae:	77 19                	ja     f01021c9 <mem_init+0x1132>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021b0:	68 00 c0 10 f0       	push   $0xf010c000
f01021b5:	68 a8 3b 10 f0       	push   $0xf0103ba8
f01021ba:	68 dd 02 00 00       	push   $0x2dd
f01021bf:	68 00 43 10 f0       	push   $0xf0104300
f01021c4:	e8 5e df ff ff       	call   f0100127 <_panic>
f01021c9:	8d 93 00 40 11 10    	lea    0x10114000(%ebx),%edx
f01021cf:	39 d0                	cmp    %edx,%eax
f01021d1:	74 19                	je     f01021ec <mem_init+0x1155>
f01021d3:	68 c8 41 10 f0       	push   $0xf01041c8
f01021d8:	68 26 43 10 f0       	push   $0xf0104326
f01021dd:	68 dd 02 00 00       	push   $0x2dd
f01021e2:	68 00 43 10 f0       	push   $0xf0104300
f01021e7:	e8 3b df ff ff       	call   f0100127 <_panic>
f01021ec:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01021f2:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01021f8:	75 a5                	jne    f010219f <mem_init+0x1108>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01021fa:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01021ff:	89 f0                	mov    %esi,%eax
f0102201:	e8 ba e7 ff ff       	call   f01009c0 <check_va2pa>
f0102206:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102209:	74 51                	je     f010225c <mem_init+0x11c5>
f010220b:	68 10 42 10 f0       	push   $0xf0104210
f0102210:	68 26 43 10 f0       	push   $0xf0104326
f0102215:	68 de 02 00 00       	push   $0x2de
f010221a:	68 00 43 10 f0       	push   $0xf0104300
f010221f:	e8 03 df ff ff       	call   f0100127 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102224:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f0102229:	72 36                	jb     f0102261 <mem_init+0x11ca>
f010222b:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102230:	76 07                	jbe    f0102239 <mem_init+0x11a2>
f0102232:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102237:	75 28                	jne    f0102261 <mem_init+0x11ca>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f0102239:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f010223d:	0f 85 83 00 00 00    	jne    f01022c6 <mem_init+0x122f>
f0102243:	68 f0 45 10 f0       	push   $0xf01045f0
f0102248:	68 26 43 10 f0       	push   $0xf0104326
f010224d:	68 e6 02 00 00       	push   $0x2e6
f0102252:	68 00 43 10 f0       	push   $0xf0104300
f0102257:	e8 cb de ff ff       	call   f0100127 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010225c:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102261:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102266:	76 3f                	jbe    f01022a7 <mem_init+0x1210>
				assert(pgdir[i] & PTE_P);
f0102268:	8b 14 86             	mov    (%esi,%eax,4),%edx
f010226b:	f6 c2 01             	test   $0x1,%dl
f010226e:	75 19                	jne    f0102289 <mem_init+0x11f2>
f0102270:	68 f0 45 10 f0       	push   $0xf01045f0
f0102275:	68 26 43 10 f0       	push   $0xf0104326
f010227a:	68 ea 02 00 00       	push   $0x2ea
f010227f:	68 00 43 10 f0       	push   $0xf0104300
f0102284:	e8 9e de ff ff       	call   f0100127 <_panic>
				assert(pgdir[i] & PTE_W);
f0102289:	f6 c2 02             	test   $0x2,%dl
f010228c:	75 38                	jne    f01022c6 <mem_init+0x122f>
f010228e:	68 01 46 10 f0       	push   $0xf0104601
f0102293:	68 26 43 10 f0       	push   $0xf0104326
f0102298:	68 eb 02 00 00       	push   $0x2eb
f010229d:	68 00 43 10 f0       	push   $0xf0104300
f01022a2:	e8 80 de ff ff       	call   f0100127 <_panic>
			} else
				assert(pgdir[i] == 0);
f01022a7:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f01022ab:	74 19                	je     f01022c6 <mem_init+0x122f>
f01022ad:	68 12 46 10 f0       	push   $0xf0104612
f01022b2:	68 26 43 10 f0       	push   $0xf0104326
f01022b7:	68 ed 02 00 00       	push   $0x2ed
f01022bc:	68 00 43 10 f0       	push   $0xf0104300
f01022c1:	e8 61 de ff ff       	call   f0100127 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01022c6:	83 c0 01             	add    $0x1,%eax
f01022c9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f01022ce:	0f 86 50 ff ff ff    	jbe    f0102224 <mem_init+0x118d>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01022d4:	83 ec 0c             	sub    $0xc,%esp
f01022d7:	68 40 42 10 f0       	push   $0xf0104240
f01022dc:	e8 ba 03 00 00       	call   f010269b <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01022e1:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022e6:	83 c4 10             	add    $0x10,%esp
f01022e9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022ee:	77 15                	ja     f0102305 <mem_init+0x126e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022f0:	50                   	push   %eax
f01022f1:	68 a8 3b 10 f0       	push   $0xf0103ba8
f01022f6:	68 d8 00 00 00       	push   $0xd8
f01022fb:	68 00 43 10 f0       	push   $0xf0104300
f0102300:	e8 22 de ff ff       	call   f0100127 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102305:	05 00 00 00 10       	add    $0x10000000,%eax
f010230a:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010230d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102312:	e8 7b e7 ff ff       	call   f0100a92 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102317:	0f 20 c0             	mov    %cr0,%eax
f010231a:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010231d:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102322:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102325:	83 ec 0c             	sub    $0xc,%esp
f0102328:	6a 00                	push   $0x0
f010232a:	e8 eb ea ff ff       	call   f0100e1a <page_alloc>
f010232f:	89 c3                	mov    %eax,%ebx
f0102331:	83 c4 10             	add    $0x10,%esp
f0102334:	85 c0                	test   %eax,%eax
f0102336:	75 19                	jne    f0102351 <mem_init+0x12ba>
f0102338:	68 e6 43 10 f0       	push   $0xf01043e6
f010233d:	68 26 43 10 f0       	push   $0xf0104326
f0102342:	68 ad 03 00 00       	push   $0x3ad
f0102347:	68 00 43 10 f0       	push   $0xf0104300
f010234c:	e8 d6 dd ff ff       	call   f0100127 <_panic>
	assert((pp1 = page_alloc(0)));
f0102351:	83 ec 0c             	sub    $0xc,%esp
f0102354:	6a 00                	push   $0x0
f0102356:	e8 bf ea ff ff       	call   f0100e1a <page_alloc>
f010235b:	89 c7                	mov    %eax,%edi
f010235d:	83 c4 10             	add    $0x10,%esp
f0102360:	85 c0                	test   %eax,%eax
f0102362:	75 19                	jne    f010237d <mem_init+0x12e6>
f0102364:	68 fc 43 10 f0       	push   $0xf01043fc
f0102369:	68 26 43 10 f0       	push   $0xf0104326
f010236e:	68 ae 03 00 00       	push   $0x3ae
f0102373:	68 00 43 10 f0       	push   $0xf0104300
f0102378:	e8 aa dd ff ff       	call   f0100127 <_panic>
	assert((pp2 = page_alloc(0)));
f010237d:	83 ec 0c             	sub    $0xc,%esp
f0102380:	6a 00                	push   $0x0
f0102382:	e8 93 ea ff ff       	call   f0100e1a <page_alloc>
f0102387:	89 c6                	mov    %eax,%esi
f0102389:	83 c4 10             	add    $0x10,%esp
f010238c:	85 c0                	test   %eax,%eax
f010238e:	75 19                	jne    f01023a9 <mem_init+0x1312>
f0102390:	68 12 44 10 f0       	push   $0xf0104412
f0102395:	68 26 43 10 f0       	push   $0xf0104326
f010239a:	68 af 03 00 00       	push   $0x3af
f010239f:	68 00 43 10 f0       	push   $0xf0104300
f01023a4:	e8 7e dd ff ff       	call   f0100127 <_panic>
	page_free(pp0);
f01023a9:	83 ec 0c             	sub    $0xc,%esp
f01023ac:	53                   	push   %ebx
f01023ad:	e8 e8 ea ff ff       	call   f0100e9a <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023b2:	89 f8                	mov    %edi,%eax
f01023b4:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01023ba:	c1 f8 03             	sar    $0x3,%eax
f01023bd:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023c0:	89 c2                	mov    %eax,%edx
f01023c2:	c1 ea 0c             	shr    $0xc,%edx
f01023c5:	83 c4 10             	add    $0x10,%esp
f01023c8:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f01023ce:	72 12                	jb     f01023e2 <mem_init+0x134b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023d0:	50                   	push   %eax
f01023d1:	68 84 3b 10 f0       	push   $0xf0103b84
f01023d6:	6a 52                	push   $0x52
f01023d8:	68 0c 43 10 f0       	push   $0xf010430c
f01023dd:	e8 45 dd ff ff       	call   f0100127 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01023e2:	83 ec 04             	sub    $0x4,%esp
f01023e5:	68 00 10 00 00       	push   $0x1000
f01023ea:	6a 01                	push   $0x1
f01023ec:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023f1:	50                   	push   %eax
f01023f2:	e8 5d 0d 00 00       	call   f0103154 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023f7:	89 f0                	mov    %esi,%eax
f01023f9:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01023ff:	c1 f8 03             	sar    $0x3,%eax
f0102402:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102405:	89 c2                	mov    %eax,%edx
f0102407:	c1 ea 0c             	shr    $0xc,%edx
f010240a:	83 c4 10             	add    $0x10,%esp
f010240d:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0102413:	72 12                	jb     f0102427 <mem_init+0x1390>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102415:	50                   	push   %eax
f0102416:	68 84 3b 10 f0       	push   $0xf0103b84
f010241b:	6a 52                	push   $0x52
f010241d:	68 0c 43 10 f0       	push   $0xf010430c
f0102422:	e8 00 dd ff ff       	call   f0100127 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102427:	83 ec 04             	sub    $0x4,%esp
f010242a:	68 00 10 00 00       	push   $0x1000
f010242f:	6a 02                	push   $0x2
f0102431:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102436:	50                   	push   %eax
f0102437:	e8 18 0d 00 00       	call   f0103154 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010243c:	6a 02                	push   $0x2
f010243e:	68 00 10 00 00       	push   $0x1000
f0102443:	57                   	push   %edi
f0102444:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010244a:	e8 d0 eb ff ff       	call   f010101f <page_insert>
	assert(pp1->pp_ref == 1);
f010244f:	83 c4 20             	add    $0x20,%esp
f0102452:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102457:	74 19                	je     f0102472 <mem_init+0x13db>
f0102459:	68 f8 44 10 f0       	push   $0xf01044f8
f010245e:	68 26 43 10 f0       	push   $0xf0104326
f0102463:	68 b4 03 00 00       	push   $0x3b4
f0102468:	68 00 43 10 f0       	push   $0xf0104300
f010246d:	e8 b5 dc ff ff       	call   f0100127 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102472:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102479:	01 01 01 
f010247c:	74 19                	je     f0102497 <mem_init+0x1400>
f010247e:	68 60 42 10 f0       	push   $0xf0104260
f0102483:	68 26 43 10 f0       	push   $0xf0104326
f0102488:	68 b5 03 00 00       	push   $0x3b5
f010248d:	68 00 43 10 f0       	push   $0xf0104300
f0102492:	e8 90 dc ff ff       	call   f0100127 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102497:	6a 02                	push   $0x2
f0102499:	68 00 10 00 00       	push   $0x1000
f010249e:	56                   	push   %esi
f010249f:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01024a5:	e8 75 eb ff ff       	call   f010101f <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01024aa:	83 c4 10             	add    $0x10,%esp
f01024ad:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01024b4:	02 02 02 
f01024b7:	74 19                	je     f01024d2 <mem_init+0x143b>
f01024b9:	68 84 42 10 f0       	push   $0xf0104284
f01024be:	68 26 43 10 f0       	push   $0xf0104326
f01024c3:	68 b7 03 00 00       	push   $0x3b7
f01024c8:	68 00 43 10 f0       	push   $0xf0104300
f01024cd:	e8 55 dc ff ff       	call   f0100127 <_panic>
	assert(pp2->pp_ref == 1);
f01024d2:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024d7:	74 19                	je     f01024f2 <mem_init+0x145b>
f01024d9:	68 1a 45 10 f0       	push   $0xf010451a
f01024de:	68 26 43 10 f0       	push   $0xf0104326
f01024e3:	68 b8 03 00 00       	push   $0x3b8
f01024e8:	68 00 43 10 f0       	push   $0xf0104300
f01024ed:	e8 35 dc ff ff       	call   f0100127 <_panic>
	assert(pp1->pp_ref == 0);
f01024f2:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01024f7:	74 19                	je     f0102512 <mem_init+0x147b>
f01024f9:	68 84 45 10 f0       	push   $0xf0104584
f01024fe:	68 26 43 10 f0       	push   $0xf0104326
f0102503:	68 b9 03 00 00       	push   $0x3b9
f0102508:	68 00 43 10 f0       	push   $0xf0104300
f010250d:	e8 15 dc ff ff       	call   f0100127 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102512:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102519:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010251c:	89 f0                	mov    %esi,%eax
f010251e:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0102524:	c1 f8 03             	sar    $0x3,%eax
f0102527:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010252a:	89 c2                	mov    %eax,%edx
f010252c:	c1 ea 0c             	shr    $0xc,%edx
f010252f:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0102535:	72 12                	jb     f0102549 <mem_init+0x14b2>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102537:	50                   	push   %eax
f0102538:	68 84 3b 10 f0       	push   $0xf0103b84
f010253d:	6a 52                	push   $0x52
f010253f:	68 0c 43 10 f0       	push   $0xf010430c
f0102544:	e8 de db ff ff       	call   f0100127 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102549:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102550:	03 03 03 
f0102553:	74 19                	je     f010256e <mem_init+0x14d7>
f0102555:	68 a8 42 10 f0       	push   $0xf01042a8
f010255a:	68 26 43 10 f0       	push   $0xf0104326
f010255f:	68 bb 03 00 00       	push   $0x3bb
f0102564:	68 00 43 10 f0       	push   $0xf0104300
f0102569:	e8 b9 db ff ff       	call   f0100127 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010256e:	83 ec 08             	sub    $0x8,%esp
f0102571:	68 00 10 00 00       	push   $0x1000
f0102576:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010257c:	e8 63 ea ff ff       	call   f0100fe4 <page_remove>
	assert(pp2->pp_ref == 0);
f0102581:	83 c4 10             	add    $0x10,%esp
f0102584:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102589:	74 19                	je     f01025a4 <mem_init+0x150d>
f010258b:	68 52 45 10 f0       	push   $0xf0104552
f0102590:	68 26 43 10 f0       	push   $0xf0104326
f0102595:	68 bd 03 00 00       	push   $0x3bd
f010259a:	68 00 43 10 f0       	push   $0xf0104300
f010259f:	e8 83 db ff ff       	call   f0100127 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01025a4:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f01025aa:	8b 11                	mov    (%ecx),%edx
f01025ac:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01025b2:	89 d8                	mov    %ebx,%eax
f01025b4:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01025ba:	c1 f8 03             	sar    $0x3,%eax
f01025bd:	c1 e0 0c             	shl    $0xc,%eax
f01025c0:	39 c2                	cmp    %eax,%edx
f01025c2:	74 19                	je     f01025dd <mem_init+0x1546>
f01025c4:	68 1c 3e 10 f0       	push   $0xf0103e1c
f01025c9:	68 26 43 10 f0       	push   $0xf0104326
f01025ce:	68 c0 03 00 00       	push   $0x3c0
f01025d3:	68 00 43 10 f0       	push   $0xf0104300
f01025d8:	e8 4a db ff ff       	call   f0100127 <_panic>
	kern_pgdir[0] = 0;
f01025dd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01025e3:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01025e8:	74 19                	je     f0102603 <mem_init+0x156c>
f01025ea:	68 09 45 10 f0       	push   $0xf0104509
f01025ef:	68 26 43 10 f0       	push   $0xf0104326
f01025f4:	68 c2 03 00 00       	push   $0x3c2
f01025f9:	68 00 43 10 f0       	push   $0xf0104300
f01025fe:	e8 24 db ff ff       	call   f0100127 <_panic>
	pp0->pp_ref = 0;
f0102603:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102609:	83 ec 0c             	sub    $0xc,%esp
f010260c:	53                   	push   %ebx
f010260d:	e8 88 e8 ff ff       	call   f0100e9a <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102612:	c7 04 24 d4 42 10 f0 	movl   $0xf01042d4,(%esp)
f0102619:	e8 7d 00 00 00       	call   f010269b <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010261e:	83 c4 10             	add    $0x10,%esp
f0102621:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102624:	5b                   	pop    %ebx
f0102625:	5e                   	pop    %esi
f0102626:	5f                   	pop    %edi
f0102627:	5d                   	pop    %ebp
f0102628:	c3                   	ret    

f0102629 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102629:	55                   	push   %ebp
f010262a:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010262c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010262f:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102632:	5d                   	pop    %ebp
f0102633:	c3                   	ret    

f0102634 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102634:	55                   	push   %ebp
f0102635:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102637:	ba 70 00 00 00       	mov    $0x70,%edx
f010263c:	8b 45 08             	mov    0x8(%ebp),%eax
f010263f:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102640:	ba 71 00 00 00       	mov    $0x71,%edx
f0102645:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102646:	0f b6 c0             	movzbl %al,%eax
}
f0102649:	5d                   	pop    %ebp
f010264a:	c3                   	ret    

f010264b <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010264b:	55                   	push   %ebp
f010264c:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010264e:	ba 70 00 00 00       	mov    $0x70,%edx
f0102653:	8b 45 08             	mov    0x8(%ebp),%eax
f0102656:	ee                   	out    %al,(%dx)
f0102657:	ba 71 00 00 00       	mov    $0x71,%edx
f010265c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010265f:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102660:	5d                   	pop    %ebp
f0102661:	c3                   	ret    

f0102662 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102662:	55                   	push   %ebp
f0102663:	89 e5                	mov    %esp,%ebp
f0102665:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102668:	ff 75 08             	pushl  0x8(%ebp)
f010266b:	e8 2c e0 ff ff       	call   f010069c <cputchar>
	*cnt++;
}
f0102670:	83 c4 10             	add    $0x10,%esp
f0102673:	c9                   	leave  
f0102674:	c3                   	ret    

f0102675 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102675:	55                   	push   %ebp
f0102676:	89 e5                	mov    %esp,%ebp
f0102678:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010267b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102682:	ff 75 0c             	pushl  0xc(%ebp)
f0102685:	ff 75 08             	pushl  0x8(%ebp)
f0102688:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010268b:	50                   	push   %eax
f010268c:	68 62 26 10 f0       	push   $0xf0102662
f0102691:	e8 52 04 00 00       	call   f0102ae8 <vprintfmt>
	return cnt;
}
f0102696:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102699:	c9                   	leave  
f010269a:	c3                   	ret    

f010269b <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010269b:	55                   	push   %ebp
f010269c:	89 e5                	mov    %esp,%ebp
f010269e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01026a1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01026a4:	50                   	push   %eax
f01026a5:	ff 75 08             	pushl  0x8(%ebp)
f01026a8:	e8 c8 ff ff ff       	call   f0102675 <vcprintf>
	va_end(ap);

	return cnt;
}
f01026ad:	c9                   	leave  
f01026ae:	c3                   	ret    

f01026af <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01026af:	55                   	push   %ebp
f01026b0:	89 e5                	mov    %esp,%ebp
f01026b2:	57                   	push   %edi
f01026b3:	56                   	push   %esi
f01026b4:	53                   	push   %ebx
f01026b5:	83 ec 14             	sub    $0x14,%esp
f01026b8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01026bb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01026be:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01026c1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01026c4:	8b 1a                	mov    (%edx),%ebx
f01026c6:	8b 01                	mov    (%ecx),%eax
f01026c8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01026cb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01026d2:	eb 7f                	jmp    f0102753 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01026d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01026d7:	01 d8                	add    %ebx,%eax
f01026d9:	89 c6                	mov    %eax,%esi
f01026db:	c1 ee 1f             	shr    $0x1f,%esi
f01026de:	01 c6                	add    %eax,%esi
f01026e0:	d1 fe                	sar    %esi
f01026e2:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01026e5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01026e8:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01026eb:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01026ed:	eb 03                	jmp    f01026f2 <stab_binsearch+0x43>
			m--;
f01026ef:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01026f2:	39 c3                	cmp    %eax,%ebx
f01026f4:	7f 0d                	jg     f0102703 <stab_binsearch+0x54>
f01026f6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01026fa:	83 ea 0c             	sub    $0xc,%edx
f01026fd:	39 f9                	cmp    %edi,%ecx
f01026ff:	75 ee                	jne    f01026ef <stab_binsearch+0x40>
f0102701:	eb 05                	jmp    f0102708 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102703:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0102706:	eb 4b                	jmp    f0102753 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102708:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010270b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010270e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0102712:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0102715:	76 11                	jbe    f0102728 <stab_binsearch+0x79>
			*region_left = m;
f0102717:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010271a:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010271c:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010271f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102726:	eb 2b                	jmp    f0102753 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102728:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010272b:	73 14                	jae    f0102741 <stab_binsearch+0x92>
			*region_right = m - 1;
f010272d:	83 e8 01             	sub    $0x1,%eax
f0102730:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102733:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102736:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102738:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010273f:	eb 12                	jmp    f0102753 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102741:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102744:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102746:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010274a:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010274c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102753:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102756:	0f 8e 78 ff ff ff    	jle    f01026d4 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010275c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102760:	75 0f                	jne    f0102771 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0102762:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102765:	8b 00                	mov    (%eax),%eax
f0102767:	83 e8 01             	sub    $0x1,%eax
f010276a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010276d:	89 06                	mov    %eax,(%esi)
f010276f:	eb 2c                	jmp    f010279d <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102771:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102774:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102776:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102779:	8b 0e                	mov    (%esi),%ecx
f010277b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010277e:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102781:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102784:	eb 03                	jmp    f0102789 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102786:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102789:	39 c8                	cmp    %ecx,%eax
f010278b:	7e 0b                	jle    f0102798 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010278d:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0102791:	83 ea 0c             	sub    $0xc,%edx
f0102794:	39 df                	cmp    %ebx,%edi
f0102796:	75 ee                	jne    f0102786 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102798:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010279b:	89 06                	mov    %eax,(%esi)
	}
}
f010279d:	83 c4 14             	add    $0x14,%esp
f01027a0:	5b                   	pop    %ebx
f01027a1:	5e                   	pop    %esi
f01027a2:	5f                   	pop    %edi
f01027a3:	5d                   	pop    %ebp
f01027a4:	c3                   	ret    

f01027a5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01027a5:	55                   	push   %ebp
f01027a6:	89 e5                	mov    %esp,%ebp
f01027a8:	57                   	push   %edi
f01027a9:	56                   	push   %esi
f01027aa:	53                   	push   %ebx
f01027ab:	83 ec 3c             	sub    $0x3c,%esp
f01027ae:	8b 75 08             	mov    0x8(%ebp),%esi
f01027b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01027b4:	c7 03 20 46 10 f0    	movl   $0xf0104620,(%ebx)
	info->eip_line = 0;
f01027ba:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01027c1:	c7 43 08 20 46 10 f0 	movl   $0xf0104620,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01027c8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01027cf:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01027d2:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01027d9:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01027df:	76 11                	jbe    f01027f2 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01027e1:	b8 5b bf 10 f0       	mov    $0xf010bf5b,%eax
f01027e6:	3d 65 a1 10 f0       	cmp    $0xf010a165,%eax
f01027eb:	77 19                	ja     f0102806 <debuginfo_eip+0x61>
f01027ed:	e9 aa 01 00 00       	jmp    f010299c <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01027f2:	83 ec 04             	sub    $0x4,%esp
f01027f5:	68 2a 46 10 f0       	push   $0xf010462a
f01027fa:	6a 7f                	push   $0x7f
f01027fc:	68 37 46 10 f0       	push   $0xf0104637
f0102801:	e8 21 d9 ff ff       	call   f0100127 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0102806:	80 3d 5a bf 10 f0 00 	cmpb   $0x0,0xf010bf5a
f010280d:	0f 85 90 01 00 00    	jne    f01029a3 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0102813:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010281a:	b8 64 a1 10 f0       	mov    $0xf010a164,%eax
f010281f:	2d 54 48 10 f0       	sub    $0xf0104854,%eax
f0102824:	c1 f8 02             	sar    $0x2,%eax
f0102827:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010282d:	83 e8 01             	sub    $0x1,%eax
f0102830:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102833:	83 ec 08             	sub    $0x8,%esp
f0102836:	56                   	push   %esi
f0102837:	6a 64                	push   $0x64
f0102839:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010283c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010283f:	b8 54 48 10 f0       	mov    $0xf0104854,%eax
f0102844:	e8 66 fe ff ff       	call   f01026af <stab_binsearch>
	if (lfile == 0)
f0102849:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010284c:	83 c4 10             	add    $0x10,%esp
f010284f:	85 c0                	test   %eax,%eax
f0102851:	0f 84 53 01 00 00    	je     f01029aa <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102857:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010285a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010285d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102860:	83 ec 08             	sub    $0x8,%esp
f0102863:	56                   	push   %esi
f0102864:	6a 24                	push   $0x24
f0102866:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0102869:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010286c:	b8 54 48 10 f0       	mov    $0xf0104854,%eax
f0102871:	e8 39 fe ff ff       	call   f01026af <stab_binsearch>

	if (lfun <= rfun) {
f0102876:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102879:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010287c:	83 c4 10             	add    $0x10,%esp
f010287f:	39 d0                	cmp    %edx,%eax
f0102881:	7f 40                	jg     f01028c3 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102883:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0102886:	c1 e1 02             	shl    $0x2,%ecx
f0102889:	8d b9 54 48 10 f0    	lea    -0xfefb7ac(%ecx),%edi
f010288f:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0102892:	8b b9 54 48 10 f0    	mov    -0xfefb7ac(%ecx),%edi
f0102898:	b9 5b bf 10 f0       	mov    $0xf010bf5b,%ecx
f010289d:	81 e9 65 a1 10 f0    	sub    $0xf010a165,%ecx
f01028a3:	39 cf                	cmp    %ecx,%edi
f01028a5:	73 09                	jae    f01028b0 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01028a7:	81 c7 65 a1 10 f0    	add    $0xf010a165,%edi
f01028ad:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01028b0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01028b3:	8b 4f 08             	mov    0x8(%edi),%ecx
f01028b6:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01028b9:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01028bb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01028be:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01028c1:	eb 0f                	jmp    f01028d2 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01028c3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01028c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01028c9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01028cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01028cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01028d2:	83 ec 08             	sub    $0x8,%esp
f01028d5:	6a 3a                	push   $0x3a
f01028d7:	ff 73 08             	pushl  0x8(%ebx)
f01028da:	e8 59 08 00 00       	call   f0103138 <strfind>
f01028df:	2b 43 08             	sub    0x8(%ebx),%eax
f01028e2:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f01028e5:	83 c4 08             	add    $0x8,%esp
f01028e8:	56                   	push   %esi
f01028e9:	6a 44                	push   $0x44
f01028eb:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f01028ee:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f01028f1:	b8 54 48 10 f0       	mov    $0xf0104854,%eax
f01028f6:	e8 b4 fd ff ff       	call   f01026af <stab_binsearch>
	if (lline <= rline) {
f01028fb:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f01028fe:	83 c4 10             	add    $0x10,%esp
f0102901:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0102904:	0f 8f a7 00 00 00    	jg     f01029b1 <debuginfo_eip+0x20c>
		info->eip_line = stabs[lline].n_desc;
f010290a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f010290d:	8d 04 85 54 48 10 f0 	lea    -0xfefb7ac(,%eax,4),%eax
f0102914:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0102918:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010291b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010291e:	eb 06                	jmp    f0102926 <debuginfo_eip+0x181>
f0102920:	83 ea 01             	sub    $0x1,%edx
f0102923:	83 e8 0c             	sub    $0xc,%eax
f0102926:	39 d6                	cmp    %edx,%esi
f0102928:	7f 34                	jg     f010295e <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f010292a:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f010292e:	80 f9 84             	cmp    $0x84,%cl
f0102931:	74 0b                	je     f010293e <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0102933:	80 f9 64             	cmp    $0x64,%cl
f0102936:	75 e8                	jne    f0102920 <debuginfo_eip+0x17b>
f0102938:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f010293c:	74 e2                	je     f0102920 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010293e:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0102941:	8b 14 85 54 48 10 f0 	mov    -0xfefb7ac(,%eax,4),%edx
f0102948:	b8 5b bf 10 f0       	mov    $0xf010bf5b,%eax
f010294d:	2d 65 a1 10 f0       	sub    $0xf010a165,%eax
f0102952:	39 c2                	cmp    %eax,%edx
f0102954:	73 08                	jae    f010295e <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0102956:	81 c2 65 a1 10 f0    	add    $0xf010a165,%edx
f010295c:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010295e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102961:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102964:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0102969:	39 f2                	cmp    %esi,%edx
f010296b:	7d 50                	jge    f01029bd <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f010296d:	83 c2 01             	add    $0x1,%edx
f0102970:	89 d0                	mov    %edx,%eax
f0102972:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0102975:	8d 14 95 54 48 10 f0 	lea    -0xfefb7ac(,%edx,4),%edx
f010297c:	eb 04                	jmp    f0102982 <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010297e:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102982:	39 c6                	cmp    %eax,%esi
f0102984:	7e 32                	jle    f01029b8 <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102986:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010298a:	83 c0 01             	add    $0x1,%eax
f010298d:	83 c2 0c             	add    $0xc,%edx
f0102990:	80 f9 a0             	cmp    $0xa0,%cl
f0102993:	74 e9                	je     f010297e <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0102995:	b8 00 00 00 00       	mov    $0x0,%eax
f010299a:	eb 21                	jmp    f01029bd <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010299c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029a1:	eb 1a                	jmp    f01029bd <debuginfo_eip+0x218>
f01029a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029a8:	eb 13                	jmp    f01029bd <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01029aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029af:	eb 0c                	jmp    f01029bd <debuginfo_eip+0x218>
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;
f01029b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01029b6:	eb 05                	jmp    f01029bd <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01029b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01029bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029c0:	5b                   	pop    %ebx
f01029c1:	5e                   	pop    %esi
f01029c2:	5f                   	pop    %edi
f01029c3:	5d                   	pop    %ebp
f01029c4:	c3                   	ret    

f01029c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01029c5:	55                   	push   %ebp
f01029c6:	89 e5                	mov    %esp,%ebp
f01029c8:	57                   	push   %edi
f01029c9:	56                   	push   %esi
f01029ca:	53                   	push   %ebx
f01029cb:	83 ec 1c             	sub    $0x1c,%esp
f01029ce:	89 c7                	mov    %eax,%edi
f01029d0:	89 d6                	mov    %edx,%esi
f01029d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01029d5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01029d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01029db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01029de:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01029e1:	bb 00 00 00 00       	mov    $0x0,%ebx
f01029e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01029e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01029ec:	39 d3                	cmp    %edx,%ebx
f01029ee:	72 05                	jb     f01029f5 <printnum+0x30>
f01029f0:	39 45 10             	cmp    %eax,0x10(%ebp)
f01029f3:	77 45                	ja     f0102a3a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01029f5:	83 ec 0c             	sub    $0xc,%esp
f01029f8:	ff 75 18             	pushl  0x18(%ebp)
f01029fb:	8b 45 14             	mov    0x14(%ebp),%eax
f01029fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102a01:	53                   	push   %ebx
f0102a02:	ff 75 10             	pushl  0x10(%ebp)
f0102a05:	83 ec 08             	sub    $0x8,%esp
f0102a08:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102a0b:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a0e:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a11:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a14:	e8 47 09 00 00       	call   f0103360 <__udivdi3>
f0102a19:	83 c4 18             	add    $0x18,%esp
f0102a1c:	52                   	push   %edx
f0102a1d:	50                   	push   %eax
f0102a1e:	89 f2                	mov    %esi,%edx
f0102a20:	89 f8                	mov    %edi,%eax
f0102a22:	e8 9e ff ff ff       	call   f01029c5 <printnum>
f0102a27:	83 c4 20             	add    $0x20,%esp
f0102a2a:	eb 18                	jmp    f0102a44 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0102a2c:	83 ec 08             	sub    $0x8,%esp
f0102a2f:	56                   	push   %esi
f0102a30:	ff 75 18             	pushl  0x18(%ebp)
f0102a33:	ff d7                	call   *%edi
f0102a35:	83 c4 10             	add    $0x10,%esp
f0102a38:	eb 03                	jmp    f0102a3d <printnum+0x78>
f0102a3a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0102a3d:	83 eb 01             	sub    $0x1,%ebx
f0102a40:	85 db                	test   %ebx,%ebx
f0102a42:	7f e8                	jg     f0102a2c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0102a44:	83 ec 08             	sub    $0x8,%esp
f0102a47:	56                   	push   %esi
f0102a48:	83 ec 04             	sub    $0x4,%esp
f0102a4b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0102a4e:	ff 75 e0             	pushl  -0x20(%ebp)
f0102a51:	ff 75 dc             	pushl  -0x24(%ebp)
f0102a54:	ff 75 d8             	pushl  -0x28(%ebp)
f0102a57:	e8 34 0a 00 00       	call   f0103490 <__umoddi3>
f0102a5c:	83 c4 14             	add    $0x14,%esp
f0102a5f:	0f be 80 45 46 10 f0 	movsbl -0xfefb9bb(%eax),%eax
f0102a66:	50                   	push   %eax
f0102a67:	ff d7                	call   *%edi
}
f0102a69:	83 c4 10             	add    $0x10,%esp
f0102a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a6f:	5b                   	pop    %ebx
f0102a70:	5e                   	pop    %esi
f0102a71:	5f                   	pop    %edi
f0102a72:	5d                   	pop    %ebp
f0102a73:	c3                   	ret    

f0102a74 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0102a74:	55                   	push   %ebp
f0102a75:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0102a77:	83 fa 01             	cmp    $0x1,%edx
f0102a7a:	7e 0e                	jle    f0102a8a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0102a7c:	8b 10                	mov    (%eax),%edx
f0102a7e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0102a81:	89 08                	mov    %ecx,(%eax)
f0102a83:	8b 02                	mov    (%edx),%eax
f0102a85:	8b 52 04             	mov    0x4(%edx),%edx
f0102a88:	eb 22                	jmp    f0102aac <getuint+0x38>
	else if (lflag)
f0102a8a:	85 d2                	test   %edx,%edx
f0102a8c:	74 10                	je     f0102a9e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0102a8e:	8b 10                	mov    (%eax),%edx
f0102a90:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102a93:	89 08                	mov    %ecx,(%eax)
f0102a95:	8b 02                	mov    (%edx),%eax
f0102a97:	ba 00 00 00 00       	mov    $0x0,%edx
f0102a9c:	eb 0e                	jmp    f0102aac <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0102a9e:	8b 10                	mov    (%eax),%edx
f0102aa0:	8d 4a 04             	lea    0x4(%edx),%ecx
f0102aa3:	89 08                	mov    %ecx,(%eax)
f0102aa5:	8b 02                	mov    (%edx),%eax
f0102aa7:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0102aac:	5d                   	pop    %ebp
f0102aad:	c3                   	ret    

f0102aae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0102aae:	55                   	push   %ebp
f0102aaf:	89 e5                	mov    %esp,%ebp
f0102ab1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0102ab4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102ab8:	8b 10                	mov    (%eax),%edx
f0102aba:	3b 50 04             	cmp    0x4(%eax),%edx
f0102abd:	73 0a                	jae    f0102ac9 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102abf:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102ac2:	89 08                	mov    %ecx,(%eax)
f0102ac4:	8b 45 08             	mov    0x8(%ebp),%eax
f0102ac7:	88 02                	mov    %al,(%edx)
}
f0102ac9:	5d                   	pop    %ebp
f0102aca:	c3                   	ret    

f0102acb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102acb:	55                   	push   %ebp
f0102acc:	89 e5                	mov    %esp,%ebp
f0102ace:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102ad1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102ad4:	50                   	push   %eax
f0102ad5:	ff 75 10             	pushl  0x10(%ebp)
f0102ad8:	ff 75 0c             	pushl  0xc(%ebp)
f0102adb:	ff 75 08             	pushl  0x8(%ebp)
f0102ade:	e8 05 00 00 00       	call   f0102ae8 <vprintfmt>
	va_end(ap);
}
f0102ae3:	83 c4 10             	add    $0x10,%esp
f0102ae6:	c9                   	leave  
f0102ae7:	c3                   	ret    

f0102ae8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102ae8:	55                   	push   %ebp
f0102ae9:	89 e5                	mov    %esp,%ebp
f0102aeb:	57                   	push   %edi
f0102aec:	56                   	push   %esi
f0102aed:	53                   	push   %ebx
f0102aee:	83 ec 2c             	sub    $0x2c,%esp
f0102af1:	8b 75 08             	mov    0x8(%ebp),%esi
f0102af4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102af7:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102afa:	eb 12                	jmp    f0102b0e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102afc:	85 c0                	test   %eax,%eax
f0102afe:	0f 84 89 03 00 00    	je     f0102e8d <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0102b04:	83 ec 08             	sub    $0x8,%esp
f0102b07:	53                   	push   %ebx
f0102b08:	50                   	push   %eax
f0102b09:	ff d6                	call   *%esi
f0102b0b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102b0e:	83 c7 01             	add    $0x1,%edi
f0102b11:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102b15:	83 f8 25             	cmp    $0x25,%eax
f0102b18:	75 e2                	jne    f0102afc <vprintfmt+0x14>
f0102b1a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102b1e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102b25:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102b2c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102b33:	ba 00 00 00 00       	mov    $0x0,%edx
f0102b38:	eb 07                	jmp    f0102b41 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102b3d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b41:	8d 47 01             	lea    0x1(%edi),%eax
f0102b44:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102b47:	0f b6 07             	movzbl (%edi),%eax
f0102b4a:	0f b6 c8             	movzbl %al,%ecx
f0102b4d:	83 e8 23             	sub    $0x23,%eax
f0102b50:	3c 55                	cmp    $0x55,%al
f0102b52:	0f 87 1a 03 00 00    	ja     f0102e72 <vprintfmt+0x38a>
f0102b58:	0f b6 c0             	movzbl %al,%eax
f0102b5b:	ff 24 85 d0 46 10 f0 	jmp    *-0xfefb930(,%eax,4)
f0102b62:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102b65:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102b69:	eb d6                	jmp    f0102b41 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102b6e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b73:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102b76:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102b79:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0102b7d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0102b80:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0102b83:	83 fa 09             	cmp    $0x9,%edx
f0102b86:	77 39                	ja     f0102bc1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102b88:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102b8b:	eb e9                	jmp    f0102b76 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102b8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b90:	8d 48 04             	lea    0x4(%eax),%ecx
f0102b93:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0102b96:	8b 00                	mov    (%eax),%eax
f0102b98:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102b9e:	eb 27                	jmp    f0102bc7 <vprintfmt+0xdf>
f0102ba0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102ba3:	85 c0                	test   %eax,%eax
f0102ba5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102baa:	0f 49 c8             	cmovns %eax,%ecx
f0102bad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102bb0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102bb3:	eb 8c                	jmp    f0102b41 <vprintfmt+0x59>
f0102bb5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102bb8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102bbf:	eb 80                	jmp    f0102b41 <vprintfmt+0x59>
f0102bc1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0102bc4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102bc7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102bcb:	0f 89 70 ff ff ff    	jns    f0102b41 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102bd1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102bd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102bd7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102bde:	e9 5e ff ff ff       	jmp    f0102b41 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102be3:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102be6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102be9:	e9 53 ff ff ff       	jmp    f0102b41 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102bee:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bf1:	8d 50 04             	lea    0x4(%eax),%edx
f0102bf4:	89 55 14             	mov    %edx,0x14(%ebp)
f0102bf7:	83 ec 08             	sub    $0x8,%esp
f0102bfa:	53                   	push   %ebx
f0102bfb:	ff 30                	pushl  (%eax)
f0102bfd:	ff d6                	call   *%esi
			break;
f0102bff:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c02:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102c05:	e9 04 ff ff ff       	jmp    f0102b0e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102c0a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c0d:	8d 50 04             	lea    0x4(%eax),%edx
f0102c10:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c13:	8b 00                	mov    (%eax),%eax
f0102c15:	99                   	cltd   
f0102c16:	31 d0                	xor    %edx,%eax
f0102c18:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102c1a:	83 f8 06             	cmp    $0x6,%eax
f0102c1d:	7f 0b                	jg     f0102c2a <vprintfmt+0x142>
f0102c1f:	8b 14 85 28 48 10 f0 	mov    -0xfefb7d8(,%eax,4),%edx
f0102c26:	85 d2                	test   %edx,%edx
f0102c28:	75 18                	jne    f0102c42 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0102c2a:	50                   	push   %eax
f0102c2b:	68 5d 46 10 f0       	push   $0xf010465d
f0102c30:	53                   	push   %ebx
f0102c31:	56                   	push   %esi
f0102c32:	e8 94 fe ff ff       	call   f0102acb <printfmt>
f0102c37:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102c3d:	e9 cc fe ff ff       	jmp    f0102b0e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102c42:	52                   	push   %edx
f0102c43:	68 38 43 10 f0       	push   $0xf0104338
f0102c48:	53                   	push   %ebx
f0102c49:	56                   	push   %esi
f0102c4a:	e8 7c fe ff ff       	call   f0102acb <printfmt>
f0102c4f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102c52:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102c55:	e9 b4 fe ff ff       	jmp    f0102b0e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102c5a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c5d:	8d 50 04             	lea    0x4(%eax),%edx
f0102c60:	89 55 14             	mov    %edx,0x14(%ebp)
f0102c63:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102c65:	85 ff                	test   %edi,%edi
f0102c67:	b8 56 46 10 f0       	mov    $0xf0104656,%eax
f0102c6c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102c6f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102c73:	0f 8e 94 00 00 00    	jle    f0102d0d <vprintfmt+0x225>
f0102c79:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102c7d:	0f 84 98 00 00 00    	je     f0102d1b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102c83:	83 ec 08             	sub    $0x8,%esp
f0102c86:	ff 75 d0             	pushl  -0x30(%ebp)
f0102c89:	57                   	push   %edi
f0102c8a:	e8 5f 03 00 00       	call   f0102fee <strnlen>
f0102c8f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102c92:	29 c1                	sub    %eax,%ecx
f0102c94:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0102c97:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102c9a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102c9e:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102ca1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102ca4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102ca6:	eb 0f                	jmp    f0102cb7 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0102ca8:	83 ec 08             	sub    $0x8,%esp
f0102cab:	53                   	push   %ebx
f0102cac:	ff 75 e0             	pushl  -0x20(%ebp)
f0102caf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102cb1:	83 ef 01             	sub    $0x1,%edi
f0102cb4:	83 c4 10             	add    $0x10,%esp
f0102cb7:	85 ff                	test   %edi,%edi
f0102cb9:	7f ed                	jg     f0102ca8 <vprintfmt+0x1c0>
f0102cbb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102cbe:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102cc1:	85 c9                	test   %ecx,%ecx
f0102cc3:	b8 00 00 00 00       	mov    $0x0,%eax
f0102cc8:	0f 49 c1             	cmovns %ecx,%eax
f0102ccb:	29 c1                	sub    %eax,%ecx
f0102ccd:	89 75 08             	mov    %esi,0x8(%ebp)
f0102cd0:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102cd3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102cd6:	89 cb                	mov    %ecx,%ebx
f0102cd8:	eb 4d                	jmp    f0102d27 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102cda:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102cde:	74 1b                	je     f0102cfb <vprintfmt+0x213>
f0102ce0:	0f be c0             	movsbl %al,%eax
f0102ce3:	83 e8 20             	sub    $0x20,%eax
f0102ce6:	83 f8 5e             	cmp    $0x5e,%eax
f0102ce9:	76 10                	jbe    f0102cfb <vprintfmt+0x213>
					putch('?', putdat);
f0102ceb:	83 ec 08             	sub    $0x8,%esp
f0102cee:	ff 75 0c             	pushl  0xc(%ebp)
f0102cf1:	6a 3f                	push   $0x3f
f0102cf3:	ff 55 08             	call   *0x8(%ebp)
f0102cf6:	83 c4 10             	add    $0x10,%esp
f0102cf9:	eb 0d                	jmp    f0102d08 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0102cfb:	83 ec 08             	sub    $0x8,%esp
f0102cfe:	ff 75 0c             	pushl  0xc(%ebp)
f0102d01:	52                   	push   %edx
f0102d02:	ff 55 08             	call   *0x8(%ebp)
f0102d05:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102d08:	83 eb 01             	sub    $0x1,%ebx
f0102d0b:	eb 1a                	jmp    f0102d27 <vprintfmt+0x23f>
f0102d0d:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d10:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d13:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d16:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102d19:	eb 0c                	jmp    f0102d27 <vprintfmt+0x23f>
f0102d1b:	89 75 08             	mov    %esi,0x8(%ebp)
f0102d1e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102d21:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102d24:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102d27:	83 c7 01             	add    $0x1,%edi
f0102d2a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102d2e:	0f be d0             	movsbl %al,%edx
f0102d31:	85 d2                	test   %edx,%edx
f0102d33:	74 23                	je     f0102d58 <vprintfmt+0x270>
f0102d35:	85 f6                	test   %esi,%esi
f0102d37:	78 a1                	js     f0102cda <vprintfmt+0x1f2>
f0102d39:	83 ee 01             	sub    $0x1,%esi
f0102d3c:	79 9c                	jns    f0102cda <vprintfmt+0x1f2>
f0102d3e:	89 df                	mov    %ebx,%edi
f0102d40:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d46:	eb 18                	jmp    f0102d60 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102d48:	83 ec 08             	sub    $0x8,%esp
f0102d4b:	53                   	push   %ebx
f0102d4c:	6a 20                	push   $0x20
f0102d4e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102d50:	83 ef 01             	sub    $0x1,%edi
f0102d53:	83 c4 10             	add    $0x10,%esp
f0102d56:	eb 08                	jmp    f0102d60 <vprintfmt+0x278>
f0102d58:	89 df                	mov    %ebx,%edi
f0102d5a:	8b 75 08             	mov    0x8(%ebp),%esi
f0102d5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102d60:	85 ff                	test   %edi,%edi
f0102d62:	7f e4                	jg     f0102d48 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102d64:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102d67:	e9 a2 fd ff ff       	jmp    f0102b0e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102d6c:	83 fa 01             	cmp    $0x1,%edx
f0102d6f:	7e 16                	jle    f0102d87 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0102d71:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d74:	8d 50 08             	lea    0x8(%eax),%edx
f0102d77:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d7a:	8b 50 04             	mov    0x4(%eax),%edx
f0102d7d:	8b 00                	mov    (%eax),%eax
f0102d7f:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d82:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102d85:	eb 32                	jmp    f0102db9 <vprintfmt+0x2d1>
	else if (lflag)
f0102d87:	85 d2                	test   %edx,%edx
f0102d89:	74 18                	je     f0102da3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0102d8b:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d8e:	8d 50 04             	lea    0x4(%eax),%edx
f0102d91:	89 55 14             	mov    %edx,0x14(%ebp)
f0102d94:	8b 00                	mov    (%eax),%eax
f0102d96:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d99:	89 c1                	mov    %eax,%ecx
f0102d9b:	c1 f9 1f             	sar    $0x1f,%ecx
f0102d9e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102da1:	eb 16                	jmp    f0102db9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0102da3:	8b 45 14             	mov    0x14(%ebp),%eax
f0102da6:	8d 50 04             	lea    0x4(%eax),%edx
f0102da9:	89 55 14             	mov    %edx,0x14(%ebp)
f0102dac:	8b 00                	mov    (%eax),%eax
f0102dae:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102db1:	89 c1                	mov    %eax,%ecx
f0102db3:	c1 f9 1f             	sar    $0x1f,%ecx
f0102db6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102db9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102dbc:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102dbf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102dc4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102dc8:	79 74                	jns    f0102e3e <vprintfmt+0x356>
				putch('-', putdat);
f0102dca:	83 ec 08             	sub    $0x8,%esp
f0102dcd:	53                   	push   %ebx
f0102dce:	6a 2d                	push   $0x2d
f0102dd0:	ff d6                	call   *%esi
				num = -(long long) num;
f0102dd2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102dd5:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102dd8:	f7 d8                	neg    %eax
f0102dda:	83 d2 00             	adc    $0x0,%edx
f0102ddd:	f7 da                	neg    %edx
f0102ddf:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102de2:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0102de7:	eb 55                	jmp    f0102e3e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0102de9:	8d 45 14             	lea    0x14(%ebp),%eax
f0102dec:	e8 83 fc ff ff       	call   f0102a74 <getuint>
			base = 10;
f0102df1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0102df6:	eb 46                	jmp    f0102e3e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0102df8:	8d 45 14             	lea    0x14(%ebp),%eax
f0102dfb:	e8 74 fc ff ff       	call   f0102a74 <getuint>
			base = 8;
f0102e00:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0102e05:	eb 37                	jmp    f0102e3e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0102e07:	83 ec 08             	sub    $0x8,%esp
f0102e0a:	53                   	push   %ebx
f0102e0b:	6a 30                	push   $0x30
f0102e0d:	ff d6                	call   *%esi
			putch('x', putdat);
f0102e0f:	83 c4 08             	add    $0x8,%esp
f0102e12:	53                   	push   %ebx
f0102e13:	6a 78                	push   $0x78
f0102e15:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102e17:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e1a:	8d 50 04             	lea    0x4(%eax),%edx
f0102e1d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0102e20:	8b 00                	mov    (%eax),%eax
f0102e22:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102e27:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0102e2a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0102e2f:	eb 0d                	jmp    f0102e3e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0102e31:	8d 45 14             	lea    0x14(%ebp),%eax
f0102e34:	e8 3b fc ff ff       	call   f0102a74 <getuint>
			base = 16;
f0102e39:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102e3e:	83 ec 0c             	sub    $0xc,%esp
f0102e41:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102e45:	57                   	push   %edi
f0102e46:	ff 75 e0             	pushl  -0x20(%ebp)
f0102e49:	51                   	push   %ecx
f0102e4a:	52                   	push   %edx
f0102e4b:	50                   	push   %eax
f0102e4c:	89 da                	mov    %ebx,%edx
f0102e4e:	89 f0                	mov    %esi,%eax
f0102e50:	e8 70 fb ff ff       	call   f01029c5 <printnum>
			break;
f0102e55:	83 c4 20             	add    $0x20,%esp
f0102e58:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e5b:	e9 ae fc ff ff       	jmp    f0102b0e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102e60:	83 ec 08             	sub    $0x8,%esp
f0102e63:	53                   	push   %ebx
f0102e64:	51                   	push   %ecx
f0102e65:	ff d6                	call   *%esi
			break;
f0102e67:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102e6d:	e9 9c fc ff ff       	jmp    f0102b0e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102e72:	83 ec 08             	sub    $0x8,%esp
f0102e75:	53                   	push   %ebx
f0102e76:	6a 25                	push   $0x25
f0102e78:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102e7a:	83 c4 10             	add    $0x10,%esp
f0102e7d:	eb 03                	jmp    f0102e82 <vprintfmt+0x39a>
f0102e7f:	83 ef 01             	sub    $0x1,%edi
f0102e82:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102e86:	75 f7                	jne    f0102e7f <vprintfmt+0x397>
f0102e88:	e9 81 fc ff ff       	jmp    f0102b0e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0102e8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e90:	5b                   	pop    %ebx
f0102e91:	5e                   	pop    %esi
f0102e92:	5f                   	pop    %edi
f0102e93:	5d                   	pop    %ebp
f0102e94:	c3                   	ret    

f0102e95 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102e95:	55                   	push   %ebp
f0102e96:	89 e5                	mov    %esp,%ebp
f0102e98:	83 ec 18             	sub    $0x18,%esp
f0102e9b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102ea1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102ea4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102ea8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102eab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102eb2:	85 c0                	test   %eax,%eax
f0102eb4:	74 26                	je     f0102edc <vsnprintf+0x47>
f0102eb6:	85 d2                	test   %edx,%edx
f0102eb8:	7e 22                	jle    f0102edc <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102eba:	ff 75 14             	pushl  0x14(%ebp)
f0102ebd:	ff 75 10             	pushl  0x10(%ebp)
f0102ec0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102ec3:	50                   	push   %eax
f0102ec4:	68 ae 2a 10 f0       	push   $0xf0102aae
f0102ec9:	e8 1a fc ff ff       	call   f0102ae8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102ece:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ed1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102ed4:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ed7:	83 c4 10             	add    $0x10,%esp
f0102eda:	eb 05                	jmp    f0102ee1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102edc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102ee1:	c9                   	leave  
f0102ee2:	c3                   	ret    

f0102ee3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102ee3:	55                   	push   %ebp
f0102ee4:	89 e5                	mov    %esp,%ebp
f0102ee6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102ee9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102eec:	50                   	push   %eax
f0102eed:	ff 75 10             	pushl  0x10(%ebp)
f0102ef0:	ff 75 0c             	pushl  0xc(%ebp)
f0102ef3:	ff 75 08             	pushl  0x8(%ebp)
f0102ef6:	e8 9a ff ff ff       	call   f0102e95 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102efb:	c9                   	leave  
f0102efc:	c3                   	ret    

f0102efd <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102efd:	55                   	push   %ebp
f0102efe:	89 e5                	mov    %esp,%ebp
f0102f00:	57                   	push   %edi
f0102f01:	56                   	push   %esi
f0102f02:	53                   	push   %ebx
f0102f03:	83 ec 0c             	sub    $0xc,%esp
f0102f06:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102f09:	85 c0                	test   %eax,%eax
f0102f0b:	74 11                	je     f0102f1e <readline+0x21>
		cprintf("%s", prompt);
f0102f0d:	83 ec 08             	sub    $0x8,%esp
f0102f10:	50                   	push   %eax
f0102f11:	68 38 43 10 f0       	push   $0xf0104338
f0102f16:	e8 80 f7 ff ff       	call   f010269b <cprintf>
f0102f1b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102f1e:	83 ec 0c             	sub    $0xc,%esp
f0102f21:	6a 00                	push   $0x0
f0102f23:	e8 95 d7 ff ff       	call   f01006bd <iscons>
f0102f28:	89 c7                	mov    %eax,%edi
f0102f2a:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102f2d:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102f32:	e8 75 d7 ff ff       	call   f01006ac <getchar>
f0102f37:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102f39:	85 c0                	test   %eax,%eax
f0102f3b:	79 18                	jns    f0102f55 <readline+0x58>
			cprintf("read error: %e\n", c);
f0102f3d:	83 ec 08             	sub    $0x8,%esp
f0102f40:	50                   	push   %eax
f0102f41:	68 44 48 10 f0       	push   $0xf0104844
f0102f46:	e8 50 f7 ff ff       	call   f010269b <cprintf>
			return NULL;
f0102f4b:	83 c4 10             	add    $0x10,%esp
f0102f4e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f53:	eb 79                	jmp    f0102fce <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102f55:	83 f8 08             	cmp    $0x8,%eax
f0102f58:	0f 94 c2             	sete   %dl
f0102f5b:	83 f8 7f             	cmp    $0x7f,%eax
f0102f5e:	0f 94 c0             	sete   %al
f0102f61:	08 c2                	or     %al,%dl
f0102f63:	74 1a                	je     f0102f7f <readline+0x82>
f0102f65:	85 f6                	test   %esi,%esi
f0102f67:	7e 16                	jle    f0102f7f <readline+0x82>
			if (echoing)
f0102f69:	85 ff                	test   %edi,%edi
f0102f6b:	74 0d                	je     f0102f7a <readline+0x7d>
				cputchar('\b');
f0102f6d:	83 ec 0c             	sub    $0xc,%esp
f0102f70:	6a 08                	push   $0x8
f0102f72:	e8 25 d7 ff ff       	call   f010069c <cputchar>
f0102f77:	83 c4 10             	add    $0x10,%esp
			i--;
f0102f7a:	83 ee 01             	sub    $0x1,%esi
f0102f7d:	eb b3                	jmp    f0102f32 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102f7f:	83 fb 1f             	cmp    $0x1f,%ebx
f0102f82:	7e 23                	jle    f0102fa7 <readline+0xaa>
f0102f84:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102f8a:	7f 1b                	jg     f0102fa7 <readline+0xaa>
			if (echoing)
f0102f8c:	85 ff                	test   %edi,%edi
f0102f8e:	74 0c                	je     f0102f9c <readline+0x9f>
				cputchar(c);
f0102f90:	83 ec 0c             	sub    $0xc,%esp
f0102f93:	53                   	push   %ebx
f0102f94:	e8 03 d7 ff ff       	call   f010069c <cputchar>
f0102f99:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0102f9c:	88 9e 60 65 11 f0    	mov    %bl,-0xfee9aa0(%esi)
f0102fa2:	8d 76 01             	lea    0x1(%esi),%esi
f0102fa5:	eb 8b                	jmp    f0102f32 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0102fa7:	83 fb 0a             	cmp    $0xa,%ebx
f0102faa:	74 05                	je     f0102fb1 <readline+0xb4>
f0102fac:	83 fb 0d             	cmp    $0xd,%ebx
f0102faf:	75 81                	jne    f0102f32 <readline+0x35>
			if (echoing)
f0102fb1:	85 ff                	test   %edi,%edi
f0102fb3:	74 0d                	je     f0102fc2 <readline+0xc5>
				cputchar('\n');
f0102fb5:	83 ec 0c             	sub    $0xc,%esp
f0102fb8:	6a 0a                	push   $0xa
f0102fba:	e8 dd d6 ff ff       	call   f010069c <cputchar>
f0102fbf:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0102fc2:	c6 86 60 65 11 f0 00 	movb   $0x0,-0xfee9aa0(%esi)
			return buf;
f0102fc9:	b8 60 65 11 f0       	mov    $0xf0116560,%eax
		}
	}
}
f0102fce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fd1:	5b                   	pop    %ebx
f0102fd2:	5e                   	pop    %esi
f0102fd3:	5f                   	pop    %edi
f0102fd4:	5d                   	pop    %ebp
f0102fd5:	c3                   	ret    

f0102fd6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0102fd6:	55                   	push   %ebp
f0102fd7:	89 e5                	mov    %esp,%ebp
f0102fd9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0102fdc:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fe1:	eb 03                	jmp    f0102fe6 <strlen+0x10>
		n++;
f0102fe3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0102fe6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0102fea:	75 f7                	jne    f0102fe3 <strlen+0xd>
		n++;
	return n;
}
f0102fec:	5d                   	pop    %ebp
f0102fed:	c3                   	ret    

f0102fee <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0102fee:	55                   	push   %ebp
f0102fef:	89 e5                	mov    %esp,%ebp
f0102ff1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102ff7:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ffc:	eb 03                	jmp    f0103001 <strnlen+0x13>
		n++;
f0102ffe:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103001:	39 c2                	cmp    %eax,%edx
f0103003:	74 08                	je     f010300d <strnlen+0x1f>
f0103005:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0103009:	75 f3                	jne    f0102ffe <strnlen+0x10>
f010300b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010300d:	5d                   	pop    %ebp
f010300e:	c3                   	ret    

f010300f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010300f:	55                   	push   %ebp
f0103010:	89 e5                	mov    %esp,%ebp
f0103012:	53                   	push   %ebx
f0103013:	8b 45 08             	mov    0x8(%ebp),%eax
f0103016:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103019:	89 c2                	mov    %eax,%edx
f010301b:	83 c2 01             	add    $0x1,%edx
f010301e:	83 c1 01             	add    $0x1,%ecx
f0103021:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103025:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103028:	84 db                	test   %bl,%bl
f010302a:	75 ef                	jne    f010301b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010302c:	5b                   	pop    %ebx
f010302d:	5d                   	pop    %ebp
f010302e:	c3                   	ret    

f010302f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010302f:	55                   	push   %ebp
f0103030:	89 e5                	mov    %esp,%ebp
f0103032:	53                   	push   %ebx
f0103033:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103036:	53                   	push   %ebx
f0103037:	e8 9a ff ff ff       	call   f0102fd6 <strlen>
f010303c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010303f:	ff 75 0c             	pushl  0xc(%ebp)
f0103042:	01 d8                	add    %ebx,%eax
f0103044:	50                   	push   %eax
f0103045:	e8 c5 ff ff ff       	call   f010300f <strcpy>
	return dst;
}
f010304a:	89 d8                	mov    %ebx,%eax
f010304c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010304f:	c9                   	leave  
f0103050:	c3                   	ret    

f0103051 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103051:	55                   	push   %ebp
f0103052:	89 e5                	mov    %esp,%ebp
f0103054:	56                   	push   %esi
f0103055:	53                   	push   %ebx
f0103056:	8b 75 08             	mov    0x8(%ebp),%esi
f0103059:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010305c:	89 f3                	mov    %esi,%ebx
f010305e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103061:	89 f2                	mov    %esi,%edx
f0103063:	eb 0f                	jmp    f0103074 <strncpy+0x23>
		*dst++ = *src;
f0103065:	83 c2 01             	add    $0x1,%edx
f0103068:	0f b6 01             	movzbl (%ecx),%eax
f010306b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010306e:	80 39 01             	cmpb   $0x1,(%ecx)
f0103071:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103074:	39 da                	cmp    %ebx,%edx
f0103076:	75 ed                	jne    f0103065 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103078:	89 f0                	mov    %esi,%eax
f010307a:	5b                   	pop    %ebx
f010307b:	5e                   	pop    %esi
f010307c:	5d                   	pop    %ebp
f010307d:	c3                   	ret    

f010307e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010307e:	55                   	push   %ebp
f010307f:	89 e5                	mov    %esp,%ebp
f0103081:	56                   	push   %esi
f0103082:	53                   	push   %ebx
f0103083:	8b 75 08             	mov    0x8(%ebp),%esi
f0103086:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0103089:	8b 55 10             	mov    0x10(%ebp),%edx
f010308c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010308e:	85 d2                	test   %edx,%edx
f0103090:	74 21                	je     f01030b3 <strlcpy+0x35>
f0103092:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103096:	89 f2                	mov    %esi,%edx
f0103098:	eb 09                	jmp    f01030a3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010309a:	83 c2 01             	add    $0x1,%edx
f010309d:	83 c1 01             	add    $0x1,%ecx
f01030a0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01030a3:	39 c2                	cmp    %eax,%edx
f01030a5:	74 09                	je     f01030b0 <strlcpy+0x32>
f01030a7:	0f b6 19             	movzbl (%ecx),%ebx
f01030aa:	84 db                	test   %bl,%bl
f01030ac:	75 ec                	jne    f010309a <strlcpy+0x1c>
f01030ae:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01030b0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01030b3:	29 f0                	sub    %esi,%eax
}
f01030b5:	5b                   	pop    %ebx
f01030b6:	5e                   	pop    %esi
f01030b7:	5d                   	pop    %ebp
f01030b8:	c3                   	ret    

f01030b9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01030b9:	55                   	push   %ebp
f01030ba:	89 e5                	mov    %esp,%ebp
f01030bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01030c2:	eb 06                	jmp    f01030ca <strcmp+0x11>
		p++, q++;
f01030c4:	83 c1 01             	add    $0x1,%ecx
f01030c7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01030ca:	0f b6 01             	movzbl (%ecx),%eax
f01030cd:	84 c0                	test   %al,%al
f01030cf:	74 04                	je     f01030d5 <strcmp+0x1c>
f01030d1:	3a 02                	cmp    (%edx),%al
f01030d3:	74 ef                	je     f01030c4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01030d5:	0f b6 c0             	movzbl %al,%eax
f01030d8:	0f b6 12             	movzbl (%edx),%edx
f01030db:	29 d0                	sub    %edx,%eax
}
f01030dd:	5d                   	pop    %ebp
f01030de:	c3                   	ret    

f01030df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01030df:	55                   	push   %ebp
f01030e0:	89 e5                	mov    %esp,%ebp
f01030e2:	53                   	push   %ebx
f01030e3:	8b 45 08             	mov    0x8(%ebp),%eax
f01030e6:	8b 55 0c             	mov    0xc(%ebp),%edx
f01030e9:	89 c3                	mov    %eax,%ebx
f01030eb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01030ee:	eb 06                	jmp    f01030f6 <strncmp+0x17>
		n--, p++, q++;
f01030f0:	83 c0 01             	add    $0x1,%eax
f01030f3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01030f6:	39 d8                	cmp    %ebx,%eax
f01030f8:	74 15                	je     f010310f <strncmp+0x30>
f01030fa:	0f b6 08             	movzbl (%eax),%ecx
f01030fd:	84 c9                	test   %cl,%cl
f01030ff:	74 04                	je     f0103105 <strncmp+0x26>
f0103101:	3a 0a                	cmp    (%edx),%cl
f0103103:	74 eb                	je     f01030f0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103105:	0f b6 00             	movzbl (%eax),%eax
f0103108:	0f b6 12             	movzbl (%edx),%edx
f010310b:	29 d0                	sub    %edx,%eax
f010310d:	eb 05                	jmp    f0103114 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010310f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103114:	5b                   	pop    %ebx
f0103115:	5d                   	pop    %ebp
f0103116:	c3                   	ret    

f0103117 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103117:	55                   	push   %ebp
f0103118:	89 e5                	mov    %esp,%ebp
f010311a:	8b 45 08             	mov    0x8(%ebp),%eax
f010311d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103121:	eb 07                	jmp    f010312a <strchr+0x13>
		if (*s == c)
f0103123:	38 ca                	cmp    %cl,%dl
f0103125:	74 0f                	je     f0103136 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103127:	83 c0 01             	add    $0x1,%eax
f010312a:	0f b6 10             	movzbl (%eax),%edx
f010312d:	84 d2                	test   %dl,%dl
f010312f:	75 f2                	jne    f0103123 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103131:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103136:	5d                   	pop    %ebp
f0103137:	c3                   	ret    

f0103138 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103138:	55                   	push   %ebp
f0103139:	89 e5                	mov    %esp,%ebp
f010313b:	8b 45 08             	mov    0x8(%ebp),%eax
f010313e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103142:	eb 03                	jmp    f0103147 <strfind+0xf>
f0103144:	83 c0 01             	add    $0x1,%eax
f0103147:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010314a:	38 ca                	cmp    %cl,%dl
f010314c:	74 04                	je     f0103152 <strfind+0x1a>
f010314e:	84 d2                	test   %dl,%dl
f0103150:	75 f2                	jne    f0103144 <strfind+0xc>
			break;
	return (char *) s;
}
f0103152:	5d                   	pop    %ebp
f0103153:	c3                   	ret    

f0103154 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103154:	55                   	push   %ebp
f0103155:	89 e5                	mov    %esp,%ebp
f0103157:	57                   	push   %edi
f0103158:	56                   	push   %esi
f0103159:	53                   	push   %ebx
f010315a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010315d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103160:	85 c9                	test   %ecx,%ecx
f0103162:	74 36                	je     f010319a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103164:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010316a:	75 28                	jne    f0103194 <memset+0x40>
f010316c:	f6 c1 03             	test   $0x3,%cl
f010316f:	75 23                	jne    f0103194 <memset+0x40>
		c &= 0xFF;
f0103171:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103175:	89 d3                	mov    %edx,%ebx
f0103177:	c1 e3 08             	shl    $0x8,%ebx
f010317a:	89 d6                	mov    %edx,%esi
f010317c:	c1 e6 18             	shl    $0x18,%esi
f010317f:	89 d0                	mov    %edx,%eax
f0103181:	c1 e0 10             	shl    $0x10,%eax
f0103184:	09 f0                	or     %esi,%eax
f0103186:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103188:	89 d8                	mov    %ebx,%eax
f010318a:	09 d0                	or     %edx,%eax
f010318c:	c1 e9 02             	shr    $0x2,%ecx
f010318f:	fc                   	cld    
f0103190:	f3 ab                	rep stos %eax,%es:(%edi)
f0103192:	eb 06                	jmp    f010319a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103194:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103197:	fc                   	cld    
f0103198:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010319a:	89 f8                	mov    %edi,%eax
f010319c:	5b                   	pop    %ebx
f010319d:	5e                   	pop    %esi
f010319e:	5f                   	pop    %edi
f010319f:	5d                   	pop    %ebp
f01031a0:	c3                   	ret    

f01031a1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01031a1:	55                   	push   %ebp
f01031a2:	89 e5                	mov    %esp,%ebp
f01031a4:	57                   	push   %edi
f01031a5:	56                   	push   %esi
f01031a6:	8b 45 08             	mov    0x8(%ebp),%eax
f01031a9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01031ac:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01031af:	39 c6                	cmp    %eax,%esi
f01031b1:	73 35                	jae    f01031e8 <memmove+0x47>
f01031b3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01031b6:	39 d0                	cmp    %edx,%eax
f01031b8:	73 2e                	jae    f01031e8 <memmove+0x47>
		s += n;
		d += n;
f01031ba:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01031bd:	89 d6                	mov    %edx,%esi
f01031bf:	09 fe                	or     %edi,%esi
f01031c1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01031c7:	75 13                	jne    f01031dc <memmove+0x3b>
f01031c9:	f6 c1 03             	test   $0x3,%cl
f01031cc:	75 0e                	jne    f01031dc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01031ce:	83 ef 04             	sub    $0x4,%edi
f01031d1:	8d 72 fc             	lea    -0x4(%edx),%esi
f01031d4:	c1 e9 02             	shr    $0x2,%ecx
f01031d7:	fd                   	std    
f01031d8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01031da:	eb 09                	jmp    f01031e5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01031dc:	83 ef 01             	sub    $0x1,%edi
f01031df:	8d 72 ff             	lea    -0x1(%edx),%esi
f01031e2:	fd                   	std    
f01031e3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01031e5:	fc                   	cld    
f01031e6:	eb 1d                	jmp    f0103205 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01031e8:	89 f2                	mov    %esi,%edx
f01031ea:	09 c2                	or     %eax,%edx
f01031ec:	f6 c2 03             	test   $0x3,%dl
f01031ef:	75 0f                	jne    f0103200 <memmove+0x5f>
f01031f1:	f6 c1 03             	test   $0x3,%cl
f01031f4:	75 0a                	jne    f0103200 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01031f6:	c1 e9 02             	shr    $0x2,%ecx
f01031f9:	89 c7                	mov    %eax,%edi
f01031fb:	fc                   	cld    
f01031fc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01031fe:	eb 05                	jmp    f0103205 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103200:	89 c7                	mov    %eax,%edi
f0103202:	fc                   	cld    
f0103203:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103205:	5e                   	pop    %esi
f0103206:	5f                   	pop    %edi
f0103207:	5d                   	pop    %ebp
f0103208:	c3                   	ret    

f0103209 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103209:	55                   	push   %ebp
f010320a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010320c:	ff 75 10             	pushl  0x10(%ebp)
f010320f:	ff 75 0c             	pushl  0xc(%ebp)
f0103212:	ff 75 08             	pushl  0x8(%ebp)
f0103215:	e8 87 ff ff ff       	call   f01031a1 <memmove>
}
f010321a:	c9                   	leave  
f010321b:	c3                   	ret    

f010321c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010321c:	55                   	push   %ebp
f010321d:	89 e5                	mov    %esp,%ebp
f010321f:	56                   	push   %esi
f0103220:	53                   	push   %ebx
f0103221:	8b 45 08             	mov    0x8(%ebp),%eax
f0103224:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103227:	89 c6                	mov    %eax,%esi
f0103229:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010322c:	eb 1a                	jmp    f0103248 <memcmp+0x2c>
		if (*s1 != *s2)
f010322e:	0f b6 08             	movzbl (%eax),%ecx
f0103231:	0f b6 1a             	movzbl (%edx),%ebx
f0103234:	38 d9                	cmp    %bl,%cl
f0103236:	74 0a                	je     f0103242 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103238:	0f b6 c1             	movzbl %cl,%eax
f010323b:	0f b6 db             	movzbl %bl,%ebx
f010323e:	29 d8                	sub    %ebx,%eax
f0103240:	eb 0f                	jmp    f0103251 <memcmp+0x35>
		s1++, s2++;
f0103242:	83 c0 01             	add    $0x1,%eax
f0103245:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103248:	39 f0                	cmp    %esi,%eax
f010324a:	75 e2                	jne    f010322e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010324c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103251:	5b                   	pop    %ebx
f0103252:	5e                   	pop    %esi
f0103253:	5d                   	pop    %ebp
f0103254:	c3                   	ret    

f0103255 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103255:	55                   	push   %ebp
f0103256:	89 e5                	mov    %esp,%ebp
f0103258:	53                   	push   %ebx
f0103259:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010325c:	89 c1                	mov    %eax,%ecx
f010325e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103261:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103265:	eb 0a                	jmp    f0103271 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103267:	0f b6 10             	movzbl (%eax),%edx
f010326a:	39 da                	cmp    %ebx,%edx
f010326c:	74 07                	je     f0103275 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010326e:	83 c0 01             	add    $0x1,%eax
f0103271:	39 c8                	cmp    %ecx,%eax
f0103273:	72 f2                	jb     f0103267 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103275:	5b                   	pop    %ebx
f0103276:	5d                   	pop    %ebp
f0103277:	c3                   	ret    

f0103278 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103278:	55                   	push   %ebp
f0103279:	89 e5                	mov    %esp,%ebp
f010327b:	57                   	push   %edi
f010327c:	56                   	push   %esi
f010327d:	53                   	push   %ebx
f010327e:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103281:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103284:	eb 03                	jmp    f0103289 <strtol+0x11>
		s++;
f0103286:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103289:	0f b6 01             	movzbl (%ecx),%eax
f010328c:	3c 20                	cmp    $0x20,%al
f010328e:	74 f6                	je     f0103286 <strtol+0xe>
f0103290:	3c 09                	cmp    $0x9,%al
f0103292:	74 f2                	je     f0103286 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103294:	3c 2b                	cmp    $0x2b,%al
f0103296:	75 0a                	jne    f01032a2 <strtol+0x2a>
		s++;
f0103298:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010329b:	bf 00 00 00 00       	mov    $0x0,%edi
f01032a0:	eb 11                	jmp    f01032b3 <strtol+0x3b>
f01032a2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01032a7:	3c 2d                	cmp    $0x2d,%al
f01032a9:	75 08                	jne    f01032b3 <strtol+0x3b>
		s++, neg = 1;
f01032ab:	83 c1 01             	add    $0x1,%ecx
f01032ae:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01032b3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01032b9:	75 15                	jne    f01032d0 <strtol+0x58>
f01032bb:	80 39 30             	cmpb   $0x30,(%ecx)
f01032be:	75 10                	jne    f01032d0 <strtol+0x58>
f01032c0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01032c4:	75 7c                	jne    f0103342 <strtol+0xca>
		s += 2, base = 16;
f01032c6:	83 c1 02             	add    $0x2,%ecx
f01032c9:	bb 10 00 00 00       	mov    $0x10,%ebx
f01032ce:	eb 16                	jmp    f01032e6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01032d0:	85 db                	test   %ebx,%ebx
f01032d2:	75 12                	jne    f01032e6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01032d4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01032d9:	80 39 30             	cmpb   $0x30,(%ecx)
f01032dc:	75 08                	jne    f01032e6 <strtol+0x6e>
		s++, base = 8;
f01032de:	83 c1 01             	add    $0x1,%ecx
f01032e1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01032e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01032eb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01032ee:	0f b6 11             	movzbl (%ecx),%edx
f01032f1:	8d 72 d0             	lea    -0x30(%edx),%esi
f01032f4:	89 f3                	mov    %esi,%ebx
f01032f6:	80 fb 09             	cmp    $0x9,%bl
f01032f9:	77 08                	ja     f0103303 <strtol+0x8b>
			dig = *s - '0';
f01032fb:	0f be d2             	movsbl %dl,%edx
f01032fe:	83 ea 30             	sub    $0x30,%edx
f0103301:	eb 22                	jmp    f0103325 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103303:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103306:	89 f3                	mov    %esi,%ebx
f0103308:	80 fb 19             	cmp    $0x19,%bl
f010330b:	77 08                	ja     f0103315 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010330d:	0f be d2             	movsbl %dl,%edx
f0103310:	83 ea 57             	sub    $0x57,%edx
f0103313:	eb 10                	jmp    f0103325 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0103315:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103318:	89 f3                	mov    %esi,%ebx
f010331a:	80 fb 19             	cmp    $0x19,%bl
f010331d:	77 16                	ja     f0103335 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010331f:	0f be d2             	movsbl %dl,%edx
f0103322:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0103325:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103328:	7d 0b                	jge    f0103335 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010332a:	83 c1 01             	add    $0x1,%ecx
f010332d:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103331:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103333:	eb b9                	jmp    f01032ee <strtol+0x76>

	if (endptr)
f0103335:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0103339:	74 0d                	je     f0103348 <strtol+0xd0>
		*endptr = (char *) s;
f010333b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010333e:	89 0e                	mov    %ecx,(%esi)
f0103340:	eb 06                	jmp    f0103348 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103342:	85 db                	test   %ebx,%ebx
f0103344:	74 98                	je     f01032de <strtol+0x66>
f0103346:	eb 9e                	jmp    f01032e6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0103348:	89 c2                	mov    %eax,%edx
f010334a:	f7 da                	neg    %edx
f010334c:	85 ff                	test   %edi,%edi
f010334e:	0f 45 c2             	cmovne %edx,%eax
}
f0103351:	5b                   	pop    %ebx
f0103352:	5e                   	pop    %esi
f0103353:	5f                   	pop    %edi
f0103354:	5d                   	pop    %ebp
f0103355:	c3                   	ret    
f0103356:	66 90                	xchg   %ax,%ax
f0103358:	66 90                	xchg   %ax,%ax
f010335a:	66 90                	xchg   %ax,%ax
f010335c:	66 90                	xchg   %ax,%ax
f010335e:	66 90                	xchg   %ax,%ax

f0103360 <__udivdi3>:
f0103360:	55                   	push   %ebp
f0103361:	57                   	push   %edi
f0103362:	56                   	push   %esi
f0103363:	53                   	push   %ebx
f0103364:	83 ec 1c             	sub    $0x1c,%esp
f0103367:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010336b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010336f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0103373:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0103377:	85 f6                	test   %esi,%esi
f0103379:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010337d:	89 ca                	mov    %ecx,%edx
f010337f:	89 f8                	mov    %edi,%eax
f0103381:	75 3d                	jne    f01033c0 <__udivdi3+0x60>
f0103383:	39 cf                	cmp    %ecx,%edi
f0103385:	0f 87 c5 00 00 00    	ja     f0103450 <__udivdi3+0xf0>
f010338b:	85 ff                	test   %edi,%edi
f010338d:	89 fd                	mov    %edi,%ebp
f010338f:	75 0b                	jne    f010339c <__udivdi3+0x3c>
f0103391:	b8 01 00 00 00       	mov    $0x1,%eax
f0103396:	31 d2                	xor    %edx,%edx
f0103398:	f7 f7                	div    %edi
f010339a:	89 c5                	mov    %eax,%ebp
f010339c:	89 c8                	mov    %ecx,%eax
f010339e:	31 d2                	xor    %edx,%edx
f01033a0:	f7 f5                	div    %ebp
f01033a2:	89 c1                	mov    %eax,%ecx
f01033a4:	89 d8                	mov    %ebx,%eax
f01033a6:	89 cf                	mov    %ecx,%edi
f01033a8:	f7 f5                	div    %ebp
f01033aa:	89 c3                	mov    %eax,%ebx
f01033ac:	89 d8                	mov    %ebx,%eax
f01033ae:	89 fa                	mov    %edi,%edx
f01033b0:	83 c4 1c             	add    $0x1c,%esp
f01033b3:	5b                   	pop    %ebx
f01033b4:	5e                   	pop    %esi
f01033b5:	5f                   	pop    %edi
f01033b6:	5d                   	pop    %ebp
f01033b7:	c3                   	ret    
f01033b8:	90                   	nop
f01033b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01033c0:	39 ce                	cmp    %ecx,%esi
f01033c2:	77 74                	ja     f0103438 <__udivdi3+0xd8>
f01033c4:	0f bd fe             	bsr    %esi,%edi
f01033c7:	83 f7 1f             	xor    $0x1f,%edi
f01033ca:	0f 84 98 00 00 00    	je     f0103468 <__udivdi3+0x108>
f01033d0:	bb 20 00 00 00       	mov    $0x20,%ebx
f01033d5:	89 f9                	mov    %edi,%ecx
f01033d7:	89 c5                	mov    %eax,%ebp
f01033d9:	29 fb                	sub    %edi,%ebx
f01033db:	d3 e6                	shl    %cl,%esi
f01033dd:	89 d9                	mov    %ebx,%ecx
f01033df:	d3 ed                	shr    %cl,%ebp
f01033e1:	89 f9                	mov    %edi,%ecx
f01033e3:	d3 e0                	shl    %cl,%eax
f01033e5:	09 ee                	or     %ebp,%esi
f01033e7:	89 d9                	mov    %ebx,%ecx
f01033e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01033ed:	89 d5                	mov    %edx,%ebp
f01033ef:	8b 44 24 08          	mov    0x8(%esp),%eax
f01033f3:	d3 ed                	shr    %cl,%ebp
f01033f5:	89 f9                	mov    %edi,%ecx
f01033f7:	d3 e2                	shl    %cl,%edx
f01033f9:	89 d9                	mov    %ebx,%ecx
f01033fb:	d3 e8                	shr    %cl,%eax
f01033fd:	09 c2                	or     %eax,%edx
f01033ff:	89 d0                	mov    %edx,%eax
f0103401:	89 ea                	mov    %ebp,%edx
f0103403:	f7 f6                	div    %esi
f0103405:	89 d5                	mov    %edx,%ebp
f0103407:	89 c3                	mov    %eax,%ebx
f0103409:	f7 64 24 0c          	mull   0xc(%esp)
f010340d:	39 d5                	cmp    %edx,%ebp
f010340f:	72 10                	jb     f0103421 <__udivdi3+0xc1>
f0103411:	8b 74 24 08          	mov    0x8(%esp),%esi
f0103415:	89 f9                	mov    %edi,%ecx
f0103417:	d3 e6                	shl    %cl,%esi
f0103419:	39 c6                	cmp    %eax,%esi
f010341b:	73 07                	jae    f0103424 <__udivdi3+0xc4>
f010341d:	39 d5                	cmp    %edx,%ebp
f010341f:	75 03                	jne    f0103424 <__udivdi3+0xc4>
f0103421:	83 eb 01             	sub    $0x1,%ebx
f0103424:	31 ff                	xor    %edi,%edi
f0103426:	89 d8                	mov    %ebx,%eax
f0103428:	89 fa                	mov    %edi,%edx
f010342a:	83 c4 1c             	add    $0x1c,%esp
f010342d:	5b                   	pop    %ebx
f010342e:	5e                   	pop    %esi
f010342f:	5f                   	pop    %edi
f0103430:	5d                   	pop    %ebp
f0103431:	c3                   	ret    
f0103432:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0103438:	31 ff                	xor    %edi,%edi
f010343a:	31 db                	xor    %ebx,%ebx
f010343c:	89 d8                	mov    %ebx,%eax
f010343e:	89 fa                	mov    %edi,%edx
f0103440:	83 c4 1c             	add    $0x1c,%esp
f0103443:	5b                   	pop    %ebx
f0103444:	5e                   	pop    %esi
f0103445:	5f                   	pop    %edi
f0103446:	5d                   	pop    %ebp
f0103447:	c3                   	ret    
f0103448:	90                   	nop
f0103449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103450:	89 d8                	mov    %ebx,%eax
f0103452:	f7 f7                	div    %edi
f0103454:	31 ff                	xor    %edi,%edi
f0103456:	89 c3                	mov    %eax,%ebx
f0103458:	89 d8                	mov    %ebx,%eax
f010345a:	89 fa                	mov    %edi,%edx
f010345c:	83 c4 1c             	add    $0x1c,%esp
f010345f:	5b                   	pop    %ebx
f0103460:	5e                   	pop    %esi
f0103461:	5f                   	pop    %edi
f0103462:	5d                   	pop    %ebp
f0103463:	c3                   	ret    
f0103464:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103468:	39 ce                	cmp    %ecx,%esi
f010346a:	72 0c                	jb     f0103478 <__udivdi3+0x118>
f010346c:	31 db                	xor    %ebx,%ebx
f010346e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0103472:	0f 87 34 ff ff ff    	ja     f01033ac <__udivdi3+0x4c>
f0103478:	bb 01 00 00 00       	mov    $0x1,%ebx
f010347d:	e9 2a ff ff ff       	jmp    f01033ac <__udivdi3+0x4c>
f0103482:	66 90                	xchg   %ax,%ax
f0103484:	66 90                	xchg   %ax,%ax
f0103486:	66 90                	xchg   %ax,%ax
f0103488:	66 90                	xchg   %ax,%ax
f010348a:	66 90                	xchg   %ax,%ax
f010348c:	66 90                	xchg   %ax,%ax
f010348e:	66 90                	xchg   %ax,%ax

f0103490 <__umoddi3>:
f0103490:	55                   	push   %ebp
f0103491:	57                   	push   %edi
f0103492:	56                   	push   %esi
f0103493:	53                   	push   %ebx
f0103494:	83 ec 1c             	sub    $0x1c,%esp
f0103497:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f010349b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010349f:	8b 74 24 34          	mov    0x34(%esp),%esi
f01034a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01034a7:	85 d2                	test   %edx,%edx
f01034a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01034ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01034b1:	89 f3                	mov    %esi,%ebx
f01034b3:	89 3c 24             	mov    %edi,(%esp)
f01034b6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01034ba:	75 1c                	jne    f01034d8 <__umoddi3+0x48>
f01034bc:	39 f7                	cmp    %esi,%edi
f01034be:	76 50                	jbe    f0103510 <__umoddi3+0x80>
f01034c0:	89 c8                	mov    %ecx,%eax
f01034c2:	89 f2                	mov    %esi,%edx
f01034c4:	f7 f7                	div    %edi
f01034c6:	89 d0                	mov    %edx,%eax
f01034c8:	31 d2                	xor    %edx,%edx
f01034ca:	83 c4 1c             	add    $0x1c,%esp
f01034cd:	5b                   	pop    %ebx
f01034ce:	5e                   	pop    %esi
f01034cf:	5f                   	pop    %edi
f01034d0:	5d                   	pop    %ebp
f01034d1:	c3                   	ret    
f01034d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f01034d8:	39 f2                	cmp    %esi,%edx
f01034da:	89 d0                	mov    %edx,%eax
f01034dc:	77 52                	ja     f0103530 <__umoddi3+0xa0>
f01034de:	0f bd ea             	bsr    %edx,%ebp
f01034e1:	83 f5 1f             	xor    $0x1f,%ebp
f01034e4:	75 5a                	jne    f0103540 <__umoddi3+0xb0>
f01034e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f01034ea:	0f 82 e0 00 00 00    	jb     f01035d0 <__umoddi3+0x140>
f01034f0:	39 0c 24             	cmp    %ecx,(%esp)
f01034f3:	0f 86 d7 00 00 00    	jbe    f01035d0 <__umoddi3+0x140>
f01034f9:	8b 44 24 08          	mov    0x8(%esp),%eax
f01034fd:	8b 54 24 04          	mov    0x4(%esp),%edx
f0103501:	83 c4 1c             	add    $0x1c,%esp
f0103504:	5b                   	pop    %ebx
f0103505:	5e                   	pop    %esi
f0103506:	5f                   	pop    %edi
f0103507:	5d                   	pop    %ebp
f0103508:	c3                   	ret    
f0103509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0103510:	85 ff                	test   %edi,%edi
f0103512:	89 fd                	mov    %edi,%ebp
f0103514:	75 0b                	jne    f0103521 <__umoddi3+0x91>
f0103516:	b8 01 00 00 00       	mov    $0x1,%eax
f010351b:	31 d2                	xor    %edx,%edx
f010351d:	f7 f7                	div    %edi
f010351f:	89 c5                	mov    %eax,%ebp
f0103521:	89 f0                	mov    %esi,%eax
f0103523:	31 d2                	xor    %edx,%edx
f0103525:	f7 f5                	div    %ebp
f0103527:	89 c8                	mov    %ecx,%eax
f0103529:	f7 f5                	div    %ebp
f010352b:	89 d0                	mov    %edx,%eax
f010352d:	eb 99                	jmp    f01034c8 <__umoddi3+0x38>
f010352f:	90                   	nop
f0103530:	89 c8                	mov    %ecx,%eax
f0103532:	89 f2                	mov    %esi,%edx
f0103534:	83 c4 1c             	add    $0x1c,%esp
f0103537:	5b                   	pop    %ebx
f0103538:	5e                   	pop    %esi
f0103539:	5f                   	pop    %edi
f010353a:	5d                   	pop    %ebp
f010353b:	c3                   	ret    
f010353c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0103540:	8b 34 24             	mov    (%esp),%esi
f0103543:	bf 20 00 00 00       	mov    $0x20,%edi
f0103548:	89 e9                	mov    %ebp,%ecx
f010354a:	29 ef                	sub    %ebp,%edi
f010354c:	d3 e0                	shl    %cl,%eax
f010354e:	89 f9                	mov    %edi,%ecx
f0103550:	89 f2                	mov    %esi,%edx
f0103552:	d3 ea                	shr    %cl,%edx
f0103554:	89 e9                	mov    %ebp,%ecx
f0103556:	09 c2                	or     %eax,%edx
f0103558:	89 d8                	mov    %ebx,%eax
f010355a:	89 14 24             	mov    %edx,(%esp)
f010355d:	89 f2                	mov    %esi,%edx
f010355f:	d3 e2                	shl    %cl,%edx
f0103561:	89 f9                	mov    %edi,%ecx
f0103563:	89 54 24 04          	mov    %edx,0x4(%esp)
f0103567:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010356b:	d3 e8                	shr    %cl,%eax
f010356d:	89 e9                	mov    %ebp,%ecx
f010356f:	89 c6                	mov    %eax,%esi
f0103571:	d3 e3                	shl    %cl,%ebx
f0103573:	89 f9                	mov    %edi,%ecx
f0103575:	89 d0                	mov    %edx,%eax
f0103577:	d3 e8                	shr    %cl,%eax
f0103579:	89 e9                	mov    %ebp,%ecx
f010357b:	09 d8                	or     %ebx,%eax
f010357d:	89 d3                	mov    %edx,%ebx
f010357f:	89 f2                	mov    %esi,%edx
f0103581:	f7 34 24             	divl   (%esp)
f0103584:	89 d6                	mov    %edx,%esi
f0103586:	d3 e3                	shl    %cl,%ebx
f0103588:	f7 64 24 04          	mull   0x4(%esp)
f010358c:	39 d6                	cmp    %edx,%esi
f010358e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103592:	89 d1                	mov    %edx,%ecx
f0103594:	89 c3                	mov    %eax,%ebx
f0103596:	72 08                	jb     f01035a0 <__umoddi3+0x110>
f0103598:	75 11                	jne    f01035ab <__umoddi3+0x11b>
f010359a:	39 44 24 08          	cmp    %eax,0x8(%esp)
f010359e:	73 0b                	jae    f01035ab <__umoddi3+0x11b>
f01035a0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01035a4:	1b 14 24             	sbb    (%esp),%edx
f01035a7:	89 d1                	mov    %edx,%ecx
f01035a9:	89 c3                	mov    %eax,%ebx
f01035ab:	8b 54 24 08          	mov    0x8(%esp),%edx
f01035af:	29 da                	sub    %ebx,%edx
f01035b1:	19 ce                	sbb    %ecx,%esi
f01035b3:	89 f9                	mov    %edi,%ecx
f01035b5:	89 f0                	mov    %esi,%eax
f01035b7:	d3 e0                	shl    %cl,%eax
f01035b9:	89 e9                	mov    %ebp,%ecx
f01035bb:	d3 ea                	shr    %cl,%edx
f01035bd:	89 e9                	mov    %ebp,%ecx
f01035bf:	d3 ee                	shr    %cl,%esi
f01035c1:	09 d0                	or     %edx,%eax
f01035c3:	89 f2                	mov    %esi,%edx
f01035c5:	83 c4 1c             	add    $0x1c,%esp
f01035c8:	5b                   	pop    %ebx
f01035c9:	5e                   	pop    %esi
f01035ca:	5f                   	pop    %edi
f01035cb:	5d                   	pop    %ebp
f01035cc:	c3                   	ret    
f01035cd:	8d 76 00             	lea    0x0(%esi),%esi
f01035d0:	29 f9                	sub    %edi,%ecx
f01035d2:	19 d6                	sbb    %edx,%esi
f01035d4:	89 74 24 04          	mov    %esi,0x4(%esp)
f01035d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01035dc:	e9 18 ff ff ff       	jmp    f01034f9 <__umoddi3+0x69>
