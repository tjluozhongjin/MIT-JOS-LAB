
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
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/kclock.h>


void
i386_init(void)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100046:	b8 70 69 11 f0       	mov    $0xf0116970,%eax
f010004b:	2d 00 63 11 f0       	sub    $0xf0116300,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 00 63 11 f0       	push   $0xf0116300
f0100058:	e8 f8 30 00 00       	call   f0103155 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 96 04 00 00       	call   f01004f8 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 00 36 10 f0       	push   $0xf0103600
f010006f:	e8 f8 25 00 00       	call   f010266c <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 49 0f 00 00       	call   f0100fc2 <mem_init>
f0100079:	83 c4 10             	add    $0x10,%esp

	// Drop into the kernel monitor.
	while (1)
		monitor(NULL);
f010007c:	83 ec 0c             	sub    $0xc,%esp
f010007f:	6a 00                	push   $0x0
f0100081:	e8 97 06 00 00       	call   f010071d <monitor>
f0100086:	83 c4 10             	add    $0x10,%esp
f0100089:	eb f1                	jmp    f010007c <i386_init+0x3c>

f010008b <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f010008b:	55                   	push   %ebp
f010008c:	89 e5                	mov    %esp,%ebp
f010008e:	56                   	push   %esi
f010008f:	53                   	push   %ebx
f0100090:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100093:	83 3d 60 69 11 f0 00 	cmpl   $0x0,0xf0116960
f010009a:	75 37                	jne    f01000d3 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f010009c:	89 35 60 69 11 f0    	mov    %esi,0xf0116960

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000a2:	fa                   	cli    
f01000a3:	fc                   	cld    

	va_start(ap, fmt);
f01000a4:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000a7:	83 ec 04             	sub    $0x4,%esp
f01000aa:	ff 75 0c             	pushl  0xc(%ebp)
f01000ad:	ff 75 08             	pushl  0x8(%ebp)
f01000b0:	68 1b 36 10 f0       	push   $0xf010361b
f01000b5:	e8 b2 25 00 00       	call   f010266c <cprintf>
	vcprintf(fmt, ap);
f01000ba:	83 c4 08             	add    $0x8,%esp
f01000bd:	53                   	push   %ebx
f01000be:	56                   	push   %esi
f01000bf:	e8 82 25 00 00       	call   f0102646 <vcprintf>
	cprintf("\n");
f01000c4:	c7 04 24 f4 44 10 f0 	movl   $0xf01044f4,(%esp)
f01000cb:	e8 9c 25 00 00       	call   f010266c <cprintf>
	va_end(ap);
f01000d0:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000d3:	83 ec 0c             	sub    $0xc,%esp
f01000d6:	6a 00                	push   $0x0
f01000d8:	e8 40 06 00 00       	call   f010071d <monitor>
f01000dd:	83 c4 10             	add    $0x10,%esp
f01000e0:	eb f1                	jmp    f01000d3 <_panic+0x48>

f01000e2 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000e2:	55                   	push   %ebp
f01000e3:	89 e5                	mov    %esp,%ebp
f01000e5:	53                   	push   %ebx
f01000e6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000e9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f01000ec:	ff 75 0c             	pushl  0xc(%ebp)
f01000ef:	ff 75 08             	pushl  0x8(%ebp)
f01000f2:	68 33 36 10 f0       	push   $0xf0103633
f01000f7:	e8 70 25 00 00       	call   f010266c <cprintf>
	vcprintf(fmt, ap);
f01000fc:	83 c4 08             	add    $0x8,%esp
f01000ff:	53                   	push   %ebx
f0100100:	ff 75 10             	pushl  0x10(%ebp)
f0100103:	e8 3e 25 00 00       	call   f0102646 <vcprintf>
	cprintf("\n");
f0100108:	c7 04 24 f4 44 10 f0 	movl   $0xf01044f4,(%esp)
f010010f:	e8 58 25 00 00       	call   f010266c <cprintf>
	va_end(ap);
}
f0100114:	83 c4 10             	add    $0x10,%esp
f0100117:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010011a:	c9                   	leave  
f010011b:	c3                   	ret    

f010011c <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010011c:	55                   	push   %ebp
f010011d:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010011f:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100124:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100125:	a8 01                	test   $0x1,%al
f0100127:	74 0b                	je     f0100134 <serial_proc_data+0x18>
f0100129:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010012e:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010012f:	0f b6 c0             	movzbl %al,%eax
f0100132:	eb 05                	jmp    f0100139 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100134:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100139:	5d                   	pop    %ebp
f010013a:	c3                   	ret    

f010013b <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010013b:	55                   	push   %ebp
f010013c:	89 e5                	mov    %esp,%ebp
f010013e:	53                   	push   %ebx
f010013f:	83 ec 04             	sub    $0x4,%esp
f0100142:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100144:	eb 2b                	jmp    f0100171 <cons_intr+0x36>
		if (c == 0)
f0100146:	85 c0                	test   %eax,%eax
f0100148:	74 27                	je     f0100171 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010014a:	8b 0d 24 65 11 f0    	mov    0xf0116524,%ecx
f0100150:	8d 51 01             	lea    0x1(%ecx),%edx
f0100153:	89 15 24 65 11 f0    	mov    %edx,0xf0116524
f0100159:	88 81 20 63 11 f0    	mov    %al,-0xfee9ce0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f010015f:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100165:	75 0a                	jne    f0100171 <cons_intr+0x36>
			cons.wpos = 0;
f0100167:	c7 05 24 65 11 f0 00 	movl   $0x0,0xf0116524
f010016e:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100171:	ff d3                	call   *%ebx
f0100173:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100176:	75 ce                	jne    f0100146 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100178:	83 c4 04             	add    $0x4,%esp
f010017b:	5b                   	pop    %ebx
f010017c:	5d                   	pop    %ebp
f010017d:	c3                   	ret    

f010017e <kbd_proc_data>:
f010017e:	ba 64 00 00 00       	mov    $0x64,%edx
f0100183:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100184:	a8 01                	test   $0x1,%al
f0100186:	0f 84 f8 00 00 00    	je     f0100284 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f010018c:	a8 20                	test   $0x20,%al
f010018e:	0f 85 f6 00 00 00    	jne    f010028a <kbd_proc_data+0x10c>
f0100194:	ba 60 00 00 00       	mov    $0x60,%edx
f0100199:	ec                   	in     (%dx),%al
f010019a:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f010019c:	3c e0                	cmp    $0xe0,%al
f010019e:	75 0d                	jne    f01001ad <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001a0:	83 0d 00 63 11 f0 40 	orl    $0x40,0xf0116300
		return 0;
f01001a7:	b8 00 00 00 00       	mov    $0x0,%eax
f01001ac:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001ad:	55                   	push   %ebp
f01001ae:	89 e5                	mov    %esp,%ebp
f01001b0:	53                   	push   %ebx
f01001b1:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001b4:	84 c0                	test   %al,%al
f01001b6:	79 36                	jns    f01001ee <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001b8:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f01001be:	89 cb                	mov    %ecx,%ebx
f01001c0:	83 e3 40             	and    $0x40,%ebx
f01001c3:	83 e0 7f             	and    $0x7f,%eax
f01001c6:	85 db                	test   %ebx,%ebx
f01001c8:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001cb:	0f b6 d2             	movzbl %dl,%edx
f01001ce:	0f b6 82 a0 37 10 f0 	movzbl -0xfefc860(%edx),%eax
f01001d5:	83 c8 40             	or     $0x40,%eax
f01001d8:	0f b6 c0             	movzbl %al,%eax
f01001db:	f7 d0                	not    %eax
f01001dd:	21 c8                	and    %ecx,%eax
f01001df:	a3 00 63 11 f0       	mov    %eax,0xf0116300
		return 0;
f01001e4:	b8 00 00 00 00       	mov    $0x0,%eax
f01001e9:	e9 a4 00 00 00       	jmp    f0100292 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f01001ee:	8b 0d 00 63 11 f0    	mov    0xf0116300,%ecx
f01001f4:	f6 c1 40             	test   $0x40,%cl
f01001f7:	74 0e                	je     f0100207 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f01001f9:	83 c8 80             	or     $0xffffff80,%eax
f01001fc:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f01001fe:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100201:	89 0d 00 63 11 f0    	mov    %ecx,0xf0116300
	}

	shift |= shiftcode[data];
f0100207:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010020a:	0f b6 82 a0 37 10 f0 	movzbl -0xfefc860(%edx),%eax
f0100211:	0b 05 00 63 11 f0    	or     0xf0116300,%eax
f0100217:	0f b6 8a a0 36 10 f0 	movzbl -0xfefc960(%edx),%ecx
f010021e:	31 c8                	xor    %ecx,%eax
f0100220:	a3 00 63 11 f0       	mov    %eax,0xf0116300

	c = charcode[shift & (CTL | SHIFT)][data];
f0100225:	89 c1                	mov    %eax,%ecx
f0100227:	83 e1 03             	and    $0x3,%ecx
f010022a:	8b 0c 8d 80 36 10 f0 	mov    -0xfefc980(,%ecx,4),%ecx
f0100231:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100235:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100238:	a8 08                	test   $0x8,%al
f010023a:	74 1b                	je     f0100257 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010023c:	89 da                	mov    %ebx,%edx
f010023e:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100241:	83 f9 19             	cmp    $0x19,%ecx
f0100244:	77 05                	ja     f010024b <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f0100246:	83 eb 20             	sub    $0x20,%ebx
f0100249:	eb 0c                	jmp    f0100257 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f010024b:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f010024e:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100251:	83 fa 19             	cmp    $0x19,%edx
f0100254:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f0100257:	f7 d0                	not    %eax
f0100259:	a8 06                	test   $0x6,%al
f010025b:	75 33                	jne    f0100290 <kbd_proc_data+0x112>
f010025d:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100263:	75 2b                	jne    f0100290 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f0100265:	83 ec 0c             	sub    $0xc,%esp
f0100268:	68 4d 36 10 f0       	push   $0xf010364d
f010026d:	e8 fa 23 00 00       	call   f010266c <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100272:	ba 92 00 00 00       	mov    $0x92,%edx
f0100277:	b8 03 00 00 00       	mov    $0x3,%eax
f010027c:	ee                   	out    %al,(%dx)
f010027d:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100280:	89 d8                	mov    %ebx,%eax
f0100282:	eb 0e                	jmp    f0100292 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100284:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100289:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010028a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010028f:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100290:	89 d8                	mov    %ebx,%eax
}
f0100292:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100295:	c9                   	leave  
f0100296:	c3                   	ret    

f0100297 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f0100297:	55                   	push   %ebp
f0100298:	89 e5                	mov    %esp,%ebp
f010029a:	57                   	push   %edi
f010029b:	56                   	push   %esi
f010029c:	53                   	push   %ebx
f010029d:	83 ec 1c             	sub    $0x1c,%esp
f01002a0:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002a2:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002a7:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002ac:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002b1:	eb 09                	jmp    f01002bc <cons_putc+0x25>
f01002b3:	89 ca                	mov    %ecx,%edx
f01002b5:	ec                   	in     (%dx),%al
f01002b6:	ec                   	in     (%dx),%al
f01002b7:	ec                   	in     (%dx),%al
f01002b8:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002b9:	83 c3 01             	add    $0x1,%ebx
f01002bc:	89 f2                	mov    %esi,%edx
f01002be:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002bf:	a8 20                	test   $0x20,%al
f01002c1:	75 08                	jne    f01002cb <cons_putc+0x34>
f01002c3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002c9:	7e e8                	jle    f01002b3 <cons_putc+0x1c>
f01002cb:	89 f8                	mov    %edi,%eax
f01002cd:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002d0:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002d5:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002d6:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002db:	be 79 03 00 00       	mov    $0x379,%esi
f01002e0:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002e5:	eb 09                	jmp    f01002f0 <cons_putc+0x59>
f01002e7:	89 ca                	mov    %ecx,%edx
f01002e9:	ec                   	in     (%dx),%al
f01002ea:	ec                   	in     (%dx),%al
f01002eb:	ec                   	in     (%dx),%al
f01002ec:	ec                   	in     (%dx),%al
f01002ed:	83 c3 01             	add    $0x1,%ebx
f01002f0:	89 f2                	mov    %esi,%edx
f01002f2:	ec                   	in     (%dx),%al
f01002f3:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002f9:	7f 04                	jg     f01002ff <cons_putc+0x68>
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 e8                	jns    f01002e7 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002ff:	ba 78 03 00 00       	mov    $0x378,%edx
f0100304:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100308:	ee                   	out    %al,(%dx)
f0100309:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010030e:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100313:	ee                   	out    %al,(%dx)
f0100314:	b8 08 00 00 00       	mov    $0x8,%eax
f0100319:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010031a:	89 fa                	mov    %edi,%edx
f010031c:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100322:	89 f8                	mov    %edi,%eax
f0100324:	80 cc 07             	or     $0x7,%ah
f0100327:	85 d2                	test   %edx,%edx
f0100329:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010032c:	89 f8                	mov    %edi,%eax
f010032e:	0f b6 c0             	movzbl %al,%eax
f0100331:	83 f8 09             	cmp    $0x9,%eax
f0100334:	74 74                	je     f01003aa <cons_putc+0x113>
f0100336:	83 f8 09             	cmp    $0x9,%eax
f0100339:	7f 0a                	jg     f0100345 <cons_putc+0xae>
f010033b:	83 f8 08             	cmp    $0x8,%eax
f010033e:	74 14                	je     f0100354 <cons_putc+0xbd>
f0100340:	e9 99 00 00 00       	jmp    f01003de <cons_putc+0x147>
f0100345:	83 f8 0a             	cmp    $0xa,%eax
f0100348:	74 3a                	je     f0100384 <cons_putc+0xed>
f010034a:	83 f8 0d             	cmp    $0xd,%eax
f010034d:	74 3d                	je     f010038c <cons_putc+0xf5>
f010034f:	e9 8a 00 00 00       	jmp    f01003de <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100354:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f010035b:	66 85 c0             	test   %ax,%ax
f010035e:	0f 84 e6 00 00 00    	je     f010044a <cons_putc+0x1b3>
			crt_pos--;
f0100364:	83 e8 01             	sub    $0x1,%eax
f0100367:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f010036d:	0f b7 c0             	movzwl %ax,%eax
f0100370:	66 81 e7 00 ff       	and    $0xff00,%di
f0100375:	83 cf 20             	or     $0x20,%edi
f0100378:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f010037e:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100382:	eb 78                	jmp    f01003fc <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100384:	66 83 05 28 65 11 f0 	addw   $0x50,0xf0116528
f010038b:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f010038c:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f0100393:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f0100399:	c1 e8 16             	shr    $0x16,%eax
f010039c:	8d 04 80             	lea    (%eax,%eax,4),%eax
f010039f:	c1 e0 04             	shl    $0x4,%eax
f01003a2:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
f01003a8:	eb 52                	jmp    f01003fc <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003aa:	b8 20 00 00 00       	mov    $0x20,%eax
f01003af:	e8 e3 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01003b9:	e8 d9 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003be:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c3:	e8 cf fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003c8:	b8 20 00 00 00       	mov    $0x20,%eax
f01003cd:	e8 c5 fe ff ff       	call   f0100297 <cons_putc>
		cons_putc(' ');
f01003d2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d7:	e8 bb fe ff ff       	call   f0100297 <cons_putc>
f01003dc:	eb 1e                	jmp    f01003fc <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003de:	0f b7 05 28 65 11 f0 	movzwl 0xf0116528,%eax
f01003e5:	8d 50 01             	lea    0x1(%eax),%edx
f01003e8:	66 89 15 28 65 11 f0 	mov    %dx,0xf0116528
f01003ef:	0f b7 c0             	movzwl %ax,%eax
f01003f2:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f01003f8:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f01003fc:	66 81 3d 28 65 11 f0 	cmpw   $0x7cf,0xf0116528
f0100403:	cf 07 
f0100405:	76 43                	jbe    f010044a <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100407:	a1 2c 65 11 f0       	mov    0xf011652c,%eax
f010040c:	83 ec 04             	sub    $0x4,%esp
f010040f:	68 00 0f 00 00       	push   $0xf00
f0100414:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010041a:	52                   	push   %edx
f010041b:	50                   	push   %eax
f010041c:	e8 81 2d 00 00       	call   f01031a2 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100421:	8b 15 2c 65 11 f0    	mov    0xf011652c,%edx
f0100427:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010042d:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100433:	83 c4 10             	add    $0x10,%esp
f0100436:	66 c7 00 20 07       	movw   $0x720,(%eax)
f010043b:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010043e:	39 d0                	cmp    %edx,%eax
f0100440:	75 f4                	jne    f0100436 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100442:	66 83 2d 28 65 11 f0 	subw   $0x50,0xf0116528
f0100449:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010044a:	8b 0d 30 65 11 f0    	mov    0xf0116530,%ecx
f0100450:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100455:	89 ca                	mov    %ecx,%edx
f0100457:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f0100458:	0f b7 1d 28 65 11 f0 	movzwl 0xf0116528,%ebx
f010045f:	8d 71 01             	lea    0x1(%ecx),%esi
f0100462:	89 d8                	mov    %ebx,%eax
f0100464:	66 c1 e8 08          	shr    $0x8,%ax
f0100468:	89 f2                	mov    %esi,%edx
f010046a:	ee                   	out    %al,(%dx)
f010046b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100470:	89 ca                	mov    %ecx,%edx
f0100472:	ee                   	out    %al,(%dx)
f0100473:	89 d8                	mov    %ebx,%eax
f0100475:	89 f2                	mov    %esi,%edx
f0100477:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f0100478:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010047b:	5b                   	pop    %ebx
f010047c:	5e                   	pop    %esi
f010047d:	5f                   	pop    %edi
f010047e:	5d                   	pop    %ebp
f010047f:	c3                   	ret    

f0100480 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100480:	80 3d 34 65 11 f0 00 	cmpb   $0x0,0xf0116534
f0100487:	74 11                	je     f010049a <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100489:	55                   	push   %ebp
f010048a:	89 e5                	mov    %esp,%ebp
f010048c:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f010048f:	b8 1c 01 10 f0       	mov    $0xf010011c,%eax
f0100494:	e8 a2 fc ff ff       	call   f010013b <cons_intr>
}
f0100499:	c9                   	leave  
f010049a:	f3 c3                	repz ret 

f010049c <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010049c:	55                   	push   %ebp
f010049d:	89 e5                	mov    %esp,%ebp
f010049f:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004a2:	b8 7e 01 10 f0       	mov    $0xf010017e,%eax
f01004a7:	e8 8f fc ff ff       	call   f010013b <cons_intr>
}
f01004ac:	c9                   	leave  
f01004ad:	c3                   	ret    

f01004ae <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004ae:	55                   	push   %ebp
f01004af:	89 e5                	mov    %esp,%ebp
f01004b1:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004b4:	e8 c7 ff ff ff       	call   f0100480 <serial_intr>
	kbd_intr();
f01004b9:	e8 de ff ff ff       	call   f010049c <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004be:	a1 20 65 11 f0       	mov    0xf0116520,%eax
f01004c3:	3b 05 24 65 11 f0    	cmp    0xf0116524,%eax
f01004c9:	74 26                	je     f01004f1 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004cb:	8d 50 01             	lea    0x1(%eax),%edx
f01004ce:	89 15 20 65 11 f0    	mov    %edx,0xf0116520
f01004d4:	0f b6 88 20 63 11 f0 	movzbl -0xfee9ce0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004db:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004dd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004e3:	75 11                	jne    f01004f6 <cons_getc+0x48>
			cons.rpos = 0;
f01004e5:	c7 05 20 65 11 f0 00 	movl   $0x0,0xf0116520
f01004ec:	00 00 00 
f01004ef:	eb 05                	jmp    f01004f6 <cons_getc+0x48>
		return c;
	}
	return 0;
f01004f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01004f6:	c9                   	leave  
f01004f7:	c3                   	ret    

f01004f8 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01004f8:	55                   	push   %ebp
f01004f9:	89 e5                	mov    %esp,%ebp
f01004fb:	57                   	push   %edi
f01004fc:	56                   	push   %esi
f01004fd:	53                   	push   %ebx
f01004fe:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100501:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100508:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010050f:	5a a5 
	if (*cp != 0xA55A) {
f0100511:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100518:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010051c:	74 11                	je     f010052f <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010051e:	c7 05 30 65 11 f0 b4 	movl   $0x3b4,0xf0116530
f0100525:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100528:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010052d:	eb 16                	jmp    f0100545 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010052f:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100536:	c7 05 30 65 11 f0 d4 	movl   $0x3d4,0xf0116530
f010053d:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100540:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f0100545:	8b 3d 30 65 11 f0    	mov    0xf0116530,%edi
f010054b:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100550:	89 fa                	mov    %edi,%edx
f0100552:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100553:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100556:	89 da                	mov    %ebx,%edx
f0100558:	ec                   	in     (%dx),%al
f0100559:	0f b6 c8             	movzbl %al,%ecx
f010055c:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010055f:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100564:	89 fa                	mov    %edi,%edx
f0100566:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100567:	89 da                	mov    %ebx,%edx
f0100569:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010056a:	89 35 2c 65 11 f0    	mov    %esi,0xf011652c
	crt_pos = pos;
f0100570:	0f b6 c0             	movzbl %al,%eax
f0100573:	09 c8                	or     %ecx,%eax
f0100575:	66 a3 28 65 11 f0    	mov    %ax,0xf0116528
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010057b:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100580:	b8 00 00 00 00       	mov    $0x0,%eax
f0100585:	89 f2                	mov    %esi,%edx
f0100587:	ee                   	out    %al,(%dx)
f0100588:	ba fb 03 00 00       	mov    $0x3fb,%edx
f010058d:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100592:	ee                   	out    %al,(%dx)
f0100593:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100598:	b8 0c 00 00 00       	mov    $0xc,%eax
f010059d:	89 da                	mov    %ebx,%edx
f010059f:	ee                   	out    %al,(%dx)
f01005a0:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01005aa:	ee                   	out    %al,(%dx)
f01005ab:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005b0:	b8 03 00 00 00       	mov    $0x3,%eax
f01005b5:	ee                   	out    %al,(%dx)
f01005b6:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005bb:	b8 00 00 00 00       	mov    $0x0,%eax
f01005c0:	ee                   	out    %al,(%dx)
f01005c1:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005c6:	b8 01 00 00 00       	mov    $0x1,%eax
f01005cb:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005cc:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005d1:	ec                   	in     (%dx),%al
f01005d2:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005d4:	3c ff                	cmp    $0xff,%al
f01005d6:	0f 95 05 34 65 11 f0 	setne  0xf0116534
f01005dd:	89 f2                	mov    %esi,%edx
f01005df:	ec                   	in     (%dx),%al
f01005e0:	89 da                	mov    %ebx,%edx
f01005e2:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005e3:	80 f9 ff             	cmp    $0xff,%cl
f01005e6:	75 10                	jne    f01005f8 <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005e8:	83 ec 0c             	sub    $0xc,%esp
f01005eb:	68 59 36 10 f0       	push   $0xf0103659
f01005f0:	e8 77 20 00 00       	call   f010266c <cprintf>
f01005f5:	83 c4 10             	add    $0x10,%esp
}
f01005f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005fb:	5b                   	pop    %ebx
f01005fc:	5e                   	pop    %esi
f01005fd:	5f                   	pop    %edi
f01005fe:	5d                   	pop    %ebp
f01005ff:	c3                   	ret    

f0100600 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100600:	55                   	push   %ebp
f0100601:	89 e5                	mov    %esp,%ebp
f0100603:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f0100606:	8b 45 08             	mov    0x8(%ebp),%eax
f0100609:	e8 89 fc ff ff       	call   f0100297 <cons_putc>
}
f010060e:	c9                   	leave  
f010060f:	c3                   	ret    

f0100610 <getchar>:

int
getchar(void)
{
f0100610:	55                   	push   %ebp
f0100611:	89 e5                	mov    %esp,%ebp
f0100613:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f0100616:	e8 93 fe ff ff       	call   f01004ae <cons_getc>
f010061b:	85 c0                	test   %eax,%eax
f010061d:	74 f7                	je     f0100616 <getchar+0x6>
		/* do nothing */;
	return c;
}
f010061f:	c9                   	leave  
f0100620:	c3                   	ret    

f0100621 <iscons>:

int
iscons(int fdnum)
{
f0100621:	55                   	push   %ebp
f0100622:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100624:	b8 01 00 00 00       	mov    $0x1,%eax
f0100629:	5d                   	pop    %ebp
f010062a:	c3                   	ret    

f010062b <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010062b:	55                   	push   %ebp
f010062c:	89 e5                	mov    %esp,%ebp
f010062e:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100631:	68 a0 38 10 f0       	push   $0xf01038a0
f0100636:	68 be 38 10 f0       	push   $0xf01038be
f010063b:	68 c3 38 10 f0       	push   $0xf01038c3
f0100640:	e8 27 20 00 00       	call   f010266c <cprintf>
f0100645:	83 c4 0c             	add    $0xc,%esp
f0100648:	68 2c 39 10 f0       	push   $0xf010392c
f010064d:	68 cc 38 10 f0       	push   $0xf01038cc
f0100652:	68 c3 38 10 f0       	push   $0xf01038c3
f0100657:	e8 10 20 00 00       	call   f010266c <cprintf>
	return 0;
}
f010065c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100661:	c9                   	leave  
f0100662:	c3                   	ret    

f0100663 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100663:	55                   	push   %ebp
f0100664:	89 e5                	mov    %esp,%ebp
f0100666:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100669:	68 d5 38 10 f0       	push   $0xf01038d5
f010066e:	e8 f9 1f 00 00       	call   f010266c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100673:	83 c4 08             	add    $0x8,%esp
f0100676:	68 0c 00 10 00       	push   $0x10000c
f010067b:	68 54 39 10 f0       	push   $0xf0103954
f0100680:	e8 e7 1f 00 00       	call   f010266c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100685:	83 c4 0c             	add    $0xc,%esp
f0100688:	68 0c 00 10 00       	push   $0x10000c
f010068d:	68 0c 00 10 f0       	push   $0xf010000c
f0100692:	68 7c 39 10 f0       	push   $0xf010397c
f0100697:	e8 d0 1f 00 00       	call   f010266c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f010069c:	83 c4 0c             	add    $0xc,%esp
f010069f:	68 e1 35 10 00       	push   $0x1035e1
f01006a4:	68 e1 35 10 f0       	push   $0xf01035e1
f01006a9:	68 a0 39 10 f0       	push   $0xf01039a0
f01006ae:	e8 b9 1f 00 00       	call   f010266c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006b3:	83 c4 0c             	add    $0xc,%esp
f01006b6:	68 00 63 11 00       	push   $0x116300
f01006bb:	68 00 63 11 f0       	push   $0xf0116300
f01006c0:	68 c4 39 10 f0       	push   $0xf01039c4
f01006c5:	e8 a2 1f 00 00       	call   f010266c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006ca:	83 c4 0c             	add    $0xc,%esp
f01006cd:	68 70 69 11 00       	push   $0x116970
f01006d2:	68 70 69 11 f0       	push   $0xf0116970
f01006d7:	68 e8 39 10 f0       	push   $0xf01039e8
f01006dc:	e8 8b 1f 00 00       	call   f010266c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006e1:	b8 6f 6d 11 f0       	mov    $0xf0116d6f,%eax
f01006e6:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f01006eb:	83 c4 08             	add    $0x8,%esp
f01006ee:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f01006f3:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f01006f9:	85 c0                	test   %eax,%eax
f01006fb:	0f 48 c2             	cmovs  %edx,%eax
f01006fe:	c1 f8 0a             	sar    $0xa,%eax
f0100701:	50                   	push   %eax
f0100702:	68 0c 3a 10 f0       	push   $0xf0103a0c
f0100707:	e8 60 1f 00 00       	call   f010266c <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010070c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100711:	c9                   	leave  
f0100712:	c3                   	ret    

