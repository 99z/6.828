
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
f0100015:	b8 00 20 11 00       	mov    $0x112000,%eax
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
f0100034:	bc 00 20 11 f0       	mov    $0xf0112000,%esp

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
f010004b:	68 20 25 10 f0       	push   $0xf0102520
f0100050:	e8 79 15 00 00       	call   f01015ce <cprintf>
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
f0100082:	68 3c 25 10 f0       	push   $0xf010253c
f0100087:	e8 42 15 00 00       	call   f01015ce <cprintf>
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
f010009a:	b8 70 49 11 f0       	mov    $0xf0114970,%eax
f010009f:	2d 00 43 11 f0       	sub    $0xf0114300,%eax
f01000a4:	50                   	push   %eax
f01000a5:	6a 00                	push   $0x0
f01000a7:	68 00 43 11 f0       	push   $0xf0114300
f01000ac:	e8 d6 1f 00 00       	call   f0102087 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b1:	e8 de 04 00 00       	call   f0100594 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000b6:	83 c4 08             	add    $0x8,%esp
f01000b9:	68 ac 1a 00 00       	push   $0x1aac
f01000be:	68 57 25 10 f0       	push   $0xf0102557
f01000c3:	e8 06 15 00 00       	call   f01015ce <cprintf>

	int x = 1, y = 3, z = 4;
	cprintf("x %d, y %x, z %d\n", x, y, z);
f01000c8:	6a 04                	push   $0x4
f01000ca:	6a 03                	push   $0x3
f01000cc:	6a 01                	push   $0x1
f01000ce:	68 72 25 10 f0       	push   $0xf0102572
f01000d3:	e8 f6 14 00 00       	call   f01015ce <cprintf>

	// 0x72 = r, 0x6c = l, 0x64 = d, 0x00 = \0
	// 57616 in hex = e110
	unsigned int i = 0x00646c72;
f01000d8:	c7 45 f4 72 6c 64 00 	movl   $0x646c72,-0xc(%ebp)
	cprintf("H%x Wo%s\n", 57616, &i);
f01000df:	83 c4 1c             	add    $0x1c,%esp
f01000e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01000e5:	50                   	push   %eax
f01000e6:	68 10 e1 00 00       	push   $0xe110
f01000eb:	68 84 25 10 f0       	push   $0xf0102584
f01000f0:	e8 d9 14 00 00       	call   f01015ce <cprintf>

	cprintf("x=%d y=%d\n", 3);
f01000f5:	83 c4 08             	add    $0x8,%esp
f01000f8:	6a 03                	push   $0x3
f01000fa:	68 8e 25 10 f0       	push   $0xf010258e
f01000ff:	e8 ca 14 00 00       	call   f01015ce <cprintf>

	// Test the stack backtrace function (lab 1 only)
	test_backtrace(5);
f0100104:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
f010010b:	e8 30 ff ff ff       	call   f0100040 <test_backtrace>

	// Lab 2 memory management initialization
	mem_init();
f0100110:	e8 c0 0d 00 00       	call   f0100ed5 <mem_init>
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
f010012f:	83 3d 60 49 11 f0 00 	cmpl   $0x0,0xf0114960
f0100136:	75 37                	jne    f010016f <_panic+0x48>
		goto dead;
	panicstr = fmt;
f0100138:	89 35 60 49 11 f0    	mov    %esi,0xf0114960

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
f010014c:	68 99 25 10 f0       	push   $0xf0102599
f0100151:	e8 78 14 00 00       	call   f01015ce <cprintf>
	vcprintf(fmt, ap);
f0100156:	83 c4 08             	add    $0x8,%esp
f0100159:	53                   	push   %ebx
f010015a:	56                   	push   %esi
f010015b:	e8 48 14 00 00       	call   f01015a8 <vcprintf>
	cprintf("\n");
f0100160:	c7 04 24 d5 25 10 f0 	movl   $0xf01025d5,(%esp)
f0100167:	e8 62 14 00 00       	call   f01015ce <cprintf>
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
f010018e:	68 b1 25 10 f0       	push   $0xf01025b1
f0100193:	e8 36 14 00 00       	call   f01015ce <cprintf>
	vcprintf(fmt, ap);
f0100198:	83 c4 08             	add    $0x8,%esp
f010019b:	53                   	push   %ebx
f010019c:	ff 75 10             	pushl  0x10(%ebp)
f010019f:	e8 04 14 00 00       	call   f01015a8 <vcprintf>
	cprintf("\n");
f01001a4:	c7 04 24 d5 25 10 f0 	movl   $0xf01025d5,(%esp)
f01001ab:	e8 1e 14 00 00       	call   f01015ce <cprintf>
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
f01001e6:	8b 0d 24 45 11 f0    	mov    0xf0114524,%ecx
f01001ec:	8d 51 01             	lea    0x1(%ecx),%edx
f01001ef:	89 15 24 45 11 f0    	mov    %edx,0xf0114524
f01001f5:	88 81 20 43 11 f0    	mov    %al,-0xfeebce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01001fb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100201:	75 0a                	jne    f010020d <cons_intr+0x36>
			cons.wpos = 0;
f0100203:	c7 05 24 45 11 f0 00 	movl   $0x0,0xf0114524
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
f010023c:	83 0d 00 43 11 f0 40 	orl    $0x40,0xf0114300
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
f0100254:	8b 0d 00 43 11 f0    	mov    0xf0114300,%ecx
f010025a:	89 cb                	mov    %ecx,%ebx
f010025c:	83 e3 40             	and    $0x40,%ebx
f010025f:	83 e0 7f             	and    $0x7f,%eax
f0100262:	85 db                	test   %ebx,%ebx
f0100264:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100267:	0f b6 d2             	movzbl %dl,%edx
f010026a:	0f b6 82 20 27 10 f0 	movzbl -0xfefd8e0(%edx),%eax
f0100271:	83 c8 40             	or     $0x40,%eax
f0100274:	0f b6 c0             	movzbl %al,%eax
f0100277:	f7 d0                	not    %eax
f0100279:	21 c8                	and    %ecx,%eax
f010027b:	a3 00 43 11 f0       	mov    %eax,0xf0114300
		return 0;
f0100280:	b8 00 00 00 00       	mov    $0x0,%eax
f0100285:	e9 a4 00 00 00       	jmp    f010032e <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010028a:	8b 0d 00 43 11 f0    	mov    0xf0114300,%ecx
f0100290:	f6 c1 40             	test   $0x40,%cl
f0100293:	74 0e                	je     f01002a3 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100295:	83 c8 80             	or     $0xffffff80,%eax
f0100298:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010029a:	83 e1 bf             	and    $0xffffffbf,%ecx
f010029d:	89 0d 00 43 11 f0    	mov    %ecx,0xf0114300
	}

	shift |= shiftcode[data];
f01002a3:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f01002a6:	0f b6 82 20 27 10 f0 	movzbl -0xfefd8e0(%edx),%eax
f01002ad:	0b 05 00 43 11 f0    	or     0xf0114300,%eax
f01002b3:	0f b6 8a 20 26 10 f0 	movzbl -0xfefd9e0(%edx),%ecx
f01002ba:	31 c8                	xor    %ecx,%eax
f01002bc:	a3 00 43 11 f0       	mov    %eax,0xf0114300

	c = charcode[shift & (CTL | SHIFT)][data];
f01002c1:	89 c1                	mov    %eax,%ecx
f01002c3:	83 e1 03             	and    $0x3,%ecx
f01002c6:	8b 0c 8d 00 26 10 f0 	mov    -0xfefda00(,%ecx,4),%ecx
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
f0100304:	68 cb 25 10 f0       	push   $0xf01025cb
f0100309:	e8 c0 12 00 00       	call   f01015ce <cprintf>
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
f01003f0:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f01003f7:	66 85 c0             	test   %ax,%ax
f01003fa:	0f 84 e6 00 00 00    	je     f01004e6 <cons_putc+0x1b3>
			crt_pos--;
f0100400:	83 e8 01             	sub    $0x1,%eax
f0100403:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100409:	0f b7 c0             	movzwl %ax,%eax
f010040c:	66 81 e7 00 ff       	and    $0xff00,%di
f0100411:	83 cf 20             	or     $0x20,%edi
f0100414:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
f010041a:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f010041e:	eb 78                	jmp    f0100498 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100420:	66 83 05 28 45 11 f0 	addw   $0x50,0xf0114528
f0100427:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f0100428:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f010042f:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100435:	c1 e8 16             	shr    $0x16,%eax
f0100438:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010043b:	c1 e0 04             	shl    $0x4,%eax
f010043e:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
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
f010047a:	0f b7 05 28 45 11 f0 	movzwl 0xf0114528,%eax
f0100481:	8d 50 01             	lea    0x1(%eax),%edx
f0100484:	66 89 15 28 45 11 f0 	mov    %dx,0xf0114528
f010048b:	0f b7 c0             	movzwl %ax,%eax
f010048e:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
f0100494:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100498:	66 81 3d 28 45 11 f0 	cmpw   $0x7cf,0xf0114528
f010049f:	cf 07 
f01004a1:	76 43                	jbe    f01004e6 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f01004a3:	a1 2c 45 11 f0       	mov    0xf011452c,%eax
f01004a8:	83 ec 04             	sub    $0x4,%esp
f01004ab:	68 00 0f 00 00       	push   $0xf00
f01004b0:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f01004b6:	52                   	push   %edx
f01004b7:	50                   	push   %eax
f01004b8:	e8 17 1c 00 00       	call   f01020d4 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f01004bd:	8b 15 2c 45 11 f0    	mov    0xf011452c,%edx
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
f01004de:	66 83 2d 28 45 11 f0 	subw   $0x50,0xf0114528
f01004e5:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01004e6:	8b 0d 30 45 11 f0    	mov    0xf0114530,%ecx
f01004ec:	b8 0e 00 00 00       	mov    $0xe,%eax
f01004f1:	89 ca                	mov    %ecx,%edx
f01004f3:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004f4:	0f b7 1d 28 45 11 f0 	movzwl 0xf0114528,%ebx
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
f010051c:	80 3d 34 45 11 f0 00 	cmpb   $0x0,0xf0114534
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
f010055a:	a1 20 45 11 f0       	mov    0xf0114520,%eax
f010055f:	3b 05 24 45 11 f0    	cmp    0xf0114524,%eax
f0100565:	74 26                	je     f010058d <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100567:	8d 50 01             	lea    0x1(%eax),%edx
f010056a:	89 15 20 45 11 f0    	mov    %edx,0xf0114520
f0100570:	0f b6 88 20 43 11 f0 	movzbl -0xfeebce0(%eax),%ecx
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
f0100581:	c7 05 20 45 11 f0 00 	movl   $0x0,0xf0114520
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
f01005ba:	c7 05 30 45 11 f0 b4 	movl   $0x3b4,0xf0114530
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
f01005d2:	c7 05 30 45 11 f0 d4 	movl   $0x3d4,0xf0114530
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
f01005e1:	8b 3d 30 45 11 f0    	mov    0xf0114530,%edi
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
f0100606:	89 35 2c 45 11 f0    	mov    %esi,0xf011452c
	crt_pos = pos;
f010060c:	0f b6 c0             	movzbl %al,%eax
f010060f:	09 c8                	or     %ecx,%eax
f0100611:	66 a3 28 45 11 f0    	mov    %ax,0xf0114528
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
f0100672:	0f 95 05 34 45 11 f0 	setne  0xf0114534
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
f0100687:	68 d7 25 10 f0       	push   $0xf01025d7
f010068c:	e8 3d 0f 00 00       	call   f01015ce <cprintf>
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
f01006cd:	68 20 28 10 f0       	push   $0xf0102820
f01006d2:	68 3e 28 10 f0       	push   $0xf010283e
f01006d7:	68 43 28 10 f0       	push   $0xf0102843
f01006dc:	e8 ed 0e 00 00       	call   f01015ce <cprintf>
f01006e1:	83 c4 0c             	add    $0xc,%esp
f01006e4:	68 f4 28 10 f0       	push   $0xf01028f4
f01006e9:	68 4c 28 10 f0       	push   $0xf010284c
f01006ee:	68 43 28 10 f0       	push   $0xf0102843
f01006f3:	e8 d6 0e 00 00       	call   f01015ce <cprintf>
f01006f8:	83 c4 0c             	add    $0xc,%esp
f01006fb:	68 55 28 10 f0       	push   $0xf0102855
f0100700:	68 72 28 10 f0       	push   $0xf0102872
f0100705:	68 43 28 10 f0       	push   $0xf0102843
f010070a:	e8 bf 0e 00 00       	call   f01015ce <cprintf>
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
f010071c:	68 7c 28 10 f0       	push   $0xf010287c
f0100721:	e8 a8 0e 00 00       	call   f01015ce <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100726:	83 c4 08             	add    $0x8,%esp
f0100729:	68 0c 00 10 00       	push   $0x10000c
f010072e:	68 1c 29 10 f0       	push   $0xf010291c
f0100733:	e8 96 0e 00 00       	call   f01015ce <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100738:	83 c4 0c             	add    $0xc,%esp
f010073b:	68 0c 00 10 00       	push   $0x10000c
f0100740:	68 0c 00 10 f0       	push   $0xf010000c
f0100745:	68 44 29 10 f0       	push   $0xf0102944
f010074a:	e8 7f 0e 00 00       	call   f01015ce <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010074f:	83 c4 0c             	add    $0xc,%esp
f0100752:	68 11 25 10 00       	push   $0x102511
f0100757:	68 11 25 10 f0       	push   $0xf0102511
f010075c:	68 68 29 10 f0       	push   $0xf0102968
f0100761:	e8 68 0e 00 00       	call   f01015ce <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100766:	83 c4 0c             	add    $0xc,%esp
f0100769:	68 00 43 11 00       	push   $0x114300
f010076e:	68 00 43 11 f0       	push   $0xf0114300
f0100773:	68 8c 29 10 f0       	push   $0xf010298c
f0100778:	e8 51 0e 00 00       	call   f01015ce <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010077d:	83 c4 0c             	add    $0xc,%esp
f0100780:	68 70 49 11 00       	push   $0x114970
f0100785:	68 70 49 11 f0       	push   $0xf0114970
f010078a:	68 b0 29 10 f0       	push   $0xf01029b0
f010078f:	e8 3a 0e 00 00       	call   f01015ce <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100794:	b8 6f 4d 11 f0       	mov    $0xf0114d6f,%eax
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
f01007b5:	68 d4 29 10 f0       	push   $0xf01029d4
f01007ba:	e8 0f 0e 00 00       	call   f01015ce <cprintf>
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
f01007d3:	68 95 28 10 f0       	push   $0xf0102895
f01007d8:	e8 f1 0d 00 00       	call   f01015ce <cprintf>
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
f01007f4:	e8 df 0e 00 00       	call   f01016d8 <debuginfo_eip>
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
f0100825:	68 00 2a 10 f0       	push   $0xf0102a00
f010082a:	e8 9f 0d 00 00       	call   f01015ce <cprintf>
		cprintf("\t%s:%d: %.*s+%d\n", eip_debug_info.eip_file, eip_debug_info.eip_line, eip_debug_info.eip_fn_namelen, eip_debug_info.eip_fn_name, eip - eip_debug_info.eip_fn_addr);
