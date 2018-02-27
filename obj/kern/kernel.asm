
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
f0100015:	b8 00 00 11 00       	mov    $0x110000,%eax
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
f0100034:	bc 00 00 11 f0       	mov    $0xf0110000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 56 00 00 00       	call   f0100094 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <test_backtrace>:
#include <kern/console.h>

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
f010004b:	68 20 19 10 f0       	push   $0xf0101920
f0100050:	e8 76 09 00 00       	call   f01009cb <cprintf>
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
f0100076:	e8 46 07 00 00       	call   f01007c1 <mon_backtrace>
f010007b:	83 c4 10             	add    $0x10,%esp
	cprintf("leaving test_backtrace %d\n", x);
f010007e:	83 ec 08             	sub    $0x8,%esp
f0100081:	53                   	push   %ebx
f0100082:	68 3c 19 10 f0       	push   $0xf010193c
f0100087:	e8 3f 09 00 00       	call   f01009cb <cprintf>
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
f010009a:	b8 44 29 11 f0       	mov    $0xf0112944,%eax
f010009f:	2d 00 23 11 f0       	sub    $0xf0112300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 23 11 f0       	push   $0xf0112300
f01000ac:	e8 d3 13 00 00       	call   f0101484 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 d9 04 00 00       	call   f010058f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 57 19 10 f0       	push   $0xf0101957
f01000c3:	e8 03 09 00 00       	call   f01009cb <cprintf>

	int x = 1, y = 3, z = 4;
	cprintf("x %d, y %x, z %d\n", x, y, z);
f01000c8:	6a 04                	push   $0x4
f01000ca:	6a 03                	push   $0x3
f01000cc:	6a 01                	push   $0x1
f01000ce:	68 72 19 10 f0       	push   $0xf0101972
f01000d3:	e8 f3 08 00 00       	call   f01009cb <cprintf>

	// 0x72 = r, 0x6c = l, 0x64 = d, 0x00 = \0
	// 57616 in hex = e110
	unsigned int i = 0x00646c72;
f01000d8:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
	cprintf("H%x Wo%s\n", 57616, &i);
f01000df:	83 c4 1c             	add    $0x1c,%esp
f01000e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01000e5:	50                   	push   %eax
f01000e6:	68 10 e1 00 00       	push   $0xe110
f01000eb:	68 84 19 10 f0       	push   $0xf0101984
f01000f0:	e8 d6 08 00 00       	call   f01009cb <cprintf>

	cprintf("x=%d y=%d\n", 3);
f01000f5:	83 c4 08             	add    $0x8,%esp
f01000f8:	6a 03                	push   $0x3
f01000fa:	68 8e 19 10 f0       	push   $0xf010198e
f01000ff:	e8 c7 08 00 00       	call   f01009cb <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100104:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f010010b:	e8 30 ff ff ff       	call   f0100040 <test_backtrace>
f0100110:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f0100113:	83 ec 0c             	sub    $0xc,%esp
f0100116:	6a 00                	push   $0x0
f0100118:	e8 41 07 00 00       	call   f010085e <monitor>
f010011d:	83 c4 10             	add    $0x10,%esp
f0100120:	eb f1                	jmp    f0100113 <i386_init+0x7f>

f0100122 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100122:	55                   	push   %ebp
f0100123:	89 e5                	mov    %esp,%ebp
f0100125:	56                   	push   %esi
f0100126:	53                   	push   %ebx
f0100127:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f010012a:	83 3d 40 29 11 f0 00 	cmpl   $0x0,0xf0112940
f0100131:	75 37                	jne    f010016a <_panic+0x48>
		goto dead;
	panicstr = fmt;
f0100133:	89 35 40 29 11 f0    	mov    %esi,0xf0112940

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100139:	fa                   	cli    
f010013a:	fc                   	cld    

	va_start(ap, fmt);
f010013b:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010013e:	83 ec 04             	sub    $0x4,%esp
f0100141:	ff 75 0c             	pushl  0xc(%ebp)
f0100144:	ff 75 08             	pushl  0x8(%ebp)
f0100147:	68 99 19 10 f0       	push   $0xf0101999
f010014c:	e8 7a 08 00 00       	call   f01009cb <cprintf>
	vcprintf(fmt, ap);
f0100151:	83 c4 08             	add    $0x8,%esp
f0100154:	53                   	push   %ebx
f0100155:	56                   	push   %esi
f0100156:	e8 4a 08 00 00       	call   f01009a5 <vcprintf>
	cprintf("\n");
f010015b:	c7 04 24 d5 19 10 f0 	movl   $0xf01019d5,(%esp)
f0100162:	e8 64 08 00 00       	call   f01009cb <cprintf>
	va_end(ap);
f0100167:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010016a:	83 ec 0c             	sub    $0xc,%esp
f010016d:	6a 00                	push   $0x0
f010016f:	e8 ea 06 00 00       	call   f010085e <monitor>
f0100174:	83 c4 10             	add    $0x10,%esp
f0100177:	eb f1                	jmp    f010016a <_panic+0x48>

f0100179 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100179:	55                   	push   %ebp
f010017a:	89 e5                	mov    %esp,%ebp
f010017c:	53                   	push   %ebx
f010017d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100180:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100183:	ff 75 0c             	pushl  0xc(%ebp)
f0100186:	ff 75 08             	pushl  0x8(%ebp)
f0100189:	68 b1 19 10 f0       	push   $0xf01019b1
f010018e:	e8 38 08 00 00       	call   f01009cb <cprintf>
	vcprintf(fmt, ap);
f0100193:	83 c4 08             	add    $0x8,%esp
f0100196:	53                   	push   %ebx
f0100197:	ff 75 10             	pushl  0x10(%ebp)
f010019a:	e8 06 08 00 00       	call   f01009a5 <vcprintf>
	cprintf("\n");
f010019f:	c7 04 24 d5 19 10 f0 	movl   $0xf01019d5,(%esp)
f01001a6:	e8 20 08 00 00       	call   f01009cb <cprintf>
	va_end(ap);
}
f01001ab:	83 c4 10             	add    $0x10,%esp
f01001ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01001b1:	c9                   	leave  
f01001b2:	c3                   	ret    

f01001b3 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01001b6:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01001bb:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01001bc:	a8 01                	test   $0x1,%al
f01001be:	74 0b                	je     f01001cb <serial_proc_data+0x18>
f01001c0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01001c5:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01001c6:	0f b6 c0             	movzbl %al,%eax
f01001c9:	eb 05                	jmp    f01001d0 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f01001cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f01001d0:	5d                   	pop    %ebp
f01001d1:	c3                   	ret    

f01001d2 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01001d2:	55                   	push   %ebp
f01001d3:	89 e5                	mov    %esp,%ebp
f01001d5:	53                   	push   %ebx
f01001d6:	83 ec 04             	sub    $0x4,%esp
f01001d9:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001db:	eb 2b                	jmp    f0100208 <cons_intr+0x36>
		if (c == 0)
f01001dd:	85 c0                	test   %eax,%eax
f01001df:	74 27                	je     f0100208 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01001e1:	8b 0d 24 25 11 f0    	mov    0xf0112524,%ecx
f01001e7:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ea:	89 15 24 25 11 f0    	mov    %edx,0xf0112524
f01001f0:	88 81 20 23 11 f0    	mov    %al,-0xfeedce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001f6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01001fc:	75 0a                	jne    f0100208 <cons_intr+0x36>
			cons.wpos = 0;
f01001fe:	c7 05 24 25 11 f0 00 	movl   $0x0,0xf0112524
f0100205:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100208:	ff d3                	call   *%ebx
f010020a:	83 f8 ff             	cmp    $0xffffffff,%eax
f010020d:	75 ce                	jne    f01001dd <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010020f:	83 c4 04             	add    $0x4,%esp
f0100212:	5b                   	pop    %ebx
f0100213:	5d                   	pop    %ebp
f0100214:	c3                   	ret    

f0100215 <kbd_proc_data>:
f0100215:	ba 64 00 00 00       	mov    $0x64,%edx
f010021a:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f010021b:	a8 01                	test   $0x1,%al
f010021d:	0f 84 f8 00 00 00    	je     f010031b <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f0100223:	a8 20                	test   $0x20,%al
f0100225:	0f 85 f6 00 00 00    	jne    f0100321 <kbd_proc_data+0x10c>
f010022b:	ba 60 00 00 00       	mov    $0x60,%edx
f0100230:	ec                   	in     (%dx),%al
f0100231:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f0100233:	3c e0                	cmp    $0xe0,%al
f0100235:	75 0d                	jne    f0100244 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f0100237:	83 0d 00 23 11 f0 40 	orl    $0x40,0xf0112300
		return 0;
f010023e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100243:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100244:	55                   	push   %ebp
f0100245:	89 e5                	mov    %esp,%ebp
f0100247:	53                   	push   %ebx
f0100248:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f010024b:	84 c0                	test   %al,%al
f010024d:	79 36                	jns    f0100285 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f010024f:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f0100255:	89 cb                	mov    %ecx,%ebx
f0100257:	83 e3 40             	and    $0x40,%ebx
f010025a:	83 e0 7f             	and    $0x7f,%eax
f010025d:	85 db                	test   %ebx,%ebx
f010025f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100262:	0f b6 d2             	movzbl %dl,%edx
f0100265:	0f b6 82 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%eax
f010026c:	83 c8 40             	or     $0x40,%eax
f010026f:	0f b6 c0             	movzbl %al,%eax
f0100272:	f7 d0                	not    %eax
f0100274:	21 c8                	and    %ecx,%eax
f0100276:	a3 00 23 11 f0       	mov    %eax,0xf0112300
		return 0;
f010027b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100280:	e9 a4 00 00 00       	jmp    f0100329 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100285:	8b 0d 00 23 11 f0    	mov    0xf0112300,%ecx
f010028b:	f6 c1 40             	test   $0x40,%cl
f010028e:	74 0e                	je     f010029e <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100290:	83 c8 80             	or     $0xffffff80,%eax
f0100293:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100295:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100298:	89 0d 00 23 11 f0    	mov    %ecx,0xf0112300
	}

	shift |= shiftcode[data];
f010029e:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01002a1:	0f b6 82 20 1b 10 f0 	movzbl -0xfefe4e0(%edx),%eax
f01002a8:	0b 05 00 23 11 f0    	or     0xf0112300,%eax
f01002ae:	0f b6 8a 20 1a 10 f0 	movzbl -0xfefe5e0(%edx),%ecx
f01002b5:	31 c8                	xor    %ecx,%eax
f01002b7:	a3 00 23 11 f0       	mov    %eax,0xf0112300

	c = charcode[shift & (CTL | SHIFT)][data];
f01002bc:	89 c1                	mov    %eax,%ecx
f01002be:	83 e1 03             	and    $0x3,%ecx
f01002c1:	8b 0c 8d 00 1a 10 f0 	mov    -0xfefe600(,%ecx,4),%ecx
f01002c8:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f01002cc:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f01002cf:	a8 08                	test   $0x8,%al
f01002d1:	74 1b                	je     f01002ee <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f01002d3:	89 da                	mov    %ebx,%edx
f01002d5:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f01002d8:	83 f9 19             	cmp    $0x19,%ecx
f01002db:	77 05                	ja     f01002e2 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01002dd:	83 eb 20             	sub    $0x20,%ebx
f01002e0:	eb 0c                	jmp    f01002ee <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01002e2:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01002e5:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01002e8:	83 fa 19             	cmp    $0x19,%edx
f01002eb:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002ee:	f7 d0                	not    %eax
f01002f0:	a8 06                	test   $0x6,%al
f01002f2:	75 33                	jne    f0100327 <kbd_proc_data+0x112>
f01002f4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002fa:	75 2b                	jne    f0100327 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01002fc:	83 ec 0c             	sub    $0xc,%esp
f01002ff:	68 cb 19 10 f0       	push   $0xf01019cb
f0100304:	e8 c2 06 00 00       	call   f01009cb <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100309:	ba 92 00 00 00       	mov    $0x92,%edx
f010030e:	b8 03 00 00 00       	mov    $0x3,%eax
f0100313:	ee                   	out    %al,(%dx)
f0100314:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100317:	89 d8                	mov    %ebx,%eax
f0100319:	eb 0e                	jmp    f0100329 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f010031b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100320:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f0100321:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100326:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100327:	89 d8                	mov    %ebx,%eax
}
f0100329:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010032c:	c9                   	leave  
f010032d:	c3                   	ret    

f010032e <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f010032e:	55                   	push   %ebp
f010032f:	89 e5                	mov    %esp,%ebp
f0100331:	57                   	push   %edi
f0100332:	56                   	push   %esi
f0100333:	53                   	push   %ebx
f0100334:	83 ec 1c             	sub    $0x1c,%esp
f0100337:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100339:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010033e:	be fd 03 00 00       	mov    $0x3fd,%esi
f0100343:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100348:	eb 09                	jmp    f0100353 <cons_putc+0x25>
f010034a:	89 ca                	mov    %ecx,%edx
f010034c:	ec                   	in     (%dx),%al
f010034d:	ec                   	in     (%dx),%al
f010034e:	ec                   	in     (%dx),%al
f010034f:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100350:	83 c3 01             	add    $0x1,%ebx
f0100353:	89 f2                	mov    %esi,%edx
f0100355:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100356:	a8 20                	test   $0x20,%al
f0100358:	75 08                	jne    f0100362 <cons_putc+0x34>
f010035a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100360:	7e e8                	jle    f010034a <cons_putc+0x1c>
f0100362:	89 f8                	mov    %edi,%eax
f0100364:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100367:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010036c:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010036d:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100372:	be 79 03 00 00       	mov    $0x379,%esi
f0100377:	b9 84 00 00 00       	mov    $0x84,%ecx
f010037c:	eb 09                	jmp    f0100387 <cons_putc+0x59>
f010037e:	89 ca                	mov    %ecx,%edx
f0100380:	ec                   	in     (%dx),%al
f0100381:	ec                   	in     (%dx),%al
f0100382:	ec                   	in     (%dx),%al
f0100383:	ec                   	in     (%dx),%al
f0100384:	83 c3 01             	add    $0x1,%ebx
f0100387:	89 f2                	mov    %esi,%edx
f0100389:	ec                   	in     (%dx),%al
f010038a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100390:	7f 04                	jg     f0100396 <cons_putc+0x68>
f0100392:	84 c0                	test   %al,%al
f0100394:	79 e8                	jns    f010037e <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100396:	ba 78 03 00 00       	mov    $0x378,%edx
f010039b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010039f:	ee                   	out    %al,(%dx)
f01003a0:	ba 7a 03 00 00       	mov    $0x37a,%edx
f01003a5:	b8 0d 00 00 00       	mov    $0xd,%eax
f01003aa:	ee                   	out    %al,(%dx)
f01003ab:	b8 08 00 00 00       	mov    $0x8,%eax
f01003b0:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f01003b1:	89 fa                	mov    %edi,%edx
f01003b3:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f01003b9:	89 f8                	mov    %edi,%eax
f01003bb:	80 cc 07             	or     $0x7,%ah
f01003be:	85 d2                	test   %edx,%edx
f01003c0:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f01003c3:	89 f8                	mov    %edi,%eax
f01003c5:	0f b6 c0             	movzbl %al,%eax
f01003c8:	83 f8 09             	cmp    $0x9,%eax
f01003cb:	74 74                	je     f0100441 <cons_putc+0x113>
f01003cd:	83 f8 09             	cmp    $0x9,%eax
f01003d0:	7f 0a                	jg     f01003dc <cons_putc+0xae>
f01003d2:	83 f8 08             	cmp    $0x8,%eax
f01003d5:	74 14                	je     f01003eb <cons_putc+0xbd>
f01003d7:	e9 99 00 00 00       	jmp    f0100475 <cons_putc+0x147>
f01003dc:	83 f8 0a             	cmp    $0xa,%eax
f01003df:	74 3a                	je     f010041b <cons_putc+0xed>
f01003e1:	83 f8 0d             	cmp    $0xd,%eax
f01003e4:	74 3d                	je     f0100423 <cons_putc+0xf5>
f01003e6:	e9 8a 00 00 00       	jmp    f0100475 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01003eb:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f01003f2:	66 85 c0             	test   %ax,%ax
f01003f5:	0f 84 e6 00 00 00    	je     f01004e1 <cons_putc+0x1b3>
			crt_pos--;