f0100713 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100713:	55                   	push   %ebp
f0100714:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f0100716:	b8 00 00 00 00       	mov    $0x0,%eax
f010071b:	5d                   	pop    %ebp
f010071c:	c3                   	ret    

f010071d <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f010071d:	55                   	push   %ebp
f010071e:	89 e5                	mov    %esp,%ebp
f0100720:	57                   	push   %edi
f0100721:	56                   	push   %esi
f0100722:	53                   	push   %ebx
f0100723:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100726:	68 38 3a 10 f0       	push   $0xf0103a38
f010072b:	e8 3c 1f 00 00       	call   f010266c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100730:	c7 04 24 5c 3a 10 f0 	movl   $0xf0103a5c,(%esp)
f0100737:	e8 30 1f 00 00       	call   f010266c <cprintf>
f010073c:	83 c4 10             	add    $0x10,%esp


	while (1) {
		buf = readline("K> ");
f010073f:	83 ec 0c             	sub    $0xc,%esp
f0100742:	68 ee 38 10 f0       	push   $0xf01038ee
f0100747:	e8 b2 27 00 00       	call   f0102efe <readline>
f010074c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010074e:	83 c4 10             	add    $0x10,%esp
f0100751:	85 c0                	test   %eax,%eax
f0100753:	74 ea                	je     f010073f <monitor+0x22>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100755:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010075c:	be 00 00 00 00       	mov    $0x0,%esi
f0100761:	eb 0a                	jmp    f010076d <monitor+0x50>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100763:	c6 03 00             	movb   $0x0,(%ebx)
f0100766:	89 f7                	mov    %esi,%edi
f0100768:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010076b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010076d:	0f b6 03             	movzbl (%ebx),%eax
f0100770:	84 c0                	test   %al,%al
f0100772:	74 63                	je     f01007d7 <monitor+0xba>
f0100774:	83 ec 08             	sub    $0x8,%esp
f0100777:	0f be c0             	movsbl %al,%eax
f010077a:	50                   	push   %eax
f010077b:	68 f2 38 10 f0       	push   $0xf01038f2
f0100780:	e8 93 29 00 00       	call   f0103118 <strchr>
f0100785:	83 c4 10             	add    $0x10,%esp
f0100788:	85 c0                	test   %eax,%eax
f010078a:	75 d7                	jne    f0100763 <monitor+0x46>
			*buf++ = 0;
		if (*buf == 0)
f010078c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010078f:	74 46                	je     f01007d7 <monitor+0xba>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100791:	83 fe 0f             	cmp    $0xf,%esi
f0100794:	75 14                	jne    f01007aa <monitor+0x8d>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100796:	83 ec 08             	sub    $0x8,%esp
f0100799:	6a 10                	push   $0x10
f010079b:	68 f7 38 10 f0       	push   $0xf01038f7
f01007a0:	e8 c7 1e 00 00       	call   f010266c <cprintf>
f01007a5:	83 c4 10             	add    $0x10,%esp
f01007a8:	eb 95                	jmp    f010073f <monitor+0x22>
			return 0;
		}
		argv[argc++] = buf;
f01007aa:	8d 7e 01             	lea    0x1(%esi),%edi
f01007ad:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007b1:	eb 03                	jmp    f01007b6 <monitor+0x99>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01007b3:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007b6:	0f b6 03             	movzbl (%ebx),%eax
f01007b9:	84 c0                	test   %al,%al
f01007bb:	74 ae                	je     f010076b <monitor+0x4e>
f01007bd:	83 ec 08             	sub    $0x8,%esp
f01007c0:	0f be c0             	movsbl %al,%eax
f01007c3:	50                   	push   %eax
f01007c4:	68 f2 38 10 f0       	push   $0xf01038f2
f01007c9:	e8 4a 29 00 00       	call   f0103118 <strchr>
f01007ce:	83 c4 10             	add    $0x10,%esp
f01007d1:	85 c0                	test   %eax,%eax
f01007d3:	74 de                	je     f01007b3 <monitor+0x96>
f01007d5:	eb 94                	jmp    f010076b <monitor+0x4e>
			buf++;
	}
	argv[argc] = 0;
f01007d7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01007de:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01007df:	85 f6                	test   %esi,%esi
f01007e1:	0f 84 58 ff ff ff    	je     f010073f <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01007e7:	83 ec 08             	sub    $0x8,%esp
f01007ea:	68 be 38 10 f0       	push   $0xf01038be
f01007ef:	ff 75 a8             	pushl  -0x58(%ebp)
f01007f2:	e8 c3 28 00 00       	call   f01030ba <strcmp>
f01007f7:	83 c4 10             	add    $0x10,%esp
f01007fa:	85 c0                	test   %eax,%eax
f01007fc:	74 1e                	je     f010081c <monitor+0xff>
f01007fe:	83 ec 08             	sub    $0x8,%esp
f0100801:	68 cc 38 10 f0       	push   $0xf01038cc
f0100806:	ff 75 a8             	pushl  -0x58(%ebp)
f0100809:	e8 ac 28 00 00       	call   f01030ba <strcmp>
f010080e:	83 c4 10             	add    $0x10,%esp
f0100811:	85 c0                	test   %eax,%eax
f0100813:	75 2f                	jne    f0100844 <monitor+0x127>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f0100815:	b8 01 00 00 00       	mov    $0x1,%eax
f010081a:	eb 05                	jmp    f0100821 <monitor+0x104>
		if (strcmp(argv[0], commands[i].name) == 0)
f010081c:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100821:	83 ec 04             	sub    $0x4,%esp
f0100824:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100827:	01 d0                	add    %edx,%eax
f0100829:	ff 75 08             	pushl  0x8(%ebp)
f010082c:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f010082f:	51                   	push   %ecx
f0100830:	56                   	push   %esi
f0100831:	ff 14 85 8c 3a 10 f0 	call   *-0xfefc574(,%eax,4)


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100838:	83 c4 10             	add    $0x10,%esp
f010083b:	85 c0                	test   %eax,%eax
f010083d:	78 1d                	js     f010085c <monitor+0x13f>
f010083f:	e9 fb fe ff ff       	jmp    f010073f <monitor+0x22>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100844:	83 ec 08             	sub    $0x8,%esp
f0100847:	ff 75 a8             	pushl  -0x58(%ebp)
f010084a:	68 14 39 10 f0       	push   $0xf0103914
f010084f:	e8 18 1e 00 00       	call   f010266c <cprintf>
f0100854:	83 c4 10             	add    $0x10,%esp
f0100857:	e9 e3 fe ff ff       	jmp    f010073f <monitor+0x22>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010085c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010085f:	5b                   	pop    %ebx
f0100860:	5e                   	pop    %esi
f0100861:	5f                   	pop    %edi
f0100862:	5d                   	pop    %ebp
f0100863:	c3                   	ret    

f0100864 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100864:	55                   	push   %ebp
f0100865:	89 e5                	mov    %esp,%ebp
f0100867:	56                   	push   %esi
f0100868:	53                   	push   %ebx
f0100869:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f010086b:	83 ec 0c             	sub    $0xc,%esp
f010086e:	50                   	push   %eax
f010086f:	e8 91 1d 00 00       	call   f0102605 <mc146818_read>
f0100874:	89 c6                	mov    %eax,%esi
f0100876:	83 c3 01             	add    $0x1,%ebx
f0100879:	89 1c 24             	mov    %ebx,(%esp)
f010087c:	e8 84 1d 00 00       	call   f0102605 <mc146818_read>
f0100881:	c1 e0 08             	shl    $0x8,%eax
f0100884:	09 f0                	or     %esi,%eax
}
f0100886:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100889:	5b                   	pop    %ebx
f010088a:	5e                   	pop    %esi
f010088b:	5d                   	pop    %ebp
f010088c:	c3                   	ret    

f010088d <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f010088d:	89 d1                	mov    %edx,%ecx
f010088f:	c1 e9 16             	shr    $0x16,%ecx
f0100892:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100895:	a8 01                	test   $0x1,%al
f0100897:	74 52                	je     f01008eb <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100899:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010089e:	89 c1                	mov    %eax,%ecx
f01008a0:	c1 e9 0c             	shr    $0xc,%ecx
f01008a3:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f01008a9:	72 1b                	jb     f01008c6 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01008ab:	55                   	push   %ebp
f01008ac:	89 e5                	mov    %esp,%ebp
f01008ae:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01008b1:	50                   	push   %eax
f01008b2:	68 9c 3a 10 f0       	push   $0xf0103a9c
f01008b7:	68 ec 02 00 00       	push   $0x2ec
f01008bc:	68 14 42 10 f0       	push   $0xf0104214
f01008c1:	e8 c5 f7 ff ff       	call   f010008b <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f01008c6:	c1 ea 0c             	shr    $0xc,%edx
f01008c9:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f01008cf:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f01008d6:	89 c2                	mov    %eax,%edx
f01008d8:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f01008db:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01008e0:	85 d2                	test   %edx,%edx
f01008e2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f01008e7:	0f 44 c2             	cmove  %edx,%eax
f01008ea:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f01008eb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f01008f0:	c3                   	ret    

f01008f1 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
//暂时用作页分配器，真实的物理页分配器是page_alloc函数
static void *
boot_alloc(uint32_t n)
{
f01008f1:	55                   	push   %ebp
f01008f2:	89 e5                	mov    %esp,%ebp
f01008f4:	53                   	push   %ebx
f01008f5:	83 ec 04             	sub    $0x4,%esp
f01008f8:	89 c2                	mov    %eax,%edx
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	//nextfree为静态变量，初始时指向开始指向内核bss段的末尾
	/*根据mem_init()函数可知，kern_pgdir初始化时第一次调用boot_alloc(),
	  故kern_pgdir指向end*/
	if (!nextfree) {
f01008fa:	83 3d 38 65 11 f0 00 	cmpl   $0x0,0xf0116538
f0100901:	75 0f                	jne    f0100912 <boot_alloc+0x21>
		extern char end[];
		//end 在哪里？？？
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100903:	b8 6f 79 11 f0       	mov    $0xf011796f,%eax
f0100908:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010090d:	a3 38 65 11 f0       	mov    %eax,0xf0116538
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//
	result = KADDR(PADDR(nextfree));
f0100912:	a1 38 65 11 f0       	mov    0xf0116538,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100917:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010091c:	77 12                	ja     f0100930 <boot_alloc+0x3f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010091e:	50                   	push   %eax
f010091f:	68 c0 3a 10 f0       	push   $0xf0103ac0
f0100924:	6a 6f                	push   $0x6f
f0100926:	68 14 42 10 f0       	push   $0xf0104214
f010092b:	e8 5b f7 ff ff       	call   f010008b <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100930:	8d 88 00 00 00 10    	lea    0x10000000(%eax),%ecx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100936:	89 cb                	mov    %ecx,%ebx
f0100938:	c1 eb 0c             	shr    $0xc,%ebx
f010093b:	39 1d 64 69 11 f0    	cmp    %ebx,0xf0116964
f0100941:	77 12                	ja     f0100955 <boot_alloc+0x64>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100943:	51                   	push   %ecx
f0100944:	68 9c 3a 10 f0       	push   $0xf0103a9c
f0100949:	6a 6f                	push   $0x6f
f010094b:	68 14 42 10 f0       	push   $0xf0104214
f0100950:	e8 36 f7 ff ff       	call   f010008b <_panic>
	//ROUNDUP()用作页对齐
	nextfree += ROUNDUP(n, PGSIZE);
f0100955:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f010095b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100961:	01 c2                	add    %eax,%edx
f0100963:	89 15 38 65 11 f0    	mov    %edx,0xf0116538
	return result;
}
f0100969:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010096c:	c9                   	leave  
f010096d:	c3                   	ret    

f010096e <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f010096e:	55                   	push   %ebp
f010096f:	89 e5                	mov    %esp,%ebp
f0100971:	57                   	push   %edi
f0100972:	56                   	push   %esi
f0100973:	53                   	push   %ebx
f0100974:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100977:	84 c0                	test   %al,%al
f0100979:	0f 85 81 02 00 00    	jne    f0100c00 <check_page_free_list+0x292>
f010097f:	e9 8e 02 00 00       	jmp    f0100c12 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100984:	83 ec 04             	sub    $0x4,%esp
f0100987:	68 e4 3a 10 f0       	push   $0xf0103ae4
f010098c:	68 2d 02 00 00       	push   $0x22d
f0100991:	68 14 42 10 f0       	push   $0xf0104214
f0100996:	e8 f0 f6 ff ff       	call   f010008b <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f010099b:	8d 55 d8             	lea    -0x28(%ebp),%edx
f010099e:	89 55 e0             	mov    %edx,-0x20(%ebp)
f01009a1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01009a4:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f01009a7:	89 c2                	mov    %eax,%edx
f01009a9:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f01009af:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f01009b5:	0f 95 c2             	setne  %dl
f01009b8:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01009bb:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01009bf:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01009c1:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009c5:	8b 00                	mov    (%eax),%eax
f01009c7:	85 c0                	test   %eax,%eax
f01009c9:	75 dc                	jne    f01009a7 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01009cb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01009d4:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009d7:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01009da:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01009dc:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009df:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009e4:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01009e9:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f01009ef:	eb 53                	jmp    f0100a44 <check_page_free_list+0xd6>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01009f1:	89 d8                	mov    %ebx,%eax
f01009f3:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01009f9:	c1 f8 03             	sar    $0x3,%eax
f01009fc:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01009ff:	89 c2                	mov    %eax,%edx
f0100a01:	c1 ea 16             	shr    $0x16,%edx
f0100a04:	39 f2                	cmp    %esi,%edx
f0100a06:	73 3a                	jae    f0100a42 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a08:	89 c2                	mov    %eax,%edx
f0100a0a:	c1 ea 0c             	shr    $0xc,%edx
f0100a0d:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100a13:	72 12                	jb     f0100a27 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a15:	50                   	push   %eax
f0100a16:	68 9c 3a 10 f0       	push   $0xf0103a9c
f0100a1b:	6a 52                	push   $0x52
f0100a1d:	68 20 42 10 f0       	push   $0xf0104220
f0100a22:	e8 64 f6 ff ff       	call   f010008b <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a27:	83 ec 04             	sub    $0x4,%esp
f0100a2a:	68 80 00 00 00       	push   $0x80
f0100a2f:	68 97 00 00 00       	push   $0x97
f0100a34:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a39:	50                   	push   %eax
f0100a3a:	e8 16 27 00 00       	call   f0103155 <memset>
f0100a3f:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a42:	8b 1b                	mov    (%ebx),%ebx
f0100a44:	85 db                	test   %ebx,%ebx
f0100a46:	75 a9                	jne    f01009f1 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100a48:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a4d:	e8 9f fe ff ff       	call   f01008f1 <boot_alloc>
f0100a52:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a55:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100a5b:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
		assert(pp < pages + npages);
f0100a61:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0100a66:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100a69:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100a6c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100a6f:	be 00 00 00 00       	mov    $0x0,%esi
f0100a74:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a77:	e9 30 01 00 00       	jmp    f0100bac <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100a7c:	39 ca                	cmp    %ecx,%edx
f0100a7e:	73 19                	jae    f0100a99 <check_page_free_list+0x12b>
f0100a80:	68 2e 42 10 f0       	push   $0xf010422e
f0100a85:	68 3a 42 10 f0       	push   $0xf010423a
f0100a8a:	68 47 02 00 00       	push   $0x247
f0100a8f:	68 14 42 10 f0       	push   $0xf0104214
f0100a94:	e8 f2 f5 ff ff       	call   f010008b <_panic>
		assert(pp < pages + npages);
f0100a99:	39 fa                	cmp    %edi,%edx
f0100a9b:	72 19                	jb     f0100ab6 <check_page_free_list+0x148>
f0100a9d:	68 4f 42 10 f0       	push   $0xf010424f
f0100aa2:	68 3a 42 10 f0       	push   $0xf010423a
f0100aa7:	68 48 02 00 00       	push   $0x248
f0100aac:	68 14 42 10 f0       	push   $0xf0104214
f0100ab1:	e8 d5 f5 ff ff       	call   f010008b <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ab6:	89 d0                	mov    %edx,%eax
f0100ab8:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100abb:	a8 07                	test   $0x7,%al
f0100abd:	74 19                	je     f0100ad8 <check_page_free_list+0x16a>
f0100abf:	68 08 3b 10 f0       	push   $0xf0103b08
f0100ac4:	68 3a 42 10 f0       	push   $0xf010423a
f0100ac9:	68 49 02 00 00       	push   $0x249
f0100ace:	68 14 42 10 f0       	push   $0xf0104214
f0100ad3:	e8 b3 f5 ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ad8:	c1 f8 03             	sar    $0x3,%eax
f0100adb:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ade:	85 c0                	test   %eax,%eax
f0100ae0:	75 19                	jne    f0100afb <check_page_free_list+0x18d>
f0100ae2:	68 63 42 10 f0       	push   $0xf0104263
f0100ae7:	68 3a 42 10 f0       	push   $0xf010423a
f0100aec:	68 4c 02 00 00       	push   $0x24c
f0100af1:	68 14 42 10 f0       	push   $0xf0104214
f0100af6:	e8 90 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100afb:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100b00:	75 19                	jne    f0100b1b <check_page_free_list+0x1ad>
f0100b02:	68 74 42 10 f0       	push   $0xf0104274
f0100b07:	68 3a 42 10 f0       	push   $0xf010423a
f0100b0c:	68 4d 02 00 00       	push   $0x24d
f0100b11:	68 14 42 10 f0       	push   $0xf0104214
f0100b16:	e8 70 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b1b:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b20:	75 19                	jne    f0100b3b <check_page_free_list+0x1cd>
f0100b22:	68 3c 3b 10 f0       	push   $0xf0103b3c
f0100b27:	68 3a 42 10 f0       	push   $0xf010423a
f0100b2c:	68 4e 02 00 00       	push   $0x24e
f0100b31:	68 14 42 10 f0       	push   $0xf0104214
f0100b36:	e8 50 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b3b:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100b40:	75 19                	jne    f0100b5b <check_page_free_list+0x1ed>
f0100b42:	68 8d 42 10 f0       	push   $0xf010428d
f0100b47:	68 3a 42 10 f0       	push   $0xf010423a
f0100b4c:	68 4f 02 00 00       	push   $0x24f
f0100b51:	68 14 42 10 f0       	push   $0xf0104214
f0100b56:	e8 30 f5 ff ff       	call   f010008b <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100b5b:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100b60:	76 3f                	jbe    f0100ba1 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b62:	89 c3                	mov    %eax,%ebx
f0100b64:	c1 eb 0c             	shr    $0xc,%ebx
f0100b67:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100b6a:	77 12                	ja     f0100b7e <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b6c:	50                   	push   %eax
f0100b6d:	68 9c 3a 10 f0       	push   $0xf0103a9c
f0100b72:	6a 52                	push   $0x52
f0100b74:	68 20 42 10 f0       	push   $0xf0104220
f0100b79:	e8 0d f5 ff ff       	call   f010008b <_panic>
f0100b7e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b83:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100b86:	76 1e                	jbe    f0100ba6 <check_page_free_list+0x238>
f0100b88:	68 60 3b 10 f0       	push   $0xf0103b60
f0100b8d:	68 3a 42 10 f0       	push   $0xf010423a
f0100b92:	68 50 02 00 00       	push   $0x250
f0100b97:	68 14 42 10 f0       	push   $0xf0104214
f0100b9c:	e8 ea f4 ff ff       	call   f010008b <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100ba1:	83 c6 01             	add    $0x1,%esi
f0100ba4:	eb 04                	jmp    f0100baa <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100ba6:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100baa:	8b 12                	mov    (%edx),%edx
f0100bac:	85 d2                	test   %edx,%edx
f0100bae:	0f 85 c8 fe ff ff    	jne    f0100a7c <check_page_free_list+0x10e>
f0100bb4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100bb7:	85 f6                	test   %esi,%esi
f0100bb9:	7f 19                	jg     f0100bd4 <check_page_free_list+0x266>
f0100bbb:	68 a7 42 10 f0       	push   $0xf01042a7
f0100bc0:	68 3a 42 10 f0       	push   $0xf010423a
f0100bc5:	68 58 02 00 00       	push   $0x258
f0100bca:	68 14 42 10 f0       	push   $0xf0104214
f0100bcf:	e8 b7 f4 ff ff       	call   f010008b <_panic>
	assert(nfree_extmem > 0);
f0100bd4:	85 db                	test   %ebx,%ebx
f0100bd6:	7f 19                	jg     f0100bf1 <check_page_free_list+0x283>
f0100bd8:	68 b9 42 10 f0       	push   $0xf01042b9
f0100bdd:	68 3a 42 10 f0       	push   $0xf010423a
f0100be2:	68 59 02 00 00       	push   $0x259
f0100be7:	68 14 42 10 f0       	push   $0xf0104214
f0100bec:	e8 9a f4 ff ff       	call   f010008b <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100bf1:	83 ec 0c             	sub    $0xc,%esp
f0100bf4:	68 a8 3b 10 f0       	push   $0xf0103ba8
f0100bf9:	e8 6e 1a 00 00       	call   f010266c <cprintf>
}
f0100bfe:	eb 29                	jmp    f0100c29 <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100c00:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0100c05:	85 c0                	test   %eax,%eax
f0100c07:	0f 85 8e fd ff ff    	jne    f010099b <check_page_free_list+0x2d>
f0100c0d:	e9 72 fd ff ff       	jmp    f0100984 <check_page_free_list+0x16>
f0100c12:	83 3d 3c 65 11 f0 00 	cmpl   $0x0,0xf011653c
f0100c19:	0f 84 65 fd ff ff    	je     f0100984 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c1f:	be 00 04 00 00       	mov    $0x400,%esi
f0100c24:	e9 c0 fd ff ff       	jmp    f01009e9 <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100c29:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c2c:	5b                   	pop    %ebx
f0100c2d:	5e                   	pop    %esi
f0100c2e:	5f                   	pop    %edi
f0100c2f:	5d                   	pop    %ebp
f0100c30:	c3                   	ret    

f0100c31 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100c31:	55                   	push   %ebp
f0100c32:	89 e5                	mov    %esp,%ebp
f0100c34:	57                   	push   %edi
f0100c35:	56                   	push   %esi
f0100c36:	53                   	push   %ebx
f0100c37:	83 ec 0c             	sub    $0xc,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	//？？
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
f0100c3a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c3f:	e8 ad fc ff ff       	call   f01008f1 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c44:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100c49:	77 15                	ja     f0100c60 <page_init+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c4b:	50                   	push   %eax
f0100c4c:	68 c0 3a 10 f0       	push   $0xf0103ac0
f0100c51:	68 1d 01 00 00       	push   $0x11d
f0100c56:	68 14 42 10 f0       	push   $0xf0104214
f0100c5b:	e8 2b f4 ff ff       	call   f010008b <_panic>
f0100c60:	05 00 00 00 10       	add    $0x10000000,%eax
f0100c65:	c1 e8 0c             	shr    $0xc,%eax
	for (i = 1; i < npages; i++) {
		if (i >= npages_basemem && i < pgnum)
f0100c68:	8b 3d 40 65 11 f0    	mov    0xf0116540,%edi
f0100c6e:	8b 35 3c 65 11 f0    	mov    0xf011653c,%esi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	//？？
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100c74:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100c79:	ba 01 00 00 00       	mov    $0x1,%edx
f0100c7e:	eb 2f                	jmp    f0100caf <page_init+0x7e>
		if (i >= npages_basemem && i < pgnum)
f0100c80:	39 c2                	cmp    %eax,%edx
f0100c82:	73 04                	jae    f0100c88 <page_init+0x57>
f0100c84:	39 fa                	cmp    %edi,%edx
f0100c86:	73 24                	jae    f0100cac <page_init+0x7b>
			continue;
		pages[i].pp_ref = 0;
f0100c88:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100c8f:	89 cb                	mov    %ecx,%ebx
f0100c91:	03 1d 6c 69 11 f0    	add    0xf011696c,%ebx
f0100c97:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f0100c9d:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f0100c9f:	89 ce                	mov    %ecx,%esi
f0100ca1:	03 35 6c 69 11 f0    	add    0xf011696c,%esi
f0100ca7:	b9 01 00 00 00       	mov    $0x1,%ecx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	//？？
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100cac:	83 c2 01             	add    $0x1,%edx
f0100caf:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100cb5:	72 c9                	jb     f0100c80 <page_init+0x4f>
f0100cb7:	84 c9                	test   %cl,%cl
f0100cb9:	74 06                	je     f0100cc1 <page_init+0x90>
f0100cbb:	89 35 3c 65 11 f0    	mov    %esi,0xf011653c
			continue;
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100cc4:	5b                   	pop    %ebx
f0100cc5:	5e                   	pop    %esi
f0100cc6:	5f                   	pop    %edi
f0100cc7:	5d                   	pop    %ebp
f0100cc8:	c3                   	ret    

f0100cc9 <page_alloc>:
//
// Hint: use page2kva and memset
//分配一个物理页面
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100cc9:	55                   	push   %ebp
f0100cca:	89 e5                	mov    %esp,%ebp
f0100ccc:	53                   	push   %ebx
f0100ccd:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo *result = NULL;
	//如果存在空闲链表
	if (page_free_list) {
f0100cd0:	8b 1d 3c 65 11 f0    	mov    0xf011653c,%ebx
f0100cd6:	85 db                	test   %ebx,%ebx
f0100cd8:	74 58                	je     f0100d32 <page_alloc+0x69>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100cda:	8b 03                	mov    (%ebx),%eax
f0100cdc:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
		result->pp_link = NULL;
f0100ce1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		//??????
		if (alloc_flags & ALLOC_ZERO)
f0100ce7:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100ceb:	74 45                	je     f0100d32 <page_alloc+0x69>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ced:	89 d8                	mov    %ebx,%eax
f0100cef:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100cf5:	c1 f8 03             	sar    $0x3,%eax
f0100cf8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cfb:	89 c2                	mov    %eax,%edx
f0100cfd:	c1 ea 0c             	shr    $0xc,%edx
f0100d00:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100d06:	72 12                	jb     f0100d1a <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100d08:	50                   	push   %eax
f0100d09:	68 9c 3a 10 f0       	push   $0xf0103a9c
f0100d0e:	6a 52                	push   $0x52
f0100d10:	68 20 42 10 f0       	push   $0xf0104220
f0100d15:	e8 71 f3 ff ff       	call   f010008b <_panic>
			memset(page2kva(result), 0, PGSIZE);
f0100d1a:	83 ec 04             	sub    $0x4,%esp
f0100d1d:	68 00 10 00 00       	push   $0x1000
f0100d22:	6a 00                	push   $0x0
f0100d24:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d29:	50                   	push   %eax
f0100d2a:	e8 26 24 00 00       	call   f0103155 <memset>
f0100d2f:	83 c4 10             	add    $0x10,%esp
	}
	return result;
}
f0100d32:	89 d8                	mov    %ebx,%eax
f0100d34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d37:	c9                   	leave  
f0100d38:	c3                   	ret    

f0100d39 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100d39:	55                   	push   %ebp
f0100d3a:	89 e5                	mov    %esp,%ebp
f0100d3c:	83 ec 08             	sub    $0x8,%esp
f0100d3f:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	//容错判断
	assert(pp != NULL);
f0100d42:	85 c0                	test   %eax,%eax
f0100d44:	75 19                	jne    f0100d5f <page_free+0x26>
f0100d46:	68 ca 42 10 f0       	push   $0xf01042ca
f0100d4b:	68 3a 42 10 f0       	push   $0xf010423a
f0100d50:	68 50 01 00 00       	push   $0x150
f0100d55:	68 14 42 10 f0       	push   $0xf0104214
f0100d5a:	e8 2c f3 ff ff       	call   f010008b <_panic>
	assert(pp->pp_ref == 0);