f010082f:	83 c4 18             	add    $0x18,%esp
f0100832:	2b 5d cc             	sub    -0x34(%ebp),%ebx
f0100835:	53                   	push   %ebx
f0100836:	ff 75 c4             	pushl  -0x3c(%ebp)
f0100839:	ff 75 c8             	pushl  -0x38(%ebp)
f010083c:	ff 75 c0             	pushl  -0x40(%ebp)
f010083f:	ff 75 bc             	pushl  -0x44(%ebp)
f0100842:	68 a7 28 10 f0       	push   $0xf01028a7
f0100847:	e8 82 0d 00 00       	call   f01015ce <cprintf>
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
f010086c:	68 34 2a 10 f0       	push   $0xf0102a34
f0100871:	e8 58 0d 00 00       	call   f01015ce <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100876:	c7 04 24 58 2a 10 f0 	movl   $0xf0102a58,(%esp)
f010087d:	e8 4c 0d 00 00       	call   f01015ce <cprintf>
f0100882:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f0100885:	83 ec 0c             	sub    $0xc,%esp
f0100888:	68 b8 28 10 f0       	push   $0xf01028b8
f010088d:	e8 9e 15 00 00       	call   f0101e30 <readline>
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
f01008c1:	68 bc 28 10 f0       	push   $0xf01028bc
f01008c6:	e8 7f 17 00 00       	call   f010204a <strchr>
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
f01008e1:	68 c1 28 10 f0       	push   $0xf01028c1
f01008e6:	e8 e3 0c 00 00       	call   f01015ce <cprintf>
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
f010090a:	68 bc 28 10 f0       	push   $0xf01028bc
f010090f:	e8 36 17 00 00       	call   f010204a <strchr>
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
f0100938:	ff 34 85 80 2a 10 f0 	pushl  -0xfefd580(,%eax,4)
f010093f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100942:	e8 a5 16 00 00       	call   f0101fec <strcmp>
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
f010095c:	ff 14 85 88 2a 10 f0 	call   *-0xfefd578(,%eax,4)


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
f010097d:	68 de 28 10 f0       	push   $0xf01028de
f0100982:	e8 47 0c 00 00       	call   f01015ce <cprintf>
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
f01009a2:	e8 c0 0b 00 00       	call   f0101567 <mc146818_read>
f01009a7:	89 c6                	mov    %eax,%esi
f01009a9:	83 c3 01             	add    $0x1,%ebx
f01009ac:	89 1c 24             	mov    %ebx,(%esp)
f01009af:	e8 b3 0b 00 00       	call   f0101567 <mc146818_read>
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
f01009d6:	3b 0d 64 49 11 f0    	cmp    0xf0114964,%ecx
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
f01009e5:	68 a4 2a 10 f0       	push   $0xf0102aa4
f01009ea:	68 ab 02 00 00       	push   $0x2ab
f01009ef:	68 b4 2c 10 f0       	push   $0xf0102cb4
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
f0100a2a:	83 3d 38 45 11 f0 00 	cmpl   $0x0,0xf0114538
f0100a31:	75 11                	jne    f0100a44 <boot_alloc+0x20>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a33:	ba 6f 59 11 f0       	mov    $0xf011596f,%edx
f0100a38:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a3e:	89 15 38 45 11 f0    	mov    %edx,0xf0114538
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.

	// If n > 0, allocate pages for result
	if (n > 0) {
f0100a44:	85 c0                	test   %eax,%eax
f0100a46:	74 43                	je     f0100a8b <boot_alloc+0x67>
		result = KADDR(PADDR(nextfree));
f0100a48:	a1 38 45 11 f0       	mov    0xf0114538,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100a4d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100a52:	77 12                	ja     f0100a66 <boot_alloc+0x42>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100a54:	50                   	push   %eax
f0100a55:	68 c8 2a 10 f0       	push   $0xf0102ac8
f0100a5a:	6a 6a                	push   $0x6a
f0100a5c:	68 b4 2c 10 f0       	push   $0xf0102cb4
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
f0100a71:	39 0d 64 49 11 f0    	cmp    %ecx,0xf0114964
f0100a77:	77 17                	ja     f0100a90 <boot_alloc+0x6c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a79:	52                   	push   %edx
f0100a7a:	68 a4 2a 10 f0       	push   $0xf0102aa4
f0100a7f:	6a 6a                	push   $0x6a
f0100a81:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100a86:	e8 9c f6 ff ff       	call   f0100127 <_panic>
	} else {
		result = nextfree + ROUNDUP(n, PGSIZE);
f0100a8b:	a1 38 45 11 f0       	mov    0xf0114538,%eax
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
f0100aab:	68 ec 2a 10 f0       	push   $0xf0102aec
f0100ab0:	68 ec 01 00 00       	push   $0x1ec
f0100ab5:	68 b4 2c 10 f0       	push   $0xf0102cb4
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
f0100acd:	2b 15 6c 49 11 f0    	sub    0xf011496c,%edx
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
f0100b03:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
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
f0100b0d:	8b 1d 3c 45 11 f0    	mov    0xf011453c,%ebx
f0100b13:	eb 53                	jmp    f0100b68 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b15:	89 d8                	mov    %ebx,%eax
f0100b17:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
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
f0100b31:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100b37:	72 12                	jb     f0100b4b <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b39:	50                   	push   %eax
f0100b3a:	68 a4 2a 10 f0       	push   $0xf0102aa4
f0100b3f:	6a 52                	push   $0x52
f0100b41:	68 c0 2c 10 f0       	push   $0xf0102cc0
f0100b46:	e8 dc f5 ff ff       	call   f0100127 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b4b:	83 ec 04             	sub    $0x4,%esp
f0100b4e:	68 80 00 00 00       	push   $0x80
f0100b53:	68 97 00 00 00       	push   $0x97
f0100b58:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b5d:	50                   	push   %eax
f0100b5e:	e8 24 15 00 00       	call   f0102087 <memset>
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
f0100b79:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b7f:	8b 0d 6c 49 11 f0    	mov    0xf011496c,%ecx
		assert(pp < pages + npages);
f0100b85:	a1 64 49 11 f0       	mov    0xf0114964,%eax
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
f0100ba4:	68 ce 2c 10 f0       	push   $0xf0102cce
f0100ba9:	68 da 2c 10 f0       	push   $0xf0102cda
f0100bae:	68 06 02 00 00       	push   $0x206
f0100bb3:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100bb8:	e8 6a f5 ff ff       	call   f0100127 <_panic>
		assert(pp < pages + npages);
f0100bbd:	39 fa                	cmp    %edi,%edx
f0100bbf:	72 19                	jb     f0100bda <check_page_free_list+0x148>
f0100bc1:	68 ef 2c 10 f0       	push   $0xf0102cef
f0100bc6:	68 da 2c 10 f0       	push   $0xf0102cda
f0100bcb:	68 07 02 00 00       	push   $0x207
f0100bd0:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100bd5:	e8 4d f5 ff ff       	call   f0100127 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bda:	89 d0                	mov    %edx,%eax
f0100bdc:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100bdf:	a8 07                	test   $0x7,%al
f0100be1:	74 19                	je     f0100bfc <check_page_free_list+0x16a>
f0100be3:	68 10 2b 10 f0       	push   $0xf0102b10
f0100be8:	68 da 2c 10 f0       	push   $0xf0102cda
f0100bed:	68 08 02 00 00       	push   $0x208
f0100bf2:	68 b4 2c 10 f0       	push   $0xf0102cb4
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
f0100c06:	68 03 2d 10 f0       	push   $0xf0102d03
f0100c0b:	68 da 2c 10 f0       	push   $0xf0102cda
f0100c10:	68 0b 02 00 00       	push   $0x20b
f0100c15:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100c1a:	e8 08 f5 ff ff       	call   f0100127 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c1f:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c24:	75 19                	jne    f0100c3f <check_page_free_list+0x1ad>
f0100c26:	68 14 2d 10 f0       	push   $0xf0102d14
f0100c2b:	68 da 2c 10 f0       	push   $0xf0102cda
f0100c30:	68 0c 02 00 00       	push   $0x20c
f0100c35:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100c3a:	e8 e8 f4 ff ff       	call   f0100127 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c3f:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c44:	75 19                	jne    f0100c5f <check_page_free_list+0x1cd>
f0100c46:	68 44 2b 10 f0       	push   $0xf0102b44
f0100c4b:	68 da 2c 10 f0       	push   $0xf0102cda
f0100c50:	68 0d 02 00 00       	push   $0x20d
f0100c55:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100c5a:	e8 c8 f4 ff ff       	call   f0100127 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c5f:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c64:	75 19                	jne    f0100c7f <check_page_free_list+0x1ed>
f0100c66:	68 2d 2d 10 f0       	push   $0xf0102d2d
f0100c6b:	68 da 2c 10 f0       	push   $0xf0102cda
f0100c70:	68 0e 02 00 00       	push   $0x20e
f0100c75:	68 b4 2c 10 f0       	push   $0xf0102cb4
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
f0100c91:	68 a4 2a 10 f0       	push   $0xf0102aa4
f0100c96:	6a 52                	push   $0x52
f0100c98:	68 c0 2c 10 f0       	push   $0xf0102cc0
f0100c9d:	e8 85 f4 ff ff       	call   f0100127 <_panic>
f0100ca2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ca7:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100caa:	76 1e                	jbe    f0100cca <check_page_free_list+0x238>
f0100cac:	68 68 2b 10 f0       	push   $0xf0102b68
f0100cb1:	68 da 2c 10 f0       	push   $0xf0102cda
f0100cb6:	68 0f 02 00 00       	push   $0x20f
f0100cbb:	68 b4 2c 10 f0       	push   $0xf0102cb4
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
f0100cdf:	68 47 2d 10 f0       	push   $0xf0102d47
f0100ce4:	68 da 2c 10 f0       	push   $0xf0102cda
f0100ce9:	68 17 02 00 00       	push   $0x217
f0100cee:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100cf3:	e8 2f f4 ff ff       	call   f0100127 <_panic>
	assert(nfree_extmem > 0);
f0100cf8:	85 db                	test   %ebx,%ebx
f0100cfa:	7f 19                	jg     f0100d15 <check_page_free_list+0x283>
f0100cfc:	68 59 2d 10 f0       	push   $0xf0102d59
f0100d01:	68 da 2c 10 f0       	push   $0xf0102cda
f0100d06:	68 18 02 00 00       	push   $0x218
f0100d0b:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100d10:	e8 12 f4 ff ff       	call   f0100127 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d15:	83 ec 0c             	sub    $0xc,%esp
f0100d18:	68 b0 2b 10 f0       	push   $0xf0102bb0
f0100d1d:	e8 ac 08 00 00       	call   f01015ce <cprintf>
}
f0100d22:	eb 29                	jmp    f0100d4d <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d24:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0100d29:	85 c0                	test   %eax,%eax
f0100d2b:	0f 85 8e fd ff ff    	jne    f0100abf <check_page_free_list+0x2d>
f0100d31:	e9 72 fd ff ff       	jmp    f0100aa8 <check_page_free_list+0x16>
f0100d36:	83 3d 3c 45 11 f0 00 	cmpl   $0x0,0xf011453c
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
f0100d70:	68 c8 2a 10 f0       	push   $0xf0102ac8
f0100d75:	68 09 01 00 00       	push   $0x109
f0100d7a:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100d7f:	e8 a3 f3 ff ff       	call   f0100127 <_panic>
f0100d84:	05 00 00 00 10       	add    $0x10000000,%eax
f0100d89:	c1 e8 0c             	shr    $0xc,%eax
	// from pmap.h
	size_t io_hole_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	pages[0].pp_ref = 1;
f0100d8c:	8b 15 6c 49 11 f0    	mov    0xf011496c,%edx
f0100d92:	66 c7 42 04 01 00    	movw   $0x1,0x4(%edx)
	for (i = 1; i < npages; i++) {
		// npages_basemem = amount of base memory in pages
		// don't allocate memory in the io hole
		if ((i >= npages_basemem && i < npages_basemem + io_hole_pages) ||
f0100d98:	8b 3d 40 45 11 f0    	mov    0xf0114540,%edi
f0100d9e:	8d 77 60             	lea    0x60(%edi),%esi
f0100da1:	8b 1d 3c 45 11 f0    	mov    0xf011453c,%ebx
	// uintptr_t of page number field of address
	size_t pagenum = PGNUM(PADDR(boot_alloc(0)));
	// from pmap.h
	size_t io_hole_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
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
	// uintptr_t of page number field of address
	size_t pagenum = PGNUM(PADDR(boot_alloc(0)));
	// from pmap.h
	size_t io_hole_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
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
f0100dcb:	a1 6c 49 11 f0       	mov    0xf011496c,%eax
f0100dd0:	66 c7 44 d0 04 01 00 	movw   $0x1,0x4(%eax,%edx,8)
			continue;
f0100dd7:	eb 24                	jmp    f0100dfd <page_init+0xa8>
		}
		pages[i].pp_ref = 0;
f0100dd9:	8d 04 d5 00 00 00 00 	lea    0x0(,%edx,8),%eax
f0100de0:	89 c1                	mov    %eax,%ecx
f0100de2:	03 0d 6c 49 11 f0    	add    0xf011496c,%ecx
f0100de8:	66 c7 41 04 00 00    	movw   $0x0,0x4(%ecx)
		pages[i].pp_link = page_free_list;
f0100dee:	89 19                	mov    %ebx,(%ecx)
		// page_free_list = PageInfo *
		page_free_list = &pages[i];
f0100df0:	03 05 6c 49 11 f0    	add    0xf011496c,%eax
f0100df6:	89 c3                	mov    %eax,%ebx
f0100df8:	b9 01 00 00 00       	mov    $0x1,%ecx
	// uintptr_t of page number field of address
	size_t pagenum = PGNUM(PADDR(boot_alloc(0)));
	// from pmap.h
	size_t io_hole_pages = (EXTPHYSMEM - IOPHYSMEM) / PGSIZE;
	pages[0].pp_ref = 1;
	for (i = 1; i < npages; i++) {
f0100dfd:	83 c2 01             	add    $0x1,%edx
f0100e00:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100e06:	72 b0                	jb     f0100db8 <page_init+0x63>
f0100e08:	84 c9                	test   %cl,%cl
f0100e0a:	74 06                	je     f0100e12 <page_init+0xbd>
f0100e0c:	89 1d 3c 45 11 f0    	mov    %ebx,0xf011453c
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
f0100e21:	8b 1d 3c 45 11 f0    	mov    0xf011453c,%ebx
f0100e27:	85 db                	test   %ebx,%ebx
f0100e29:	74 68                	je     f0100e93 <page_alloc+0x79>
		return NULL;
	}

	struct PageInfo *pp = page_free_list;
	page_free_list = pp->pp_link;
f0100e2b:	8b 03                	mov    (%ebx),%eax
f0100e2d:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
	pp->pp_link = NULL;
f0100e32:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	// bitwise AND, not &&
	if (alloc_flags & ALLOC_ZERO) {
f0100e38:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e3c:	74 55                	je     f0100e93 <page_alloc+0x79>
		cprintf("alloc_flags is zero\n");
f0100e3e:	83 ec 0c             	sub    $0xc,%esp
f0100e41:	68 6a 2d 10 f0       	push   $0xf0102d6a
f0100e46:	e8 83 07 00 00       	call   f01015ce <cprintf>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e4b:	89 d8                	mov    %ebx,%eax
f0100e4d:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
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
f0100e61:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0100e67:	72 12                	jb     f0100e7b <page_alloc+0x61>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e69:	50                   	push   %eax
f0100e6a:	68 a4 2a 10 f0       	push   $0xf0102aa4
f0100e6f:	6a 52                	push   $0x52
f0100e71:	68 c0 2c 10 f0       	push   $0xf0102cc0
f0100e76:	e8 ac f2 ff ff       	call   f0100127 <_panic>
		// fill physical page with '\0' bytes
		memset(page2kva(pp), '\0', PGSIZE);
f0100e7b:	83 ec 04             	sub    $0x4,%esp
f0100e7e:	68 00 10 00 00       	push   $0x1000
f0100e83:	6a 00                	push   $0x0
f0100e85:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100e8a:	50                   	push   %eax
f0100e8b:	e8 f7 11 00 00       	call   f0102087 <memset>
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
f0100eb2:	68 d4 2b 10 f0       	push   $0xf0102bd4
f0100eb7:	68 49 01 00 00       	push   $0x149
f0100ebc:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100ec1:	e8 61 f2 ff ff       	call   f0100127 <_panic>
	}
	pp->pp_link = page_free_list;
f0100ec6:	8b 15 3c 45 11 f0    	mov    0xf011453c,%edx
f0100ecc:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100ece:	a3 3c 45 11 f0       	mov    %eax,0xf011453c
}
f0100ed3:	c9                   	leave  
f0100ed4:	c3                   	ret    

f0100ed5 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100ed5:	55                   	push   %ebp
f0100ed6:	89 e5                	mov    %esp,%ebp
f0100ed8:	57                   	push   %edi
f0100ed9:	56                   	push   %esi
f0100eda:	53                   	push   %ebx
f0100edb:	83 ec 1c             	sub    $0x1c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100ede:	b8 15 00 00 00       	mov    $0x15,%eax
f0100ee3:	e8 af fa ff ff       	call   f0100997 <nvram_read>
f0100ee8:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100eea:	b8 17 00 00 00       	mov    $0x17,%eax
f0100eef:	e8 a3 fa ff ff       	call   f0100997 <nvram_read>
f0100ef4:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100ef6:	b8 34 00 00 00       	mov    $0x34,%eax
f0100efb:	e8 97 fa ff ff       	call   f0100997 <nvram_read>
f0100f00:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100f03:	85 c0                	test   %eax,%eax
f0100f05:	74 07                	je     f0100f0e <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0100f07:	05 00 40 00 00       	add    $0x4000,%eax
f0100f0c:	eb 0b                	jmp    f0100f19 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0100f0e:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100f14:	85 f6                	test   %esi,%esi
f0100f16:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100f19:	89 c2                	mov    %eax,%edx
f0100f1b:	c1 ea 02             	shr    $0x2,%edx
f0100f1e:	89 15 64 49 11 f0    	mov    %edx,0xf0114964
	npages_basemem = basemem / (PGSIZE / 1024);
f0100f24:	89 da                	mov    %ebx,%edx
f0100f26:	c1 ea 02             	shr    $0x2,%edx
f0100f29:	89 15 40 45 11 f0    	mov    %edx,0xf0114540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100f2f:	89 c2                	mov    %eax,%edx
f0100f31:	29 da                	sub    %ebx,%edx
f0100f33:	52                   	push   %edx
f0100f34:	53                   	push   %ebx
f0100f35:	50                   	push   %eax
f0100f36:	68 08 2c 10 f0       	push   $0xf0102c08
f0100f3b:	e8 8e 06 00 00       	call   f01015ce <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0100f40:	b8 00 10 00 00       	mov    $0x1000,%eax
f0100f45:	e8 da fa ff ff       	call   f0100a24 <boot_alloc>
f0100f4a:	a3 68 49 11 f0       	mov    %eax,0xf0114968
	memset(kern_pgdir, 0, PGSIZE);
f0100f4f:	83 c4 0c             	add    $0xc,%esp
f0100f52:	68 00 10 00 00       	push   $0x1000
f0100f57:	6a 00                	push   $0x0
f0100f59:	50                   	push   %eax
f0100f5a:	e8 28 11 00 00       	call   f0102087 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0100f5f:	a1 68 49 11 f0       	mov    0xf0114968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f64:	83 c4 10             	add    $0x10,%esp
f0100f67:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100f6c:	77 15                	ja     f0100f83 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f6e:	50                   	push   %eax
f0100f6f:	68 c8 2a 10 f0       	push   $0xf0102ac8
f0100f74:	68 93 00 00 00       	push   $0x93
f0100f79:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100f7e:	e8 a4 f1 ff ff       	call   f0100127 <_panic>
f0100f83:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0100f89:	83 ca 05             	or     $0x5,%edx
f0100f8c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.

	// pages = number of elements (npages) * size of the struct we want
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0100f92:	a1 64 49 11 f0       	mov    0xf0114964,%eax
f0100f97:	c1 e0 03             	shl    $0x3,%eax
f0100f9a:	e8 85 fa ff ff       	call   f0100a24 <boot_alloc>
f0100f9f:	a3 6c 49 11 f0       	mov    %eax,0xf011496c
	memset(pages, 0, npages * sizeof(struct PageInfo));