f01003fb:	83 e8 01             	sub    $0x1,%eax
f01003fe:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100404:	0f b7 c0             	movzwl %ax,%eax
f0100407:	66 81 e7 00 ff       	and    $0xff00,%di
f010040c:	83 cf 20             	or     $0x20,%edi
f010040f:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f0100415:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100419:	eb 78                	jmp    f0100493 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f010041b:	66 83 05 28 25 11 f0 	addw   $0x50,0xf0112528
f0100422:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100423:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010042a:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100430:	c1 e8 16             	shr    $0x16,%eax
f0100433:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100436:	c1 e0 04             	shl    $0x4,%eax
f0100439:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
f010043f:	eb 52                	jmp    f0100493 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100441:	b8 20 00 00 00       	mov    $0x20,%eax
f0100446:	e8 e3 fe ff ff       	call   f010032e <cons_putc>
		cons_putc(' ');
f010044b:	b8 20 00 00 00       	mov    $0x20,%eax
f0100450:	e8 d9 fe ff ff       	call   f010032e <cons_putc>
		cons_putc(' ');
f0100455:	b8 20 00 00 00       	mov    $0x20,%eax
f010045a:	e8 cf fe ff ff       	call   f010032e <cons_putc>
		cons_putc(' ');
f010045f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100464:	e8 c5 fe ff ff       	call   f010032e <cons_putc>
		cons_putc(' ');
f0100469:	b8 20 00 00 00       	mov    $0x20,%eax
f010046e:	e8 bb fe ff ff       	call   f010032e <cons_putc>
f0100473:	eb 1e                	jmp    f0100493 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100475:	0f b7 05 28 25 11 f0 	movzwl 0xf0112528,%eax
f010047c:	8d 50 01             	lea    0x1(%eax),%edx
f010047f:	66 89 15 28 25 11 f0 	mov    %dx,0xf0112528
f0100486:	0f b7 c0             	movzwl %ax,%eax
f0100489:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f010048f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100493:	66 81 3d 28 25 11 f0 	cmpw   $0x7cf,0xf0112528
f010049a:	cf 07 
f010049c:	76 43                	jbe    f01004e1 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010049e:	a1 2c 25 11 f0       	mov    0xf011252c,%eax
f01004a3:	83 ec 04             	sub    $0x4,%esp
f01004a6:	68 00 0f 00 00       	push   $0xf00
f01004ab:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004b1:	52                   	push   %edx
f01004b2:	50                   	push   %eax
f01004b3:	e8 19 10 00 00       	call   f01014d1 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004b8:	8b 15 2c 25 11 f0    	mov    0xf011252c,%edx
f01004be:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f01004c4:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f01004ca:	83 c4 10             	add    $0x10,%esp
f01004cd:	66 c7 00 20 07       	movw   $0x720,(%eax)
f01004d2:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f01004d5:	39 d0                	cmp    %edx,%eax
f01004d7:	75 f4                	jne    f01004cd <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01004d9:	66 83 2d 28 25 11 f0 	subw   $0x50,0xf0112528
f01004e0:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004e1:	8b 0d 30 25 11 f0    	mov    0xf0112530,%ecx
f01004e7:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004ec:	89 ca                	mov    %ecx,%edx
f01004ee:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004ef:	0f b7 1d 28 25 11 f0 	movzwl 0xf0112528,%ebx
f01004f6:	8d 71 01             	lea    0x1(%ecx),%esi
f01004f9:	89 d8                	mov    %ebx,%eax
f01004fb:	66 c1 e8 08          	shr    $0x8,%ax
f01004ff:	89 f2                	mov    %esi,%edx
f0100501:	ee                   	out    %al,(%dx)
f0100502:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100507:	89 ca                	mov    %ecx,%edx
f0100509:	ee                   	out    %al,(%dx)
f010050a:	89 d8                	mov    %ebx,%eax
f010050c:	89 f2                	mov    %esi,%edx
f010050e:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010050f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100512:	5b                   	pop    %ebx
f0100513:	5e                   	pop    %esi
f0100514:	5f                   	pop    %edi
f0100515:	5d                   	pop    %ebp
f0100516:	c3                   	ret    

f0100517 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100517:	80 3d 34 25 11 f0 00 	cmpb   $0x0,0xf0112534
f010051e:	74 11                	je     f0100531 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100520:	55                   	push   %ebp
f0100521:	89 e5                	mov    %esp,%ebp
f0100523:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f0100526:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
f010052b:	e8 a2 fc ff ff       	call   f01001d2 <cons_intr>
}
f0100530:	c9                   	leave  
f0100531:	f3 c3                	repz ret 

f0100533 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f0100533:	55                   	push   %ebp
f0100534:	89 e5                	mov    %esp,%ebp
f0100536:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100539:	b8 15 02 10 f0       	mov    $0xf0100215,%eax
f010053e:	e8 8f fc ff ff       	call   f01001d2 <cons_intr>
}
f0100543:	c9                   	leave  
f0100544:	c3                   	ret    

f0100545 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f0100545:	55                   	push   %ebp
f0100546:	89 e5                	mov    %esp,%ebp
f0100548:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f010054b:	e8 c7 ff ff ff       	call   f0100517 <serial_intr>
	kbd_intr();
f0100550:	e8 de ff ff ff       	call   f0100533 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100555:	a1 20 25 11 f0       	mov    0xf0112520,%eax
f010055a:	3b 05 24 25 11 f0    	cmp    0xf0112524,%eax
f0100560:	74 26                	je     f0100588 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100562:	8d 50 01             	lea    0x1(%eax),%edx
f0100565:	89 15 20 25 11 f0    	mov    %edx,0xf0112520
f010056b:	0f b6 88 20 23 11 f0 	movzbl -0xfeedce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100572:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100574:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010057a:	75 11                	jne    f010058d <cons_getc+0x48>
			cons.rpos = 0;
f010057c:	c7 05 20 25 11 f0 00 	movl   $0x0,0xf0112520
f0100583:	00 00 00 
f0100586:	eb 05                	jmp    f010058d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100588:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010058d:	c9                   	leave  
f010058e:	c3                   	ret    

f010058f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010058f:	55                   	push   %ebp
f0100590:	89 e5                	mov    %esp,%ebp
f0100592:	57                   	push   %edi
f0100593:	56                   	push   %esi
f0100594:	53                   	push   %ebx
f0100595:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100598:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010059f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f01005a6:	5a a5 
	if (*cp != 0xA55A) {
f01005a8:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f01005af:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01005b3:	74 11                	je     f01005c6 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01005b5:	c7 05 30 25 11 f0 b4 	movl   $0x3b4,0xf0112530
f01005bc:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f01005bf:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f01005c4:	eb 16                	jmp    f01005dc <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f01005c6:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f01005cd:	c7 05 30 25 11 f0 d4 	movl   $0x3d4,0xf0112530
f01005d4:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f01005d7:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01005dc:	8b 3d 30 25 11 f0    	mov    0xf0112530,%edi
f01005e2:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005e7:	89 fa                	mov    %edi,%edx
f01005e9:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01005ea:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005ed:	89 da                	mov    %ebx,%edx
f01005ef:	ec                   	in     (%dx),%al
f01005f0:	0f b6 c8             	movzbl %al,%ecx
f01005f3:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005f6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005fb:	89 fa                	mov    %edi,%edx
f01005fd:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005fe:	89 da                	mov    %ebx,%edx
f0100600:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100601:	89 35 2c 25 11 f0    	mov    %esi,0xf011252c
	crt_pos = pos;
f0100607:	0f b6 c0             	movzbl %al,%eax
f010060a:	09 c8                	or     %ecx,%eax
f010060c:	66 a3 28 25 11 f0    	mov    %ax,0xf0112528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100612:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100617:	b8 00 00 00 00       	mov    $0x0,%eax
f010061c:	89 f2                	mov    %esi,%edx
f010061e:	ee                   	out    %al,(%dx)
f010061f:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100624:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100629:	ee                   	out    %al,(%dx)
f010062a:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f010062f:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100634:	89 da                	mov    %ebx,%edx
f0100636:	ee                   	out    %al,(%dx)
f0100637:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010063c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100641:	ee                   	out    %al,(%dx)
f0100642:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100647:	b8 03 00 00 00       	mov    $0x3,%eax
f010064c:	ee                   	out    %al,(%dx)
f010064d:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100652:	b8 00 00 00 00       	mov    $0x0,%eax
f0100657:	ee                   	out    %al,(%dx)
f0100658:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010065d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100662:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100663:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100668:	ec                   	in     (%dx),%al
f0100669:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010066b:	3c ff                	cmp    $0xff,%al
f010066d:	0f 95 05 34 25 11 f0 	setne  0xf0112534
f0100674:	89 f2                	mov    %esi,%edx
f0100676:	ec                   	in     (%dx),%al
f0100677:	89 da                	mov    %ebx,%edx
f0100679:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f010067a:	80 f9 ff             	cmp    $0xff,%cl
f010067d:	75 10                	jne    f010068f <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f010067f:	83 ec 0c             	sub    $0xc,%esp
f0100682:	68 d7 19 10 f0       	push   $0xf01019d7
f0100687:	e8 3f 03 00 00       	call   f01009cb <cprintf>
f010068c:	83 c4 10             	add    $0x10,%esp
}
f010068f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100692:	5b                   	pop    %ebx
f0100693:	5e                   	pop    %esi
f0100694:	5f                   	pop    %edi
f0100695:	5d                   	pop    %ebp
f0100696:	c3                   	ret    

f0100697 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100697:	55                   	push   %ebp
f0100698:	89 e5                	mov    %esp,%ebp
f010069a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010069d:	8b 45 08             	mov    0x8(%ebp),%eax
f01006a0:	e8 89 fc ff ff       	call   f010032e <cons_putc>
}
f01006a5:	c9                   	leave  
f01006a6:	c3                   	ret    

f01006a7 <getchar>:

int
getchar(void)
{
f01006a7:	55                   	push   %ebp
f01006a8:	89 e5                	mov    %esp,%ebp
f01006aa:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01006ad:	e8 93 fe ff ff       	call   f0100545 <cons_getc>
f01006b2:	85 c0                	test   %eax,%eax
f01006b4:	74 f7                	je     f01006ad <getchar+0x6>
		/* do nothing */;
	return c;
}
f01006b6:	c9                   	leave  
f01006b7:	c3                   	ret    

f01006b8 <iscons>:

int
iscons(int fdnum)
{
f01006b8:	55                   	push   %ebp
f01006b9:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01006bb:	b8 01 00 00 00       	mov    $0x1,%eax
f01006c0:	5d                   	pop    %ebp
f01006c1:	c3                   	ret    

f01006c2 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006c2:	55                   	push   %ebp
f01006c3:	89 e5                	mov    %esp,%ebp
f01006c5:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006c8:	68 20 1c 10 f0       	push   $0xf0101c20
f01006cd:	68 3e 1c 10 f0       	push   $0xf0101c3e
f01006d2:	68 43 1c 10 f0       	push   $0xf0101c43
f01006d7:	e8 ef 02 00 00       	call   f01009cb <cprintf>
f01006dc:	83 c4 0c             	add    $0xc,%esp
f01006df:	68 f4 1c 10 f0       	push   $0xf0101cf4
f01006e4:	68 4c 1c 10 f0       	push   $0xf0101c4c
f01006e9:	68 43 1c 10 f0       	push   $0xf0101c43
f01006ee:	e8 d8 02 00 00       	call   f01009cb <cprintf>
f01006f3:	83 c4 0c             	add    $0xc,%esp
f01006f6:	68 55 1c 10 f0       	push   $0xf0101c55
f01006fb:	68 72 1c 10 f0       	push   $0xf0101c72
f0100700:	68 43 1c 10 f0       	push   $0xf0101c43
f0100705:	e8 c1 02 00 00       	call   f01009cb <cprintf>
	return 0;
}
f010070a:	b8 00 00 00 00       	mov    $0x0,%eax
f010070f:	c9                   	leave  
f0100710:	c3                   	ret    

f0100711 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100711:	55                   	push   %ebp
f0100712:	89 e5                	mov    %esp,%ebp
f0100714:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100717:	68 7c 1c 10 f0       	push   $0xf0101c7c
f010071c:	e8 aa 02 00 00       	call   f01009cb <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100721:	83 c4 08             	add    $0x8,%esp
f0100724:	68 0c 00 10 00       	push   $0x10000c
f0100729:	68 1c 1d 10 f0       	push   $0xf0101d1c
f010072e:	e8 98 02 00 00       	call   f01009cb <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100733:	83 c4 0c             	add    $0xc,%esp
f0100736:	68 0c 00 10 00       	push   $0x10000c
f010073b:	68 0c 00 10 f0       	push   $0xf010000c
f0100740:	68 44 1d 10 f0       	push   $0xf0101d44
f0100745:	e8 81 02 00 00       	call   f01009cb <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010074a:	83 c4 0c             	add    $0xc,%esp
f010074d:	68 11 19 10 00       	push   $0x101911
f0100752:	68 11 19 10 f0       	push   $0xf0101911
f0100757:	68 68 1d 10 f0       	push   $0xf0101d68
f010075c:	e8 6a 02 00 00       	call   f01009cb <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100761:	83 c4 0c             	add    $0xc,%esp
f0100764:	68 00 23 11 00       	push   $0x112300
f0100769:	68 00 23 11 f0       	push   $0xf0112300
f010076e:	68 8c 1d 10 f0       	push   $0xf0101d8c
f0100773:	e8 53 02 00 00       	call   f01009cb <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100778:	83 c4 0c             	add    $0xc,%esp
f010077b:	68 44 29 11 00       	push   $0x112944
f0100780:	68 44 29 11 f0       	push   $0xf0112944
f0100785:	68 b0 1d 10 f0       	push   $0xf0101db0
f010078a:	e8 3c 02 00 00       	call   f01009cb <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010078f:	b8 43 2d 11 f0       	mov    $0xf0112d43,%eax
f0100794:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100799:	83 c4 08             	add    $0x8,%esp
f010079c:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01007a1:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01007a7:	85 c0                	test   %eax,%eax
f01007a9:	0f 48 c2             	cmovs  %edx,%eax
f01007ac:	c1 f8 0a             	sar    $0xa,%eax
f01007af:	50                   	push   %eax
f01007b0:	68 d4 1d 10 f0       	push   $0xf0101dd4
f01007b5:	e8 11 02 00 00       	call   f01009cb <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01007ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01007bf:	c9                   	leave  
f01007c0:	c3                   	ret    