f0100d5f:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100d64:	74 19                	je     f0100d7f <page_free+0x46>
f0100d66:	68 d5 42 10 f0       	push   $0xf01042d5
f0100d6b:	68 3a 42 10 f0       	push   $0xf010423a
f0100d70:	68 51 01 00 00       	push   $0x151
f0100d75:	68 14 42 10 f0       	push   $0xf0104214
f0100d7a:	e8 0c f3 ff ff       	call   f010008b <_panic>
	assert(pp->pp_link == NULL);
f0100d7f:	83 38 00             	cmpl   $0x0,(%eax)
f0100d82:	74 19                	je     f0100d9d <page_free+0x64>
f0100d84:	68 e5 42 10 f0       	push   $0xf01042e5
f0100d89:	68 3a 42 10 f0       	push   $0xf010423a
f0100d8e:	68 52 01 00 00       	push   $0x152
f0100d93:	68 14 42 10 f0       	push   $0xf0104214
f0100d98:	e8 ee f2 ff ff       	call   f010008b <_panic>
	
	//释放物理页面
      	pp->pp_link = page_free_list;
f0100d9d:	8b 15 3c 65 11 f0    	mov    0xf011653c,%edx
f0100da3:	89 10                	mov    %edx,(%eax)
      	page_free_list = pp;
f0100da5:	a3 3c 65 11 f0       	mov    %eax,0xf011653c
}
f0100daa:	c9                   	leave  
f0100dab:	c3                   	ret    

f0100dac <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100dac:	55                   	push   %ebp
f0100dad:	89 e5                	mov    %esp,%ebp
f0100daf:	83 ec 08             	sub    $0x8,%esp
f0100db2:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100db5:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100db9:	83 e8 01             	sub    $0x1,%eax
f0100dbc:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100dc0:	66 85 c0             	test   %ax,%ax
f0100dc3:	75 0c                	jne    f0100dd1 <page_decref+0x25>
		page_free(pp);
f0100dc5:	83 ec 0c             	sub    $0xc,%esp
f0100dc8:	52                   	push   %edx
f0100dc9:	e8 6b ff ff ff       	call   f0100d39 <page_free>
f0100dce:	83 c4 10             	add    $0x10,%esp
}
f0100dd1:	c9                   	leave  
f0100dd2:	c3                   	ret    

f0100dd3 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//返回虚拟地址所对应的页表项指针page table entry (PTE)
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100dd3:	55                   	push   %ebp
f0100dd4:	89 e5                	mov    %esp,%ebp
f0100dd6:	56                   	push   %esi
f0100dd7:	53                   	push   %ebx
f0100dd8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	//return NULL;
	//根据虚拟地址解析出页目录索引和页表索引，pdx--页目录索引 ptx -- 页表索引
	size_t pdx = PDX(va), ptx = PTX(va);
f0100ddb:	89 de                	mov    %ebx,%esi
f0100ddd:	c1 ee 0c             	shr    $0xc,%esi
f0100de0:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
f0100de6:	c1 eb 16             	shr    $0x16,%ebx
f0100de9:	c1 e3 02             	shl    $0x2,%ebx
f0100dec:	03 5d 08             	add    0x8(%ebp),%ebx
f0100def:	f6 03 01             	testb  $0x1,(%ebx)
f0100df2:	75 2d                	jne    f0100e21 <pgdir_walk+0x4e>
		if (!create) 
f0100df4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100df8:	74 59                	je     f0100e53 <pgdir_walk+0x80>
			return NULL;
		pp = page_alloc(ALLOC_ZERO);
f0100dfa:	83 ec 0c             	sub    $0xc,%esp
f0100dfd:	6a 01                	push   $0x1
f0100dff:	e8 c5 fe ff ff       	call   f0100cc9 <page_alloc>
		if (pp == NULL) 
f0100e04:	83 c4 10             	add    $0x10,%esp
f0100e07:	85 c0                	test   %eax,%eax
f0100e09:	74 4f                	je     f0100e5a <pgdir_walk+0x87>
			return NULL;
		pp->pp_ref++;
f0100e0b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		pgdir[pdx] = page2pa(pp) | PTE_W | PTE_U | PTE_P; 
f0100e10:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0100e16:	c1 f8 03             	sar    $0x3,%eax
f0100e19:	c1 e0 0c             	shl    $0xc,%eax
f0100e1c:	83 c8 07             	or     $0x7,%eax
f0100e1f:	89 03                	mov    %eax,(%ebx)
	} 
	
	//这里为什么要用 PTE_ADDR？？？
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
f0100e21:	8b 03                	mov    (%ebx),%eax
f0100e23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e28:	89 c2                	mov    %eax,%edx
f0100e2a:	c1 ea 0c             	shr    $0xc,%edx
f0100e2d:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0100e33:	72 15                	jb     f0100e4a <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e35:	50                   	push   %eax
f0100e36:	68 9c 3a 10 f0       	push   $0xf0103a9c
f0100e3b:	68 8f 01 00 00       	push   $0x18f
f0100e40:	68 14 42 10 f0       	push   $0xf0104214
f0100e45:	e8 41 f2 ff ff       	call   f010008b <_panic>
	return &pgtbl[ptx];
f0100e4a:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100e51:	eb 0c                	jmp    f0100e5f <pgdir_walk+0x8c>
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
		if (!create) 
			return NULL;
f0100e53:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e58:	eb 05                	jmp    f0100e5f <pgdir_walk+0x8c>
		pp = page_alloc(ALLOC_ZERO);
		if (pp == NULL) 
			return NULL;
f0100e5a:	b8 00 00 00 00       	mov    $0x0,%eax
	} 
	
	//这里为什么要用 PTE_ADDR？？？
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
	return &pgtbl[ptx];
}
f0100e5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e62:	5b                   	pop    %ebx
f0100e63:	5e                   	pop    %esi
f0100e64:	5d                   	pop    %ebp
f0100e65:	c3                   	ret    

f0100e66 <boot_map_region>:
// Hint: the TA solution uses pgdir_walk
//把虚拟地址空间范围[va, va+size)映射到物理空间[pa, pa+size)的映射关系加入到页表中
//这个函数主要的目的是为了设置虚拟地址UTOP之上的地址范围
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100e66:	55                   	push   %ebp
f0100e67:	89 e5                	mov    %esp,%ebp
f0100e69:	57                   	push   %edi
f0100e6a:	56                   	push   %esi
f0100e6b:	53                   	push   %ebx
f0100e6c:	83 ec 1c             	sub    $0x1c,%esp
f0100e6f:	89 c7                	mov    %eax,%edi
f0100e71:	89 d6                	mov    %edx,%esi
f0100e73:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	size_t i;
	//?????i < size??
	for (i = 0; i < size; i += PGSIZE) {
f0100e76:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		//??????| perm | PTE_P
		*pte = (pa + i) | perm | PTE_P;
f0100e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e7e:	83 c8 01             	or     $0x1,%eax
f0100e81:	89 45 e0             	mov    %eax,-0x20(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	//?????i < size??
	for (i = 0; i < size; i += PGSIZE) {
f0100e84:	eb 22                	jmp    f0100ea8 <boot_map_region+0x42>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f0100e86:	83 ec 04             	sub    $0x4,%esp
f0100e89:	6a 01                	push   $0x1
f0100e8b:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0100e8e:	50                   	push   %eax
f0100e8f:	57                   	push   %edi
f0100e90:	e8 3e ff ff ff       	call   f0100dd3 <pgdir_walk>
		//??????| perm | PTE_P
		*pte = (pa + i) | perm | PTE_P;
f0100e95:	89 da                	mov    %ebx,%edx
f0100e97:	03 55 08             	add    0x8(%ebp),%edx
f0100e9a:	0b 55 e0             	or     -0x20(%ebp),%edx
f0100e9d:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	//?????i < size??
	for (i = 0; i < size; i += PGSIZE) {
f0100e9f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100ea5:	83 c4 10             	add    $0x10,%esp
f0100ea8:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100eab:	72 d9                	jb     f0100e86 <boot_map_region+0x20>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		//??????| perm | PTE_P
		*pte = (pa + i) | perm | PTE_P;
	}
}
f0100ead:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100eb0:	5b                   	pop    %ebx
f0100eb1:	5e                   	pop    %esi
f0100eb2:	5f                   	pop    %edi
f0100eb3:	5d                   	pop    %ebp
f0100eb4:	c3                   	ret    

f0100eb5 <page_lookup>:
// Hint: the TA solution uses pgdir_walk and pa2page.
//返回虚拟地址所映射（对应）的物理页的PageInfo结构体的指针
//返回虚拟地址所对应的物理页指针
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100eb5:	55                   	push   %ebp
f0100eb6:	89 e5                	mov    %esp,%ebp
f0100eb8:	53                   	push   %ebx
f0100eb9:	83 ec 08             	sub    $0x8,%esp
f0100ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100ebf:	6a 01                	push   $0x1
f0100ec1:	ff 75 0c             	pushl  0xc(%ebp)
f0100ec4:	ff 75 08             	pushl  0x8(%ebp)
f0100ec7:	e8 07 ff ff ff       	call   f0100dd3 <pgdir_walk>
	//pte_store存页表项指针的地址，*pte_store表示页表项指针，即页表项地址，**pte_store表示页表项
	//pte_store????
	if (pte_store)
f0100ecc:	83 c4 10             	add    $0x10,%esp
f0100ecf:	85 db                	test   %ebx,%ebx
f0100ed1:	74 02                	je     f0100ed5 <page_lookup+0x20>
		*pte_store = pte;
f0100ed3:	89 03                	mov    %eax,(%ebx)
	if (pte == NULL || !(*pte & PTE_P)) 
f0100ed5:	85 c0                	test   %eax,%eax
f0100ed7:	74 30                	je     f0100f09 <page_lookup+0x54>
f0100ed9:	8b 00                	mov    (%eax),%eax
f0100edb:	a8 01                	test   $0x1,%al
f0100edd:	74 31                	je     f0100f10 <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100edf:	c1 e8 0c             	shr    $0xc,%eax
f0100ee2:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f0100ee8:	72 14                	jb     f0100efe <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f0100eea:	83 ec 04             	sub    $0x4,%esp
f0100eed:	68 cc 3b 10 f0       	push   $0xf0103bcc
f0100ef2:	6a 4b                	push   $0x4b
f0100ef4:	68 20 42 10 f0       	push   $0xf0104220
f0100ef9:	e8 8d f1 ff ff       	call   f010008b <_panic>
	return &pages[PGNUM(pa)];
f0100efe:	8b 15 6c 69 11 f0    	mov    0xf011696c,%edx
f0100f04:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		return NULL;
	return pa2page(PTE_ADDR(*pte));
f0100f07:	eb 0c                	jmp    f0100f15 <page_lookup+0x60>
	//pte_store存页表项指针的地址，*pte_store表示页表项指针，即页表项地址，**pte_store表示页表项
	//pte_store????
	if (pte_store)
		*pte_store = pte;
	if (pte == NULL || !(*pte & PTE_P)) 
		return NULL;
f0100f09:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f0e:	eb 05                	jmp    f0100f15 <page_lookup+0x60>
f0100f10:	b8 00 00 00 00       	mov    $0x0,%eax
	return pa2page(PTE_ADDR(*pte));
}
f0100f15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f18:	c9                   	leave  
f0100f19:	c3                   	ret    

f0100f1a <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f1a:	55                   	push   %ebp
f0100f1b:	89 e5                	mov    %esp,%ebp
f0100f1d:	53                   	push   %ebx
f0100f1e:	83 ec 18             	sub    $0x18,%esp
f0100f21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte = NULL;
f0100f24:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f0100f2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f2e:	50                   	push   %eax
f0100f2f:	53                   	push   %ebx
f0100f30:	ff 75 08             	pushl  0x8(%ebp)
f0100f33:	e8 7d ff ff ff       	call   f0100eb5 <page_lookup>
	if(pp == NULL)
f0100f38:	83 c4 10             	add    $0x10,%esp
f0100f3b:	85 c0                	test   %eax,%eax
f0100f3d:	74 18                	je     f0100f57 <page_remove+0x3d>
		return;
	*pte = (pte_t) 0; //将页表项内容置为空
f0100f3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100f42:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f48:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va); //tlb置为无效
	page_decref(pp); //减少引用
f0100f4b:	83 ec 0c             	sub    $0xc,%esp
f0100f4e:	50                   	push   %eax
f0100f4f:	e8 58 fe ff ff       	call   f0100dac <page_decref>
f0100f54:	83 c4 10             	add    $0x10,%esp
}
f0100f57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f5a:	c9                   	leave  
f0100f5b:	c3                   	ret    

f0100f5c <page_insert>:
// and page2pa.
//把一个物理内存中页pp与虚拟地址va建立映射关系。
//其实就是 更新页表
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100f5c:	55                   	push   %ebp
f0100f5d:	89 e5                	mov    %esp,%ebp
f0100f5f:	57                   	push   %edi
f0100f60:	56                   	push   %esi
f0100f61:	53                   	push   %ebx
f0100f62:	83 ec 10             	sub    $0x10,%esp
f0100f65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f68:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	//return 0;
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100f6b:	6a 01                	push   $0x1
f0100f6d:	57                   	push   %edi
f0100f6e:	ff 75 08             	pushl  0x8(%ebp)
f0100f71:	e8 5d fe ff ff       	call   f0100dd3 <pgdir_walk>
    if (pte == NULL)  
f0100f76:	83 c4 10             	add    $0x10,%esp
f0100f79:	85 c0                	test   %eax,%eax
f0100f7b:	74 38                	je     f0100fb5 <page_insert+0x59>
f0100f7d:	89 c6                	mov    %eax,%esi
    	return -E_NO_MEM;

    pp->pp_ref++;
f0100f7f:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    //??????
    if (*pte & PTE_P)
f0100f84:	f6 00 01             	testb  $0x1,(%eax)
f0100f87:	74 0f                	je     f0100f98 <page_insert+0x3c>
            page_remove(pgdir, va);
f0100f89:	83 ec 08             	sub    $0x8,%esp
f0100f8c:	57                   	push   %edi
f0100f8d:	ff 75 08             	pushl  0x8(%ebp)
f0100f90:	e8 85 ff ff ff       	call   f0100f1a <page_remove>
f0100f95:	83 c4 10             	add    $0x10,%esp

    *pte = page2pa(pp) | perm | PTE_P;
f0100f98:	2b 1d 6c 69 11 f0    	sub    0xf011696c,%ebx
f0100f9e:	c1 fb 03             	sar    $0x3,%ebx
f0100fa1:	c1 e3 0c             	shl    $0xc,%ebx
f0100fa4:	8b 45 14             	mov    0x14(%ebp),%eax
f0100fa7:	83 c8 01             	or     $0x1,%eax
f0100faa:	09 c3                	or     %eax,%ebx
f0100fac:	89 1e                	mov    %ebx,(%esi)

    return 0;
f0100fae:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fb3:	eb 05                	jmp    f0100fba <page_insert+0x5e>
{
	// Fill this function in
	//return 0;
	pte_t *pte = pgdir_walk(pgdir, va, 1);
    if (pte == NULL)  
    	return -E_NO_MEM;
f0100fb5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
            page_remove(pgdir, va);

    *pte = page2pa(pp) | perm | PTE_P;

    return 0;
}
f0100fba:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fbd:	5b                   	pop    %ebx
f0100fbe:	5e                   	pop    %esi
f0100fbf:	5f                   	pop    %edi
f0100fc0:	5d                   	pop    %ebp
f0100fc1:	c3                   	ret    

f0100fc2 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100fc2:	55                   	push   %ebp
f0100fc3:	89 e5                	mov    %esp,%ebp
f0100fc5:	57                   	push   %edi
f0100fc6:	56                   	push   %esi
f0100fc7:	53                   	push   %ebx
f0100fc8:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100fcb:	b8 15 00 00 00       	mov    $0x15,%eax
f0100fd0:	e8 8f f8 ff ff       	call   f0100864 <nvram_read>
f0100fd5:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100fd7:	b8 17 00 00 00       	mov    $0x17,%eax
f0100fdc:	e8 83 f8 ff ff       	call   f0100864 <nvram_read>
f0100fe1:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100fe3:	b8 34 00 00 00       	mov    $0x34,%eax
f0100fe8:	e8 77 f8 ff ff       	call   f0100864 <nvram_read>
f0100fed:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100ff0:	85 c0                	test   %eax,%eax
f0100ff2:	74 07                	je     f0100ffb <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0100ff4:	05 00 40 00 00       	add    $0x4000,%eax
f0100ff9:	eb 0b                	jmp    f0101006 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0100ffb:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101001:	85 f6                	test   %esi,%esi
f0101003:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101006:	89 c2                	mov    %eax,%edx
f0101008:	c1 ea 02             	shr    $0x2,%edx
f010100b:	89 15 64 69 11 f0    	mov    %edx,0xf0116964
	npages_basemem = basemem / (PGSIZE / 1024);
f0101011:	89 da                	mov    %ebx,%edx
f0101013:	c1 ea 02             	shr    $0x2,%edx
f0101016:	89 15 40 65 11 f0    	mov    %edx,0xf0116540

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010101c:	89 c2                	mov    %eax,%edx
f010101e:	29 da                	sub    %ebx,%edx
f0101020:	52                   	push   %edx
f0101021:	53                   	push   %ebx
f0101022:	50                   	push   %eax
f0101023:	68 ec 3b 10 f0       	push   $0xf0103bec
f0101028:	e8 3f 16 00 00       	call   f010266c <cprintf>

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	//kern_pgdir -- 操作系统的页目录表指针，页目录表的大小为一个页的大小
	//第一个调用boot_alloc(),故kern_pgdir位于内核bss段的末尾，紧跟这操作系统内核
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010102d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101032:	e8 ba f8 ff ff       	call   f01008f1 <boot_alloc>
f0101037:	a3 68 69 11 f0       	mov    %eax,0xf0116968
	//内存清零
	memset(kern_pgdir, 0, PGSIZE);
f010103c:	83 c4 0c             	add    $0xc,%esp
f010103f:	68 00 10 00 00       	push   $0x1000
f0101044:	6a 00                	push   $0x0
f0101046:	50                   	push   %eax
f0101047:	e8 09 21 00 00       	call   f0103155 <memset>
	// Permissions: kernel R, user R
	// 为页目录表添加第一个页目录表项
	/* UVPT的定义是一段虚拟地址的起始地址，0xef400000，
	   从这个虚拟地址开始，存放的就是这个操作系统的页目录表*/
	// 映射？？？自身映射
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010104c:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101051:	83 c4 10             	add    $0x10,%esp
f0101054:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101059:	77 15                	ja     f0101070 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010105b:	50                   	push   %eax
f010105c:	68 c0 3a 10 f0       	push   $0xf0103ac0
f0101061:	68 9e 00 00 00       	push   $0x9e
f0101066:	68 14 42 10 f0       	push   $0xf0104214
f010106b:	e8 1b f0 ff ff       	call   f010008b <_panic>
f0101070:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101076:	83 ca 05             	or     $0x5,%edx
f0101079:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	// 分配一块内存用来存放pages，pages数组里的每一项代表一个物理页面
	n = npages * sizeof(struct PageInfo);
f010107f:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f0101084:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f010108b:	89 d8                	mov    %ebx,%eax
f010108d:	e8 5f f8 ff ff       	call   f01008f1 <boot_alloc>
f0101092:	a3 6c 69 11 f0       	mov    %eax,0xf011696c
	//内存清零
	memset(pages, 0, n);
f0101097:	83 ec 04             	sub    $0x4,%esp
f010109a:	53                   	push   %ebx
f010109b:	6a 00                	push   $0x0
f010109d:	50                   	push   %eax
f010109e:	e8 b2 20 00 00       	call   f0103155 <memset>
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	// 初始化物理页和空闲链表
	page_init();
f01010a3:	e8 89 fb ff ff       	call   f0100c31 <page_init>
	
	//检查空闲链表是否合法
	check_page_free_list(1);
f01010a8:	b8 01 00 00 00       	mov    $0x1,%eax
f01010ad:	e8 bc f8 ff ff       	call   f010096e <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01010b2:	83 c4 10             	add    $0x10,%esp
f01010b5:	83 3d 6c 69 11 f0 00 	cmpl   $0x0,0xf011696c
f01010bc:	75 17                	jne    f01010d5 <mem_init+0x113>
		panic("'pages' is a null pointer!");
f01010be:	83 ec 04             	sub    $0x4,%esp
f01010c1:	68 f9 42 10 f0       	push   $0xf01042f9
f01010c6:	68 6c 02 00 00       	push   $0x26c
f01010cb:	68 14 42 10 f0       	push   $0xf0104214
f01010d0:	e8 b6 ef ff ff       	call   f010008b <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01010d5:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f01010da:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010df:	eb 05                	jmp    f01010e6 <mem_init+0x124>
		++nfree;
f01010e1:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01010e4:	8b 00                	mov    (%eax),%eax
f01010e6:	85 c0                	test   %eax,%eax
f01010e8:	75 f7                	jne    f01010e1 <mem_init+0x11f>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01010ea:	83 ec 0c             	sub    $0xc,%esp
f01010ed:	6a 00                	push   $0x0
f01010ef:	e8 d5 fb ff ff       	call   f0100cc9 <page_alloc>
f01010f4:	89 c7                	mov    %eax,%edi
f01010f6:	83 c4 10             	add    $0x10,%esp
f01010f9:	85 c0                	test   %eax,%eax
f01010fb:	75 19                	jne    f0101116 <mem_init+0x154>
f01010fd:	68 14 43 10 f0       	push   $0xf0104314
f0101102:	68 3a 42 10 f0       	push   $0xf010423a
f0101107:	68 74 02 00 00       	push   $0x274
f010110c:	68 14 42 10 f0       	push   $0xf0104214
f0101111:	e8 75 ef ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101116:	83 ec 0c             	sub    $0xc,%esp
f0101119:	6a 00                	push   $0x0
f010111b:	e8 a9 fb ff ff       	call   f0100cc9 <page_alloc>
f0101120:	89 c6                	mov    %eax,%esi
f0101122:	83 c4 10             	add    $0x10,%esp
f0101125:	85 c0                	test   %eax,%eax
f0101127:	75 19                	jne    f0101142 <mem_init+0x180>
f0101129:	68 2a 43 10 f0       	push   $0xf010432a
f010112e:	68 3a 42 10 f0       	push   $0xf010423a
f0101133:	68 75 02 00 00       	push   $0x275
f0101138:	68 14 42 10 f0       	push   $0xf0104214
f010113d:	e8 49 ef ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f0101142:	83 ec 0c             	sub    $0xc,%esp
f0101145:	6a 00                	push   $0x0
f0101147:	e8 7d fb ff ff       	call   f0100cc9 <page_alloc>
f010114c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010114f:	83 c4 10             	add    $0x10,%esp
f0101152:	85 c0                	test   %eax,%eax
f0101154:	75 19                	jne    f010116f <mem_init+0x1ad>
f0101156:	68 40 43 10 f0       	push   $0xf0104340
f010115b:	68 3a 42 10 f0       	push   $0xf010423a
f0101160:	68 76 02 00 00       	push   $0x276
f0101165:	68 14 42 10 f0       	push   $0xf0104214
f010116a:	e8 1c ef ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010116f:	39 f7                	cmp    %esi,%edi
f0101171:	75 19                	jne    f010118c <mem_init+0x1ca>
f0101173:	68 56 43 10 f0       	push   $0xf0104356
f0101178:	68 3a 42 10 f0       	push   $0xf010423a
f010117d:	68 79 02 00 00       	push   $0x279
f0101182:	68 14 42 10 f0       	push   $0xf0104214
f0101187:	e8 ff ee ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010118c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010118f:	39 c6                	cmp    %eax,%esi
f0101191:	74 04                	je     f0101197 <mem_init+0x1d5>
f0101193:	39 c7                	cmp    %eax,%edi
f0101195:	75 19                	jne    f01011b0 <mem_init+0x1ee>
f0101197:	68 28 3c 10 f0       	push   $0xf0103c28
f010119c:	68 3a 42 10 f0       	push   $0xf010423a
f01011a1:	68 7a 02 00 00       	push   $0x27a
f01011a6:	68 14 42 10 f0       	push   $0xf0104214
f01011ab:	e8 db ee ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011b0:	8b 0d 6c 69 11 f0    	mov    0xf011696c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01011b6:	8b 15 64 69 11 f0    	mov    0xf0116964,%edx
f01011bc:	c1 e2 0c             	shl    $0xc,%edx
f01011bf:	89 f8                	mov    %edi,%eax
f01011c1:	29 c8                	sub    %ecx,%eax
f01011c3:	c1 f8 03             	sar    $0x3,%eax
f01011c6:	c1 e0 0c             	shl    $0xc,%eax
f01011c9:	39 d0                	cmp    %edx,%eax
f01011cb:	72 19                	jb     f01011e6 <mem_init+0x224>
f01011cd:	68 68 43 10 f0       	push   $0xf0104368
f01011d2:	68 3a 42 10 f0       	push   $0xf010423a
f01011d7:	68 7b 02 00 00       	push   $0x27b
f01011dc:	68 14 42 10 f0       	push   $0xf0104214
f01011e1:	e8 a5 ee ff ff       	call   f010008b <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01011e6:	89 f0                	mov    %esi,%eax
f01011e8:	29 c8                	sub    %ecx,%eax
f01011ea:	c1 f8 03             	sar    $0x3,%eax
f01011ed:	c1 e0 0c             	shl    $0xc,%eax
f01011f0:	39 c2                	cmp    %eax,%edx
f01011f2:	77 19                	ja     f010120d <mem_init+0x24b>
f01011f4:	68 85 43 10 f0       	push   $0xf0104385
f01011f9:	68 3a 42 10 f0       	push   $0xf010423a
f01011fe:	68 7c 02 00 00       	push   $0x27c
f0101203:	68 14 42 10 f0       	push   $0xf0104214
f0101208:	e8 7e ee ff ff       	call   f010008b <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010120d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101210:	29 c8                	sub    %ecx,%eax
f0101212:	c1 f8 03             	sar    $0x3,%eax
f0101215:	c1 e0 0c             	shl    $0xc,%eax
f0101218:	39 c2                	cmp    %eax,%edx
f010121a:	77 19                	ja     f0101235 <mem_init+0x273>
f010121c:	68 a2 43 10 f0       	push   $0xf01043a2
f0101221:	68 3a 42 10 f0       	push   $0xf010423a
f0101226:	68 7d 02 00 00       	push   $0x27d
f010122b:	68 14 42 10 f0       	push   $0xf0104214
f0101230:	e8 56 ee ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101235:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f010123a:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010123d:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f0101244:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101247:	83 ec 0c             	sub    $0xc,%esp
f010124a:	6a 00                	push   $0x0
f010124c:	e8 78 fa ff ff       	call   f0100cc9 <page_alloc>
f0101251:	83 c4 10             	add    $0x10,%esp
f0101254:	85 c0                	test   %eax,%eax
f0101256:	74 19                	je     f0101271 <mem_init+0x2af>
f0101258:	68 bf 43 10 f0       	push   $0xf01043bf
f010125d:	68 3a 42 10 f0       	push   $0xf010423a
f0101262:	68 84 02 00 00       	push   $0x284
f0101267:	68 14 42 10 f0       	push   $0xf0104214
f010126c:	e8 1a ee ff ff       	call   f010008b <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101271:	83 ec 0c             	sub    $0xc,%esp
f0101274:	57                   	push   %edi
f0101275:	e8 bf fa ff ff       	call   f0100d39 <page_free>
	page_free(pp1);
f010127a:	89 34 24             	mov    %esi,(%esp)
f010127d:	e8 b7 fa ff ff       	call   f0100d39 <page_free>
	page_free(pp2);