f0100fa4:	83 ec 04             	sub    $0x4,%esp
f0100fa7:	8b 0d 64 49 11 f0    	mov    0xf0114964,%ecx
f0100fad:	8d 14 cd 00 00 00 00 	lea    0x0(,%ecx,8),%edx
f0100fb4:	52                   	push   %edx
f0100fb5:	6a 00                	push   $0x0
f0100fb7:	50                   	push   %eax
f0100fb8:	e8 ca 10 00 00       	call   f0102087 <memset>
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0100fbd:	e8 93 fd ff ff       	call   f0100d55 <page_init>

	check_page_free_list(1);
f0100fc2:	b8 01 00 00 00       	mov    $0x1,%eax
f0100fc7:	e8 c6 fa ff ff       	call   f0100a92 <check_page_free_list>
	cprintf("Entering check_page_alloc\n");
f0100fcc:	c7 04 24 7f 2d 10 f0 	movl   $0xf0102d7f,(%esp)
f0100fd3:	e8 f6 05 00 00       	call   f01015ce <cprintf>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0100fd8:	83 c4 10             	add    $0x10,%esp
f0100fdb:	83 3d 6c 49 11 f0 00 	cmpl   $0x0,0xf011496c
f0100fe2:	75 17                	jne    f0100ffb <mem_init+0x126>
		panic("'pages' is a null pointer!");
f0100fe4:	83 ec 04             	sub    $0x4,%esp
f0100fe7:	68 9a 2d 10 f0       	push   $0xf0102d9a
f0100fec:	68 2b 02 00 00       	push   $0x22b
f0100ff1:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0100ff6:	e8 2c f1 ff ff       	call   f0100127 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0100ffb:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0101000:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101005:	eb 05                	jmp    f010100c <mem_init+0x137>
		++nfree;
f0101007:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010100a:	8b 00                	mov    (%eax),%eax
f010100c:	85 c0                	test   %eax,%eax
f010100e:	75 f7                	jne    f0101007 <mem_init+0x132>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101010:	83 ec 0c             	sub    $0xc,%esp
f0101013:	6a 00                	push   $0x0
f0101015:	e8 00 fe ff ff       	call   f0100e1a <page_alloc>
f010101a:	89 c7                	mov    %eax,%edi
f010101c:	83 c4 10             	add    $0x10,%esp
f010101f:	85 c0                	test   %eax,%eax
f0101021:	75 19                	jne    f010103c <mem_init+0x167>
f0101023:	68 b5 2d 10 f0       	push   $0xf0102db5
f0101028:	68 da 2c 10 f0       	push   $0xf0102cda
f010102d:	68 33 02 00 00       	push   $0x233
f0101032:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101037:	e8 eb f0 ff ff       	call   f0100127 <_panic>
	assert((pp1 = page_alloc(0)));
f010103c:	83 ec 0c             	sub    $0xc,%esp
f010103f:	6a 00                	push   $0x0
f0101041:	e8 d4 fd ff ff       	call   f0100e1a <page_alloc>
f0101046:	89 c6                	mov    %eax,%esi
f0101048:	83 c4 10             	add    $0x10,%esp
f010104b:	85 c0                	test   %eax,%eax
f010104d:	75 19                	jne    f0101068 <mem_init+0x193>
f010104f:	68 cb 2d 10 f0       	push   $0xf0102dcb
f0101054:	68 da 2c 10 f0       	push   $0xf0102cda
f0101059:	68 34 02 00 00       	push   $0x234
f010105e:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101063:	e8 bf f0 ff ff       	call   f0100127 <_panic>
	assert((pp2 = page_alloc(0)));
f0101068:	83 ec 0c             	sub    $0xc,%esp
f010106b:	6a 00                	push   $0x0
f010106d:	e8 a8 fd ff ff       	call   f0100e1a <page_alloc>
f0101072:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101075:	83 c4 10             	add    $0x10,%esp
f0101078:	85 c0                	test   %eax,%eax
f010107a:	75 19                	jne    f0101095 <mem_init+0x1c0>
f010107c:	68 e1 2d 10 f0       	push   $0xf0102de1
f0101081:	68 da 2c 10 f0       	push   $0xf0102cda
f0101086:	68 35 02 00 00       	push   $0x235
f010108b:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101090:	e8 92 f0 ff ff       	call   f0100127 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101095:	39 f7                	cmp    %esi,%edi
f0101097:	75 19                	jne    f01010b2 <mem_init+0x1dd>
f0101099:	68 f7 2d 10 f0       	push   $0xf0102df7
f010109e:	68 da 2c 10 f0       	push   $0xf0102cda
f01010a3:	68 38 02 00 00       	push   $0x238
f01010a8:	68 b4 2c 10 f0       	push   $0xf0102cb4
f01010ad:	e8 75 f0 ff ff       	call   f0100127 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01010b2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010b5:	39 c7                	cmp    %eax,%edi
f01010b7:	74 04                	je     f01010bd <mem_init+0x1e8>
f01010b9:	39 c6                	cmp    %eax,%esi
f01010bb:	75 19                	jne    f01010d6 <mem_init+0x201>
f01010bd:	68 44 2c 10 f0       	push   $0xf0102c44
f01010c2:	68 da 2c 10 f0       	push   $0xf0102cda
f01010c7:	68 39 02 00 00       	push   $0x239
f01010cc:	68 b4 2c 10 f0       	push   $0xf0102cb4
f01010d1:	e8 51 f0 ff ff       	call   f0100127 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01010d6:	8b 0d 6c 49 11 f0    	mov    0xf011496c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01010dc:	8b 15 64 49 11 f0    	mov    0xf0114964,%edx
f01010e2:	c1 e2 0c             	shl    $0xc,%edx
f01010e5:	89 f8                	mov    %edi,%eax
f01010e7:	29 c8                	sub    %ecx,%eax
f01010e9:	c1 f8 03             	sar    $0x3,%eax
f01010ec:	c1 e0 0c             	shl    $0xc,%eax
f01010ef:	39 d0                	cmp    %edx,%eax
f01010f1:	72 19                	jb     f010110c <mem_init+0x237>
f01010f3:	68 09 2e 10 f0       	push   $0xf0102e09
f01010f8:	68 da 2c 10 f0       	push   $0xf0102cda
f01010fd:	68 3a 02 00 00       	push   $0x23a
f0101102:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101107:	e8 1b f0 ff ff       	call   f0100127 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010110c:	89 f0                	mov    %esi,%eax
f010110e:	29 c8                	sub    %ecx,%eax
f0101110:	c1 f8 03             	sar    $0x3,%eax
f0101113:	c1 e0 0c             	shl    $0xc,%eax
f0101116:	39 c2                	cmp    %eax,%edx
f0101118:	77 19                	ja     f0101133 <mem_init+0x25e>
f010111a:	68 26 2e 10 f0       	push   $0xf0102e26
f010111f:	68 da 2c 10 f0       	push   $0xf0102cda
f0101124:	68 3b 02 00 00       	push   $0x23b
f0101129:	68 b4 2c 10 f0       	push   $0xf0102cb4
f010112e:	e8 f4 ef ff ff       	call   f0100127 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101133:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101136:	29 c8                	sub    %ecx,%eax
f0101138:	c1 f8 03             	sar    $0x3,%eax
f010113b:	c1 e0 0c             	shl    $0xc,%eax
f010113e:	39 c2                	cmp    %eax,%edx
f0101140:	77 19                	ja     f010115b <mem_init+0x286>
f0101142:	68 43 2e 10 f0       	push   $0xf0102e43
f0101147:	68 da 2c 10 f0       	push   $0xf0102cda
f010114c:	68 3c 02 00 00       	push   $0x23c
f0101151:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101156:	e8 cc ef ff ff       	call   f0100127 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010115b:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f0101160:	89 45 e0             	mov    %eax,-0x20(%ebp)
	page_free_list = 0;
f0101163:	c7 05 3c 45 11 f0 00 	movl   $0x0,0xf011453c
f010116a:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010116d:	83 ec 0c             	sub    $0xc,%esp
f0101170:	6a 00                	push   $0x0
f0101172:	e8 a3 fc ff ff       	call   f0100e1a <page_alloc>
f0101177:	83 c4 10             	add    $0x10,%esp
f010117a:	85 c0                	test   %eax,%eax
f010117c:	74 19                	je     f0101197 <mem_init+0x2c2>
f010117e:	68 60 2e 10 f0       	push   $0xf0102e60
f0101183:	68 da 2c 10 f0       	push   $0xf0102cda
f0101188:	68 43 02 00 00       	push   $0x243
f010118d:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101192:	e8 90 ef ff ff       	call   f0100127 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101197:	83 ec 0c             	sub    $0xc,%esp
f010119a:	57                   	push   %edi
f010119b:	e8 fa fc ff ff       	call   f0100e9a <page_free>
	page_free(pp1);
f01011a0:	89 34 24             	mov    %esi,(%esp)
f01011a3:	e8 f2 fc ff ff       	call   f0100e9a <page_free>
	page_free(pp2);
f01011a8:	83 c4 04             	add    $0x4,%esp
f01011ab:	ff 75 e4             	pushl  -0x1c(%ebp)
f01011ae:	e8 e7 fc ff ff       	call   f0100e9a <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01011b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01011ba:	e8 5b fc ff ff       	call   f0100e1a <page_alloc>
f01011bf:	89 c6                	mov    %eax,%esi
f01011c1:	83 c4 10             	add    $0x10,%esp
f01011c4:	85 c0                	test   %eax,%eax
f01011c6:	75 19                	jne    f01011e1 <mem_init+0x30c>
f01011c8:	68 b5 2d 10 f0       	push   $0xf0102db5
f01011cd:	68 da 2c 10 f0       	push   $0xf0102cda
f01011d2:	68 4a 02 00 00       	push   $0x24a
f01011d7:	68 b4 2c 10 f0       	push   $0xf0102cb4
f01011dc:	e8 46 ef ff ff       	call   f0100127 <_panic>
	assert((pp1 = page_alloc(0)));
f01011e1:	83 ec 0c             	sub    $0xc,%esp
f01011e4:	6a 00                	push   $0x0
f01011e6:	e8 2f fc ff ff       	call   f0100e1a <page_alloc>
f01011eb:	89 c7                	mov    %eax,%edi
f01011ed:	83 c4 10             	add    $0x10,%esp
f01011f0:	85 c0                	test   %eax,%eax
f01011f2:	75 19                	jne    f010120d <mem_init+0x338>
f01011f4:	68 cb 2d 10 f0       	push   $0xf0102dcb
f01011f9:	68 da 2c 10 f0       	push   $0xf0102cda
f01011fe:	68 4b 02 00 00       	push   $0x24b
f0101203:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101208:	e8 1a ef ff ff       	call   f0100127 <_panic>
	assert((pp2 = page_alloc(0)));
f010120d:	83 ec 0c             	sub    $0xc,%esp
f0101210:	6a 00                	push   $0x0
f0101212:	e8 03 fc ff ff       	call   f0100e1a <page_alloc>
f0101217:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010121a:	83 c4 10             	add    $0x10,%esp
f010121d:	85 c0                	test   %eax,%eax
f010121f:	75 19                	jne    f010123a <mem_init+0x365>
f0101221:	68 e1 2d 10 f0       	push   $0xf0102de1
f0101226:	68 da 2c 10 f0       	push   $0xf0102cda
f010122b:	68 4c 02 00 00       	push   $0x24c
f0101230:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101235:	e8 ed ee ff ff       	call   f0100127 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010123a:	39 fe                	cmp    %edi,%esi
f010123c:	75 19                	jne    f0101257 <mem_init+0x382>
f010123e:	68 f7 2d 10 f0       	push   $0xf0102df7
f0101243:	68 da 2c 10 f0       	push   $0xf0102cda
f0101248:	68 4e 02 00 00       	push   $0x24e
f010124d:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101252:	e8 d0 ee ff ff       	call   f0100127 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101257:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010125a:	39 c7                	cmp    %eax,%edi
f010125c:	74 04                	je     f0101262 <mem_init+0x38d>
f010125e:	39 c6                	cmp    %eax,%esi
f0101260:	75 19                	jne    f010127b <mem_init+0x3a6>
f0101262:	68 44 2c 10 f0       	push   $0xf0102c44
f0101267:	68 da 2c 10 f0       	push   $0xf0102cda
f010126c:	68 4f 02 00 00       	push   $0x24f
f0101271:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101276:	e8 ac ee ff ff       	call   f0100127 <_panic>
	assert(!page_alloc(0));
f010127b:	83 ec 0c             	sub    $0xc,%esp
f010127e:	6a 00                	push   $0x0
f0101280:	e8 95 fb ff ff       	call   f0100e1a <page_alloc>
f0101285:	83 c4 10             	add    $0x10,%esp
f0101288:	85 c0                	test   %eax,%eax
f010128a:	74 19                	je     f01012a5 <mem_init+0x3d0>
f010128c:	68 60 2e 10 f0       	push   $0xf0102e60
f0101291:	68 da 2c 10 f0       	push   $0xf0102cda
f0101296:	68 50 02 00 00       	push   $0x250
f010129b:	68 b4 2c 10 f0       	push   $0xf0102cb4
f01012a0:	e8 82 ee ff ff       	call   f0100127 <_panic>
f01012a5:	89 f0                	mov    %esi,%eax
f01012a7:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f01012ad:	c1 f8 03             	sar    $0x3,%eax
f01012b0:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01012b3:	89 c2                	mov    %eax,%edx
f01012b5:	c1 ea 0c             	shr    $0xc,%edx
f01012b8:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f01012be:	72 12                	jb     f01012d2 <mem_init+0x3fd>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01012c0:	50                   	push   %eax
f01012c1:	68 a4 2a 10 f0       	push   $0xf0102aa4
f01012c6:	6a 52                	push   $0x52
f01012c8:	68 c0 2c 10 f0       	push   $0xf0102cc0
f01012cd:	e8 55 ee ff ff       	call   f0100127 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01012d2:	83 ec 04             	sub    $0x4,%esp
f01012d5:	68 00 10 00 00       	push   $0x1000
f01012da:	6a 01                	push   $0x1
f01012dc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01012e1:	50                   	push   %eax
f01012e2:	e8 a0 0d 00 00       	call   f0102087 <memset>
	page_free(pp0);
f01012e7:	89 34 24             	mov    %esi,(%esp)
f01012ea:	e8 ab fb ff ff       	call   f0100e9a <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01012ef:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01012f6:	e8 1f fb ff ff       	call   f0100e1a <page_alloc>
f01012fb:	83 c4 10             	add    $0x10,%esp
f01012fe:	85 c0                	test   %eax,%eax
f0101300:	75 19                	jne    f010131b <mem_init+0x446>
f0101302:	68 6f 2e 10 f0       	push   $0xf0102e6f
f0101307:	68 da 2c 10 f0       	push   $0xf0102cda
f010130c:	68 55 02 00 00       	push   $0x255
f0101311:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101316:	e8 0c ee ff ff       	call   f0100127 <_panic>
	assert(pp && pp0 == pp);
f010131b:	39 c6                	cmp    %eax,%esi
f010131d:	74 19                	je     f0101338 <mem_init+0x463>
f010131f:	68 8d 2e 10 f0       	push   $0xf0102e8d
f0101324:	68 da 2c 10 f0       	push   $0xf0102cda
f0101329:	68 56 02 00 00       	push   $0x256
f010132e:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101333:	e8 ef ed ff ff       	call   f0100127 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101338:	89 f0                	mov    %esi,%eax
f010133a:	2b 05 6c 49 11 f0    	sub    0xf011496c,%eax
f0101340:	c1 f8 03             	sar    $0x3,%eax
f0101343:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101346:	89 c2                	mov    %eax,%edx
f0101348:	c1 ea 0c             	shr    $0xc,%edx
f010134b:	3b 15 64 49 11 f0    	cmp    0xf0114964,%edx
f0101351:	72 12                	jb     f0101365 <mem_init+0x490>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101353:	50                   	push   %eax
f0101354:	68 a4 2a 10 f0       	push   $0xf0102aa4
f0101359:	6a 52                	push   $0x52
f010135b:	68 c0 2c 10 f0       	push   $0xf0102cc0
f0101360:	e8 c2 ed ff ff       	call   f0100127 <_panic>
f0101365:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010136b:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101371:	80 38 00             	cmpb   $0x0,(%eax)
f0101374:	74 19                	je     f010138f <mem_init+0x4ba>
f0101376:	68 9d 2e 10 f0       	push   $0xf0102e9d
f010137b:	68 da 2c 10 f0       	push   $0xf0102cda
f0101380:	68 59 02 00 00       	push   $0x259
f0101385:	68 b4 2c 10 f0       	push   $0xf0102cb4
f010138a:	e8 98 ed ff ff       	call   f0100127 <_panic>
f010138f:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101392:	39 d0                	cmp    %edx,%eax
f0101394:	75 db                	jne    f0101371 <mem_init+0x49c>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101396:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101399:	a3 3c 45 11 f0       	mov    %eax,0xf011453c

	// free the pages we took
	page_free(pp0);
f010139e:	83 ec 0c             	sub    $0xc,%esp
f01013a1:	56                   	push   %esi
f01013a2:	e8 f3 fa ff ff       	call   f0100e9a <page_free>
	page_free(pp1);
f01013a7:	89 3c 24             	mov    %edi,(%esp)
f01013aa:	e8 eb fa ff ff       	call   f0100e9a <page_free>
	page_free(pp2);
f01013af:	83 c4 04             	add    $0x4,%esp
f01013b2:	ff 75 e4             	pushl  -0x1c(%ebp)
f01013b5:	e8 e0 fa ff ff       	call   f0100e9a <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013ba:	a1 3c 45 11 f0       	mov    0xf011453c,%eax
f01013bf:	83 c4 10             	add    $0x10,%esp
f01013c2:	eb 05                	jmp    f01013c9 <mem_init+0x4f4>
		--nfree;
f01013c4:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01013c7:	8b 00                	mov    (%eax),%eax
f01013c9:	85 c0                	test   %eax,%eax
f01013cb:	75 f7                	jne    f01013c4 <mem_init+0x4ef>
		--nfree;
	assert(nfree == 0);