f01007c1 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01007c1:	55                   	push   %ebp
f01007c2:	89 e5                	mov    %esp,%ebp
f01007c4:	57                   	push   %edi
f01007c5:	56                   	push   %esi
f01007c6:	53                   	push   %ebx
f01007c7:	83 ec 58             	sub    $0x58,%esp

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f01007ca:	89 e8                	mov    %ebp,%eax
f01007cc:	89 c6                	mov    %eax,%esi
	// Your code here.
	uint32_t ebp = read_ebp();
	uint32_t args[5];
	struct Eipdebuginfo eip_debug_info;

	cprintf("Stack backtrace:\n");
f01007ce:	68 95 1c 10 f0       	push   $0xf0101c95
f01007d3:	e8 f3 01 00 00       	call   f01009cb <cprintf>
	// When ebp is 0, we've reached the end of the call stack
	while (ebp != 0) {
f01007d8:	83 c4 10             	add    $0x10,%esp
f01007db:	eb 70                	jmp    f010084d <mon_backtrace+0x8c>

static inline uint32_t
read_byte_at_addr(uint32_t *addr)
{
        uint32_t val;
        asm volatile("movl (%1),%0" : "=r" (val) : "r" (addr));
f01007dd:	8b 06                	mov    (%esi),%eax
f01007df:	89 45 b4             	mov    %eax,-0x4c(%ebp)
f01007e2:	8d 5e 04             	lea    0x4(%esi),%ebx
f01007e5:	8b 1b                	mov    (%ebx),%ebx
		uint32_t prev_ebp = read_byte_at_addr((uint32_t *) ebp);

		// eip is address of the next instruction to be executed
		uint32_t eip = read_byte_at_addr((uint32_t *) (ebp + 1 * sizeof(uint32_t)));
		debuginfo_eip(eip, &eip_debug_info);
f01007e7:	83 ec 08             	sub    $0x8,%esp
f01007ea:	8d 45 bc             	lea    -0x44(%ebp),%eax
f01007ed:	50                   	push   %eax
f01007ee:	53                   	push   %ebx
f01007ef:	e8 e1 02 00 00       	call   f0100ad5 <debuginfo_eip>
f01007f4:	8d 46 08             	lea    0x8(%esi),%eax
f01007f7:	8d 7e 1c             	lea    0x1c(%esi),%edi
f01007fa:	83 c4 10             	add    $0x10,%esp

		for (int i = 0; i < 5; i++) {
			args[i] = read_byte_at_addr((uint32_t *) (ebp + (i + 2) * sizeof(uint32_t)));
f01007fd:	8d 4d d4             	lea    -0x2c(%ebp),%ecx
f0100800:	29 f1                	sub    %esi,%ecx
f0100802:	8b 10                	mov    (%eax),%edx
f0100804:	89 54 01 f8          	mov    %edx,-0x8(%ecx,%eax,1)
f0100808:	83 c0 04             	add    $0x4,%eax

		// eip is address of the next instruction to be executed
		uint32_t eip = read_byte_at_addr((uint32_t *) (ebp + 1 * sizeof(uint32_t)));
		debuginfo_eip(eip, &eip_debug_info);

		for (int i = 0; i < 5; i++) {
f010080b:	39 f8                	cmp    %edi,%eax
f010080d:	75 f3                	jne    f0100802 <mon_backtrace+0x41>
			args[i] = read_byte_at_addr((uint32_t *) (ebp + (i + 2) * sizeof(uint32_t)));
		}
		cprintf("ebp %08x eip %08x args %08x %08x %08x %08x %08x\n", ebp, eip, args[0], args[1], args[2], args[3], args[4]);
f010080f:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100812:	ff 75 e0             	pushl  -0x20(%ebp)
f0100815:	ff 75 dc             	pushl  -0x24(%ebp)
f0100818:	ff 75 d8             	pushl  -0x28(%ebp)
f010081b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010081e:	53                   	push   %ebx
f010081f:	56                   	push   %esi
f0100820:	68 00 1e 10 f0       	push   $0xf0101e00
f0100825:	e8 a1 01 00 00       	call   f01009cb <cprintf>
		cprintf("\t%s:%d: %.*s+%d\n", eip_debug_info.eip_file, eip_debug_info.eip_line, eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name, eip - eip_debug_info.eip_fn_addr);
f010082a:	83 c4 18             	add    $0x18,%esp
f010082d:	2b 5d cc             	sub    -0x34(%ebp),%ebx
f0100830:	53                   	push   %ebx
f0100831:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100834:	ff 75 c8             	pushl  -0x38(%ebp)
f0100837:	ff 75 c0             	pushl  -0x40(%ebp)
f010083a:	ff 75 bc             	pushl  -0x44(%ebp)
f010083d:	68 a7 1c 10 f0       	push   $0xf0101ca7
f0100842:	e8 84 01 00 00       	call   f01009cb <cprintf>
f0100847:	83 c4 20             	add    $0x20,%esp
		ebp = prev_ebp;
f010084a:	8b 75 b4             	mov    -0x4c(%ebp),%esi
	uint32_t args[5];
	struct Eipdebuginfo eip_debug_info;

	cprintf("Stack backtrace:\n");
	// When ebp is 0, we've reached the end of the call stack
	while (ebp != 0) {
f010084d:	85 f6                	test   %esi,%esi
f010084f:	75 8c                	jne    f01007dd <mon_backtrace+0x1c>
		cprintf("\t%s:%d: %.*s+%d\n", eip_debug_info.eip_file, eip_debug_info.eip_line, eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name, eip - eip_debug_info.eip_fn_addr);
		ebp = prev_ebp;
	}

	return 0;
}
f0100851:	b8 00 00 00 00       	mov    $0x0,%eax
f0100856:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100859:	5b                   	pop    %ebx
f010085a:	5e                   	pop    %esi
f010085b:	5f                   	pop    %edi
f010085c:	5d                   	pop    %ebp
f010085d:	c3                   	ret    

f010085e <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010085e:	55                   	push   %ebp
f010085f:	89 e5                	mov    %esp,%ebp
f0100861:	57                   	push   %edi
f0100862:	56                   	push   %esi
f0100863:	53                   	push   %ebx
f0100864:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100867:	68 34 1e 10 f0       	push   $0xf0101e34
f010086c:	e8 5a 01 00 00       	call   f01009cb <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100871:	c7 04 24 58 1e 10 f0 	movl   $0xf0101e58,(%esp)
f0100878:	e8 4e 01 00 00       	call   f01009cb <cprintf>
f010087d:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100880:	83 ec 0c             	sub    $0xc,%esp
f0100883:	68 b8 1c 10 f0       	push   $0xf0101cb8
f0100888:	e8 a0 09 00 00       	call   f010122d <readline>
f010088d:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010088f:	83 c4 10             	add    $0x10,%esp
f0100892:	85 c0                	test   %eax,%eax
f0100894:	74 ea                	je     f0100880 <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100896:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010089d:	be 00 00 00 00       	mov    $0x0,%esi
f01008a2:	eb 0a                	jmp    f01008ae <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008a4:	c6 03 00             	movb   $0x0,(%ebx)
f01008a7:	89 f7                	mov    %esi,%edi
f01008a9:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01008ac:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008ae:	0f b6 03             	movzbl (%ebx),%eax
f01008b1:	84 c0                	test   %al,%al
f01008b3:	74 63                	je     f0100918 <monitor+0xba>
f01008b5:	83 ec 08             	sub    $0x8,%esp
f01008b8:	0f be c0             	movsbl %al,%eax
f01008bb:	50                   	push   %eax
f01008bc:	68 bc 1c 10 f0       	push   $0xf0101cbc
f01008c1:	e8 81 0b 00 00       	call   f0101447 <strchr>
f01008c6:	83 c4 10             	add    $0x10,%esp
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	75 d7                	jne    f01008a4 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f01008cd:	80 3b 00             	cmpb   $0x0,(%ebx)
f01008d0:	74 46                	je     f0100918 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01008d2:	83 fe 0f             	cmp    $0xf,%esi
f01008d5:	75 14                	jne    f01008eb <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01008d7:	83 ec 08             	sub    $0x8,%esp
f01008da:	6a 10                	push   $0x10
f01008dc:	68 c1 1c 10 f0       	push   $0xf0101cc1
f01008e1:	e8 e5 00 00 00       	call   f01009cb <cprintf>
f01008e6:	83 c4 10             	add    $0x10,%esp
f01008e9:	eb 95                	jmp    f0100880 <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01008eb:	8d 7e 01             	lea    0x1(%esi),%edi
f01008ee:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01008f2:	eb 03                	jmp    f01008f7 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01008f4:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01008f7:	0f b6 03             	movzbl (%ebx),%eax
f01008fa:	84 c0                	test   %al,%al
f01008fc:	74 ae                	je     f01008ac <monitor+0x4e>
f01008fe:	83 ec 08             	sub    $0x8,%esp
f0100901:	0f be c0             	movsbl %al,%eax
f0100904:	50                   	push   %eax
f0100905:	68 bc 1c 10 f0       	push   $0xf0101cbc
f010090a:	e8 38 0b 00 00       	call   f0101447 <strchr>
f010090f:	83 c4 10             	add    $0x10,%esp
f0100912:	85 c0                	test   %eax,%eax
f0100914:	74 de                	je     f01008f4 <monitor+0x96>
f0100916:	eb 94                	jmp    f01008ac <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f0100918:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010091f:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100920:	85 f6                	test   %esi,%esi
f0100922:	0f 84 58 ff ff ff    	je     f0100880 <monitor+0x22>
f0100928:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010092d:	83 ec 08             	sub    $0x8,%esp
f0100930:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100933:	ff 34 85 80 1e 10 f0 	pushl  -0xfefe180(,%eax,4)
f010093a:	ff 75 a8             	pushl  -0x58(%ebp)
f010093d:	e8 a7 0a 00 00       	call   f01013e9 <strcmp>
f0100942:	83 c4 10             	add    $0x10,%esp
f0100945:	85 c0                	test   %eax,%eax
f0100947:	75 21                	jne    f010096a <monitor+0x10c>
			return commands[i].func(argc, argv, tf);
f0100949:	83 ec 04             	sub    $0x4,%esp
f010094c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010094f:	ff 75 08             	pushl  0x8(%ebp)
f0100952:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100955:	52                   	push   %edx
f0100956:	56                   	push   %esi
f0100957:	ff 14 85 88 1e 10 f0 	call   *-0xfefe178(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f010095e:	83 c4 10             	add    $0x10,%esp
f0100961:	85 c0                	test   %eax,%eax
f0100963:	78 25                	js     f010098a <monitor+0x12c>
f0100965:	e9 16 ff ff ff       	jmp    f0100880 <monitor+0x22>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010096a:	83 c3 01             	add    $0x1,%ebx
f010096d:	83 fb 03             	cmp    $0x3,%ebx
f0100970:	75 bb                	jne    f010092d <monitor+0xcf>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100972:	83 ec 08             	sub    $0x8,%esp
f0100975:	ff 75 a8             	pushl  -0x58(%ebp)
f0100978:	68 de 1c 10 f0       	push   $0xf0101cde
f010097d:	e8 49 00 00 00       	call   f01009cb <cprintf>
f0100982:	83 c4 10             	add    $0x10,%esp
f0100985:	e9 f6 fe ff ff       	jmp    f0100880 <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010098a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010098d:	5b                   	pop    %ebx
f010098e:	5e                   	pop    %esi
f010098f:	5f                   	pop    %edi
f0100990:	5d                   	pop    %ebp
f0100991:	c3                   	ret    

f0100992 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100992:	55                   	push   %ebp
f0100993:	89 e5                	mov    %esp,%ebp
f0100995:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0100998:	ff 75 08             	pushl  0x8(%ebp)
f010099b:	e8 f7 fc ff ff       	call   f0100697 <cputchar>
	*cnt++;
}
f01009a0:	83 c4 10             	add    $0x10,%esp
f01009a3:	c9                   	leave  
f01009a4:	c3                   	ret    

f01009a5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01009a5:	55                   	push   %ebp
f01009a6:	89 e5                	mov    %esp,%ebp
f01009a8:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01009ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01009b2:	ff 75 0c             	pushl  0xc(%ebp)
f01009b5:	ff 75 08             	pushl  0x8(%ebp)
f01009b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01009bb:	50                   	push   %eax
f01009bc:	68 92 09 10 f0       	push   $0xf0100992
f01009c1:	e8 52 04 00 00       	call   f0100e18 <vprintfmt>
	return cnt;
}
f01009c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01009c9:	c9                   	leave  
f01009ca:	c3                   	ret    

f01009cb <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01009cb:	55                   	push   %ebp
f01009cc:	89 e5                	mov    %esp,%ebp
f01009ce:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01009d1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01009d4:	50                   	push   %eax
f01009d5:	ff 75 08             	pushl  0x8(%ebp)
f01009d8:	e8 c8 ff ff ff       	call   f01009a5 <vcprintf>
	va_end(ap);

	return cnt;
}
f01009dd:	c9                   	leave  
f01009de:	c3                   	ret    

f01009df <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01009df:	55                   	push   %ebp
f01009e0:	89 e5                	mov    %esp,%ebp
f01009e2:	57                   	push   %edi
f01009e3:	56                   	push   %esi
f01009e4:	53                   	push   %ebx
f01009e5:	83 ec 14             	sub    $0x14,%esp
f01009e8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01009eb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01009ee:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01009f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01009f4:	8b 1a                	mov    (%edx),%ebx
f01009f6:	8b 01                	mov    (%ecx),%eax
f01009f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01009fb:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0100a02:	eb 7f                	jmp    f0100a83 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0100a04:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0100a07:	01 d8                	add    %ebx,%eax
f0100a09:	89 c6                	mov    %eax,%esi
f0100a0b:	c1 ee 1f             	shr    $0x1f,%esi
f0100a0e:	01 c6                	add    %eax,%esi
f0100a10:	d1 fe                	sar    %esi
f0100a12:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0100a15:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a18:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0100a1b:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a1d:	eb 03                	jmp    f0100a22 <stab_binsearch+0x43>
			m--;