f0101282:	83 c4 04             	add    $0x4,%esp
f0101285:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101288:	e8 ac fa ff ff       	call   f0100d39 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010128d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101294:	e8 30 fa ff ff       	call   f0100cc9 <page_alloc>
f0101299:	89 c6                	mov    %eax,%esi
f010129b:	83 c4 10             	add    $0x10,%esp
f010129e:	85 c0                	test   %eax,%eax
f01012a0:	75 19                	jne    f01012bb <mem_init+0x2f9>
f01012a2:	68 14 43 10 f0       	push   $0xf0104314
f01012a7:	68 3a 42 10 f0       	push   $0xf010423a
f01012ac:	68 8b 02 00 00       	push   $0x28b
f01012b1:	68 14 42 10 f0       	push   $0xf0104214
f01012b6:	e8 d0 ed ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f01012bb:	83 ec 0c             	sub    $0xc,%esp
f01012be:	6a 00                	push   $0x0
f01012c0:	e8 04 fa ff ff       	call   f0100cc9 <page_alloc>
f01012c5:	89 c7                	mov    %eax,%edi
f01012c7:	83 c4 10             	add    $0x10,%esp
f01012ca:	85 c0                	test   %eax,%eax
f01012cc:	75 19                	jne    f01012e7 <mem_init+0x325>
f01012ce:	68 2a 43 10 f0       	push   $0xf010432a
f01012d3:	68 3a 42 10 f0       	push   $0xf010423a
f01012d8:	68 8c 02 00 00       	push   $0x28c
f01012dd:	68 14 42 10 f0       	push   $0xf0104214
f01012e2:	e8 a4 ed ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f01012e7:	83 ec 0c             	sub    $0xc,%esp
f01012ea:	6a 00                	push   $0x0
f01012ec:	e8 d8 f9 ff ff       	call   f0100cc9 <page_alloc>
f01012f1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012f4:	83 c4 10             	add    $0x10,%esp
f01012f7:	85 c0                	test   %eax,%eax
f01012f9:	75 19                	jne    f0101314 <mem_init+0x352>
f01012fb:	68 40 43 10 f0       	push   $0xf0104340
f0101300:	68 3a 42 10 f0       	push   $0xf010423a
f0101305:	68 8d 02 00 00       	push   $0x28d
f010130a:	68 14 42 10 f0       	push   $0xf0104214
f010130f:	e8 77 ed ff ff       	call   f010008b <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101314:	39 fe                	cmp    %edi,%esi
f0101316:	75 19                	jne    f0101331 <mem_init+0x36f>
f0101318:	68 56 43 10 f0       	push   $0xf0104356
f010131d:	68 3a 42 10 f0       	push   $0xf010423a
f0101322:	68 8f 02 00 00       	push   $0x28f
f0101327:	68 14 42 10 f0       	push   $0xf0104214
f010132c:	e8 5a ed ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101331:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101334:	39 c7                	cmp    %eax,%edi
f0101336:	74 04                	je     f010133c <mem_init+0x37a>
f0101338:	39 c6                	cmp    %eax,%esi
f010133a:	75 19                	jne    f0101355 <mem_init+0x393>
f010133c:	68 28 3c 10 f0       	push   $0xf0103c28
f0101341:	68 3a 42 10 f0       	push   $0xf010423a
f0101346:	68 90 02 00 00       	push   $0x290
f010134b:	68 14 42 10 f0       	push   $0xf0104214
f0101350:	e8 36 ed ff ff       	call   f010008b <_panic>
	assert(!page_alloc(0));
f0101355:	83 ec 0c             	sub    $0xc,%esp
f0101358:	6a 00                	push   $0x0
f010135a:	e8 6a f9 ff ff       	call   f0100cc9 <page_alloc>
f010135f:	83 c4 10             	add    $0x10,%esp
f0101362:	85 c0                	test   %eax,%eax
f0101364:	74 19                	je     f010137f <mem_init+0x3bd>
f0101366:	68 bf 43 10 f0       	push   $0xf01043bf
f010136b:	68 3a 42 10 f0       	push   $0xf010423a
f0101370:	68 91 02 00 00       	push   $0x291
f0101375:	68 14 42 10 f0       	push   $0xf0104214
f010137a:	e8 0c ed ff ff       	call   f010008b <_panic>
f010137f:	89 f0                	mov    %esi,%eax
f0101381:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101387:	c1 f8 03             	sar    $0x3,%eax
f010138a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010138d:	89 c2                	mov    %eax,%edx
f010138f:	c1 ea 0c             	shr    $0xc,%edx
f0101392:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0101398:	72 12                	jb     f01013ac <mem_init+0x3ea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010139a:	50                   	push   %eax
f010139b:	68 9c 3a 10 f0       	push   $0xf0103a9c
f01013a0:	6a 52                	push   $0x52
f01013a2:	68 20 42 10 f0       	push   $0xf0104220
f01013a7:	e8 df ec ff ff       	call   f010008b <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01013ac:	83 ec 04             	sub    $0x4,%esp
f01013af:	68 00 10 00 00       	push   $0x1000
f01013b4:	6a 01                	push   $0x1
f01013b6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013bb:	50                   	push   %eax
f01013bc:	e8 94 1d 00 00       	call   f0103155 <memset>
	page_free(pp0);
f01013c1:	89 34 24             	mov    %esi,(%esp)
f01013c4:	e8 70 f9 ff ff       	call   f0100d39 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01013c9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01013d0:	e8 f4 f8 ff ff       	call   f0100cc9 <page_alloc>
f01013d5:	83 c4 10             	add    $0x10,%esp
f01013d8:	85 c0                	test   %eax,%eax
f01013da:	75 19                	jne    f01013f5 <mem_init+0x433>
f01013dc:	68 ce 43 10 f0       	push   $0xf01043ce
f01013e1:	68 3a 42 10 f0       	push   $0xf010423a
f01013e6:	68 96 02 00 00       	push   $0x296
f01013eb:	68 14 42 10 f0       	push   $0xf0104214
f01013f0:	e8 96 ec ff ff       	call   f010008b <_panic>
	assert(pp && pp0 == pp);
f01013f5:	39 c6                	cmp    %eax,%esi
f01013f7:	74 19                	je     f0101412 <mem_init+0x450>
f01013f9:	68 ec 43 10 f0       	push   $0xf01043ec
f01013fe:	68 3a 42 10 f0       	push   $0xf010423a
f0101403:	68 97 02 00 00       	push   $0x297
f0101408:	68 14 42 10 f0       	push   $0xf0104214
f010140d:	e8 79 ec ff ff       	call   f010008b <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101412:	89 f0                	mov    %esi,%eax
f0101414:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f010141a:	c1 f8 03             	sar    $0x3,%eax
f010141d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101420:	89 c2                	mov    %eax,%edx
f0101422:	c1 ea 0c             	shr    $0xc,%edx
f0101425:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f010142b:	72 12                	jb     f010143f <mem_init+0x47d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010142d:	50                   	push   %eax
f010142e:	68 9c 3a 10 f0       	push   $0xf0103a9c
f0101433:	6a 52                	push   $0x52
f0101435:	68 20 42 10 f0       	push   $0xf0104220
f010143a:	e8 4c ec ff ff       	call   f010008b <_panic>
f010143f:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101445:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010144b:	80 38 00             	cmpb   $0x0,(%eax)
f010144e:	74 19                	je     f0101469 <mem_init+0x4a7>
f0101450:	68 fc 43 10 f0       	push   $0xf01043fc
f0101455:	68 3a 42 10 f0       	push   $0xf010423a
f010145a:	68 9a 02 00 00       	push   $0x29a
f010145f:	68 14 42 10 f0       	push   $0xf0104214
f0101464:	e8 22 ec ff ff       	call   f010008b <_panic>
f0101469:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010146c:	39 d0                	cmp    %edx,%eax
f010146e:	75 db                	jne    f010144b <mem_init+0x489>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101470:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101473:	a3 3c 65 11 f0       	mov    %eax,0xf011653c

	// free the pages we took
	page_free(pp0);
f0101478:	83 ec 0c             	sub    $0xc,%esp
f010147b:	56                   	push   %esi
f010147c:	e8 b8 f8 ff ff       	call   f0100d39 <page_free>
	page_free(pp1);
f0101481:	89 3c 24             	mov    %edi,(%esp)
f0101484:	e8 b0 f8 ff ff       	call   f0100d39 <page_free>
	page_free(pp2);
f0101489:	83 c4 04             	add    $0x4,%esp
f010148c:	ff 75 d4             	pushl  -0x2c(%ebp)
f010148f:	e8 a5 f8 ff ff       	call   f0100d39 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101494:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f0101499:	83 c4 10             	add    $0x10,%esp
f010149c:	eb 05                	jmp    f01014a3 <mem_init+0x4e1>
		--nfree;
f010149e:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01014a1:	8b 00                	mov    (%eax),%eax
f01014a3:	85 c0                	test   %eax,%eax
f01014a5:	75 f7                	jne    f010149e <mem_init+0x4dc>
		--nfree;
	assert(nfree == 0);
f01014a7:	85 db                	test   %ebx,%ebx
f01014a9:	74 19                	je     f01014c4 <mem_init+0x502>
f01014ab:	68 06 44 10 f0       	push   $0xf0104406
f01014b0:	68 3a 42 10 f0       	push   $0xf010423a
f01014b5:	68 a7 02 00 00       	push   $0x2a7
f01014ba:	68 14 42 10 f0       	push   $0xf0104214
f01014bf:	e8 c7 eb ff ff       	call   f010008b <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01014c4:	83 ec 0c             	sub    $0xc,%esp
f01014c7:	68 48 3c 10 f0       	push   $0xf0103c48
f01014cc:	e8 9b 11 00 00       	call   f010266c <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014d1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014d8:	e8 ec f7 ff ff       	call   f0100cc9 <page_alloc>
f01014dd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014e0:	83 c4 10             	add    $0x10,%esp
f01014e3:	85 c0                	test   %eax,%eax
f01014e5:	75 19                	jne    f0101500 <mem_init+0x53e>
f01014e7:	68 14 43 10 f0       	push   $0xf0104314
f01014ec:	68 3a 42 10 f0       	push   $0xf010423a
f01014f1:	68 00 03 00 00       	push   $0x300
f01014f6:	68 14 42 10 f0       	push   $0xf0104214
f01014fb:	e8 8b eb ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0101500:	83 ec 0c             	sub    $0xc,%esp
f0101503:	6a 00                	push   $0x0
f0101505:	e8 bf f7 ff ff       	call   f0100cc9 <page_alloc>
f010150a:	89 c3                	mov    %eax,%ebx
f010150c:	83 c4 10             	add    $0x10,%esp
f010150f:	85 c0                	test   %eax,%eax
f0101511:	75 19                	jne    f010152c <mem_init+0x56a>
f0101513:	68 2a 43 10 f0       	push   $0xf010432a
f0101518:	68 3a 42 10 f0       	push   $0xf010423a
f010151d:	68 01 03 00 00       	push   $0x301
f0101522:	68 14 42 10 f0       	push   $0xf0104214
f0101527:	e8 5f eb ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010152c:	83 ec 0c             	sub    $0xc,%esp
f010152f:	6a 00                	push   $0x0
f0101531:	e8 93 f7 ff ff       	call   f0100cc9 <page_alloc>
f0101536:	89 c6                	mov    %eax,%esi
f0101538:	83 c4 10             	add    $0x10,%esp
f010153b:	85 c0                	test   %eax,%eax
f010153d:	75 19                	jne    f0101558 <mem_init+0x596>
f010153f:	68 40 43 10 f0       	push   $0xf0104340
f0101544:	68 3a 42 10 f0       	push   $0xf010423a
f0101549:	68 02 03 00 00       	push   $0x302
f010154e:	68 14 42 10 f0       	push   $0xf0104214
f0101553:	e8 33 eb ff ff       	call   f010008b <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101558:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010155b:	75 19                	jne    f0101576 <mem_init+0x5b4>
f010155d:	68 56 43 10 f0       	push   $0xf0104356
f0101562:	68 3a 42 10 f0       	push   $0xf010423a
f0101567:	68 05 03 00 00       	push   $0x305
f010156c:	68 14 42 10 f0       	push   $0xf0104214
f0101571:	e8 15 eb ff ff       	call   f010008b <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101576:	39 c3                	cmp    %eax,%ebx
f0101578:	74 05                	je     f010157f <mem_init+0x5bd>
f010157a:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f010157d:	75 19                	jne    f0101598 <mem_init+0x5d6>
f010157f:	68 28 3c 10 f0       	push   $0xf0103c28
f0101584:	68 3a 42 10 f0       	push   $0xf010423a
f0101589:	68 06 03 00 00       	push   $0x306
f010158e:	68 14 42 10 f0       	push   $0xf0104214
f0101593:	e8 f3 ea ff ff       	call   f010008b <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101598:	a1 3c 65 11 f0       	mov    0xf011653c,%eax
f010159d:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01015a0:	c7 05 3c 65 11 f0 00 	movl   $0x0,0xf011653c
f01015a7:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01015aa:	83 ec 0c             	sub    $0xc,%esp
f01015ad:	6a 00                	push   $0x0
f01015af:	e8 15 f7 ff ff       	call   f0100cc9 <page_alloc>
f01015b4:	83 c4 10             	add    $0x10,%esp
f01015b7:	85 c0                	test   %eax,%eax
f01015b9:	74 19                	je     f01015d4 <mem_init+0x612>
f01015bb:	68 bf 43 10 f0       	push   $0xf01043bf
f01015c0:	68 3a 42 10 f0       	push   $0xf010423a
f01015c5:	68 0d 03 00 00       	push   $0x30d
f01015ca:	68 14 42 10 f0       	push   $0xf0104214
f01015cf:	e8 b7 ea ff ff       	call   f010008b <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01015d4:	83 ec 04             	sub    $0x4,%esp
f01015d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01015da:	50                   	push   %eax
f01015db:	6a 00                	push   $0x0
f01015dd:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01015e3:	e8 cd f8 ff ff       	call   f0100eb5 <page_lookup>
f01015e8:	83 c4 10             	add    $0x10,%esp
f01015eb:	85 c0                	test   %eax,%eax
f01015ed:	74 19                	je     f0101608 <mem_init+0x646>
f01015ef:	68 68 3c 10 f0       	push   $0xf0103c68
f01015f4:	68 3a 42 10 f0       	push   $0xf010423a
f01015f9:	68 10 03 00 00       	push   $0x310
f01015fe:	68 14 42 10 f0       	push   $0xf0104214
f0101603:	e8 83 ea ff ff       	call   f010008b <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101608:	6a 02                	push   $0x2
f010160a:	6a 00                	push   $0x0
f010160c:	53                   	push   %ebx
f010160d:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101613:	e8 44 f9 ff ff       	call   f0100f5c <page_insert>
f0101618:	83 c4 10             	add    $0x10,%esp
f010161b:	85 c0                	test   %eax,%eax
f010161d:	78 19                	js     f0101638 <mem_init+0x676>
f010161f:	68 a0 3c 10 f0       	push   $0xf0103ca0
f0101624:	68 3a 42 10 f0       	push   $0xf010423a
f0101629:	68 13 03 00 00       	push   $0x313
f010162e:	68 14 42 10 f0       	push   $0xf0104214
f0101633:	e8 53 ea ff ff       	call   f010008b <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101638:	83 ec 0c             	sub    $0xc,%esp
f010163b:	ff 75 d4             	pushl  -0x2c(%ebp)
f010163e:	e8 f6 f6 ff ff       	call   f0100d39 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101643:	6a 02                	push   $0x2
f0101645:	6a 00                	push   $0x0
f0101647:	53                   	push   %ebx
f0101648:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010164e:	e8 09 f9 ff ff       	call   f0100f5c <page_insert>
f0101653:	83 c4 20             	add    $0x20,%esp
f0101656:	85 c0                	test   %eax,%eax
f0101658:	74 19                	je     f0101673 <mem_init+0x6b1>
f010165a:	68 d0 3c 10 f0       	push   $0xf0103cd0
f010165f:	68 3a 42 10 f0       	push   $0xf010423a
f0101664:	68 17 03 00 00       	push   $0x317
f0101669:	68 14 42 10 f0       	push   $0xf0104214
f010166e:	e8 18 ea ff ff       	call   f010008b <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101673:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101679:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
f010167e:	89 c1                	mov    %eax,%ecx
f0101680:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101683:	8b 17                	mov    (%edi),%edx
f0101685:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f010168b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010168e:	29 c8                	sub    %ecx,%eax
f0101690:	c1 f8 03             	sar    $0x3,%eax
f0101693:	c1 e0 0c             	shl    $0xc,%eax
f0101696:	39 c2                	cmp    %eax,%edx
f0101698:	74 19                	je     f01016b3 <mem_init+0x6f1>
f010169a:	68 00 3d 10 f0       	push   $0xf0103d00
f010169f:	68 3a 42 10 f0       	push   $0xf010423a
f01016a4:	68 18 03 00 00       	push   $0x318
f01016a9:	68 14 42 10 f0       	push   $0xf0104214
f01016ae:	e8 d8 e9 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01016b3:	ba 00 00 00 00       	mov    $0x0,%edx
f01016b8:	89 f8                	mov    %edi,%eax
f01016ba:	e8 ce f1 ff ff       	call   f010088d <check_va2pa>
f01016bf:	89 da                	mov    %ebx,%edx
f01016c1:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01016c4:	c1 fa 03             	sar    $0x3,%edx
f01016c7:	c1 e2 0c             	shl    $0xc,%edx
f01016ca:	39 d0                	cmp    %edx,%eax
f01016cc:	74 19                	je     f01016e7 <mem_init+0x725>
f01016ce:	68 28 3d 10 f0       	push   $0xf0103d28
f01016d3:	68 3a 42 10 f0       	push   $0xf010423a
f01016d8:	68 19 03 00 00       	push   $0x319
f01016dd:	68 14 42 10 f0       	push   $0xf0104214
f01016e2:	e8 a4 e9 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f01016e7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01016ec:	74 19                	je     f0101707 <mem_init+0x745>
f01016ee:	68 11 44 10 f0       	push   $0xf0104411
f01016f3:	68 3a 42 10 f0       	push   $0xf010423a
f01016f8:	68 1a 03 00 00       	push   $0x31a
f01016fd:	68 14 42 10 f0       	push   $0xf0104214
f0101702:	e8 84 e9 ff ff       	call   f010008b <_panic>
	assert(pp0->pp_ref == 1);