f01013cd:	85 db                	test   %ebx,%ebx
f01013cf:	74 19                	je     f01013ea <mem_init+0x515>
f01013d1:	68 a7 2e 10 f0       	push   $0xf0102ea7
f01013d6:	68 da 2c 10 f0       	push   $0xf0102cda
f01013db:	68 66 02 00 00       	push   $0x266
f01013e0:	68 b4 2c 10 f0       	push   $0xf0102cb4
f01013e5:	e8 3d ed ff ff       	call   f0100127 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01013ea:	83 ec 0c             	sub    $0xc,%esp
f01013ed:	68 64 2c 10 f0       	push   $0xf0102c64
f01013f2:	e8 d7 01 00 00       	call   f01015ce <cprintf>
	page_init();

	check_page_free_list(1);
	cprintf("Entering check_page_alloc\n");
	check_page_alloc();
	cprintf("Exited check_page_alloc\n");
f01013f7:	c7 04 24 b2 2e 10 f0 	movl   $0xf0102eb2,(%esp)
f01013fe:	e8 cb 01 00 00       	call   f01015ce <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101403:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010140a:	e8 0b fa ff ff       	call   f0100e1a <page_alloc>
f010140f:	89 c3                	mov    %eax,%ebx
f0101411:	83 c4 10             	add    $0x10,%esp
f0101414:	85 c0                	test   %eax,%eax
f0101416:	75 19                	jne    f0101431 <mem_init+0x55c>
f0101418:	68 b5 2d 10 f0       	push   $0xf0102db5
f010141d:	68 da 2c 10 f0       	push   $0xf0102cda
f0101422:	68 bf 02 00 00       	push   $0x2bf
f0101427:	68 b4 2c 10 f0       	push   $0xf0102cb4
f010142c:	e8 f6 ec ff ff       	call   f0100127 <_panic>
	assert((pp1 = page_alloc(0)));
f0101431:	83 ec 0c             	sub    $0xc,%esp
f0101434:	6a 00                	push   $0x0
f0101436:	e8 df f9 ff ff       	call   f0100e1a <page_alloc>
f010143b:	89 c6                	mov    %eax,%esi
f010143d:	83 c4 10             	add    $0x10,%esp
f0101440:	85 c0                	test   %eax,%eax
f0101442:	75 19                	jne    f010145d <mem_init+0x588>
f0101444:	68 cb 2d 10 f0       	push   $0xf0102dcb
f0101449:	68 da 2c 10 f0       	push   $0xf0102cda
f010144e:	68 c0 02 00 00       	push   $0x2c0
f0101453:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101458:	e8 ca ec ff ff       	call   f0100127 <_panic>
	assert((pp2 = page_alloc(0)));
f010145d:	83 ec 0c             	sub    $0xc,%esp
f0101460:	6a 00                	push   $0x0
f0101462:	e8 b3 f9 ff ff       	call   f0100e1a <page_alloc>
f0101467:	83 c4 10             	add    $0x10,%esp
f010146a:	85 c0                	test   %eax,%eax
f010146c:	75 19                	jne    f0101487 <mem_init+0x5b2>
f010146e:	68 e1 2d 10 f0       	push   $0xf0102de1
f0101473:	68 da 2c 10 f0       	push   $0xf0102cda
f0101478:	68 c1 02 00 00       	push   $0x2c1
f010147d:	68 b4 2c 10 f0       	push   $0xf0102cb4
f0101482:	e8 a0 ec ff ff       	call   f0100127 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101487:	39 f3                	cmp    %esi,%ebx
f0101489:	75 19                	jne    f01014a4 <mem_init+0x5cf>
f010148b:	68 f7 2d 10 f0       	push   $0xf0102df7
f0101490:	68 da 2c 10 f0       	push   $0xf0102cda
f0101495:	68 c4 02 00 00       	push   $0x2c4
f010149a:	68 b4 2c 10 f0       	push   $0xf0102cb4
f010149f:	e8 83 ec ff ff       	call   f0100127 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01014a4:	39 c6                	cmp    %eax,%esi
f01014a6:	74 04                	je     f01014ac <mem_init+0x5d7>
f01014a8:	39 c3                	cmp    %eax,%ebx
f01014aa:	75 19                	jne    f01014c5 <mem_init+0x5f0>
f01014ac:	68 44 2c 10 f0       	push   $0xf0102c44
f01014b1:	68 da 2c 10 f0       	push   $0xf0102cda
f01014b6:	68 c5 02 00 00       	push   $0x2c5
f01014bb:	68 b4 2c 10 f0       	push   $0xf0102cb4
f01014c0:	e8 62 ec ff ff       	call   f0100127 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
	page_free_list = 0;
f01014c5:	c7 05 3c 45 11 f0 00 	movl   $0x0,0xf011453c
f01014cc:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01014cf:	83 ec 0c             	sub    $0xc,%esp
f01014d2:	6a 00                	push   $0x0
f01014d4:	e8 41 f9 ff ff       	call   f0100e1a <page_alloc>
f01014d9:	83 c4 10             	add    $0x10,%esp
f01014dc:	85 c0                	test   %eax,%eax
f01014de:	74 19                	je     f01014f9 <mem_init+0x624>
f01014e0:	68 60 2e 10 f0       	push   $0xf0102e60
f01014e5:	68 da 2c 10 f0       	push   $0xf0102cda
f01014ea:	68 cc 02 00 00       	push   $0x2cc
f01014ef:	68 b4 2c 10 f0       	push   $0xf0102cb4
f01014f4:	e8 2e ec ff ff       	call   f0100127 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01014f9:	68 84 2c 10 f0       	push   $0xf0102c84
f01014fe:	68 da 2c 10 f0       	push   $0xf0102cda
f0101503:	68 d2 02 00 00       	push   $0x2d2
f0101508:	68 b4 2c 10 f0       	push   $0xf0102cb4
f010150d:	e8 15 ec ff ff       	call   f0100127 <_panic>

f0101512 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0101512:	55                   	push   %ebp
f0101513:	89 e5                	mov    %esp,%ebp
f0101515:	83 ec 08             	sub    $0x8,%esp
f0101518:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f010151b:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f010151f:	83 e8 01             	sub    $0x1,%eax
f0101522:	66 89 42 04          	mov    %ax,0x4(%edx)
f0101526:	66 85 c0             	test   %ax,%ax
f0101529:	75 0c                	jne    f0101537 <page_decref+0x25>
		page_free(pp);
f010152b:	83 ec 0c             	sub    $0xc,%esp
f010152e:	52                   	push   %edx
f010152f:	e8 66 f9 ff ff       	call   f0100e9a <page_free>
f0101534:	83 c4 10             	add    $0x10,%esp
}
f0101537:	c9                   	leave  
f0101538:	c3                   	ret    

f0101539 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0101539:	55                   	push   %ebp
f010153a:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f010153c:	b8 00 00 00 00       	mov    $0x0,%eax
f0101541:	5d                   	pop    %ebp
f0101542:	c3                   	ret    

f0101543 <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101543:	55                   	push   %ebp
f0101544:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return 0;
}
f0101546:	b8 00 00 00 00       	mov    $0x0,%eax
f010154b:	5d                   	pop    %ebp
f010154c:	c3                   	ret    

f010154d <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010154d:	55                   	push   %ebp
f010154e:	89 e5                	mov    %esp,%ebp
	// Fill this function in
	return NULL;
}
f0101550:	b8 00 00 00 00       	mov    $0x0,%eax
f0101555:	5d                   	pop    %ebp
f0101556:	c3                   	ret    

f0101557 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101557:	55                   	push   %ebp
f0101558:	89 e5                	mov    %esp,%ebp
	// Fill this function in
}
f010155a:	5d                   	pop    %ebp
f010155b:	c3                   	ret    

f010155c <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f010155c:	55                   	push   %ebp
f010155d:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010155f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101562:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0101565:	5d                   	pop    %ebp
f0101566:	c3                   	ret    

f0101567 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0101567:	55                   	push   %ebp
f0101568:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010156a:	ba 70 00 00 00       	mov    $0x70,%edx
f010156f:	8b 45 08             	mov    0x8(%ebp),%eax
f0101572:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0101573:	ba 71 00 00 00       	mov    $0x71,%edx
f0101578:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0101579:	0f b6 c0             	movzbl %al,%eax
}
f010157c:	5d                   	pop    %ebp
f010157d:	c3                   	ret    

f010157e <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010157e:	55                   	push   %ebp
f010157f:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0101581:	ba 70 00 00 00       	mov    $0x70,%edx
f0101586:	8b 45 08             	mov    0x8(%ebp),%eax
f0101589:	ee                   	out    %al,(%dx)
f010158a:	ba 71 00 00 00       	mov    $0x71,%edx
f010158f:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101592:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0101593:	5d                   	pop    %ebp
f0101594:	c3                   	ret    

f0101595 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0101595:	55                   	push   %ebp
f0101596:	89 e5                	mov    %esp,%ebp
f0101598:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010159b:	ff 75 08             	pushl  0x8(%ebp)
f010159e:	e8 f9 f0 ff ff       	call   f010069c <cputchar>
	*cnt++;
}
f01015a3:	83 c4 10             	add    $0x10,%esp
f01015a6:	c9                   	leave  
f01015a7:	c3                   	ret    

f01015a8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f01015a8:	55                   	push   %ebp
f01015a9:	89 e5                	mov    %esp,%ebp
f01015ab:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f01015ae:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f01015b5:	ff 75 0c             	pushl  0xc(%ebp)
f01015b8:	ff 75 08             	pushl  0x8(%ebp)
f01015bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01015be:	50                   	push   %eax
f01015bf:	68 95 15 10 f0       	push   $0xf0101595
f01015c4:	e8 52 04 00 00       	call   f0101a1b <vprintfmt>
	return cnt;
}
f01015c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01015cc:	c9                   	leave  
f01015cd:	c3                   	ret    

f01015ce <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01015ce:	55                   	push   %ebp
f01015cf:	89 e5                	mov    %esp,%ebp
f01015d1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01015d4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01015d7:	50                   	push   %eax
f01015d8:	ff 75 08             	pushl  0x8(%ebp)
f01015db:	e8 c8 ff ff ff       	call   f01015a8 <vcprintf>
	va_end(ap);

	return cnt;
}
f01015e0:	c9                   	leave  
f01015e1:	c3                   	ret    

f01015e2 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01015e2:	55                   	push   %ebp
f01015e3:	89 e5                	mov    %esp,%ebp
f01015e5:	57                   	push   %edi
f01015e6:	56                   	push   %esi
f01015e7:	53                   	push   %ebx
f01015e8:	83 ec 14             	sub    $0x14,%esp
f01015eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01015ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01015f1:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01015f4:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01015f7:	8b 1a                	mov    (%edx),%ebx
f01015f9:	8b 01                	mov    (%ecx),%eax
f01015fb:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01015fe:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f0101605:	eb 7f                	jmp    f0101686 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f0101607:	8b 45 f0             	mov    -0x10(%ebp),%eax
f010160a:	01 d8                	add    %ebx,%eax
f010160c:	89 c6                	mov    %eax,%esi
f010160e:	c1 ee 1f             	shr    $0x1f,%esi
f0101611:	01 c6                	add    %eax,%esi
f0101613:	d1 fe                	sar    %esi
f0101615:	8d 04 76             	lea    (%esi,%esi,2),%eax
f0101618:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f010161b:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010161e:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101620:	eb 03                	jmp    f0101625 <stab_binsearch+0x43>
			m--;
f0101622:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0101625:	39 c3                	cmp    %eax,%ebx
f0101627:	7f 0d                	jg     f0101636 <stab_binsearch+0x54>
f0101629:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f010162d:	83 ea 0c             	sub    $0xc,%edx
f0101630:	39 f9                	cmp    %edi,%ecx
f0101632:	75 ee                	jne    f0101622 <stab_binsearch+0x40>
f0101634:	eb 05                	jmp    f010163b <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0101636:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0101639:	eb 4b                	jmp    f0101686 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f010163b:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010163e:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0101641:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0101645:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0101648:	76 11                	jbe    f010165b <stab_binsearch+0x79>
			*region_left = m;
f010164a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f010164d:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010164f:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0101652:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0101659:	eb 2b                	jmp    f0101686 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f010165b:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010165e:	73 14                	jae    f0101674 <stab_binsearch+0x92>
			*region_right = m - 1;
f0101660:	83 e8 01             	sub    $0x1,%eax
f0101663:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0101666:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0101669:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010166b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0101672:	eb 12                	jmp    f0101686 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0101674:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101677:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0101679:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010167d:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010167f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0101686:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0101689:	0f 8e 78 ff ff ff    	jle    f0101607 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010168f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0101693:	75 0f                	jne    f01016a4 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0101695:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0101698:	8b 00                	mov    (%eax),%eax
f010169a:	83 e8 01             	sub    $0x1,%eax
f010169d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01016a0:	89 06                	mov    %eax,(%esi)
f01016a2:	eb 2c                	jmp    f01016d0 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01016a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01016a7:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f01016a9:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01016ac:	8b 0e                	mov    (%esi),%ecx
f01016ae:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01016b1:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01016b4:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01016b7:	eb 03                	jmp    f01016bc <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01016b9:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01016bc:	39 c8                	cmp    %ecx,%eax
f01016be:	7e 0b                	jle    f01016cb <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01016c0:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01016c4:	83 ea 0c             	sub    $0xc,%edx
f01016c7:	39 df                	cmp    %ebx,%edi
f01016c9:	75 ee                	jne    f01016b9 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01016cb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01016ce:	89 06                	mov    %eax,(%esi)
	}
}
f01016d0:	83 c4 14             	add    $0x14,%esp
f01016d3:	5b                   	pop    %ebx
f01016d4:	5e                   	pop    %esi
f01016d5:	5f                   	pop    %edi
f01016d6:	5d                   	pop    %ebp
f01016d7:	c3                   	ret    

f01016d8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01016d8:	55                   	push   %ebp
f01016d9:	89 e5                	mov    %esp,%ebp
f01016db:	57                   	push   %edi
f01016dc:	56                   	push   %esi
f01016dd:	53                   	push   %ebx
f01016de:	83 ec 3c             	sub    $0x3c,%esp
f01016e1:	8b 75 08             	mov    0x8(%ebp),%esi
f01016e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01016e7:	c7 03 cb 2e 10 f0    	movl   $0xf0102ecb,(%ebx)
	info->eip_line = 0;
f01016ed:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01016f4:	c7 43 08 cb 2e 10 f0 	movl   $0xf0102ecb,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01016fb:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0101702:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0101705:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f010170c:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0101712:	76 11                	jbe    f0101725 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101714:	b8 7a 9b 10 f0       	mov    $0xf0109b7a,%eax
f0101719:	3d 05 7e 10 f0       	cmp    $0xf0107e05,%eax
f010171e:	77 19                	ja     f0101739 <debuginfo_eip+0x61>
f0101720:	e9 aa 01 00 00       	jmp    f01018cf <debuginfo_eip+0x1f7>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f0101725:	83 ec 04             	sub    $0x4,%esp
f0101728:	68 d5 2e 10 f0       	push   $0xf0102ed5
f010172d:	6a 7f                	push   $0x7f
f010172f:	68 e2 2e 10 f0       	push   $0xf0102ee2
f0101734:	e8 ee e9 ff ff       	call   f0100127 <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0101739:	80 3d 79 9b 10 f0 00 	cmpb   $0x0,0xf0109b79
f0101740:	0f 85 90 01 00 00    	jne    f01018d6 <debuginfo_eip+0x1fe>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0101746:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f010174d:	b8 04 7e 10 f0       	mov    $0xf0107e04,%eax
f0101752:	2d 00 31 10 f0       	sub    $0xf0103100,%eax
f0101757:	c1 f8 02             	sar    $0x2,%eax
f010175a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0101760:	83 e8 01             	sub    $0x1,%eax
f0101763:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0101766:	83 ec 08             	sub    $0x8,%esp
f0101769:	56                   	push   %esi
f010176a:	6a 64                	push   $0x64
f010176c:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010176f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0101772:	b8 00 31 10 f0       	mov    $0xf0103100,%eax
f0101777:	e8 66 fe ff ff       	call   f01015e2 <stab_binsearch>
	if (lfile == 0)