f0100a1f:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0100a22:	39 c3                	cmp    %eax,%ebx
f0100a24:	7f 0d                	jg     f0100a33 <stab_binsearch+0x54>
f0100a26:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100a2a:	83 ea 0c             	sub    $0xc,%edx
f0100a2d:	39 f9                	cmp    %edi,%ecx
f0100a2f:	75 ee                	jne    f0100a1f <stab_binsearch+0x40>
f0100a31:	eb 05                	jmp    f0100a38 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0100a33:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0100a36:	eb 4b                	jmp    f0100a83 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0100a38:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100a3b:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0100a3e:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0100a42:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a45:	76 11                	jbe    f0100a58 <stab_binsearch+0x79>
			*region_left = m;
f0100a47:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100a4a:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0100a4c:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a4f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a56:	eb 2b                	jmp    f0100a83 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0100a58:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0100a5b:	73 14                	jae    f0100a71 <stab_binsearch+0x92>
			*region_right = m - 1;
f0100a5d:	83 e8 01             	sub    $0x1,%eax
f0100a60:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0100a63:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a66:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a68:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0100a6f:	eb 12                	jmp    f0100a83 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0100a71:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100a74:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0100a76:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0100a7a:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0100a7c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0100a83:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0100a86:	0f 8e 78 ff ff ff    	jle    f0100a04 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0100a8c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0100a90:	75 0f                	jne    f0100aa1 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0100a92:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100a95:	8b 00                	mov    (%eax),%eax
f0100a97:	83 e8 01             	sub    $0x1,%eax
f0100a9a:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0100a9d:	89 06                	mov    %eax,(%esi)
f0100a9f:	eb 2c                	jmp    f0100acd <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100aa1:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100aa4:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0100aa6:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100aa9:	8b 0e                	mov    (%esi),%ecx
f0100aab:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0100aae:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0100ab1:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ab4:	eb 03                	jmp    f0100ab9 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0100ab6:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0100ab9:	39 c8                	cmp    %ecx,%eax
f0100abb:	7e 0b                	jle    f0100ac8 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0100abd:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0100ac1:	83 ea 0c             	sub    $0xc,%edx
f0100ac4:	39 df                	cmp    %ebx,%edi
f0100ac6:	75 ee                	jne    f0100ab6 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0100ac8:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100acb:	89 06                	mov    %eax,(%esi)
	}
}
f0100acd:	83 c4 14             	add    $0x14,%esp
f0100ad0:	5b                   	pop    %ebx
f0100ad1:	5e                   	pop    %esi
f0100ad2:	5f                   	pop    %edi
f0100ad3:	5d                   	pop    %ebp
f0100ad4:	c3                   	ret    

f0100ad5 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0100ad5:	55                   	push   %ebp
f0100ad6:	89 e5                	mov    %esp,%ebp
f0100ad8:	57                   	push   %edi
f0100ad9:	56                   	push   %esi
f0100ada:	53                   	push   %ebx
f0100adb:	83 ec 3c             	sub    $0x3c,%esp
f0100ade:	8b 75 08             	mov    0x8(%ebp),%esi
f0100ae1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0100ae4:	c7 03 a4 1e 10 f0    	movl   $0xf0101ea4,(%ebx)
	info->eip_line = 0;
f0100aea:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0100af1:	c7 43 08 a4 1e 10 f0 	movl   $0xf0101ea4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0100af8:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0100aff:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0100b02:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0100b09:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0100b0f:	76 11                	jbe    f0100b22 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b11:	b8 39 74 10 f0       	mov    $0xf0107439,%eax
f0100b16:	3d fd 5a 10 f0       	cmp    $0xf0105afd,%eax
f0100b1b:	77 19                	ja     f0100b36 <debuginfo_eip+0x61>
f0100b1d:	e9 aa 01 00 00       	jmp    f0100ccc <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0100b22:	83 ec 04             	sub    $0x4,%esp
f0100b25:	68 ae 1e 10 f0       	push   $0xf0101eae
f0100b2a:	6a 7f                	push   $0x7f
f0100b2c:	68 bb 1e 10 f0       	push   $0xf0101ebb
f0100b31:	e8 ec f5 ff ff       	call   f0100122 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0100b36:	80 3d 38 74 10 f0 00 	cmpb   $0x0,0xf0107438
f0100b3d:	0f 85 90 01 00 00    	jne    f0100cd3 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0100b43:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0100b4a:	b8 fc 5a 10 f0       	mov    $0xf0105afc,%eax
f0100b4f:	2d dc 20 10 f0       	sub    $0xf01020dc,%eax
f0100b54:	c1 f8 02             	sar    $0x2,%eax
f0100b57:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0100b5d:	83 e8 01             	sub    $0x1,%eax
f0100b60:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0100b63:	83 ec 08             	sub    $0x8,%esp
f0100b66:	56                   	push   %esi
f0100b67:	6a 64                	push   $0x64
f0100b69:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0100b6c:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0100b6f:	b8 dc 20 10 f0       	mov    $0xf01020dc,%eax
f0100b74:	e8 66 fe ff ff       	call   f01009df <stab_binsearch>
	if (lfile == 0)
f0100b79:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b7c:	83 c4 10             	add    $0x10,%esp
f0100b7f:	85 c0                	test   %eax,%eax
f0100b81:	0f 84 53 01 00 00    	je     f0100cda <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0100b87:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0100b8a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b8d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0100b90:	83 ec 08             	sub    $0x8,%esp
f0100b93:	56                   	push   %esi
f0100b94:	6a 24                	push   $0x24
f0100b96:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0100b99:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b9c:	b8 dc 20 10 f0       	mov    $0xf01020dc,%eax
f0100ba1:	e8 39 fe ff ff       	call   f01009df <stab_binsearch>

	if (lfun <= rfun) {
f0100ba6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100ba9:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0100bac:	83 c4 10             	add    $0x10,%esp
f0100baf:	39 d0                	cmp    %edx,%eax
f0100bb1:	7f 40                	jg     f0100bf3 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0100bb3:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f0100bb6:	c1 e1 02             	shl    $0x2,%ecx
f0100bb9:	8d b9 dc 20 10 f0    	lea    -0xfefdf24(%ecx),%edi
f0100bbf:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f0100bc2:	8b b9 dc 20 10 f0    	mov    -0xfefdf24(%ecx),%edi
f0100bc8:	b9 39 74 10 f0       	mov    $0xf0107439,%ecx
f0100bcd:	81 e9 fd 5a 10 f0    	sub    $0xf0105afd,%ecx
f0100bd3:	39 cf                	cmp    %ecx,%edi
f0100bd5:	73 09                	jae    f0100be0 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0100bd7:	81 c7 fd 5a 10 f0    	add    $0xf0105afd,%edi
f0100bdd:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0100be0:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0100be3:	8b 4f 08             	mov    0x8(%edi),%ecx
f0100be6:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0100be9:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f0100beb:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0100bee:	89 55 d0             	mov    %edx,-0x30(%ebp)
f0100bf1:	eb 0f                	jmp    f0100c02 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0100bf3:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0100bf6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100bf9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0100bfc:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100bff:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0100c02:	83 ec 08             	sub    $0x8,%esp
f0100c05:	6a 3a                	push   $0x3a
f0100c07:	ff 73 08             	pushl  0x8(%ebx)
f0100c0a:	e8 59 08 00 00       	call   f0101468 <strfind>
f0100c0f:	2b 43 08             	sub    0x8(%ebx),%eax
f0100c12:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0100c15:	83 c4 08             	add    $0x8,%esp
f0100c18:	56                   	push   %esi
f0100c19:	6a 44                	push   $0x44
f0100c1b:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0100c1e:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0100c21:	b8 dc 20 10 f0       	mov    $0xf01020dc,%eax
f0100c26:	e8 b4 fd ff ff       	call   f01009df <stab_binsearch>
	if (lline <= rline) {
f0100c2b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0100c2e:	83 c4 10             	add    $0x10,%esp
f0100c31:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100c34:	0f 8f a7 00 00 00    	jg     f0100ce1 <debuginfo_eip+0x20c>
		info->eip_line = stabs[lline].n_desc;
f0100c3a:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c3d:	8d 04 85 dc 20 10 f0 	lea    -0xfefdf24(,%eax,4),%eax
f0100c44:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f0100c48:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0100c4b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0100c4e:	eb 06                	jmp    f0100c56 <debuginfo_eip+0x181>
f0100c50:	83 ea 01             	sub    $0x1,%edx
f0100c53:	83 e8 0c             	sub    $0xc,%eax
f0100c56:	39 d6                	cmp    %edx,%esi
f0100c58:	7f 34                	jg     f0100c8e <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f0100c5a:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0100c5e:	80 f9 84             	cmp    $0x84,%cl
f0100c61:	74 0b                	je     f0100c6e <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0100c63:	80 f9 64             	cmp    $0x64,%cl
f0100c66:	75 e8                	jne    f0100c50 <debuginfo_eip+0x17b>
f0100c68:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0100c6c:	74 e2                	je     f0100c50 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0100c6e:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0100c71:	8b 14 85 dc 20 10 f0 	mov    -0xfefdf24(,%eax,4),%edx
f0100c78:	b8 39 74 10 f0       	mov    $0xf0107439,%eax
f0100c7d:	2d fd 5a 10 f0       	sub    $0xf0105afd,%eax
f0100c82:	39 c2                	cmp    %eax,%edx
f0100c84:	73 08                	jae    f0100c8e <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0100c86:	81 c2 fd 5a 10 f0    	add    $0xf0105afd,%edx
f0100c8c:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c8e:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100c91:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100c94:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0100c99:	39 f2                	cmp    %esi,%edx
f0100c9b:	7d 50                	jge    f0100ced <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f0100c9d:	83 c2 01             	add    $0x1,%edx
f0100ca0:	89 d0                	mov    %edx,%eax
f0100ca2:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0100ca5:	8d 14 95 dc 20 10 f0 	lea    -0xfefdf24(,%edx,4),%edx
f0100cac:	eb 04                	jmp    f0100cb2 <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0100cae:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0100cb2:	39 c6                	cmp    %eax,%esi
f0100cb4:	7e 32                	jle    f0100ce8 <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0100cb6:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0100cba:	83 c0 01             	add    $0x1,%eax
f0100cbd:	83 c2 0c             	add    $0xc,%edx
f0100cc0:	80 f9 a0             	cmp    $0xa0,%cl
f0100cc3:	74 e9                	je     f0100cae <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100cc5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100cca:	eb 21                	jmp    f0100ced <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0100ccc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cd1:	eb 1a                	jmp    f0100ced <debuginfo_eip+0x218>
f0100cd3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cd8:	eb 13                	jmp    f0100ced <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0100cda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100cdf:	eb 0c                	jmp    f0100ced <debuginfo_eip+0x218>
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;
f0100ce1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0100ce6:	eb 05                	jmp    f0100ced <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0100ce8:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cf0:	5b                   	pop    %ebx
f0100cf1:	5e                   	pop    %esi
f0100cf2:	5f                   	pop    %edi
f0100cf3:	5d                   	pop    %ebp
f0100cf4:	c3                   	ret    

f0100cf5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0100cf5:	55                   	push   %ebp
f0100cf6:	89 e5                	mov    %esp,%ebp
f0100cf8:	57                   	push   %edi
f0100cf9:	56                   	push   %esi
f0100cfa:	53                   	push   %ebx
f0100cfb:	83 ec 1c             	sub    $0x1c,%esp
f0100cfe:	89 c7                	mov    %eax,%edi
f0100d00:	89 d6                	mov    %edx,%esi
f0100d02:	8b 45 08             	mov    0x8(%ebp),%eax
f0100d05:	8b 55 0c             	mov    0xc(%ebp),%edx
f0100d08:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100d0b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0100d0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0100d11:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100d16:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0100d19:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0100d1c:	39 d3                	cmp    %edx,%ebx
f0100d1e:	72 05                	jb     f0100d25 <printnum+0x30>
f0100d20:	39 45 10             	cmp    %eax,0x10(%ebp)
f0100d23:	77 45                	ja     f0100d6a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0100d25:	83 ec 0c             	sub    $0xc,%esp
f0100d28:	ff 75 18             	pushl  0x18(%ebp)
f0100d2b:	8b 45 14             	mov    0x14(%ebp),%eax
f0100d2e:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0100d31:	53                   	push   %ebx
f0100d32:	ff 75 10             	pushl  0x10(%ebp)
f0100d35:	83 ec 08             	sub    $0x8,%esp
f0100d38:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d3b:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d3e:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d41:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d44:	e8 47 09 00 00       	call   f0101690 <__udivdi3>
f0100d49:	83 c4 18             	add    $0x18,%esp
f0100d4c:	52                   	push   %edx
f0100d4d:	50                   	push   %eax
f0100d4e:	89 f2                	mov    %esi,%edx
f0100d50:	89 f8                	mov    %edi,%eax
f0100d52:	e8 9e ff ff ff       	call   f0100cf5 <printnum>
f0100d57:	83 c4 20             	add    $0x20,%esp
f0100d5a:	eb 18                	jmp    f0100d74 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0100d5c:	83 ec 08             	sub    $0x8,%esp
f0100d5f:	56                   	push   %esi
f0100d60:	ff 75 18             	pushl  0x18(%ebp)
f0100d63:	ff d7                	call   *%edi
f0100d65:	83 c4 10             	add    $0x10,%esp
f0100d68:	eb 03                	jmp    f0100d6d <printnum+0x78>
f0100d6a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0100d6d:	83 eb 01             	sub    $0x1,%ebx
f0100d70:	85 db                	test   %ebx,%ebx
f0100d72:	7f e8                	jg     f0100d5c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0100d74:	83 ec 08             	sub    $0x8,%esp
f0100d77:	56                   	push   %esi
f0100d78:	83 ec 04             	sub    $0x4,%esp
f0100d7b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0100d7e:	ff 75 e0             	pushl  -0x20(%ebp)
f0100d81:	ff 75 dc             	pushl  -0x24(%ebp)
f0100d84:	ff 75 d8             	pushl  -0x28(%ebp)
f0100d87:	e8 34 0a 00 00       	call   f01017c0 <__umoddi3>
f0100d8c:	83 c4 14             	add    $0x14,%esp
f0100d8f:	0f be 80 c9 1e 10 f0 	movsbl -0xfefe137(%eax),%eax
f0100d96:	50                   	push   %eax
f0100d97:	ff d7                	call   *%edi
}
f0100d99:	83 c4 10             	add    $0x10,%esp
f0100d9c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100d9f:	5b                   	pop    %ebx
f0100da0:	5e                   	pop    %esi
f0100da1:	5f                   	pop    %edi
f0100da2:	5d                   	pop    %ebp
f0100da3:	c3                   	ret    

f0100da4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0100da4:	55                   	push   %ebp
f0100da5:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0100da7:	83 fa 01             	cmp    $0x1,%edx
f0100daa:	7e 0e                	jle    f0100dba <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0100dac:	8b 10                	mov    (%eax),%edx
f0100dae:	8d 4a 08             	lea    0x8(%edx),%ecx
f0100db1:	89 08                	mov    %ecx,(%eax)
f0100db3:	8b 02                	mov    (%edx),%eax
f0100db5:	8b 52 04             	mov    0x4(%edx),%edx
f0100db8:	eb 22                	jmp    f0100ddc <getuint+0x38>
	else if (lflag)
f0100dba:	85 d2                	test   %edx,%edx
f0100dbc:	74 10                	je     f0100dce <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0100dbe:	8b 10                	mov    (%eax),%edx
f0100dc0:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100dc3:	89 08                	mov    %ecx,(%eax)
f0100dc5:	8b 02                	mov    (%edx),%eax
f0100dc7:	ba 00 00 00 00       	mov    $0x0,%edx
f0100dcc:	eb 0e                	jmp    f0100ddc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0100dce:	8b 10                	mov    (%eax),%edx
f0100dd0:	8d 4a 04             	lea    0x4(%edx),%ecx
f0100dd3:	89 08                	mov    %ecx,(%eax)
f0100dd5:	8b 02                	mov    (%edx),%eax
f0100dd7:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0100ddc:	5d                   	pop    %ebp
f0100ddd:	c3                   	ret    

f0100dde <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0100dde:	55                   	push   %ebp
f0100ddf:	89 e5                	mov    %esp,%ebp
f0100de1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0100de4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0100de8:	8b 10                	mov    (%eax),%edx
f0100dea:	3b 50 04             	cmp    0x4(%eax),%edx
f0100ded:	73 0a                	jae    f0100df9 <sprintputch+0x1b>
		*b->buf++ = ch;
f0100def:	8d 4a 01             	lea    0x1(%edx),%ecx
f0100df2:	89 08                	mov    %ecx,(%eax)
f0100df4:	8b 45 08             	mov    0x8(%ebp),%eax
f0100df7:	88 02                	mov    %al,(%edx)
}
f0100df9:	5d                   	pop    %ebp
f0100dfa:	c3                   	ret    