f0101707:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010170a:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010170f:	74 19                	je     f010172a <mem_init+0x768>
f0101711:	68 22 44 10 f0       	push   $0xf0104422
f0101716:	68 3a 42 10 f0       	push   $0xf010423a
f010171b:	68 1b 03 00 00       	push   $0x31b
f0101720:	68 14 42 10 f0       	push   $0xf0104214
f0101725:	e8 61 e9 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010172a:	6a 02                	push   $0x2
f010172c:	68 00 10 00 00       	push   $0x1000
f0101731:	56                   	push   %esi
f0101732:	57                   	push   %edi
f0101733:	e8 24 f8 ff ff       	call   f0100f5c <page_insert>
f0101738:	83 c4 10             	add    $0x10,%esp
f010173b:	85 c0                	test   %eax,%eax
f010173d:	74 19                	je     f0101758 <mem_init+0x796>
f010173f:	68 58 3d 10 f0       	push   $0xf0103d58
f0101744:	68 3a 42 10 f0       	push   $0xf010423a
f0101749:	68 1e 03 00 00       	push   $0x31e
f010174e:	68 14 42 10 f0       	push   $0xf0104214
f0101753:	e8 33 e9 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101758:	ba 00 10 00 00       	mov    $0x1000,%edx
f010175d:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101762:	e8 26 f1 ff ff       	call   f010088d <check_va2pa>
f0101767:	89 f2                	mov    %esi,%edx
f0101769:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f010176f:	c1 fa 03             	sar    $0x3,%edx
f0101772:	c1 e2 0c             	shl    $0xc,%edx
f0101775:	39 d0                	cmp    %edx,%eax
f0101777:	74 19                	je     f0101792 <mem_init+0x7d0>
f0101779:	68 94 3d 10 f0       	push   $0xf0103d94
f010177e:	68 3a 42 10 f0       	push   $0xf010423a
f0101783:	68 1f 03 00 00       	push   $0x31f
f0101788:	68 14 42 10 f0       	push   $0xf0104214
f010178d:	e8 f9 e8 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101792:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101797:	74 19                	je     f01017b2 <mem_init+0x7f0>
f0101799:	68 33 44 10 f0       	push   $0xf0104433
f010179e:	68 3a 42 10 f0       	push   $0xf010423a
f01017a3:	68 20 03 00 00       	push   $0x320
f01017a8:	68 14 42 10 f0       	push   $0xf0104214
f01017ad:	e8 d9 e8 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01017b2:	83 ec 0c             	sub    $0xc,%esp
f01017b5:	6a 00                	push   $0x0
f01017b7:	e8 0d f5 ff ff       	call   f0100cc9 <page_alloc>
f01017bc:	83 c4 10             	add    $0x10,%esp
f01017bf:	85 c0                	test   %eax,%eax
f01017c1:	74 19                	je     f01017dc <mem_init+0x81a>
f01017c3:	68 bf 43 10 f0       	push   $0xf01043bf
f01017c8:	68 3a 42 10 f0       	push   $0xf010423a
f01017cd:	68 23 03 00 00       	push   $0x323
f01017d2:	68 14 42 10 f0       	push   $0xf0104214
f01017d7:	e8 af e8 ff ff       	call   f010008b <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017dc:	6a 02                	push   $0x2
f01017de:	68 00 10 00 00       	push   $0x1000
f01017e3:	56                   	push   %esi
f01017e4:	ff 35 68 69 11 f0    	pushl  0xf0116968
f01017ea:	e8 6d f7 ff ff       	call   f0100f5c <page_insert>
f01017ef:	83 c4 10             	add    $0x10,%esp
f01017f2:	85 c0                	test   %eax,%eax
f01017f4:	74 19                	je     f010180f <mem_init+0x84d>
f01017f6:	68 58 3d 10 f0       	push   $0xf0103d58
f01017fb:	68 3a 42 10 f0       	push   $0xf010423a
f0101800:	68 26 03 00 00       	push   $0x326
f0101805:	68 14 42 10 f0       	push   $0xf0104214
f010180a:	e8 7c e8 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010180f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101814:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101819:	e8 6f f0 ff ff       	call   f010088d <check_va2pa>
f010181e:	89 f2                	mov    %esi,%edx
f0101820:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101826:	c1 fa 03             	sar    $0x3,%edx
f0101829:	c1 e2 0c             	shl    $0xc,%edx
f010182c:	39 d0                	cmp    %edx,%eax
f010182e:	74 19                	je     f0101849 <mem_init+0x887>
f0101830:	68 94 3d 10 f0       	push   $0xf0103d94
f0101835:	68 3a 42 10 f0       	push   $0xf010423a
f010183a:	68 27 03 00 00       	push   $0x327
f010183f:	68 14 42 10 f0       	push   $0xf0104214
f0101844:	e8 42 e8 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101849:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010184e:	74 19                	je     f0101869 <mem_init+0x8a7>
f0101850:	68 33 44 10 f0       	push   $0xf0104433
f0101855:	68 3a 42 10 f0       	push   $0xf010423a
f010185a:	68 28 03 00 00       	push   $0x328
f010185f:	68 14 42 10 f0       	push   $0xf0104214
f0101864:	e8 22 e8 ff ff       	call   f010008b <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101869:	83 ec 0c             	sub    $0xc,%esp
f010186c:	6a 00                	push   $0x0
f010186e:	e8 56 f4 ff ff       	call   f0100cc9 <page_alloc>
f0101873:	83 c4 10             	add    $0x10,%esp
f0101876:	85 c0                	test   %eax,%eax
f0101878:	74 19                	je     f0101893 <mem_init+0x8d1>
f010187a:	68 bf 43 10 f0       	push   $0xf01043bf
f010187f:	68 3a 42 10 f0       	push   $0xf010423a
f0101884:	68 2c 03 00 00       	push   $0x32c
f0101889:	68 14 42 10 f0       	push   $0xf0104214
f010188e:	e8 f8 e7 ff ff       	call   f010008b <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101893:	8b 15 68 69 11 f0    	mov    0xf0116968,%edx
f0101899:	8b 02                	mov    (%edx),%eax
f010189b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01018a0:	89 c1                	mov    %eax,%ecx
f01018a2:	c1 e9 0c             	shr    $0xc,%ecx
f01018a5:	3b 0d 64 69 11 f0    	cmp    0xf0116964,%ecx
f01018ab:	72 15                	jb     f01018c2 <mem_init+0x900>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018ad:	50                   	push   %eax
f01018ae:	68 9c 3a 10 f0       	push   $0xf0103a9c
f01018b3:	68 2f 03 00 00       	push   $0x32f
f01018b8:	68 14 42 10 f0       	push   $0xf0104214
f01018bd:	e8 c9 e7 ff ff       	call   f010008b <_panic>
f01018c2:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01018ca:	83 ec 04             	sub    $0x4,%esp
f01018cd:	6a 00                	push   $0x0
f01018cf:	68 00 10 00 00       	push   $0x1000
f01018d4:	52                   	push   %edx
f01018d5:	e8 f9 f4 ff ff       	call   f0100dd3 <pgdir_walk>
f01018da:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f01018dd:	8d 51 04             	lea    0x4(%ecx),%edx
f01018e0:	83 c4 10             	add    $0x10,%esp
f01018e3:	39 d0                	cmp    %edx,%eax
f01018e5:	74 19                	je     f0101900 <mem_init+0x93e>
f01018e7:	68 c4 3d 10 f0       	push   $0xf0103dc4
f01018ec:	68 3a 42 10 f0       	push   $0xf010423a
f01018f1:	68 30 03 00 00       	push   $0x330
f01018f6:	68 14 42 10 f0       	push   $0xf0104214
f01018fb:	e8 8b e7 ff ff       	call   f010008b <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101900:	6a 06                	push   $0x6
f0101902:	68 00 10 00 00       	push   $0x1000
f0101907:	56                   	push   %esi
f0101908:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010190e:	e8 49 f6 ff ff       	call   f0100f5c <page_insert>
f0101913:	83 c4 10             	add    $0x10,%esp
f0101916:	85 c0                	test   %eax,%eax
f0101918:	74 19                	je     f0101933 <mem_init+0x971>
f010191a:	68 04 3e 10 f0       	push   $0xf0103e04
f010191f:	68 3a 42 10 f0       	push   $0xf010423a
f0101924:	68 33 03 00 00       	push   $0x333
f0101929:	68 14 42 10 f0       	push   $0xf0104214
f010192e:	e8 58 e7 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101933:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101939:	ba 00 10 00 00       	mov    $0x1000,%edx
f010193e:	89 f8                	mov    %edi,%eax
f0101940:	e8 48 ef ff ff       	call   f010088d <check_va2pa>
f0101945:	89 f2                	mov    %esi,%edx
f0101947:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f010194d:	c1 fa 03             	sar    $0x3,%edx
f0101950:	c1 e2 0c             	shl    $0xc,%edx
f0101953:	39 d0                	cmp    %edx,%eax
f0101955:	74 19                	je     f0101970 <mem_init+0x9ae>
f0101957:	68 94 3d 10 f0       	push   $0xf0103d94
f010195c:	68 3a 42 10 f0       	push   $0xf010423a
f0101961:	68 34 03 00 00       	push   $0x334
f0101966:	68 14 42 10 f0       	push   $0xf0104214
f010196b:	e8 1b e7 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f0101970:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101975:	74 19                	je     f0101990 <mem_init+0x9ce>
f0101977:	68 33 44 10 f0       	push   $0xf0104433
f010197c:	68 3a 42 10 f0       	push   $0xf010423a
f0101981:	68 35 03 00 00       	push   $0x335
f0101986:	68 14 42 10 f0       	push   $0xf0104214
f010198b:	e8 fb e6 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101990:	83 ec 04             	sub    $0x4,%esp
f0101993:	6a 00                	push   $0x0
f0101995:	68 00 10 00 00       	push   $0x1000
f010199a:	57                   	push   %edi
f010199b:	e8 33 f4 ff ff       	call   f0100dd3 <pgdir_walk>
f01019a0:	83 c4 10             	add    $0x10,%esp
f01019a3:	f6 00 04             	testb  $0x4,(%eax)
f01019a6:	75 19                	jne    f01019c1 <mem_init+0x9ff>
f01019a8:	68 44 3e 10 f0       	push   $0xf0103e44
f01019ad:	68 3a 42 10 f0       	push   $0xf010423a
f01019b2:	68 36 03 00 00       	push   $0x336
f01019b7:	68 14 42 10 f0       	push   $0xf0104214
f01019bc:	e8 ca e6 ff ff       	call   f010008b <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01019c1:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01019c6:	f6 00 04             	testb  $0x4,(%eax)
f01019c9:	75 19                	jne    f01019e4 <mem_init+0xa22>
f01019cb:	68 44 44 10 f0       	push   $0xf0104444
f01019d0:	68 3a 42 10 f0       	push   $0xf010423a
f01019d5:	68 37 03 00 00       	push   $0x337
f01019da:	68 14 42 10 f0       	push   $0xf0104214
f01019df:	e8 a7 e6 ff ff       	call   f010008b <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019e4:	6a 02                	push   $0x2
f01019e6:	68 00 10 00 00       	push   $0x1000
f01019eb:	56                   	push   %esi
f01019ec:	50                   	push   %eax
f01019ed:	e8 6a f5 ff ff       	call   f0100f5c <page_insert>
f01019f2:	83 c4 10             	add    $0x10,%esp
f01019f5:	85 c0                	test   %eax,%eax
f01019f7:	74 19                	je     f0101a12 <mem_init+0xa50>
f01019f9:	68 58 3d 10 f0       	push   $0xf0103d58
f01019fe:	68 3a 42 10 f0       	push   $0xf010423a
f0101a03:	68 3a 03 00 00       	push   $0x33a
f0101a08:	68 14 42 10 f0       	push   $0xf0104214
f0101a0d:	e8 79 e6 ff ff       	call   f010008b <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101a12:	83 ec 04             	sub    $0x4,%esp
f0101a15:	6a 00                	push   $0x0
f0101a17:	68 00 10 00 00       	push   $0x1000
f0101a1c:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101a22:	e8 ac f3 ff ff       	call   f0100dd3 <pgdir_walk>
f0101a27:	83 c4 10             	add    $0x10,%esp
f0101a2a:	f6 00 02             	testb  $0x2,(%eax)
f0101a2d:	75 19                	jne    f0101a48 <mem_init+0xa86>
f0101a2f:	68 78 3e 10 f0       	push   $0xf0103e78
f0101a34:	68 3a 42 10 f0       	push   $0xf010423a
f0101a39:	68 3b 03 00 00       	push   $0x33b
f0101a3e:	68 14 42 10 f0       	push   $0xf0104214
f0101a43:	e8 43 e6 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101a48:	83 ec 04             	sub    $0x4,%esp
f0101a4b:	6a 00                	push   $0x0
f0101a4d:	68 00 10 00 00       	push   $0x1000
f0101a52:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101a58:	e8 76 f3 ff ff       	call   f0100dd3 <pgdir_walk>
f0101a5d:	83 c4 10             	add    $0x10,%esp
f0101a60:	f6 00 04             	testb  $0x4,(%eax)
f0101a63:	74 19                	je     f0101a7e <mem_init+0xabc>
f0101a65:	68 ac 3e 10 f0       	push   $0xf0103eac
f0101a6a:	68 3a 42 10 f0       	push   $0xf010423a
f0101a6f:	68 3c 03 00 00       	push   $0x33c
f0101a74:	68 14 42 10 f0       	push   $0xf0104214
f0101a79:	e8 0d e6 ff ff       	call   f010008b <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101a7e:	6a 02                	push   $0x2
f0101a80:	68 00 00 40 00       	push   $0x400000
f0101a85:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a88:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101a8e:	e8 c9 f4 ff ff       	call   f0100f5c <page_insert>
f0101a93:	83 c4 10             	add    $0x10,%esp
f0101a96:	85 c0                	test   %eax,%eax
f0101a98:	78 19                	js     f0101ab3 <mem_init+0xaf1>
f0101a9a:	68 e4 3e 10 f0       	push   $0xf0103ee4
f0101a9f:	68 3a 42 10 f0       	push   $0xf010423a
f0101aa4:	68 3f 03 00 00       	push   $0x33f
f0101aa9:	68 14 42 10 f0       	push   $0xf0104214
f0101aae:	e8 d8 e5 ff ff       	call   f010008b <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101ab3:	6a 02                	push   $0x2
f0101ab5:	68 00 10 00 00       	push   $0x1000
f0101aba:	53                   	push   %ebx
f0101abb:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101ac1:	e8 96 f4 ff ff       	call   f0100f5c <page_insert>
f0101ac6:	83 c4 10             	add    $0x10,%esp
f0101ac9:	85 c0                	test   %eax,%eax
f0101acb:	74 19                	je     f0101ae6 <mem_init+0xb24>
f0101acd:	68 1c 3f 10 f0       	push   $0xf0103f1c
f0101ad2:	68 3a 42 10 f0       	push   $0xf010423a
f0101ad7:	68 42 03 00 00       	push   $0x342
f0101adc:	68 14 42 10 f0       	push   $0xf0104214
f0101ae1:	e8 a5 e5 ff ff       	call   f010008b <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101ae6:	83 ec 04             	sub    $0x4,%esp
f0101ae9:	6a 00                	push   $0x0
f0101aeb:	68 00 10 00 00       	push   $0x1000
f0101af0:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101af6:	e8 d8 f2 ff ff       	call   f0100dd3 <pgdir_walk>
f0101afb:	83 c4 10             	add    $0x10,%esp
f0101afe:	f6 00 04             	testb  $0x4,(%eax)
f0101b01:	74 19                	je     f0101b1c <mem_init+0xb5a>
f0101b03:	68 ac 3e 10 f0       	push   $0xf0103eac
f0101b08:	68 3a 42 10 f0       	push   $0xf010423a
f0101b0d:	68 43 03 00 00       	push   $0x343
f0101b12:	68 14 42 10 f0       	push   $0xf0104214
f0101b17:	e8 6f e5 ff ff       	call   f010008b <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101b1c:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101b22:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b27:	89 f8                	mov    %edi,%eax
f0101b29:	e8 5f ed ff ff       	call   f010088d <check_va2pa>
f0101b2e:	89 c1                	mov    %eax,%ecx
f0101b30:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b33:	89 d8                	mov    %ebx,%eax
f0101b35:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101b3b:	c1 f8 03             	sar    $0x3,%eax
f0101b3e:	c1 e0 0c             	shl    $0xc,%eax
f0101b41:	39 c1                	cmp    %eax,%ecx
f0101b43:	74 19                	je     f0101b5e <mem_init+0xb9c>
f0101b45:	68 58 3f 10 f0       	push   $0xf0103f58
f0101b4a:	68 3a 42 10 f0       	push   $0xf010423a
f0101b4f:	68 46 03 00 00       	push   $0x346
f0101b54:	68 14 42 10 f0       	push   $0xf0104214
f0101b59:	e8 2d e5 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101b5e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b63:	89 f8                	mov    %edi,%eax
f0101b65:	e8 23 ed ff ff       	call   f010088d <check_va2pa>
f0101b6a:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101b6d:	74 19                	je     f0101b88 <mem_init+0xbc6>
f0101b6f:	68 84 3f 10 f0       	push   $0xf0103f84
f0101b74:	68 3a 42 10 f0       	push   $0xf010423a
f0101b79:	68 47 03 00 00       	push   $0x347
f0101b7e:	68 14 42 10 f0       	push   $0xf0104214
f0101b83:	e8 03 e5 ff ff       	call   f010008b <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101b88:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101b8d:	74 19                	je     f0101ba8 <mem_init+0xbe6>
f0101b8f:	68 5a 44 10 f0       	push   $0xf010445a
f0101b94:	68 3a 42 10 f0       	push   $0xf010423a
f0101b99:	68 49 03 00 00       	push   $0x349
f0101b9e:	68 14 42 10 f0       	push   $0xf0104214
f0101ba3:	e8 e3 e4 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101ba8:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101bad:	74 19                	je     f0101bc8 <mem_init+0xc06>
f0101baf:	68 6b 44 10 f0       	push   $0xf010446b
f0101bb4:	68 3a 42 10 f0       	push   $0xf010423a
f0101bb9:	68 4a 03 00 00       	push   $0x34a
f0101bbe:	68 14 42 10 f0       	push   $0xf0104214
f0101bc3:	e8 c3 e4 ff ff       	call   f010008b <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101bc8:	83 ec 0c             	sub    $0xc,%esp
f0101bcb:	6a 00                	push   $0x0
f0101bcd:	e8 f7 f0 ff ff       	call   f0100cc9 <page_alloc>
f0101bd2:	83 c4 10             	add    $0x10,%esp
f0101bd5:	85 c0                	test   %eax,%eax
f0101bd7:	74 04                	je     f0101bdd <mem_init+0xc1b>
f0101bd9:	39 c6                	cmp    %eax,%esi
f0101bdb:	74 19                	je     f0101bf6 <mem_init+0xc34>
f0101bdd:	68 b4 3f 10 f0       	push   $0xf0103fb4
f0101be2:	68 3a 42 10 f0       	push   $0xf010423a
f0101be7:	68 4d 03 00 00       	push   $0x34d
f0101bec:	68 14 42 10 f0       	push   $0xf0104214
f0101bf1:	e8 95 e4 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101bf6:	83 ec 08             	sub    $0x8,%esp
f0101bf9:	6a 00                	push   $0x0
f0101bfb:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101c01:	e8 14 f3 ff ff       	call   f0100f1a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101c06:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101c0c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c11:	89 f8                	mov    %edi,%eax
f0101c13:	e8 75 ec ff ff       	call   f010088d <check_va2pa>
f0101c18:	83 c4 10             	add    $0x10,%esp
f0101c1b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c1e:	74 19                	je     f0101c39 <mem_init+0xc77>
f0101c20:	68 d8 3f 10 f0       	push   $0xf0103fd8
f0101c25:	68 3a 42 10 f0       	push   $0xf010423a
f0101c2a:	68 51 03 00 00       	push   $0x351
f0101c2f:	68 14 42 10 f0       	push   $0xf0104214
f0101c34:	e8 52 e4 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c39:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c3e:	89 f8                	mov    %edi,%eax
f0101c40:	e8 48 ec ff ff       	call   f010088d <check_va2pa>
f0101c45:	89 da                	mov    %ebx,%edx
f0101c47:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101c4d:	c1 fa 03             	sar    $0x3,%edx
f0101c50:	c1 e2 0c             	shl    $0xc,%edx
f0101c53:	39 d0                	cmp    %edx,%eax
f0101c55:	74 19                	je     f0101c70 <mem_init+0xcae>
f0101c57:	68 84 3f 10 f0       	push   $0xf0103f84
f0101c5c:	68 3a 42 10 f0       	push   $0xf010423a
f0101c61:	68 52 03 00 00       	push   $0x352
f0101c66:	68 14 42 10 f0       	push   $0xf0104214
f0101c6b:	e8 1b e4 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 1);
f0101c70:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c75:	74 19                	je     f0101c90 <mem_init+0xcce>
f0101c77:	68 11 44 10 f0       	push   $0xf0104411
f0101c7c:	68 3a 42 10 f0       	push   $0xf010423a
f0101c81:	68 53 03 00 00       	push   $0x353
f0101c86:	68 14 42 10 f0       	push   $0xf0104214
f0101c8b:	e8 fb e3 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101c90:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c95:	74 19                	je     f0101cb0 <mem_init+0xcee>
f0101c97:	68 6b 44 10 f0       	push   $0xf010446b
f0101c9c:	68 3a 42 10 f0       	push   $0xf010423a
f0101ca1:	68 54 03 00 00       	push   $0x354
f0101ca6:	68 14 42 10 f0       	push   $0xf0104214
f0101cab:	e8 db e3 ff ff       	call   f010008b <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101cb0:	6a 00                	push   $0x0
f0101cb2:	68 00 10 00 00       	push   $0x1000
f0101cb7:	53                   	push   %ebx
f0101cb8:	57                   	push   %edi
f0101cb9:	e8 9e f2 ff ff       	call   f0100f5c <page_insert>
f0101cbe:	83 c4 10             	add    $0x10,%esp
f0101cc1:	85 c0                	test   %eax,%eax
f0101cc3:	74 19                	je     f0101cde <mem_init+0xd1c>
f0101cc5:	68 fc 3f 10 f0       	push   $0xf0103ffc
f0101cca:	68 3a 42 10 f0       	push   $0xf010423a
f0101ccf:	68 57 03 00 00       	push   $0x357
f0101cd4:	68 14 42 10 f0       	push   $0xf0104214
f0101cd9:	e8 ad e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref);
f0101cde:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ce3:	75 19                	jne    f0101cfe <mem_init+0xd3c>
f0101ce5:	68 7c 44 10 f0       	push   $0xf010447c
f0101cea:	68 3a 42 10 f0       	push   $0xf010423a
f0101cef:	68 58 03 00 00       	push   $0x358
f0101cf4:	68 14 42 10 f0       	push   $0xf0104214
f0101cf9:	e8 8d e3 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_link == NULL);
f0101cfe:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101d01:	74 19                	je     f0101d1c <mem_init+0xd5a>
f0101d03:	68 88 44 10 f0       	push   $0xf0104488
f0101d08:	68 3a 42 10 f0       	push   $0xf010423a
f0101d0d:	68 59 03 00 00       	push   $0x359
f0101d12:	68 14 42 10 f0       	push   $0xf0104214
f0101d17:	e8 6f e3 ff ff       	call   f010008b <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d1c:	83 ec 08             	sub    $0x8,%esp
f0101d1f:	68 00 10 00 00       	push   $0x1000
f0101d24:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101d2a:	e8 eb f1 ff ff       	call   f0100f1a <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d2f:	8b 3d 68 69 11 f0    	mov    0xf0116968,%edi
f0101d35:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d3a:	89 f8                	mov    %edi,%eax
f0101d3c:	e8 4c eb ff ff       	call   f010088d <check_va2pa>
f0101d41:	83 c4 10             	add    $0x10,%esp
f0101d44:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d47:	74 19                	je     f0101d62 <mem_init+0xda0>
f0101d49:	68 d8 3f 10 f0       	push   $0xf0103fd8
f0101d4e:	68 3a 42 10 f0       	push   $0xf010423a
f0101d53:	68 5d 03 00 00       	push   $0x35d
f0101d58:	68 14 42 10 f0       	push   $0xf0104214
f0101d5d:	e8 29 e3 ff ff       	call   f010008b <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d62:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d67:	89 f8                	mov    %edi,%eax
f0101d69:	e8 1f eb ff ff       	call   f010088d <check_va2pa>
f0101d6e:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d71:	74 19                	je     f0101d8c <mem_init+0xdca>
f0101d73:	68 34 40 10 f0       	push   $0xf0104034
f0101d78:	68 3a 42 10 f0       	push   $0xf010423a
f0101d7d:	68 5e 03 00 00       	push   $0x35e
f0101d82:	68 14 42 10 f0       	push   $0xf0104214
f0101d87:	e8 ff e2 ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f0101d8c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d91:	74 19                	je     f0101dac <mem_init+0xdea>
f0101d93:	68 9d 44 10 f0       	push   $0xf010449d
f0101d98:	68 3a 42 10 f0       	push   $0xf010423a
f0101d9d:	68 5f 03 00 00       	push   $0x35f
f0101da2:	68 14 42 10 f0       	push   $0xf0104214
f0101da7:	e8 df e2 ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 0);
f0101dac:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101db1:	74 19                	je     f0101dcc <mem_init+0xe0a>
f0101db3:	68 6b 44 10 f0       	push   $0xf010446b
f0101db8:	68 3a 42 10 f0       	push   $0xf010423a
f0101dbd:	68 60 03 00 00       	push   $0x360
f0101dc2:	68 14 42 10 f0       	push   $0xf0104214
f0101dc7:	e8 bf e2 ff ff       	call   f010008b <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101dcc:	83 ec 0c             	sub    $0xc,%esp
f0101dcf:	6a 00                	push   $0x0
f0101dd1:	e8 f3 ee ff ff       	call   f0100cc9 <page_alloc>
f0101dd6:	83 c4 10             	add    $0x10,%esp
f0101dd9:	39 c3                	cmp    %eax,%ebx
f0101ddb:	75 04                	jne    f0101de1 <mem_init+0xe1f>
f0101ddd:	85 c0                	test   %eax,%eax
f0101ddf:	75 19                	jne    f0101dfa <mem_init+0xe38>
f0101de1:	68 5c 40 10 f0       	push   $0xf010405c
f0101de6:	68 3a 42 10 f0       	push   $0xf010423a
f0101deb:	68 63 03 00 00       	push   $0x363
f0101df0:	68 14 42 10 f0       	push   $0xf0104214
f0101df5:	e8 91 e2 ff ff       	call   f010008b <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101dfa:	83 ec 0c             	sub    $0xc,%esp
f0101dfd:	6a 00                	push   $0x0
f0101dff:	e8 c5 ee ff ff       	call   f0100cc9 <page_alloc>
f0101e04:	83 c4 10             	add    $0x10,%esp
f0101e07:	85 c0                	test   %eax,%eax
f0101e09:	74 19                	je     f0101e24 <mem_init+0xe62>
f0101e0b:	68 bf 43 10 f0       	push   $0xf01043bf
f0101e10:	68 3a 42 10 f0       	push   $0xf010423a
f0101e15:	68 66 03 00 00       	push   $0x366
f0101e1a:	68 14 42 10 f0       	push   $0xf0104214
f0101e1f:	e8 67 e2 ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e24:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f0101e2a:	8b 11                	mov    (%ecx),%edx
f0101e2c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e32:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e35:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101e3b:	c1 f8 03             	sar    $0x3,%eax
f0101e3e:	c1 e0 0c             	shl    $0xc,%eax
f0101e41:	39 c2                	cmp    %eax,%edx
f0101e43:	74 19                	je     f0101e5e <mem_init+0xe9c>
f0101e45:	68 00 3d 10 f0       	push   $0xf0103d00
f0101e4a:	68 3a 42 10 f0       	push   $0xf010423a
f0101e4f:	68 69 03 00 00       	push   $0x369
f0101e54:	68 14 42 10 f0       	push   $0xf0104214
f0101e59:	e8 2d e2 ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f0101e5e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e64:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e67:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e6c:	74 19                	je     f0101e87 <mem_init+0xec5>
f0101e6e:	68 22 44 10 f0       	push   $0xf0104422
f0101e73:	68 3a 42 10 f0       	push   $0xf010423a
f0101e78:	68 6b 03 00 00       	push   $0x36b
f0101e7d:	68 14 42 10 f0       	push   $0xf0104214
f0101e82:	e8 04 e2 ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f0101e87:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e8a:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e90:	83 ec 0c             	sub    $0xc,%esp
f0101e93:	50                   	push   %eax
f0101e94:	e8 a0 ee ff ff       	call   f0100d39 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e99:	83 c4 0c             	add    $0xc,%esp
f0101e9c:	6a 01                	push   $0x1
f0101e9e:	68 00 10 40 00       	push   $0x401000
f0101ea3:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101ea9:	e8 25 ef ff ff       	call   f0100dd3 <pgdir_walk>
f0101eae:	89 c7                	mov    %eax,%edi
f0101eb0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101eb3:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101eb8:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101ebb:	8b 40 04             	mov    0x4(%eax),%eax
f0101ebe:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ec3:	8b 0d 64 69 11 f0    	mov    0xf0116964,%ecx
f0101ec9:	89 c2                	mov    %eax,%edx
f0101ecb:	c1 ea 0c             	shr    $0xc,%edx
f0101ece:	83 c4 10             	add    $0x10,%esp
f0101ed1:	39 ca                	cmp    %ecx,%edx
f0101ed3:	72 15                	jb     f0101eea <mem_init+0xf28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101ed5:	50                   	push   %eax
f0101ed6:	68 9c 3a 10 f0       	push   $0xf0103a9c
f0101edb:	68 72 03 00 00       	push   $0x372
f0101ee0:	68 14 42 10 f0       	push   $0xf0104214
f0101ee5:	e8 a1 e1 ff ff       	call   f010008b <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101eea:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101eef:	39 c7                	cmp    %eax,%edi
f0101ef1:	74 19                	je     f0101f0c <mem_init+0xf4a>
f0101ef3:	68 ae 44 10 f0       	push   $0xf01044ae
f0101ef8:	68 3a 42 10 f0       	push   $0xf010423a
f0101efd:	68 73 03 00 00       	push   $0x373
f0101f02:	68 14 42 10 f0       	push   $0xf0104214
f0101f07:	e8 7f e1 ff ff       	call   f010008b <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101f0c:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f0f:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101f16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f19:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f1f:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f0101f25:	c1 f8 03             	sar    $0x3,%eax
f0101f28:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f2b:	89 c2                	mov    %eax,%edx
f0101f2d:	c1 ea 0c             	shr    $0xc,%edx
f0101f30:	39 d1                	cmp    %edx,%ecx
f0101f32:	77 12                	ja     f0101f46 <mem_init+0xf84>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f34:	50                   	push   %eax
f0101f35:	68 9c 3a 10 f0       	push   $0xf0103a9c
f0101f3a:	6a 52                	push   $0x52
f0101f3c:	68 20 42 10 f0       	push   $0xf0104220
f0101f41:	e8 45 e1 ff ff       	call   f010008b <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f46:	83 ec 04             	sub    $0x4,%esp
f0101f49:	68 00 10 00 00       	push   $0x1000
f0101f4e:	68 ff 00 00 00       	push   $0xff
f0101f53:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f58:	50                   	push   %eax
f0101f59:	e8 f7 11 00 00       	call   f0103155 <memset>
	page_free(pp0);
f0101f5e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101f61:	89 3c 24             	mov    %edi,(%esp)
f0101f64:	e8 d0 ed ff ff       	call   f0100d39 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f69:	83 c4 0c             	add    $0xc,%esp
f0101f6c:	6a 01                	push   $0x1
f0101f6e:	6a 00                	push   $0x0
f0101f70:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0101f76:	e8 58 ee ff ff       	call   f0100dd3 <pgdir_walk>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f7b:	89 fa                	mov    %edi,%edx
f0101f7d:	2b 15 6c 69 11 f0    	sub    0xf011696c,%edx
f0101f83:	c1 fa 03             	sar    $0x3,%edx
f0101f86:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f89:	89 d0                	mov    %edx,%eax
f0101f8b:	c1 e8 0c             	shr    $0xc,%eax
f0101f8e:	83 c4 10             	add    $0x10,%esp
f0101f91:	3b 05 64 69 11 f0    	cmp    0xf0116964,%eax
f0101f97:	72 12                	jb     f0101fab <mem_init+0xfe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f99:	52                   	push   %edx
f0101f9a:	68 9c 3a 10 f0       	push   $0xf0103a9c
f0101f9f:	6a 52                	push   $0x52
f0101fa1:	68 20 42 10 f0       	push   $0xf0104220
f0101fa6:	e8 e0 e0 ff ff       	call   f010008b <_panic>
	return (void *)(pa + KERNBASE);
f0101fab:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101fb1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101fb4:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101fba:	f6 00 01             	testb  $0x1,(%eax)
f0101fbd:	74 19                	je     f0101fd8 <mem_init+0x1016>
f0101fbf:	68 c6 44 10 f0       	push   $0xf01044c6
f0101fc4:	68 3a 42 10 f0       	push   $0xf010423a
f0101fc9:	68 7d 03 00 00       	push   $0x37d
f0101fce:	68 14 42 10 f0       	push   $0xf0104214
f0101fd3:	e8 b3 e0 ff ff       	call   f010008b <_panic>
f0101fd8:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0101fdb:	39 d0                	cmp    %edx,%eax
f0101fdd:	75 db                	jne    f0101fba <mem_init+0xff8>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0101fdf:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f0101fe4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101fea:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fed:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101ff3:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0101ff6:	89 0d 3c 65 11 f0    	mov    %ecx,0xf011653c

	// free the pages we took
	page_free(pp0);
f0101ffc:	83 ec 0c             	sub    $0xc,%esp
f0101fff:	50                   	push   %eax
f0102000:	e8 34 ed ff ff       	call   f0100d39 <page_free>
	page_free(pp1);
f0102005:	89 1c 24             	mov    %ebx,(%esp)
f0102008:	e8 2c ed ff ff       	call   f0100d39 <page_free>
	page_free(pp2);
f010200d:	89 34 24             	mov    %esi,(%esp)
f0102010:	e8 24 ed ff ff       	call   f0100d39 <page_free>

	cprintf("check_page() succeeded!\n");
f0102015:	c7 04 24 dd 44 10 f0 	movl   $0xf01044dd,(%esp)
f010201c:	e8 4b 06 00 00       	call   f010266c <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102021:	a1 6c 69 11 f0       	mov    0xf011696c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102026:	83 c4 10             	add    $0x10,%esp
f0102029:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010202e:	77 15                	ja     f0102045 <mem_init+0x1083>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102030:	50                   	push   %eax
f0102031:	68 c0 3a 10 f0       	push   $0xf0103ac0
f0102036:	68 c6 00 00 00       	push   $0xc6
f010203b:	68 14 42 10 f0       	push   $0xf0104214
f0102040:	e8 46 e0 ff ff       	call   f010008b <_panic>
f0102045:	83 ec 08             	sub    $0x8,%esp
f0102048:	6a 04                	push   $0x4
f010204a:	05 00 00 00 10       	add    $0x10000000,%eax
f010204f:	50                   	push   %eax
f0102050:	b9 00 00 40 00       	mov    $0x400000,%ecx
f0102055:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010205a:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f010205f:	e8 02 ee ff ff       	call   f0100e66 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102064:	83 c4 10             	add    $0x10,%esp
f0102067:	b8 00 c0 10 f0       	mov    $0xf010c000,%eax
f010206c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102071:	77 15                	ja     f0102088 <mem_init+0x10c6>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102073:	50                   	push   %eax
f0102074:	68 c0 3a 10 f0       	push   $0xf0103ac0
f0102079:	68 d3 00 00 00       	push   $0xd3
f010207e:	68 14 42 10 f0       	push   $0xf0104214
f0102083:	e8 03 e0 ff ff       	call   f010008b <_panic>
	//     * [KSTACKTOP-PTSIZE, KSTACKTOP-KSTKSIZE) -- not backed; so if
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102088:	83 ec 08             	sub    $0x8,%esp
f010208b:	6a 02                	push   $0x2
f010208d:	68 00 c0 10 00       	push   $0x10c000
f0102092:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102097:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010209c:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01020a1:	e8 c0 ed ff ff       	call   f0100e66 <boot_map_region>
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	//？？？？？
	//n = (uint32_t)(-1) - KERNBASE + 1;
	//2^32 - 15*16^7 = 1*16^7 = 0x10000000
	boot_map_region(kern_pgdir, KERNBASE, 0x10000000, 0, PTE_W | PTE_P);