f010177c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010177f:	83 c4 10             	add    $0x10,%esp
f0101782:	85 c0                	test   %eax,%eax
f0101784:	0f 84 53 01 00 00    	je     f01018dd <debuginfo_eip+0x205>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010178a:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010178d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101790:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0101793:	83 ec 08             	sub    $0x8,%esp
f0101796:	56                   	push   %esi
f0101797:	6a 24                	push   $0x24
f0101799:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010179c:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010179f:	b8 00 31 10 f0       	mov    $0xf0103100,%eax
f01017a4:	e8 39 fe ff ff       	call   f01015e2 <stab_binsearch>

	if (lfun <= rfun) {
f01017a9:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01017ac:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01017af:	83 c4 10             	add    $0x10,%esp
f01017b2:	39 d0                	cmp    %edx,%eax
f01017b4:	7f 40                	jg     f01017f6 <debuginfo_eip+0x11e>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01017b6:	8d 0c 40             	lea    (%eax,%eax,2),%ecx
f01017b9:	c1 e1 02             	shl    $0x2,%ecx
f01017bc:	8d b9 00 31 10 f0    	lea    -0xfefcf00(%ecx),%edi
f01017c2:	89 7d c4             	mov    %edi,-0x3c(%ebp)
f01017c5:	8b b9 00 31 10 f0    	mov    -0xfefcf00(%ecx),%edi
f01017cb:	b9 7a 9b 10 f0       	mov    $0xf0109b7a,%ecx
f01017d0:	81 e9 05 7e 10 f0    	sub    $0xf0107e05,%ecx
f01017d6:	39 cf                	cmp    %ecx,%edi
f01017d8:	73 09                	jae    f01017e3 <debuginfo_eip+0x10b>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01017da:	81 c7 05 7e 10 f0    	add    $0xf0107e05,%edi
f01017e0:	89 7b 08             	mov    %edi,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f01017e3:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f01017e6:	8b 4f 08             	mov    0x8(%edi),%ecx
f01017e9:	89 4b 10             	mov    %ecx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f01017ec:	29 ce                	sub    %ecx,%esi
		// Search within the function definition for the line number.
		lline = lfun;
f01017ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f01017f1:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01017f4:	eb 0f                	jmp    f0101805 <debuginfo_eip+0x12d>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01017f6:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f01017f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01017fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f01017ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101802:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0101805:	83 ec 08             	sub    $0x8,%esp
f0101808:	6a 3a                	push   $0x3a
f010180a:	ff 73 08             	pushl  0x8(%ebx)
f010180d:	e8 59 08 00 00       	call   f010206b <strfind>
f0101812:	2b 43 08             	sub    0x8(%ebx),%eax
f0101815:	89 43 0c             	mov    %eax,0xc(%ebx)
	//
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0101818:	83 c4 08             	add    $0x8,%esp
f010181b:	56                   	push   %esi
f010181c:	6a 44                	push   $0x44
f010181e:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0101821:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0101824:	b8 00 31 10 f0       	mov    $0xf0103100,%eax
f0101829:	e8 b4 fd ff ff       	call   f01015e2 <stab_binsearch>
	if (lline <= rline) {
f010182e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101831:	83 c4 10             	add    $0x10,%esp
f0101834:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0101837:	0f 8f a7 00 00 00    	jg     f01018e4 <debuginfo_eip+0x20c>
		info->eip_line = stabs[lline].n_desc;
f010183d:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101840:	8d 04 85 00 31 10 f0 	lea    -0xfefcf00(,%eax,4),%eax
f0101847:	0f b7 48 06          	movzwl 0x6(%eax),%ecx
f010184b:	89 4b 04             	mov    %ecx,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010184e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0101851:	eb 06                	jmp    f0101859 <debuginfo_eip+0x181>
f0101853:	83 ea 01             	sub    $0x1,%edx
f0101856:	83 e8 0c             	sub    $0xc,%eax
f0101859:	39 d6                	cmp    %edx,%esi
f010185b:	7f 34                	jg     f0101891 <debuginfo_eip+0x1b9>
	       && stabs[lline].n_type != N_SOL
f010185d:	0f b6 48 04          	movzbl 0x4(%eax),%ecx
f0101861:	80 f9 84             	cmp    $0x84,%cl
f0101864:	74 0b                	je     f0101871 <debuginfo_eip+0x199>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0101866:	80 f9 64             	cmp    $0x64,%cl
f0101869:	75 e8                	jne    f0101853 <debuginfo_eip+0x17b>
f010186b:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f010186f:	74 e2                	je     f0101853 <debuginfo_eip+0x17b>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0101871:	8d 04 52             	lea    (%edx,%edx,2),%eax
f0101874:	8b 14 85 00 31 10 f0 	mov    -0xfefcf00(,%eax,4),%edx
f010187b:	b8 7a 9b 10 f0       	mov    $0xf0109b7a,%eax
f0101880:	2d 05 7e 10 f0       	sub    $0xf0107e05,%eax
f0101885:	39 c2                	cmp    %eax,%edx
f0101887:	73 08                	jae    f0101891 <debuginfo_eip+0x1b9>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0101889:	81 c2 05 7e 10 f0    	add    $0xf0107e05,%edx
f010188f:	89 13                	mov    %edx,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0101891:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101894:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0101897:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010189c:	39 f2                	cmp    %esi,%edx
f010189e:	7d 50                	jge    f01018f0 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
f01018a0:	83 c2 01             	add    $0x1,%edx
f01018a3:	89 d0                	mov    %edx,%eax
f01018a5:	8d 14 52             	lea    (%edx,%edx,2),%edx
f01018a8:	8d 14 95 00 31 10 f0 	lea    -0xfefcf00(,%edx,4),%edx
f01018af:	eb 04                	jmp    f01018b5 <debuginfo_eip+0x1dd>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01018b1:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01018b5:	39 c6                	cmp    %eax,%esi
f01018b7:	7e 32                	jle    f01018eb <debuginfo_eip+0x213>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01018b9:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01018bd:	83 c0 01             	add    $0x1,%eax
f01018c0:	83 c2 0c             	add    $0xc,%edx
f01018c3:	80 f9 a0             	cmp    $0xa0,%cl
f01018c6:	74 e9                	je     f01018b1 <debuginfo_eip+0x1d9>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01018c8:	b8 00 00 00 00       	mov    $0x0,%eax
f01018cd:	eb 21                	jmp    f01018f0 <debuginfo_eip+0x218>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01018cf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01018d4:	eb 1a                	jmp    f01018f0 <debuginfo_eip+0x218>
f01018d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01018db:	eb 13                	jmp    f01018f0 <debuginfo_eip+0x218>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01018dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01018e2:	eb 0c                	jmp    f01018f0 <debuginfo_eip+0x218>
	//	which one.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline <= rline) {
		info->eip_line = stabs[lline].n_desc;
	} else {
		return -1;
f01018e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01018e9:	eb 05                	jmp    f01018f0 <debuginfo_eip+0x218>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01018eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01018f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01018f3:	5b                   	pop    %ebx
f01018f4:	5e                   	pop    %esi
f01018f5:	5f                   	pop    %edi
f01018f6:	5d                   	pop    %ebp
f01018f7:	c3                   	ret    

f01018f8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f01018f8:	55                   	push   %ebp
f01018f9:	89 e5                	mov    %esp,%ebp
f01018fb:	57                   	push   %edi
f01018fc:	56                   	push   %esi
f01018fd:	53                   	push   %ebx
f01018fe:	83 ec 1c             	sub    $0x1c,%esp
f0101901:	89 c7                	mov    %eax,%edi
f0101903:	89 d6                	mov    %edx,%esi
f0101905:	8b 45 08             	mov    0x8(%ebp),%eax
f0101908:	8b 55 0c             	mov    0xc(%ebp),%edx
f010190b:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010190e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0101911:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0101914:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101919:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010191c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010191f:	39 d3                	cmp    %edx,%ebx
f0101921:	72 05                	jb     f0101928 <printnum+0x30>
f0101923:	39 45 10             	cmp    %eax,0x10(%ebp)
f0101926:	77 45                	ja     f010196d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0101928:	83 ec 0c             	sub    $0xc,%esp
f010192b:	ff 75 18             	pushl  0x18(%ebp)
f010192e:	8b 45 14             	mov    0x14(%ebp),%eax
f0101931:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0101934:	53                   	push   %ebx
f0101935:	ff 75 10             	pushl  0x10(%ebp)
f0101938:	83 ec 08             	sub    $0x8,%esp
f010193b:	ff 75 e4             	pushl  -0x1c(%ebp)
f010193e:	ff 75 e0             	pushl  -0x20(%ebp)
f0101941:	ff 75 dc             	pushl  -0x24(%ebp)
f0101944:	ff 75 d8             	pushl  -0x28(%ebp)
f0101947:	e8 44 09 00 00       	call   f0102290 <__udivdi3>
f010194c:	83 c4 18             	add    $0x18,%esp
f010194f:	52                   	push   %edx
f0101950:	50                   	push   %eax
f0101951:	89 f2                	mov    %esi,%edx
f0101953:	89 f8                	mov    %edi,%eax
f0101955:	e8 9e ff ff ff       	call   f01018f8 <printnum>
f010195a:	83 c4 20             	add    $0x20,%esp
f010195d:	eb 18                	jmp    f0101977 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f010195f:	83 ec 08             	sub    $0x8,%esp
f0101962:	56                   	push   %esi
f0101963:	ff 75 18             	pushl  0x18(%ebp)
f0101966:	ff d7                	call   *%edi
f0101968:	83 c4 10             	add    $0x10,%esp
f010196b:	eb 03                	jmp    f0101970 <printnum+0x78>
f010196d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0101970:	83 eb 01             	sub    $0x1,%ebx
f0101973:	85 db                	test   %ebx,%ebx
f0101975:	7f e8                	jg     f010195f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0101977:	83 ec 08             	sub    $0x8,%esp
f010197a:	56                   	push   %esi
f010197b:	83 ec 04             	sub    $0x4,%esp
f010197e:	ff 75 e4             	pushl  -0x1c(%ebp)
f0101981:	ff 75 e0             	pushl  -0x20(%ebp)
f0101984:	ff 75 dc             	pushl  -0x24(%ebp)
f0101987:	ff 75 d8             	pushl  -0x28(%ebp)
f010198a:	e8 31 0a 00 00       	call   f01023c0 <__umoddi3>
f010198f:	83 c4 14             	add    $0x14,%esp
f0101992:	0f be 80 f0 2e 10 f0 	movsbl -0xfefd110(%eax),%eax
f0101999:	50                   	push   %eax
f010199a:	ff d7                	call   *%edi
}
f010199c:	83 c4 10             	add    $0x10,%esp
f010199f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01019a2:	5b                   	pop    %ebx
f01019a3:	5e                   	pop    %esi
f01019a4:	5f                   	pop    %edi
f01019a5:	5d                   	pop    %ebp
f01019a6:	c3                   	ret    

f01019a7 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01019a7:	55                   	push   %ebp
f01019a8:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f01019aa:	83 fa 01             	cmp    $0x1,%edx
f01019ad:	7e 0e                	jle    f01019bd <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f01019af:	8b 10                	mov    (%eax),%edx
f01019b1:	8d 4a 08             	lea    0x8(%edx),%ecx
f01019b4:	89 08                	mov    %ecx,(%eax)
f01019b6:	8b 02                	mov    (%edx),%eax
f01019b8:	8b 52 04             	mov    0x4(%edx),%edx
f01019bb:	eb 22                	jmp    f01019df <getuint+0x38>
	else if (lflag)
f01019bd:	85 d2                	test   %edx,%edx
f01019bf:	74 10                	je     f01019d1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f01019c1:	8b 10                	mov    (%eax),%edx
f01019c3:	8d 4a 04             	lea    0x4(%edx),%ecx
f01019c6:	89 08                	mov    %ecx,(%eax)
f01019c8:	8b 02                	mov    (%edx),%eax
f01019ca:	ba 00 00 00 00       	mov    $0x0,%edx
f01019cf:	eb 0e                	jmp    f01019df <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f01019d1:	8b 10                	mov    (%eax),%edx
f01019d3:	8d 4a 04             	lea    0x4(%edx),%ecx
f01019d6:	89 08                	mov    %ecx,(%eax)
f01019d8:	8b 02                	mov    (%edx),%eax
f01019da:	ba 00 00 00 00       	mov    $0x0,%edx
}
f01019df:	5d                   	pop    %ebp
f01019e0:	c3                   	ret    

f01019e1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01019e1:	55                   	push   %ebp
f01019e2:	89 e5                	mov    %esp,%ebp
f01019e4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01019e7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01019eb:	8b 10                	mov    (%eax),%edx
f01019ed:	3b 50 04             	cmp    0x4(%eax),%edx
f01019f0:	73 0a                	jae    f01019fc <sprintputch+0x1b>
		*b->buf++ = ch;
f01019f2:	8d 4a 01             	lea    0x1(%edx),%ecx
f01019f5:	89 08                	mov    %ecx,(%eax)
f01019f7:	8b 45 08             	mov    0x8(%ebp),%eax
f01019fa:	88 02                	mov    %al,(%edx)
}
f01019fc:	5d                   	pop    %ebp
f01019fd:	c3                   	ret    

f01019fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01019fe:	55                   	push   %ebp
f01019ff:	89 e5                	mov    %esp,%ebp
f0101a01:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0101a04:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0101a07:	50                   	push   %eax
f0101a08:	ff 75 10             	pushl  0x10(%ebp)
f0101a0b:	ff 75 0c             	pushl  0xc(%ebp)
f0101a0e:	ff 75 08             	pushl  0x8(%ebp)
f0101a11:	e8 05 00 00 00       	call   f0101a1b <vprintfmt>
	va_end(ap);
}
f0101a16:	83 c4 10             	add    $0x10,%esp
f0101a19:	c9                   	leave  
f0101a1a:	c3                   	ret    

f0101a1b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0101a1b:	55                   	push   %ebp
f0101a1c:	89 e5                	mov    %esp,%ebp
f0101a1e:	57                   	push   %edi
f0101a1f:	56                   	push   %esi
f0101a20:	53                   	push   %ebx
f0101a21:	83 ec 2c             	sub    $0x2c,%esp
f0101a24:	8b 75 08             	mov    0x8(%ebp),%esi
f0101a27:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101a2a:	8b 7d 10             	mov    0x10(%ebp),%edi
f0101a2d:	eb 12                	jmp    f0101a41 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0101a2f:	85 c0                	test   %eax,%eax
f0101a31:	0f 84 89 03 00 00    	je     f0101dc0 <vprintfmt+0x3a5>
				return;
			putch(ch, putdat);
f0101a37:	83 ec 08             	sub    $0x8,%esp
f0101a3a:	53                   	push   %ebx
f0101a3b:	50                   	push   %eax
f0101a3c:	ff d6                	call   *%esi
f0101a3e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0101a41:	83 c7 01             	add    $0x1,%edi
f0101a44:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101a48:	83 f8 25             	cmp    $0x25,%eax
f0101a4b:	75 e2                	jne    f0101a2f <vprintfmt+0x14>
f0101a4d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0101a51:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0101a58:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101a5f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0101a66:	ba 00 00 00 00       	mov    $0x0,%edx
f0101a6b:	eb 07                	jmp    f0101a74 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101a6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0101a70:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101a74:	8d 47 01             	lea    0x1(%edi),%eax
f0101a77:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101a7a:	0f b6 07             	movzbl (%edi),%eax
f0101a7d:	0f b6 c8             	movzbl %al,%ecx
f0101a80:	83 e8 23             	sub    $0x23,%eax
f0101a83:	3c 55                	cmp    $0x55,%al
f0101a85:	0f 87 1a 03 00 00    	ja     f0101da5 <vprintfmt+0x38a>
f0101a8b:	0f b6 c0             	movzbl %al,%eax
f0101a8e:	ff 24 85 7c 2f 10 f0 	jmp    *-0xfefd084(,%eax,4)
f0101a95:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0101a98:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0101a9c:	eb d6                	jmp    f0101a74 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101a9e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101aa1:	b8 00 00 00 00       	mov    $0x0,%eax
f0101aa6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0101aa9:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0101aac:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0101ab0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0101ab3:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0101ab6:	83 fa 09             	cmp    $0x9,%edx
f0101ab9:	77 39                	ja     f0101af4 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0101abb:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0101abe:	eb e9                	jmp    f0101aa9 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0101ac0:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ac3:	8d 48 04             	lea    0x4(%eax),%ecx
f0101ac6:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0101ac9:	8b 00                	mov    (%eax),%eax
f0101acb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101ace:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0101ad1:	eb 27                	jmp    f0101afa <vprintfmt+0xdf>
f0101ad3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0101ad6:	85 c0                	test   %eax,%eax
f0101ad8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0101add:	0f 49 c8             	cmovns %eax,%ecx
f0101ae0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101ae3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101ae6:	eb 8c                	jmp    f0101a74 <vprintfmt+0x59>
f0101ae8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0101aeb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0101af2:	eb 80                	jmp    f0101a74 <vprintfmt+0x59>
f0101af4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0101af7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0101afa:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101afe:	0f 89 70 ff ff ff    	jns    f0101a74 <vprintfmt+0x59>
				width = precision, precision = -1;
f0101b04:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101b07:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101b0a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0101b11:	e9 5e ff ff ff       	jmp    f0101a74 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0101b16:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101b19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0101b1c:	e9 53 ff ff ff       	jmp    f0101a74 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0101b21:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b24:	8d 50 04             	lea    0x4(%eax),%edx
f0101b27:	89 55 14             	mov    %edx,0x14(%ebp)
f0101b2a:	83 ec 08             	sub    $0x8,%esp
f0101b2d:	53                   	push   %ebx
f0101b2e:	ff 30                	pushl  (%eax)
f0101b30:	ff d6                	call   *%esi
			break;
f0101b32:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101b35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0101b38:	e9 04 ff ff ff       	jmp    f0101a41 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0101b3d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b40:	8d 50 04             	lea    0x4(%eax),%edx
f0101b43:	89 55 14             	mov    %edx,0x14(%ebp)
f0101b46:	8b 00                	mov    (%eax),%eax
f0101b48:	99                   	cltd   
f0101b49:	31 d0                	xor    %edx,%eax
f0101b4b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0101b4d:	83 f8 06             	cmp    $0x6,%eax
f0101b50:	7f 0b                	jg     f0101b5d <vprintfmt+0x142>
f0101b52:	8b 14 85 d4 30 10 f0 	mov    -0xfefcf2c(,%eax,4),%edx
f0101b59:	85 d2                	test   %edx,%edx
f0101b5b:	75 18                	jne    f0101b75 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
f0101b5d:	50                   	push   %eax
f0101b5e:	68 08 2f 10 f0       	push   $0xf0102f08
f0101b63:	53                   	push   %ebx
f0101b64:	56                   	push   %esi
f0101b65:	e8 94 fe ff ff       	call   f01019fe <printfmt>
f0101b6a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101b6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0101b70:	e9 cc fe ff ff       	jmp    f0101a41 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0101b75:	52                   	push   %edx
f0101b76:	68 ec 2c 10 f0       	push   $0xf0102cec
f0101b7b:	53                   	push   %ebx
f0101b7c:	56                   	push   %esi
f0101b7d:	e8 7c fe ff ff       	call   f01019fe <printfmt>
f0101b82:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101b85:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101b88:	e9 b4 fe ff ff       	jmp    f0101a41 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0101b8d:	8b 45 14             	mov    0x14(%ebp),%eax
f0101b90:	8d 50 04             	lea    0x4(%eax),%edx
f0101b93:	89 55 14             	mov    %edx,0x14(%ebp)
f0101b96:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0101b98:	85 ff                	test   %edi,%edi
f0101b9a:	b8 01 2f 10 f0       	mov    $0xf0102f01,%eax
f0101b9f:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0101ba2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0101ba6:	0f 8e 94 00 00 00    	jle    f0101c40 <vprintfmt+0x225>
f0101bac:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0101bb0:	0f 84 98 00 00 00    	je     f0101c4e <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
f0101bb6:	83 ec 08             	sub    $0x8,%esp
f0101bb9:	ff 75 d0             	pushl  -0x30(%ebp)
f0101bbc:	57                   	push   %edi
f0101bbd:	e8 5f 03 00 00       	call   f0101f21 <strnlen>
f0101bc2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0101bc5:	29 c1                	sub    %eax,%ecx
f0101bc7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0101bca:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0101bcd:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0101bd1:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0101bd4:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0101bd7:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101bd9:	eb 0f                	jmp    f0101bea <vprintfmt+0x1cf>
					putch(padc, putdat);