f0100dfb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0100dfb:	55                   	push   %ebp
f0100dfc:	89 e5                	mov    %esp,%ebp
f0100dfe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100e01:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0100e04:	50                   	push   %eax
f0100e05:	ff 75 10             	pushl  0x10(%ebp)
f0100e08:	ff 75 0c             	pushl  0xc(%ebp)
f0100e0b:	ff 75 08             	pushl  0x8(%ebp)
f0100e0e:	e8 05 00 00 00       	call   f0100e18 <vprintfmt>
	va_end(ap);
}
f0100e13:	83 c4 10             	add    $0x10,%esp
f0100e16:	c9                   	leave  
f0100e17:	c3                   	ret    

f0100e18 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0100e18:	55                   	push   %ebp
f0100e19:	89 e5                	mov    %esp,%ebp
f0100e1b:	57                   	push   %edi
f0100e1c:	56                   	push   %esi
f0100e1d:	53                   	push   %ebx
f0100e1e:	83 ec 2c             	sub    $0x2c,%esp
f0100e21:	8b 75 08             	mov    0x8(%ebp),%esi
f0100e24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100e27:	8b 7d 10             	mov    0x10(%ebp),%edi
f0100e2a:	eb 12                	jmp    f0100e3e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0100e2c:	85 c0                	test   %eax,%eax
f0100e2e:	0f 84 89 03 00 00    	je     f01011bd <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0100e34:	83 ec 08             	sub    $0x8,%esp
f0100e37:	53                   	push   %ebx
f0100e38:	50                   	push   %eax
f0100e39:	ff d6                	call   *%esi
f0100e3b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0100e3e:	83 c7 01             	add    $0x1,%edi
f0100e41:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0100e45:	83 f8 25             	cmp    $0x25,%eax
f0100e48:	75 e2                	jne    f0100e2c <vprintfmt+0x14>
f0100e4a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0100e4e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0100e55:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100e5c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0100e63:	ba 00 00 00 00       	mov    $0x0,%edx
f0100e68:	eb 07                	jmp    f0100e71 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0100e6d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e71:	8d 47 01             	lea    0x1(%edi),%eax
f0100e74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0100e77:	0f b6 07             	movzbl (%edi),%eax
f0100e7a:	0f b6 c8             	movzbl %al,%ecx
f0100e7d:	83 e8 23             	sub    $0x23,%eax
f0100e80:	3c 55                	cmp    $0x55,%al
f0100e82:	0f 87 1a 03 00 00    	ja     f01011a2 <vprintfmt+0x38a>
f0100e88:	0f b6 c0             	movzbl %al,%eax
f0100e8b:	ff 24 85 58 1f 10 f0 	jmp    *-0xfefe0a8(,%eax,4)
f0100e92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0100e95:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0100e99:	eb d6                	jmp    f0100e71 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100e9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100e9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ea3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0100ea6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0100ea9:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0100ead:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0100eb0:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0100eb3:	83 fa 09             	cmp    $0x9,%edx
f0100eb6:	77 39                	ja     f0100ef1 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0100eb8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0100ebb:	eb e9                	jmp    f0100ea6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0100ebd:	8b 45 14             	mov    0x14(%ebp),%eax
f0100ec0:	8d 48 04             	lea    0x4(%eax),%ecx
f0100ec3:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0100ec6:	8b 00                	mov    (%eax),%eax
f0100ec8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ecb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0100ece:	eb 27                	jmp    f0100ef7 <vprintfmt+0xdf>
f0100ed0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100ed3:	85 c0                	test   %eax,%eax
f0100ed5:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100eda:	0f 49 c8             	cmovns %eax,%ecx
f0100edd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100ee0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100ee3:	eb 8c                	jmp    f0100e71 <vprintfmt+0x59>
f0100ee5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0100ee8:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0100eef:	eb 80                	jmp    f0100e71 <vprintfmt+0x59>
f0100ef1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0100ef4:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0100ef7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100efb:	0f 89 70 ff ff ff    	jns    f0100e71 <vprintfmt+0x59>
				width = precision, precision = -1;
f0100f01:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100f04:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100f07:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0100f0e:	e9 5e ff ff ff       	jmp    f0100e71 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0100f13:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f16:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0100f19:	e9 53 ff ff ff       	jmp    f0100e71 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0100f1e:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f21:	8d 50 04             	lea    0x4(%eax),%edx
f0100f24:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f27:	83 ec 08             	sub    $0x8,%esp
f0100f2a:	53                   	push   %ebx
f0100f2b:	ff 30                	pushl  (%eax)
f0100f2d:	ff d6                	call   *%esi
			break;
f0100f2f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0100f35:	e9 04 ff ff ff       	jmp    f0100e3e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0100f3a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f3d:	8d 50 04             	lea    0x4(%eax),%edx
f0100f40:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f43:	8b 00                	mov    (%eax),%eax
f0100f45:	99                   	cltd   
f0100f46:	31 d0                	xor    %edx,%eax
f0100f48:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0100f4a:	83 f8 06             	cmp    $0x6,%eax
f0100f4d:	7f 0b                	jg     f0100f5a <vprintfmt+0x142>
f0100f4f:	8b 14 85 b0 20 10 f0 	mov    -0xfefdf50(,%eax,4),%edx
f0100f56:	85 d2                	test   %edx,%edx
f0100f58:	75 18                	jne    f0100f72 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0100f5a:	50                   	push   %eax
f0100f5b:	68 e1 1e 10 f0       	push   $0xf0101ee1
f0100f60:	53                   	push   %ebx
f0100f61:	56                   	push   %esi
f0100f62:	e8 94 fe ff ff       	call   f0100dfb <printfmt>
f0100f67:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0100f6d:	e9 cc fe ff ff       	jmp    f0100e3e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0100f72:	52                   	push   %edx
f0100f73:	68 ea 1e 10 f0       	push   $0xf0101eea
f0100f78:	53                   	push   %ebx
f0100f79:	56                   	push   %esi
f0100f7a:	e8 7c fe ff ff       	call   f0100dfb <printfmt>
f0100f7f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0100f82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0100f85:	e9 b4 fe ff ff       	jmp    f0100e3e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0100f8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f8d:	8d 50 04             	lea    0x4(%eax),%edx
f0100f90:	89 55 14             	mov    %edx,0x14(%ebp)
f0100f93:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0100f95:	85 ff                	test   %edi,%edi
f0100f97:	b8 da 1e 10 f0       	mov    $0xf0101eda,%eax
f0100f9c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0100f9f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0100fa3:	0f 8e 94 00 00 00    	jle    f010103d <vprintfmt+0x225>
f0100fa9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0100fad:	0f 84 98 00 00 00    	je     f010104b <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fb3:	83 ec 08             	sub    $0x8,%esp
f0100fb6:	ff 75 d0             	pushl  -0x30(%ebp)
f0100fb9:	57                   	push   %edi
f0100fba:	e8 5f 03 00 00       	call   f010131e <strnlen>
f0100fbf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0100fc2:	29 c1                	sub    %eax,%ecx
f0100fc4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0100fc7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0100fca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0100fce:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0100fd1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0100fd4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fd6:	eb 0f                	jmp    f0100fe7 <vprintfmt+0x1cf>
					putch(padc, putdat);
f0100fd8:	83 ec 08             	sub    $0x8,%esp
f0100fdb:	53                   	push   %ebx
f0100fdc:	ff 75 e0             	pushl  -0x20(%ebp)
f0100fdf:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0100fe1:	83 ef 01             	sub    $0x1,%edi
f0100fe4:	83 c4 10             	add    $0x10,%esp
f0100fe7:	85 ff                	test   %edi,%edi
f0100fe9:	7f ed                	jg     f0100fd8 <vprintfmt+0x1c0>
f0100feb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0100fee:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0100ff1:	85 c9                	test   %ecx,%ecx
f0100ff3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff8:	0f 49 c1             	cmovns %ecx,%eax
f0100ffb:	29 c1                	sub    %eax,%ecx
f0100ffd:	89 75 08             	mov    %esi,0x8(%ebp)
f0101000:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101003:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101006:	89 cb                	mov    %ecx,%ebx
f0101008:	eb 4d                	jmp    f0101057 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010100a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f010100e:	74 1b                	je     f010102b <vprintfmt+0x213>
f0101010:	0f be c0             	movsbl %al,%eax
f0101013:	83 e8 20             	sub    $0x20,%eax
f0101016:	83 f8 5e             	cmp    $0x5e,%eax
f0101019:	76 10                	jbe    f010102b <vprintfmt+0x213>
					putch('?', putdat);
f010101b:	83 ec 08             	sub    $0x8,%esp
f010101e:	ff 75 0c             	pushl  0xc(%ebp)
f0101021:	6a 3f                	push   $0x3f
f0101023:	ff 55 08             	call   *0x8(%ebp)
f0101026:	83 c4 10             	add    $0x10,%esp
f0101029:	eb 0d                	jmp    f0101038 <vprintfmt+0x220>
				else
					putch(ch, putdat);
f010102b:	83 ec 08             	sub    $0x8,%esp
f010102e:	ff 75 0c             	pushl  0xc(%ebp)
f0101031:	52                   	push   %edx
f0101032:	ff 55 08             	call   *0x8(%ebp)
f0101035:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101038:	83 eb 01             	sub    $0x1,%ebx
f010103b:	eb 1a                	jmp    f0101057 <vprintfmt+0x23f>
f010103d:	89 75 08             	mov    %esi,0x8(%ebp)
f0101040:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101043:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101046:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101049:	eb 0c                	jmp    f0101057 <vprintfmt+0x23f>
f010104b:	89 75 08             	mov    %esi,0x8(%ebp)
f010104e:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101051:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101054:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101057:	83 c7 01             	add    $0x1,%edi
f010105a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f010105e:	0f be d0             	movsbl %al,%edx
f0101061:	85 d2                	test   %edx,%edx
f0101063:	74 23                	je     f0101088 <vprintfmt+0x270>
f0101065:	85 f6                	test   %esi,%esi
f0101067:	78 a1                	js     f010100a <vprintfmt+0x1f2>
f0101069:	83 ee 01             	sub    $0x1,%esi
f010106c:	79 9c                	jns    f010100a <vprintfmt+0x1f2>
f010106e:	89 df                	mov    %ebx,%edi
f0101070:	8b 75 08             	mov    0x8(%ebp),%esi
f0101073:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101076:	eb 18                	jmp    f0101090 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101078:	83 ec 08             	sub    $0x8,%esp
f010107b:	53                   	push   %ebx
f010107c:	6a 20                	push   $0x20
f010107e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101080:	83 ef 01             	sub    $0x1,%edi
f0101083:	83 c4 10             	add    $0x10,%esp
f0101086:	eb 08                	jmp    f0101090 <vprintfmt+0x278>
f0101088:	89 df                	mov    %ebx,%edi
f010108a:	8b 75 08             	mov    0x8(%ebp),%esi
f010108d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101090:	85 ff                	test   %edi,%edi
f0101092:	7f e4                	jg     f0101078 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101094:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101097:	e9 a2 fd ff ff       	jmp    f0100e3e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010109c:	83 fa 01             	cmp    $0x1,%edx
f010109f:	7e 16                	jle    f01010b7 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f01010a1:	8b 45 14             	mov    0x14(%ebp),%eax
f01010a4:	8d 50 08             	lea    0x8(%eax),%edx
f01010a7:	89 55 14             	mov    %edx,0x14(%ebp)
f01010aa:	8b 50 04             	mov    0x4(%eax),%edx
f01010ad:	8b 00                	mov    (%eax),%eax
f01010af:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
f01010b5:	eb 32                	jmp    f01010e9 <vprintfmt+0x2d1>
	else if (lflag)
f01010b7:	85 d2                	test   %edx,%edx
f01010b9:	74 18                	je     f01010d3 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f01010bb:	8b 45 14             	mov    0x14(%ebp),%eax
f01010be:	8d 50 04             	lea    0x4(%eax),%edx
f01010c1:	89 55 14             	mov    %edx,0x14(%ebp)
f01010c4:	8b 00                	mov    (%eax),%eax
f01010c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010c9:	89 c1                	mov    %eax,%ecx
f01010cb:	c1 f9 1f             	sar    $0x1f,%ecx
f01010ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01010d1:	eb 16                	jmp    f01010e9 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f01010d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01010d6:	8d 50 04             	lea    0x4(%eax),%edx
f01010d9:	89 55 14             	mov    %edx,0x14(%ebp)
f01010dc:	8b 00                	mov    (%eax),%eax
f01010de:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01010e1:	89 c1                	mov    %eax,%ecx
f01010e3:	c1 f9 1f             	sar    $0x1f,%ecx
f01010e6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01010e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01010ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01010ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01010f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f01010f8:	79 74                	jns    f010116e <vprintfmt+0x356>
				putch('-', putdat);
f01010fa:	83 ec 08             	sub    $0x8,%esp
f01010fd:	53                   	push   %ebx
f01010fe:	6a 2d                	push   $0x2d
f0101100:	ff d6                	call   *%esi
				num = -(long long) num;