f01020a6:	83 c4 08             	add    $0x8,%esp
f01020a9:	6a 03                	push   $0x3
f01020ab:	6a 00                	push   $0x0
f01020ad:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01020b2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020b7:	a1 68 69 11 f0       	mov    0xf0116968,%eax
f01020bc:	e8 a5 ed ff ff       	call   f0100e66 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01020c1:	8b 35 68 69 11 f0    	mov    0xf0116968,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01020c7:	a1 64 69 11 f0       	mov    0xf0116964,%eax
f01020cc:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020cf:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01020d6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01020db:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01020de:	8b 3d 6c 69 11 f0    	mov    0xf011696c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01020e4:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01020e7:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01020ea:	bb 00 00 00 00       	mov    $0x0,%ebx
f01020ef:	eb 55                	jmp    f0102146 <mem_init+0x1184>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01020f1:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01020f7:	89 f0                	mov    %esi,%eax
f01020f9:	e8 8f e7 ff ff       	call   f010088d <check_va2pa>
f01020fe:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102105:	77 15                	ja     f010211c <mem_init+0x115a>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102107:	57                   	push   %edi
f0102108:	68 c0 3a 10 f0       	push   $0xf0103ac0
f010210d:	68 bf 02 00 00       	push   $0x2bf
f0102112:	68 14 42 10 f0       	push   $0xf0104214
f0102117:	e8 6f df ff ff       	call   f010008b <_panic>
f010211c:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f0102123:	39 c2                	cmp    %eax,%edx
f0102125:	74 19                	je     f0102140 <mem_init+0x117e>
f0102127:	68 80 40 10 f0       	push   $0xf0104080
f010212c:	68 3a 42 10 f0       	push   $0xf010423a
f0102131:	68 bf 02 00 00       	push   $0x2bf
f0102136:	68 14 42 10 f0       	push   $0xf0104214
f010213b:	e8 4b df ff ff       	call   f010008b <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102140:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102146:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102149:	77 a6                	ja     f01020f1 <mem_init+0x112f>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010214b:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010214e:	c1 e7 0c             	shl    $0xc,%edi
f0102151:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102156:	eb 30                	jmp    f0102188 <mem_init+0x11c6>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f0102158:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f010215e:	89 f0                	mov    %esi,%eax
f0102160:	e8 28 e7 ff ff       	call   f010088d <check_va2pa>
f0102165:	39 c3                	cmp    %eax,%ebx
f0102167:	74 19                	je     f0102182 <mem_init+0x11c0>
f0102169:	68 b4 40 10 f0       	push   $0xf01040b4
f010216e:	68 3a 42 10 f0       	push   $0xf010423a
f0102173:	68 c4 02 00 00       	push   $0x2c4
f0102178:	68 14 42 10 f0       	push   $0xf0104214
f010217d:	e8 09 df ff ff       	call   f010008b <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);


	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102182:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102188:	39 fb                	cmp    %edi,%ebx
f010218a:	72 cc                	jb     f0102158 <mem_init+0x1196>
f010218c:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102191:	89 da                	mov    %ebx,%edx
f0102193:	89 f0                	mov    %esi,%eax
f0102195:	e8 f3 e6 ff ff       	call   f010088d <check_va2pa>
f010219a:	8d 93 00 40 11 10    	lea    0x10114000(%ebx),%edx
f01021a0:	39 c2                	cmp    %eax,%edx
f01021a2:	74 19                	je     f01021bd <mem_init+0x11fb>
f01021a4:	68 dc 40 10 f0       	push   $0xf01040dc
f01021a9:	68 3a 42 10 f0       	push   $0xf010423a
f01021ae:	68 c8 02 00 00       	push   $0x2c8
f01021b3:	68 14 42 10 f0       	push   $0xf0104214
f01021b8:	e8 ce de ff ff       	call   f010008b <_panic>
f01021bd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f01021c3:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f01021c9:	75 c6                	jne    f0102191 <mem_init+0x11cf>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01021cb:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f01021d0:	89 f0                	mov    %esi,%eax
f01021d2:	e8 b6 e6 ff ff       	call   f010088d <check_va2pa>
f01021d7:	83 f8 ff             	cmp    $0xffffffff,%eax
f01021da:	74 51                	je     f010222d <mem_init+0x126b>
f01021dc:	68 24 41 10 f0       	push   $0xf0104124
f01021e1:	68 3a 42 10 f0       	push   $0xf010423a
f01021e6:	68 c9 02 00 00       	push   $0x2c9
f01021eb:	68 14 42 10 f0       	push   $0xf0104214
f01021f0:	e8 96 de ff ff       	call   f010008b <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01021f5:	3d bc 03 00 00       	cmp    $0x3bc,%eax
f01021fa:	72 36                	jb     f0102232 <mem_init+0x1270>
f01021fc:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f0102201:	76 07                	jbe    f010220a <mem_init+0x1248>
f0102203:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102208:	75 28                	jne    f0102232 <mem_init+0x1270>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
f010220a:	f6 04 86 01          	testb  $0x1,(%esi,%eax,4)
f010220e:	0f 85 83 00 00 00    	jne    f0102297 <mem_init+0x12d5>
f0102214:	68 f6 44 10 f0       	push   $0xf01044f6
f0102219:	68 3a 42 10 f0       	push   $0xf010423a
f010221e:	68 d1 02 00 00       	push   $0x2d1
f0102223:	68 14 42 10 f0       	push   $0xf0104214
f0102228:	e8 5e de ff ff       	call   f010008b <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010222d:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f0102232:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102237:	76 3f                	jbe    f0102278 <mem_init+0x12b6>
				assert(pgdir[i] & PTE_P);
f0102239:	8b 14 86             	mov    (%esi,%eax,4),%edx
f010223c:	f6 c2 01             	test   $0x1,%dl
f010223f:	75 19                	jne    f010225a <mem_init+0x1298>
f0102241:	68 f6 44 10 f0       	push   $0xf01044f6
f0102246:	68 3a 42 10 f0       	push   $0xf010423a
f010224b:	68 d5 02 00 00       	push   $0x2d5
f0102250:	68 14 42 10 f0       	push   $0xf0104214
f0102255:	e8 31 de ff ff       	call   f010008b <_panic>
				assert(pgdir[i] & PTE_W);
f010225a:	f6 c2 02             	test   $0x2,%dl
f010225d:	75 38                	jne    f0102297 <mem_init+0x12d5>
f010225f:	68 07 45 10 f0       	push   $0xf0104507
f0102264:	68 3a 42 10 f0       	push   $0xf010423a
f0102269:	68 d6 02 00 00       	push   $0x2d6
f010226e:	68 14 42 10 f0       	push   $0xf0104214
f0102273:	e8 13 de ff ff       	call   f010008b <_panic>
			} else
				assert(pgdir[i] == 0);
f0102278:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f010227c:	74 19                	je     f0102297 <mem_init+0x12d5>
f010227e:	68 18 45 10 f0       	push   $0xf0104518
f0102283:	68 3a 42 10 f0       	push   $0xf010423a
f0102288:	68 d8 02 00 00       	push   $0x2d8
f010228d:	68 14 42 10 f0       	push   $0xf0104214
f0102292:	e8 f4 dd ff ff       	call   f010008b <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102297:	83 c0 01             	add    $0x1,%eax
f010229a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010229f:	0f 86 50 ff ff ff    	jbe    f01021f5 <mem_init+0x1233>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01022a5:	83 ec 0c             	sub    $0xc,%esp
f01022a8:	68 54 41 10 f0       	push   $0xf0104154
f01022ad:	e8 ba 03 00 00       	call   f010266c <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01022b2:	a1 68 69 11 f0       	mov    0xf0116968,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022b7:	83 c4 10             	add    $0x10,%esp
f01022ba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022bf:	77 15                	ja     f01022d6 <mem_init+0x1314>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01022c1:	50                   	push   %eax
f01022c2:	68 c0 3a 10 f0       	push   $0xf0103ac0
f01022c7:	68 ec 00 00 00       	push   $0xec
f01022cc:	68 14 42 10 f0       	push   $0xf0104214
f01022d1:	e8 b5 dd ff ff       	call   f010008b <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01022d6:	05 00 00 00 10       	add    $0x10000000,%eax
f01022db:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01022de:	b8 00 00 00 00       	mov    $0x0,%eax
f01022e3:	e8 86 e6 ff ff       	call   f010096e <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01022e8:	0f 20 c0             	mov    %cr0,%eax
f01022eb:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01022ee:	0d 23 00 05 80       	or     $0x80050023,%eax
f01022f3:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01022f6:	83 ec 0c             	sub    $0xc,%esp
f01022f9:	6a 00                	push   $0x0
f01022fb:	e8 c9 e9 ff ff       	call   f0100cc9 <page_alloc>
f0102300:	89 c3                	mov    %eax,%ebx
f0102302:	83 c4 10             	add    $0x10,%esp
f0102305:	85 c0                	test   %eax,%eax
f0102307:	75 19                	jne    f0102322 <mem_init+0x1360>
f0102309:	68 14 43 10 f0       	push   $0xf0104314
f010230e:	68 3a 42 10 f0       	push   $0xf010423a
f0102313:	68 98 03 00 00       	push   $0x398
f0102318:	68 14 42 10 f0       	push   $0xf0104214
f010231d:	e8 69 dd ff ff       	call   f010008b <_panic>
	assert((pp1 = page_alloc(0)));
f0102322:	83 ec 0c             	sub    $0xc,%esp
f0102325:	6a 00                	push   $0x0
f0102327:	e8 9d e9 ff ff       	call   f0100cc9 <page_alloc>
f010232c:	89 c7                	mov    %eax,%edi
f010232e:	83 c4 10             	add    $0x10,%esp
f0102331:	85 c0                	test   %eax,%eax
f0102333:	75 19                	jne    f010234e <mem_init+0x138c>
f0102335:	68 2a 43 10 f0       	push   $0xf010432a
f010233a:	68 3a 42 10 f0       	push   $0xf010423a
f010233f:	68 99 03 00 00       	push   $0x399
f0102344:	68 14 42 10 f0       	push   $0xf0104214
f0102349:	e8 3d dd ff ff       	call   f010008b <_panic>
	assert((pp2 = page_alloc(0)));
f010234e:	83 ec 0c             	sub    $0xc,%esp
f0102351:	6a 00                	push   $0x0
f0102353:	e8 71 e9 ff ff       	call   f0100cc9 <page_alloc>
f0102358:	89 c6                	mov    %eax,%esi
f010235a:	83 c4 10             	add    $0x10,%esp
f010235d:	85 c0                	test   %eax,%eax
f010235f:	75 19                	jne    f010237a <mem_init+0x13b8>
f0102361:	68 40 43 10 f0       	push   $0xf0104340
f0102366:	68 3a 42 10 f0       	push   $0xf010423a
f010236b:	68 9a 03 00 00       	push   $0x39a
f0102370:	68 14 42 10 f0       	push   $0xf0104214
f0102375:	e8 11 dd ff ff       	call   f010008b <_panic>
	page_free(pp0);
f010237a:	83 ec 0c             	sub    $0xc,%esp
f010237d:	53                   	push   %ebx
f010237e:	e8 b6 e9 ff ff       	call   f0100d39 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102383:	89 f8                	mov    %edi,%eax
f0102385:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f010238b:	c1 f8 03             	sar    $0x3,%eax
f010238e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102391:	89 c2                	mov    %eax,%edx
f0102393:	c1 ea 0c             	shr    $0xc,%edx
f0102396:	83 c4 10             	add    $0x10,%esp
f0102399:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f010239f:	72 12                	jb     f01023b3 <mem_init+0x13f1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023a1:	50                   	push   %eax
f01023a2:	68 9c 3a 10 f0       	push   $0xf0103a9c
f01023a7:	6a 52                	push   $0x52
f01023a9:	68 20 42 10 f0       	push   $0xf0104220
f01023ae:	e8 d8 dc ff ff       	call   f010008b <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01023b3:	83 ec 04             	sub    $0x4,%esp
f01023b6:	68 00 10 00 00       	push   $0x1000
f01023bb:	6a 01                	push   $0x1
f01023bd:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01023c2:	50                   	push   %eax
f01023c3:	e8 8d 0d 00 00       	call   f0103155 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01023c8:	89 f0                	mov    %esi,%eax
f01023ca:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01023d0:	c1 f8 03             	sar    $0x3,%eax
f01023d3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01023d6:	89 c2                	mov    %eax,%edx
f01023d8:	c1 ea 0c             	shr    $0xc,%edx
f01023db:	83 c4 10             	add    $0x10,%esp
f01023de:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f01023e4:	72 12                	jb     f01023f8 <mem_init+0x1436>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01023e6:	50                   	push   %eax
f01023e7:	68 9c 3a 10 f0       	push   $0xf0103a9c
f01023ec:	6a 52                	push   $0x52
f01023ee:	68 20 42 10 f0       	push   $0xf0104220
f01023f3:	e8 93 dc ff ff       	call   f010008b <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01023f8:	83 ec 04             	sub    $0x4,%esp
f01023fb:	68 00 10 00 00       	push   $0x1000
f0102400:	6a 02                	push   $0x2
f0102402:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102407:	50                   	push   %eax
f0102408:	e8 48 0d 00 00       	call   f0103155 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010240d:	6a 02                	push   $0x2
f010240f:	68 00 10 00 00       	push   $0x1000
f0102414:	57                   	push   %edi
f0102415:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010241b:	e8 3c eb ff ff       	call   f0100f5c <page_insert>
	assert(pp1->pp_ref == 1);
f0102420:	83 c4 20             	add    $0x20,%esp
f0102423:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102428:	74 19                	je     f0102443 <mem_init+0x1481>
f010242a:	68 11 44 10 f0       	push   $0xf0104411
f010242f:	68 3a 42 10 f0       	push   $0xf010423a
f0102434:	68 9f 03 00 00       	push   $0x39f
f0102439:	68 14 42 10 f0       	push   $0xf0104214
f010243e:	e8 48 dc ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102443:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f010244a:	01 01 01 
f010244d:	74 19                	je     f0102468 <mem_init+0x14a6>
f010244f:	68 74 41 10 f0       	push   $0xf0104174
f0102454:	68 3a 42 10 f0       	push   $0xf010423a
f0102459:	68 a0 03 00 00       	push   $0x3a0
f010245e:	68 14 42 10 f0       	push   $0xf0104214
f0102463:	e8 23 dc ff ff       	call   f010008b <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102468:	6a 02                	push   $0x2
f010246a:	68 00 10 00 00       	push   $0x1000
f010246f:	56                   	push   %esi
f0102470:	ff 35 68 69 11 f0    	pushl  0xf0116968
f0102476:	e8 e1 ea ff ff       	call   f0100f5c <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010247b:	83 c4 10             	add    $0x10,%esp
f010247e:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102485:	02 02 02 
f0102488:	74 19                	je     f01024a3 <mem_init+0x14e1>
f010248a:	68 98 41 10 f0       	push   $0xf0104198
f010248f:	68 3a 42 10 f0       	push   $0xf010423a
f0102494:	68 a2 03 00 00       	push   $0x3a2
f0102499:	68 14 42 10 f0       	push   $0xf0104214
f010249e:	e8 e8 db ff ff       	call   f010008b <_panic>
	assert(pp2->pp_ref == 1);
f01024a3:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01024a8:	74 19                	je     f01024c3 <mem_init+0x1501>
f01024aa:	68 33 44 10 f0       	push   $0xf0104433
f01024af:	68 3a 42 10 f0       	push   $0xf010423a
f01024b4:	68 a3 03 00 00       	push   $0x3a3
f01024b9:	68 14 42 10 f0       	push   $0xf0104214
f01024be:	e8 c8 db ff ff       	call   f010008b <_panic>
	assert(pp1->pp_ref == 0);
f01024c3:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f01024c8:	74 19                	je     f01024e3 <mem_init+0x1521>
f01024ca:	68 9d 44 10 f0       	push   $0xf010449d
f01024cf:	68 3a 42 10 f0       	push   $0xf010423a
f01024d4:	68 a4 03 00 00       	push   $0x3a4
f01024d9:	68 14 42 10 f0       	push   $0xf0104214
f01024de:	e8 a8 db ff ff       	call   f010008b <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f01024e3:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f01024ea:	03 03 03 
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01024ed:	89 f0                	mov    %esi,%eax
f01024ef:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f01024f5:	c1 f8 03             	sar    $0x3,%eax
f01024f8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01024fb:	89 c2                	mov    %eax,%edx
f01024fd:	c1 ea 0c             	shr    $0xc,%edx
f0102500:	3b 15 64 69 11 f0    	cmp    0xf0116964,%edx
f0102506:	72 12                	jb     f010251a <mem_init+0x1558>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102508:	50                   	push   %eax
f0102509:	68 9c 3a 10 f0       	push   $0xf0103a9c
f010250e:	6a 52                	push   $0x52
f0102510:	68 20 42 10 f0       	push   $0xf0104220
f0102515:	e8 71 db ff ff       	call   f010008b <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f010251a:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102521:	03 03 03 
f0102524:	74 19                	je     f010253f <mem_init+0x157d>
f0102526:	68 bc 41 10 f0       	push   $0xf01041bc
f010252b:	68 3a 42 10 f0       	push   $0xf010423a
f0102530:	68 a6 03 00 00       	push   $0x3a6
f0102535:	68 14 42 10 f0       	push   $0xf0104214
f010253a:	e8 4c db ff ff       	call   f010008b <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f010253f:	83 ec 08             	sub    $0x8,%esp
f0102542:	68 00 10 00 00       	push   $0x1000
f0102547:	ff 35 68 69 11 f0    	pushl  0xf0116968
f010254d:	e8 c8 e9 ff ff       	call   f0100f1a <page_remove>
	assert(pp2->pp_ref == 0);
f0102552:	83 c4 10             	add    $0x10,%esp
f0102555:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010255a:	74 19                	je     f0102575 <mem_init+0x15b3>
f010255c:	68 6b 44 10 f0       	push   $0xf010446b
f0102561:	68 3a 42 10 f0       	push   $0xf010423a
f0102566:	68 a8 03 00 00       	push   $0x3a8
f010256b:	68 14 42 10 f0       	push   $0xf0104214
f0102570:	e8 16 db ff ff       	call   f010008b <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102575:	8b 0d 68 69 11 f0    	mov    0xf0116968,%ecx
f010257b:	8b 11                	mov    (%ecx),%edx
f010257d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102583:	89 d8                	mov    %ebx,%eax
f0102585:	2b 05 6c 69 11 f0    	sub    0xf011696c,%eax
f010258b:	c1 f8 03             	sar    $0x3,%eax
f010258e:	c1 e0 0c             	shl    $0xc,%eax
f0102591:	39 c2                	cmp    %eax,%edx
f0102593:	74 19                	je     f01025ae <mem_init+0x15ec>
f0102595:	68 00 3d 10 f0       	push   $0xf0103d00
f010259a:	68 3a 42 10 f0       	push   $0xf010423a
f010259f:	68 ab 03 00 00       	push   $0x3ab
f01025a4:	68 14 42 10 f0       	push   $0xf0104214
f01025a9:	e8 dd da ff ff       	call   f010008b <_panic>
	kern_pgdir[0] = 0;
f01025ae:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01025b4:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01025b9:	74 19                	je     f01025d4 <mem_init+0x1612>
f01025bb:	68 22 44 10 f0       	push   $0xf0104422
f01025c0:	68 3a 42 10 f0       	push   $0xf010423a
f01025c5:	68 ad 03 00 00       	push   $0x3ad
f01025ca:	68 14 42 10 f0       	push   $0xf0104214
f01025cf:	e8 b7 da ff ff       	call   f010008b <_panic>
	pp0->pp_ref = 0;
f01025d4:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01025da:	83 ec 0c             	sub    $0xc,%esp
f01025dd:	53                   	push   %ebx
f01025de:	e8 56 e7 ff ff       	call   f0100d39 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01025e3:	c7 04 24 e8 41 10 f0 	movl   $0xf01041e8,(%esp)
f01025ea:	e8 7d 00 00 00       	call   f010266c <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f01025ef:	83 c4 10             	add    $0x10,%esp
f01025f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01025f5:	5b                   	pop    %ebx
f01025f6:	5e                   	pop    %esi
f01025f7:	5f                   	pop    %edi
f01025f8:	5d                   	pop    %ebp
f01025f9:	c3                   	ret    

f01025fa <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01025fa:	55                   	push   %ebp
f01025fb:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01025fd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102600:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f0102603:	5d                   	pop    %ebp
f0102604:	c3                   	ret    

f0102605 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102605:	55                   	push   %ebp
f0102606:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102608:	ba 70 00 00 00       	mov    $0x70,%edx
f010260d:	8b 45 08             	mov    0x8(%ebp),%eax
f0102610:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102611:	ba 71 00 00 00       	mov    $0x71,%edx
f0102616:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102617:	0f b6 c0             	movzbl %al,%eax
}
f010261a:	5d                   	pop    %ebp
f010261b:	c3                   	ret    

f010261c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010261c:	55                   	push   %ebp
f010261d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010261f:	ba 70 00 00 00       	mov    $0x70,%edx
f0102624:	8b 45 08             	mov    0x8(%ebp),%eax
f0102627:	ee                   	out    %al,(%dx)
f0102628:	ba 71 00 00 00       	mov    $0x71,%edx
f010262d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102630:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102631:	5d                   	pop    %ebp
f0102632:	c3                   	ret    

f0102633 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102633:	55                   	push   %ebp
f0102634:	89 e5                	mov    %esp,%ebp
f0102636:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102639:	ff 75 08             	pushl  0x8(%ebp)
f010263c:	e8 bf df ff ff       	call   f0100600 <cputchar>
	*cnt++;
}
f0102641:	83 c4 10             	add    $0x10,%esp
f0102644:	c9                   	leave  
f0102645:	c3                   	ret    

f0102646 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102646:	55                   	push   %ebp
f0102647:	89 e5                	mov    %esp,%ebp
f0102649:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f010264c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102653:	ff 75 0c             	pushl  0xc(%ebp)
f0102656:	ff 75 08             	pushl  0x8(%ebp)
f0102659:	8d 45 f4             	lea    -0xc(%ebp),%eax
f010265c:	50                   	push   %eax
f010265d:	68 33 26 10 f0       	push   $0xf0102633
f0102662:	e8 c9 03 00 00       	call   f0102a30 <vprintfmt>
	return cnt;
}
f0102667:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010266a:	c9                   	leave  
f010266b:	c3                   	ret    

f010266c <cprintf>:

int
cprintf(const char *fmt, ...)
{
f010266c:	55                   	push   %ebp
f010266d:	89 e5                	mov    %esp,%ebp
f010266f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102672:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102675:	50                   	push   %eax
f0102676:	ff 75 08             	pushl  0x8(%ebp)
f0102679:	e8 c8 ff ff ff       	call   f0102646 <vcprintf>
	va_end(ap);

	return cnt;
}
f010267e:	c9                   	leave  
f010267f:	c3                   	ret    

f0102680 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102680:	55                   	push   %ebp
f0102681:	89 e5                	mov    %esp,%ebp
f0102683:	57                   	push   %edi
f0102684:	56                   	push   %esi
f0102685:	53                   	push   %ebx
f0102686:	83 ec 14             	sub    $0x14,%esp
f0102689:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010268c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f010268f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0102692:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f0102695:	8b 1a                	mov    (%edx),%ebx
f0102697:	8b 01                	mov    (%ecx),%eax
f0102699:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010269c:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01026a3:	eb 7f                	jmp    f0102724 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01026a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01026a8:	01 d8                	add    %ebx,%eax
f01026aa:	89 c6                	mov    %eax,%esi
f01026ac:	c1 ee 1f             	shr    $0x1f,%esi
f01026af:	01 c6                	add    %eax,%esi
f01026b1:	d1 fe                	sar    %esi
f01026b3:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01026b6:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01026b9:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01026bc:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01026be:	eb 03                	jmp    f01026c3 <stab_binsearch+0x43>
			m--;
f01026c0:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01026c3:	39 c3                	cmp    %eax,%ebx
f01026c5:	7f 0d                	jg     f01026d4 <stab_binsearch+0x54>
f01026c7:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01026cb:	83 ea 0c             	sub    $0xc,%edx
f01026ce:	39 f9                	cmp    %edi,%ecx
f01026d0:	75 ee                	jne    f01026c0 <stab_binsearch+0x40>
f01026d2:	eb 05                	jmp    f01026d9 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01026d4:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01026d7:	eb 4b                	jmp    f0102724 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01026d9:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01026dc:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01026df:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01026e3:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01026e6:	76 11                	jbe    f01026f9 <stab_binsearch+0x79>
			*region_left = m;
f01026e8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01026eb:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01026ed:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01026f0:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01026f7:	eb 2b                	jmp    f0102724 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01026f9:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01026fc:	73 14                	jae    f0102712 <stab_binsearch+0x92>
			*region_right = m - 1;
f01026fe:	83 e8 01             	sub    $0x1,%eax
f0102701:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0102704:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0102707:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102709:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0102710:	eb 12                	jmp    f0102724 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102712:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0102715:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0102717:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010271b:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010271d:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102724:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0102727:	0f 8e 78 ff ff ff    	jle    f01026a5 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010272d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0102731:	75 0f                	jne    f0102742 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0102733:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102736:	8b 00                	mov    (%eax),%eax
f0102738:	83 e8 01             	sub    $0x1,%eax
f010273b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010273e:	89 06                	mov    %eax,(%esi)
f0102740:	eb 2c                	jmp    f010276e <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102742:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102745:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0102747:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010274a:	8b 0e                	mov    (%esi),%ecx
f010274c:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010274f:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0102752:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102755:	eb 03                	jmp    f010275a <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0102757:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010275a:	39 c8                	cmp    %ecx,%eax
f010275c:	7e 0b                	jle    f0102769 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010275e:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0102762:	83 ea 0c             	sub    $0xc,%edx
f0102765:	39 df                	cmp    %ebx,%edi
f0102767:	75 ee                	jne    f0102757 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102769:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010276c:	89 06                	mov    %eax,(%esi)
	}
}
f010276e:	83 c4 14             	add    $0x14,%esp
f0102771:	5b                   	pop    %ebx
f0102772:	5e                   	pop    %esi
f0102773:	5f                   	pop    %edi
f0102774:	5d                   	pop    %ebp
f0102775:	c3                   	ret    

f0102776 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0102776:	55                   	push   %ebp
f0102777:	89 e5                	mov    %esp,%ebp
f0102779:	57                   	push   %edi
f010277a:	56                   	push   %esi
f010277b:	53                   	push   %ebx
f010277c:	83 ec 1c             	sub    $0x1c,%esp
f010277f:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102782:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0102785:	c7 06 26 45 10 f0    	movl   $0xf0104526,(%esi)
	info->eip_line = 0;
f010278b:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f0102792:	c7 46 08 26 45 10 f0 	movl   $0xf0104526,0x8(%esi)
	info->eip_fn_namelen = 9;