f0101bdb:	83 ec 08             	sub    $0x8,%esp
f0101bde:	53                   	push   %ebx
f0101bdf:	ff 75 e0             	pushl  -0x20(%ebp)
f0101be2:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0101be4:	83 ef 01             	sub    $0x1,%edi
f0101be7:	83 c4 10             	add    $0x10,%esp
f0101bea:	85 ff                	test   %edi,%edi
f0101bec:	7f ed                	jg     f0101bdb <vprintfmt+0x1c0>
f0101bee:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101bf1:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101bf4:	85 c9                	test   %ecx,%ecx
f0101bf6:	b8 00 00 00 00       	mov    $0x0,%eax
f0101bfb:	0f 49 c1             	cmovns %ecx,%eax
f0101bfe:	29 c1                	sub    %eax,%ecx
f0101c00:	89 75 08             	mov    %esi,0x8(%ebp)
f0101c03:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101c06:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101c09:	89 cb                	mov    %ecx,%ebx
f0101c0b:	eb 4d                	jmp    f0101c5a <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0101c0d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0101c11:	74 1b                	je     f0101c2e <vprintfmt+0x213>
f0101c13:	0f be c0             	movsbl %al,%eax
f0101c16:	83 e8 20             	sub    $0x20,%eax
f0101c19:	83 f8 5e             	cmp    $0x5e,%eax
f0101c1c:	76 10                	jbe    f0101c2e <vprintfmt+0x213>
					putch('?', putdat);
f0101c1e:	83 ec 08             	sub    $0x8,%esp
f0101c21:	ff 75 0c             	pushl  0xc(%ebp)
f0101c24:	6a 3f                	push   $0x3f
f0101c26:	ff 55 08             	call   *0x8(%ebp)
f0101c29:	83 c4 10             	add    $0x10,%esp
f0101c2c:	eb 0d                	jmp    f0101c3b <vprintfmt+0x220>
				else
					putch(ch, putdat);
f0101c2e:	83 ec 08             	sub    $0x8,%esp
f0101c31:	ff 75 0c             	pushl  0xc(%ebp)
f0101c34:	52                   	push   %edx
f0101c35:	ff 55 08             	call   *0x8(%ebp)
f0101c38:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0101c3b:	83 eb 01             	sub    $0x1,%ebx
f0101c3e:	eb 1a                	jmp    f0101c5a <vprintfmt+0x23f>
f0101c40:	89 75 08             	mov    %esi,0x8(%ebp)
f0101c43:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101c46:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101c49:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101c4c:	eb 0c                	jmp    f0101c5a <vprintfmt+0x23f>
f0101c4e:	89 75 08             	mov    %esi,0x8(%ebp)
f0101c51:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0101c54:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0101c57:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0101c5a:	83 c7 01             	add    $0x1,%edi
f0101c5d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0101c61:	0f be d0             	movsbl %al,%edx
f0101c64:	85 d2                	test   %edx,%edx
f0101c66:	74 23                	je     f0101c8b <vprintfmt+0x270>
f0101c68:	85 f6                	test   %esi,%esi
f0101c6a:	78 a1                	js     f0101c0d <vprintfmt+0x1f2>
f0101c6c:	83 ee 01             	sub    $0x1,%esi
f0101c6f:	79 9c                	jns    f0101c0d <vprintfmt+0x1f2>
f0101c71:	89 df                	mov    %ebx,%edi
f0101c73:	8b 75 08             	mov    0x8(%ebp),%esi
f0101c76:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101c79:	eb 18                	jmp    f0101c93 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0101c7b:	83 ec 08             	sub    $0x8,%esp
f0101c7e:	53                   	push   %ebx
f0101c7f:	6a 20                	push   $0x20
f0101c81:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0101c83:	83 ef 01             	sub    $0x1,%edi
f0101c86:	83 c4 10             	add    $0x10,%esp
f0101c89:	eb 08                	jmp    f0101c93 <vprintfmt+0x278>
f0101c8b:	89 df                	mov    %ebx,%edi
f0101c8d:	8b 75 08             	mov    0x8(%ebp),%esi
f0101c90:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101c93:	85 ff                	test   %edi,%edi
f0101c95:	7f e4                	jg     f0101c7b <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101c97:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101c9a:	e9 a2 fd ff ff       	jmp    f0101a41 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0101c9f:	83 fa 01             	cmp    $0x1,%edx
f0101ca2:	7e 16                	jle    f0101cba <vprintfmt+0x29f>
		return va_arg(*ap, long long);
f0101ca4:	8b 45 14             	mov    0x14(%ebp),%eax
f0101ca7:	8d 50 08             	lea    0x8(%eax),%edx
f0101caa:	89 55 14             	mov    %edx,0x14(%ebp)
f0101cad:	8b 50 04             	mov    0x4(%eax),%edx
f0101cb0:	8b 00                	mov    (%eax),%eax
f0101cb2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101cb5:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0101cb8:	eb 32                	jmp    f0101cec <vprintfmt+0x2d1>
	else if (lflag)
f0101cba:	85 d2                	test   %edx,%edx
f0101cbc:	74 18                	je     f0101cd6 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
f0101cbe:	8b 45 14             	mov    0x14(%ebp),%eax
f0101cc1:	8d 50 04             	lea    0x4(%eax),%edx
f0101cc4:	89 55 14             	mov    %edx,0x14(%ebp)
f0101cc7:	8b 00                	mov    (%eax),%eax
f0101cc9:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101ccc:	89 c1                	mov    %eax,%ecx
f0101cce:	c1 f9 1f             	sar    $0x1f,%ecx
f0101cd1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0101cd4:	eb 16                	jmp    f0101cec <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
f0101cd6:	8b 45 14             	mov    0x14(%ebp),%eax
f0101cd9:	8d 50 04             	lea    0x4(%eax),%edx
f0101cdc:	89 55 14             	mov    %edx,0x14(%ebp)
f0101cdf:	8b 00                	mov    (%eax),%eax
f0101ce1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0101ce4:	89 c1                	mov    %eax,%ecx
f0101ce6:	c1 f9 1f             	sar    $0x1f,%ecx
f0101ce9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0101cec:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101cef:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0101cf2:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0101cf7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0101cfb:	79 74                	jns    f0101d71 <vprintfmt+0x356>
				putch('-', putdat);
f0101cfd:	83 ec 08             	sub    $0x8,%esp
f0101d00:	53                   	push   %ebx
f0101d01:	6a 2d                	push   $0x2d
f0101d03:	ff d6                	call   *%esi
				num = -(long long) num;
f0101d05:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0101d08:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0101d0b:	f7 d8                	neg    %eax
f0101d0d:	83 d2 00             	adc    $0x0,%edx
f0101d10:	f7 da                	neg    %edx
f0101d12:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0101d15:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0101d1a:	eb 55                	jmp    f0101d71 <vprintfmt+0x356>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0101d1c:	8d 45 14             	lea    0x14(%ebp),%eax
f0101d1f:	e8 83 fc ff ff       	call   f01019a7 <getuint>
			base = 10;
f0101d24:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f0101d29:	eb 46                	jmp    f0101d71 <vprintfmt+0x356>

		// (unsigned) octal
		case 'o':
			num = getuint(&ap, lflag);
f0101d2b:	8d 45 14             	lea    0x14(%ebp),%eax
f0101d2e:	e8 74 fc ff ff       	call   f01019a7 <getuint>
			base = 8;
f0101d33:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0101d38:	eb 37                	jmp    f0101d71 <vprintfmt+0x356>

		// pointer
		case 'p':
			putch('0', putdat);
f0101d3a:	83 ec 08             	sub    $0x8,%esp
f0101d3d:	53                   	push   %ebx
f0101d3e:	6a 30                	push   $0x30
f0101d40:	ff d6                	call   *%esi
			putch('x', putdat);
f0101d42:	83 c4 08             	add    $0x8,%esp
f0101d45:	53                   	push   %ebx
f0101d46:	6a 78                	push   $0x78
f0101d48:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0101d4a:	8b 45 14             	mov    0x14(%ebp),%eax
f0101d4d:	8d 50 04             	lea    0x4(%eax),%edx
f0101d50:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0101d53:	8b 00                	mov    (%eax),%eax
f0101d55:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0101d5a:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f0101d5d:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0101d62:	eb 0d                	jmp    f0101d71 <vprintfmt+0x356>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0101d64:	8d 45 14             	lea    0x14(%ebp),%eax
f0101d67:	e8 3b fc ff ff       	call   f01019a7 <getuint>
			base = 16;
f0101d6c:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0101d71:	83 ec 0c             	sub    $0xc,%esp
f0101d74:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0101d78:	57                   	push   %edi
f0101d79:	ff 75 e0             	pushl  -0x20(%ebp)
f0101d7c:	51                   	push   %ecx
f0101d7d:	52                   	push   %edx
f0101d7e:	50                   	push   %eax
f0101d7f:	89 da                	mov    %ebx,%edx
f0101d81:	89 f0                	mov    %esi,%eax
f0101d83:	e8 70 fb ff ff       	call   f01018f8 <printnum>
			break;
f0101d88:	83 c4 20             	add    $0x20,%esp
f0101d8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101d8e:	e9 ae fc ff ff       	jmp    f0101a41 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0101d93:	83 ec 08             	sub    $0x8,%esp
f0101d96:	53                   	push   %ebx
f0101d97:	51                   	push   %ecx
f0101d98:	ff d6                	call   *%esi
			break;
f0101d9a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0101d9d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0101da0:	e9 9c fc ff ff       	jmp    f0101a41 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0101da5:	83 ec 08             	sub    $0x8,%esp
f0101da8:	53                   	push   %ebx
f0101da9:	6a 25                	push   $0x25
f0101dab:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0101dad:	83 c4 10             	add    $0x10,%esp
f0101db0:	eb 03                	jmp    f0101db5 <vprintfmt+0x39a>
f0101db2:	83 ef 01             	sub    $0x1,%edi
f0101db5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0101db9:	75 f7                	jne    f0101db2 <vprintfmt+0x397>
f0101dbb:	e9 81 fc ff ff       	jmp    f0101a41 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0101dc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101dc3:	5b                   	pop    %ebx
f0101dc4:	5e                   	pop    %esi
f0101dc5:	5f                   	pop    %edi
f0101dc6:	5d                   	pop    %ebp
f0101dc7:	c3                   	ret    

f0101dc8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0101dc8:	55                   	push   %ebp
f0101dc9:	89 e5                	mov    %esp,%ebp
f0101dcb:	83 ec 18             	sub    $0x18,%esp
f0101dce:	8b 45 08             	mov    0x8(%ebp),%eax
f0101dd1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0101dd4:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0101dd7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0101ddb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0101dde:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0101de5:	85 c0                	test   %eax,%eax
f0101de7:	74 26                	je     f0101e0f <vsnprintf+0x47>
f0101de9:	85 d2                	test   %edx,%edx
f0101deb:	7e 22                	jle    f0101e0f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0101ded:	ff 75 14             	pushl  0x14(%ebp)
f0101df0:	ff 75 10             	pushl  0x10(%ebp)
f0101df3:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0101df6:	50                   	push   %eax
f0101df7:	68 e1 19 10 f0       	push   $0xf01019e1
f0101dfc:	e8 1a fc ff ff       	call   f0101a1b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0101e01:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0101e04:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0101e07:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101e0a:	83 c4 10             	add    $0x10,%esp
f0101e0d:	eb 05                	jmp    f0101e14 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0101e0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0101e14:	c9                   	leave  
f0101e15:	c3                   	ret    

f0101e16 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0101e16:	55                   	push   %ebp
f0101e17:	89 e5                	mov    %esp,%ebp
f0101e19:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0101e1c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0101e1f:	50                   	push   %eax
f0101e20:	ff 75 10             	pushl  0x10(%ebp)
f0101e23:	ff 75 0c             	pushl  0xc(%ebp)
f0101e26:	ff 75 08             	pushl  0x8(%ebp)
f0101e29:	e8 9a ff ff ff       	call   f0101dc8 <vsnprintf>
	va_end(ap);

	return rc;
}
f0101e2e:	c9                   	leave  
f0101e2f:	c3                   	ret    

f0101e30 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0101e30:	55                   	push   %ebp
f0101e31:	89 e5                	mov    %esp,%ebp
f0101e33:	57                   	push   %edi
f0101e34:	56                   	push   %esi
f0101e35:	53                   	push   %ebx
f0101e36:	83 ec 0c             	sub    $0xc,%esp
f0101e39:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0101e3c:	85 c0                	test   %eax,%eax
f0101e3e:	74 11                	je     f0101e51 <readline+0x21>
		cprintf("%s", prompt);
f0101e40:	83 ec 08             	sub    $0x8,%esp
f0101e43:	50                   	push   %eax
f0101e44:	68 ec 2c 10 f0       	push   $0xf0102cec
f0101e49:	e8 80 f7 ff ff       	call   f01015ce <cprintf>
f0101e4e:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0101e51:	83 ec 0c             	sub    $0xc,%esp
f0101e54:	6a 00                	push   $0x0
f0101e56:	e8 62 e8 ff ff       	call   f01006bd <iscons>
f0101e5b:	89 c7                	mov    %eax,%edi
f0101e5d:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0101e60:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0101e65:	e8 42 e8 ff ff       	call   f01006ac <getchar>
f0101e6a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0101e6c:	85 c0                	test   %eax,%eax
f0101e6e:	79 18                	jns    f0101e88 <readline+0x58>
			cprintf("read error: %e\n", c);
f0101e70:	83 ec 08             	sub    $0x8,%esp
f0101e73:	50                   	push   %eax
f0101e74:	68 f0 30 10 f0       	push   $0xf01030f0
f0101e79:	e8 50 f7 ff ff       	call   f01015ce <cprintf>
			return NULL;
f0101e7e:	83 c4 10             	add    $0x10,%esp
f0101e81:	b8 00 00 00 00       	mov    $0x0,%eax
f0101e86:	eb 79                	jmp    f0101f01 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0101e88:	83 f8 08             	cmp    $0x8,%eax
f0101e8b:	0f 94 c2             	sete   %dl
f0101e8e:	83 f8 7f             	cmp    $0x7f,%eax
f0101e91:	0f 94 c0             	sete   %al
f0101e94:	08 c2                	or     %al,%dl
f0101e96:	74 1a                	je     f0101eb2 <readline+0x82>
f0101e98:	85 f6                	test   %esi,%esi
f0101e9a:	7e 16                	jle    f0101eb2 <readline+0x82>
			if (echoing)
f0101e9c:	85 ff                	test   %edi,%edi
f0101e9e:	74 0d                	je     f0101ead <readline+0x7d>
				cputchar('\b');
f0101ea0:	83 ec 0c             	sub    $0xc,%esp
f0101ea3:	6a 08                	push   $0x8
f0101ea5:	e8 f2 e7 ff ff       	call   f010069c <cputchar>
f0101eaa:	83 c4 10             	add    $0x10,%esp
			i--;
f0101ead:	83 ee 01             	sub    $0x1,%esi
f0101eb0:	eb b3                	jmp    f0101e65 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0101eb2:	83 fb 1f             	cmp    $0x1f,%ebx
f0101eb5:	7e 23                	jle    f0101eda <readline+0xaa>
f0101eb7:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0101ebd:	7f 1b                	jg     f0101eda <readline+0xaa>
			if (echoing)
f0101ebf:	85 ff                	test   %edi,%edi
f0101ec1:	74 0c                	je     f0101ecf <readline+0x9f>
				cputchar(c);
f0101ec3:	83 ec 0c             	sub    $0xc,%esp
f0101ec6:	53                   	push   %ebx
f0101ec7:	e8 d0 e7 ff ff       	call   f010069c <cputchar>
f0101ecc:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0101ecf:	88 9e 60 45 11 f0    	mov    %bl,-0xfeebaa0(%esi)
f0101ed5:	8d 76 01             	lea    0x1(%esi),%esi
f0101ed8:	eb 8b                	jmp    f0101e65 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0101eda:	83 fb 0a             	cmp    $0xa,%ebx
f0101edd:	74 05                	je     f0101ee4 <readline+0xb4>
f0101edf:	83 fb 0d             	cmp    $0xd,%ebx
f0101ee2:	75 81                	jne    f0101e65 <readline+0x35>
			if (echoing)
f0101ee4:	85 ff                	test   %edi,%edi
f0101ee6:	74 0d                	je     f0101ef5 <readline+0xc5>
				cputchar('\n');
f0101ee8:	83 ec 0c             	sub    $0xc,%esp
f0101eeb:	6a 0a                	push   $0xa
f0101eed:	e8 aa e7 ff ff       	call   f010069c <cputchar>
f0101ef2:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0101ef5:	c6 86 60 45 11 f0 00 	movb   $0x0,-0xfeebaa0(%esi)
			return buf;
f0101efc:	b8 60 45 11 f0       	mov    $0xf0114560,%eax
		}
	}
}
f0101f01:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101f04:	5b                   	pop    %ebx
f0101f05:	5e                   	pop    %esi
f0101f06:	5f                   	pop    %edi
f0101f07:	5d                   	pop    %ebp
f0101f08:	c3                   	ret    