f0101102:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101105:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101108:	f7 d8                	neg    %eax
f010110a:	83 d2 00             	adc    $0x0,%edx
f010110d:	f7 da                	neg    %edx
f010110f:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0101112:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101117:	eb 55                	jmp    f010116e <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101119:	8d 45 14             	lea    0x14(%ebp),%eax
f010111c:	e8 83 fc ff ff       	call   f0100da4 <getuint>
			base = 10;
f0101121:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101126:	eb 46                	jmp    f010116e <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0101128:	8d 45 14             	lea    0x14(%ebp),%eax
f010112b:	e8 74 fc ff ff       	call   f0100da4 <getuint>
			base = 8;
f0101130:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101135:	eb 37                	jmp    f010116e <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0101137:	83 ec 08             	sub    $0x8,%esp
f010113a:	53                   	push   %ebx
f010113b:	6a 30                	push   $0x30
f010113d:	ff d6                	call   *%esi
			putch('x', putdat);
f010113f:	83 c4 08             	add    $0x8,%esp
f0101142:	53                   	push   %ebx
f0101143:	6a 78                	push   $0x78
f0101145:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101147:	8b 45 14             	mov    0x14(%ebp),%eax
f010114a:	8d 50 04             	lea    0x4(%eax),%edx
f010114d:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101150:	8b 00                	mov    (%eax),%eax
f0101152:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101157:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010115a:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f010115f:	eb 0d                	jmp    f010116e <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101161:	8d 45 14             	lea    0x14(%ebp),%eax
f0101164:	e8 3b fc ff ff       	call   f0100da4 <getuint>
			base = 16;
f0101169:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f010116e:	83 ec 0c             	sub    $0xc,%esp
f0101171:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101175:	57                   	push   %edi
f0101176:	ff 75 e0             	pushl  -0x20(%ebp)
f0101179:	51                   	push   %ecx
f010117a:	52                   	push   %edx
f010117b:	50                   	push   %eax
f010117c:	89 da                	mov    %ebx,%edx
f010117e:	89 f0                	mov    %esi,%eax
f0101180:	e8 70 fb ff ff       	call   f0100cf5 <printnum>
			break;
f0101185:	83 c4 20             	add    $0x20,%esp
f0101188:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010118b:	e9 ae fc ff ff       	jmp    f0100e3e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101190:	83 ec 08             	sub    $0x8,%esp
f0101193:	53                   	push   %ebx
f0101194:	51                   	push   %ecx
f0101195:	ff d6                	call   *%esi
			break;
f0101197:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010119a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f010119d:	e9 9c fc ff ff       	jmp    f0100e3e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01011a2:	83 ec 08             	sub    $0x8,%esp
f01011a5:	53                   	push   %ebx
f01011a6:	6a 25                	push   $0x25
f01011a8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f01011aa:	83 c4 10             	add    $0x10,%esp
f01011ad:	eb 03                	jmp    f01011b2 <vprintfmt+0x39a>
f01011af:	83 ef 01             	sub    $0x1,%edi
f01011b2:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f01011b6:	75 f7                	jne    f01011af <vprintfmt+0x397>
f01011b8:	e9 81 fc ff ff       	jmp    f0100e3e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01011bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011c0:	5b                   	pop    %ebx
f01011c1:	5e                   	pop    %esi
f01011c2:	5f                   	pop    %edi
f01011c3:	5d                   	pop    %ebp
f01011c4:	c3                   	ret    

f01011c5 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01011c5:	55                   	push   %ebp
f01011c6:	89 e5                	mov    %esp,%ebp
f01011c8:	83 ec 18             	sub    $0x18,%esp
f01011cb:	8b 45 08             	mov    0x8(%ebp),%eax
f01011ce:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01011d1:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01011d4:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01011d8:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01011db:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01011e2:	85 c0                	test   %eax,%eax
f01011e4:	74 26                	je     f010120c <vsnprintf+0x47>
f01011e6:	85 d2                	test   %edx,%edx
f01011e8:	7e 22                	jle    f010120c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01011ea:	ff 75 14             	pushl  0x14(%ebp)
f01011ed:	ff 75 10             	pushl  0x10(%ebp)
f01011f0:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01011f3:	50                   	push   %eax
f01011f4:	68 de 0d 10 f0       	push   $0xf0100dde
f01011f9:	e8 1a fc ff ff       	call   f0100e18 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01011fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101201:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101204:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101207:	83 c4 10             	add    $0x10,%esp
f010120a:	eb 05                	jmp    f0101211 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f010120c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101211:	c9                   	leave  
f0101212:	c3                   	ret    

f0101213 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101213:	55                   	push   %ebp
f0101214:	89 e5                	mov    %esp,%ebp
f0101216:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101219:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f010121c:	50                   	push   %eax
f010121d:	ff 75 10             	pushl  0x10(%ebp)
f0101220:	ff 75 0c             	pushl  0xc(%ebp)
f0101223:	ff 75 08             	pushl  0x8(%ebp)
f0101226:	e8 9a ff ff ff       	call   f01011c5 <vsnprintf>
	va_end(ap);

	return rc;
}
f010122b:	c9                   	leave  
f010122c:	c3                   	ret    

f010122d <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f010122d:	55                   	push   %ebp
f010122e:	89 e5                	mov    %esp,%ebp
f0101230:	57                   	push   %edi
f0101231:	56                   	push   %esi
f0101232:	53                   	push   %ebx
f0101233:	83 ec 0c             	sub    $0xc,%esp
f0101236:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101239:	85 c0                	test   %eax,%eax
f010123b:	74 11                	je     f010124e <readline+0x21>
		cprintf("%s", prompt);
f010123d:	83 ec 08             	sub    $0x8,%esp
f0101240:	50                   	push   %eax
f0101241:	68 ea 1e 10 f0       	push   $0xf0101eea
f0101246:	e8 80 f7 ff ff       	call   f01009cb <cprintf>
f010124b:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f010124e:	83 ec 0c             	sub    $0xc,%esp
f0101251:	6a 00                	push   $0x0
f0101253:	e8 60 f4 ff ff       	call   f01006b8 <iscons>
f0101258:	89 c7                	mov    %eax,%edi
f010125a:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f010125d:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101262:	e8 40 f4 ff ff       	call   f01006a7 <getchar>
f0101267:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101269:	85 c0                	test   %eax,%eax
f010126b:	79 18                	jns    f0101285 <readline+0x58>
			cprintf("read error: %e\n", c);
f010126d:	83 ec 08             	sub    $0x8,%esp
f0101270:	50                   	push   %eax
f0101271:	68 cc 20 10 f0       	push   $0xf01020cc
f0101276:	e8 50 f7 ff ff       	call   f01009cb <cprintf>
			return NULL;
f010127b:	83 c4 10             	add    $0x10,%esp
f010127e:	b8 00 00 00 00       	mov    $0x0,%eax
f0101283:	eb 79                	jmp    f01012fe <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101285:	83 f8 08             	cmp    $0x8,%eax
f0101288:	0f 94 c2             	sete   %dl
f010128b:	83 f8 7f             	cmp    $0x7f,%eax
f010128e:	0f 94 c0             	sete   %al
f0101291:	08 c2                	or     %al,%dl
f0101293:	74 1a                	je     f01012af <readline+0x82>
f0101295:	85 f6                	test   %esi,%esi
f0101297:	7e 16                	jle    f01012af <readline+0x82>
			if (echoing)
f0101299:	85 ff                	test   %edi,%edi
f010129b:	74 0d                	je     f01012aa <readline+0x7d>
				cputchar('\b');
f010129d:	83 ec 0c             	sub    $0xc,%esp
f01012a0:	6a 08                	push   $0x8
f01012a2:	e8 f0 f3 ff ff       	call   f0100697 <cputchar>
f01012a7:	83 c4 10             	add    $0x10,%esp
			i--;
f01012aa:	83 ee 01             	sub    $0x1,%esi
f01012ad:	eb b3                	jmp    f0101262 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01012af:	83 fb 1f             	cmp    $0x1f,%ebx
f01012b2:	7e 23                	jle    f01012d7 <readline+0xaa>
f01012b4:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01012ba:	7f 1b                	jg     f01012d7 <readline+0xaa>
			if (echoing)
f01012bc:	85 ff                	test   %edi,%edi
f01012be:	74 0c                	je     f01012cc <readline+0x9f>
				cputchar(c);
f01012c0:	83 ec 0c             	sub    $0xc,%esp
f01012c3:	53                   	push   %ebx
f01012c4:	e8 ce f3 ff ff       	call   f0100697 <cputchar>
f01012c9:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01012cc:	88 9e 40 25 11 f0    	mov    %bl,-0xfeedac0(%esi)
f01012d2:	8d 76 01             	lea    0x1(%esi),%esi
f01012d5:	eb 8b                	jmp    f0101262 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01012d7:	83 fb 0a             	cmp    $0xa,%ebx
f01012da:	74 05                	je     f01012e1 <readline+0xb4>
f01012dc:	83 fb 0d             	cmp    $0xd,%ebx
f01012df:	75 81                	jne    f0101262 <readline+0x35>
			if (echoing)
f01012e1:	85 ff                	test   %edi,%edi
f01012e3:	74 0d                	je     f01012f2 <readline+0xc5>
				cputchar('\n');
f01012e5:	83 ec 0c             	sub    $0xc,%esp
f01012e8:	6a 0a                	push   $0xa
f01012ea:	e8 a8 f3 ff ff       	call   f0100697 <cputchar>
f01012ef:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01012f2:	c6 86 40 25 11 f0 00 	movb   $0x0,-0xfeedac0(%esi)
			return buf;
f01012f9:	b8 40 25 11 f0       	mov    $0xf0112540,%eax
		}
	}
}
f01012fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101301:	5b                   	pop    %ebx
f0101302:	5e                   	pop    %esi
f0101303:	5f                   	pop    %edi
f0101304:	5d                   	pop    %ebp
f0101305:	c3                   	ret    

f0101306 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101306:	55                   	push   %ebp
f0101307:	89 e5                	mov    %esp,%ebp
f0101309:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f010130c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101311:	eb 03                	jmp    f0101316 <strlen+0x10>
		n++;
f0101313:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101316:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f010131a:	75 f7                	jne    f0101313 <strlen+0xd>
		n++;
	return n;
}
f010131c:	5d                   	pop    %ebp
f010131d:	c3                   	ret    

f010131e <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010131e:	55                   	push   %ebp
f010131f:	89 e5                	mov    %esp,%ebp
f0101321:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101324:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101327:	ba 00 00 00 00       	mov    $0x0,%edx
f010132c:	eb 03                	jmp    f0101331 <strnlen+0x13>
		n++;
f010132e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101331:	39 c2                	cmp    %eax,%edx
f0101333:	74 08                	je     f010133d <strnlen+0x1f>
f0101335:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101339:	75 f3                	jne    f010132e <strnlen+0x10>
f010133b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010133d:	5d                   	pop    %ebp
f010133e:	c3                   	ret    

f010133f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010133f:	55                   	push   %ebp
f0101340:	89 e5                	mov    %esp,%ebp
f0101342:	53                   	push   %ebx
f0101343:	8b 45 08             	mov    0x8(%ebp),%eax
f0101346:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101349:	89 c2                	mov    %eax,%edx
f010134b:	83 c2 01             	add    $0x1,%edx
f010134e:	83 c1 01             	add    $0x1,%ecx
f0101351:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101355:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101358:	84 db                	test   %bl,%bl
f010135a:	75 ef                	jne    f010134b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010135c:	5b                   	pop    %ebx
f010135d:	5d                   	pop    %ebp
f010135e:	c3                   	ret    

f010135f <strcat>:

char *
strcat(char *dst, const char *src)
{
f010135f:	55                   	push   %ebp
f0101360:	89 e5                	mov    %esp,%ebp
f0101362:	53                   	push   %ebx
f0101363:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101366:	53                   	push   %ebx
f0101367:	e8 9a ff ff ff       	call   f0101306 <strlen>
f010136c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010136f:	ff 75 0c             	pushl  0xc(%ebp)
f0101372:	01 d8                	add    %ebx,%eax
f0101374:	50                   	push   %eax
f0101375:	e8 c5 ff ff ff       	call   f010133f <strcpy>
	return dst;
}
f010137a:	89 d8                	mov    %ebx,%eax
f010137c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010137f:	c9                   	leave  
f0101380:	c3                   	ret    

f0101381 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101381:	55                   	push   %ebp
f0101382:	89 e5                	mov    %esp,%ebp
f0101384:	56                   	push   %esi
f0101385:	53                   	push   %ebx
f0101386:	8b 75 08             	mov    0x8(%ebp),%esi
f0101389:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010138c:	89 f3                	mov    %esi,%ebx
f010138e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101391:	89 f2                	mov    %esi,%edx
f0101393:	eb 0f                	jmp    f01013a4 <strncpy+0x23>
		*dst++ = *src;
f0101395:	83 c2 01             	add    $0x1,%edx
f0101398:	0f b6 01             	movzbl (%ecx),%eax
f010139b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010139e:	80 39 01             	cmpb   $0x1,(%ecx)
f01013a1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01013a4:	39 da                	cmp    %ebx,%edx
f01013a6:	75 ed                	jne    f0101395 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01013a8:	89 f0                	mov    %esi,%eax
f01013aa:	5b                   	pop    %ebx
f01013ab:	5e                   	pop    %esi
f01013ac:	5d                   	pop    %ebp
f01013ad:	c3                   	ret    

f01013ae <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01013ae:	55                   	push   %ebp
f01013af:	89 e5                	mov    %esp,%ebp
f01013b1:	56                   	push   %esi
f01013b2:	53                   	push   %ebx
f01013b3:	8b 75 08             	mov    0x8(%ebp),%esi
f01013b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01013b9:	8b 55 10             	mov    0x10(%ebp),%edx
f01013bc:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01013be:	85 d2                	test   %edx,%edx
f01013c0:	74 21                	je     f01013e3 <strlcpy+0x35>
f01013c2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01013c6:	89 f2                	mov    %esi,%edx
f01013c8:	eb 09                	jmp    f01013d3 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01013ca:	83 c2 01             	add    $0x1,%edx
f01013cd:	83 c1 01             	add    $0x1,%ecx
f01013d0:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01013d3:	39 c2                	cmp    %eax,%edx
f01013d5:	74 09                	je     f01013e0 <strlcpy+0x32>
f01013d7:	0f b6 19             	movzbl (%ecx),%ebx
f01013da:	84 db                	test   %bl,%bl
f01013dc:	75 ec                	jne    f01013ca <strlcpy+0x1c>
f01013de:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01013e0:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01013e3:	29 f0                	sub    %esi,%eax
}
f01013e5:	5b                   	pop    %ebx
f01013e6:	5e                   	pop    %esi
f01013e7:	5d                   	pop    %ebp
f01013e8:	c3                   	ret    

f01013e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01013e9:	55                   	push   %ebp
f01013ea:	89 e5                	mov    %esp,%ebp
f01013ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01013ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01013f2:	eb 06                	jmp    f01013fa <strcmp+0x11>
		p++, q++;
