
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
f0100015:	b8 00 d0 11 00       	mov    $0x11d000,%eax
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
f0100034:	bc 00 d0 11 f0       	mov    $0xf011d000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 5c 00 00 00       	call   f010009a <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	56                   	push   %esi
f0100044:	53                   	push   %ebx
f0100045:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100048:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 1e 21 f0    	mov    %esi,0xf0211e80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 15 57 00 00       	call   f0105776 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 00 5e 10 f0       	push   $0xf0105e00
f010006d:	e8 02 35 00 00       	call   f0103574 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 d2 34 00 00       	call   f010354e <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 74 6f 10 f0 	movl   $0xf0106f74,(%esp)
f0100083:	e8 ec 34 00 00       	call   f0103574 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 24 08 00 00       	call   f01008b9 <monitor>
f0100095:	83 c4 10             	add    $0x10,%esp
f0100098:	eb f1                	jmp    f010008b <_panic+0x4b>

f010009a <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f010009a:	55                   	push   %ebp
f010009b:	89 e5                	mov    %esp,%ebp
f010009d:	53                   	push   %ebx
f010009e:	83 ec 08             	sub    $0x8,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f01000a1:	b8 08 30 25 f0       	mov    $0xf0253008,%eax
f01000a6:	2d 44 05 21 f0       	sub    $0xf0210544,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 44 05 21 f0       	push   $0xf0210544
f01000b3:	e8 9d 50 00 00       	call   f0105155 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 99 05 00 00       	call   f0100656 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 6c 5e 10 f0       	push   $0xf0105e6c
f01000ca:	e8 a5 34 00 00       	call   f0103574 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 46 11 00 00       	call   f010121a <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 30 2d 00 00       	call   f0102e09 <env_init>
	trap_init();
f01000d9:	e8 61 35 00 00       	call   f010363f <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 89 53 00 00       	call   f010546c <mp_init>
	lapic_init();
f01000e3:	e8 a9 56 00 00       	call   f0105791 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 ae 33 00 00       	call   f010349b <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f01000f4:	e8 eb 58 00 00       	call   f01059e4 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 1e 21 f0 07 	cmpl   $0x7,0xf0211e88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 24 5e 10 f0       	push   $0xf0105e24
f010010f:	6a 68                	push   $0x68
f0100111:	68 87 5e 10 f0       	push   $0xf0105e87
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>

	// Write entry code to unused memory at MPENTRY_PADDR
	// 找到引导代码
	code = KADDR(MPENTRY_PADDR);
	// 将引导代码拷贝到 MPENTRY_PADDR
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 d2 53 10 f0       	mov    $0xf01053d2,%eax
f0100123:	2d 58 53 10 f0       	sub    $0xf0105358,%eax
f0100128:	50                   	push   %eax
f0100129:	68 58 53 10 f0       	push   $0xf0105358
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 6a 50 00 00       	call   f01051a2 <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp
	
	// Boot each AP one at a time
	// 逐一引导每个CPU
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 20 21 f0       	mov    $0xf0212020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 2f 56 00 00       	call   f0105776 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 20 21 f0       	add    $0xf0212020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		// 设置cpu的内核栈
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 20 21 f0       	sub    $0xf0212020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 b0 21 f0       	add    $0xf021b000,%eax
f010016b:	a3 84 1e 21 f0       	mov    %eax,0xf0211e84
		// Start the CPU at mpentry_start
		// 执行引导代码
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 5e 57 00 00       	call   f01058df <lapic_startap>
f0100181:	83 c4 10             	add    $0x10,%esp
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f0100184:	8b 43 04             	mov    0x4(%ebx),%eax
f0100187:	83 f8 01             	cmp    $0x1,%eax
f010018a:	75 f8                	jne    f0100184 <i386_init+0xea>
	// 将引导代码拷贝到 MPENTRY_PADDR
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
	
	// Boot each AP one at a time
	// 逐一引导每个CPU
	for (c = cpus; c < cpus + ncpu; c++) {
f010018c:	83 c3 74             	add    $0x74,%ebx
f010018f:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f0100196:	05 20 20 21 f0       	add    $0xf0212020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	// Starting non-boot CPUs
	// 引导启动APs
	boot_aps();

	// Start fs.
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 01                	push   $0x1
f01001a4:	68 a8 f8 1c f0       	push   $0xf01cf8a8
f01001a9:	e8 fd 2d 00 00       	call   f0102fab <env_create>


	// 创建进程s
#if defined(TEST)
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
f01001ae:	83 c4 08             	add    $0x8,%esp
f01001b1:	6a 00                	push   $0x0
f01001b3:	68 f4 a5 20 f0       	push   $0xf020a5f4
f01001b8:	e8 ee 2d 00 00       	call   f0102fab <env_create>
	//ENV_CREATE();

#endif // TEST*

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01001bd:	e8 38 04 00 00       	call   f01005fa <kbd_intr>

	// Schedule and run the first user environment!
	// 进程调度
	sched_yield();
f01001c2:	e8 9d 3e 00 00       	call   f0104064 <sched_yield>

f01001c7 <mp_main>:

// Setup code for APs
// cpu 启动后的调用的第一个程序
void
mp_main(void)
{
f01001c7:	55                   	push   %ebp
f01001c8:	89 e5                	mov    %esp,%ebp
f01001ca:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001cd:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001d2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001d7:	77 15                	ja     f01001ee <mp_main+0x27>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001d9:	50                   	push   %eax
f01001da:	68 48 5e 10 f0       	push   $0xf0105e48
f01001df:	68 84 00 00 00       	push   $0x84
f01001e4:	68 87 5e 10 f0       	push   $0xf0105e87
f01001e9:	e8 52 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001ee:	05 00 00 00 10       	add    $0x10000000,%eax
f01001f3:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001f6:	e8 7b 55 00 00       	call   f0105776 <cpunum>
f01001fb:	83 ec 08             	sub    $0x8,%esp
f01001fe:	50                   	push   %eax
f01001ff:	68 93 5e 10 f0       	push   $0xf0105e93
f0100204:	e8 6b 33 00 00       	call   f0103574 <cprintf>

	lapic_init();
f0100209:	e8 83 55 00 00       	call   f0105791 <lapic_init>
	env_init_percpu();
f010020e:	e8 c6 2b 00 00       	call   f0102dd9 <env_init_percpu>
	trap_init_percpu();
f0100213:	e8 70 33 00 00       	call   f0103588 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100218:	e8 59 55 00 00       	call   f0105776 <cpunum>
f010021d:	6b d0 74             	imul   $0x74,%eax,%edx
f0100220:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0100226:	b8 01 00 00 00       	mov    $0x1,%eax
f010022b:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f010022f:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f0100236:	e8 a9 57 00 00       	call   f01059e4 <spin_lock>
	// Your code here:
	// 获取大内核锁(在运行调度函数之前，必须获得大内核锁)
	lock_kernel();
	
	// 调度一个进程来执行
	sched_yield();
f010023b:	e8 24 3e 00 00       	call   f0104064 <sched_yield>

f0100240 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100240:	55                   	push   %ebp
f0100241:	89 e5                	mov    %esp,%ebp
f0100243:	53                   	push   %ebx
f0100244:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100247:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f010024a:	ff 75 0c             	pushl  0xc(%ebp)
f010024d:	ff 75 08             	pushl  0x8(%ebp)
f0100250:	68 a9 5e 10 f0       	push   $0xf0105ea9
f0100255:	e8 1a 33 00 00       	call   f0103574 <cprintf>
	vcprintf(fmt, ap);
f010025a:	83 c4 08             	add    $0x8,%esp
f010025d:	53                   	push   %ebx
f010025e:	ff 75 10             	pushl  0x10(%ebp)
f0100261:	e8 e8 32 00 00       	call   f010354e <vcprintf>
	cprintf("\n");
f0100266:	c7 04 24 74 6f 10 f0 	movl   $0xf0106f74,(%esp)
f010026d:	e8 02 33 00 00       	call   f0103574 <cprintf>
	va_end(ap);
}
f0100272:	83 c4 10             	add    $0x10,%esp
f0100275:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100278:	c9                   	leave  
f0100279:	c3                   	ret    

f010027a <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f010027a:	55                   	push   %ebp
f010027b:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010027d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100282:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f0100283:	a8 01                	test   $0x1,%al
f0100285:	74 0b                	je     f0100292 <serial_proc_data+0x18>
f0100287:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010028c:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f010028d:	0f b6 c0             	movzbl %al,%eax
f0100290:	eb 05                	jmp    f0100297 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100297:	5d                   	pop    %ebp
f0100298:	c3                   	ret    

f0100299 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100299:	55                   	push   %ebp
f010029a:	89 e5                	mov    %esp,%ebp
f010029c:	53                   	push   %ebx
f010029d:	83 ec 04             	sub    $0x4,%esp
f01002a0:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01002a2:	eb 2b                	jmp    f01002cf <cons_intr+0x36>
		if (c == 0)
f01002a4:	85 c0                	test   %eax,%eax
f01002a6:	74 27                	je     f01002cf <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f01002a8:	8b 0d 24 12 21 f0    	mov    0xf0211224,%ecx
f01002ae:	8d 51 01             	lea    0x1(%ecx),%edx
f01002b1:	89 15 24 12 21 f0    	mov    %edx,0xf0211224
f01002b7:	88 81 20 10 21 f0    	mov    %al,-0xfdeefe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002bd:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002c3:	75 0a                	jne    f01002cf <cons_intr+0x36>
			cons.wpos = 0;
f01002c5:	c7 05 24 12 21 f0 00 	movl   $0x0,0xf0211224
f01002cc:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002cf:	ff d3                	call   *%ebx
f01002d1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002d4:	75 ce                	jne    f01002a4 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002d6:	83 c4 04             	add    $0x4,%esp
f01002d9:	5b                   	pop    %ebx
f01002da:	5d                   	pop    %ebp
f01002db:	c3                   	ret    

f01002dc <kbd_proc_data>:
f01002dc:	ba 64 00 00 00       	mov    $0x64,%edx
f01002e1:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002e2:	a8 01                	test   $0x1,%al
f01002e4:	0f 84 f8 00 00 00    	je     f01003e2 <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002ea:	a8 20                	test   $0x20,%al
f01002ec:	0f 85 f6 00 00 00    	jne    f01003e8 <kbd_proc_data+0x10c>
f01002f2:	ba 60 00 00 00       	mov    $0x60,%edx
f01002f7:	ec                   	in     (%dx),%al
f01002f8:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002fa:	3c e0                	cmp    $0xe0,%al
f01002fc:	75 0d                	jne    f010030b <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002fe:	83 0d 00 10 21 f0 40 	orl    $0x40,0xf0211000
		return 0;
f0100305:	b8 00 00 00 00       	mov    $0x0,%eax
f010030a:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f010030b:	55                   	push   %ebp
f010030c:	89 e5                	mov    %esp,%ebp
f010030e:	53                   	push   %ebx
f010030f:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f0100312:	84 c0                	test   %al,%al
f0100314:	79 36                	jns    f010034c <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100316:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f010031c:	89 cb                	mov    %ecx,%ebx
f010031e:	83 e3 40             	and    $0x40,%ebx
f0100321:	83 e0 7f             	and    $0x7f,%eax
f0100324:	85 db                	test   %ebx,%ebx
f0100326:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100329:	0f b6 d2             	movzbl %dl,%edx
f010032c:	0f b6 82 20 60 10 f0 	movzbl -0xfef9fe0(%edx),%eax
f0100333:	83 c8 40             	or     $0x40,%eax
f0100336:	0f b6 c0             	movzbl %al,%eax
f0100339:	f7 d0                	not    %eax
f010033b:	21 c8                	and    %ecx,%eax
f010033d:	a3 00 10 21 f0       	mov    %eax,0xf0211000
		return 0;
f0100342:	b8 00 00 00 00       	mov    $0x0,%eax
f0100347:	e9 a4 00 00 00       	jmp    f01003f0 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f010034c:	8b 0d 00 10 21 f0    	mov    0xf0211000,%ecx
f0100352:	f6 c1 40             	test   $0x40,%cl
f0100355:	74 0e                	je     f0100365 <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100357:	83 c8 80             	or     $0xffffff80,%eax
f010035a:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010035c:	83 e1 bf             	and    $0xffffffbf,%ecx
f010035f:	89 0d 00 10 21 f0    	mov    %ecx,0xf0211000
	}

	shift |= shiftcode[data];
f0100365:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100368:	0f b6 82 20 60 10 f0 	movzbl -0xfef9fe0(%edx),%eax
f010036f:	0b 05 00 10 21 f0    	or     0xf0211000,%eax
f0100375:	0f b6 8a 20 5f 10 f0 	movzbl -0xfefa0e0(%edx),%ecx
f010037c:	31 c8                	xor    %ecx,%eax
f010037e:	a3 00 10 21 f0       	mov    %eax,0xf0211000

	c = charcode[shift & (CTL | SHIFT)][data];
f0100383:	89 c1                	mov    %eax,%ecx
f0100385:	83 e1 03             	and    $0x3,%ecx
f0100388:	8b 0c 8d 00 5f 10 f0 	mov    -0xfefa100(,%ecx,4),%ecx
f010038f:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f0100393:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f0100396:	a8 08                	test   $0x8,%al
f0100398:	74 1b                	je     f01003b5 <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f010039a:	89 da                	mov    %ebx,%edx
f010039c:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f010039f:	83 f9 19             	cmp    $0x19,%ecx
f01003a2:	77 05                	ja     f01003a9 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f01003a4:	83 eb 20             	sub    $0x20,%ebx
f01003a7:	eb 0c                	jmp    f01003b5 <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f01003a9:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f01003ac:	8d 4b 20             	lea    0x20(%ebx),%ecx
f01003af:	83 fa 19             	cmp    $0x19,%edx
f01003b2:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01003b5:	f7 d0                	not    %eax
f01003b7:	a8 06                	test   $0x6,%al
f01003b9:	75 33                	jne    f01003ee <kbd_proc_data+0x112>
f01003bb:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003c1:	75 2b                	jne    f01003ee <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003c3:	83 ec 0c             	sub    $0xc,%esp
f01003c6:	68 c3 5e 10 f0       	push   $0xf0105ec3
f01003cb:	e8 a4 31 00 00       	call   f0103574 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003d0:	ba 92 00 00 00       	mov    $0x92,%edx
f01003d5:	b8 03 00 00 00       	mov    $0x3,%eax
f01003da:	ee                   	out    %al,(%dx)
f01003db:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003de:	89 d8                	mov    %ebx,%eax
f01003e0:	eb 0e                	jmp    f01003f0 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003e2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003e7:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003ed:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003ee:	89 d8                	mov    %ebx,%eax
}
f01003f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003f3:	c9                   	leave  
f01003f4:	c3                   	ret    

f01003f5 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003f5:	55                   	push   %ebp
f01003f6:	89 e5                	mov    %esp,%ebp
f01003f8:	57                   	push   %edi
f01003f9:	56                   	push   %esi
f01003fa:	53                   	push   %ebx
f01003fb:	83 ec 1c             	sub    $0x1c,%esp
f01003fe:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f0100400:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100405:	be fd 03 00 00       	mov    $0x3fd,%esi
f010040a:	b9 84 00 00 00       	mov    $0x84,%ecx
f010040f:	eb 09                	jmp    f010041a <cons_putc+0x25>
f0100411:	89 ca                	mov    %ecx,%edx
f0100413:	ec                   	in     (%dx),%al
f0100414:	ec                   	in     (%dx),%al
f0100415:	ec                   	in     (%dx),%al
f0100416:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100417:	83 c3 01             	add    $0x1,%ebx
f010041a:	89 f2                	mov    %esi,%edx
f010041c:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010041d:	a8 20                	test   $0x20,%al
f010041f:	75 08                	jne    f0100429 <cons_putc+0x34>
f0100421:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100427:	7e e8                	jle    f0100411 <cons_putc+0x1c>
f0100429:	89 f8                	mov    %edi,%eax
f010042b:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010042e:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100433:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100434:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100439:	be 79 03 00 00       	mov    $0x379,%esi
f010043e:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100443:	eb 09                	jmp    f010044e <cons_putc+0x59>
f0100445:	89 ca                	mov    %ecx,%edx
f0100447:	ec                   	in     (%dx),%al
f0100448:	ec                   	in     (%dx),%al
f0100449:	ec                   	in     (%dx),%al
f010044a:	ec                   	in     (%dx),%al
f010044b:	83 c3 01             	add    $0x1,%ebx
f010044e:	89 f2                	mov    %esi,%edx
f0100450:	ec                   	in     (%dx),%al
f0100451:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100457:	7f 04                	jg     f010045d <cons_putc+0x68>
f0100459:	84 c0                	test   %al,%al
f010045b:	79 e8                	jns    f0100445 <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010045d:	ba 78 03 00 00       	mov    $0x378,%edx
f0100462:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100466:	ee                   	out    %al,(%dx)
f0100467:	ba 7a 03 00 00       	mov    $0x37a,%edx
f010046c:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100471:	ee                   	out    %al,(%dx)
f0100472:	b8 08 00 00 00       	mov    $0x8,%eax
f0100477:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100478:	89 fa                	mov    %edi,%edx
f010047a:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100480:	89 f8                	mov    %edi,%eax
f0100482:	80 cc 07             	or     $0x7,%ah
f0100485:	85 d2                	test   %edx,%edx
f0100487:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010048a:	89 f8                	mov    %edi,%eax
f010048c:	0f b6 c0             	movzbl %al,%eax
f010048f:	83 f8 09             	cmp    $0x9,%eax
f0100492:	74 74                	je     f0100508 <cons_putc+0x113>
f0100494:	83 f8 09             	cmp    $0x9,%eax
f0100497:	7f 0a                	jg     f01004a3 <cons_putc+0xae>
f0100499:	83 f8 08             	cmp    $0x8,%eax
f010049c:	74 14                	je     f01004b2 <cons_putc+0xbd>
f010049e:	e9 99 00 00 00       	jmp    f010053c <cons_putc+0x147>
f01004a3:	83 f8 0a             	cmp    $0xa,%eax
f01004a6:	74 3a                	je     f01004e2 <cons_putc+0xed>
f01004a8:	83 f8 0d             	cmp    $0xd,%eax
f01004ab:	74 3d                	je     f01004ea <cons_putc+0xf5>
f01004ad:	e9 8a 00 00 00       	jmp    f010053c <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f01004b2:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004b9:	66 85 c0             	test   %ax,%ax
f01004bc:	0f 84 e6 00 00 00    	je     f01005a8 <cons_putc+0x1b3>
			crt_pos--;
f01004c2:	83 e8 01             	sub    $0x1,%eax
f01004c5:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004cb:	0f b7 c0             	movzwl %ax,%eax
f01004ce:	66 81 e7 00 ff       	and    $0xff00,%di
f01004d3:	83 cf 20             	or     $0x20,%edi
f01004d6:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f01004dc:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004e0:	eb 78                	jmp    f010055a <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004e2:	66 83 05 28 12 21 f0 	addw   $0x50,0xf0211228
f01004e9:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004ea:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f01004f1:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004f7:	c1 e8 16             	shr    $0x16,%eax
f01004fa:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004fd:	c1 e0 04             	shl    $0x4,%eax
f0100500:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228
f0100506:	eb 52                	jmp    f010055a <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f0100508:	b8 20 00 00 00       	mov    $0x20,%eax
f010050d:	e8 e3 fe ff ff       	call   f01003f5 <cons_putc>
		cons_putc(' ');
f0100512:	b8 20 00 00 00       	mov    $0x20,%eax
f0100517:	e8 d9 fe ff ff       	call   f01003f5 <cons_putc>
		cons_putc(' ');
f010051c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100521:	e8 cf fe ff ff       	call   f01003f5 <cons_putc>
		cons_putc(' ');
f0100526:	b8 20 00 00 00       	mov    $0x20,%eax
f010052b:	e8 c5 fe ff ff       	call   f01003f5 <cons_putc>
		cons_putc(' ');
f0100530:	b8 20 00 00 00       	mov    $0x20,%eax
f0100535:	e8 bb fe ff ff       	call   f01003f5 <cons_putc>
f010053a:	eb 1e                	jmp    f010055a <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f010053c:	0f b7 05 28 12 21 f0 	movzwl 0xf0211228,%eax
f0100543:	8d 50 01             	lea    0x1(%eax),%edx
f0100546:	66 89 15 28 12 21 f0 	mov    %dx,0xf0211228
f010054d:	0f b7 c0             	movzwl %ax,%eax
f0100550:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f0100556:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f010055a:	66 81 3d 28 12 21 f0 	cmpw   $0x7cf,0xf0211228
f0100561:	cf 07 
f0100563:	76 43                	jbe    f01005a8 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100565:	a1 2c 12 21 f0       	mov    0xf021122c,%eax
f010056a:	83 ec 04             	sub    $0x4,%esp
f010056d:	68 00 0f 00 00       	push   $0xf00
f0100572:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100578:	52                   	push   %edx
f0100579:	50                   	push   %eax
f010057a:	e8 23 4c 00 00       	call   f01051a2 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010057f:	8b 15 2c 12 21 f0    	mov    0xf021122c,%edx
f0100585:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f010058b:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f0100591:	83 c4 10             	add    $0x10,%esp
f0100594:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100599:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f010059c:	39 d0                	cmp    %edx,%eax
f010059e:	75 f4                	jne    f0100594 <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f01005a0:	66 83 2d 28 12 21 f0 	subw   $0x50,0xf0211228
f01005a7:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f01005a8:	8b 0d 30 12 21 f0    	mov    0xf0211230,%ecx
f01005ae:	b8 0e 00 00 00       	mov    $0xe,%eax
f01005b3:	89 ca                	mov    %ecx,%edx
f01005b5:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005b6:	0f b7 1d 28 12 21 f0 	movzwl 0xf0211228,%ebx
f01005bd:	8d 71 01             	lea    0x1(%ecx),%esi
f01005c0:	89 d8                	mov    %ebx,%eax
f01005c2:	66 c1 e8 08          	shr    $0x8,%ax
f01005c6:	89 f2                	mov    %esi,%edx
f01005c8:	ee                   	out    %al,(%dx)
f01005c9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005ce:	89 ca                	mov    %ecx,%edx
f01005d0:	ee                   	out    %al,(%dx)
f01005d1:	89 d8                	mov    %ebx,%eax
f01005d3:	89 f2                	mov    %esi,%edx
f01005d5:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005d9:	5b                   	pop    %ebx
f01005da:	5e                   	pop    %esi
f01005db:	5f                   	pop    %edi
f01005dc:	5d                   	pop    %ebp
f01005dd:	c3                   	ret    

f01005de <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005de:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f01005e5:	74 11                	je     f01005f8 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005e7:	55                   	push   %ebp
f01005e8:	89 e5                	mov    %esp,%ebp
f01005ea:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005ed:	b8 7a 02 10 f0       	mov    $0xf010027a,%eax
f01005f2:	e8 a2 fc ff ff       	call   f0100299 <cons_intr>
}
f01005f7:	c9                   	leave  
f01005f8:	f3 c3                	repz ret 

f01005fa <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005fa:	55                   	push   %ebp
f01005fb:	89 e5                	mov    %esp,%ebp
f01005fd:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100600:	b8 dc 02 10 f0       	mov    $0xf01002dc,%eax
f0100605:	e8 8f fc ff ff       	call   f0100299 <cons_intr>
}
f010060a:	c9                   	leave  
f010060b:	c3                   	ret    

f010060c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010060c:	55                   	push   %ebp
f010060d:	89 e5                	mov    %esp,%ebp
f010060f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100612:	e8 c7 ff ff ff       	call   f01005de <serial_intr>
	kbd_intr();
f0100617:	e8 de ff ff ff       	call   f01005fa <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010061c:	a1 20 12 21 f0       	mov    0xf0211220,%eax
f0100621:	3b 05 24 12 21 f0    	cmp    0xf0211224,%eax
f0100627:	74 26                	je     f010064f <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100629:	8d 50 01             	lea    0x1(%eax),%edx
f010062c:	89 15 20 12 21 f0    	mov    %edx,0xf0211220
f0100632:	0f b6 88 20 10 21 f0 	movzbl -0xfdeefe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100639:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f010063b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f0100641:	75 11                	jne    f0100654 <cons_getc+0x48>
			cons.rpos = 0;
f0100643:	c7 05 20 12 21 f0 00 	movl   $0x0,0xf0211220
f010064a:	00 00 00 
f010064d:	eb 05                	jmp    f0100654 <cons_getc+0x48>
		return c;
	}
	return 0;
f010064f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0100654:	c9                   	leave  
f0100655:	c3                   	ret    

f0100656 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100656:	55                   	push   %ebp
f0100657:	89 e5                	mov    %esp,%ebp
f0100659:	57                   	push   %edi
f010065a:	56                   	push   %esi
f010065b:	53                   	push   %ebx
f010065c:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f010065f:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100666:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f010066d:	5a a5 
	if (*cp != 0xA55A) {
f010066f:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100676:	66 3d 5a a5          	cmp    $0xa55a,%ax
f010067a:	74 11                	je     f010068d <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f010067c:	c7 05 30 12 21 f0 b4 	movl   $0x3b4,0xf0211230
f0100683:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f0100686:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f010068b:	eb 16                	jmp    f01006a3 <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f010068d:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100694:	c7 05 30 12 21 f0 d4 	movl   $0x3d4,0xf0211230
f010069b:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f010069e:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f01006a3:	8b 3d 30 12 21 f0    	mov    0xf0211230,%edi
f01006a9:	b8 0e 00 00 00       	mov    $0xe,%eax
f01006ae:	89 fa                	mov    %edi,%edx
f01006b0:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f01006b1:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006b4:	89 da                	mov    %ebx,%edx
f01006b6:	ec                   	in     (%dx),%al
f01006b7:	0f b6 c8             	movzbl %al,%ecx
f01006ba:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006bd:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006c2:	89 fa                	mov    %edi,%edx
f01006c4:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006c5:	89 da                	mov    %ebx,%edx
f01006c7:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006c8:	89 35 2c 12 21 f0    	mov    %esi,0xf021122c
	crt_pos = pos;
f01006ce:	0f b6 c0             	movzbl %al,%eax
f01006d1:	09 c8                	or     %ecx,%eax
f01006d3:	66 a3 28 12 21 f0    	mov    %ax,0xf0211228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006d9:	e8 1c ff ff ff       	call   f01005fa <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006de:	83 ec 0c             	sub    $0xc,%esp
f01006e1:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f01006e8:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006ed:	50                   	push   %eax
f01006ee:	e8 30 2d 00 00       	call   f0103423 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006f3:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01006fd:	89 f2                	mov    %esi,%edx
f01006ff:	ee                   	out    %al,(%dx)
f0100700:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100705:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f010070a:	ee                   	out    %al,(%dx)
f010070b:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f0100710:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100715:	89 da                	mov    %ebx,%edx
f0100717:	ee                   	out    %al,(%dx)
f0100718:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010071d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100722:	ee                   	out    %al,(%dx)
f0100723:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100728:	b8 03 00 00 00       	mov    $0x3,%eax
f010072d:	ee                   	out    %al,(%dx)
f010072e:	ba fc 03 00 00       	mov    $0x3fc,%edx
f0100733:	b8 00 00 00 00       	mov    $0x0,%eax
f0100738:	ee                   	out    %al,(%dx)
f0100739:	ba f9 03 00 00       	mov    $0x3f9,%edx
f010073e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100743:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100744:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100749:	ec                   	in     (%dx),%al
f010074a:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f010074c:	83 c4 10             	add    $0x10,%esp
f010074f:	3c ff                	cmp    $0xff,%al
f0100751:	0f 95 05 34 12 21 f0 	setne  0xf0211234
f0100758:	89 f2                	mov    %esi,%edx
f010075a:	ec                   	in     (%dx),%al
f010075b:	89 da                	mov    %ebx,%edx
f010075d:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010075e:	80 f9 ff             	cmp    $0xff,%cl
f0100761:	74 21                	je     f0100784 <cons_init+0x12e>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_SERIAL));
f0100763:	83 ec 0c             	sub    $0xc,%esp
f0100766:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f010076d:	25 ef ff 00 00       	and    $0xffef,%eax
f0100772:	50                   	push   %eax
f0100773:	e8 ab 2c 00 00       	call   f0103423 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100778:	83 c4 10             	add    $0x10,%esp
f010077b:	80 3d 34 12 21 f0 00 	cmpb   $0x0,0xf0211234
f0100782:	75 10                	jne    f0100794 <cons_init+0x13e>
		cprintf("Serial port does not exist!\n");
f0100784:	83 ec 0c             	sub    $0xc,%esp
f0100787:	68 cf 5e 10 f0       	push   $0xf0105ecf
f010078c:	e8 e3 2d 00 00       	call   f0103574 <cprintf>
f0100791:	83 c4 10             	add    $0x10,%esp
}
f0100794:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100797:	5b                   	pop    %ebx
f0100798:	5e                   	pop    %esi
f0100799:	5f                   	pop    %edi
f010079a:	5d                   	pop    %ebp
f010079b:	c3                   	ret    

f010079c <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f010079c:	55                   	push   %ebp
f010079d:	89 e5                	mov    %esp,%ebp
f010079f:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01007a2:	8b 45 08             	mov    0x8(%ebp),%eax
f01007a5:	e8 4b fc ff ff       	call   f01003f5 <cons_putc>
}
f01007aa:	c9                   	leave  
f01007ab:	c3                   	ret    

f01007ac <getchar>:

int
getchar(void)
{
f01007ac:	55                   	push   %ebp
f01007ad:	89 e5                	mov    %esp,%ebp
f01007af:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01007b2:	e8 55 fe ff ff       	call   f010060c <cons_getc>
f01007b7:	85 c0                	test   %eax,%eax
f01007b9:	74 f7                	je     f01007b2 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01007bb:	c9                   	leave  
f01007bc:	c3                   	ret    

f01007bd <iscons>:

int
iscons(int fdnum)
{
f01007bd:	55                   	push   %ebp
f01007be:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01007c0:	b8 01 00 00 00       	mov    $0x1,%eax
f01007c5:	5d                   	pop    %ebp
f01007c6:	c3                   	ret    

f01007c7 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01007c7:	55                   	push   %ebp
f01007c8:	89 e5                	mov    %esp,%ebp
f01007ca:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01007cd:	68 20 61 10 f0       	push   $0xf0106120
f01007d2:	68 3e 61 10 f0       	push   $0xf010613e
f01007d7:	68 43 61 10 f0       	push   $0xf0106143
f01007dc:	e8 93 2d 00 00       	call   f0103574 <cprintf>
f01007e1:	83 c4 0c             	add    $0xc,%esp
f01007e4:	68 ac 61 10 f0       	push   $0xf01061ac
f01007e9:	68 4c 61 10 f0       	push   $0xf010614c
f01007ee:	68 43 61 10 f0       	push   $0xf0106143
f01007f3:	e8 7c 2d 00 00       	call   f0103574 <cprintf>
	return 0;
}
f01007f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01007fd:	c9                   	leave  
f01007fe:	c3                   	ret    

f01007ff <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007ff:	55                   	push   %ebp
f0100800:	89 e5                	mov    %esp,%ebp
f0100802:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f0100805:	68 55 61 10 f0       	push   $0xf0106155
f010080a:	e8 65 2d 00 00       	call   f0103574 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f010080f:	83 c4 08             	add    $0x8,%esp
f0100812:	68 0c 00 10 00       	push   $0x10000c
f0100817:	68 d4 61 10 f0       	push   $0xf01061d4
f010081c:	e8 53 2d 00 00       	call   f0103574 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100821:	83 c4 0c             	add    $0xc,%esp
f0100824:	68 0c 00 10 00       	push   $0x10000c
f0100829:	68 0c 00 10 f0       	push   $0xf010000c
f010082e:	68 fc 61 10 f0       	push   $0xf01061fc
f0100833:	e8 3c 2d 00 00       	call   f0103574 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100838:	83 c4 0c             	add    $0xc,%esp
f010083b:	68 f1 5d 10 00       	push   $0x105df1
f0100840:	68 f1 5d 10 f0       	push   $0xf0105df1
f0100845:	68 20 62 10 f0       	push   $0xf0106220
f010084a:	e8 25 2d 00 00       	call   f0103574 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084f:	83 c4 0c             	add    $0xc,%esp
f0100852:	68 44 05 21 00       	push   $0x210544
f0100857:	68 44 05 21 f0       	push   $0xf0210544
f010085c:	68 44 62 10 f0       	push   $0xf0106244
f0100861:	e8 0e 2d 00 00       	call   f0103574 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100866:	83 c4 0c             	add    $0xc,%esp
f0100869:	68 08 30 25 00       	push   $0x253008
f010086e:	68 08 30 25 f0       	push   $0xf0253008
f0100873:	68 68 62 10 f0       	push   $0xf0106268
f0100878:	e8 f7 2c 00 00       	call   f0103574 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f010087d:	b8 07 34 25 f0       	mov    $0xf0253407,%eax
f0100882:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100887:	83 c4 08             	add    $0x8,%esp
f010088a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f010088f:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f0100895:	85 c0                	test   %eax,%eax
f0100897:	0f 48 c2             	cmovs  %edx,%eax
f010089a:	c1 f8 0a             	sar    $0xa,%eax
f010089d:	50                   	push   %eax
f010089e:	68 8c 62 10 f0       	push   $0xf010628c
f01008a3:	e8 cc 2c 00 00       	call   f0103574 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008a8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008ad:	c9                   	leave  
f01008ae:	c3                   	ret    

f01008af <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01008af:	55                   	push   %ebp
f01008b0:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f01008b2:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b7:	5d                   	pop    %ebp
f01008b8:	c3                   	ret    

f01008b9 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f01008b9:	55                   	push   %ebp
f01008ba:	89 e5                	mov    %esp,%ebp
f01008bc:	57                   	push   %edi
f01008bd:	56                   	push   %esi
f01008be:	53                   	push   %ebx
f01008bf:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f01008c2:	68 b8 62 10 f0       	push   $0xf01062b8
f01008c7:	e8 a8 2c 00 00       	call   f0103574 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01008cc:	c7 04 24 dc 62 10 f0 	movl   $0xf01062dc,(%esp)
f01008d3:	e8 9c 2c 00 00       	call   f0103574 <cprintf>

	if (tf != NULL)
f01008d8:	83 c4 10             	add    $0x10,%esp
f01008db:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008df:	74 0e                	je     f01008ef <monitor+0x36>
		print_trapframe(tf);
f01008e1:	83 ec 0c             	sub    $0xc,%esp
f01008e4:	ff 75 08             	pushl  0x8(%ebp)
f01008e7:	e8 4a 31 00 00       	call   f0103a36 <print_trapframe>
f01008ec:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008ef:	83 ec 0c             	sub    $0xc,%esp
f01008f2:	68 6e 61 10 f0       	push   $0xf010616e
f01008f7:	e8 ea 45 00 00       	call   f0104ee6 <readline>
f01008fc:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008fe:	83 c4 10             	add    $0x10,%esp
f0100901:	85 c0                	test   %eax,%eax
f0100903:	74 ea                	je     f01008ef <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100905:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010090c:	be 00 00 00 00       	mov    $0x0,%esi
f0100911:	eb 0a                	jmp    f010091d <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100913:	c6 03 00             	movb   $0x0,(%ebx)
f0100916:	89 f7                	mov    %esi,%edi
f0100918:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010091b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010091d:	0f b6 03             	movzbl (%ebx),%eax
f0100920:	84 c0                	test   %al,%al
f0100922:	74 63                	je     f0100987 <monitor+0xce>
f0100924:	83 ec 08             	sub    $0x8,%esp
f0100927:	0f be c0             	movsbl %al,%eax
f010092a:	50                   	push   %eax
f010092b:	68 72 61 10 f0       	push   $0xf0106172
f0100930:	e8 e3 47 00 00       	call   f0105118 <strchr>
f0100935:	83 c4 10             	add    $0x10,%esp
f0100938:	85 c0                	test   %eax,%eax
f010093a:	75 d7                	jne    f0100913 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f010093c:	80 3b 00             	cmpb   $0x0,(%ebx)
f010093f:	74 46                	je     f0100987 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100941:	83 fe 0f             	cmp    $0xf,%esi
f0100944:	75 14                	jne    f010095a <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100946:	83 ec 08             	sub    $0x8,%esp
f0100949:	6a 10                	push   $0x10
f010094b:	68 77 61 10 f0       	push   $0xf0106177
f0100950:	e8 1f 2c 00 00       	call   f0103574 <cprintf>
f0100955:	83 c4 10             	add    $0x10,%esp
f0100958:	eb 95                	jmp    f01008ef <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f010095a:	8d 7e 01             	lea    0x1(%esi),%edi
f010095d:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100961:	eb 03                	jmp    f0100966 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f0100963:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f0100966:	0f b6 03             	movzbl (%ebx),%eax
f0100969:	84 c0                	test   %al,%al
f010096b:	74 ae                	je     f010091b <monitor+0x62>
f010096d:	83 ec 08             	sub    $0x8,%esp
f0100970:	0f be c0             	movsbl %al,%eax
f0100973:	50                   	push   %eax
f0100974:	68 72 61 10 f0       	push   $0xf0106172
f0100979:	e8 9a 47 00 00       	call   f0105118 <strchr>
f010097e:	83 c4 10             	add    $0x10,%esp
f0100981:	85 c0                	test   %eax,%eax
f0100983:	74 de                	je     f0100963 <monitor+0xaa>
f0100985:	eb 94                	jmp    f010091b <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f0100987:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f010098e:	00 

	// Lookup and invoke the command
	if (argc == 0)
f010098f:	85 f6                	test   %esi,%esi
f0100991:	0f 84 58 ff ff ff    	je     f01008ef <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100997:	83 ec 08             	sub    $0x8,%esp
f010099a:	68 3e 61 10 f0       	push   $0xf010613e
f010099f:	ff 75 a8             	pushl  -0x58(%ebp)
f01009a2:	e8 13 47 00 00       	call   f01050ba <strcmp>
f01009a7:	83 c4 10             	add    $0x10,%esp
f01009aa:	85 c0                	test   %eax,%eax
f01009ac:	74 1e                	je     f01009cc <monitor+0x113>
f01009ae:	83 ec 08             	sub    $0x8,%esp
f01009b1:	68 4c 61 10 f0       	push   $0xf010614c
f01009b6:	ff 75 a8             	pushl  -0x58(%ebp)
f01009b9:	e8 fc 46 00 00       	call   f01050ba <strcmp>
f01009be:	83 c4 10             	add    $0x10,%esp
f01009c1:	85 c0                	test   %eax,%eax
f01009c3:	75 2f                	jne    f01009f4 <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f01009c5:	b8 01 00 00 00       	mov    $0x1,%eax
f01009ca:	eb 05                	jmp    f01009d1 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f01009cc:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f01009d1:	83 ec 04             	sub    $0x4,%esp
f01009d4:	8d 14 00             	lea    (%eax,%eax,1),%edx
f01009d7:	01 d0                	add    %edx,%eax
f01009d9:	ff 75 08             	pushl  0x8(%ebp)
f01009dc:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01009df:	51                   	push   %ecx
f01009e0:	56                   	push   %esi
f01009e1:	ff 14 85 0c 63 10 f0 	call   *-0xfef9cf4(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009e8:	83 c4 10             	add    $0x10,%esp
f01009eb:	85 c0                	test   %eax,%eax
f01009ed:	78 1d                	js     f0100a0c <monitor+0x153>
f01009ef:	e9 fb fe ff ff       	jmp    f01008ef <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009f4:	83 ec 08             	sub    $0x8,%esp
f01009f7:	ff 75 a8             	pushl  -0x58(%ebp)
f01009fa:	68 94 61 10 f0       	push   $0xf0106194
f01009ff:	e8 70 2b 00 00       	call   f0103574 <cprintf>
f0100a04:	83 c4 10             	add    $0x10,%esp
f0100a07:	e9 e3 fe ff ff       	jmp    f01008ef <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a0f:	5b                   	pop    %ebx
f0100a10:	5e                   	pop    %esi
f0100a11:	5f                   	pop    %edi
f0100a12:	5d                   	pop    %ebp
f0100a13:	c3                   	ret    

f0100a14 <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
//暂时用作页分配器，真实的物理页分配器是page_alloc函数
static void *
boot_alloc(uint32_t n)
{
f0100a14:	55                   	push   %ebp
f0100a15:	89 e5                	mov    %esp,%ebp
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	//nextfree为静态变量，初始时指向开始指向内核bss段的末尾
	/*根据mem_init()函数可知，kern_pgdir初始化时第一次调用boot_alloc(),
	  故kern_pgdir指向end*/
	if (!nextfree) {
f0100a17:	83 3d 38 12 21 f0 00 	cmpl   $0x0,0xf0211238
f0100a1e:	75 11                	jne    f0100a31 <boot_alloc+0x1d>
		extern char end[];
		//end 在哪里？？？
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a20:	ba 07 40 25 f0       	mov    $0xf0254007,%edx
f0100a25:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a2b:	89 15 38 12 21 f0    	mov    %edx,0xf0211238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//
	result = nextfree;
f0100a31:	8b 0d 38 12 21 f0    	mov    0xf0211238,%ecx
	//ROUNDUP()用作页对齐
	nextfree = ROUNDUP((char *)nextfree + n, PGSIZE);
f0100a37:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100a3e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a44:	89 15 38 12 21 f0    	mov    %edx,0xf0211238
	return result;
}
f0100a4a:	89 c8                	mov    %ecx,%eax
f0100a4c:	5d                   	pop    %ebp
f0100a4d:	c3                   	ret    

f0100a4e <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a4e:	55                   	push   %ebp
f0100a4f:	89 e5                	mov    %esp,%ebp
f0100a51:	56                   	push   %esi
f0100a52:	53                   	push   %ebx
f0100a53:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a55:	83 ec 0c             	sub    $0xc,%esp
f0100a58:	50                   	push   %eax
f0100a59:	e8 97 29 00 00       	call   f01033f5 <mc146818_read>
f0100a5e:	89 c6                	mov    %eax,%esi
f0100a60:	83 c3 01             	add    $0x1,%ebx
f0100a63:	89 1c 24             	mov    %ebx,(%esp)
f0100a66:	e8 8a 29 00 00       	call   f01033f5 <mc146818_read>
f0100a6b:	c1 e0 08             	shl    $0x8,%eax
f0100a6e:	09 f0                	or     %esi,%eax
}
f0100a70:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a73:	5b                   	pop    %ebx
f0100a74:	5e                   	pop    %esi
f0100a75:	5d                   	pop    %ebp
f0100a76:	c3                   	ret    

f0100a77 <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a77:	89 d1                	mov    %edx,%ecx
f0100a79:	c1 e9 16             	shr    $0x16,%ecx
f0100a7c:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a7f:	a8 01                	test   $0x1,%al
f0100a81:	74 52                	je     f0100ad5 <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a83:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a88:	89 c1                	mov    %eax,%ecx
f0100a8a:	c1 e9 0c             	shr    $0xc,%ecx
f0100a8d:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0100a93:	72 1b                	jb     f0100ab0 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a95:	55                   	push   %ebp
f0100a96:	89 e5                	mov    %esp,%ebp
f0100a98:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a9b:	50                   	push   %eax
f0100a9c:	68 24 5e 10 f0       	push   $0xf0105e24
f0100aa1:	68 ae 03 00 00       	push   $0x3ae
f0100aa6:	68 65 6c 10 f0       	push   $0xf0106c65
f0100aab:	e8 90 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100ab0:	c1 ea 0c             	shr    $0xc,%edx
f0100ab3:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100ab9:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100ac0:	89 c2                	mov    %eax,%edx
f0100ac2:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100ac5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100aca:	85 d2                	test   %edx,%edx
f0100acc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100ad1:	0f 44 c2             	cmove  %edx,%eax
f0100ad4:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100ad5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100ada:	c3                   	ret    

f0100adb <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100adb:	55                   	push   %ebp
f0100adc:	89 e5                	mov    %esp,%ebp
f0100ade:	57                   	push   %edi
f0100adf:	56                   	push   %esi
f0100ae0:	53                   	push   %ebx
f0100ae1:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100ae4:	84 c0                	test   %al,%al
f0100ae6:	0f 85 a0 02 00 00    	jne    f0100d8c <check_page_free_list+0x2b1>
f0100aec:	e9 ad 02 00 00       	jmp    f0100d9e <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100af1:	83 ec 04             	sub    $0x4,%esp
f0100af4:	68 1c 63 10 f0       	push   $0xf010631c
f0100af9:	68 e1 02 00 00       	push   $0x2e1
f0100afe:	68 65 6c 10 f0       	push   $0xf0106c65
f0100b03:	e8 38 f5 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b08:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b0b:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b0e:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b11:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b14:	89 c2                	mov    %eax,%edx
f0100b16:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0100b1c:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b22:	0f 95 c2             	setne  %dl
f0100b25:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b28:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b2c:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b2e:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b32:	8b 00                	mov    (%eax),%eax
f0100b34:	85 c0                	test   %eax,%eax
f0100b36:	75 dc                	jne    f0100b14 <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b3b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b41:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b44:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b47:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b49:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b4c:	a3 40 12 21 f0       	mov    %eax,0xf0211240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b51:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b56:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100b5c:	eb 53                	jmp    f0100bb1 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b5e:	89 d8                	mov    %ebx,%eax
f0100b60:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100b66:	c1 f8 03             	sar    $0x3,%eax
f0100b69:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b6c:	89 c2                	mov    %eax,%edx
f0100b6e:	c1 ea 16             	shr    $0x16,%edx
f0100b71:	39 f2                	cmp    %esi,%edx
f0100b73:	73 3a                	jae    f0100baf <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b75:	89 c2                	mov    %eax,%edx
f0100b77:	c1 ea 0c             	shr    $0xc,%edx
f0100b7a:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100b80:	72 12                	jb     f0100b94 <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b82:	50                   	push   %eax
f0100b83:	68 24 5e 10 f0       	push   $0xf0105e24
f0100b88:	6a 58                	push   $0x58
f0100b8a:	68 71 6c 10 f0       	push   $0xf0106c71
f0100b8f:	e8 ac f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b94:	83 ec 04             	sub    $0x4,%esp
f0100b97:	68 80 00 00 00       	push   $0x80
f0100b9c:	68 97 00 00 00       	push   $0x97
f0100ba1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ba6:	50                   	push   %eax
f0100ba7:	e8 a9 45 00 00       	call   f0105155 <memset>
f0100bac:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100baf:	8b 1b                	mov    (%ebx),%ebx
f0100bb1:	85 db                	test   %ebx,%ebx
f0100bb3:	75 a9                	jne    f0100b5e <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100bb5:	b8 00 00 00 00       	mov    $0x0,%eax
f0100bba:	e8 55 fe ff ff       	call   f0100a14 <boot_alloc>
f0100bbf:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bc2:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bc8:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
		assert(pp < pages + npages);
f0100bce:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f0100bd3:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100bd6:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100bd9:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bdc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100bdf:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100be4:	e9 52 01 00 00       	jmp    f0100d3b <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100be9:	39 ca                	cmp    %ecx,%edx
f0100beb:	73 19                	jae    f0100c06 <check_page_free_list+0x12b>
f0100bed:	68 7f 6c 10 f0       	push   $0xf0106c7f
f0100bf2:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100bf7:	68 fb 02 00 00       	push   $0x2fb
f0100bfc:	68 65 6c 10 f0       	push   $0xf0106c65
f0100c01:	e8 3a f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100c06:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100c09:	72 19                	jb     f0100c24 <check_page_free_list+0x149>
f0100c0b:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0100c10:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100c15:	68 fc 02 00 00       	push   $0x2fc
f0100c1a:	68 65 6c 10 f0       	push   $0xf0106c65
f0100c1f:	e8 1c f4 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c24:	89 d0                	mov    %edx,%eax
f0100c26:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100c29:	a8 07                	test   $0x7,%al
f0100c2b:	74 19                	je     f0100c46 <check_page_free_list+0x16b>
f0100c2d:	68 40 63 10 f0       	push   $0xf0106340
f0100c32:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100c37:	68 fd 02 00 00       	push   $0x2fd
f0100c3c:	68 65 6c 10 f0       	push   $0xf0106c65
f0100c41:	e8 fa f3 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c46:	c1 f8 03             	sar    $0x3,%eax
f0100c49:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c4c:	85 c0                	test   %eax,%eax
f0100c4e:	75 19                	jne    f0100c69 <check_page_free_list+0x18e>
f0100c50:	68 b4 6c 10 f0       	push   $0xf0106cb4
f0100c55:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100c5a:	68 00 03 00 00       	push   $0x300
f0100c5f:	68 65 6c 10 f0       	push   $0xf0106c65
f0100c64:	e8 d7 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c69:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c6e:	75 19                	jne    f0100c89 <check_page_free_list+0x1ae>
f0100c70:	68 c5 6c 10 f0       	push   $0xf0106cc5
f0100c75:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100c7a:	68 01 03 00 00       	push   $0x301
f0100c7f:	68 65 6c 10 f0       	push   $0xf0106c65
f0100c84:	e8 b7 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c89:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c8e:	75 19                	jne    f0100ca9 <check_page_free_list+0x1ce>
f0100c90:	68 74 63 10 f0       	push   $0xf0106374
f0100c95:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100c9a:	68 02 03 00 00       	push   $0x302
f0100c9f:	68 65 6c 10 f0       	push   $0xf0106c65
f0100ca4:	e8 97 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100ca9:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100cae:	75 19                	jne    f0100cc9 <check_page_free_list+0x1ee>
f0100cb0:	68 de 6c 10 f0       	push   $0xf0106cde
f0100cb5:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100cba:	68 03 03 00 00       	push   $0x303
f0100cbf:	68 65 6c 10 f0       	push   $0xf0106c65
f0100cc4:	e8 77 f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100cc9:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100cce:	0f 86 f1 00 00 00    	jbe    f0100dc5 <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100cd4:	89 c7                	mov    %eax,%edi
f0100cd6:	c1 ef 0c             	shr    $0xc,%edi
f0100cd9:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100cdc:	77 12                	ja     f0100cf0 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100cde:	50                   	push   %eax
f0100cdf:	68 24 5e 10 f0       	push   $0xf0105e24
f0100ce4:	6a 58                	push   $0x58
f0100ce6:	68 71 6c 10 f0       	push   $0xf0106c71
f0100ceb:	e8 50 f3 ff ff       	call   f0100040 <_panic>
f0100cf0:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100cf6:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100cf9:	0f 86 b6 00 00 00    	jbe    f0100db5 <check_page_free_list+0x2da>
f0100cff:	68 98 63 10 f0       	push   $0xf0106398
f0100d04:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100d09:	68 04 03 00 00       	push   $0x304
f0100d0e:	68 65 6c 10 f0       	push   $0xf0106c65
f0100d13:	e8 28 f3 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d18:	68 f8 6c 10 f0       	push   $0xf0106cf8
f0100d1d:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100d22:	68 06 03 00 00       	push   $0x306
f0100d27:	68 65 6c 10 f0       	push   $0xf0106c65
f0100d2c:	e8 0f f3 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d31:	83 c6 01             	add    $0x1,%esi
f0100d34:	eb 03                	jmp    f0100d39 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100d36:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d39:	8b 12                	mov    (%edx),%edx
f0100d3b:	85 d2                	test   %edx,%edx
f0100d3d:	0f 85 a6 fe ff ff    	jne    f0100be9 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d43:	85 f6                	test   %esi,%esi
f0100d45:	7f 19                	jg     f0100d60 <check_page_free_list+0x285>
f0100d47:	68 15 6d 10 f0       	push   $0xf0106d15
f0100d4c:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100d51:	68 0e 03 00 00       	push   $0x30e
f0100d56:	68 65 6c 10 f0       	push   $0xf0106c65
f0100d5b:	e8 e0 f2 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100d60:	85 db                	test   %ebx,%ebx
f0100d62:	7f 19                	jg     f0100d7d <check_page_free_list+0x2a2>
f0100d64:	68 27 6d 10 f0       	push   $0xf0106d27
f0100d69:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100d6e:	68 0f 03 00 00       	push   $0x30f
f0100d73:	68 65 6c 10 f0       	push   $0xf0106c65
f0100d78:	e8 c3 f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d7d:	83 ec 0c             	sub    $0xc,%esp
f0100d80:	68 e0 63 10 f0       	push   $0xf01063e0
f0100d85:	e8 ea 27 00 00       	call   f0103574 <cprintf>
}
f0100d8a:	eb 49                	jmp    f0100dd5 <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d8c:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0100d91:	85 c0                	test   %eax,%eax
f0100d93:	0f 85 6f fd ff ff    	jne    f0100b08 <check_page_free_list+0x2d>
f0100d99:	e9 53 fd ff ff       	jmp    f0100af1 <check_page_free_list+0x16>
f0100d9e:	83 3d 40 12 21 f0 00 	cmpl   $0x0,0xf0211240
f0100da5:	0f 84 46 fd ff ff    	je     f0100af1 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dab:	be 00 04 00 00       	mov    $0x400,%esi
f0100db0:	e9 a1 fd ff ff       	jmp    f0100b56 <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100db5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dba:	0f 85 76 ff ff ff    	jne    f0100d36 <check_page_free_list+0x25b>
f0100dc0:	e9 53 ff ff ff       	jmp    f0100d18 <check_page_free_list+0x23d>
f0100dc5:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100dca:	0f 85 61 ff ff ff    	jne    f0100d31 <check_page_free_list+0x256>
f0100dd0:	e9 43 ff ff ff       	jmp    f0100d18 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100dd8:	5b                   	pop    %ebx
f0100dd9:	5e                   	pop    %esi
f0100dda:	5f                   	pop    %edi
f0100ddb:	5d                   	pop    %ebp
f0100ddc:	c3                   	ret    

f0100ddd <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100ddd:	55                   	push   %ebp
f0100dde:	89 e5                	mov    %esp,%ebp
f0100de0:	57                   	push   %edi
f0100de1:	56                   	push   %esi
f0100de2:	53                   	push   %ebx
f0100de3:	83 ec 0c             	sub    $0xc,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
f0100de6:	b8 00 00 00 00       	mov    $0x0,%eax
f0100deb:	e8 24 fc ff ff       	call   f0100a14 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100df0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100df5:	77 15                	ja     f0100e0c <page_init+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100df7:	50                   	push   %eax
f0100df8:	68 48 5e 10 f0       	push   $0xf0105e48
f0100dfd:	68 59 01 00 00       	push   $0x159
f0100e02:	68 65 6c 10 f0       	push   $0xf0106c65
f0100e07:	e8 34 f2 ff ff       	call   f0100040 <_panic>
f0100e0c:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e11:	c1 e8 0c             	shr    $0xc,%eax
	for (i = 1; i < npages; i++) {
		if (i >= npages_basemem && i < pgnum)
f0100e14:	8b 3d 44 12 21 f0    	mov    0xf0211244,%edi
f0100e1a:	8b 35 40 12 21 f0    	mov    0xf0211240,%esi
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100e20:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100e25:	ba 01 00 00 00       	mov    $0x1,%edx
f0100e2a:	eb 34                	jmp    f0100e60 <page_init+0x83>
		if (i >= npages_basemem && i < pgnum)
f0100e2c:	39 c2                	cmp    %eax,%edx
f0100e2e:	73 04                	jae    f0100e34 <page_init+0x57>
f0100e30:	39 fa                	cmp    %edi,%edx
f0100e32:	73 29                	jae    f0100e5d <page_init+0x80>
			continue;
		else if (i == PGNUM(MPENTRY_PADDR)){
f0100e34:	83 fa 07             	cmp    $0x7,%edx
f0100e37:	74 24                	je     f0100e5d <page_init+0x80>
			continue;
		}
		pages[i].pp_ref = 0;
f0100e39:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100e40:	89 cb                	mov    %ecx,%ebx
f0100e42:	03 1d 90 1e 21 f0    	add    0xf0211e90,%ebx
f0100e48:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f0100e4e:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f0100e50:	89 ce                	mov    %ecx,%esi
f0100e52:	03 35 90 1e 21 f0    	add    0xf0211e90,%esi
f0100e58:	b9 01 00 00 00       	mov    $0x1,%ecx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100e5d:	83 c2 01             	add    $0x1,%edx
f0100e60:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100e66:	72 c4                	jb     f0100e2c <page_init+0x4f>
f0100e68:	84 c9                	test   %cl,%cl
f0100e6a:	74 06                	je     f0100e72 <page_init+0x95>
f0100e6c:	89 35 40 12 21 f0    	mov    %esi,0xf0211240
		}
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100e72:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e75:	5b                   	pop    %ebx
f0100e76:	5e                   	pop    %esi
f0100e77:	5f                   	pop    %edi
f0100e78:	5d                   	pop    %ebp
f0100e79:	c3                   	ret    

f0100e7a <page_alloc>:
//
// Hint: use page2kva and memset
//分配一个物理页面
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e7a:	55                   	push   %ebp
f0100e7b:	89 e5                	mov    %esp,%ebp
f0100e7d:	53                   	push   %ebx
f0100e7e:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo *result = NULL;
	//如果存在空闲ye
	if (page_free_list) {
f0100e81:	8b 1d 40 12 21 f0    	mov    0xf0211240,%ebx
f0100e87:	85 db                	test   %ebx,%ebx
f0100e89:	74 58                	je     f0100ee3 <page_alloc+0x69>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100e8b:	8b 03                	mov    (%ebx),%eax
f0100e8d:	a3 40 12 21 f0       	mov    %eax,0xf0211240
		result->pp_link = NULL;
f0100e92:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		//??????
		if (alloc_flags & ALLOC_ZERO)
f0100e98:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e9c:	74 45                	je     f0100ee3 <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e9e:	89 d8                	mov    %ebx,%eax
f0100ea0:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100ea6:	c1 f8 03             	sar    $0x3,%eax
f0100ea9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100eac:	89 c2                	mov    %eax,%edx
f0100eae:	c1 ea 0c             	shr    $0xc,%edx
f0100eb1:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100eb7:	72 12                	jb     f0100ecb <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100eb9:	50                   	push   %eax
f0100eba:	68 24 5e 10 f0       	push   $0xf0105e24
f0100ebf:	6a 58                	push   $0x58
f0100ec1:	68 71 6c 10 f0       	push   $0xf0106c71
f0100ec6:	e8 75 f1 ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f0100ecb:	83 ec 04             	sub    $0x4,%esp
f0100ece:	68 00 10 00 00       	push   $0x1000
f0100ed3:	6a 00                	push   $0x0
f0100ed5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100eda:	50                   	push   %eax
f0100edb:	e8 75 42 00 00       	call   f0105155 <memset>
f0100ee0:	83 c4 10             	add    $0x10,%esp
	}
	return result;
}
f0100ee3:	89 d8                	mov    %ebx,%eax
f0100ee5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100ee8:	c9                   	leave  
f0100ee9:	c3                   	ret    

f0100eea <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100eea:	55                   	push   %ebp
f0100eeb:	89 e5                	mov    %esp,%ebp
f0100eed:	83 ec 08             	sub    $0x8,%esp
f0100ef0:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	//容错判断
	assert(pp != NULL);
f0100ef3:	85 c0                	test   %eax,%eax
f0100ef5:	75 19                	jne    f0100f10 <page_free+0x26>
f0100ef7:	68 38 6d 10 f0       	push   $0xf0106d38
f0100efc:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100f01:	68 8f 01 00 00       	push   $0x18f
f0100f06:	68 65 6c 10 f0       	push   $0xf0106c65
f0100f0b:	e8 30 f1 ff ff       	call   f0100040 <_panic>
	assert(pp->pp_ref == 0);
f0100f10:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f15:	74 19                	je     f0100f30 <page_free+0x46>
f0100f17:	68 43 6d 10 f0       	push   $0xf0106d43
f0100f1c:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100f21:	68 90 01 00 00       	push   $0x190
f0100f26:	68 65 6c 10 f0       	push   $0xf0106c65
f0100f2b:	e8 10 f1 ff ff       	call   f0100040 <_panic>
	assert(pp->pp_link == NULL);
f0100f30:	83 38 00             	cmpl   $0x0,(%eax)
f0100f33:	74 19                	je     f0100f4e <page_free+0x64>
f0100f35:	68 53 6d 10 f0       	push   $0xf0106d53
f0100f3a:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0100f3f:	68 91 01 00 00       	push   $0x191
f0100f44:	68 65 6c 10 f0       	push   $0xf0106c65
f0100f49:	e8 f2 f0 ff ff       	call   f0100040 <_panic>
	
	//释放物理页面
      	pp->pp_link = page_free_list;
f0100f4e:	8b 15 40 12 21 f0    	mov    0xf0211240,%edx
f0100f54:	89 10                	mov    %edx,(%eax)
      	page_free_list = pp;
f0100f56:	a3 40 12 21 f0       	mov    %eax,0xf0211240
}
f0100f5b:	c9                   	leave  
f0100f5c:	c3                   	ret    

f0100f5d <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f5d:	55                   	push   %ebp
f0100f5e:	89 e5                	mov    %esp,%ebp
f0100f60:	83 ec 08             	sub    $0x8,%esp
f0100f63:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f66:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f6a:	83 e8 01             	sub    $0x1,%eax
f0100f6d:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f71:	66 85 c0             	test   %ax,%ax
f0100f74:	75 0c                	jne    f0100f82 <page_decref+0x25>
		page_free(pp);
f0100f76:	83 ec 0c             	sub    $0xc,%esp
f0100f79:	52                   	push   %edx
f0100f7a:	e8 6b ff ff ff       	call   f0100eea <page_free>
f0100f7f:	83 c4 10             	add    $0x10,%esp
}
f0100f82:	c9                   	leave  
f0100f83:	c3                   	ret    

f0100f84 <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//返回虚拟地址所对应的页表项指针page table entry (PTE)
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f84:	55                   	push   %ebp
f0100f85:	89 e5                	mov    %esp,%ebp
f0100f87:	56                   	push   %esi
f0100f88:	53                   	push   %ebx
f0100f89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	//return NULL;
	//根据虚拟地址解析出页目录索引和页表索引，pdx--页目录索引 ptx -- 页表索引
	size_t pdx = PDX(va), ptx = PTX(va);
f0100f8c:	89 de                	mov    %ebx,%esi
f0100f8e:	c1 ee 0c             	shr    $0xc,%esi
f0100f91:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
f0100f97:	c1 eb 16             	shr    $0x16,%ebx
f0100f9a:	c1 e3 02             	shl    $0x2,%ebx
f0100f9d:	03 5d 08             	add    0x8(%ebp),%ebx
f0100fa0:	f6 03 01             	testb  $0x1,(%ebx)
f0100fa3:	75 2d                	jne    f0100fd2 <pgdir_walk+0x4e>
		if (!create) 
f0100fa5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100fa9:	74 59                	je     f0101004 <pgdir_walk+0x80>
			return NULL;
		pp = page_alloc(ALLOC_ZERO);
f0100fab:	83 ec 0c             	sub    $0xc,%esp
f0100fae:	6a 01                	push   $0x1
f0100fb0:	e8 c5 fe ff ff       	call   f0100e7a <page_alloc>
		if (pp == NULL) 
f0100fb5:	83 c4 10             	add    $0x10,%esp
f0100fb8:	85 c0                	test   %eax,%eax
f0100fba:	74 4f                	je     f010100b <pgdir_walk+0x87>
			return NULL;
		pp->pp_ref++;
f0100fbc:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		pgdir[pdx] = page2pa(pp) | PTE_W | PTE_U | PTE_P; 
f0100fc1:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0100fc7:	c1 f8 03             	sar    $0x3,%eax
f0100fca:	c1 e0 0c             	shl    $0xc,%eax
f0100fcd:	83 c8 07             	or     $0x7,%eax
f0100fd0:	89 03                	mov    %eax,(%ebx)
	} 
	
	//这里为什么要用 PTE_ADDR？？？
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
f0100fd2:	8b 03                	mov    (%ebx),%eax
f0100fd4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fd9:	89 c2                	mov    %eax,%edx
f0100fdb:	c1 ea 0c             	shr    $0xc,%edx
f0100fde:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0100fe4:	72 15                	jb     f0100ffb <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fe6:	50                   	push   %eax
f0100fe7:	68 24 5e 10 f0       	push   $0xf0105e24
f0100fec:	68 ce 01 00 00       	push   $0x1ce
f0100ff1:	68 65 6c 10 f0       	push   $0xf0106c65
f0100ff6:	e8 45 f0 ff ff       	call   f0100040 <_panic>
	return &pgtbl[ptx];
f0100ffb:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0101002:	eb 0c                	jmp    f0101010 <pgdir_walk+0x8c>
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
		if (!create) 
			return NULL;
f0101004:	b8 00 00 00 00       	mov    $0x0,%eax
f0101009:	eb 05                	jmp    f0101010 <pgdir_walk+0x8c>
		pp = page_alloc(ALLOC_ZERO);
		if (pp == NULL) 
			return NULL;
f010100b:	b8 00 00 00 00       	mov    $0x0,%eax
	} 
	
	//这里为什么要用 PTE_ADDR？？？
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
	return &pgtbl[ptx];
}
f0101010:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0101013:	5b                   	pop    %ebx
f0101014:	5e                   	pop    %esi
f0101015:	5d                   	pop    %ebp
f0101016:	c3                   	ret    

f0101017 <boot_map_region>:
// Hint: the TA solution uses pgdir_walk
//把虚拟地址空间范围[va, va+size)映射到物理空间[pa, pa+size)的映射关系加入到页表中
//这个函数主要的目的是为了设置虚拟地址UTOP之上的地址范围
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101017:	55                   	push   %ebp
f0101018:	89 e5                	mov    %esp,%ebp
f010101a:	57                   	push   %edi
f010101b:	56                   	push   %esi
f010101c:	53                   	push   %ebx
f010101d:	83 ec 1c             	sub    $0x1c,%esp
f0101020:	89 c7                	mov    %eax,%edi
f0101022:	89 d6                	mov    %edx,%esi
f0101024:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f0101027:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
f010102c:	8b 45 0c             	mov    0xc(%ebp),%eax
f010102f:	83 c8 01             	or     $0x1,%eax
f0101032:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f0101035:	eb 22                	jmp    f0101059 <boot_map_region+0x42>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f0101037:	83 ec 04             	sub    $0x4,%esp
f010103a:	6a 01                	push   $0x1
f010103c:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f010103f:	50                   	push   %eax
f0101040:	57                   	push   %edi
f0101041:	e8 3e ff ff ff       	call   f0100f84 <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f0101046:	89 da                	mov    %ebx,%edx
f0101048:	03 55 08             	add    0x8(%ebp),%edx
f010104b:	0b 55 e0             	or     -0x20(%ebp),%edx
f010104e:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f0101050:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101056:	83 c4 10             	add    $0x10,%esp
f0101059:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f010105c:	72 d9                	jb     f0101037 <boot_map_region+0x20>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
	}
}
f010105e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101061:	5b                   	pop    %ebx
f0101062:	5e                   	pop    %esi
f0101063:	5f                   	pop    %edi
f0101064:	5d                   	pop    %ebp
f0101065:	c3                   	ret    

f0101066 <page_lookup>:
// Hint: the TA solution uses pgdir_walk and pa2page.
//返回虚拟地址所映射（对应）的物理页的PageInfo结构体的指针
//返回虚拟地址所对应的物理页指针
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101066:	55                   	push   %ebp
f0101067:	89 e5                	mov    %esp,%ebp
f0101069:	53                   	push   %ebx
f010106a:	83 ec 08             	sub    $0x8,%esp
f010106d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101070:	6a 01                	push   $0x1
f0101072:	ff 75 0c             	pushl  0xc(%ebp)
f0101075:	ff 75 08             	pushl  0x8(%ebp)
f0101078:	e8 07 ff ff ff       	call   f0100f84 <pgdir_walk>
	//pte_store存页表项指针的地址，*pte_store表示页表项指针，即页表项地址，**pte_store表示页表项
	//pte_store????
	if (pte_store)
f010107d:	83 c4 10             	add    $0x10,%esp
f0101080:	85 db                	test   %ebx,%ebx
f0101082:	74 02                	je     f0101086 <page_lookup+0x20>
		*pte_store = pte;
f0101084:	89 03                	mov    %eax,(%ebx)
	if (pte == NULL || !(*pte & PTE_P)) 
f0101086:	85 c0                	test   %eax,%eax
f0101088:	74 30                	je     f01010ba <page_lookup+0x54>
f010108a:	8b 00                	mov    (%eax),%eax
f010108c:	a8 01                	test   $0x1,%al
f010108e:	74 31                	je     f01010c1 <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101090:	c1 e8 0c             	shr    $0xc,%eax
f0101093:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0101099:	72 14                	jb     f01010af <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f010109b:	83 ec 04             	sub    $0x4,%esp
f010109e:	68 04 64 10 f0       	push   $0xf0106404
f01010a3:	6a 51                	push   $0x51
f01010a5:	68 71 6c 10 f0       	push   $0xf0106c71
f01010aa:	e8 91 ef ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f01010af:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f01010b5:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		return NULL;
	return pa2page(PTE_ADDR(*pte));
f01010b8:	eb 0c                	jmp    f01010c6 <page_lookup+0x60>
	//pte_store存页表项指针的地址，*pte_store表示页表项指针，即页表项地址，**pte_store表示页表项
	//pte_store????
	if (pte_store)
		*pte_store = pte;
	if (pte == NULL || !(*pte & PTE_P)) 
		return NULL;
f01010ba:	b8 00 00 00 00       	mov    $0x0,%eax
f01010bf:	eb 05                	jmp    f01010c6 <page_lookup+0x60>
f01010c1:	b8 00 00 00 00       	mov    $0x0,%eax
	return pa2page(PTE_ADDR(*pte));
}
f01010c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010c9:	c9                   	leave  
f01010ca:	c3                   	ret    

f01010cb <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01010cb:	55                   	push   %ebp
f01010cc:	89 e5                	mov    %esp,%ebp
f01010ce:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01010d1:	e8 a0 46 00 00       	call   f0105776 <cpunum>
f01010d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01010d9:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01010e0:	74 16                	je     f01010f8 <tlb_invalidate+0x2d>
f01010e2:	e8 8f 46 00 00       	call   f0105776 <cpunum>
f01010e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01010ea:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01010f0:	8b 55 08             	mov    0x8(%ebp),%edx
f01010f3:	39 50 60             	cmp    %edx,0x60(%eax)
f01010f6:	75 06                	jne    f01010fe <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010f8:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010fb:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01010fe:	c9                   	leave  
f01010ff:	c3                   	ret    

f0101100 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f0101100:	55                   	push   %ebp
f0101101:	89 e5                	mov    %esp,%ebp
f0101103:	57                   	push   %edi
f0101104:	56                   	push   %esi
f0101105:	53                   	push   %ebx
f0101106:	83 ec 20             	sub    $0x20,%esp
f0101109:	8b 75 08             	mov    0x8(%ebp),%esi
f010110c:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t *pte = NULL;
f010110f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f0101116:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101119:	50                   	push   %eax
f010111a:	57                   	push   %edi
f010111b:	56                   	push   %esi
f010111c:	e8 45 ff ff ff       	call   f0101066 <page_lookup>
	if(pp == NULL)
f0101121:	83 c4 10             	add    $0x10,%esp
f0101124:	85 c0                	test   %eax,%eax
f0101126:	74 20                	je     f0101148 <page_remove+0x48>
f0101128:	89 c3                	mov    %eax,%ebx
		return;
	*pte = (pte_t) 0; //将页表项内容置为空
f010112a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010112d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va); //tlb置为无效
f0101133:	83 ec 08             	sub    $0x8,%esp
f0101136:	57                   	push   %edi
f0101137:	56                   	push   %esi
f0101138:	e8 8e ff ff ff       	call   f01010cb <tlb_invalidate>
	page_decref(pp); //减少引用
f010113d:	89 1c 24             	mov    %ebx,(%esp)
f0101140:	e8 18 fe ff ff       	call   f0100f5d <page_decref>
f0101145:	83 c4 10             	add    $0x10,%esp
}
f0101148:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010114b:	5b                   	pop    %ebx
f010114c:	5e                   	pop    %esi
f010114d:	5f                   	pop    %edi
f010114e:	5d                   	pop    %ebp
f010114f:	c3                   	ret    

f0101150 <page_insert>:
// and page2pa.
//把一个物理内存中页pp与虚拟地址va建立映射关系。
//其实就是 更新页表
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101150:	55                   	push   %ebp
f0101151:	89 e5                	mov    %esp,%ebp
f0101153:	57                   	push   %edi
f0101154:	56                   	push   %esi
f0101155:	53                   	push   %ebx
f0101156:	83 ec 10             	sub    $0x10,%esp
f0101159:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010115c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	//return 0;
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f010115f:	6a 01                	push   $0x1
f0101161:	57                   	push   %edi
f0101162:	ff 75 08             	pushl  0x8(%ebp)
f0101165:	e8 1a fe ff ff       	call   f0100f84 <pgdir_walk>
    if (pte == NULL)  
f010116a:	83 c4 10             	add    $0x10,%esp
f010116d:	85 c0                	test   %eax,%eax
f010116f:	74 38                	je     f01011a9 <page_insert+0x59>
f0101171:	89 c6                	mov    %eax,%esi
    	return -E_NO_MEM;

    pp->pp_ref++;
f0101173:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    //??????
    if (*pte & PTE_P)
f0101178:	f6 00 01             	testb  $0x1,(%eax)
f010117b:	74 0f                	je     f010118c <page_insert+0x3c>
            page_remove(pgdir, va);
f010117d:	83 ec 08             	sub    $0x8,%esp
f0101180:	57                   	push   %edi
f0101181:	ff 75 08             	pushl  0x8(%ebp)
f0101184:	e8 77 ff ff ff       	call   f0101100 <page_remove>
f0101189:	83 c4 10             	add    $0x10,%esp

    *pte = page2pa(pp) | perm | PTE_P;
f010118c:	2b 1d 90 1e 21 f0    	sub    0xf0211e90,%ebx
f0101192:	c1 fb 03             	sar    $0x3,%ebx
f0101195:	c1 e3 0c             	shl    $0xc,%ebx
f0101198:	8b 45 14             	mov    0x14(%ebp),%eax
f010119b:	83 c8 01             	or     $0x1,%eax
f010119e:	09 c3                	or     %eax,%ebx
f01011a0:	89 1e                	mov    %ebx,(%esi)

    return 0;
f01011a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01011a7:	eb 05                	jmp    f01011ae <page_insert+0x5e>
{
	// Fill this function in
	//return 0;
	pte_t *pte = pgdir_walk(pgdir, va, 1);
    if (pte == NULL)  
    	return -E_NO_MEM;
f01011a9:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
            page_remove(pgdir, va);

    *pte = page2pa(pp) | perm | PTE_P;

    return 0;
}
f01011ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01011b1:	5b                   	pop    %ebx
f01011b2:	5e                   	pop    %esi
f01011b3:	5f                   	pop    %edi
f01011b4:	5d                   	pop    %ebp
f01011b5:	c3                   	ret    

f01011b6 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
// I/O内存映射
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f01011b6:	55                   	push   %ebp
f01011b7:	89 e5                	mov    %esp,%ebp
f01011b9:	53                   	push   %ebx
f01011ba:	83 ec 04             	sub    $0x4,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	uintptr_t va_start = base, va_end;
f01011bd:	8b 1d 00 f3 11 f0    	mov    0xf011f300,%ebx
	
	// 向上页对齐
	size = ROUNDUP(size, PGSIZE);
f01011c3:	8b 45 0c             	mov    0xc(%ebp),%eax
f01011c6:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
f01011cc:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	va_end = base + size;
f01011d2:	8d 04 0b             	lea    (%ebx,%ecx,1),%eax
	
	// 如果要分配的空间低于MMIOBASE或者超过MMIOLIM,这发出错误
	if (!(va_end >= MMIOBASE && va_end <= MMIOLIM))
f01011d5:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f01011db:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
f01011e1:	76 17                	jbe    f01011fa <mmio_map_region+0x44>
		panic("mmio_map_region: MMIO space overflow");
f01011e3:	83 ec 04             	sub    $0x4,%esp
f01011e6:	68 24 64 10 f0       	push   $0xf0106424
f01011eb:	68 82 02 00 00       	push   $0x282
f01011f0:	68 65 6c 10 f0       	push   $0xf0106c65
f01011f5:	e8 46 ee ff ff       	call   f0100040 <_panic>

	// 让base指向虚拟空间中MMIO空洞的空闲位置
	base = va_end;
f01011fa:	a3 00 f3 11 f0       	mov    %eax,0xf011f300
	
	// 将设备的虚拟地址映射其真实的物理地址(cache访问不安全)
	boot_map_region(kern_pgdir, va_start, size, pa, PTE_W | PTE_PCD | PTE_PWT);
f01011ff:	83 ec 08             	sub    $0x8,%esp
f0101202:	6a 1a                	push   $0x1a
f0101204:	ff 75 08             	pushl  0x8(%ebp)
f0101207:	89 da                	mov    %ebx,%edx
f0101209:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010120e:	e8 04 fe ff ff       	call   f0101017 <boot_map_region>
	
	// 返回设备在虚拟空间的地址
	return (void *) va_start;

	//panic("mmio_map_region not implemented");
}
f0101213:	89 d8                	mov    %ebx,%eax
f0101215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101218:	c9                   	leave  
f0101219:	c3                   	ret    

f010121a <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f010121a:	55                   	push   %ebp
f010121b:	89 e5                	mov    %esp,%ebp
f010121d:	57                   	push   %edi
f010121e:	56                   	push   %esi
f010121f:	53                   	push   %ebx
f0101220:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f0101223:	b8 15 00 00 00       	mov    $0x15,%eax
f0101228:	e8 21 f8 ff ff       	call   f0100a4e <nvram_read>
f010122d:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f010122f:	b8 17 00 00 00       	mov    $0x17,%eax
f0101234:	e8 15 f8 ff ff       	call   f0100a4e <nvram_read>
f0101239:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f010123b:	b8 34 00 00 00       	mov    $0x34,%eax
f0101240:	e8 09 f8 ff ff       	call   f0100a4e <nvram_read>
f0101245:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101248:	85 c0                	test   %eax,%eax
f010124a:	74 07                	je     f0101253 <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f010124c:	05 00 40 00 00       	add    $0x4000,%eax
f0101251:	eb 0b                	jmp    f010125e <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f0101253:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101259:	85 f6                	test   %esi,%esi
f010125b:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f010125e:	89 c2                	mov    %eax,%edx
f0101260:	c1 ea 02             	shr    $0x2,%edx
f0101263:	89 15 88 1e 21 f0    	mov    %edx,0xf0211e88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101269:	89 da                	mov    %ebx,%edx
f010126b:	c1 ea 02             	shr    $0x2,%edx
f010126e:	89 15 44 12 21 f0    	mov    %edx,0xf0211244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101274:	89 c2                	mov    %eax,%edx
f0101276:	29 da                	sub    %ebx,%edx
f0101278:	52                   	push   %edx
f0101279:	53                   	push   %ebx
f010127a:	50                   	push   %eax
f010127b:	68 4c 64 10 f0       	push   $0xf010644c
f0101280:	e8 ef 22 00 00       	call   f0103574 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	//kern_pgdir -- 操作系统的页目录表指针，页目录表的大小为一个页的大小
	//第一个调用boot_alloc(),故kern_pgdir位于内核bss段的末尾，紧跟这操作系统内核
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101285:	b8 00 10 00 00       	mov    $0x1000,%eax
f010128a:	e8 85 f7 ff ff       	call   f0100a14 <boot_alloc>
f010128f:	a3 8c 1e 21 f0       	mov    %eax,0xf0211e8c
	//内存清零
	memset(kern_pgdir, 0, PGSIZE);
f0101294:	83 c4 0c             	add    $0xc,%esp
f0101297:	68 00 10 00 00       	push   $0x1000
f010129c:	6a 00                	push   $0x0
f010129e:	50                   	push   %eax
f010129f:	e8 b1 3e 00 00       	call   f0105155 <memset>
	// Permissions: kernel R, user R
	// 为页目录表添加第一个页目录表项
	/* UVPT的定义是一段虚拟地址的起始地址，0xef400000，
	   从这个虚拟地址开始，存放的就是这个操作系统的页目录表*/
	// 映射？？？自身映射
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01012a4:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01012a9:	83 c4 10             	add    $0x10,%esp
f01012ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01012b1:	77 15                	ja     f01012c8 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01012b3:	50                   	push   %eax
f01012b4:	68 48 5e 10 f0       	push   $0xf0105e48
f01012b9:	68 a1 00 00 00       	push   $0xa1
f01012be:	68 65 6c 10 f0       	push   $0xf0106c65
f01012c3:	e8 78 ed ff ff       	call   f0100040 <_panic>
f01012c8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f01012ce:	83 ca 05             	or     $0x5,%edx
f01012d1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	// 分配一块内存用来存放pages，pages数组里的每一项代表一个物理页面
	n = npages * sizeof(struct PageInfo);
f01012d7:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f01012dc:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f01012e3:	89 d8                	mov    %ebx,%eax
f01012e5:	e8 2a f7 ff ff       	call   f0100a14 <boot_alloc>
f01012ea:	a3 90 1e 21 f0       	mov    %eax,0xf0211e90
	//内存清零
	memset(pages, 0, n);
f01012ef:	83 ec 04             	sub    $0x4,%esp
f01012f2:	53                   	push   %ebx
f01012f3:	6a 00                	push   $0x0
f01012f5:	50                   	push   %eax
f01012f6:	e8 5a 3e 00 00       	call   f0105155 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	// 分配空间存储envs，envs数组里的每一项代表一个用户空间(进程空间)
	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f01012fb:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101300:	e8 0f f7 ff ff       	call   f0100a14 <boot_alloc>
f0101305:	a3 48 12 21 f0       	mov    %eax,0xf0211248
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	// 初始化物理页和空闲链表
	page_init();
f010130a:	e8 ce fa ff ff       	call   f0100ddd <page_init>
	
	//检查空闲链表是否合法
	check_page_free_list(1);
f010130f:	b8 01 00 00 00       	mov    $0x1,%eax
f0101314:	e8 c2 f7 ff ff       	call   f0100adb <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101319:	83 c4 10             	add    $0x10,%esp
f010131c:	83 3d 90 1e 21 f0 00 	cmpl   $0x0,0xf0211e90
f0101323:	75 17                	jne    f010133c <mem_init+0x122>
		panic("'pages' is a null pointer!");
f0101325:	83 ec 04             	sub    $0x4,%esp
f0101328:	68 67 6d 10 f0       	push   $0xf0106d67
f010132d:	68 22 03 00 00       	push   $0x322
f0101332:	68 65 6c 10 f0       	push   $0xf0106c65
f0101337:	e8 04 ed ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010133c:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101341:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101346:	eb 05                	jmp    f010134d <mem_init+0x133>
		++nfree;
f0101348:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f010134b:	8b 00                	mov    (%eax),%eax
f010134d:	85 c0                	test   %eax,%eax
f010134f:	75 f7                	jne    f0101348 <mem_init+0x12e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101351:	83 ec 0c             	sub    $0xc,%esp
f0101354:	6a 00                	push   $0x0
f0101356:	e8 1f fb ff ff       	call   f0100e7a <page_alloc>
f010135b:	89 c7                	mov    %eax,%edi
f010135d:	83 c4 10             	add    $0x10,%esp
f0101360:	85 c0                	test   %eax,%eax
f0101362:	75 19                	jne    f010137d <mem_init+0x163>
f0101364:	68 82 6d 10 f0       	push   $0xf0106d82
f0101369:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010136e:	68 2a 03 00 00       	push   $0x32a
f0101373:	68 65 6c 10 f0       	push   $0xf0106c65
f0101378:	e8 c3 ec ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010137d:	83 ec 0c             	sub    $0xc,%esp
f0101380:	6a 00                	push   $0x0
f0101382:	e8 f3 fa ff ff       	call   f0100e7a <page_alloc>
f0101387:	89 c6                	mov    %eax,%esi
f0101389:	83 c4 10             	add    $0x10,%esp
f010138c:	85 c0                	test   %eax,%eax
f010138e:	75 19                	jne    f01013a9 <mem_init+0x18f>
f0101390:	68 98 6d 10 f0       	push   $0xf0106d98
f0101395:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010139a:	68 2b 03 00 00       	push   $0x32b
f010139f:	68 65 6c 10 f0       	push   $0xf0106c65
f01013a4:	e8 97 ec ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f01013a9:	83 ec 0c             	sub    $0xc,%esp
f01013ac:	6a 00                	push   $0x0
f01013ae:	e8 c7 fa ff ff       	call   f0100e7a <page_alloc>
f01013b3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f01013b6:	83 c4 10             	add    $0x10,%esp
f01013b9:	85 c0                	test   %eax,%eax
f01013bb:	75 19                	jne    f01013d6 <mem_init+0x1bc>
f01013bd:	68 ae 6d 10 f0       	push   $0xf0106dae
f01013c2:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01013c7:	68 2c 03 00 00       	push   $0x32c
f01013cc:	68 65 6c 10 f0       	push   $0xf0106c65
f01013d1:	e8 6a ec ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013d6:	39 f7                	cmp    %esi,%edi
f01013d8:	75 19                	jne    f01013f3 <mem_init+0x1d9>
f01013da:	68 c4 6d 10 f0       	push   $0xf0106dc4
f01013df:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01013e4:	68 2f 03 00 00       	push   $0x32f
f01013e9:	68 65 6c 10 f0       	push   $0xf0106c65
f01013ee:	e8 4d ec ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013f3:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013f6:	39 c6                	cmp    %eax,%esi
f01013f8:	74 04                	je     f01013fe <mem_init+0x1e4>
f01013fa:	39 c7                	cmp    %eax,%edi
f01013fc:	75 19                	jne    f0101417 <mem_init+0x1fd>
f01013fe:	68 88 64 10 f0       	push   $0xf0106488
f0101403:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101408:	68 30 03 00 00       	push   $0x330
f010140d:	68 65 6c 10 f0       	push   $0xf0106c65
f0101412:	e8 29 ec ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101417:	8b 0d 90 1e 21 f0    	mov    0xf0211e90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f010141d:	8b 15 88 1e 21 f0    	mov    0xf0211e88,%edx
f0101423:	c1 e2 0c             	shl    $0xc,%edx
f0101426:	89 f8                	mov    %edi,%eax
f0101428:	29 c8                	sub    %ecx,%eax
f010142a:	c1 f8 03             	sar    $0x3,%eax
f010142d:	c1 e0 0c             	shl    $0xc,%eax
f0101430:	39 d0                	cmp    %edx,%eax
f0101432:	72 19                	jb     f010144d <mem_init+0x233>
f0101434:	68 d6 6d 10 f0       	push   $0xf0106dd6
f0101439:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010143e:	68 31 03 00 00       	push   $0x331
f0101443:	68 65 6c 10 f0       	push   $0xf0106c65
f0101448:	e8 f3 eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f010144d:	89 f0                	mov    %esi,%eax
f010144f:	29 c8                	sub    %ecx,%eax
f0101451:	c1 f8 03             	sar    $0x3,%eax
f0101454:	c1 e0 0c             	shl    $0xc,%eax
f0101457:	39 c2                	cmp    %eax,%edx
f0101459:	77 19                	ja     f0101474 <mem_init+0x25a>
f010145b:	68 f3 6d 10 f0       	push   $0xf0106df3
f0101460:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101465:	68 32 03 00 00       	push   $0x332
f010146a:	68 65 6c 10 f0       	push   $0xf0106c65
f010146f:	e8 cc eb ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101474:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101477:	29 c8                	sub    %ecx,%eax
f0101479:	c1 f8 03             	sar    $0x3,%eax
f010147c:	c1 e0 0c             	shl    $0xc,%eax
f010147f:	39 c2                	cmp    %eax,%edx
f0101481:	77 19                	ja     f010149c <mem_init+0x282>
f0101483:	68 10 6e 10 f0       	push   $0xf0106e10
f0101488:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010148d:	68 33 03 00 00       	push   $0x333
f0101492:	68 65 6c 10 f0       	push   $0xf0106c65
f0101497:	e8 a4 eb ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f010149c:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f01014a1:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01014a4:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f01014ab:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01014ae:	83 ec 0c             	sub    $0xc,%esp
f01014b1:	6a 00                	push   $0x0
f01014b3:	e8 c2 f9 ff ff       	call   f0100e7a <page_alloc>
f01014b8:	83 c4 10             	add    $0x10,%esp
f01014bb:	85 c0                	test   %eax,%eax
f01014bd:	74 19                	je     f01014d8 <mem_init+0x2be>
f01014bf:	68 2d 6e 10 f0       	push   $0xf0106e2d
f01014c4:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01014c9:	68 3a 03 00 00       	push   $0x33a
f01014ce:	68 65 6c 10 f0       	push   $0xf0106c65
f01014d3:	e8 68 eb ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014d8:	83 ec 0c             	sub    $0xc,%esp
f01014db:	57                   	push   %edi
f01014dc:	e8 09 fa ff ff       	call   f0100eea <page_free>
	page_free(pp1);
f01014e1:	89 34 24             	mov    %esi,(%esp)
f01014e4:	e8 01 fa ff ff       	call   f0100eea <page_free>
	page_free(pp2);
f01014e9:	83 c4 04             	add    $0x4,%esp
f01014ec:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014ef:	e8 f6 f9 ff ff       	call   f0100eea <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014f4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014fb:	e8 7a f9 ff ff       	call   f0100e7a <page_alloc>
f0101500:	89 c6                	mov    %eax,%esi
f0101502:	83 c4 10             	add    $0x10,%esp
f0101505:	85 c0                	test   %eax,%eax
f0101507:	75 19                	jne    f0101522 <mem_init+0x308>
f0101509:	68 82 6d 10 f0       	push   $0xf0106d82
f010150e:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101513:	68 41 03 00 00       	push   $0x341
f0101518:	68 65 6c 10 f0       	push   $0xf0106c65
f010151d:	e8 1e eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101522:	83 ec 0c             	sub    $0xc,%esp
f0101525:	6a 00                	push   $0x0
f0101527:	e8 4e f9 ff ff       	call   f0100e7a <page_alloc>
f010152c:	89 c7                	mov    %eax,%edi
f010152e:	83 c4 10             	add    $0x10,%esp
f0101531:	85 c0                	test   %eax,%eax
f0101533:	75 19                	jne    f010154e <mem_init+0x334>
f0101535:	68 98 6d 10 f0       	push   $0xf0106d98
f010153a:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010153f:	68 42 03 00 00       	push   $0x342
f0101544:	68 65 6c 10 f0       	push   $0xf0106c65
f0101549:	e8 f2 ea ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010154e:	83 ec 0c             	sub    $0xc,%esp
f0101551:	6a 00                	push   $0x0
f0101553:	e8 22 f9 ff ff       	call   f0100e7a <page_alloc>
f0101558:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010155b:	83 c4 10             	add    $0x10,%esp
f010155e:	85 c0                	test   %eax,%eax
f0101560:	75 19                	jne    f010157b <mem_init+0x361>
f0101562:	68 ae 6d 10 f0       	push   $0xf0106dae
f0101567:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010156c:	68 43 03 00 00       	push   $0x343
f0101571:	68 65 6c 10 f0       	push   $0xf0106c65
f0101576:	e8 c5 ea ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010157b:	39 fe                	cmp    %edi,%esi
f010157d:	75 19                	jne    f0101598 <mem_init+0x37e>
f010157f:	68 c4 6d 10 f0       	push   $0xf0106dc4
f0101584:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101589:	68 45 03 00 00       	push   $0x345
f010158e:	68 65 6c 10 f0       	push   $0xf0106c65
f0101593:	e8 a8 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101598:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010159b:	39 c7                	cmp    %eax,%edi
f010159d:	74 04                	je     f01015a3 <mem_init+0x389>
f010159f:	39 c6                	cmp    %eax,%esi
f01015a1:	75 19                	jne    f01015bc <mem_init+0x3a2>
f01015a3:	68 88 64 10 f0       	push   $0xf0106488
f01015a8:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01015ad:	68 46 03 00 00       	push   $0x346
f01015b2:	68 65 6c 10 f0       	push   $0xf0106c65
f01015b7:	e8 84 ea ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f01015bc:	83 ec 0c             	sub    $0xc,%esp
f01015bf:	6a 00                	push   $0x0
f01015c1:	e8 b4 f8 ff ff       	call   f0100e7a <page_alloc>
f01015c6:	83 c4 10             	add    $0x10,%esp
f01015c9:	85 c0                	test   %eax,%eax
f01015cb:	74 19                	je     f01015e6 <mem_init+0x3cc>
f01015cd:	68 2d 6e 10 f0       	push   $0xf0106e2d
f01015d2:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01015d7:	68 47 03 00 00       	push   $0x347
f01015dc:	68 65 6c 10 f0       	push   $0xf0106c65
f01015e1:	e8 5a ea ff ff       	call   f0100040 <_panic>
f01015e6:	89 f0                	mov    %esi,%eax
f01015e8:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01015ee:	c1 f8 03             	sar    $0x3,%eax
f01015f1:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015f4:	89 c2                	mov    %eax,%edx
f01015f6:	c1 ea 0c             	shr    $0xc,%edx
f01015f9:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01015ff:	72 12                	jb     f0101613 <mem_init+0x3f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101601:	50                   	push   %eax
f0101602:	68 24 5e 10 f0       	push   $0xf0105e24
f0101607:	6a 58                	push   $0x58
f0101609:	68 71 6c 10 f0       	push   $0xf0106c71
f010160e:	e8 2d ea ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101613:	83 ec 04             	sub    $0x4,%esp
f0101616:	68 00 10 00 00       	push   $0x1000
f010161b:	6a 01                	push   $0x1
f010161d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101622:	50                   	push   %eax
f0101623:	e8 2d 3b 00 00       	call   f0105155 <memset>
	page_free(pp0);
f0101628:	89 34 24             	mov    %esi,(%esp)
f010162b:	e8 ba f8 ff ff       	call   f0100eea <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101630:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101637:	e8 3e f8 ff ff       	call   f0100e7a <page_alloc>
f010163c:	83 c4 10             	add    $0x10,%esp
f010163f:	85 c0                	test   %eax,%eax
f0101641:	75 19                	jne    f010165c <mem_init+0x442>
f0101643:	68 3c 6e 10 f0       	push   $0xf0106e3c
f0101648:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010164d:	68 4c 03 00 00       	push   $0x34c
f0101652:	68 65 6c 10 f0       	push   $0xf0106c65
f0101657:	e8 e4 e9 ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f010165c:	39 c6                	cmp    %eax,%esi
f010165e:	74 19                	je     f0101679 <mem_init+0x45f>
f0101660:	68 5a 6e 10 f0       	push   $0xf0106e5a
f0101665:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010166a:	68 4d 03 00 00       	push   $0x34d
f010166f:	68 65 6c 10 f0       	push   $0xf0106c65
f0101674:	e8 c7 e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101679:	89 f0                	mov    %esi,%eax
f010167b:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101681:	c1 f8 03             	sar    $0x3,%eax
f0101684:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101687:	89 c2                	mov    %eax,%edx
f0101689:	c1 ea 0c             	shr    $0xc,%edx
f010168c:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0101692:	72 12                	jb     f01016a6 <mem_init+0x48c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101694:	50                   	push   %eax
f0101695:	68 24 5e 10 f0       	push   $0xf0105e24
f010169a:	6a 58                	push   $0x58
f010169c:	68 71 6c 10 f0       	push   $0xf0106c71
f01016a1:	e8 9a e9 ff ff       	call   f0100040 <_panic>
f01016a6:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f01016ac:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f01016b2:	80 38 00             	cmpb   $0x0,(%eax)
f01016b5:	74 19                	je     f01016d0 <mem_init+0x4b6>
f01016b7:	68 6a 6e 10 f0       	push   $0xf0106e6a
f01016bc:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01016c1:	68 50 03 00 00       	push   $0x350
f01016c6:	68 65 6c 10 f0       	push   $0xf0106c65
f01016cb:	e8 70 e9 ff ff       	call   f0100040 <_panic>
f01016d0:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01016d3:	39 d0                	cmp    %edx,%eax
f01016d5:	75 db                	jne    f01016b2 <mem_init+0x498>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01016d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016da:	a3 40 12 21 f0       	mov    %eax,0xf0211240

	// free the pages we took
	page_free(pp0);
f01016df:	83 ec 0c             	sub    $0xc,%esp
f01016e2:	56                   	push   %esi
f01016e3:	e8 02 f8 ff ff       	call   f0100eea <page_free>
	page_free(pp1);
f01016e8:	89 3c 24             	mov    %edi,(%esp)
f01016eb:	e8 fa f7 ff ff       	call   f0100eea <page_free>
	page_free(pp2);
f01016f0:	83 c4 04             	add    $0x4,%esp
f01016f3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016f6:	e8 ef f7 ff ff       	call   f0100eea <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016fb:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101700:	83 c4 10             	add    $0x10,%esp
f0101703:	eb 05                	jmp    f010170a <mem_init+0x4f0>
		--nfree;
f0101705:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101708:	8b 00                	mov    (%eax),%eax
f010170a:	85 c0                	test   %eax,%eax
f010170c:	75 f7                	jne    f0101705 <mem_init+0x4eb>
		--nfree;
	assert(nfree == 0);
f010170e:	85 db                	test   %ebx,%ebx
f0101710:	74 19                	je     f010172b <mem_init+0x511>
f0101712:	68 74 6e 10 f0       	push   $0xf0106e74
f0101717:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010171c:	68 5d 03 00 00       	push   $0x35d
f0101721:	68 65 6c 10 f0       	push   $0xf0106c65
f0101726:	e8 15 e9 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f010172b:	83 ec 0c             	sub    $0xc,%esp
f010172e:	68 a8 64 10 f0       	push   $0xf01064a8
f0101733:	e8 3c 1e 00 00       	call   f0103574 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101738:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010173f:	e8 36 f7 ff ff       	call   f0100e7a <page_alloc>
f0101744:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101747:	83 c4 10             	add    $0x10,%esp
f010174a:	85 c0                	test   %eax,%eax
f010174c:	75 19                	jne    f0101767 <mem_init+0x54d>
f010174e:	68 82 6d 10 f0       	push   $0xf0106d82
f0101753:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101758:	68 c3 03 00 00       	push   $0x3c3
f010175d:	68 65 6c 10 f0       	push   $0xf0106c65
f0101762:	e8 d9 e8 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101767:	83 ec 0c             	sub    $0xc,%esp
f010176a:	6a 00                	push   $0x0
f010176c:	e8 09 f7 ff ff       	call   f0100e7a <page_alloc>
f0101771:	89 c3                	mov    %eax,%ebx
f0101773:	83 c4 10             	add    $0x10,%esp
f0101776:	85 c0                	test   %eax,%eax
f0101778:	75 19                	jne    f0101793 <mem_init+0x579>
f010177a:	68 98 6d 10 f0       	push   $0xf0106d98
f010177f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101784:	68 c4 03 00 00       	push   $0x3c4
f0101789:	68 65 6c 10 f0       	push   $0xf0106c65
f010178e:	e8 ad e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101793:	83 ec 0c             	sub    $0xc,%esp
f0101796:	6a 00                	push   $0x0
f0101798:	e8 dd f6 ff ff       	call   f0100e7a <page_alloc>
f010179d:	89 c6                	mov    %eax,%esi
f010179f:	83 c4 10             	add    $0x10,%esp
f01017a2:	85 c0                	test   %eax,%eax
f01017a4:	75 19                	jne    f01017bf <mem_init+0x5a5>
f01017a6:	68 ae 6d 10 f0       	push   $0xf0106dae
f01017ab:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01017b0:	68 c5 03 00 00       	push   $0x3c5
f01017b5:	68 65 6c 10 f0       	push   $0xf0106c65
f01017ba:	e8 81 e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01017bf:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f01017c2:	75 19                	jne    f01017dd <mem_init+0x5c3>
f01017c4:	68 c4 6d 10 f0       	push   $0xf0106dc4
f01017c9:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01017ce:	68 c8 03 00 00       	push   $0x3c8
f01017d3:	68 65 6c 10 f0       	push   $0xf0106c65
f01017d8:	e8 63 e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017dd:	39 c3                	cmp    %eax,%ebx
f01017df:	74 05                	je     f01017e6 <mem_init+0x5cc>
f01017e1:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01017e4:	75 19                	jne    f01017ff <mem_init+0x5e5>
f01017e6:	68 88 64 10 f0       	push   $0xf0106488
f01017eb:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01017f0:	68 c9 03 00 00       	push   $0x3c9
f01017f5:	68 65 6c 10 f0       	push   $0xf0106c65
f01017fa:	e8 41 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017ff:	a1 40 12 21 f0       	mov    0xf0211240,%eax
f0101804:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f0101807:	c7 05 40 12 21 f0 00 	movl   $0x0,0xf0211240
f010180e:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101811:	83 ec 0c             	sub    $0xc,%esp
f0101814:	6a 00                	push   $0x0
f0101816:	e8 5f f6 ff ff       	call   f0100e7a <page_alloc>
f010181b:	83 c4 10             	add    $0x10,%esp
f010181e:	85 c0                	test   %eax,%eax
f0101820:	74 19                	je     f010183b <mem_init+0x621>
f0101822:	68 2d 6e 10 f0       	push   $0xf0106e2d
f0101827:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010182c:	68 d0 03 00 00       	push   $0x3d0
f0101831:	68 65 6c 10 f0       	push   $0xf0106c65
f0101836:	e8 05 e8 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f010183b:	83 ec 04             	sub    $0x4,%esp
f010183e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101841:	50                   	push   %eax
f0101842:	6a 00                	push   $0x0
f0101844:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010184a:	e8 17 f8 ff ff       	call   f0101066 <page_lookup>
f010184f:	83 c4 10             	add    $0x10,%esp
f0101852:	85 c0                	test   %eax,%eax
f0101854:	74 19                	je     f010186f <mem_init+0x655>
f0101856:	68 c8 64 10 f0       	push   $0xf01064c8
f010185b:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101860:	68 d3 03 00 00       	push   $0x3d3
f0101865:	68 65 6c 10 f0       	push   $0xf0106c65
f010186a:	e8 d1 e7 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f010186f:	6a 02                	push   $0x2
f0101871:	6a 00                	push   $0x0
f0101873:	53                   	push   %ebx
f0101874:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010187a:	e8 d1 f8 ff ff       	call   f0101150 <page_insert>
f010187f:	83 c4 10             	add    $0x10,%esp
f0101882:	85 c0                	test   %eax,%eax
f0101884:	78 19                	js     f010189f <mem_init+0x685>
f0101886:	68 00 65 10 f0       	push   $0xf0106500
f010188b:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101890:	68 d6 03 00 00       	push   $0x3d6
f0101895:	68 65 6c 10 f0       	push   $0xf0106c65
f010189a:	e8 a1 e7 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010189f:	83 ec 0c             	sub    $0xc,%esp
f01018a2:	ff 75 d4             	pushl  -0x2c(%ebp)
f01018a5:	e8 40 f6 ff ff       	call   f0100eea <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f01018aa:	6a 02                	push   $0x2
f01018ac:	6a 00                	push   $0x0
f01018ae:	53                   	push   %ebx
f01018af:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01018b5:	e8 96 f8 ff ff       	call   f0101150 <page_insert>
f01018ba:	83 c4 20             	add    $0x20,%esp
f01018bd:	85 c0                	test   %eax,%eax
f01018bf:	74 19                	je     f01018da <mem_init+0x6c0>
f01018c1:	68 30 65 10 f0       	push   $0xf0106530
f01018c6:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01018cb:	68 da 03 00 00       	push   $0x3da
f01018d0:	68 65 6c 10 f0       	push   $0xf0106c65
f01018d5:	e8 66 e7 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018da:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018e0:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f01018e5:	89 c1                	mov    %eax,%ecx
f01018e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018ea:	8b 17                	mov    (%edi),%edx
f01018ec:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018f5:	29 c8                	sub    %ecx,%eax
f01018f7:	c1 f8 03             	sar    $0x3,%eax
f01018fa:	c1 e0 0c             	shl    $0xc,%eax
f01018fd:	39 c2                	cmp    %eax,%edx
f01018ff:	74 19                	je     f010191a <mem_init+0x700>
f0101901:	68 60 65 10 f0       	push   $0xf0106560
f0101906:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010190b:	68 db 03 00 00       	push   $0x3db
f0101910:	68 65 6c 10 f0       	push   $0xf0106c65
f0101915:	e8 26 e7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f010191a:	ba 00 00 00 00       	mov    $0x0,%edx
f010191f:	89 f8                	mov    %edi,%eax
f0101921:	e8 51 f1 ff ff       	call   f0100a77 <check_va2pa>
f0101926:	89 da                	mov    %ebx,%edx
f0101928:	2b 55 cc             	sub    -0x34(%ebp),%edx
f010192b:	c1 fa 03             	sar    $0x3,%edx
f010192e:	c1 e2 0c             	shl    $0xc,%edx
f0101931:	39 d0                	cmp    %edx,%eax
f0101933:	74 19                	je     f010194e <mem_init+0x734>
f0101935:	68 88 65 10 f0       	push   $0xf0106588
f010193a:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010193f:	68 dc 03 00 00       	push   $0x3dc
f0101944:	68 65 6c 10 f0       	push   $0xf0106c65
f0101949:	e8 f2 e6 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f010194e:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101953:	74 19                	je     f010196e <mem_init+0x754>
f0101955:	68 7f 6e 10 f0       	push   $0xf0106e7f
f010195a:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010195f:	68 dd 03 00 00       	push   $0x3dd
f0101964:	68 65 6c 10 f0       	push   $0xf0106c65
f0101969:	e8 d2 e6 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f010196e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101971:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f0101976:	74 19                	je     f0101991 <mem_init+0x777>
f0101978:	68 90 6e 10 f0       	push   $0xf0106e90
f010197d:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101982:	68 de 03 00 00       	push   $0x3de
f0101987:	68 65 6c 10 f0       	push   $0xf0106c65
f010198c:	e8 af e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101991:	6a 02                	push   $0x2
f0101993:	68 00 10 00 00       	push   $0x1000
f0101998:	56                   	push   %esi
f0101999:	57                   	push   %edi
f010199a:	e8 b1 f7 ff ff       	call   f0101150 <page_insert>
f010199f:	83 c4 10             	add    $0x10,%esp
f01019a2:	85 c0                	test   %eax,%eax
f01019a4:	74 19                	je     f01019bf <mem_init+0x7a5>
f01019a6:	68 b8 65 10 f0       	push   $0xf01065b8
f01019ab:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01019b0:	68 e1 03 00 00       	push   $0x3e1
f01019b5:	68 65 6c 10 f0       	push   $0xf0106c65
f01019ba:	e8 81 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01019bf:	ba 00 10 00 00       	mov    $0x1000,%edx
f01019c4:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01019c9:	e8 a9 f0 ff ff       	call   f0100a77 <check_va2pa>
f01019ce:	89 f2                	mov    %esi,%edx
f01019d0:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f01019d6:	c1 fa 03             	sar    $0x3,%edx
f01019d9:	c1 e2 0c             	shl    $0xc,%edx
f01019dc:	39 d0                	cmp    %edx,%eax
f01019de:	74 19                	je     f01019f9 <mem_init+0x7df>
f01019e0:	68 f4 65 10 f0       	push   $0xf01065f4
f01019e5:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01019ea:	68 e2 03 00 00       	push   $0x3e2
f01019ef:	68 65 6c 10 f0       	push   $0xf0106c65
f01019f4:	e8 47 e6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01019f9:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019fe:	74 19                	je     f0101a19 <mem_init+0x7ff>
f0101a00:	68 a1 6e 10 f0       	push   $0xf0106ea1
f0101a05:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101a0a:	68 e3 03 00 00       	push   $0x3e3
f0101a0f:	68 65 6c 10 f0       	push   $0xf0106c65
f0101a14:	e8 27 e6 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0101a19:	83 ec 0c             	sub    $0xc,%esp
f0101a1c:	6a 00                	push   $0x0
f0101a1e:	e8 57 f4 ff ff       	call   f0100e7a <page_alloc>
f0101a23:	83 c4 10             	add    $0x10,%esp
f0101a26:	85 c0                	test   %eax,%eax
f0101a28:	74 19                	je     f0101a43 <mem_init+0x829>
f0101a2a:	68 2d 6e 10 f0       	push   $0xf0106e2d
f0101a2f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101a34:	68 e6 03 00 00       	push   $0x3e6
f0101a39:	68 65 6c 10 f0       	push   $0xf0106c65
f0101a3e:	e8 fd e5 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a43:	6a 02                	push   $0x2
f0101a45:	68 00 10 00 00       	push   $0x1000
f0101a4a:	56                   	push   %esi
f0101a4b:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101a51:	e8 fa f6 ff ff       	call   f0101150 <page_insert>
f0101a56:	83 c4 10             	add    $0x10,%esp
f0101a59:	85 c0                	test   %eax,%eax
f0101a5b:	74 19                	je     f0101a76 <mem_init+0x85c>
f0101a5d:	68 b8 65 10 f0       	push   $0xf01065b8
f0101a62:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101a67:	68 e9 03 00 00       	push   $0x3e9
f0101a6c:	68 65 6c 10 f0       	push   $0xf0106c65
f0101a71:	e8 ca e5 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a76:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a7b:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101a80:	e8 f2 ef ff ff       	call   f0100a77 <check_va2pa>
f0101a85:	89 f2                	mov    %esi,%edx
f0101a87:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101a8d:	c1 fa 03             	sar    $0x3,%edx
f0101a90:	c1 e2 0c             	shl    $0xc,%edx
f0101a93:	39 d0                	cmp    %edx,%eax
f0101a95:	74 19                	je     f0101ab0 <mem_init+0x896>
f0101a97:	68 f4 65 10 f0       	push   $0xf01065f4
f0101a9c:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101aa1:	68 ea 03 00 00       	push   $0x3ea
f0101aa6:	68 65 6c 10 f0       	push   $0xf0106c65
f0101aab:	e8 90 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101ab0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ab5:	74 19                	je     f0101ad0 <mem_init+0x8b6>
f0101ab7:	68 a1 6e 10 f0       	push   $0xf0106ea1
f0101abc:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101ac1:	68 eb 03 00 00       	push   $0x3eb
f0101ac6:	68 65 6c 10 f0       	push   $0xf0106c65
f0101acb:	e8 70 e5 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101ad0:	83 ec 0c             	sub    $0xc,%esp
f0101ad3:	6a 00                	push   $0x0
f0101ad5:	e8 a0 f3 ff ff       	call   f0100e7a <page_alloc>
f0101ada:	83 c4 10             	add    $0x10,%esp
f0101add:	85 c0                	test   %eax,%eax
f0101adf:	74 19                	je     f0101afa <mem_init+0x8e0>
f0101ae1:	68 2d 6e 10 f0       	push   $0xf0106e2d
f0101ae6:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101aeb:	68 ef 03 00 00       	push   $0x3ef
f0101af0:	68 65 6c 10 f0       	push   $0xf0106c65
f0101af5:	e8 46 e5 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101afa:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f0101b00:	8b 02                	mov    (%edx),%eax
f0101b02:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101b07:	89 c1                	mov    %eax,%ecx
f0101b09:	c1 e9 0c             	shr    $0xc,%ecx
f0101b0c:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0101b12:	72 15                	jb     f0101b29 <mem_init+0x90f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101b14:	50                   	push   %eax
f0101b15:	68 24 5e 10 f0       	push   $0xf0105e24
f0101b1a:	68 f2 03 00 00       	push   $0x3f2
f0101b1f:	68 65 6c 10 f0       	push   $0xf0106c65
f0101b24:	e8 17 e5 ff ff       	call   f0100040 <_panic>
f0101b29:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b2e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b31:	83 ec 04             	sub    $0x4,%esp
f0101b34:	6a 00                	push   $0x0
f0101b36:	68 00 10 00 00       	push   $0x1000
f0101b3b:	52                   	push   %edx
f0101b3c:	e8 43 f4 ff ff       	call   f0100f84 <pgdir_walk>
f0101b41:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101b44:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b47:	83 c4 10             	add    $0x10,%esp
f0101b4a:	39 d0                	cmp    %edx,%eax
f0101b4c:	74 19                	je     f0101b67 <mem_init+0x94d>
f0101b4e:	68 24 66 10 f0       	push   $0xf0106624
f0101b53:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101b58:	68 f3 03 00 00       	push   $0x3f3
f0101b5d:	68 65 6c 10 f0       	push   $0xf0106c65
f0101b62:	e8 d9 e4 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b67:	6a 06                	push   $0x6
f0101b69:	68 00 10 00 00       	push   $0x1000
f0101b6e:	56                   	push   %esi
f0101b6f:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101b75:	e8 d6 f5 ff ff       	call   f0101150 <page_insert>
f0101b7a:	83 c4 10             	add    $0x10,%esp
f0101b7d:	85 c0                	test   %eax,%eax
f0101b7f:	74 19                	je     f0101b9a <mem_init+0x980>
f0101b81:	68 64 66 10 f0       	push   $0xf0106664
f0101b86:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101b8b:	68 f6 03 00 00       	push   $0x3f6
f0101b90:	68 65 6c 10 f0       	push   $0xf0106c65
f0101b95:	e8 a6 e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b9a:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101ba0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ba5:	89 f8                	mov    %edi,%eax
f0101ba7:	e8 cb ee ff ff       	call   f0100a77 <check_va2pa>
f0101bac:	89 f2                	mov    %esi,%edx
f0101bae:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101bb4:	c1 fa 03             	sar    $0x3,%edx
f0101bb7:	c1 e2 0c             	shl    $0xc,%edx
f0101bba:	39 d0                	cmp    %edx,%eax
f0101bbc:	74 19                	je     f0101bd7 <mem_init+0x9bd>
f0101bbe:	68 f4 65 10 f0       	push   $0xf01065f4
f0101bc3:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101bc8:	68 f7 03 00 00       	push   $0x3f7
f0101bcd:	68 65 6c 10 f0       	push   $0xf0106c65
f0101bd2:	e8 69 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101bd7:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bdc:	74 19                	je     f0101bf7 <mem_init+0x9dd>
f0101bde:	68 a1 6e 10 f0       	push   $0xf0106ea1
f0101be3:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101be8:	68 f8 03 00 00       	push   $0x3f8
f0101bed:	68 65 6c 10 f0       	push   $0xf0106c65
f0101bf2:	e8 49 e4 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bf7:	83 ec 04             	sub    $0x4,%esp
f0101bfa:	6a 00                	push   $0x0
f0101bfc:	68 00 10 00 00       	push   $0x1000
f0101c01:	57                   	push   %edi
f0101c02:	e8 7d f3 ff ff       	call   f0100f84 <pgdir_walk>
f0101c07:	83 c4 10             	add    $0x10,%esp
f0101c0a:	f6 00 04             	testb  $0x4,(%eax)
f0101c0d:	75 19                	jne    f0101c28 <mem_init+0xa0e>
f0101c0f:	68 a4 66 10 f0       	push   $0xf01066a4
f0101c14:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101c19:	68 f9 03 00 00       	push   $0x3f9
f0101c1e:	68 65 6c 10 f0       	push   $0xf0106c65
f0101c23:	e8 18 e4 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101c28:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0101c2d:	f6 00 04             	testb  $0x4,(%eax)
f0101c30:	75 19                	jne    f0101c4b <mem_init+0xa31>
f0101c32:	68 b2 6e 10 f0       	push   $0xf0106eb2
f0101c37:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101c3c:	68 fa 03 00 00       	push   $0x3fa
f0101c41:	68 65 6c 10 f0       	push   $0xf0106c65
f0101c46:	e8 f5 e3 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c4b:	6a 02                	push   $0x2
f0101c4d:	68 00 10 00 00       	push   $0x1000
f0101c52:	56                   	push   %esi
f0101c53:	50                   	push   %eax
f0101c54:	e8 f7 f4 ff ff       	call   f0101150 <page_insert>
f0101c59:	83 c4 10             	add    $0x10,%esp
f0101c5c:	85 c0                	test   %eax,%eax
f0101c5e:	74 19                	je     f0101c79 <mem_init+0xa5f>
f0101c60:	68 b8 65 10 f0       	push   $0xf01065b8
f0101c65:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101c6a:	68 fd 03 00 00       	push   $0x3fd
f0101c6f:	68 65 6c 10 f0       	push   $0xf0106c65
f0101c74:	e8 c7 e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c79:	83 ec 04             	sub    $0x4,%esp
f0101c7c:	6a 00                	push   $0x0
f0101c7e:	68 00 10 00 00       	push   $0x1000
f0101c83:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101c89:	e8 f6 f2 ff ff       	call   f0100f84 <pgdir_walk>
f0101c8e:	83 c4 10             	add    $0x10,%esp
f0101c91:	f6 00 02             	testb  $0x2,(%eax)
f0101c94:	75 19                	jne    f0101caf <mem_init+0xa95>
f0101c96:	68 d8 66 10 f0       	push   $0xf01066d8
f0101c9b:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101ca0:	68 fe 03 00 00       	push   $0x3fe
f0101ca5:	68 65 6c 10 f0       	push   $0xf0106c65
f0101caa:	e8 91 e3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101caf:	83 ec 04             	sub    $0x4,%esp
f0101cb2:	6a 00                	push   $0x0
f0101cb4:	68 00 10 00 00       	push   $0x1000
f0101cb9:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101cbf:	e8 c0 f2 ff ff       	call   f0100f84 <pgdir_walk>
f0101cc4:	83 c4 10             	add    $0x10,%esp
f0101cc7:	f6 00 04             	testb  $0x4,(%eax)
f0101cca:	74 19                	je     f0101ce5 <mem_init+0xacb>
f0101ccc:	68 0c 67 10 f0       	push   $0xf010670c
f0101cd1:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101cd6:	68 ff 03 00 00       	push   $0x3ff
f0101cdb:	68 65 6c 10 f0       	push   $0xf0106c65
f0101ce0:	e8 5b e3 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101ce5:	6a 02                	push   $0x2
f0101ce7:	68 00 00 40 00       	push   $0x400000
f0101cec:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cef:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101cf5:	e8 56 f4 ff ff       	call   f0101150 <page_insert>
f0101cfa:	83 c4 10             	add    $0x10,%esp
f0101cfd:	85 c0                	test   %eax,%eax
f0101cff:	78 19                	js     f0101d1a <mem_init+0xb00>
f0101d01:	68 44 67 10 f0       	push   $0xf0106744
f0101d06:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101d0b:	68 02 04 00 00       	push   $0x402
f0101d10:	68 65 6c 10 f0       	push   $0xf0106c65
f0101d15:	e8 26 e3 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101d1a:	6a 02                	push   $0x2
f0101d1c:	68 00 10 00 00       	push   $0x1000
f0101d21:	53                   	push   %ebx
f0101d22:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101d28:	e8 23 f4 ff ff       	call   f0101150 <page_insert>
f0101d2d:	83 c4 10             	add    $0x10,%esp
f0101d30:	85 c0                	test   %eax,%eax
f0101d32:	74 19                	je     f0101d4d <mem_init+0xb33>
f0101d34:	68 7c 67 10 f0       	push   $0xf010677c
f0101d39:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101d3e:	68 05 04 00 00       	push   $0x405
f0101d43:	68 65 6c 10 f0       	push   $0xf0106c65
f0101d48:	e8 f3 e2 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d4d:	83 ec 04             	sub    $0x4,%esp
f0101d50:	6a 00                	push   $0x0
f0101d52:	68 00 10 00 00       	push   $0x1000
f0101d57:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101d5d:	e8 22 f2 ff ff       	call   f0100f84 <pgdir_walk>
f0101d62:	83 c4 10             	add    $0x10,%esp
f0101d65:	f6 00 04             	testb  $0x4,(%eax)
f0101d68:	74 19                	je     f0101d83 <mem_init+0xb69>
f0101d6a:	68 0c 67 10 f0       	push   $0xf010670c
f0101d6f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101d74:	68 06 04 00 00       	push   $0x406
f0101d79:	68 65 6c 10 f0       	push   $0xf0106c65
f0101d7e:	e8 bd e2 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d83:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101d89:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d8e:	89 f8                	mov    %edi,%eax
f0101d90:	e8 e2 ec ff ff       	call   f0100a77 <check_va2pa>
f0101d95:	89 c1                	mov    %eax,%ecx
f0101d97:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d9a:	89 d8                	mov    %ebx,%eax
f0101d9c:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0101da2:	c1 f8 03             	sar    $0x3,%eax
f0101da5:	c1 e0 0c             	shl    $0xc,%eax
f0101da8:	39 c1                	cmp    %eax,%ecx
f0101daa:	74 19                	je     f0101dc5 <mem_init+0xbab>
f0101dac:	68 b8 67 10 f0       	push   $0xf01067b8
f0101db1:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101db6:	68 09 04 00 00       	push   $0x409
f0101dbb:	68 65 6c 10 f0       	push   $0xf0106c65
f0101dc0:	e8 7b e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dc5:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101dca:	89 f8                	mov    %edi,%eax
f0101dcc:	e8 a6 ec ff ff       	call   f0100a77 <check_va2pa>
f0101dd1:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101dd4:	74 19                	je     f0101def <mem_init+0xbd5>
f0101dd6:	68 e4 67 10 f0       	push   $0xf01067e4
f0101ddb:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101de0:	68 0a 04 00 00       	push   $0x40a
f0101de5:	68 65 6c 10 f0       	push   $0xf0106c65
f0101dea:	e8 51 e2 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101def:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101df4:	74 19                	je     f0101e0f <mem_init+0xbf5>
f0101df6:	68 c8 6e 10 f0       	push   $0xf0106ec8
f0101dfb:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101e00:	68 0c 04 00 00       	push   $0x40c
f0101e05:	68 65 6c 10 f0       	push   $0xf0106c65
f0101e0a:	e8 31 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101e0f:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101e14:	74 19                	je     f0101e2f <mem_init+0xc15>
f0101e16:	68 d9 6e 10 f0       	push   $0xf0106ed9
f0101e1b:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101e20:	68 0d 04 00 00       	push   $0x40d
f0101e25:	68 65 6c 10 f0       	push   $0xf0106c65
f0101e2a:	e8 11 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e2f:	83 ec 0c             	sub    $0xc,%esp
f0101e32:	6a 00                	push   $0x0
f0101e34:	e8 41 f0 ff ff       	call   f0100e7a <page_alloc>
f0101e39:	83 c4 10             	add    $0x10,%esp
f0101e3c:	85 c0                	test   %eax,%eax
f0101e3e:	74 04                	je     f0101e44 <mem_init+0xc2a>
f0101e40:	39 c6                	cmp    %eax,%esi
f0101e42:	74 19                	je     f0101e5d <mem_init+0xc43>
f0101e44:	68 14 68 10 f0       	push   $0xf0106814
f0101e49:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101e4e:	68 10 04 00 00       	push   $0x410
f0101e53:	68 65 6c 10 f0       	push   $0xf0106c65
f0101e58:	e8 e3 e1 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e5d:	83 ec 08             	sub    $0x8,%esp
f0101e60:	6a 00                	push   $0x0
f0101e62:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101e68:	e8 93 f2 ff ff       	call   f0101100 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e6d:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101e73:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e78:	89 f8                	mov    %edi,%eax
f0101e7a:	e8 f8 eb ff ff       	call   f0100a77 <check_va2pa>
f0101e7f:	83 c4 10             	add    $0x10,%esp
f0101e82:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e85:	74 19                	je     f0101ea0 <mem_init+0xc86>
f0101e87:	68 38 68 10 f0       	push   $0xf0106838
f0101e8c:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101e91:	68 14 04 00 00       	push   $0x414
f0101e96:	68 65 6c 10 f0       	push   $0xf0106c65
f0101e9b:	e8 a0 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101ea0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101ea5:	89 f8                	mov    %edi,%eax
f0101ea7:	e8 cb eb ff ff       	call   f0100a77 <check_va2pa>
f0101eac:	89 da                	mov    %ebx,%edx
f0101eae:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0101eb4:	c1 fa 03             	sar    $0x3,%edx
f0101eb7:	c1 e2 0c             	shl    $0xc,%edx
f0101eba:	39 d0                	cmp    %edx,%eax
f0101ebc:	74 19                	je     f0101ed7 <mem_init+0xcbd>
f0101ebe:	68 e4 67 10 f0       	push   $0xf01067e4
f0101ec3:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101ec8:	68 15 04 00 00       	push   $0x415
f0101ecd:	68 65 6c 10 f0       	push   $0xf0106c65
f0101ed2:	e8 69 e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101ed7:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101edc:	74 19                	je     f0101ef7 <mem_init+0xcdd>
f0101ede:	68 7f 6e 10 f0       	push   $0xf0106e7f
f0101ee3:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101ee8:	68 16 04 00 00       	push   $0x416
f0101eed:	68 65 6c 10 f0       	push   $0xf0106c65
f0101ef2:	e8 49 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101ef7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101efc:	74 19                	je     f0101f17 <mem_init+0xcfd>
f0101efe:	68 d9 6e 10 f0       	push   $0xf0106ed9
f0101f03:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101f08:	68 17 04 00 00       	push   $0x417
f0101f0d:	68 65 6c 10 f0       	push   $0xf0106c65
f0101f12:	e8 29 e1 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101f17:	6a 00                	push   $0x0
f0101f19:	68 00 10 00 00       	push   $0x1000
f0101f1e:	53                   	push   %ebx
f0101f1f:	57                   	push   %edi
f0101f20:	e8 2b f2 ff ff       	call   f0101150 <page_insert>
f0101f25:	83 c4 10             	add    $0x10,%esp
f0101f28:	85 c0                	test   %eax,%eax
f0101f2a:	74 19                	je     f0101f45 <mem_init+0xd2b>
f0101f2c:	68 5c 68 10 f0       	push   $0xf010685c
f0101f31:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101f36:	68 1a 04 00 00       	push   $0x41a
f0101f3b:	68 65 6c 10 f0       	push   $0xf0106c65
f0101f40:	e8 fb e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0101f45:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f4a:	75 19                	jne    f0101f65 <mem_init+0xd4b>
f0101f4c:	68 ea 6e 10 f0       	push   $0xf0106eea
f0101f51:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101f56:	68 1b 04 00 00       	push   $0x41b
f0101f5b:	68 65 6c 10 f0       	push   $0xf0106c65
f0101f60:	e8 db e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0101f65:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f68:	74 19                	je     f0101f83 <mem_init+0xd69>
f0101f6a:	68 f6 6e 10 f0       	push   $0xf0106ef6
f0101f6f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101f74:	68 1c 04 00 00       	push   $0x41c
f0101f79:	68 65 6c 10 f0       	push   $0xf0106c65
f0101f7e:	e8 bd e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f83:	83 ec 08             	sub    $0x8,%esp
f0101f86:	68 00 10 00 00       	push   $0x1000
f0101f8b:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0101f91:	e8 6a f1 ff ff       	call   f0101100 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f96:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0101f9c:	ba 00 00 00 00       	mov    $0x0,%edx
f0101fa1:	89 f8                	mov    %edi,%eax
f0101fa3:	e8 cf ea ff ff       	call   f0100a77 <check_va2pa>
f0101fa8:	83 c4 10             	add    $0x10,%esp
f0101fab:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fae:	74 19                	je     f0101fc9 <mem_init+0xdaf>
f0101fb0:	68 38 68 10 f0       	push   $0xf0106838
f0101fb5:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101fba:	68 20 04 00 00       	push   $0x420
f0101fbf:	68 65 6c 10 f0       	push   $0xf0106c65
f0101fc4:	e8 77 e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fc9:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fce:	89 f8                	mov    %edi,%eax
f0101fd0:	e8 a2 ea ff ff       	call   f0100a77 <check_va2pa>
f0101fd5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fd8:	74 19                	je     f0101ff3 <mem_init+0xdd9>
f0101fda:	68 94 68 10 f0       	push   $0xf0106894
f0101fdf:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0101fe4:	68 21 04 00 00       	push   $0x421
f0101fe9:	68 65 6c 10 f0       	push   $0xf0106c65
f0101fee:	e8 4d e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0101ff3:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101ff8:	74 19                	je     f0102013 <mem_init+0xdf9>
f0101ffa:	68 0b 6f 10 f0       	push   $0xf0106f0b
f0101fff:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102004:	68 22 04 00 00       	push   $0x422
f0102009:	68 65 6c 10 f0       	push   $0xf0106c65
f010200e:	e8 2d e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0102013:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102018:	74 19                	je     f0102033 <mem_init+0xe19>
f010201a:	68 d9 6e 10 f0       	push   $0xf0106ed9
f010201f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102024:	68 23 04 00 00       	push   $0x423
f0102029:	68 65 6c 10 f0       	push   $0xf0106c65
f010202e:	e8 0d e0 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102033:	83 ec 0c             	sub    $0xc,%esp
f0102036:	6a 00                	push   $0x0
f0102038:	e8 3d ee ff ff       	call   f0100e7a <page_alloc>
f010203d:	83 c4 10             	add    $0x10,%esp
f0102040:	39 c3                	cmp    %eax,%ebx
f0102042:	75 04                	jne    f0102048 <mem_init+0xe2e>
f0102044:	85 c0                	test   %eax,%eax
f0102046:	75 19                	jne    f0102061 <mem_init+0xe47>
f0102048:	68 bc 68 10 f0       	push   $0xf01068bc
f010204d:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102052:	68 26 04 00 00       	push   $0x426
f0102057:	68 65 6c 10 f0       	push   $0xf0106c65
f010205c:	e8 df df ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102061:	83 ec 0c             	sub    $0xc,%esp
f0102064:	6a 00                	push   $0x0
f0102066:	e8 0f ee ff ff       	call   f0100e7a <page_alloc>
f010206b:	83 c4 10             	add    $0x10,%esp
f010206e:	85 c0                	test   %eax,%eax
f0102070:	74 19                	je     f010208b <mem_init+0xe71>
f0102072:	68 2d 6e 10 f0       	push   $0xf0106e2d
f0102077:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010207c:	68 29 04 00 00       	push   $0x429
f0102081:	68 65 6c 10 f0       	push   $0xf0106c65
f0102086:	e8 b5 df ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010208b:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f0102091:	8b 11                	mov    (%ecx),%edx
f0102093:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102099:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010209c:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01020a2:	c1 f8 03             	sar    $0x3,%eax
f01020a5:	c1 e0 0c             	shl    $0xc,%eax
f01020a8:	39 c2                	cmp    %eax,%edx
f01020aa:	74 19                	je     f01020c5 <mem_init+0xeab>
f01020ac:	68 60 65 10 f0       	push   $0xf0106560
f01020b1:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01020b6:	68 2c 04 00 00       	push   $0x42c
f01020bb:	68 65 6c 10 f0       	push   $0xf0106c65
f01020c0:	e8 7b df ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f01020c5:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01020cb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020ce:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01020d3:	74 19                	je     f01020ee <mem_init+0xed4>
f01020d5:	68 90 6e 10 f0       	push   $0xf0106e90
f01020da:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01020df:	68 2e 04 00 00       	push   $0x42e
f01020e4:	68 65 6c 10 f0       	push   $0xf0106c65
f01020e9:	e8 52 df ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01020ee:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020f1:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01020f7:	83 ec 0c             	sub    $0xc,%esp
f01020fa:	50                   	push   %eax
f01020fb:	e8 ea ed ff ff       	call   f0100eea <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102100:	83 c4 0c             	add    $0xc,%esp
f0102103:	6a 01                	push   $0x1
f0102105:	68 00 10 40 00       	push   $0x401000
f010210a:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102110:	e8 6f ee ff ff       	call   f0100f84 <pgdir_walk>
f0102115:	89 c7                	mov    %eax,%edi
f0102117:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f010211a:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010211f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102122:	8b 40 04             	mov    0x4(%eax),%eax
f0102125:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010212a:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f0102130:	89 c2                	mov    %eax,%edx
f0102132:	c1 ea 0c             	shr    $0xc,%edx
f0102135:	83 c4 10             	add    $0x10,%esp
f0102138:	39 ca                	cmp    %ecx,%edx
f010213a:	72 15                	jb     f0102151 <mem_init+0xf37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010213c:	50                   	push   %eax
f010213d:	68 24 5e 10 f0       	push   $0xf0105e24
f0102142:	68 35 04 00 00       	push   $0x435
f0102147:	68 65 6c 10 f0       	push   $0xf0106c65
f010214c:	e8 ef de ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102151:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f0102156:	39 c7                	cmp    %eax,%edi
f0102158:	74 19                	je     f0102173 <mem_init+0xf59>
f010215a:	68 1c 6f 10 f0       	push   $0xf0106f1c
f010215f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102164:	68 36 04 00 00       	push   $0x436
f0102169:	68 65 6c 10 f0       	push   $0xf0106c65
f010216e:	e8 cd de ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102173:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102176:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f010217d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102180:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102186:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f010218c:	c1 f8 03             	sar    $0x3,%eax
f010218f:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102192:	89 c2                	mov    %eax,%edx
f0102194:	c1 ea 0c             	shr    $0xc,%edx
f0102197:	39 d1                	cmp    %edx,%ecx
f0102199:	77 12                	ja     f01021ad <mem_init+0xf93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010219b:	50                   	push   %eax
f010219c:	68 24 5e 10 f0       	push   $0xf0105e24
f01021a1:	6a 58                	push   $0x58
f01021a3:	68 71 6c 10 f0       	push   $0xf0106c71
f01021a8:	e8 93 de ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f01021ad:	83 ec 04             	sub    $0x4,%esp
f01021b0:	68 00 10 00 00       	push   $0x1000
f01021b5:	68 ff 00 00 00       	push   $0xff
f01021ba:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01021bf:	50                   	push   %eax
f01021c0:	e8 90 2f 00 00       	call   f0105155 <memset>
	page_free(pp0);
f01021c5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01021c8:	89 3c 24             	mov    %edi,(%esp)
f01021cb:	e8 1a ed ff ff       	call   f0100eea <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01021d0:	83 c4 0c             	add    $0xc,%esp
f01021d3:	6a 01                	push   $0x1
f01021d5:	6a 00                	push   $0x0
f01021d7:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f01021dd:	e8 a2 ed ff ff       	call   f0100f84 <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021e2:	89 fa                	mov    %edi,%edx
f01021e4:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f01021ea:	c1 fa 03             	sar    $0x3,%edx
f01021ed:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021f0:	89 d0                	mov    %edx,%eax
f01021f2:	c1 e8 0c             	shr    $0xc,%eax
f01021f5:	83 c4 10             	add    $0x10,%esp
f01021f8:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01021fe:	72 12                	jb     f0102212 <mem_init+0xff8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102200:	52                   	push   %edx
f0102201:	68 24 5e 10 f0       	push   $0xf0105e24
f0102206:	6a 58                	push   $0x58
f0102208:	68 71 6c 10 f0       	push   $0xf0106c71
f010220d:	e8 2e de ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0102212:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f0102218:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f010221b:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102221:	f6 00 01             	testb  $0x1,(%eax)
f0102224:	74 19                	je     f010223f <mem_init+0x1025>
f0102226:	68 34 6f 10 f0       	push   $0xf0106f34
f010222b:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102230:	68 40 04 00 00       	push   $0x440
f0102235:	68 65 6c 10 f0       	push   $0xf0106c65
f010223a:	e8 01 de ff ff       	call   f0100040 <_panic>
f010223f:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102242:	39 c2                	cmp    %eax,%edx
f0102244:	75 db                	jne    f0102221 <mem_init+0x1007>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102246:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f010224b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102251:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102254:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f010225a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010225d:	89 0d 40 12 21 f0    	mov    %ecx,0xf0211240

	// free the pages we took
	page_free(pp0);
f0102263:	83 ec 0c             	sub    $0xc,%esp
f0102266:	50                   	push   %eax
f0102267:	e8 7e ec ff ff       	call   f0100eea <page_free>
	page_free(pp1);
f010226c:	89 1c 24             	mov    %ebx,(%esp)
f010226f:	e8 76 ec ff ff       	call   f0100eea <page_free>
	page_free(pp2);
f0102274:	89 34 24             	mov    %esi,(%esp)
f0102277:	e8 6e ec ff ff       	call   f0100eea <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f010227c:	83 c4 08             	add    $0x8,%esp
f010227f:	68 01 10 00 00       	push   $0x1001
f0102284:	6a 00                	push   $0x0
f0102286:	e8 2b ef ff ff       	call   f01011b6 <mmio_map_region>
f010228b:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f010228d:	83 c4 08             	add    $0x8,%esp
f0102290:	68 00 10 00 00       	push   $0x1000
f0102295:	6a 00                	push   $0x0
f0102297:	e8 1a ef ff ff       	call   f01011b6 <mmio_map_region>
f010229c:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f010229e:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f01022a4:	83 c4 10             	add    $0x10,%esp
f01022a7:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01022ad:	76 07                	jbe    f01022b6 <mem_init+0x109c>
f01022af:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f01022b4:	76 19                	jbe    f01022cf <mem_init+0x10b5>
f01022b6:	68 e0 68 10 f0       	push   $0xf01068e0
f01022bb:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01022c0:	68 50 04 00 00       	push   $0x450
f01022c5:	68 65 6c 10 f0       	push   $0xf0106c65
f01022ca:	e8 71 dd ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f01022cf:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f01022d5:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01022db:	77 08                	ja     f01022e5 <mem_init+0x10cb>
f01022dd:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01022e3:	77 19                	ja     f01022fe <mem_init+0x10e4>
f01022e5:	68 08 69 10 f0       	push   $0xf0106908
f01022ea:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01022ef:	68 51 04 00 00       	push   $0x451
f01022f4:	68 65 6c 10 f0       	push   $0xf0106c65
f01022f9:	e8 42 dd ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01022fe:	89 da                	mov    %ebx,%edx
f0102300:	09 f2                	or     %esi,%edx
f0102302:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f0102308:	74 19                	je     f0102323 <mem_init+0x1109>
f010230a:	68 30 69 10 f0       	push   $0xf0106930
f010230f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102314:	68 53 04 00 00       	push   $0x453
f0102319:	68 65 6c 10 f0       	push   $0xf0106c65
f010231e:	e8 1d dd ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f0102323:	39 c6                	cmp    %eax,%esi
f0102325:	73 19                	jae    f0102340 <mem_init+0x1126>
f0102327:	68 4b 6f 10 f0       	push   $0xf0106f4b
f010232c:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102331:	68 55 04 00 00       	push   $0x455
f0102336:	68 65 6c 10 f0       	push   $0xf0106c65
f010233b:	e8 00 dd ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102340:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi
f0102346:	89 da                	mov    %ebx,%edx
f0102348:	89 f8                	mov    %edi,%eax
f010234a:	e8 28 e7 ff ff       	call   f0100a77 <check_va2pa>
f010234f:	85 c0                	test   %eax,%eax
f0102351:	74 19                	je     f010236c <mem_init+0x1152>
f0102353:	68 58 69 10 f0       	push   $0xf0106958
f0102358:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010235d:	68 57 04 00 00       	push   $0x457
f0102362:	68 65 6c 10 f0       	push   $0xf0106c65
f0102367:	e8 d4 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f010236c:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f0102372:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102375:	89 c2                	mov    %eax,%edx
f0102377:	89 f8                	mov    %edi,%eax
f0102379:	e8 f9 e6 ff ff       	call   f0100a77 <check_va2pa>
f010237e:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102383:	74 19                	je     f010239e <mem_init+0x1184>
f0102385:	68 7c 69 10 f0       	push   $0xf010697c
f010238a:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010238f:	68 58 04 00 00       	push   $0x458
f0102394:	68 65 6c 10 f0       	push   $0xf0106c65
f0102399:	e8 a2 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f010239e:	89 f2                	mov    %esi,%edx
f01023a0:	89 f8                	mov    %edi,%eax
f01023a2:	e8 d0 e6 ff ff       	call   f0100a77 <check_va2pa>
f01023a7:	85 c0                	test   %eax,%eax
f01023a9:	74 19                	je     f01023c4 <mem_init+0x11aa>
f01023ab:	68 ac 69 10 f0       	push   $0xf01069ac
f01023b0:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01023b5:	68 59 04 00 00       	push   $0x459
f01023ba:	68 65 6c 10 f0       	push   $0xf0106c65
f01023bf:	e8 7c dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f01023c4:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f01023ca:	89 f8                	mov    %edi,%eax
f01023cc:	e8 a6 e6 ff ff       	call   f0100a77 <check_va2pa>
f01023d1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01023d4:	74 19                	je     f01023ef <mem_init+0x11d5>
f01023d6:	68 d0 69 10 f0       	push   $0xf01069d0
f01023db:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01023e0:	68 5a 04 00 00       	push   $0x45a
f01023e5:	68 65 6c 10 f0       	push   $0xf0106c65
f01023ea:	e8 51 dc ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01023ef:	83 ec 04             	sub    $0x4,%esp
f01023f2:	6a 00                	push   $0x0
f01023f4:	53                   	push   %ebx
f01023f5:	57                   	push   %edi
f01023f6:	e8 89 eb ff ff       	call   f0100f84 <pgdir_walk>
f01023fb:	83 c4 10             	add    $0x10,%esp
f01023fe:	f6 00 1a             	testb  $0x1a,(%eax)
f0102401:	75 19                	jne    f010241c <mem_init+0x1202>
f0102403:	68 fc 69 10 f0       	push   $0xf01069fc
f0102408:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010240d:	68 5c 04 00 00       	push   $0x45c
f0102412:	68 65 6c 10 f0       	push   $0xf0106c65
f0102417:	e8 24 dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f010241c:	83 ec 04             	sub    $0x4,%esp
f010241f:	6a 00                	push   $0x0
f0102421:	53                   	push   %ebx
f0102422:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102428:	e8 57 eb ff ff       	call   f0100f84 <pgdir_walk>
f010242d:	8b 00                	mov    (%eax),%eax
f010242f:	83 c4 10             	add    $0x10,%esp
f0102432:	83 e0 04             	and    $0x4,%eax
f0102435:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102438:	74 19                	je     f0102453 <mem_init+0x1239>
f010243a:	68 40 6a 10 f0       	push   $0xf0106a40
f010243f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102444:	68 5d 04 00 00       	push   $0x45d
f0102449:	68 65 6c 10 f0       	push   $0xf0106c65
f010244e:	e8 ed db ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102453:	83 ec 04             	sub    $0x4,%esp
f0102456:	6a 00                	push   $0x0
f0102458:	53                   	push   %ebx
f0102459:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010245f:	e8 20 eb ff ff       	call   f0100f84 <pgdir_walk>
f0102464:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f010246a:	83 c4 0c             	add    $0xc,%esp
f010246d:	6a 00                	push   $0x0
f010246f:	ff 75 d4             	pushl  -0x2c(%ebp)
f0102472:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102478:	e8 07 eb ff ff       	call   f0100f84 <pgdir_walk>
f010247d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102483:	83 c4 0c             	add    $0xc,%esp
f0102486:	6a 00                	push   $0x0
f0102488:	56                   	push   %esi
f0102489:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f010248f:	e8 f0 ea ff ff       	call   f0100f84 <pgdir_walk>
f0102494:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f010249a:	c7 04 24 5d 6f 10 f0 	movl   $0xf0106f5d,(%esp)
f01024a1:	e8 ce 10 00 00       	call   f0103574 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	// 把pages数组映射到线性地址UPAGES
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f01024a6:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024ab:	83 c4 10             	add    $0x10,%esp
f01024ae:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024b3:	77 15                	ja     f01024ca <mem_init+0x12b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024b5:	50                   	push   %eax
f01024b6:	68 48 5e 10 f0       	push   $0xf0105e48
f01024bb:	68 d0 00 00 00       	push   $0xd0
f01024c0:	68 65 6c 10 f0       	push   $0xf0106c65
f01024c5:	e8 76 db ff ff       	call   f0100040 <_panic>
f01024ca:	83 ec 08             	sub    $0x8,%esp
f01024cd:	6a 04                	push   $0x4
f01024cf:	05 00 00 00 10       	add    $0x10000000,%eax
f01024d4:	50                   	push   %eax
f01024d5:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01024da:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01024df:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01024e4:	e8 2e eb ff ff       	call   f0101017 <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	// 将envs映射到虚拟空间UENVS处
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01024e9:	a1 48 12 21 f0       	mov    0xf0211248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024ee:	83 c4 10             	add    $0x10,%esp
f01024f1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024f6:	77 15                	ja     f010250d <mem_init+0x12f3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024f8:	50                   	push   %eax
f01024f9:	68 48 5e 10 f0       	push   $0xf0105e48
f01024fe:	68 da 00 00 00       	push   $0xda
f0102503:	68 65 6c 10 f0       	push   $0xf0106c65
f0102508:	e8 33 db ff ff       	call   f0100040 <_panic>
f010250d:	83 ec 08             	sub    $0x8,%esp
f0102510:	6a 04                	push   $0x4
f0102512:	05 00 00 00 10       	add    $0x10000000,%eax
f0102517:	50                   	push   %eax
f0102518:	b9 00 00 40 00       	mov    $0x400000,%ecx
f010251d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f0102522:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102527:	e8 eb ea ff ff       	call   f0101017 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010252c:	83 c4 10             	add    $0x10,%esp
f010252f:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f0102534:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102539:	77 15                	ja     f0102550 <mem_init+0x1336>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010253b:	50                   	push   %eax
f010253c:	68 48 5e 10 f0       	push   $0xf0105e48
f0102541:	68 e9 00 00 00       	push   $0xe9
f0102546:	68 65 6c 10 f0       	push   $0xf0106c65
f010254b:	e8 f0 da ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// 把由bootstack变量所标记的物理地址范围映射给内核的堆栈
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102550:	83 ec 08             	sub    $0x8,%esp
f0102553:	6a 02                	push   $0x2
f0102555:	68 00 50 11 00       	push   $0x115000
f010255a:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010255f:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0102564:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102569:	e8 a9 ea ff ff       	call   f0101017 <boot_map_region>
	// Your code goes here:
	//？？？？？
	// n = (uint32_t)(-1) - KERNBASE + 1;
	// 2^32 - 15*16^7 = 1*16^7 = 0x10000000
	// 将整个物理内存映射到虚拟地址空间KERNBASE
	boot_map_region(kern_pgdir, KERNBASE, 0x10000000, 0, PTE_W | PTE_P);
f010256e:	83 c4 08             	add    $0x8,%esp
f0102571:	6a 03                	push   $0x3
f0102573:	6a 00                	push   $0x0
f0102575:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f010257a:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010257f:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f0102584:	e8 8e ea ff ff       	call   f0101017 <boot_map_region>
f0102589:	c7 45 c4 00 30 21 f0 	movl   $0xf0213000,-0x3c(%ebp)
f0102590:	83 c4 10             	add    $0x10,%esp
f0102593:	bb 00 30 21 f0       	mov    $0xf0213000,%ebx
f0102598:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010259d:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f01025a3:	77 15                	ja     f01025ba <mem_init+0x13a0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025a5:	53                   	push   %ebx
f01025a6:	68 48 5e 10 f0       	push   $0xf0105e48
f01025ab:	68 30 01 00 00       	push   $0x130
f01025b0:	68 65 6c 10 f0       	push   $0xf0106c65
f01025b5:	e8 86 da ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	// KSTKGAP -- 保护页
	int i;
	for (i = 0; i < NCPU; i++) {
		intptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, 
f01025ba:	83 ec 08             	sub    $0x8,%esp
f01025bd:	6a 03                	push   $0x3
f01025bf:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f01025c5:	50                   	push   %eax
f01025c6:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01025cb:	89 f2                	mov    %esi,%edx
f01025cd:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
f01025d2:	e8 40 ea ff ff       	call   f0101017 <boot_map_region>
f01025d7:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01025dd:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	// KSTKGAP -- 保护页
	int i;
	for (i = 0; i < NCPU; i++) {
f01025e3:	83 c4 10             	add    $0x10,%esp
f01025e6:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f01025eb:	39 d8                	cmp    %ebx,%eax
f01025ed:	75 ae                	jne    f010259d <mem_init+0x1383>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01025ef:	8b 3d 8c 1e 21 f0    	mov    0xf0211e8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01025f5:	a1 88 1e 21 f0       	mov    0xf0211e88,%eax
f01025fa:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01025fd:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f0102604:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102609:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010260c:	8b 35 90 1e 21 f0    	mov    0xf0211e90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102612:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102615:	bb 00 00 00 00       	mov    $0x0,%ebx
f010261a:	eb 55                	jmp    f0102671 <mem_init+0x1457>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010261c:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f0102622:	89 f8                	mov    %edi,%eax
f0102624:	e8 4e e4 ff ff       	call   f0100a77 <check_va2pa>
f0102629:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f0102630:	77 15                	ja     f0102647 <mem_init+0x142d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102632:	56                   	push   %esi
f0102633:	68 48 5e 10 f0       	push   $0xf0105e48
f0102638:	68 75 03 00 00       	push   $0x375
f010263d:	68 65 6c 10 f0       	push   $0xf0106c65
f0102642:	e8 f9 d9 ff ff       	call   f0100040 <_panic>
f0102647:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f010264e:	39 c2                	cmp    %eax,%edx
f0102650:	74 19                	je     f010266b <mem_init+0x1451>
f0102652:	68 74 6a 10 f0       	push   $0xf0106a74
f0102657:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010265c:	68 75 03 00 00       	push   $0x375
f0102661:	68 65 6c 10 f0       	push   $0xf0106c65
f0102666:	e8 d5 d9 ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010266b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102671:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0102674:	77 a6                	ja     f010261c <mem_init+0x1402>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f0102676:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010267c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010267f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f0102684:	89 da                	mov    %ebx,%edx
f0102686:	89 f8                	mov    %edi,%eax
f0102688:	e8 ea e3 ff ff       	call   f0100a77 <check_va2pa>
f010268d:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f0102694:	77 15                	ja     f01026ab <mem_init+0x1491>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102696:	56                   	push   %esi
f0102697:	68 48 5e 10 f0       	push   $0xf0105e48
f010269c:	68 7a 03 00 00       	push   $0x37a
f01026a1:	68 65 6c 10 f0       	push   $0xf0106c65
f01026a6:	e8 95 d9 ff ff       	call   f0100040 <_panic>
f01026ab:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f01026b2:	39 d0                	cmp    %edx,%eax
f01026b4:	74 19                	je     f01026cf <mem_init+0x14b5>
f01026b6:	68 a8 6a 10 f0       	push   $0xf0106aa8
f01026bb:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01026c0:	68 7a 03 00 00       	push   $0x37a
f01026c5:	68 65 6c 10 f0       	push   $0xf0106c65
f01026ca:	e8 71 d9 ff ff       	call   f0100040 <_panic>
f01026cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01026d5:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01026db:	75 a7                	jne    f0102684 <mem_init+0x146a>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026dd:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01026e0:	c1 e6 0c             	shl    $0xc,%esi
f01026e3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026e8:	eb 30                	jmp    f010271a <mem_init+0x1500>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01026ea:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01026f0:	89 f8                	mov    %edi,%eax
f01026f2:	e8 80 e3 ff ff       	call   f0100a77 <check_va2pa>
f01026f7:	39 c3                	cmp    %eax,%ebx
f01026f9:	74 19                	je     f0102714 <mem_init+0x14fa>
f01026fb:	68 dc 6a 10 f0       	push   $0xf0106adc
f0102700:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102705:	68 7e 03 00 00       	push   $0x37e
f010270a:	68 65 6c 10 f0       	push   $0xf0106c65
f010270f:	e8 2c d9 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102714:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010271a:	39 f3                	cmp    %esi,%ebx
f010271c:	72 cc                	jb     f01026ea <mem_init+0x14d0>
f010271e:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f0102723:	89 75 cc             	mov    %esi,-0x34(%ebp)
f0102726:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0102729:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010272c:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f0102732:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0102735:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0102737:	8b 45 c8             	mov    -0x38(%ebp),%eax
f010273a:	05 00 80 00 20       	add    $0x20008000,%eax
f010273f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102742:	89 da                	mov    %ebx,%edx
f0102744:	89 f8                	mov    %edi,%eax
f0102746:	e8 2c e3 ff ff       	call   f0100a77 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010274b:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102751:	77 15                	ja     f0102768 <mem_init+0x154e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102753:	56                   	push   %esi
f0102754:	68 48 5e 10 f0       	push   $0xf0105e48
f0102759:	68 86 03 00 00       	push   $0x386
f010275e:	68 65 6c 10 f0       	push   $0xf0106c65
f0102763:	e8 d8 d8 ff ff       	call   f0100040 <_panic>
f0102768:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010276b:	8d 94 0b 00 30 21 f0 	lea    -0xfded000(%ebx,%ecx,1),%edx
f0102772:	39 d0                	cmp    %edx,%eax
f0102774:	74 19                	je     f010278f <mem_init+0x1575>
f0102776:	68 04 6b 10 f0       	push   $0xf0106b04
f010277b:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102780:	68 86 03 00 00       	push   $0x386
f0102785:	68 65 6c 10 f0       	push   $0xf0106c65
f010278a:	e8 b1 d8 ff ff       	call   f0100040 <_panic>
f010278f:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0102795:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102798:	75 a8                	jne    f0102742 <mem_init+0x1528>
f010279a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010279d:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f01027a3:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01027a6:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f01027a8:	89 da                	mov    %ebx,%edx
f01027aa:	89 f8                	mov    %edi,%eax
f01027ac:	e8 c6 e2 ff ff       	call   f0100a77 <check_va2pa>
f01027b1:	83 f8 ff             	cmp    $0xffffffff,%eax
f01027b4:	74 19                	je     f01027cf <mem_init+0x15b5>
f01027b6:	68 4c 6b 10 f0       	push   $0xf0106b4c
f01027bb:	68 8b 6c 10 f0       	push   $0xf0106c8b
f01027c0:	68 88 03 00 00       	push   $0x388
f01027c5:	68 65 6c 10 f0       	push   $0xf0106c65
f01027ca:	e8 71 d8 ff ff       	call   f0100040 <_panic>
f01027cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01027d5:	39 f3                	cmp    %esi,%ebx
f01027d7:	75 cf                	jne    f01027a8 <mem_init+0x158e>
f01027d9:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01027dc:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01027e3:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01027ea:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01027f0:	b8 00 30 25 f0       	mov    $0xf0253000,%eax
f01027f5:	39 f0                	cmp    %esi,%eax
f01027f7:	0f 85 2c ff ff ff    	jne    f0102729 <mem_init+0x150f>
f01027fd:	b8 00 00 00 00       	mov    $0x0,%eax
f0102802:	eb 2a                	jmp    f010282e <mem_init+0x1614>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0102804:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f010280a:	83 fa 04             	cmp    $0x4,%edx
f010280d:	77 1f                	ja     f010282e <mem_init+0x1614>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010280f:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f0102813:	75 7e                	jne    f0102893 <mem_init+0x1679>
f0102815:	68 76 6f 10 f0       	push   $0xf0106f76
f010281a:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010281f:	68 93 03 00 00       	push   $0x393
f0102824:	68 65 6c 10 f0       	push   $0xf0106c65
f0102829:	e8 12 d8 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010282e:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0102833:	76 3f                	jbe    f0102874 <mem_init+0x165a>
				assert(pgdir[i] & PTE_P);
f0102835:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102838:	f6 c2 01             	test   $0x1,%dl
f010283b:	75 19                	jne    f0102856 <mem_init+0x163c>
f010283d:	68 76 6f 10 f0       	push   $0xf0106f76
f0102842:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102847:	68 97 03 00 00       	push   $0x397
f010284c:	68 65 6c 10 f0       	push   $0xf0106c65
f0102851:	e8 ea d7 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f0102856:	f6 c2 02             	test   $0x2,%dl
f0102859:	75 38                	jne    f0102893 <mem_init+0x1679>
f010285b:	68 87 6f 10 f0       	push   $0xf0106f87
f0102860:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102865:	68 98 03 00 00       	push   $0x398
f010286a:	68 65 6c 10 f0       	push   $0xf0106c65
f010286f:	e8 cc d7 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102874:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102878:	74 19                	je     f0102893 <mem_init+0x1679>
f010287a:	68 98 6f 10 f0       	push   $0xf0106f98
f010287f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102884:	68 9a 03 00 00       	push   $0x39a
f0102889:	68 65 6c 10 f0       	push   $0xf0106c65
f010288e:	e8 ad d7 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102893:	83 c0 01             	add    $0x1,%eax
f0102896:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010289b:	0f 86 63 ff ff ff    	jbe    f0102804 <mem_init+0x15ea>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01028a1:	83 ec 0c             	sub    $0xc,%esp
f01028a4:	68 70 6b 10 f0       	push   $0xf0106b70
f01028a9:	e8 c6 0c 00 00       	call   f0103574 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01028ae:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01028b3:	83 c4 10             	add    $0x10,%esp
f01028b6:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01028bb:	77 15                	ja     f01028d2 <mem_init+0x16b8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01028bd:	50                   	push   %eax
f01028be:	68 48 5e 10 f0       	push   $0xf0105e48
f01028c3:	68 06 01 00 00       	push   $0x106
f01028c8:	68 65 6c 10 f0       	push   $0xf0106c65
f01028cd:	e8 6e d7 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01028d2:	05 00 00 00 10       	add    $0x10000000,%eax
f01028d7:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01028da:	b8 00 00 00 00       	mov    $0x0,%eax
f01028df:	e8 f7 e1 ff ff       	call   f0100adb <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01028e4:	0f 20 c0             	mov    %cr0,%eax
f01028e7:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01028ea:	0d 23 00 05 80       	or     $0x80050023,%eax
f01028ef:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01028f2:	83 ec 0c             	sub    $0xc,%esp
f01028f5:	6a 00                	push   $0x0
f01028f7:	e8 7e e5 ff ff       	call   f0100e7a <page_alloc>
f01028fc:	89 c3                	mov    %eax,%ebx
f01028fe:	83 c4 10             	add    $0x10,%esp
f0102901:	85 c0                	test   %eax,%eax
f0102903:	75 19                	jne    f010291e <mem_init+0x1704>
f0102905:	68 82 6d 10 f0       	push   $0xf0106d82
f010290a:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010290f:	68 72 04 00 00       	push   $0x472
f0102914:	68 65 6c 10 f0       	push   $0xf0106c65
f0102919:	e8 22 d7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010291e:	83 ec 0c             	sub    $0xc,%esp
f0102921:	6a 00                	push   $0x0
f0102923:	e8 52 e5 ff ff       	call   f0100e7a <page_alloc>
f0102928:	89 c7                	mov    %eax,%edi
f010292a:	83 c4 10             	add    $0x10,%esp
f010292d:	85 c0                	test   %eax,%eax
f010292f:	75 19                	jne    f010294a <mem_init+0x1730>
f0102931:	68 98 6d 10 f0       	push   $0xf0106d98
f0102936:	68 8b 6c 10 f0       	push   $0xf0106c8b
f010293b:	68 73 04 00 00       	push   $0x473
f0102940:	68 65 6c 10 f0       	push   $0xf0106c65
f0102945:	e8 f6 d6 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010294a:	83 ec 0c             	sub    $0xc,%esp
f010294d:	6a 00                	push   $0x0
f010294f:	e8 26 e5 ff ff       	call   f0100e7a <page_alloc>
f0102954:	89 c6                	mov    %eax,%esi
f0102956:	83 c4 10             	add    $0x10,%esp
f0102959:	85 c0                	test   %eax,%eax
f010295b:	75 19                	jne    f0102976 <mem_init+0x175c>
f010295d:	68 ae 6d 10 f0       	push   $0xf0106dae
f0102962:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102967:	68 74 04 00 00       	push   $0x474
f010296c:	68 65 6c 10 f0       	push   $0xf0106c65
f0102971:	e8 ca d6 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f0102976:	83 ec 0c             	sub    $0xc,%esp
f0102979:	53                   	push   %ebx
f010297a:	e8 6b e5 ff ff       	call   f0100eea <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010297f:	89 f8                	mov    %edi,%eax
f0102981:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102987:	c1 f8 03             	sar    $0x3,%eax
f010298a:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010298d:	89 c2                	mov    %eax,%edx
f010298f:	c1 ea 0c             	shr    $0xc,%edx
f0102992:	83 c4 10             	add    $0x10,%esp
f0102995:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f010299b:	72 12                	jb     f01029af <mem_init+0x1795>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010299d:	50                   	push   %eax
f010299e:	68 24 5e 10 f0       	push   $0xf0105e24
f01029a3:	6a 58                	push   $0x58
f01029a5:	68 71 6c 10 f0       	push   $0xf0106c71
f01029aa:	e8 91 d6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01029af:	83 ec 04             	sub    $0x4,%esp
f01029b2:	68 00 10 00 00       	push   $0x1000
f01029b7:	6a 01                	push   $0x1
f01029b9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029be:	50                   	push   %eax
f01029bf:	e8 91 27 00 00       	call   f0105155 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01029c4:	89 f0                	mov    %esi,%eax
f01029c6:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f01029cc:	c1 f8 03             	sar    $0x3,%eax
f01029cf:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01029d2:	89 c2                	mov    %eax,%edx
f01029d4:	c1 ea 0c             	shr    $0xc,%edx
f01029d7:	83 c4 10             	add    $0x10,%esp
f01029da:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f01029e0:	72 12                	jb     f01029f4 <mem_init+0x17da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029e2:	50                   	push   %eax
f01029e3:	68 24 5e 10 f0       	push   $0xf0105e24
f01029e8:	6a 58                	push   $0x58
f01029ea:	68 71 6c 10 f0       	push   $0xf0106c71
f01029ef:	e8 4c d6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01029f4:	83 ec 04             	sub    $0x4,%esp
f01029f7:	68 00 10 00 00       	push   $0x1000
f01029fc:	6a 02                	push   $0x2
f01029fe:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102a03:	50                   	push   %eax
f0102a04:	e8 4c 27 00 00       	call   f0105155 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f0102a09:	6a 02                	push   $0x2
f0102a0b:	68 00 10 00 00       	push   $0x1000
f0102a10:	57                   	push   %edi
f0102a11:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102a17:	e8 34 e7 ff ff       	call   f0101150 <page_insert>
	assert(pp1->pp_ref == 1);
f0102a1c:	83 c4 20             	add    $0x20,%esp
f0102a1f:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102a24:	74 19                	je     f0102a3f <mem_init+0x1825>
f0102a26:	68 7f 6e 10 f0       	push   $0xf0106e7f
f0102a2b:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102a30:	68 79 04 00 00       	push   $0x479
f0102a35:	68 65 6c 10 f0       	push   $0xf0106c65
f0102a3a:	e8 01 d6 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a3f:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102a46:	01 01 01 
f0102a49:	74 19                	je     f0102a64 <mem_init+0x184a>
f0102a4b:	68 90 6b 10 f0       	push   $0xf0106b90
f0102a50:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102a55:	68 7a 04 00 00       	push   $0x47a
f0102a5a:	68 65 6c 10 f0       	push   $0xf0106c65
f0102a5f:	e8 dc d5 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102a64:	6a 02                	push   $0x2
f0102a66:	68 00 10 00 00       	push   $0x1000
f0102a6b:	56                   	push   %esi
f0102a6c:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102a72:	e8 d9 e6 ff ff       	call   f0101150 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a77:	83 c4 10             	add    $0x10,%esp
f0102a7a:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102a81:	02 02 02 
f0102a84:	74 19                	je     f0102a9f <mem_init+0x1885>
f0102a86:	68 b4 6b 10 f0       	push   $0xf0106bb4
f0102a8b:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102a90:	68 7c 04 00 00       	push   $0x47c
f0102a95:	68 65 6c 10 f0       	push   $0xf0106c65
f0102a9a:	e8 a1 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102a9f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102aa4:	74 19                	je     f0102abf <mem_init+0x18a5>
f0102aa6:	68 a1 6e 10 f0       	push   $0xf0106ea1
f0102aab:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102ab0:	68 7d 04 00 00       	push   $0x47d
f0102ab5:	68 65 6c 10 f0       	push   $0xf0106c65
f0102aba:	e8 81 d5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102abf:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102ac4:	74 19                	je     f0102adf <mem_init+0x18c5>
f0102ac6:	68 0b 6f 10 f0       	push   $0xf0106f0b
f0102acb:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102ad0:	68 7e 04 00 00       	push   $0x47e
f0102ad5:	68 65 6c 10 f0       	push   $0xf0106c65
f0102ada:	e8 61 d5 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102adf:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102ae6:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ae9:	89 f0                	mov    %esi,%eax
f0102aeb:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102af1:	c1 f8 03             	sar    $0x3,%eax
f0102af4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102af7:	89 c2                	mov    %eax,%edx
f0102af9:	c1 ea 0c             	shr    $0xc,%edx
f0102afc:	3b 15 88 1e 21 f0    	cmp    0xf0211e88,%edx
f0102b02:	72 12                	jb     f0102b16 <mem_init+0x18fc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102b04:	50                   	push   %eax
f0102b05:	68 24 5e 10 f0       	push   $0xf0105e24
f0102b0a:	6a 58                	push   $0x58
f0102b0c:	68 71 6c 10 f0       	push   $0xf0106c71
f0102b11:	e8 2a d5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102b16:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102b1d:	03 03 03 
f0102b20:	74 19                	je     f0102b3b <mem_init+0x1921>
f0102b22:	68 d8 6b 10 f0       	push   $0xf0106bd8
f0102b27:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102b2c:	68 80 04 00 00       	push   $0x480
f0102b31:	68 65 6c 10 f0       	push   $0xf0106c65
f0102b36:	e8 05 d5 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b3b:	83 ec 08             	sub    $0x8,%esp
f0102b3e:	68 00 10 00 00       	push   $0x1000
f0102b43:	ff 35 8c 1e 21 f0    	pushl  0xf0211e8c
f0102b49:	e8 b2 e5 ff ff       	call   f0101100 <page_remove>
	assert(pp2->pp_ref == 0);
f0102b4e:	83 c4 10             	add    $0x10,%esp
f0102b51:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102b56:	74 19                	je     f0102b71 <mem_init+0x1957>
f0102b58:	68 d9 6e 10 f0       	push   $0xf0106ed9
f0102b5d:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102b62:	68 82 04 00 00       	push   $0x482
f0102b67:	68 65 6c 10 f0       	push   $0xf0106c65
f0102b6c:	e8 cf d4 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b71:	8b 0d 8c 1e 21 f0    	mov    0xf0211e8c,%ecx
f0102b77:	8b 11                	mov    (%ecx),%edx
f0102b79:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102b7f:	89 d8                	mov    %ebx,%eax
f0102b81:	2b 05 90 1e 21 f0    	sub    0xf0211e90,%eax
f0102b87:	c1 f8 03             	sar    $0x3,%eax
f0102b8a:	c1 e0 0c             	shl    $0xc,%eax
f0102b8d:	39 c2                	cmp    %eax,%edx
f0102b8f:	74 19                	je     f0102baa <mem_init+0x1990>
f0102b91:	68 60 65 10 f0       	push   $0xf0106560
f0102b96:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102b9b:	68 85 04 00 00       	push   $0x485
f0102ba0:	68 65 6c 10 f0       	push   $0xf0106c65
f0102ba5:	e8 96 d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102baa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102bb0:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102bb5:	74 19                	je     f0102bd0 <mem_init+0x19b6>
f0102bb7:	68 90 6e 10 f0       	push   $0xf0106e90
f0102bbc:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0102bc1:	68 87 04 00 00       	push   $0x487
f0102bc6:	68 65 6c 10 f0       	push   $0xf0106c65
f0102bcb:	e8 70 d4 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102bd0:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102bd6:	83 ec 0c             	sub    $0xc,%esp
f0102bd9:	53                   	push   %ebx
f0102bda:	e8 0b e3 ff ff       	call   f0100eea <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102bdf:	c7 04 24 04 6c 10 f0 	movl   $0xf0106c04,(%esp)
f0102be6:	e8 89 09 00 00       	call   f0103574 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102beb:	83 c4 10             	add    $0x10,%esp
f0102bee:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bf1:	5b                   	pop    %ebx
f0102bf2:	5e                   	pop    %esi
f0102bf3:	5f                   	pop    %edi
f0102bf4:	5d                   	pop    %ebp
f0102bf5:	c3                   	ret    

f0102bf6 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
// ?????
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102bf6:	55                   	push   %ebp
f0102bf7:	89 e5                	mov    %esp,%ebp
f0102bf9:	57                   	push   %edi
f0102bfa:	56                   	push   %esi
f0102bfb:	53                   	push   %ebx
f0102bfc:	83 ec 1c             	sub    $0x1c,%esp
f0102bff:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102c02:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	char * end = NULL;
	char * start = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE); 
f0102c05:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c08:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102c0d:	89 c3                	mov    %eax,%ebx
f0102c0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
	end = ROUNDUP((char *)(va + len), PGSIZE);
f0102c12:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c15:	03 45 10             	add    0x10(%ebp),%eax
f0102c18:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102c1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102c22:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t *cur = NULL;

	for(; start < end; start += PGSIZE) {
f0102c25:	eb 4e                	jmp    f0102c75 <user_mem_check+0x7f>
		cur = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102c27:	83 ec 04             	sub    $0x4,%esp
f0102c2a:	6a 00                	push   $0x0
f0102c2c:	53                   	push   %ebx
f0102c2d:	ff 77 60             	pushl  0x60(%edi)
f0102c30:	e8 4f e3 ff ff       	call   f0100f84 <pgdir_walk>
		if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
f0102c35:	89 da                	mov    %ebx,%edx
f0102c37:	83 c4 10             	add    $0x10,%esp
f0102c3a:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102c40:	77 0c                	ja     f0102c4e <user_mem_check+0x58>
f0102c42:	85 c0                	test   %eax,%eax
f0102c44:	74 08                	je     f0102c4e <user_mem_check+0x58>
f0102c46:	89 f1                	mov    %esi,%ecx
f0102c48:	23 08                	and    (%eax),%ecx
f0102c4a:	39 ce                	cmp    %ecx,%esi
f0102c4c:	74 21                	je     f0102c6f <user_mem_check+0x79>
			  if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f0102c4e:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102c51:	75 0f                	jne    f0102c62 <user_mem_check+0x6c>
					user_mem_check_addr = (uintptr_t)va;
f0102c53:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c56:	a3 3c 12 21 f0       	mov    %eax,0xf021123c
			  }
			  else {
			  		user_mem_check_addr = (uintptr_t)start;
			  }
			  return -E_FAULT;
f0102c5b:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102c60:	eb 1d                	jmp    f0102c7f <user_mem_check+0x89>
		if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
			  if(start == ROUNDDOWN((char *)va, PGSIZE)) {
					user_mem_check_addr = (uintptr_t)va;
			  }
			  else {
			  		user_mem_check_addr = (uintptr_t)start;
f0102c62:	89 15 3c 12 21 f0    	mov    %edx,0xf021123c
			  }
			  return -E_FAULT;
f0102c68:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102c6d:	eb 10                	jmp    f0102c7f <user_mem_check+0x89>
	char * start = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE); 
	end = ROUNDUP((char *)(va + len), PGSIZE);
	pte_t *cur = NULL;

	for(; start < end; start += PGSIZE) {
f0102c6f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c75:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102c78:	72 ad                	jb     f0102c27 <user_mem_check+0x31>
			  return -E_FAULT;
		}
		
	}
		
	return 0;
f0102c7a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c82:	5b                   	pop    %ebx
f0102c83:	5e                   	pop    %esi
f0102c84:	5f                   	pop    %edi
f0102c85:	5d                   	pop    %ebp
f0102c86:	c3                   	ret    

f0102c87 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102c87:	55                   	push   %ebp
f0102c88:	89 e5                	mov    %esp,%ebp
f0102c8a:	53                   	push   %ebx
f0102c8b:	83 ec 04             	sub    $0x4,%esp
f0102c8e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102c91:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c94:	83 c8 04             	or     $0x4,%eax
f0102c97:	50                   	push   %eax
f0102c98:	ff 75 10             	pushl  0x10(%ebp)
f0102c9b:	ff 75 0c             	pushl  0xc(%ebp)
f0102c9e:	53                   	push   %ebx
f0102c9f:	e8 52 ff ff ff       	call   f0102bf6 <user_mem_check>
f0102ca4:	83 c4 10             	add    $0x10,%esp
f0102ca7:	85 c0                	test   %eax,%eax
f0102ca9:	79 21                	jns    f0102ccc <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102cab:	83 ec 04             	sub    $0x4,%esp
f0102cae:	ff 35 3c 12 21 f0    	pushl  0xf021123c
f0102cb4:	ff 73 48             	pushl  0x48(%ebx)
f0102cb7:	68 30 6c 10 f0       	push   $0xf0106c30
f0102cbc:	e8 b3 08 00 00       	call   f0103574 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102cc1:	89 1c 24             	mov    %ebx,(%esp)
f0102cc4:	e8 bb 05 00 00       	call   f0103284 <env_destroy>
f0102cc9:	83 c4 10             	add    $0x10,%esp
	}
}
f0102ccc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102ccf:	c9                   	leave  
f0102cd0:	c3                   	ret    

f0102cd1 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
// 为用户环境分配物理空间
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102cd1:	55                   	push   %ebp
f0102cd2:	89 e5                	mov    %esp,%ebp
f0102cd4:	57                   	push   %edi
f0102cd5:	56                   	push   %esi
f0102cd6:	53                   	push   %ebx
f0102cd7:	83 ec 0c             	sub    $0xc,%esp
f0102cda:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *vas, *vat;

	vas = ROUNDDOWN(va, PGSIZE);
f0102cdc:	89 d3                	mov    %edx,%ebx
f0102cde:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	vat = ROUNDUP(va + len, PGSIZE);
f0102ce4:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102ceb:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	for (; vas < vat; vas += PGSIZE) {
f0102cf1:	eb 3d                	jmp    f0102d30 <region_alloc+0x5f>
		struct PageInfo *pp = page_alloc(0);
f0102cf3:	83 ec 0c             	sub    $0xc,%esp
f0102cf6:	6a 00                	push   $0x0
f0102cf8:	e8 7d e1 ff ff       	call   f0100e7a <page_alloc>
		if (pp == NULL)
f0102cfd:	83 c4 10             	add    $0x10,%esp
f0102d00:	85 c0                	test   %eax,%eax
f0102d02:	75 17                	jne    f0102d1b <region_alloc+0x4a>
			panic("region_alloc: allocation failed.");
f0102d04:	83 ec 04             	sub    $0x4,%esp
f0102d07:	68 a8 6f 10 f0       	push   $0xf0106fa8
f0102d0c:	68 39 01 00 00       	push   $0x139
f0102d11:	68 ec 6f 10 f0       	push   $0xf0106fec
f0102d16:	e8 25 d3 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, pp, vas, PTE_U | PTE_W);
f0102d1b:	6a 06                	push   $0x6
f0102d1d:	53                   	push   %ebx
f0102d1e:	50                   	push   %eax
f0102d1f:	ff 77 60             	pushl  0x60(%edi)
f0102d22:	e8 29 e4 ff ff       	call   f0101150 <page_insert>
	void *vas, *vat;

	vas = ROUNDDOWN(va, PGSIZE);
	vat = ROUNDUP(va + len, PGSIZE);

	for (; vas < vat; vas += PGSIZE) {
f0102d27:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102d2d:	83 c4 10             	add    $0x10,%esp
f0102d30:	39 f3                	cmp    %esi,%ebx
f0102d32:	72 bf                	jb     f0102cf3 <region_alloc+0x22>
		struct PageInfo *pp = page_alloc(0);
		if (pp == NULL)
			panic("region_alloc: allocation failed.");
		page_insert(e->env_pgdir, pp, vas, PTE_U | PTE_W);
	}
}
f0102d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102d37:	5b                   	pop    %ebx
f0102d38:	5e                   	pop    %esi
f0102d39:	5f                   	pop    %edi
f0102d3a:	5d                   	pop    %ebp
f0102d3b:	c3                   	ret    

f0102d3c <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102d3c:	55                   	push   %ebp
f0102d3d:	89 e5                	mov    %esp,%ebp
f0102d3f:	56                   	push   %esi
f0102d40:	53                   	push   %ebx
f0102d41:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d44:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102d47:	85 c0                	test   %eax,%eax
f0102d49:	75 1a                	jne    f0102d65 <envid2env+0x29>
		*env_store = curenv;
f0102d4b:	e8 26 2a 00 00       	call   f0105776 <cpunum>
f0102d50:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d53:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0102d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102d5c:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102d5e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d63:	eb 70                	jmp    f0102dd5 <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102d65:	89 c3                	mov    %eax,%ebx
f0102d67:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102d6d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102d70:	03 1d 48 12 21 f0    	add    0xf0211248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102d76:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102d7a:	74 05                	je     f0102d81 <envid2env+0x45>
f0102d7c:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102d7f:	74 10                	je     f0102d91 <envid2env+0x55>
		*env_store = 0;
f0102d81:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d84:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102d8a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d8f:	eb 44                	jmp    f0102dd5 <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102d91:	84 d2                	test   %dl,%dl
f0102d93:	74 36                	je     f0102dcb <envid2env+0x8f>
f0102d95:	e8 dc 29 00 00       	call   f0105776 <cpunum>
f0102d9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d9d:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f0102da3:	74 26                	je     f0102dcb <envid2env+0x8f>
f0102da5:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102da8:	e8 c9 29 00 00       	call   f0105776 <cpunum>
f0102dad:	6b c0 74             	imul   $0x74,%eax,%eax
f0102db0:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0102db6:	3b 70 48             	cmp    0x48(%eax),%esi
f0102db9:	74 10                	je     f0102dcb <envid2env+0x8f>
		*env_store = 0;
f0102dbb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102dbe:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102dc4:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102dc9:	eb 0a                	jmp    f0102dd5 <envid2env+0x99>
	}

	*env_store = e;
f0102dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102dce:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102dd0:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102dd5:	5b                   	pop    %ebx
f0102dd6:	5e                   	pop    %esi
f0102dd7:	5d                   	pop    %ebp
f0102dd8:	c3                   	ret    

f0102dd9 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102dd9:	55                   	push   %ebp
f0102dda:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102ddc:	b8 20 f3 11 f0       	mov    $0xf011f320,%eax
f0102de1:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102de4:	b8 23 00 00 00       	mov    $0x23,%eax
f0102de9:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102deb:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102ded:	b8 10 00 00 00       	mov    $0x10,%eax
f0102df2:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102df4:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102df6:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102df8:	ea ff 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102dff
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102dff:	b8 00 00 00 00       	mov    $0x0,%eax
f0102e04:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102e07:	5d                   	pop    %ebp
f0102e08:	c3                   	ret    

f0102e09 <env_init>:
// 初始化所有的在envs数组中的 Env结构体，并把它们加入到 env_free_list中
// 与page_init()类似
// 要求所有的 Env 在 env_free_list 中的顺序，要和它在 envs 中的顺序一致
void
env_init(void)
{
f0102e09:	55                   	push   %ebp
f0102e0a:	89 e5                	mov    %esp,%ebp
f0102e0c:	56                   	push   %esi
f0102e0d:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	//从 NENV-1 到 0， 保证第一次分配的是envs[0]
	for (i = NENV-1; i >= 0; i--) {
		envs[i].env_status = ENV_FREE;
f0102e0e:	8b 35 48 12 21 f0    	mov    0xf0211248,%esi
f0102e14:	8b 15 4c 12 21 f0    	mov    0xf021124c,%edx
f0102e1a:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102e20:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102e23:	89 c1                	mov    %eax,%ecx
f0102e25:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0102e2c:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102e33:	89 50 44             	mov    %edx,0x44(%eax)
f0102e36:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs + i;
f0102e39:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	//从 NENV-1 到 0， 保证第一次分配的是envs[0]
	for (i = NENV-1; i >= 0; i--) {
f0102e3b:	39 d8                	cmp    %ebx,%eax
f0102e3d:	75 e4                	jne    f0102e23 <env_init+0x1a>
f0102e3f:	89 35 4c 12 21 f0    	mov    %esi,0xf021124c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs + i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102e45:	e8 8f ff ff ff       	call   f0102dd9 <env_init_percpu>
}
f0102e4a:	5b                   	pop    %ebx
f0102e4b:	5e                   	pop    %esi
f0102e4c:	5d                   	pop    %ebp
f0102e4d:	c3                   	ret    

f0102e4e <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102e4e:	55                   	push   %ebp
f0102e4f:	89 e5                	mov    %esp,%ebp
f0102e51:	53                   	push   %ebx
f0102e52:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102e55:	8b 1d 4c 12 21 f0    	mov    0xf021124c,%ebx
f0102e5b:	85 db                	test   %ebx,%ebx
f0102e5d:	0f 84 37 01 00 00    	je     f0102f9a <env_alloc+0x14c>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102e63:	83 ec 0c             	sub    $0xc,%esp
f0102e66:	6a 01                	push   $0x1
f0102e68:	e8 0d e0 ff ff       	call   f0100e7a <page_alloc>
f0102e6d:	83 c4 10             	add    $0x10,%esp
f0102e70:	85 c0                	test   %eax,%eax
f0102e72:	0f 84 29 01 00 00    	je     f0102fa1 <env_alloc+0x153>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e78:	89 c2                	mov    %eax,%edx
f0102e7a:	2b 15 90 1e 21 f0    	sub    0xf0211e90,%edx
f0102e80:	c1 fa 03             	sar    $0x3,%edx
f0102e83:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e86:	89 d1                	mov    %edx,%ecx
f0102e88:	c1 e9 0c             	shr    $0xc,%ecx
f0102e8b:	3b 0d 88 1e 21 f0    	cmp    0xf0211e88,%ecx
f0102e91:	72 12                	jb     f0102ea5 <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e93:	52                   	push   %edx
f0102e94:	68 24 5e 10 f0       	push   $0xf0105e24
f0102e99:	6a 58                	push   $0x58
f0102e9b:	68 71 6c 10 f0       	push   $0xf0106c71
f0102ea0:	e8 9b d1 ff ff       	call   f0100040 <_panic>
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	
	// 初始化页目录
	e->env_pgdir = (pde_t *) page2kva(p);
f0102ea5:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102eab:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f0102eae:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0102eb3:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	
	// 初始化与内核相关的页目录项
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
		e->env_pgdir[i] = kern_pgdir[i];
f0102eb8:	8b 15 8c 1e 21 f0    	mov    0xf0211e8c,%edx
f0102ebe:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102ec1:	8b 53 60             	mov    0x60(%ebx),%edx
f0102ec4:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102ec7:	83 c0 04             	add    $0x4,%eax
	// 初始化页目录
	e->env_pgdir = (pde_t *) page2kva(p);
	p->pp_ref++;
	
	// 初始化与内核相关的页目录项
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
f0102eca:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102ecf:	75 e7                	jne    f0102eb8 <env_alloc+0x6a>
	


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102ed1:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ed4:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ed9:	77 15                	ja     f0102ef0 <env_alloc+0xa2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102edb:	50                   	push   %eax
f0102edc:	68 48 5e 10 f0       	push   $0xf0105e48
f0102ee1:	68 d1 00 00 00       	push   $0xd1
f0102ee6:	68 ec 6f 10 f0       	push   $0xf0106fec
f0102eeb:	e8 50 d1 ff ff       	call   f0100040 <_panic>
f0102ef0:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102ef6:	83 ca 05             	or     $0x5,%edx
f0102ef9:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102eff:	8b 43 48             	mov    0x48(%ebx),%eax
f0102f02:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102f07:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102f0c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102f11:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102f14:	89 da                	mov    %ebx,%edx
f0102f16:	2b 15 48 12 21 f0    	sub    0xf0211248,%edx
f0102f1c:	c1 fa 02             	sar    $0x2,%edx
f0102f1f:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0102f25:	09 d0                	or     %edx,%eax
f0102f27:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102f2d:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102f30:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102f37:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102f3e:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102f45:	83 ec 04             	sub    $0x4,%esp
f0102f48:	6a 44                	push   $0x44
f0102f4a:	6a 00                	push   $0x0
f0102f4c:	53                   	push   %ebx
f0102f4d:	e8 03 22 00 00       	call   f0105155 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102f52:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102f58:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102f5e:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102f64:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102f6b:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	// 打开中断
	e->env_tf.tf_eflags |= FL_IF;
f0102f71:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0102f78:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0102f7f:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0102f83:	8b 43 44             	mov    0x44(%ebx),%eax
f0102f86:	a3 4c 12 21 f0       	mov    %eax,0xf021124c
	*newenv_store = e;
f0102f8b:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f8e:	89 18                	mov    %ebx,(%eax)

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
f0102f90:	83 c4 10             	add    $0x10,%esp
f0102f93:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f98:	eb 0c                	jmp    f0102fa6 <env_alloc+0x158>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102f9a:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102f9f:	eb 05                	jmp    f0102fa6 <env_alloc+0x158>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102fa1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	// cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102fa6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fa9:	c9                   	leave  
f0102faa:	c3                   	ret    

f0102fab <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102fab:	55                   	push   %ebp
f0102fac:	89 e5                	mov    %esp,%ebp
f0102fae:	57                   	push   %edi
f0102faf:	56                   	push   %esi
f0102fb0:	53                   	push   %ebx
f0102fb1:	83 ec 34             	sub    $0x34,%esp
f0102fb4:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int errorcode;

	if ((errorcode=env_alloc(&e, 0)) < 0)
f0102fb7:	6a 00                	push   $0x0
f0102fb9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102fbc:	50                   	push   %eax
f0102fbd:	e8 8c fe ff ff       	call   f0102e4e <env_alloc>
f0102fc2:	83 c4 10             	add    $0x10,%esp
f0102fc5:	85 c0                	test   %eax,%eax
f0102fc7:	79 15                	jns    f0102fde <env_create+0x33>
		panic("env_create: %e", errorcode);
f0102fc9:	50                   	push   %eax
f0102fca:	68 f7 6f 10 f0       	push   $0xf0106ff7
f0102fcf:	68 a8 01 00 00       	push   $0x1a8
f0102fd4:	68 ec 6f 10 f0       	push   $0xf0106fec
f0102fd9:	e8 62 d0 ff ff       	call   f0100040 <_panic>

	load_icode(e, binary);
f0102fde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102fe1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Proghdr *ph, *eph;

	ELFHDR = (struct Elf *) binary;

	//根据文件魔数是否ELF文件
	if (ELFHDR->e_magic != ELF_MAGIC)
f0102fe4:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102fea:	74 17                	je     f0103003 <env_create+0x58>
		panic("load_icode: not ELF executable.");
f0102fec:	83 ec 04             	sub    $0x4,%esp
f0102fef:	68 cc 6f 10 f0       	push   $0xf0106fcc
f0102ff4:	68 7b 01 00 00       	push   $0x17b
f0102ff9:	68 ec 6f 10 f0       	push   $0xf0106fec
f0102ffe:	e8 3d d0 ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
f0103003:	89 fb                	mov    %edi,%ebx
f0103005:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103008:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f010300c:	c1 e6 05             	shl    $0x5,%esi
f010300f:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f0103011:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103014:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103017:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010301c:	77 15                	ja     f0103033 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010301e:	50                   	push   %eax
f010301f:	68 48 5e 10 f0       	push   $0xf0105e48
f0103024:	68 80 01 00 00       	push   $0x180
f0103029:	68 ec 6f 10 f0       	push   $0xf0106fec
f010302e:	e8 0d d0 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103033:	05 00 00 00 10       	add    $0x10000000,%eax
f0103038:	0f 22 d8             	mov    %eax,%cr3
f010303b:	eb 3d                	jmp    f010307a <env_create+0xcf>

	//program header记录着需要加载到内存里的部分
	for (; ph < eph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
f010303d:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103040:	75 35                	jne    f0103077 <env_create+0xcc>
			region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f0103042:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103045:	8b 53 08             	mov    0x8(%ebx),%edx
f0103048:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010304b:	e8 81 fc ff ff       	call   f0102cd1 <region_alloc>
			memset((void *) ph->p_va, 0, ph->p_memsz);
f0103050:	83 ec 04             	sub    $0x4,%esp
f0103053:	ff 73 14             	pushl  0x14(%ebx)
f0103056:	6a 00                	push   $0x0
f0103058:	ff 73 08             	pushl  0x8(%ebx)
f010305b:	e8 f5 20 00 00       	call   f0105155 <memset>
			memcpy((void *) ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103060:	83 c4 0c             	add    $0xc,%esp
f0103063:	ff 73 10             	pushl  0x10(%ebx)
f0103066:	89 f8                	mov    %edi,%eax
f0103068:	03 43 04             	add    0x4(%ebx),%eax
f010306b:	50                   	push   %eax
f010306c:	ff 73 08             	pushl  0x8(%ebx)
f010306f:	e8 96 21 00 00       	call   f010520a <memcpy>
f0103074:	83 c4 10             	add    $0x10,%esp
	eph = ph + ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));

	//program header记录着需要加载到内存里的部分
	for (; ph < eph; ph++) {
f0103077:	83 c3 20             	add    $0x20,%ebx
f010307a:	39 de                	cmp    %ebx,%esi
f010307c:	77 bf                	ja     f010303d <env_create+0x92>
			memset((void *) ph->p_va, 0, ph->p_memsz);
			memcpy((void *) ph->p_va, binary + ph->p_offset, ph->p_filesz);
		}
	}

	lcr3(PADDR(kern_pgdir));
f010307e:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103083:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103088:	77 15                	ja     f010309f <env_create+0xf4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010308a:	50                   	push   %eax
f010308b:	68 48 5e 10 f0       	push   $0xf0105e48
f0103090:	68 8b 01 00 00       	push   $0x18b
f0103095:	68 ec 6f 10 f0       	push   $0xf0106fec
f010309a:	e8 a1 cf ff ff       	call   f0100040 <_panic>
f010309f:	05 00 00 00 10       	add    $0x10000000,%eax
f01030a4:	0f 22 d8             	mov    %eax,%cr3
	
	// 设置程序的入口位置
	// 最重要这一句啦
	e->env_tf.tf_eip = ELFHDR->e_entry;
f01030a7:	8b 47 18             	mov    0x18(%edi),%eax
f01030aa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01030ad:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	// 进程运行栈
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01030b0:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01030b5:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01030ba:	89 f8                	mov    %edi,%eax
f01030bc:	e8 10 fc ff ff       	call   f0102cd1 <region_alloc>
	if ((errorcode=env_alloc(&e, 0)) < 0)
		panic("env_create: %e", errorcode);

	load_icode(e, binary);

	e->env_type = type;
f01030c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01030c7:	89 48 50             	mov    %ecx,0x50(%eax)


	// If this is the file server (type == ENV_TYPE_FS) give it I/O privileges.
	// LAB 5: Your code here.s
	// 如果是文件系统进程，允许其访问I/O
	if(type == ENV_TYPE_FS)
f01030ca:	83 f9 01             	cmp    $0x1,%ecx
f01030cd:	75 07                	jne    f01030d6 <env_create+0x12b>
		e->env_tf.tf_eflags |= FL_IOPL_3;
f01030cf:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
		
	
}
f01030d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030d9:	5b                   	pop    %ebx
f01030da:	5e                   	pop    %esi
f01030db:	5f                   	pop    %edi
f01030dc:	5d                   	pop    %ebp
f01030dd:	c3                   	ret    

f01030de <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01030de:	55                   	push   %ebp
f01030df:	89 e5                	mov    %esp,%ebp
f01030e1:	57                   	push   %edi
f01030e2:	56                   	push   %esi
f01030e3:	53                   	push   %ebx
f01030e4:	83 ec 1c             	sub    $0x1c,%esp
f01030e7:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01030ea:	e8 87 26 00 00       	call   f0105776 <cpunum>
f01030ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01030f2:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f01030f9:	39 b8 28 20 21 f0    	cmp    %edi,-0xfdedfd8(%eax)
f01030ff:	75 30                	jne    f0103131 <env_free+0x53>
		lcr3(PADDR(kern_pgdir));
f0103101:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103106:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010310b:	77 15                	ja     f0103122 <env_free+0x44>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010310d:	50                   	push   %eax
f010310e:	68 48 5e 10 f0       	push   $0xf0105e48
f0103113:	68 c6 01 00 00       	push   $0x1c6
f0103118:	68 ec 6f 10 f0       	push   $0xf0106fec
f010311d:	e8 1e cf ff ff       	call   f0100040 <_panic>
f0103122:	05 00 00 00 10       	add    $0x10000000,%eax
f0103127:	0f 22 d8             	mov    %eax,%cr3
f010312a:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103131:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103134:	89 d0                	mov    %edx,%eax
f0103136:	c1 e0 02             	shl    $0x2,%eax
f0103139:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f010313c:	8b 47 60             	mov    0x60(%edi),%eax
f010313f:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0103142:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103148:	0f 84 a8 00 00 00    	je     f01031f6 <env_free+0x118>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010314e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103154:	89 f0                	mov    %esi,%eax
f0103156:	c1 e8 0c             	shr    $0xc,%eax
f0103159:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010315c:	39 05 88 1e 21 f0    	cmp    %eax,0xf0211e88
f0103162:	77 15                	ja     f0103179 <env_free+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103164:	56                   	push   %esi
f0103165:	68 24 5e 10 f0       	push   $0xf0105e24
f010316a:	68 d5 01 00 00       	push   $0x1d5
f010316f:	68 ec 6f 10 f0       	push   $0xf0106fec
f0103174:	e8 c7 ce ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103179:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010317c:	c1 e0 16             	shl    $0x16,%eax
f010317f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0103182:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0103187:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f010318e:	01 
f010318f:	74 17                	je     f01031a8 <env_free+0xca>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0103191:	83 ec 08             	sub    $0x8,%esp
f0103194:	89 d8                	mov    %ebx,%eax
f0103196:	c1 e0 0c             	shl    $0xc,%eax
f0103199:	0b 45 e4             	or     -0x1c(%ebp),%eax
f010319c:	50                   	push   %eax
f010319d:	ff 77 60             	pushl  0x60(%edi)
f01031a0:	e8 5b df ff ff       	call   f0101100 <page_remove>
f01031a5:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01031a8:	83 c3 01             	add    $0x1,%ebx
f01031ab:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01031b1:	75 d4                	jne    f0103187 <env_free+0xa9>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01031b3:	8b 47 60             	mov    0x60(%edi),%eax
f01031b6:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01031b9:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01031c3:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f01031c9:	72 14                	jb     f01031df <env_free+0x101>
		panic("pa2page called with invalid pa");
f01031cb:	83 ec 04             	sub    $0x4,%esp
f01031ce:	68 04 64 10 f0       	push   $0xf0106404
f01031d3:	6a 51                	push   $0x51
f01031d5:	68 71 6c 10 f0       	push   $0xf0106c71
f01031da:	e8 61 ce ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f01031df:	83 ec 0c             	sub    $0xc,%esp
f01031e2:	a1 90 1e 21 f0       	mov    0xf0211e90,%eax
f01031e7:	8b 55 d8             	mov    -0x28(%ebp),%edx
f01031ea:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f01031ed:	50                   	push   %eax
f01031ee:	e8 6a dd ff ff       	call   f0100f5d <page_decref>
f01031f3:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	// cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f01031f6:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f01031fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01031fd:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f0103202:	0f 85 29 ff ff ff    	jne    f0103131 <env_free+0x53>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103208:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010320b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103210:	77 15                	ja     f0103227 <env_free+0x149>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103212:	50                   	push   %eax
f0103213:	68 48 5e 10 f0       	push   $0xf0105e48
f0103218:	68 e3 01 00 00       	push   $0x1e3
f010321d:	68 ec 6f 10 f0       	push   $0xf0106fec
f0103222:	e8 19 ce ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103227:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010322e:	05 00 00 00 10       	add    $0x10000000,%eax
f0103233:	c1 e8 0c             	shr    $0xc,%eax
f0103236:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f010323c:	72 14                	jb     f0103252 <env_free+0x174>
		panic("pa2page called with invalid pa");
f010323e:	83 ec 04             	sub    $0x4,%esp
f0103241:	68 04 64 10 f0       	push   $0xf0106404
f0103246:	6a 51                	push   $0x51
f0103248:	68 71 6c 10 f0       	push   $0xf0106c71
f010324d:	e8 ee cd ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f0103252:	83 ec 0c             	sub    $0xc,%esp
f0103255:	8b 15 90 1e 21 f0    	mov    0xf0211e90,%edx
f010325b:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010325e:	50                   	push   %eax
f010325f:	e8 f9 dc ff ff       	call   f0100f5d <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103264:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f010326b:	a1 4c 12 21 f0       	mov    0xf021124c,%eax
f0103270:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103273:	89 3d 4c 12 21 f0    	mov    %edi,0xf021124c
}
f0103279:	83 c4 10             	add    $0x10,%esp
f010327c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010327f:	5b                   	pop    %ebx
f0103280:	5e                   	pop    %esi
f0103281:	5f                   	pop    %edi
f0103282:	5d                   	pop    %ebp
f0103283:	c3                   	ret    

f0103284 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f0103284:	55                   	push   %ebp
f0103285:	89 e5                	mov    %esp,%ebp
f0103287:	53                   	push   %ebx
f0103288:	83 ec 04             	sub    $0x4,%esp
f010328b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f010328e:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f0103292:	75 19                	jne    f01032ad <env_destroy+0x29>
f0103294:	e8 dd 24 00 00       	call   f0105776 <cpunum>
f0103299:	6b c0 74             	imul   $0x74,%eax,%eax
f010329c:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f01032a2:	74 09                	je     f01032ad <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01032a4:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01032ab:	eb 33                	jmp    f01032e0 <env_destroy+0x5c>
	}

	env_free(e);
f01032ad:	83 ec 0c             	sub    $0xc,%esp
f01032b0:	53                   	push   %ebx
f01032b1:	e8 28 fe ff ff       	call   f01030de <env_free>

	if (curenv == e) {
f01032b6:	e8 bb 24 00 00       	call   f0105776 <cpunum>
f01032bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01032be:	83 c4 10             	add    $0x10,%esp
f01032c1:	3b 98 28 20 21 f0    	cmp    -0xfdedfd8(%eax),%ebx
f01032c7:	75 17                	jne    f01032e0 <env_destroy+0x5c>
		curenv = NULL;
f01032c9:	e8 a8 24 00 00       	call   f0105776 <cpunum>
f01032ce:	6b c0 74             	imul   $0x74,%eax,%eax
f01032d1:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f01032d8:	00 00 00 
		sched_yield();
f01032db:	e8 84 0d 00 00       	call   f0104064 <sched_yield>
	}
}
f01032e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01032e3:	c9                   	leave  
f01032e4:	c3                   	ret    

f01032e5 <env_pop_tf>:
//
// This function does not return.
// 将相应数据pop到寄存器，开始执行
void
env_pop_tf(struct Trapframe *tf)
{
f01032e5:	55                   	push   %ebp
f01032e6:	89 e5                	mov    %esp,%ebp
f01032e8:	53                   	push   %ebx
f01032e9:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01032ec:	e8 85 24 00 00       	call   f0105776 <cpunum>
f01032f1:	6b c0 74             	imul   $0x74,%eax,%eax
f01032f4:	8b 98 28 20 21 f0    	mov    -0xfdedfd8(%eax),%ebx
f01032fa:	e8 77 24 00 00       	call   f0105776 <cpunum>
f01032ff:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f0103302:	8b 65 08             	mov    0x8(%ebp),%esp
f0103305:	61                   	popa   
f0103306:	07                   	pop    %es
f0103307:	1f                   	pop    %ds
f0103308:	83 c4 08             	add    $0x8,%esp
f010330b:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f010330c:	83 ec 04             	sub    $0x4,%esp
f010330f:	68 06 70 10 f0       	push   $0xf0107006
f0103314:	68 1a 02 00 00       	push   $0x21a
f0103319:	68 ec 6f 10 f0       	push   $0xf0106fec
f010331e:	e8 1d cd ff ff       	call   f0100040 <_panic>

f0103323 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103323:	55                   	push   %ebp
f0103324:	89 e5                	mov    %esp,%ebp
f0103326:	83 ec 08             	sub    $0x8,%esp

	// LAB 3: Your code here.


	//panic("env_run not yet implemented");
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103329:	e8 48 24 00 00       	call   f0105776 <cpunum>
f010332e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103331:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0103338:	74 29                	je     f0103363 <env_run+0x40>
f010333a:	e8 37 24 00 00       	call   f0105776 <cpunum>
f010333f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103342:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103348:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010334c:	75 15                	jne    f0103363 <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE;
f010334e:	e8 23 24 00 00       	call   f0105776 <cpunum>
f0103353:	6b c0 74             	imul   $0x74,%eax,%eax
f0103356:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010335c:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103363:	e8 0e 24 00 00       	call   f0105776 <cpunum>
f0103368:	6b c0 74             	imul   $0x74,%eax,%eax
f010336b:	8b 55 08             	mov    0x8(%ebp),%edx
f010336e:	89 90 28 20 21 f0    	mov    %edx,-0xfdedfd8(%eax)
	curenv->env_status = ENV_RUNNING;
f0103374:	e8 fd 23 00 00       	call   f0105776 <cpunum>
f0103379:	6b c0 74             	imul   $0x74,%eax,%eax
f010337c:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103382:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f0103389:	e8 e8 23 00 00       	call   f0105776 <cpunum>
f010338e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103391:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103397:	83 40 58 01          	addl   $0x1,0x58(%eax)
	// 加载进程的页目录地址到cr3
	lcr3(PADDR(curenv->env_pgdir));
f010339b:	e8 d6 23 00 00       	call   f0105776 <cpunum>
f01033a0:	6b c0 74             	imul   $0x74,%eax,%eax
f01033a3:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01033a9:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033ac:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033b1:	77 15                	ja     f01033c8 <env_run+0xa5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033b3:	50                   	push   %eax
f01033b4:	68 48 5e 10 f0       	push   $0xf0105e48
f01033b9:	68 41 02 00 00       	push   $0x241
f01033be:	68 ec 6f 10 f0       	push   $0xf0106fec
f01033c3:	e8 78 cc ff ff       	call   f0100040 <_panic>
f01033c8:	05 00 00 00 10       	add    $0x10000000,%eax
f01033cd:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01033d0:	83 ec 0c             	sub    $0xc,%esp
f01033d3:	68 c0 f3 11 f0       	push   $0xf011f3c0
f01033d8:	e8 a4 26 00 00       	call   f0105a81 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01033dd:	f3 90                	pause  
	// 释放内核锁
	unlock_kernel();
	//开始执行
	env_pop_tf(&curenv->env_tf);
f01033df:	e8 92 23 00 00       	call   f0105776 <cpunum>
f01033e4:	83 c4 04             	add    $0x4,%esp
f01033e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01033ea:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f01033f0:	e8 f0 fe ff ff       	call   f01032e5 <env_pop_tf>

f01033f5 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f01033f5:	55                   	push   %ebp
f01033f6:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01033f8:	ba 70 00 00 00       	mov    $0x70,%edx
f01033fd:	8b 45 08             	mov    0x8(%ebp),%eax
f0103400:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103401:	ba 71 00 00 00       	mov    $0x71,%edx
f0103406:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103407:	0f b6 c0             	movzbl %al,%eax
}
f010340a:	5d                   	pop    %ebp
f010340b:	c3                   	ret    

f010340c <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f010340c:	55                   	push   %ebp
f010340d:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010340f:	ba 70 00 00 00       	mov    $0x70,%edx
f0103414:	8b 45 08             	mov    0x8(%ebp),%eax
f0103417:	ee                   	out    %al,(%dx)
f0103418:	ba 71 00 00 00       	mov    $0x71,%edx
f010341d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103420:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103421:	5d                   	pop    %ebp
f0103422:	c3                   	ret    

f0103423 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103423:	55                   	push   %ebp
f0103424:	89 e5                	mov    %esp,%ebp
f0103426:	56                   	push   %esi
f0103427:	53                   	push   %ebx
f0103428:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f010342b:	66 a3 a8 f3 11 f0    	mov    %ax,0xf011f3a8
	if (!didinit)
f0103431:	80 3d 50 12 21 f0 00 	cmpb   $0x0,0xf0211250
f0103438:	74 5a                	je     f0103494 <irq_setmask_8259A+0x71>
f010343a:	89 c6                	mov    %eax,%esi
f010343c:	ba 21 00 00 00       	mov    $0x21,%edx
f0103441:	ee                   	out    %al,(%dx)
f0103442:	66 c1 e8 08          	shr    $0x8,%ax
f0103446:	ba a1 00 00 00       	mov    $0xa1,%edx
f010344b:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f010344c:	83 ec 0c             	sub    $0xc,%esp
f010344f:	68 12 70 10 f0       	push   $0xf0107012
f0103454:	e8 1b 01 00 00       	call   f0103574 <cprintf>
f0103459:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f010345c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f0103461:	0f b7 f6             	movzwl %si,%esi
f0103464:	f7 d6                	not    %esi
f0103466:	0f a3 de             	bt     %ebx,%esi
f0103469:	73 11                	jae    f010347c <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f010346b:	83 ec 08             	sub    $0x8,%esp
f010346e:	53                   	push   %ebx
f010346f:	68 cb 74 10 f0       	push   $0xf01074cb
f0103474:	e8 fb 00 00 00       	call   f0103574 <cprintf>
f0103479:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f010347c:	83 c3 01             	add    $0x1,%ebx
f010347f:	83 fb 10             	cmp    $0x10,%ebx
f0103482:	75 e2                	jne    f0103466 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103484:	83 ec 0c             	sub    $0xc,%esp
f0103487:	68 74 6f 10 f0       	push   $0xf0106f74
f010348c:	e8 e3 00 00 00       	call   f0103574 <cprintf>
f0103491:	83 c4 10             	add    $0x10,%esp
}
f0103494:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103497:	5b                   	pop    %ebx
f0103498:	5e                   	pop    %esi
f0103499:	5d                   	pop    %ebp
f010349a:	c3                   	ret    

f010349b <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f010349b:	c6 05 50 12 21 f0 01 	movb   $0x1,0xf0211250
f01034a2:	ba 21 00 00 00       	mov    $0x21,%edx
f01034a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01034ac:	ee                   	out    %al,(%dx)
f01034ad:	ba a1 00 00 00       	mov    $0xa1,%edx
f01034b2:	ee                   	out    %al,(%dx)
f01034b3:	ba 20 00 00 00       	mov    $0x20,%edx
f01034b8:	b8 11 00 00 00       	mov    $0x11,%eax
f01034bd:	ee                   	out    %al,(%dx)
f01034be:	ba 21 00 00 00       	mov    $0x21,%edx
f01034c3:	b8 20 00 00 00       	mov    $0x20,%eax
f01034c8:	ee                   	out    %al,(%dx)
f01034c9:	b8 04 00 00 00       	mov    $0x4,%eax
f01034ce:	ee                   	out    %al,(%dx)
f01034cf:	b8 03 00 00 00       	mov    $0x3,%eax
f01034d4:	ee                   	out    %al,(%dx)
f01034d5:	ba a0 00 00 00       	mov    $0xa0,%edx
f01034da:	b8 11 00 00 00       	mov    $0x11,%eax
f01034df:	ee                   	out    %al,(%dx)
f01034e0:	ba a1 00 00 00       	mov    $0xa1,%edx
f01034e5:	b8 28 00 00 00       	mov    $0x28,%eax
f01034ea:	ee                   	out    %al,(%dx)
f01034eb:	b8 02 00 00 00       	mov    $0x2,%eax
f01034f0:	ee                   	out    %al,(%dx)
f01034f1:	b8 01 00 00 00       	mov    $0x1,%eax
f01034f6:	ee                   	out    %al,(%dx)
f01034f7:	ba 20 00 00 00       	mov    $0x20,%edx
f01034fc:	b8 68 00 00 00       	mov    $0x68,%eax
f0103501:	ee                   	out    %al,(%dx)
f0103502:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103507:	ee                   	out    %al,(%dx)
f0103508:	ba a0 00 00 00       	mov    $0xa0,%edx
f010350d:	b8 68 00 00 00       	mov    $0x68,%eax
f0103512:	ee                   	out    %al,(%dx)
f0103513:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103518:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103519:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f0103520:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103524:	74 13                	je     f0103539 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103526:	55                   	push   %ebp
f0103527:	89 e5                	mov    %esp,%ebp
f0103529:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f010352c:	0f b7 c0             	movzwl %ax,%eax
f010352f:	50                   	push   %eax
f0103530:	e8 ee fe ff ff       	call   f0103423 <irq_setmask_8259A>
f0103535:	83 c4 10             	add    $0x10,%esp
}
f0103538:	c9                   	leave  
f0103539:	f3 c3                	repz ret 

f010353b <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f010353b:	55                   	push   %ebp
f010353c:	89 e5                	mov    %esp,%ebp
f010353e:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f0103541:	ff 75 08             	pushl  0x8(%ebp)
f0103544:	e8 53 d2 ff ff       	call   f010079c <cputchar>
	*cnt++;
}
f0103549:	83 c4 10             	add    $0x10,%esp
f010354c:	c9                   	leave  
f010354d:	c3                   	ret    

f010354e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010354e:	55                   	push   %ebp
f010354f:	89 e5                	mov    %esp,%ebp
f0103551:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103554:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010355b:	ff 75 0c             	pushl  0xc(%ebp)
f010355e:	ff 75 08             	pushl  0x8(%ebp)
f0103561:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103564:	50                   	push   %eax
f0103565:	68 3b 35 10 f0       	push   $0xf010353b
f010356a:	e8 a9 14 00 00       	call   f0104a18 <vprintfmt>
	return cnt;
}
f010356f:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103572:	c9                   	leave  
f0103573:	c3                   	ret    

f0103574 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103574:	55                   	push   %ebp
f0103575:	89 e5                	mov    %esp,%ebp
f0103577:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010357a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010357d:	50                   	push   %eax
f010357e:	ff 75 08             	pushl  0x8(%ebp)
f0103581:	e8 c8 ff ff ff       	call   f010354e <vcprintf>
	va_end(ap);

	return cnt;
}
f0103586:	c9                   	leave  
f0103587:	c3                   	ret    

f0103588 <trap_init_percpu>:

// Initialize and load the per-CPU TSS and IDT
// 加载CPU的TSS选择子和IDT中断描述符表
void
trap_init_percpu(void)
{
f0103588:	55                   	push   %ebp
f0103589:	89 e5                	mov    %esp,%ebp
f010358b:	57                   	push   %edi
f010358c:	56                   	push   %esi
f010358d:	53                   	push   %ebx
f010358e:	83 ec 0c             	sub    $0xc,%esp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	//ts.ts_esp0 = KSTACKTOP;
	//ts.ts_ss0 = GD_KD;
	//ts.ts_iomb = sizeof(struct Taskstate);
	int i = cpunum();
f0103591:	e8 e0 21 00 00       	call   f0105776 <cpunum>
f0103596:	89 c3                	mov    %eax,%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f0103598:	e8 d9 21 00 00       	call   f0105776 <cpunum>
f010359d:	6b c0 74             	imul   $0x74,%eax,%eax
f01035a0:	89 d9                	mov    %ebx,%ecx
f01035a2:	c1 e1 10             	shl    $0x10,%ecx
f01035a5:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01035aa:	29 ca                	sub    %ecx,%edx
f01035ac:	89 90 30 20 21 f0    	mov    %edx,-0xfdedfd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;		
f01035b2:	e8 bf 21 00 00       	call   f0105776 <cpunum>
f01035b7:	6b c0 74             	imul   $0x74,%eax,%eax
f01035ba:	66 c7 80 34 20 21 f0 	movw   $0x10,-0xfdedfcc(%eax)
f01035c1:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)(&(thiscpu->cpu_ts)), 
f01035c3:	83 c3 05             	add    $0x5,%ebx
f01035c6:	e8 ab 21 00 00       	call   f0105776 <cpunum>
f01035cb:	89 c7                	mov    %eax,%edi
f01035cd:	e8 a4 21 00 00       	call   f0105776 <cpunum>
f01035d2:	89 c6                	mov    %eax,%esi
f01035d4:	e8 9d 21 00 00       	call   f0105776 <cpunum>
f01035d9:	66 c7 04 dd 40 f3 11 	movw   $0x67,-0xfee0cc0(,%ebx,8)
f01035e0:	f0 67 00 
f01035e3:	6b ff 74             	imul   $0x74,%edi,%edi
f01035e6:	81 c7 2c 20 21 f0    	add    $0xf021202c,%edi
f01035ec:	66 89 3c dd 42 f3 11 	mov    %di,-0xfee0cbe(,%ebx,8)
f01035f3:	f0 
f01035f4:	6b d6 74             	imul   $0x74,%esi,%edx
f01035f7:	81 c2 2c 20 21 f0    	add    $0xf021202c,%edx
f01035fd:	c1 ea 10             	shr    $0x10,%edx
f0103600:	88 14 dd 44 f3 11 f0 	mov    %dl,-0xfee0cbc(,%ebx,8)
f0103607:	c6 04 dd 46 f3 11 f0 	movb   $0x40,-0xfee0cba(,%ebx,8)
f010360e:	40 
f010360f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103612:	05 2c 20 21 f0       	add    $0xf021202c,%eax
f0103617:	c1 e8 18             	shr    $0x18,%eax
f010361a:	88 04 dd 47 f3 11 f0 	mov    %al,-0xfee0cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f0103621:	c6 04 dd 45 f3 11 f0 	movb   $0x89,-0xfee0cbb(,%ebx,8)
f0103628:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103629:	c1 e3 03             	shl    $0x3,%ebx
f010362c:	0f 00 db             	ltr    %bx
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010362f:	b8 ac f3 11 f0       	mov    $0xf011f3ac,%eax
f0103634:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * i);

	// Load the IDT
	lidt(&idt_pd);
}
f0103637:	83 c4 0c             	add    $0xc,%esp
f010363a:	5b                   	pop    %ebx
f010363b:	5e                   	pop    %esi
f010363c:	5f                   	pop    %edi
f010363d:	5d                   	pop    %ebp
f010363e:	c3                   	ret    

f010363f <trap_init>:
}


void
trap_init(void)
{
f010363f:	55                   	push   %ebp
f0103640:	89 e5                	mov    %esp,%ebp
f0103642:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103645:	b8 14 3f 10 f0       	mov    $0xf0103f14,%eax
f010364a:	66 a3 60 12 21 f0    	mov    %ax,0xf0211260
f0103650:	66 c7 05 62 12 21 f0 	movw   $0x8,0xf0211262
f0103657:	08 00 
f0103659:	c6 05 64 12 21 f0 00 	movb   $0x0,0xf0211264
f0103660:	c6 05 65 12 21 f0 8e 	movb   $0x8e,0xf0211265
f0103667:	c1 e8 10             	shr    $0x10,%eax
f010366a:	66 a3 66 12 21 f0    	mov    %ax,0xf0211266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f0103670:	b8 1a 3f 10 f0       	mov    $0xf0103f1a,%eax
f0103675:	66 a3 68 12 21 f0    	mov    %ax,0xf0211268
f010367b:	66 c7 05 6a 12 21 f0 	movw   $0x8,0xf021126a
f0103682:	08 00 
f0103684:	c6 05 6c 12 21 f0 00 	movb   $0x0,0xf021126c
f010368b:	c6 05 6d 12 21 f0 8e 	movb   $0x8e,0xf021126d
f0103692:	c1 e8 10             	shr    $0x10,%eax
f0103695:	66 a3 6e 12 21 f0    	mov    %ax,0xf021126e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f010369b:	b8 20 3f 10 f0       	mov    $0xf0103f20,%eax
f01036a0:	66 a3 70 12 21 f0    	mov    %ax,0xf0211270
f01036a6:	66 c7 05 72 12 21 f0 	movw   $0x8,0xf0211272
f01036ad:	08 00 
f01036af:	c6 05 74 12 21 f0 00 	movb   $0x0,0xf0211274
f01036b6:	c6 05 75 12 21 f0 8e 	movb   $0x8e,0xf0211275
f01036bd:	c1 e8 10             	shr    $0x10,%eax
f01036c0:	66 a3 76 12 21 f0    	mov    %ax,0xf0211276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01036c6:	b8 26 3f 10 f0       	mov    $0xf0103f26,%eax
f01036cb:	66 a3 78 12 21 f0    	mov    %ax,0xf0211278
f01036d1:	66 c7 05 7a 12 21 f0 	movw   $0x8,0xf021127a
f01036d8:	08 00 
f01036da:	c6 05 7c 12 21 f0 00 	movb   $0x0,0xf021127c
f01036e1:	c6 05 7d 12 21 f0 ee 	movb   $0xee,0xf021127d
f01036e8:	c1 e8 10             	shr    $0x10,%eax
f01036eb:	66 a3 7e 12 21 f0    	mov    %ax,0xf021127e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f01036f1:	b8 2c 3f 10 f0       	mov    $0xf0103f2c,%eax
f01036f6:	66 a3 80 12 21 f0    	mov    %ax,0xf0211280
f01036fc:	66 c7 05 82 12 21 f0 	movw   $0x8,0xf0211282
f0103703:	08 00 
f0103705:	c6 05 84 12 21 f0 00 	movb   $0x0,0xf0211284
f010370c:	c6 05 85 12 21 f0 8e 	movb   $0x8e,0xf0211285
f0103713:	c1 e8 10             	shr    $0x10,%eax
f0103716:	66 a3 86 12 21 f0    	mov    %ax,0xf0211286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f010371c:	b8 32 3f 10 f0       	mov    $0xf0103f32,%eax
f0103721:	66 a3 88 12 21 f0    	mov    %ax,0xf0211288
f0103727:	66 c7 05 8a 12 21 f0 	movw   $0x8,0xf021128a
f010372e:	08 00 
f0103730:	c6 05 8c 12 21 f0 00 	movb   $0x0,0xf021128c
f0103737:	c6 05 8d 12 21 f0 8e 	movb   $0x8e,0xf021128d
f010373e:	c1 e8 10             	shr    $0x10,%eax
f0103741:	66 a3 8e 12 21 f0    	mov    %ax,0xf021128e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103747:	b8 38 3f 10 f0       	mov    $0xf0103f38,%eax
f010374c:	66 a3 90 12 21 f0    	mov    %ax,0xf0211290
f0103752:	66 c7 05 92 12 21 f0 	movw   $0x8,0xf0211292
f0103759:	08 00 
f010375b:	c6 05 94 12 21 f0 00 	movb   $0x0,0xf0211294
f0103762:	c6 05 95 12 21 f0 8e 	movb   $0x8e,0xf0211295
f0103769:	c1 e8 10             	shr    $0x10,%eax
f010376c:	66 a3 96 12 21 f0    	mov    %ax,0xf0211296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f0103772:	b8 3e 3f 10 f0       	mov    $0xf0103f3e,%eax
f0103777:	66 a3 98 12 21 f0    	mov    %ax,0xf0211298
f010377d:	66 c7 05 9a 12 21 f0 	movw   $0x8,0xf021129a
f0103784:	08 00 
f0103786:	c6 05 9c 12 21 f0 00 	movb   $0x0,0xf021129c
f010378d:	c6 05 9d 12 21 f0 8e 	movb   $0x8e,0xf021129d
f0103794:	c1 e8 10             	shr    $0x10,%eax
f0103797:	66 a3 9e 12 21 f0    	mov    %ax,0xf021129e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f010379d:	b8 44 3f 10 f0       	mov    $0xf0103f44,%eax
f01037a2:	66 a3 a0 12 21 f0    	mov    %ax,0xf02112a0
f01037a8:	66 c7 05 a2 12 21 f0 	movw   $0x8,0xf02112a2
f01037af:	08 00 
f01037b1:	c6 05 a4 12 21 f0 00 	movb   $0x0,0xf02112a4
f01037b8:	c6 05 a5 12 21 f0 8e 	movb   $0x8e,0xf02112a5
f01037bf:	c1 e8 10             	shr    $0x10,%eax
f01037c2:	66 a3 a6 12 21 f0    	mov    %ax,0xf02112a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f01037c8:	b8 48 3f 10 f0       	mov    $0xf0103f48,%eax
f01037cd:	66 a3 b0 12 21 f0    	mov    %ax,0xf02112b0
f01037d3:	66 c7 05 b2 12 21 f0 	movw   $0x8,0xf02112b2
f01037da:	08 00 
f01037dc:	c6 05 b4 12 21 f0 00 	movb   $0x0,0xf02112b4
f01037e3:	c6 05 b5 12 21 f0 8e 	movb   $0x8e,0xf02112b5
f01037ea:	c1 e8 10             	shr    $0x10,%eax
f01037ed:	66 a3 b6 12 21 f0    	mov    %ax,0xf02112b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f01037f3:	b8 4c 3f 10 f0       	mov    $0xf0103f4c,%eax
f01037f8:	66 a3 b8 12 21 f0    	mov    %ax,0xf02112b8
f01037fe:	66 c7 05 ba 12 21 f0 	movw   $0x8,0xf02112ba
f0103805:	08 00 
f0103807:	c6 05 bc 12 21 f0 00 	movb   $0x0,0xf02112bc
f010380e:	c6 05 bd 12 21 f0 8e 	movb   $0x8e,0xf02112bd
f0103815:	c1 e8 10             	shr    $0x10,%eax
f0103818:	66 a3 be 12 21 f0    	mov    %ax,0xf02112be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f010381e:	b8 50 3f 10 f0       	mov    $0xf0103f50,%eax
f0103823:	66 a3 c0 12 21 f0    	mov    %ax,0xf02112c0
f0103829:	66 c7 05 c2 12 21 f0 	movw   $0x8,0xf02112c2
f0103830:	08 00 
f0103832:	c6 05 c4 12 21 f0 00 	movb   $0x0,0xf02112c4
f0103839:	c6 05 c5 12 21 f0 8e 	movb   $0x8e,0xf02112c5
f0103840:	c1 e8 10             	shr    $0x10,%eax
f0103843:	66 a3 c6 12 21 f0    	mov    %ax,0xf02112c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103849:	b8 54 3f 10 f0       	mov    $0xf0103f54,%eax
f010384e:	66 a3 c8 12 21 f0    	mov    %ax,0xf02112c8
f0103854:	66 c7 05 ca 12 21 f0 	movw   $0x8,0xf02112ca
f010385b:	08 00 
f010385d:	c6 05 cc 12 21 f0 00 	movb   $0x0,0xf02112cc
f0103864:	c6 05 cd 12 21 f0 8e 	movb   $0x8e,0xf02112cd
f010386b:	c1 e8 10             	shr    $0x10,%eax
f010386e:	66 a3 ce 12 21 f0    	mov    %ax,0xf02112ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f0103874:	b8 58 3f 10 f0       	mov    $0xf0103f58,%eax
f0103879:	66 a3 d0 12 21 f0    	mov    %ax,0xf02112d0
f010387f:	66 c7 05 d2 12 21 f0 	movw   $0x8,0xf02112d2
f0103886:	08 00 
f0103888:	c6 05 d4 12 21 f0 00 	movb   $0x0,0xf02112d4
f010388f:	c6 05 d5 12 21 f0 8e 	movb   $0x8e,0xf02112d5
f0103896:	c1 e8 10             	shr    $0x10,%eax
f0103899:	66 a3 d6 12 21 f0    	mov    %ax,0xf02112d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f010389f:	b8 5c 3f 10 f0       	mov    $0xf0103f5c,%eax
f01038a4:	66 a3 e0 12 21 f0    	mov    %ax,0xf02112e0
f01038aa:	66 c7 05 e2 12 21 f0 	movw   $0x8,0xf02112e2
f01038b1:	08 00 
f01038b3:	c6 05 e4 12 21 f0 00 	movb   $0x0,0xf02112e4
f01038ba:	c6 05 e5 12 21 f0 8e 	movb   $0x8e,0xf02112e5
f01038c1:	c1 e8 10             	shr    $0x10,%eax
f01038c4:	66 a3 e6 12 21 f0    	mov    %ax,0xf02112e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f01038ca:	b8 62 3f 10 f0       	mov    $0xf0103f62,%eax
f01038cf:	66 a3 e8 12 21 f0    	mov    %ax,0xf02112e8
f01038d5:	66 c7 05 ea 12 21 f0 	movw   $0x8,0xf02112ea
f01038dc:	08 00 
f01038de:	c6 05 ec 12 21 f0 00 	movb   $0x0,0xf02112ec
f01038e5:	c6 05 ed 12 21 f0 8e 	movb   $0x8e,0xf02112ed
f01038ec:	c1 e8 10             	shr    $0x10,%eax
f01038ef:	66 a3 ee 12 21 f0    	mov    %ax,0xf02112ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f01038f5:	b8 66 3f 10 f0       	mov    $0xf0103f66,%eax
f01038fa:	66 a3 f0 12 21 f0    	mov    %ax,0xf02112f0
f0103900:	66 c7 05 f2 12 21 f0 	movw   $0x8,0xf02112f2
f0103907:	08 00 
f0103909:	c6 05 f4 12 21 f0 00 	movb   $0x0,0xf02112f4
f0103910:	c6 05 f5 12 21 f0 8e 	movb   $0x8e,0xf02112f5
f0103917:	c1 e8 10             	shr    $0x10,%eax
f010391a:	66 a3 f6 12 21 f0    	mov    %ax,0xf02112f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f0103920:	b8 6c 3f 10 f0       	mov    $0xf0103f6c,%eax
f0103925:	66 a3 f8 12 21 f0    	mov    %ax,0xf02112f8
f010392b:	66 c7 05 fa 12 21 f0 	movw   $0x8,0xf02112fa
f0103932:	08 00 
f0103934:	c6 05 fc 12 21 f0 00 	movb   $0x0,0xf02112fc
f010393b:	c6 05 fd 12 21 f0 8e 	movb   $0x8e,0xf02112fd
f0103942:	c1 e8 10             	shr    $0x10,%eax
f0103945:	66 a3 fe 12 21 f0    	mov    %ax,0xf02112fe

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f010394b:	b8 72 3f 10 f0       	mov    $0xf0103f72,%eax
f0103950:	66 a3 e0 13 21 f0    	mov    %ax,0xf02113e0
f0103956:	66 c7 05 e2 13 21 f0 	movw   $0x8,0xf02113e2
f010395d:	08 00 
f010395f:	c6 05 e4 13 21 f0 00 	movb   $0x0,0xf02113e4
f0103966:	c6 05 e5 13 21 f0 ee 	movb   $0xee,0xf02113e5
f010396d:	c1 e8 10             	shr    $0x10,%eax
f0103970:	66 a3 e6 13 21 f0    	mov    %ax,0xf02113e6


	SETGATE(idt[IRQ_OFFSET+IRQ_TIMER], 0, GD_KT, timer, 0);
f0103976:	b8 78 3f 10 f0       	mov    $0xf0103f78,%eax
f010397b:	66 a3 60 13 21 f0    	mov    %ax,0xf0211360
f0103981:	66 c7 05 62 13 21 f0 	movw   $0x8,0xf0211362
f0103988:	08 00 
f010398a:	c6 05 64 13 21 f0 00 	movb   $0x0,0xf0211364
f0103991:	c6 05 65 13 21 f0 8e 	movb   $0x8e,0xf0211365
f0103998:	c1 e8 10             	shr    $0x10,%eax
f010399b:	66 a3 66 13 21 f0    	mov    %ax,0xf0211366

	// Per-CPU setup 
	trap_init_percpu();
f01039a1:	e8 e2 fb ff ff       	call   f0103588 <trap_init_percpu>
}
f01039a6:	c9                   	leave  
f01039a7:	c3                   	ret    

f01039a8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01039a8:	55                   	push   %ebp
f01039a9:	89 e5                	mov    %esp,%ebp
f01039ab:	53                   	push   %ebx
f01039ac:	83 ec 0c             	sub    $0xc,%esp
f01039af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01039b2:	ff 33                	pushl  (%ebx)
f01039b4:	68 26 70 10 f0       	push   $0xf0107026
f01039b9:	e8 b6 fb ff ff       	call   f0103574 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01039be:	83 c4 08             	add    $0x8,%esp
f01039c1:	ff 73 04             	pushl  0x4(%ebx)
f01039c4:	68 35 70 10 f0       	push   $0xf0107035
f01039c9:	e8 a6 fb ff ff       	call   f0103574 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01039ce:	83 c4 08             	add    $0x8,%esp
f01039d1:	ff 73 08             	pushl  0x8(%ebx)
f01039d4:	68 44 70 10 f0       	push   $0xf0107044
f01039d9:	e8 96 fb ff ff       	call   f0103574 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f01039de:	83 c4 08             	add    $0x8,%esp
f01039e1:	ff 73 0c             	pushl  0xc(%ebx)
f01039e4:	68 53 70 10 f0       	push   $0xf0107053
f01039e9:	e8 86 fb ff ff       	call   f0103574 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f01039ee:	83 c4 08             	add    $0x8,%esp
f01039f1:	ff 73 10             	pushl  0x10(%ebx)
f01039f4:	68 62 70 10 f0       	push   $0xf0107062
f01039f9:	e8 76 fb ff ff       	call   f0103574 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f01039fe:	83 c4 08             	add    $0x8,%esp
f0103a01:	ff 73 14             	pushl  0x14(%ebx)
f0103a04:	68 71 70 10 f0       	push   $0xf0107071
f0103a09:	e8 66 fb ff ff       	call   f0103574 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103a0e:	83 c4 08             	add    $0x8,%esp
f0103a11:	ff 73 18             	pushl  0x18(%ebx)
f0103a14:	68 80 70 10 f0       	push   $0xf0107080
f0103a19:	e8 56 fb ff ff       	call   f0103574 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103a1e:	83 c4 08             	add    $0x8,%esp
f0103a21:	ff 73 1c             	pushl  0x1c(%ebx)
f0103a24:	68 8f 70 10 f0       	push   $0xf010708f
f0103a29:	e8 46 fb ff ff       	call   f0103574 <cprintf>
}
f0103a2e:	83 c4 10             	add    $0x10,%esp
f0103a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a34:	c9                   	leave  
f0103a35:	c3                   	ret    

f0103a36 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103a36:	55                   	push   %ebp
f0103a37:	89 e5                	mov    %esp,%ebp
f0103a39:	56                   	push   %esi
f0103a3a:	53                   	push   %ebx
f0103a3b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103a3e:	e8 33 1d 00 00       	call   f0105776 <cpunum>
f0103a43:	83 ec 04             	sub    $0x4,%esp
f0103a46:	50                   	push   %eax
f0103a47:	53                   	push   %ebx
f0103a48:	68 f3 70 10 f0       	push   $0xf01070f3
f0103a4d:	e8 22 fb ff ff       	call   f0103574 <cprintf>
	print_regs(&tf->tf_regs);
f0103a52:	89 1c 24             	mov    %ebx,(%esp)
f0103a55:	e8 4e ff ff ff       	call   f01039a8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103a5a:	83 c4 08             	add    $0x8,%esp
f0103a5d:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103a61:	50                   	push   %eax
f0103a62:	68 11 71 10 f0       	push   $0xf0107111
f0103a67:	e8 08 fb ff ff       	call   f0103574 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103a6c:	83 c4 08             	add    $0x8,%esp
f0103a6f:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103a73:	50                   	push   %eax
f0103a74:	68 24 71 10 f0       	push   $0xf0107124
f0103a79:	e8 f6 fa ff ff       	call   f0103574 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103a7e:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103a81:	83 c4 10             	add    $0x10,%esp
f0103a84:	83 f8 13             	cmp    $0x13,%eax
f0103a87:	77 09                	ja     f0103a92 <print_trapframe+0x5c>
		return excnames[trapno];
f0103a89:	8b 14 85 e0 73 10 f0 	mov    -0xfef8c20(,%eax,4),%edx
f0103a90:	eb 1f                	jmp    f0103ab1 <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103a92:	83 f8 30             	cmp    $0x30,%eax
f0103a95:	74 15                	je     f0103aac <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103a97:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103a9a:	83 fa 10             	cmp    $0x10,%edx
f0103a9d:	b9 bd 70 10 f0       	mov    $0xf01070bd,%ecx
f0103aa2:	ba aa 70 10 f0       	mov    $0xf01070aa,%edx
f0103aa7:	0f 43 d1             	cmovae %ecx,%edx
f0103aaa:	eb 05                	jmp    f0103ab1 <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103aac:	ba 9e 70 10 f0       	mov    $0xf010709e,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ab1:	83 ec 04             	sub    $0x4,%esp
f0103ab4:	52                   	push   %edx
f0103ab5:	50                   	push   %eax
f0103ab6:	68 37 71 10 f0       	push   $0xf0107137
f0103abb:	e8 b4 fa ff ff       	call   f0103574 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103ac0:	83 c4 10             	add    $0x10,%esp
f0103ac3:	3b 1d 60 1a 21 f0    	cmp    0xf0211a60,%ebx
f0103ac9:	75 1a                	jne    f0103ae5 <print_trapframe+0xaf>
f0103acb:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103acf:	75 14                	jne    f0103ae5 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103ad1:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103ad4:	83 ec 08             	sub    $0x8,%esp
f0103ad7:	50                   	push   %eax
f0103ad8:	68 49 71 10 f0       	push   $0xf0107149
f0103add:	e8 92 fa ff ff       	call   f0103574 <cprintf>
f0103ae2:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103ae5:	83 ec 08             	sub    $0x8,%esp
f0103ae8:	ff 73 2c             	pushl  0x2c(%ebx)
f0103aeb:	68 58 71 10 f0       	push   $0xf0107158
f0103af0:	e8 7f fa ff ff       	call   f0103574 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103af5:	83 c4 10             	add    $0x10,%esp
f0103af8:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103afc:	75 49                	jne    f0103b47 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103afe:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103b01:	89 c2                	mov    %eax,%edx
f0103b03:	83 e2 01             	and    $0x1,%edx
f0103b06:	ba d7 70 10 f0       	mov    $0xf01070d7,%edx
f0103b0b:	b9 cc 70 10 f0       	mov    $0xf01070cc,%ecx
f0103b10:	0f 44 ca             	cmove  %edx,%ecx
f0103b13:	89 c2                	mov    %eax,%edx
f0103b15:	83 e2 02             	and    $0x2,%edx
f0103b18:	ba e9 70 10 f0       	mov    $0xf01070e9,%edx
f0103b1d:	be e3 70 10 f0       	mov    $0xf01070e3,%esi
f0103b22:	0f 45 d6             	cmovne %esi,%edx
f0103b25:	83 e0 04             	and    $0x4,%eax
f0103b28:	be 23 72 10 f0       	mov    $0xf0107223,%esi
f0103b2d:	b8 ee 70 10 f0       	mov    $0xf01070ee,%eax
f0103b32:	0f 44 c6             	cmove  %esi,%eax
f0103b35:	51                   	push   %ecx
f0103b36:	52                   	push   %edx
f0103b37:	50                   	push   %eax
f0103b38:	68 66 71 10 f0       	push   $0xf0107166
f0103b3d:	e8 32 fa ff ff       	call   f0103574 <cprintf>
f0103b42:	83 c4 10             	add    $0x10,%esp
f0103b45:	eb 10                	jmp    f0103b57 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103b47:	83 ec 0c             	sub    $0xc,%esp
f0103b4a:	68 74 6f 10 f0       	push   $0xf0106f74
f0103b4f:	e8 20 fa ff ff       	call   f0103574 <cprintf>
f0103b54:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103b57:	83 ec 08             	sub    $0x8,%esp
f0103b5a:	ff 73 30             	pushl  0x30(%ebx)
f0103b5d:	68 75 71 10 f0       	push   $0xf0107175
f0103b62:	e8 0d fa ff ff       	call   f0103574 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103b67:	83 c4 08             	add    $0x8,%esp
f0103b6a:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103b6e:	50                   	push   %eax
f0103b6f:	68 84 71 10 f0       	push   $0xf0107184
f0103b74:	e8 fb f9 ff ff       	call   f0103574 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103b79:	83 c4 08             	add    $0x8,%esp
f0103b7c:	ff 73 38             	pushl  0x38(%ebx)
f0103b7f:	68 97 71 10 f0       	push   $0xf0107197
f0103b84:	e8 eb f9 ff ff       	call   f0103574 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103b89:	83 c4 10             	add    $0x10,%esp
f0103b8c:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103b90:	74 25                	je     f0103bb7 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103b92:	83 ec 08             	sub    $0x8,%esp
f0103b95:	ff 73 3c             	pushl  0x3c(%ebx)
f0103b98:	68 a6 71 10 f0       	push   $0xf01071a6
f0103b9d:	e8 d2 f9 ff ff       	call   f0103574 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103ba2:	83 c4 08             	add    $0x8,%esp
f0103ba5:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103ba9:	50                   	push   %eax
f0103baa:	68 b5 71 10 f0       	push   $0xf01071b5
f0103baf:	e8 c0 f9 ff ff       	call   f0103574 <cprintf>
f0103bb4:	83 c4 10             	add    $0x10,%esp
	}
}
f0103bb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103bba:	5b                   	pop    %ebx
f0103bbb:	5e                   	pop    %esi
f0103bbc:	5d                   	pop    %ebp
f0103bbd:	c3                   	ret    

f0103bbe <page_fault_handler>:
// 1.根据tf构造用户异常栈(借助utf)
// 2.esp 指向用户异常栈  eip 指向进程中断(页错误)处理函数的入口位置
// 3.重新运行进程，此时会将用户异常栈的值pop到寄存器
void
page_fault_handler(struct Trapframe *tf)
{
f0103bbe:	55                   	push   %ebp
f0103bbf:	89 e5                	mov    %esp,%ebp
f0103bc1:	57                   	push   %edi
f0103bc2:	56                   	push   %esi
f0103bc3:	53                   	push   %ebx
f0103bc4:	83 ec 0c             	sub    $0xc,%esp
f0103bc7:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103bca:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 0x3) == 0) 
f0103bcd:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103bd1:	75 17                	jne    f0103bea <page_fault_handler+0x2c>
		panic("page_fault_handler: page fault in kernel mode");
f0103bd3:	83 ec 04             	sub    $0x4,%esp
f0103bd6:	68 70 73 10 f0       	push   $0xf0107370
f0103bdb:	68 76 01 00 00       	push   $0x176
f0103be0:	68 c8 71 10 f0       	push   $0xf01071c8
f0103be5:	e8 56 c4 ff ff       	call   f0100040 <_panic>

	// LAB 4: Your code here.
	// 用户态页错误
	// 把现场信息记录下来，构建用户异常栈数据结构，然后改变esp eip
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall != NULL) {
f0103bea:	e8 87 1b 00 00       	call   f0105776 <cpunum>
f0103bef:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bf2:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103bf8:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103bfc:	0f 84 89 00 00 00    	je     f0103c8b <page_fault_handler+0xcd>
		
		// 判断发生错误时堆栈指针是否处于用户异常栈，如果是，留出一个字的空间存返回值
        if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1)
f0103c02:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103c05:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f0103c0b:	83 e8 38             	sub    $0x38,%eax
f0103c0e:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103c14:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103c19:	0f 46 d0             	cmovbe %eax,%edx
f0103c1c:	89 d7                	mov    %edx,%edi
        else
                utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
        user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_U | PTE_W);
f0103c1e:	e8 53 1b 00 00       	call   f0105776 <cpunum>
f0103c23:	6a 06                	push   $0x6
f0103c25:	6a 34                	push   $0x34
f0103c27:	57                   	push   %edi
f0103c28:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c2b:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103c31:	e8 51 f0 ff ff       	call   f0102c87 <user_mem_assert>
		
		// 构构造utf(用户异常栈)
        utf->utf_fault_va = fault_va;
f0103c36:	89 fa                	mov    %edi,%edx
f0103c38:	89 37                	mov    %esi,(%edi)
        utf->utf_err = tf->tf_trapno;
f0103c3a:	8b 43 28             	mov    0x28(%ebx),%eax
f0103c3d:	89 47 04             	mov    %eax,0x4(%edi)
        utf->utf_eip = tf->tf_eip;
f0103c40:	8b 43 30             	mov    0x30(%ebx),%eax
f0103c43:	89 47 28             	mov    %eax,0x28(%edi)
        utf->utf_eflags = tf->tf_eflags;
f0103c46:	8b 43 38             	mov    0x38(%ebx),%eax
f0103c49:	89 47 2c             	mov    %eax,0x2c(%edi)
        utf->utf_esp = tf->tf_esp;
f0103c4c:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103c4f:	89 47 30             	mov    %eax,0x30(%edi)
        utf->utf_regs = tf->tf_regs;
f0103c52:	8d 7f 08             	lea    0x8(%edi),%edi
f0103c55:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103c5a:	89 de                	mov    %ebx,%esi
f0103c5c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		
		
		// 将进程的堆栈指针指向用户异常栈
        tf->tf_esp = (uint32_t)utf;
f0103c5e:	89 53 3c             	mov    %edx,0x3c(%ebx)

		// 将进程的下一条指令的指针指向进程的中断处理函数的入口位置
        tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0103c61:	e8 10 1b 00 00       	call   f0105776 <cpunum>
f0103c66:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c69:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103c6f:	8b 40 64             	mov    0x64(%eax),%eax
f0103c72:	89 43 30             	mov    %eax,0x30(%ebx)
	
		// 重新运行进程(将用户异常栈的值pop到寄存器)
        env_run(curenv);
f0103c75:	e8 fc 1a 00 00       	call   f0105776 <cpunum>
f0103c7a:	83 c4 04             	add    $0x4,%esp
f0103c7d:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c80:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103c86:	e8 98 f6 ff ff       	call   f0103323 <env_run>
	} 

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c8b:	8b 7b 30             	mov    0x30(%ebx),%edi
	curenv->env_id, fault_va, tf->tf_eip);
f0103c8e:	e8 e3 1a 00 00       	call   f0105776 <cpunum>
		// 重新运行进程(将用户异常栈的值pop到寄存器)
        env_run(curenv);
	} 

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c93:	57                   	push   %edi
f0103c94:	56                   	push   %esi
	curenv->env_id, fault_va, tf->tf_eip);
f0103c95:	6b c0 74             	imul   $0x74,%eax,%eax
		// 重新运行进程(将用户异常栈的值pop到寄存器)
        env_run(curenv);
	} 

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103c98:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103c9e:	ff 70 48             	pushl  0x48(%eax)
f0103ca1:	68 a0 73 10 f0       	push   $0xf01073a0
f0103ca6:	e8 c9 f8 ff ff       	call   f0103574 <cprintf>
	curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103cab:	89 1c 24             	mov    %ebx,(%esp)
f0103cae:	e8 83 fd ff ff       	call   f0103a36 <print_trapframe>
	env_destroy(curenv);
f0103cb3:	e8 be 1a 00 00       	call   f0105776 <cpunum>
f0103cb8:	83 c4 04             	add    $0x4,%esp
f0103cbb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cbe:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103cc4:	e8 bb f5 ff ff       	call   f0103284 <env_destroy>
}
f0103cc9:	83 c4 10             	add    $0x10,%esp
f0103ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103ccf:	5b                   	pop    %ebx
f0103cd0:	5e                   	pop    %esi
f0103cd1:	5f                   	pop    %edi
f0103cd2:	5d                   	pop    %ebp
f0103cd3:	c3                   	ret    

f0103cd4 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103cd4:	55                   	push   %ebp
f0103cd5:	89 e5                	mov    %esp,%ebp
f0103cd7:	57                   	push   %edi
f0103cd8:	56                   	push   %esi
f0103cd9:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103cdc:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103cdd:	83 3d 80 1e 21 f0 00 	cmpl   $0x0,0xf0211e80
f0103ce4:	74 01                	je     f0103ce7 <trap+0x13>
		asm volatile("hlt");
f0103ce6:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103ce7:	e8 8a 1a 00 00       	call   f0105776 <cpunum>
f0103cec:	6b d0 74             	imul   $0x74,%eax,%edx
f0103cef:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0103cf5:	b8 01 00 00 00       	mov    $0x1,%eax
f0103cfa:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103cfe:	83 f8 02             	cmp    $0x2,%eax
f0103d01:	75 10                	jne    f0103d13 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103d03:	83 ec 0c             	sub    $0xc,%esp
f0103d06:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103d0b:	e8 d4 1c 00 00       	call   f01059e4 <spin_lock>
f0103d10:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103d13:	9c                   	pushf  
f0103d14:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103d15:	f6 c4 02             	test   $0x2,%ah
f0103d18:	74 19                	je     f0103d33 <trap+0x5f>
f0103d1a:	68 d4 71 10 f0       	push   $0xf01071d4
f0103d1f:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0103d24:	68 3c 01 00 00       	push   $0x13c
f0103d29:	68 c8 71 10 f0       	push   $0xf01071c8
f0103d2e:	e8 0d c3 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103d33:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103d37:	83 e0 03             	and    $0x3,%eax
f0103d3a:	66 83 f8 03          	cmp    $0x3,%ax
f0103d3e:	0f 85 a0 00 00 00    	jne    f0103de4 <trap+0x110>
f0103d44:	83 ec 0c             	sub    $0xc,%esp
f0103d47:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103d4c:	e8 93 1c 00 00       	call   f01059e4 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0103d51:	e8 20 1a 00 00       	call   f0105776 <cpunum>
f0103d56:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d59:	83 c4 10             	add    $0x10,%esp
f0103d5c:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0103d63:	75 19                	jne    f0103d7e <trap+0xaa>
f0103d65:	68 ed 71 10 f0       	push   $0xf01071ed
f0103d6a:	68 8b 6c 10 f0       	push   $0xf0106c8b
f0103d6f:	68 44 01 00 00       	push   $0x144
f0103d74:	68 c8 71 10 f0       	push   $0xf01071c8
f0103d79:	e8 c2 c2 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103d7e:	e8 f3 19 00 00       	call   f0105776 <cpunum>
f0103d83:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d86:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103d8c:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103d90:	75 2d                	jne    f0103dbf <trap+0xeb>
			env_free(curenv);
f0103d92:	e8 df 19 00 00       	call   f0105776 <cpunum>
f0103d97:	83 ec 0c             	sub    $0xc,%esp
f0103d9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d9d:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103da3:	e8 36 f3 ff ff       	call   f01030de <env_free>
			curenv = NULL;
f0103da8:	e8 c9 19 00 00       	call   f0105776 <cpunum>
f0103dad:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db0:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f0103db7:	00 00 00 
			sched_yield();
f0103dba:	e8 a5 02 00 00       	call   f0104064 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103dbf:	e8 b2 19 00 00       	call   f0105776 <cpunum>
f0103dc4:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dc7:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103dcd:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103dd2:	89 c7                	mov    %eax,%edi
f0103dd4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103dd6:	e8 9b 19 00 00       	call   f0105776 <cpunum>
f0103ddb:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dde:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103de4:	89 35 60 1a 21 f0    	mov    %esi,0xf0211a60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103dea:	8b 46 28             	mov    0x28(%esi),%eax
f0103ded:	83 f8 27             	cmp    $0x27,%eax
f0103df0:	75 1d                	jne    f0103e0f <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f0103df2:	83 ec 0c             	sub    $0xc,%esp
f0103df5:	68 f4 71 10 f0       	push   $0xf01071f4
f0103dfa:	e8 75 f7 ff ff       	call   f0103574 <cprintf>
		print_trapframe(tf);
f0103dff:	89 34 24             	mov    %esi,(%esp)
f0103e02:	e8 2f fc ff ff       	call   f0103a36 <print_trapframe>
f0103e07:	83 c4 10             	add    $0x10,%esp
f0103e0a:	e9 c5 00 00 00       	jmp    f0103ed4 <trap+0x200>
	// 	panic("unhandled trap in kernel");
	// else {
	// 	env_destroy(curenv);
	// 	return;
	// }
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_KBD) {
f0103e0f:	83 f8 21             	cmp    $0x21,%eax
f0103e12:	75 0a                	jne    f0103e1e <trap+0x14a>
        kbd_intr();
f0103e14:	e8 e1 c7 ff ff       	call   f01005fa <kbd_intr>
f0103e19:	e9 b6 00 00 00       	jmp    f0103ed4 <trap+0x200>
        return;
    }
    if (tf->tf_trapno == IRQ_OFFSET + IRQ_SERIAL) {
f0103e1e:	83 f8 24             	cmp    $0x24,%eax
f0103e21:	75 0a                	jne    f0103e2d <trap+0x159>
        serial_intr();
f0103e23:	e8 b6 c7 ff ff       	call   f01005de <serial_intr>
f0103e28:	e9 a7 00 00 00       	jmp    f0103ed4 <trap+0x200>
        return;
    }

	switch(tf->tf_trapno){
f0103e2d:	83 f8 0e             	cmp    $0xe,%eax
f0103e30:	74 18                	je     f0103e4a <trap+0x176>
f0103e32:	83 f8 0e             	cmp    $0xe,%eax
f0103e35:	77 07                	ja     f0103e3e <trap+0x16a>
f0103e37:	83 f8 03             	cmp    $0x3,%eax
f0103e3a:	74 1c                	je     f0103e58 <trap+0x184>
f0103e3c:	eb 53                	jmp    f0103e91 <trap+0x1bd>
f0103e3e:	83 f8 20             	cmp    $0x20,%eax
f0103e41:	74 44                	je     f0103e87 <trap+0x1b3>
f0103e43:	83 f8 30             	cmp    $0x30,%eax
f0103e46:	74 1e                	je     f0103e66 <trap+0x192>
f0103e48:	eb 47                	jmp    f0103e91 <trap+0x1bd>
		case(T_PGFLT):
			page_fault_handler(tf);
f0103e4a:	83 ec 0c             	sub    $0xc,%esp
f0103e4d:	56                   	push   %esi
f0103e4e:	e8 6b fd ff ff       	call   f0103bbe <page_fault_handler>
f0103e53:	83 c4 10             	add    $0x10,%esp
f0103e56:	eb 7c                	jmp    f0103ed4 <trap+0x200>
			break;
		case(T_BRKPT):
			monitor(tf);
f0103e58:	83 ec 0c             	sub    $0xc,%esp
f0103e5b:	56                   	push   %esi
f0103e5c:	e8 58 ca ff ff       	call   f01008b9 <monitor>
f0103e61:	83 c4 10             	add    $0x10,%esp
f0103e64:	eb 6e                	jmp    f0103ed4 <trap+0x200>
			break;
		case (T_SYSCALL):
			//print_trapframe(tf);

			tf->tf_regs.reg_eax = syscall(
f0103e66:	83 ec 08             	sub    $0x8,%esp
f0103e69:	ff 76 04             	pushl  0x4(%esi)
f0103e6c:	ff 36                	pushl  (%esi)
f0103e6e:	ff 76 10             	pushl  0x10(%esi)
f0103e71:	ff 76 18             	pushl  0x18(%esi)
f0103e74:	ff 76 14             	pushl  0x14(%esi)
f0103e77:	ff 76 1c             	pushl  0x1c(%esi)
f0103e7a:	e8 98 02 00 00       	call   f0104117 <syscall>
f0103e7f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103e82:	83 c4 20             	add    $0x20,%esp
f0103e85:	eb 4d                	jmp    f0103ed4 <trap+0x200>
					tf->tf_regs.reg_ebx,
					tf->tf_regs.reg_edi,
					tf->tf_regs.reg_esi);
			break;
		case(IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();
f0103e87:	e8 35 1a 00 00       	call   f01058c1 <lapic_eoi>
			sched_yield();
f0103e8c:	e8 d3 01 00 00       	call   f0104064 <sched_yield>
			return;
		default:
			print_trapframe(tf);
f0103e91:	83 ec 0c             	sub    $0xc,%esp
f0103e94:	56                   	push   %esi
f0103e95:	e8 9c fb ff ff       	call   f0103a36 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0103e9a:	83 c4 10             	add    $0x10,%esp
f0103e9d:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103ea2:	75 17                	jne    f0103ebb <trap+0x1e7>
				panic("unhandled trap in kernel");
f0103ea4:	83 ec 04             	sub    $0x4,%esp
f0103ea7:	68 11 72 10 f0       	push   $0xf0107211
f0103eac:	68 20 01 00 00       	push   $0x120
f0103eb1:	68 c8 71 10 f0       	push   $0xf01071c8
f0103eb6:	e8 85 c1 ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f0103ebb:	e8 b6 18 00 00       	call   f0105776 <cpunum>
f0103ec0:	83 ec 0c             	sub    $0xc,%esp
f0103ec3:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ec6:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103ecc:	e8 b3 f3 ff ff       	call   f0103284 <env_destroy>
f0103ed1:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103ed4:	e8 9d 18 00 00       	call   f0105776 <cpunum>
f0103ed9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103edc:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f0103ee3:	74 2a                	je     f0103f0f <trap+0x23b>
f0103ee5:	e8 8c 18 00 00       	call   f0105776 <cpunum>
f0103eea:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eed:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0103ef3:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103ef7:	75 16                	jne    f0103f0f <trap+0x23b>
		env_run(curenv);
f0103ef9:	e8 78 18 00 00       	call   f0105776 <cpunum>
f0103efe:	83 ec 0c             	sub    $0xc,%esp
f0103f01:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f04:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0103f0a:	e8 14 f4 ff ff       	call   f0103323 <env_run>
	else
		sched_yield();
f0103f0f:	e8 50 01 00 00       	call   f0104064 <sched_yield>

f0103f14 <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
//中断处理程序生成
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0103f14:	6a 00                	push   $0x0
f0103f16:	6a 00                	push   $0x0
f0103f18:	eb 64                	jmp    f0103f7e <_alltraps>

f0103f1a <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0103f1a:	6a 00                	push   $0x0
f0103f1c:	6a 01                	push   $0x1
f0103f1e:	eb 5e                	jmp    f0103f7e <_alltraps>

f0103f20 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0103f20:	6a 00                	push   $0x0
f0103f22:	6a 02                	push   $0x2
f0103f24:	eb 58                	jmp    f0103f7e <_alltraps>

f0103f26 <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0103f26:	6a 00                	push   $0x0
f0103f28:	6a 03                	push   $0x3
f0103f2a:	eb 52                	jmp    f0103f7e <_alltraps>

f0103f2c <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0103f2c:	6a 00                	push   $0x0
f0103f2e:	6a 04                	push   $0x4
f0103f30:	eb 4c                	jmp    f0103f7e <_alltraps>

f0103f32 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0103f32:	6a 00                	push   $0x0
f0103f34:	6a 05                	push   $0x5
f0103f36:	eb 46                	jmp    f0103f7e <_alltraps>

f0103f38 <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0103f38:	6a 00                	push   $0x0
f0103f3a:	6a 06                	push   $0x6
f0103f3c:	eb 40                	jmp    f0103f7e <_alltraps>

f0103f3e <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0103f3e:	6a 00                	push   $0x0
f0103f40:	6a 07                	push   $0x7
f0103f42:	eb 3a                	jmp    f0103f7e <_alltraps>

f0103f44 <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f0103f44:	6a 08                	push   $0x8
f0103f46:	eb 36                	jmp    f0103f7e <_alltraps>

f0103f48 <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0103f48:	6a 0a                	push   $0xa
f0103f4a:	eb 32                	jmp    f0103f7e <_alltraps>

f0103f4c <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f0103f4c:	6a 0b                	push   $0xb
f0103f4e:	eb 2e                	jmp    f0103f7e <_alltraps>

f0103f50 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0103f50:	6a 0c                	push   $0xc
f0103f52:	eb 2a                	jmp    f0103f7e <_alltraps>

f0103f54 <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0103f54:	6a 0d                	push   $0xd
f0103f56:	eb 26                	jmp    f0103f7e <_alltraps>

f0103f58 <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f0103f58:	6a 0e                	push   $0xe
f0103f5a:	eb 22                	jmp    f0103f7e <_alltraps>

f0103f5c <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0103f5c:	6a 00                	push   $0x0
f0103f5e:	6a 10                	push   $0x10
f0103f60:	eb 1c                	jmp    f0103f7e <_alltraps>

f0103f62 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0103f62:	6a 11                	push   $0x11
f0103f64:	eb 18                	jmp    f0103f7e <_alltraps>

f0103f66 <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0103f66:	6a 00                	push   $0x0
f0103f68:	6a 12                	push   $0x12
f0103f6a:	eb 12                	jmp    f0103f7e <_alltraps>

f0103f6c <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0103f6c:	6a 00                	push   $0x0
f0103f6e:	6a 13                	push   $0x13
f0103f70:	eb 0c                	jmp    f0103f7e <_alltraps>

f0103f72 <t_syscall>:


TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0103f72:	6a 00                	push   $0x0
f0103f74:	6a 30                	push   $0x30
f0103f76:	eb 06                	jmp    f0103f7e <_alltraps>

f0103f78 <timer>:

TRAPHANDLER_NOEC(timer, IRQ_OFFSET + IRQ_TIMER);
f0103f78:	6a 00                	push   $0x0
f0103f7a:	6a 20                	push   $0x20
f0103f7c:	eb 00                	jmp    f0103f7e <_alltraps>

f0103f7e <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
 /*公有部分，压入顺序和trapframe有关，因为MIT要求构建Trapframe在堆栈中
,以供trap函数使用*/
_alltraps:
	pushl %ds
f0103f7e:	1e                   	push   %ds
	pushl %es
f0103f7f:	06                   	push   %es
	pushal 
f0103f80:	60                   	pusha  

	movl $GD_KD, %eax
f0103f81:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0103f86:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0103f88:	8e c0                	mov    %eax,%es

	push %esp
f0103f8a:	54                   	push   %esp
	call trap
f0103f8b:	e8 44 fd ff ff       	call   f0103cd4 <trap>

f0103f90 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103f90:	55                   	push   %ebp
f0103f91:	89 e5                	mov    %esp,%ebp
f0103f93:	83 ec 08             	sub    $0x8,%esp
f0103f96:	a1 48 12 21 f0       	mov    0xf0211248,%eax
f0103f9b:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103f9e:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103fa3:	8b 02                	mov    (%edx),%eax
f0103fa5:	83 e8 01             	sub    $0x1,%eax
f0103fa8:	83 f8 02             	cmp    $0x2,%eax
f0103fab:	76 10                	jbe    f0103fbd <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103fad:	83 c1 01             	add    $0x1,%ecx
f0103fb0:	83 c2 7c             	add    $0x7c,%edx
f0103fb3:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103fb9:	75 e8                	jne    f0103fa3 <sched_halt+0x13>
f0103fbb:	eb 08                	jmp    f0103fc5 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103fbd:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103fc3:	75 1f                	jne    f0103fe4 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0103fc5:	83 ec 0c             	sub    $0xc,%esp
f0103fc8:	68 30 74 10 f0       	push   $0xf0107430
f0103fcd:	e8 a2 f5 ff ff       	call   f0103574 <cprintf>
f0103fd2:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103fd5:	83 ec 0c             	sub    $0xc,%esp
f0103fd8:	6a 00                	push   $0x0
f0103fda:	e8 da c8 ff ff       	call   f01008b9 <monitor>
f0103fdf:	83 c4 10             	add    $0x10,%esp
f0103fe2:	eb f1                	jmp    f0103fd5 <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f0103fe4:	e8 8d 17 00 00       	call   f0105776 <cpunum>
f0103fe9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103fec:	c7 80 28 20 21 f0 00 	movl   $0x0,-0xfdedfd8(%eax)
f0103ff3:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f0103ff6:	a1 8c 1e 21 f0       	mov    0xf0211e8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103ffb:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104000:	77 12                	ja     f0104014 <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104002:	50                   	push   %eax
f0104003:	68 48 5e 10 f0       	push   $0xf0105e48
f0104008:	6a 4f                	push   $0x4f
f010400a:	68 59 74 10 f0       	push   $0xf0107459
f010400f:	e8 2c c0 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0104014:	05 00 00 00 10       	add    $0x10000000,%eax
f0104019:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f010401c:	e8 55 17 00 00       	call   f0105776 <cpunum>
f0104021:	6b d0 74             	imul   $0x74,%eax,%edx
f0104024:	81 c2 20 20 21 f0    	add    $0xf0212020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010402a:	b8 02 00 00 00       	mov    $0x2,%eax
f010402f:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104033:	83 ec 0c             	sub    $0xc,%esp
f0104036:	68 c0 f3 11 f0       	push   $0xf011f3c0
f010403b:	e8 41 1a 00 00       	call   f0105a81 <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104040:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104042:	e8 2f 17 00 00       	call   f0105776 <cpunum>
f0104047:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f010404a:	8b 80 30 20 21 f0    	mov    -0xfdedfd0(%eax),%eax
f0104050:	bd 00 00 00 00       	mov    $0x0,%ebp
f0104055:	89 c4                	mov    %eax,%esp
f0104057:	6a 00                	push   $0x0
f0104059:	6a 00                	push   $0x0
f010405b:	fb                   	sti    
f010405c:	f4                   	hlt    
f010405d:	eb fd                	jmp    f010405c <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f010405f:	83 c4 10             	add    $0x10,%esp
f0104062:	c9                   	leave  
f0104063:	c3                   	ret    

f0104064 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104064:	55                   	push   %ebp
f0104065:	89 e5                	mov    %esp,%ebp
f0104067:	53                   	push   %ebx
f0104068:	83 ec 04             	sub    $0x4,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, nexti = 0;
	if (curenv != NULL)
f010406b:	e8 06 17 00 00       	call   f0105776 <cpunum>
f0104070:	6b d0 74             	imul   $0x74,%eax,%edx
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, nexti = 0;
f0104073:	b8 00 00 00 00       	mov    $0x0,%eax
	if (curenv != NULL)
f0104078:	83 ba 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%edx)
f010407f:	74 19                	je     f010409a <sched_yield+0x36>
		nexti = (ENVX(curenv->env_id) + 1) % NENV;
f0104081:	e8 f0 16 00 00       	call   f0105776 <cpunum>
f0104086:	6b c0 74             	imul   $0x74,%eax,%eax
f0104089:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010408f:	8b 40 48             	mov    0x48(%eax),%eax
f0104092:	8d 40 01             	lea    0x1(%eax),%eax
f0104095:	25 ff 03 00 00       	and    $0x3ff,%eax
	
	// 轮询，找一个进程去运行
	for (i = 0; i < NENV; i++) {
		if (envs[nexti].env_status == ENV_RUNNABLE){
f010409a:	8b 0d 48 12 21 f0    	mov    0xf0211248,%ecx
f01040a0:	ba 00 04 00 00       	mov    $0x400,%edx
f01040a5:	6b d8 7c             	imul   $0x7c,%eax,%ebx
f01040a8:	01 cb                	add    %ecx,%ebx
f01040aa:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f01040ae:	75 09                	jne    f01040b9 <sched_yield+0x55>
			env_run(&envs[nexti]);
f01040b0:	83 ec 0c             	sub    $0xc,%esp
f01040b3:	53                   	push   %ebx
f01040b4:	e8 6a f2 ff ff       	call   f0103323 <env_run>
			return;
		}
		nexti = (nexti + 1) % NENV;
f01040b9:	83 c0 01             	add    $0x1,%eax
f01040bc:	89 c3                	mov    %eax,%ebx
f01040be:	c1 fb 1f             	sar    $0x1f,%ebx
f01040c1:	c1 eb 16             	shr    $0x16,%ebx
f01040c4:	01 d8                	add    %ebx,%eax
f01040c6:	25 ff 03 00 00       	and    $0x3ff,%eax
f01040cb:	29 d8                	sub    %ebx,%eax
	int i, nexti = 0;
	if (curenv != NULL)
		nexti = (ENVX(curenv->env_id) + 1) % NENV;
	
	// 轮询，找一个进程去运行
	for (i = 0; i < NENV; i++) {
f01040cd:	83 ea 01             	sub    $0x1,%edx
f01040d0:	75 d3                	jne    f01040a5 <sched_yield+0x41>
			return;
		}
		nexti = (nexti + 1) % NENV;
	}

	if (curenv != NULL && curenv->env_status == ENV_RUNNING){
f01040d2:	e8 9f 16 00 00       	call   f0105776 <cpunum>
f01040d7:	6b c0 74             	imul   $0x74,%eax,%eax
f01040da:	83 b8 28 20 21 f0 00 	cmpl   $0x0,-0xfdedfd8(%eax)
f01040e1:	74 2a                	je     f010410d <sched_yield+0xa9>
f01040e3:	e8 8e 16 00 00       	call   f0105776 <cpunum>
f01040e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01040eb:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01040f1:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01040f5:	75 16                	jne    f010410d <sched_yield+0xa9>
			env_run(curenv);
f01040f7:	e8 7a 16 00 00       	call   f0105776 <cpunum>
f01040fc:	83 ec 0c             	sub    $0xc,%esp
f01040ff:	6b c0 74             	imul   $0x74,%eax,%eax
f0104102:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104108:	e8 16 f2 ff ff       	call   f0103323 <env_run>
			return;
	}


	// sched_halt never returns
	sched_halt();
f010410d:	e8 7e fe ff ff       	call   f0103f90 <sched_halt>
}
f0104112:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0104115:	c9                   	leave  
f0104116:	c3                   	ret    

f0104117 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104117:	55                   	push   %ebp
f0104118:	89 e5                	mov    %esp,%ebp
f010411a:	57                   	push   %edi
f010411b:	56                   	push   %esi
f010411c:	53                   	push   %ebx
f010411d:	83 ec 1c             	sub    $0x1c,%esp
f0104120:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f0104123:	83 f8 0d             	cmp    $0xd,%eax
f0104126:	0f 87 29 05 00 00    	ja     f0104655 <syscall+0x53e>
f010412c:	ff 24 85 6c 74 10 f0 	jmp    *-0xfef8b94(,%eax,4)
	// Destroy the environment if not.

	// LAB 3: Your code here.
	//user_mem_assert(curenv, s, len, 0);
	//检查用户传送过来的指针
	user_mem_assert(curenv, s, len, PTE_U | PTE_P);	
f0104133:	e8 3e 16 00 00       	call   f0105776 <cpunum>
f0104138:	6a 05                	push   $0x5
f010413a:	ff 75 10             	pushl  0x10(%ebp)
f010413d:	ff 75 0c             	pushl  0xc(%ebp)
f0104140:	6b c0 74             	imul   $0x74,%eax,%eax
f0104143:	ff b0 28 20 21 f0    	pushl  -0xfdedfd8(%eax)
f0104149:	e8 39 eb ff ff       	call   f0102c87 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f010414e:	83 c4 0c             	add    $0xc,%esp
f0104151:	ff 75 0c             	pushl  0xc(%ebp)
f0104154:	ff 75 10             	pushl  0x10(%ebp)
f0104157:	68 66 74 10 f0       	push   $0xf0107466
f010415c:	e8 13 f4 ff ff       	call   f0103574 <cprintf>
f0104161:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *) a1, a2);
		return 0;
f0104164:	b8 00 00 00 00       	mov    $0x0,%eax
f0104169:	e9 f3 04 00 00       	jmp    f0104661 <syscall+0x54a>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f010416e:	e8 99 c4 ff ff       	call   f010060c <cons_getc>
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *) a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f0104173:	e9 e9 04 00 00       	jmp    f0104661 <syscall+0x54a>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104178:	83 ec 04             	sub    $0x4,%esp
f010417b:	6a 01                	push   $0x1
f010417d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104180:	50                   	push   %eax
f0104181:	ff 75 0c             	pushl  0xc(%ebp)
f0104184:	e8 b3 eb ff ff       	call   f0102d3c <envid2env>
f0104189:	83 c4 10             	add    $0x10,%esp
f010418c:	85 c0                	test   %eax,%eax
f010418e:	0f 88 cd 04 00 00    	js     f0104661 <syscall+0x54a>
		return r;
	env_destroy(e);
f0104194:	83 ec 0c             	sub    $0xc,%esp
f0104197:	ff 75 e4             	pushl  -0x1c(%ebp)
f010419a:	e8 e5 f0 ff ff       	call   f0103284 <env_destroy>
f010419f:	83 c4 10             	add    $0x10,%esp
	return 0;
f01041a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01041a7:	e9 b5 04 00 00       	jmp    f0104661 <syscall+0x54a>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01041ac:	e8 c5 15 00 00       	call   f0105776 <cpunum>
f01041b1:	6b c0 74             	imul   $0x74,%eax,%eax
f01041b4:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01041ba:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
	case SYS_getenvid:
		return sys_getenvid();
f01041bd:	e9 9f 04 00 00       	jmp    f0104661 <syscall+0x54a>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f01041c2:	e8 9d fe ff ff       	call   f0104064 <sched_yield>
	struct PageInfo *pp;
	int ret;

	//cprintf("id:--------%d\n",envid);

	if ((ret = envid2env(envid, &e, 1)) < 0)
f01041c7:	83 ec 04             	sub    $0x4,%esp
f01041ca:	6a 01                	push   $0x1
f01041cc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01041cf:	50                   	push   %eax
f01041d0:	ff 75 0c             	pushl  0xc(%ebp)
f01041d3:	e8 64 eb ff ff       	call   f0102d3c <envid2env>
f01041d8:	83 c4 10             	add    $0x10,%esp
f01041db:	85 c0                	test   %eax,%eax
f01041dd:	0f 88 7e 04 00 00    	js     f0104661 <syscall+0x54a>
		return ret;

	if (va >= (void *)UTOP || PGOFF(va) != 0)
f01041e3:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01041ea:	77 60                	ja     f010424c <syscall+0x135>
f01041ec:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01041f3:	75 61                	jne    f0104256 <syscall+0x13f>
		return -E_INVAL;

	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
f01041f5:	8b 45 14             	mov    0x14(%ebp),%eax
f01041f8:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01041fd:	83 f8 05             	cmp    $0x5,%eax
f0104200:	75 5e                	jne    f0104260 <syscall+0x149>
		return -E_INVAL;

	// 申请一个物理页
	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
f0104202:	83 ec 0c             	sub    $0xc,%esp
f0104205:	6a 01                	push   $0x1
f0104207:	e8 6e cc ff ff       	call   f0100e7a <page_alloc>
f010420c:	89 c3                	mov    %eax,%ebx
f010420e:	83 c4 10             	add    $0x10,%esp
f0104211:	85 c0                	test   %eax,%eax
f0104213:	74 55                	je     f010426a <syscall+0x153>
		return -E_NO_MEM;
	
	// 映射物理页到进程的虚拟空间中
	if ((ret = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
f0104215:	ff 75 14             	pushl  0x14(%ebp)
f0104218:	ff 75 10             	pushl  0x10(%ebp)
f010421b:	50                   	push   %eax
f010421c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010421f:	ff 70 60             	pushl  0x60(%eax)
f0104222:	e8 29 cf ff ff       	call   f0101150 <page_insert>
f0104227:	89 c6                	mov    %eax,%esi
f0104229:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return ret;
	}

	return 0;
f010422c:	b8 00 00 00 00       	mov    $0x0,%eax
	// 申请一个物理页
	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
		return -E_NO_MEM;
	
	// 映射物理页到进程的虚拟空间中
	if ((ret = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
f0104231:	85 f6                	test   %esi,%esi
f0104233:	0f 89 28 04 00 00    	jns    f0104661 <syscall+0x54a>
		page_free(pp);
f0104239:	83 ec 0c             	sub    $0xc,%esp
f010423c:	53                   	push   %ebx
f010423d:	e8 a8 cc ff ff       	call   f0100eea <page_free>
f0104242:	83 c4 10             	add    $0x10,%esp
		return ret;
f0104245:	89 f0                	mov    %esi,%eax
f0104247:	e9 15 04 00 00       	jmp    f0104661 <syscall+0x54a>

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (va >= (void *)UTOP || PGOFF(va) != 0)
		return -E_INVAL;
f010424c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104251:	e9 0b 04 00 00       	jmp    f0104661 <syscall+0x54a>
f0104256:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010425b:	e9 01 04 00 00       	jmp    f0104661 <syscall+0x54a>

	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;
f0104260:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104265:	e9 f7 03 00 00       	jmp    f0104661 <syscall+0x54a>

	// 申请一个物理页
	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
		return -E_NO_MEM;
f010426a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010426f:	e9 ed 03 00 00       	jmp    f0104661 <syscall+0x54a>
	struct Env *srcenv, *dstenv;
	struct PageInfo *pp;
	pte_t *pte;
	int ret;
	
	if ((ret = envid2env(srcenvid, &srcenv, 1)) < 0)
f0104274:	83 ec 04             	sub    $0x4,%esp
f0104277:	6a 01                	push   $0x1
f0104279:	8d 45 dc             	lea    -0x24(%ebp),%eax
f010427c:	50                   	push   %eax
f010427d:	ff 75 0c             	pushl  0xc(%ebp)
f0104280:	e8 b7 ea ff ff       	call   f0102d3c <envid2env>
f0104285:	83 c4 10             	add    $0x10,%esp
f0104288:	85 c0                	test   %eax,%eax
f010428a:	0f 88 d1 03 00 00    	js     f0104661 <syscall+0x54a>
		return ret;
	if ((ret = envid2env(dstenvid, &dstenv, 1)) < 0)
f0104290:	83 ec 04             	sub    $0x4,%esp
f0104293:	6a 01                	push   $0x1
f0104295:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104298:	50                   	push   %eax
f0104299:	ff 75 14             	pushl  0x14(%ebp)
f010429c:	e8 9b ea ff ff       	call   f0102d3c <envid2env>
f01042a1:	83 c4 10             	add    $0x10,%esp
f01042a4:	85 c0                	test   %eax,%eax
f01042a6:	0f 88 b5 03 00 00    	js     f0104661 <syscall+0x54a>
		return ret;

	if (srcva >= (void *) UTOP || PGOFF(srcva) != 0)
f01042ac:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f01042b3:	77 76                	ja     f010432b <syscall+0x214>
		return -E_INVAL;
	if (dstva >= (void *) UTOP || PGOFF(dstva) != 0)
f01042b5:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f01042bc:	75 77                	jne    f0104335 <syscall+0x21e>
f01042be:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f01042c5:	77 6e                	ja     f0104335 <syscall+0x21e>
f01042c7:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f01042ce:	75 6f                	jne    f010433f <syscall+0x228>
		return -E_INVAL;
	
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
f01042d0:	8b 45 1c             	mov    0x1c(%ebp),%eax
f01042d3:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01042d8:	83 f8 05             	cmp    $0x5,%eax
f01042db:	75 6c                	jne    f0104349 <syscall+0x232>
		return -E_INVAL;
	
	// 查到进程 srcenv 的虚拟地址srcva对应的物理页
	if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f01042dd:	83 ec 04             	sub    $0x4,%esp
f01042e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01042e3:	50                   	push   %eax
f01042e4:	ff 75 10             	pushl  0x10(%ebp)
f01042e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01042ea:	ff 70 60             	pushl  0x60(%eax)
f01042ed:	e8 74 cd ff ff       	call   f0101066 <page_lookup>
f01042f2:	83 c4 10             	add    $0x10,%esp
f01042f5:	85 c0                	test   %eax,%eax
f01042f7:	74 5a                	je     f0104353 <syscall+0x23c>
		return -E_INVAL;

	if ((perm & PTE_W) && !(*pte & PTE_W))
f01042f9:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f01042fd:	74 08                	je     f0104307 <syscall+0x1f0>
f01042ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104302:	f6 02 02             	testb  $0x2,(%edx)
f0104305:	74 56                	je     f010435d <syscall+0x246>
		return -E_INVAL;
	
	
	// 将进程虚拟地址 dstva 对应的虚拟页映射到物理页pp 
	if ((ret = page_insert(dstenv->env_pgdir, pp, dstva, perm)) < 0)
f0104307:	ff 75 1c             	pushl  0x1c(%ebp)
f010430a:	ff 75 18             	pushl  0x18(%ebp)
f010430d:	50                   	push   %eax
f010430e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104311:	ff 70 60             	pushl  0x60(%eax)
f0104314:	e8 37 ce ff ff       	call   f0101150 <page_insert>
f0104319:	83 c4 10             	add    $0x10,%esp
f010431c:	85 c0                	test   %eax,%eax
f010431e:	ba 00 00 00 00       	mov    $0x0,%edx
f0104323:	0f 4f c2             	cmovg  %edx,%eax
f0104326:	e9 36 03 00 00       	jmp    f0104661 <syscall+0x54a>
		return ret;
	if ((ret = envid2env(dstenvid, &dstenv, 1)) < 0)
		return ret;

	if (srcva >= (void *) UTOP || PGOFF(srcva) != 0)
		return -E_INVAL;
f010432b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104330:	e9 2c 03 00 00       	jmp    f0104661 <syscall+0x54a>
	if (dstva >= (void *) UTOP || PGOFF(dstva) != 0)
		return -E_INVAL;
f0104335:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010433a:	e9 22 03 00 00       	jmp    f0104661 <syscall+0x54a>
f010433f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104344:	e9 18 03 00 00       	jmp    f0104661 <syscall+0x54a>
	
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;
f0104349:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010434e:	e9 0e 03 00 00       	jmp    f0104661 <syscall+0x54a>
	
	// 查到进程 srcenv 的虚拟地址srcva对应的物理页
	if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
f0104353:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104358:	e9 04 03 00 00       	jmp    f0104661 <syscall+0x54a>

	if ((perm & PTE_W) && !(*pte & PTE_W))
		return -E_INVAL;
f010435d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		sys_yield();
		return 0;
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *) a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
f0104362:	e9 fa 02 00 00       	jmp    f0104661 <syscall+0x54a>
	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");
	struct Env* e;
	int ret;

	if ((ret = envid2env(envid, &e, 1)) < 0)
f0104367:	83 ec 04             	sub    $0x4,%esp
f010436a:	6a 01                	push   $0x1
f010436c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010436f:	50                   	push   %eax
f0104370:	ff 75 0c             	pushl  0xc(%ebp)
f0104373:	e8 c4 e9 ff ff       	call   f0102d3c <envid2env>
f0104378:	83 c4 10             	add    $0x10,%esp
f010437b:	85 c0                	test   %eax,%eax
f010437d:	0f 88 de 02 00 00    	js     f0104661 <syscall+0x54a>
		return ret;

	if (va >= (void *) UTOP || PGOFF(va) != 0)
f0104383:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010438a:	77 27                	ja     f01043b3 <syscall+0x29c>
f010438c:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104393:	75 28                	jne    f01043bd <syscall+0x2a6>
		return -E_INVAL;
	
	// 解除映射
	page_remove(e->env_pgdir, va);
f0104395:	83 ec 08             	sub    $0x8,%esp
f0104398:	ff 75 10             	pushl  0x10(%ebp)
f010439b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010439e:	ff 70 60             	pushl  0x60(%eax)
f01043a1:	e8 5a cd ff ff       	call   f0101100 <page_remove>
f01043a6:	83 c4 10             	add    $0x10,%esp

	return 0;
f01043a9:	b8 00 00 00 00       	mov    $0x0,%eax
f01043ae:	e9 ae 02 00 00       	jmp    f0104661 <syscall+0x54a>

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (va >= (void *) UTOP || PGOFF(va) != 0)
		return -E_INVAL;
f01043b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01043b8:	e9 a4 02 00 00       	jmp    f0104661 <syscall+0x54a>
f01043bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *) a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *) a2);
f01043c2:	e9 9a 02 00 00       	jmp    f0104661 <syscall+0x54a>
	// LAB 4: Your code here.
	//panic("sys_exofork not implemented");

	struct Env *e;
	// 申请一个新进程
	int ret = env_alloc(&e, curenv->env_id);
f01043c7:	e8 aa 13 00 00       	call   f0105776 <cpunum>
f01043cc:	83 ec 08             	sub    $0x8,%esp
f01043cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01043d2:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01043d8:	ff 70 48             	pushl  0x48(%eax)
f01043db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01043de:	50                   	push   %eax
f01043df:	e8 6a ea ff ff       	call   f0102e4e <env_alloc>
	if (ret < 0) 
f01043e4:	83 c4 10             	add    $0x10,%esp
f01043e7:	85 c0                	test   %eax,%eax
f01043e9:	0f 88 72 02 00 00    	js     f0104661 <syscall+0x54a>
		return ret;
	
	// 初始化新进程
	e->env_status = ENV_NOT_RUNNABLE;
f01043ef:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01043f2:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f01043f9:	e8 78 13 00 00       	call   f0105776 <cpunum>
f01043fe:	6b c0 74             	imul   $0x74,%eax,%eax
f0104401:	8b b0 28 20 21 f0    	mov    -0xfdedfd8(%eax),%esi
f0104407:	b9 11 00 00 00       	mov    $0x11,%ecx
f010440c:	89 df                	mov    %ebx,%edi
f010440e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// 将子进程的返回值设置为0
	e->env_tf.tf_regs.reg_eax = 0;
f0104410:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104413:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return e->env_id;
f010441a:	8b 40 48             	mov    0x48(%eax),%eax
f010441d:	e9 3f 02 00 00       	jmp    f0104661 <syscall+0x54a>

	// LAB 4: Your code here.
	struct Env *e;
	int ret;

	if ((ret = envid2env(envid, &e, 1)) < 0)
f0104422:	83 ec 04             	sub    $0x4,%esp
f0104425:	6a 01                	push   $0x1
f0104427:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010442a:	50                   	push   %eax
f010442b:	ff 75 0c             	pushl  0xc(%ebp)
f010442e:	e8 09 e9 ff ff       	call   f0102d3c <envid2env>
f0104433:	83 c4 10             	add    $0x10,%esp
f0104436:	85 c0                	test   %eax,%eax
f0104438:	0f 88 23 02 00 00    	js     f0104661 <syscall+0x54a>
		return ret;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f010443e:	8b 45 10             	mov    0x10(%ebp),%eax
f0104441:	83 e8 02             	sub    $0x2,%eax
f0104444:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f0104449:	75 13                	jne    f010445e <syscall+0x347>
		return -E_INVAL;

	e->env_status = status;
f010444b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010444e:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104451:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f0104454:	b8 00 00 00 00       	mov    $0x0,%eax
f0104459:	e9 03 02 00 00       	jmp    f0104661 <syscall+0x54a>

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f010445e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *) a2);
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
f0104463:	e9 f9 01 00 00       	jmp    f0104661 <syscall+0x54a>
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *e;
	int ret;
	
	if ((ret = envid2env(envid, &e, 1)) < 0)
f0104468:	83 ec 04             	sub    $0x4,%esp
f010446b:	6a 01                	push   $0x1
f010446d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104470:	50                   	push   %eax
f0104471:	ff 75 0c             	pushl  0xc(%ebp)
f0104474:	e8 c3 e8 ff ff       	call   f0102d3c <envid2env>
f0104479:	83 c4 10             	add    $0x10,%esp
f010447c:	85 c0                	test   %eax,%eax
f010447e:	0f 88 dd 01 00 00    	js     f0104661 <syscall+0x54a>
		return ret;

	e->env_pgfault_upcall = func;
f0104484:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104487:	8b 7d 10             	mov    0x10(%ebp),%edi
f010448a:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f010448d:	b8 00 00 00 00       	mov    $0x0,%eax
f0104492:	e9 ca 01 00 00       	jmp    f0104661 <syscall+0x54a>
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
	struct Env *env;
	int r;
	if ((r = envid2env(envid, &env, 0)) < 0)
f0104497:	83 ec 04             	sub    $0x4,%esp
f010449a:	6a 00                	push   $0x0
f010449c:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010449f:	50                   	push   %eax
f01044a0:	ff 75 0c             	pushl  0xc(%ebp)
f01044a3:	e8 94 e8 ff ff       	call   f0102d3c <envid2env>
f01044a8:	83 c4 10             	add    $0x10,%esp
f01044ab:	85 c0                	test   %eax,%eax
f01044ad:	0f 88 fb 00 00 00    	js     f01045ae <syscall+0x497>
		return -E_BAD_ENV;
	if (env->env_ipc_recving == 0)
f01044b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01044b6:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f01044ba:	0f 84 f8 00 00 00    	je     f01045b8 <syscall+0x4a1>
		return -E_IPC_NOT_RECV;
	if (srcva < (void *) UTOP) {
f01044c0:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f01044c7:	0f 87 a5 00 00 00    	ja     f0104572 <syscall+0x45b>

		// if (perm & (~(PTE_U | PTE_P | PTE_AVAIL | PTE_W)))
		// 	return -E_INVAL;

		if (srcva != ROUNDDOWN(srcva, PGSIZE))
			return -E_INVAL;
f01044cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		// 	return -E_INVAL;

		// if (perm & (~(PTE_U | PTE_P | PTE_AVAIL | PTE_W)))
		// 	return -E_INVAL;

		if (srcva != ROUNDDOWN(srcva, PGSIZE))
f01044d2:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01044d9:	0f 85 82 01 00 00    	jne    f0104661 <syscall+0x54a>
		
		// 根据发送者(当前进程)提供的虚拟地址找到对应的物理页，再将该物理页映射到接受者的虚拟空间

		pte_t *pte;
		// 1.根据发送者提供的虚拟地址查找发送内容所在的物理页
		struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
f01044df:	e8 92 12 00 00       	call   f0105776 <cpunum>
f01044e4:	83 ec 04             	sub    $0x4,%esp
f01044e7:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01044ea:	52                   	push   %edx
f01044eb:	ff 75 14             	pushl  0x14(%ebp)
f01044ee:	6b c0 74             	imul   $0x74,%eax,%eax
f01044f1:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01044f7:	ff 70 60             	pushl  0x60(%eax)
f01044fa:	e8 67 cb ff ff       	call   f0101066 <page_lookup>
f01044ff:	89 c2                	mov    %eax,%edx
		if (!page)
f0104501:	83 c4 10             	add    $0x10,%esp
f0104504:	85 c0                	test   %eax,%eax
f0104506:	74 56                	je     f010455e <syscall+0x447>
			return -E_INVAL;

		if((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0)
f0104508:	8b 4d 18             	mov    0x18(%ebp),%ecx
f010450b:	81 e1 fd f1 ff ff    	and    $0xfffff1fd,%ecx
            return -E_INVAL;
f0104511:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		// 1.根据发送者提供的虚拟地址查找发送内容所在的物理页
		struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!page)
			return -E_INVAL;

		if((perm & PTE_U) == 0 || (perm & PTE_P) == 0 || (perm & ~PTE_SYSCALL) != 0)
f0104516:	83 f9 05             	cmp    $0x5,%ecx
f0104519:	0f 85 42 01 00 00    	jne    f0104661 <syscall+0x54a>
            return -E_INVAL;

		if ((perm & PTE_W) && !(*pte & PTE_W))
f010451f:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104523:	74 0c                	je     f0104531 <syscall+0x41a>
f0104525:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104528:	f6 01 02             	testb  $0x2,(%ecx)
f010452b:	0f 84 30 01 00 00    	je     f0104661 <syscall+0x54a>
			return -E_INVAL;
		// 2.将物理页映射到接受者的虚拟空间中
		if (env->env_ipc_dstva < (void *) UTOP) {
f0104531:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104534:	8b 48 6c             	mov    0x6c(%eax),%ecx
f0104537:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f010453d:	77 33                	ja     f0104572 <syscall+0x45b>
			if ((r = page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) < 0)
f010453f:	ff 75 18             	pushl  0x18(%ebp)
f0104542:	51                   	push   %ecx
f0104543:	52                   	push   %edx
f0104544:	ff 70 60             	pushl  0x60(%eax)
f0104547:	e8 04 cc ff ff       	call   f0101150 <page_insert>
f010454c:	83 c4 10             	add    $0x10,%esp
f010454f:	85 c0                	test   %eax,%eax
f0104551:	78 15                	js     f0104568 <syscall+0x451>
				return -E_NO_MEM;
			env->env_ipc_perm = perm;
f0104553:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104556:	8b 7d 18             	mov    0x18(%ebp),%edi
f0104559:	89 78 78             	mov    %edi,0x78(%eax)
f010455c:	eb 14                	jmp    f0104572 <syscall+0x45b>

		pte_t *pte;
		// 1.根据发送者提供的虚拟地址查找发送内容所在的物理页
		struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!page)
			return -E_INVAL;
f010455e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104563:	e9 f9 00 00 00       	jmp    f0104661 <syscall+0x54a>
		if ((perm & PTE_W) && !(*pte & PTE_W))
			return -E_INVAL;
		// 2.将物理页映射到接受者的虚拟空间中
		if (env->env_ipc_dstva < (void *) UTOP) {
			if ((r = page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) < 0)
				return -E_NO_MEM;
f0104568:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010456d:	e9 ef 00 00 00       	jmp    f0104661 <syscall+0x54a>
			env->env_ipc_perm = perm;
		}
	}
	// 3.更新接受者的信息，通知其消息已经发送
	env->env_ipc_recving = 0;
f0104572:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104575:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env->env_ipc_from = curenv->env_id;
f0104579:	e8 f8 11 00 00       	call   f0105776 <cpunum>
f010457e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104581:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f0104587:	8b 40 48             	mov    0x48(%eax),%eax
f010458a:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f010458d:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104590:	8b 5d 10             	mov    0x10(%ebp),%ebx
f0104593:	89 58 70             	mov    %ebx,0x70(%eax)
	// 将接受进程设置为ENV_RUNNABLE，使得其可以重新参与调度
	env->env_status = ENV_RUNNABLE;
f0104596:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	// ???
	env->env_tf.tf_regs.reg_eax = 0;
f010459d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f01045a4:	b8 00 00 00 00       	mov    $0x0,%eax
f01045a9:	e9 b3 00 00 00       	jmp    f0104661 <syscall+0x54a>
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
	struct Env *env;
	int r;
	if ((r = envid2env(envid, &env, 0)) < 0)
		return -E_BAD_ENV;
f01045ae:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f01045b3:	e9 a9 00 00 00       	jmp    f0104661 <syscall+0x54a>
	if (env->env_ipc_recving == 0)
		return -E_IPC_NOT_RECV;
f01045b8:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *) a2);	
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
f01045bd:	e9 9f 00 00 00       	jmp    f0104661 <syscall+0x54a>
// 参数为接受消息的虚拟页的起始地址
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void *) UTOP && dstva != ROUNDDOWN(dstva, PGSIZE))
f01045c2:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f01045c9:	77 0d                	ja     f01045d8 <syscall+0x4c1>
f01045cb:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01045d2:	0f 85 84 00 00 00    	jne    f010465c <syscall+0x545>
		return -E_INVAL;
	
	curenv->env_ipc_recving = 1;
f01045d8:	e8 99 11 00 00       	call   f0105776 <cpunum>
f01045dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01045e0:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01045e6:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f01045ea:	e8 87 11 00 00       	call   f0105776 <cpunum>
f01045ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01045f2:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f01045f8:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01045fb:	89 78 6c             	mov    %edi,0x6c(%eax)
	// 设置当前进程为
	curenv->env_status = ENV_NOT_RUNNABLE;
f01045fe:	e8 73 11 00 00       	call   f0105776 <cpunum>
f0104603:	6b c0 74             	imul   $0x74,%eax,%eax
f0104606:	8b 80 28 20 21 f0    	mov    -0xfdedfd8(%eax),%eax
f010460c:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104613:	e8 4c fa ff ff       	call   f0104064 <sched_yield>
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *) a1);
	case SYS_env_set_trapframe:
		return sys_env_set_trapframe(a1, (struct Trapframe *) a2);
f0104618:	8b 75 10             	mov    0x10(%ebp),%esi
{
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
f010461b:	83 ec 04             	sub    $0x4,%esp
f010461e:	6a 01                	push   $0x1
f0104620:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104623:	50                   	push   %eax
f0104624:	ff 75 0c             	pushl  0xc(%ebp)
f0104627:	e8 10 e7 ff ff       	call   f0102d3c <envid2env>
f010462c:	83 c4 10             	add    $0x10,%esp
f010462f:	85 c0                	test   %eax,%eax
f0104631:	78 1b                	js     f010464e <syscall+0x537>
		return -E_BAD_ENV;

 	// if (tf->tf_eip >= UTOP)
 	// 	return 
 	env->env_tf = *tf;
f0104633:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010463b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
 	env->env_tf.tf_eflags |= FL_IF;
f010463d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104640:	81 48 38 00 02 00 00 	orl    $0x200,0x38(%eax)

	return 0;
f0104647:	b8 00 00 00 00       	mov    $0x0,%eax
f010464c:	eb 13                	jmp    f0104661 <syscall+0x54a>
	// LAB 5: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *env;
	if (envid2env(envid, &env, 1) < 0)
		return -E_BAD_ENV;
f010464e:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *) a1);
	case SYS_env_set_trapframe:
		return sys_env_set_trapframe(a1, (struct Trapframe *) a2);
f0104653:	eb 0c                	jmp    f0104661 <syscall+0x54a>
	default:
		return -E_INVAL;
f0104655:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010465a:	eb 05                	jmp    f0104661 <syscall+0x54a>
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *) a2);	
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *) a1);
f010465c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return sys_env_set_trapframe(a1, (struct Trapframe *) a2);
	default:
		return -E_INVAL;
	}
	panic("syscall not implemented");
}
f0104661:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104664:	5b                   	pop    %ebx
f0104665:	5e                   	pop    %esi
f0104666:	5f                   	pop    %edi
f0104667:	5d                   	pop    %ebp
f0104668:	c3                   	ret    

f0104669 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104669:	55                   	push   %ebp
f010466a:	89 e5                	mov    %esp,%ebp
f010466c:	57                   	push   %edi
f010466d:	56                   	push   %esi
f010466e:	53                   	push   %ebx
f010466f:	83 ec 14             	sub    $0x14,%esp
f0104672:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104675:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f0104678:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f010467b:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f010467e:	8b 1a                	mov    (%edx),%ebx
f0104680:	8b 01                	mov    (%ecx),%eax
f0104682:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104685:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f010468c:	eb 7f                	jmp    f010470d <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f010468e:	8b 45 f0             	mov    -0x10(%ebp),%eax
f0104691:	01 d8                	add    %ebx,%eax
f0104693:	89 c6                	mov    %eax,%esi
f0104695:	c1 ee 1f             	shr    $0x1f,%esi
f0104698:	01 c6                	add    %eax,%esi
f010469a:	d1 fe                	sar    %esi
f010469c:	8d 04 76             	lea    (%esi,%esi,2),%eax
f010469f:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01046a2:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01046a5:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01046a7:	eb 03                	jmp    f01046ac <stab_binsearch+0x43>
			m--;
f01046a9:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01046ac:	39 c3                	cmp    %eax,%ebx
f01046ae:	7f 0d                	jg     f01046bd <stab_binsearch+0x54>
f01046b0:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01046b4:	83 ea 0c             	sub    $0xc,%edx
f01046b7:	39 f9                	cmp    %edi,%ecx
f01046b9:	75 ee                	jne    f01046a9 <stab_binsearch+0x40>
f01046bb:	eb 05                	jmp    f01046c2 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01046bd:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01046c0:	eb 4b                	jmp    f010470d <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01046c2:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01046c5:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01046c8:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f01046cc:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01046cf:	76 11                	jbe    f01046e2 <stab_binsearch+0x79>
			*region_left = m;
f01046d1:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f01046d4:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f01046d6:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01046d9:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01046e0:	eb 2b                	jmp    f010470d <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f01046e2:	39 55 0c             	cmp    %edx,0xc(%ebp)
f01046e5:	73 14                	jae    f01046fb <stab_binsearch+0x92>
			*region_right = m - 1;
f01046e7:	83 e8 01             	sub    $0x1,%eax
f01046ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01046ed:	8b 75 e0             	mov    -0x20(%ebp),%esi
f01046f0:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f01046f2:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f01046f9:	eb 12                	jmp    f010470d <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f01046fb:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01046fe:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104700:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104704:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104706:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f010470d:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104710:	0f 8e 78 ff ff ff    	jle    f010468e <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104716:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010471a:	75 0f                	jne    f010472b <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f010471c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010471f:	8b 00                	mov    (%eax),%eax
f0104721:	83 e8 01             	sub    $0x1,%eax
f0104724:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104727:	89 06                	mov    %eax,(%esi)
f0104729:	eb 2c                	jmp    f0104757 <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010472b:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010472e:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104730:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104733:	8b 0e                	mov    (%esi),%ecx
f0104735:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104738:	8b 75 ec             	mov    -0x14(%ebp),%esi
f010473b:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010473e:	eb 03                	jmp    f0104743 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104740:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104743:	39 c8                	cmp    %ecx,%eax
f0104745:	7e 0b                	jle    f0104752 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f0104747:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f010474b:	83 ea 0c             	sub    $0xc,%edx
f010474e:	39 df                	cmp    %ebx,%edi
f0104750:	75 ee                	jne    f0104740 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104752:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104755:	89 06                	mov    %eax,(%esi)
	}
}
f0104757:	83 c4 14             	add    $0x14,%esp
f010475a:	5b                   	pop    %ebx
f010475b:	5e                   	pop    %esi
f010475c:	5f                   	pop    %edi
f010475d:	5d                   	pop    %ebp
f010475e:	c3                   	ret    

f010475f <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f010475f:	55                   	push   %ebp
f0104760:	89 e5                	mov    %esp,%ebp
f0104762:	57                   	push   %edi
f0104763:	56                   	push   %esi
f0104764:	53                   	push   %ebx
f0104765:	83 ec 2c             	sub    $0x2c,%esp
f0104768:	8b 7d 08             	mov    0x8(%ebp),%edi
f010476b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f010476e:	c7 06 a4 74 10 f0    	movl   $0xf01074a4,(%esi)
	info->eip_line = 0;
f0104774:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f010477b:	c7 46 08 a4 74 10 f0 	movl   $0xf01074a4,0x8(%esi)
	info->eip_fn_namelen = 9;
f0104782:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f0104789:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f010478c:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104793:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0104799:	77 21                	ja     f01047bc <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f010479b:	a1 00 00 20 00       	mov    0x200000,%eax
f01047a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f01047a3:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01047a8:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f01047ae:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f01047b1:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f01047b7:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01047ba:	eb 1a                	jmp    f01047d6 <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01047bc:	c7 45 d0 5b 4f 11 f0 	movl   $0xf0114f5b,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01047c3:	c7 45 cc 79 18 11 f0 	movl   $0xf0111879,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01047ca:	b8 78 18 11 f0       	mov    $0xf0111878,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f01047cf:	c7 45 d4 50 7a 10 f0 	movl   $0xf0107a50,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f01047d6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01047d9:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f01047dc:	0f 83 2b 01 00 00    	jae    f010490d <debuginfo_eip+0x1ae>
f01047e2:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f01047e6:	0f 85 28 01 00 00    	jne    f0104914 <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f01047ec:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f01047f3:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01047f6:	29 d8                	sub    %ebx,%eax
f01047f8:	c1 f8 02             	sar    $0x2,%eax
f01047fb:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104801:	83 e8 01             	sub    $0x1,%eax
f0104804:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104807:	57                   	push   %edi
f0104808:	6a 64                	push   $0x64
f010480a:	8d 45 e0             	lea    -0x20(%ebp),%eax
f010480d:	89 c1                	mov    %eax,%ecx
f010480f:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104812:	89 d8                	mov    %ebx,%eax
f0104814:	e8 50 fe ff ff       	call   f0104669 <stab_binsearch>
	if (lfile == 0)
f0104819:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010481c:	83 c4 08             	add    $0x8,%esp
f010481f:	85 c0                	test   %eax,%eax
f0104821:	0f 84 f4 00 00 00    	je     f010491b <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104827:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010482a:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010482d:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104830:	57                   	push   %edi
f0104831:	6a 24                	push   $0x24
f0104833:	8d 45 d8             	lea    -0x28(%ebp),%eax
f0104836:	89 c1                	mov    %eax,%ecx
f0104838:	8d 55 dc             	lea    -0x24(%ebp),%edx
f010483b:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f010483e:	89 d8                	mov    %ebx,%eax
f0104840:	e8 24 fe ff ff       	call   f0104669 <stab_binsearch>

	if (lfun <= rfun) {
f0104845:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104848:	83 c4 08             	add    $0x8,%esp
f010484b:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f010484e:	7f 24                	jg     f0104874 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104850:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104853:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104856:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f0104859:	8b 02                	mov    (%edx),%eax
f010485b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010485e:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104861:	29 f9                	sub    %edi,%ecx
f0104863:	39 c8                	cmp    %ecx,%eax
f0104865:	73 05                	jae    f010486c <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104867:	01 f8                	add    %edi,%eax
f0104869:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f010486c:	8b 42 08             	mov    0x8(%edx),%eax
f010486f:	89 46 10             	mov    %eax,0x10(%esi)
f0104872:	eb 06                	jmp    f010487a <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104874:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f0104877:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010487a:	83 ec 08             	sub    $0x8,%esp
f010487d:	6a 3a                	push   $0x3a
f010487f:	ff 76 08             	pushl  0x8(%esi)
f0104882:	e8 b2 08 00 00       	call   f0105139 <strfind>
f0104887:	2b 46 08             	sub    0x8(%esi),%eax
f010488a:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f010488d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104890:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104893:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0104896:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0104899:	83 c4 10             	add    $0x10,%esp
f010489c:	eb 06                	jmp    f01048a4 <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f010489e:	83 eb 01             	sub    $0x1,%ebx
f01048a1:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01048a4:	39 fb                	cmp    %edi,%ebx
f01048a6:	7c 2d                	jl     f01048d5 <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f01048a8:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01048ac:	80 fa 84             	cmp    $0x84,%dl
f01048af:	74 0b                	je     f01048bc <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01048b1:	80 fa 64             	cmp    $0x64,%dl
f01048b4:	75 e8                	jne    f010489e <debuginfo_eip+0x13f>
f01048b6:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01048ba:	74 e2                	je     f010489e <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01048bc:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01048bf:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01048c2:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01048c5:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01048c8:	8b 7d cc             	mov    -0x34(%ebp),%edi
f01048cb:	29 f8                	sub    %edi,%eax
f01048cd:	39 c2                	cmp    %eax,%edx
f01048cf:	73 04                	jae    f01048d5 <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f01048d1:	01 fa                	add    %edi,%edx
f01048d3:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01048d5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f01048d8:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01048db:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f01048e0:	39 cb                	cmp    %ecx,%ebx
f01048e2:	7d 43                	jge    f0104927 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f01048e4:	8d 53 01             	lea    0x1(%ebx),%edx
f01048e7:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01048ea:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01048ed:	8d 04 87             	lea    (%edi,%eax,4),%eax
f01048f0:	eb 07                	jmp    f01048f9 <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f01048f2:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f01048f6:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f01048f9:	39 ca                	cmp    %ecx,%edx
f01048fb:	74 25                	je     f0104922 <debuginfo_eip+0x1c3>
f01048fd:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104900:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104904:	74 ec                	je     f01048f2 <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104906:	b8 00 00 00 00       	mov    $0x0,%eax
f010490b:	eb 1a                	jmp    f0104927 <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f010490d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104912:	eb 13                	jmp    f0104927 <debuginfo_eip+0x1c8>
f0104914:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104919:	eb 0c                	jmp    f0104927 <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f010491b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104920:	eb 05                	jmp    f0104927 <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104922:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104927:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010492a:	5b                   	pop    %ebx
f010492b:	5e                   	pop    %esi
f010492c:	5f                   	pop    %edi
f010492d:	5d                   	pop    %ebp
f010492e:	c3                   	ret    

f010492f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f010492f:	55                   	push   %ebp
f0104930:	89 e5                	mov    %esp,%ebp
f0104932:	57                   	push   %edi
f0104933:	56                   	push   %esi
f0104934:	53                   	push   %ebx
f0104935:	83 ec 1c             	sub    $0x1c,%esp
f0104938:	89 c7                	mov    %eax,%edi
f010493a:	89 d6                	mov    %edx,%esi
f010493c:	8b 45 08             	mov    0x8(%ebp),%eax
f010493f:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104942:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104945:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104948:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010494b:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104950:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104953:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f0104956:	39 d3                	cmp    %edx,%ebx
f0104958:	72 05                	jb     f010495f <printnum+0x30>
f010495a:	39 45 10             	cmp    %eax,0x10(%ebp)
f010495d:	77 45                	ja     f01049a4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f010495f:	83 ec 0c             	sub    $0xc,%esp
f0104962:	ff 75 18             	pushl  0x18(%ebp)
f0104965:	8b 45 14             	mov    0x14(%ebp),%eax
f0104968:	8d 58 ff             	lea    -0x1(%eax),%ebx
f010496b:	53                   	push   %ebx
f010496c:	ff 75 10             	pushl  0x10(%ebp)
f010496f:	83 ec 08             	sub    $0x8,%esp
f0104972:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104975:	ff 75 e0             	pushl  -0x20(%ebp)
f0104978:	ff 75 dc             	pushl  -0x24(%ebp)
f010497b:	ff 75 d8             	pushl  -0x28(%ebp)
f010497e:	e8 ed 11 00 00       	call   f0105b70 <__udivdi3>
f0104983:	83 c4 18             	add    $0x18,%esp
f0104986:	52                   	push   %edx
f0104987:	50                   	push   %eax
f0104988:	89 f2                	mov    %esi,%edx
f010498a:	89 f8                	mov    %edi,%eax
f010498c:	e8 9e ff ff ff       	call   f010492f <printnum>
f0104991:	83 c4 20             	add    $0x20,%esp
f0104994:	eb 18                	jmp    f01049ae <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104996:	83 ec 08             	sub    $0x8,%esp
f0104999:	56                   	push   %esi
f010499a:	ff 75 18             	pushl  0x18(%ebp)
f010499d:	ff d7                	call   *%edi
f010499f:	83 c4 10             	add    $0x10,%esp
f01049a2:	eb 03                	jmp    f01049a7 <printnum+0x78>
f01049a4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01049a7:	83 eb 01             	sub    $0x1,%ebx
f01049aa:	85 db                	test   %ebx,%ebx
f01049ac:	7f e8                	jg     f0104996 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01049ae:	83 ec 08             	sub    $0x8,%esp
f01049b1:	56                   	push   %esi
f01049b2:	83 ec 04             	sub    $0x4,%esp
f01049b5:	ff 75 e4             	pushl  -0x1c(%ebp)
f01049b8:	ff 75 e0             	pushl  -0x20(%ebp)
f01049bb:	ff 75 dc             	pushl  -0x24(%ebp)
f01049be:	ff 75 d8             	pushl  -0x28(%ebp)
f01049c1:	e8 da 12 00 00       	call   f0105ca0 <__umoddi3>
f01049c6:	83 c4 14             	add    $0x14,%esp
f01049c9:	0f be 80 ae 74 10 f0 	movsbl -0xfef8b52(%eax),%eax
f01049d0:	50                   	push   %eax
f01049d1:	ff d7                	call   *%edi
}
f01049d3:	83 c4 10             	add    $0x10,%esp
f01049d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01049d9:	5b                   	pop    %ebx
f01049da:	5e                   	pop    %esi
f01049db:	5f                   	pop    %edi
f01049dc:	5d                   	pop    %ebp
f01049dd:	c3                   	ret    

f01049de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f01049de:	55                   	push   %ebp
f01049df:	89 e5                	mov    %esp,%ebp
f01049e1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f01049e4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f01049e8:	8b 10                	mov    (%eax),%edx
f01049ea:	3b 50 04             	cmp    0x4(%eax),%edx
f01049ed:	73 0a                	jae    f01049f9 <sprintputch+0x1b>
		*b->buf++ = ch;
f01049ef:	8d 4a 01             	lea    0x1(%edx),%ecx
f01049f2:	89 08                	mov    %ecx,(%eax)
f01049f4:	8b 45 08             	mov    0x8(%ebp),%eax
f01049f7:	88 02                	mov    %al,(%edx)
}
f01049f9:	5d                   	pop    %ebp
f01049fa:	c3                   	ret    

f01049fb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f01049fb:	55                   	push   %ebp
f01049fc:	89 e5                	mov    %esp,%ebp
f01049fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104a01:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104a04:	50                   	push   %eax
f0104a05:	ff 75 10             	pushl  0x10(%ebp)
f0104a08:	ff 75 0c             	pushl  0xc(%ebp)
f0104a0b:	ff 75 08             	pushl  0x8(%ebp)
f0104a0e:	e8 05 00 00 00       	call   f0104a18 <vprintfmt>
	va_end(ap);
}
f0104a13:	83 c4 10             	add    $0x10,%esp
f0104a16:	c9                   	leave  
f0104a17:	c3                   	ret    

f0104a18 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104a18:	55                   	push   %ebp
f0104a19:	89 e5                	mov    %esp,%ebp
f0104a1b:	57                   	push   %edi
f0104a1c:	56                   	push   %esi
f0104a1d:	53                   	push   %ebx
f0104a1e:	83 ec 2c             	sub    $0x2c,%esp
f0104a21:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a24:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a27:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a2a:	eb 12                	jmp    f0104a3e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104a2c:	85 c0                	test   %eax,%eax
f0104a2e:	0f 84 42 04 00 00    	je     f0104e76 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0104a34:	83 ec 08             	sub    $0x8,%esp
f0104a37:	53                   	push   %ebx
f0104a38:	50                   	push   %eax
f0104a39:	ff d6                	call   *%esi
f0104a3b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104a3e:	83 c7 01             	add    $0x1,%edi
f0104a41:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104a45:	83 f8 25             	cmp    $0x25,%eax
f0104a48:	75 e2                	jne    f0104a2c <vprintfmt+0x14>
f0104a4a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104a4e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104a55:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104a5c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104a63:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a68:	eb 07                	jmp    f0104a71 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104a6d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a71:	8d 47 01             	lea    0x1(%edi),%eax
f0104a74:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104a77:	0f b6 07             	movzbl (%edi),%eax
f0104a7a:	0f b6 d0             	movzbl %al,%edx
f0104a7d:	83 e8 23             	sub    $0x23,%eax
f0104a80:	3c 55                	cmp    $0x55,%al
f0104a82:	0f 87 d3 03 00 00    	ja     f0104e5b <vprintfmt+0x443>
f0104a88:	0f b6 c0             	movzbl %al,%eax
f0104a8b:	ff 24 85 00 76 10 f0 	jmp    *-0xfef8a00(,%eax,4)
f0104a92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104a95:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104a99:	eb d6                	jmp    f0104a71 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a9b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a9e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104aa3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104aa6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104aa9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104aad:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104ab0:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104ab3:	83 f9 09             	cmp    $0x9,%ecx
f0104ab6:	77 3f                	ja     f0104af7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104ab8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104abb:	eb e9                	jmp    f0104aa6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104abd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ac0:	8b 00                	mov    (%eax),%eax
f0104ac2:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104ac5:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ac8:	8d 40 04             	lea    0x4(%eax),%eax
f0104acb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ace:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104ad1:	eb 2a                	jmp    f0104afd <vprintfmt+0xe5>
f0104ad3:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104ad6:	85 c0                	test   %eax,%eax
f0104ad8:	ba 00 00 00 00       	mov    $0x0,%edx
f0104add:	0f 49 d0             	cmovns %eax,%edx
f0104ae0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ae3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ae6:	eb 89                	jmp    f0104a71 <vprintfmt+0x59>
f0104ae8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104aeb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104af2:	e9 7a ff ff ff       	jmp    f0104a71 <vprintfmt+0x59>
f0104af7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104afa:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104afd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104b01:	0f 89 6a ff ff ff    	jns    f0104a71 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104b07:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104b0a:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104b0d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104b14:	e9 58 ff ff ff       	jmp    f0104a71 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104b19:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b1c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104b1f:	e9 4d ff ff ff       	jmp    f0104a71 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104b24:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b27:	8d 78 04             	lea    0x4(%eax),%edi
f0104b2a:	83 ec 08             	sub    $0x8,%esp
f0104b2d:	53                   	push   %ebx
f0104b2e:	ff 30                	pushl  (%eax)
f0104b30:	ff d6                	call   *%esi
			break;
f0104b32:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104b35:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104b3b:	e9 fe fe ff ff       	jmp    f0104a3e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b40:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b43:	8d 78 04             	lea    0x4(%eax),%edi
f0104b46:	8b 00                	mov    (%eax),%eax
f0104b48:	99                   	cltd   
f0104b49:	31 d0                	xor    %edx,%eax
f0104b4b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104b4d:	83 f8 0f             	cmp    $0xf,%eax
f0104b50:	7f 0b                	jg     f0104b5d <vprintfmt+0x145>
f0104b52:	8b 14 85 60 77 10 f0 	mov    -0xfef88a0(,%eax,4),%edx
f0104b59:	85 d2                	test   %edx,%edx
f0104b5b:	75 1b                	jne    f0104b78 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0104b5d:	50                   	push   %eax
f0104b5e:	68 c6 74 10 f0       	push   $0xf01074c6
f0104b63:	53                   	push   %ebx
f0104b64:	56                   	push   %esi
f0104b65:	e8 91 fe ff ff       	call   f01049fb <printfmt>
f0104b6a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b6d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104b73:	e9 c6 fe ff ff       	jmp    f0104a3e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104b78:	52                   	push   %edx
f0104b79:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0104b7e:	53                   	push   %ebx
f0104b7f:	56                   	push   %esi
f0104b80:	e8 76 fe ff ff       	call   f01049fb <printfmt>
f0104b85:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b88:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b8e:	e9 ab fe ff ff       	jmp    f0104a3e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104b93:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b96:	83 c0 04             	add    $0x4,%eax
f0104b99:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104b9c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b9f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104ba1:	85 ff                	test   %edi,%edi
f0104ba3:	b8 bf 74 10 f0       	mov    $0xf01074bf,%eax
f0104ba8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104bab:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104baf:	0f 8e 94 00 00 00    	jle    f0104c49 <vprintfmt+0x231>
f0104bb5:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104bb9:	0f 84 98 00 00 00    	je     f0104c57 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bbf:	83 ec 08             	sub    $0x8,%esp
f0104bc2:	ff 75 d0             	pushl  -0x30(%ebp)
f0104bc5:	57                   	push   %edi
f0104bc6:	e8 24 04 00 00       	call   f0104fef <strnlen>
f0104bcb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104bce:	29 c1                	sub    %eax,%ecx
f0104bd0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104bd3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104bd6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104bda:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104bdd:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104be0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104be2:	eb 0f                	jmp    f0104bf3 <vprintfmt+0x1db>
					putch(padc, putdat);
f0104be4:	83 ec 08             	sub    $0x8,%esp
f0104be7:	53                   	push   %ebx
f0104be8:	ff 75 e0             	pushl  -0x20(%ebp)
f0104beb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bed:	83 ef 01             	sub    $0x1,%edi
f0104bf0:	83 c4 10             	add    $0x10,%esp
f0104bf3:	85 ff                	test   %edi,%edi
f0104bf5:	7f ed                	jg     f0104be4 <vprintfmt+0x1cc>
f0104bf7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104bfa:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104bfd:	85 c9                	test   %ecx,%ecx
f0104bff:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c04:	0f 49 c1             	cmovns %ecx,%eax
f0104c07:	29 c1                	sub    %eax,%ecx
f0104c09:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c0c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c0f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c12:	89 cb                	mov    %ecx,%ebx
f0104c14:	eb 4d                	jmp    f0104c63 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104c16:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104c1a:	74 1b                	je     f0104c37 <vprintfmt+0x21f>
f0104c1c:	0f be c0             	movsbl %al,%eax
f0104c1f:	83 e8 20             	sub    $0x20,%eax
f0104c22:	83 f8 5e             	cmp    $0x5e,%eax
f0104c25:	76 10                	jbe    f0104c37 <vprintfmt+0x21f>
					putch('?', putdat);
f0104c27:	83 ec 08             	sub    $0x8,%esp
f0104c2a:	ff 75 0c             	pushl  0xc(%ebp)
f0104c2d:	6a 3f                	push   $0x3f
f0104c2f:	ff 55 08             	call   *0x8(%ebp)
f0104c32:	83 c4 10             	add    $0x10,%esp
f0104c35:	eb 0d                	jmp    f0104c44 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0104c37:	83 ec 08             	sub    $0x8,%esp
f0104c3a:	ff 75 0c             	pushl  0xc(%ebp)
f0104c3d:	52                   	push   %edx
f0104c3e:	ff 55 08             	call   *0x8(%ebp)
f0104c41:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c44:	83 eb 01             	sub    $0x1,%ebx
f0104c47:	eb 1a                	jmp    f0104c63 <vprintfmt+0x24b>
f0104c49:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c4c:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c4f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c52:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104c55:	eb 0c                	jmp    f0104c63 <vprintfmt+0x24b>
f0104c57:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c5a:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c5d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c60:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104c63:	83 c7 01             	add    $0x1,%edi
f0104c66:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104c6a:	0f be d0             	movsbl %al,%edx
f0104c6d:	85 d2                	test   %edx,%edx
f0104c6f:	74 23                	je     f0104c94 <vprintfmt+0x27c>
f0104c71:	85 f6                	test   %esi,%esi
f0104c73:	78 a1                	js     f0104c16 <vprintfmt+0x1fe>
f0104c75:	83 ee 01             	sub    $0x1,%esi
f0104c78:	79 9c                	jns    f0104c16 <vprintfmt+0x1fe>
f0104c7a:	89 df                	mov    %ebx,%edi
f0104c7c:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c7f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c82:	eb 18                	jmp    f0104c9c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104c84:	83 ec 08             	sub    $0x8,%esp
f0104c87:	53                   	push   %ebx
f0104c88:	6a 20                	push   $0x20
f0104c8a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104c8c:	83 ef 01             	sub    $0x1,%edi
f0104c8f:	83 c4 10             	add    $0x10,%esp
f0104c92:	eb 08                	jmp    f0104c9c <vprintfmt+0x284>
f0104c94:	89 df                	mov    %ebx,%edi
f0104c96:	8b 75 08             	mov    0x8(%ebp),%esi
f0104c99:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104c9c:	85 ff                	test   %edi,%edi
f0104c9e:	7f e4                	jg     f0104c84 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104ca0:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104ca3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ca6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ca9:	e9 90 fd ff ff       	jmp    f0104a3e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104cae:	83 f9 01             	cmp    $0x1,%ecx
f0104cb1:	7e 19                	jle    f0104ccc <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0104cb3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cb6:	8b 50 04             	mov    0x4(%eax),%edx
f0104cb9:	8b 00                	mov    (%eax),%eax
f0104cbb:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cbe:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104cc1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cc4:	8d 40 08             	lea    0x8(%eax),%eax
f0104cc7:	89 45 14             	mov    %eax,0x14(%ebp)
f0104cca:	eb 38                	jmp    f0104d04 <vprintfmt+0x2ec>
	else if (lflag)
f0104ccc:	85 c9                	test   %ecx,%ecx
f0104cce:	74 1b                	je     f0104ceb <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0104cd0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cd3:	8b 00                	mov    (%eax),%eax
f0104cd5:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cd8:	89 c1                	mov    %eax,%ecx
f0104cda:	c1 f9 1f             	sar    $0x1f,%ecx
f0104cdd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104ce0:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ce3:	8d 40 04             	lea    0x4(%eax),%eax
f0104ce6:	89 45 14             	mov    %eax,0x14(%ebp)
f0104ce9:	eb 19                	jmp    f0104d04 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0104ceb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cee:	8b 00                	mov    (%eax),%eax
f0104cf0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cf3:	89 c1                	mov    %eax,%ecx
f0104cf5:	c1 f9 1f             	sar    $0x1f,%ecx
f0104cf8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104cfb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cfe:	8d 40 04             	lea    0x4(%eax),%eax
f0104d01:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104d04:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104d07:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104d0a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104d0f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104d13:	0f 89 0e 01 00 00    	jns    f0104e27 <vprintfmt+0x40f>
				putch('-', putdat);
f0104d19:	83 ec 08             	sub    $0x8,%esp
f0104d1c:	53                   	push   %ebx
f0104d1d:	6a 2d                	push   $0x2d
f0104d1f:	ff d6                	call   *%esi
				num = -(long long) num;
f0104d21:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104d24:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104d27:	f7 da                	neg    %edx
f0104d29:	83 d1 00             	adc    $0x0,%ecx
f0104d2c:	f7 d9                	neg    %ecx
f0104d2e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104d31:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d36:	e9 ec 00 00 00       	jmp    f0104e27 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104d3b:	83 f9 01             	cmp    $0x1,%ecx
f0104d3e:	7e 18                	jle    f0104d58 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0104d40:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d43:	8b 10                	mov    (%eax),%edx
f0104d45:	8b 48 04             	mov    0x4(%eax),%ecx
f0104d48:	8d 40 08             	lea    0x8(%eax),%eax
f0104d4b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104d4e:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d53:	e9 cf 00 00 00       	jmp    f0104e27 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0104d58:	85 c9                	test   %ecx,%ecx
f0104d5a:	74 1a                	je     f0104d76 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0104d5c:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d5f:	8b 10                	mov    (%eax),%edx
f0104d61:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d66:	8d 40 04             	lea    0x4(%eax),%eax
f0104d69:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104d6c:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d71:	e9 b1 00 00 00       	jmp    f0104e27 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104d76:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d79:	8b 10                	mov    (%eax),%edx
f0104d7b:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d80:	8d 40 04             	lea    0x4(%eax),%eax
f0104d83:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104d86:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d8b:	e9 97 00 00 00       	jmp    f0104e27 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0104d90:	83 ec 08             	sub    $0x8,%esp
f0104d93:	53                   	push   %ebx
f0104d94:	6a 58                	push   $0x58
f0104d96:	ff d6                	call   *%esi
			putch('X', putdat);
f0104d98:	83 c4 08             	add    $0x8,%esp
f0104d9b:	53                   	push   %ebx
f0104d9c:	6a 58                	push   $0x58
f0104d9e:	ff d6                	call   *%esi
			putch('X', putdat);
f0104da0:	83 c4 08             	add    $0x8,%esp
f0104da3:	53                   	push   %ebx
f0104da4:	6a 58                	push   $0x58
f0104da6:	ff d6                	call   *%esi
			break;
f0104da8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104dab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0104dae:	e9 8b fc ff ff       	jmp    f0104a3e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0104db3:	83 ec 08             	sub    $0x8,%esp
f0104db6:	53                   	push   %ebx
f0104db7:	6a 30                	push   $0x30
f0104db9:	ff d6                	call   *%esi
			putch('x', putdat);
f0104dbb:	83 c4 08             	add    $0x8,%esp
f0104dbe:	53                   	push   %ebx
f0104dbf:	6a 78                	push   $0x78
f0104dc1:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104dc3:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dc6:	8b 10                	mov    (%eax),%edx
f0104dc8:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104dcd:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104dd0:	8d 40 04             	lea    0x4(%eax),%eax
f0104dd3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104dd6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104ddb:	eb 4a                	jmp    f0104e27 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104ddd:	83 f9 01             	cmp    $0x1,%ecx
f0104de0:	7e 15                	jle    f0104df7 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0104de2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104de5:	8b 10                	mov    (%eax),%edx
f0104de7:	8b 48 04             	mov    0x4(%eax),%ecx
f0104dea:	8d 40 08             	lea    0x8(%eax),%eax
f0104ded:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104df0:	b8 10 00 00 00       	mov    $0x10,%eax
f0104df5:	eb 30                	jmp    f0104e27 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0104df7:	85 c9                	test   %ecx,%ecx
f0104df9:	74 17                	je     f0104e12 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f0104dfb:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dfe:	8b 10                	mov    (%eax),%edx
f0104e00:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e05:	8d 40 04             	lea    0x4(%eax),%eax
f0104e08:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104e0b:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e10:	eb 15                	jmp    f0104e27 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104e12:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e15:	8b 10                	mov    (%eax),%edx
f0104e17:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e1c:	8d 40 04             	lea    0x4(%eax),%eax
f0104e1f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104e22:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104e27:	83 ec 0c             	sub    $0xc,%esp
f0104e2a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104e2e:	57                   	push   %edi
f0104e2f:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e32:	50                   	push   %eax
f0104e33:	51                   	push   %ecx
f0104e34:	52                   	push   %edx
f0104e35:	89 da                	mov    %ebx,%edx
f0104e37:	89 f0                	mov    %esi,%eax
f0104e39:	e8 f1 fa ff ff       	call   f010492f <printnum>
			break;
f0104e3e:	83 c4 20             	add    $0x20,%esp
f0104e41:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e44:	e9 f5 fb ff ff       	jmp    f0104a3e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104e49:	83 ec 08             	sub    $0x8,%esp
f0104e4c:	53                   	push   %ebx
f0104e4d:	52                   	push   %edx
f0104e4e:	ff d6                	call   *%esi
			break;
f0104e50:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e53:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104e56:	e9 e3 fb ff ff       	jmp    f0104a3e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104e5b:	83 ec 08             	sub    $0x8,%esp
f0104e5e:	53                   	push   %ebx
f0104e5f:	6a 25                	push   $0x25
f0104e61:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104e63:	83 c4 10             	add    $0x10,%esp
f0104e66:	eb 03                	jmp    f0104e6b <vprintfmt+0x453>
f0104e68:	83 ef 01             	sub    $0x1,%edi
f0104e6b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104e6f:	75 f7                	jne    f0104e68 <vprintfmt+0x450>
f0104e71:	e9 c8 fb ff ff       	jmp    f0104a3e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104e76:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104e79:	5b                   	pop    %ebx
f0104e7a:	5e                   	pop    %esi
f0104e7b:	5f                   	pop    %edi
f0104e7c:	5d                   	pop    %ebp
f0104e7d:	c3                   	ret    

f0104e7e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104e7e:	55                   	push   %ebp
f0104e7f:	89 e5                	mov    %esp,%ebp
f0104e81:	83 ec 18             	sub    $0x18,%esp
f0104e84:	8b 45 08             	mov    0x8(%ebp),%eax
f0104e87:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104e8a:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104e8d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104e91:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104e94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104e9b:	85 c0                	test   %eax,%eax
f0104e9d:	74 26                	je     f0104ec5 <vsnprintf+0x47>
f0104e9f:	85 d2                	test   %edx,%edx
f0104ea1:	7e 22                	jle    f0104ec5 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104ea3:	ff 75 14             	pushl  0x14(%ebp)
f0104ea6:	ff 75 10             	pushl  0x10(%ebp)
f0104ea9:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104eac:	50                   	push   %eax
f0104ead:	68 de 49 10 f0       	push   $0xf01049de
f0104eb2:	e8 61 fb ff ff       	call   f0104a18 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104eb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104eba:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ec0:	83 c4 10             	add    $0x10,%esp
f0104ec3:	eb 05                	jmp    f0104eca <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104ec5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104eca:	c9                   	leave  
f0104ecb:	c3                   	ret    

f0104ecc <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104ecc:	55                   	push   %ebp
f0104ecd:	89 e5                	mov    %esp,%ebp
f0104ecf:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104ed2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104ed5:	50                   	push   %eax
f0104ed6:	ff 75 10             	pushl  0x10(%ebp)
f0104ed9:	ff 75 0c             	pushl  0xc(%ebp)
f0104edc:	ff 75 08             	pushl  0x8(%ebp)
f0104edf:	e8 9a ff ff ff       	call   f0104e7e <vsnprintf>
	va_end(ap);

	return rc;
}
f0104ee4:	c9                   	leave  
f0104ee5:	c3                   	ret    

f0104ee6 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104ee6:	55                   	push   %ebp
f0104ee7:	89 e5                	mov    %esp,%ebp
f0104ee9:	57                   	push   %edi
f0104eea:	56                   	push   %esi
f0104eeb:	53                   	push   %ebx
f0104eec:	83 ec 0c             	sub    $0xc,%esp
f0104eef:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

#if JOS_KERNEL
	if (prompt != NULL)
f0104ef2:	85 c0                	test   %eax,%eax
f0104ef4:	74 11                	je     f0104f07 <readline+0x21>
		cprintf("%s", prompt);
f0104ef6:	83 ec 08             	sub    $0x8,%esp
f0104ef9:	50                   	push   %eax
f0104efa:	68 9d 6c 10 f0       	push   $0xf0106c9d
f0104eff:	e8 70 e6 ff ff       	call   f0103574 <cprintf>
f0104f04:	83 c4 10             	add    $0x10,%esp
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
	echoing = iscons(0);
f0104f07:	83 ec 0c             	sub    $0xc,%esp
f0104f0a:	6a 00                	push   $0x0
f0104f0c:	e8 ac b8 ff ff       	call   f01007bd <iscons>
f0104f11:	89 c7                	mov    %eax,%edi
f0104f13:	83 c4 10             	add    $0x10,%esp
#else
	if (prompt != NULL)
		fprintf(1, "%s", prompt);
#endif

	i = 0;
f0104f16:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104f1b:	e8 8c b8 ff ff       	call   f01007ac <getchar>
f0104f20:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104f22:	85 c0                	test   %eax,%eax
f0104f24:	79 29                	jns    f0104f4f <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
f0104f26:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0104f2b:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0104f2e:	0f 84 9b 00 00 00    	je     f0104fcf <readline+0xe9>
				cprintf("read error: %e\n", c);
f0104f34:	83 ec 08             	sub    $0x8,%esp
f0104f37:	53                   	push   %ebx
f0104f38:	68 bf 77 10 f0       	push   $0xf01077bf
f0104f3d:	e8 32 e6 ff ff       	call   f0103574 <cprintf>
f0104f42:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0104f45:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f4a:	e9 80 00 00 00       	jmp    f0104fcf <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104f4f:	83 f8 08             	cmp    $0x8,%eax
f0104f52:	0f 94 c2             	sete   %dl
f0104f55:	83 f8 7f             	cmp    $0x7f,%eax
f0104f58:	0f 94 c0             	sete   %al
f0104f5b:	08 c2                	or     %al,%dl
f0104f5d:	74 1a                	je     f0104f79 <readline+0x93>
f0104f5f:	85 f6                	test   %esi,%esi
f0104f61:	7e 16                	jle    f0104f79 <readline+0x93>
			if (echoing)
f0104f63:	85 ff                	test   %edi,%edi
f0104f65:	74 0d                	je     f0104f74 <readline+0x8e>
				cputchar('\b');
f0104f67:	83 ec 0c             	sub    $0xc,%esp
f0104f6a:	6a 08                	push   $0x8
f0104f6c:	e8 2b b8 ff ff       	call   f010079c <cputchar>
f0104f71:	83 c4 10             	add    $0x10,%esp
			i--;
f0104f74:	83 ee 01             	sub    $0x1,%esi
f0104f77:	eb a2                	jmp    f0104f1b <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104f79:	83 fb 1f             	cmp    $0x1f,%ebx
f0104f7c:	7e 26                	jle    f0104fa4 <readline+0xbe>
f0104f7e:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104f84:	7f 1e                	jg     f0104fa4 <readline+0xbe>
			if (echoing)
f0104f86:	85 ff                	test   %edi,%edi
f0104f88:	74 0c                	je     f0104f96 <readline+0xb0>
				cputchar(c);
f0104f8a:	83 ec 0c             	sub    $0xc,%esp
f0104f8d:	53                   	push   %ebx
f0104f8e:	e8 09 b8 ff ff       	call   f010079c <cputchar>
f0104f93:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104f96:	88 9e 80 1a 21 f0    	mov    %bl,-0xfdee580(%esi)
f0104f9c:	8d 76 01             	lea    0x1(%esi),%esi
f0104f9f:	e9 77 ff ff ff       	jmp    f0104f1b <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104fa4:	83 fb 0a             	cmp    $0xa,%ebx
f0104fa7:	74 09                	je     f0104fb2 <readline+0xcc>
f0104fa9:	83 fb 0d             	cmp    $0xd,%ebx
f0104fac:	0f 85 69 ff ff ff    	jne    f0104f1b <readline+0x35>
			if (echoing)
f0104fb2:	85 ff                	test   %edi,%edi
f0104fb4:	74 0d                	je     f0104fc3 <readline+0xdd>
				cputchar('\n');
f0104fb6:	83 ec 0c             	sub    $0xc,%esp
f0104fb9:	6a 0a                	push   $0xa
f0104fbb:	e8 dc b7 ff ff       	call   f010079c <cputchar>
f0104fc0:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104fc3:	c6 86 80 1a 21 f0 00 	movb   $0x0,-0xfdee580(%esi)
			return buf;
f0104fca:	b8 80 1a 21 f0       	mov    $0xf0211a80,%eax
		}
	}
}
f0104fcf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fd2:	5b                   	pop    %ebx
f0104fd3:	5e                   	pop    %esi
f0104fd4:	5f                   	pop    %edi
f0104fd5:	5d                   	pop    %ebp
f0104fd6:	c3                   	ret    

f0104fd7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104fd7:	55                   	push   %ebp
f0104fd8:	89 e5                	mov    %esp,%ebp
f0104fda:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104fdd:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fe2:	eb 03                	jmp    f0104fe7 <strlen+0x10>
		n++;
f0104fe4:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0104fe7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0104feb:	75 f7                	jne    f0104fe4 <strlen+0xd>
		n++;
	return n;
}
f0104fed:	5d                   	pop    %ebp
f0104fee:	c3                   	ret    

f0104fef <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0104fef:	55                   	push   %ebp
f0104ff0:	89 e5                	mov    %esp,%ebp
f0104ff2:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104ff5:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0104ff8:	ba 00 00 00 00       	mov    $0x0,%edx
f0104ffd:	eb 03                	jmp    f0105002 <strnlen+0x13>
		n++;
f0104fff:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105002:	39 c2                	cmp    %eax,%edx
f0105004:	74 08                	je     f010500e <strnlen+0x1f>
f0105006:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f010500a:	75 f3                	jne    f0104fff <strnlen+0x10>
f010500c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010500e:	5d                   	pop    %ebp
f010500f:	c3                   	ret    

f0105010 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0105010:	55                   	push   %ebp
f0105011:	89 e5                	mov    %esp,%ebp
f0105013:	53                   	push   %ebx
f0105014:	8b 45 08             	mov    0x8(%ebp),%eax
f0105017:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f010501a:	89 c2                	mov    %eax,%edx
f010501c:	83 c2 01             	add    $0x1,%edx
f010501f:	83 c1 01             	add    $0x1,%ecx
f0105022:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105026:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105029:	84 db                	test   %bl,%bl
f010502b:	75 ef                	jne    f010501c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010502d:	5b                   	pop    %ebx
f010502e:	5d                   	pop    %ebp
f010502f:	c3                   	ret    

f0105030 <strcat>:

char *
strcat(char *dst, const char *src)
{
f0105030:	55                   	push   %ebp
f0105031:	89 e5                	mov    %esp,%ebp
f0105033:	53                   	push   %ebx
f0105034:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105037:	53                   	push   %ebx
f0105038:	e8 9a ff ff ff       	call   f0104fd7 <strlen>
f010503d:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f0105040:	ff 75 0c             	pushl  0xc(%ebp)
f0105043:	01 d8                	add    %ebx,%eax
f0105045:	50                   	push   %eax
f0105046:	e8 c5 ff ff ff       	call   f0105010 <strcpy>
	return dst;
}
f010504b:	89 d8                	mov    %ebx,%eax
f010504d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0105050:	c9                   	leave  
f0105051:	c3                   	ret    

f0105052 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105052:	55                   	push   %ebp
f0105053:	89 e5                	mov    %esp,%ebp
f0105055:	56                   	push   %esi
f0105056:	53                   	push   %ebx
f0105057:	8b 75 08             	mov    0x8(%ebp),%esi
f010505a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010505d:	89 f3                	mov    %esi,%ebx
f010505f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105062:	89 f2                	mov    %esi,%edx
f0105064:	eb 0f                	jmp    f0105075 <strncpy+0x23>
		*dst++ = *src;
f0105066:	83 c2 01             	add    $0x1,%edx
f0105069:	0f b6 01             	movzbl (%ecx),%eax
f010506c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010506f:	80 39 01             	cmpb   $0x1,(%ecx)
f0105072:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105075:	39 da                	cmp    %ebx,%edx
f0105077:	75 ed                	jne    f0105066 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105079:	89 f0                	mov    %esi,%eax
f010507b:	5b                   	pop    %ebx
f010507c:	5e                   	pop    %esi
f010507d:	5d                   	pop    %ebp
f010507e:	c3                   	ret    

f010507f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010507f:	55                   	push   %ebp
f0105080:	89 e5                	mov    %esp,%ebp
f0105082:	56                   	push   %esi
f0105083:	53                   	push   %ebx
f0105084:	8b 75 08             	mov    0x8(%ebp),%esi
f0105087:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010508a:	8b 55 10             	mov    0x10(%ebp),%edx
f010508d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f010508f:	85 d2                	test   %edx,%edx
f0105091:	74 21                	je     f01050b4 <strlcpy+0x35>
f0105093:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f0105097:	89 f2                	mov    %esi,%edx
f0105099:	eb 09                	jmp    f01050a4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f010509b:	83 c2 01             	add    $0x1,%edx
f010509e:	83 c1 01             	add    $0x1,%ecx
f01050a1:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01050a4:	39 c2                	cmp    %eax,%edx
f01050a6:	74 09                	je     f01050b1 <strlcpy+0x32>
f01050a8:	0f b6 19             	movzbl (%ecx),%ebx
f01050ab:	84 db                	test   %bl,%bl
f01050ad:	75 ec                	jne    f010509b <strlcpy+0x1c>
f01050af:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01050b1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01050b4:	29 f0                	sub    %esi,%eax
}
f01050b6:	5b                   	pop    %ebx
f01050b7:	5e                   	pop    %esi
f01050b8:	5d                   	pop    %ebp
f01050b9:	c3                   	ret    

f01050ba <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01050ba:	55                   	push   %ebp
f01050bb:	89 e5                	mov    %esp,%ebp
f01050bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01050c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01050c3:	eb 06                	jmp    f01050cb <strcmp+0x11>
		p++, q++;
f01050c5:	83 c1 01             	add    $0x1,%ecx
f01050c8:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01050cb:	0f b6 01             	movzbl (%ecx),%eax
f01050ce:	84 c0                	test   %al,%al
f01050d0:	74 04                	je     f01050d6 <strcmp+0x1c>
f01050d2:	3a 02                	cmp    (%edx),%al
f01050d4:	74 ef                	je     f01050c5 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01050d6:	0f b6 c0             	movzbl %al,%eax
f01050d9:	0f b6 12             	movzbl (%edx),%edx
f01050dc:	29 d0                	sub    %edx,%eax
}
f01050de:	5d                   	pop    %ebp
f01050df:	c3                   	ret    

f01050e0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01050e0:	55                   	push   %ebp
f01050e1:	89 e5                	mov    %esp,%ebp
f01050e3:	53                   	push   %ebx
f01050e4:	8b 45 08             	mov    0x8(%ebp),%eax
f01050e7:	8b 55 0c             	mov    0xc(%ebp),%edx
f01050ea:	89 c3                	mov    %eax,%ebx
f01050ec:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f01050ef:	eb 06                	jmp    f01050f7 <strncmp+0x17>
		n--, p++, q++;
f01050f1:	83 c0 01             	add    $0x1,%eax
f01050f4:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f01050f7:	39 d8                	cmp    %ebx,%eax
f01050f9:	74 15                	je     f0105110 <strncmp+0x30>
f01050fb:	0f b6 08             	movzbl (%eax),%ecx
f01050fe:	84 c9                	test   %cl,%cl
f0105100:	74 04                	je     f0105106 <strncmp+0x26>
f0105102:	3a 0a                	cmp    (%edx),%cl
f0105104:	74 eb                	je     f01050f1 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105106:	0f b6 00             	movzbl (%eax),%eax
f0105109:	0f b6 12             	movzbl (%edx),%edx
f010510c:	29 d0                	sub    %edx,%eax
f010510e:	eb 05                	jmp    f0105115 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f0105110:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105115:	5b                   	pop    %ebx
f0105116:	5d                   	pop    %ebp
f0105117:	c3                   	ret    

f0105118 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105118:	55                   	push   %ebp
f0105119:	89 e5                	mov    %esp,%ebp
f010511b:	8b 45 08             	mov    0x8(%ebp),%eax
f010511e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105122:	eb 07                	jmp    f010512b <strchr+0x13>
		if (*s == c)
f0105124:	38 ca                	cmp    %cl,%dl
f0105126:	74 0f                	je     f0105137 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105128:	83 c0 01             	add    $0x1,%eax
f010512b:	0f b6 10             	movzbl (%eax),%edx
f010512e:	84 d2                	test   %dl,%dl
f0105130:	75 f2                	jne    f0105124 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f0105132:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105137:	5d                   	pop    %ebp
f0105138:	c3                   	ret    

f0105139 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105139:	55                   	push   %ebp
f010513a:	89 e5                	mov    %esp,%ebp
f010513c:	8b 45 08             	mov    0x8(%ebp),%eax
f010513f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105143:	eb 03                	jmp    f0105148 <strfind+0xf>
f0105145:	83 c0 01             	add    $0x1,%eax
f0105148:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f010514b:	38 ca                	cmp    %cl,%dl
f010514d:	74 04                	je     f0105153 <strfind+0x1a>
f010514f:	84 d2                	test   %dl,%dl
f0105151:	75 f2                	jne    f0105145 <strfind+0xc>
			break;
	return (char *) s;
}
f0105153:	5d                   	pop    %ebp
f0105154:	c3                   	ret    

f0105155 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105155:	55                   	push   %ebp
f0105156:	89 e5                	mov    %esp,%ebp
f0105158:	57                   	push   %edi
f0105159:	56                   	push   %esi
f010515a:	53                   	push   %ebx
f010515b:	8b 7d 08             	mov    0x8(%ebp),%edi
f010515e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f0105161:	85 c9                	test   %ecx,%ecx
f0105163:	74 36                	je     f010519b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105165:	f7 c7 03 00 00 00    	test   $0x3,%edi
f010516b:	75 28                	jne    f0105195 <memset+0x40>
f010516d:	f6 c1 03             	test   $0x3,%cl
f0105170:	75 23                	jne    f0105195 <memset+0x40>
		c &= 0xFF;
f0105172:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105176:	89 d3                	mov    %edx,%ebx
f0105178:	c1 e3 08             	shl    $0x8,%ebx
f010517b:	89 d6                	mov    %edx,%esi
f010517d:	c1 e6 18             	shl    $0x18,%esi
f0105180:	89 d0                	mov    %edx,%eax
f0105182:	c1 e0 10             	shl    $0x10,%eax
f0105185:	09 f0                	or     %esi,%eax
f0105187:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f0105189:	89 d8                	mov    %ebx,%eax
f010518b:	09 d0                	or     %edx,%eax
f010518d:	c1 e9 02             	shr    $0x2,%ecx
f0105190:	fc                   	cld    
f0105191:	f3 ab                	rep stos %eax,%es:(%edi)
f0105193:	eb 06                	jmp    f010519b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f0105195:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105198:	fc                   	cld    
f0105199:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f010519b:	89 f8                	mov    %edi,%eax
f010519d:	5b                   	pop    %ebx
f010519e:	5e                   	pop    %esi
f010519f:	5f                   	pop    %edi
f01051a0:	5d                   	pop    %ebp
f01051a1:	c3                   	ret    

f01051a2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01051a2:	55                   	push   %ebp
f01051a3:	89 e5                	mov    %esp,%ebp
f01051a5:	57                   	push   %edi
f01051a6:	56                   	push   %esi
f01051a7:	8b 45 08             	mov    0x8(%ebp),%eax
f01051aa:	8b 75 0c             	mov    0xc(%ebp),%esi
f01051ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01051b0:	39 c6                	cmp    %eax,%esi
f01051b2:	73 35                	jae    f01051e9 <memmove+0x47>
f01051b4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01051b7:	39 d0                	cmp    %edx,%eax
f01051b9:	73 2e                	jae    f01051e9 <memmove+0x47>
		s += n;
		d += n;
f01051bb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01051be:	89 d6                	mov    %edx,%esi
f01051c0:	09 fe                	or     %edi,%esi
f01051c2:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01051c8:	75 13                	jne    f01051dd <memmove+0x3b>
f01051ca:	f6 c1 03             	test   $0x3,%cl
f01051cd:	75 0e                	jne    f01051dd <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01051cf:	83 ef 04             	sub    $0x4,%edi
f01051d2:	8d 72 fc             	lea    -0x4(%edx),%esi
f01051d5:	c1 e9 02             	shr    $0x2,%ecx
f01051d8:	fd                   	std    
f01051d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01051db:	eb 09                	jmp    f01051e6 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01051dd:	83 ef 01             	sub    $0x1,%edi
f01051e0:	8d 72 ff             	lea    -0x1(%edx),%esi
f01051e3:	fd                   	std    
f01051e4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f01051e6:	fc                   	cld    
f01051e7:	eb 1d                	jmp    f0105206 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01051e9:	89 f2                	mov    %esi,%edx
f01051eb:	09 c2                	or     %eax,%edx
f01051ed:	f6 c2 03             	test   $0x3,%dl
f01051f0:	75 0f                	jne    f0105201 <memmove+0x5f>
f01051f2:	f6 c1 03             	test   $0x3,%cl
f01051f5:	75 0a                	jne    f0105201 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f01051f7:	c1 e9 02             	shr    $0x2,%ecx
f01051fa:	89 c7                	mov    %eax,%edi
f01051fc:	fc                   	cld    
f01051fd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01051ff:	eb 05                	jmp    f0105206 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105201:	89 c7                	mov    %eax,%edi
f0105203:	fc                   	cld    
f0105204:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105206:	5e                   	pop    %esi
f0105207:	5f                   	pop    %edi
f0105208:	5d                   	pop    %ebp
f0105209:	c3                   	ret    

f010520a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f010520a:	55                   	push   %ebp
f010520b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010520d:	ff 75 10             	pushl  0x10(%ebp)
f0105210:	ff 75 0c             	pushl  0xc(%ebp)
f0105213:	ff 75 08             	pushl  0x8(%ebp)
f0105216:	e8 87 ff ff ff       	call   f01051a2 <memmove>
}
f010521b:	c9                   	leave  
f010521c:	c3                   	ret    

f010521d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010521d:	55                   	push   %ebp
f010521e:	89 e5                	mov    %esp,%ebp
f0105220:	56                   	push   %esi
f0105221:	53                   	push   %ebx
f0105222:	8b 45 08             	mov    0x8(%ebp),%eax
f0105225:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105228:	89 c6                	mov    %eax,%esi
f010522a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010522d:	eb 1a                	jmp    f0105249 <memcmp+0x2c>
		if (*s1 != *s2)
f010522f:	0f b6 08             	movzbl (%eax),%ecx
f0105232:	0f b6 1a             	movzbl (%edx),%ebx
f0105235:	38 d9                	cmp    %bl,%cl
f0105237:	74 0a                	je     f0105243 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105239:	0f b6 c1             	movzbl %cl,%eax
f010523c:	0f b6 db             	movzbl %bl,%ebx
f010523f:	29 d8                	sub    %ebx,%eax
f0105241:	eb 0f                	jmp    f0105252 <memcmp+0x35>
		s1++, s2++;
f0105243:	83 c0 01             	add    $0x1,%eax
f0105246:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105249:	39 f0                	cmp    %esi,%eax
f010524b:	75 e2                	jne    f010522f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010524d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105252:	5b                   	pop    %ebx
f0105253:	5e                   	pop    %esi
f0105254:	5d                   	pop    %ebp
f0105255:	c3                   	ret    

f0105256 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105256:	55                   	push   %ebp
f0105257:	89 e5                	mov    %esp,%ebp
f0105259:	53                   	push   %ebx
f010525a:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010525d:	89 c1                	mov    %eax,%ecx
f010525f:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f0105262:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105266:	eb 0a                	jmp    f0105272 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105268:	0f b6 10             	movzbl (%eax),%edx
f010526b:	39 da                	cmp    %ebx,%edx
f010526d:	74 07                	je     f0105276 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010526f:	83 c0 01             	add    $0x1,%eax
f0105272:	39 c8                	cmp    %ecx,%eax
f0105274:	72 f2                	jb     f0105268 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105276:	5b                   	pop    %ebx
f0105277:	5d                   	pop    %ebp
f0105278:	c3                   	ret    

f0105279 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105279:	55                   	push   %ebp
f010527a:	89 e5                	mov    %esp,%ebp
f010527c:	57                   	push   %edi
f010527d:	56                   	push   %esi
f010527e:	53                   	push   %ebx
f010527f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105282:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105285:	eb 03                	jmp    f010528a <strtol+0x11>
		s++;
f0105287:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010528a:	0f b6 01             	movzbl (%ecx),%eax
f010528d:	3c 20                	cmp    $0x20,%al
f010528f:	74 f6                	je     f0105287 <strtol+0xe>
f0105291:	3c 09                	cmp    $0x9,%al
f0105293:	74 f2                	je     f0105287 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105295:	3c 2b                	cmp    $0x2b,%al
f0105297:	75 0a                	jne    f01052a3 <strtol+0x2a>
		s++;
f0105299:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f010529c:	bf 00 00 00 00       	mov    $0x0,%edi
f01052a1:	eb 11                	jmp    f01052b4 <strtol+0x3b>
f01052a3:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01052a8:	3c 2d                	cmp    $0x2d,%al
f01052aa:	75 08                	jne    f01052b4 <strtol+0x3b>
		s++, neg = 1;
f01052ac:	83 c1 01             	add    $0x1,%ecx
f01052af:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01052b4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01052ba:	75 15                	jne    f01052d1 <strtol+0x58>
f01052bc:	80 39 30             	cmpb   $0x30,(%ecx)
f01052bf:	75 10                	jne    f01052d1 <strtol+0x58>
f01052c1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01052c5:	75 7c                	jne    f0105343 <strtol+0xca>
		s += 2, base = 16;
f01052c7:	83 c1 02             	add    $0x2,%ecx
f01052ca:	bb 10 00 00 00       	mov    $0x10,%ebx
f01052cf:	eb 16                	jmp    f01052e7 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01052d1:	85 db                	test   %ebx,%ebx
f01052d3:	75 12                	jne    f01052e7 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01052d5:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01052da:	80 39 30             	cmpb   $0x30,(%ecx)
f01052dd:	75 08                	jne    f01052e7 <strtol+0x6e>
		s++, base = 8;
f01052df:	83 c1 01             	add    $0x1,%ecx
f01052e2:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f01052e7:	b8 00 00 00 00       	mov    $0x0,%eax
f01052ec:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01052ef:	0f b6 11             	movzbl (%ecx),%edx
f01052f2:	8d 72 d0             	lea    -0x30(%edx),%esi
f01052f5:	89 f3                	mov    %esi,%ebx
f01052f7:	80 fb 09             	cmp    $0x9,%bl
f01052fa:	77 08                	ja     f0105304 <strtol+0x8b>
			dig = *s - '0';
f01052fc:	0f be d2             	movsbl %dl,%edx
f01052ff:	83 ea 30             	sub    $0x30,%edx
f0105302:	eb 22                	jmp    f0105326 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105304:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105307:	89 f3                	mov    %esi,%ebx
f0105309:	80 fb 19             	cmp    $0x19,%bl
f010530c:	77 08                	ja     f0105316 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010530e:	0f be d2             	movsbl %dl,%edx
f0105311:	83 ea 57             	sub    $0x57,%edx
f0105314:	eb 10                	jmp    f0105326 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105316:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105319:	89 f3                	mov    %esi,%ebx
f010531b:	80 fb 19             	cmp    $0x19,%bl
f010531e:	77 16                	ja     f0105336 <strtol+0xbd>
			dig = *s - 'A' + 10;
f0105320:	0f be d2             	movsbl %dl,%edx
f0105323:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105326:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105329:	7d 0b                	jge    f0105336 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f010532b:	83 c1 01             	add    $0x1,%ecx
f010532e:	0f af 45 10          	imul   0x10(%ebp),%eax
f0105332:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105334:	eb b9                	jmp    f01052ef <strtol+0x76>

	if (endptr)
f0105336:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010533a:	74 0d                	je     f0105349 <strtol+0xd0>
		*endptr = (char *) s;
f010533c:	8b 75 0c             	mov    0xc(%ebp),%esi
f010533f:	89 0e                	mov    %ecx,(%esi)
f0105341:	eb 06                	jmp    f0105349 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105343:	85 db                	test   %ebx,%ebx
f0105345:	74 98                	je     f01052df <strtol+0x66>
f0105347:	eb 9e                	jmp    f01052e7 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105349:	89 c2                	mov    %eax,%edx
f010534b:	f7 da                	neg    %edx
f010534d:	85 ff                	test   %edi,%edi
f010534f:	0f 45 c2             	cmovne %edx,%eax
}
f0105352:	5b                   	pop    %ebx
f0105353:	5e                   	pop    %esi
f0105354:	5f                   	pop    %edi
f0105355:	5d                   	pop    %ebp
f0105356:	c3                   	ret    
f0105357:	90                   	nop

f0105358 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105358:	fa                   	cli    

	xorw    %ax, %ax
f0105359:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f010535b:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010535d:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010535f:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f0105361:	0f 01 16             	lgdtl  (%esi)
f0105364:	74 70                	je     f01053d6 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105366:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105369:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f010536d:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105370:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105376:	08 00                	or     %al,(%eax)

f0105378 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105378:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f010537c:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010537e:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105380:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105382:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105386:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105388:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f010538a:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl    %eax, %cr3
f010538f:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105392:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105395:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f010539a:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f010539d:	8b 25 84 1e 21 f0    	mov    0xf0211e84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01053a3:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01053a8:	b8 c7 01 10 f0       	mov    $0xf01001c7,%eax
	call    *%eax
f01053ad:	ff d0                	call   *%eax

f01053af <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01053af:	eb fe                	jmp    f01053af <spin>
f01053b1:	8d 76 00             	lea    0x0(%esi),%esi

f01053b4 <gdt>:
	...
f01053bc:	ff                   	(bad)  
f01053bd:	ff 00                	incl   (%eax)
f01053bf:	00 00                	add    %al,(%eax)
f01053c1:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01053c8:	00                   	.byte 0x0
f01053c9:	92                   	xchg   %eax,%edx
f01053ca:	cf                   	iret   
	...

f01053cc <gdtdesc>:
f01053cc:	17                   	pop    %ss
f01053cd:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01053d2 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01053d2:	90                   	nop

f01053d3 <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01053d3:	55                   	push   %ebp
f01053d4:	89 e5                	mov    %esp,%ebp
f01053d6:	57                   	push   %edi
f01053d7:	56                   	push   %esi
f01053d8:	53                   	push   %ebx
f01053d9:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01053dc:	8b 0d 88 1e 21 f0    	mov    0xf0211e88,%ecx
f01053e2:	89 c3                	mov    %eax,%ebx
f01053e4:	c1 eb 0c             	shr    $0xc,%ebx
f01053e7:	39 cb                	cmp    %ecx,%ebx
f01053e9:	72 12                	jb     f01053fd <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01053eb:	50                   	push   %eax
f01053ec:	68 24 5e 10 f0       	push   $0xf0105e24
f01053f1:	6a 57                	push   $0x57
f01053f3:	68 5d 79 10 f0       	push   $0xf010795d
f01053f8:	e8 43 ac ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01053fd:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105403:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105405:	89 c2                	mov    %eax,%edx
f0105407:	c1 ea 0c             	shr    $0xc,%edx
f010540a:	39 ca                	cmp    %ecx,%edx
f010540c:	72 12                	jb     f0105420 <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010540e:	50                   	push   %eax
f010540f:	68 24 5e 10 f0       	push   $0xf0105e24
f0105414:	6a 57                	push   $0x57
f0105416:	68 5d 79 10 f0       	push   $0xf010795d
f010541b:	e8 20 ac ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105420:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105426:	eb 2f                	jmp    f0105457 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105428:	83 ec 04             	sub    $0x4,%esp
f010542b:	6a 04                	push   $0x4
f010542d:	68 6d 79 10 f0       	push   $0xf010796d
f0105432:	53                   	push   %ebx
f0105433:	e8 e5 fd ff ff       	call   f010521d <memcmp>
f0105438:	83 c4 10             	add    $0x10,%esp
f010543b:	85 c0                	test   %eax,%eax
f010543d:	75 15                	jne    f0105454 <mpsearch1+0x81>
f010543f:	89 da                	mov    %ebx,%edx
f0105441:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105444:	0f b6 0a             	movzbl (%edx),%ecx
f0105447:	01 c8                	add    %ecx,%eax
f0105449:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f010544c:	39 d7                	cmp    %edx,%edi
f010544e:	75 f4                	jne    f0105444 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105450:	84 c0                	test   %al,%al
f0105452:	74 0e                	je     f0105462 <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105454:	83 c3 10             	add    $0x10,%ebx
f0105457:	39 f3                	cmp    %esi,%ebx
f0105459:	72 cd                	jb     f0105428 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f010545b:	b8 00 00 00 00       	mov    $0x0,%eax
f0105460:	eb 02                	jmp    f0105464 <mpsearch1+0x91>
f0105462:	89 d8                	mov    %ebx,%eax
}
f0105464:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105467:	5b                   	pop    %ebx
f0105468:	5e                   	pop    %esi
f0105469:	5f                   	pop    %edi
f010546a:	5d                   	pop    %ebp
f010546b:	c3                   	ret    

f010546c <mp_init>:
	return conf;
}

void
mp_init(void)
{
f010546c:	55                   	push   %ebp
f010546d:	89 e5                	mov    %esp,%ebp
f010546f:	57                   	push   %edi
f0105470:	56                   	push   %esi
f0105471:	53                   	push   %ebx
f0105472:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105475:	c7 05 c0 23 21 f0 20 	movl   $0xf0212020,0xf02123c0
f010547c:	20 21 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010547f:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0105486:	75 16                	jne    f010549e <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105488:	68 00 04 00 00       	push   $0x400
f010548d:	68 24 5e 10 f0       	push   $0xf0105e24
f0105492:	6a 6f                	push   $0x6f
f0105494:	68 5d 79 10 f0       	push   $0xf010795d
f0105499:	e8 a2 ab ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f010549e:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01054a5:	85 c0                	test   %eax,%eax
f01054a7:	74 16                	je     f01054bf <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01054a9:	c1 e0 04             	shl    $0x4,%eax
f01054ac:	ba 00 04 00 00       	mov    $0x400,%edx
f01054b1:	e8 1d ff ff ff       	call   f01053d3 <mpsearch1>
f01054b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054b9:	85 c0                	test   %eax,%eax
f01054bb:	75 3c                	jne    f01054f9 <mp_init+0x8d>
f01054bd:	eb 20                	jmp    f01054df <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01054bf:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01054c6:	c1 e0 0a             	shl    $0xa,%eax
f01054c9:	2d 00 04 00 00       	sub    $0x400,%eax
f01054ce:	ba 00 04 00 00       	mov    $0x400,%edx
f01054d3:	e8 fb fe ff ff       	call   f01053d3 <mpsearch1>
f01054d8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054db:	85 c0                	test   %eax,%eax
f01054dd:	75 1a                	jne    f01054f9 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01054df:	ba 00 00 01 00       	mov    $0x10000,%edx
f01054e4:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f01054e9:	e8 e5 fe ff ff       	call   f01053d3 <mpsearch1>
f01054ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f01054f1:	85 c0                	test   %eax,%eax
f01054f3:	0f 84 5d 02 00 00    	je     f0105756 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f01054f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01054fc:	8b 70 04             	mov    0x4(%eax),%esi
f01054ff:	85 f6                	test   %esi,%esi
f0105501:	74 06                	je     f0105509 <mp_init+0x9d>
f0105503:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105507:	74 15                	je     f010551e <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105509:	83 ec 0c             	sub    $0xc,%esp
f010550c:	68 d0 77 10 f0       	push   $0xf01077d0
f0105511:	e8 5e e0 ff ff       	call   f0103574 <cprintf>
f0105516:	83 c4 10             	add    $0x10,%esp
f0105519:	e9 38 02 00 00       	jmp    f0105756 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010551e:	89 f0                	mov    %esi,%eax
f0105520:	c1 e8 0c             	shr    $0xc,%eax
f0105523:	3b 05 88 1e 21 f0    	cmp    0xf0211e88,%eax
f0105529:	72 15                	jb     f0105540 <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010552b:	56                   	push   %esi
f010552c:	68 24 5e 10 f0       	push   $0xf0105e24
f0105531:	68 90 00 00 00       	push   $0x90
f0105536:	68 5d 79 10 f0       	push   $0xf010795d
f010553b:	e8 00 ab ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105540:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105546:	83 ec 04             	sub    $0x4,%esp
f0105549:	6a 04                	push   $0x4
f010554b:	68 72 79 10 f0       	push   $0xf0107972
f0105550:	53                   	push   %ebx
f0105551:	e8 c7 fc ff ff       	call   f010521d <memcmp>
f0105556:	83 c4 10             	add    $0x10,%esp
f0105559:	85 c0                	test   %eax,%eax
f010555b:	74 15                	je     f0105572 <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f010555d:	83 ec 0c             	sub    $0xc,%esp
f0105560:	68 00 78 10 f0       	push   $0xf0107800
f0105565:	e8 0a e0 ff ff       	call   f0103574 <cprintf>
f010556a:	83 c4 10             	add    $0x10,%esp
f010556d:	e9 e4 01 00 00       	jmp    f0105756 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105572:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105576:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f010557a:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f010557d:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105582:	b8 00 00 00 00       	mov    $0x0,%eax
f0105587:	eb 0d                	jmp    f0105596 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f0105589:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f0105590:	f0 
f0105591:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105593:	83 c0 01             	add    $0x1,%eax
f0105596:	39 c7                	cmp    %eax,%edi
f0105598:	75 ef                	jne    f0105589 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010559a:	84 d2                	test   %dl,%dl
f010559c:	74 15                	je     f01055b3 <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f010559e:	83 ec 0c             	sub    $0xc,%esp
f01055a1:	68 34 78 10 f0       	push   $0xf0107834
f01055a6:	e8 c9 df ff ff       	call   f0103574 <cprintf>
f01055ab:	83 c4 10             	add    $0x10,%esp
f01055ae:	e9 a3 01 00 00       	jmp    f0105756 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01055b3:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01055b7:	3c 01                	cmp    $0x1,%al
f01055b9:	74 1d                	je     f01055d8 <mp_init+0x16c>
f01055bb:	3c 04                	cmp    $0x4,%al
f01055bd:	74 19                	je     f01055d8 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01055bf:	83 ec 08             	sub    $0x8,%esp
f01055c2:	0f b6 c0             	movzbl %al,%eax
f01055c5:	50                   	push   %eax
f01055c6:	68 58 78 10 f0       	push   $0xf0107858
f01055cb:	e8 a4 df ff ff       	call   f0103574 <cprintf>
f01055d0:	83 c4 10             	add    $0x10,%esp
f01055d3:	e9 7e 01 00 00       	jmp    f0105756 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01055d8:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01055dc:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01055e0:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f01055e5:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f01055ea:	01 ce                	add    %ecx,%esi
f01055ec:	eb 0d                	jmp    f01055fb <mp_init+0x18f>
f01055ee:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f01055f5:	f0 
f01055f6:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01055f8:	83 c0 01             	add    $0x1,%eax
f01055fb:	39 c7                	cmp    %eax,%edi
f01055fd:	75 ef                	jne    f01055ee <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01055ff:	89 d0                	mov    %edx,%eax
f0105601:	02 43 2a             	add    0x2a(%ebx),%al
f0105604:	74 15                	je     f010561b <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105606:	83 ec 0c             	sub    $0xc,%esp
f0105609:	68 78 78 10 f0       	push   $0xf0107878
f010560e:	e8 61 df ff ff       	call   f0103574 <cprintf>
f0105613:	83 c4 10             	add    $0x10,%esp
f0105616:	e9 3b 01 00 00       	jmp    f0105756 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f010561b:	85 db                	test   %ebx,%ebx
f010561d:	0f 84 33 01 00 00    	je     f0105756 <mp_init+0x2ea>
		return;
	ismp = 1;
f0105623:	c7 05 00 20 21 f0 01 	movl   $0x1,0xf0212000
f010562a:	00 00 00 
	lapicaddr = conf->lapicaddr;
f010562d:	8b 43 24             	mov    0x24(%ebx),%eax
f0105630:	a3 00 30 25 f0       	mov    %eax,0xf0253000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105635:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105638:	be 00 00 00 00       	mov    $0x0,%esi
f010563d:	e9 85 00 00 00       	jmp    f01056c7 <mp_init+0x25b>
		switch (*p) {
f0105642:	0f b6 07             	movzbl (%edi),%eax
f0105645:	84 c0                	test   %al,%al
f0105647:	74 06                	je     f010564f <mp_init+0x1e3>
f0105649:	3c 04                	cmp    $0x4,%al
f010564b:	77 55                	ja     f01056a2 <mp_init+0x236>
f010564d:	eb 4e                	jmp    f010569d <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010564f:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f0105653:	74 11                	je     f0105666 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105655:	6b 05 c4 23 21 f0 74 	imul   $0x74,0xf02123c4,%eax
f010565c:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105661:	a3 c0 23 21 f0       	mov    %eax,0xf02123c0
			if (ncpu < NCPU) {
f0105666:	a1 c4 23 21 f0       	mov    0xf02123c4,%eax
f010566b:	83 f8 07             	cmp    $0x7,%eax
f010566e:	7f 13                	jg     f0105683 <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f0105670:	6b d0 74             	imul   $0x74,%eax,%edx
f0105673:	88 82 20 20 21 f0    	mov    %al,-0xfdedfe0(%edx)
				ncpu++;
f0105679:	83 c0 01             	add    $0x1,%eax
f010567c:	a3 c4 23 21 f0       	mov    %eax,0xf02123c4
f0105681:	eb 15                	jmp    f0105698 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105683:	83 ec 08             	sub    $0x8,%esp
f0105686:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f010568a:	50                   	push   %eax
f010568b:	68 a8 78 10 f0       	push   $0xf01078a8
f0105690:	e8 df de ff ff       	call   f0103574 <cprintf>
f0105695:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105698:	83 c7 14             	add    $0x14,%edi
			continue;
f010569b:	eb 27                	jmp    f01056c4 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f010569d:	83 c7 08             	add    $0x8,%edi
			continue;
f01056a0:	eb 22                	jmp    f01056c4 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01056a2:	83 ec 08             	sub    $0x8,%esp
f01056a5:	0f b6 c0             	movzbl %al,%eax
f01056a8:	50                   	push   %eax
f01056a9:	68 d0 78 10 f0       	push   $0xf01078d0
f01056ae:	e8 c1 de ff ff       	call   f0103574 <cprintf>
			ismp = 0;
f01056b3:	c7 05 00 20 21 f0 00 	movl   $0x0,0xf0212000
f01056ba:	00 00 00 
			i = conf->entry;
f01056bd:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f01056c1:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01056c4:	83 c6 01             	add    $0x1,%esi
f01056c7:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01056cb:	39 c6                	cmp    %eax,%esi
f01056cd:	0f 82 6f ff ff ff    	jb     f0105642 <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01056d3:	a1 c0 23 21 f0       	mov    0xf02123c0,%eax
f01056d8:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01056df:	83 3d 00 20 21 f0 00 	cmpl   $0x0,0xf0212000
f01056e6:	75 26                	jne    f010570e <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f01056e8:	c7 05 c4 23 21 f0 01 	movl   $0x1,0xf02123c4
f01056ef:	00 00 00 
		lapicaddr = 0;
f01056f2:	c7 05 00 30 25 f0 00 	movl   $0x0,0xf0253000
f01056f9:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f01056fc:	83 ec 0c             	sub    $0xc,%esp
f01056ff:	68 f0 78 10 f0       	push   $0xf01078f0
f0105704:	e8 6b de ff ff       	call   f0103574 <cprintf>
		return;
f0105709:	83 c4 10             	add    $0x10,%esp
f010570c:	eb 48                	jmp    f0105756 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010570e:	83 ec 04             	sub    $0x4,%esp
f0105711:	ff 35 c4 23 21 f0    	pushl  0xf02123c4
f0105717:	0f b6 00             	movzbl (%eax),%eax
f010571a:	50                   	push   %eax
f010571b:	68 77 79 10 f0       	push   $0xf0107977
f0105720:	e8 4f de ff ff       	call   f0103574 <cprintf>

	if (mp->imcrp) {
f0105725:	83 c4 10             	add    $0x10,%esp
f0105728:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010572b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010572f:	74 25                	je     f0105756 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105731:	83 ec 0c             	sub    $0xc,%esp
f0105734:	68 1c 79 10 f0       	push   $0xf010791c
f0105739:	e8 36 de ff ff       	call   f0103574 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010573e:	ba 22 00 00 00       	mov    $0x22,%edx
f0105743:	b8 70 00 00 00       	mov    $0x70,%eax
f0105748:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105749:	ba 23 00 00 00       	mov    $0x23,%edx
f010574e:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010574f:	83 c8 01             	or     $0x1,%eax
f0105752:	ee                   	out    %al,(%dx)
f0105753:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105756:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105759:	5b                   	pop    %ebx
f010575a:	5e                   	pop    %esi
f010575b:	5f                   	pop    %edi
f010575c:	5d                   	pop    %ebp
f010575d:	c3                   	ret    

f010575e <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010575e:	55                   	push   %ebp
f010575f:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105761:	8b 0d 04 30 25 f0    	mov    0xf0253004,%ecx
f0105767:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f010576a:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f010576c:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f0105771:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105774:	5d                   	pop    %ebp
f0105775:	c3                   	ret    

f0105776 <cpunum>:
}

// 获取CPU ID
int
cpunum(void)
{
f0105776:	55                   	push   %ebp
f0105777:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105779:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f010577e:	85 c0                	test   %eax,%eax
f0105780:	74 08                	je     f010578a <cpunum+0x14>
		return lapic[ID] >> 24;
f0105782:	8b 40 20             	mov    0x20(%eax),%eax
f0105785:	c1 e8 18             	shr    $0x18,%eax
f0105788:	eb 05                	jmp    f010578f <cpunum+0x19>
	return 0;
f010578a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010578f:	5d                   	pop    %ebp
f0105790:	c3                   	ret    

f0105791 <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f0105791:	a1 00 30 25 f0       	mov    0xf0253000,%eax
f0105796:	85 c0                	test   %eax,%eax
f0105798:	0f 84 21 01 00 00    	je     f01058bf <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f010579e:	55                   	push   %ebp
f010579f:	89 e5                	mov    %esp,%ebp
f01057a1:	83 ec 10             	sub    $0x10,%esp
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	// 将LAPIC 4KB的物理地址映射到虚拟地址
	lapic = mmio_map_region(lapicaddr, 4096);
f01057a4:	68 00 10 00 00       	push   $0x1000
f01057a9:	50                   	push   %eax
f01057aa:	e8 07 ba ff ff       	call   f01011b6 <mmio_map_region>
f01057af:	a3 04 30 25 f0       	mov    %eax,0xf0253004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01057b4:	ba 27 01 00 00       	mov    $0x127,%edx
f01057b9:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01057be:	e8 9b ff ff ff       	call   f010575e <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01057c3:	ba 0b 00 00 00       	mov    $0xb,%edx
f01057c8:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01057cd:	e8 8c ff ff ff       	call   f010575e <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01057d2:	ba 20 00 02 00       	mov    $0x20020,%edx
f01057d7:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01057dc:	e8 7d ff ff ff       	call   f010575e <lapicw>
	lapicw(TICR, 10000000); 
f01057e1:	ba 80 96 98 00       	mov    $0x989680,%edx
f01057e6:	b8 e0 00 00 00       	mov    $0xe0,%eax
f01057eb:	e8 6e ff ff ff       	call   f010575e <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f01057f0:	e8 81 ff ff ff       	call   f0105776 <cpunum>
f01057f5:	6b c0 74             	imul   $0x74,%eax,%eax
f01057f8:	05 20 20 21 f0       	add    $0xf0212020,%eax
f01057fd:	83 c4 10             	add    $0x10,%esp
f0105800:	39 05 c0 23 21 f0    	cmp    %eax,0xf02123c0
f0105806:	74 0f                	je     f0105817 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105808:	ba 00 00 01 00       	mov    $0x10000,%edx
f010580d:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105812:	e8 47 ff ff ff       	call   f010575e <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105817:	ba 00 00 01 00       	mov    $0x10000,%edx
f010581c:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105821:	e8 38 ff ff ff       	call   f010575e <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105826:	a1 04 30 25 f0       	mov    0xf0253004,%eax
f010582b:	8b 40 30             	mov    0x30(%eax),%eax
f010582e:	c1 e8 10             	shr    $0x10,%eax
f0105831:	3c 03                	cmp    $0x3,%al
f0105833:	76 0f                	jbe    f0105844 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105835:	ba 00 00 01 00       	mov    $0x10000,%edx
f010583a:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010583f:	e8 1a ff ff ff       	call   f010575e <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105844:	ba 33 00 00 00       	mov    $0x33,%edx
f0105849:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010584e:	e8 0b ff ff ff       	call   f010575e <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f0105853:	ba 00 00 00 00       	mov    $0x0,%edx
f0105858:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010585d:	e8 fc fe ff ff       	call   f010575e <lapicw>
	lapicw(ESR, 0);
f0105862:	ba 00 00 00 00       	mov    $0x0,%edx
f0105867:	b8 a0 00 00 00       	mov    $0xa0,%eax
f010586c:	e8 ed fe ff ff       	call   f010575e <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f0105871:	ba 00 00 00 00       	mov    $0x0,%edx
f0105876:	b8 2c 00 00 00       	mov    $0x2c,%eax
f010587b:	e8 de fe ff ff       	call   f010575e <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f0105880:	ba 00 00 00 00       	mov    $0x0,%edx
f0105885:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010588a:	e8 cf fe ff ff       	call   f010575e <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010588f:	ba 00 85 08 00       	mov    $0x88500,%edx
f0105894:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105899:	e8 c0 fe ff ff       	call   f010575e <lapicw>
	while(lapic[ICRLO] & DELIVS)
f010589e:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f01058a4:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01058aa:	f6 c4 10             	test   $0x10,%ah
f01058ad:	75 f5                	jne    f01058a4 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01058af:	ba 00 00 00 00       	mov    $0x0,%edx
f01058b4:	b8 20 00 00 00       	mov    $0x20,%eax
f01058b9:	e8 a0 fe ff ff       	call   f010575e <lapicw>
}
f01058be:	c9                   	leave  
f01058bf:	f3 c3                	repz ret 

f01058c1 <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01058c1:	83 3d 04 30 25 f0 00 	cmpl   $0x0,0xf0253004
f01058c8:	74 13                	je     f01058dd <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01058ca:	55                   	push   %ebp
f01058cb:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01058cd:	ba 00 00 00 00       	mov    $0x0,%edx
f01058d2:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01058d7:	e8 82 fe ff ff       	call   f010575e <lapicw>
}
f01058dc:	5d                   	pop    %ebp
f01058dd:	f3 c3                	repz ret 

f01058df <lapic_startap>:
// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
// 唤醒某个CPU
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01058df:	55                   	push   %ebp
f01058e0:	89 e5                	mov    %esp,%ebp
f01058e2:	56                   	push   %esi
f01058e3:	53                   	push   %ebx
f01058e4:	8b 75 08             	mov    0x8(%ebp),%esi
f01058e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01058ea:	ba 70 00 00 00       	mov    $0x70,%edx
f01058ef:	b8 0f 00 00 00       	mov    $0xf,%eax
f01058f4:	ee                   	out    %al,(%dx)
f01058f5:	ba 71 00 00 00       	mov    $0x71,%edx
f01058fa:	b8 0a 00 00 00       	mov    $0xa,%eax
f01058ff:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105900:	83 3d 88 1e 21 f0 00 	cmpl   $0x0,0xf0211e88
f0105907:	75 19                	jne    f0105922 <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105909:	68 67 04 00 00       	push   $0x467
f010590e:	68 24 5e 10 f0       	push   $0xf0105e24
f0105913:	68 9b 00 00 00       	push   $0x9b
f0105918:	68 94 79 10 f0       	push   $0xf0107994
f010591d:	e8 1e a7 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105922:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105929:	00 00 
	wrv[1] = addr >> 4;
f010592b:	89 d8                	mov    %ebx,%eax
f010592d:	c1 e8 04             	shr    $0x4,%eax
f0105930:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105936:	c1 e6 18             	shl    $0x18,%esi
f0105939:	89 f2                	mov    %esi,%edx
f010593b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105940:	e8 19 fe ff ff       	call   f010575e <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105945:	ba 00 c5 00 00       	mov    $0xc500,%edx
f010594a:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010594f:	e8 0a fe ff ff       	call   f010575e <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105954:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105959:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010595e:	e8 fb fd ff ff       	call   f010575e <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105963:	c1 eb 0c             	shr    $0xc,%ebx
f0105966:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105969:	89 f2                	mov    %esi,%edx
f010596b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105970:	e8 e9 fd ff ff       	call   f010575e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105975:	89 da                	mov    %ebx,%edx
f0105977:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010597c:	e8 dd fd ff ff       	call   f010575e <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105981:	89 f2                	mov    %esi,%edx
f0105983:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105988:	e8 d1 fd ff ff       	call   f010575e <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010598d:	89 da                	mov    %ebx,%edx
f010598f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105994:	e8 c5 fd ff ff       	call   f010575e <lapicw>
		microdelay(200);
	}
}
f0105999:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010599c:	5b                   	pop    %ebx
f010599d:	5e                   	pop    %esi
f010599e:	5d                   	pop    %ebp
f010599f:	c3                   	ret    

f01059a0 <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01059a0:	55                   	push   %ebp
f01059a1:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01059a3:	8b 55 08             	mov    0x8(%ebp),%edx
f01059a6:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01059ac:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01059b1:	e8 a8 fd ff ff       	call   f010575e <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01059b6:	8b 15 04 30 25 f0    	mov    0xf0253004,%edx
f01059bc:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01059c2:	f6 c4 10             	test   $0x10,%ah
f01059c5:	75 f5                	jne    f01059bc <lapic_ipi+0x1c>
		;
}
f01059c7:	5d                   	pop    %ebp
f01059c8:	c3                   	ret    

f01059c9 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01059c9:	55                   	push   %ebp
f01059ca:	89 e5                	mov    %esp,%ebp
f01059cc:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01059cf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01059d5:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059d8:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01059db:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01059e2:	5d                   	pop    %ebp
f01059e3:	c3                   	ret    

f01059e4 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f01059e4:	55                   	push   %ebp
f01059e5:	89 e5                	mov    %esp,%ebp
f01059e7:	56                   	push   %esi
f01059e8:	53                   	push   %ebx
f01059e9:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f01059ec:	83 3b 00             	cmpl   $0x0,(%ebx)
f01059ef:	74 14                	je     f0105a05 <spin_lock+0x21>
f01059f1:	8b 73 08             	mov    0x8(%ebx),%esi
f01059f4:	e8 7d fd ff ff       	call   f0105776 <cpunum>
f01059f9:	6b c0 74             	imul   $0x74,%eax,%eax
f01059fc:	05 20 20 21 f0       	add    $0xf0212020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105a01:	39 c6                	cmp    %eax,%esi
f0105a03:	74 07                	je     f0105a0c <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105a05:	ba 01 00 00 00       	mov    $0x1,%edx
f0105a0a:	eb 20                	jmp    f0105a2c <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105a0c:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105a0f:	e8 62 fd ff ff       	call   f0105776 <cpunum>
f0105a14:	83 ec 0c             	sub    $0xc,%esp
f0105a17:	53                   	push   %ebx
f0105a18:	50                   	push   %eax
f0105a19:	68 a4 79 10 f0       	push   $0xf01079a4
f0105a1e:	6a 41                	push   $0x41
f0105a20:	68 08 7a 10 f0       	push   $0xf0107a08
f0105a25:	e8 16 a6 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105a2a:	f3 90                	pause  
f0105a2c:	89 d0                	mov    %edx,%eax
f0105a2e:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105a31:	85 c0                	test   %eax,%eax
f0105a33:	75 f5                	jne    f0105a2a <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105a35:	e8 3c fd ff ff       	call   f0105776 <cpunum>
f0105a3a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a3d:	05 20 20 21 f0       	add    $0xf0212020,%eax
f0105a42:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105a45:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105a48:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105a4a:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a4f:	eb 0b                	jmp    f0105a5c <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105a51:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105a54:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105a57:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105a59:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105a5c:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105a62:	76 11                	jbe    f0105a75 <spin_lock+0x91>
f0105a64:	83 f8 09             	cmp    $0x9,%eax
f0105a67:	7e e8                	jle    f0105a51 <spin_lock+0x6d>
f0105a69:	eb 0a                	jmp    f0105a75 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105a6b:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105a72:	83 c0 01             	add    $0x1,%eax
f0105a75:	83 f8 09             	cmp    $0x9,%eax
f0105a78:	7e f1                	jle    f0105a6b <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105a7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105a7d:	5b                   	pop    %ebx
f0105a7e:	5e                   	pop    %esi
f0105a7f:	5d                   	pop    %ebp
f0105a80:	c3                   	ret    

f0105a81 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105a81:	55                   	push   %ebp
f0105a82:	89 e5                	mov    %esp,%ebp
f0105a84:	57                   	push   %edi
f0105a85:	56                   	push   %esi
f0105a86:	53                   	push   %ebx
f0105a87:	83 ec 4c             	sub    $0x4c,%esp
f0105a8a:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105a8d:	83 3e 00             	cmpl   $0x0,(%esi)
f0105a90:	74 18                	je     f0105aaa <spin_unlock+0x29>
f0105a92:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105a95:	e8 dc fc ff ff       	call   f0105776 <cpunum>
f0105a9a:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a9d:	05 20 20 21 f0       	add    $0xf0212020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105aa2:	39 c3                	cmp    %eax,%ebx
f0105aa4:	0f 84 a5 00 00 00    	je     f0105b4f <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105aaa:	83 ec 04             	sub    $0x4,%esp
f0105aad:	6a 28                	push   $0x28
f0105aaf:	8d 46 0c             	lea    0xc(%esi),%eax
f0105ab2:	50                   	push   %eax
f0105ab3:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105ab6:	53                   	push   %ebx
f0105ab7:	e8 e6 f6 ff ff       	call   f01051a2 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105abc:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105abf:	0f b6 38             	movzbl (%eax),%edi
f0105ac2:	8b 76 04             	mov    0x4(%esi),%esi
f0105ac5:	e8 ac fc ff ff       	call   f0105776 <cpunum>
f0105aca:	57                   	push   %edi
f0105acb:	56                   	push   %esi
f0105acc:	50                   	push   %eax
f0105acd:	68 d0 79 10 f0       	push   $0xf01079d0
f0105ad2:	e8 9d da ff ff       	call   f0103574 <cprintf>
f0105ad7:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105ada:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105add:	eb 54                	jmp    f0105b33 <spin_unlock+0xb2>
f0105adf:	83 ec 08             	sub    $0x8,%esp
f0105ae2:	57                   	push   %edi
f0105ae3:	50                   	push   %eax
f0105ae4:	e8 76 ec ff ff       	call   f010475f <debuginfo_eip>
f0105ae9:	83 c4 10             	add    $0x10,%esp
f0105aec:	85 c0                	test   %eax,%eax
f0105aee:	78 27                	js     f0105b17 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105af0:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105af2:	83 ec 04             	sub    $0x4,%esp
f0105af5:	89 c2                	mov    %eax,%edx
f0105af7:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105afa:	52                   	push   %edx
f0105afb:	ff 75 b0             	pushl  -0x50(%ebp)
f0105afe:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105b01:	ff 75 ac             	pushl  -0x54(%ebp)
f0105b04:	ff 75 a8             	pushl  -0x58(%ebp)
f0105b07:	50                   	push   %eax
f0105b08:	68 18 7a 10 f0       	push   $0xf0107a18
f0105b0d:	e8 62 da ff ff       	call   f0103574 <cprintf>
f0105b12:	83 c4 20             	add    $0x20,%esp
f0105b15:	eb 12                	jmp    f0105b29 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105b17:	83 ec 08             	sub    $0x8,%esp
f0105b1a:	ff 36                	pushl  (%esi)
f0105b1c:	68 2f 7a 10 f0       	push   $0xf0107a2f
f0105b21:	e8 4e da ff ff       	call   f0103574 <cprintf>
f0105b26:	83 c4 10             	add    $0x10,%esp
f0105b29:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105b2c:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105b2f:	39 c3                	cmp    %eax,%ebx
f0105b31:	74 08                	je     f0105b3b <spin_unlock+0xba>
f0105b33:	89 de                	mov    %ebx,%esi
f0105b35:	8b 03                	mov    (%ebx),%eax
f0105b37:	85 c0                	test   %eax,%eax
f0105b39:	75 a4                	jne    f0105adf <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105b3b:	83 ec 04             	sub    $0x4,%esp
f0105b3e:	68 37 7a 10 f0       	push   $0xf0107a37
f0105b43:	6a 67                	push   $0x67
f0105b45:	68 08 7a 10 f0       	push   $0xf0107a08
f0105b4a:	e8 f1 a4 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105b4f:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105b56:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105b5d:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b62:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b68:	5b                   	pop    %ebx
f0105b69:	5e                   	pop    %esi
f0105b6a:	5f                   	pop    %edi
f0105b6b:	5d                   	pop    %ebp
f0105b6c:	c3                   	ret    
f0105b6d:	66 90                	xchg   %ax,%ax
f0105b6f:	90                   	nop

f0105b70 <__udivdi3>:
f0105b70:	55                   	push   %ebp
f0105b71:	57                   	push   %edi
f0105b72:	56                   	push   %esi
f0105b73:	53                   	push   %ebx
f0105b74:	83 ec 1c             	sub    $0x1c,%esp
f0105b77:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105b7b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105b7f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105b83:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105b87:	85 f6                	test   %esi,%esi
f0105b89:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105b8d:	89 ca                	mov    %ecx,%edx
f0105b8f:	89 f8                	mov    %edi,%eax
f0105b91:	75 3d                	jne    f0105bd0 <__udivdi3+0x60>
f0105b93:	39 cf                	cmp    %ecx,%edi
f0105b95:	0f 87 c5 00 00 00    	ja     f0105c60 <__udivdi3+0xf0>
f0105b9b:	85 ff                	test   %edi,%edi
f0105b9d:	89 fd                	mov    %edi,%ebp
f0105b9f:	75 0b                	jne    f0105bac <__udivdi3+0x3c>
f0105ba1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105ba6:	31 d2                	xor    %edx,%edx
f0105ba8:	f7 f7                	div    %edi
f0105baa:	89 c5                	mov    %eax,%ebp
f0105bac:	89 c8                	mov    %ecx,%eax
f0105bae:	31 d2                	xor    %edx,%edx
f0105bb0:	f7 f5                	div    %ebp
f0105bb2:	89 c1                	mov    %eax,%ecx
f0105bb4:	89 d8                	mov    %ebx,%eax
f0105bb6:	89 cf                	mov    %ecx,%edi
f0105bb8:	f7 f5                	div    %ebp
f0105bba:	89 c3                	mov    %eax,%ebx
f0105bbc:	89 d8                	mov    %ebx,%eax
f0105bbe:	89 fa                	mov    %edi,%edx
f0105bc0:	83 c4 1c             	add    $0x1c,%esp
f0105bc3:	5b                   	pop    %ebx
f0105bc4:	5e                   	pop    %esi
f0105bc5:	5f                   	pop    %edi
f0105bc6:	5d                   	pop    %ebp
f0105bc7:	c3                   	ret    
f0105bc8:	90                   	nop
f0105bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105bd0:	39 ce                	cmp    %ecx,%esi
f0105bd2:	77 74                	ja     f0105c48 <__udivdi3+0xd8>
f0105bd4:	0f bd fe             	bsr    %esi,%edi
f0105bd7:	83 f7 1f             	xor    $0x1f,%edi
f0105bda:	0f 84 98 00 00 00    	je     f0105c78 <__udivdi3+0x108>
f0105be0:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105be5:	89 f9                	mov    %edi,%ecx
f0105be7:	89 c5                	mov    %eax,%ebp
f0105be9:	29 fb                	sub    %edi,%ebx
f0105beb:	d3 e6                	shl    %cl,%esi
f0105bed:	89 d9                	mov    %ebx,%ecx
f0105bef:	d3 ed                	shr    %cl,%ebp
f0105bf1:	89 f9                	mov    %edi,%ecx
f0105bf3:	d3 e0                	shl    %cl,%eax
f0105bf5:	09 ee                	or     %ebp,%esi
f0105bf7:	89 d9                	mov    %ebx,%ecx
f0105bf9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105bfd:	89 d5                	mov    %edx,%ebp
f0105bff:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105c03:	d3 ed                	shr    %cl,%ebp
f0105c05:	89 f9                	mov    %edi,%ecx
f0105c07:	d3 e2                	shl    %cl,%edx
f0105c09:	89 d9                	mov    %ebx,%ecx
f0105c0b:	d3 e8                	shr    %cl,%eax
f0105c0d:	09 c2                	or     %eax,%edx
f0105c0f:	89 d0                	mov    %edx,%eax
f0105c11:	89 ea                	mov    %ebp,%edx
f0105c13:	f7 f6                	div    %esi
f0105c15:	89 d5                	mov    %edx,%ebp
f0105c17:	89 c3                	mov    %eax,%ebx
f0105c19:	f7 64 24 0c          	mull   0xc(%esp)
f0105c1d:	39 d5                	cmp    %edx,%ebp
f0105c1f:	72 10                	jb     f0105c31 <__udivdi3+0xc1>
f0105c21:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105c25:	89 f9                	mov    %edi,%ecx
f0105c27:	d3 e6                	shl    %cl,%esi
f0105c29:	39 c6                	cmp    %eax,%esi
f0105c2b:	73 07                	jae    f0105c34 <__udivdi3+0xc4>
f0105c2d:	39 d5                	cmp    %edx,%ebp
f0105c2f:	75 03                	jne    f0105c34 <__udivdi3+0xc4>
f0105c31:	83 eb 01             	sub    $0x1,%ebx
f0105c34:	31 ff                	xor    %edi,%edi
f0105c36:	89 d8                	mov    %ebx,%eax
f0105c38:	89 fa                	mov    %edi,%edx
f0105c3a:	83 c4 1c             	add    $0x1c,%esp
f0105c3d:	5b                   	pop    %ebx
f0105c3e:	5e                   	pop    %esi
f0105c3f:	5f                   	pop    %edi
f0105c40:	5d                   	pop    %ebp
f0105c41:	c3                   	ret    
f0105c42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105c48:	31 ff                	xor    %edi,%edi
f0105c4a:	31 db                	xor    %ebx,%ebx
f0105c4c:	89 d8                	mov    %ebx,%eax
f0105c4e:	89 fa                	mov    %edi,%edx
f0105c50:	83 c4 1c             	add    $0x1c,%esp
f0105c53:	5b                   	pop    %ebx
f0105c54:	5e                   	pop    %esi
f0105c55:	5f                   	pop    %edi
f0105c56:	5d                   	pop    %ebp
f0105c57:	c3                   	ret    
f0105c58:	90                   	nop
f0105c59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105c60:	89 d8                	mov    %ebx,%eax
f0105c62:	f7 f7                	div    %edi
f0105c64:	31 ff                	xor    %edi,%edi
f0105c66:	89 c3                	mov    %eax,%ebx
f0105c68:	89 d8                	mov    %ebx,%eax
f0105c6a:	89 fa                	mov    %edi,%edx
f0105c6c:	83 c4 1c             	add    $0x1c,%esp
f0105c6f:	5b                   	pop    %ebx
f0105c70:	5e                   	pop    %esi
f0105c71:	5f                   	pop    %edi
f0105c72:	5d                   	pop    %ebp
f0105c73:	c3                   	ret    
f0105c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105c78:	39 ce                	cmp    %ecx,%esi
f0105c7a:	72 0c                	jb     f0105c88 <__udivdi3+0x118>
f0105c7c:	31 db                	xor    %ebx,%ebx
f0105c7e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105c82:	0f 87 34 ff ff ff    	ja     f0105bbc <__udivdi3+0x4c>
f0105c88:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105c8d:	e9 2a ff ff ff       	jmp    f0105bbc <__udivdi3+0x4c>
f0105c92:	66 90                	xchg   %ax,%ax
f0105c94:	66 90                	xchg   %ax,%ax
f0105c96:	66 90                	xchg   %ax,%ax
f0105c98:	66 90                	xchg   %ax,%ax
f0105c9a:	66 90                	xchg   %ax,%ax
f0105c9c:	66 90                	xchg   %ax,%ax
f0105c9e:	66 90                	xchg   %ax,%ax

f0105ca0 <__umoddi3>:
f0105ca0:	55                   	push   %ebp
f0105ca1:	57                   	push   %edi
f0105ca2:	56                   	push   %esi
f0105ca3:	53                   	push   %ebx
f0105ca4:	83 ec 1c             	sub    $0x1c,%esp
f0105ca7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105cab:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105caf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105cb3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105cb7:	85 d2                	test   %edx,%edx
f0105cb9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105cbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105cc1:	89 f3                	mov    %esi,%ebx
f0105cc3:	89 3c 24             	mov    %edi,(%esp)
f0105cc6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105cca:	75 1c                	jne    f0105ce8 <__umoddi3+0x48>
f0105ccc:	39 f7                	cmp    %esi,%edi
f0105cce:	76 50                	jbe    f0105d20 <__umoddi3+0x80>
f0105cd0:	89 c8                	mov    %ecx,%eax
f0105cd2:	89 f2                	mov    %esi,%edx
f0105cd4:	f7 f7                	div    %edi
f0105cd6:	89 d0                	mov    %edx,%eax
f0105cd8:	31 d2                	xor    %edx,%edx
f0105cda:	83 c4 1c             	add    $0x1c,%esp
f0105cdd:	5b                   	pop    %ebx
f0105cde:	5e                   	pop    %esi
f0105cdf:	5f                   	pop    %edi
f0105ce0:	5d                   	pop    %ebp
f0105ce1:	c3                   	ret    
f0105ce2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105ce8:	39 f2                	cmp    %esi,%edx
f0105cea:	89 d0                	mov    %edx,%eax
f0105cec:	77 52                	ja     f0105d40 <__umoddi3+0xa0>
f0105cee:	0f bd ea             	bsr    %edx,%ebp
f0105cf1:	83 f5 1f             	xor    $0x1f,%ebp
f0105cf4:	75 5a                	jne    f0105d50 <__umoddi3+0xb0>
f0105cf6:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105cfa:	0f 82 e0 00 00 00    	jb     f0105de0 <__umoddi3+0x140>
f0105d00:	39 0c 24             	cmp    %ecx,(%esp)
f0105d03:	0f 86 d7 00 00 00    	jbe    f0105de0 <__umoddi3+0x140>
f0105d09:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d0d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105d11:	83 c4 1c             	add    $0x1c,%esp
f0105d14:	5b                   	pop    %ebx
f0105d15:	5e                   	pop    %esi
f0105d16:	5f                   	pop    %edi
f0105d17:	5d                   	pop    %ebp
f0105d18:	c3                   	ret    
f0105d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105d20:	85 ff                	test   %edi,%edi
f0105d22:	89 fd                	mov    %edi,%ebp
f0105d24:	75 0b                	jne    f0105d31 <__umoddi3+0x91>
f0105d26:	b8 01 00 00 00       	mov    $0x1,%eax
f0105d2b:	31 d2                	xor    %edx,%edx
f0105d2d:	f7 f7                	div    %edi
f0105d2f:	89 c5                	mov    %eax,%ebp
f0105d31:	89 f0                	mov    %esi,%eax
f0105d33:	31 d2                	xor    %edx,%edx
f0105d35:	f7 f5                	div    %ebp
f0105d37:	89 c8                	mov    %ecx,%eax
f0105d39:	f7 f5                	div    %ebp
f0105d3b:	89 d0                	mov    %edx,%eax
f0105d3d:	eb 99                	jmp    f0105cd8 <__umoddi3+0x38>
f0105d3f:	90                   	nop
f0105d40:	89 c8                	mov    %ecx,%eax
f0105d42:	89 f2                	mov    %esi,%edx
f0105d44:	83 c4 1c             	add    $0x1c,%esp
f0105d47:	5b                   	pop    %ebx
f0105d48:	5e                   	pop    %esi
f0105d49:	5f                   	pop    %edi
f0105d4a:	5d                   	pop    %ebp
f0105d4b:	c3                   	ret    
f0105d4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105d50:	8b 34 24             	mov    (%esp),%esi
f0105d53:	bf 20 00 00 00       	mov    $0x20,%edi
f0105d58:	89 e9                	mov    %ebp,%ecx
f0105d5a:	29 ef                	sub    %ebp,%edi
f0105d5c:	d3 e0                	shl    %cl,%eax
f0105d5e:	89 f9                	mov    %edi,%ecx
f0105d60:	89 f2                	mov    %esi,%edx
f0105d62:	d3 ea                	shr    %cl,%edx
f0105d64:	89 e9                	mov    %ebp,%ecx
f0105d66:	09 c2                	or     %eax,%edx
f0105d68:	89 d8                	mov    %ebx,%eax
f0105d6a:	89 14 24             	mov    %edx,(%esp)
f0105d6d:	89 f2                	mov    %esi,%edx
f0105d6f:	d3 e2                	shl    %cl,%edx
f0105d71:	89 f9                	mov    %edi,%ecx
f0105d73:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d77:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105d7b:	d3 e8                	shr    %cl,%eax
f0105d7d:	89 e9                	mov    %ebp,%ecx
f0105d7f:	89 c6                	mov    %eax,%esi
f0105d81:	d3 e3                	shl    %cl,%ebx
f0105d83:	89 f9                	mov    %edi,%ecx
f0105d85:	89 d0                	mov    %edx,%eax
f0105d87:	d3 e8                	shr    %cl,%eax
f0105d89:	89 e9                	mov    %ebp,%ecx
f0105d8b:	09 d8                	or     %ebx,%eax
f0105d8d:	89 d3                	mov    %edx,%ebx
f0105d8f:	89 f2                	mov    %esi,%edx
f0105d91:	f7 34 24             	divl   (%esp)
f0105d94:	89 d6                	mov    %edx,%esi
f0105d96:	d3 e3                	shl    %cl,%ebx
f0105d98:	f7 64 24 04          	mull   0x4(%esp)
f0105d9c:	39 d6                	cmp    %edx,%esi
f0105d9e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105da2:	89 d1                	mov    %edx,%ecx
f0105da4:	89 c3                	mov    %eax,%ebx
f0105da6:	72 08                	jb     f0105db0 <__umoddi3+0x110>
f0105da8:	75 11                	jne    f0105dbb <__umoddi3+0x11b>
f0105daa:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105dae:	73 0b                	jae    f0105dbb <__umoddi3+0x11b>
f0105db0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105db4:	1b 14 24             	sbb    (%esp),%edx
f0105db7:	89 d1                	mov    %edx,%ecx
f0105db9:	89 c3                	mov    %eax,%ebx
f0105dbb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0105dbf:	29 da                	sub    %ebx,%edx
f0105dc1:	19 ce                	sbb    %ecx,%esi
f0105dc3:	89 f9                	mov    %edi,%ecx
f0105dc5:	89 f0                	mov    %esi,%eax
f0105dc7:	d3 e0                	shl    %cl,%eax
f0105dc9:	89 e9                	mov    %ebp,%ecx
f0105dcb:	d3 ea                	shr    %cl,%edx
f0105dcd:	89 e9                	mov    %ebp,%ecx
f0105dcf:	d3 ee                	shr    %cl,%esi
f0105dd1:	09 d0                	or     %edx,%eax
f0105dd3:	89 f2                	mov    %esi,%edx
f0105dd5:	83 c4 1c             	add    $0x1c,%esp
f0105dd8:	5b                   	pop    %ebx
f0105dd9:	5e                   	pop    %esi
f0105dda:	5f                   	pop    %edi
f0105ddb:	5d                   	pop    %ebp
f0105ddc:	c3                   	ret    
f0105ddd:	8d 76 00             	lea    0x0(%esi),%esi
f0105de0:	29 f9                	sub    %edi,%ecx
f0105de2:	19 d6                	sbb    %edx,%esi
f0105de4:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105de8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105dec:	e9 18 ff ff ff       	jmp    f0105d09 <__umoddi3+0x69>