f0101f09 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0101f09:	55                   	push   %ebp
f0101f0a:	89 e5                	mov    %esp,%ebp
f0101f0c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0101f0f:	b8 00 00 00 00       	mov    $0x0,%eax
f0101f14:	eb 03                	jmp    f0101f19 <strlen+0x10>
		n++;
f0101f16:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0101f19:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0101f1d:	75 f7                	jne    f0101f16 <strlen+0xd>
		n++;
	return n;
}
f0101f1f:	5d                   	pop    %ebp
f0101f20:	c3                   	ret    

f0101f21 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0101f21:	55                   	push   %ebp
f0101f22:	89 e5                	mov    %esp,%ebp
f0101f24:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101f27:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101f2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f2f:	eb 03                	jmp    f0101f34 <strnlen+0x13>
		n++;
f0101f31:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0101f34:	39 c2                	cmp    %eax,%edx
f0101f36:	74 08                	je     f0101f40 <strnlen+0x1f>
f0101f38:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0101f3c:	75 f3                	jne    f0101f31 <strnlen+0x10>
f0101f3e:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0101f40:	5d                   	pop    %ebp
f0101f41:	c3                   	ret    

f0101f42 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0101f42:	55                   	push   %ebp
f0101f43:	89 e5                	mov    %esp,%ebp
f0101f45:	53                   	push   %ebx
f0101f46:	8b 45 08             	mov    0x8(%ebp),%eax
f0101f49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0101f4c:	89 c2                	mov    %eax,%edx
f0101f4e:	83 c2 01             	add    $0x1,%edx
f0101f51:	83 c1 01             	add    $0x1,%ecx
f0101f54:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0101f58:	88 5a ff             	mov    %bl,-0x1(%edx)
f0101f5b:	84 db                	test   %bl,%bl
f0101f5d:	75 ef                	jne    f0101f4e <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0101f5f:	5b                   	pop    %ebx
f0101f60:	5d                   	pop    %ebp
f0101f61:	c3                   	ret    

f0101f62 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0101f62:	55                   	push   %ebp
f0101f63:	89 e5                	mov    %esp,%ebp
f0101f65:	53                   	push   %ebx
f0101f66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0101f69:	53                   	push   %ebx
f0101f6a:	e8 9a ff ff ff       	call   f0101f09 <strlen>
f0101f6f:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0101f72:	ff 75 0c             	pushl  0xc(%ebp)
f0101f75:	01 d8                	add    %ebx,%eax
f0101f77:	50                   	push   %eax
f0101f78:	e8 c5 ff ff ff       	call   f0101f42 <strcpy>
	return dst;
}
f0101f7d:	89 d8                	mov    %ebx,%eax
f0101f7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101f82:	c9                   	leave  
f0101f83:	c3                   	ret    

f0101f84 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0101f84:	55                   	push   %ebp
f0101f85:	89 e5                	mov    %esp,%ebp
f0101f87:	56                   	push   %esi
f0101f88:	53                   	push   %ebx
f0101f89:	8b 75 08             	mov    0x8(%ebp),%esi
f0101f8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101f8f:	89 f3                	mov    %esi,%ebx
f0101f91:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101f94:	89 f2                	mov    %esi,%edx
f0101f96:	eb 0f                	jmp    f0101fa7 <strncpy+0x23>
		*dst++ = *src;
f0101f98:	83 c2 01             	add    $0x1,%edx
f0101f9b:	0f b6 01             	movzbl (%ecx),%eax
f0101f9e:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0101fa1:	80 39 01             	cmpb   $0x1,(%ecx)
f0101fa4:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0101fa7:	39 da                	cmp    %ebx,%edx
f0101fa9:	75 ed                	jne    f0101f98 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0101fab:	89 f0                	mov    %esi,%eax
f0101fad:	5b                   	pop    %ebx
f0101fae:	5e                   	pop    %esi
f0101faf:	5d                   	pop    %ebp
f0101fb0:	c3                   	ret    

f0101fb1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0101fb1:	55                   	push   %ebp
f0101fb2:	89 e5                	mov    %esp,%ebp
f0101fb4:	56                   	push   %esi
f0101fb5:	53                   	push   %ebx
f0101fb6:	8b 75 08             	mov    0x8(%ebp),%esi
f0101fb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0101fbc:	8b 55 10             	mov    0x10(%ebp),%edx
f0101fbf:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0101fc1:	85 d2                	test   %edx,%edx
f0101fc3:	74 21                	je     f0101fe6 <strlcpy+0x35>
f0101fc5:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0101fc9:	89 f2                	mov    %esi,%edx
f0101fcb:	eb 09                	jmp    f0101fd6 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f0101fcd:	83 c2 01             	add    $0x1,%edx
f0101fd0:	83 c1 01             	add    $0x1,%ecx
f0101fd3:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0101fd6:	39 c2                	cmp    %eax,%edx
f0101fd8:	74 09                	je     f0101fe3 <strlcpy+0x32>
f0101fda:	0f b6 19             	movzbl (%ecx),%ebx
f0101fdd:	84 db                	test   %bl,%bl
f0101fdf:	75 ec                	jne    f0101fcd <strlcpy+0x1c>
f0101fe1:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0101fe3:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f0101fe6:	29 f0                	sub    %esi,%eax
}
f0101fe8:	5b                   	pop    %ebx
f0101fe9:	5e                   	pop    %esi
f0101fea:	5d                   	pop    %ebp
f0101feb:	c3                   	ret    

f0101fec <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0101fec:	55                   	push   %ebp
f0101fed:	89 e5                	mov    %esp,%ebp
f0101fef:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0101ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0101ff5:	eb 06                	jmp    f0101ffd <strcmp+0x11>
		p++, q++;
f0101ff7:	83 c1 01             	add    $0x1,%ecx
f0101ffa:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0101ffd:	0f b6 01             	movzbl (%ecx),%eax
f0102000:	84 c0                	test   %al,%al
f0102002:	74 04                	je     f0102008 <strcmp+0x1c>
f0102004:	3a 02                	cmp    (%edx),%al
f0102006:	74 ef                	je     f0101ff7 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0102008:	0f b6 c0             	movzbl %al,%eax
f010200b:	0f b6 12             	movzbl (%edx),%edx
f010200e:	29 d0                	sub    %edx,%eax
}
f0102010:	5d                   	pop    %ebp
f0102011:	c3                   	ret    

f0102012 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0102012:	55                   	push   %ebp
f0102013:	89 e5                	mov    %esp,%ebp
f0102015:	53                   	push   %ebx
f0102016:	8b 45 08             	mov    0x8(%ebp),%eax
f0102019:	8b 55 0c             	mov    0xc(%ebp),%edx
f010201c:	89 c3                	mov    %eax,%ebx
f010201e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0102021:	eb 06                	jmp    f0102029 <strncmp+0x17>
		n--, p++, q++;
f0102023:	83 c0 01             	add    $0x1,%eax
f0102026:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0102029:	39 d8                	cmp    %ebx,%eax
f010202b:	74 15                	je     f0102042 <strncmp+0x30>
f010202d:	0f b6 08             	movzbl (%eax),%ecx
f0102030:	84 c9                	test   %cl,%cl
f0102032:	74 04                	je     f0102038 <strncmp+0x26>
f0102034:	3a 0a                	cmp    (%edx),%cl
f0102036:	74 eb                	je     f0102023 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0102038:	0f b6 00             	movzbl (%eax),%eax
f010203b:	0f b6 12             	movzbl (%edx),%edx
f010203e:	29 d0                	sub    %edx,%eax
f0102040:	eb 05                	jmp    f0102047 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0102042:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0102047:	5b                   	pop    %ebx
f0102048:	5d                   	pop    %ebp
f0102049:	c3                   	ret    

f010204a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010204a:	55                   	push   %ebp
f010204b:	89 e5                	mov    %esp,%ebp
f010204d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102050:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102054:	eb 07                	jmp    f010205d <strchr+0x13>
		if (*s == c)
f0102056:	38 ca                	cmp    %cl,%dl
f0102058:	74 0f                	je     f0102069 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010205a:	83 c0 01             	add    $0x1,%eax
f010205d:	0f b6 10             	movzbl (%eax),%edx
f0102060:	84 d2                	test   %dl,%dl
f0102062:	75 f2                	jne    f0102056 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0102064:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102069:	5d                   	pop    %ebp
f010206a:	c3                   	ret    

f010206b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010206b:	55                   	push   %ebp
f010206c:	89 e5                	mov    %esp,%ebp
f010206e:	8b 45 08             	mov    0x8(%ebp),%eax
f0102071:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0102075:	eb 03                	jmp    f010207a <strfind+0xf>
f0102077:	83 c0 01             	add    $0x1,%eax
f010207a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010207d:	38 ca                	cmp    %cl,%dl
f010207f:	74 04                	je     f0102085 <strfind+0x1a>
f0102081:	84 d2                	test   %dl,%dl
f0102083:	75 f2                	jne    f0102077 <strfind+0xc>
			break;
	return (char *) s;
}
f0102085:	5d                   	pop    %ebp
f0102086:	c3                   	ret    

f0102087 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0102087:	55                   	push   %ebp
f0102088:	89 e5                	mov    %esp,%ebp
f010208a:	57                   	push   %edi
f010208b:	56                   	push   %esi
f010208c:	53                   	push   %ebx
f010208d:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102090:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0102093:	85 c9                	test   %ecx,%ecx
f0102095:	74 36                	je     f01020cd <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0102097:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010209d:	75 28                	jne    f01020c7 <memset+0x40>
f010209f:	f6 c1 03             	test   $0x3,%cl
f01020a2:	75 23                	jne    f01020c7 <memset+0x40>
		c &= 0xFF;
f01020a4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01020a8:	89 d3                	mov    %edx,%ebx
f01020aa:	c1 e3 08             	shl    $0x8,%ebx
f01020ad:	89 d6                	mov    %edx,%esi
f01020af:	c1 e6 18             	shl    $0x18,%esi
f01020b2:	89 d0                	mov    %edx,%eax
f01020b4:	c1 e0 10             	shl    $0x10,%eax
f01020b7:	09 f0                	or     %esi,%eax
f01020b9:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01020bb:	89 d8                	mov    %ebx,%eax
f01020bd:	09 d0                	or     %edx,%eax
f01020bf:	c1 e9 02             	shr    $0x2,%ecx
f01020c2:	fc                   	cld    
f01020c3:	f3 ab                	rep stos %eax,%es:(%edi)
f01020c5:	eb 06                	jmp    f01020cd <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01020c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01020ca:	fc                   	cld    
f01020cb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01020cd:	89 f8                	mov    %edi,%eax
f01020cf:	5b                   	pop    %ebx
f01020d0:	5e                   	pop    %esi
f01020d1:	5f                   	pop    %edi
f01020d2:	5d                   	pop    %ebp
f01020d3:	c3                   	ret    

f01020d4 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01020d4:	55                   	push   %ebp
f01020d5:	89 e5                	mov    %esp,%ebp
f01020d7:	57                   	push   %edi
f01020d8:	56                   	push   %esi
f01020d9:	8b 45 08             	mov    0x8(%ebp),%eax
f01020dc:	8b 75 0c             	mov    0xc(%ebp),%esi
f01020df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01020e2:	39 c6                	cmp    %eax,%esi
f01020e4:	73 35                	jae    f010211b <memmove+0x47>
f01020e6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01020e9:	39 d0                	cmp    %edx,%eax
f01020eb:	73 2e                	jae    f010211b <memmove+0x47>
		s += n;
		d += n;
f01020ed:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01020f0:	89 d6                	mov    %edx,%esi
f01020f2:	09 fe                	or     %edi,%esi
f01020f4:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01020fa:	75 13                	jne    f010210f <memmove+0x3b>
f01020fc:	f6 c1 03             	test   $0x3,%cl
f01020ff:	75 0e                	jne    f010210f <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0102101:	83 ef 04             	sub    $0x4,%edi
f0102104:	8d 72 fc             	lea    -0x4(%edx),%esi
f0102107:	c1 e9 02             	shr    $0x2,%ecx
f010210a:	fd                   	std    
f010210b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010210d:	eb 09                	jmp    f0102118 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010210f:	83 ef 01             	sub    $0x1,%edi
f0102112:	8d 72 ff             	lea    -0x1(%edx),%esi
f0102115:	fd                   	std    
f0102116:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0102118:	fc                   	cld    
f0102119:	eb 1d                	jmp    f0102138 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010211b:	89 f2                	mov    %esi,%edx
f010211d:	09 c2                	or     %eax,%edx
f010211f:	f6 c2 03             	test   $0x3,%dl
f0102122:	75 0f                	jne    f0102133 <memmove+0x5f>
f0102124:	f6 c1 03             	test   $0x3,%cl
f0102127:	75 0a                	jne    f0102133 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0102129:	c1 e9 02             	shr    $0x2,%ecx
f010212c:	89 c7                	mov    %eax,%edi
f010212e:	fc                   	cld    
f010212f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0102131:	eb 05                	jmp    f0102138 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0102133:	89 c7                	mov    %eax,%edi
f0102135:	fc                   	cld    
f0102136:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0102138:	5e                   	pop    %esi
f0102139:	5f                   	pop    %edi
f010213a:	5d                   	pop    %ebp
f010213b:	c3                   	ret    

f010213c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010213c:	55                   	push   %ebp
f010213d:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010213f:	ff 75 10             	pushl  0x10(%ebp)
f0102142:	ff 75 0c             	pushl  0xc(%ebp)
f0102145:	ff 75 08             	pushl  0x8(%ebp)
f0102148:	e8 87 ff ff ff       	call   f01020d4 <memmove>
}
f010214d:	c9                   	leave  
f010214e:	c3                   	ret    

f010214f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010214f:	55                   	push   %ebp
f0102150:	89 e5                	mov    %esp,%ebp
f0102152:	56                   	push   %esi
f0102153:	53                   	push   %ebx
f0102154:	8b 45 08             	mov    0x8(%ebp),%eax
f0102157:	8b 55 0c             	mov    0xc(%ebp),%edx
f010215a:	89 c6                	mov    %eax,%esi
f010215c:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010215f:	eb 1a                	jmp    f010217b <memcmp+0x2c>
		if (*s1 != *s2)
f0102161:	0f b6 08             	movzbl (%eax),%ecx
f0102164:	0f b6 1a             	movzbl (%edx),%ebx
f0102167:	38 d9                	cmp    %bl,%cl
f0102169:	74 0a                	je     f0102175 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010216b:	0f b6 c1             	movzbl %cl,%eax
f010216e:	0f b6 db             	movzbl %bl,%ebx
f0102171:	29 d8                	sub    %ebx,%eax
f0102173:	eb 0f                	jmp    f0102184 <memcmp+0x35>
		s1++, s2++;
f0102175:	83 c0 01             	add    $0x1,%eax
f0102178:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010217b:	39 f0                	cmp    %esi,%eax
f010217d:	75 e2                	jne    f0102161 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010217f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102184:	5b                   	pop    %ebx
f0102185:	5e                   	pop    %esi
f0102186:	5d                   	pop    %ebp
f0102187:	c3                   	ret    

f0102188 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0102188:	55                   	push   %ebp
f0102189:	89 e5                	mov    %esp,%ebp
f010218b:	53                   	push   %ebx
f010218c:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010218f:	89 c1                	mov    %eax,%ecx
f0102191:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0102194:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0102198:	eb 0a                	jmp    f01021a4 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f010219a:	0f b6 10             	movzbl (%eax),%edx
f010219d:	39 da                	cmp    %ebx,%edx
f010219f:	74 07                	je     f01021a8 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01021a1:	83 c0 01             	add    $0x1,%eax
f01021a4:	39 c8                	cmp    %ecx,%eax
f01021a6:	72 f2                	jb     f010219a <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01021a8:	5b                   	pop    %ebx
f01021a9:	5d                   	pop    %ebp
f01021aa:	c3                   	ret    

f01021ab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01021ab:	55                   	push   %ebp
f01021ac:	89 e5                	mov    %esp,%ebp
f01021ae:	57                   	push   %edi
f01021af:	56                   	push   %esi
f01021b0:	53                   	push   %ebx
f01021b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01021b4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01021b7:	eb 03                	jmp    f01021bc <strtol+0x11>
		s++;
f01021b9:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01021bc:	0f b6 01             	movzbl (%ecx),%eax
f01021bf:	3c 20                	cmp    $0x20,%al
f01021c1:	74 f6                	je     f01021b9 <strtol+0xe>
f01021c3:	3c 09                	cmp    $0x9,%al
f01021c5:	74 f2                	je     f01021b9 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01021c7:	3c 2b                	cmp    $0x2b,%al
f01021c9:	75 0a                	jne    f01021d5 <strtol+0x2a>
		s++;
f01021cb:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01021ce:	bf 00 00 00 00       	mov    $0x0,%edi
f01021d3:	eb 11                	jmp    f01021e6 <strtol+0x3b>
f01021d5:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01021da:	3c 2d                	cmp    $0x2d,%al
f01021dc:	75 08                	jne    f01021e6 <strtol+0x3b>
		s++, neg = 1;
f01021de:	83 c1 01             	add    $0x1,%ecx
f01021e1:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01021e6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01021ec:	75 15                	jne    f0102203 <strtol+0x58>
f01021ee:	80 39 30             	cmpb   $0x30,(%ecx)
f01021f1:	75 10                	jne    f0102203 <strtol+0x58>
f01021f3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01021f7:	75 7c                	jne    f0102275 <strtol+0xca>
		s += 2, base = 16;
f01021f9:	83 c1 02             	add    $0x2,%ecx
f01021fc:	bb 10 00 00 00       	mov    $0x10,%ebx
f0102201:	eb 16                	jmp    f0102219 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0102203:	85 db                	test   %ebx,%ebx
f0102205:	75 12                	jne    f0102219 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0102207:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010220c:	80 39 30             	cmpb   $0x30,(%ecx)
f010220f:	75 08                	jne    f0102219 <strtol+0x6e>
		s++, base = 8;