f01013f4:	83 c1 01             	add    $0x1,%ecx
f01013f7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01013fa:	0f b6 01             	movzbl (%ecx),%eax
f01013fd:	84 c0                	test   %al,%al
f01013ff:	74 04                	je     f0101405 <strcmp+0x1c>
f0101401:	3a 02                	cmp    (%edx),%al
f0101403:	74 ef                	je     f01013f4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0101405:	0f b6 c0             	movzbl %al,%eax
f0101408:	0f b6 12             	movzbl (%edx),%edx
f010140b:	29 d0                	sub    %edx,%eax
}
f010140d:	5d                   	pop    %ebp
f010140e:	c3                   	ret    

f010140f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010140f:	55                   	push   %ebp
f0101410:	89 e5                	mov    %esp,%ebp
f0101412:	53                   	push   %ebx
f0101413:	8b 45 08             	mov    0x8(%ebp),%eax
f0101416:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101419:	89 c3                	mov    %eax,%ebx
f010141b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010141e:	eb 06                	jmp    f0101426 <strncmp+0x17>
		n--, p++, q++;
f0101420:	83 c0 01             	add    $0x1,%eax
f0101423:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0101426:	39 d8                	cmp    %ebx,%eax
f0101428:	74 15                	je     f010143f <strncmp+0x30>
f010142a:	0f b6 08             	movzbl (%eax),%ecx
f010142d:	84 c9                	test   %cl,%cl
f010142f:	74 04                	je     f0101435 <strncmp+0x26>
f0101431:	3a 0a                	cmp    (%edx),%cl
f0101433:	74 eb                	je     f0101420 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0101435:	0f b6 00             	movzbl (%eax),%eax
f0101438:	0f b6 12             	movzbl (%edx),%edx
f010143b:	29 d0                	sub    %edx,%eax
f010143d:	eb 05                	jmp    f0101444 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010143f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0101444:	5b                   	pop    %ebx
f0101445:	5d                   	pop    %ebp
f0101446:	c3                   	ret    

f0101447 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0101447:	55                   	push   %ebp
f0101448:	89 e5                	mov    %esp,%ebp
f010144a:	8b 45 08             	mov    0x8(%ebp),%eax
f010144d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101451:	eb 07                	jmp    f010145a <strchr+0x13>
		if (*s == c)
f0101453:	38 ca                	cmp    %cl,%dl
f0101455:	74 0f                	je     f0101466 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0101457:	83 c0 01             	add    $0x1,%eax
f010145a:	0f b6 10             	movzbl (%eax),%edx
f010145d:	84 d2                	test   %dl,%dl
f010145f:	75 f2                	jne    f0101453 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0101461:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101466:	5d                   	pop    %ebp
f0101467:	c3                   	ret    

f0101468 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0101468:	55                   	push   %ebp
f0101469:	89 e5                	mov    %esp,%ebp
f010146b:	8b 45 08             	mov    0x8(%ebp),%eax
f010146e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0101472:	eb 03                	jmp    f0101477 <strfind+0xf>
f0101474:	83 c0 01             	add    $0x1,%eax
f0101477:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010147a:	38 ca                	cmp    %cl,%dl
f010147c:	74 04                	je     f0101482 <strfind+0x1a>
f010147e:	84 d2                	test   %dl,%dl
f0101480:	75 f2                	jne    f0101474 <strfind+0xc>
			break;
	return (char *) s;
}
f0101482:	5d                   	pop    %ebp
f0101483:	c3                   	ret    

f0101484 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0101484:	55                   	push   %ebp
f0101485:	89 e5                	mov    %esp,%ebp
f0101487:	57                   	push   %edi
f0101488:	56                   	push   %esi
f0101489:	53                   	push   %ebx
f010148a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010148d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0101490:	85 c9                	test   %ecx,%ecx
f0101492:	74 36                	je     f01014ca <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0101494:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010149a:	75 28                	jne    f01014c4 <memset+0x40>
f010149c:	f6 c1 03             	test   $0x3,%cl
f010149f:	75 23                	jne    f01014c4 <memset+0x40>
		c &= 0xFF;
f01014a1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01014a5:	89 d3                	mov    %edx,%ebx
f01014a7:	c1 e3 08             	shl    $0x8,%ebx
f01014aa:	89 d6                	mov    %edx,%esi
f01014ac:	c1 e6 18             	shl    $0x18,%esi
f01014af:	89 d0                	mov    %edx,%eax
f01014b1:	c1 e0 10             	shl    $0x10,%eax
f01014b4:	09 f0                	or     %esi,%eax
f01014b6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01014b8:	89 d8                	mov    %ebx,%eax
f01014ba:	09 d0                	or     %edx,%eax
f01014bc:	c1 e9 02             	shr    $0x2,%ecx
f01014bf:	fc                   	cld    
f01014c0:	f3 ab                	rep stos %eax,%es:(%edi)
f01014c2:	eb 06                	jmp    f01014ca <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01014c4:	8b 45 0c             	mov    0xc(%ebp),%eax
f01014c7:	fc                   	cld    
f01014c8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01014ca:	89 f8                	mov    %edi,%eax
f01014cc:	5b                   	pop    %ebx
f01014cd:	5e                   	pop    %esi
f01014ce:	5f                   	pop    %edi
f01014cf:	5d                   	pop    %ebp
f01014d0:	c3                   	ret    

f01014d1 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01014d1:	55                   	push   %ebp
f01014d2:	89 e5                	mov    %esp,%ebp
f01014d4:	57                   	push   %edi
f01014d5:	56                   	push   %esi
f01014d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01014d9:	8b 75 0c             	mov    0xc(%ebp),%esi
f01014dc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01014df:	39 c6                	cmp    %eax,%esi
f01014e1:	73 35                	jae    f0101518 <memmove+0x47>
f01014e3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01014e6:	39 d0                	cmp    %edx,%eax
f01014e8:	73 2e                	jae    f0101518 <memmove+0x47>
		s += n;
		d += n;
f01014ea:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01014ed:	89 d6                	mov    %edx,%esi
f01014ef:	09 fe                	or     %edi,%esi
f01014f1:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01014f7:	75 13                	jne    f010150c <memmove+0x3b>
f01014f9:	f6 c1 03             	test   $0x3,%cl
f01014fc:	75 0e                	jne    f010150c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01014fe:	83 ef 04             	sub    $0x4,%edi
f0101501:	8d 72 fc             	lea    -0x4(%edx),%esi
f0101504:	c1 e9 02             	shr    $0x2,%ecx
f0101507:	fd                   	std    
f0101508:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010150a:	eb 09                	jmp    f0101515 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010150c:	83 ef 01             	sub    $0x1,%edi
f010150f:	8d 72 ff             	lea    -0x1(%edx),%esi
f0101512:	fd                   	std    
f0101513:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0101515:	fc                   	cld    
f0101516:	eb 1d                	jmp    f0101535 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0101518:	89 f2                	mov    %esi,%edx
f010151a:	09 c2                	or     %eax,%edx
f010151c:	f6 c2 03             	test   $0x3,%dl
f010151f:	75 0f                	jne    f0101530 <memmove+0x5f>
f0101521:	f6 c1 03             	test   $0x3,%cl
f0101524:	75 0a                	jne    f0101530 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0101526:	c1 e9 02             	shr    $0x2,%ecx
f0101529:	89 c7                	mov    %eax,%edi
f010152b:	fc                   	cld    
f010152c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010152e:	eb 05                	jmp    f0101535 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0101530:	89 c7                	mov    %eax,%edi
f0101532:	fc                   	cld    
f0101533:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0101535:	5e                   	pop    %esi
f0101536:	5f                   	pop    %edi
f0101537:	5d                   	pop    %ebp
f0101538:	c3                   	ret    

f0101539 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0101539:	55                   	push   %ebp
f010153a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010153c:	ff 75 10             	pushl  0x10(%ebp)
f010153f:	ff 75 0c             	pushl  0xc(%ebp)
f0101542:	ff 75 08             	pushl  0x8(%ebp)
f0101545:	e8 87 ff ff ff       	call   f01014d1 <memmove>
}
f010154a:	c9                   	leave  
f010154b:	c3                   	ret    

f010154c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010154c:	55                   	push   %ebp
f010154d:	89 e5                	mov    %esp,%ebp
f010154f:	56                   	push   %esi
f0101550:	53                   	push   %ebx
f0101551:	8b 45 08             	mov    0x8(%ebp),%eax
f0101554:	8b 55 0c             	mov    0xc(%ebp),%edx
f0101557:	89 c6                	mov    %eax,%esi
f0101559:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010155c:	eb 1a                	jmp    f0101578 <memcmp+0x2c>
		if (*s1 != *s2)
f010155e:	0f b6 08             	movzbl (%eax),%ecx
f0101561:	0f b6 1a             	movzbl (%edx),%ebx
f0101564:	38 d9                	cmp    %bl,%cl
f0101566:	74 0a                	je     f0101572 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0101568:	0f b6 c1             	movzbl %cl,%eax
f010156b:	0f b6 db             	movzbl %bl,%ebx
f010156e:	29 d8                	sub    %ebx,%eax
f0101570:	eb 0f                	jmp    f0101581 <memcmp+0x35>
		s1++, s2++;
f0101572:	83 c0 01             	add    $0x1,%eax
f0101575:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0101578:	39 f0                	cmp    %esi,%eax
f010157a:	75 e2                	jne    f010155e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010157c:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0101581:	5b                   	pop    %ebx
f0101582:	5e                   	pop    %esi
f0101583:	5d                   	pop    %ebp
f0101584:	c3                   	ret    

f0101585 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0101585:	55                   	push   %ebp
f0101586:	89 e5                	mov    %esp,%ebp
f0101588:	53                   	push   %ebx
f0101589:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010158c:	89 c1                	mov    %eax,%ecx
f010158e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0101591:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0101595:	eb 0a                	jmp    f01015a1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0101597:	0f b6 10             	movzbl (%eax),%edx
f010159a:	39 da                	cmp    %ebx,%edx
f010159c:	74 07                	je     f01015a5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010159e:	83 c0 01             	add    $0x1,%eax
f01015a1:	39 c8                	cmp    %ecx,%eax
f01015a3:	72 f2                	jb     f0101597 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01015a5:	5b                   	pop    %ebx
f01015a6:	5d                   	pop    %ebp
f01015a7:	c3                   	ret    

f01015a8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01015a8:	55                   	push   %ebp
f01015a9:	89 e5                	mov    %esp,%ebp
f01015ab:	57                   	push   %edi
f01015ac:	56                   	push   %esi
f01015ad:	53                   	push   %ebx
f01015ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01015b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015b4:	eb 03                	jmp    f01015b9 <strtol+0x11>
		s++;
f01015b6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01015b9:	0f b6 01             	movzbl (%ecx),%eax
f01015bc:	3c 20                	cmp    $0x20,%al
f01015be:	74 f6                	je     f01015b6 <strtol+0xe>
f01015c0:	3c 09                	cmp    $0x9,%al
f01015c2:	74 f2                	je     f01015b6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01015c4:	3c 2b                	cmp    $0x2b,%al
f01015c6:	75 0a                	jne    f01015d2 <strtol+0x2a>
		s++;
f01015c8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01015cb:	bf 00 00 00 00       	mov    $0x0,%edi
f01015d0:	eb 11                	jmp    f01015e3 <strtol+0x3b>
f01015d2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01015d7:	3c 2d                	cmp    $0x2d,%al
f01015d9:	75 08                	jne    f01015e3 <strtol+0x3b>
		s++, neg = 1;
f01015db:	83 c1 01             	add    $0x1,%ecx
f01015de:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01015e3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01015e9:	75 15                	jne    f0101600 <strtol+0x58>
f01015eb:	80 39 30             	cmpb   $0x30,(%ecx)
f01015ee:	75 10                	jne    f0101600 <strtol+0x58>
f01015f0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01015f4:	75 7c                	jne    f0101672 <strtol+0xca>
		s += 2, base = 16;
f01015f6:	83 c1 02             	add    $0x2,%ecx
f01015f9:	bb 10 00 00 00       	mov    $0x10,%ebx
f01015fe:	eb 16                	jmp    f0101616 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0101600:	85 db                	test   %ebx,%ebx
f0101602:	75 12                	jne    f0101616 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0101604:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101609:	80 39 30             	cmpb   $0x30,(%ecx)
f010160c:	75 08                	jne    f0101616 <strtol+0x6e>
		s++, base = 8;
f010160e:	83 c1 01             	add    $0x1,%ecx
f0101611:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0101616:	b8 00 00 00 00       	mov    $0x0,%eax
f010161b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010161e:	0f b6 11             	movzbl (%ecx),%edx
f0101621:	8d 72 d0             	lea    -0x30(%edx),%esi
f0101624:	89 f3                	mov    %esi,%ebx
f0101626:	80 fb 09             	cmp    $0x9,%bl
f0101629:	77 08                	ja     f0101633 <strtol+0x8b>
			dig = *s - '0';
f010162b:	0f be d2             	movsbl %dl,%edx
f010162e:	83 ea 30             	sub    $0x30,%edx
f0101631:	eb 22                	jmp    f0101655 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0101633:	8d 72 9f             	lea    -0x61(%edx),%esi
f0101636:	89 f3                	mov    %esi,%ebx
f0101638:	80 fb 19             	cmp    $0x19,%bl
f010163b:	77 08                	ja     f0101645 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010163d:	0f be d2             	movsbl %dl,%edx
f0101640:	83 ea 57             	sub    $0x57,%edx
f0101643:	eb 10                	jmp    f0101655 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0101645:	8d 72 bf             	lea    -0x41(%edx),%esi
f0101648:	89 f3                	mov    %esi,%ebx
f010164a:	80 fb 19             	cmp    $0x19,%bl
f010164d:	77 16                	ja     f0101665 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010164f:	0f be d2             	movsbl %dl,%edx
f0101652:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0101655:	3b 55 10             	cmp    0x10(%ebp),%edx
f0101658:	7d 0b                	jge    f0101665 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010165a:	83 c1 01             	add    $0x1,%ecx
f010165d:	0f af 45 10          	imul   0x10(%ebp),%eax
f0101661:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0101663:	eb b9                	jmp    f010161e <strtol+0x76>

	if (endptr)
f0101665:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0101669:	74 0d                	je     f0101678 <strtol+0xd0>
		*endptr = (char *) s;
f010166b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010166e:	89 0e                	mov    %ecx,(%esi)
f0101670:	eb 06                	jmp    f0101678 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0101672:	85 db                	test   %ebx,%ebx
f0101674:	74 98                	je     f010160e <strtol+0x66>
f0101676:	eb 9e                	jmp    f0101616 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0101678:	89 c2                	mov    %eax,%edx
f010167a:	f7 da                	neg    %edx
f010167c:	85 ff                	test   %edi,%edi
f010167e:	0f 45 c2             	cmovne %edx,%eax
}
f0101681:	5b                   	pop    %ebx
f0101682:	5e                   	pop    %esi
f0101683:	5f                   	pop    %edi
f0101684:	5d                   	pop    %ebp
f0101685:	c3                   	ret    
f0101686:	66 90                	xchg   %ax,%ax
f0101688:	66 90                	xchg   %ax,%ax
f010168a:	66 90                	xchg   %ax,%ax
f010168c:	66 90                	xchg   %ax,%ax
f010168e:	66 90                	xchg   %ax,%ax