f0102799:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01027a0:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01027a3:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01027aa:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01027b0:	76 11                	jbe    f01027c3 <debuginfo_eip+0x4d>
		// Can't search for user-level addresses yet!
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01027b2:	b8 54 bd 10 f0       	mov    $0xf010bd54,%eax
f01027b7:	3d e9 9f 10 f0       	cmp    $0xf0109fe9,%eax
f01027bc:	77 19                	ja     f01027d7 <debuginfo_eip+0x61>
f01027be:	e9 62 01 00 00       	jmp    f0102925 <debuginfo_eip+0x1af>
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
	} else {
		// Can't search for user-level addresses yet!
  	        panic("User address");
f01027c3:	83 ec 04             	sub    $0x4,%esp
f01027c6:	68 30 45 10 f0       	push   $0xf0104530
f01027cb:	6a 7f                	push   $0x7f
f01027cd:	68 3d 45 10 f0       	push   $0xf010453d
f01027d2:	e8 b4 d8 ff ff       	call   f010008b <_panic>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01027d7:	80 3d 53 bd 10 f0 00 	cmpb   $0x0,0xf010bd53
f01027de:	0f 85 48 01 00 00    	jne    f010292c <debuginfo_eip+0x1b6>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01027e4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01027eb:	b8 e8 9f 10 f0       	mov    $0xf0109fe8,%eax
f01027f0:	2d 5c 47 10 f0       	sub    $0xf010475c,%eax
f01027f5:	c1 f8 02             	sar    $0x2,%eax
f01027f8:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f01027fe:	83 e8 01             	sub    $0x1,%eax
f0102801:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0102804:	83 ec 08             	sub    $0x8,%esp
f0102807:	57                   	push   %edi
f0102808:	6a 64                	push   $0x64
f010280a:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f010280d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0102810:	b8 5c 47 10 f0       	mov    $0xf010475c,%eax
f0102815:	e8 66 fe ff ff       	call   f0102680 <stab_binsearch>
	if (lfile == 0)
f010281a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010281d:	83 c4 10             	add    $0x10,%esp
f0102820:	85 c0                	test   %eax,%eax
f0102822:	0f 84 0b 01 00 00    	je     f0102933 <debuginfo_eip+0x1bd>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0102828:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010282b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010282e:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0102831:	83 ec 08             	sub    $0x8,%esp
f0102834:	57                   	push   %edi
f0102835:	6a 24                	push   $0x24
f0102837:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f010283a:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010283d:	b8 5c 47 10 f0       	mov    $0xf010475c,%eax
f0102842:	e8 39 fe ff ff       	call   f0102680 <stab_binsearch>

	if (lfun <= rfun) {
f0102847:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010284a:	83 c4 10             	add    $0x10,%esp
f010284d:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0102850:	7f 31                	jg     f0102883 <debuginfo_eip+0x10d>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0102852:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102855:	c1 e0 02             	shl    $0x2,%eax
f0102858:	8d 90 5c 47 10 f0    	lea    -0xfefb8a4(%eax),%edx
f010285e:	8b 88 5c 47 10 f0    	mov    -0xfefb8a4(%eax),%ecx
f0102864:	b8 54 bd 10 f0       	mov    $0xf010bd54,%eax
f0102869:	2d e9 9f 10 f0       	sub    $0xf0109fe9,%eax
f010286e:	39 c1                	cmp    %eax,%ecx
f0102870:	73 09                	jae    f010287b <debuginfo_eip+0x105>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0102872:	81 c1 e9 9f 10 f0    	add    $0xf0109fe9,%ecx
f0102878:	89 4e 08             	mov    %ecx,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010287b:	8b 42 08             	mov    0x8(%edx),%eax
f010287e:	89 46 10             	mov    %eax,0x10(%esi)
f0102881:	eb 06                	jmp    f0102889 <debuginfo_eip+0x113>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0102883:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0102886:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0102889:	83 ec 08             	sub    $0x8,%esp
f010288c:	6a 3a                	push   $0x3a
f010288e:	ff 76 08             	pushl  0x8(%esi)
f0102891:	e8 a3 08 00 00       	call   f0103139 <strfind>
f0102896:	2b 46 08             	sub    0x8(%esi),%eax
f0102899:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010289c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010289f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01028a2:	8d 04 85 5c 47 10 f0 	lea    -0xfefb8a4(,%eax,4),%eax
f01028a9:	83 c4 10             	add    $0x10,%esp
f01028ac:	eb 06                	jmp    f01028b4 <debuginfo_eip+0x13e>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01028ae:	83 eb 01             	sub    $0x1,%ebx
f01028b1:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01028b4:	39 fb                	cmp    %edi,%ebx
f01028b6:	7c 34                	jl     f01028ec <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f01028b8:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01028bc:	80 fa 84             	cmp    $0x84,%dl
f01028bf:	74 0b                	je     f01028cc <debuginfo_eip+0x156>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01028c1:	80 fa 64             	cmp    $0x64,%dl
f01028c4:	75 e8                	jne    f01028ae <debuginfo_eip+0x138>
f01028c6:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01028ca:	74 e2                	je     f01028ae <debuginfo_eip+0x138>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01028cc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01028cf:	8b 14 85 5c 47 10 f0 	mov    -0xfefb8a4(,%eax,4),%edx
f01028d6:	b8 54 bd 10 f0       	mov    $0xf010bd54,%eax
f01028db:	2d e9 9f 10 f0       	sub    $0xf0109fe9,%eax
f01028e0:	39 c2                	cmp    %eax,%edx
f01028e2:	73 08                	jae    f01028ec <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01028e4:	81 c2 e9 9f 10 f0    	add    $0xf0109fe9,%edx
f01028ea:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01028ec:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01028ef:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01028f2:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01028f7:	39 cb                	cmp    %ecx,%ebx
f01028f9:	7d 44                	jge    f010293f <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
f01028fb:	8d 53 01             	lea    0x1(%ebx),%edx
f01028fe:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0102901:	8d 04 85 5c 47 10 f0 	lea    -0xfefb8a4(,%eax,4),%eax
f0102908:	eb 07                	jmp    f0102911 <debuginfo_eip+0x19b>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f010290a:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010290e:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0102911:	39 ca                	cmp    %ecx,%edx
f0102913:	74 25                	je     f010293a <debuginfo_eip+0x1c4>
f0102915:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0102918:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f010291c:	74 ec                	je     f010290a <debuginfo_eip+0x194>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010291e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102923:	eb 1a                	jmp    f010293f <debuginfo_eip+0x1c9>
  	        panic("User address");
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0102925:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010292a:	eb 13                	jmp    f010293f <debuginfo_eip+0x1c9>
f010292c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102931:	eb 0c                	jmp    f010293f <debuginfo_eip+0x1c9>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0102933:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0102938:	eb 05                	jmp    f010293f <debuginfo_eip+0x1c9>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010293a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010293f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102942:	5b                   	pop    %ebx
f0102943:	5e                   	pop    %esi
f0102944:	5f                   	pop    %edi
f0102945:	5d                   	pop    %ebp
f0102946:	c3                   	ret    

f0102947 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0102947:	55                   	push   %ebp
f0102948:	89 e5                	mov    %esp,%ebp
f010294a:	57                   	push   %edi
f010294b:	56                   	push   %esi
f010294c:	53                   	push   %ebx
f010294d:	83 ec 1c             	sub    $0x1c,%esp
f0102950:	89 c7                	mov    %eax,%edi
f0102952:	89 d6                	mov    %edx,%esi
f0102954:	8b 45 08             	mov    0x8(%ebp),%eax
f0102957:	8b 55 0c             	mov    0xc(%ebp),%edx
f010295a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010295d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0102960:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0102963:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102968:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010296b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010296e:	39 d3                	cmp    %edx,%ebx
f0102970:	72 05                	jb     f0102977 <printnum+0x30>
f0102972:	39 45 10             	cmp    %eax,0x10(%ebp)
f0102975:	77 45                	ja     f01029bc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0102977:	83 ec 0c             	sub    $0xc,%esp
f010297a:	ff 75 18             	pushl  0x18(%ebp)
f010297d:	8b 45 14             	mov    0x14(%ebp),%eax
f0102980:	8d 58 ff             	lea    -0x1(%eax),%ebx
f0102983:	53                   	push   %ebx
f0102984:	ff 75 10             	pushl  0x10(%ebp)
f0102987:	83 ec 08             	sub    $0x8,%esp
f010298a:	ff 75 e4             	pushl  -0x1c(%ebp)
f010298d:	ff 75 e0             	pushl  -0x20(%ebp)
f0102990:	ff 75 dc             	pushl  -0x24(%ebp)
f0102993:	ff 75 d8             	pushl  -0x28(%ebp)
f0102996:	e8 c5 09 00 00       	call   f0103360 <__udivdi3>
f010299b:	83 c4 18             	add    $0x18,%esp
f010299e:	52                   	push   %edx
f010299f:	50                   	push   %eax
f01029a0:	89 f2                	mov    %esi,%edx
f01029a2:	89 f8                	mov    %edi,%eax
f01029a4:	e8 9e ff ff ff       	call   f0102947 <printnum>
f01029a9:	83 c4 20             	add    $0x20,%esp
f01029ac:	eb 18                	jmp    f01029c6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01029ae:	83 ec 08             	sub    $0x8,%esp
f01029b1:	56                   	push   %esi
f01029b2:	ff 75 18             	pushl  0x18(%ebp)
f01029b5:	ff d7                	call   *%edi
f01029b7:	83 c4 10             	add    $0x10,%esp
f01029ba:	eb 03                	jmp    f01029bf <printnum+0x78>
f01029bc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01029bf:	83 eb 01             	sub    $0x1,%ebx
f01029c2:	85 db                	test   %ebx,%ebx
f01029c4:	7f e8                	jg     f01029ae <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01029c6:	83 ec 08             	sub    $0x8,%esp
f01029c9:	56                   	push   %esi
f01029ca:	83 ec 04             	sub    $0x4,%esp
f01029cd:	ff 75 e4             	pushl  -0x1c(%ebp)
f01029d0:	ff 75 e0             	pushl  -0x20(%ebp)
f01029d3:	ff 75 dc             	pushl  -0x24(%ebp)
f01029d6:	ff 75 d8             	pushl  -0x28(%ebp)
f01029d9:	e8 b2 0a 00 00       	call   f0103490 <__umoddi3>
f01029de:	83 c4 14             	add    $0x14,%esp
f01029e1:	0f be 80 4b 45 10 f0 	movsbl -0xfefbab5(%eax),%eax
f01029e8:	50                   	push   %eax
f01029e9:	ff d7                	call   *%edi
}
f01029eb:	83 c4 10             	add    $0x10,%esp
f01029ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01029f1:	5b                   	pop    %ebx
f01029f2:	5e                   	pop    %esi
f01029f3:	5f                   	pop    %edi
f01029f4:	5d                   	pop    %ebp
f01029f5:	c3                   	ret    

f01029f6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01029f6:	55                   	push   %ebp
f01029f7:	89 e5                	mov    %esp,%ebp
f01029f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01029fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0102a00:	8b 10                	mov    (%eax),%edx
f0102a02:	3b 50 04             	cmp    0x4(%eax),%edx
f0102a05:	73 0a                	jae    f0102a11 <sprintputch+0x1b>
		*b->buf++ = ch;
f0102a07:	8d 4a 01             	lea    0x1(%edx),%ecx
f0102a0a:	89 08                	mov    %ecx,(%eax)
f0102a0c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a0f:	88 02                	mov    %al,(%edx)
}
f0102a11:	5d                   	pop    %ebp
f0102a12:	c3                   	ret    

f0102a13 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0102a13:	55                   	push   %ebp
f0102a14:	89 e5                	mov    %esp,%ebp
f0102a16:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0102a19:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0102a1c:	50                   	push   %eax
f0102a1d:	ff 75 10             	pushl  0x10(%ebp)
f0102a20:	ff 75 0c             	pushl  0xc(%ebp)
f0102a23:	ff 75 08             	pushl  0x8(%ebp)
f0102a26:	e8 05 00 00 00       	call   f0102a30 <vprintfmt>
	va_end(ap);
}
f0102a2b:	83 c4 10             	add    $0x10,%esp
f0102a2e:	c9                   	leave  
f0102a2f:	c3                   	ret    

f0102a30 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0102a30:	55                   	push   %ebp
f0102a31:	89 e5                	mov    %esp,%ebp
f0102a33:	57                   	push   %edi
f0102a34:	56                   	push   %esi
f0102a35:	53                   	push   %ebx
f0102a36:	83 ec 2c             	sub    $0x2c,%esp
f0102a39:	8b 75 08             	mov    0x8(%ebp),%esi
f0102a3c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102a3f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0102a42:	eb 12                	jmp    f0102a56 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0102a44:	85 c0                	test   %eax,%eax
f0102a46:	0f 84 42 04 00 00    	je     f0102e8e <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0102a4c:	83 ec 08             	sub    $0x8,%esp
f0102a4f:	53                   	push   %ebx
f0102a50:	50                   	push   %eax
f0102a51:	ff d6                	call   *%esi
f0102a53:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0102a56:	83 c7 01             	add    $0x1,%edi
f0102a59:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102a5d:	83 f8 25             	cmp    $0x25,%eax
f0102a60:	75 e2                	jne    f0102a44 <vprintfmt+0x14>
f0102a62:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0102a66:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0102a6d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102a74:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0102a7b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102a80:	eb 07                	jmp    f0102a89 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102a82:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0102a85:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102a89:	8d 47 01             	lea    0x1(%edi),%eax
f0102a8c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0102a8f:	0f b6 07             	movzbl (%edi),%eax
f0102a92:	0f b6 d0             	movzbl %al,%edx
f0102a95:	83 e8 23             	sub    $0x23,%eax
f0102a98:	3c 55                	cmp    $0x55,%al
f0102a9a:	0f 87 d3 03 00 00    	ja     f0102e73 <vprintfmt+0x443>
f0102aa0:	0f b6 c0             	movzbl %al,%eax
f0102aa3:	ff 24 85 d8 45 10 f0 	jmp    *-0xfefba28(,%eax,4)
f0102aaa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0102aad:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0102ab1:	eb d6                	jmp    f0102a89 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ab3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102ab6:	b8 00 00 00 00       	mov    $0x0,%eax
f0102abb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0102abe:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0102ac1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0102ac5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0102ac8:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0102acb:	83 f9 09             	cmp    $0x9,%ecx
f0102ace:	77 3f                	ja     f0102b0f <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0102ad0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0102ad3:	eb e9                	jmp    f0102abe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0102ad5:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ad8:	8b 00                	mov    (%eax),%eax
f0102ada:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0102add:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ae0:	8d 40 04             	lea    0x4(%eax),%eax
f0102ae3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ae6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0102ae9:	eb 2a                	jmp    f0102b15 <vprintfmt+0xe5>
f0102aeb:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102aee:	85 c0                	test   %eax,%eax
f0102af0:	ba 00 00 00 00       	mov    $0x0,%edx
f0102af5:	0f 49 d0             	cmovns %eax,%edx
f0102af8:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102afb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102afe:	eb 89                	jmp    f0102a89 <vprintfmt+0x59>
f0102b00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0102b03:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0102b0a:	e9 7a ff ff ff       	jmp    f0102a89 <vprintfmt+0x59>
f0102b0f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0102b12:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0102b15:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102b19:	0f 89 6a ff ff ff    	jns    f0102a89 <vprintfmt+0x59>
				width = precision, precision = -1;
f0102b1f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0102b22:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102b25:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0102b2c:	e9 58 ff ff ff       	jmp    f0102a89 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0102b31:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b34:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0102b37:	e9 4d ff ff ff       	jmp    f0102a89 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102b3c:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b3f:	8d 78 04             	lea    0x4(%eax),%edi
f0102b42:	83 ec 08             	sub    $0x8,%esp
f0102b45:	53                   	push   %ebx
f0102b46:	ff 30                	pushl  (%eax)
f0102b48:	ff d6                	call   *%esi
			break;
f0102b4a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0102b4d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b50:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0102b53:	e9 fe fe ff ff       	jmp    f0102a56 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102b58:	8b 45 14             	mov    0x14(%ebp),%eax
f0102b5b:	8d 78 04             	lea    0x4(%eax),%edi
f0102b5e:	8b 00                	mov    (%eax),%eax
f0102b60:	99                   	cltd   
f0102b61:	31 d0                	xor    %edx,%eax
f0102b63:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0102b65:	83 f8 06             	cmp    $0x6,%eax
f0102b68:	7f 0b                	jg     f0102b75 <vprintfmt+0x145>
f0102b6a:	8b 14 85 30 47 10 f0 	mov    -0xfefb8d0(,%eax,4),%edx
f0102b71:	85 d2                	test   %edx,%edx
f0102b73:	75 1b                	jne    f0102b90 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0102b75:	50                   	push   %eax
f0102b76:	68 63 45 10 f0       	push   $0xf0104563
f0102b7b:	53                   	push   %ebx
f0102b7c:	56                   	push   %esi
f0102b7d:	e8 91 fe ff ff       	call   f0102a13 <printfmt>
f0102b82:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102b85:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102b88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0102b8b:	e9 c6 fe ff ff       	jmp    f0102a56 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0102b90:	52                   	push   %edx
f0102b91:	68 4c 42 10 f0       	push   $0xf010424c
f0102b96:	53                   	push   %ebx
f0102b97:	56                   	push   %esi
f0102b98:	e8 76 fe ff ff       	call   f0102a13 <printfmt>
f0102b9d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0102ba0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102ba3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102ba6:	e9 ab fe ff ff       	jmp    f0102a56 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102bab:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bae:	83 c0 04             	add    $0x4,%eax
f0102bb1:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102bb4:	8b 45 14             	mov    0x14(%ebp),%eax
f0102bb7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0102bb9:	85 ff                	test   %edi,%edi
f0102bbb:	b8 5c 45 10 f0       	mov    $0xf010455c,%eax
f0102bc0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0102bc3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0102bc7:	0f 8e 94 00 00 00    	jle    f0102c61 <vprintfmt+0x231>
f0102bcd:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0102bd1:	0f 84 98 00 00 00    	je     f0102c6f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0102bd7:	83 ec 08             	sub    $0x8,%esp
f0102bda:	ff 75 d0             	pushl  -0x30(%ebp)
f0102bdd:	57                   	push   %edi
f0102bde:	e8 0c 04 00 00       	call   f0102fef <strnlen>
f0102be3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0102be6:	29 c1                	sub    %eax,%ecx
f0102be8:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0102beb:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0102bee:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0102bf2:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0102bf5:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0102bf8:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102bfa:	eb 0f                	jmp    f0102c0b <vprintfmt+0x1db>
					putch(padc, putdat);
f0102bfc:	83 ec 08             	sub    $0x8,%esp
f0102bff:	53                   	push   %ebx
f0102c00:	ff 75 e0             	pushl  -0x20(%ebp)
f0102c03:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0102c05:	83 ef 01             	sub    $0x1,%edi
f0102c08:	83 c4 10             	add    $0x10,%esp
f0102c0b:	85 ff                	test   %edi,%edi
f0102c0d:	7f ed                	jg     f0102bfc <vprintfmt+0x1cc>
f0102c0f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102c12:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0102c15:	85 c9                	test   %ecx,%ecx
f0102c17:	b8 00 00 00 00       	mov    $0x0,%eax
f0102c1c:	0f 49 c1             	cmovns %ecx,%eax
f0102c1f:	29 c1                	sub    %eax,%ecx
f0102c21:	89 75 08             	mov    %esi,0x8(%ebp)
f0102c24:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102c27:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102c2a:	89 cb                	mov    %ecx,%ebx
f0102c2c:	eb 4d                	jmp    f0102c7b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0102c2e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0102c32:	74 1b                	je     f0102c4f <vprintfmt+0x21f>
f0102c34:	0f be c0             	movsbl %al,%eax
f0102c37:	83 e8 20             	sub    $0x20,%eax
f0102c3a:	83 f8 5e             	cmp    $0x5e,%eax
f0102c3d:	76 10                	jbe    f0102c4f <vprintfmt+0x21f>
					putch('?', putdat);
f0102c3f:	83 ec 08             	sub    $0x8,%esp
f0102c42:	ff 75 0c             	pushl  0xc(%ebp)
f0102c45:	6a 3f                	push   $0x3f
f0102c47:	ff 55 08             	call   *0x8(%ebp)
f0102c4a:	83 c4 10             	add    $0x10,%esp
f0102c4d:	eb 0d                	jmp    f0102c5c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0102c4f:	83 ec 08             	sub    $0x8,%esp
f0102c52:	ff 75 0c             	pushl  0xc(%ebp)
f0102c55:	52                   	push   %edx
f0102c56:	ff 55 08             	call   *0x8(%ebp)
f0102c59:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0102c5c:	83 eb 01             	sub    $0x1,%ebx
f0102c5f:	eb 1a                	jmp    f0102c7b <vprintfmt+0x24b>
f0102c61:	89 75 08             	mov    %esi,0x8(%ebp)
f0102c64:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102c67:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102c6a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102c6d:	eb 0c                	jmp    f0102c7b <vprintfmt+0x24b>
f0102c6f:	89 75 08             	mov    %esi,0x8(%ebp)
f0102c72:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0102c75:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0102c78:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0102c7b:	83 c7 01             	add    $0x1,%edi
f0102c7e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0102c82:	0f be d0             	movsbl %al,%edx
f0102c85:	85 d2                	test   %edx,%edx
f0102c87:	74 23                	je     f0102cac <vprintfmt+0x27c>
f0102c89:	85 f6                	test   %esi,%esi
f0102c8b:	78 a1                	js     f0102c2e <vprintfmt+0x1fe>
f0102c8d:	83 ee 01             	sub    $0x1,%esi
f0102c90:	79 9c                	jns    f0102c2e <vprintfmt+0x1fe>
f0102c92:	89 df                	mov    %ebx,%edi
f0102c94:	8b 75 08             	mov    0x8(%ebp),%esi
f0102c97:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102c9a:	eb 18                	jmp    f0102cb4 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0102c9c:	83 ec 08             	sub    $0x8,%esp
f0102c9f:	53                   	push   %ebx
f0102ca0:	6a 20                	push   $0x20
f0102ca2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0102ca4:	83 ef 01             	sub    $0x1,%edi
f0102ca7:	83 c4 10             	add    $0x10,%esp
f0102caa:	eb 08                	jmp    f0102cb4 <vprintfmt+0x284>
f0102cac:	89 df                	mov    %ebx,%edi
f0102cae:	8b 75 08             	mov    0x8(%ebp),%esi
f0102cb1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0102cb4:	85 ff                	test   %edi,%edi
f0102cb6:	7f e4                	jg     f0102c9c <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0102cb8:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102cbb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102cbe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102cc1:	e9 90 fd ff ff       	jmp    f0102a56 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102cc6:	83 f9 01             	cmp    $0x1,%ecx
f0102cc9:	7e 19                	jle    f0102ce4 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0102ccb:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cce:	8b 50 04             	mov    0x4(%eax),%edx
f0102cd1:	8b 00                	mov    (%eax),%eax
f0102cd3:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102cd6:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0102cd9:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cdc:	8d 40 08             	lea    0x8(%eax),%eax
f0102cdf:	89 45 14             	mov    %eax,0x14(%ebp)
f0102ce2:	eb 38                	jmp    f0102d1c <vprintfmt+0x2ec>
	else if (lflag)
f0102ce4:	85 c9                	test   %ecx,%ecx
f0102ce6:	74 1b                	je     f0102d03 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0102ce8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102ceb:	8b 00                	mov    (%eax),%eax
f0102ced:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102cf0:	89 c1                	mov    %eax,%ecx
f0102cf2:	c1 f9 1f             	sar    $0x1f,%ecx
f0102cf5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102cf8:	8b 45 14             	mov    0x14(%ebp),%eax
f0102cfb:	8d 40 04             	lea    0x4(%eax),%eax
f0102cfe:	89 45 14             	mov    %eax,0x14(%ebp)
f0102d01:	eb 19                	jmp    f0102d1c <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0102d03:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d06:	8b 00                	mov    (%eax),%eax
f0102d08:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102d0b:	89 c1                	mov    %eax,%ecx
f0102d0d:	c1 f9 1f             	sar    $0x1f,%ecx
f0102d10:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0102d13:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d16:	8d 40 04             	lea    0x4(%eax),%eax
f0102d19:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0102d1c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d1f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0102d22:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0102d27:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0102d2b:	0f 89 0e 01 00 00    	jns    f0102e3f <vprintfmt+0x40f>
				putch('-', putdat);
f0102d31:	83 ec 08             	sub    $0x8,%esp
f0102d34:	53                   	push   %ebx
f0102d35:	6a 2d                	push   $0x2d
f0102d37:	ff d6                	call   *%esi
				num = -(long long) num;
f0102d39:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102d3c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0102d3f:	f7 da                	neg    %edx
f0102d41:	83 d1 00             	adc    $0x0,%ecx
f0102d44:	f7 d9                	neg    %ecx
f0102d46:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0102d49:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102d4e:	e9 ec 00 00 00       	jmp    f0102e3f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102d53:	83 f9 01             	cmp    $0x1,%ecx
f0102d56:	7e 18                	jle    f0102d70 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0102d58:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d5b:	8b 10                	mov    (%eax),%edx
f0102d5d:	8b 48 04             	mov    0x4(%eax),%ecx
f0102d60:	8d 40 08             	lea    0x8(%eax),%eax
f0102d63:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102d66:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102d6b:	e9 cf 00 00 00       	jmp    f0102e3f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0102d70:	85 c9                	test   %ecx,%ecx
f0102d72:	74 1a                	je     f0102d8e <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0102d74:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d77:	8b 10                	mov    (%eax),%edx
f0102d79:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102d7e:	8d 40 04             	lea    0x4(%eax),%eax
f0102d81:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102d84:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102d89:	e9 b1 00 00 00       	jmp    f0102e3f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0102d8e:	8b 45 14             	mov    0x14(%ebp),%eax
f0102d91:	8b 10                	mov    (%eax),%edx
f0102d93:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102d98:	8d 40 04             	lea    0x4(%eax),%eax
f0102d9b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0102d9e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0102da3:	e9 97 00 00 00       	jmp    f0102e3f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0102da8:	83 ec 08             	sub    $0x8,%esp
f0102dab:	53                   	push   %ebx
f0102dac:	6a 58                	push   $0x58
f0102dae:	ff d6                	call   *%esi
			putch('X', putdat);
f0102db0:	83 c4 08             	add    $0x8,%esp
f0102db3:	53                   	push   %ebx
f0102db4:	6a 58                	push   $0x58
f0102db6:	ff d6                	call   *%esi
			putch('X', putdat);
f0102db8:	83 c4 08             	add    $0x8,%esp
f0102dbb:	53                   	push   %ebx
f0102dbc:	6a 58                	push   $0x58
f0102dbe:	ff d6                	call   *%esi
			break;
f0102dc0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102dc3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0102dc6:	e9 8b fc ff ff       	jmp    f0102a56 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0102dcb:	83 ec 08             	sub    $0x8,%esp
f0102dce:	53                   	push   %ebx
f0102dcf:	6a 30                	push   $0x30
f0102dd1:	ff d6                	call   *%esi
			putch('x', putdat);
f0102dd3:	83 c4 08             	add    $0x8,%esp
f0102dd6:	53                   	push   %ebx
f0102dd7:	6a 78                	push   $0x78
f0102dd9:	ff d6                	call   *%esi
			num = (unsigned long long)
f0102ddb:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dde:	8b 10                	mov    (%eax),%edx
f0102de0:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0102de5:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0102de8:	8d 40 04             	lea    0x4(%eax),%eax
f0102deb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0102dee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0102df3:	eb 4a                	jmp    f0102e3f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0102df5:	83 f9 01             	cmp    $0x1,%ecx
f0102df8:	7e 15                	jle    f0102e0f <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0102dfa:	8b 45 14             	mov    0x14(%ebp),%eax
f0102dfd:	8b 10                	mov    (%eax),%edx
f0102dff:	8b 48 04             	mov    0x4(%eax),%ecx
f0102e02:	8d 40 08             	lea    0x8(%eax),%eax
f0102e05:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102e08:	b8 10 00 00 00       	mov    $0x10,%eax
f0102e0d:	eb 30                	jmp    f0102e3f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0102e0f:	85 c9                	test   %ecx,%ecx
f0102e11:	74 17                	je     f0102e2a <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f0102e13:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e16:	8b 10                	mov    (%eax),%edx
f0102e18:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102e1d:	8d 40 04             	lea    0x4(%eax),%eax
f0102e20:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102e23:	b8 10 00 00 00       	mov    $0x10,%eax
f0102e28:	eb 15                	jmp    f0102e3f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0102e2a:	8b 45 14             	mov    0x14(%ebp),%eax
f0102e2d:	8b 10                	mov    (%eax),%edx
f0102e2f:	b9 00 00 00 00       	mov    $0x0,%ecx
f0102e34:	8d 40 04             	lea    0x4(%eax),%eax
f0102e37:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0102e3a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0102e3f:	83 ec 0c             	sub    $0xc,%esp
f0102e42:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0102e46:	57                   	push   %edi
f0102e47:	ff 75 e0             	pushl  -0x20(%ebp)
f0102e4a:	50                   	push   %eax
f0102e4b:	51                   	push   %ecx
f0102e4c:	52                   	push   %edx
f0102e4d:	89 da                	mov    %ebx,%edx
f0102e4f:	89 f0                	mov    %esi,%eax
f0102e51:	e8 f1 fa ff ff       	call   f0102947 <printnum>
			break;
f0102e56:	83 c4 20             	add    $0x20,%esp
f0102e59:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0102e5c:	e9 f5 fb ff ff       	jmp    f0102a56 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0102e61:	83 ec 08             	sub    $0x8,%esp
f0102e64:	53                   	push   %ebx
f0102e65:	52                   	push   %edx
f0102e66:	ff d6                	call   *%esi
			break;