f0102211:	83 c1 01             	add    $0x1,%ecx
f0102214:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0102219:	b8 00 00 00 00       	mov    $0x0,%eax
f010221e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0102221:	0f b6 11             	movzbl (%ecx),%edx
f0102224:	8d 72 d0             	lea    -0x30(%edx),%esi
f0102227:	89 f3                	mov    %esi,%ebx
f0102229:	80 fb 09             	cmp    $0x9,%bl
f010222c:	77 08                	ja     f0102236 <strtol+0x8b>
			dig = *s - '0';
f010222e:	0f be d2             	movsbl %dl,%edx
f0102231:	83 ea 30             	sub    $0x30,%edx
f0102234:	eb 22                	jmp    f0102258 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0102236:	8d 72 9f             	lea    -0x61(%edx),%esi
f0102239:	89 f3                	mov    %esi,%ebx
f010223b:	80 fb 19             	cmp    $0x19,%bl
f010223e:	77 08                	ja     f0102248 <strtol+0x9d>
			dig = *s - 'a' + 10;
f0102240:	0f be d2             	movsbl %dl,%edx
f0102243:	83 ea 57             	sub    $0x57,%edx
f0102246:	eb 10                	jmp    f0102258 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0102248:	8d 72 bf             	lea    -0x41(%edx),%esi
f010224b:	89 f3                	mov    %esi,%ebx
f010224d:	80 fb 19             	cmp    $0x19,%bl
f0102250:	77 16                	ja     f0102268 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0102252:	0f be d2             	movsbl %dl,%edx
f0102255:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0102258:	3b 55 10             	cmp    0x10(%ebp),%edx
f010225b:	7d 0b                	jge    f0102268 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010225d:	83 c1 01             	add    $0x1,%ecx
f0102260:	0f af 45 10          	imul   0x10(%ebp),%eax
f0102264:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0102266:	eb b9                	jmp    f0102221 <strtol+0x76>

	if (endptr)
f0102268:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010226c:	74 0d                	je     f010227b <strtol+0xd0>
		*endptr = (char *) s;
f010226e:	8b 75 0c             	mov    0xc(%ebp),%esi
f0102271:	89 0e                	mov    %ecx,(%esi)
f0102273:	eb 06                	jmp    f010227b <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0102275:	85 db                	test   %ebx,%ebx
f0102277:	74 98                	je     f0102211 <strtol+0x66>
f0102279:	eb 9e                	jmp    f0102219 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010227b:	89 c2                	mov    %eax,%edx
f010227d:	f7 da                	neg    %edx
f010227f:	85 ff                	test   %edi,%edi
f0102281:	0f 45 c2             	cmovne %edx,%eax
}
f0102284:	5b                   	pop    %ebx
f0102285:	5e                   	pop    %esi
f0102286:	5f                   	pop    %edi
f0102287:	5d                   	pop    %ebp
f0102288:	c3                   	ret    
f0102289:	66 90                	xchg   %ax,%ax
f010228b:	66 90                	xchg   %ax,%ax
f010228d:	66 90                	xchg   %ax,%ax
f010228f:	90                   	nop

f0102290 <__udivdi3>:
f0102290:	55                   	push   %ebp
f0102291:	57                   	push   %edi
f0102292:	56                   	push   %esi
f0102293:	53                   	push   %ebx
f0102294:	83 ec 1c             	sub    $0x1c,%esp
f0102297:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f010229b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f010229f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01022a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01022a7:	85 f6                	test   %esi,%esi
f01022a9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01022ad:	89 ca                	mov    %ecx,%edx
f01022af:	89 f8                	mov    %edi,%eax
f01022b1:	75 3d                	jne    f01022f0 <__udivdi3+0x60>
f01022b3:	39 cf                	cmp    %ecx,%edi
f01022b5:	0f 87 c5 00 00 00    	ja     f0102380 <__udivdi3+0xf0>
f01022bb:	85 ff                	test   %edi,%edi
f01022bd:	89 fd                	mov    %edi,%ebp
f01022bf:	75 0b                	jne    f01022cc <__udivdi3+0x3c>
f01022c1:	b8 01 00 00 00       	mov    $0x1,%eax
f01022c6:	31 d2                	xor    %edx,%edx
f01022c8:	f7 f7                	div    %edi
f01022ca:	89 c5                	mov    %eax,%ebp
f01022cc:	89 c8                	mov    %ecx,%eax
f01022ce:	31 d2                	xor    %edx,%edx
f01022d0:	f7 f5                	div    %ebp
f01022d2:	89 c1                	mov    %eax,%ecx
f01022d4:	89 d8                	mov    %ebx,%eax
f01022d6:	89 cf                	mov    %ecx,%edi
f01022d8:	f7 f5                	div    %ebp
f01022da:	89 c3                	mov    %eax,%ebx
f01022dc:	89 d8                	mov    %ebx,%eax
f01022de:	89 fa                	mov    %edi,%edx
f01022e0:	83 c4 1c             	add    $0x1c,%esp
f01022e3:	5b                   	pop    %ebx
f01022e4:	5e                   	pop    %esi
f01022e5:	5f                   	pop    %edi
f01022e6:	5d                   	pop    %ebp
f01022e7:	c3                   	ret    
f01022e8:	90                   	nop
f01022e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01022f0:	39 ce                	cmp    %ecx,%esi
f01022f2:	77 74                	ja     f0102368 <__udivdi3+0xd8>
f01022f4:	0f bd fe             	bsr    %esi,%edi
f01022f7:	83 f7 1f             	xor    $0x1f,%edi
f01022fa:	0f 84 98 00 00 00    	je     f0102398 <__udivdi3+0x108>
f0102300:	bb 20 00 00 00       	mov    $0x20,%ebx
f0102305:	89 f9                	mov    %edi,%ecx
f0102307:	89 c5                	mov    %eax,%ebp
f0102309:	29 fb                	sub    %edi,%ebx
f010230b:	d3 e6                	shl    %cl,%esi
f010230d:	89 d9                	mov    %ebx,%ecx
f010230f:	d3 ed                	shr    %cl,%ebp
f0102311:	89 f9                	mov    %edi,%ecx
f0102313:	d3 e0                	shl    %cl,%eax
f0102315:	09 ee                	or     %ebp,%esi
f0102317:	89 d9                	mov    %ebx,%ecx
f0102319:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010231d:	89 d5                	mov    %edx,%ebp
f010231f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0102323:	d3 ed                	shr    %cl,%ebp
f0102325:	89 f9                	mov    %edi,%ecx
f0102327:	d3 e2                	shl    %cl,%edx
f0102329:	89 d9                	mov    %ebx,%ecx
f010232b:	d3 e8                	shr    %cl,%eax
f010232d:	09 c2                	or     %eax,%edx
f010232f:	89 d0                	mov    %edx,%eax
f0102331:	89 ea                	mov    %ebp,%edx
f0102333:	f7 f6                	div    %esi
f0102335:	89 d5                	mov    %edx,%ebp
f0102337:	89 c3                	mov    %eax,%ebx
f0102339:	f7 64 24 0c          	mull   0xc(%esp)
f010233d:	39 d5                	cmp    %edx,%ebp
f010233f:	72 10                	jb     f0102351 <__udivdi3+0xc1>
f0102341:	8b 74 24 08          	mov    0x8(%esp),%esi
f0102345:	89 f9                	mov    %edi,%ecx
f0102347:	d3 e6                	shl    %cl,%esi
f0102349:	39 c6                	cmp    %eax,%esi
f010234b:	73 07                	jae    f0102354 <__udivdi3+0xc4>
f010234d:	39 d5                	cmp    %edx,%ebp
f010234f:	75 03                	jne    f0102354 <__udivdi3+0xc4>
f0102351:	83 eb 01             	sub    $0x1,%ebx
f0102354:	31 ff                	xor    %edi,%edi
f0102356:	89 d8                	mov    %ebx,%eax
f0102358:	89 fa                	mov    %edi,%edx
f010235a:	83 c4 1c             	add    $0x1c,%esp
f010235d:	5b                   	pop    %ebx
f010235e:	5e                   	pop    %esi
f010235f:	5f                   	pop    %edi
f0102360:	5d                   	pop    %ebp
f0102361:	c3                   	ret    
f0102362:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102368:	31 ff                	xor    %edi,%edi
f010236a:	31 db                	xor    %ebx,%ebx
f010236c:	89 d8                	mov    %ebx,%eax
f010236e:	89 fa                	mov    %edi,%edx
f0102370:	83 c4 1c             	add    $0x1c,%esp
f0102373:	5b                   	pop    %ebx
f0102374:	5e                   	pop    %esi
f0102375:	5f                   	pop    %edi
f0102376:	5d                   	pop    %ebp
f0102377:	c3                   	ret    
f0102378:	90                   	nop
f0102379:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102380:	89 d8                	mov    %ebx,%eax
f0102382:	f7 f7                	div    %edi
f0102384:	31 ff                	xor    %edi,%edi
f0102386:	89 c3                	mov    %eax,%ebx
f0102388:	89 d8                	mov    %ebx,%eax
f010238a:	89 fa                	mov    %edi,%edx
f010238c:	83 c4 1c             	add    $0x1c,%esp
f010238f:	5b                   	pop    %ebx
f0102390:	5e                   	pop    %esi
f0102391:	5f                   	pop    %edi
f0102392:	5d                   	pop    %ebp
f0102393:	c3                   	ret    
f0102394:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102398:	39 ce                	cmp    %ecx,%esi
f010239a:	72 0c                	jb     f01023a8 <__udivdi3+0x118>
f010239c:	31 db                	xor    %ebx,%ebx
f010239e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01023a2:	0f 87 34 ff ff ff    	ja     f01022dc <__udivdi3+0x4c>
f01023a8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01023ad:	e9 2a ff ff ff       	jmp    f01022dc <__udivdi3+0x4c>
f01023b2:	66 90                	xchg   %ax,%ax
f01023b4:	66 90                	xchg   %ax,%ax
f01023b6:	66 90                	xchg   %ax,%ax
f01023b8:	66 90                	xchg   %ax,%ax
f01023ba:	66 90                	xchg   %ax,%ax
f01023bc:	66 90                	xchg   %ax,%ax
f01023be:	66 90                	xchg   %ax,%ax

f01023c0 <__umoddi3>:
f01023c0:	55                   	push   %ebp
f01023c1:	57                   	push   %edi
f01023c2:	56                   	push   %esi
f01023c3:	53                   	push   %ebx
f01023c4:	83 ec 1c             	sub    $0x1c,%esp
f01023c7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01023cb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01023cf:	8b 74 24 34          	mov    0x34(%esp),%esi
f01023d3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01023d7:	85 d2                	test   %edx,%edx
f01023d9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01023dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f01023e1:	89 f3                	mov    %esi,%ebx
f01023e3:	89 3c 24             	mov    %edi,(%esp)
f01023e6:	89 74 24 04          	mov    %esi,0x4(%esp)
f01023ea:	75 1c                	jne    f0102408 <__umoddi3+0x48>
f01023ec:	39 f7                	cmp    %esi,%edi
f01023ee:	76 50                	jbe    f0102440 <__umoddi3+0x80>
f01023f0:	89 c8                	mov    %ecx,%eax
f01023f2:	89 f2                	mov    %esi,%edx
f01023f4:	f7 f7                	div    %edi
f01023f6:	89 d0                	mov    %edx,%eax
f01023f8:	31 d2                	xor    %edx,%edx
f01023fa:	83 c4 1c             	add    $0x1c,%esp
f01023fd:	5b                   	pop    %ebx
f01023fe:	5e                   	pop    %esi
f01023ff:	5f                   	pop    %edi
f0102400:	5d                   	pop    %ebp
f0102401:	c3                   	ret    
f0102402:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0102408:	39 f2                	cmp    %esi,%edx
f010240a:	89 d0                	mov    %edx,%eax
f010240c:	77 52                	ja     f0102460 <__umoddi3+0xa0>
f010240e:	0f bd ea             	bsr    %edx,%ebp
f0102411:	83 f5 1f             	xor    $0x1f,%ebp
f0102414:	75 5a                	jne    f0102470 <__umoddi3+0xb0>
f0102416:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010241a:	0f 82 e0 00 00 00    	jb     f0102500 <__umoddi3+0x140>
f0102420:	39 0c 24             	cmp    %ecx,(%esp)
f0102423:	0f 86 d7 00 00 00    	jbe    f0102500 <__umoddi3+0x140>
f0102429:	8b 44 24 08          	mov    0x8(%esp),%eax
f010242d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0102431:	83 c4 1c             	add    $0x1c,%esp
f0102434:	5b                   	pop    %ebx
f0102435:	5e                   	pop    %esi
f0102436:	5f                   	pop    %edi
f0102437:	5d                   	pop    %ebp
f0102438:	c3                   	ret    
f0102439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0102440:	85 ff                	test   %edi,%edi
f0102442:	89 fd                	mov    %edi,%ebp
f0102444:	75 0b                	jne    f0102451 <__umoddi3+0x91>
f0102446:	b8 01 00 00 00       	mov    $0x1,%eax
f010244b:	31 d2                	xor    %edx,%edx
f010244d:	f7 f7                	div    %edi
f010244f:	89 c5                	mov    %eax,%ebp
f0102451:	89 f0                	mov    %esi,%eax
f0102453:	31 d2                	xor    %edx,%edx
f0102455:	f7 f5                	div    %ebp
f0102457:	89 c8                	mov    %ecx,%eax
f0102459:	f7 f5                	div    %ebp
f010245b:	89 d0                	mov    %edx,%eax
f010245d:	eb 99                	jmp    f01023f8 <__umoddi3+0x38>
f010245f:	90                   	nop
f0102460:	89 c8                	mov    %ecx,%eax
f0102462:	89 f2                	mov    %esi,%edx
f0102464:	83 c4 1c             	add    $0x1c,%esp
f0102467:	5b                   	pop    %ebx
f0102468:	5e                   	pop    %esi
f0102469:	5f                   	pop    %edi
f010246a:	5d                   	pop    %ebp
f010246b:	c3                   	ret    
f010246c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0102470:	8b 34 24             	mov    (%esp),%esi
f0102473:	bf 20 00 00 00       	mov    $0x20,%edi
f0102478:	89 e9                	mov    %ebp,%ecx
f010247a:	29 ef                	sub    %ebp,%edi
f010247c:	d3 e0                	shl    %cl,%eax
f010247e:	89 f9                	mov    %edi,%ecx
f0102480:	89 f2                	mov    %esi,%edx
f0102482:	d3 ea                	shr    %cl,%edx
f0102484:	89 e9                	mov    %ebp,%ecx
f0102486:	09 c2                	or     %eax,%edx
f0102488:	89 d8                	mov    %ebx,%eax
f010248a:	89 14 24             	mov    %edx,(%esp)
f010248d:	89 f2                	mov    %esi,%edx
f010248f:	d3 e2                	shl    %cl,%edx
f0102491:	89 f9                	mov    %edi,%ecx
f0102493:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102497:	8b 54 24 0c          	mov    0xc(%esp),%edx
f010249b:	d3 e8                	shr    %cl,%eax
f010249d:	89 e9                	mov    %ebp,%ecx
f010249f:	89 c6                	mov    %eax,%esi
f01024a1:	d3 e3                	shl    %cl,%ebx
f01024a3:	89 f9                	mov    %edi,%ecx
f01024a5:	89 d0                	mov    %edx,%eax
f01024a7:	d3 e8                	shr    %cl,%eax
f01024a9:	89 e9                	mov    %ebp,%ecx
f01024ab:	09 d8                	or     %ebx,%eax
f01024ad:	89 d3                	mov    %edx,%ebx
f01024af:	89 f2                	mov    %esi,%edx
f01024b1:	f7 34 24             	divl   (%esp)
f01024b4:	89 d6                	mov    %edx,%esi
f01024b6:	d3 e3                	shl    %cl,%ebx
f01024b8:	f7 64 24 04          	mull   0x4(%esp)
f01024bc:	39 d6                	cmp    %edx,%esi
f01024be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01024c2:	89 d1                	mov    %edx,%ecx
f01024c4:	89 c3                	mov    %eax,%ebx
f01024c6:	72 08                	jb     f01024d0 <__umoddi3+0x110>
f01024c8:	75 11                	jne    f01024db <__umoddi3+0x11b>
f01024ca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01024ce:	73 0b                	jae    f01024db <__umoddi3+0x11b>
f01024d0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01024d4:	1b 14 24             	sbb    (%esp),%edx
f01024d7:	89 d1                	mov    %edx,%ecx
f01024d9:	89 c3                	mov    %eax,%ebx
f01024db:	8b 54 24 08          	mov    0x8(%esp),%edx
f01024df:	29 da                	sub    %ebx,%edx
f01024e1:	19 ce                	sbb    %ecx,%esi
f01024e3:	89 f9                	mov    %edi,%ecx
f01024e5:	89 f0                	mov    %esi,%eax
f01024e7:	d3 e0                	shl    %cl,%eax
f01024e9:	89 e9                	mov    %ebp,%ecx
f01024eb:	d3 ea                	shr    %cl,%edx
f01024ed:	89 e9                	mov    %ebp,%ecx
f01024ef:	d3 ee                	shr    %cl,%esi
f01024f1:	09 d0                	or     %edx,%eax
f01024f3:	89 f2                	mov    %esi,%edx
f01024f5:	83 c4 1c             	add    $0x1c,%esp
f01024f8:	5b                   	pop    %ebx
f01024f9:	5e                   	pop    %esi
f01024fa:	5f                   	pop    %edi
f01024fb:	5d                   	pop    %ebp
f01024fc:	c3                   	ret    
f01024fd:	8d 76 00             	lea    0x0(%esi),%esi
f0102500:	29 f9                	sub    %edi,%ecx
f0102502:	19 d6                	sbb    %edx,%esi
f0102504:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102508:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010250c:	e9 18 ff ff ff       	jmp    f0102429 <__umoddi3+0x69>