f0101690 <__udivdi3>:
f0101690:	55                   	push   %ebp
f0101691:	57                   	push   %edi
f0101692:	56                   	push   %esi
f0101693:	53                   	push   %ebx
f0101694:	83 ec 1c             	sub    $0x1c,%esp
f0101697:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010169b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010169f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01016a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01016a7:	85 f6                	test   %esi,%esi
f01016a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01016ad:	89 ca                	mov    %ecx,%edx
f01016af:	89 f8                	mov    %edi,%eax
f01016b1:	75 3d                	jne    f01016f0 <__udivdi3+0x60>
f01016b3:	39 cf                	cmp    %ecx,%edi
f01016b5:	0f 87 c5 00 00 00    	ja     f0101780 <__udivdi3+0xf0>
f01016bb:	85 ff                	test   %edi,%edi
f01016bd:	89 fd                	mov    %edi,%ebp
f01016bf:	75 0b                	jne    f01016cc <__udivdi3+0x3c>
f01016c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01016c6:	31 d2                	xor    %edx,%edx
f01016c8:	f7 f7                	div    %edi
f01016ca:	89 c5                	mov    %eax,%ebp
f01016cc:	89 c8                	mov    %ecx,%eax
f01016ce:	31 d2                	xor    %edx,%edx
f01016d0:	f7 f5                	div    %ebp
f01016d2:	89 c1                	mov    %eax,%ecx
f01016d4:	89 d8                	mov    %ebx,%eax
f01016d6:	89 cf                	mov    %ecx,%edi
f01016d8:	f7 f5                	div    %ebp
f01016da:	89 c3                	mov    %eax,%ebx
f01016dc:	89 d8                	mov    %ebx,%eax
f01016de:	89 fa                	mov    %edi,%edx
f01016e0:	83 c4 1c             	add    $0x1c,%esp
f01016e3:	5b                   	pop    %ebx
f01016e4:	5e                   	pop    %esi
f01016e5:	5f                   	pop    %edi
f01016e6:	5d                   	pop    %ebp
f01016e7:	c3                   	ret    
f01016e8:	90                   	nop
f01016e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01016f0:	39 ce                	cmp    %ecx,%esi
f01016f2:	77 74                	ja     f0101768 <__udivdi3+0xd8>
f01016f4:	0f bd fe             	bsr    %esi,%edi
f01016f7:	83 f7 1f             	xor    $0x1f,%edi
f01016fa:	0f 84 98 00 00 00    	je     f0101798 <__udivdi3+0x108>
f0101700:	bb 20 00 00 00       	mov    $0x20,%ebx
f0101705:	89 f9                	mov    %edi,%ecx
f0101707:	89 c5                	mov    %eax,%ebp
f0101709:	29 fb                	sub    %edi,%ebx
f010170b:	d3 e6                	shl    %cl,%esi
f010170d:	89 d9                	mov    %ebx,%ecx
f010170f:	d3 ed                	shr    %cl,%ebp
f0101711:	89 f9                	mov    %edi,%ecx
f0101713:	d3 e0                	shl    %cl,%eax
f0101715:	09 ee                	or     %ebp,%esi
f0101717:	89 d9                	mov    %ebx,%ecx
f0101719:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010171d:	89 d5                	mov    %edx,%ebp
f010171f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0101723:	d3 ed                	shr    %cl,%ebp
f0101725:	89 f9                	mov    %edi,%ecx
f0101727:	d3 e2                	shl    %cl,%edx
f0101729:	89 d9                	mov    %ebx,%ecx
f010172b:	d3 e8                	shr    %cl,%eax
f010172d:	09 c2                	or     %eax,%edx
f010172f:	89 d0                	mov    %edx,%eax
f0101731:	89 ea                	mov    %ebp,%edx
f0101733:	f7 f6                	div    %esi
f0101735:	89 d5                	mov    %edx,%ebp
f0101737:	89 c3                	mov    %eax,%ebx
f0101739:	f7 64 24 0c          	mull   0xc(%esp)
f010173d:	39 d5                	cmp    %edx,%ebp
f010173f:	72 10                	jb     f0101751 <__udivdi3+0xc1>
f0101741:	8b 74 24 08          	mov    0x8(%esp),%esi
f0101745:	89 f9                	mov    %edi,%ecx
f0101747:	d3 e6                	shl    %cl,%esi
f0101749:	39 c6                	cmp    %eax,%esi
f010174b:	73 07                	jae    f0101754 <__udivdi3+0xc4>
f010174d:	39 d5                	cmp    %edx,%ebp
f010174f:	75 03                	jne    f0101754 <__udivdi3+0xc4>
f0101751:	83 eb 01             	sub    $0x1,%ebx
f0101754:	31 ff                	xor    %edi,%edi
f0101756:	89 d8                	mov    %ebx,%eax
f0101758:	89 fa                	mov    %edi,%edx
f010175a:	83 c4 1c             	add    $0x1c,%esp
f010175d:	5b                   	pop    %ebx
f010175e:	5e                   	pop    %esi
f010175f:	5f                   	pop    %edi
f0101760:	5d                   	pop    %ebp
f0101761:	c3                   	ret    
f0101762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101768:	31 ff                	xor    %edi,%edi
f010176a:	31 db                	xor    %ebx,%ebx
f010176c:	89 d8                	mov    %ebx,%eax
f010176e:	89 fa                	mov    %edi,%edx
f0101770:	83 c4 1c             	add    $0x1c,%esp
f0101773:	5b                   	pop    %ebx
f0101774:	5e                   	pop    %esi
f0101775:	5f                   	pop    %edi
f0101776:	5d                   	pop    %ebp
f0101777:	c3                   	ret    
f0101778:	90                   	nop
f0101779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101780:	89 d8                	mov    %ebx,%eax
f0101782:	f7 f7                	div    %edi
f0101784:	31 ff                	xor    %edi,%edi
f0101786:	89 c3                	mov    %eax,%ebx
f0101788:	89 d8                	mov    %ebx,%eax
f010178a:	89 fa                	mov    %edi,%edx
f010178c:	83 c4 1c             	add    $0x1c,%esp
f010178f:	5b                   	pop    %ebx
f0101790:	5e                   	pop    %esi
f0101791:	5f                   	pop    %edi
f0101792:	5d                   	pop    %ebp
f0101793:	c3                   	ret    
f0101794:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101798:	39 ce                	cmp    %ecx,%esi
f010179a:	72 0c                	jb     f01017a8 <__udivdi3+0x118>
f010179c:	31 db                	xor    %ebx,%ebx
f010179e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01017a2:	0f 87 34 ff ff ff    	ja     f01016dc <__udivdi3+0x4c>
f01017a8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01017ad:	e9 2a ff ff ff       	jmp    f01016dc <__udivdi3+0x4c>
f01017b2:	66 90                	xchg   %ax,%ax
f01017b4:	66 90                	xchg   %ax,%ax
f01017b6:	66 90                	xchg   %ax,%ax
f01017b8:	66 90                	xchg   %ax,%ax
f01017ba:	66 90                	xchg   %ax,%ax
f01017bc:	66 90                	xchg   %ax,%ax
f01017be:	66 90                	xchg   %ax,%ax

f01017c0 <__umoddi3>:
f01017c0:	55                   	push   %ebp
f01017c1:	57                   	push   %edi
f01017c2:	56                   	push   %esi
f01017c3:	53                   	push   %ebx
f01017c4:	83 ec 1c             	sub    $0x1c,%esp
f01017c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01017cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01017cf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01017d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01017d7:	85 d2                	test   %edx,%edx
f01017d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01017dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01017e1:	89 f3                	mov    %esi,%ebx
f01017e3:	89 3c 24             	mov    %edi,(%esp)
f01017e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017ea:	75 1c                	jne    f0101808 <__umoddi3+0x48>
f01017ec:	39 f7                	cmp    %esi,%edi
f01017ee:	76 50                	jbe    f0101840 <__umoddi3+0x80>
f01017f0:	89 c8                	mov    %ecx,%eax
f01017f2:	89 f2                	mov    %esi,%edx
f01017f4:	f7 f7                	div    %edi
f01017f6:	89 d0                	mov    %edx,%eax
f01017f8:	31 d2                	xor    %edx,%edx
f01017fa:	83 c4 1c             	add    $0x1c,%esp
f01017fd:	5b                   	pop    %ebx
f01017fe:	5e                   	pop    %esi
f01017ff:	5f                   	pop    %edi
f0101800:	5d                   	pop    %ebp
f0101801:	c3                   	ret    
f0101802:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0101808:	39 f2                	cmp    %esi,%edx
f010180a:	89 d0                	mov    %edx,%eax
f010180c:	77 52                	ja     f0101860 <__umoddi3+0xa0>
f010180e:	0f bd ea             	bsr    %edx,%ebp
f0101811:	83 f5 1f             	xor    $0x1f,%ebp
f0101814:	75 5a                	jne    f0101870 <__umoddi3+0xb0>
f0101816:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010181a:	0f 82 e0 00 00 00    	jb     f0101900 <__umoddi3+0x140>
f0101820:	39 0c 24             	cmp    %ecx,(%esp)
f0101823:	0f 86 d7 00 00 00    	jbe    f0101900 <__umoddi3+0x140>
f0101829:	8b 44 24 08          	mov    0x8(%esp),%eax
f010182d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0101831:	83 c4 1c             	add    $0x1c,%esp
f0101834:	5b                   	pop    %ebx
f0101835:	5e                   	pop    %esi
f0101836:	5f                   	pop    %edi
f0101837:	5d                   	pop    %ebp
f0101838:	c3                   	ret    
f0101839:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0101840:	85 ff                	test   %edi,%edi
f0101842:	89 fd                	mov    %edi,%ebp
f0101844:	75 0b                	jne    f0101851 <__umoddi3+0x91>
f0101846:	b8 01 00 00 00       	mov    $0x1,%eax
f010184b:	31 d2                	xor    %edx,%edx
f010184d:	f7 f7                	div    %edi
f010184f:	89 c5                	mov    %eax,%ebp
f0101851:	89 f0                	mov    %esi,%eax
f0101853:	31 d2                	xor    %edx,%edx
f0101855:	f7 f5                	div    %ebp
f0101857:	89 c8                	mov    %ecx,%eax
f0101859:	f7 f5                	div    %ebp
f010185b:	89 d0                	mov    %edx,%eax
f010185d:	eb 99                	jmp    f01017f8 <__umoddi3+0x38>
f010185f:	90                   	nop
f0101860:	89 c8                	mov    %ecx,%eax
f0101862:	89 f2                	mov    %esi,%edx
f0101864:	83 c4 1c             	add    $0x1c,%esp
f0101867:	5b                   	pop    %ebx
f0101868:	5e                   	pop    %esi
f0101869:	5f                   	pop    %edi
f010186a:	5d                   	pop    %ebp
f010186b:	c3                   	ret    
f010186c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0101870:	8b 34 24             	mov    (%esp),%esi
f0101873:	bf 20 00 00 00       	mov    $0x20,%edi
f0101878:	89 e9                	mov    %ebp,%ecx
f010187a:	29 ef                	sub    %ebp,%edi
f010187c:	d3 e0                	shl    %cl,%eax
f010187e:	89 f9                	mov    %edi,%ecx
f0101880:	89 f2                	mov    %esi,%edx
f0101882:	d3 ea                	shr    %cl,%edx
f0101884:	89 e9                	mov    %ebp,%ecx
f0101886:	09 c2                	or     %eax,%edx
f0101888:	89 d8                	mov    %ebx,%eax
f010188a:	89 14 24             	mov    %edx,(%esp)
f010188d:	89 f2                	mov    %esi,%edx
f010188f:	d3 e2                	shl    %cl,%edx
f0101891:	89 f9                	mov    %edi,%ecx
f0101893:	89 54 24 04          	mov    %edx,0x4(%esp)
f0101897:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010189b:	d3 e8                	shr    %cl,%eax
f010189d:	89 e9                	mov    %ebp,%ecx
f010189f:	89 c6                	mov    %eax,%esi
f01018a1:	d3 e3                	shl    %cl,%ebx
f01018a3:	89 f9                	mov    %edi,%ecx
f01018a5:	89 d0                	mov    %edx,%eax
f01018a7:	d3 e8                	shr    %cl,%eax
f01018a9:	89 e9                	mov    %ebp,%ecx
f01018ab:	09 d8                	or     %ebx,%eax
f01018ad:	89 d3                	mov    %edx,%ebx
f01018af:	89 f2                	mov    %esi,%edx
f01018b1:	f7 34 24             	divl   (%esp)
f01018b4:	89 d6                	mov    %edx,%esi
f01018b6:	d3 e3                	shl    %cl,%ebx
f01018b8:	f7 64 24 04          	mull   0x4(%esp)
f01018bc:	39 d6                	cmp    %edx,%esi
f01018be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01018c2:	89 d1                	mov    %edx,%ecx
f01018c4:	89 c3                	mov    %eax,%ebx
f01018c6:	72 08                	jb     f01018d0 <__umoddi3+0x110>
f01018c8:	75 11                	jne    f01018db <__umoddi3+0x11b>
f01018ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01018ce:	73 0b                	jae    f01018db <__umoddi3+0x11b>
f01018d0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01018d4:	1b 14 24             	sbb    (%esp),%edx
f01018d7:	89 d1                	mov    %edx,%ecx
f01018d9:	89 c3                	mov    %eax,%ebx
f01018db:	8b 54 24 08          	mov    0x8(%esp),%edx
f01018df:	29 da                	sub    %ebx,%edx
f01018e1:	19 ce                	sbb    %ecx,%esi
f01018e3:	89 f9                	mov    %edi,%ecx
f01018e5:	89 f0                	mov    %esi,%eax
f01018e7:	d3 e0                	shl    %cl,%eax
f01018e9:	89 e9                	mov    %ebp,%ecx
f01018eb:	d3 ea                	shr    %cl,%edx
f01018ed:	89 e9                	mov    %ebp,%ecx
f01018ef:	d3 ee                	shr    %cl,%esi
f01018f1:	09 d0                	or     %edx,%eax
f01018f3:	89 f2                	mov    %esi,%edx
f01018f5:	83 c4 1c             	add    $0x1c,%esp
f01018f8:	5b                   	pop    %ebx
f01018f9:	5e                   	pop    %esi
f01018fa:	5f                   	pop    %edi
f01018fb:	5d                   	pop    %ebp
f01018fc:	c3                   	ret    
f01018fd:	8d 76 00             	lea    0x0(%esi),%esi
f0101900:	29 f9                	sub    %edi,%ecx
f0101902:	19 d6                	sbb    %edx,%esi
f0101904:	89 74 24 04          	mov    %esi,0x4(%esp)
f0101908:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010190c:	e9 18 ff ff ff       	jmp    f0101829 <__umoddi3+0x69>