f0102e68:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0102e6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0102e6e:	e9 e3 fb ff ff       	jmp    f0102a56 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0102e73:	83 ec 08             	sub    $0x8,%esp
f0102e76:	53                   	push   %ebx
f0102e77:	6a 25                	push   $0x25
f0102e79:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0102e7b:	83 c4 10             	add    $0x10,%esp
f0102e7e:	eb 03                	jmp    f0102e83 <vprintfmt+0x453>
f0102e80:	83 ef 01             	sub    $0x1,%edi
f0102e83:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0102e87:	75 f7                	jne    f0102e80 <vprintfmt+0x450>
f0102e89:	e9 c8 fb ff ff       	jmp    f0102a56 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0102e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102e91:	5b                   	pop    %ebx
f0102e92:	5e                   	pop    %esi
f0102e93:	5f                   	pop    %edi
f0102e94:	5d                   	pop    %ebp
f0102e95:	c3                   	ret    

f0102e96 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0102e96:	55                   	push   %ebp
f0102e97:	89 e5                	mov    %esp,%ebp
f0102e99:	83 ec 18             	sub    $0x18,%esp
f0102e9c:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e9f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0102ea2:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0102ea5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0102ea9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0102eac:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0102eb3:	85 c0                	test   %eax,%eax
f0102eb5:	74 26                	je     f0102edd <vsnprintf+0x47>
f0102eb7:	85 d2                	test   %edx,%edx
f0102eb9:	7e 22                	jle    f0102edd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0102ebb:	ff 75 14             	pushl  0x14(%ebp)
f0102ebe:	ff 75 10             	pushl  0x10(%ebp)
f0102ec1:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0102ec4:	50                   	push   %eax
f0102ec5:	68 f6 29 10 f0       	push   $0xf01029f6
f0102eca:	e8 61 fb ff ff       	call   f0102a30 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0102ecf:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0102ed2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0102ed5:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102ed8:	83 c4 10             	add    $0x10,%esp
f0102edb:	eb 05                	jmp    f0102ee2 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0102edd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0102ee2:	c9                   	leave  
f0102ee3:	c3                   	ret    

f0102ee4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0102ee4:	55                   	push   %ebp
f0102ee5:	89 e5                	mov    %esp,%ebp
f0102ee7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0102eea:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0102eed:	50                   	push   %eax
f0102eee:	ff 75 10             	pushl  0x10(%ebp)
f0102ef1:	ff 75 0c             	pushl  0xc(%ebp)
f0102ef4:	ff 75 08             	pushl  0x8(%ebp)
f0102ef7:	e8 9a ff ff ff       	call   f0102e96 <vsnprintf>
	va_end(ap);

	return rc;
}
f0102efc:	c9                   	leave  
f0102efd:	c3                   	ret    

f0102efe <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0102efe:	55                   	push   %ebp
f0102eff:	89 e5                	mov    %esp,%ebp
f0102f01:	57                   	push   %edi
f0102f02:	56                   	push   %esi
f0102f03:	53                   	push   %ebx
f0102f04:	83 ec 0c             	sub    $0xc,%esp
f0102f07:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0102f0a:	85 c0                	test   %eax,%eax
f0102f0c:	74 11                	je     f0102f1f <readline+0x21>
		cprintf("%s", prompt);
f0102f0e:	83 ec 08             	sub    $0x8,%esp
f0102f11:	50                   	push   %eax
f0102f12:	68 4c 42 10 f0       	push   $0xf010424c
f0102f17:	e8 50 f7 ff ff       	call   f010266c <cprintf>
f0102f1c:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0102f1f:	83 ec 0c             	sub    $0xc,%esp
f0102f22:	6a 00                	push   $0x0
f0102f24:	e8 f8 d6 ff ff       	call   f0100621 <iscons>
f0102f29:	89 c7                	mov    %eax,%edi
f0102f2b:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0102f2e:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0102f33:	e8 d8 d6 ff ff       	call   f0100610 <getchar>
f0102f38:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0102f3a:	85 c0                	test   %eax,%eax
f0102f3c:	79 18                	jns    f0102f56 <readline+0x58>
			cprintf("read error: %e\n", c);
f0102f3e:	83 ec 08             	sub    $0x8,%esp
f0102f41:	50                   	push   %eax
f0102f42:	68 4c 47 10 f0       	push   $0xf010474c
f0102f47:	e8 20 f7 ff ff       	call   f010266c <cprintf>
			return NULL;
f0102f4c:	83 c4 10             	add    $0x10,%esp
f0102f4f:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f54:	eb 79                	jmp    f0102fcf <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0102f56:	83 f8 08             	cmp    $0x8,%eax
f0102f59:	0f 94 c2             	sete   %dl
f0102f5c:	83 f8 7f             	cmp    $0x7f,%eax
f0102f5f:	0f 94 c0             	sete   %al
f0102f62:	08 c2                	or     %al,%dl
f0102f64:	74 1a                	je     f0102f80 <readline+0x82>
f0102f66:	85 f6                	test   %esi,%esi
f0102f68:	7e 16                	jle    f0102f80 <readline+0x82>
			if (echoing)
f0102f6a:	85 ff                	test   %edi,%edi
f0102f6c:	74 0d                	je     f0102f7b <readline+0x7d>
				cputchar('\b');
f0102f6e:	83 ec 0c             	sub    $0xc,%esp
f0102f71:	6a 08                	push   $0x8
f0102f73:	e8 88 d6 ff ff       	call   f0100600 <cputchar>
f0102f78:	83 c4 10             	add    $0x10,%esp
			i--;
f0102f7b:	83 ee 01             	sub    $0x1,%esi
f0102f7e:	eb b3                	jmp    f0102f33 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0102f80:	83 fb 1f             	cmp    $0x1f,%ebx
f0102f83:	7e 23                	jle    f0102fa8 <readline+0xaa>
f0102f85:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0102f8b:	7f 1b                	jg     f0102fa8 <readline+0xaa>
			if (echoing)
f0102f8d:	85 ff                	test   %edi,%edi
f0102f8f:	74 0c                	je     f0102f9d <readline+0x9f>
				cputchar(c);
f0102f91:	83 ec 0c             	sub    $0xc,%esp
f0102f94:	53                   	push   %ebx
f0102f95:	e8 66 d6 ff ff       	call   f0100600 <cputchar>
f0102f9a:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0102f9d:	88 9e 60 65 11 f0    	mov    %bl,-0xfee9aa0(%esi)
f0102fa3:	8d 76 01             	lea    0x1(%esi),%esi
f0102fa6:	eb 8b                	jmp    f0102f33 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0102fa8:	83 fb 0a             	cmp    $0xa,%ebx
f0102fab:	74 05                	je     f0102fb2 <readline+0xb4>
f0102fad:	83 fb 0d             	cmp    $0xd,%ebx
f0102fb0:	75 81                	jne    f0102f33 <readline+0x35>
			if (echoing)
f0102fb2:	85 ff                	test   %edi,%edi
f0102fb4:	74 0d                	je     f0102fc3 <readline+0xc5>
				cputchar('\n');
f0102fb6:	83 ec 0c             	sub    $0xc,%esp
f0102fb9:	6a 0a                	push   $0xa
f0102fbb:	e8 40 d6 ff ff       	call   f0100600 <cputchar>
f0102fc0:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0102fc3:	c6 86 60 65 11 f0 00 	movb   $0x0,-0xfee9aa0(%esi)
			return buf;
f0102fca:	b8 60 65 11 f0       	mov    $0xf0116560,%eax
		}
	}
}
f0102fcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102fd2:	5b                   	pop    %ebx
f0102fd3:	5e                   	pop    %esi
f0102fd4:	5f                   	pop    %edi
f0102fd5:	5d                   	pop    %ebp
f0102fd6:	c3                   	ret    

f0102fd7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0102fd7:	55                   	push   %ebp
f0102fd8:	89 e5                	mov    %esp,%ebp
f0102fda:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0102fdd:	b8 00 00 00 00       	mov    $0x0,%eax
f0102fe2:	eb 03                	jmp    f0102fe7 <strlen+0x10>
		n++;
f0102fe4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0102fe7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0102feb:	75 f7                	jne    f0102fe4 <strlen+0xd>
		n++;
	return n;
}
f0102fed:	5d                   	pop    %ebp
f0102fee:	c3                   	ret    

f0102fef <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0102fef:	55                   	push   %ebp
f0102ff0:	89 e5                	mov    %esp,%ebp
f0102ff2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0102ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0102ff8:	ba 00 00 00 00       	mov    $0x0,%edx
f0102ffd:	eb 03                	jmp    f0103002 <strnlen+0x13>
		n++;
f0102fff:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103002:	39 c2                	cmp    %eax,%edx
f0103004:	74 08                	je     f010300e <strnlen+0x1f>
f0103006:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010300a:	75 f3                	jne    f0102fff <strnlen+0x10>
f010300c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010300e:	5d                   	pop    %ebp
f010300f:	c3                   	ret    

f0103010 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103010:	55                   	push   %ebp
f0103011:	89 e5                	mov    %esp,%ebp
f0103013:	53                   	push   %ebx
f0103014:	8b 45 08             	mov    0x8(%ebp),%eax
f0103017:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010301a:	89 c2                	mov    %eax,%edx
f010301c:	83 c2 01             	add    $0x1,%edx
f010301f:	83 c1 01             	add    $0x1,%ecx
f0103022:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0103026:	88 5a ff             	mov    %bl,-0x1(%edx)
f0103029:	84 db                	test   %bl,%bl
f010302b:	75 ef                	jne    f010301c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010302d:	5b                   	pop    %ebx
f010302e:	5d                   	pop    %ebp
f010302f:	c3                   	ret    

f0103030 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103030:	55                   	push   %ebp
f0103031:	89 e5                	mov    %esp,%ebp
f0103033:	53                   	push   %ebx
f0103034:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0103037:	53                   	push   %ebx
f0103038:	e8 9a ff ff ff       	call   f0102fd7 <strlen>
f010303d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0103040:	ff 75 0c             	pushl  0xc(%ebp)
f0103043:	01 d8                	add    %ebx,%eax
f0103045:	50                   	push   %eax
f0103046:	e8 c5 ff ff ff       	call   f0103010 <strcpy>
	return dst;
}
f010304b:	89 d8                	mov    %ebx,%eax
f010304d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103050:	c9                   	leave  
f0103051:	c3                   	ret    

f0103052 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103052:	55                   	push   %ebp
f0103053:	89 e5                	mov    %esp,%ebp
f0103055:	56                   	push   %esi
f0103056:	53                   	push   %ebx
f0103057:	8b 75 08             	mov    0x8(%ebp),%esi
f010305a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010305d:	89 f3                	mov    %esi,%ebx
f010305f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103062:	89 f2                	mov    %esi,%edx
f0103064:	eb 0f                	jmp    f0103075 <strncpy+0x23>
		*dst++ = *src;
f0103066:	83 c2 01             	add    $0x1,%edx
f0103069:	0f b6 01             	movzbl (%ecx),%eax
f010306c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010306f:	80 39 01             	cmpb   $0x1,(%ecx)
f0103072:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103075:	39 da                	cmp    %ebx,%edx
f0103077:	75 ed                	jne    f0103066 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103079:	89 f0                	mov    %esi,%eax
f010307b:	5b                   	pop    %ebx
f010307c:	5e                   	pop    %esi
f010307d:	5d                   	pop    %ebp
f010307e:	c3                   	ret    

f010307f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010307f:	55                   	push   %ebp
f0103080:	89 e5                	mov    %esp,%ebp
f0103082:	56                   	push   %esi
f0103083:	53                   	push   %ebx
f0103084:	8b 75 08             	mov    0x8(%ebp),%esi
f0103087:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010308a:	8b 55 10             	mov    0x10(%ebp),%edx
f010308d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010308f:	85 d2                	test   %edx,%edx
f0103091:	74 21                	je     f01030b4 <strlcpy+0x35>
f0103093:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0103097:	89 f2                	mov    %esi,%edx
f0103099:	eb 09                	jmp    f01030a4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010309b:	83 c2 01             	add    $0x1,%edx
f010309e:	83 c1 01             	add    $0x1,%ecx
f01030a1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01030a4:	39 c2                	cmp    %eax,%edx
f01030a6:	74 09                	je     f01030b1 <strlcpy+0x32>
f01030a8:	0f b6 19             	movzbl (%ecx),%ebx
f01030ab:	84 db                	test   %bl,%bl
f01030ad:	75 ec                	jne    f010309b <strlcpy+0x1c>
f01030af:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01030b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01030b4:	29 f0                	sub    %esi,%eax
}
f01030b6:	5b                   	pop    %ebx
f01030b7:	5e                   	pop    %esi
f01030b8:	5d                   	pop    %ebp
f01030b9:	c3                   	ret    

f01030ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01030ba:	55                   	push   %ebp
f01030bb:	89 e5                	mov    %esp,%ebp
f01030bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01030c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01030c3:	eb 06                	jmp    f01030cb <strcmp+0x11>
		p++, q++;
f01030c5:	83 c1 01             	add    $0x1,%ecx
f01030c8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01030cb:	0f b6 01             	movzbl (%ecx),%eax
f01030ce:	84 c0                	test   %al,%al
f01030d0:	74 04                	je     f01030d6 <strcmp+0x1c>
f01030d2:	3a 02                	cmp    (%edx),%al
f01030d4:	74 ef                	je     f01030c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01030d6:	0f b6 c0             	movzbl %al,%eax
f01030d9:	0f b6 12             	movzbl (%edx),%edx
f01030dc:	29 d0                	sub    %edx,%eax
}
f01030de:	5d                   	pop    %ebp
f01030df:	c3                   	ret    

f01030e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01030e0:	55                   	push   %ebp
f01030e1:	89 e5                	mov    %esp,%ebp
f01030e3:	53                   	push   %ebx
f01030e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01030e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01030ea:	89 c3                	mov    %eax,%ebx
f01030ec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01030ef:	eb 06                	jmp    f01030f7 <strncmp+0x17>
		n--, p++, q++;
f01030f1:	83 c0 01             	add    $0x1,%eax
f01030f4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01030f7:	39 d8                	cmp    %ebx,%eax
f01030f9:	74 15                	je     f0103110 <strncmp+0x30>
f01030fb:	0f b6 08             	movzbl (%eax),%ecx
f01030fe:	84 c9                	test   %cl,%cl
f0103100:	74 04                	je     f0103106 <strncmp+0x26>
f0103102:	3a 0a                	cmp    (%edx),%cl
f0103104:	74 eb                	je     f01030f1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103106:	0f b6 00             	movzbl (%eax),%eax
f0103109:	0f b6 12             	movzbl (%edx),%edx
f010310c:	29 d0                	sub    %edx,%eax
f010310e:	eb 05                	jmp    f0103115 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103110:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0103115:	5b                   	pop    %ebx
f0103116:	5d                   	pop    %ebp
f0103117:	c3                   	ret    

f0103118 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103118:	55                   	push   %ebp
f0103119:	89 e5                	mov    %esp,%ebp
f010311b:	8b 45 08             	mov    0x8(%ebp),%eax
f010311e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103122:	eb 07                	jmp    f010312b <strchr+0x13>
		if (*s == c)
f0103124:	38 ca                	cmp    %cl,%dl
f0103126:	74 0f                	je     f0103137 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103128:	83 c0 01             	add    $0x1,%eax
f010312b:	0f b6 10             	movzbl (%eax),%edx
f010312e:	84 d2                	test   %dl,%dl
f0103130:	75 f2                	jne    f0103124 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0103132:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103137:	5d                   	pop    %ebp
f0103138:	c3                   	ret    

f0103139 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103139:	55                   	push   %ebp
f010313a:	89 e5                	mov    %esp,%ebp
f010313c:	8b 45 08             	mov    0x8(%ebp),%eax
f010313f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0103143:	eb 03                	jmp    f0103148 <strfind+0xf>
f0103145:	83 c0 01             	add    $0x1,%eax
f0103148:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010314b:	38 ca                	cmp    %cl,%dl
f010314d:	74 04                	je     f0103153 <strfind+0x1a>
f010314f:	84 d2                	test   %dl,%dl
f0103151:	75 f2                	jne    f0103145 <strfind+0xc>
			break;
	return (char *) s;
}
f0103153:	5d                   	pop    %ebp
f0103154:	c3                   	ret    

f0103155 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0103155:	55                   	push   %ebp
f0103156:	89 e5                	mov    %esp,%ebp
f0103158:	57                   	push   %edi
f0103159:	56                   	push   %esi
f010315a:	53                   	push   %ebx
f010315b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010315e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0103161:	85 c9                	test   %ecx,%ecx
f0103163:	74 36                	je     f010319b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0103165:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010316b:	75 28                	jne    f0103195 <memset+0x40>
f010316d:	f6 c1 03             	test   $0x3,%cl
f0103170:	75 23                	jne    f0103195 <memset+0x40>
		c &= 0xFF;
f0103172:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0103176:	89 d3                	mov    %edx,%ebx
f0103178:	c1 e3 08             	shl    $0x8,%ebx
f010317b:	89 d6                	mov    %edx,%esi
f010317d:	c1 e6 18             	shl    $0x18,%esi
f0103180:	89 d0                	mov    %edx,%eax
f0103182:	c1 e0 10             	shl    $0x10,%eax
f0103185:	09 f0                	or     %esi,%eax
f0103187:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0103189:	89 d8                	mov    %ebx,%eax
f010318b:	09 d0                	or     %edx,%eax
f010318d:	c1 e9 02             	shr    $0x2,%ecx
f0103190:	fc                   	cld    
f0103191:	f3 ab                	rep stos %eax,%es:(%edi)
f0103193:	eb 06                	jmp    f010319b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0103195:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103198:	fc                   	cld    
f0103199:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010319b:	89 f8                	mov    %edi,%eax
f010319d:	5b                   	pop    %ebx
f010319e:	5e                   	pop    %esi
f010319f:	5f                   	pop    %edi
f01031a0:	5d                   	pop    %ebp
f01031a1:	c3                   	ret    

f01031a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01031a2:	55                   	push   %ebp
f01031a3:	89 e5                	mov    %esp,%ebp
f01031a5:	57                   	push   %edi
f01031a6:	56                   	push   %esi
f01031a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01031aa:	8b 75 0c             	mov    0xc(%ebp),%esi
f01031ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01031b0:	39 c6                	cmp    %eax,%esi
f01031b2:	73 35                	jae    f01031e9 <memmove+0x47>
f01031b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01031b7:	39 d0                	cmp    %edx,%eax
f01031b9:	73 2e                	jae    f01031e9 <memmove+0x47>
		s += n;
		d += n;
f01031bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01031be:	89 d6                	mov    %edx,%esi
f01031c0:	09 fe                	or     %edi,%esi
f01031c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01031c8:	75 13                	jne    f01031dd <memmove+0x3b>
f01031ca:	f6 c1 03             	test   $0x3,%cl
f01031cd:	75 0e                	jne    f01031dd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01031cf:	83 ef 04             	sub    $0x4,%edi
f01031d2:	8d 72 fc             	lea    -0x4(%edx),%esi
f01031d5:	c1 e9 02             	shr    $0x2,%ecx
f01031d8:	fd                   	std    
f01031d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01031db:	eb 09                	jmp    f01031e6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01031dd:	83 ef 01             	sub    $0x1,%edi
f01031e0:	8d 72 ff             	lea    -0x1(%edx),%esi
f01031e3:	fd                   	std    
f01031e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01031e6:	fc                   	cld    
f01031e7:	eb 1d                	jmp    f0103206 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01031e9:	89 f2                	mov    %esi,%edx
f01031eb:	09 c2                	or     %eax,%edx
f01031ed:	f6 c2 03             	test   $0x3,%dl
f01031f0:	75 0f                	jne    f0103201 <memmove+0x5f>
f01031f2:	f6 c1 03             	test   $0x3,%cl
f01031f5:	75 0a                	jne    f0103201 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01031f7:	c1 e9 02             	shr    $0x2,%ecx
f01031fa:	89 c7                	mov    %eax,%edi
f01031fc:	fc                   	cld    
f01031fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01031ff:	eb 05                	jmp    f0103206 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0103201:	89 c7                	mov    %eax,%edi
f0103203:	fc                   	cld    
f0103204:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0103206:	5e                   	pop    %esi
f0103207:	5f                   	pop    %edi
f0103208:	5d                   	pop    %ebp
f0103209:	c3                   	ret    

f010320a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010320a:	55                   	push   %ebp
f010320b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010320d:	ff 75 10             	pushl  0x10(%ebp)
f0103210:	ff 75 0c             	pushl  0xc(%ebp)
f0103213:	ff 75 08             	pushl  0x8(%ebp)
f0103216:	e8 87 ff ff ff       	call   f01031a2 <memmove>
}
f010321b:	c9                   	leave  
f010321c:	c3                   	ret    

f010321d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010321d:	55                   	push   %ebp
f010321e:	89 e5                	mov    %esp,%ebp
f0103220:	56                   	push   %esi
f0103221:	53                   	push   %ebx
f0103222:	8b 45 08             	mov    0x8(%ebp),%eax
f0103225:	8b 55 0c             	mov    0xc(%ebp),%edx
f0103228:	89 c6                	mov    %eax,%esi
f010322a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010322d:	eb 1a                	jmp    f0103249 <memcmp+0x2c>
		if (*s1 != *s2)
f010322f:	0f b6 08             	movzbl (%eax),%ecx
f0103232:	0f b6 1a             	movzbl (%edx),%ebx
f0103235:	38 d9                	cmp    %bl,%cl
f0103237:	74 0a                	je     f0103243 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0103239:	0f b6 c1             	movzbl %cl,%eax
f010323c:	0f b6 db             	movzbl %bl,%ebx
f010323f:	29 d8                	sub    %ebx,%eax
f0103241:	eb 0f                	jmp    f0103252 <memcmp+0x35>
		s1++, s2++;
f0103243:	83 c0 01             	add    $0x1,%eax
f0103246:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103249:	39 f0                	cmp    %esi,%eax
f010324b:	75 e2                	jne    f010322f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010324d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103252:	5b                   	pop    %ebx
f0103253:	5e                   	pop    %esi
f0103254:	5d                   	pop    %ebp
f0103255:	c3                   	ret    

f0103256 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0103256:	55                   	push   %ebp
f0103257:	89 e5                	mov    %esp,%ebp
f0103259:	53                   	push   %ebx
f010325a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010325d:	89 c1                	mov    %eax,%ecx
f010325f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0103262:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0103266:	eb 0a                	jmp    f0103272 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103268:	0f b6 10             	movzbl (%eax),%edx
f010326b:	39 da                	cmp    %ebx,%edx
f010326d:	74 07                	je     f0103276 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010326f:	83 c0 01             	add    $0x1,%eax
f0103272:	39 c8                	cmp    %ecx,%eax
f0103274:	72 f2                	jb     f0103268 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0103276:	5b                   	pop    %ebx
f0103277:	5d                   	pop    %ebp
f0103278:	c3                   	ret    

f0103279 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0103279:	55                   	push   %ebp
f010327a:	89 e5                	mov    %esp,%ebp
f010327c:	57                   	push   %edi
f010327d:	56                   	push   %esi
f010327e:	53                   	push   %ebx
f010327f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0103282:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0103285:	eb 03                	jmp    f010328a <strtol+0x11>
		s++;
f0103287:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010328a:	0f b6 01             	movzbl (%ecx),%eax
f010328d:	3c 20                	cmp    $0x20,%al
f010328f:	74 f6                	je     f0103287 <strtol+0xe>
f0103291:	3c 09                	cmp    $0x9,%al
f0103293:	74 f2                	je     f0103287 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0103295:	3c 2b                	cmp    $0x2b,%al
f0103297:	75 0a                	jne    f01032a3 <strtol+0x2a>
		s++;
f0103299:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010329c:	bf 00 00 00 00       	mov    $0x0,%edi
f01032a1:	eb 11                	jmp    f01032b4 <strtol+0x3b>
f01032a3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01032a8:	3c 2d                	cmp    $0x2d,%al
f01032aa:	75 08                	jne    f01032b4 <strtol+0x3b>
		s++, neg = 1;
f01032ac:	83 c1 01             	add    $0x1,%ecx
f01032af:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01032b4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01032ba:	75 15                	jne    f01032d1 <strtol+0x58>
f01032bc:	80 39 30             	cmpb   $0x30,(%ecx)
f01032bf:	75 10                	jne    f01032d1 <strtol+0x58>
f01032c1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01032c5:	75 7c                	jne    f0103343 <strtol+0xca>
		s += 2, base = 16;
f01032c7:	83 c1 02             	add    $0x2,%ecx
f01032ca:	bb 10 00 00 00       	mov    $0x10,%ebx
f01032cf:	eb 16                	jmp    f01032e7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01032d1:	85 db                	test   %ebx,%ebx
f01032d3:	75 12                	jne    f01032e7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01032d5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01032da:	80 39 30             	cmpb   $0x30,(%ecx)
f01032dd:	75 08                	jne    f01032e7 <strtol+0x6e>
		s++, base = 8;
f01032df:	83 c1 01             	add    $0x1,%ecx
f01032e2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01032e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01032ec:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01032ef:	0f b6 11             	movzbl (%ecx),%edx
f01032f2:	8d 72 d0             	lea    -0x30(%edx),%esi
f01032f5:	89 f3                	mov    %esi,%ebx
f01032f7:	80 fb 09             	cmp    $0x9,%bl
f01032fa:	77 08                	ja     f0103304 <strtol+0x8b>
			dig = *s - '0';
f01032fc:	0f be d2             	movsbl %dl,%edx
f01032ff:	83 ea 30             	sub    $0x30,%edx
f0103302:	eb 22                	jmp    f0103326 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0103304:	8d 72 9f             	lea    -0x61(%edx),%esi
f0103307:	89 f3                	mov    %esi,%ebx
f0103309:	80 fb 19             	cmp    $0x19,%bl
f010330c:	77 08                	ja     f0103316 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010330e:	0f be d2             	movsbl %dl,%edx
f0103311:	83 ea 57             	sub    $0x57,%edx
f0103314:	eb 10                	jmp    f0103326 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0103316:	8d 72 bf             	lea    -0x41(%edx),%esi
f0103319:	89 f3                	mov    %esi,%ebx
f010331b:	80 fb 19             	cmp    $0x19,%bl
f010331e:	77 16                	ja     f0103336 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0103320:	0f be d2             	movsbl %dl,%edx
f0103323:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0103326:	3b 55 10             	cmp    0x10(%ebp),%edx
f0103329:	7d 0b                	jge    f0103336 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010332b:	83 c1 01             	add    $0x1,%ecx
f010332e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0103332:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0103334:	eb b9                	jmp    f01032ef <strtol+0x76>

	if (endptr)
f0103336:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010333a:	74 0d                	je     f0103349 <strtol+0xd0>
		*endptr = (char *) s;
f010333c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010333f:	89 0e                	mov    %ecx,(%esi)
f0103341:	eb 06                	jmp    f0103349 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0103343:	85 db                	test   %ebx,%ebx
f0103345:	74 98                	je     f01032df <strtol+0x66>
f0103347:	eb 9e                	jmp    f01032e7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0103349:	89 c2                	mov    %eax,%edx
f010334b:	f7 da                	neg    %edx
f010334d:	85 ff                	test   %edi,%edi
f010334f:	0f 45 c2             	cmovne %edx,%eax
}
f0103352:	5b                   	pop    %ebx
f0103353:	5e                   	pop    %esi
f0103354:	5f                   	pop    %edi
f0103355:	5d                   	pop    %ebp
f0103356:	c3                   	ret    
f0103357:	66 90                	xchg   %ax,%ax
f0103359:	66 90                	xchg   %ax,%ax
f010335b:	66 90                	xchg   %ax,%ax
f010335d:	66 90                	xchg   %ax,%ax
f010335f:	90                   	nop

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
