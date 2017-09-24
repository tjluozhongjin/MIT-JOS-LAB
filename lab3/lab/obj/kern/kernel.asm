
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
f0100015:	b8 00 80 11 00       	mov    $0x118000,%eax
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
f0100034:	bc 00 80 11 f0       	mov    $0xf0118000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 02 00 00 00       	call   f0100040 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <i386_init>:
#include <kern/trap.h>


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
f0100046:	b8 10 cb 17 f0       	mov    $0xf017cb10,%eax
f010004b:	2d ee bb 17 f0       	sub    $0xf017bbee,%eax
f0100050:	50                   	push   %eax
f0100051:	6a 00                	push   $0x0
f0100053:	68 ee bb 17 f0       	push   $0xf017bbee
f0100058:	e8 4e 41 00 00       	call   f01041ab <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005d:	e8 ab 04 00 00       	call   f010050d <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100062:	83 c4 08             	add    $0x8,%esp
f0100065:	68 ac 1a 00 00       	push   $0x1aac
f010006a:	68 40 46 10 f0       	push   $0xf0104640
f010006f:	e8 d8 2d 00 00       	call   f0102e4c <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f0100074:	e8 2f 0f 00 00       	call   f0100fa8 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f0100079:	e8 1a 28 00 00       	call   f0102898 <env_init>
	trap_init();
f010007e:	e8 3a 2e 00 00       	call   f0102ebd <trap_init>
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	ENV_CREATE(user_hello, ENV_TYPE_USER);
f0100083:	83 c4 08             	add    $0x8,%esp
f0100086:	6a 00                	push   $0x0
f0100088:	68 56 a3 11 f0       	push   $0xf011a356
f010008d:	e8 be 29 00 00       	call   f0102a50 <env_create>
#endif // TEST*

	// We only have one user environment for now, so just run it.
	env_run(&envs[0]);
f0100092:	83 c4 04             	add    $0x4,%esp
f0100095:	ff 35 4c be 17 f0    	pushl  0xf017be4c
f010009b:	e8 e3 2c 00 00       	call   f0102d83 <env_run>

f01000a0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a0:	55                   	push   %ebp
f01000a1:	89 e5                	mov    %esp,%ebp
f01000a3:	56                   	push   %esi
f01000a4:	53                   	push   %ebx
f01000a5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000a8:	83 3d 00 cb 17 f0 00 	cmpl   $0x0,0xf017cb00
f01000af:	75 37                	jne    f01000e8 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f01000b1:	89 35 00 cb 17 f0    	mov    %esi,0xf017cb00

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f01000b7:	fa                   	cli    
f01000b8:	fc                   	cld    

	va_start(ap, fmt);
f01000b9:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f01000bc:	83 ec 04             	sub    $0x4,%esp
f01000bf:	ff 75 0c             	pushl  0xc(%ebp)
f01000c2:	ff 75 08             	pushl  0x8(%ebp)
f01000c5:	68 5b 46 10 f0       	push   $0xf010465b
f01000ca:	e8 7d 2d 00 00       	call   f0102e4c <cprintf>
	vcprintf(fmt, ap);
f01000cf:	83 c4 08             	add    $0x8,%esp
f01000d2:	53                   	push   %ebx
f01000d3:	56                   	push   %esi
f01000d4:	e8 4d 2d 00 00       	call   f0102e26 <vcprintf>
	cprintf("\n");
f01000d9:	c7 04 24 9d 55 10 f0 	movl   $0xf010559d,(%esp)
f01000e0:	e8 67 2d 00 00       	call   f0102e4c <cprintf>
	va_end(ap);
f01000e5:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000e8:	83 ec 0c             	sub    $0xc,%esp
f01000eb:	6a 00                	push   $0x0
f01000ed:	e8 40 06 00 00       	call   f0100732 <monitor>
f01000f2:	83 c4 10             	add    $0x10,%esp
f01000f5:	eb f1                	jmp    f01000e8 <_panic+0x48>

f01000f7 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f01000f7:	55                   	push   %ebp
f01000f8:	89 e5                	mov    %esp,%ebp
f01000fa:	53                   	push   %ebx
f01000fb:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f01000fe:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100101:	ff 75 0c             	pushl  0xc(%ebp)
f0100104:	ff 75 08             	pushl  0x8(%ebp)
f0100107:	68 73 46 10 f0       	push   $0xf0104673
f010010c:	e8 3b 2d 00 00       	call   f0102e4c <cprintf>
	vcprintf(fmt, ap);
f0100111:	83 c4 08             	add    $0x8,%esp
f0100114:	53                   	push   %ebx
f0100115:	ff 75 10             	pushl  0x10(%ebp)
f0100118:	e8 09 2d 00 00       	call   f0102e26 <vcprintf>
	cprintf("\n");
f010011d:	c7 04 24 9d 55 10 f0 	movl   $0xf010559d,(%esp)
f0100124:	e8 23 2d 00 00       	call   f0102e4c <cprintf>
	va_end(ap);
}
f0100129:	83 c4 10             	add    $0x10,%esp
f010012c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010012f:	c9                   	leave  
f0100130:	c3                   	ret    

f0100131 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100131:	55                   	push   %ebp
f0100132:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100134:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100139:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010013a:	a8 01                	test   $0x1,%al
f010013c:	74 0b                	je     f0100149 <serial_proc_data+0x18>
f010013e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100143:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100144:	0f b6 c0             	movzbl %al,%eax
f0100147:	eb 05                	jmp    f010014e <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100149:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010014e:	5d                   	pop    %ebp
f010014f:	c3                   	ret    

f0100150 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100150:	55                   	push   %ebp
f0100151:	89 e5                	mov    %esp,%ebp
f0100153:	53                   	push   %ebx
f0100154:	83 ec 04             	sub    $0x4,%esp
f0100157:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f0100159:	eb 2b                	jmp    f0100186 <cons_intr+0x36>
		if (c == 0)
f010015b:	85 c0                	test   %eax,%eax
f010015d:	74 27                	je     f0100186 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f010015f:	8b 0d 24 be 17 f0    	mov    0xf017be24,%ecx
f0100165:	8d 51 01             	lea    0x1(%ecx),%edx
f0100168:	89 15 24 be 17 f0    	mov    %edx,0xf017be24
f010016e:	88 81 20 bc 17 f0    	mov    %al,-0xfe843e0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f0100174:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010017a:	75 0a                	jne    f0100186 <cons_intr+0x36>
			cons.wpos = 0;
f010017c:	c7 05 24 be 17 f0 00 	movl   $0x0,0xf017be24
f0100183:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100186:	ff d3                	call   *%ebx
f0100188:	83 f8 ff             	cmp    $0xffffffff,%eax
f010018b:	75 ce                	jne    f010015b <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f010018d:	83 c4 04             	add    $0x4,%esp
f0100190:	5b                   	pop    %ebx
f0100191:	5d                   	pop    %ebp
f0100192:	c3                   	ret    

f0100193 <kbd_proc_data>:
f0100193:	ba 64 00 00 00       	mov    $0x64,%edx
f0100198:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f0100199:	a8 01                	test   $0x1,%al
f010019b:	0f 84 f8 00 00 00    	je     f0100299 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01001a1:	a8 20                	test   $0x20,%al
f01001a3:	0f 85 f6 00 00 00    	jne    f010029f <kbd_proc_data+0x10c>
f01001a9:	ba 60 00 00 00       	mov    $0x60,%edx
f01001ae:	ec                   	in     (%dx),%al
f01001af:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001b1:	3c e0                	cmp    $0xe0,%al
f01001b3:	75 0d                	jne    f01001c2 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01001b5:	83 0d 00 bc 17 f0 40 	orl    $0x40,0xf017bc00
		return 0;
f01001bc:	b8 00 00 00 00       	mov    $0x0,%eax
f01001c1:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01001c2:	55                   	push   %ebp
f01001c3:	89 e5                	mov    %esp,%ebp
f01001c5:	53                   	push   %ebx
f01001c6:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01001c9:	84 c0                	test   %al,%al
f01001cb:	79 36                	jns    f0100203 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01001cd:	8b 0d 00 bc 17 f0    	mov    0xf017bc00,%ecx
f01001d3:	89 cb                	mov    %ecx,%ebx
f01001d5:	83 e3 40             	and    $0x40,%ebx
f01001d8:	83 e0 7f             	and    $0x7f,%eax
f01001db:	85 db                	test   %ebx,%ebx
f01001dd:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f01001e0:	0f b6 d2             	movzbl %dl,%edx
f01001e3:	0f b6 82 e0 47 10 f0 	movzbl -0xfefb820(%edx),%eax
f01001ea:	83 c8 40             	or     $0x40,%eax
f01001ed:	0f b6 c0             	movzbl %al,%eax
f01001f0:	f7 d0                	not    %eax
f01001f2:	21 c8                	and    %ecx,%eax
f01001f4:	a3 00 bc 17 f0       	mov    %eax,0xf017bc00
		return 0;
f01001f9:	b8 00 00 00 00       	mov    $0x0,%eax
f01001fe:	e9 a4 00 00 00       	jmp    f01002a7 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100203:	8b 0d 00 bc 17 f0    	mov    0xf017bc00,%ecx
f0100209:	f6 c1 40             	test   $0x40,%cl
f010020c:	74 0e                	je     f010021c <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010020e:	83 c8 80             	or     $0xffffff80,%eax
f0100211:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100213:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100216:	89 0d 00 bc 17 f0    	mov    %ecx,0xf017bc00
	}

	shift |= shiftcode[data];
f010021c:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f010021f:	0f b6 82 e0 47 10 f0 	movzbl -0xfefb820(%edx),%eax
f0100226:	0b 05 00 bc 17 f0    	or     0xf017bc00,%eax
f010022c:	0f b6 8a e0 46 10 f0 	movzbl -0xfefb920(%edx),%ecx
f0100233:	31 c8                	xor    %ecx,%eax
f0100235:	a3 00 bc 17 f0       	mov    %eax,0xf017bc00

	c = charcode[shift & (CTL | SHIFT)][data];
f010023a:	89 c1                	mov    %eax,%ecx
f010023c:	83 e1 03             	and    $0x3,%ecx
f010023f:	8b 0c 8d c0 46 10 f0 	mov    -0xfefb940(,%ecx,4),%ecx
f0100246:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010024a:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010024d:	a8 08                	test   $0x8,%al
f010024f:	74 1b                	je     f010026c <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100251:	89 da                	mov    %ebx,%edx
f0100253:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100256:	83 f9 19             	cmp    $0x19,%ecx
f0100259:	77 05                	ja     f0100260 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010025b:	83 eb 20             	sub    $0x20,%ebx
f010025e:	eb 0c                	jmp    f010026c <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100260:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100263:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100266:	83 fa 19             	cmp    $0x19,%edx
f0100269:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010026c:	f7 d0                	not    %eax
f010026e:	a8 06                	test   $0x6,%al
f0100270:	75 33                	jne    f01002a5 <kbd_proc_data+0x112>
f0100272:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f0100278:	75 2b                	jne    f01002a5 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f010027a:	83 ec 0c             	sub    $0xc,%esp
f010027d:	68 8d 46 10 f0       	push   $0xf010468d
f0100282:	e8 c5 2b 00 00       	call   f0102e4c <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100287:	ba 92 00 00 00       	mov    $0x92,%edx
f010028c:	b8 03 00 00 00       	mov    $0x3,%eax
f0100291:	ee                   	out    %al,(%dx)
f0100292:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f0100295:	89 d8                	mov    %ebx,%eax
f0100297:	eb 0e                	jmp    f01002a7 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f0100299:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f010029e:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f010029f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002a4:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002a5:	89 d8                	mov    %ebx,%eax
}
f01002a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002aa:	c9                   	leave  
f01002ab:	c3                   	ret    

f01002ac <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002ac:	55                   	push   %ebp
f01002ad:	89 e5                	mov    %esp,%ebp
f01002af:	57                   	push   %edi
f01002b0:	56                   	push   %esi
f01002b1:	53                   	push   %ebx
f01002b2:	83 ec 1c             	sub    $0x1c,%esp
f01002b5:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002b7:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002bc:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002c1:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002c6:	eb 09                	jmp    f01002d1 <cons_putc+0x25>
f01002c8:	89 ca                	mov    %ecx,%edx
f01002ca:	ec                   	in     (%dx),%al
f01002cb:	ec                   	in     (%dx),%al
f01002cc:	ec                   	in     (%dx),%al
f01002cd:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01002ce:	83 c3 01             	add    $0x1,%ebx
f01002d1:	89 f2                	mov    %esi,%edx
f01002d3:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f01002d4:	a8 20                	test   $0x20,%al
f01002d6:	75 08                	jne    f01002e0 <cons_putc+0x34>
f01002d8:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f01002de:	7e e8                	jle    f01002c8 <cons_putc+0x1c>
f01002e0:	89 f8                	mov    %edi,%eax
f01002e2:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002e5:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002ea:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f01002eb:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f0:	be 79 03 00 00       	mov    $0x379,%esi
f01002f5:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fa:	eb 09                	jmp    f0100305 <cons_putc+0x59>
f01002fc:	89 ca                	mov    %ecx,%edx
f01002fe:	ec                   	in     (%dx),%al
f01002ff:	ec                   	in     (%dx),%al
f0100300:	ec                   	in     (%dx),%al
f0100301:	ec                   	in     (%dx),%al
f0100302:	83 c3 01             	add    $0x1,%ebx
f0100305:	89 f2                	mov    %esi,%edx
f0100307:	ec                   	in     (%dx),%al
f0100308:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010030e:	7f 04                	jg     f0100314 <cons_putc+0x68>
f0100310:	84 c0                	test   %al,%al
f0100312:	79 e8                	jns    f01002fc <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100314:	ba 78 03 00 00       	mov    $0x378,%edx
f0100319:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010031d:	ee                   	out    %al,(%dx)
f010031e:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100323:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100328:	ee                   	out    %al,(%dx)
f0100329:	b8 08 00 00 00       	mov    $0x8,%eax
f010032e:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f010032f:	89 fa                	mov    %edi,%edx
f0100331:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100337:	89 f8                	mov    %edi,%eax
f0100339:	80 cc 07             	or     $0x7,%ah
f010033c:	85 d2                	test   %edx,%edx
f010033e:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100341:	89 f8                	mov    %edi,%eax
f0100343:	0f b6 c0             	movzbl %al,%eax
f0100346:	83 f8 09             	cmp    $0x9,%eax
f0100349:	74 74                	je     f01003bf <cons_putc+0x113>
f010034b:	83 f8 09             	cmp    $0x9,%eax
f010034e:	7f 0a                	jg     f010035a <cons_putc+0xae>
f0100350:	83 f8 08             	cmp    $0x8,%eax
f0100353:	74 14                	je     f0100369 <cons_putc+0xbd>
f0100355:	e9 99 00 00 00       	jmp    f01003f3 <cons_putc+0x147>
f010035a:	83 f8 0a             	cmp    $0xa,%eax
f010035d:	74 3a                	je     f0100399 <cons_putc+0xed>
f010035f:	83 f8 0d             	cmp    $0xd,%eax
f0100362:	74 3d                	je     f01003a1 <cons_putc+0xf5>
f0100364:	e9 8a 00 00 00       	jmp    f01003f3 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f0100369:	0f b7 05 28 be 17 f0 	movzwl 0xf017be28,%eax
f0100370:	66 85 c0             	test   %ax,%ax
f0100373:	0f 84 e6 00 00 00    	je     f010045f <cons_putc+0x1b3>
			crt_pos--;
f0100379:	83 e8 01             	sub    $0x1,%eax
f010037c:	66 a3 28 be 17 f0    	mov    %ax,0xf017be28
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f0100382:	0f b7 c0             	movzwl %ax,%eax
f0100385:	66 81 e7 00 ff       	and    $0xff00,%di
f010038a:	83 cf 20             	or     $0x20,%edi
f010038d:	8b 15 2c be 17 f0    	mov    0xf017be2c,%edx
f0100393:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f0100397:	eb 78                	jmp    f0100411 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f0100399:	66 83 05 28 be 17 f0 	addw   $0x50,0xf017be28
f01003a0:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003a1:	0f b7 05 28 be 17 f0 	movzwl 0xf017be28,%eax
f01003a8:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003ae:	c1 e8 16             	shr    $0x16,%eax
f01003b1:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003b4:	c1 e0 04             	shl    $0x4,%eax
f01003b7:	66 a3 28 be 17 f0    	mov    %ax,0xf017be28
f01003bd:	eb 52                	jmp    f0100411 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01003bf:	b8 20 00 00 00       	mov    $0x20,%eax
f01003c4:	e8 e3 fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003c9:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ce:	e8 d9 fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003d3:	b8 20 00 00 00       	mov    $0x20,%eax
f01003d8:	e8 cf fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003dd:	b8 20 00 00 00       	mov    $0x20,%eax
f01003e2:	e8 c5 fe ff ff       	call   f01002ac <cons_putc>
		cons_putc(' ');
f01003e7:	b8 20 00 00 00       	mov    $0x20,%eax
f01003ec:	e8 bb fe ff ff       	call   f01002ac <cons_putc>
f01003f1:	eb 1e                	jmp    f0100411 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f01003f3:	0f b7 05 28 be 17 f0 	movzwl 0xf017be28,%eax
f01003fa:	8d 50 01             	lea    0x1(%eax),%edx
f01003fd:	66 89 15 28 be 17 f0 	mov    %dx,0xf017be28
f0100404:	0f b7 c0             	movzwl %ax,%eax
f0100407:	8b 15 2c be 17 f0    	mov    0xf017be2c,%edx
f010040d:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100411:	66 81 3d 28 be 17 f0 	cmpw   $0x7cf,0xf017be28
f0100418:	cf 07 
f010041a:	76 43                	jbe    f010045f <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010041c:	a1 2c be 17 f0       	mov    0xf017be2c,%eax
f0100421:	83 ec 04             	sub    $0x4,%esp
f0100424:	68 00 0f 00 00       	push   $0xf00
f0100429:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f010042f:	52                   	push   %edx
f0100430:	50                   	push   %eax
f0100431:	e8 c2 3d 00 00       	call   f01041f8 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100436:	8b 15 2c be 17 f0    	mov    0xf017be2c,%edx
f010043c:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100442:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100448:	83 c4 10             	add    $0x10,%esp
f010044b:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100450:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100453:	39 d0                	cmp    %edx,%eax
f0100455:	75 f4                	jne    f010044b <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100457:	66 83 2d 28 be 17 f0 	subw   $0x50,0xf017be28
f010045e:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f010045f:	8b 0d 30 be 17 f0    	mov    0xf017be30,%ecx
f0100465:	b8 0e 00 00 00       	mov    $0xe,%eax
f010046a:	89 ca                	mov    %ecx,%edx
f010046c:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010046d:	0f b7 1d 28 be 17 f0 	movzwl 0xf017be28,%ebx
f0100474:	8d 71 01             	lea    0x1(%ecx),%esi
f0100477:	89 d8                	mov    %ebx,%eax
f0100479:	66 c1 e8 08          	shr    $0x8,%ax
f010047d:	89 f2                	mov    %esi,%edx
f010047f:	ee                   	out    %al,(%dx)
f0100480:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100485:	89 ca                	mov    %ecx,%edx
f0100487:	ee                   	out    %al,(%dx)
f0100488:	89 d8                	mov    %ebx,%eax
f010048a:	89 f2                	mov    %esi,%edx
f010048c:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f010048d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100490:	5b                   	pop    %ebx
f0100491:	5e                   	pop    %esi
f0100492:	5f                   	pop    %edi
f0100493:	5d                   	pop    %ebp
f0100494:	c3                   	ret    

f0100495 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f0100495:	80 3d 34 be 17 f0 00 	cmpb   $0x0,0xf017be34
f010049c:	74 11                	je     f01004af <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f010049e:	55                   	push   %ebp
f010049f:	89 e5                	mov    %esp,%ebp
f01004a1:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004a4:	b8 31 01 10 f0       	mov    $0xf0100131,%eax
f01004a9:	e8 a2 fc ff ff       	call   f0100150 <cons_intr>
}
f01004ae:	c9                   	leave  
f01004af:	f3 c3                	repz ret 

f01004b1 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004b1:	55                   	push   %ebp
f01004b2:	89 e5                	mov    %esp,%ebp
f01004b4:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004b7:	b8 93 01 10 f0       	mov    $0xf0100193,%eax
f01004bc:	e8 8f fc ff ff       	call   f0100150 <cons_intr>
}
f01004c1:	c9                   	leave  
f01004c2:	c3                   	ret    

f01004c3 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004c3:	55                   	push   %ebp
f01004c4:	89 e5                	mov    %esp,%ebp
f01004c6:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004c9:	e8 c7 ff ff ff       	call   f0100495 <serial_intr>
	kbd_intr();
f01004ce:	e8 de ff ff ff       	call   f01004b1 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01004d3:	a1 20 be 17 f0       	mov    0xf017be20,%eax
f01004d8:	3b 05 24 be 17 f0    	cmp    0xf017be24,%eax
f01004de:	74 26                	je     f0100506 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f01004e0:	8d 50 01             	lea    0x1(%eax),%edx
f01004e3:	89 15 20 be 17 f0    	mov    %edx,0xf017be20
f01004e9:	0f b6 88 20 bc 17 f0 	movzbl -0xfe843e0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f01004f0:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f01004f2:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01004f8:	75 11                	jne    f010050b <cons_getc+0x48>
			cons.rpos = 0;
f01004fa:	c7 05 20 be 17 f0 00 	movl   $0x0,0xf017be20
f0100501:	00 00 00 
f0100504:	eb 05                	jmp    f010050b <cons_getc+0x48>
		return c;
	}
	return 0;
f0100506:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010050b:	c9                   	leave  
f010050c:	c3                   	ret    

f010050d <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010050d:	55                   	push   %ebp
f010050e:	89 e5                	mov    %esp,%ebp
f0100510:	57                   	push   %edi
f0100511:	56                   	push   %esi
f0100512:	53                   	push   %ebx
f0100513:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100516:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010051d:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100524:	5a a5 
	if (*cp != 0xA55A) {
f0100526:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010052d:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100531:	74 11                	je     f0100544 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100533:	c7 05 30 be 17 f0 b4 	movl   $0x3b4,0xf017be30
f010053a:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010053d:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100542:	eb 16                	jmp    f010055a <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100544:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010054b:	c7 05 30 be 17 f0 d4 	movl   $0x3d4,0xf017be30
f0100552:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100555:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010055a:	8b 3d 30 be 17 f0    	mov    0xf017be30,%edi
f0100560:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100565:	89 fa                	mov    %edi,%edx
f0100567:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f0100568:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010056b:	89 da                	mov    %ebx,%edx
f010056d:	ec                   	in     (%dx),%al
f010056e:	0f b6 c8             	movzbl %al,%ecx
f0100571:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100574:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100579:	89 fa                	mov    %edi,%edx
f010057b:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010057c:	89 da                	mov    %ebx,%edx
f010057e:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f010057f:	89 35 2c be 17 f0    	mov    %esi,0xf017be2c
	crt_pos = pos;
f0100585:	0f b6 c0             	movzbl %al,%eax
f0100588:	09 c8                	or     %ecx,%eax
f010058a:	66 a3 28 be 17 f0    	mov    %ax,0xf017be28
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100590:	be fa 03 00 00       	mov    $0x3fa,%esi
f0100595:	b8 00 00 00 00       	mov    $0x0,%eax
f010059a:	89 f2                	mov    %esi,%edx
f010059c:	ee                   	out    %al,(%dx)
f010059d:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005a2:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005a7:	ee                   	out    %al,(%dx)
f01005a8:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01005ad:	b8 0c 00 00 00       	mov    $0xc,%eax
f01005b2:	89 da                	mov    %ebx,%edx
f01005b4:	ee                   	out    %al,(%dx)
f01005b5:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01005bf:	ee                   	out    %al,(%dx)
f01005c0:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01005c5:	b8 03 00 00 00       	mov    $0x3,%eax
f01005ca:	ee                   	out    %al,(%dx)
f01005cb:	ba fc 03 00 00       	mov    $0x3fc,%edx
f01005d0:	b8 00 00 00 00       	mov    $0x0,%eax
f01005d5:	ee                   	out    %al,(%dx)
f01005d6:	ba f9 03 00 00       	mov    $0x3f9,%edx
f01005db:	b8 01 00 00 00       	mov    $0x1,%eax
f01005e0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01005e6:	ec                   	in     (%dx),%al
f01005e7:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01005e9:	3c ff                	cmp    $0xff,%al
f01005eb:	0f 95 05 34 be 17 f0 	setne  0xf017be34
f01005f2:	89 f2                	mov    %esi,%edx
f01005f4:	ec                   	in     (%dx),%al
f01005f5:	89 da                	mov    %ebx,%edx
f01005f7:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01005f8:	80 f9 ff             	cmp    $0xff,%cl
f01005fb:	75 10                	jne    f010060d <cons_init+0x100>
		cprintf("Serial port does not exist!\n");
f01005fd:	83 ec 0c             	sub    $0xc,%esp
f0100600:	68 99 46 10 f0       	push   $0xf0104699
f0100605:	e8 42 28 00 00       	call   f0102e4c <cprintf>
f010060a:	83 c4 10             	add    $0x10,%esp
}
f010060d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100610:	5b                   	pop    %ebx
f0100611:	5e                   	pop    %esi
f0100612:	5f                   	pop    %edi
f0100613:	5d                   	pop    %ebp
f0100614:	c3                   	ret    

f0100615 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100615:	55                   	push   %ebp
f0100616:	89 e5                	mov    %esp,%ebp
f0100618:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010061b:	8b 45 08             	mov    0x8(%ebp),%eax
f010061e:	e8 89 fc ff ff       	call   f01002ac <cons_putc>
}
f0100623:	c9                   	leave  
f0100624:	c3                   	ret    

f0100625 <getchar>:

int
getchar(void)
{
f0100625:	55                   	push   %ebp
f0100626:	89 e5                	mov    %esp,%ebp
f0100628:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010062b:	e8 93 fe ff ff       	call   f01004c3 <cons_getc>
f0100630:	85 c0                	test   %eax,%eax
f0100632:	74 f7                	je     f010062b <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100634:	c9                   	leave  
f0100635:	c3                   	ret    

f0100636 <iscons>:

int
iscons(int fdnum)
{
f0100636:	55                   	push   %ebp
f0100637:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100639:	b8 01 00 00 00       	mov    $0x1,%eax
f010063e:	5d                   	pop    %ebp
f010063f:	c3                   	ret    

f0100640 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100640:	55                   	push   %ebp
f0100641:	89 e5                	mov    %esp,%ebp
f0100643:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100646:	68 e0 48 10 f0       	push   $0xf01048e0
f010064b:	68 fe 48 10 f0       	push   $0xf01048fe
f0100650:	68 03 49 10 f0       	push   $0xf0104903
f0100655:	e8 f2 27 00 00       	call   f0102e4c <cprintf>
f010065a:	83 c4 0c             	add    $0xc,%esp
f010065d:	68 6c 49 10 f0       	push   $0xf010496c
f0100662:	68 0c 49 10 f0       	push   $0xf010490c
f0100667:	68 03 49 10 f0       	push   $0xf0104903
f010066c:	e8 db 27 00 00       	call   f0102e4c <cprintf>
	return 0;
}
f0100671:	b8 00 00 00 00       	mov    $0x0,%eax
f0100676:	c9                   	leave  
f0100677:	c3                   	ret    

f0100678 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100678:	55                   	push   %ebp
f0100679:	89 e5                	mov    %esp,%ebp
f010067b:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f010067e:	68 15 49 10 f0       	push   $0xf0104915
f0100683:	e8 c4 27 00 00       	call   f0102e4c <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100688:	83 c4 08             	add    $0x8,%esp
f010068b:	68 0c 00 10 00       	push   $0x10000c
f0100690:	68 94 49 10 f0       	push   $0xf0104994
f0100695:	e8 b2 27 00 00       	call   f0102e4c <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f010069a:	83 c4 0c             	add    $0xc,%esp
f010069d:	68 0c 00 10 00       	push   $0x10000c
f01006a2:	68 0c 00 10 f0       	push   $0xf010000c
f01006a7:	68 bc 49 10 f0       	push   $0xf01049bc
f01006ac:	e8 9b 27 00 00       	call   f0102e4c <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01006b1:	83 c4 0c             	add    $0xc,%esp
f01006b4:	68 31 46 10 00       	push   $0x104631
f01006b9:	68 31 46 10 f0       	push   $0xf0104631
f01006be:	68 e0 49 10 f0       	push   $0xf01049e0
f01006c3:	e8 84 27 00 00       	call   f0102e4c <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f01006c8:	83 c4 0c             	add    $0xc,%esp
f01006cb:	68 ee bb 17 00       	push   $0x17bbee
f01006d0:	68 ee bb 17 f0       	push   $0xf017bbee
f01006d5:	68 04 4a 10 f0       	push   $0xf0104a04
f01006da:	e8 6d 27 00 00       	call   f0102e4c <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f01006df:	83 c4 0c             	add    $0xc,%esp
f01006e2:	68 10 cb 17 00       	push   $0x17cb10
f01006e7:	68 10 cb 17 f0       	push   $0xf017cb10
f01006ec:	68 28 4a 10 f0       	push   $0xf0104a28
f01006f1:	e8 56 27 00 00       	call   f0102e4c <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f01006f6:	b8 0f cf 17 f0       	mov    $0xf017cf0f,%eax
f01006fb:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100700:	83 c4 08             	add    $0x8,%esp
f0100703:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100708:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010070e:	85 c0                	test   %eax,%eax
f0100710:	0f 48 c2             	cmovs  %edx,%eax
f0100713:	c1 f8 0a             	sar    $0xa,%eax
f0100716:	50                   	push   %eax
f0100717:	68 4c 4a 10 f0       	push   $0xf0104a4c
f010071c:	e8 2b 27 00 00       	call   f0102e4c <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100721:	b8 00 00 00 00       	mov    $0x0,%eax
f0100726:	c9                   	leave  
f0100727:	c3                   	ret    

f0100728 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100728:	55                   	push   %ebp
f0100729:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f010072b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100730:	5d                   	pop    %ebp
f0100731:	c3                   	ret    

f0100732 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100732:	55                   	push   %ebp
f0100733:	89 e5                	mov    %esp,%ebp
f0100735:	57                   	push   %edi
f0100736:	56                   	push   %esi
f0100737:	53                   	push   %ebx
f0100738:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010073b:	68 78 4a 10 f0       	push   $0xf0104a78
f0100740:	e8 07 27 00 00       	call   f0102e4c <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100745:	c7 04 24 9c 4a 10 f0 	movl   $0xf0104a9c,(%esp)
f010074c:	e8 fb 26 00 00       	call   f0102e4c <cprintf>

	if (tf != NULL)
f0100751:	83 c4 10             	add    $0x10,%esp
f0100754:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100758:	74 0e                	je     f0100768 <monitor+0x36>
		print_trapframe(tf);
f010075a:	83 ec 0c             	sub    $0xc,%esp
f010075d:	ff 75 08             	pushl  0x8(%ebp)
f0100760:	e8 21 2b 00 00       	call   f0103286 <print_trapframe>
f0100765:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f0100768:	83 ec 0c             	sub    $0xc,%esp
f010076b:	68 2e 49 10 f0       	push   $0xf010492e
f0100770:	e8 df 37 00 00       	call   f0103f54 <readline>
f0100775:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100777:	83 c4 10             	add    $0x10,%esp
f010077a:	85 c0                	test   %eax,%eax
f010077c:	74 ea                	je     f0100768 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f010077e:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f0100785:	be 00 00 00 00       	mov    $0x0,%esi
f010078a:	eb 0a                	jmp    f0100796 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f010078c:	c6 03 00             	movb   $0x0,(%ebx)
f010078f:	89 f7                	mov    %esi,%edi
f0100791:	8d 5b 01             	lea    0x1(%ebx),%ebx
f0100794:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100796:	0f b6 03             	movzbl (%ebx),%eax
f0100799:	84 c0                	test   %al,%al
f010079b:	74 63                	je     f0100800 <monitor+0xce>
f010079d:	83 ec 08             	sub    $0x8,%esp
f01007a0:	0f be c0             	movsbl %al,%eax
f01007a3:	50                   	push   %eax
f01007a4:	68 32 49 10 f0       	push   $0xf0104932
f01007a9:	e8 c0 39 00 00       	call   f010416e <strchr>
f01007ae:	83 c4 10             	add    $0x10,%esp
f01007b1:	85 c0                	test   %eax,%eax
f01007b3:	75 d7                	jne    f010078c <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01007b5:	80 3b 00             	cmpb   $0x0,(%ebx)
f01007b8:	74 46                	je     f0100800 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01007ba:	83 fe 0f             	cmp    $0xf,%esi
f01007bd:	75 14                	jne    f01007d3 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01007bf:	83 ec 08             	sub    $0x8,%esp
f01007c2:	6a 10                	push   $0x10
f01007c4:	68 37 49 10 f0       	push   $0xf0104937
f01007c9:	e8 7e 26 00 00       	call   f0102e4c <cprintf>
f01007ce:	83 c4 10             	add    $0x10,%esp
f01007d1:	eb 95                	jmp    f0100768 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01007d3:	8d 7e 01             	lea    0x1(%esi),%edi
f01007d6:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01007da:	eb 03                	jmp    f01007df <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01007dc:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01007df:	0f b6 03             	movzbl (%ebx),%eax
f01007e2:	84 c0                	test   %al,%al
f01007e4:	74 ae                	je     f0100794 <monitor+0x62>
f01007e6:	83 ec 08             	sub    $0x8,%esp
f01007e9:	0f be c0             	movsbl %al,%eax
f01007ec:	50                   	push   %eax
f01007ed:	68 32 49 10 f0       	push   $0xf0104932
f01007f2:	e8 77 39 00 00       	call   f010416e <strchr>
f01007f7:	83 c4 10             	add    $0x10,%esp
f01007fa:	85 c0                	test   %eax,%eax
f01007fc:	74 de                	je     f01007dc <monitor+0xaa>
f01007fe:	eb 94                	jmp    f0100794 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100800:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100807:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100808:	85 f6                	test   %esi,%esi
f010080a:	0f 84 58 ff ff ff    	je     f0100768 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100810:	83 ec 08             	sub    $0x8,%esp
f0100813:	68 fe 48 10 f0       	push   $0xf01048fe
f0100818:	ff 75 a8             	pushl  -0x58(%ebp)
f010081b:	e8 f0 38 00 00       	call   f0104110 <strcmp>
f0100820:	83 c4 10             	add    $0x10,%esp
f0100823:	85 c0                	test   %eax,%eax
f0100825:	74 1e                	je     f0100845 <monitor+0x113>
f0100827:	83 ec 08             	sub    $0x8,%esp
f010082a:	68 0c 49 10 f0       	push   $0xf010490c
f010082f:	ff 75 a8             	pushl  -0x58(%ebp)
f0100832:	e8 d9 38 00 00       	call   f0104110 <strcmp>
f0100837:	83 c4 10             	add    $0x10,%esp
f010083a:	85 c0                	test   %eax,%eax
f010083c:	75 2f                	jne    f010086d <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010083e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100843:	eb 05                	jmp    f010084a <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100845:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f010084a:	83 ec 04             	sub    $0x4,%esp
f010084d:	8d 14 00             	lea    (%eax,%eax,1),%edx
f0100850:	01 d0                	add    %edx,%eax
f0100852:	ff 75 08             	pushl  0x8(%ebp)
f0100855:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f0100858:	51                   	push   %ecx
f0100859:	56                   	push   %esi
f010085a:	ff 14 85 cc 4a 10 f0 	call   *-0xfefb534(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100861:	83 c4 10             	add    $0x10,%esp
f0100864:	85 c0                	test   %eax,%eax
f0100866:	78 1d                	js     f0100885 <monitor+0x153>
f0100868:	e9 fb fe ff ff       	jmp    f0100768 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010086d:	83 ec 08             	sub    $0x8,%esp
f0100870:	ff 75 a8             	pushl  -0x58(%ebp)
f0100873:	68 54 49 10 f0       	push   $0xf0104954
f0100878:	e8 cf 25 00 00       	call   f0102e4c <cprintf>
f010087d:	83 c4 10             	add    $0x10,%esp
f0100880:	e9 e3 fe ff ff       	jmp    f0100768 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100885:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100888:	5b                   	pop    %ebx
f0100889:	5e                   	pop    %esi
f010088a:	5f                   	pop    %edi
f010088b:	5d                   	pop    %ebp
f010088c:	c3                   	ret    

f010088d <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
//暂时用作页分配器，真实的物理页分配器是page_alloc函数
static void *
boot_alloc(uint32_t n)
{
f010088d:	55                   	push   %ebp
f010088e:	89 e5                	mov    %esp,%ebp
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	//nextfree为静态变量，初始时指向开始指向内核bss段的末尾
	/*根据mem_init()函数可知，kern_pgdir初始化时第一次调用boot_alloc(),
	  故kern_pgdir指向end*/
	if (!nextfree) {
f0100890:	83 3d 38 be 17 f0 00 	cmpl   $0x0,0xf017be38
f0100897:	75 11                	jne    f01008aa <boot_alloc+0x1d>
		extern char end[];
		//end 在哪里？？？
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100899:	ba 0f db 17 f0       	mov    $0xf017db0f,%edx
f010089e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008a4:	89 15 38 be 17 f0    	mov    %edx,0xf017be38
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//
	result = nextfree;
f01008aa:	8b 0d 38 be 17 f0    	mov    0xf017be38,%ecx
	//ROUNDUP()用作页对齐
	nextfree = ROUNDUP((char *)nextfree + n, PGSIZE);
f01008b0:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f01008b7:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01008bd:	89 15 38 be 17 f0    	mov    %edx,0xf017be38
	return result;
}
f01008c3:	89 c8                	mov    %ecx,%eax
f01008c5:	5d                   	pop    %ebp
f01008c6:	c3                   	ret    

f01008c7 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f01008c7:	55                   	push   %ebp
f01008c8:	89 e5                	mov    %esp,%ebp
f01008ca:	56                   	push   %esi
f01008cb:	53                   	push   %ebx
f01008cc:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01008ce:	83 ec 0c             	sub    $0xc,%esp
f01008d1:	50                   	push   %eax
f01008d2:	e8 0e 25 00 00       	call   f0102de5 <mc146818_read>
f01008d7:	89 c6                	mov    %eax,%esi
f01008d9:	83 c3 01             	add    $0x1,%ebx
f01008dc:	89 1c 24             	mov    %ebx,(%esp)
f01008df:	e8 01 25 00 00       	call   f0102de5 <mc146818_read>
f01008e4:	c1 e0 08             	shl    $0x8,%eax
f01008e7:	09 f0                	or     %esi,%eax
}
f01008e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01008ec:	5b                   	pop    %ebx
f01008ed:	5e                   	pop    %esi
f01008ee:	5d                   	pop    %ebp
f01008ef:	c3                   	ret    

f01008f0 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f01008f0:	89 d1                	mov    %edx,%ecx
f01008f2:	c1 e9 16             	shr    $0x16,%ecx
f01008f5:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f01008f8:	a8 01                	test   $0x1,%al
f01008fa:	74 52                	je     f010094e <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f01008fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100901:	89 c1                	mov    %eax,%ecx
f0100903:	c1 e9 0c             	shr    $0xc,%ecx
f0100906:	3b 0d 04 cb 17 f0    	cmp    0xf017cb04,%ecx
f010090c:	72 1b                	jb     f0100929 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f010090e:	55                   	push   %ebp
f010090f:	89 e5                	mov    %esp,%ebp
f0100911:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100914:	50                   	push   %eax
f0100915:	68 dc 4a 10 f0       	push   $0xf0104adc
f010091a:	68 46 03 00 00       	push   $0x346
f010091f:	68 bd 52 10 f0       	push   $0xf01052bd
f0100924:	e8 77 f7 ff ff       	call   f01000a0 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100929:	c1 ea 0c             	shr    $0xc,%edx
f010092c:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100932:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100939:	89 c2                	mov    %eax,%edx
f010093b:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f010093e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100943:	85 d2                	test   %edx,%edx
f0100945:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f010094a:	0f 44 c2             	cmove  %edx,%eax
f010094d:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f010094e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100953:	c3                   	ret    

f0100954 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100954:	55                   	push   %ebp
f0100955:	89 e5                	mov    %esp,%ebp
f0100957:	57                   	push   %edi
f0100958:	56                   	push   %esi
f0100959:	53                   	push   %ebx
f010095a:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f010095d:	84 c0                	test   %al,%al
f010095f:	0f 85 81 02 00 00    	jne    f0100be6 <check_page_free_list+0x292>
f0100965:	e9 8e 02 00 00       	jmp    f0100bf8 <check_page_free_list+0x2a4>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f010096a:	83 ec 04             	sub    $0x4,%esp
f010096d:	68 00 4b 10 f0       	push   $0xf0104b00
f0100972:	68 82 02 00 00       	push   $0x282
f0100977:	68 bd 52 10 f0       	push   $0xf01052bd
f010097c:	e8 1f f7 ff ff       	call   f01000a0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100981:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100984:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100987:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010098a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f010098d:	89 c2                	mov    %eax,%edx
f010098f:	2b 15 0c cb 17 f0    	sub    0xf017cb0c,%edx
f0100995:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f010099b:	0f 95 c2             	setne  %dl
f010099e:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f01009a1:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f01009a5:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f01009a7:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f01009ab:	8b 00                	mov    (%eax),%eax
f01009ad:	85 c0                	test   %eax,%eax
f01009af:	75 dc                	jne    f010098d <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f01009b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01009b4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f01009ba:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01009bd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01009c0:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f01009c2:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01009c5:	a3 40 be 17 f0       	mov    %eax,0xf017be40
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f01009ca:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01009cf:	8b 1d 40 be 17 f0    	mov    0xf017be40,%ebx
f01009d5:	eb 53                	jmp    f0100a2a <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01009d7:	89 d8                	mov    %ebx,%eax
f01009d9:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f01009df:	c1 f8 03             	sar    $0x3,%eax
f01009e2:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f01009e5:	89 c2                	mov    %eax,%edx
f01009e7:	c1 ea 16             	shr    $0x16,%edx
f01009ea:	39 f2                	cmp    %esi,%edx
f01009ec:	73 3a                	jae    f0100a28 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01009ee:	89 c2                	mov    %eax,%edx
f01009f0:	c1 ea 0c             	shr    $0xc,%edx
f01009f3:	3b 15 04 cb 17 f0    	cmp    0xf017cb04,%edx
f01009f9:	72 12                	jb     f0100a0d <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01009fb:	50                   	push   %eax
f01009fc:	68 dc 4a 10 f0       	push   $0xf0104adc
f0100a01:	6a 56                	push   $0x56
f0100a03:	68 c9 52 10 f0       	push   $0xf01052c9
f0100a08:	e8 93 f6 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100a0d:	83 ec 04             	sub    $0x4,%esp
f0100a10:	68 80 00 00 00       	push   $0x80
f0100a15:	68 97 00 00 00       	push   $0x97
f0100a1a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100a1f:	50                   	push   %eax
f0100a20:	e8 86 37 00 00       	call   f01041ab <memset>
f0100a25:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100a28:	8b 1b                	mov    (%ebx),%ebx
f0100a2a:	85 db                	test   %ebx,%ebx
f0100a2c:	75 a9                	jne    f01009d7 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100a2e:	b8 00 00 00 00       	mov    $0x0,%eax
f0100a33:	e8 55 fe ff ff       	call   f010088d <boot_alloc>
f0100a38:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a3b:	8b 15 40 be 17 f0    	mov    0xf017be40,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100a41:	8b 0d 0c cb 17 f0    	mov    0xf017cb0c,%ecx
		assert(pp < pages + npages);
f0100a47:	a1 04 cb 17 f0       	mov    0xf017cb04,%eax
f0100a4c:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100a4f:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100a52:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100a55:	be 00 00 00 00       	mov    $0x0,%esi
f0100a5a:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100a5d:	e9 30 01 00 00       	jmp    f0100b92 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100a62:	39 ca                	cmp    %ecx,%edx
f0100a64:	73 19                	jae    f0100a7f <check_page_free_list+0x12b>
f0100a66:	68 d7 52 10 f0       	push   $0xf01052d7
f0100a6b:	68 e3 52 10 f0       	push   $0xf01052e3
f0100a70:	68 9c 02 00 00       	push   $0x29c
f0100a75:	68 bd 52 10 f0       	push   $0xf01052bd
f0100a7a:	e8 21 f6 ff ff       	call   f01000a0 <_panic>
		assert(pp < pages + npages);
f0100a7f:	39 fa                	cmp    %edi,%edx
f0100a81:	72 19                	jb     f0100a9c <check_page_free_list+0x148>
f0100a83:	68 f8 52 10 f0       	push   $0xf01052f8
f0100a88:	68 e3 52 10 f0       	push   $0xf01052e3
f0100a8d:	68 9d 02 00 00       	push   $0x29d
f0100a92:	68 bd 52 10 f0       	push   $0xf01052bd
f0100a97:	e8 04 f6 ff ff       	call   f01000a0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100a9c:	89 d0                	mov    %edx,%eax
f0100a9e:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100aa1:	a8 07                	test   $0x7,%al
f0100aa3:	74 19                	je     f0100abe <check_page_free_list+0x16a>
f0100aa5:	68 24 4b 10 f0       	push   $0xf0104b24
f0100aaa:	68 e3 52 10 f0       	push   $0xf01052e3
f0100aaf:	68 9e 02 00 00       	push   $0x29e
f0100ab4:	68 bd 52 10 f0       	push   $0xf01052bd
f0100ab9:	e8 e2 f5 ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100abe:	c1 f8 03             	sar    $0x3,%eax
f0100ac1:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ac4:	85 c0                	test   %eax,%eax
f0100ac6:	75 19                	jne    f0100ae1 <check_page_free_list+0x18d>
f0100ac8:	68 0c 53 10 f0       	push   $0xf010530c
f0100acd:	68 e3 52 10 f0       	push   $0xf01052e3
f0100ad2:	68 a1 02 00 00       	push   $0x2a1
f0100ad7:	68 bd 52 10 f0       	push   $0xf01052bd
f0100adc:	e8 bf f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ae1:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ae6:	75 19                	jne    f0100b01 <check_page_free_list+0x1ad>
f0100ae8:	68 1d 53 10 f0       	push   $0xf010531d
f0100aed:	68 e3 52 10 f0       	push   $0xf01052e3
f0100af2:	68 a2 02 00 00       	push   $0x2a2
f0100af7:	68 bd 52 10 f0       	push   $0xf01052bd
f0100afc:	e8 9f f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100b01:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100b06:	75 19                	jne    f0100b21 <check_page_free_list+0x1cd>
f0100b08:	68 58 4b 10 f0       	push   $0xf0104b58
f0100b0d:	68 e3 52 10 f0       	push   $0xf01052e3
f0100b12:	68 a3 02 00 00       	push   $0x2a3
f0100b17:	68 bd 52 10 f0       	push   $0xf01052bd
f0100b1c:	e8 7f f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100b21:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100b26:	75 19                	jne    f0100b41 <check_page_free_list+0x1ed>
f0100b28:	68 36 53 10 f0       	push   $0xf0105336
f0100b2d:	68 e3 52 10 f0       	push   $0xf01052e3
f0100b32:	68 a4 02 00 00       	push   $0x2a4
f0100b37:	68 bd 52 10 f0       	push   $0xf01052bd
f0100b3c:	e8 5f f5 ff ff       	call   f01000a0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100b41:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100b46:	76 3f                	jbe    f0100b87 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b48:	89 c3                	mov    %eax,%ebx
f0100b4a:	c1 eb 0c             	shr    $0xc,%ebx
f0100b4d:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100b50:	77 12                	ja     f0100b64 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b52:	50                   	push   %eax
f0100b53:	68 dc 4a 10 f0       	push   $0xf0104adc
f0100b58:	6a 56                	push   $0x56
f0100b5a:	68 c9 52 10 f0       	push   $0xf01052c9
f0100b5f:	e8 3c f5 ff ff       	call   f01000a0 <_panic>
f0100b64:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b69:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100b6c:	76 1e                	jbe    f0100b8c <check_page_free_list+0x238>
f0100b6e:	68 7c 4b 10 f0       	push   $0xf0104b7c
f0100b73:	68 e3 52 10 f0       	push   $0xf01052e3
f0100b78:	68 a5 02 00 00       	push   $0x2a5
f0100b7d:	68 bd 52 10 f0       	push   $0xf01052bd
f0100b82:	e8 19 f5 ff ff       	call   f01000a0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100b87:	83 c6 01             	add    $0x1,%esi
f0100b8a:	eb 04                	jmp    f0100b90 <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100b8c:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b90:	8b 12                	mov    (%edx),%edx
f0100b92:	85 d2                	test   %edx,%edx
f0100b94:	0f 85 c8 fe ff ff    	jne    f0100a62 <check_page_free_list+0x10e>
f0100b9a:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100b9d:	85 f6                	test   %esi,%esi
f0100b9f:	7f 19                	jg     f0100bba <check_page_free_list+0x266>
f0100ba1:	68 50 53 10 f0       	push   $0xf0105350
f0100ba6:	68 e3 52 10 f0       	push   $0xf01052e3
f0100bab:	68 ad 02 00 00       	push   $0x2ad
f0100bb0:	68 bd 52 10 f0       	push   $0xf01052bd
f0100bb5:	e8 e6 f4 ff ff       	call   f01000a0 <_panic>
	assert(nfree_extmem > 0);
f0100bba:	85 db                	test   %ebx,%ebx
f0100bbc:	7f 19                	jg     f0100bd7 <check_page_free_list+0x283>
f0100bbe:	68 62 53 10 f0       	push   $0xf0105362
f0100bc3:	68 e3 52 10 f0       	push   $0xf01052e3
f0100bc8:	68 ae 02 00 00       	push   $0x2ae
f0100bcd:	68 bd 52 10 f0       	push   $0xf01052bd
f0100bd2:	e8 c9 f4 ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100bd7:	83 ec 0c             	sub    $0xc,%esp
f0100bda:	68 c4 4b 10 f0       	push   $0xf0104bc4
f0100bdf:	e8 68 22 00 00       	call   f0102e4c <cprintf>
}
f0100be4:	eb 29                	jmp    f0100c0f <check_page_free_list+0x2bb>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100be6:	a1 40 be 17 f0       	mov    0xf017be40,%eax
f0100beb:	85 c0                	test   %eax,%eax
f0100bed:	0f 85 8e fd ff ff    	jne    f0100981 <check_page_free_list+0x2d>
f0100bf3:	e9 72 fd ff ff       	jmp    f010096a <check_page_free_list+0x16>
f0100bf8:	83 3d 40 be 17 f0 00 	cmpl   $0x0,0xf017be40
f0100bff:	0f 84 65 fd ff ff    	je     f010096a <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100c05:	be 00 04 00 00       	mov    $0x400,%esi
f0100c0a:	e9 c0 fd ff ff       	jmp    f01009cf <check_page_free_list+0x7b>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100c12:	5b                   	pop    %ebx
f0100c13:	5e                   	pop    %esi
f0100c14:	5f                   	pop    %edi
f0100c15:	5d                   	pop    %ebp
f0100c16:	c3                   	ret    

f0100c17 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100c17:	55                   	push   %ebp
f0100c18:	89 e5                	mov    %esp,%ebp
f0100c1a:	57                   	push   %edi
f0100c1b:	56                   	push   %esi
f0100c1c:	53                   	push   %ebx
f0100c1d:	83 ec 0c             	sub    $0xc,%esp
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	//？？
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
f0100c20:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c25:	e8 63 fc ff ff       	call   f010088d <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c2a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100c2f:	77 15                	ja     f0100c46 <page_init+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c31:	50                   	push   %eax
f0100c32:	68 e8 4b 10 f0       	push   $0xf0104be8
f0100c37:	68 32 01 00 00       	push   $0x132
f0100c3c:	68 bd 52 10 f0       	push   $0xf01052bd
f0100c41:	e8 5a f4 ff ff       	call   f01000a0 <_panic>
f0100c46:	05 00 00 00 10       	add    $0x10000000,%eax
f0100c4b:	c1 e8 0c             	shr    $0xc,%eax
	for (i = 1; i < npages; i++) {
		if (i >= npages_basemem && i < pgnum)
f0100c4e:	8b 3d 44 be 17 f0    	mov    0xf017be44,%edi
f0100c54:	8b 35 40 be 17 f0    	mov    0xf017be40,%esi
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	//？？
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100c5f:	ba 01 00 00 00       	mov    $0x1,%edx
f0100c64:	eb 2f                	jmp    f0100c95 <page_init+0x7e>
		if (i >= npages_basemem && i < pgnum)
f0100c66:	39 c2                	cmp    %eax,%edx
f0100c68:	73 04                	jae    f0100c6e <page_init+0x57>
f0100c6a:	39 fa                	cmp    %edi,%edx
f0100c6c:	73 24                	jae    f0100c92 <page_init+0x7b>
			continue;
		pages[i].pp_ref = 0;
f0100c6e:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100c75:	89 cb                	mov    %ecx,%ebx
f0100c77:	03 1d 0c cb 17 f0    	add    0xf017cb0c,%ebx
f0100c7d:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f0100c83:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f0100c85:	89 ce                	mov    %ecx,%esi
f0100c87:	03 35 0c cb 17 f0    	add    0xf017cb0c,%esi
f0100c8d:	b9 01 00 00 00       	mov    $0x1,%ecx
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	//？？
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100c92:	83 c2 01             	add    $0x1,%edx
f0100c95:	3b 15 04 cb 17 f0    	cmp    0xf017cb04,%edx
f0100c9b:	72 c9                	jb     f0100c66 <page_init+0x4f>
f0100c9d:	84 c9                	test   %cl,%cl
f0100c9f:	74 06                	je     f0100ca7 <page_init+0x90>
f0100ca1:	89 35 40 be 17 f0    	mov    %esi,0xf017be40
			continue;
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100ca7:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100caa:	5b                   	pop    %ebx
f0100cab:	5e                   	pop    %esi
f0100cac:	5f                   	pop    %edi
f0100cad:	5d                   	pop    %ebp
f0100cae:	c3                   	ret    

f0100caf <page_alloc>:
//
// Hint: use page2kva and memset
//分配一个物理页面
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100caf:	55                   	push   %ebp
f0100cb0:	89 e5                	mov    %esp,%ebp
f0100cb2:	53                   	push   %ebx
f0100cb3:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo *result = NULL;
	//如果存在空闲ye
	if (page_free_list) {
f0100cb6:	8b 1d 40 be 17 f0    	mov    0xf017be40,%ebx
f0100cbc:	85 db                	test   %ebx,%ebx
f0100cbe:	74 58                	je     f0100d18 <page_alloc+0x69>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100cc0:	8b 03                	mov    (%ebx),%eax
f0100cc2:	a3 40 be 17 f0       	mov    %eax,0xf017be40
		result->pp_link = NULL;
f0100cc7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		//??????
		if (alloc_flags & ALLOC_ZERO)
f0100ccd:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100cd1:	74 45                	je     f0100d18 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100cd3:	89 d8                	mov    %ebx,%eax
f0100cd5:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f0100cdb:	c1 f8 03             	sar    $0x3,%eax
f0100cde:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ce1:	89 c2                	mov    %eax,%edx
f0100ce3:	c1 ea 0c             	shr    $0xc,%edx
f0100ce6:	3b 15 04 cb 17 f0    	cmp    0xf017cb04,%edx
f0100cec:	72 12                	jb     f0100d00 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cee:	50                   	push   %eax
f0100cef:	68 dc 4a 10 f0       	push   $0xf0104adc
f0100cf4:	6a 56                	push   $0x56
f0100cf6:	68 c9 52 10 f0       	push   $0xf01052c9
f0100cfb:	e8 a0 f3 ff ff       	call   f01000a0 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f0100d00:	83 ec 04             	sub    $0x4,%esp
f0100d03:	68 00 10 00 00       	push   $0x1000
f0100d08:	6a 00                	push   $0x0
f0100d0a:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d0f:	50                   	push   %eax
f0100d10:	e8 96 34 00 00       	call   f01041ab <memset>
f0100d15:	83 c4 10             	add    $0x10,%esp
	}
	return result;
}
f0100d18:	89 d8                	mov    %ebx,%eax
f0100d1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100d1d:	c9                   	leave  
f0100d1e:	c3                   	ret    

f0100d1f <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100d1f:	55                   	push   %ebp
f0100d20:	89 e5                	mov    %esp,%ebp
f0100d22:	83 ec 08             	sub    $0x8,%esp
f0100d25:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	//容错判断
	assert(pp != NULL);
f0100d28:	85 c0                	test   %eax,%eax
f0100d2a:	75 19                	jne    f0100d45 <page_free+0x26>
f0100d2c:	68 73 53 10 f0       	push   $0xf0105373
f0100d31:	68 e3 52 10 f0       	push   $0xf01052e3
f0100d36:	68 65 01 00 00       	push   $0x165
f0100d3b:	68 bd 52 10 f0       	push   $0xf01052bd
f0100d40:	e8 5b f3 ff ff       	call   f01000a0 <_panic>
	assert(pp->pp_ref == 0);
f0100d45:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100d4a:	74 19                	je     f0100d65 <page_free+0x46>
f0100d4c:	68 7e 53 10 f0       	push   $0xf010537e
f0100d51:	68 e3 52 10 f0       	push   $0xf01052e3
f0100d56:	68 66 01 00 00       	push   $0x166
f0100d5b:	68 bd 52 10 f0       	push   $0xf01052bd
f0100d60:	e8 3b f3 ff ff       	call   f01000a0 <_panic>
	assert(pp->pp_link == NULL);
f0100d65:	83 38 00             	cmpl   $0x0,(%eax)
f0100d68:	74 19                	je     f0100d83 <page_free+0x64>
f0100d6a:	68 8e 53 10 f0       	push   $0xf010538e
f0100d6f:	68 e3 52 10 f0       	push   $0xf01052e3
f0100d74:	68 67 01 00 00       	push   $0x167
f0100d79:	68 bd 52 10 f0       	push   $0xf01052bd
f0100d7e:	e8 1d f3 ff ff       	call   f01000a0 <_panic>
	
	//释放物理页面
      	pp->pp_link = page_free_list;
f0100d83:	8b 15 40 be 17 f0    	mov    0xf017be40,%edx
f0100d89:	89 10                	mov    %edx,(%eax)
      	page_free_list = pp;
f0100d8b:	a3 40 be 17 f0       	mov    %eax,0xf017be40
}
f0100d90:	c9                   	leave  
f0100d91:	c3                   	ret    

f0100d92 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100d92:	55                   	push   %ebp
f0100d93:	89 e5                	mov    %esp,%ebp
f0100d95:	83 ec 08             	sub    $0x8,%esp
f0100d98:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100d9b:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100d9f:	83 e8 01             	sub    $0x1,%eax
f0100da2:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100da6:	66 85 c0             	test   %ax,%ax
f0100da9:	75 0c                	jne    f0100db7 <page_decref+0x25>
		page_free(pp);
f0100dab:	83 ec 0c             	sub    $0xc,%esp
f0100dae:	52                   	push   %edx
f0100daf:	e8 6b ff ff ff       	call   f0100d1f <page_free>
f0100db4:	83 c4 10             	add    $0x10,%esp
}
f0100db7:	c9                   	leave  
f0100db8:	c3                   	ret    

f0100db9 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//返回虚拟地址所对应的页表项指针page table entry (PTE)
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100db9:	55                   	push   %ebp
f0100dba:	89 e5                	mov    %esp,%ebp
f0100dbc:	56                   	push   %esi
f0100dbd:	53                   	push   %ebx
f0100dbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	//return NULL;
	//根据虚拟地址解析出页目录索引和页表索引，pdx--页目录索引 ptx -- 页表索引
	size_t pdx = PDX(va), ptx = PTX(va);
f0100dc1:	89 de                	mov    %ebx,%esi
f0100dc3:	c1 ee 0c             	shr    $0xc,%esi
f0100dc6:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
f0100dcc:	c1 eb 16             	shr    $0x16,%ebx
f0100dcf:	c1 e3 02             	shl    $0x2,%ebx
f0100dd2:	03 5d 08             	add    0x8(%ebp),%ebx
f0100dd5:	f6 03 01             	testb  $0x1,(%ebx)
f0100dd8:	75 2d                	jne    f0100e07 <pgdir_walk+0x4e>
		if (!create) 
f0100dda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100dde:	74 59                	je     f0100e39 <pgdir_walk+0x80>
			return NULL;
		pp = page_alloc(ALLOC_ZERO);
f0100de0:	83 ec 0c             	sub    $0xc,%esp
f0100de3:	6a 01                	push   $0x1
f0100de5:	e8 c5 fe ff ff       	call   f0100caf <page_alloc>
		if (pp == NULL) 
f0100dea:	83 c4 10             	add    $0x10,%esp
f0100ded:	85 c0                	test   %eax,%eax
f0100def:	74 4f                	je     f0100e40 <pgdir_walk+0x87>
			return NULL;
		pp->pp_ref++;
f0100df1:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		pgdir[pdx] = page2pa(pp) | PTE_W | PTE_U | PTE_P; 
f0100df6:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f0100dfc:	c1 f8 03             	sar    $0x3,%eax
f0100dff:	c1 e0 0c             	shl    $0xc,%eax
f0100e02:	83 c8 07             	or     $0x7,%eax
f0100e05:	89 03                	mov    %eax,(%ebx)
	} 
	
	//这里为什么要用 PTE_ADDR？？？
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
f0100e07:	8b 03                	mov    (%ebx),%eax
f0100e09:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e0e:	89 c2                	mov    %eax,%edx
f0100e10:	c1 ea 0c             	shr    $0xc,%edx
f0100e13:	3b 15 04 cb 17 f0    	cmp    0xf017cb04,%edx
f0100e19:	72 15                	jb     f0100e30 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e1b:	50                   	push   %eax
f0100e1c:	68 dc 4a 10 f0       	push   $0xf0104adc
f0100e21:	68 a4 01 00 00       	push   $0x1a4
f0100e26:	68 bd 52 10 f0       	push   $0xf01052bd
f0100e2b:	e8 70 f2 ff ff       	call   f01000a0 <_panic>
	return &pgtbl[ptx];
f0100e30:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100e37:	eb 0c                	jmp    f0100e45 <pgdir_walk+0x8c>
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
		if (!create) 
			return NULL;
f0100e39:	b8 00 00 00 00       	mov    $0x0,%eax
f0100e3e:	eb 05                	jmp    f0100e45 <pgdir_walk+0x8c>
		pp = page_alloc(ALLOC_ZERO);
		if (pp == NULL) 
			return NULL;
f0100e40:	b8 00 00 00 00       	mov    $0x0,%eax
	} 
	
	//这里为什么要用 PTE_ADDR？？？
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
	return &pgtbl[ptx];
}
f0100e45:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100e48:	5b                   	pop    %ebx
f0100e49:	5e                   	pop    %esi
f0100e4a:	5d                   	pop    %ebp
f0100e4b:	c3                   	ret    

f0100e4c <boot_map_region>:
// Hint: the TA solution uses pgdir_walk
//把虚拟地址空间范围[va, va+size)映射到物理空间[pa, pa+size)的映射关系加入到页表中
//这个函数主要的目的是为了设置虚拟地址UTOP之上的地址范围
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100e4c:	55                   	push   %ebp
f0100e4d:	89 e5                	mov    %esp,%ebp
f0100e4f:	57                   	push   %edi
f0100e50:	56                   	push   %esi
f0100e51:	53                   	push   %ebx
f0100e52:	83 ec 1c             	sub    $0x1c,%esp
f0100e55:	89 c7                	mov    %eax,%edi
f0100e57:	89 d6                	mov    %edx,%esi
f0100e59:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	size_t i;
	//?????i < size??
	for (i = 0; i < size; i += PGSIZE) {
f0100e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		//??????| perm | PTE_P
		*pte = (pa + i) | perm | PTE_P;
f0100e61:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100e64:	83 c8 01             	or     $0x1,%eax
f0100e67:	89 45 e0             	mov    %eax,-0x20(%ebp)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	//?????i < size??
	for (i = 0; i < size; i += PGSIZE) {
f0100e6a:	eb 22                	jmp    f0100e8e <boot_map_region+0x42>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f0100e6c:	83 ec 04             	sub    $0x4,%esp
f0100e6f:	6a 01                	push   $0x1
f0100e71:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0100e74:	50                   	push   %eax
f0100e75:	57                   	push   %edi
f0100e76:	e8 3e ff ff ff       	call   f0100db9 <pgdir_walk>
		//??????| perm | PTE_P
		*pte = (pa + i) | perm | PTE_P;
f0100e7b:	89 da                	mov    %ebx,%edx
f0100e7d:	03 55 08             	add    0x8(%ebp),%edx
f0100e80:	0b 55 e0             	or     -0x20(%ebp),%edx
f0100e83:	89 10                	mov    %edx,(%eax)
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	//?????i < size??
	for (i = 0; i < size; i += PGSIZE) {
f0100e85:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0100e8b:	83 c4 10             	add    $0x10,%esp
f0100e8e:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0100e91:	72 d9                	jb     f0100e6c <boot_map_region+0x20>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		//??????| perm | PTE_P
		*pte = (pa + i) | perm | PTE_P;
	}
}
f0100e93:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e96:	5b                   	pop    %ebx
f0100e97:	5e                   	pop    %esi
f0100e98:	5f                   	pop    %edi
f0100e99:	5d                   	pop    %ebp
f0100e9a:	c3                   	ret    

f0100e9b <page_lookup>:
// Hint: the TA solution uses pgdir_walk and pa2page.
//返回虚拟地址所映射（对应）的物理页的PageInfo结构体的指针
//返回虚拟地址所对应的物理页指针
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100e9b:	55                   	push   %ebp
f0100e9c:	89 e5                	mov    %esp,%ebp
f0100e9e:	53                   	push   %ebx
f0100e9f:	83 ec 08             	sub    $0x8,%esp
f0100ea2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100ea5:	6a 01                	push   $0x1
f0100ea7:	ff 75 0c             	pushl  0xc(%ebp)
f0100eaa:	ff 75 08             	pushl  0x8(%ebp)
f0100ead:	e8 07 ff ff ff       	call   f0100db9 <pgdir_walk>
	//pte_store存页表项指针的地址，*pte_store表示页表项指针，即页表项地址，**pte_store表示页表项
	//pte_store????
	if (pte_store)
f0100eb2:	83 c4 10             	add    $0x10,%esp
f0100eb5:	85 db                	test   %ebx,%ebx
f0100eb7:	74 02                	je     f0100ebb <page_lookup+0x20>
		*pte_store = pte;
f0100eb9:	89 03                	mov    %eax,(%ebx)
	if (pte == NULL || !(*pte & PTE_P)) 
f0100ebb:	85 c0                	test   %eax,%eax
f0100ebd:	74 30                	je     f0100eef <page_lookup+0x54>
f0100ebf:	8b 00                	mov    (%eax),%eax
f0100ec1:	a8 01                	test   $0x1,%al
f0100ec3:	74 31                	je     f0100ef6 <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ec5:	c1 e8 0c             	shr    $0xc,%eax
f0100ec8:	3b 05 04 cb 17 f0    	cmp    0xf017cb04,%eax
f0100ece:	72 14                	jb     f0100ee4 <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f0100ed0:	83 ec 04             	sub    $0x4,%esp
f0100ed3:	68 0c 4c 10 f0       	push   $0xf0104c0c
f0100ed8:	6a 4f                	push   $0x4f
f0100eda:	68 c9 52 10 f0       	push   $0xf01052c9
f0100edf:	e8 bc f1 ff ff       	call   f01000a0 <_panic>
	return &pages[PGNUM(pa)];
f0100ee4:	8b 15 0c cb 17 f0    	mov    0xf017cb0c,%edx
f0100eea:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		return NULL;
	return pa2page(PTE_ADDR(*pte));
f0100eed:	eb 0c                	jmp    f0100efb <page_lookup+0x60>
	//pte_store存页表项指针的地址，*pte_store表示页表项指针，即页表项地址，**pte_store表示页表项
	//pte_store????
	if (pte_store)
		*pte_store = pte;
	if (pte == NULL || !(*pte & PTE_P)) 
		return NULL;
f0100eef:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ef4:	eb 05                	jmp    f0100efb <page_lookup+0x60>
f0100ef6:	b8 00 00 00 00       	mov    $0x0,%eax
	return pa2page(PTE_ADDR(*pte));
}
f0100efb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100efe:	c9                   	leave  
f0100eff:	c3                   	ret    

f0100f00 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0100f00:	55                   	push   %ebp
f0100f01:	89 e5                	mov    %esp,%ebp
f0100f03:	53                   	push   %ebx
f0100f04:	83 ec 18             	sub    $0x18,%esp
f0100f07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	pte_t *pte = NULL;
f0100f0a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f0100f11:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0100f14:	50                   	push   %eax
f0100f15:	53                   	push   %ebx
f0100f16:	ff 75 08             	pushl  0x8(%ebp)
f0100f19:	e8 7d ff ff ff       	call   f0100e9b <page_lookup>
	if(pp == NULL)
f0100f1e:	83 c4 10             	add    $0x10,%esp
f0100f21:	85 c0                	test   %eax,%eax
f0100f23:	74 18                	je     f0100f3d <page_remove+0x3d>
		return;
	*pte = (pte_t) 0; //将页表项内容置为空
f0100f25:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0100f28:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100f2e:	0f 01 3b             	invlpg (%ebx)
	tlb_invalidate(pgdir, va); //tlb置为无效
	page_decref(pp); //减少引用
f0100f31:	83 ec 0c             	sub    $0xc,%esp
f0100f34:	50                   	push   %eax
f0100f35:	e8 58 fe ff ff       	call   f0100d92 <page_decref>
f0100f3a:	83 c4 10             	add    $0x10,%esp
}
f0100f3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f40:	c9                   	leave  
f0100f41:	c3                   	ret    

f0100f42 <page_insert>:
// and page2pa.
//把一个物理内存中页pp与虚拟地址va建立映射关系。
//其实就是 更新页表
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100f42:	55                   	push   %ebp
f0100f43:	89 e5                	mov    %esp,%ebp
f0100f45:	57                   	push   %edi
f0100f46:	56                   	push   %esi
f0100f47:	53                   	push   %ebx
f0100f48:	83 ec 10             	sub    $0x10,%esp
f0100f4b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0100f4e:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	//return 0;
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100f51:	6a 01                	push   $0x1
f0100f53:	57                   	push   %edi
f0100f54:	ff 75 08             	pushl  0x8(%ebp)
f0100f57:	e8 5d fe ff ff       	call   f0100db9 <pgdir_walk>
    if (pte == NULL)  
f0100f5c:	83 c4 10             	add    $0x10,%esp
f0100f5f:	85 c0                	test   %eax,%eax
f0100f61:	74 38                	je     f0100f9b <page_insert+0x59>
f0100f63:	89 c6                	mov    %eax,%esi
    	return -E_NO_MEM;

    pp->pp_ref++;
f0100f65:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    //??????
    if (*pte & PTE_P)
f0100f6a:	f6 00 01             	testb  $0x1,(%eax)
f0100f6d:	74 0f                	je     f0100f7e <page_insert+0x3c>
            page_remove(pgdir, va);
f0100f6f:	83 ec 08             	sub    $0x8,%esp
f0100f72:	57                   	push   %edi
f0100f73:	ff 75 08             	pushl  0x8(%ebp)
f0100f76:	e8 85 ff ff ff       	call   f0100f00 <page_remove>
f0100f7b:	83 c4 10             	add    $0x10,%esp

    *pte = page2pa(pp) | perm | PTE_P;
f0100f7e:	2b 1d 0c cb 17 f0    	sub    0xf017cb0c,%ebx
f0100f84:	c1 fb 03             	sar    $0x3,%ebx
f0100f87:	c1 e3 0c             	shl    $0xc,%ebx
f0100f8a:	8b 45 14             	mov    0x14(%ebp),%eax
f0100f8d:	83 c8 01             	or     $0x1,%eax
f0100f90:	09 c3                	or     %eax,%ebx
f0100f92:	89 1e                	mov    %ebx,(%esi)

    return 0;
f0100f94:	b8 00 00 00 00       	mov    $0x0,%eax
f0100f99:	eb 05                	jmp    f0100fa0 <page_insert+0x5e>
{
	// Fill this function in
	//return 0;
	pte_t *pte = pgdir_walk(pgdir, va, 1);
    if (pte == NULL)  
    	return -E_NO_MEM;
f0100f9b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
            page_remove(pgdir, va);

    *pte = page2pa(pp) | perm | PTE_P;

    return 0;
}
f0100fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100fa3:	5b                   	pop    %ebx
f0100fa4:	5e                   	pop    %esi
f0100fa5:	5f                   	pop    %edi
f0100fa6:	5d                   	pop    %ebp
f0100fa7:	c3                   	ret    

f0100fa8 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0100fa8:	55                   	push   %ebp
f0100fa9:	89 e5                	mov    %esp,%ebp
f0100fab:	57                   	push   %edi
f0100fac:	56                   	push   %esi
f0100fad:	53                   	push   %ebx
f0100fae:	83 ec 2c             	sub    $0x2c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0100fb1:	b8 15 00 00 00       	mov    $0x15,%eax
f0100fb6:	e8 0c f9 ff ff       	call   f01008c7 <nvram_read>
f0100fbb:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f0100fbd:	b8 17 00 00 00       	mov    $0x17,%eax
f0100fc2:	e8 00 f9 ff ff       	call   f01008c7 <nvram_read>
f0100fc7:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0100fc9:	b8 34 00 00 00       	mov    $0x34,%eax
f0100fce:	e8 f4 f8 ff ff       	call   f01008c7 <nvram_read>
f0100fd3:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0100fd6:	85 c0                	test   %eax,%eax
f0100fd8:	74 07                	je     f0100fe1 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0100fda:	05 00 40 00 00       	add    $0x4000,%eax
f0100fdf:	eb 0b                	jmp    f0100fec <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0100fe1:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0100fe7:	85 f6                	test   %esi,%esi
f0100fe9:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0100fec:	89 c2                	mov    %eax,%edx
f0100fee:	c1 ea 02             	shr    $0x2,%edx
f0100ff1:	89 15 04 cb 17 f0    	mov    %edx,0xf017cb04
	npages_basemem = basemem / (PGSIZE / 1024);
f0100ff7:	89 da                	mov    %ebx,%edx
f0100ff9:	c1 ea 02             	shr    $0x2,%edx
f0100ffc:	89 15 44 be 17 f0    	mov    %edx,0xf017be44

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101002:	89 c2                	mov    %eax,%edx
f0101004:	29 da                	sub    %ebx,%edx
f0101006:	52                   	push   %edx
f0101007:	53                   	push   %ebx
f0101008:	50                   	push   %eax
f0101009:	68 2c 4c 10 f0       	push   $0xf0104c2c
f010100e:	e8 39 1e 00 00       	call   f0102e4c <cprintf>

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	//kern_pgdir -- 操作系统的页目录表指针，页目录表的大小为一个页的大小
	//第一个调用boot_alloc(),故kern_pgdir位于内核bss段的末尾，紧跟这操作系统内核
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101013:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101018:	e8 70 f8 ff ff       	call   f010088d <boot_alloc>
f010101d:	a3 08 cb 17 f0       	mov    %eax,0xf017cb08
	//内存清零
	memset(kern_pgdir, 0, PGSIZE);
f0101022:	83 c4 0c             	add    $0xc,%esp
f0101025:	68 00 10 00 00       	push   $0x1000
f010102a:	6a 00                	push   $0x0
f010102c:	50                   	push   %eax
f010102d:	e8 79 31 00 00       	call   f01041ab <memset>
	// Permissions: kernel R, user R
	// 为页目录表添加第一个页目录表项
	/* UVPT的定义是一段虚拟地址的起始地址，0xef400000，
	   从这个虚拟地址开始，存放的就是这个操作系统的页目录表*/
	// 映射？？？自身映射
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101032:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101037:	83 c4 10             	add    $0x10,%esp
f010103a:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010103f:	77 15                	ja     f0101056 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101041:	50                   	push   %eax
f0101042:	68 e8 4b 10 f0       	push   $0xf0104be8
f0101047:	68 9f 00 00 00       	push   $0x9f
f010104c:	68 bd 52 10 f0       	push   $0xf01052bd
f0101051:	e8 4a f0 ff ff       	call   f01000a0 <_panic>
f0101056:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010105c:	83 ca 05             	or     $0x5,%edx
f010105f:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	// 分配一块内存用来存放pages，pages数组里的每一项代表一个物理页面
	n = npages * sizeof(struct PageInfo);
f0101065:	a1 04 cb 17 f0       	mov    0xf017cb04,%eax
f010106a:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f0101071:	89 d8                	mov    %ebx,%eax
f0101073:	e8 15 f8 ff ff       	call   f010088d <boot_alloc>
f0101078:	a3 0c cb 17 f0       	mov    %eax,0xf017cb0c
	//内存清零
	memset(pages, 0, n);
f010107d:	83 ec 04             	sub    $0x4,%esp
f0101080:	53                   	push   %ebx
f0101081:	6a 00                	push   $0x0
f0101083:	50                   	push   %eax
f0101084:	e8 22 31 00 00       	call   f01041ab <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	// 分配空间存储envs，envs数组里的每一项代表一个用户空间(进程空间)
	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f0101089:	b8 00 80 01 00       	mov    $0x18000,%eax
f010108e:	e8 fa f7 ff ff       	call   f010088d <boot_alloc>
f0101093:	a3 4c be 17 f0       	mov    %eax,0xf017be4c
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	// 初始化物理页和空闲链表
	page_init();
f0101098:	e8 7a fb ff ff       	call   f0100c17 <page_init>
	
	//检查空闲链表是否合法
	check_page_free_list(1);
f010109d:	b8 01 00 00 00       	mov    $0x1,%eax
f01010a2:	e8 ad f8 ff ff       	call   f0100954 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01010a7:	83 c4 10             	add    $0x10,%esp
f01010aa:	83 3d 0c cb 17 f0 00 	cmpl   $0x0,0xf017cb0c
f01010b1:	75 17                	jne    f01010ca <mem_init+0x122>
		panic("'pages' is a null pointer!");
f01010b3:	83 ec 04             	sub    $0x4,%esp
f01010b6:	68 a2 53 10 f0       	push   $0xf01053a2
f01010bb:	68 c1 02 00 00       	push   $0x2c1
f01010c0:	68 bd 52 10 f0       	push   $0xf01052bd
f01010c5:	e8 d6 ef ff ff       	call   f01000a0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01010ca:	a1 40 be 17 f0       	mov    0xf017be40,%eax
f01010cf:	bb 00 00 00 00       	mov    $0x0,%ebx
f01010d4:	eb 05                	jmp    f01010db <mem_init+0x133>
		++nfree;
f01010d6:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f01010d9:	8b 00                	mov    (%eax),%eax
f01010db:	85 c0                	test   %eax,%eax
f01010dd:	75 f7                	jne    f01010d6 <mem_init+0x12e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01010df:	83 ec 0c             	sub    $0xc,%esp
f01010e2:	6a 00                	push   $0x0
f01010e4:	e8 c6 fb ff ff       	call   f0100caf <page_alloc>
f01010e9:	89 c7                	mov    %eax,%edi
f01010eb:	83 c4 10             	add    $0x10,%esp
f01010ee:	85 c0                	test   %eax,%eax
f01010f0:	75 19                	jne    f010110b <mem_init+0x163>
f01010f2:	68 bd 53 10 f0       	push   $0xf01053bd
f01010f7:	68 e3 52 10 f0       	push   $0xf01052e3
f01010fc:	68 c9 02 00 00       	push   $0x2c9
f0101101:	68 bd 52 10 f0       	push   $0xf01052bd
f0101106:	e8 95 ef ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f010110b:	83 ec 0c             	sub    $0xc,%esp
f010110e:	6a 00                	push   $0x0
f0101110:	e8 9a fb ff ff       	call   f0100caf <page_alloc>
f0101115:	89 c6                	mov    %eax,%esi
f0101117:	83 c4 10             	add    $0x10,%esp
f010111a:	85 c0                	test   %eax,%eax
f010111c:	75 19                	jne    f0101137 <mem_init+0x18f>
f010111e:	68 d3 53 10 f0       	push   $0xf01053d3
f0101123:	68 e3 52 10 f0       	push   $0xf01052e3
f0101128:	68 ca 02 00 00       	push   $0x2ca
f010112d:	68 bd 52 10 f0       	push   $0xf01052bd
f0101132:	e8 69 ef ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101137:	83 ec 0c             	sub    $0xc,%esp
f010113a:	6a 00                	push   $0x0
f010113c:	e8 6e fb ff ff       	call   f0100caf <page_alloc>
f0101141:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101144:	83 c4 10             	add    $0x10,%esp
f0101147:	85 c0                	test   %eax,%eax
f0101149:	75 19                	jne    f0101164 <mem_init+0x1bc>
f010114b:	68 e9 53 10 f0       	push   $0xf01053e9
f0101150:	68 e3 52 10 f0       	push   $0xf01052e3
f0101155:	68 cb 02 00 00       	push   $0x2cb
f010115a:	68 bd 52 10 f0       	push   $0xf01052bd
f010115f:	e8 3c ef ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101164:	39 f7                	cmp    %esi,%edi
f0101166:	75 19                	jne    f0101181 <mem_init+0x1d9>
f0101168:	68 ff 53 10 f0       	push   $0xf01053ff
f010116d:	68 e3 52 10 f0       	push   $0xf01052e3
f0101172:	68 ce 02 00 00       	push   $0x2ce
f0101177:	68 bd 52 10 f0       	push   $0xf01052bd
f010117c:	e8 1f ef ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101181:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101184:	39 c6                	cmp    %eax,%esi
f0101186:	74 04                	je     f010118c <mem_init+0x1e4>
f0101188:	39 c7                	cmp    %eax,%edi
f010118a:	75 19                	jne    f01011a5 <mem_init+0x1fd>
f010118c:	68 68 4c 10 f0       	push   $0xf0104c68
f0101191:	68 e3 52 10 f0       	push   $0xf01052e3
f0101196:	68 cf 02 00 00       	push   $0x2cf
f010119b:	68 bd 52 10 f0       	push   $0xf01052bd
f01011a0:	e8 fb ee ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01011a5:	8b 0d 0c cb 17 f0    	mov    0xf017cb0c,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01011ab:	8b 15 04 cb 17 f0    	mov    0xf017cb04,%edx
f01011b1:	c1 e2 0c             	shl    $0xc,%edx
f01011b4:	89 f8                	mov    %edi,%eax
f01011b6:	29 c8                	sub    %ecx,%eax
f01011b8:	c1 f8 03             	sar    $0x3,%eax
f01011bb:	c1 e0 0c             	shl    $0xc,%eax
f01011be:	39 d0                	cmp    %edx,%eax
f01011c0:	72 19                	jb     f01011db <mem_init+0x233>
f01011c2:	68 11 54 10 f0       	push   $0xf0105411
f01011c7:	68 e3 52 10 f0       	push   $0xf01052e3
f01011cc:	68 d0 02 00 00       	push   $0x2d0
f01011d1:	68 bd 52 10 f0       	push   $0xf01052bd
f01011d6:	e8 c5 ee ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f01011db:	89 f0                	mov    %esi,%eax
f01011dd:	29 c8                	sub    %ecx,%eax
f01011df:	c1 f8 03             	sar    $0x3,%eax
f01011e2:	c1 e0 0c             	shl    $0xc,%eax
f01011e5:	39 c2                	cmp    %eax,%edx
f01011e7:	77 19                	ja     f0101202 <mem_init+0x25a>
f01011e9:	68 2e 54 10 f0       	push   $0xf010542e
f01011ee:	68 e3 52 10 f0       	push   $0xf01052e3
f01011f3:	68 d1 02 00 00       	push   $0x2d1
f01011f8:	68 bd 52 10 f0       	push   $0xf01052bd
f01011fd:	e8 9e ee ff ff       	call   f01000a0 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101202:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101205:	29 c8                	sub    %ecx,%eax
f0101207:	c1 f8 03             	sar    $0x3,%eax
f010120a:	c1 e0 0c             	shl    $0xc,%eax
f010120d:	39 c2                	cmp    %eax,%edx
f010120f:	77 19                	ja     f010122a <mem_init+0x282>
f0101211:	68 4b 54 10 f0       	push   $0xf010544b
f0101216:	68 e3 52 10 f0       	push   $0xf01052e3
f010121b:	68 d2 02 00 00       	push   $0x2d2
f0101220:	68 bd 52 10 f0       	push   $0xf01052bd
f0101225:	e8 76 ee ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010122a:	a1 40 be 17 f0       	mov    0xf017be40,%eax
f010122f:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101232:	c7 05 40 be 17 f0 00 	movl   $0x0,0xf017be40
f0101239:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010123c:	83 ec 0c             	sub    $0xc,%esp
f010123f:	6a 00                	push   $0x0
f0101241:	e8 69 fa ff ff       	call   f0100caf <page_alloc>
f0101246:	83 c4 10             	add    $0x10,%esp
f0101249:	85 c0                	test   %eax,%eax
f010124b:	74 19                	je     f0101266 <mem_init+0x2be>
f010124d:	68 68 54 10 f0       	push   $0xf0105468
f0101252:	68 e3 52 10 f0       	push   $0xf01052e3
f0101257:	68 d9 02 00 00       	push   $0x2d9
f010125c:	68 bd 52 10 f0       	push   $0xf01052bd
f0101261:	e8 3a ee ff ff       	call   f01000a0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101266:	83 ec 0c             	sub    $0xc,%esp
f0101269:	57                   	push   %edi
f010126a:	e8 b0 fa ff ff       	call   f0100d1f <page_free>
	page_free(pp1);
f010126f:	89 34 24             	mov    %esi,(%esp)
f0101272:	e8 a8 fa ff ff       	call   f0100d1f <page_free>
	page_free(pp2);
f0101277:	83 c4 04             	add    $0x4,%esp
f010127a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010127d:	e8 9d fa ff ff       	call   f0100d1f <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101282:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101289:	e8 21 fa ff ff       	call   f0100caf <page_alloc>
f010128e:	89 c6                	mov    %eax,%esi
f0101290:	83 c4 10             	add    $0x10,%esp
f0101293:	85 c0                	test   %eax,%eax
f0101295:	75 19                	jne    f01012b0 <mem_init+0x308>
f0101297:	68 bd 53 10 f0       	push   $0xf01053bd
f010129c:	68 e3 52 10 f0       	push   $0xf01052e3
f01012a1:	68 e0 02 00 00       	push   $0x2e0
f01012a6:	68 bd 52 10 f0       	push   $0xf01052bd
f01012ab:	e8 f0 ed ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01012b0:	83 ec 0c             	sub    $0xc,%esp
f01012b3:	6a 00                	push   $0x0
f01012b5:	e8 f5 f9 ff ff       	call   f0100caf <page_alloc>
f01012ba:	89 c7                	mov    %eax,%edi
f01012bc:	83 c4 10             	add    $0x10,%esp
f01012bf:	85 c0                	test   %eax,%eax
f01012c1:	75 19                	jne    f01012dc <mem_init+0x334>
f01012c3:	68 d3 53 10 f0       	push   $0xf01053d3
f01012c8:	68 e3 52 10 f0       	push   $0xf01052e3
f01012cd:	68 e1 02 00 00       	push   $0x2e1
f01012d2:	68 bd 52 10 f0       	push   $0xf01052bd
f01012d7:	e8 c4 ed ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01012dc:	83 ec 0c             	sub    $0xc,%esp
f01012df:	6a 00                	push   $0x0
f01012e1:	e8 c9 f9 ff ff       	call   f0100caf <page_alloc>
f01012e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01012e9:	83 c4 10             	add    $0x10,%esp
f01012ec:	85 c0                	test   %eax,%eax
f01012ee:	75 19                	jne    f0101309 <mem_init+0x361>
f01012f0:	68 e9 53 10 f0       	push   $0xf01053e9
f01012f5:	68 e3 52 10 f0       	push   $0xf01052e3
f01012fa:	68 e2 02 00 00       	push   $0x2e2
f01012ff:	68 bd 52 10 f0       	push   $0xf01052bd
f0101304:	e8 97 ed ff ff       	call   f01000a0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101309:	39 fe                	cmp    %edi,%esi
f010130b:	75 19                	jne    f0101326 <mem_init+0x37e>
f010130d:	68 ff 53 10 f0       	push   $0xf01053ff
f0101312:	68 e3 52 10 f0       	push   $0xf01052e3
f0101317:	68 e4 02 00 00       	push   $0x2e4
f010131c:	68 bd 52 10 f0       	push   $0xf01052bd
f0101321:	e8 7a ed ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101326:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101329:	39 c7                	cmp    %eax,%edi
f010132b:	74 04                	je     f0101331 <mem_init+0x389>
f010132d:	39 c6                	cmp    %eax,%esi
f010132f:	75 19                	jne    f010134a <mem_init+0x3a2>
f0101331:	68 68 4c 10 f0       	push   $0xf0104c68
f0101336:	68 e3 52 10 f0       	push   $0xf01052e3
f010133b:	68 e5 02 00 00       	push   $0x2e5
f0101340:	68 bd 52 10 f0       	push   $0xf01052bd
f0101345:	e8 56 ed ff ff       	call   f01000a0 <_panic>
	assert(!page_alloc(0));
f010134a:	83 ec 0c             	sub    $0xc,%esp
f010134d:	6a 00                	push   $0x0
f010134f:	e8 5b f9 ff ff       	call   f0100caf <page_alloc>
f0101354:	83 c4 10             	add    $0x10,%esp
f0101357:	85 c0                	test   %eax,%eax
f0101359:	74 19                	je     f0101374 <mem_init+0x3cc>
f010135b:	68 68 54 10 f0       	push   $0xf0105468
f0101360:	68 e3 52 10 f0       	push   $0xf01052e3
f0101365:	68 e6 02 00 00       	push   $0x2e6
f010136a:	68 bd 52 10 f0       	push   $0xf01052bd
f010136f:	e8 2c ed ff ff       	call   f01000a0 <_panic>
f0101374:	89 f0                	mov    %esi,%eax
f0101376:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f010137c:	c1 f8 03             	sar    $0x3,%eax
f010137f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101382:	89 c2                	mov    %eax,%edx
f0101384:	c1 ea 0c             	shr    $0xc,%edx
f0101387:	3b 15 04 cb 17 f0    	cmp    0xf017cb04,%edx
f010138d:	72 12                	jb     f01013a1 <mem_init+0x3f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010138f:	50                   	push   %eax
f0101390:	68 dc 4a 10 f0       	push   $0xf0104adc
f0101395:	6a 56                	push   $0x56
f0101397:	68 c9 52 10 f0       	push   $0xf01052c9
f010139c:	e8 ff ec ff ff       	call   f01000a0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01013a1:	83 ec 04             	sub    $0x4,%esp
f01013a4:	68 00 10 00 00       	push   $0x1000
f01013a9:	6a 01                	push   $0x1
f01013ab:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01013b0:	50                   	push   %eax
f01013b1:	e8 f5 2d 00 00       	call   f01041ab <memset>
	page_free(pp0);
f01013b6:	89 34 24             	mov    %esi,(%esp)
f01013b9:	e8 61 f9 ff ff       	call   f0100d1f <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01013be:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01013c5:	e8 e5 f8 ff ff       	call   f0100caf <page_alloc>
f01013ca:	83 c4 10             	add    $0x10,%esp
f01013cd:	85 c0                	test   %eax,%eax
f01013cf:	75 19                	jne    f01013ea <mem_init+0x442>
f01013d1:	68 77 54 10 f0       	push   $0xf0105477
f01013d6:	68 e3 52 10 f0       	push   $0xf01052e3
f01013db:	68 eb 02 00 00       	push   $0x2eb
f01013e0:	68 bd 52 10 f0       	push   $0xf01052bd
f01013e5:	e8 b6 ec ff ff       	call   f01000a0 <_panic>
	assert(pp && pp0 == pp);
f01013ea:	39 c6                	cmp    %eax,%esi
f01013ec:	74 19                	je     f0101407 <mem_init+0x45f>
f01013ee:	68 95 54 10 f0       	push   $0xf0105495
f01013f3:	68 e3 52 10 f0       	push   $0xf01052e3
f01013f8:	68 ec 02 00 00       	push   $0x2ec
f01013fd:	68 bd 52 10 f0       	push   $0xf01052bd
f0101402:	e8 99 ec ff ff       	call   f01000a0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101407:	89 f0                	mov    %esi,%eax
f0101409:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f010140f:	c1 f8 03             	sar    $0x3,%eax
f0101412:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101415:	89 c2                	mov    %eax,%edx
f0101417:	c1 ea 0c             	shr    $0xc,%edx
f010141a:	3b 15 04 cb 17 f0    	cmp    0xf017cb04,%edx
f0101420:	72 12                	jb     f0101434 <mem_init+0x48c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101422:	50                   	push   %eax
f0101423:	68 dc 4a 10 f0       	push   $0xf0104adc
f0101428:	6a 56                	push   $0x56
f010142a:	68 c9 52 10 f0       	push   $0xf01052c9
f010142f:	e8 6c ec ff ff       	call   f01000a0 <_panic>
f0101434:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f010143a:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101440:	80 38 00             	cmpb   $0x0,(%eax)
f0101443:	74 19                	je     f010145e <mem_init+0x4b6>
f0101445:	68 a5 54 10 f0       	push   $0xf01054a5
f010144a:	68 e3 52 10 f0       	push   $0xf01052e3
f010144f:	68 ef 02 00 00       	push   $0x2ef
f0101454:	68 bd 52 10 f0       	push   $0xf01052bd
f0101459:	e8 42 ec ff ff       	call   f01000a0 <_panic>
f010145e:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101461:	39 d0                	cmp    %edx,%eax
f0101463:	75 db                	jne    f0101440 <mem_init+0x498>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101465:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0101468:	a3 40 be 17 f0       	mov    %eax,0xf017be40

	// free the pages we took
	page_free(pp0);
f010146d:	83 ec 0c             	sub    $0xc,%esp
f0101470:	56                   	push   %esi
f0101471:	e8 a9 f8 ff ff       	call   f0100d1f <page_free>
	page_free(pp1);
f0101476:	89 3c 24             	mov    %edi,(%esp)
f0101479:	e8 a1 f8 ff ff       	call   f0100d1f <page_free>
	page_free(pp2);
f010147e:	83 c4 04             	add    $0x4,%esp
f0101481:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101484:	e8 96 f8 ff ff       	call   f0100d1f <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101489:	a1 40 be 17 f0       	mov    0xf017be40,%eax
f010148e:	83 c4 10             	add    $0x10,%esp
f0101491:	eb 05                	jmp    f0101498 <mem_init+0x4f0>
		--nfree;
f0101493:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101496:	8b 00                	mov    (%eax),%eax
f0101498:	85 c0                	test   %eax,%eax
f010149a:	75 f7                	jne    f0101493 <mem_init+0x4eb>
		--nfree;
	assert(nfree == 0);
f010149c:	85 db                	test   %ebx,%ebx
f010149e:	74 19                	je     f01014b9 <mem_init+0x511>
f01014a0:	68 af 54 10 f0       	push   $0xf01054af
f01014a5:	68 e3 52 10 f0       	push   $0xf01052e3
f01014aa:	68 fc 02 00 00       	push   $0x2fc
f01014af:	68 bd 52 10 f0       	push   $0xf01052bd
f01014b4:	e8 e7 eb ff ff       	call   f01000a0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01014b9:	83 ec 0c             	sub    $0xc,%esp
f01014bc:	68 88 4c 10 f0       	push   $0xf0104c88
f01014c1:	e8 86 19 00 00       	call   f0102e4c <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014c6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014cd:	e8 dd f7 ff ff       	call   f0100caf <page_alloc>
f01014d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01014d5:	83 c4 10             	add    $0x10,%esp
f01014d8:	85 c0                	test   %eax,%eax
f01014da:	75 19                	jne    f01014f5 <mem_init+0x54d>
f01014dc:	68 bd 53 10 f0       	push   $0xf01053bd
f01014e1:	68 e3 52 10 f0       	push   $0xf01052e3
f01014e6:	68 5a 03 00 00       	push   $0x35a
f01014eb:	68 bd 52 10 f0       	push   $0xf01052bd
f01014f0:	e8 ab eb ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01014f5:	83 ec 0c             	sub    $0xc,%esp
f01014f8:	6a 00                	push   $0x0
f01014fa:	e8 b0 f7 ff ff       	call   f0100caf <page_alloc>
f01014ff:	89 c3                	mov    %eax,%ebx
f0101501:	83 c4 10             	add    $0x10,%esp
f0101504:	85 c0                	test   %eax,%eax
f0101506:	75 19                	jne    f0101521 <mem_init+0x579>
f0101508:	68 d3 53 10 f0       	push   $0xf01053d3
f010150d:	68 e3 52 10 f0       	push   $0xf01052e3
f0101512:	68 5b 03 00 00       	push   $0x35b
f0101517:	68 bd 52 10 f0       	push   $0xf01052bd
f010151c:	e8 7f eb ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101521:	83 ec 0c             	sub    $0xc,%esp
f0101524:	6a 00                	push   $0x0
f0101526:	e8 84 f7 ff ff       	call   f0100caf <page_alloc>
f010152b:	89 c6                	mov    %eax,%esi
f010152d:	83 c4 10             	add    $0x10,%esp
f0101530:	85 c0                	test   %eax,%eax
f0101532:	75 19                	jne    f010154d <mem_init+0x5a5>
f0101534:	68 e9 53 10 f0       	push   $0xf01053e9
f0101539:	68 e3 52 10 f0       	push   $0xf01052e3
f010153e:	68 5c 03 00 00       	push   $0x35c
f0101543:	68 bd 52 10 f0       	push   $0xf01052bd
f0101548:	e8 53 eb ff ff       	call   f01000a0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010154d:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101550:	75 19                	jne    f010156b <mem_init+0x5c3>
f0101552:	68 ff 53 10 f0       	push   $0xf01053ff
f0101557:	68 e3 52 10 f0       	push   $0xf01052e3
f010155c:	68 5f 03 00 00       	push   $0x35f
f0101561:	68 bd 52 10 f0       	push   $0xf01052bd
f0101566:	e8 35 eb ff ff       	call   f01000a0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010156b:	39 c3                	cmp    %eax,%ebx
f010156d:	74 05                	je     f0101574 <mem_init+0x5cc>
f010156f:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f0101572:	75 19                	jne    f010158d <mem_init+0x5e5>
f0101574:	68 68 4c 10 f0       	push   $0xf0104c68
f0101579:	68 e3 52 10 f0       	push   $0xf01052e3
f010157e:	68 60 03 00 00       	push   $0x360
f0101583:	68 bd 52 10 f0       	push   $0xf01052bd
f0101588:	e8 13 eb ff ff       	call   f01000a0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010158d:	a1 40 be 17 f0       	mov    0xf017be40,%eax
f0101592:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101595:	c7 05 40 be 17 f0 00 	movl   $0x0,0xf017be40
f010159c:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f010159f:	83 ec 0c             	sub    $0xc,%esp
f01015a2:	6a 00                	push   $0x0
f01015a4:	e8 06 f7 ff ff       	call   f0100caf <page_alloc>
f01015a9:	83 c4 10             	add    $0x10,%esp
f01015ac:	85 c0                	test   %eax,%eax
f01015ae:	74 19                	je     f01015c9 <mem_init+0x621>
f01015b0:	68 68 54 10 f0       	push   $0xf0105468
f01015b5:	68 e3 52 10 f0       	push   $0xf01052e3
f01015ba:	68 67 03 00 00       	push   $0x367
f01015bf:	68 bd 52 10 f0       	push   $0xf01052bd
f01015c4:	e8 d7 ea ff ff       	call   f01000a0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01015c9:	83 ec 04             	sub    $0x4,%esp
f01015cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01015cf:	50                   	push   %eax
f01015d0:	6a 00                	push   $0x0
f01015d2:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f01015d8:	e8 be f8 ff ff       	call   f0100e9b <page_lookup>
f01015dd:	83 c4 10             	add    $0x10,%esp
f01015e0:	85 c0                	test   %eax,%eax
f01015e2:	74 19                	je     f01015fd <mem_init+0x655>
f01015e4:	68 a8 4c 10 f0       	push   $0xf0104ca8
f01015e9:	68 e3 52 10 f0       	push   $0xf01052e3
f01015ee:	68 6a 03 00 00       	push   $0x36a
f01015f3:	68 bd 52 10 f0       	push   $0xf01052bd
f01015f8:	e8 a3 ea ff ff       	call   f01000a0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f01015fd:	6a 02                	push   $0x2
f01015ff:	6a 00                	push   $0x0
f0101601:	53                   	push   %ebx
f0101602:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101608:	e8 35 f9 ff ff       	call   f0100f42 <page_insert>
f010160d:	83 c4 10             	add    $0x10,%esp
f0101610:	85 c0                	test   %eax,%eax
f0101612:	78 19                	js     f010162d <mem_init+0x685>
f0101614:	68 e0 4c 10 f0       	push   $0xf0104ce0
f0101619:	68 e3 52 10 f0       	push   $0xf01052e3
f010161e:	68 6d 03 00 00       	push   $0x36d
f0101623:	68 bd 52 10 f0       	push   $0xf01052bd
f0101628:	e8 73 ea ff ff       	call   f01000a0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010162d:	83 ec 0c             	sub    $0xc,%esp
f0101630:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101633:	e8 e7 f6 ff ff       	call   f0100d1f <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101638:	6a 02                	push   $0x2
f010163a:	6a 00                	push   $0x0
f010163c:	53                   	push   %ebx
f010163d:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101643:	e8 fa f8 ff ff       	call   f0100f42 <page_insert>
f0101648:	83 c4 20             	add    $0x20,%esp
f010164b:	85 c0                	test   %eax,%eax
f010164d:	74 19                	je     f0101668 <mem_init+0x6c0>
f010164f:	68 10 4d 10 f0       	push   $0xf0104d10
f0101654:	68 e3 52 10 f0       	push   $0xf01052e3
f0101659:	68 71 03 00 00       	push   $0x371
f010165e:	68 bd 52 10 f0       	push   $0xf01052bd
f0101663:	e8 38 ea ff ff       	call   f01000a0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101668:	8b 3d 08 cb 17 f0    	mov    0xf017cb08,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010166e:	a1 0c cb 17 f0       	mov    0xf017cb0c,%eax
f0101673:	89 c1                	mov    %eax,%ecx
f0101675:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101678:	8b 17                	mov    (%edi),%edx
f010167a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101680:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101683:	29 c8                	sub    %ecx,%eax
f0101685:	c1 f8 03             	sar    $0x3,%eax
f0101688:	c1 e0 0c             	shl    $0xc,%eax
f010168b:	39 c2                	cmp    %eax,%edx
f010168d:	74 19                	je     f01016a8 <mem_init+0x700>
f010168f:	68 40 4d 10 f0       	push   $0xf0104d40
f0101694:	68 e3 52 10 f0       	push   $0xf01052e3
f0101699:	68 72 03 00 00       	push   $0x372
f010169e:	68 bd 52 10 f0       	push   $0xf01052bd
f01016a3:	e8 f8 e9 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01016a8:	ba 00 00 00 00       	mov    $0x0,%edx
f01016ad:	89 f8                	mov    %edi,%eax
f01016af:	e8 3c f2 ff ff       	call   f01008f0 <check_va2pa>
f01016b4:	89 da                	mov    %ebx,%edx
f01016b6:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01016b9:	c1 fa 03             	sar    $0x3,%edx
f01016bc:	c1 e2 0c             	shl    $0xc,%edx
f01016bf:	39 d0                	cmp    %edx,%eax
f01016c1:	74 19                	je     f01016dc <mem_init+0x734>
f01016c3:	68 68 4d 10 f0       	push   $0xf0104d68
f01016c8:	68 e3 52 10 f0       	push   $0xf01052e3
f01016cd:	68 73 03 00 00       	push   $0x373
f01016d2:	68 bd 52 10 f0       	push   $0xf01052bd
f01016d7:	e8 c4 e9 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f01016dc:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01016e1:	74 19                	je     f01016fc <mem_init+0x754>
f01016e3:	68 ba 54 10 f0       	push   $0xf01054ba
f01016e8:	68 e3 52 10 f0       	push   $0xf01052e3
f01016ed:	68 74 03 00 00       	push   $0x374
f01016f2:	68 bd 52 10 f0       	push   $0xf01052bd
f01016f7:	e8 a4 e9 ff ff       	call   f01000a0 <_panic>
	assert(pp0->pp_ref == 1);
f01016fc:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01016ff:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101704:	74 19                	je     f010171f <mem_init+0x777>
f0101706:	68 cb 54 10 f0       	push   $0xf01054cb
f010170b:	68 e3 52 10 f0       	push   $0xf01052e3
f0101710:	68 75 03 00 00       	push   $0x375
f0101715:	68 bd 52 10 f0       	push   $0xf01052bd
f010171a:	e8 81 e9 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010171f:	6a 02                	push   $0x2
f0101721:	68 00 10 00 00       	push   $0x1000
f0101726:	56                   	push   %esi
f0101727:	57                   	push   %edi
f0101728:	e8 15 f8 ff ff       	call   f0100f42 <page_insert>
f010172d:	83 c4 10             	add    $0x10,%esp
f0101730:	85 c0                	test   %eax,%eax
f0101732:	74 19                	je     f010174d <mem_init+0x7a5>
f0101734:	68 98 4d 10 f0       	push   $0xf0104d98
f0101739:	68 e3 52 10 f0       	push   $0xf01052e3
f010173e:	68 78 03 00 00       	push   $0x378
f0101743:	68 bd 52 10 f0       	push   $0xf01052bd
f0101748:	e8 53 e9 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010174d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101752:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
f0101757:	e8 94 f1 ff ff       	call   f01008f0 <check_va2pa>
f010175c:	89 f2                	mov    %esi,%edx
f010175e:	2b 15 0c cb 17 f0    	sub    0xf017cb0c,%edx
f0101764:	c1 fa 03             	sar    $0x3,%edx
f0101767:	c1 e2 0c             	shl    $0xc,%edx
f010176a:	39 d0                	cmp    %edx,%eax
f010176c:	74 19                	je     f0101787 <mem_init+0x7df>
f010176e:	68 d4 4d 10 f0       	push   $0xf0104dd4
f0101773:	68 e3 52 10 f0       	push   $0xf01052e3
f0101778:	68 79 03 00 00       	push   $0x379
f010177d:	68 bd 52 10 f0       	push   $0xf01052bd
f0101782:	e8 19 e9 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101787:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010178c:	74 19                	je     f01017a7 <mem_init+0x7ff>
f010178e:	68 dc 54 10 f0       	push   $0xf01054dc
f0101793:	68 e3 52 10 f0       	push   $0xf01052e3
f0101798:	68 7a 03 00 00       	push   $0x37a
f010179d:	68 bd 52 10 f0       	push   $0xf01052bd
f01017a2:	e8 f9 e8 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01017a7:	83 ec 0c             	sub    $0xc,%esp
f01017aa:	6a 00                	push   $0x0
f01017ac:	e8 fe f4 ff ff       	call   f0100caf <page_alloc>
f01017b1:	83 c4 10             	add    $0x10,%esp
f01017b4:	85 c0                	test   %eax,%eax
f01017b6:	74 19                	je     f01017d1 <mem_init+0x829>
f01017b8:	68 68 54 10 f0       	push   $0xf0105468
f01017bd:	68 e3 52 10 f0       	push   $0xf01052e3
f01017c2:	68 7d 03 00 00       	push   $0x37d
f01017c7:	68 bd 52 10 f0       	push   $0xf01052bd
f01017cc:	e8 cf e8 ff ff       	call   f01000a0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01017d1:	6a 02                	push   $0x2
f01017d3:	68 00 10 00 00       	push   $0x1000
f01017d8:	56                   	push   %esi
f01017d9:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f01017df:	e8 5e f7 ff ff       	call   f0100f42 <page_insert>
f01017e4:	83 c4 10             	add    $0x10,%esp
f01017e7:	85 c0                	test   %eax,%eax
f01017e9:	74 19                	je     f0101804 <mem_init+0x85c>
f01017eb:	68 98 4d 10 f0       	push   $0xf0104d98
f01017f0:	68 e3 52 10 f0       	push   $0xf01052e3
f01017f5:	68 80 03 00 00       	push   $0x380
f01017fa:	68 bd 52 10 f0       	push   $0xf01052bd
f01017ff:	e8 9c e8 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101804:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101809:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
f010180e:	e8 dd f0 ff ff       	call   f01008f0 <check_va2pa>
f0101813:	89 f2                	mov    %esi,%edx
f0101815:	2b 15 0c cb 17 f0    	sub    0xf017cb0c,%edx
f010181b:	c1 fa 03             	sar    $0x3,%edx
f010181e:	c1 e2 0c             	shl    $0xc,%edx
f0101821:	39 d0                	cmp    %edx,%eax
f0101823:	74 19                	je     f010183e <mem_init+0x896>
f0101825:	68 d4 4d 10 f0       	push   $0xf0104dd4
f010182a:	68 e3 52 10 f0       	push   $0xf01052e3
f010182f:	68 81 03 00 00       	push   $0x381
f0101834:	68 bd 52 10 f0       	push   $0xf01052bd
f0101839:	e8 62 e8 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f010183e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101843:	74 19                	je     f010185e <mem_init+0x8b6>
f0101845:	68 dc 54 10 f0       	push   $0xf01054dc
f010184a:	68 e3 52 10 f0       	push   $0xf01052e3
f010184f:	68 82 03 00 00       	push   $0x382
f0101854:	68 bd 52 10 f0       	push   $0xf01052bd
f0101859:	e8 42 e8 ff ff       	call   f01000a0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f010185e:	83 ec 0c             	sub    $0xc,%esp
f0101861:	6a 00                	push   $0x0
f0101863:	e8 47 f4 ff ff       	call   f0100caf <page_alloc>
f0101868:	83 c4 10             	add    $0x10,%esp
f010186b:	85 c0                	test   %eax,%eax
f010186d:	74 19                	je     f0101888 <mem_init+0x8e0>
f010186f:	68 68 54 10 f0       	push   $0xf0105468
f0101874:	68 e3 52 10 f0       	push   $0xf01052e3
f0101879:	68 86 03 00 00       	push   $0x386
f010187e:	68 bd 52 10 f0       	push   $0xf01052bd
f0101883:	e8 18 e8 ff ff       	call   f01000a0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101888:	8b 15 08 cb 17 f0    	mov    0xf017cb08,%edx
f010188e:	8b 02                	mov    (%edx),%eax
f0101890:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101895:	89 c1                	mov    %eax,%ecx
f0101897:	c1 e9 0c             	shr    $0xc,%ecx
f010189a:	3b 0d 04 cb 17 f0    	cmp    0xf017cb04,%ecx
f01018a0:	72 15                	jb     f01018b7 <mem_init+0x90f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018a2:	50                   	push   %eax
f01018a3:	68 dc 4a 10 f0       	push   $0xf0104adc
f01018a8:	68 89 03 00 00       	push   $0x389
f01018ad:	68 bd 52 10 f0       	push   $0xf01052bd
f01018b2:	e8 e9 e7 ff ff       	call   f01000a0 <_panic>
f01018b7:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01018bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f01018bf:	83 ec 04             	sub    $0x4,%esp
f01018c2:	6a 00                	push   $0x0
f01018c4:	68 00 10 00 00       	push   $0x1000
f01018c9:	52                   	push   %edx
f01018ca:	e8 ea f4 ff ff       	call   f0100db9 <pgdir_walk>
f01018cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01018d2:	8d 57 04             	lea    0x4(%edi),%edx
f01018d5:	83 c4 10             	add    $0x10,%esp
f01018d8:	39 d0                	cmp    %edx,%eax
f01018da:	74 19                	je     f01018f5 <mem_init+0x94d>
f01018dc:	68 04 4e 10 f0       	push   $0xf0104e04
f01018e1:	68 e3 52 10 f0       	push   $0xf01052e3
f01018e6:	68 8a 03 00 00       	push   $0x38a
f01018eb:	68 bd 52 10 f0       	push   $0xf01052bd
f01018f0:	e8 ab e7 ff ff       	call   f01000a0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01018f5:	6a 06                	push   $0x6
f01018f7:	68 00 10 00 00       	push   $0x1000
f01018fc:	56                   	push   %esi
f01018fd:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101903:	e8 3a f6 ff ff       	call   f0100f42 <page_insert>
f0101908:	83 c4 10             	add    $0x10,%esp
f010190b:	85 c0                	test   %eax,%eax
f010190d:	74 19                	je     f0101928 <mem_init+0x980>
f010190f:	68 44 4e 10 f0       	push   $0xf0104e44
f0101914:	68 e3 52 10 f0       	push   $0xf01052e3
f0101919:	68 8d 03 00 00       	push   $0x38d
f010191e:	68 bd 52 10 f0       	push   $0xf01052bd
f0101923:	e8 78 e7 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101928:	8b 3d 08 cb 17 f0    	mov    0xf017cb08,%edi
f010192e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101933:	89 f8                	mov    %edi,%eax
f0101935:	e8 b6 ef ff ff       	call   f01008f0 <check_va2pa>
f010193a:	89 f2                	mov    %esi,%edx
f010193c:	2b 15 0c cb 17 f0    	sub    0xf017cb0c,%edx
f0101942:	c1 fa 03             	sar    $0x3,%edx
f0101945:	c1 e2 0c             	shl    $0xc,%edx
f0101948:	39 d0                	cmp    %edx,%eax
f010194a:	74 19                	je     f0101965 <mem_init+0x9bd>
f010194c:	68 d4 4d 10 f0       	push   $0xf0104dd4
f0101951:	68 e3 52 10 f0       	push   $0xf01052e3
f0101956:	68 8e 03 00 00       	push   $0x38e
f010195b:	68 bd 52 10 f0       	push   $0xf01052bd
f0101960:	e8 3b e7 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0101965:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010196a:	74 19                	je     f0101985 <mem_init+0x9dd>
f010196c:	68 dc 54 10 f0       	push   $0xf01054dc
f0101971:	68 e3 52 10 f0       	push   $0xf01052e3
f0101976:	68 8f 03 00 00       	push   $0x38f
f010197b:	68 bd 52 10 f0       	push   $0xf01052bd
f0101980:	e8 1b e7 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101985:	83 ec 04             	sub    $0x4,%esp
f0101988:	6a 00                	push   $0x0
f010198a:	68 00 10 00 00       	push   $0x1000
f010198f:	57                   	push   %edi
f0101990:	e8 24 f4 ff ff       	call   f0100db9 <pgdir_walk>
f0101995:	83 c4 10             	add    $0x10,%esp
f0101998:	f6 00 04             	testb  $0x4,(%eax)
f010199b:	75 19                	jne    f01019b6 <mem_init+0xa0e>
f010199d:	68 84 4e 10 f0       	push   $0xf0104e84
f01019a2:	68 e3 52 10 f0       	push   $0xf01052e3
f01019a7:	68 90 03 00 00       	push   $0x390
f01019ac:	68 bd 52 10 f0       	push   $0xf01052bd
f01019b1:	e8 ea e6 ff ff       	call   f01000a0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01019b6:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
f01019bb:	f6 00 04             	testb  $0x4,(%eax)
f01019be:	75 19                	jne    f01019d9 <mem_init+0xa31>
f01019c0:	68 ed 54 10 f0       	push   $0xf01054ed
f01019c5:	68 e3 52 10 f0       	push   $0xf01052e3
f01019ca:	68 91 03 00 00       	push   $0x391
f01019cf:	68 bd 52 10 f0       	push   $0xf01052bd
f01019d4:	e8 c7 e6 ff ff       	call   f01000a0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f01019d9:	6a 02                	push   $0x2
f01019db:	68 00 10 00 00       	push   $0x1000
f01019e0:	56                   	push   %esi
f01019e1:	50                   	push   %eax
f01019e2:	e8 5b f5 ff ff       	call   f0100f42 <page_insert>
f01019e7:	83 c4 10             	add    $0x10,%esp
f01019ea:	85 c0                	test   %eax,%eax
f01019ec:	74 19                	je     f0101a07 <mem_init+0xa5f>
f01019ee:	68 98 4d 10 f0       	push   $0xf0104d98
f01019f3:	68 e3 52 10 f0       	push   $0xf01052e3
f01019f8:	68 94 03 00 00       	push   $0x394
f01019fd:	68 bd 52 10 f0       	push   $0xf01052bd
f0101a02:	e8 99 e6 ff ff       	call   f01000a0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101a07:	83 ec 04             	sub    $0x4,%esp
f0101a0a:	6a 00                	push   $0x0
f0101a0c:	68 00 10 00 00       	push   $0x1000
f0101a11:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101a17:	e8 9d f3 ff ff       	call   f0100db9 <pgdir_walk>
f0101a1c:	83 c4 10             	add    $0x10,%esp
f0101a1f:	f6 00 02             	testb  $0x2,(%eax)
f0101a22:	75 19                	jne    f0101a3d <mem_init+0xa95>
f0101a24:	68 b8 4e 10 f0       	push   $0xf0104eb8
f0101a29:	68 e3 52 10 f0       	push   $0xf01052e3
f0101a2e:	68 95 03 00 00       	push   $0x395
f0101a33:	68 bd 52 10 f0       	push   $0xf01052bd
f0101a38:	e8 63 e6 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101a3d:	83 ec 04             	sub    $0x4,%esp
f0101a40:	6a 00                	push   $0x0
f0101a42:	68 00 10 00 00       	push   $0x1000
f0101a47:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101a4d:	e8 67 f3 ff ff       	call   f0100db9 <pgdir_walk>
f0101a52:	83 c4 10             	add    $0x10,%esp
f0101a55:	f6 00 04             	testb  $0x4,(%eax)
f0101a58:	74 19                	je     f0101a73 <mem_init+0xacb>
f0101a5a:	68 ec 4e 10 f0       	push   $0xf0104eec
f0101a5f:	68 e3 52 10 f0       	push   $0xf01052e3
f0101a64:	68 96 03 00 00       	push   $0x396
f0101a69:	68 bd 52 10 f0       	push   $0xf01052bd
f0101a6e:	e8 2d e6 ff ff       	call   f01000a0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101a73:	6a 02                	push   $0x2
f0101a75:	68 00 00 40 00       	push   $0x400000
f0101a7a:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101a7d:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101a83:	e8 ba f4 ff ff       	call   f0100f42 <page_insert>
f0101a88:	83 c4 10             	add    $0x10,%esp
f0101a8b:	85 c0                	test   %eax,%eax
f0101a8d:	78 19                	js     f0101aa8 <mem_init+0xb00>
f0101a8f:	68 24 4f 10 f0       	push   $0xf0104f24
f0101a94:	68 e3 52 10 f0       	push   $0xf01052e3
f0101a99:	68 99 03 00 00       	push   $0x399
f0101a9e:	68 bd 52 10 f0       	push   $0xf01052bd
f0101aa3:	e8 f8 e5 ff ff       	call   f01000a0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101aa8:	6a 02                	push   $0x2
f0101aaa:	68 00 10 00 00       	push   $0x1000
f0101aaf:	53                   	push   %ebx
f0101ab0:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101ab6:	e8 87 f4 ff ff       	call   f0100f42 <page_insert>
f0101abb:	83 c4 10             	add    $0x10,%esp
f0101abe:	85 c0                	test   %eax,%eax
f0101ac0:	74 19                	je     f0101adb <mem_init+0xb33>
f0101ac2:	68 5c 4f 10 f0       	push   $0xf0104f5c
f0101ac7:	68 e3 52 10 f0       	push   $0xf01052e3
f0101acc:	68 9c 03 00 00       	push   $0x39c
f0101ad1:	68 bd 52 10 f0       	push   $0xf01052bd
f0101ad6:	e8 c5 e5 ff ff       	call   f01000a0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101adb:	83 ec 04             	sub    $0x4,%esp
f0101ade:	6a 00                	push   $0x0
f0101ae0:	68 00 10 00 00       	push   $0x1000
f0101ae5:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101aeb:	e8 c9 f2 ff ff       	call   f0100db9 <pgdir_walk>
f0101af0:	83 c4 10             	add    $0x10,%esp
f0101af3:	f6 00 04             	testb  $0x4,(%eax)
f0101af6:	74 19                	je     f0101b11 <mem_init+0xb69>
f0101af8:	68 ec 4e 10 f0       	push   $0xf0104eec
f0101afd:	68 e3 52 10 f0       	push   $0xf01052e3
f0101b02:	68 9d 03 00 00       	push   $0x39d
f0101b07:	68 bd 52 10 f0       	push   $0xf01052bd
f0101b0c:	e8 8f e5 ff ff       	call   f01000a0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101b11:	8b 3d 08 cb 17 f0    	mov    0xf017cb08,%edi
f0101b17:	ba 00 00 00 00       	mov    $0x0,%edx
f0101b1c:	89 f8                	mov    %edi,%eax
f0101b1e:	e8 cd ed ff ff       	call   f01008f0 <check_va2pa>
f0101b23:	89 c1                	mov    %eax,%ecx
f0101b25:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101b28:	89 d8                	mov    %ebx,%eax
f0101b2a:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f0101b30:	c1 f8 03             	sar    $0x3,%eax
f0101b33:	c1 e0 0c             	shl    $0xc,%eax
f0101b36:	39 c1                	cmp    %eax,%ecx
f0101b38:	74 19                	je     f0101b53 <mem_init+0xbab>
f0101b3a:	68 98 4f 10 f0       	push   $0xf0104f98
f0101b3f:	68 e3 52 10 f0       	push   $0xf01052e3
f0101b44:	68 a0 03 00 00       	push   $0x3a0
f0101b49:	68 bd 52 10 f0       	push   $0xf01052bd
f0101b4e:	e8 4d e5 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101b53:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b58:	89 f8                	mov    %edi,%eax
f0101b5a:	e8 91 ed ff ff       	call   f01008f0 <check_va2pa>
f0101b5f:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101b62:	74 19                	je     f0101b7d <mem_init+0xbd5>
f0101b64:	68 c4 4f 10 f0       	push   $0xf0104fc4
f0101b69:	68 e3 52 10 f0       	push   $0xf01052e3
f0101b6e:	68 a1 03 00 00       	push   $0x3a1
f0101b73:	68 bd 52 10 f0       	push   $0xf01052bd
f0101b78:	e8 23 e5 ff ff       	call   f01000a0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101b7d:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101b82:	74 19                	je     f0101b9d <mem_init+0xbf5>
f0101b84:	68 03 55 10 f0       	push   $0xf0105503
f0101b89:	68 e3 52 10 f0       	push   $0xf01052e3
f0101b8e:	68 a3 03 00 00       	push   $0x3a3
f0101b93:	68 bd 52 10 f0       	push   $0xf01052bd
f0101b98:	e8 03 e5 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101b9d:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ba2:	74 19                	je     f0101bbd <mem_init+0xc15>
f0101ba4:	68 14 55 10 f0       	push   $0xf0105514
f0101ba9:	68 e3 52 10 f0       	push   $0xf01052e3
f0101bae:	68 a4 03 00 00       	push   $0x3a4
f0101bb3:	68 bd 52 10 f0       	push   $0xf01052bd
f0101bb8:	e8 e3 e4 ff ff       	call   f01000a0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101bbd:	83 ec 0c             	sub    $0xc,%esp
f0101bc0:	6a 00                	push   $0x0
f0101bc2:	e8 e8 f0 ff ff       	call   f0100caf <page_alloc>
f0101bc7:	83 c4 10             	add    $0x10,%esp
f0101bca:	85 c0                	test   %eax,%eax
f0101bcc:	74 04                	je     f0101bd2 <mem_init+0xc2a>
f0101bce:	39 c6                	cmp    %eax,%esi
f0101bd0:	74 19                	je     f0101beb <mem_init+0xc43>
f0101bd2:	68 f4 4f 10 f0       	push   $0xf0104ff4
f0101bd7:	68 e3 52 10 f0       	push   $0xf01052e3
f0101bdc:	68 a7 03 00 00       	push   $0x3a7
f0101be1:	68 bd 52 10 f0       	push   $0xf01052bd
f0101be6:	e8 b5 e4 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101beb:	83 ec 08             	sub    $0x8,%esp
f0101bee:	6a 00                	push   $0x0
f0101bf0:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101bf6:	e8 05 f3 ff ff       	call   f0100f00 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101bfb:	8b 3d 08 cb 17 f0    	mov    0xf017cb08,%edi
f0101c01:	ba 00 00 00 00       	mov    $0x0,%edx
f0101c06:	89 f8                	mov    %edi,%eax
f0101c08:	e8 e3 ec ff ff       	call   f01008f0 <check_va2pa>
f0101c0d:	83 c4 10             	add    $0x10,%esp
f0101c10:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101c13:	74 19                	je     f0101c2e <mem_init+0xc86>
f0101c15:	68 18 50 10 f0       	push   $0xf0105018
f0101c1a:	68 e3 52 10 f0       	push   $0xf01052e3
f0101c1f:	68 ab 03 00 00       	push   $0x3ab
f0101c24:	68 bd 52 10 f0       	push   $0xf01052bd
f0101c29:	e8 72 e4 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101c2e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101c33:	89 f8                	mov    %edi,%eax
f0101c35:	e8 b6 ec ff ff       	call   f01008f0 <check_va2pa>
f0101c3a:	89 da                	mov    %ebx,%edx
f0101c3c:	2b 15 0c cb 17 f0    	sub    0xf017cb0c,%edx
f0101c42:	c1 fa 03             	sar    $0x3,%edx
f0101c45:	c1 e2 0c             	shl    $0xc,%edx
f0101c48:	39 d0                	cmp    %edx,%eax
f0101c4a:	74 19                	je     f0101c65 <mem_init+0xcbd>
f0101c4c:	68 c4 4f 10 f0       	push   $0xf0104fc4
f0101c51:	68 e3 52 10 f0       	push   $0xf01052e3
f0101c56:	68 ac 03 00 00       	push   $0x3ac
f0101c5b:	68 bd 52 10 f0       	push   $0xf01052bd
f0101c60:	e8 3b e4 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 1);
f0101c65:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101c6a:	74 19                	je     f0101c85 <mem_init+0xcdd>
f0101c6c:	68 ba 54 10 f0       	push   $0xf01054ba
f0101c71:	68 e3 52 10 f0       	push   $0xf01052e3
f0101c76:	68 ad 03 00 00       	push   $0x3ad
f0101c7b:	68 bd 52 10 f0       	push   $0xf01052bd
f0101c80:	e8 1b e4 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101c85:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101c8a:	74 19                	je     f0101ca5 <mem_init+0xcfd>
f0101c8c:	68 14 55 10 f0       	push   $0xf0105514
f0101c91:	68 e3 52 10 f0       	push   $0xf01052e3
f0101c96:	68 ae 03 00 00       	push   $0x3ae
f0101c9b:	68 bd 52 10 f0       	push   $0xf01052bd
f0101ca0:	e8 fb e3 ff ff       	call   f01000a0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101ca5:	6a 00                	push   $0x0
f0101ca7:	68 00 10 00 00       	push   $0x1000
f0101cac:	53                   	push   %ebx
f0101cad:	57                   	push   %edi
f0101cae:	e8 8f f2 ff ff       	call   f0100f42 <page_insert>
f0101cb3:	83 c4 10             	add    $0x10,%esp
f0101cb6:	85 c0                	test   %eax,%eax
f0101cb8:	74 19                	je     f0101cd3 <mem_init+0xd2b>
f0101cba:	68 3c 50 10 f0       	push   $0xf010503c
f0101cbf:	68 e3 52 10 f0       	push   $0xf01052e3
f0101cc4:	68 b1 03 00 00       	push   $0x3b1
f0101cc9:	68 bd 52 10 f0       	push   $0xf01052bd
f0101cce:	e8 cd e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref);
f0101cd3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101cd8:	75 19                	jne    f0101cf3 <mem_init+0xd4b>
f0101cda:	68 25 55 10 f0       	push   $0xf0105525
f0101cdf:	68 e3 52 10 f0       	push   $0xf01052e3
f0101ce4:	68 b2 03 00 00       	push   $0x3b2
f0101ce9:	68 bd 52 10 f0       	push   $0xf01052bd
f0101cee:	e8 ad e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_link == NULL);
f0101cf3:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101cf6:	74 19                	je     f0101d11 <mem_init+0xd69>
f0101cf8:	68 31 55 10 f0       	push   $0xf0105531
f0101cfd:	68 e3 52 10 f0       	push   $0xf01052e3
f0101d02:	68 b3 03 00 00       	push   $0x3b3
f0101d07:	68 bd 52 10 f0       	push   $0xf01052bd
f0101d0c:	e8 8f e3 ff ff       	call   f01000a0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101d11:	83 ec 08             	sub    $0x8,%esp
f0101d14:	68 00 10 00 00       	push   $0x1000
f0101d19:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101d1f:	e8 dc f1 ff ff       	call   f0100f00 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101d24:	8b 3d 08 cb 17 f0    	mov    0xf017cb08,%edi
f0101d2a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d2f:	89 f8                	mov    %edi,%eax
f0101d31:	e8 ba eb ff ff       	call   f01008f0 <check_va2pa>
f0101d36:	83 c4 10             	add    $0x10,%esp
f0101d39:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d3c:	74 19                	je     f0101d57 <mem_init+0xdaf>
f0101d3e:	68 18 50 10 f0       	push   $0xf0105018
f0101d43:	68 e3 52 10 f0       	push   $0xf01052e3
f0101d48:	68 b7 03 00 00       	push   $0x3b7
f0101d4d:	68 bd 52 10 f0       	push   $0xf01052bd
f0101d52:	e8 49 e3 ff ff       	call   f01000a0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101d57:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d5c:	89 f8                	mov    %edi,%eax
f0101d5e:	e8 8d eb ff ff       	call   f01008f0 <check_va2pa>
f0101d63:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101d66:	74 19                	je     f0101d81 <mem_init+0xdd9>
f0101d68:	68 74 50 10 f0       	push   $0xf0105074
f0101d6d:	68 e3 52 10 f0       	push   $0xf01052e3
f0101d72:	68 b8 03 00 00       	push   $0x3b8
f0101d77:	68 bd 52 10 f0       	push   $0xf01052bd
f0101d7c:	e8 1f e3 ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0101d81:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101d86:	74 19                	je     f0101da1 <mem_init+0xdf9>
f0101d88:	68 46 55 10 f0       	push   $0xf0105546
f0101d8d:	68 e3 52 10 f0       	push   $0xf01052e3
f0101d92:	68 b9 03 00 00       	push   $0x3b9
f0101d97:	68 bd 52 10 f0       	push   $0xf01052bd
f0101d9c:	e8 ff e2 ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 0);
f0101da1:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101da6:	74 19                	je     f0101dc1 <mem_init+0xe19>
f0101da8:	68 14 55 10 f0       	push   $0xf0105514
f0101dad:	68 e3 52 10 f0       	push   $0xf01052e3
f0101db2:	68 ba 03 00 00       	push   $0x3ba
f0101db7:	68 bd 52 10 f0       	push   $0xf01052bd
f0101dbc:	e8 df e2 ff ff       	call   f01000a0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101dc1:	83 ec 0c             	sub    $0xc,%esp
f0101dc4:	6a 00                	push   $0x0
f0101dc6:	e8 e4 ee ff ff       	call   f0100caf <page_alloc>
f0101dcb:	83 c4 10             	add    $0x10,%esp
f0101dce:	39 c3                	cmp    %eax,%ebx
f0101dd0:	75 04                	jne    f0101dd6 <mem_init+0xe2e>
f0101dd2:	85 c0                	test   %eax,%eax
f0101dd4:	75 19                	jne    f0101def <mem_init+0xe47>
f0101dd6:	68 9c 50 10 f0       	push   $0xf010509c
f0101ddb:	68 e3 52 10 f0       	push   $0xf01052e3
f0101de0:	68 bd 03 00 00       	push   $0x3bd
f0101de5:	68 bd 52 10 f0       	push   $0xf01052bd
f0101dea:	e8 b1 e2 ff ff       	call   f01000a0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101def:	83 ec 0c             	sub    $0xc,%esp
f0101df2:	6a 00                	push   $0x0
f0101df4:	e8 b6 ee ff ff       	call   f0100caf <page_alloc>
f0101df9:	83 c4 10             	add    $0x10,%esp
f0101dfc:	85 c0                	test   %eax,%eax
f0101dfe:	74 19                	je     f0101e19 <mem_init+0xe71>
f0101e00:	68 68 54 10 f0       	push   $0xf0105468
f0101e05:	68 e3 52 10 f0       	push   $0xf01052e3
f0101e0a:	68 c0 03 00 00       	push   $0x3c0
f0101e0f:	68 bd 52 10 f0       	push   $0xf01052bd
f0101e14:	e8 87 e2 ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101e19:	8b 0d 08 cb 17 f0    	mov    0xf017cb08,%ecx
f0101e1f:	8b 11                	mov    (%ecx),%edx
f0101e21:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0101e27:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e2a:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f0101e30:	c1 f8 03             	sar    $0x3,%eax
f0101e33:	c1 e0 0c             	shl    $0xc,%eax
f0101e36:	39 c2                	cmp    %eax,%edx
f0101e38:	74 19                	je     f0101e53 <mem_init+0xeab>
f0101e3a:	68 40 4d 10 f0       	push   $0xf0104d40
f0101e3f:	68 e3 52 10 f0       	push   $0xf01052e3
f0101e44:	68 c3 03 00 00       	push   $0x3c3
f0101e49:	68 bd 52 10 f0       	push   $0xf01052bd
f0101e4e:	e8 4d e2 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f0101e53:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0101e59:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e5c:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101e61:	74 19                	je     f0101e7c <mem_init+0xed4>
f0101e63:	68 cb 54 10 f0       	push   $0xf01054cb
f0101e68:	68 e3 52 10 f0       	push   $0xf01052e3
f0101e6d:	68 c5 03 00 00       	push   $0x3c5
f0101e72:	68 bd 52 10 f0       	push   $0xf01052bd
f0101e77:	e8 24 e2 ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0101e7c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101e7f:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0101e85:	83 ec 0c             	sub    $0xc,%esp
f0101e88:	50                   	push   %eax
f0101e89:	e8 91 ee ff ff       	call   f0100d1f <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0101e8e:	83 c4 0c             	add    $0xc,%esp
f0101e91:	6a 01                	push   $0x1
f0101e93:	68 00 10 40 00       	push   $0x401000
f0101e98:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101e9e:	e8 16 ef ff ff       	call   f0100db9 <pgdir_walk>
f0101ea3:	89 c7                	mov    %eax,%edi
f0101ea5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0101ea8:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
f0101ead:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101eb0:	8b 40 04             	mov    0x4(%eax),%eax
f0101eb3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101eb8:	8b 0d 04 cb 17 f0    	mov    0xf017cb04,%ecx
f0101ebe:	89 c2                	mov    %eax,%edx
f0101ec0:	c1 ea 0c             	shr    $0xc,%edx
f0101ec3:	83 c4 10             	add    $0x10,%esp
f0101ec6:	39 ca                	cmp    %ecx,%edx
f0101ec8:	72 15                	jb     f0101edf <mem_init+0xf37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101eca:	50                   	push   %eax
f0101ecb:	68 dc 4a 10 f0       	push   $0xf0104adc
f0101ed0:	68 cc 03 00 00       	push   $0x3cc
f0101ed5:	68 bd 52 10 f0       	push   $0xf01052bd
f0101eda:	e8 c1 e1 ff ff       	call   f01000a0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0101edf:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0101ee4:	39 c7                	cmp    %eax,%edi
f0101ee6:	74 19                	je     f0101f01 <mem_init+0xf59>
f0101ee8:	68 57 55 10 f0       	push   $0xf0105557
f0101eed:	68 e3 52 10 f0       	push   $0xf01052e3
f0101ef2:	68 cd 03 00 00       	push   $0x3cd
f0101ef7:	68 bd 52 10 f0       	push   $0xf01052bd
f0101efc:	e8 9f e1 ff ff       	call   f01000a0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0101f01:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0101f04:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0101f0b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f0e:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f14:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f0101f1a:	c1 f8 03             	sar    $0x3,%eax
f0101f1d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f20:	89 c2                	mov    %eax,%edx
f0101f22:	c1 ea 0c             	shr    $0xc,%edx
f0101f25:	39 d1                	cmp    %edx,%ecx
f0101f27:	77 12                	ja     f0101f3b <mem_init+0xf93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f29:	50                   	push   %eax
f0101f2a:	68 dc 4a 10 f0       	push   $0xf0104adc
f0101f2f:	6a 56                	push   $0x56
f0101f31:	68 c9 52 10 f0       	push   $0xf01052c9
f0101f36:	e8 65 e1 ff ff       	call   f01000a0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0101f3b:	83 ec 04             	sub    $0x4,%esp
f0101f3e:	68 00 10 00 00       	push   $0x1000
f0101f43:	68 ff 00 00 00       	push   $0xff
f0101f48:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101f4d:	50                   	push   %eax
f0101f4e:	e8 58 22 00 00       	call   f01041ab <memset>
	page_free(pp0);
f0101f53:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0101f56:	89 3c 24             	mov    %edi,(%esp)
f0101f59:	e8 c1 ed ff ff       	call   f0100d1f <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0101f5e:	83 c4 0c             	add    $0xc,%esp
f0101f61:	6a 01                	push   $0x1
f0101f63:	6a 00                	push   $0x0
f0101f65:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0101f6b:	e8 49 ee ff ff       	call   f0100db9 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101f70:	89 fa                	mov    %edi,%edx
f0101f72:	2b 15 0c cb 17 f0    	sub    0xf017cb0c,%edx
f0101f78:	c1 fa 03             	sar    $0x3,%edx
f0101f7b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101f7e:	89 d0                	mov    %edx,%eax
f0101f80:	c1 e8 0c             	shr    $0xc,%eax
f0101f83:	83 c4 10             	add    $0x10,%esp
f0101f86:	3b 05 04 cb 17 f0    	cmp    0xf017cb04,%eax
f0101f8c:	72 12                	jb     f0101fa0 <mem_init+0xff8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101f8e:	52                   	push   %edx
f0101f8f:	68 dc 4a 10 f0       	push   $0xf0104adc
f0101f94:	6a 56                	push   $0x56
f0101f96:	68 c9 52 10 f0       	push   $0xf01052c9
f0101f9b:	e8 00 e1 ff ff       	call   f01000a0 <_panic>
	return (void *)(pa + KERNBASE);
f0101fa0:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0101fa6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0101fa9:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0101faf:	f6 00 01             	testb  $0x1,(%eax)
f0101fb2:	74 19                	je     f0101fcd <mem_init+0x1025>
f0101fb4:	68 6f 55 10 f0       	push   $0xf010556f
f0101fb9:	68 e3 52 10 f0       	push   $0xf01052e3
f0101fbe:	68 d7 03 00 00       	push   $0x3d7
f0101fc3:	68 bd 52 10 f0       	push   $0xf01052bd
f0101fc8:	e8 d3 e0 ff ff       	call   f01000a0 <_panic>
f0101fcd:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0101fd0:	39 c2                	cmp    %eax,%edx
f0101fd2:	75 db                	jne    f0101faf <mem_init+0x1007>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0101fd4:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
f0101fd9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0101fdf:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101fe2:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0101fe8:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0101feb:	89 3d 40 be 17 f0    	mov    %edi,0xf017be40

	// free the pages we took
	page_free(pp0);
f0101ff1:	83 ec 0c             	sub    $0xc,%esp
f0101ff4:	50                   	push   %eax
f0101ff5:	e8 25 ed ff ff       	call   f0100d1f <page_free>
	page_free(pp1);
f0101ffa:	89 1c 24             	mov    %ebx,(%esp)
f0101ffd:	e8 1d ed ff ff       	call   f0100d1f <page_free>
	page_free(pp2);
f0102002:	89 34 24             	mov    %esi,(%esp)
f0102005:	e8 15 ed ff ff       	call   f0100d1f <page_free>

	cprintf("check_page() succeeded!\n");
f010200a:	c7 04 24 86 55 10 f0 	movl   $0xf0105586,(%esp)
f0102011:	e8 36 0e 00 00       	call   f0102e4c <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	// 把pages数组映射到线性地址UPAGES
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f0102016:	a1 0c cb 17 f0       	mov    0xf017cb0c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010201b:	83 c4 10             	add    $0x10,%esp
f010201e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102023:	77 15                	ja     f010203a <mem_init+0x1092>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102025:	50                   	push   %eax
f0102026:	68 e8 4b 10 f0       	push   $0xf0104be8
f010202b:	68 ce 00 00 00       	push   $0xce
f0102030:	68 bd 52 10 f0       	push   $0xf01052bd
f0102035:	e8 66 e0 ff ff       	call   f01000a0 <_panic>
f010203a:	83 ec 08             	sub    $0x8,%esp
f010203d:	6a 04                	push   $0x4
f010203f:	05 00 00 00 10       	add    $0x10000000,%eax
f0102044:	50                   	push   %eax
f0102045:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010204a:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f010204f:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
f0102054:	e8 f3 ed ff ff       	call   f0100e4c <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	// 将envs映射到虚拟空间UENVS处
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f0102059:	a1 4c be 17 f0       	mov    0xf017be4c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010205e:	83 c4 10             	add    $0x10,%esp
f0102061:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102066:	77 15                	ja     f010207d <mem_init+0x10d5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102068:	50                   	push   %eax
f0102069:	68 e8 4b 10 f0       	push   $0xf0104be8
f010206e:	68 d8 00 00 00       	push   $0xd8
f0102073:	68 bd 52 10 f0       	push   $0xf01052bd
f0102078:	e8 23 e0 ff ff       	call   f01000a0 <_panic>
f010207d:	83 ec 08             	sub    $0x8,%esp
f0102080:	6a 04                	push   $0x4
f0102082:	05 00 00 00 10       	add    $0x10000000,%eax
f0102087:	50                   	push   %eax
f0102088:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010208d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102092:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
f0102097:	e8 b0 ed ff ff       	call   f0100e4c <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010209c:	83 c4 10             	add    $0x10,%esp
f010209f:	b8 00 00 11 f0       	mov    $0xf0110000,%eax
f01020a4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01020a9:	77 15                	ja     f01020c0 <mem_init+0x1118>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01020ab:	50                   	push   %eax
f01020ac:	68 e8 4b 10 f0       	push   $0xf0104be8
f01020b1:	68 e7 00 00 00       	push   $0xe7
f01020b6:	68 bd 52 10 f0       	push   $0xf01052bd
f01020bb:	e8 e0 df ff ff       	call   f01000a0 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// 把由bootstack变量所标记的物理地址范围映射给内核的堆栈
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01020c0:	83 ec 08             	sub    $0x8,%esp
f01020c3:	6a 02                	push   $0x2
f01020c5:	68 00 00 11 00       	push   $0x110000
f01020ca:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01020cf:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01020d4:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
f01020d9:	e8 6e ed ff ff       	call   f0100e4c <boot_map_region>
	// Your code goes here:
	//？？？？？
	// n = (uint32_t)(-1) - KERNBASE + 1;
	// 2^32 - 15*16^7 = 1*16^7 = 0x10000000
	// 将整个物理内存映射到虚拟地址空间KERNBASE
	boot_map_region(kern_pgdir, KERNBASE, 0x10000000, 0, PTE_W | PTE_P);
f01020de:	83 c4 08             	add    $0x8,%esp
f01020e1:	6a 03                	push   $0x3
f01020e3:	6a 00                	push   $0x0
f01020e5:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f01020ea:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01020ef:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
f01020f4:	e8 53 ed ff ff       	call   f0100e4c <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01020f9:	8b 1d 08 cb 17 f0    	mov    0xf017cb08,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01020ff:	a1 04 cb 17 f0       	mov    0xf017cb04,%eax
f0102104:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102107:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010210e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102113:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102116:	8b 3d 0c cb 17 f0    	mov    0xf017cb0c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010211c:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010211f:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102122:	be 00 00 00 00       	mov    $0x0,%esi
f0102127:	eb 55                	jmp    f010217e <mem_init+0x11d6>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102129:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f010212f:	89 d8                	mov    %ebx,%eax
f0102131:	e8 ba e7 ff ff       	call   f01008f0 <check_va2pa>
f0102136:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010213d:	77 15                	ja     f0102154 <mem_init+0x11ac>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010213f:	57                   	push   %edi
f0102140:	68 e8 4b 10 f0       	push   $0xf0104be8
f0102145:	68 14 03 00 00       	push   $0x314
f010214a:	68 bd 52 10 f0       	push   $0xf01052bd
f010214f:	e8 4c df ff ff       	call   f01000a0 <_panic>
f0102154:	8d 94 37 00 00 00 10 	lea    0x10000000(%edi,%esi,1),%edx
f010215b:	39 d0                	cmp    %edx,%eax
f010215d:	74 19                	je     f0102178 <mem_init+0x11d0>
f010215f:	68 c0 50 10 f0       	push   $0xf01050c0
f0102164:	68 e3 52 10 f0       	push   $0xf01052e3
f0102169:	68 14 03 00 00       	push   $0x314
f010216e:	68 bd 52 10 f0       	push   $0xf01052bd
f0102173:	e8 28 df ff ff       	call   f01000a0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102178:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010217e:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
f0102181:	77 a6                	ja     f0102129 <mem_init+0x1181>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102183:	8b 3d 4c be 17 f0    	mov    0xf017be4c,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102189:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f010218c:	be 00 00 c0 ee       	mov    $0xeec00000,%esi
f0102191:	89 f2                	mov    %esi,%edx
f0102193:	89 d8                	mov    %ebx,%eax
f0102195:	e8 56 e7 ff ff       	call   f01008f0 <check_va2pa>
f010219a:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01021a1:	77 15                	ja     f01021b8 <mem_init+0x1210>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01021a3:	57                   	push   %edi
f01021a4:	68 e8 4b 10 f0       	push   $0xf0104be8
f01021a9:	68 19 03 00 00       	push   $0x319
f01021ae:	68 bd 52 10 f0       	push   $0xf01052bd
f01021b3:	e8 e8 de ff ff       	call   f01000a0 <_panic>
f01021b8:	8d 94 37 00 00 40 21 	lea    0x21400000(%edi,%esi,1),%edx
f01021bf:	39 c2                	cmp    %eax,%edx
f01021c1:	74 19                	je     f01021dc <mem_init+0x1234>
f01021c3:	68 f4 50 10 f0       	push   $0xf01050f4
f01021c8:	68 e3 52 10 f0       	push   $0xf01052e3
f01021cd:	68 19 03 00 00       	push   $0x319
f01021d2:	68 bd 52 10 f0       	push   $0xf01052bd
f01021d7:	e8 c4 de ff ff       	call   f01000a0 <_panic>
f01021dc:	81 c6 00 10 00 00    	add    $0x1000,%esi
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01021e2:	81 fe 00 80 c1 ee    	cmp    $0xeec18000,%esi
f01021e8:	75 a7                	jne    f0102191 <mem_init+0x11e9>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01021ea:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01021ed:	c1 e7 0c             	shl    $0xc,%edi
f01021f0:	be 00 00 00 00       	mov    $0x0,%esi
f01021f5:	eb 30                	jmp    f0102227 <mem_init+0x127f>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01021f7:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01021fd:	89 d8                	mov    %ebx,%eax
f01021ff:	e8 ec e6 ff ff       	call   f01008f0 <check_va2pa>
f0102204:	39 c6                	cmp    %eax,%esi
f0102206:	74 19                	je     f0102221 <mem_init+0x1279>
f0102208:	68 28 51 10 f0       	push   $0xf0105128
f010220d:	68 e3 52 10 f0       	push   $0xf01052e3
f0102212:	68 1d 03 00 00       	push   $0x31d
f0102217:	68 bd 52 10 f0       	push   $0xf01052bd
f010221c:	e8 7f de ff ff       	call   f01000a0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102221:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102227:	39 fe                	cmp    %edi,%esi
f0102229:	72 cc                	jb     f01021f7 <mem_init+0x124f>
f010222b:	be 00 80 ff ef       	mov    $0xefff8000,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f0102230:	89 f2                	mov    %esi,%edx
f0102232:	89 d8                	mov    %ebx,%eax
f0102234:	e8 b7 e6 ff ff       	call   f01008f0 <check_va2pa>
f0102239:	8d 96 00 80 11 10    	lea    0x10118000(%esi),%edx
f010223f:	39 c2                	cmp    %eax,%edx
f0102241:	74 19                	je     f010225c <mem_init+0x12b4>
f0102243:	68 50 51 10 f0       	push   $0xf0105150
f0102248:	68 e3 52 10 f0       	push   $0xf01052e3
f010224d:	68 21 03 00 00       	push   $0x321
f0102252:	68 bd 52 10 f0       	push   $0xf01052bd
f0102257:	e8 44 de ff ff       	call   f01000a0 <_panic>
f010225c:	81 c6 00 10 00 00    	add    $0x1000,%esi
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102262:	81 fe 00 00 00 f0    	cmp    $0xf0000000,%esi
f0102268:	75 c6                	jne    f0102230 <mem_init+0x1288>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f010226a:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010226f:	89 d8                	mov    %ebx,%eax
f0102271:	e8 7a e6 ff ff       	call   f01008f0 <check_va2pa>
f0102276:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102279:	74 51                	je     f01022cc <mem_init+0x1324>
f010227b:	68 98 51 10 f0       	push   $0xf0105198
f0102280:	68 e3 52 10 f0       	push   $0xf01052e3
f0102285:	68 22 03 00 00       	push   $0x322
f010228a:	68 bd 52 10 f0       	push   $0xf01052bd
f010228f:	e8 0c de ff ff       	call   f01000a0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102294:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102299:	72 36                	jb     f01022d1 <mem_init+0x1329>
f010229b:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01022a0:	76 07                	jbe    f01022a9 <mem_init+0x1301>
f01022a2:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01022a7:	75 28                	jne    f01022d1 <mem_init+0x1329>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
f01022a9:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f01022ad:	0f 85 83 00 00 00    	jne    f0102336 <mem_init+0x138e>
f01022b3:	68 9f 55 10 f0       	push   $0xf010559f
f01022b8:	68 e3 52 10 f0       	push   $0xf01052e3
f01022bd:	68 2b 03 00 00       	push   $0x32b
f01022c2:	68 bd 52 10 f0       	push   $0xf01052bd
f01022c7:	e8 d4 dd ff ff       	call   f01000a0 <_panic>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01022cc:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UPAGES):
		case PDX(UENVS):
			assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01022d1:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01022d6:	76 3f                	jbe    f0102317 <mem_init+0x136f>
				assert(pgdir[i] & PTE_P);
f01022d8:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f01022db:	f6 c2 01             	test   $0x1,%dl
f01022de:	75 19                	jne    f01022f9 <mem_init+0x1351>
f01022e0:	68 9f 55 10 f0       	push   $0xf010559f
f01022e5:	68 e3 52 10 f0       	push   $0xf01052e3
f01022ea:	68 2f 03 00 00       	push   $0x32f
f01022ef:	68 bd 52 10 f0       	push   $0xf01052bd
f01022f4:	e8 a7 dd ff ff       	call   f01000a0 <_panic>
				assert(pgdir[i] & PTE_W);
f01022f9:	f6 c2 02             	test   $0x2,%dl
f01022fc:	75 38                	jne    f0102336 <mem_init+0x138e>
f01022fe:	68 b0 55 10 f0       	push   $0xf01055b0
f0102303:	68 e3 52 10 f0       	push   $0xf01052e3
f0102308:	68 30 03 00 00       	push   $0x330
f010230d:	68 bd 52 10 f0       	push   $0xf01052bd
f0102312:	e8 89 dd ff ff       	call   f01000a0 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102317:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010231b:	74 19                	je     f0102336 <mem_init+0x138e>
f010231d:	68 c1 55 10 f0       	push   $0xf01055c1
f0102322:	68 e3 52 10 f0       	push   $0xf01052e3
f0102327:	68 32 03 00 00       	push   $0x332
f010232c:	68 bd 52 10 f0       	push   $0xf01052bd
f0102331:	e8 6a dd ff ff       	call   f01000a0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102336:	83 c0 01             	add    $0x1,%eax
f0102339:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010233e:	0f 86 50 ff ff ff    	jbe    f0102294 <mem_init+0x12ec>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102344:	83 ec 0c             	sub    $0xc,%esp
f0102347:	68 c8 51 10 f0       	push   $0xf01051c8
f010234c:	e8 fb 0a 00 00       	call   f0102e4c <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102351:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102356:	83 c4 10             	add    $0x10,%esp
f0102359:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010235e:	77 15                	ja     f0102375 <mem_init+0x13cd>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102360:	50                   	push   %eax
f0102361:	68 e8 4b 10 f0       	push   $0xf0104be8
f0102366:	68 01 01 00 00       	push   $0x101
f010236b:	68 bd 52 10 f0       	push   $0xf01052bd
f0102370:	e8 2b dd ff ff       	call   f01000a0 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102375:	05 00 00 00 10       	add    $0x10000000,%eax
f010237a:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f010237d:	b8 00 00 00 00       	mov    $0x0,%eax
f0102382:	e8 cd e5 ff ff       	call   f0100954 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f0102387:	0f 20 c0             	mov    %cr0,%eax
f010238a:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f010238d:	0d 23 00 05 80       	or     $0x80050023,%eax
f0102392:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102395:	83 ec 0c             	sub    $0xc,%esp
f0102398:	6a 00                	push   $0x0
f010239a:	e8 10 e9 ff ff       	call   f0100caf <page_alloc>
f010239f:	89 c3                	mov    %eax,%ebx
f01023a1:	83 c4 10             	add    $0x10,%esp
f01023a4:	85 c0                	test   %eax,%eax
f01023a6:	75 19                	jne    f01023c1 <mem_init+0x1419>
f01023a8:	68 bd 53 10 f0       	push   $0xf01053bd
f01023ad:	68 e3 52 10 f0       	push   $0xf01052e3
f01023b2:	68 f2 03 00 00       	push   $0x3f2
f01023b7:	68 bd 52 10 f0       	push   $0xf01052bd
f01023bc:	e8 df dc ff ff       	call   f01000a0 <_panic>
	assert((pp1 = page_alloc(0)));
f01023c1:	83 ec 0c             	sub    $0xc,%esp
f01023c4:	6a 00                	push   $0x0
f01023c6:	e8 e4 e8 ff ff       	call   f0100caf <page_alloc>
f01023cb:	89 c7                	mov    %eax,%edi
f01023cd:	83 c4 10             	add    $0x10,%esp
f01023d0:	85 c0                	test   %eax,%eax
f01023d2:	75 19                	jne    f01023ed <mem_init+0x1445>
f01023d4:	68 d3 53 10 f0       	push   $0xf01053d3
f01023d9:	68 e3 52 10 f0       	push   $0xf01052e3
f01023de:	68 f3 03 00 00       	push   $0x3f3
f01023e3:	68 bd 52 10 f0       	push   $0xf01052bd
f01023e8:	e8 b3 dc ff ff       	call   f01000a0 <_panic>
	assert((pp2 = page_alloc(0)));
f01023ed:	83 ec 0c             	sub    $0xc,%esp
f01023f0:	6a 00                	push   $0x0
f01023f2:	e8 b8 e8 ff ff       	call   f0100caf <page_alloc>
f01023f7:	89 c6                	mov    %eax,%esi
f01023f9:	83 c4 10             	add    $0x10,%esp
f01023fc:	85 c0                	test   %eax,%eax
f01023fe:	75 19                	jne    f0102419 <mem_init+0x1471>
f0102400:	68 e9 53 10 f0       	push   $0xf01053e9
f0102405:	68 e3 52 10 f0       	push   $0xf01052e3
f010240a:	68 f4 03 00 00       	push   $0x3f4
f010240f:	68 bd 52 10 f0       	push   $0xf01052bd
f0102414:	e8 87 dc ff ff       	call   f01000a0 <_panic>
	page_free(pp0);
f0102419:	83 ec 0c             	sub    $0xc,%esp
f010241c:	53                   	push   %ebx
f010241d:	e8 fd e8 ff ff       	call   f0100d1f <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102422:	89 f8                	mov    %edi,%eax
f0102424:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f010242a:	c1 f8 03             	sar    $0x3,%eax
f010242d:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102430:	89 c2                	mov    %eax,%edx
f0102432:	c1 ea 0c             	shr    $0xc,%edx
f0102435:	83 c4 10             	add    $0x10,%esp
f0102438:	3b 15 04 cb 17 f0    	cmp    0xf017cb04,%edx
f010243e:	72 12                	jb     f0102452 <mem_init+0x14aa>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102440:	50                   	push   %eax
f0102441:	68 dc 4a 10 f0       	push   $0xf0104adc
f0102446:	6a 56                	push   $0x56
f0102448:	68 c9 52 10 f0       	push   $0xf01052c9
f010244d:	e8 4e dc ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102452:	83 ec 04             	sub    $0x4,%esp
f0102455:	68 00 10 00 00       	push   $0x1000
f010245a:	6a 01                	push   $0x1
f010245c:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102461:	50                   	push   %eax
f0102462:	e8 44 1d 00 00       	call   f01041ab <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102467:	89 f0                	mov    %esi,%eax
f0102469:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f010246f:	c1 f8 03             	sar    $0x3,%eax
f0102472:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102475:	89 c2                	mov    %eax,%edx
f0102477:	c1 ea 0c             	shr    $0xc,%edx
f010247a:	83 c4 10             	add    $0x10,%esp
f010247d:	3b 15 04 cb 17 f0    	cmp    0xf017cb04,%edx
f0102483:	72 12                	jb     f0102497 <mem_init+0x14ef>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102485:	50                   	push   %eax
f0102486:	68 dc 4a 10 f0       	push   $0xf0104adc
f010248b:	6a 56                	push   $0x56
f010248d:	68 c9 52 10 f0       	push   $0xf01052c9
f0102492:	e8 09 dc ff ff       	call   f01000a0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102497:	83 ec 04             	sub    $0x4,%esp
f010249a:	68 00 10 00 00       	push   $0x1000
f010249f:	6a 02                	push   $0x2
f01024a1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01024a6:	50                   	push   %eax
f01024a7:	e8 ff 1c 00 00       	call   f01041ab <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01024ac:	6a 02                	push   $0x2
f01024ae:	68 00 10 00 00       	push   $0x1000
f01024b3:	57                   	push   %edi
f01024b4:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f01024ba:	e8 83 ea ff ff       	call   f0100f42 <page_insert>
	assert(pp1->pp_ref == 1);
f01024bf:	83 c4 20             	add    $0x20,%esp
f01024c2:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01024c7:	74 19                	je     f01024e2 <mem_init+0x153a>
f01024c9:	68 ba 54 10 f0       	push   $0xf01054ba
f01024ce:	68 e3 52 10 f0       	push   $0xf01052e3
f01024d3:	68 f9 03 00 00       	push   $0x3f9
f01024d8:	68 bd 52 10 f0       	push   $0xf01052bd
f01024dd:	e8 be db ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01024e2:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01024e9:	01 01 01 
f01024ec:	74 19                	je     f0102507 <mem_init+0x155f>
f01024ee:	68 e8 51 10 f0       	push   $0xf01051e8
f01024f3:	68 e3 52 10 f0       	push   $0xf01052e3
f01024f8:	68 fa 03 00 00       	push   $0x3fa
f01024fd:	68 bd 52 10 f0       	push   $0xf01052bd
f0102502:	e8 99 db ff ff       	call   f01000a0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102507:	6a 02                	push   $0x2
f0102509:	68 00 10 00 00       	push   $0x1000
f010250e:	56                   	push   %esi
f010250f:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f0102515:	e8 28 ea ff ff       	call   f0100f42 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f010251a:	83 c4 10             	add    $0x10,%esp
f010251d:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102524:	02 02 02 
f0102527:	74 19                	je     f0102542 <mem_init+0x159a>
f0102529:	68 0c 52 10 f0       	push   $0xf010520c
f010252e:	68 e3 52 10 f0       	push   $0xf01052e3
f0102533:	68 fc 03 00 00       	push   $0x3fc
f0102538:	68 bd 52 10 f0       	push   $0xf01052bd
f010253d:	e8 5e db ff ff       	call   f01000a0 <_panic>
	assert(pp2->pp_ref == 1);
f0102542:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102547:	74 19                	je     f0102562 <mem_init+0x15ba>
f0102549:	68 dc 54 10 f0       	push   $0xf01054dc
f010254e:	68 e3 52 10 f0       	push   $0xf01052e3
f0102553:	68 fd 03 00 00       	push   $0x3fd
f0102558:	68 bd 52 10 f0       	push   $0xf01052bd
f010255d:	e8 3e db ff ff       	call   f01000a0 <_panic>
	assert(pp1->pp_ref == 0);
f0102562:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102567:	74 19                	je     f0102582 <mem_init+0x15da>
f0102569:	68 46 55 10 f0       	push   $0xf0105546
f010256e:	68 e3 52 10 f0       	push   $0xf01052e3
f0102573:	68 fe 03 00 00       	push   $0x3fe
f0102578:	68 bd 52 10 f0       	push   $0xf01052bd
f010257d:	e8 1e db ff ff       	call   f01000a0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102582:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102589:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010258c:	89 f0                	mov    %esi,%eax
f010258e:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f0102594:	c1 f8 03             	sar    $0x3,%eax
f0102597:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010259a:	89 c2                	mov    %eax,%edx
f010259c:	c1 ea 0c             	shr    $0xc,%edx
f010259f:	3b 15 04 cb 17 f0    	cmp    0xf017cb04,%edx
f01025a5:	72 12                	jb     f01025b9 <mem_init+0x1611>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01025a7:	50                   	push   %eax
f01025a8:	68 dc 4a 10 f0       	push   $0xf0104adc
f01025ad:	6a 56                	push   $0x56
f01025af:	68 c9 52 10 f0       	push   $0xf01052c9
f01025b4:	e8 e7 da ff ff       	call   f01000a0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01025b9:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01025c0:	03 03 03 
f01025c3:	74 19                	je     f01025de <mem_init+0x1636>
f01025c5:	68 30 52 10 f0       	push   $0xf0105230
f01025ca:	68 e3 52 10 f0       	push   $0xf01052e3
f01025cf:	68 00 04 00 00       	push   $0x400
f01025d4:	68 bd 52 10 f0       	push   $0xf01052bd
f01025d9:	e8 c2 da ff ff       	call   f01000a0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01025de:	83 ec 08             	sub    $0x8,%esp
f01025e1:	68 00 10 00 00       	push   $0x1000
f01025e6:	ff 35 08 cb 17 f0    	pushl  0xf017cb08
f01025ec:	e8 0f e9 ff ff       	call   f0100f00 <page_remove>
	assert(pp2->pp_ref == 0);
f01025f1:	83 c4 10             	add    $0x10,%esp
f01025f4:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01025f9:	74 19                	je     f0102614 <mem_init+0x166c>
f01025fb:	68 14 55 10 f0       	push   $0xf0105514
f0102600:	68 e3 52 10 f0       	push   $0xf01052e3
f0102605:	68 02 04 00 00       	push   $0x402
f010260a:	68 bd 52 10 f0       	push   $0xf01052bd
f010260f:	e8 8c da ff ff       	call   f01000a0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102614:	8b 0d 08 cb 17 f0    	mov    0xf017cb08,%ecx
f010261a:	8b 11                	mov    (%ecx),%edx
f010261c:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102622:	89 d8                	mov    %ebx,%eax
f0102624:	2b 05 0c cb 17 f0    	sub    0xf017cb0c,%eax
f010262a:	c1 f8 03             	sar    $0x3,%eax
f010262d:	c1 e0 0c             	shl    $0xc,%eax
f0102630:	39 c2                	cmp    %eax,%edx
f0102632:	74 19                	je     f010264d <mem_init+0x16a5>
f0102634:	68 40 4d 10 f0       	push   $0xf0104d40
f0102639:	68 e3 52 10 f0       	push   $0xf01052e3
f010263e:	68 05 04 00 00       	push   $0x405
f0102643:	68 bd 52 10 f0       	push   $0xf01052bd
f0102648:	e8 53 da ff ff       	call   f01000a0 <_panic>
	kern_pgdir[0] = 0;
f010264d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102653:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102658:	74 19                	je     f0102673 <mem_init+0x16cb>
f010265a:	68 cb 54 10 f0       	push   $0xf01054cb
f010265f:	68 e3 52 10 f0       	push   $0xf01052e3
f0102664:	68 07 04 00 00       	push   $0x407
f0102669:	68 bd 52 10 f0       	push   $0xf01052bd
f010266e:	e8 2d da ff ff       	call   f01000a0 <_panic>
	pp0->pp_ref = 0;
f0102673:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102679:	83 ec 0c             	sub    $0xc,%esp
f010267c:	53                   	push   %ebx
f010267d:	e8 9d e6 ff ff       	call   f0100d1f <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102682:	c7 04 24 5c 52 10 f0 	movl   $0xf010525c,(%esp)
f0102689:	e8 be 07 00 00       	call   f0102e4c <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010268e:	83 c4 10             	add    $0x10,%esp
f0102691:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102694:	5b                   	pop    %ebx
f0102695:	5e                   	pop    %esi
f0102696:	5f                   	pop    %edi
f0102697:	5d                   	pop    %ebp
f0102698:	c3                   	ret    

f0102699 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0102699:	55                   	push   %ebp
f010269a:	89 e5                	mov    %esp,%ebp
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f010269c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010269f:	0f 01 38             	invlpg (%eax)
	// Flush the entry only if we're modifying the current address space.
	// For now, there is only one address space, so always invalidate.
	invlpg(va);
}
f01026a2:	5d                   	pop    %ebp
f01026a3:	c3                   	ret    

f01026a4 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
// ?????
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01026a4:	55                   	push   %ebp
f01026a5:	89 e5                	mov    %esp,%ebp
f01026a7:	57                   	push   %edi
f01026a8:	56                   	push   %esi
f01026a9:	53                   	push   %ebx
f01026aa:	83 ec 1c             	sub    $0x1c,%esp
f01026ad:	8b 7d 08             	mov    0x8(%ebp),%edi
f01026b0:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	char * end = NULL;
	char * start = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE); 
f01026b3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026b6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026bb:	89 c3                	mov    %eax,%ebx
f01026bd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	end = ROUNDUP((char *)(va + len), PGSIZE);
f01026c0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01026c3:	03 45 10             	add    0x10(%ebp),%eax
f01026c6:	05 ff 0f 00 00       	add    $0xfff,%eax
f01026cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01026d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t *cur = NULL;

	for(; start < end; start += PGSIZE) {
f01026d3:	eb 4e                	jmp    f0102723 <user_mem_check+0x7f>
		cur = pgdir_walk(env->env_pgdir, (void *)start, 0);
f01026d5:	83 ec 04             	sub    $0x4,%esp
f01026d8:	6a 00                	push   $0x0
f01026da:	53                   	push   %ebx
f01026db:	ff 77 5c             	pushl  0x5c(%edi)
f01026de:	e8 d6 e6 ff ff       	call   f0100db9 <pgdir_walk>
		if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
f01026e3:	89 da                	mov    %ebx,%edx
f01026e5:	83 c4 10             	add    $0x10,%esp
f01026e8:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f01026ee:	77 0c                	ja     f01026fc <user_mem_check+0x58>
f01026f0:	85 c0                	test   %eax,%eax
f01026f2:	74 08                	je     f01026fc <user_mem_check+0x58>
f01026f4:	89 f1                	mov    %esi,%ecx
f01026f6:	23 08                	and    (%eax),%ecx
f01026f8:	39 ce                	cmp    %ecx,%esi
f01026fa:	74 21                	je     f010271d <user_mem_check+0x79>
			  if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f01026fc:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f01026ff:	75 0f                	jne    f0102710 <user_mem_check+0x6c>
					user_mem_check_addr = (uintptr_t)va;
f0102701:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102704:	a3 3c be 17 f0       	mov    %eax,0xf017be3c
			  }
			  else {
			  		user_mem_check_addr = (uintptr_t)start;
			  }
			  return -E_FAULT;
f0102709:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010270e:	eb 1d                	jmp    f010272d <user_mem_check+0x89>
		if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
			  if(start == ROUNDDOWN((char *)va, PGSIZE)) {
					user_mem_check_addr = (uintptr_t)va;
			  }
			  else {
			  		user_mem_check_addr = (uintptr_t)start;
f0102710:	89 15 3c be 17 f0    	mov    %edx,0xf017be3c
			  }
			  return -E_FAULT;
f0102716:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f010271b:	eb 10                	jmp    f010272d <user_mem_check+0x89>
	char * start = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE); 
	end = ROUNDUP((char *)(va + len), PGSIZE);
	pte_t *cur = NULL;

	for(; start < end; start += PGSIZE) {
f010271d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102723:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102726:	72 ad                	jb     f01026d5 <user_mem_check+0x31>
			  return -E_FAULT;
		}
		
	}
		
	return 0;
f0102728:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010272d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102730:	5b                   	pop    %ebx
f0102731:	5e                   	pop    %esi
f0102732:	5f                   	pop    %edi
f0102733:	5d                   	pop    %ebp
f0102734:	c3                   	ret    

f0102735 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102735:	55                   	push   %ebp
f0102736:	89 e5                	mov    %esp,%ebp
f0102738:	53                   	push   %ebx
f0102739:	83 ec 04             	sub    $0x4,%esp
f010273c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010273f:	8b 45 14             	mov    0x14(%ebp),%eax
f0102742:	83 c8 04             	or     $0x4,%eax
f0102745:	50                   	push   %eax
f0102746:	ff 75 10             	pushl  0x10(%ebp)
f0102749:	ff 75 0c             	pushl  0xc(%ebp)
f010274c:	53                   	push   %ebx
f010274d:	e8 52 ff ff ff       	call   f01026a4 <user_mem_check>
f0102752:	83 c4 10             	add    $0x10,%esp
f0102755:	85 c0                	test   %eax,%eax
f0102757:	79 21                	jns    f010277a <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102759:	83 ec 04             	sub    $0x4,%esp
f010275c:	ff 35 3c be 17 f0    	pushl  0xf017be3c
f0102762:	ff 73 48             	pushl  0x48(%ebx)
f0102765:	68 88 52 10 f0       	push   $0xf0105288
f010276a:	e8 dd 06 00 00       	call   f0102e4c <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f010276f:	89 1c 24             	mov    %ebx,(%esp)
f0102772:	e8 bc 05 00 00       	call   f0102d33 <env_destroy>
f0102777:	83 c4 10             	add    $0x10,%esp
	}
}
f010277a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010277d:	c9                   	leave  
f010277e:	c3                   	ret    

f010277f <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
// 为用户环境分配物理空间
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f010277f:	55                   	push   %ebp
f0102780:	89 e5                	mov    %esp,%ebp
f0102782:	57                   	push   %edi
f0102783:	56                   	push   %esi
f0102784:	53                   	push   %ebx
f0102785:	83 ec 0c             	sub    $0xc,%esp
f0102788:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *vas, *vat;

	vas = ROUNDDOWN(va, PGSIZE);
f010278a:	89 d3                	mov    %edx,%ebx
f010278c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	vat = ROUNDUP(va + len, PGSIZE);
f0102792:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102799:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	for (; vas < vat; vas += PGSIZE) {
f010279f:	eb 3d                	jmp    f01027de <region_alloc+0x5f>
		struct PageInfo *pp = page_alloc(0);
f01027a1:	83 ec 0c             	sub    $0xc,%esp
f01027a4:	6a 00                	push   $0x0
f01027a6:	e8 04 e5 ff ff       	call   f0100caf <page_alloc>
		if (pp == NULL)
f01027ab:	83 c4 10             	add    $0x10,%esp
f01027ae:	85 c0                	test   %eax,%eax
f01027b0:	75 17                	jne    f01027c9 <region_alloc+0x4a>
			panic("region_alloc: allocation failed.");
f01027b2:	83 ec 04             	sub    $0x4,%esp
f01027b5:	68 d0 55 10 f0       	push   $0xf01055d0
f01027ba:	68 2b 01 00 00       	push   $0x12b
f01027bf:	68 4a 56 10 f0       	push   $0xf010564a
f01027c4:	e8 d7 d8 ff ff       	call   f01000a0 <_panic>
		page_insert(e->env_pgdir, pp, vas, PTE_U | PTE_W);
f01027c9:	6a 06                	push   $0x6
f01027cb:	53                   	push   %ebx
f01027cc:	50                   	push   %eax
f01027cd:	ff 77 5c             	pushl  0x5c(%edi)
f01027d0:	e8 6d e7 ff ff       	call   f0100f42 <page_insert>
	void *vas, *vat;

	vas = ROUNDDOWN(va, PGSIZE);
	vat = ROUNDUP(va + len, PGSIZE);

	for (; vas < vat; vas += PGSIZE) {
f01027d5:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01027db:	83 c4 10             	add    $0x10,%esp
f01027de:	39 f3                	cmp    %esi,%ebx
f01027e0:	72 bf                	jb     f01027a1 <region_alloc+0x22>
		struct PageInfo *pp = page_alloc(0);
		if (pp == NULL)
			panic("region_alloc: allocation failed.");
		page_insert(e->env_pgdir, pp, vas, PTE_U | PTE_W);
	}
}
f01027e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01027e5:	5b                   	pop    %ebx
f01027e6:	5e                   	pop    %esi
f01027e7:	5f                   	pop    %edi
f01027e8:	5d                   	pop    %ebp
f01027e9:	c3                   	ret    

f01027ea <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f01027ea:	55                   	push   %ebp
f01027eb:	89 e5                	mov    %esp,%ebp
f01027ed:	8b 55 08             	mov    0x8(%ebp),%edx
f01027f0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f01027f3:	85 d2                	test   %edx,%edx
f01027f5:	75 11                	jne    f0102808 <envid2env+0x1e>
		*env_store = curenv;
f01027f7:	a1 48 be 17 f0       	mov    0xf017be48,%eax
f01027fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01027ff:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102801:	b8 00 00 00 00       	mov    $0x0,%eax
f0102806:	eb 5e                	jmp    f0102866 <envid2env+0x7c>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102808:	89 d0                	mov    %edx,%eax
f010280a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010280f:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0102812:	c1 e0 05             	shl    $0x5,%eax
f0102815:	03 05 4c be 17 f0    	add    0xf017be4c,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010281b:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f010281f:	74 05                	je     f0102826 <envid2env+0x3c>
f0102821:	3b 50 48             	cmp    0x48(%eax),%edx
f0102824:	74 10                	je     f0102836 <envid2env+0x4c>
		*env_store = 0;
f0102826:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102829:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f010282f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102834:	eb 30                	jmp    f0102866 <envid2env+0x7c>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102836:	84 c9                	test   %cl,%cl
f0102838:	74 22                	je     f010285c <envid2env+0x72>
f010283a:	8b 15 48 be 17 f0    	mov    0xf017be48,%edx
f0102840:	39 d0                	cmp    %edx,%eax
f0102842:	74 18                	je     f010285c <envid2env+0x72>
f0102844:	8b 4a 48             	mov    0x48(%edx),%ecx
f0102847:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f010284a:	74 10                	je     f010285c <envid2env+0x72>
		*env_store = 0;
f010284c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010284f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102855:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010285a:	eb 0a                	jmp    f0102866 <envid2env+0x7c>
	}

	*env_store = e;
f010285c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010285f:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102861:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102866:	5d                   	pop    %ebp
f0102867:	c3                   	ret    

f0102868 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102868:	55                   	push   %ebp
f0102869:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f010286b:	b8 00 a3 11 f0       	mov    $0xf011a300,%eax
f0102870:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102873:	b8 23 00 00 00       	mov    $0x23,%eax
f0102878:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f010287a:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f010287c:	b8 10 00 00 00       	mov    $0x10,%eax
f0102881:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102883:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102885:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102887:	ea 8e 28 10 f0 08 00 	ljmp   $0x8,$0xf010288e
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f010288e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102893:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102896:	5d                   	pop    %ebp
f0102897:	c3                   	ret    

f0102898 <env_init>:
// 初始化所有的在envs数组中的 Env结构体，并把它们加入到 env_free_list中
// 与page_init()类似
// 要求所有的 Env 在 env_free_list 中的顺序，要和它在 envs 中的顺序一致
void
env_init(void)
{
f0102898:	55                   	push   %ebp
f0102899:	89 e5                	mov    %esp,%ebp
f010289b:	56                   	push   %esi
f010289c:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	//从 NENV-1 到 0， 保证第一次分配的是envs[0]
	for (i = NENV-1; i >= 0; i--) {
		envs[i].env_status = ENV_FREE;
f010289d:	8b 35 4c be 17 f0    	mov    0xf017be4c,%esi
f01028a3:	8b 15 50 be 17 f0    	mov    0xf017be50,%edx
f01028a9:	8d 86 a0 7f 01 00    	lea    0x17fa0(%esi),%eax
f01028af:	8d 5e a0             	lea    -0x60(%esi),%ebx
f01028b2:	89 c1                	mov    %eax,%ecx
f01028b4:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f01028bb:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f01028c2:	89 50 44             	mov    %edx,0x44(%eax)
f01028c5:	83 e8 60             	sub    $0x60,%eax
		env_free_list = envs + i;
f01028c8:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	//从 NENV-1 到 0， 保证第一次分配的是envs[0]
	for (i = NENV-1; i >= 0; i--) {
f01028ca:	39 d8                	cmp    %ebx,%eax
f01028cc:	75 e4                	jne    f01028b2 <env_init+0x1a>
f01028ce:	89 35 50 be 17 f0    	mov    %esi,0xf017be50
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs + i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f01028d4:	e8 8f ff ff ff       	call   f0102868 <env_init_percpu>
}
f01028d9:	5b                   	pop    %ebx
f01028da:	5e                   	pop    %esi
f01028db:	5d                   	pop    %ebp
f01028dc:	c3                   	ret    

f01028dd <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f01028dd:	55                   	push   %ebp
f01028de:	89 e5                	mov    %esp,%ebp
f01028e0:	53                   	push   %ebx
f01028e1:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f01028e4:	8b 1d 50 be 17 f0    	mov    0xf017be50,%ebx
f01028ea:	85 db                	test   %ebx,%ebx
f01028ec:	0f 84 4d 01 00 00    	je     f0102a3f <env_alloc+0x162>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f01028f2:	83 ec 0c             	sub    $0xc,%esp
f01028f5:	6a 01                	push   $0x1
f01028f7:	e8 b3 e3 ff ff       	call   f0100caf <page_alloc>
f01028fc:	83 c4 10             	add    $0x10,%esp
f01028ff:	85 c0                	test   %eax,%eax
f0102901:	0f 84 3f 01 00 00    	je     f0102a46 <env_alloc+0x169>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102907:	89 c2                	mov    %eax,%edx
f0102909:	2b 15 0c cb 17 f0    	sub    0xf017cb0c,%edx
f010290f:	c1 fa 03             	sar    $0x3,%edx
f0102912:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102915:	89 d1                	mov    %edx,%ecx
f0102917:	c1 e9 0c             	shr    $0xc,%ecx
f010291a:	3b 0d 04 cb 17 f0    	cmp    0xf017cb04,%ecx
f0102920:	72 12                	jb     f0102934 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102922:	52                   	push   %edx
f0102923:	68 dc 4a 10 f0       	push   $0xf0104adc
f0102928:	6a 56                	push   $0x56
f010292a:	68 c9 52 10 f0       	push   $0xf01052c9
f010292f:	e8 6c d7 ff ff       	call   f01000a0 <_panic>
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	
	// 初始化页目录
	e->env_pgdir = (pde_t *) page2kva(p);
f0102934:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f010293a:	89 53 5c             	mov    %edx,0x5c(%ebx)
	p->pp_ref++;
f010293d:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0102942:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	
	// 初始化与内核相关的页目录项
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
		e->env_pgdir[i] = kern_pgdir[i];
f0102947:	8b 15 08 cb 17 f0    	mov    0xf017cb08,%edx
f010294d:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102950:	8b 53 5c             	mov    0x5c(%ebx),%edx
f0102953:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102956:	83 c0 04             	add    $0x4,%eax
	// 初始化页目录
	e->env_pgdir = (pde_t *) page2kva(p);
	p->pp_ref++;
	
	// 初始化与内核相关的页目录项
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
f0102959:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010295e:	75 e7                	jne    f0102947 <env_alloc+0x6a>
	


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102960:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102963:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102968:	77 15                	ja     f010297f <env_alloc+0xa2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010296a:	50                   	push   %eax
f010296b:	68 e8 4b 10 f0       	push   $0xf0104be8
f0102970:	68 ce 00 00 00       	push   $0xce
f0102975:	68 4a 56 10 f0       	push   $0xf010564a
f010297a:	e8 21 d7 ff ff       	call   f01000a0 <_panic>
f010297f:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102985:	83 ca 05             	or     $0x5,%edx
f0102988:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f010298e:	8b 43 48             	mov    0x48(%ebx),%eax
f0102991:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102996:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f010299b:	ba 00 10 00 00       	mov    $0x1000,%edx
f01029a0:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f01029a3:	89 da                	mov    %ebx,%edx
f01029a5:	2b 15 4c be 17 f0    	sub    0xf017be4c,%edx
f01029ab:	c1 fa 05             	sar    $0x5,%edx
f01029ae:	69 d2 ab aa aa aa    	imul   $0xaaaaaaab,%edx,%edx
f01029b4:	09 d0                	or     %edx,%eax
f01029b6:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f01029b9:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029bc:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f01029bf:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f01029c6:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f01029cd:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f01029d4:	83 ec 04             	sub    $0x4,%esp
f01029d7:	6a 44                	push   $0x44
f01029d9:	6a 00                	push   $0x0
f01029db:	53                   	push   %ebx
f01029dc:	e8 ca 17 00 00       	call   f01041ab <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f01029e1:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f01029e7:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f01029ed:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f01029f3:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f01029fa:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// commit the allocation
	env_free_list = e->env_link;
f0102a00:	8b 43 44             	mov    0x44(%ebx),%eax
f0102a03:	a3 50 be 17 f0       	mov    %eax,0xf017be50
	*newenv_store = e;
f0102a08:	8b 45 08             	mov    0x8(%ebp),%eax
f0102a0b:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102a0d:	8b 53 48             	mov    0x48(%ebx),%edx
f0102a10:	a1 48 be 17 f0       	mov    0xf017be48,%eax
f0102a15:	83 c4 10             	add    $0x10,%esp
f0102a18:	85 c0                	test   %eax,%eax
f0102a1a:	74 05                	je     f0102a21 <env_alloc+0x144>
f0102a1c:	8b 40 48             	mov    0x48(%eax),%eax
f0102a1f:	eb 05                	jmp    f0102a26 <env_alloc+0x149>
f0102a21:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a26:	83 ec 04             	sub    $0x4,%esp
f0102a29:	52                   	push   %edx
f0102a2a:	50                   	push   %eax
f0102a2b:	68 55 56 10 f0       	push   $0xf0105655
f0102a30:	e8 17 04 00 00       	call   f0102e4c <cprintf>
	return 0;
f0102a35:	83 c4 10             	add    $0x10,%esp
f0102a38:	b8 00 00 00 00       	mov    $0x0,%eax
f0102a3d:	eb 0c                	jmp    f0102a4b <env_alloc+0x16e>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102a3f:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102a44:	eb 05                	jmp    f0102a4b <env_alloc+0x16e>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102a46:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102a4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102a4e:	c9                   	leave  
f0102a4f:	c3                   	ret    

f0102a50 <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102a50:	55                   	push   %ebp
f0102a51:	89 e5                	mov    %esp,%ebp
f0102a53:	57                   	push   %edi
f0102a54:	56                   	push   %esi
f0102a55:	53                   	push   %ebx
f0102a56:	83 ec 34             	sub    $0x34,%esp
f0102a59:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int errorcode;

	if ((errorcode=env_alloc(&e, 0)) < 0)
f0102a5c:	6a 00                	push   $0x0
f0102a5e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102a61:	50                   	push   %eax
f0102a62:	e8 76 fe ff ff       	call   f01028dd <env_alloc>
f0102a67:	83 c4 10             	add    $0x10,%esp
f0102a6a:	85 c0                	test   %eax,%eax
f0102a6c:	79 15                	jns    f0102a83 <env_create+0x33>
		panic("env_create: %e", errorcode);
f0102a6e:	50                   	push   %eax
f0102a6f:	68 6a 56 10 f0       	push   $0xf010566a
f0102a74:	68 97 01 00 00       	push   $0x197
f0102a79:	68 4a 56 10 f0       	push   $0xf010564a
f0102a7e:	e8 1d d6 ff ff       	call   f01000a0 <_panic>

	load_icode(e, binary);
f0102a83:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102a86:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Proghdr *ph, *eph;

	ELFHDR = (struct Elf *) binary;

	//根据文件魔数是否ELF文件
	if (ELFHDR->e_magic != ELF_MAGIC)
f0102a89:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102a8f:	74 17                	je     f0102aa8 <env_create+0x58>
		panic("load_icode: not ELF executable.");
f0102a91:	83 ec 04             	sub    $0x4,%esp
f0102a94:	68 f4 55 10 f0       	push   $0xf01055f4
f0102a99:	68 6d 01 00 00       	push   $0x16d
f0102a9e:	68 4a 56 10 f0       	push   $0xf010564a
f0102aa3:	e8 f8 d5 ff ff       	call   f01000a0 <_panic>

	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
f0102aa8:	89 fb                	mov    %edi,%ebx
f0102aaa:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0102aad:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102ab1:	c1 e6 05             	shl    $0x5,%esi
f0102ab4:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f0102ab6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ab9:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102abc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ac1:	77 15                	ja     f0102ad8 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ac3:	50                   	push   %eax
f0102ac4:	68 e8 4b 10 f0       	push   $0xf0104be8
f0102ac9:	68 72 01 00 00       	push   $0x172
f0102ace:	68 4a 56 10 f0       	push   $0xf010564a
f0102ad3:	e8 c8 d5 ff ff       	call   f01000a0 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0102ad8:	05 00 00 00 10       	add    $0x10000000,%eax
f0102add:	0f 22 d8             	mov    %eax,%cr3
f0102ae0:	eb 3d                	jmp    f0102b1f <env_create+0xcf>

	//program header记录着需要加载到内存里的部分
	for (; ph < eph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
f0102ae2:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102ae5:	75 35                	jne    f0102b1c <env_create+0xcc>
			region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f0102ae7:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102aea:	8b 53 08             	mov    0x8(%ebx),%edx
f0102aed:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102af0:	e8 8a fc ff ff       	call   f010277f <region_alloc>
			memset((void *) ph->p_va, 0, ph->p_memsz);
f0102af5:	83 ec 04             	sub    $0x4,%esp
f0102af8:	ff 73 14             	pushl  0x14(%ebx)
f0102afb:	6a 00                	push   $0x0
f0102afd:	ff 73 08             	pushl  0x8(%ebx)
f0102b00:	e8 a6 16 00 00       	call   f01041ab <memset>
			memcpy((void *) ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0102b05:	83 c4 0c             	add    $0xc,%esp
f0102b08:	ff 73 10             	pushl  0x10(%ebx)
f0102b0b:	89 f8                	mov    %edi,%eax
f0102b0d:	03 43 04             	add    0x4(%ebx),%eax
f0102b10:	50                   	push   %eax
f0102b11:	ff 73 08             	pushl  0x8(%ebx)
f0102b14:	e8 47 17 00 00       	call   f0104260 <memcpy>
f0102b19:	83 c4 10             	add    $0x10,%esp
	eph = ph + ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));

	//program header记录着需要加载到内存里的部分
	for (; ph < eph; ph++) {
f0102b1c:	83 c3 20             	add    $0x20,%ebx
f0102b1f:	39 de                	cmp    %ebx,%esi
f0102b21:	77 bf                	ja     f0102ae2 <env_create+0x92>
			memset((void *) ph->p_va, 0, ph->p_memsz);
			memcpy((void *) ph->p_va, binary + ph->p_offset, ph->p_filesz);
		}
	}

	lcr3(PADDR(kern_pgdir));
f0102b23:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b28:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b2d:	77 15                	ja     f0102b44 <env_create+0xf4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b2f:	50                   	push   %eax
f0102b30:	68 e8 4b 10 f0       	push   $0xf0104be8
f0102b35:	68 7d 01 00 00       	push   $0x17d
f0102b3a:	68 4a 56 10 f0       	push   $0xf010564a
f0102b3f:	e8 5c d5 ff ff       	call   f01000a0 <_panic>
f0102b44:	05 00 00 00 10       	add    $0x10000000,%eax
f0102b49:	0f 22 d8             	mov    %eax,%cr3

	e->env_tf.tf_eip = ELFHDR->e_entry;
f0102b4c:	8b 47 18             	mov    0x18(%edi),%eax
f0102b4f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102b52:	89 47 30             	mov    %eax,0x30(%edi)

	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0102b55:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102b5a:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0102b5f:	89 f8                	mov    %edi,%eax
f0102b61:	e8 19 fc ff ff       	call   f010277f <region_alloc>
	if ((errorcode=env_alloc(&e, 0)) < 0)
		panic("env_create: %e", errorcode);

	load_icode(e, binary);

	e->env_type = type;
f0102b66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102b69:	8b 55 0c             	mov    0xc(%ebp),%edx
f0102b6c:	89 50 50             	mov    %edx,0x50(%eax)
}
f0102b6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102b72:	5b                   	pop    %ebx
f0102b73:	5e                   	pop    %esi
f0102b74:	5f                   	pop    %edi
f0102b75:	5d                   	pop    %ebp
f0102b76:	c3                   	ret    

f0102b77 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102b77:	55                   	push   %ebp
f0102b78:	89 e5                	mov    %esp,%ebp
f0102b7a:	57                   	push   %edi
f0102b7b:	56                   	push   %esi
f0102b7c:	53                   	push   %ebx
f0102b7d:	83 ec 1c             	sub    $0x1c,%esp
f0102b80:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102b83:	8b 15 48 be 17 f0    	mov    0xf017be48,%edx
f0102b89:	39 fa                	cmp    %edi,%edx
f0102b8b:	75 29                	jne    f0102bb6 <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102b8d:	a1 08 cb 17 f0       	mov    0xf017cb08,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102b92:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102b97:	77 15                	ja     f0102bae <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102b99:	50                   	push   %eax
f0102b9a:	68 e8 4b 10 f0       	push   $0xf0104be8
f0102b9f:	68 ac 01 00 00       	push   $0x1ac
f0102ba4:	68 4a 56 10 f0       	push   $0xf010564a
f0102ba9:	e8 f2 d4 ff ff       	call   f01000a0 <_panic>
f0102bae:	05 00 00 00 10       	add    $0x10000000,%eax
f0102bb3:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102bb6:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102bb9:	85 d2                	test   %edx,%edx
f0102bbb:	74 05                	je     f0102bc2 <env_free+0x4b>
f0102bbd:	8b 42 48             	mov    0x48(%edx),%eax
f0102bc0:	eb 05                	jmp    f0102bc7 <env_free+0x50>
f0102bc2:	b8 00 00 00 00       	mov    $0x0,%eax
f0102bc7:	83 ec 04             	sub    $0x4,%esp
f0102bca:	51                   	push   %ecx
f0102bcb:	50                   	push   %eax
f0102bcc:	68 79 56 10 f0       	push   $0xf0105679
f0102bd1:	e8 76 02 00 00       	call   f0102e4c <cprintf>
f0102bd6:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102bd9:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102be0:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102be3:	89 d0                	mov    %edx,%eax
f0102be5:	c1 e0 02             	shl    $0x2,%eax
f0102be8:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102beb:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102bee:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102bf1:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102bf7:	0f 84 a8 00 00 00    	je     f0102ca5 <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102bfd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c03:	89 f0                	mov    %esi,%eax
f0102c05:	c1 e8 0c             	shr    $0xc,%eax
f0102c08:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0102c0b:	39 05 04 cb 17 f0    	cmp    %eax,0xf017cb04
f0102c11:	77 15                	ja     f0102c28 <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c13:	56                   	push   %esi
f0102c14:	68 dc 4a 10 f0       	push   $0xf0104adc
f0102c19:	68 bb 01 00 00       	push   $0x1bb
f0102c1e:	68 4a 56 10 f0       	push   $0xf010564a
f0102c23:	e8 78 d4 ff ff       	call   f01000a0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102c28:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102c2b:	c1 e0 16             	shl    $0x16,%eax
f0102c2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102c31:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102c36:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102c3d:	01 
f0102c3e:	74 17                	je     f0102c57 <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102c40:	83 ec 08             	sub    $0x8,%esp
f0102c43:	89 d8                	mov    %ebx,%eax
f0102c45:	c1 e0 0c             	shl    $0xc,%eax
f0102c48:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102c4b:	50                   	push   %eax
f0102c4c:	ff 77 5c             	pushl  0x5c(%edi)
f0102c4f:	e8 ac e2 ff ff       	call   f0100f00 <page_remove>
f0102c54:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102c57:	83 c3 01             	add    $0x1,%ebx
f0102c5a:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102c60:	75 d4                	jne    f0102c36 <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102c62:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102c65:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102c68:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c6f:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0102c72:	3b 05 04 cb 17 f0    	cmp    0xf017cb04,%eax
f0102c78:	72 14                	jb     f0102c8e <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102c7a:	83 ec 04             	sub    $0x4,%esp
f0102c7d:	68 0c 4c 10 f0       	push   $0xf0104c0c
f0102c82:	6a 4f                	push   $0x4f
f0102c84:	68 c9 52 10 f0       	push   $0xf01052c9
f0102c89:	e8 12 d4 ff ff       	call   f01000a0 <_panic>
		page_decref(pa2page(pa));
f0102c8e:	83 ec 0c             	sub    $0xc,%esp
f0102c91:	a1 0c cb 17 f0       	mov    0xf017cb0c,%eax
f0102c96:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102c99:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102c9c:	50                   	push   %eax
f0102c9d:	e8 f0 e0 ff ff       	call   f0100d92 <page_decref>
f0102ca2:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102ca5:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102ca9:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102cac:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0102cb1:	0f 85 29 ff ff ff    	jne    f0102be0 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102cb7:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102cba:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102cbf:	77 15                	ja     f0102cd6 <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102cc1:	50                   	push   %eax
f0102cc2:	68 e8 4b 10 f0       	push   $0xf0104be8
f0102cc7:	68 c9 01 00 00       	push   $0x1c9
f0102ccc:	68 4a 56 10 f0       	push   $0xf010564a
f0102cd1:	e8 ca d3 ff ff       	call   f01000a0 <_panic>
	e->env_pgdir = 0;
f0102cd6:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cdd:	05 00 00 00 10       	add    $0x10000000,%eax
f0102ce2:	c1 e8 0c             	shr    $0xc,%eax
f0102ce5:	3b 05 04 cb 17 f0    	cmp    0xf017cb04,%eax
f0102ceb:	72 14                	jb     f0102d01 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0102ced:	83 ec 04             	sub    $0x4,%esp
f0102cf0:	68 0c 4c 10 f0       	push   $0xf0104c0c
f0102cf5:	6a 4f                	push   $0x4f
f0102cf7:	68 c9 52 10 f0       	push   $0xf01052c9
f0102cfc:	e8 9f d3 ff ff       	call   f01000a0 <_panic>
	page_decref(pa2page(pa));
f0102d01:	83 ec 0c             	sub    $0xc,%esp
f0102d04:	8b 15 0c cb 17 f0    	mov    0xf017cb0c,%edx
f0102d0a:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0102d0d:	50                   	push   %eax
f0102d0e:	e8 7f e0 ff ff       	call   f0100d92 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0102d13:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0102d1a:	a1 50 be 17 f0       	mov    0xf017be50,%eax
f0102d1f:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0102d22:	89 3d 50 be 17 f0    	mov    %edi,0xf017be50
}
f0102d28:	83 c4 10             	add    $0x10,%esp
f0102d2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d2e:	5b                   	pop    %ebx
f0102d2f:	5e                   	pop    %esi
f0102d30:	5f                   	pop    %edi
f0102d31:	5d                   	pop    %ebp
f0102d32:	c3                   	ret    

f0102d33 <env_destroy>:
//
// Frees environment e.
//
void
env_destroy(struct Env *e)
{
f0102d33:	55                   	push   %ebp
f0102d34:	89 e5                	mov    %esp,%ebp
f0102d36:	83 ec 14             	sub    $0x14,%esp
	env_free(e);
f0102d39:	ff 75 08             	pushl  0x8(%ebp)
f0102d3c:	e8 36 fe ff ff       	call   f0102b77 <env_free>

	cprintf("Destroyed the only environment - nothing more to do!\n");
f0102d41:	c7 04 24 14 56 10 f0 	movl   $0xf0105614,(%esp)
f0102d48:	e8 ff 00 00 00       	call   f0102e4c <cprintf>
f0102d4d:	83 c4 10             	add    $0x10,%esp
	while (1)
		monitor(NULL);
f0102d50:	83 ec 0c             	sub    $0xc,%esp
f0102d53:	6a 00                	push   $0x0
f0102d55:	e8 d8 d9 ff ff       	call   f0100732 <monitor>
f0102d5a:	83 c4 10             	add    $0x10,%esp
f0102d5d:	eb f1                	jmp    f0102d50 <env_destroy+0x1d>

f0102d5f <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0102d5f:	55                   	push   %ebp
f0102d60:	89 e5                	mov    %esp,%ebp
f0102d62:	83 ec 0c             	sub    $0xc,%esp
	asm volatile(
f0102d65:	8b 65 08             	mov    0x8(%ebp),%esp
f0102d68:	61                   	popa   
f0102d69:	07                   	pop    %es
f0102d6a:	1f                   	pop    %ds
f0102d6b:	83 c4 08             	add    $0x8,%esp
f0102d6e:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0102d6f:	68 8f 56 10 f0       	push   $0xf010568f
f0102d74:	68 f2 01 00 00       	push   $0x1f2
f0102d79:	68 4a 56 10 f0       	push   $0xf010564a
f0102d7e:	e8 1d d3 ff ff       	call   f01000a0 <_panic>

f0102d83 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0102d83:	55                   	push   %ebp
f0102d84:	89 e5                	mov    %esp,%ebp
f0102d86:	83 ec 08             	sub    $0x8,%esp
f0102d89:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.

	//panic("env_run not yet implemented");
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0102d8c:	8b 15 48 be 17 f0    	mov    0xf017be48,%edx
f0102d92:	85 d2                	test   %edx,%edx
f0102d94:	74 0d                	je     f0102da3 <env_run+0x20>
f0102d96:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f0102d9a:	75 07                	jne    f0102da3 <env_run+0x20>
		curenv->env_status = ENV_RUNNABLE;
f0102d9c:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	curenv = e;
f0102da3:	a3 48 be 17 f0       	mov    %eax,0xf017be48
	curenv->env_status = ENV_RUNNING;
f0102da8:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0102daf:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(curenv->env_pgdir));
f0102db3:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102db6:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102dbc:	77 15                	ja     f0102dd3 <env_run+0x50>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102dbe:	52                   	push   %edx
f0102dbf:	68 e8 4b 10 f0       	push   $0xf0104be8
f0102dc4:	68 17 02 00 00       	push   $0x217
f0102dc9:	68 4a 56 10 f0       	push   $0xf010564a
f0102dce:	e8 cd d2 ff ff       	call   f01000a0 <_panic>
f0102dd3:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0102dd9:	0f 22 da             	mov    %edx,%cr3

	env_pop_tf(&curenv->env_tf);
f0102ddc:	83 ec 0c             	sub    $0xc,%esp
f0102ddf:	50                   	push   %eax
f0102de0:	e8 7a ff ff ff       	call   f0102d5f <env_pop_tf>

f0102de5 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0102de5:	55                   	push   %ebp
f0102de6:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102de8:	ba 70 00 00 00       	mov    $0x70,%edx
f0102ded:	8b 45 08             	mov    0x8(%ebp),%eax
f0102df0:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0102df1:	ba 71 00 00 00       	mov    $0x71,%edx
f0102df6:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0102df7:	0f b6 c0             	movzbl %al,%eax
}
f0102dfa:	5d                   	pop    %ebp
f0102dfb:	c3                   	ret    

f0102dfc <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0102dfc:	55                   	push   %ebp
f0102dfd:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0102dff:	ba 70 00 00 00       	mov    $0x70,%edx
f0102e04:	8b 45 08             	mov    0x8(%ebp),%eax
f0102e07:	ee                   	out    %al,(%dx)
f0102e08:	ba 71 00 00 00       	mov    $0x71,%edx
f0102e0d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102e10:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0102e11:	5d                   	pop    %ebp
f0102e12:	c3                   	ret    

f0102e13 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0102e13:	55                   	push   %ebp
f0102e14:	89 e5                	mov    %esp,%ebp
f0102e16:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0102e19:	ff 75 08             	pushl  0x8(%ebp)
f0102e1c:	e8 f4 d7 ff ff       	call   f0100615 <cputchar>
	*cnt++;
}
f0102e21:	83 c4 10             	add    $0x10,%esp
f0102e24:	c9                   	leave  
f0102e25:	c3                   	ret    

f0102e26 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0102e26:	55                   	push   %ebp
f0102e27:	89 e5                	mov    %esp,%ebp
f0102e29:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0102e2c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0102e33:	ff 75 0c             	pushl  0xc(%ebp)
f0102e36:	ff 75 08             	pushl  0x8(%ebp)
f0102e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0102e3c:	50                   	push   %eax
f0102e3d:	68 13 2e 10 f0       	push   $0xf0102e13
f0102e42:	e8 3f 0c 00 00       	call   f0103a86 <vprintfmt>
	return cnt;
}
f0102e47:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0102e4a:	c9                   	leave  
f0102e4b:	c3                   	ret    

f0102e4c <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0102e4c:	55                   	push   %ebp
f0102e4d:	89 e5                	mov    %esp,%ebp
f0102e4f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f0102e52:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f0102e55:	50                   	push   %eax
f0102e56:	ff 75 08             	pushl  0x8(%ebp)
f0102e59:	e8 c8 ff ff ff       	call   f0102e26 <vcprintf>
	va_end(ap);

	return cnt;
}
f0102e5e:	c9                   	leave  
f0102e5f:	c3                   	ret    

f0102e60 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0102e60:	55                   	push   %ebp
f0102e61:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0102e63:	b8 80 c6 17 f0       	mov    $0xf017c680,%eax
f0102e68:	c7 05 84 c6 17 f0 00 	movl   $0xf0000000,0xf017c684
f0102e6f:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0102e72:	66 c7 05 88 c6 17 f0 	movw   $0x10,0xf017c688
f0102e79:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0102e7b:	66 c7 05 48 a3 11 f0 	movw   $0x67,0xf011a348
f0102e82:	67 00 
f0102e84:	66 a3 4a a3 11 f0    	mov    %ax,0xf011a34a
f0102e8a:	89 c2                	mov    %eax,%edx
f0102e8c:	c1 ea 10             	shr    $0x10,%edx
f0102e8f:	88 15 4c a3 11 f0    	mov    %dl,0xf011a34c
f0102e95:	c6 05 4e a3 11 f0 40 	movb   $0x40,0xf011a34e
f0102e9c:	c1 e8 18             	shr    $0x18,%eax
f0102e9f:	a2 4f a3 11 f0       	mov    %al,0xf011a34f
					sizeof(struct Taskstate) - 1, 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0102ea4:	c6 05 4d a3 11 f0 89 	movb   $0x89,0xf011a34d
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0102eab:	b8 28 00 00 00       	mov    $0x28,%eax
f0102eb0:	0f 00 d8             	ltr    %ax
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f0102eb3:	b8 50 a3 11 f0       	mov    $0xf011a350,%eax
f0102eb8:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0102ebb:	5d                   	pop    %ebp
f0102ebc:	c3                   	ret    

f0102ebd <trap_init>:
}


void
trap_init(void)
{
f0102ebd:	55                   	push   %ebp
f0102ebe:	89 e5                	mov    %esp,%ebp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0102ec0:	b8 92 35 10 f0       	mov    $0xf0103592,%eax
f0102ec5:	66 a3 60 be 17 f0    	mov    %ax,0xf017be60
f0102ecb:	66 c7 05 62 be 17 f0 	movw   $0x8,0xf017be62
f0102ed2:	08 00 
f0102ed4:	c6 05 64 be 17 f0 00 	movb   $0x0,0xf017be64
f0102edb:	c6 05 65 be 17 f0 8e 	movb   $0x8e,0xf017be65
f0102ee2:	c1 e8 10             	shr    $0x10,%eax
f0102ee5:	66 a3 66 be 17 f0    	mov    %ax,0xf017be66
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0102eeb:	b8 98 35 10 f0       	mov    $0xf0103598,%eax
f0102ef0:	66 a3 68 be 17 f0    	mov    %ax,0xf017be68
f0102ef6:	66 c7 05 6a be 17 f0 	movw   $0x8,0xf017be6a
f0102efd:	08 00 
f0102eff:	c6 05 6c be 17 f0 00 	movb   $0x0,0xf017be6c
f0102f06:	c6 05 6d be 17 f0 8e 	movb   $0x8e,0xf017be6d
f0102f0d:	c1 e8 10             	shr    $0x10,%eax
f0102f10:	66 a3 6e be 17 f0    	mov    %ax,0xf017be6e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f0102f16:	b8 9e 35 10 f0       	mov    $0xf010359e,%eax
f0102f1b:	66 a3 70 be 17 f0    	mov    %ax,0xf017be70
f0102f21:	66 c7 05 72 be 17 f0 	movw   $0x8,0xf017be72
f0102f28:	08 00 
f0102f2a:	c6 05 74 be 17 f0 00 	movb   $0x0,0xf017be74
f0102f31:	c6 05 75 be 17 f0 8e 	movb   $0x8e,0xf017be75
f0102f38:	c1 e8 10             	shr    $0x10,%eax
f0102f3b:	66 a3 76 be 17 f0    	mov    %ax,0xf017be76
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f0102f41:	b8 a4 35 10 f0       	mov    $0xf01035a4,%eax
f0102f46:	66 a3 78 be 17 f0    	mov    %ax,0xf017be78
f0102f4c:	66 c7 05 7a be 17 f0 	movw   $0x8,0xf017be7a
f0102f53:	08 00 
f0102f55:	c6 05 7c be 17 f0 00 	movb   $0x0,0xf017be7c
f0102f5c:	c6 05 7d be 17 f0 ee 	movb   $0xee,0xf017be7d
f0102f63:	c1 e8 10             	shr    $0x10,%eax
f0102f66:	66 a3 7e be 17 f0    	mov    %ax,0xf017be7e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f0102f6c:	b8 aa 35 10 f0       	mov    $0xf01035aa,%eax
f0102f71:	66 a3 80 be 17 f0    	mov    %ax,0xf017be80
f0102f77:	66 c7 05 82 be 17 f0 	movw   $0x8,0xf017be82
f0102f7e:	08 00 
f0102f80:	c6 05 84 be 17 f0 00 	movb   $0x0,0xf017be84
f0102f87:	c6 05 85 be 17 f0 8e 	movb   $0x8e,0xf017be85
f0102f8e:	c1 e8 10             	shr    $0x10,%eax
f0102f91:	66 a3 86 be 17 f0    	mov    %ax,0xf017be86
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0102f97:	b8 b0 35 10 f0       	mov    $0xf01035b0,%eax
f0102f9c:	66 a3 88 be 17 f0    	mov    %ax,0xf017be88
f0102fa2:	66 c7 05 8a be 17 f0 	movw   $0x8,0xf017be8a
f0102fa9:	08 00 
f0102fab:	c6 05 8c be 17 f0 00 	movb   $0x0,0xf017be8c
f0102fb2:	c6 05 8d be 17 f0 8e 	movb   $0x8e,0xf017be8d
f0102fb9:	c1 e8 10             	shr    $0x10,%eax
f0102fbc:	66 a3 8e be 17 f0    	mov    %ax,0xf017be8e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0102fc2:	b8 b6 35 10 f0       	mov    $0xf01035b6,%eax
f0102fc7:	66 a3 90 be 17 f0    	mov    %ax,0xf017be90
f0102fcd:	66 c7 05 92 be 17 f0 	movw   $0x8,0xf017be92
f0102fd4:	08 00 
f0102fd6:	c6 05 94 be 17 f0 00 	movb   $0x0,0xf017be94
f0102fdd:	c6 05 95 be 17 f0 8e 	movb   $0x8e,0xf017be95
f0102fe4:	c1 e8 10             	shr    $0x10,%eax
f0102fe7:	66 a3 96 be 17 f0    	mov    %ax,0xf017be96
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0102fed:	b8 bc 35 10 f0       	mov    $0xf01035bc,%eax
f0102ff2:	66 a3 98 be 17 f0    	mov    %ax,0xf017be98
f0102ff8:	66 c7 05 9a be 17 f0 	movw   $0x8,0xf017be9a
f0102fff:	08 00 
f0103001:	c6 05 9c be 17 f0 00 	movb   $0x0,0xf017be9c
f0103008:	c6 05 9d be 17 f0 8e 	movb   $0x8e,0xf017be9d
f010300f:	c1 e8 10             	shr    $0x10,%eax
f0103012:	66 a3 9e be 17 f0    	mov    %ax,0xf017be9e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f0103018:	b8 c2 35 10 f0       	mov    $0xf01035c2,%eax
f010301d:	66 a3 a0 be 17 f0    	mov    %ax,0xf017bea0
f0103023:	66 c7 05 a2 be 17 f0 	movw   $0x8,0xf017bea2
f010302a:	08 00 
f010302c:	c6 05 a4 be 17 f0 00 	movb   $0x0,0xf017bea4
f0103033:	c6 05 a5 be 17 f0 8e 	movb   $0x8e,0xf017bea5
f010303a:	c1 e8 10             	shr    $0x10,%eax
f010303d:	66 a3 a6 be 17 f0    	mov    %ax,0xf017bea6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f0103043:	b8 c6 35 10 f0       	mov    $0xf01035c6,%eax
f0103048:	66 a3 b0 be 17 f0    	mov    %ax,0xf017beb0
f010304e:	66 c7 05 b2 be 17 f0 	movw   $0x8,0xf017beb2
f0103055:	08 00 
f0103057:	c6 05 b4 be 17 f0 00 	movb   $0x0,0xf017beb4
f010305e:	c6 05 b5 be 17 f0 8e 	movb   $0x8e,0xf017beb5
f0103065:	c1 e8 10             	shr    $0x10,%eax
f0103068:	66 a3 b6 be 17 f0    	mov    %ax,0xf017beb6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f010306e:	b8 ca 35 10 f0       	mov    $0xf01035ca,%eax
f0103073:	66 a3 b8 be 17 f0    	mov    %ax,0xf017beb8
f0103079:	66 c7 05 ba be 17 f0 	movw   $0x8,0xf017beba
f0103080:	08 00 
f0103082:	c6 05 bc be 17 f0 00 	movb   $0x0,0xf017bebc
f0103089:	c6 05 bd be 17 f0 8e 	movb   $0x8e,0xf017bebd
f0103090:	c1 e8 10             	shr    $0x10,%eax
f0103093:	66 a3 be be 17 f0    	mov    %ax,0xf017bebe
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f0103099:	b8 ce 35 10 f0       	mov    $0xf01035ce,%eax
f010309e:	66 a3 c0 be 17 f0    	mov    %ax,0xf017bec0
f01030a4:	66 c7 05 c2 be 17 f0 	movw   $0x8,0xf017bec2
f01030ab:	08 00 
f01030ad:	c6 05 c4 be 17 f0 00 	movb   $0x0,0xf017bec4
f01030b4:	c6 05 c5 be 17 f0 8e 	movb   $0x8e,0xf017bec5
f01030bb:	c1 e8 10             	shr    $0x10,%eax
f01030be:	66 a3 c6 be 17 f0    	mov    %ax,0xf017bec6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f01030c4:	b8 d2 35 10 f0       	mov    $0xf01035d2,%eax
f01030c9:	66 a3 c8 be 17 f0    	mov    %ax,0xf017bec8
f01030cf:	66 c7 05 ca be 17 f0 	movw   $0x8,0xf017beca
f01030d6:	08 00 
f01030d8:	c6 05 cc be 17 f0 00 	movb   $0x0,0xf017becc
f01030df:	c6 05 cd be 17 f0 8e 	movb   $0x8e,0xf017becd
f01030e6:	c1 e8 10             	shr    $0x10,%eax
f01030e9:	66 a3 ce be 17 f0    	mov    %ax,0xf017bece
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01030ef:	b8 d6 35 10 f0       	mov    $0xf01035d6,%eax
f01030f4:	66 a3 d0 be 17 f0    	mov    %ax,0xf017bed0
f01030fa:	66 c7 05 d2 be 17 f0 	movw   $0x8,0xf017bed2
f0103101:	08 00 
f0103103:	c6 05 d4 be 17 f0 00 	movb   $0x0,0xf017bed4
f010310a:	c6 05 d5 be 17 f0 8e 	movb   $0x8e,0xf017bed5
f0103111:	c1 e8 10             	shr    $0x10,%eax
f0103114:	66 a3 d6 be 17 f0    	mov    %ax,0xf017bed6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f010311a:	b8 da 35 10 f0       	mov    $0xf01035da,%eax
f010311f:	66 a3 e0 be 17 f0    	mov    %ax,0xf017bee0
f0103125:	66 c7 05 e2 be 17 f0 	movw   $0x8,0xf017bee2
f010312c:	08 00 
f010312e:	c6 05 e4 be 17 f0 00 	movb   $0x0,0xf017bee4
f0103135:	c6 05 e5 be 17 f0 8e 	movb   $0x8e,0xf017bee5
f010313c:	c1 e8 10             	shr    $0x10,%eax
f010313f:	66 a3 e6 be 17 f0    	mov    %ax,0xf017bee6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f0103145:	b8 e0 35 10 f0       	mov    $0xf01035e0,%eax
f010314a:	66 a3 e8 be 17 f0    	mov    %ax,0xf017bee8
f0103150:	66 c7 05 ea be 17 f0 	movw   $0x8,0xf017beea
f0103157:	08 00 
f0103159:	c6 05 ec be 17 f0 00 	movb   $0x0,0xf017beec
f0103160:	c6 05 ed be 17 f0 8e 	movb   $0x8e,0xf017beed
f0103167:	c1 e8 10             	shr    $0x10,%eax
f010316a:	66 a3 ee be 17 f0    	mov    %ax,0xf017beee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103170:	b8 e4 35 10 f0       	mov    $0xf01035e4,%eax
f0103175:	66 a3 f0 be 17 f0    	mov    %ax,0xf017bef0
f010317b:	66 c7 05 f2 be 17 f0 	movw   $0x8,0xf017bef2
f0103182:	08 00 
f0103184:	c6 05 f4 be 17 f0 00 	movb   $0x0,0xf017bef4
f010318b:	c6 05 f5 be 17 f0 8e 	movb   $0x8e,0xf017bef5
f0103192:	c1 e8 10             	shr    $0x10,%eax
f0103195:	66 a3 f6 be 17 f0    	mov    %ax,0xf017bef6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f010319b:	b8 ea 35 10 f0       	mov    $0xf01035ea,%eax
f01031a0:	66 a3 f8 be 17 f0    	mov    %ax,0xf017bef8
f01031a6:	66 c7 05 fa be 17 f0 	movw   $0x8,0xf017befa
f01031ad:	08 00 
f01031af:	c6 05 fc be 17 f0 00 	movb   $0x0,0xf017befc
f01031b6:	c6 05 fd be 17 f0 8e 	movb   $0x8e,0xf017befd
f01031bd:	c1 e8 10             	shr    $0x10,%eax
f01031c0:	66 a3 fe be 17 f0    	mov    %ax,0xf017befe

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f01031c6:	b8 f0 35 10 f0       	mov    $0xf01035f0,%eax
f01031cb:	66 a3 e0 bf 17 f0    	mov    %ax,0xf017bfe0
f01031d1:	66 c7 05 e2 bf 17 f0 	movw   $0x8,0xf017bfe2
f01031d8:	08 00 
f01031da:	c6 05 e4 bf 17 f0 00 	movb   $0x0,0xf017bfe4
f01031e1:	c6 05 e5 bf 17 f0 ee 	movb   $0xee,0xf017bfe5
f01031e8:	c1 e8 10             	shr    $0x10,%eax
f01031eb:	66 a3 e6 bf 17 f0    	mov    %ax,0xf017bfe6

	// Per-CPU setup 
	trap_init_percpu();
f01031f1:	e8 6a fc ff ff       	call   f0102e60 <trap_init_percpu>
}
f01031f6:	5d                   	pop    %ebp
f01031f7:	c3                   	ret    

f01031f8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01031f8:	55                   	push   %ebp
f01031f9:	89 e5                	mov    %esp,%ebp
f01031fb:	53                   	push   %ebx
f01031fc:	83 ec 0c             	sub    $0xc,%esp
f01031ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103202:	ff 33                	pushl  (%ebx)
f0103204:	68 9b 56 10 f0       	push   $0xf010569b
f0103209:	e8 3e fc ff ff       	call   f0102e4c <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f010320e:	83 c4 08             	add    $0x8,%esp
f0103211:	ff 73 04             	pushl  0x4(%ebx)
f0103214:	68 aa 56 10 f0       	push   $0xf01056aa
f0103219:	e8 2e fc ff ff       	call   f0102e4c <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f010321e:	83 c4 08             	add    $0x8,%esp
f0103221:	ff 73 08             	pushl  0x8(%ebx)
f0103224:	68 b9 56 10 f0       	push   $0xf01056b9
f0103229:	e8 1e fc ff ff       	call   f0102e4c <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010322e:	83 c4 08             	add    $0x8,%esp
f0103231:	ff 73 0c             	pushl  0xc(%ebx)
f0103234:	68 c8 56 10 f0       	push   $0xf01056c8
f0103239:	e8 0e fc ff ff       	call   f0102e4c <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010323e:	83 c4 08             	add    $0x8,%esp
f0103241:	ff 73 10             	pushl  0x10(%ebx)
f0103244:	68 d7 56 10 f0       	push   $0xf01056d7
f0103249:	e8 fe fb ff ff       	call   f0102e4c <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f010324e:	83 c4 08             	add    $0x8,%esp
f0103251:	ff 73 14             	pushl  0x14(%ebx)
f0103254:	68 e6 56 10 f0       	push   $0xf01056e6
f0103259:	e8 ee fb ff ff       	call   f0102e4c <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f010325e:	83 c4 08             	add    $0x8,%esp
f0103261:	ff 73 18             	pushl  0x18(%ebx)
f0103264:	68 f5 56 10 f0       	push   $0xf01056f5
f0103269:	e8 de fb ff ff       	call   f0102e4c <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f010326e:	83 c4 08             	add    $0x8,%esp
f0103271:	ff 73 1c             	pushl  0x1c(%ebx)
f0103274:	68 04 57 10 f0       	push   $0xf0105704
f0103279:	e8 ce fb ff ff       	call   f0102e4c <cprintf>
}
f010327e:	83 c4 10             	add    $0x10,%esp
f0103281:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103284:	c9                   	leave  
f0103285:	c3                   	ret    

f0103286 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103286:	55                   	push   %ebp
f0103287:	89 e5                	mov    %esp,%ebp
f0103289:	56                   	push   %esi
f010328a:	53                   	push   %ebx
f010328b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f010328e:	83 ec 08             	sub    $0x8,%esp
f0103291:	53                   	push   %ebx
f0103292:	68 3a 58 10 f0       	push   $0xf010583a
f0103297:	e8 b0 fb ff ff       	call   f0102e4c <cprintf>
	print_regs(&tf->tf_regs);
f010329c:	89 1c 24             	mov    %ebx,(%esp)
f010329f:	e8 54 ff ff ff       	call   f01031f8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01032a4:	83 c4 08             	add    $0x8,%esp
f01032a7:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01032ab:	50                   	push   %eax
f01032ac:	68 55 57 10 f0       	push   $0xf0105755
f01032b1:	e8 96 fb ff ff       	call   f0102e4c <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01032b6:	83 c4 08             	add    $0x8,%esp
f01032b9:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01032bd:	50                   	push   %eax
f01032be:	68 68 57 10 f0       	push   $0xf0105768
f01032c3:	e8 84 fb ff ff       	call   f0102e4c <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01032c8:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f01032cb:	83 c4 10             	add    $0x10,%esp
f01032ce:	83 f8 13             	cmp    $0x13,%eax
f01032d1:	77 09                	ja     f01032dc <print_trapframe+0x56>
		return excnames[trapno];
f01032d3:	8b 14 85 40 5a 10 f0 	mov    -0xfefa5c0(,%eax,4),%edx
f01032da:	eb 10                	jmp    f01032ec <print_trapframe+0x66>
	if (trapno == T_SYSCALL)
		return "System call";
	return "(unknown trap)";
f01032dc:	83 f8 30             	cmp    $0x30,%eax
f01032df:	b9 1f 57 10 f0       	mov    $0xf010571f,%ecx
f01032e4:	ba 13 57 10 f0       	mov    $0xf0105713,%edx
f01032e9:	0f 45 d1             	cmovne %ecx,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01032ec:	83 ec 04             	sub    $0x4,%esp
f01032ef:	52                   	push   %edx
f01032f0:	50                   	push   %eax
f01032f1:	68 7b 57 10 f0       	push   $0xf010577b
f01032f6:	e8 51 fb ff ff       	call   f0102e4c <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f01032fb:	83 c4 10             	add    $0x10,%esp
f01032fe:	3b 1d 60 c6 17 f0    	cmp    0xf017c660,%ebx
f0103304:	75 1a                	jne    f0103320 <print_trapframe+0x9a>
f0103306:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010330a:	75 14                	jne    f0103320 <print_trapframe+0x9a>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f010330c:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f010330f:	83 ec 08             	sub    $0x8,%esp
f0103312:	50                   	push   %eax
f0103313:	68 8d 57 10 f0       	push   $0xf010578d
f0103318:	e8 2f fb ff ff       	call   f0102e4c <cprintf>
f010331d:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103320:	83 ec 08             	sub    $0x8,%esp
f0103323:	ff 73 2c             	pushl  0x2c(%ebx)
f0103326:	68 9c 57 10 f0       	push   $0xf010579c
f010332b:	e8 1c fb ff ff       	call   f0102e4c <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103330:	83 c4 10             	add    $0x10,%esp
f0103333:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103337:	75 49                	jne    f0103382 <print_trapframe+0xfc>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103339:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f010333c:	89 c2                	mov    %eax,%edx
f010333e:	83 e2 01             	and    $0x1,%edx
f0103341:	ba 39 57 10 f0       	mov    $0xf0105739,%edx
f0103346:	b9 2e 57 10 f0       	mov    $0xf010572e,%ecx
f010334b:	0f 44 ca             	cmove  %edx,%ecx
f010334e:	89 c2                	mov    %eax,%edx
f0103350:	83 e2 02             	and    $0x2,%edx
f0103353:	ba 4b 57 10 f0       	mov    $0xf010574b,%edx
f0103358:	be 45 57 10 f0       	mov    $0xf0105745,%esi
f010335d:	0f 45 d6             	cmovne %esi,%edx
f0103360:	83 e0 04             	and    $0x4,%eax
f0103363:	be 65 58 10 f0       	mov    $0xf0105865,%esi
f0103368:	b8 50 57 10 f0       	mov    $0xf0105750,%eax
f010336d:	0f 44 c6             	cmove  %esi,%eax
f0103370:	51                   	push   %ecx
f0103371:	52                   	push   %edx
f0103372:	50                   	push   %eax
f0103373:	68 aa 57 10 f0       	push   $0xf01057aa
f0103378:	e8 cf fa ff ff       	call   f0102e4c <cprintf>
f010337d:	83 c4 10             	add    $0x10,%esp
f0103380:	eb 10                	jmp    f0103392 <print_trapframe+0x10c>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103382:	83 ec 0c             	sub    $0xc,%esp
f0103385:	68 9d 55 10 f0       	push   $0xf010559d
f010338a:	e8 bd fa ff ff       	call   f0102e4c <cprintf>
f010338f:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103392:	83 ec 08             	sub    $0x8,%esp
f0103395:	ff 73 30             	pushl  0x30(%ebx)
f0103398:	68 b9 57 10 f0       	push   $0xf01057b9
f010339d:	e8 aa fa ff ff       	call   f0102e4c <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01033a2:	83 c4 08             	add    $0x8,%esp
f01033a5:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01033a9:	50                   	push   %eax
f01033aa:	68 c8 57 10 f0       	push   $0xf01057c8
f01033af:	e8 98 fa ff ff       	call   f0102e4c <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01033b4:	83 c4 08             	add    $0x8,%esp
f01033b7:	ff 73 38             	pushl  0x38(%ebx)
f01033ba:	68 db 57 10 f0       	push   $0xf01057db
f01033bf:	e8 88 fa ff ff       	call   f0102e4c <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01033c4:	83 c4 10             	add    $0x10,%esp
f01033c7:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f01033cb:	74 25                	je     f01033f2 <print_trapframe+0x16c>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f01033cd:	83 ec 08             	sub    $0x8,%esp
f01033d0:	ff 73 3c             	pushl  0x3c(%ebx)
f01033d3:	68 ea 57 10 f0       	push   $0xf01057ea
f01033d8:	e8 6f fa ff ff       	call   f0102e4c <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f01033dd:	83 c4 08             	add    $0x8,%esp
f01033e0:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f01033e4:	50                   	push   %eax
f01033e5:	68 f9 57 10 f0       	push   $0xf01057f9
f01033ea:	e8 5d fa ff ff       	call   f0102e4c <cprintf>
f01033ef:	83 c4 10             	add    $0x10,%esp
	}
}
f01033f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01033f5:	5b                   	pop    %ebx
f01033f6:	5e                   	pop    %esi
f01033f7:	5d                   	pop    %ebp
f01033f8:	c3                   	ret    

f01033f9 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f01033f9:	55                   	push   %ebp
f01033fa:	89 e5                	mov    %esp,%ebp
f01033fc:	53                   	push   %ebx
f01033fd:	83 ec 04             	sub    $0x4,%esp
f0103400:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103403:	0f 20 d0             	mov    %cr2,%eax
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 0x3) == 0) 
f0103406:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f010340a:	75 17                	jne    f0103423 <page_fault_handler+0x2a>
		panic("page_fault_handler: page fault in kernel mode");
f010340c:	83 ec 04             	sub    $0x4,%esp
f010340f:	68 b0 59 10 f0       	push   $0xf01059b0
f0103414:	68 14 01 00 00       	push   $0x114
f0103419:	68 0c 58 10 f0       	push   $0xf010580c
f010341e:	e8 7d cc ff ff       	call   f01000a0 <_panic>

	// We've already handled kernel-mode exceptions, so if we get here,
	// the page fault happened in user mode.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103423:	ff 73 30             	pushl  0x30(%ebx)
f0103426:	50                   	push   %eax
f0103427:	a1 48 be 17 f0       	mov    0xf017be48,%eax
f010342c:	ff 70 48             	pushl  0x48(%eax)
f010342f:	68 e0 59 10 f0       	push   $0xf01059e0
f0103434:	e8 13 fa ff ff       	call   f0102e4c <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103439:	89 1c 24             	mov    %ebx,(%esp)
f010343c:	e8 45 fe ff ff       	call   f0103286 <print_trapframe>
	env_destroy(curenv);
f0103441:	83 c4 04             	add    $0x4,%esp
f0103444:	ff 35 48 be 17 f0    	pushl  0xf017be48
f010344a:	e8 e4 f8 ff ff       	call   f0102d33 <env_destroy>
}
f010344f:	83 c4 10             	add    $0x10,%esp
f0103452:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103455:	c9                   	leave  
f0103456:	c3                   	ret    

f0103457 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103457:	55                   	push   %ebp
f0103458:	89 e5                	mov    %esp,%ebp
f010345a:	57                   	push   %edi
f010345b:	56                   	push   %esi
f010345c:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f010345f:	fc                   	cld    

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103460:	9c                   	pushf  
f0103461:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103462:	f6 c4 02             	test   $0x2,%ah
f0103465:	74 19                	je     f0103480 <trap+0x29>
f0103467:	68 18 58 10 f0       	push   $0xf0105818
f010346c:	68 e3 52 10 f0       	push   $0xf01052e3
f0103471:	68 eb 00 00 00       	push   $0xeb
f0103476:	68 0c 58 10 f0       	push   $0xf010580c
f010347b:	e8 20 cc ff ff       	call   f01000a0 <_panic>

	cprintf("Incoming TRAP frame at %p\n", tf);
f0103480:	83 ec 08             	sub    $0x8,%esp
f0103483:	56                   	push   %esi
f0103484:	68 31 58 10 f0       	push   $0xf0105831
f0103489:	e8 be f9 ff ff       	call   f0102e4c <cprintf>

	if ((tf->tf_cs & 3) == 3) {
f010348e:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103492:	83 e0 03             	and    $0x3,%eax
f0103495:	83 c4 10             	add    $0x10,%esp
f0103498:	66 83 f8 03          	cmp    $0x3,%ax
f010349c:	75 31                	jne    f01034cf <trap+0x78>
		// Trapped from user mode.
		assert(curenv);
f010349e:	a1 48 be 17 f0       	mov    0xf017be48,%eax
f01034a3:	85 c0                	test   %eax,%eax
f01034a5:	75 19                	jne    f01034c0 <trap+0x69>
f01034a7:	68 4c 58 10 f0       	push   $0xf010584c
f01034ac:	68 e3 52 10 f0       	push   $0xf01052e3
f01034b1:	68 f1 00 00 00       	push   $0xf1
f01034b6:	68 0c 58 10 f0       	push   $0xf010580c
f01034bb:	e8 e0 cb ff ff       	call   f01000a0 <_panic>

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01034c0:	b9 11 00 00 00       	mov    $0x11,%ecx
f01034c5:	89 c7                	mov    %eax,%edi
f01034c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01034c9:	8b 35 48 be 17 f0    	mov    0xf017be48,%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01034cf:	89 35 60 c6 17 f0    	mov    %esi,0xf017c660
	// 	panic("unhandled trap in kernel");
	// else {
	// 	env_destroy(curenv);
	// 	return;
	// }
	switch(tf->tf_trapno){
f01034d5:	8b 46 28             	mov    0x28(%esi),%eax
f01034d8:	83 f8 0e             	cmp    $0xe,%eax
f01034db:	74 0c                	je     f01034e9 <trap+0x92>
f01034dd:	83 f8 30             	cmp    $0x30,%eax
f01034e0:	74 23                	je     f0103505 <trap+0xae>
f01034e2:	83 f8 03             	cmp    $0x3,%eax
f01034e5:	75 3f                	jne    f0103526 <trap+0xcf>
f01034e7:	eb 0e                	jmp    f01034f7 <trap+0xa0>
		case(T_PGFLT):
			page_fault_handler(tf);
f01034e9:	83 ec 0c             	sub    $0xc,%esp
f01034ec:	56                   	push   %esi
f01034ed:	e8 07 ff ff ff       	call   f01033f9 <page_fault_handler>
f01034f2:	83 c4 10             	add    $0x10,%esp
f01034f5:	eb 6a                	jmp    f0103561 <trap+0x10a>
			break;
		case(T_BRKPT):
			monitor(tf);
f01034f7:	83 ec 0c             	sub    $0xc,%esp
f01034fa:	56                   	push   %esi
f01034fb:	e8 32 d2 ff ff       	call   f0100732 <monitor>
f0103500:	83 c4 10             	add    $0x10,%esp
f0103503:	eb 5c                	jmp    f0103561 <trap+0x10a>
			break;
		case (T_SYSCALL):
			//print_trapframe(tf);

			tf->tf_regs.reg_eax = syscall(
f0103505:	83 ec 08             	sub    $0x8,%esp
f0103508:	ff 76 04             	pushl  0x4(%esi)
f010350b:	ff 36                	pushl  (%esi)
f010350d:	ff 76 10             	pushl  0x10(%esi)
f0103510:	ff 76 18             	pushl  0x18(%esi)
f0103513:	ff 76 14             	pushl  0x14(%esi)
f0103516:	ff 76 1c             	pushl  0x1c(%esi)
f0103519:	e8 ea 00 00 00       	call   f0103608 <syscall>
f010351e:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103521:	83 c4 20             	add    $0x20,%esp
f0103524:	eb 3b                	jmp    f0103561 <trap+0x10a>
					tf->tf_regs.reg_ebx,
					tf->tf_regs.reg_edi,
					tf->tf_regs.reg_esi);
			break;
		default:
			print_trapframe(tf);
f0103526:	83 ec 0c             	sub    $0xc,%esp
f0103529:	56                   	push   %esi
f010352a:	e8 57 fd ff ff       	call   f0103286 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f010352f:	83 c4 10             	add    $0x10,%esp
f0103532:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103537:	75 17                	jne    f0103550 <trap+0xf9>
				panic("unhandled trap in kernel");
f0103539:	83 ec 04             	sub    $0x4,%esp
f010353c:	68 53 58 10 f0       	push   $0xf0105853
f0103541:	68 d8 00 00 00       	push   $0xd8
f0103546:	68 0c 58 10 f0       	push   $0xf010580c
f010354b:	e8 50 cb ff ff       	call   f01000a0 <_panic>
			else {
				env_destroy(curenv);
f0103550:	83 ec 0c             	sub    $0xc,%esp
f0103553:	ff 35 48 be 17 f0    	pushl  0xf017be48
f0103559:	e8 d5 f7 ff ff       	call   f0102d33 <env_destroy>
f010355e:	83 c4 10             	add    $0x10,%esp

	// Dispatch based on what type of trap occurred
	trap_dispatch(tf);

	// Return to the current environment, which should be running.
	assert(curenv && curenv->env_status == ENV_RUNNING);
f0103561:	a1 48 be 17 f0       	mov    0xf017be48,%eax
f0103566:	85 c0                	test   %eax,%eax
f0103568:	74 06                	je     f0103570 <trap+0x119>
f010356a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010356e:	74 19                	je     f0103589 <trap+0x132>
f0103570:	68 04 5a 10 f0       	push   $0xf0105a04
f0103575:	68 e3 52 10 f0       	push   $0xf01052e3
f010357a:	68 03 01 00 00       	push   $0x103
f010357f:	68 0c 58 10 f0       	push   $0xf010580c
f0103584:	e8 17 cb ff ff       	call   f01000a0 <_panic>
	env_run(curenv);
f0103589:	83 ec 0c             	sub    $0xc,%esp
f010358c:	50                   	push   %eax
f010358d:	e8 f1 f7 ff ff       	call   f0102d83 <env_run>

f0103592 <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
//中断处理程序生成
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0103592:	6a 00                	push   $0x0
f0103594:	6a 00                	push   $0x0
f0103596:	eb 5e                	jmp    f01035f6 <_alltraps>

f0103598 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0103598:	6a 00                	push   $0x0
f010359a:	6a 01                	push   $0x1
f010359c:	eb 58                	jmp    f01035f6 <_alltraps>

f010359e <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f010359e:	6a 00                	push   $0x0
f01035a0:	6a 02                	push   $0x2
f01035a2:	eb 52                	jmp    f01035f6 <_alltraps>

f01035a4 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f01035a4:	6a 00                	push   $0x0
f01035a6:	6a 03                	push   $0x3
f01035a8:	eb 4c                	jmp    f01035f6 <_alltraps>

f01035aa <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f01035aa:	6a 00                	push   $0x0
f01035ac:	6a 04                	push   $0x4
f01035ae:	eb 46                	jmp    f01035f6 <_alltraps>

f01035b0 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f01035b0:	6a 00                	push   $0x0
f01035b2:	6a 05                	push   $0x5
f01035b4:	eb 40                	jmp    f01035f6 <_alltraps>

f01035b6 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f01035b6:	6a 00                	push   $0x0
f01035b8:	6a 06                	push   $0x6
f01035ba:	eb 3a                	jmp    f01035f6 <_alltraps>

f01035bc <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f01035bc:	6a 00                	push   $0x0
f01035be:	6a 07                	push   $0x7
f01035c0:	eb 34                	jmp    f01035f6 <_alltraps>

f01035c2 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f01035c2:	6a 08                	push   $0x8
f01035c4:	eb 30                	jmp    f01035f6 <_alltraps>

f01035c6 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f01035c6:	6a 0a                	push   $0xa
f01035c8:	eb 2c                	jmp    f01035f6 <_alltraps>

f01035ca <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f01035ca:	6a 0b                	push   $0xb
f01035cc:	eb 28                	jmp    f01035f6 <_alltraps>

f01035ce <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f01035ce:	6a 0c                	push   $0xc
f01035d0:	eb 24                	jmp    f01035f6 <_alltraps>

f01035d2 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f01035d2:	6a 0d                	push   $0xd
f01035d4:	eb 20                	jmp    f01035f6 <_alltraps>

f01035d6 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f01035d6:	6a 0e                	push   $0xe
f01035d8:	eb 1c                	jmp    f01035f6 <_alltraps>

f01035da <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f01035da:	6a 00                	push   $0x0
f01035dc:	6a 10                	push   $0x10
f01035de:	eb 16                	jmp    f01035f6 <_alltraps>

f01035e0 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f01035e0:	6a 11                	push   $0x11
f01035e2:	eb 12                	jmp    f01035f6 <_alltraps>

f01035e4 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f01035e4:	6a 00                	push   $0x0
f01035e6:	6a 12                	push   $0x12
f01035e8:	eb 0c                	jmp    f01035f6 <_alltraps>

f01035ea <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f01035ea:	6a 00                	push   $0x0
f01035ec:	6a 13                	push   $0x13
f01035ee:	eb 06                	jmp    f01035f6 <_alltraps>

f01035f0 <t_syscall>:


TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f01035f0:	6a 00                	push   $0x0
f01035f2:	6a 30                	push   $0x30
f01035f4:	eb 00                	jmp    f01035f6 <_alltraps>

f01035f6 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
 /*公有部分，压入顺序和trapframe有关，因为MIT要求构建Trapframe在堆栈中
,以供trap函数使用*/
_alltraps:
	pushl %ds
f01035f6:	1e                   	push   %ds
	pushl %es
f01035f7:	06                   	push   %es
	pushal 
f01035f8:	60                   	pusha  

	movl $GD_KD, %eax
f01035f9:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f01035fe:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0103600:	8e c0                	mov    %eax,%es

	push %esp
f0103602:	54                   	push   %esp
	call trap
f0103603:	e8 4f fe ff ff       	call   f0103457 <trap>

f0103608 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0103608:	55                   	push   %ebp
f0103609:	89 e5                	mov    %esp,%ebp
f010360b:	83 ec 18             	sub    $0x18,%esp
f010360e:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f0103611:	83 f8 01             	cmp    $0x1,%eax
f0103614:	74 44                	je     f010365a <syscall+0x52>
f0103616:	83 f8 01             	cmp    $0x1,%eax
f0103619:	72 0f                	jb     f010362a <syscall+0x22>
f010361b:	83 f8 02             	cmp    $0x2,%eax
f010361e:	74 41                	je     f0103661 <syscall+0x59>
f0103620:	83 f8 03             	cmp    $0x3,%eax
f0103623:	74 46                	je     f010366b <syscall+0x63>
f0103625:	e9 a6 00 00 00       	jmp    f01036d0 <syscall+0xc8>
	// Destroy the environment if not.

	// LAB 3: Your code here.
	//user_mem_assert(curenv, s, len, 0);
	//检查用户传送过来的指针
	user_mem_assert(curenv, s, len, PTE_U | PTE_P);	
f010362a:	6a 05                	push   $0x5
f010362c:	ff 75 10             	pushl  0x10(%ebp)
f010362f:	ff 75 0c             	pushl  0xc(%ebp)
f0103632:	ff 35 48 be 17 f0    	pushl  0xf017be48
f0103638:	e8 f8 f0 ff ff       	call   f0102735 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010363d:	83 c4 0c             	add    $0xc,%esp
f0103640:	ff 75 0c             	pushl  0xc(%ebp)
f0103643:	ff 75 10             	pushl  0x10(%ebp)
f0103646:	68 90 5a 10 f0       	push   $0xf0105a90
f010364b:	e8 fc f7 ff ff       	call   f0102e4c <cprintf>
f0103650:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");

	switch (syscallno) {
		case (SYS_cputs):
			sys_cputs((const char *)a1, a2);
			return 0;
f0103653:	b8 00 00 00 00       	mov    $0x0,%eax
f0103658:	eb 7b                	jmp    f01036d5 <syscall+0xcd>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010365a:	e8 64 ce ff ff       	call   f01004c3 <cons_getc>
	switch (syscallno) {
		case (SYS_cputs):
			sys_cputs((const char *)a1, a2);
			return 0;
		case (SYS_cgetc):
			return sys_cgetc();
f010365f:	eb 74                	jmp    f01036d5 <syscall+0xcd>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0103661:	a1 48 be 17 f0       	mov    0xf017be48,%eax
f0103666:	8b 40 48             	mov    0x48(%eax),%eax
			sys_cputs((const char *)a1, a2);
			return 0;
		case (SYS_cgetc):
			return sys_cgetc();
		case (SYS_getenvid):
			return sys_getenvid();
f0103669:	eb 6a                	jmp    f01036d5 <syscall+0xcd>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010366b:	83 ec 04             	sub    $0x4,%esp
f010366e:	6a 01                	push   $0x1
f0103670:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103673:	50                   	push   %eax
f0103674:	ff 75 0c             	pushl  0xc(%ebp)
f0103677:	e8 6e f1 ff ff       	call   f01027ea <envid2env>
f010367c:	83 c4 10             	add    $0x10,%esp
f010367f:	85 c0                	test   %eax,%eax
f0103681:	78 52                	js     f01036d5 <syscall+0xcd>
		return r;
	if (e == curenv)
f0103683:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103686:	8b 15 48 be 17 f0    	mov    0xf017be48,%edx
f010368c:	39 d0                	cmp    %edx,%eax
f010368e:	75 15                	jne    f01036a5 <syscall+0x9d>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0103690:	83 ec 08             	sub    $0x8,%esp
f0103693:	ff 70 48             	pushl  0x48(%eax)
f0103696:	68 95 5a 10 f0       	push   $0xf0105a95
f010369b:	e8 ac f7 ff ff       	call   f0102e4c <cprintf>
f01036a0:	83 c4 10             	add    $0x10,%esp
f01036a3:	eb 16                	jmp    f01036bb <syscall+0xb3>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01036a5:	83 ec 04             	sub    $0x4,%esp
f01036a8:	ff 70 48             	pushl  0x48(%eax)
f01036ab:	ff 72 48             	pushl  0x48(%edx)
f01036ae:	68 b0 5a 10 f0       	push   $0xf0105ab0
f01036b3:	e8 94 f7 ff ff       	call   f0102e4c <cprintf>
f01036b8:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f01036bb:	83 ec 0c             	sub    $0xc,%esp
f01036be:	ff 75 f4             	pushl  -0xc(%ebp)
f01036c1:	e8 6d f6 ff ff       	call   f0102d33 <env_destroy>
f01036c6:	83 c4 10             	add    $0x10,%esp
	return 0;
f01036c9:	b8 00 00 00 00       	mov    $0x0,%eax
f01036ce:	eb 05                	jmp    f01036d5 <syscall+0xcd>
		case (SYS_getenvid):
			return sys_getenvid();
		case (SYS_env_destroy):
			return sys_env_destroy(a1);
		default:
			return -E_INVAL;
f01036d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	panic("syscall not implemented");
}
f01036d5:	c9                   	leave  
f01036d6:	c3                   	ret    

f01036d7 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01036d7:	55                   	push   %ebp
f01036d8:	89 e5                	mov    %esp,%ebp
f01036da:	57                   	push   %edi
f01036db:	56                   	push   %esi
f01036dc:	53                   	push   %ebx
f01036dd:	83 ec 14             	sub    $0x14,%esp
f01036e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01036e3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01036e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01036e9:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01036ec:	8b 1a                	mov    (%edx),%ebx
f01036ee:	8b 01                	mov    (%ecx),%eax
f01036f0:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01036f3:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01036fa:	eb 7f                	jmp    f010377b <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01036fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01036ff:	01 d8                	add    %ebx,%eax
f0103701:	89 c6                	mov    %eax,%esi
f0103703:	c1 ee 1f             	shr    $0x1f,%esi
f0103706:	01 c6                	add    %eax,%esi
f0103708:	d1 fe                	sar    %esi
f010370a:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010370d:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103710:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0103713:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0103715:	eb 03                	jmp    f010371a <stab_binsearch+0x43>
			m--;
f0103717:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f010371a:	39 c3                	cmp    %eax,%ebx
f010371c:	7f 0d                	jg     f010372b <stab_binsearch+0x54>
f010371e:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0103722:	83 ea 0c             	sub    $0xc,%edx
f0103725:	39 f9                	cmp    %edi,%ecx
f0103727:	75 ee                	jne    f0103717 <stab_binsearch+0x40>
f0103729:	eb 05                	jmp    f0103730 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010372b:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f010372e:	eb 4b                	jmp    f010377b <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0103730:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0103733:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0103736:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f010373a:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010373d:	76 11                	jbe    f0103750 <stab_binsearch+0x79>
			*region_left = m;
f010373f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0103742:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0103744:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103747:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010374e:	eb 2b                	jmp    f010377b <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0103750:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0103753:	73 14                	jae    f0103769 <stab_binsearch+0x92>
			*region_right = m - 1;
f0103755:	83 e8 01             	sub    $0x1,%eax
f0103758:	89 45 f0             	mov    %eax,-0x10(%ebp)
f010375b:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010375e:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103760:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0103767:	eb 12                	jmp    f010377b <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0103769:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010376c:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f010376e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0103772:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0103774:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010377b:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f010377e:	0f 8e 78 ff ff ff    	jle    f01036fc <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0103784:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0103788:	75 0f                	jne    f0103799 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010378a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010378d:	8b 00                	mov    (%eax),%eax
f010378f:	83 e8 01             	sub    $0x1,%eax
f0103792:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0103795:	89 06                	mov    %eax,(%esi)
f0103797:	eb 2c                	jmp    f01037c5 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0103799:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010379c:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f010379e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01037a1:	8b 0e                	mov    (%esi),%ecx
f01037a3:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01037a6:	8b 75 ec             	mov    -0x14(%ebp),%esi
f01037a9:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01037ac:	eb 03                	jmp    f01037b1 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f01037ae:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f01037b1:	39 c8                	cmp    %ecx,%eax
f01037b3:	7e 0b                	jle    f01037c0 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f01037b5:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f01037b9:	83 ea 0c             	sub    $0xc,%edx
f01037bc:	39 df                	cmp    %ebx,%edi
f01037be:	75 ee                	jne    f01037ae <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f01037c0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01037c3:	89 06                	mov    %eax,(%esi)
	}
}
f01037c5:	83 c4 14             	add    $0x14,%esp
f01037c8:	5b                   	pop    %ebx
f01037c9:	5e                   	pop    %esi
f01037ca:	5f                   	pop    %edi
f01037cb:	5d                   	pop    %ebp
f01037cc:	c3                   	ret    

f01037cd <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01037cd:	55                   	push   %ebp
f01037ce:	89 e5                	mov    %esp,%ebp
f01037d0:	57                   	push   %edi
f01037d1:	56                   	push   %esi
f01037d2:	53                   	push   %ebx
f01037d3:	83 ec 2c             	sub    $0x2c,%esp
f01037d6:	8b 7d 08             	mov    0x8(%ebp),%edi
f01037d9:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01037dc:	c7 06 c8 5a 10 f0    	movl   $0xf0105ac8,(%esi)
	info->eip_line = 0;
f01037e2:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01037e9:	c7 46 08 c8 5a 10 f0 	movl   $0xf0105ac8,0x8(%esi)
	info->eip_fn_namelen = 9;
f01037f0:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01037f7:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01037fa:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0103801:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0103807:	77 21                	ja     f010382a <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f0103809:	a1 00 00 20 00       	mov    0x200000,%eax
f010380e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f0103811:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f0103816:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f010381c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f010381f:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f0103825:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0103828:	eb 1a                	jmp    f0103844 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f010382a:	c7 45 d0 20 fe 10 f0 	movl   $0xf010fe20,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0103831:	c7 45 cc f1 d3 10 f0 	movl   $0xf010d3f1,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0103838:	b8 f0 d3 10 f0       	mov    $0xf010d3f0,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f010383d:	c7 45 d4 e0 5c 10 f0 	movl   $0xf0105ce0,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0103844:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0103847:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f010384a:	0f 83 2b 01 00 00    	jae    f010397b <debuginfo_eip+0x1ae>
f0103850:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f0103854:	0f 85 28 01 00 00    	jne    f0103982 <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f010385a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0103861:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0103864:	29 d8                	sub    %ebx,%eax
f0103866:	c1 f8 02             	sar    $0x2,%eax
f0103869:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f010386f:	83 e8 01             	sub    $0x1,%eax
f0103872:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0103875:	57                   	push   %edi
f0103876:	6a 64                	push   $0x64
f0103878:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010387b:	89 c1                	mov    %eax,%ecx
f010387d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0103880:	89 d8                	mov    %ebx,%eax
f0103882:	e8 50 fe ff ff       	call   f01036d7 <stab_binsearch>
	if (lfile == 0)
f0103887:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010388a:	83 c4 08             	add    $0x8,%esp
f010388d:	85 c0                	test   %eax,%eax
f010388f:	0f 84 f4 00 00 00    	je     f0103989 <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0103895:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0103898:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010389b:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f010389e:	57                   	push   %edi
f010389f:	6a 24                	push   $0x24
f01038a1:	8d 45 d8             	lea    -0x28(%ebp),%eax
f01038a4:	89 c1                	mov    %eax,%ecx
f01038a6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01038a9:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f01038ac:	89 d8                	mov    %ebx,%eax
f01038ae:	e8 24 fe ff ff       	call   f01036d7 <stab_binsearch>

	if (lfun <= rfun) {
f01038b3:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01038b6:	83 c4 08             	add    $0x8,%esp
f01038b9:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f01038bc:	7f 24                	jg     f01038e2 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01038be:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01038c1:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01038c4:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01038c7:	8b 02                	mov    (%edx),%eax
f01038c9:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01038cc:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01038cf:	29 f9                	sub    %edi,%ecx
f01038d1:	39 c8                	cmp    %ecx,%eax
f01038d3:	73 05                	jae    f01038da <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f01038d5:	01 f8                	add    %edi,%eax
f01038d7:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01038da:	8b 42 08             	mov    0x8(%edx),%eax
f01038dd:	89 46 10             	mov    %eax,0x10(%esi)
f01038e0:	eb 06                	jmp    f01038e8 <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01038e2:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01038e5:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01038e8:	83 ec 08             	sub    $0x8,%esp
f01038eb:	6a 3a                	push   $0x3a
f01038ed:	ff 76 08             	pushl  0x8(%esi)
f01038f0:	e8 9a 08 00 00       	call   f010418f <strfind>
f01038f5:	2b 46 08             	sub    0x8(%esi),%eax
f01038f8:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01038fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01038fe:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103901:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0103904:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0103907:	83 c4 10             	add    $0x10,%esp
f010390a:	eb 06                	jmp    f0103912 <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010390c:	83 eb 01             	sub    $0x1,%ebx
f010390f:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103912:	39 fb                	cmp    %edi,%ebx
f0103914:	7c 2d                	jl     f0103943 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f0103916:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f010391a:	80 fa 84             	cmp    $0x84,%dl
f010391d:	74 0b                	je     f010392a <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f010391f:	80 fa 64             	cmp    $0x64,%dl
f0103922:	75 e8                	jne    f010390c <debuginfo_eip+0x13f>
f0103924:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f0103928:	74 e2                	je     f010390c <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f010392a:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010392d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103930:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0103933:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103936:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0103939:	29 f8                	sub    %edi,%eax
f010393b:	39 c2                	cmp    %eax,%edx
f010393d:	73 04                	jae    f0103943 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f010393f:	01 fa                	add    %edi,%edx
f0103941:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103943:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0103946:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103949:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010394e:	39 cb                	cmp    %ecx,%ebx
f0103950:	7d 43                	jge    f0103995 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0103952:	8d 53 01             	lea    0x1(%ebx),%edx
f0103955:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0103958:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010395b:	8d 04 87             	lea    (%edi,%eax,4),%eax
f010395e:	eb 07                	jmp    f0103967 <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0103960:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103964:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103967:	39 ca                	cmp    %ecx,%edx
f0103969:	74 25                	je     f0103990 <debuginfo_eip+0x1c3>
f010396b:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f010396e:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0103972:	74 ec                	je     f0103960 <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103974:	b8 00 00 00 00       	mov    $0x0,%eax
f0103979:	eb 1a                	jmp    f0103995 <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010397b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103980:	eb 13                	jmp    f0103995 <debuginfo_eip+0x1c8>
f0103982:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103987:	eb 0c                	jmp    f0103995 <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0103989:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010398e:	eb 05                	jmp    f0103995 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103990:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0103995:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103998:	5b                   	pop    %ebx
f0103999:	5e                   	pop    %esi
f010399a:	5f                   	pop    %edi
f010399b:	5d                   	pop    %ebp
f010399c:	c3                   	ret    

f010399d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010399d:	55                   	push   %ebp
f010399e:	89 e5                	mov    %esp,%ebp
f01039a0:	57                   	push   %edi
f01039a1:	56                   	push   %esi
f01039a2:	53                   	push   %ebx
f01039a3:	83 ec 1c             	sub    $0x1c,%esp
f01039a6:	89 c7                	mov    %eax,%edi
f01039a8:	89 d6                	mov    %edx,%esi
f01039aa:	8b 45 08             	mov    0x8(%ebp),%eax
f01039ad:	8b 55 0c             	mov    0xc(%ebp),%edx
f01039b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01039b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f01039b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01039b9:	bb 00 00 00 00       	mov    $0x0,%ebx
f01039be:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01039c1:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f01039c4:	39 d3                	cmp    %edx,%ebx
f01039c6:	72 05                	jb     f01039cd <printnum+0x30>
f01039c8:	39 45 10             	cmp    %eax,0x10(%ebp)
f01039cb:	77 45                	ja     f0103a12 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f01039cd:	83 ec 0c             	sub    $0xc,%esp
f01039d0:	ff 75 18             	pushl  0x18(%ebp)
f01039d3:	8b 45 14             	mov    0x14(%ebp),%eax
f01039d6:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01039d9:	53                   	push   %ebx
f01039da:	ff 75 10             	pushl  0x10(%ebp)
f01039dd:	83 ec 08             	sub    $0x8,%esp
f01039e0:	ff 75 e4             	pushl  -0x1c(%ebp)
f01039e3:	ff 75 e0             	pushl  -0x20(%ebp)
f01039e6:	ff 75 dc             	pushl  -0x24(%ebp)
f01039e9:	ff 75 d8             	pushl  -0x28(%ebp)
f01039ec:	e8 bf 09 00 00       	call   f01043b0 <__udivdi3>
f01039f1:	83 c4 18             	add    $0x18,%esp
f01039f4:	52                   	push   %edx
f01039f5:	50                   	push   %eax
f01039f6:	89 f2                	mov    %esi,%edx
f01039f8:	89 f8                	mov    %edi,%eax
f01039fa:	e8 9e ff ff ff       	call   f010399d <printnum>
f01039ff:	83 c4 20             	add    $0x20,%esp
f0103a02:	eb 18                	jmp    f0103a1c <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103a04:	83 ec 08             	sub    $0x8,%esp
f0103a07:	56                   	push   %esi
f0103a08:	ff 75 18             	pushl  0x18(%ebp)
f0103a0b:	ff d7                	call   *%edi
f0103a0d:	83 c4 10             	add    $0x10,%esp
f0103a10:	eb 03                	jmp    f0103a15 <printnum+0x78>
f0103a12:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103a15:	83 eb 01             	sub    $0x1,%ebx
f0103a18:	85 db                	test   %ebx,%ebx
f0103a1a:	7f e8                	jg     f0103a04 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103a1c:	83 ec 08             	sub    $0x8,%esp
f0103a1f:	56                   	push   %esi
f0103a20:	83 ec 04             	sub    $0x4,%esp
f0103a23:	ff 75 e4             	pushl  -0x1c(%ebp)
f0103a26:	ff 75 e0             	pushl  -0x20(%ebp)
f0103a29:	ff 75 dc             	pushl  -0x24(%ebp)
f0103a2c:	ff 75 d8             	pushl  -0x28(%ebp)
f0103a2f:	e8 ac 0a 00 00       	call   f01044e0 <__umoddi3>
f0103a34:	83 c4 14             	add    $0x14,%esp
f0103a37:	0f be 80 d2 5a 10 f0 	movsbl -0xfefa52e(%eax),%eax
f0103a3e:	50                   	push   %eax
f0103a3f:	ff d7                	call   *%edi
}
f0103a41:	83 c4 10             	add    $0x10,%esp
f0103a44:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103a47:	5b                   	pop    %ebx
f0103a48:	5e                   	pop    %esi
f0103a49:	5f                   	pop    %edi
f0103a4a:	5d                   	pop    %ebp
f0103a4b:	c3                   	ret    

f0103a4c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103a4c:	55                   	push   %ebp
f0103a4d:	89 e5                	mov    %esp,%ebp
f0103a4f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0103a52:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0103a56:	8b 10                	mov    (%eax),%edx
f0103a58:	3b 50 04             	cmp    0x4(%eax),%edx
f0103a5b:	73 0a                	jae    f0103a67 <sprintputch+0x1b>
		*b->buf++ = ch;
f0103a5d:	8d 4a 01             	lea    0x1(%edx),%ecx
f0103a60:	89 08                	mov    %ecx,(%eax)
f0103a62:	8b 45 08             	mov    0x8(%ebp),%eax
f0103a65:	88 02                	mov    %al,(%edx)
}
f0103a67:	5d                   	pop    %ebp
f0103a68:	c3                   	ret    

f0103a69 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0103a69:	55                   	push   %ebp
f0103a6a:	89 e5                	mov    %esp,%ebp
f0103a6c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0103a6f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0103a72:	50                   	push   %eax
f0103a73:	ff 75 10             	pushl  0x10(%ebp)
f0103a76:	ff 75 0c             	pushl  0xc(%ebp)
f0103a79:	ff 75 08             	pushl  0x8(%ebp)
f0103a7c:	e8 05 00 00 00       	call   f0103a86 <vprintfmt>
	va_end(ap);
}
f0103a81:	83 c4 10             	add    $0x10,%esp
f0103a84:	c9                   	leave  
f0103a85:	c3                   	ret    

f0103a86 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0103a86:	55                   	push   %ebp
f0103a87:	89 e5                	mov    %esp,%ebp
f0103a89:	57                   	push   %edi
f0103a8a:	56                   	push   %esi
f0103a8b:	53                   	push   %ebx
f0103a8c:	83 ec 2c             	sub    $0x2c,%esp
f0103a8f:	8b 75 08             	mov    0x8(%ebp),%esi
f0103a92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103a95:	8b 7d 10             	mov    0x10(%ebp),%edi
f0103a98:	eb 12                	jmp    f0103aac <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0103a9a:	85 c0                	test   %eax,%eax
f0103a9c:	0f 84 42 04 00 00    	je     f0103ee4 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0103aa2:	83 ec 08             	sub    $0x8,%esp
f0103aa5:	53                   	push   %ebx
f0103aa6:	50                   	push   %eax
f0103aa7:	ff d6                	call   *%esi
f0103aa9:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0103aac:	83 c7 01             	add    $0x1,%edi
f0103aaf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103ab3:	83 f8 25             	cmp    $0x25,%eax
f0103ab6:	75 e2                	jne    f0103a9a <vprintfmt+0x14>
f0103ab8:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0103abc:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0103ac3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103aca:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0103ad1:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103ad6:	eb 07                	jmp    f0103adf <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ad8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0103adb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103adf:	8d 47 01             	lea    0x1(%edi),%eax
f0103ae2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0103ae5:	0f b6 07             	movzbl (%edi),%eax
f0103ae8:	0f b6 d0             	movzbl %al,%edx
f0103aeb:	83 e8 23             	sub    $0x23,%eax
f0103aee:	3c 55                	cmp    $0x55,%al
f0103af0:	0f 87 d3 03 00 00    	ja     f0103ec9 <vprintfmt+0x443>
f0103af6:	0f b6 c0             	movzbl %al,%eax
f0103af9:	ff 24 85 5c 5b 10 f0 	jmp    *-0xfefa4a4(,%eax,4)
f0103b00:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103b03:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0103b07:	eb d6                	jmp    f0103adf <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b09:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103b0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0103b11:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0103b14:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0103b17:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0103b1b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0103b1e:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0103b21:	83 f9 09             	cmp    $0x9,%ecx
f0103b24:	77 3f                	ja     f0103b65 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0103b26:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0103b29:	eb e9                	jmp    f0103b14 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0103b2b:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b2e:	8b 00                	mov    (%eax),%eax
f0103b30:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0103b33:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b36:	8d 40 04             	lea    0x4(%eax),%eax
f0103b39:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b3c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103b3f:	eb 2a                	jmp    f0103b6b <vprintfmt+0xe5>
f0103b41:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0103b44:	85 c0                	test   %eax,%eax
f0103b46:	ba 00 00 00 00       	mov    $0x0,%edx
f0103b4b:	0f 49 d0             	cmovns %eax,%edx
f0103b4e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103b54:	eb 89                	jmp    f0103adf <vprintfmt+0x59>
f0103b56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103b59:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0103b60:	e9 7a ff ff ff       	jmp    f0103adf <vprintfmt+0x59>
f0103b65:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0103b68:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0103b6b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103b6f:	0f 89 6a ff ff ff    	jns    f0103adf <vprintfmt+0x59>
				width = precision, precision = -1;
f0103b75:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0103b78:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103b7b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0103b82:	e9 58 ff ff ff       	jmp    f0103adf <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103b87:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103b8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103b8d:	e9 4d ff ff ff       	jmp    f0103adf <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103b92:	8b 45 14             	mov    0x14(%ebp),%eax
f0103b95:	8d 78 04             	lea    0x4(%eax),%edi
f0103b98:	83 ec 08             	sub    $0x8,%esp
f0103b9b:	53                   	push   %ebx
f0103b9c:	ff 30                	pushl  (%eax)
f0103b9e:	ff d6                	call   *%esi
			break;
f0103ba0:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0103ba3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ba6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0103ba9:	e9 fe fe ff ff       	jmp    f0103aac <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103bae:	8b 45 14             	mov    0x14(%ebp),%eax
f0103bb1:	8d 78 04             	lea    0x4(%eax),%edi
f0103bb4:	8b 00                	mov    (%eax),%eax
f0103bb6:	99                   	cltd   
f0103bb7:	31 d0                	xor    %edx,%eax
f0103bb9:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103bbb:	83 f8 06             	cmp    $0x6,%eax
f0103bbe:	7f 0b                	jg     f0103bcb <vprintfmt+0x145>
f0103bc0:	8b 14 85 b4 5c 10 f0 	mov    -0xfefa34c(,%eax,4),%edx
f0103bc7:	85 d2                	test   %edx,%edx
f0103bc9:	75 1b                	jne    f0103be6 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0103bcb:	50                   	push   %eax
f0103bcc:	68 ea 5a 10 f0       	push   $0xf0105aea
f0103bd1:	53                   	push   %ebx
f0103bd2:	56                   	push   %esi
f0103bd3:	e8 91 fe ff ff       	call   f0103a69 <printfmt>
f0103bd8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103bdb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103bde:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0103be1:	e9 c6 fe ff ff       	jmp    f0103aac <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0103be6:	52                   	push   %edx
f0103be7:	68 f5 52 10 f0       	push   $0xf01052f5
f0103bec:	53                   	push   %ebx
f0103bed:	56                   	push   %esi
f0103bee:	e8 76 fe ff ff       	call   f0103a69 <printfmt>
f0103bf3:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103bf6:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103bf9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103bfc:	e9 ab fe ff ff       	jmp    f0103aac <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103c01:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c04:	83 c0 04             	add    $0x4,%eax
f0103c07:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0103c0a:	8b 45 14             	mov    0x14(%ebp),%eax
f0103c0d:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0103c0f:	85 ff                	test   %edi,%edi
f0103c11:	b8 e3 5a 10 f0       	mov    $0xf0105ae3,%eax
f0103c16:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0103c19:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0103c1d:	0f 8e 94 00 00 00    	jle    f0103cb7 <vprintfmt+0x231>
f0103c23:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0103c27:	0f 84 98 00 00 00    	je     f0103cc5 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c2d:	83 ec 08             	sub    $0x8,%esp
f0103c30:	ff 75 d0             	pushl  -0x30(%ebp)
f0103c33:	57                   	push   %edi
f0103c34:	e8 0c 04 00 00       	call   f0104045 <strnlen>
f0103c39:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0103c3c:	29 c1                	sub    %eax,%ecx
f0103c3e:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103c41:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0103c44:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0103c48:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0103c4b:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0103c4e:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c50:	eb 0f                	jmp    f0103c61 <vprintfmt+0x1db>
					putch(padc, putdat);
f0103c52:	83 ec 08             	sub    $0x8,%esp
f0103c55:	53                   	push   %ebx
f0103c56:	ff 75 e0             	pushl  -0x20(%ebp)
f0103c59:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103c5b:	83 ef 01             	sub    $0x1,%edi
f0103c5e:	83 c4 10             	add    $0x10,%esp
f0103c61:	85 ff                	test   %edi,%edi
f0103c63:	7f ed                	jg     f0103c52 <vprintfmt+0x1cc>
f0103c65:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0103c68:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0103c6b:	85 c9                	test   %ecx,%ecx
f0103c6d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103c72:	0f 49 c1             	cmovns %ecx,%eax
f0103c75:	29 c1                	sub    %eax,%ecx
f0103c77:	89 75 08             	mov    %esi,0x8(%ebp)
f0103c7a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103c7d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103c80:	89 cb                	mov    %ecx,%ebx
f0103c82:	eb 4d                	jmp    f0103cd1 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0103c84:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0103c88:	74 1b                	je     f0103ca5 <vprintfmt+0x21f>
f0103c8a:	0f be c0             	movsbl %al,%eax
f0103c8d:	83 e8 20             	sub    $0x20,%eax
f0103c90:	83 f8 5e             	cmp    $0x5e,%eax
f0103c93:	76 10                	jbe    f0103ca5 <vprintfmt+0x21f>
					putch('?', putdat);
f0103c95:	83 ec 08             	sub    $0x8,%esp
f0103c98:	ff 75 0c             	pushl  0xc(%ebp)
f0103c9b:	6a 3f                	push   $0x3f
f0103c9d:	ff 55 08             	call   *0x8(%ebp)
f0103ca0:	83 c4 10             	add    $0x10,%esp
f0103ca3:	eb 0d                	jmp    f0103cb2 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0103ca5:	83 ec 08             	sub    $0x8,%esp
f0103ca8:	ff 75 0c             	pushl  0xc(%ebp)
f0103cab:	52                   	push   %edx
f0103cac:	ff 55 08             	call   *0x8(%ebp)
f0103caf:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103cb2:	83 eb 01             	sub    $0x1,%ebx
f0103cb5:	eb 1a                	jmp    f0103cd1 <vprintfmt+0x24b>
f0103cb7:	89 75 08             	mov    %esi,0x8(%ebp)
f0103cba:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103cbd:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103cc0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103cc3:	eb 0c                	jmp    f0103cd1 <vprintfmt+0x24b>
f0103cc5:	89 75 08             	mov    %esi,0x8(%ebp)
f0103cc8:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0103ccb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0103cce:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0103cd1:	83 c7 01             	add    $0x1,%edi
f0103cd4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0103cd8:	0f be d0             	movsbl %al,%edx
f0103cdb:	85 d2                	test   %edx,%edx
f0103cdd:	74 23                	je     f0103d02 <vprintfmt+0x27c>
f0103cdf:	85 f6                	test   %esi,%esi
f0103ce1:	78 a1                	js     f0103c84 <vprintfmt+0x1fe>
f0103ce3:	83 ee 01             	sub    $0x1,%esi
f0103ce6:	79 9c                	jns    f0103c84 <vprintfmt+0x1fe>
f0103ce8:	89 df                	mov    %ebx,%edi
f0103cea:	8b 75 08             	mov    0x8(%ebp),%esi
f0103ced:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103cf0:	eb 18                	jmp    f0103d0a <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0103cf2:	83 ec 08             	sub    $0x8,%esp
f0103cf5:	53                   	push   %ebx
f0103cf6:	6a 20                	push   $0x20
f0103cf8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103cfa:	83 ef 01             	sub    $0x1,%edi
f0103cfd:	83 c4 10             	add    $0x10,%esp
f0103d00:	eb 08                	jmp    f0103d0a <vprintfmt+0x284>
f0103d02:	89 df                	mov    %ebx,%edi
f0103d04:	8b 75 08             	mov    0x8(%ebp),%esi
f0103d07:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0103d0a:	85 ff                	test   %edi,%edi
f0103d0c:	7f e4                	jg     f0103cf2 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0103d0e:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103d11:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103d14:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103d17:	e9 90 fd ff ff       	jmp    f0103aac <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103d1c:	83 f9 01             	cmp    $0x1,%ecx
f0103d1f:	7e 19                	jle    f0103d3a <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0103d21:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d24:	8b 50 04             	mov    0x4(%eax),%edx
f0103d27:	8b 00                	mov    (%eax),%eax
f0103d29:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d2c:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0103d2f:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d32:	8d 40 08             	lea    0x8(%eax),%eax
f0103d35:	89 45 14             	mov    %eax,0x14(%ebp)
f0103d38:	eb 38                	jmp    f0103d72 <vprintfmt+0x2ec>
	else if (lflag)
f0103d3a:	85 c9                	test   %ecx,%ecx
f0103d3c:	74 1b                	je     f0103d59 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0103d3e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d41:	8b 00                	mov    (%eax),%eax
f0103d43:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d46:	89 c1                	mov    %eax,%ecx
f0103d48:	c1 f9 1f             	sar    $0x1f,%ecx
f0103d4b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103d4e:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d51:	8d 40 04             	lea    0x4(%eax),%eax
f0103d54:	89 45 14             	mov    %eax,0x14(%ebp)
f0103d57:	eb 19                	jmp    f0103d72 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0103d59:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d5c:	8b 00                	mov    (%eax),%eax
f0103d5e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103d61:	89 c1                	mov    %eax,%ecx
f0103d63:	c1 f9 1f             	sar    $0x1f,%ecx
f0103d66:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0103d69:	8b 45 14             	mov    0x14(%ebp),%eax
f0103d6c:	8d 40 04             	lea    0x4(%eax),%eax
f0103d6f:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0103d72:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d75:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0103d78:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0103d7d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0103d81:	0f 89 0e 01 00 00    	jns    f0103e95 <vprintfmt+0x40f>
				putch('-', putdat);
f0103d87:	83 ec 08             	sub    $0x8,%esp
f0103d8a:	53                   	push   %ebx
f0103d8b:	6a 2d                	push   $0x2d
f0103d8d:	ff d6                	call   *%esi
				num = -(long long) num;
f0103d8f:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103d92:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0103d95:	f7 da                	neg    %edx
f0103d97:	83 d1 00             	adc    $0x0,%ecx
f0103d9a:	f7 d9                	neg    %ecx
f0103d9c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0103d9f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103da4:	e9 ec 00 00 00       	jmp    f0103e95 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103da9:	83 f9 01             	cmp    $0x1,%ecx
f0103dac:	7e 18                	jle    f0103dc6 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0103dae:	8b 45 14             	mov    0x14(%ebp),%eax
f0103db1:	8b 10                	mov    (%eax),%edx
f0103db3:	8b 48 04             	mov    0x4(%eax),%ecx
f0103db6:	8d 40 08             	lea    0x8(%eax),%eax
f0103db9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103dbc:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103dc1:	e9 cf 00 00 00       	jmp    f0103e95 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0103dc6:	85 c9                	test   %ecx,%ecx
f0103dc8:	74 1a                	je     f0103de4 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0103dca:	8b 45 14             	mov    0x14(%ebp),%eax
f0103dcd:	8b 10                	mov    (%eax),%edx
f0103dcf:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103dd4:	8d 40 04             	lea    0x4(%eax),%eax
f0103dd7:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103dda:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ddf:	e9 b1 00 00 00       	jmp    f0103e95 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0103de4:	8b 45 14             	mov    0x14(%ebp),%eax
f0103de7:	8b 10                	mov    (%eax),%edx
f0103de9:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103dee:	8d 40 04             	lea    0x4(%eax),%eax
f0103df1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0103df4:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103df9:	e9 97 00 00 00       	jmp    f0103e95 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0103dfe:	83 ec 08             	sub    $0x8,%esp
f0103e01:	53                   	push   %ebx
f0103e02:	6a 58                	push   $0x58
f0103e04:	ff d6                	call   *%esi
			putch('X', putdat);
f0103e06:	83 c4 08             	add    $0x8,%esp
f0103e09:	53                   	push   %ebx
f0103e0a:	6a 58                	push   $0x58
f0103e0c:	ff d6                	call   *%esi
			putch('X', putdat);
f0103e0e:	83 c4 08             	add    $0x8,%esp
f0103e11:	53                   	push   %ebx
f0103e12:	6a 58                	push   $0x58
f0103e14:	ff d6                	call   *%esi
			break;
f0103e16:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103e19:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0103e1c:	e9 8b fc ff ff       	jmp    f0103aac <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0103e21:	83 ec 08             	sub    $0x8,%esp
f0103e24:	53                   	push   %ebx
f0103e25:	6a 30                	push   $0x30
f0103e27:	ff d6                	call   *%esi
			putch('x', putdat);
f0103e29:	83 c4 08             	add    $0x8,%esp
f0103e2c:	53                   	push   %ebx
f0103e2d:	6a 78                	push   $0x78
f0103e2f:	ff d6                	call   *%esi
			num = (unsigned long long)
f0103e31:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e34:	8b 10                	mov    (%eax),%edx
f0103e36:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0103e3b:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103e3e:	8d 40 04             	lea    0x4(%eax),%eax
f0103e41:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0103e44:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0103e49:	eb 4a                	jmp    f0103e95 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0103e4b:	83 f9 01             	cmp    $0x1,%ecx
f0103e4e:	7e 15                	jle    f0103e65 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0103e50:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e53:	8b 10                	mov    (%eax),%edx
f0103e55:	8b 48 04             	mov    0x4(%eax),%ecx
f0103e58:	8d 40 08             	lea    0x8(%eax),%eax
f0103e5b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103e5e:	b8 10 00 00 00       	mov    $0x10,%eax
f0103e63:	eb 30                	jmp    f0103e95 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0103e65:	85 c9                	test   %ecx,%ecx
f0103e67:	74 17                	je     f0103e80 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f0103e69:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e6c:	8b 10                	mov    (%eax),%edx
f0103e6e:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e73:	8d 40 04             	lea    0x4(%eax),%eax
f0103e76:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103e79:	b8 10 00 00 00       	mov    $0x10,%eax
f0103e7e:	eb 15                	jmp    f0103e95 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0103e80:	8b 45 14             	mov    0x14(%ebp),%eax
f0103e83:	8b 10                	mov    (%eax),%edx
f0103e85:	b9 00 00 00 00       	mov    $0x0,%ecx
f0103e8a:	8d 40 04             	lea    0x4(%eax),%eax
f0103e8d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0103e90:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0103e95:	83 ec 0c             	sub    $0xc,%esp
f0103e98:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0103e9c:	57                   	push   %edi
f0103e9d:	ff 75 e0             	pushl  -0x20(%ebp)
f0103ea0:	50                   	push   %eax
f0103ea1:	51                   	push   %ecx
f0103ea2:	52                   	push   %edx
f0103ea3:	89 da                	mov    %ebx,%edx
f0103ea5:	89 f0                	mov    %esi,%eax
f0103ea7:	e8 f1 fa ff ff       	call   f010399d <printnum>
			break;
f0103eac:	83 c4 20             	add    $0x20,%esp
f0103eaf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0103eb2:	e9 f5 fb ff ff       	jmp    f0103aac <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0103eb7:	83 ec 08             	sub    $0x8,%esp
f0103eba:	53                   	push   %ebx
f0103ebb:	52                   	push   %edx
f0103ebc:	ff d6                	call   *%esi
			break;
f0103ebe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103ec1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0103ec4:	e9 e3 fb ff ff       	jmp    f0103aac <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0103ec9:	83 ec 08             	sub    $0x8,%esp
f0103ecc:	53                   	push   %ebx
f0103ecd:	6a 25                	push   $0x25
f0103ecf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0103ed1:	83 c4 10             	add    $0x10,%esp
f0103ed4:	eb 03                	jmp    f0103ed9 <vprintfmt+0x453>
f0103ed6:	83 ef 01             	sub    $0x1,%edi
f0103ed9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0103edd:	75 f7                	jne    f0103ed6 <vprintfmt+0x450>
f0103edf:	e9 c8 fb ff ff       	jmp    f0103aac <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0103ee4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ee7:	5b                   	pop    %ebx
f0103ee8:	5e                   	pop    %esi
f0103ee9:	5f                   	pop    %edi
f0103eea:	5d                   	pop    %ebp
f0103eeb:	c3                   	ret    

f0103eec <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103eec:	55                   	push   %ebp
f0103eed:	89 e5                	mov    %esp,%ebp
f0103eef:	83 ec 18             	sub    $0x18,%esp
f0103ef2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ef5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103ef8:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0103efb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0103eff:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0103f02:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0103f09:	85 c0                	test   %eax,%eax
f0103f0b:	74 26                	je     f0103f33 <vsnprintf+0x47>
f0103f0d:	85 d2                	test   %edx,%edx
f0103f0f:	7e 22                	jle    f0103f33 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103f11:	ff 75 14             	pushl  0x14(%ebp)
f0103f14:	ff 75 10             	pushl  0x10(%ebp)
f0103f17:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0103f1a:	50                   	push   %eax
f0103f1b:	68 4c 3a 10 f0       	push   $0xf0103a4c
f0103f20:	e8 61 fb ff ff       	call   f0103a86 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103f25:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0103f28:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0103f2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f2e:	83 c4 10             	add    $0x10,%esp
f0103f31:	eb 05                	jmp    f0103f38 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103f33:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103f38:	c9                   	leave  
f0103f39:	c3                   	ret    

f0103f3a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103f3a:	55                   	push   %ebp
f0103f3b:	89 e5                	mov    %esp,%ebp
f0103f3d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103f40:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0103f43:	50                   	push   %eax
f0103f44:	ff 75 10             	pushl  0x10(%ebp)
f0103f47:	ff 75 0c             	pushl  0xc(%ebp)
f0103f4a:	ff 75 08             	pushl  0x8(%ebp)
f0103f4d:	e8 9a ff ff ff       	call   f0103eec <vsnprintf>
	va_end(ap);

	return rc;
}
f0103f52:	c9                   	leave  
f0103f53:	c3                   	ret    

f0103f54 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103f54:	55                   	push   %ebp
f0103f55:	89 e5                	mov    %esp,%ebp
f0103f57:	57                   	push   %edi
f0103f58:	56                   	push   %esi
f0103f59:	53                   	push   %ebx
f0103f5a:	83 ec 0c             	sub    $0xc,%esp
f0103f5d:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0103f60:	85 c0                	test   %eax,%eax
f0103f62:	74 11                	je     f0103f75 <readline+0x21>
		cprintf("%s", prompt);
f0103f64:	83 ec 08             	sub    $0x8,%esp
f0103f67:	50                   	push   %eax
f0103f68:	68 f5 52 10 f0       	push   $0xf01052f5
f0103f6d:	e8 da ee ff ff       	call   f0102e4c <cprintf>
f0103f72:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0103f75:	83 ec 0c             	sub    $0xc,%esp
f0103f78:	6a 00                	push   $0x0
f0103f7a:	e8 b7 c6 ff ff       	call   f0100636 <iscons>
f0103f7f:	89 c7                	mov    %eax,%edi
f0103f81:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103f84:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103f89:	e8 97 c6 ff ff       	call   f0100625 <getchar>
f0103f8e:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0103f90:	85 c0                	test   %eax,%eax
f0103f92:	79 18                	jns    f0103fac <readline+0x58>
			cprintf("read error: %e\n", c);
f0103f94:	83 ec 08             	sub    $0x8,%esp
f0103f97:	50                   	push   %eax
f0103f98:	68 d0 5c 10 f0       	push   $0xf0105cd0
f0103f9d:	e8 aa ee ff ff       	call   f0102e4c <cprintf>
			return NULL;
f0103fa2:	83 c4 10             	add    $0x10,%esp
f0103fa5:	b8 00 00 00 00       	mov    $0x0,%eax
f0103faa:	eb 79                	jmp    f0104025 <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103fac:	83 f8 08             	cmp    $0x8,%eax
f0103faf:	0f 94 c2             	sete   %dl
f0103fb2:	83 f8 7f             	cmp    $0x7f,%eax
f0103fb5:	0f 94 c0             	sete   %al
f0103fb8:	08 c2                	or     %al,%dl
f0103fba:	74 1a                	je     f0103fd6 <readline+0x82>
f0103fbc:	85 f6                	test   %esi,%esi
f0103fbe:	7e 16                	jle    f0103fd6 <readline+0x82>
			if (echoing)
f0103fc0:	85 ff                	test   %edi,%edi
f0103fc2:	74 0d                	je     f0103fd1 <readline+0x7d>
				cputchar('\b');
f0103fc4:	83 ec 0c             	sub    $0xc,%esp
f0103fc7:	6a 08                	push   $0x8
f0103fc9:	e8 47 c6 ff ff       	call   f0100615 <cputchar>
f0103fce:	83 c4 10             	add    $0x10,%esp
			i--;
f0103fd1:	83 ee 01             	sub    $0x1,%esi
f0103fd4:	eb b3                	jmp    f0103f89 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103fd6:	83 fb 1f             	cmp    $0x1f,%ebx
f0103fd9:	7e 23                	jle    f0103ffe <readline+0xaa>
f0103fdb:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0103fe1:	7f 1b                	jg     f0103ffe <readline+0xaa>
			if (echoing)
f0103fe3:	85 ff                	test   %edi,%edi
f0103fe5:	74 0c                	je     f0103ff3 <readline+0x9f>
				cputchar(c);
f0103fe7:	83 ec 0c             	sub    $0xc,%esp
f0103fea:	53                   	push   %ebx
f0103feb:	e8 25 c6 ff ff       	call   f0100615 <cputchar>
f0103ff0:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0103ff3:	88 9e 00 c7 17 f0    	mov    %bl,-0xfe83900(%esi)
f0103ff9:	8d 76 01             	lea    0x1(%esi),%esi
f0103ffc:	eb 8b                	jmp    f0103f89 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0103ffe:	83 fb 0a             	cmp    $0xa,%ebx
f0104001:	74 05                	je     f0104008 <readline+0xb4>
f0104003:	83 fb 0d             	cmp    $0xd,%ebx
f0104006:	75 81                	jne    f0103f89 <readline+0x35>
			if (echoing)
f0104008:	85 ff                	test   %edi,%edi
f010400a:	74 0d                	je     f0104019 <readline+0xc5>
				cputchar('\n');
f010400c:	83 ec 0c             	sub    $0xc,%esp
f010400f:	6a 0a                	push   $0xa
f0104011:	e8 ff c5 ff ff       	call   f0100615 <cputchar>
f0104016:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104019:	c6 86 00 c7 17 f0 00 	movb   $0x0,-0xfe83900(%esi)
			return buf;
f0104020:	b8 00 c7 17 f0       	mov    $0xf017c700,%eax
		}
	}
}
f0104025:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104028:	5b                   	pop    %ebx
f0104029:	5e                   	pop    %esi
f010402a:	5f                   	pop    %edi
f010402b:	5d                   	pop    %ebp
f010402c:	c3                   	ret    

f010402d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f010402d:	55                   	push   %ebp
f010402e:	89 e5                	mov    %esp,%ebp
f0104030:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104033:	b8 00 00 00 00       	mov    $0x0,%eax
f0104038:	eb 03                	jmp    f010403d <strlen+0x10>
		n++;
f010403a:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f010403d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104041:	75 f7                	jne    f010403a <strlen+0xd>
		n++;
	return n;
}
f0104043:	5d                   	pop    %ebp
f0104044:	c3                   	ret    

f0104045 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104045:	55                   	push   %ebp
f0104046:	89 e5                	mov    %esp,%ebp
f0104048:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010404b:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010404e:	ba 00 00 00 00       	mov    $0x0,%edx
f0104053:	eb 03                	jmp    f0104058 <strnlen+0x13>
		n++;
f0104055:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104058:	39 c2                	cmp    %eax,%edx
f010405a:	74 08                	je     f0104064 <strnlen+0x1f>
f010405c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0104060:	75 f3                	jne    f0104055 <strnlen+0x10>
f0104062:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0104064:	5d                   	pop    %ebp
f0104065:	c3                   	ret    

f0104066 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0104066:	55                   	push   %ebp
f0104067:	89 e5                	mov    %esp,%ebp
f0104069:	53                   	push   %ebx
f010406a:	8b 45 08             	mov    0x8(%ebp),%eax
f010406d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0104070:	89 c2                	mov    %eax,%edx
f0104072:	83 c2 01             	add    $0x1,%edx
f0104075:	83 c1 01             	add    $0x1,%ecx
f0104078:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f010407c:	88 5a ff             	mov    %bl,-0x1(%edx)
f010407f:	84 db                	test   %bl,%bl
f0104081:	75 ef                	jne    f0104072 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0104083:	5b                   	pop    %ebx
f0104084:	5d                   	pop    %ebp
f0104085:	c3                   	ret    

f0104086 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0104086:	55                   	push   %ebp
f0104087:	89 e5                	mov    %esp,%ebp
f0104089:	53                   	push   %ebx
f010408a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f010408d:	53                   	push   %ebx
f010408e:	e8 9a ff ff ff       	call   f010402d <strlen>
f0104093:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0104096:	ff 75 0c             	pushl  0xc(%ebp)
f0104099:	01 d8                	add    %ebx,%eax
f010409b:	50                   	push   %eax
f010409c:	e8 c5 ff ff ff       	call   f0104066 <strcpy>
	return dst;
}
f01040a1:	89 d8                	mov    %ebx,%eax
f01040a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01040a6:	c9                   	leave  
f01040a7:	c3                   	ret    

f01040a8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f01040a8:	55                   	push   %ebp
f01040a9:	89 e5                	mov    %esp,%ebp
f01040ab:	56                   	push   %esi
f01040ac:	53                   	push   %ebx
f01040ad:	8b 75 08             	mov    0x8(%ebp),%esi
f01040b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01040b3:	89 f3                	mov    %esi,%ebx
f01040b5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01040b8:	89 f2                	mov    %esi,%edx
f01040ba:	eb 0f                	jmp    f01040cb <strncpy+0x23>
		*dst++ = *src;
f01040bc:	83 c2 01             	add    $0x1,%edx
f01040bf:	0f b6 01             	movzbl (%ecx),%eax
f01040c2:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f01040c5:	80 39 01             	cmpb   $0x1,(%ecx)
f01040c8:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01040cb:	39 da                	cmp    %ebx,%edx
f01040cd:	75 ed                	jne    f01040bc <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01040cf:	89 f0                	mov    %esi,%eax
f01040d1:	5b                   	pop    %ebx
f01040d2:	5e                   	pop    %esi
f01040d3:	5d                   	pop    %ebp
f01040d4:	c3                   	ret    

f01040d5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01040d5:	55                   	push   %ebp
f01040d6:	89 e5                	mov    %esp,%ebp
f01040d8:	56                   	push   %esi
f01040d9:	53                   	push   %ebx
f01040da:	8b 75 08             	mov    0x8(%ebp),%esi
f01040dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01040e0:	8b 55 10             	mov    0x10(%ebp),%edx
f01040e3:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01040e5:	85 d2                	test   %edx,%edx
f01040e7:	74 21                	je     f010410a <strlcpy+0x35>
f01040e9:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01040ed:	89 f2                	mov    %esi,%edx
f01040ef:	eb 09                	jmp    f01040fa <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01040f1:	83 c2 01             	add    $0x1,%edx
f01040f4:	83 c1 01             	add    $0x1,%ecx
f01040f7:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01040fa:	39 c2                	cmp    %eax,%edx
f01040fc:	74 09                	je     f0104107 <strlcpy+0x32>
f01040fe:	0f b6 19             	movzbl (%ecx),%ebx
f0104101:	84 db                	test   %bl,%bl
f0104103:	75 ec                	jne    f01040f1 <strlcpy+0x1c>
f0104105:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f0104107:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f010410a:	29 f0                	sub    %esi,%eax
}
f010410c:	5b                   	pop    %ebx
f010410d:	5e                   	pop    %esi
f010410e:	5d                   	pop    %ebp
f010410f:	c3                   	ret    

f0104110 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0104110:	55                   	push   %ebp
f0104111:	89 e5                	mov    %esp,%ebp
f0104113:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104116:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f0104119:	eb 06                	jmp    f0104121 <strcmp+0x11>
		p++, q++;
f010411b:	83 c1 01             	add    $0x1,%ecx
f010411e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0104121:	0f b6 01             	movzbl (%ecx),%eax
f0104124:	84 c0                	test   %al,%al
f0104126:	74 04                	je     f010412c <strcmp+0x1c>
f0104128:	3a 02                	cmp    (%edx),%al
f010412a:	74 ef                	je     f010411b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f010412c:	0f b6 c0             	movzbl %al,%eax
f010412f:	0f b6 12             	movzbl (%edx),%edx
f0104132:	29 d0                	sub    %edx,%eax
}
f0104134:	5d                   	pop    %ebp
f0104135:	c3                   	ret    

f0104136 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f0104136:	55                   	push   %ebp
f0104137:	89 e5                	mov    %esp,%ebp
f0104139:	53                   	push   %ebx
f010413a:	8b 45 08             	mov    0x8(%ebp),%eax
f010413d:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104140:	89 c3                	mov    %eax,%ebx
f0104142:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f0104145:	eb 06                	jmp    f010414d <strncmp+0x17>
		n--, p++, q++;
f0104147:	83 c0 01             	add    $0x1,%eax
f010414a:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010414d:	39 d8                	cmp    %ebx,%eax
f010414f:	74 15                	je     f0104166 <strncmp+0x30>
f0104151:	0f b6 08             	movzbl (%eax),%ecx
f0104154:	84 c9                	test   %cl,%cl
f0104156:	74 04                	je     f010415c <strncmp+0x26>
f0104158:	3a 0a                	cmp    (%edx),%cl
f010415a:	74 eb                	je     f0104147 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f010415c:	0f b6 00             	movzbl (%eax),%eax
f010415f:	0f b6 12             	movzbl (%edx),%edx
f0104162:	29 d0                	sub    %edx,%eax
f0104164:	eb 05                	jmp    f010416b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0104166:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010416b:	5b                   	pop    %ebx
f010416c:	5d                   	pop    %ebp
f010416d:	c3                   	ret    

f010416e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010416e:	55                   	push   %ebp
f010416f:	89 e5                	mov    %esp,%ebp
f0104171:	8b 45 08             	mov    0x8(%ebp),%eax
f0104174:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104178:	eb 07                	jmp    f0104181 <strchr+0x13>
		if (*s == c)
f010417a:	38 ca                	cmp    %cl,%dl
f010417c:	74 0f                	je     f010418d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010417e:	83 c0 01             	add    $0x1,%eax
f0104181:	0f b6 10             	movzbl (%eax),%edx
f0104184:	84 d2                	test   %dl,%dl
f0104186:	75 f2                	jne    f010417a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0104188:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010418d:	5d                   	pop    %ebp
f010418e:	c3                   	ret    

f010418f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010418f:	55                   	push   %ebp
f0104190:	89 e5                	mov    %esp,%ebp
f0104192:	8b 45 08             	mov    0x8(%ebp),%eax
f0104195:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0104199:	eb 03                	jmp    f010419e <strfind+0xf>
f010419b:	83 c0 01             	add    $0x1,%eax
f010419e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f01041a1:	38 ca                	cmp    %cl,%dl
f01041a3:	74 04                	je     f01041a9 <strfind+0x1a>
f01041a5:	84 d2                	test   %dl,%dl
f01041a7:	75 f2                	jne    f010419b <strfind+0xc>
			break;
	return (char *) s;
}
f01041a9:	5d                   	pop    %ebp
f01041aa:	c3                   	ret    

f01041ab <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f01041ab:	55                   	push   %ebp
f01041ac:	89 e5                	mov    %esp,%ebp
f01041ae:	57                   	push   %edi
f01041af:	56                   	push   %esi
f01041b0:	53                   	push   %ebx
f01041b1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01041b4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01041b7:	85 c9                	test   %ecx,%ecx
f01041b9:	74 36                	je     f01041f1 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01041bb:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01041c1:	75 28                	jne    f01041eb <memset+0x40>
f01041c3:	f6 c1 03             	test   $0x3,%cl
f01041c6:	75 23                	jne    f01041eb <memset+0x40>
		c &= 0xFF;
f01041c8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01041cc:	89 d3                	mov    %edx,%ebx
f01041ce:	c1 e3 08             	shl    $0x8,%ebx
f01041d1:	89 d6                	mov    %edx,%esi
f01041d3:	c1 e6 18             	shl    $0x18,%esi
f01041d6:	89 d0                	mov    %edx,%eax
f01041d8:	c1 e0 10             	shl    $0x10,%eax
f01041db:	09 f0                	or     %esi,%eax
f01041dd:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01041df:	89 d8                	mov    %ebx,%eax
f01041e1:	09 d0                	or     %edx,%eax
f01041e3:	c1 e9 02             	shr    $0x2,%ecx
f01041e6:	fc                   	cld    
f01041e7:	f3 ab                	rep stos %eax,%es:(%edi)
f01041e9:	eb 06                	jmp    f01041f1 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01041eb:	8b 45 0c             	mov    0xc(%ebp),%eax
f01041ee:	fc                   	cld    
f01041ef:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01041f1:	89 f8                	mov    %edi,%eax
f01041f3:	5b                   	pop    %ebx
f01041f4:	5e                   	pop    %esi
f01041f5:	5f                   	pop    %edi
f01041f6:	5d                   	pop    %ebp
f01041f7:	c3                   	ret    

f01041f8 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01041f8:	55                   	push   %ebp
f01041f9:	89 e5                	mov    %esp,%ebp
f01041fb:	57                   	push   %edi
f01041fc:	56                   	push   %esi
f01041fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0104200:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104203:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0104206:	39 c6                	cmp    %eax,%esi
f0104208:	73 35                	jae    f010423f <memmove+0x47>
f010420a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f010420d:	39 d0                	cmp    %edx,%eax
f010420f:	73 2e                	jae    f010423f <memmove+0x47>
		s += n;
		d += n;
f0104211:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0104214:	89 d6                	mov    %edx,%esi
f0104216:	09 fe                	or     %edi,%esi
f0104218:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010421e:	75 13                	jne    f0104233 <memmove+0x3b>
f0104220:	f6 c1 03             	test   $0x3,%cl
f0104223:	75 0e                	jne    f0104233 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f0104225:	83 ef 04             	sub    $0x4,%edi
f0104228:	8d 72 fc             	lea    -0x4(%edx),%esi
f010422b:	c1 e9 02             	shr    $0x2,%ecx
f010422e:	fd                   	std    
f010422f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104231:	eb 09                	jmp    f010423c <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f0104233:	83 ef 01             	sub    $0x1,%edi
f0104236:	8d 72 ff             	lea    -0x1(%edx),%esi
f0104239:	fd                   	std    
f010423a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f010423c:	fc                   	cld    
f010423d:	eb 1d                	jmp    f010425c <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010423f:	89 f2                	mov    %esi,%edx
f0104241:	09 c2                	or     %eax,%edx
f0104243:	f6 c2 03             	test   $0x3,%dl
f0104246:	75 0f                	jne    f0104257 <memmove+0x5f>
f0104248:	f6 c1 03             	test   $0x3,%cl
f010424b:	75 0a                	jne    f0104257 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f010424d:	c1 e9 02             	shr    $0x2,%ecx
f0104250:	89 c7                	mov    %eax,%edi
f0104252:	fc                   	cld    
f0104253:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0104255:	eb 05                	jmp    f010425c <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0104257:	89 c7                	mov    %eax,%edi
f0104259:	fc                   	cld    
f010425a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f010425c:	5e                   	pop    %esi
f010425d:	5f                   	pop    %edi
f010425e:	5d                   	pop    %ebp
f010425f:	c3                   	ret    

f0104260 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0104260:	55                   	push   %ebp
f0104261:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0104263:	ff 75 10             	pushl  0x10(%ebp)
f0104266:	ff 75 0c             	pushl  0xc(%ebp)
f0104269:	ff 75 08             	pushl  0x8(%ebp)
f010426c:	e8 87 ff ff ff       	call   f01041f8 <memmove>
}
f0104271:	c9                   	leave  
f0104272:	c3                   	ret    

f0104273 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0104273:	55                   	push   %ebp
f0104274:	89 e5                	mov    %esp,%ebp
f0104276:	56                   	push   %esi
f0104277:	53                   	push   %ebx
f0104278:	8b 45 08             	mov    0x8(%ebp),%eax
f010427b:	8b 55 0c             	mov    0xc(%ebp),%edx
f010427e:	89 c6                	mov    %eax,%esi
f0104280:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0104283:	eb 1a                	jmp    f010429f <memcmp+0x2c>
		if (*s1 != *s2)
f0104285:	0f b6 08             	movzbl (%eax),%ecx
f0104288:	0f b6 1a             	movzbl (%edx),%ebx
f010428b:	38 d9                	cmp    %bl,%cl
f010428d:	74 0a                	je     f0104299 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f010428f:	0f b6 c1             	movzbl %cl,%eax
f0104292:	0f b6 db             	movzbl %bl,%ebx
f0104295:	29 d8                	sub    %ebx,%eax
f0104297:	eb 0f                	jmp    f01042a8 <memcmp+0x35>
		s1++, s2++;
f0104299:	83 c0 01             	add    $0x1,%eax
f010429c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010429f:	39 f0                	cmp    %esi,%eax
f01042a1:	75 e2                	jne    f0104285 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f01042a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01042a8:	5b                   	pop    %ebx
f01042a9:	5e                   	pop    %esi
f01042aa:	5d                   	pop    %ebp
f01042ab:	c3                   	ret    

f01042ac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01042ac:	55                   	push   %ebp
f01042ad:	89 e5                	mov    %esp,%ebp
f01042af:	53                   	push   %ebx
f01042b0:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01042b3:	89 c1                	mov    %eax,%ecx
f01042b5:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f01042b8:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01042bc:	eb 0a                	jmp    f01042c8 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f01042be:	0f b6 10             	movzbl (%eax),%edx
f01042c1:	39 da                	cmp    %ebx,%edx
f01042c3:	74 07                	je     f01042cc <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01042c5:	83 c0 01             	add    $0x1,%eax
f01042c8:	39 c8                	cmp    %ecx,%eax
f01042ca:	72 f2                	jb     f01042be <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01042cc:	5b                   	pop    %ebx
f01042cd:	5d                   	pop    %ebp
f01042ce:	c3                   	ret    

f01042cf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01042cf:	55                   	push   %ebp
f01042d0:	89 e5                	mov    %esp,%ebp
f01042d2:	57                   	push   %edi
f01042d3:	56                   	push   %esi
f01042d4:	53                   	push   %ebx
f01042d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01042d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01042db:	eb 03                	jmp    f01042e0 <strtol+0x11>
		s++;
f01042dd:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01042e0:	0f b6 01             	movzbl (%ecx),%eax
f01042e3:	3c 20                	cmp    $0x20,%al
f01042e5:	74 f6                	je     f01042dd <strtol+0xe>
f01042e7:	3c 09                	cmp    $0x9,%al
f01042e9:	74 f2                	je     f01042dd <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01042eb:	3c 2b                	cmp    $0x2b,%al
f01042ed:	75 0a                	jne    f01042f9 <strtol+0x2a>
		s++;
f01042ef:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01042f2:	bf 00 00 00 00       	mov    $0x0,%edi
f01042f7:	eb 11                	jmp    f010430a <strtol+0x3b>
f01042f9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01042fe:	3c 2d                	cmp    $0x2d,%al
f0104300:	75 08                	jne    f010430a <strtol+0x3b>
		s++, neg = 1;
f0104302:	83 c1 01             	add    $0x1,%ecx
f0104305:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010430a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f0104310:	75 15                	jne    f0104327 <strtol+0x58>
f0104312:	80 39 30             	cmpb   $0x30,(%ecx)
f0104315:	75 10                	jne    f0104327 <strtol+0x58>
f0104317:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f010431b:	75 7c                	jne    f0104399 <strtol+0xca>
		s += 2, base = 16;
f010431d:	83 c1 02             	add    $0x2,%ecx
f0104320:	bb 10 00 00 00       	mov    $0x10,%ebx
f0104325:	eb 16                	jmp    f010433d <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f0104327:	85 db                	test   %ebx,%ebx
f0104329:	75 12                	jne    f010433d <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f010432b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104330:	80 39 30             	cmpb   $0x30,(%ecx)
f0104333:	75 08                	jne    f010433d <strtol+0x6e>
		s++, base = 8;
f0104335:	83 c1 01             	add    $0x1,%ecx
f0104338:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f010433d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104342:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0104345:	0f b6 11             	movzbl (%ecx),%edx
f0104348:	8d 72 d0             	lea    -0x30(%edx),%esi
f010434b:	89 f3                	mov    %esi,%ebx
f010434d:	80 fb 09             	cmp    $0x9,%bl
f0104350:	77 08                	ja     f010435a <strtol+0x8b>
			dig = *s - '0';
f0104352:	0f be d2             	movsbl %dl,%edx
f0104355:	83 ea 30             	sub    $0x30,%edx
f0104358:	eb 22                	jmp    f010437c <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f010435a:	8d 72 9f             	lea    -0x61(%edx),%esi
f010435d:	89 f3                	mov    %esi,%ebx
f010435f:	80 fb 19             	cmp    $0x19,%bl
f0104362:	77 08                	ja     f010436c <strtol+0x9d>
			dig = *s - 'a' + 10;
f0104364:	0f be d2             	movsbl %dl,%edx
f0104367:	83 ea 57             	sub    $0x57,%edx
f010436a:	eb 10                	jmp    f010437c <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f010436c:	8d 72 bf             	lea    -0x41(%edx),%esi
f010436f:	89 f3                	mov    %esi,%ebx
f0104371:	80 fb 19             	cmp    $0x19,%bl
f0104374:	77 16                	ja     f010438c <strtol+0xbd>
			dig = *s - 'A' + 10;
f0104376:	0f be d2             	movsbl %dl,%edx
f0104379:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f010437c:	3b 55 10             	cmp    0x10(%ebp),%edx
f010437f:	7d 0b                	jge    f010438c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0104381:	83 c1 01             	add    $0x1,%ecx
f0104384:	0f af 45 10          	imul   0x10(%ebp),%eax
f0104388:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f010438a:	eb b9                	jmp    f0104345 <strtol+0x76>

	if (endptr)
f010438c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0104390:	74 0d                	je     f010439f <strtol+0xd0>
		*endptr = (char *) s;
f0104392:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104395:	89 0e                	mov    %ecx,(%esi)
f0104397:	eb 06                	jmp    f010439f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104399:	85 db                	test   %ebx,%ebx
f010439b:	74 98                	je     f0104335 <strtol+0x66>
f010439d:	eb 9e                	jmp    f010433d <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f010439f:	89 c2                	mov    %eax,%edx
f01043a1:	f7 da                	neg    %edx
f01043a3:	85 ff                	test   %edi,%edi
f01043a5:	0f 45 c2             	cmovne %edx,%eax
}
f01043a8:	5b                   	pop    %ebx
f01043a9:	5e                   	pop    %esi
f01043aa:	5f                   	pop    %edi
f01043ab:	5d                   	pop    %ebp
f01043ac:	c3                   	ret    
f01043ad:	66 90                	xchg   %ax,%ax
f01043af:	90                   	nop

f01043b0 <__udivdi3>:
f01043b0:	55                   	push   %ebp
f01043b1:	57                   	push   %edi
f01043b2:	56                   	push   %esi
f01043b3:	53                   	push   %ebx
f01043b4:	83 ec 1c             	sub    $0x1c,%esp
f01043b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f01043bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f01043bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f01043c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01043c7:	85 f6                	test   %esi,%esi
f01043c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01043cd:	89 ca                	mov    %ecx,%edx
f01043cf:	89 f8                	mov    %edi,%eax
f01043d1:	75 3d                	jne    f0104410 <__udivdi3+0x60>
f01043d3:	39 cf                	cmp    %ecx,%edi
f01043d5:	0f 87 c5 00 00 00    	ja     f01044a0 <__udivdi3+0xf0>
f01043db:	85 ff                	test   %edi,%edi
f01043dd:	89 fd                	mov    %edi,%ebp
f01043df:	75 0b                	jne    f01043ec <__udivdi3+0x3c>
f01043e1:	b8 01 00 00 00       	mov    $0x1,%eax
f01043e6:	31 d2                	xor    %edx,%edx
f01043e8:	f7 f7                	div    %edi
f01043ea:	89 c5                	mov    %eax,%ebp
f01043ec:	89 c8                	mov    %ecx,%eax
f01043ee:	31 d2                	xor    %edx,%edx
f01043f0:	f7 f5                	div    %ebp
f01043f2:	89 c1                	mov    %eax,%ecx
f01043f4:	89 d8                	mov    %ebx,%eax
f01043f6:	89 cf                	mov    %ecx,%edi
f01043f8:	f7 f5                	div    %ebp
f01043fa:	89 c3                	mov    %eax,%ebx
f01043fc:	89 d8                	mov    %ebx,%eax
f01043fe:	89 fa                	mov    %edi,%edx
f0104400:	83 c4 1c             	add    $0x1c,%esp
f0104403:	5b                   	pop    %ebx
f0104404:	5e                   	pop    %esi
f0104405:	5f                   	pop    %edi
f0104406:	5d                   	pop    %ebp
f0104407:	c3                   	ret    
f0104408:	90                   	nop
f0104409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104410:	39 ce                	cmp    %ecx,%esi
f0104412:	77 74                	ja     f0104488 <__udivdi3+0xd8>
f0104414:	0f bd fe             	bsr    %esi,%edi
f0104417:	83 f7 1f             	xor    $0x1f,%edi
f010441a:	0f 84 98 00 00 00    	je     f01044b8 <__udivdi3+0x108>
f0104420:	bb 20 00 00 00       	mov    $0x20,%ebx
f0104425:	89 f9                	mov    %edi,%ecx
f0104427:	89 c5                	mov    %eax,%ebp
f0104429:	29 fb                	sub    %edi,%ebx
f010442b:	d3 e6                	shl    %cl,%esi
f010442d:	89 d9                	mov    %ebx,%ecx
f010442f:	d3 ed                	shr    %cl,%ebp
f0104431:	89 f9                	mov    %edi,%ecx
f0104433:	d3 e0                	shl    %cl,%eax
f0104435:	09 ee                	or     %ebp,%esi
f0104437:	89 d9                	mov    %ebx,%ecx
f0104439:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010443d:	89 d5                	mov    %edx,%ebp
f010443f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0104443:	d3 ed                	shr    %cl,%ebp
f0104445:	89 f9                	mov    %edi,%ecx
f0104447:	d3 e2                	shl    %cl,%edx
f0104449:	89 d9                	mov    %ebx,%ecx
f010444b:	d3 e8                	shr    %cl,%eax
f010444d:	09 c2                	or     %eax,%edx
f010444f:	89 d0                	mov    %edx,%eax
f0104451:	89 ea                	mov    %ebp,%edx
f0104453:	f7 f6                	div    %esi
f0104455:	89 d5                	mov    %edx,%ebp
f0104457:	89 c3                	mov    %eax,%ebx
f0104459:	f7 64 24 0c          	mull   0xc(%esp)
f010445d:	39 d5                	cmp    %edx,%ebp
f010445f:	72 10                	jb     f0104471 <__udivdi3+0xc1>
f0104461:	8b 74 24 08          	mov    0x8(%esp),%esi
f0104465:	89 f9                	mov    %edi,%ecx
f0104467:	d3 e6                	shl    %cl,%esi
f0104469:	39 c6                	cmp    %eax,%esi
f010446b:	73 07                	jae    f0104474 <__udivdi3+0xc4>
f010446d:	39 d5                	cmp    %edx,%ebp
f010446f:	75 03                	jne    f0104474 <__udivdi3+0xc4>
f0104471:	83 eb 01             	sub    $0x1,%ebx
f0104474:	31 ff                	xor    %edi,%edi
f0104476:	89 d8                	mov    %ebx,%eax
f0104478:	89 fa                	mov    %edi,%edx
f010447a:	83 c4 1c             	add    $0x1c,%esp
f010447d:	5b                   	pop    %ebx
f010447e:	5e                   	pop    %esi
f010447f:	5f                   	pop    %edi
f0104480:	5d                   	pop    %ebp
f0104481:	c3                   	ret    
f0104482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104488:	31 ff                	xor    %edi,%edi
f010448a:	31 db                	xor    %ebx,%ebx
f010448c:	89 d8                	mov    %ebx,%eax
f010448e:	89 fa                	mov    %edi,%edx
f0104490:	83 c4 1c             	add    $0x1c,%esp
f0104493:	5b                   	pop    %ebx
f0104494:	5e                   	pop    %esi
f0104495:	5f                   	pop    %edi
f0104496:	5d                   	pop    %ebp
f0104497:	c3                   	ret    
f0104498:	90                   	nop
f0104499:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01044a0:	89 d8                	mov    %ebx,%eax
f01044a2:	f7 f7                	div    %edi
f01044a4:	31 ff                	xor    %edi,%edi
f01044a6:	89 c3                	mov    %eax,%ebx
f01044a8:	89 d8                	mov    %ebx,%eax
f01044aa:	89 fa                	mov    %edi,%edx
f01044ac:	83 c4 1c             	add    $0x1c,%esp
f01044af:	5b                   	pop    %ebx
f01044b0:	5e                   	pop    %esi
f01044b1:	5f                   	pop    %edi
f01044b2:	5d                   	pop    %ebp
f01044b3:	c3                   	ret    
f01044b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01044b8:	39 ce                	cmp    %ecx,%esi
f01044ba:	72 0c                	jb     f01044c8 <__udivdi3+0x118>
f01044bc:	31 db                	xor    %ebx,%ebx
f01044be:	3b 44 24 08          	cmp    0x8(%esp),%eax
f01044c2:	0f 87 34 ff ff ff    	ja     f01043fc <__udivdi3+0x4c>
f01044c8:	bb 01 00 00 00       	mov    $0x1,%ebx
f01044cd:	e9 2a ff ff ff       	jmp    f01043fc <__udivdi3+0x4c>
f01044d2:	66 90                	xchg   %ax,%ax
f01044d4:	66 90                	xchg   %ax,%ax
f01044d6:	66 90                	xchg   %ax,%ax
f01044d8:	66 90                	xchg   %ax,%ax
f01044da:	66 90                	xchg   %ax,%ax
f01044dc:	66 90                	xchg   %ax,%ax
f01044de:	66 90                	xchg   %ax,%ax

f01044e0 <__umoddi3>:
f01044e0:	55                   	push   %ebp
f01044e1:	57                   	push   %edi
f01044e2:	56                   	push   %esi
f01044e3:	53                   	push   %ebx
f01044e4:	83 ec 1c             	sub    $0x1c,%esp
f01044e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f01044eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f01044ef:	8b 74 24 34          	mov    0x34(%esp),%esi
f01044f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f01044f7:	85 d2                	test   %edx,%edx
f01044f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01044fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104501:	89 f3                	mov    %esi,%ebx
f0104503:	89 3c 24             	mov    %edi,(%esp)
f0104506:	89 74 24 04          	mov    %esi,0x4(%esp)
f010450a:	75 1c                	jne    f0104528 <__umoddi3+0x48>
f010450c:	39 f7                	cmp    %esi,%edi
f010450e:	76 50                	jbe    f0104560 <__umoddi3+0x80>
f0104510:	89 c8                	mov    %ecx,%eax
f0104512:	89 f2                	mov    %esi,%edx
f0104514:	f7 f7                	div    %edi
f0104516:	89 d0                	mov    %edx,%eax
f0104518:	31 d2                	xor    %edx,%edx
f010451a:	83 c4 1c             	add    $0x1c,%esp
f010451d:	5b                   	pop    %ebx
f010451e:	5e                   	pop    %esi
f010451f:	5f                   	pop    %edi
f0104520:	5d                   	pop    %ebp
f0104521:	c3                   	ret    
f0104522:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0104528:	39 f2                	cmp    %esi,%edx
f010452a:	89 d0                	mov    %edx,%eax
f010452c:	77 52                	ja     f0104580 <__umoddi3+0xa0>
f010452e:	0f bd ea             	bsr    %edx,%ebp
f0104531:	83 f5 1f             	xor    $0x1f,%ebp
f0104534:	75 5a                	jne    f0104590 <__umoddi3+0xb0>
f0104536:	3b 54 24 04          	cmp    0x4(%esp),%edx
f010453a:	0f 82 e0 00 00 00    	jb     f0104620 <__umoddi3+0x140>
f0104540:	39 0c 24             	cmp    %ecx,(%esp)
f0104543:	0f 86 d7 00 00 00    	jbe    f0104620 <__umoddi3+0x140>
f0104549:	8b 44 24 08          	mov    0x8(%esp),%eax
f010454d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0104551:	83 c4 1c             	add    $0x1c,%esp
f0104554:	5b                   	pop    %ebx
f0104555:	5e                   	pop    %esi
f0104556:	5f                   	pop    %edi
f0104557:	5d                   	pop    %ebp
f0104558:	c3                   	ret    
f0104559:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0104560:	85 ff                	test   %edi,%edi
f0104562:	89 fd                	mov    %edi,%ebp
f0104564:	75 0b                	jne    f0104571 <__umoddi3+0x91>
f0104566:	b8 01 00 00 00       	mov    $0x1,%eax
f010456b:	31 d2                	xor    %edx,%edx
f010456d:	f7 f7                	div    %edi
f010456f:	89 c5                	mov    %eax,%ebp
f0104571:	89 f0                	mov    %esi,%eax
f0104573:	31 d2                	xor    %edx,%edx
f0104575:	f7 f5                	div    %ebp
f0104577:	89 c8                	mov    %ecx,%eax
f0104579:	f7 f5                	div    %ebp
f010457b:	89 d0                	mov    %edx,%eax
f010457d:	eb 99                	jmp    f0104518 <__umoddi3+0x38>
f010457f:	90                   	nop
f0104580:	89 c8                	mov    %ecx,%eax
f0104582:	89 f2                	mov    %esi,%edx
f0104584:	83 c4 1c             	add    $0x1c,%esp
f0104587:	5b                   	pop    %ebx
f0104588:	5e                   	pop    %esi
f0104589:	5f                   	pop    %edi
f010458a:	5d                   	pop    %ebp
f010458b:	c3                   	ret    
f010458c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0104590:	8b 34 24             	mov    (%esp),%esi
f0104593:	bf 20 00 00 00       	mov    $0x20,%edi
f0104598:	89 e9                	mov    %ebp,%ecx
f010459a:	29 ef                	sub    %ebp,%edi
f010459c:	d3 e0                	shl    %cl,%eax
f010459e:	89 f9                	mov    %edi,%ecx
f01045a0:	89 f2                	mov    %esi,%edx
f01045a2:	d3 ea                	shr    %cl,%edx
f01045a4:	89 e9                	mov    %ebp,%ecx
f01045a6:	09 c2                	or     %eax,%edx
f01045a8:	89 d8                	mov    %ebx,%eax
f01045aa:	89 14 24             	mov    %edx,(%esp)
f01045ad:	89 f2                	mov    %esi,%edx
f01045af:	d3 e2                	shl    %cl,%edx
f01045b1:	89 f9                	mov    %edi,%ecx
f01045b3:	89 54 24 04          	mov    %edx,0x4(%esp)
f01045b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
f01045bb:	d3 e8                	shr    %cl,%eax
f01045bd:	89 e9                	mov    %ebp,%ecx
f01045bf:	89 c6                	mov    %eax,%esi
f01045c1:	d3 e3                	shl    %cl,%ebx
f01045c3:	89 f9                	mov    %edi,%ecx
f01045c5:	89 d0                	mov    %edx,%eax
f01045c7:	d3 e8                	shr    %cl,%eax
f01045c9:	89 e9                	mov    %ebp,%ecx
f01045cb:	09 d8                	or     %ebx,%eax
f01045cd:	89 d3                	mov    %edx,%ebx
f01045cf:	89 f2                	mov    %esi,%edx
f01045d1:	f7 34 24             	divl   (%esp)
f01045d4:	89 d6                	mov    %edx,%esi
f01045d6:	d3 e3                	shl    %cl,%ebx
f01045d8:	f7 64 24 04          	mull   0x4(%esp)
f01045dc:	39 d6                	cmp    %edx,%esi
f01045de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01045e2:	89 d1                	mov    %edx,%ecx
f01045e4:	89 c3                	mov    %eax,%ebx
f01045e6:	72 08                	jb     f01045f0 <__umoddi3+0x110>
f01045e8:	75 11                	jne    f01045fb <__umoddi3+0x11b>
f01045ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
f01045ee:	73 0b                	jae    f01045fb <__umoddi3+0x11b>
f01045f0:	2b 44 24 04          	sub    0x4(%esp),%eax
f01045f4:	1b 14 24             	sbb    (%esp),%edx
f01045f7:	89 d1                	mov    %edx,%ecx
f01045f9:	89 c3                	mov    %eax,%ebx
f01045fb:	8b 54 24 08          	mov    0x8(%esp),%edx
f01045ff:	29 da                	sub    %ebx,%edx
f0104601:	19 ce                	sbb    %ecx,%esi
f0104603:	89 f9                	mov    %edi,%ecx
f0104605:	89 f0                	mov    %esi,%eax
f0104607:	d3 e0                	shl    %cl,%eax
f0104609:	89 e9                	mov    %ebp,%ecx
f010460b:	d3 ea                	shr    %cl,%edx
f010460d:	89 e9                	mov    %ebp,%ecx
f010460f:	d3 ee                	shr    %cl,%esi
f0104611:	09 d0                	or     %edx,%eax
f0104613:	89 f2                	mov    %esi,%edx
f0104615:	83 c4 1c             	add    $0x1c,%esp
f0104618:	5b                   	pop    %ebx
f0104619:	5e                   	pop    %esi
f010461a:	5f                   	pop    %edi
f010461b:	5d                   	pop    %ebp
f010461c:	c3                   	ret    
f010461d:	8d 76 00             	lea    0x0(%esi),%esi
f0104620:	29 f9                	sub    %edi,%ecx
f0104622:	19 d6                	sbb    %edx,%esi
f0104624:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104628:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f010462c:	e9 18 ff ff ff       	jmp    f0104549 <__umoddi3+0x69>
