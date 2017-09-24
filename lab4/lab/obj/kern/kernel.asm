
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
f0100048:	83 3d 80 ee 22 f0 00 	cmpl   $0x0,0xf022ee80
f010004f:	75 3a                	jne    f010008b <_panic+0x4b>
		goto dead;
	panicstr = fmt;
f0100051:	89 35 80 ee 22 f0    	mov    %esi,0xf022ee80

	// Be extra sure that the machine is in as reasonable state
	asm volatile("cli; cld");
f0100057:	fa                   	cli    
f0100058:	fc                   	cld    

	va_start(ap, fmt);
f0100059:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f010005c:	e8 31 57 00 00       	call   f0105792 <cpunum>
f0100061:	ff 75 0c             	pushl  0xc(%ebp)
f0100064:	ff 75 08             	pushl  0x8(%ebp)
f0100067:	50                   	push   %eax
f0100068:	68 20 5e 10 f0       	push   $0xf0105e20
f010006d:	e8 2f 35 00 00       	call   f01035a1 <cprintf>
	vcprintf(fmt, ap);
f0100072:	83 c4 08             	add    $0x8,%esp
f0100075:	53                   	push   %ebx
f0100076:	56                   	push   %esi
f0100077:	e8 ff 34 00 00       	call   f010357b <vcprintf>
	cprintf("\n");
f010007c:	c7 04 24 94 6f 10 f0 	movl   $0xf0106f94,(%esp)
f0100083:	e8 19 35 00 00       	call   f01035a1 <cprintf>
	va_end(ap);
f0100088:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f010008b:	83 ec 0c             	sub    $0xc,%esp
f010008e:	6a 00                	push   $0x0
f0100090:	e8 ec 07 00 00       	call   f0100881 <monitor>
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
f01000a1:	b8 08 00 27 f0       	mov    $0xf0270008,%eax
f01000a6:	2d 28 d6 22 f0       	sub    $0xf022d628,%eax
f01000ab:	50                   	push   %eax
f01000ac:	6a 00                	push   $0x0
f01000ae:	68 28 d6 22 f0       	push   $0xf022d628
f01000b3:	e8 ba 50 00 00       	call   f0105172 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f01000b8:	e8 82 05 00 00       	call   f010063f <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f01000bd:	83 c4 08             	add    $0x8,%esp
f01000c0:	68 ac 1a 00 00       	push   $0x1aac
f01000c5:	68 8c 5e 10 f0       	push   $0xf0105e8c
f01000ca:	e8 d2 34 00 00       	call   f01035a1 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01000cf:	e8 0e 11 00 00       	call   f01011e2 <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01000d4:	e8 f8 2c 00 00       	call   f0102dd1 <env_init>
	trap_init();
f01000d9:	e8 8e 35 00 00       	call   f010366c <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01000de:	e8 a5 53 00 00       	call   f0105488 <mp_init>
	lapic_init();
f01000e3:	e8 c5 56 00 00       	call   f01057ad <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01000e8:	e8 db 33 00 00       	call   f01034c8 <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01000ed:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f01000f4:	e8 07 59 00 00       	call   f0105a00 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01000f9:	83 c4 10             	add    $0x10,%esp
f01000fc:	83 3d 88 ee 22 f0 07 	cmpl   $0x7,0xf022ee88
f0100103:	77 16                	ja     f010011b <i386_init+0x81>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100105:	68 00 70 00 00       	push   $0x7000
f010010a:	68 44 5e 10 f0       	push   $0xf0105e44
f010010f:	6a 5c                	push   $0x5c
f0100111:	68 a7 5e 10 f0       	push   $0xf0105ea7
f0100116:	e8 25 ff ff ff       	call   f0100040 <_panic>

	// Write entry code to unused memory at MPENTRY_PADDR
	// 找到引导代码
	code = KADDR(MPENTRY_PADDR);
	// 将引导代码拷贝到 MPENTRY_PADDR
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f010011b:	83 ec 04             	sub    $0x4,%esp
f010011e:	b8 ee 53 10 f0       	mov    $0xf01053ee,%eax
f0100123:	2d 74 53 10 f0       	sub    $0xf0105374,%eax
f0100128:	50                   	push   %eax
f0100129:	68 74 53 10 f0       	push   $0xf0105374
f010012e:	68 00 70 00 f0       	push   $0xf0007000
f0100133:	e8 87 50 00 00       	call   f01051bf <memmove>
f0100138:	83 c4 10             	add    $0x10,%esp
	
	// Boot each AP one at a time
	// 逐一引导每个CPU
	for (c = cpus; c < cpus + ncpu; c++) {
f010013b:	bb 20 f0 22 f0       	mov    $0xf022f020,%ebx
f0100140:	eb 4d                	jmp    f010018f <i386_init+0xf5>
		if (c == cpus + cpunum())  // We've started already.
f0100142:	e8 4b 56 00 00       	call   f0105792 <cpunum>
f0100147:	6b c0 74             	imul   $0x74,%eax,%eax
f010014a:	05 20 f0 22 f0       	add    $0xf022f020,%eax
f010014f:	39 c3                	cmp    %eax,%ebx
f0100151:	74 39                	je     f010018c <i386_init+0xf2>
			continue;

		// Tell mpentry.S what stack to use 
		// 设置cpu的内核栈
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100153:	89 d8                	mov    %ebx,%eax
f0100155:	2d 20 f0 22 f0       	sub    $0xf022f020,%eax
f010015a:	c1 f8 02             	sar    $0x2,%eax
f010015d:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f0100163:	c1 e0 0f             	shl    $0xf,%eax
f0100166:	05 00 80 23 f0       	add    $0xf0238000,%eax
f010016b:	a3 84 ee 22 f0       	mov    %eax,0xf022ee84
		// Start the CPU at mpentry_start
		// 执行引导代码
		lapic_startap(c->cpu_id, PADDR(code));
f0100170:	83 ec 08             	sub    $0x8,%esp
f0100173:	68 00 70 00 00       	push   $0x7000
f0100178:	0f b6 03             	movzbl (%ebx),%eax
f010017b:	50                   	push   %eax
f010017c:	e8 7a 57 00 00       	call   f01058fb <lapic_startap>
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
f010018f:	6b 05 c4 f3 22 f0 74 	imul   $0x74,0xf022f3c4,%eax
f0100196:	05 20 f0 22 f0       	add    $0xf022f020,%eax
f010019b:	39 c3                	cmp    %eax,%ebx
f010019d:	72 a3                	jb     f0100142 <i386_init+0xa8>
	// Touch all you want.
	//ENV_CREATE(user_primes, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	//ENV_CREATE(user_yield, ENV_TYPE_USER);
	ENV_CREATE(user_forktree, ENV_TYPE_USER);
f010019f:	83 ec 08             	sub    $0x8,%esp
f01001a2:	6a 00                	push   $0x0
f01001a4:	68 78 d0 1e f0       	push   $0xf01ed078
f01001a9:	e8 01 2e 00 00       	call   f0102faf <env_create>
	//ENV_CREATE();
#endif // TEST*

	// Schedule and run the first user environment!
	// 进程调度
	sched_yield();
f01001ae:	e8 d7 3e 00 00       	call   f010408a <sched_yield>

f01001b3 <mp_main>:

// Setup code for APs
// cpu 启动后的调用的第一个程序
void
mp_main(void)
{
f01001b3:	55                   	push   %ebp
f01001b4:	89 e5                	mov    %esp,%ebp
f01001b6:	83 ec 08             	sub    $0x8,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01001b9:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01001be:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01001c3:	77 12                	ja     f01001d7 <mp_main+0x24>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01001c5:	50                   	push   %eax
f01001c6:	68 68 5e 10 f0       	push   $0xf0105e68
f01001cb:	6a 78                	push   $0x78
f01001cd:	68 a7 5e 10 f0       	push   $0xf0105ea7
f01001d2:	e8 69 fe ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f01001d7:	05 00 00 00 10       	add    $0x10000000,%eax
f01001dc:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f01001df:	e8 ae 55 00 00       	call   f0105792 <cpunum>
f01001e4:	83 ec 08             	sub    $0x8,%esp
f01001e7:	50                   	push   %eax
f01001e8:	68 b3 5e 10 f0       	push   $0xf0105eb3
f01001ed:	e8 af 33 00 00       	call   f01035a1 <cprintf>

	lapic_init();
f01001f2:	e8 b6 55 00 00       	call   f01057ad <lapic_init>
	env_init_percpu();
f01001f7:	e8 a5 2b 00 00       	call   f0102da1 <env_init_percpu>
	trap_init_percpu();
f01001fc:	e8 b4 33 00 00       	call   f01035b5 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f0100201:	e8 8c 55 00 00       	call   f0105792 <cpunum>
f0100206:	6b d0 74             	imul   $0x74,%eax,%edx
f0100209:	81 c2 20 f0 22 f0    	add    $0xf022f020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f010020f:	b8 01 00 00 00       	mov    $0x1,%eax
f0100214:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0100218:	c7 04 24 c0 f3 11 f0 	movl   $0xf011f3c0,(%esp)
f010021f:	e8 dc 57 00 00       	call   f0105a00 <spin_lock>
	// Your code here:
	// 获取大内核锁(在运行调度函数之前，必须获得大内核锁)
	lock_kernel();
	
	// 调度一个进程来执行
	sched_yield();
f0100224:	e8 61 3e 00 00       	call   f010408a <sched_yield>

f0100229 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100229:	55                   	push   %ebp
f010022a:	89 e5                	mov    %esp,%ebp
f010022c:	53                   	push   %ebx
f010022d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0100230:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100233:	ff 75 0c             	pushl  0xc(%ebp)
f0100236:	ff 75 08             	pushl  0x8(%ebp)
f0100239:	68 c9 5e 10 f0       	push   $0xf0105ec9
f010023e:	e8 5e 33 00 00       	call   f01035a1 <cprintf>
	vcprintf(fmt, ap);
f0100243:	83 c4 08             	add    $0x8,%esp
f0100246:	53                   	push   %ebx
f0100247:	ff 75 10             	pushl  0x10(%ebp)
f010024a:	e8 2c 33 00 00       	call   f010357b <vcprintf>
	cprintf("\n");
f010024f:	c7 04 24 94 6f 10 f0 	movl   $0xf0106f94,(%esp)
f0100256:	e8 46 33 00 00       	call   f01035a1 <cprintf>
	va_end(ap);
}
f010025b:	83 c4 10             	add    $0x10,%esp
f010025e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100261:	c9                   	leave  
f0100262:	c3                   	ret    

f0100263 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100263:	55                   	push   %ebp
f0100264:	89 e5                	mov    %esp,%ebp

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100266:	ba fd 03 00 00       	mov    $0x3fd,%edx
f010026b:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010026c:	a8 01                	test   $0x1,%al
f010026e:	74 0b                	je     f010027b <serial_proc_data+0x18>
f0100270:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100275:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100276:	0f b6 c0             	movzbl %al,%eax
f0100279:	eb 05                	jmp    f0100280 <serial_proc_data+0x1d>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f010027b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f0100280:	5d                   	pop    %ebp
f0100281:	c3                   	ret    

f0100282 <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f0100282:	55                   	push   %ebp
f0100283:	89 e5                	mov    %esp,%ebp
f0100285:	53                   	push   %ebx
f0100286:	83 ec 04             	sub    $0x4,%esp
f0100289:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f010028b:	eb 2b                	jmp    f01002b8 <cons_intr+0x36>
		if (c == 0)
f010028d:	85 c0                	test   %eax,%eax
f010028f:	74 27                	je     f01002b8 <cons_intr+0x36>
			continue;
		cons.buf[cons.wpos++] = c;
f0100291:	8b 0d 24 e2 22 f0    	mov    0xf022e224,%ecx
f0100297:	8d 51 01             	lea    0x1(%ecx),%edx
f010029a:	89 15 24 e2 22 f0    	mov    %edx,0xf022e224
f01002a0:	88 81 20 e0 22 f0    	mov    %al,-0xfdd1fe0(%ecx)
		if (cons.wpos == CONSBUFSIZE)
f01002a6:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f01002ac:	75 0a                	jne    f01002b8 <cons_intr+0x36>
			cons.wpos = 0;
f01002ae:	c7 05 24 e2 22 f0 00 	movl   $0x0,0xf022e224
f01002b5:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01002b8:	ff d3                	call   *%ebx
f01002ba:	83 f8 ff             	cmp    $0xffffffff,%eax
f01002bd:	75 ce                	jne    f010028d <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01002bf:	83 c4 04             	add    $0x4,%esp
f01002c2:	5b                   	pop    %ebx
f01002c3:	5d                   	pop    %ebp
f01002c4:	c3                   	ret    

f01002c5 <kbd_proc_data>:
f01002c5:	ba 64 00 00 00       	mov    $0x64,%edx
f01002ca:	ec                   	in     (%dx),%al
	int c;
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
f01002cb:	a8 01                	test   $0x1,%al
f01002cd:	0f 84 f8 00 00 00    	je     f01003cb <kbd_proc_data+0x106>
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
f01002d3:	a8 20                	test   $0x20,%al
f01002d5:	0f 85 f6 00 00 00    	jne    f01003d1 <kbd_proc_data+0x10c>
f01002db:	ba 60 00 00 00       	mov    $0x60,%edx
f01002e0:	ec                   	in     (%dx),%al
f01002e1:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01002e3:	3c e0                	cmp    $0xe0,%al
f01002e5:	75 0d                	jne    f01002f4 <kbd_proc_data+0x2f>
		// E0 escape character
		shift |= E0ESC;
f01002e7:	83 0d 00 e0 22 f0 40 	orl    $0x40,0xf022e000
		return 0;
f01002ee:	b8 00 00 00 00       	mov    $0x0,%eax
f01002f3:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01002f4:	55                   	push   %ebp
f01002f5:	89 e5                	mov    %esp,%ebp
f01002f7:	53                   	push   %ebx
f01002f8:	83 ec 04             	sub    $0x4,%esp

	if (data == 0xE0) {
		// E0 escape character
		shift |= E0ESC;
		return 0;
	} else if (data & 0x80) {
f01002fb:	84 c0                	test   %al,%al
f01002fd:	79 36                	jns    f0100335 <kbd_proc_data+0x70>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f01002ff:	8b 0d 00 e0 22 f0    	mov    0xf022e000,%ecx
f0100305:	89 cb                	mov    %ecx,%ebx
f0100307:	83 e3 40             	and    $0x40,%ebx
f010030a:	83 e0 7f             	and    $0x7f,%eax
f010030d:	85 db                	test   %ebx,%ebx
f010030f:	0f 44 d0             	cmove  %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100312:	0f b6 d2             	movzbl %dl,%edx
f0100315:	0f b6 82 40 60 10 f0 	movzbl -0xfef9fc0(%edx),%eax
f010031c:	83 c8 40             	or     $0x40,%eax
f010031f:	0f b6 c0             	movzbl %al,%eax
f0100322:	f7 d0                	not    %eax
f0100324:	21 c8                	and    %ecx,%eax
f0100326:	a3 00 e0 22 f0       	mov    %eax,0xf022e000
		return 0;
f010032b:	b8 00 00 00 00       	mov    $0x0,%eax
f0100330:	e9 a4 00 00 00       	jmp    f01003d9 <kbd_proc_data+0x114>
	} else if (shift & E0ESC) {
f0100335:	8b 0d 00 e0 22 f0    	mov    0xf022e000,%ecx
f010033b:	f6 c1 40             	test   $0x40,%cl
f010033e:	74 0e                	je     f010034e <kbd_proc_data+0x89>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100340:	83 c8 80             	or     $0xffffff80,%eax
f0100343:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f0100345:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100348:	89 0d 00 e0 22 f0    	mov    %ecx,0xf022e000
	}

	shift |= shiftcode[data];
f010034e:	0f b6 d2             	movzbl %dl,%edx
	shift ^= togglecode[data];
f0100351:	0f b6 82 40 60 10 f0 	movzbl -0xfef9fc0(%edx),%eax
f0100358:	0b 05 00 e0 22 f0    	or     0xf022e000,%eax
f010035e:	0f b6 8a 40 5f 10 f0 	movzbl -0xfefa0c0(%edx),%ecx
f0100365:	31 c8                	xor    %ecx,%eax
f0100367:	a3 00 e0 22 f0       	mov    %eax,0xf022e000

	c = charcode[shift & (CTL | SHIFT)][data];
f010036c:	89 c1                	mov    %eax,%ecx
f010036e:	83 e1 03             	and    $0x3,%ecx
f0100371:	8b 0c 8d 20 5f 10 f0 	mov    -0xfefa0e0(,%ecx,4),%ecx
f0100378:	0f b6 14 11          	movzbl (%ecx,%edx,1),%edx
f010037c:	0f b6 da             	movzbl %dl,%ebx
	if (shift & CAPSLOCK) {
f010037f:	a8 08                	test   $0x8,%al
f0100381:	74 1b                	je     f010039e <kbd_proc_data+0xd9>
		if ('a' <= c && c <= 'z')
f0100383:	89 da                	mov    %ebx,%edx
f0100385:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100388:	83 f9 19             	cmp    $0x19,%ecx
f010038b:	77 05                	ja     f0100392 <kbd_proc_data+0xcd>
			c += 'A' - 'a';
f010038d:	83 eb 20             	sub    $0x20,%ebx
f0100390:	eb 0c                	jmp    f010039e <kbd_proc_data+0xd9>
		else if ('A' <= c && c <= 'Z')
f0100392:	83 ea 41             	sub    $0x41,%edx
			c += 'a' - 'A';
f0100395:	8d 4b 20             	lea    0x20(%ebx),%ecx
f0100398:	83 fa 19             	cmp    $0x19,%edx
f010039b:	0f 46 d9             	cmovbe %ecx,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f010039e:	f7 d0                	not    %eax
f01003a0:	a8 06                	test   $0x6,%al
f01003a2:	75 33                	jne    f01003d7 <kbd_proc_data+0x112>
f01003a4:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01003aa:	75 2b                	jne    f01003d7 <kbd_proc_data+0x112>
		cprintf("Rebooting!\n");
f01003ac:	83 ec 0c             	sub    $0xc,%esp
f01003af:	68 e3 5e 10 f0       	push   $0xf0105ee3
f01003b4:	e8 e8 31 00 00       	call   f01035a1 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01003b9:	ba 92 00 00 00       	mov    $0x92,%edx
f01003be:	b8 03 00 00 00       	mov    $0x3,%eax
f01003c3:	ee                   	out    %al,(%dx)
f01003c4:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003c7:	89 d8                	mov    %ebx,%eax
f01003c9:	eb 0e                	jmp    f01003d9 <kbd_proc_data+0x114>
	uint8_t stat, data;
	static uint32_t shift;

	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
f01003cb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01003d0:	c3                   	ret    
	stat = inb(KBSTATP);
	if ((stat & KBS_DIB) == 0)
		return -1;
	// Ignore data from mouse.
	if (stat & KBS_TERR)
		return -1;
f01003d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01003d6:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01003d7:	89 d8                	mov    %ebx,%eax
}
f01003d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01003dc:	c9                   	leave  
f01003dd:	c3                   	ret    

f01003de <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003de:	55                   	push   %ebp
f01003df:	89 e5                	mov    %esp,%ebp
f01003e1:	57                   	push   %edi
f01003e2:	56                   	push   %esi
f01003e3:	53                   	push   %ebx
f01003e4:	83 ec 1c             	sub    $0x1c,%esp
f01003e7:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003e9:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01003ee:	be fd 03 00 00       	mov    $0x3fd,%esi
f01003f3:	b9 84 00 00 00       	mov    $0x84,%ecx
f01003f8:	eb 09                	jmp    f0100403 <cons_putc+0x25>
f01003fa:	89 ca                	mov    %ecx,%edx
f01003fc:	ec                   	in     (%dx),%al
f01003fd:	ec                   	in     (%dx),%al
f01003fe:	ec                   	in     (%dx),%al
f01003ff:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100400:	83 c3 01             	add    $0x1,%ebx
f0100403:	89 f2                	mov    %esi,%edx
f0100405:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f0100406:	a8 20                	test   $0x20,%al
f0100408:	75 08                	jne    f0100412 <cons_putc+0x34>
f010040a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100410:	7e e8                	jle    f01003fa <cons_putc+0x1c>
f0100412:	89 f8                	mov    %edi,%eax
f0100414:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100417:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010041c:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f010041d:	bb 00 00 00 00       	mov    $0x0,%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100422:	be 79 03 00 00       	mov    $0x379,%esi
f0100427:	b9 84 00 00 00       	mov    $0x84,%ecx
f010042c:	eb 09                	jmp    f0100437 <cons_putc+0x59>
f010042e:	89 ca                	mov    %ecx,%edx
f0100430:	ec                   	in     (%dx),%al
f0100431:	ec                   	in     (%dx),%al
f0100432:	ec                   	in     (%dx),%al
f0100433:	ec                   	in     (%dx),%al
f0100434:	83 c3 01             	add    $0x1,%ebx
f0100437:	89 f2                	mov    %esi,%edx
f0100439:	ec                   	in     (%dx),%al
f010043a:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100440:	7f 04                	jg     f0100446 <cons_putc+0x68>
f0100442:	84 c0                	test   %al,%al
f0100444:	79 e8                	jns    f010042e <cons_putc+0x50>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100446:	ba 78 03 00 00       	mov    $0x378,%edx
f010044b:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010044f:	ee                   	out    %al,(%dx)
f0100450:	ba 7a 03 00 00       	mov    $0x37a,%edx
f0100455:	b8 0d 00 00 00       	mov    $0xd,%eax
f010045a:	ee                   	out    %al,(%dx)
f010045b:	b8 08 00 00 00       	mov    $0x8,%eax
f0100460:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100461:	89 fa                	mov    %edi,%edx
f0100463:	81 e2 00 ff ff ff    	and    $0xffffff00,%edx
		c |= 0x0700;
f0100469:	89 f8                	mov    %edi,%eax
f010046b:	80 cc 07             	or     $0x7,%ah
f010046e:	85 d2                	test   %edx,%edx
f0100470:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f0100473:	89 f8                	mov    %edi,%eax
f0100475:	0f b6 c0             	movzbl %al,%eax
f0100478:	83 f8 09             	cmp    $0x9,%eax
f010047b:	74 74                	je     f01004f1 <cons_putc+0x113>
f010047d:	83 f8 09             	cmp    $0x9,%eax
f0100480:	7f 0a                	jg     f010048c <cons_putc+0xae>
f0100482:	83 f8 08             	cmp    $0x8,%eax
f0100485:	74 14                	je     f010049b <cons_putc+0xbd>
f0100487:	e9 99 00 00 00       	jmp    f0100525 <cons_putc+0x147>
f010048c:	83 f8 0a             	cmp    $0xa,%eax
f010048f:	74 3a                	je     f01004cb <cons_putc+0xed>
f0100491:	83 f8 0d             	cmp    $0xd,%eax
f0100494:	74 3d                	je     f01004d3 <cons_putc+0xf5>
f0100496:	e9 8a 00 00 00       	jmp    f0100525 <cons_putc+0x147>
	case '\b':
		if (crt_pos > 0) {
f010049b:	0f b7 05 28 e2 22 f0 	movzwl 0xf022e228,%eax
f01004a2:	66 85 c0             	test   %ax,%ax
f01004a5:	0f 84 e6 00 00 00    	je     f0100591 <cons_putc+0x1b3>
			crt_pos--;
f01004ab:	83 e8 01             	sub    $0x1,%eax
f01004ae:	66 a3 28 e2 22 f0    	mov    %ax,0xf022e228
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b4:	0f b7 c0             	movzwl %ax,%eax
f01004b7:	66 81 e7 00 ff       	and    $0xff00,%di
f01004bc:	83 cf 20             	or     $0x20,%edi
f01004bf:	8b 15 2c e2 22 f0    	mov    0xf022e22c,%edx
f01004c5:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c9:	eb 78                	jmp    f0100543 <cons_putc+0x165>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004cb:	66 83 05 28 e2 22 f0 	addw   $0x50,0xf022e228
f01004d2:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d3:	0f b7 05 28 e2 22 f0 	movzwl 0xf022e228,%eax
f01004da:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004e0:	c1 e8 16             	shr    $0x16,%eax
f01004e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e6:	c1 e0 04             	shl    $0x4,%eax
f01004e9:	66 a3 28 e2 22 f0    	mov    %ax,0xf022e228
f01004ef:	eb 52                	jmp    f0100543 <cons_putc+0x165>
		break;
	case '\t':
		cons_putc(' ');
f01004f1:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f6:	e8 e3 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f01004fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0100500:	e8 d9 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100505:	b8 20 00 00 00       	mov    $0x20,%eax
f010050a:	e8 cf fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f010050f:	b8 20 00 00 00       	mov    $0x20,%eax
f0100514:	e8 c5 fe ff ff       	call   f01003de <cons_putc>
		cons_putc(' ');
f0100519:	b8 20 00 00 00       	mov    $0x20,%eax
f010051e:	e8 bb fe ff ff       	call   f01003de <cons_putc>
f0100523:	eb 1e                	jmp    f0100543 <cons_putc+0x165>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100525:	0f b7 05 28 e2 22 f0 	movzwl 0xf022e228,%eax
f010052c:	8d 50 01             	lea    0x1(%eax),%edx
f010052f:	66 89 15 28 e2 22 f0 	mov    %dx,0xf022e228
f0100536:	0f b7 c0             	movzwl %ax,%eax
f0100539:	8b 15 2c e2 22 f0    	mov    0xf022e22c,%edx
f010053f:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100543:	66 81 3d 28 e2 22 f0 	cmpw   $0x7cf,0xf022e228
f010054a:	cf 07 
f010054c:	76 43                	jbe    f0100591 <cons_putc+0x1b3>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010054e:	a1 2c e2 22 f0       	mov    0xf022e22c,%eax
f0100553:	83 ec 04             	sub    $0x4,%esp
f0100556:	68 00 0f 00 00       	push   $0xf00
f010055b:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100561:	52                   	push   %edx
f0100562:	50                   	push   %eax
f0100563:	e8 57 4c 00 00       	call   f01051bf <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100568:	8b 15 2c e2 22 f0    	mov    0xf022e22c,%edx
f010056e:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100574:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010057a:	83 c4 10             	add    $0x10,%esp
f010057d:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100582:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100585:	39 d0                	cmp    %edx,%eax
f0100587:	75 f4                	jne    f010057d <cons_putc+0x19f>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f0100589:	66 83 2d 28 e2 22 f0 	subw   $0x50,0xf022e228
f0100590:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100591:	8b 0d 30 e2 22 f0    	mov    0xf022e230,%ecx
f0100597:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059c:	89 ca                	mov    %ecx,%edx
f010059e:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f010059f:	0f b7 1d 28 e2 22 f0 	movzwl 0xf022e228,%ebx
f01005a6:	8d 71 01             	lea    0x1(%ecx),%esi
f01005a9:	89 d8                	mov    %ebx,%eax
f01005ab:	66 c1 e8 08          	shr    $0x8,%ax
f01005af:	89 f2                	mov    %esi,%edx
f01005b1:	ee                   	out    %al,(%dx)
f01005b2:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005b7:	89 ca                	mov    %ecx,%edx
f01005b9:	ee                   	out    %al,(%dx)
f01005ba:	89 d8                	mov    %ebx,%eax
f01005bc:	89 f2                	mov    %esi,%edx
f01005be:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01005c2:	5b                   	pop    %ebx
f01005c3:	5e                   	pop    %esi
f01005c4:	5f                   	pop    %edi
f01005c5:	5d                   	pop    %ebp
f01005c6:	c3                   	ret    

f01005c7 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01005c7:	80 3d 34 e2 22 f0 00 	cmpb   $0x0,0xf022e234
f01005ce:	74 11                	je     f01005e1 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01005d0:	55                   	push   %ebp
f01005d1:	89 e5                	mov    %esp,%ebp
f01005d3:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01005d6:	b8 63 02 10 f0       	mov    $0xf0100263,%eax
f01005db:	e8 a2 fc ff ff       	call   f0100282 <cons_intr>
}
f01005e0:	c9                   	leave  
f01005e1:	f3 c3                	repz ret 

f01005e3 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01005e3:	55                   	push   %ebp
f01005e4:	89 e5                	mov    %esp,%ebp
f01005e6:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01005e9:	b8 c5 02 10 f0       	mov    $0xf01002c5,%eax
f01005ee:	e8 8f fc ff ff       	call   f0100282 <cons_intr>
}
f01005f3:	c9                   	leave  
f01005f4:	c3                   	ret    

f01005f5 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01005f5:	55                   	push   %ebp
f01005f6:	89 e5                	mov    %esp,%ebp
f01005f8:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01005fb:	e8 c7 ff ff ff       	call   f01005c7 <serial_intr>
	kbd_intr();
f0100600:	e8 de ff ff ff       	call   f01005e3 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100605:	a1 20 e2 22 f0       	mov    0xf022e220,%eax
f010060a:	3b 05 24 e2 22 f0    	cmp    0xf022e224,%eax
f0100610:	74 26                	je     f0100638 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100612:	8d 50 01             	lea    0x1(%eax),%edx
f0100615:	89 15 20 e2 22 f0    	mov    %edx,0xf022e220
f010061b:	0f b6 88 20 e0 22 f0 	movzbl -0xfdd1fe0(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100622:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100624:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010062a:	75 11                	jne    f010063d <cons_getc+0x48>
			cons.rpos = 0;
f010062c:	c7 05 20 e2 22 f0 00 	movl   $0x0,0xf022e220
f0100633:	00 00 00 
f0100636:	eb 05                	jmp    f010063d <cons_getc+0x48>
		return c;
	}
	return 0;
f0100638:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010063d:	c9                   	leave  
f010063e:	c3                   	ret    

f010063f <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f010063f:	55                   	push   %ebp
f0100640:	89 e5                	mov    %esp,%ebp
f0100642:	57                   	push   %edi
f0100643:	56                   	push   %esi
f0100644:	53                   	push   %ebx
f0100645:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f0100648:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f010064f:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100656:	5a a5 
	if (*cp != 0xA55A) {
f0100658:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f010065f:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100663:	74 11                	je     f0100676 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f0100665:	c7 05 30 e2 22 f0 b4 	movl   $0x3b4,0xf022e230
f010066c:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
f010066f:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100674:	eb 16                	jmp    f010068c <cons_init+0x4d>
		addr_6845 = MONO_BASE;
	} else {
		*cp = was;
f0100676:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010067d:	c7 05 30 e2 22 f0 d4 	movl   $0x3d4,0xf022e230
f0100684:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
f0100687:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010068c:	8b 3d 30 e2 22 f0    	mov    0xf022e230,%edi
f0100692:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100697:	89 fa                	mov    %edi,%edx
f0100699:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010069a:	8d 5f 01             	lea    0x1(%edi),%ebx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010069d:	89 da                	mov    %ebx,%edx
f010069f:	ec                   	in     (%dx),%al
f01006a0:	0f b6 c8             	movzbl %al,%ecx
f01006a3:	c1 e1 08             	shl    $0x8,%ecx
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006a6:	b8 0f 00 00 00       	mov    $0xf,%eax
f01006ab:	89 fa                	mov    %edi,%edx
f01006ad:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01006ae:	89 da                	mov    %ebx,%edx
f01006b0:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01006b1:	89 35 2c e2 22 f0    	mov    %esi,0xf022e22c
	crt_pos = pos;
f01006b7:	0f b6 c0             	movzbl %al,%eax
f01006ba:	09 c8                	or     %ecx,%eax
f01006bc:	66 a3 28 e2 22 f0    	mov    %ax,0xf022e228

static void
kbd_init(void)
{
	// Drain the kbd buffer so that QEMU generates interrupts.
	kbd_intr();
f01006c2:	e8 1c ff ff ff       	call   f01005e3 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_KBD));
f01006c7:	83 ec 0c             	sub    $0xc,%esp
f01006ca:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f01006d1:	25 fd ff 00 00       	and    $0xfffd,%eax
f01006d6:	50                   	push   %eax
f01006d7:	e8 74 2d 00 00       	call   f0103450 <irq_setmask_8259A>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006dc:	be fa 03 00 00       	mov    $0x3fa,%esi
f01006e1:	b8 00 00 00 00       	mov    $0x0,%eax
f01006e6:	89 f2                	mov    %esi,%edx
f01006e8:	ee                   	out    %al,(%dx)
f01006e9:	ba fb 03 00 00       	mov    $0x3fb,%edx
f01006ee:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01006f3:	ee                   	out    %al,(%dx)
f01006f4:	bb f8 03 00 00       	mov    $0x3f8,%ebx
f01006f9:	b8 0c 00 00 00       	mov    $0xc,%eax
f01006fe:	89 da                	mov    %ebx,%edx
f0100700:	ee                   	out    %al,(%dx)
f0100701:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100706:	b8 00 00 00 00       	mov    $0x0,%eax
f010070b:	ee                   	out    %al,(%dx)
f010070c:	ba fb 03 00 00       	mov    $0x3fb,%edx
f0100711:	b8 03 00 00 00       	mov    $0x3,%eax
f0100716:	ee                   	out    %al,(%dx)
f0100717:	ba fc 03 00 00       	mov    $0x3fc,%edx
f010071c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100721:	ee                   	out    %al,(%dx)
f0100722:	ba f9 03 00 00       	mov    $0x3f9,%edx
f0100727:	b8 01 00 00 00       	mov    $0x1,%eax
f010072c:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010072d:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100732:	ec                   	in     (%dx),%al
f0100733:	89 c1                	mov    %eax,%ecx
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100735:	83 c4 10             	add    $0x10,%esp
f0100738:	3c ff                	cmp    $0xff,%al
f010073a:	0f 95 05 34 e2 22 f0 	setne  0xf022e234
f0100741:	89 f2                	mov    %esi,%edx
f0100743:	ec                   	in     (%dx),%al
f0100744:	89 da                	mov    %ebx,%edx
f0100746:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100747:	80 f9 ff             	cmp    $0xff,%cl
f010074a:	75 10                	jne    f010075c <cons_init+0x11d>
		cprintf("Serial port does not exist!\n");
f010074c:	83 ec 0c             	sub    $0xc,%esp
f010074f:	68 ef 5e 10 f0       	push   $0xf0105eef
f0100754:	e8 48 2e 00 00       	call   f01035a1 <cprintf>
f0100759:	83 c4 10             	add    $0x10,%esp
}
f010075c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010075f:	5b                   	pop    %ebx
f0100760:	5e                   	pop    %esi
f0100761:	5f                   	pop    %edi
f0100762:	5d                   	pop    %ebp
f0100763:	c3                   	ret    

f0100764 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100764:	55                   	push   %ebp
f0100765:	89 e5                	mov    %esp,%ebp
f0100767:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010076a:	8b 45 08             	mov    0x8(%ebp),%eax
f010076d:	e8 6c fc ff ff       	call   f01003de <cons_putc>
}
f0100772:	c9                   	leave  
f0100773:	c3                   	ret    

f0100774 <getchar>:

int
getchar(void)
{
f0100774:	55                   	push   %ebp
f0100775:	89 e5                	mov    %esp,%ebp
f0100777:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010077a:	e8 76 fe ff ff       	call   f01005f5 <cons_getc>
f010077f:	85 c0                	test   %eax,%eax
f0100781:	74 f7                	je     f010077a <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100783:	c9                   	leave  
f0100784:	c3                   	ret    

f0100785 <iscons>:

int
iscons(int fdnum)
{
f0100785:	55                   	push   %ebp
f0100786:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f0100788:	b8 01 00 00 00       	mov    $0x1,%eax
f010078d:	5d                   	pop    %ebp
f010078e:	c3                   	ret    

f010078f <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f010078f:	55                   	push   %ebp
f0100790:	89 e5                	mov    %esp,%ebp
f0100792:	83 ec 0c             	sub    $0xc,%esp
	int i;

	for (i = 0; i < ARRAY_SIZE(commands); i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f0100795:	68 40 61 10 f0       	push   $0xf0106140
f010079a:	68 5e 61 10 f0       	push   $0xf010615e
f010079f:	68 63 61 10 f0       	push   $0xf0106163
f01007a4:	e8 f8 2d 00 00       	call   f01035a1 <cprintf>
f01007a9:	83 c4 0c             	add    $0xc,%esp
f01007ac:	68 cc 61 10 f0       	push   $0xf01061cc
f01007b1:	68 6c 61 10 f0       	push   $0xf010616c
f01007b6:	68 63 61 10 f0       	push   $0xf0106163
f01007bb:	e8 e1 2d 00 00       	call   f01035a1 <cprintf>
	return 0;
}
f01007c0:	b8 00 00 00 00       	mov    $0x0,%eax
f01007c5:	c9                   	leave  
f01007c6:	c3                   	ret    

f01007c7 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007c7:	55                   	push   %ebp
f01007c8:	89 e5                	mov    %esp,%ebp
f01007ca:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007cd:	68 75 61 10 f0       	push   $0xf0106175
f01007d2:	e8 ca 2d 00 00       	call   f01035a1 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f01007d7:	83 c4 08             	add    $0x8,%esp
f01007da:	68 0c 00 10 00       	push   $0x10000c
f01007df:	68 f4 61 10 f0       	push   $0xf01061f4
f01007e4:	e8 b8 2d 00 00       	call   f01035a1 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01007e9:	83 c4 0c             	add    $0xc,%esp
f01007ec:	68 0c 00 10 00       	push   $0x10000c
f01007f1:	68 0c 00 10 f0       	push   $0xf010000c
f01007f6:	68 1c 62 10 f0       	push   $0xf010621c
f01007fb:	e8 a1 2d 00 00       	call   f01035a1 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100800:	83 c4 0c             	add    $0xc,%esp
f0100803:	68 11 5e 10 00       	push   $0x105e11
f0100808:	68 11 5e 10 f0       	push   $0xf0105e11
f010080d:	68 40 62 10 f0       	push   $0xf0106240
f0100812:	e8 8a 2d 00 00       	call   f01035a1 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100817:	83 c4 0c             	add    $0xc,%esp
f010081a:	68 28 d6 22 00       	push   $0x22d628
f010081f:	68 28 d6 22 f0       	push   $0xf022d628
f0100824:	68 64 62 10 f0       	push   $0xf0106264
f0100829:	e8 73 2d 00 00       	call   f01035a1 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010082e:	83 c4 0c             	add    $0xc,%esp
f0100831:	68 08 00 27 00       	push   $0x270008
f0100836:	68 08 00 27 f0       	push   $0xf0270008
f010083b:	68 88 62 10 f0       	push   $0xf0106288
f0100840:	e8 5c 2d 00 00       	call   f01035a1 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100845:	b8 07 04 27 f0       	mov    $0xf0270407,%eax
f010084a:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f010084f:	83 c4 08             	add    $0x8,%esp
f0100852:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100857:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010085d:	85 c0                	test   %eax,%eax
f010085f:	0f 48 c2             	cmovs  %edx,%eax
f0100862:	c1 f8 0a             	sar    $0xa,%eax
f0100865:	50                   	push   %eax
f0100866:	68 ac 62 10 f0       	push   $0xf01062ac
f010086b:	e8 31 2d 00 00       	call   f01035a1 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100870:	b8 00 00 00 00       	mov    $0x0,%eax
f0100875:	c9                   	leave  
f0100876:	c3                   	ret    

f0100877 <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100877:	55                   	push   %ebp
f0100878:	89 e5                	mov    %esp,%ebp
	// Your code here.
	return 0;
}
f010087a:	b8 00 00 00 00       	mov    $0x0,%eax
f010087f:	5d                   	pop    %ebp
f0100880:	c3                   	ret    

f0100881 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100881:	55                   	push   %ebp
f0100882:	89 e5                	mov    %esp,%ebp
f0100884:	57                   	push   %edi
f0100885:	56                   	push   %esi
f0100886:	53                   	push   %ebx
f0100887:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010088a:	68 d8 62 10 f0       	push   $0xf01062d8
f010088f:	e8 0d 2d 00 00       	call   f01035a1 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100894:	c7 04 24 fc 62 10 f0 	movl   $0xf01062fc,(%esp)
f010089b:	e8 01 2d 00 00       	call   f01035a1 <cprintf>

	if (tf != NULL)
f01008a0:	83 c4 10             	add    $0x10,%esp
f01008a3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f01008a7:	74 0e                	je     f01008b7 <monitor+0x36>
		print_trapframe(tf);
f01008a9:	83 ec 0c             	sub    $0xc,%esp
f01008ac:	ff 75 08             	pushl  0x8(%ebp)
f01008af:	e8 af 31 00 00       	call   f0103a63 <print_trapframe>
f01008b4:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f01008b7:	83 ec 0c             	sub    $0xc,%esp
f01008ba:	68 8e 61 10 f0       	push   $0xf010618e
f01008bf:	e8 57 46 00 00       	call   f0104f1b <readline>
f01008c4:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f01008c6:	83 c4 10             	add    $0x10,%esp
f01008c9:	85 c0                	test   %eax,%eax
f01008cb:	74 ea                	je     f01008b7 <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01008cd:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f01008d4:	be 00 00 00 00       	mov    $0x0,%esi
f01008d9:	eb 0a                	jmp    f01008e5 <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01008db:	c6 03 00             	movb   $0x0,(%ebx)
f01008de:	89 f7                	mov    %esi,%edi
f01008e0:	8d 5b 01             	lea    0x1(%ebx),%ebx
f01008e3:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01008e5:	0f b6 03             	movzbl (%ebx),%eax
f01008e8:	84 c0                	test   %al,%al
f01008ea:	74 63                	je     f010094f <monitor+0xce>
f01008ec:	83 ec 08             	sub    $0x8,%esp
f01008ef:	0f be c0             	movsbl %al,%eax
f01008f2:	50                   	push   %eax
f01008f3:	68 92 61 10 f0       	push   $0xf0106192
f01008f8:	e8 38 48 00 00       	call   f0105135 <strchr>
f01008fd:	83 c4 10             	add    $0x10,%esp
f0100900:	85 c0                	test   %eax,%eax
f0100902:	75 d7                	jne    f01008db <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f0100904:	80 3b 00             	cmpb   $0x0,(%ebx)
f0100907:	74 46                	je     f010094f <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100909:	83 fe 0f             	cmp    $0xf,%esi
f010090c:	75 14                	jne    f0100922 <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f010090e:	83 ec 08             	sub    $0x8,%esp
f0100911:	6a 10                	push   $0x10
f0100913:	68 97 61 10 f0       	push   $0xf0106197
f0100918:	e8 84 2c 00 00       	call   f01035a1 <cprintf>
f010091d:	83 c4 10             	add    $0x10,%esp
f0100920:	eb 95                	jmp    f01008b7 <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f0100922:	8d 7e 01             	lea    0x1(%esi),%edi
f0100925:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f0100929:	eb 03                	jmp    f010092e <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f010092b:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f010092e:	0f b6 03             	movzbl (%ebx),%eax
f0100931:	84 c0                	test   %al,%al
f0100933:	74 ae                	je     f01008e3 <monitor+0x62>
f0100935:	83 ec 08             	sub    $0x8,%esp
f0100938:	0f be c0             	movsbl %al,%eax
f010093b:	50                   	push   %eax
f010093c:	68 92 61 10 f0       	push   $0xf0106192
f0100941:	e8 ef 47 00 00       	call   f0105135 <strchr>
f0100946:	83 c4 10             	add    $0x10,%esp
f0100949:	85 c0                	test   %eax,%eax
f010094b:	74 de                	je     f010092b <monitor+0xaa>
f010094d:	eb 94                	jmp    f01008e3 <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f010094f:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f0100956:	00 

	// Lookup and invoke the command
	if (argc == 0)
f0100957:	85 f6                	test   %esi,%esi
f0100959:	0f 84 58 ff ff ff    	je     f01008b7 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f010095f:	83 ec 08             	sub    $0x8,%esp
f0100962:	68 5e 61 10 f0       	push   $0xf010615e
f0100967:	ff 75 a8             	pushl  -0x58(%ebp)
f010096a:	e8 68 47 00 00       	call   f01050d7 <strcmp>
f010096f:	83 c4 10             	add    $0x10,%esp
f0100972:	85 c0                	test   %eax,%eax
f0100974:	74 1e                	je     f0100994 <monitor+0x113>
f0100976:	83 ec 08             	sub    $0x8,%esp
f0100979:	68 6c 61 10 f0       	push   $0xf010616c
f010097e:	ff 75 a8             	pushl  -0x58(%ebp)
f0100981:	e8 51 47 00 00       	call   f01050d7 <strcmp>
f0100986:	83 c4 10             	add    $0x10,%esp
f0100989:	85 c0                	test   %eax,%eax
f010098b:	75 2f                	jne    f01009bc <monitor+0x13b>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
f010098d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100992:	eb 05                	jmp    f0100999 <monitor+0x118>
		if (strcmp(argv[0], commands[i].name) == 0)
f0100994:	b8 00 00 00 00       	mov    $0x0,%eax
			return commands[i].func(argc, argv, tf);
f0100999:	83 ec 04             	sub    $0x4,%esp
f010099c:	8d 14 00             	lea    (%eax,%eax,1),%edx
f010099f:	01 d0                	add    %edx,%eax
f01009a1:	ff 75 08             	pushl  0x8(%ebp)
f01009a4:	8d 4d a8             	lea    -0x58(%ebp),%ecx
f01009a7:	51                   	push   %ecx
f01009a8:	56                   	push   %esi
f01009a9:	ff 14 85 2c 63 10 f0 	call   *-0xfef9cd4(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01009b0:	83 c4 10             	add    $0x10,%esp
f01009b3:	85 c0                	test   %eax,%eax
f01009b5:	78 1d                	js     f01009d4 <monitor+0x153>
f01009b7:	e9 fb fe ff ff       	jmp    f01008b7 <monitor+0x36>
		return 0;
	for (i = 0; i < ARRAY_SIZE(commands); i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01009bc:	83 ec 08             	sub    $0x8,%esp
f01009bf:	ff 75 a8             	pushl  -0x58(%ebp)
f01009c2:	68 b4 61 10 f0       	push   $0xf01061b4
f01009c7:	e8 d5 2b 00 00       	call   f01035a1 <cprintf>
f01009cc:	83 c4 10             	add    $0x10,%esp
f01009cf:	e9 e3 fe ff ff       	jmp    f01008b7 <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f01009d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01009d7:	5b                   	pop    %ebx
f01009d8:	5e                   	pop    %esi
f01009d9:	5f                   	pop    %edi
f01009da:	5d                   	pop    %ebp
f01009db:	c3                   	ret    

f01009dc <boot_alloc>:
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
//暂时用作页分配器，真实的物理页分配器是page_alloc函数
static void *
boot_alloc(uint32_t n)
{
f01009dc:	55                   	push   %ebp
f01009dd:	89 e5                	mov    %esp,%ebp
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	//nextfree为静态变量，初始时指向开始指向内核bss段的末尾
	/*根据mem_init()函数可知，kern_pgdir初始化时第一次调用boot_alloc(),
	  故kern_pgdir指向end*/
	if (!nextfree) {
f01009df:	83 3d 38 e2 22 f0 00 	cmpl   $0x0,0xf022e238
f01009e6:	75 11                	jne    f01009f9 <boot_alloc+0x1d>
		extern char end[];
		//end 在哪里？？？
		nextfree = ROUNDUP((char *) end, PGSIZE);
f01009e8:	ba 07 10 27 f0       	mov    $0xf0271007,%edx
f01009ed:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01009f3:	89 15 38 e2 22 f0    	mov    %edx,0xf022e238
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	//
	result = nextfree;
f01009f9:	8b 0d 38 e2 22 f0    	mov    0xf022e238,%ecx
	//ROUNDUP()用作页对齐
	nextfree = ROUNDUP((char *)nextfree + n, PGSIZE);
f01009ff:	8d 94 01 ff 0f 00 00 	lea    0xfff(%ecx,%eax,1),%edx
f0100a06:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100a0c:	89 15 38 e2 22 f0    	mov    %edx,0xf022e238
	return result;
}
f0100a12:	89 c8                	mov    %ecx,%eax
f0100a14:	5d                   	pop    %ebp
f0100a15:	c3                   	ret    

f0100a16 <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100a16:	55                   	push   %ebp
f0100a17:	89 e5                	mov    %esp,%ebp
f0100a19:	56                   	push   %esi
f0100a1a:	53                   	push   %ebx
f0100a1b:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100a1d:	83 ec 0c             	sub    $0xc,%esp
f0100a20:	50                   	push   %eax
f0100a21:	e8 fc 29 00 00       	call   f0103422 <mc146818_read>
f0100a26:	89 c6                	mov    %eax,%esi
f0100a28:	83 c3 01             	add    $0x1,%ebx
f0100a2b:	89 1c 24             	mov    %ebx,(%esp)
f0100a2e:	e8 ef 29 00 00       	call   f0103422 <mc146818_read>
f0100a33:	c1 e0 08             	shl    $0x8,%eax
f0100a36:	09 f0                	or     %esi,%eax
}
f0100a38:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100a3b:	5b                   	pop    %ebx
f0100a3c:	5e                   	pop    %esi
f0100a3d:	5d                   	pop    %ebp
f0100a3e:	c3                   	ret    

f0100a3f <check_va2pa>:
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100a3f:	89 d1                	mov    %edx,%ecx
f0100a41:	c1 e9 16             	shr    $0x16,%ecx
f0100a44:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100a47:	a8 01                	test   $0x1,%al
f0100a49:	74 52                	je     f0100a9d <check_va2pa+0x5e>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100a4b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a50:	89 c1                	mov    %eax,%ecx
f0100a52:	c1 e9 0c             	shr    $0xc,%ecx
f0100a55:	3b 0d 88 ee 22 f0    	cmp    0xf022ee88,%ecx
f0100a5b:	72 1b                	jb     f0100a78 <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100a5d:	55                   	push   %ebp
f0100a5e:	89 e5                	mov    %esp,%ebp
f0100a60:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a63:	50                   	push   %eax
f0100a64:	68 44 5e 10 f0       	push   $0xf0105e44
f0100a69:	68 ae 03 00 00       	push   $0x3ae
f0100a6e:	68 85 6c 10 f0       	push   $0xf0106c85
f0100a73:	e8 c8 f5 ff ff       	call   f0100040 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100a78:	c1 ea 0c             	shr    $0xc,%edx
f0100a7b:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100a81:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100a88:	89 c2                	mov    %eax,%edx
f0100a8a:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100a8d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a92:	85 d2                	test   %edx,%edx
f0100a94:	ba ff ff ff ff       	mov    $0xffffffff,%edx
f0100a99:	0f 44 c2             	cmove  %edx,%eax
f0100a9c:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100a9d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100aa2:	c3                   	ret    

f0100aa3 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100aa3:	55                   	push   %ebp
f0100aa4:	89 e5                	mov    %esp,%ebp
f0100aa6:	57                   	push   %edi
f0100aa7:	56                   	push   %esi
f0100aa8:	53                   	push   %ebx
f0100aa9:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100aac:	84 c0                	test   %al,%al
f0100aae:	0f 85 a0 02 00 00    	jne    f0100d54 <check_page_free_list+0x2b1>
f0100ab4:	e9 ad 02 00 00       	jmp    f0100d66 <check_page_free_list+0x2c3>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100ab9:	83 ec 04             	sub    $0x4,%esp
f0100abc:	68 3c 63 10 f0       	push   $0xf010633c
f0100ac1:	68 e1 02 00 00       	push   $0x2e1
f0100ac6:	68 85 6c 10 f0       	push   $0xf0106c85
f0100acb:	e8 70 f5 ff ff       	call   f0100040 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100ad0:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100ad3:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100ad6:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100ad9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100adc:	89 c2                	mov    %eax,%edx
f0100ade:	2b 15 90 ee 22 f0    	sub    0xf022ee90,%edx
f0100ae4:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100aea:	0f 95 c2             	setne  %dl
f0100aed:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100af0:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100af4:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100af6:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100afa:	8b 00                	mov    (%eax),%eax
f0100afc:	85 c0                	test   %eax,%eax
f0100afe:	75 dc                	jne    f0100adc <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b00:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b03:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b09:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b0c:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100b0f:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100b11:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100b14:	a3 40 e2 22 f0       	mov    %eax,0xf022e240
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b19:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b1e:	8b 1d 40 e2 22 f0    	mov    0xf022e240,%ebx
f0100b24:	eb 53                	jmp    f0100b79 <check_page_free_list+0xd6>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b26:	89 d8                	mov    %ebx,%eax
f0100b28:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f0100b2e:	c1 f8 03             	sar    $0x3,%eax
f0100b31:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100b34:	89 c2                	mov    %eax,%edx
f0100b36:	c1 ea 16             	shr    $0x16,%edx
f0100b39:	39 f2                	cmp    %esi,%edx
f0100b3b:	73 3a                	jae    f0100b77 <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100b3d:	89 c2                	mov    %eax,%edx
f0100b3f:	c1 ea 0c             	shr    $0xc,%edx
f0100b42:	3b 15 88 ee 22 f0    	cmp    0xf022ee88,%edx
f0100b48:	72 12                	jb     f0100b5c <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100b4a:	50                   	push   %eax
f0100b4b:	68 44 5e 10 f0       	push   $0xf0105e44
f0100b50:	6a 58                	push   $0x58
f0100b52:	68 91 6c 10 f0       	push   $0xf0106c91
f0100b57:	e8 e4 f4 ff ff       	call   f0100040 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100b5c:	83 ec 04             	sub    $0x4,%esp
f0100b5f:	68 80 00 00 00       	push   $0x80
f0100b64:	68 97 00 00 00       	push   $0x97
f0100b69:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100b6e:	50                   	push   %eax
f0100b6f:	e8 fe 45 00 00       	call   f0105172 <memset>
f0100b74:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100b77:	8b 1b                	mov    (%ebx),%ebx
f0100b79:	85 db                	test   %ebx,%ebx
f0100b7b:	75 a9                	jne    f0100b26 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100b7d:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b82:	e8 55 fe ff ff       	call   f01009dc <boot_alloc>
f0100b87:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b8a:	8b 15 40 e2 22 f0    	mov    0xf022e240,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100b90:	8b 0d 90 ee 22 f0    	mov    0xf022ee90,%ecx
		assert(pp < pages + npages);
f0100b96:	a1 88 ee 22 f0       	mov    0xf022ee88,%eax
f0100b9b:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100b9e:	8d 04 c1             	lea    (%ecx,%eax,8),%eax
f0100ba1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100ba4:	89 4d d0             	mov    %ecx,-0x30(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100ba7:	be 00 00 00 00       	mov    $0x0,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100bac:	e9 52 01 00 00       	jmp    f0100d03 <check_page_free_list+0x260>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100bb1:	39 ca                	cmp    %ecx,%edx
f0100bb3:	73 19                	jae    f0100bce <check_page_free_list+0x12b>
f0100bb5:	68 9f 6c 10 f0       	push   $0xf0106c9f
f0100bba:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100bbf:	68 fb 02 00 00       	push   $0x2fb
f0100bc4:	68 85 6c 10 f0       	push   $0xf0106c85
f0100bc9:	e8 72 f4 ff ff       	call   f0100040 <_panic>
		assert(pp < pages + npages);
f0100bce:	3b 55 d4             	cmp    -0x2c(%ebp),%edx
f0100bd1:	72 19                	jb     f0100bec <check_page_free_list+0x149>
f0100bd3:	68 c0 6c 10 f0       	push   $0xf0106cc0
f0100bd8:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100bdd:	68 fc 02 00 00       	push   $0x2fc
f0100be2:	68 85 6c 10 f0       	push   $0xf0106c85
f0100be7:	e8 54 f4 ff ff       	call   f0100040 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100bec:	89 d0                	mov    %edx,%eax
f0100bee:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0100bf1:	a8 07                	test   $0x7,%al
f0100bf3:	74 19                	je     f0100c0e <check_page_free_list+0x16b>
f0100bf5:	68 60 63 10 f0       	push   $0xf0106360
f0100bfa:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100bff:	68 fd 02 00 00       	push   $0x2fd
f0100c04:	68 85 6c 10 f0       	push   $0xf0106c85
f0100c09:	e8 32 f4 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100c0e:	c1 f8 03             	sar    $0x3,%eax
f0100c11:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100c14:	85 c0                	test   %eax,%eax
f0100c16:	75 19                	jne    f0100c31 <check_page_free_list+0x18e>
f0100c18:	68 d4 6c 10 f0       	push   $0xf0106cd4
f0100c1d:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100c22:	68 00 03 00 00       	push   $0x300
f0100c27:	68 85 6c 10 f0       	push   $0xf0106c85
f0100c2c:	e8 0f f4 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100c31:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100c36:	75 19                	jne    f0100c51 <check_page_free_list+0x1ae>
f0100c38:	68 e5 6c 10 f0       	push   $0xf0106ce5
f0100c3d:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100c42:	68 01 03 00 00       	push   $0x301
f0100c47:	68 85 6c 10 f0       	push   $0xf0106c85
f0100c4c:	e8 ef f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100c51:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100c56:	75 19                	jne    f0100c71 <check_page_free_list+0x1ce>
f0100c58:	68 94 63 10 f0       	push   $0xf0106394
f0100c5d:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100c62:	68 02 03 00 00       	push   $0x302
f0100c67:	68 85 6c 10 f0       	push   $0xf0106c85
f0100c6c:	e8 cf f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100c71:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100c76:	75 19                	jne    f0100c91 <check_page_free_list+0x1ee>
f0100c78:	68 fe 6c 10 f0       	push   $0xf0106cfe
f0100c7d:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100c82:	68 03 03 00 00       	push   $0x303
f0100c87:	68 85 6c 10 f0       	push   $0xf0106c85
f0100c8c:	e8 af f3 ff ff       	call   f0100040 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100c91:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100c96:	0f 86 f1 00 00 00    	jbe    f0100d8d <check_page_free_list+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c9c:	89 c7                	mov    %eax,%edi
f0100c9e:	c1 ef 0c             	shr    $0xc,%edi
f0100ca1:	39 7d c8             	cmp    %edi,-0x38(%ebp)
f0100ca4:	77 12                	ja     f0100cb8 <check_page_free_list+0x215>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100ca6:	50                   	push   %eax
f0100ca7:	68 44 5e 10 f0       	push   $0xf0105e44
f0100cac:	6a 58                	push   $0x58
f0100cae:	68 91 6c 10 f0       	push   $0xf0106c91
f0100cb3:	e8 88 f3 ff ff       	call   f0100040 <_panic>
f0100cb8:	8d b8 00 00 00 f0    	lea    -0x10000000(%eax),%edi
f0100cbe:	39 7d cc             	cmp    %edi,-0x34(%ebp)
f0100cc1:	0f 86 b6 00 00 00    	jbe    f0100d7d <check_page_free_list+0x2da>
f0100cc7:	68 b8 63 10 f0       	push   $0xf01063b8
f0100ccc:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100cd1:	68 04 03 00 00       	push   $0x304
f0100cd6:	68 85 6c 10 f0       	push   $0xf0106c85
f0100cdb:	e8 60 f3 ff ff       	call   f0100040 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100ce0:	68 18 6d 10 f0       	push   $0xf0106d18
f0100ce5:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100cea:	68 06 03 00 00       	push   $0x306
f0100cef:	68 85 6c 10 f0       	push   $0xf0106c85
f0100cf4:	e8 47 f3 ff ff       	call   f0100040 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100cf9:	83 c6 01             	add    $0x1,%esi
f0100cfc:	eb 03                	jmp    f0100d01 <check_page_free_list+0x25e>
		else
			++nfree_extmem;
f0100cfe:	83 c3 01             	add    $0x1,%ebx
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d01:	8b 12                	mov    (%edx),%edx
f0100d03:	85 d2                	test   %edx,%edx
f0100d05:	0f 85 a6 fe ff ff    	jne    f0100bb1 <check_page_free_list+0x10e>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d0b:	85 f6                	test   %esi,%esi
f0100d0d:	7f 19                	jg     f0100d28 <check_page_free_list+0x285>
f0100d0f:	68 35 6d 10 f0       	push   $0xf0106d35
f0100d14:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100d19:	68 0e 03 00 00       	push   $0x30e
f0100d1e:	68 85 6c 10 f0       	push   $0xf0106c85
f0100d23:	e8 18 f3 ff ff       	call   f0100040 <_panic>
	assert(nfree_extmem > 0);
f0100d28:	85 db                	test   %ebx,%ebx
f0100d2a:	7f 19                	jg     f0100d45 <check_page_free_list+0x2a2>
f0100d2c:	68 47 6d 10 f0       	push   $0xf0106d47
f0100d31:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100d36:	68 0f 03 00 00       	push   $0x30f
f0100d3b:	68 85 6c 10 f0       	push   $0xf0106c85
f0100d40:	e8 fb f2 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_free_list() succeeded!\n");
f0100d45:	83 ec 0c             	sub    $0xc,%esp
f0100d48:	68 00 64 10 f0       	push   $0xf0106400
f0100d4d:	e8 4f 28 00 00       	call   f01035a1 <cprintf>
}
f0100d52:	eb 49                	jmp    f0100d9d <check_page_free_list+0x2fa>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100d54:	a1 40 e2 22 f0       	mov    0xf022e240,%eax
f0100d59:	85 c0                	test   %eax,%eax
f0100d5b:	0f 85 6f fd ff ff    	jne    f0100ad0 <check_page_free_list+0x2d>
f0100d61:	e9 53 fd ff ff       	jmp    f0100ab9 <check_page_free_list+0x16>
f0100d66:	83 3d 40 e2 22 f0 00 	cmpl   $0x0,0xf022e240
f0100d6d:	0f 84 46 fd ff ff    	je     f0100ab9 <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100d73:	be 00 04 00 00       	mov    $0x400,%esi
f0100d78:	e9 a1 fd ff ff       	jmp    f0100b1e <check_page_free_list+0x7b>
		assert(page2pa(pp) != IOPHYSMEM);
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
		assert(page2pa(pp) != EXTPHYSMEM);
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f0100d7d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d82:	0f 85 76 ff ff ff    	jne    f0100cfe <check_page_free_list+0x25b>
f0100d88:	e9 53 ff ff ff       	jmp    f0100ce0 <check_page_free_list+0x23d>
f0100d8d:	3d 00 70 00 00       	cmp    $0x7000,%eax
f0100d92:	0f 85 61 ff ff ff    	jne    f0100cf9 <check_page_free_list+0x256>
f0100d98:	e9 43 ff ff ff       	jmp    f0100ce0 <check_page_free_list+0x23d>

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);

	cprintf("check_page_free_list() succeeded!\n");
}
f0100d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100da0:	5b                   	pop    %ebx
f0100da1:	5e                   	pop    %esi
f0100da2:	5f                   	pop    %edi
f0100da3:	5d                   	pop    %ebp
f0100da4:	c3                   	ret    

f0100da5 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100da5:	55                   	push   %ebp
f0100da6:	89 e5                	mov    %esp,%ebp
f0100da8:	57                   	push   %edi
f0100da9:	56                   	push   %esi
f0100daa:	53                   	push   %ebx
f0100dab:	83 ec 0c             	sub    $0xc,%esp
	//
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
f0100dae:	b8 00 00 00 00       	mov    $0x0,%eax
f0100db3:	e8 24 fc ff ff       	call   f01009dc <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100db8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100dbd:	77 15                	ja     f0100dd4 <page_init+0x2f>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100dbf:	50                   	push   %eax
f0100dc0:	68 68 5e 10 f0       	push   $0xf0105e68
f0100dc5:	68 59 01 00 00       	push   $0x159
f0100dca:	68 85 6c 10 f0       	push   $0xf0106c85
f0100dcf:	e8 6c f2 ff ff       	call   f0100040 <_panic>
f0100dd4:	05 00 00 00 10       	add    $0x10000000,%eax
f0100dd9:	c1 e8 0c             	shr    $0xc,%eax
	for (i = 1; i < npages; i++) {
		if (i >= npages_basemem && i < pgnum)
f0100ddc:	8b 3d 44 e2 22 f0    	mov    0xf022e244,%edi
f0100de2:	8b 35 40 e2 22 f0    	mov    0xf022e240,%esi
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100de8:	b9 00 00 00 00       	mov    $0x0,%ecx
f0100ded:	ba 01 00 00 00       	mov    $0x1,%edx
f0100df2:	eb 34                	jmp    f0100e28 <page_init+0x83>
		if (i >= npages_basemem && i < pgnum)
f0100df4:	39 c2                	cmp    %eax,%edx
f0100df6:	73 04                	jae    f0100dfc <page_init+0x57>
f0100df8:	39 fa                	cmp    %edi,%edx
f0100dfa:	73 29                	jae    f0100e25 <page_init+0x80>
			continue;
		else if (i == PGNUM(MPENTRY_PADDR)){
f0100dfc:	83 fa 07             	cmp    $0x7,%edx
f0100dff:	74 24                	je     f0100e25 <page_init+0x80>
			continue;
		}
		pages[i].pp_ref = 0;
f0100e01:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
f0100e08:	89 cb                	mov    %ecx,%ebx
f0100e0a:	03 1d 90 ee 22 f0    	add    0xf022ee90,%ebx
f0100e10:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
		pages[i].pp_link = page_free_list;
f0100e16:	89 33                	mov    %esi,(%ebx)
		page_free_list = &pages[i];
f0100e18:	89 ce                	mov    %ecx,%esi
f0100e1a:	03 35 90 ee 22 f0    	add    0xf022ee90,%esi
f0100e20:	b9 01 00 00 00       	mov    $0x1,%ecx
	// Change the code to reflect this.
	// NB: DO NOT actually touch the physical memory corresponding to
	// free pages!
	size_t i;
	size_t pgnum = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100e25:	83 c2 01             	add    $0x1,%edx
f0100e28:	3b 15 88 ee 22 f0    	cmp    0xf022ee88,%edx
f0100e2e:	72 c4                	jb     f0100df4 <page_init+0x4f>
f0100e30:	84 c9                	test   %cl,%cl
f0100e32:	74 06                	je     f0100e3a <page_init+0x95>
f0100e34:	89 35 40 e2 22 f0    	mov    %esi,0xf022e240
		}
		pages[i].pp_ref = 0;
		pages[i].pp_link = page_free_list;
		page_free_list = &pages[i];
	}
}
f0100e3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e3d:	5b                   	pop    %ebx
f0100e3e:	5e                   	pop    %esi
f0100e3f:	5f                   	pop    %edi
f0100e40:	5d                   	pop    %ebp
f0100e41:	c3                   	ret    

f0100e42 <page_alloc>:
//
// Hint: use page2kva and memset
//分配一个物理页面
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e42:	55                   	push   %ebp
f0100e43:	89 e5                	mov    %esp,%ebp
f0100e45:	53                   	push   %ebx
f0100e46:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo *result = NULL;
	//如果存在空闲ye
	if (page_free_list) {
f0100e49:	8b 1d 40 e2 22 f0    	mov    0xf022e240,%ebx
f0100e4f:	85 db                	test   %ebx,%ebx
f0100e51:	74 58                	je     f0100eab <page_alloc+0x69>
		result = page_free_list;
		page_free_list = page_free_list->pp_link;
f0100e53:	8b 03                	mov    (%ebx),%eax
f0100e55:	a3 40 e2 22 f0       	mov    %eax,0xf022e240
		result->pp_link = NULL;
f0100e5a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
		//??????
		if (alloc_flags & ALLOC_ZERO)
f0100e60:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100e64:	74 45                	je     f0100eab <page_alloc+0x69>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e66:	89 d8                	mov    %ebx,%eax
f0100e68:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f0100e6e:	c1 f8 03             	sar    $0x3,%eax
f0100e71:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e74:	89 c2                	mov    %eax,%edx
f0100e76:	c1 ea 0c             	shr    $0xc,%edx
f0100e79:	3b 15 88 ee 22 f0    	cmp    0xf022ee88,%edx
f0100e7f:	72 12                	jb     f0100e93 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e81:	50                   	push   %eax
f0100e82:	68 44 5e 10 f0       	push   $0xf0105e44
f0100e87:	6a 58                	push   $0x58
f0100e89:	68 91 6c 10 f0       	push   $0xf0106c91
f0100e8e:	e8 ad f1 ff ff       	call   f0100040 <_panic>
			memset(page2kva(result), 0, PGSIZE);
f0100e93:	83 ec 04             	sub    $0x4,%esp
f0100e96:	68 00 10 00 00       	push   $0x1000
f0100e9b:	6a 00                	push   $0x0
f0100e9d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ea2:	50                   	push   %eax
f0100ea3:	e8 ca 42 00 00       	call   f0105172 <memset>
f0100ea8:	83 c4 10             	add    $0x10,%esp
	}
	return result;
}
f0100eab:	89 d8                	mov    %ebx,%eax
f0100ead:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100eb0:	c9                   	leave  
f0100eb1:	c3                   	ret    

f0100eb2 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100eb2:	55                   	push   %ebp
f0100eb3:	89 e5                	mov    %esp,%ebp
f0100eb5:	83 ec 08             	sub    $0x8,%esp
f0100eb8:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	//容错判断
	assert(pp != NULL);
f0100ebb:	85 c0                	test   %eax,%eax
f0100ebd:	75 19                	jne    f0100ed8 <page_free+0x26>
f0100ebf:	68 58 6d 10 f0       	push   $0xf0106d58
f0100ec4:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100ec9:	68 8f 01 00 00       	push   $0x18f
f0100ece:	68 85 6c 10 f0       	push   $0xf0106c85
f0100ed3:	e8 68 f1 ff ff       	call   f0100040 <_panic>
	assert(pp->pp_ref == 0);
f0100ed8:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100edd:	74 19                	je     f0100ef8 <page_free+0x46>
f0100edf:	68 63 6d 10 f0       	push   $0xf0106d63
f0100ee4:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100ee9:	68 90 01 00 00       	push   $0x190
f0100eee:	68 85 6c 10 f0       	push   $0xf0106c85
f0100ef3:	e8 48 f1 ff ff       	call   f0100040 <_panic>
	assert(pp->pp_link == NULL);
f0100ef8:	83 38 00             	cmpl   $0x0,(%eax)
f0100efb:	74 19                	je     f0100f16 <page_free+0x64>
f0100efd:	68 73 6d 10 f0       	push   $0xf0106d73
f0100f02:	68 ab 6c 10 f0       	push   $0xf0106cab
f0100f07:	68 91 01 00 00       	push   $0x191
f0100f0c:	68 85 6c 10 f0       	push   $0xf0106c85
f0100f11:	e8 2a f1 ff ff       	call   f0100040 <_panic>
	
	//释放物理页面
      	pp->pp_link = page_free_list;
f0100f16:	8b 15 40 e2 22 f0    	mov    0xf022e240,%edx
f0100f1c:	89 10                	mov    %edx,(%eax)
      	page_free_list = pp;
f0100f1e:	a3 40 e2 22 f0       	mov    %eax,0xf022e240
}
f0100f23:	c9                   	leave  
f0100f24:	c3                   	ret    

f0100f25 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f25:	55                   	push   %ebp
f0100f26:	89 e5                	mov    %esp,%ebp
f0100f28:	83 ec 08             	sub    $0x8,%esp
f0100f2b:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f2e:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f32:	83 e8 01             	sub    $0x1,%eax
f0100f35:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f39:	66 85 c0             	test   %ax,%ax
f0100f3c:	75 0c                	jne    f0100f4a <page_decref+0x25>
		page_free(pp);
f0100f3e:	83 ec 0c             	sub    $0xc,%esp
f0100f41:	52                   	push   %edx
f0100f42:	e8 6b ff ff ff       	call   f0100eb2 <page_free>
f0100f47:	83 c4 10             	add    $0x10,%esp
}
f0100f4a:	c9                   	leave  
f0100f4b:	c3                   	ret    

f0100f4c <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//返回虚拟地址所对应的页表项指针page table entry (PTE)
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f4c:	55                   	push   %ebp
f0100f4d:	89 e5                	mov    %esp,%ebp
f0100f4f:	56                   	push   %esi
f0100f50:	53                   	push   %ebx
f0100f51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	//return NULL;
	//根据虚拟地址解析出页目录索引和页表索引，pdx--页目录索引 ptx -- 页表索引
	size_t pdx = PDX(va), ptx = PTX(va);
f0100f54:	89 de                	mov    %ebx,%esi
f0100f56:	c1 ee 0c             	shr    $0xc,%esi
f0100f59:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
f0100f5f:	c1 eb 16             	shr    $0x16,%ebx
f0100f62:	c1 e3 02             	shl    $0x2,%ebx
f0100f65:	03 5d 08             	add    0x8(%ebp),%ebx
f0100f68:	f6 03 01             	testb  $0x1,(%ebx)
f0100f6b:	75 2d                	jne    f0100f9a <pgdir_walk+0x4e>
		if (!create) 
f0100f6d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f71:	74 59                	je     f0100fcc <pgdir_walk+0x80>
			return NULL;
		pp = page_alloc(ALLOC_ZERO);
f0100f73:	83 ec 0c             	sub    $0xc,%esp
f0100f76:	6a 01                	push   $0x1
f0100f78:	e8 c5 fe ff ff       	call   f0100e42 <page_alloc>
		if (pp == NULL) 
f0100f7d:	83 c4 10             	add    $0x10,%esp
f0100f80:	85 c0                	test   %eax,%eax
f0100f82:	74 4f                	je     f0100fd3 <pgdir_walk+0x87>
			return NULL;
		pp->pp_ref++;
f0100f84:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
		pgdir[pdx] = page2pa(pp) | PTE_W | PTE_U | PTE_P; 
f0100f89:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f0100f8f:	c1 f8 03             	sar    $0x3,%eax
f0100f92:	c1 e0 0c             	shl    $0xc,%eax
f0100f95:	83 c8 07             	or     $0x7,%eax
f0100f98:	89 03                	mov    %eax,(%ebx)
	} 
	
	//这里为什么要用 PTE_ADDR？？？
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
f0100f9a:	8b 03                	mov    (%ebx),%eax
f0100f9c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fa1:	89 c2                	mov    %eax,%edx
f0100fa3:	c1 ea 0c             	shr    $0xc,%edx
f0100fa6:	3b 15 88 ee 22 f0    	cmp    0xf022ee88,%edx
f0100fac:	72 15                	jb     f0100fc3 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100fae:	50                   	push   %eax
f0100faf:	68 44 5e 10 f0       	push   $0xf0105e44
f0100fb4:	68 ce 01 00 00       	push   $0x1ce
f0100fb9:	68 85 6c 10 f0       	push   $0xf0106c85
f0100fbe:	e8 7d f0 ff ff       	call   f0100040 <_panic>
	return &pgtbl[ptx];
f0100fc3:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100fca:	eb 0c                	jmp    f0100fd8 <pgdir_walk+0x8c>
	struct PageInfo *pp = NULL;
	pte_t *pgtbl = NULL;

	if (!(pgdir[pdx] & PTE_P)) {
		if (!create) 
			return NULL;
f0100fcc:	b8 00 00 00 00       	mov    $0x0,%eax
f0100fd1:	eb 05                	jmp    f0100fd8 <pgdir_walk+0x8c>
		pp = page_alloc(ALLOC_ZERO);
		if (pp == NULL) 
			return NULL;
f0100fd3:	b8 00 00 00 00       	mov    $0x0,%eax
	} 
	
	//这里为什么要用 PTE_ADDR？？？
	pgtbl = (pte_t *) KADDR(PTE_ADDR(pgdir[pdx]));
	return &pgtbl[ptx];
}
f0100fd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100fdb:	5b                   	pop    %ebx
f0100fdc:	5e                   	pop    %esi
f0100fdd:	5d                   	pop    %ebp
f0100fde:	c3                   	ret    

f0100fdf <boot_map_region>:
// Hint: the TA solution uses pgdir_walk
//把虚拟地址空间范围[va, va+size)映射到物理空间[pa, pa+size)的映射关系加入到页表中
//这个函数主要的目的是为了设置虚拟地址UTOP之上的地址范围
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0100fdf:	55                   	push   %ebp
f0100fe0:	89 e5                	mov    %esp,%ebp
f0100fe2:	57                   	push   %edi
f0100fe3:	56                   	push   %esi
f0100fe4:	53                   	push   %ebx
f0100fe5:	83 ec 1c             	sub    $0x1c,%esp
f0100fe8:	89 c7                	mov    %eax,%edi
f0100fea:	89 d6                	mov    %edx,%esi
f0100fec:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f0100fef:	bb 00 00 00 00       	mov    $0x0,%ebx
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
f0100ff4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100ff7:	83 c8 01             	or     $0x1,%eax
f0100ffa:	89 45 e0             	mov    %eax,-0x20(%ebp)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f0100ffd:	eb 22                	jmp    f0101021 <boot_map_region+0x42>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
f0100fff:	83 ec 04             	sub    $0x4,%esp
f0101002:	6a 01                	push   $0x1
f0101004:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f0101007:	50                   	push   %eax
f0101008:	57                   	push   %edi
f0101009:	e8 3e ff ff ff       	call   f0100f4c <pgdir_walk>
		*pte = (pa + i) | perm | PTE_P;
f010100e:	89 da                	mov    %ebx,%edx
f0101010:	03 55 08             	add    0x8(%ebp),%edx
f0101013:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101016:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	size_t i;
	for (i = 0; i < size; i += PGSIZE) {
f0101018:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010101e:	83 c4 10             	add    $0x10,%esp
f0101021:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101024:	72 d9                	jb     f0100fff <boot_map_region+0x20>
		pte_t *pte = pgdir_walk(pgdir, (void *)(va + i), 1);
		*pte = (pa + i) | perm | PTE_P;
	}
}
f0101026:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101029:	5b                   	pop    %ebx
f010102a:	5e                   	pop    %esi
f010102b:	5f                   	pop    %edi
f010102c:	5d                   	pop    %ebp
f010102d:	c3                   	ret    

f010102e <page_lookup>:
// Hint: the TA solution uses pgdir_walk and pa2page.
//返回虚拟地址所映射（对应）的物理页的PageInfo结构体的指针
//返回虚拟地址所对应的物理页指针
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f010102e:	55                   	push   %ebp
f010102f:	89 e5                	mov    %esp,%ebp
f0101031:	53                   	push   %ebx
f0101032:	83 ec 08             	sub    $0x8,%esp
f0101035:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101038:	6a 01                	push   $0x1
f010103a:	ff 75 0c             	pushl  0xc(%ebp)
f010103d:	ff 75 08             	pushl  0x8(%ebp)
f0101040:	e8 07 ff ff ff       	call   f0100f4c <pgdir_walk>
	//pte_store存页表项指针的地址，*pte_store表示页表项指针，即页表项地址，**pte_store表示页表项
	//pte_store????
	if (pte_store)
f0101045:	83 c4 10             	add    $0x10,%esp
f0101048:	85 db                	test   %ebx,%ebx
f010104a:	74 02                	je     f010104e <page_lookup+0x20>
		*pte_store = pte;
f010104c:	89 03                	mov    %eax,(%ebx)
	if (pte == NULL || !(*pte & PTE_P)) 
f010104e:	85 c0                	test   %eax,%eax
f0101050:	74 30                	je     f0101082 <page_lookup+0x54>
f0101052:	8b 00                	mov    (%eax),%eax
f0101054:	a8 01                	test   $0x1,%al
f0101056:	74 31                	je     f0101089 <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101058:	c1 e8 0c             	shr    $0xc,%eax
f010105b:	3b 05 88 ee 22 f0    	cmp    0xf022ee88,%eax
f0101061:	72 14                	jb     f0101077 <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f0101063:	83 ec 04             	sub    $0x4,%esp
f0101066:	68 24 64 10 f0       	push   $0xf0106424
f010106b:	6a 51                	push   $0x51
f010106d:	68 91 6c 10 f0       	push   $0xf0106c91
f0101072:	e8 c9 ef ff ff       	call   f0100040 <_panic>
	return &pages[PGNUM(pa)];
f0101077:	8b 15 90 ee 22 f0    	mov    0xf022ee90,%edx
f010107d:	8d 04 c2             	lea    (%edx,%eax,8),%eax
		return NULL;
	return pa2page(PTE_ADDR(*pte));
f0101080:	eb 0c                	jmp    f010108e <page_lookup+0x60>
	//pte_store存页表项指针的地址，*pte_store表示页表项指针，即页表项地址，**pte_store表示页表项
	//pte_store????
	if (pte_store)
		*pte_store = pte;
	if (pte == NULL || !(*pte & PTE_P)) 
		return NULL;
f0101082:	b8 00 00 00 00       	mov    $0x0,%eax
f0101087:	eb 05                	jmp    f010108e <page_lookup+0x60>
f0101089:	b8 00 00 00 00       	mov    $0x0,%eax
	return pa2page(PTE_ADDR(*pte));
}
f010108e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0101091:	c9                   	leave  
f0101092:	c3                   	ret    

f0101093 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0101093:	55                   	push   %ebp
f0101094:	89 e5                	mov    %esp,%ebp
f0101096:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0101099:	e8 f4 46 00 00       	call   f0105792 <cpunum>
f010109e:	6b c0 74             	imul   $0x74,%eax,%eax
f01010a1:	83 b8 28 f0 22 f0 00 	cmpl   $0x0,-0xfdd0fd8(%eax)
f01010a8:	74 16                	je     f01010c0 <tlb_invalidate+0x2d>
f01010aa:	e8 e3 46 00 00       	call   f0105792 <cpunum>
f01010af:	6b c0 74             	imul   $0x74,%eax,%eax
f01010b2:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f01010b8:	8b 55 08             	mov    0x8(%ebp),%edx
f01010bb:	39 50 60             	cmp    %edx,0x60(%eax)
f01010be:	75 06                	jne    f01010c6 <tlb_invalidate+0x33>
}

static inline void
invlpg(void *addr)
{
	asm volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010c0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010c3:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01010c6:	c9                   	leave  
f01010c7:	c3                   	ret    

f01010c8 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01010c8:	55                   	push   %ebp
f01010c9:	89 e5                	mov    %esp,%ebp
f01010cb:	57                   	push   %edi
f01010cc:	56                   	push   %esi
f01010cd:	53                   	push   %ebx
f01010ce:	83 ec 20             	sub    $0x20,%esp
f01010d1:	8b 75 08             	mov    0x8(%ebp),%esi
f01010d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	// Fill this function in
	pte_t *pte = NULL;
f01010d7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	struct PageInfo *pp = page_lookup(pgdir, va, &pte);
f01010de:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01010e1:	50                   	push   %eax
f01010e2:	57                   	push   %edi
f01010e3:	56                   	push   %esi
f01010e4:	e8 45 ff ff ff       	call   f010102e <page_lookup>
	if(pp == NULL)
f01010e9:	83 c4 10             	add    $0x10,%esp
f01010ec:	85 c0                	test   %eax,%eax
f01010ee:	74 20                	je     f0101110 <page_remove+0x48>
f01010f0:	89 c3                	mov    %eax,%ebx
		return;
	*pte = (pte_t) 0; //将页表项内容置为空
f01010f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01010f5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	tlb_invalidate(pgdir, va); //tlb置为无效
f01010fb:	83 ec 08             	sub    $0x8,%esp
f01010fe:	57                   	push   %edi
f01010ff:	56                   	push   %esi
f0101100:	e8 8e ff ff ff       	call   f0101093 <tlb_invalidate>
	page_decref(pp); //减少引用
f0101105:	89 1c 24             	mov    %ebx,(%esp)
f0101108:	e8 18 fe ff ff       	call   f0100f25 <page_decref>
f010110d:	83 c4 10             	add    $0x10,%esp
}
f0101110:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101113:	5b                   	pop    %ebx
f0101114:	5e                   	pop    %esi
f0101115:	5f                   	pop    %edi
f0101116:	5d                   	pop    %ebp
f0101117:	c3                   	ret    

f0101118 <page_insert>:
// and page2pa.
//把一个物理内存中页pp与虚拟地址va建立映射关系。
//其实就是 更新页表
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101118:	55                   	push   %ebp
f0101119:	89 e5                	mov    %esp,%ebp
f010111b:	57                   	push   %edi
f010111c:	56                   	push   %esi
f010111d:	53                   	push   %ebx
f010111e:	83 ec 10             	sub    $0x10,%esp
f0101121:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0101124:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	//return 0;
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f0101127:	6a 01                	push   $0x1
f0101129:	57                   	push   %edi
f010112a:	ff 75 08             	pushl  0x8(%ebp)
f010112d:	e8 1a fe ff ff       	call   f0100f4c <pgdir_walk>
    if (pte == NULL)  
f0101132:	83 c4 10             	add    $0x10,%esp
f0101135:	85 c0                	test   %eax,%eax
f0101137:	74 38                	je     f0101171 <page_insert+0x59>
f0101139:	89 c6                	mov    %eax,%esi
    	return -E_NO_MEM;

    pp->pp_ref++;
f010113b:	66 83 43 04 01       	addw   $0x1,0x4(%ebx)
    //??????
    if (*pte & PTE_P)
f0101140:	f6 00 01             	testb  $0x1,(%eax)
f0101143:	74 0f                	je     f0101154 <page_insert+0x3c>
            page_remove(pgdir, va);
f0101145:	83 ec 08             	sub    $0x8,%esp
f0101148:	57                   	push   %edi
f0101149:	ff 75 08             	pushl  0x8(%ebp)
f010114c:	e8 77 ff ff ff       	call   f01010c8 <page_remove>
f0101151:	83 c4 10             	add    $0x10,%esp

    *pte = page2pa(pp) | perm | PTE_P;
f0101154:	2b 1d 90 ee 22 f0    	sub    0xf022ee90,%ebx
f010115a:	c1 fb 03             	sar    $0x3,%ebx
f010115d:	c1 e3 0c             	shl    $0xc,%ebx
f0101160:	8b 45 14             	mov    0x14(%ebp),%eax
f0101163:	83 c8 01             	or     $0x1,%eax
f0101166:	09 c3                	or     %eax,%ebx
f0101168:	89 1e                	mov    %ebx,(%esi)

    return 0;
f010116a:	b8 00 00 00 00       	mov    $0x0,%eax
f010116f:	eb 05                	jmp    f0101176 <page_insert+0x5e>
{
	// Fill this function in
	//return 0;
	pte_t *pte = pgdir_walk(pgdir, va, 1);
    if (pte == NULL)  
    	return -E_NO_MEM;
f0101171:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
            page_remove(pgdir, va);

    *pte = page2pa(pp) | perm | PTE_P;

    return 0;
}
f0101176:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101179:	5b                   	pop    %ebx
f010117a:	5e                   	pop    %esi
f010117b:	5f                   	pop    %edi
f010117c:	5d                   	pop    %ebp
f010117d:	c3                   	ret    

f010117e <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
// I/O内存映射
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f010117e:	55                   	push   %ebp
f010117f:	89 e5                	mov    %esp,%ebp
f0101181:	53                   	push   %ebx
f0101182:	83 ec 04             	sub    $0x4,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	uintptr_t va_start = base, va_end;
f0101185:	8b 1d 00 f3 11 f0    	mov    0xf011f300,%ebx
	
	// 向上页对齐
	size = ROUNDUP(size, PGSIZE);
f010118b:	8b 45 0c             	mov    0xc(%ebp),%eax
f010118e:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
f0101194:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
	va_end = base + size;
f010119a:	8d 04 0b             	lea    (%ebx,%ecx,1),%eax
	
	// 如果要分配的空间低于MMIOBASE或者超过MMIOLIM,这发出错误
	if (!(va_end >= MMIOBASE && va_end <= MMIOLIM))
f010119d:	8d 90 00 00 80 10    	lea    0x10800000(%eax),%edx
f01011a3:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
f01011a9:	76 17                	jbe    f01011c2 <mmio_map_region+0x44>
		panic("mmio_map_region: MMIO space overflow");
f01011ab:	83 ec 04             	sub    $0x4,%esp
f01011ae:	68 44 64 10 f0       	push   $0xf0106444
f01011b3:	68 82 02 00 00       	push   $0x282
f01011b8:	68 85 6c 10 f0       	push   $0xf0106c85
f01011bd:	e8 7e ee ff ff       	call   f0100040 <_panic>

	// 让base指向虚拟空间中MMIO空洞的空闲位置
	base = va_end;
f01011c2:	a3 00 f3 11 f0       	mov    %eax,0xf011f300
	
	// 将设备的虚拟地址映射其真实的物理地址(cache访问不安全)
	boot_map_region(kern_pgdir, va_start, size, pa, PTE_W | PTE_PCD | PTE_PWT);
f01011c7:	83 ec 08             	sub    $0x8,%esp
f01011ca:	6a 1a                	push   $0x1a
f01011cc:	ff 75 08             	pushl  0x8(%ebp)
f01011cf:	89 da                	mov    %ebx,%edx
f01011d1:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f01011d6:	e8 04 fe ff ff       	call   f0100fdf <boot_map_region>
	
	// 返回设备在虚拟空间的地址
	return (void *) va_start;

	//panic("mmio_map_region not implemented");
}
f01011db:	89 d8                	mov    %ebx,%eax
f01011dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01011e0:	c9                   	leave  
f01011e1:	c3                   	ret    

f01011e2 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01011e2:	55                   	push   %ebp
f01011e3:	89 e5                	mov    %esp,%ebp
f01011e5:	57                   	push   %edi
f01011e6:	56                   	push   %esi
f01011e7:	53                   	push   %ebx
f01011e8:	83 ec 3c             	sub    $0x3c,%esp
{
	size_t basemem, extmem, ext16mem, totalmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	basemem = nvram_read(NVRAM_BASELO);
f01011eb:	b8 15 00 00 00       	mov    $0x15,%eax
f01011f0:	e8 21 f8 ff ff       	call   f0100a16 <nvram_read>
f01011f5:	89 c3                	mov    %eax,%ebx
	extmem = nvram_read(NVRAM_EXTLO);
f01011f7:	b8 17 00 00 00       	mov    $0x17,%eax
f01011fc:	e8 15 f8 ff ff       	call   f0100a16 <nvram_read>
f0101201:	89 c6                	mov    %eax,%esi
	ext16mem = nvram_read(NVRAM_EXT16LO) * 64;
f0101203:	b8 34 00 00 00       	mov    $0x34,%eax
f0101208:	e8 09 f8 ff ff       	call   f0100a16 <nvram_read>
f010120d:	c1 e0 06             	shl    $0x6,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (ext16mem)
f0101210:	85 c0                	test   %eax,%eax
f0101212:	74 07                	je     f010121b <mem_init+0x39>
		totalmem = 16 * 1024 + ext16mem;
f0101214:	05 00 40 00 00       	add    $0x4000,%eax
f0101219:	eb 0b                	jmp    f0101226 <mem_init+0x44>
	else if (extmem)
		totalmem = 1 * 1024 + extmem;
f010121b:	8d 86 00 04 00 00    	lea    0x400(%esi),%eax
f0101221:	85 f6                	test   %esi,%esi
f0101223:	0f 44 c3             	cmove  %ebx,%eax
	else
		totalmem = basemem;

	npages = totalmem / (PGSIZE / 1024);
f0101226:	89 c2                	mov    %eax,%edx
f0101228:	c1 ea 02             	shr    $0x2,%edx
f010122b:	89 15 88 ee 22 f0    	mov    %edx,0xf022ee88
	npages_basemem = basemem / (PGSIZE / 1024);
f0101231:	89 da                	mov    %ebx,%edx
f0101233:	c1 ea 02             	shr    $0x2,%edx
f0101236:	89 15 44 e2 22 f0    	mov    %edx,0xf022e244

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010123c:	89 c2                	mov    %eax,%edx
f010123e:	29 da                	sub    %ebx,%edx
f0101240:	52                   	push   %edx
f0101241:	53                   	push   %ebx
f0101242:	50                   	push   %eax
f0101243:	68 6c 64 10 f0       	push   $0xf010646c
f0101248:	e8 54 23 00 00       	call   f01035a1 <cprintf>

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	//kern_pgdir -- 操作系统的页目录表指针，页目录表的大小为一个页的大小
	//第一个调用boot_alloc(),故kern_pgdir位于内核bss段的末尾，紧跟这操作系统内核
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f010124d:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101252:	e8 85 f7 ff ff       	call   f01009dc <boot_alloc>
f0101257:	a3 8c ee 22 f0       	mov    %eax,0xf022ee8c
	//内存清零
	memset(kern_pgdir, 0, PGSIZE);
f010125c:	83 c4 0c             	add    $0xc,%esp
f010125f:	68 00 10 00 00       	push   $0x1000
f0101264:	6a 00                	push   $0x0
f0101266:	50                   	push   %eax
f0101267:	e8 06 3f 00 00       	call   f0105172 <memset>
	// Permissions: kernel R, user R
	// 为页目录表添加第一个页目录表项
	/* UVPT的定义是一段虚拟地址的起始地址，0xef400000，
	   从这个虚拟地址开始，存放的就是这个操作系统的页目录表*/
	// 映射？？？自身映射
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f010126c:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101271:	83 c4 10             	add    $0x10,%esp
f0101274:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101279:	77 15                	ja     f0101290 <mem_init+0xae>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010127b:	50                   	push   %eax
f010127c:	68 68 5e 10 f0       	push   $0xf0105e68
f0101281:	68 a1 00 00 00       	push   $0xa1
f0101286:	68 85 6c 10 f0       	push   $0xf0106c85
f010128b:	e8 b0 ed ff ff       	call   f0100040 <_panic>
f0101290:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0101296:	83 ca 05             	or     $0x5,%edx
f0101299:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	// 分配一块内存用来存放pages，pages数组里的每一项代表一个物理页面
	n = npages * sizeof(struct PageInfo);
f010129f:	a1 88 ee 22 f0       	mov    0xf022ee88,%eax
f01012a4:	8d 1c c5 00 00 00 00 	lea    0x0(,%eax,8),%ebx
	pages = (struct PageInfo *) boot_alloc(n);
f01012ab:	89 d8                	mov    %ebx,%eax
f01012ad:	e8 2a f7 ff ff       	call   f01009dc <boot_alloc>
f01012b2:	a3 90 ee 22 f0       	mov    %eax,0xf022ee90
	//内存清零
	memset(pages, 0, n);
f01012b7:	83 ec 04             	sub    $0x4,%esp
f01012ba:	53                   	push   %ebx
f01012bb:	6a 00                	push   $0x0
f01012bd:	50                   	push   %eax
f01012be:	e8 af 3e 00 00       	call   f0105172 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	// 分配空间存储envs，envs数组里的每一项代表一个用户空间(进程空间)
	envs = (struct Env *) boot_alloc(NENV * sizeof(struct Env));
f01012c3:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f01012c8:	e8 0f f7 ff ff       	call   f01009dc <boot_alloc>
f01012cd:	a3 48 e2 22 f0       	mov    %eax,0xf022e248
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	// 初始化物理页和空闲链表
	page_init();
f01012d2:	e8 ce fa ff ff       	call   f0100da5 <page_init>
	
	//检查空闲链表是否合法
	check_page_free_list(1);
f01012d7:	b8 01 00 00 00       	mov    $0x1,%eax
f01012dc:	e8 c2 f7 ff ff       	call   f0100aa3 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01012e1:	83 c4 10             	add    $0x10,%esp
f01012e4:	83 3d 90 ee 22 f0 00 	cmpl   $0x0,0xf022ee90
f01012eb:	75 17                	jne    f0101304 <mem_init+0x122>
		panic("'pages' is a null pointer!");
f01012ed:	83 ec 04             	sub    $0x4,%esp
f01012f0:	68 87 6d 10 f0       	push   $0xf0106d87
f01012f5:	68 22 03 00 00       	push   $0x322
f01012fa:	68 85 6c 10 f0       	push   $0xf0106c85
f01012ff:	e8 3c ed ff ff       	call   f0100040 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101304:	a1 40 e2 22 f0       	mov    0xf022e240,%eax
f0101309:	bb 00 00 00 00       	mov    $0x0,%ebx
f010130e:	eb 05                	jmp    f0101315 <mem_init+0x133>
		++nfree;
f0101310:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101313:	8b 00                	mov    (%eax),%eax
f0101315:	85 c0                	test   %eax,%eax
f0101317:	75 f7                	jne    f0101310 <mem_init+0x12e>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101319:	83 ec 0c             	sub    $0xc,%esp
f010131c:	6a 00                	push   $0x0
f010131e:	e8 1f fb ff ff       	call   f0100e42 <page_alloc>
f0101323:	89 c7                	mov    %eax,%edi
f0101325:	83 c4 10             	add    $0x10,%esp
f0101328:	85 c0                	test   %eax,%eax
f010132a:	75 19                	jne    f0101345 <mem_init+0x163>
f010132c:	68 a2 6d 10 f0       	push   $0xf0106da2
f0101331:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101336:	68 2a 03 00 00       	push   $0x32a
f010133b:	68 85 6c 10 f0       	push   $0xf0106c85
f0101340:	e8 fb ec ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f0101345:	83 ec 0c             	sub    $0xc,%esp
f0101348:	6a 00                	push   $0x0
f010134a:	e8 f3 fa ff ff       	call   f0100e42 <page_alloc>
f010134f:	89 c6                	mov    %eax,%esi
f0101351:	83 c4 10             	add    $0x10,%esp
f0101354:	85 c0                	test   %eax,%eax
f0101356:	75 19                	jne    f0101371 <mem_init+0x18f>
f0101358:	68 b8 6d 10 f0       	push   $0xf0106db8
f010135d:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101362:	68 2b 03 00 00       	push   $0x32b
f0101367:	68 85 6c 10 f0       	push   $0xf0106c85
f010136c:	e8 cf ec ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101371:	83 ec 0c             	sub    $0xc,%esp
f0101374:	6a 00                	push   $0x0
f0101376:	e8 c7 fa ff ff       	call   f0100e42 <page_alloc>
f010137b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010137e:	83 c4 10             	add    $0x10,%esp
f0101381:	85 c0                	test   %eax,%eax
f0101383:	75 19                	jne    f010139e <mem_init+0x1bc>
f0101385:	68 ce 6d 10 f0       	push   $0xf0106dce
f010138a:	68 ab 6c 10 f0       	push   $0xf0106cab
f010138f:	68 2c 03 00 00       	push   $0x32c
f0101394:	68 85 6c 10 f0       	push   $0xf0106c85
f0101399:	e8 a2 ec ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f010139e:	39 f7                	cmp    %esi,%edi
f01013a0:	75 19                	jne    f01013bb <mem_init+0x1d9>
f01013a2:	68 e4 6d 10 f0       	push   $0xf0106de4
f01013a7:	68 ab 6c 10 f0       	push   $0xf0106cab
f01013ac:	68 2f 03 00 00       	push   $0x32f
f01013b1:	68 85 6c 10 f0       	push   $0xf0106c85
f01013b6:	e8 85 ec ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013be:	39 c6                	cmp    %eax,%esi
f01013c0:	74 04                	je     f01013c6 <mem_init+0x1e4>
f01013c2:	39 c7                	cmp    %eax,%edi
f01013c4:	75 19                	jne    f01013df <mem_init+0x1fd>
f01013c6:	68 a8 64 10 f0       	push   $0xf01064a8
f01013cb:	68 ab 6c 10 f0       	push   $0xf0106cab
f01013d0:	68 30 03 00 00       	push   $0x330
f01013d5:	68 85 6c 10 f0       	push   $0xf0106c85
f01013da:	e8 61 ec ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013df:	8b 0d 90 ee 22 f0    	mov    0xf022ee90,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013e5:	8b 15 88 ee 22 f0    	mov    0xf022ee88,%edx
f01013eb:	c1 e2 0c             	shl    $0xc,%edx
f01013ee:	89 f8                	mov    %edi,%eax
f01013f0:	29 c8                	sub    %ecx,%eax
f01013f2:	c1 f8 03             	sar    $0x3,%eax
f01013f5:	c1 e0 0c             	shl    $0xc,%eax
f01013f8:	39 d0                	cmp    %edx,%eax
f01013fa:	72 19                	jb     f0101415 <mem_init+0x233>
f01013fc:	68 f6 6d 10 f0       	push   $0xf0106df6
f0101401:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101406:	68 31 03 00 00       	push   $0x331
f010140b:	68 85 6c 10 f0       	push   $0xf0106c85
f0101410:	e8 2b ec ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101415:	89 f0                	mov    %esi,%eax
f0101417:	29 c8                	sub    %ecx,%eax
f0101419:	c1 f8 03             	sar    $0x3,%eax
f010141c:	c1 e0 0c             	shl    $0xc,%eax
f010141f:	39 c2                	cmp    %eax,%edx
f0101421:	77 19                	ja     f010143c <mem_init+0x25a>
f0101423:	68 13 6e 10 f0       	push   $0xf0106e13
f0101428:	68 ab 6c 10 f0       	push   $0xf0106cab
f010142d:	68 32 03 00 00       	push   $0x332
f0101432:	68 85 6c 10 f0       	push   $0xf0106c85
f0101437:	e8 04 ec ff ff       	call   f0100040 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f010143c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010143f:	29 c8                	sub    %ecx,%eax
f0101441:	c1 f8 03             	sar    $0x3,%eax
f0101444:	c1 e0 0c             	shl    $0xc,%eax
f0101447:	39 c2                	cmp    %eax,%edx
f0101449:	77 19                	ja     f0101464 <mem_init+0x282>
f010144b:	68 30 6e 10 f0       	push   $0xf0106e30
f0101450:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101455:	68 33 03 00 00       	push   $0x333
f010145a:	68 85 6c 10 f0       	push   $0xf0106c85
f010145f:	e8 dc eb ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101464:	a1 40 e2 22 f0       	mov    0xf022e240,%eax
f0101469:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010146c:	c7 05 40 e2 22 f0 00 	movl   $0x0,0xf022e240
f0101473:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101476:	83 ec 0c             	sub    $0xc,%esp
f0101479:	6a 00                	push   $0x0
f010147b:	e8 c2 f9 ff ff       	call   f0100e42 <page_alloc>
f0101480:	83 c4 10             	add    $0x10,%esp
f0101483:	85 c0                	test   %eax,%eax
f0101485:	74 19                	je     f01014a0 <mem_init+0x2be>
f0101487:	68 4d 6e 10 f0       	push   $0xf0106e4d
f010148c:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101491:	68 3a 03 00 00       	push   $0x33a
f0101496:	68 85 6c 10 f0       	push   $0xf0106c85
f010149b:	e8 a0 eb ff ff       	call   f0100040 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014a0:	83 ec 0c             	sub    $0xc,%esp
f01014a3:	57                   	push   %edi
f01014a4:	e8 09 fa ff ff       	call   f0100eb2 <page_free>
	page_free(pp1);
f01014a9:	89 34 24             	mov    %esi,(%esp)
f01014ac:	e8 01 fa ff ff       	call   f0100eb2 <page_free>
	page_free(pp2);
f01014b1:	83 c4 04             	add    $0x4,%esp
f01014b4:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014b7:	e8 f6 f9 ff ff       	call   f0100eb2 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014bc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014c3:	e8 7a f9 ff ff       	call   f0100e42 <page_alloc>
f01014c8:	89 c6                	mov    %eax,%esi
f01014ca:	83 c4 10             	add    $0x10,%esp
f01014cd:	85 c0                	test   %eax,%eax
f01014cf:	75 19                	jne    f01014ea <mem_init+0x308>
f01014d1:	68 a2 6d 10 f0       	push   $0xf0106da2
f01014d6:	68 ab 6c 10 f0       	push   $0xf0106cab
f01014db:	68 41 03 00 00       	push   $0x341
f01014e0:	68 85 6c 10 f0       	push   $0xf0106c85
f01014e5:	e8 56 eb ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01014ea:	83 ec 0c             	sub    $0xc,%esp
f01014ed:	6a 00                	push   $0x0
f01014ef:	e8 4e f9 ff ff       	call   f0100e42 <page_alloc>
f01014f4:	89 c7                	mov    %eax,%edi
f01014f6:	83 c4 10             	add    $0x10,%esp
f01014f9:	85 c0                	test   %eax,%eax
f01014fb:	75 19                	jne    f0101516 <mem_init+0x334>
f01014fd:	68 b8 6d 10 f0       	push   $0xf0106db8
f0101502:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101507:	68 42 03 00 00       	push   $0x342
f010150c:	68 85 6c 10 f0       	push   $0xf0106c85
f0101511:	e8 2a eb ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0101516:	83 ec 0c             	sub    $0xc,%esp
f0101519:	6a 00                	push   $0x0
f010151b:	e8 22 f9 ff ff       	call   f0100e42 <page_alloc>
f0101520:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101523:	83 c4 10             	add    $0x10,%esp
f0101526:	85 c0                	test   %eax,%eax
f0101528:	75 19                	jne    f0101543 <mem_init+0x361>
f010152a:	68 ce 6d 10 f0       	push   $0xf0106dce
f010152f:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101534:	68 43 03 00 00       	push   $0x343
f0101539:	68 85 6c 10 f0       	push   $0xf0106c85
f010153e:	e8 fd ea ff ff       	call   f0100040 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101543:	39 fe                	cmp    %edi,%esi
f0101545:	75 19                	jne    f0101560 <mem_init+0x37e>
f0101547:	68 e4 6d 10 f0       	push   $0xf0106de4
f010154c:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101551:	68 45 03 00 00       	push   $0x345
f0101556:	68 85 6c 10 f0       	push   $0xf0106c85
f010155b:	e8 e0 ea ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101560:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101563:	39 c7                	cmp    %eax,%edi
f0101565:	74 04                	je     f010156b <mem_init+0x389>
f0101567:	39 c6                	cmp    %eax,%esi
f0101569:	75 19                	jne    f0101584 <mem_init+0x3a2>
f010156b:	68 a8 64 10 f0       	push   $0xf01064a8
f0101570:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101575:	68 46 03 00 00       	push   $0x346
f010157a:	68 85 6c 10 f0       	push   $0xf0106c85
f010157f:	e8 bc ea ff ff       	call   f0100040 <_panic>
	assert(!page_alloc(0));
f0101584:	83 ec 0c             	sub    $0xc,%esp
f0101587:	6a 00                	push   $0x0
f0101589:	e8 b4 f8 ff ff       	call   f0100e42 <page_alloc>
f010158e:	83 c4 10             	add    $0x10,%esp
f0101591:	85 c0                	test   %eax,%eax
f0101593:	74 19                	je     f01015ae <mem_init+0x3cc>
f0101595:	68 4d 6e 10 f0       	push   $0xf0106e4d
f010159a:	68 ab 6c 10 f0       	push   $0xf0106cab
f010159f:	68 47 03 00 00       	push   $0x347
f01015a4:	68 85 6c 10 f0       	push   $0xf0106c85
f01015a9:	e8 92 ea ff ff       	call   f0100040 <_panic>
f01015ae:	89 f0                	mov    %esi,%eax
f01015b0:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f01015b6:	c1 f8 03             	sar    $0x3,%eax
f01015b9:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015bc:	89 c2                	mov    %eax,%edx
f01015be:	c1 ea 0c             	shr    $0xc,%edx
f01015c1:	3b 15 88 ee 22 f0    	cmp    0xf022ee88,%edx
f01015c7:	72 12                	jb     f01015db <mem_init+0x3f9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01015c9:	50                   	push   %eax
f01015ca:	68 44 5e 10 f0       	push   $0xf0105e44
f01015cf:	6a 58                	push   $0x58
f01015d1:	68 91 6c 10 f0       	push   $0xf0106c91
f01015d6:	e8 65 ea ff ff       	call   f0100040 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01015db:	83 ec 04             	sub    $0x4,%esp
f01015de:	68 00 10 00 00       	push   $0x1000
f01015e3:	6a 01                	push   $0x1
f01015e5:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015ea:	50                   	push   %eax
f01015eb:	e8 82 3b 00 00       	call   f0105172 <memset>
	page_free(pp0);
f01015f0:	89 34 24             	mov    %esi,(%esp)
f01015f3:	e8 ba f8 ff ff       	call   f0100eb2 <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f01015f8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f01015ff:	e8 3e f8 ff ff       	call   f0100e42 <page_alloc>
f0101604:	83 c4 10             	add    $0x10,%esp
f0101607:	85 c0                	test   %eax,%eax
f0101609:	75 19                	jne    f0101624 <mem_init+0x442>
f010160b:	68 5c 6e 10 f0       	push   $0xf0106e5c
f0101610:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101615:	68 4c 03 00 00       	push   $0x34c
f010161a:	68 85 6c 10 f0       	push   $0xf0106c85
f010161f:	e8 1c ea ff ff       	call   f0100040 <_panic>
	assert(pp && pp0 == pp);
f0101624:	39 c6                	cmp    %eax,%esi
f0101626:	74 19                	je     f0101641 <mem_init+0x45f>
f0101628:	68 7a 6e 10 f0       	push   $0xf0106e7a
f010162d:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101632:	68 4d 03 00 00       	push   $0x34d
f0101637:	68 85 6c 10 f0       	push   $0xf0106c85
f010163c:	e8 ff e9 ff ff       	call   f0100040 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101641:	89 f0                	mov    %esi,%eax
f0101643:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f0101649:	c1 f8 03             	sar    $0x3,%eax
f010164c:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010164f:	89 c2                	mov    %eax,%edx
f0101651:	c1 ea 0c             	shr    $0xc,%edx
f0101654:	3b 15 88 ee 22 f0    	cmp    0xf022ee88,%edx
f010165a:	72 12                	jb     f010166e <mem_init+0x48c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010165c:	50                   	push   %eax
f010165d:	68 44 5e 10 f0       	push   $0xf0105e44
f0101662:	6a 58                	push   $0x58
f0101664:	68 91 6c 10 f0       	push   $0xf0106c91
f0101669:	e8 d2 e9 ff ff       	call   f0100040 <_panic>
f010166e:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101674:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f010167a:	80 38 00             	cmpb   $0x0,(%eax)
f010167d:	74 19                	je     f0101698 <mem_init+0x4b6>
f010167f:	68 8a 6e 10 f0       	push   $0xf0106e8a
f0101684:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101689:	68 50 03 00 00       	push   $0x350
f010168e:	68 85 6c 10 f0       	push   $0xf0106c85
f0101693:	e8 a8 e9 ff ff       	call   f0100040 <_panic>
f0101698:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f010169b:	39 d0                	cmp    %edx,%eax
f010169d:	75 db                	jne    f010167a <mem_init+0x498>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f010169f:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016a2:	a3 40 e2 22 f0       	mov    %eax,0xf022e240

	// free the pages we took
	page_free(pp0);
f01016a7:	83 ec 0c             	sub    $0xc,%esp
f01016aa:	56                   	push   %esi
f01016ab:	e8 02 f8 ff ff       	call   f0100eb2 <page_free>
	page_free(pp1);
f01016b0:	89 3c 24             	mov    %edi,(%esp)
f01016b3:	e8 fa f7 ff ff       	call   f0100eb2 <page_free>
	page_free(pp2);
f01016b8:	83 c4 04             	add    $0x4,%esp
f01016bb:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016be:	e8 ef f7 ff ff       	call   f0100eb2 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016c3:	a1 40 e2 22 f0       	mov    0xf022e240,%eax
f01016c8:	83 c4 10             	add    $0x10,%esp
f01016cb:	eb 05                	jmp    f01016d2 <mem_init+0x4f0>
		--nfree;
f01016cd:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016d0:	8b 00                	mov    (%eax),%eax
f01016d2:	85 c0                	test   %eax,%eax
f01016d4:	75 f7                	jne    f01016cd <mem_init+0x4eb>
		--nfree;
	assert(nfree == 0);
f01016d6:	85 db                	test   %ebx,%ebx
f01016d8:	74 19                	je     f01016f3 <mem_init+0x511>
f01016da:	68 94 6e 10 f0       	push   $0xf0106e94
f01016df:	68 ab 6c 10 f0       	push   $0xf0106cab
f01016e4:	68 5d 03 00 00       	push   $0x35d
f01016e9:	68 85 6c 10 f0       	push   $0xf0106c85
f01016ee:	e8 4d e9 ff ff       	call   f0100040 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f01016f3:	83 ec 0c             	sub    $0xc,%esp
f01016f6:	68 c8 64 10 f0       	push   $0xf01064c8
f01016fb:	e8 a1 1e 00 00       	call   f01035a1 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101700:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101707:	e8 36 f7 ff ff       	call   f0100e42 <page_alloc>
f010170c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010170f:	83 c4 10             	add    $0x10,%esp
f0101712:	85 c0                	test   %eax,%eax
f0101714:	75 19                	jne    f010172f <mem_init+0x54d>
f0101716:	68 a2 6d 10 f0       	push   $0xf0106da2
f010171b:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101720:	68 c3 03 00 00       	push   $0x3c3
f0101725:	68 85 6c 10 f0       	push   $0xf0106c85
f010172a:	e8 11 e9 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f010172f:	83 ec 0c             	sub    $0xc,%esp
f0101732:	6a 00                	push   $0x0
f0101734:	e8 09 f7 ff ff       	call   f0100e42 <page_alloc>
f0101739:	89 c3                	mov    %eax,%ebx
f010173b:	83 c4 10             	add    $0x10,%esp
f010173e:	85 c0                	test   %eax,%eax
f0101740:	75 19                	jne    f010175b <mem_init+0x579>
f0101742:	68 b8 6d 10 f0       	push   $0xf0106db8
f0101747:	68 ab 6c 10 f0       	push   $0xf0106cab
f010174c:	68 c4 03 00 00       	push   $0x3c4
f0101751:	68 85 6c 10 f0       	push   $0xf0106c85
f0101756:	e8 e5 e8 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f010175b:	83 ec 0c             	sub    $0xc,%esp
f010175e:	6a 00                	push   $0x0
f0101760:	e8 dd f6 ff ff       	call   f0100e42 <page_alloc>
f0101765:	89 c6                	mov    %eax,%esi
f0101767:	83 c4 10             	add    $0x10,%esp
f010176a:	85 c0                	test   %eax,%eax
f010176c:	75 19                	jne    f0101787 <mem_init+0x5a5>
f010176e:	68 ce 6d 10 f0       	push   $0xf0106dce
f0101773:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101778:	68 c5 03 00 00       	push   $0x3c5
f010177d:	68 85 6c 10 f0       	push   $0xf0106c85
f0101782:	e8 b9 e8 ff ff       	call   f0100040 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101787:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010178a:	75 19                	jne    f01017a5 <mem_init+0x5c3>
f010178c:	68 e4 6d 10 f0       	push   $0xf0106de4
f0101791:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101796:	68 c8 03 00 00       	push   $0x3c8
f010179b:	68 85 6c 10 f0       	push   $0xf0106c85
f01017a0:	e8 9b e8 ff ff       	call   f0100040 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017a5:	39 c3                	cmp    %eax,%ebx
f01017a7:	74 05                	je     f01017ae <mem_init+0x5cc>
f01017a9:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01017ac:	75 19                	jne    f01017c7 <mem_init+0x5e5>
f01017ae:	68 a8 64 10 f0       	push   $0xf01064a8
f01017b3:	68 ab 6c 10 f0       	push   $0xf0106cab
f01017b8:	68 c9 03 00 00       	push   $0x3c9
f01017bd:	68 85 6c 10 f0       	push   $0xf0106c85
f01017c2:	e8 79 e8 ff ff       	call   f0100040 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017c7:	a1 40 e2 22 f0       	mov    0xf022e240,%eax
f01017cc:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01017cf:	c7 05 40 e2 22 f0 00 	movl   $0x0,0xf022e240
f01017d6:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017d9:	83 ec 0c             	sub    $0xc,%esp
f01017dc:	6a 00                	push   $0x0
f01017de:	e8 5f f6 ff ff       	call   f0100e42 <page_alloc>
f01017e3:	83 c4 10             	add    $0x10,%esp
f01017e6:	85 c0                	test   %eax,%eax
f01017e8:	74 19                	je     f0101803 <mem_init+0x621>
f01017ea:	68 4d 6e 10 f0       	push   $0xf0106e4d
f01017ef:	68 ab 6c 10 f0       	push   $0xf0106cab
f01017f4:	68 d0 03 00 00       	push   $0x3d0
f01017f9:	68 85 6c 10 f0       	push   $0xf0106c85
f01017fe:	e8 3d e8 ff ff       	call   f0100040 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101803:	83 ec 04             	sub    $0x4,%esp
f0101806:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101809:	50                   	push   %eax
f010180a:	6a 00                	push   $0x0
f010180c:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101812:	e8 17 f8 ff ff       	call   f010102e <page_lookup>
f0101817:	83 c4 10             	add    $0x10,%esp
f010181a:	85 c0                	test   %eax,%eax
f010181c:	74 19                	je     f0101837 <mem_init+0x655>
f010181e:	68 e8 64 10 f0       	push   $0xf01064e8
f0101823:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101828:	68 d3 03 00 00       	push   $0x3d3
f010182d:	68 85 6c 10 f0       	push   $0xf0106c85
f0101832:	e8 09 e8 ff ff       	call   f0100040 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101837:	6a 02                	push   $0x2
f0101839:	6a 00                	push   $0x0
f010183b:	53                   	push   %ebx
f010183c:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101842:	e8 d1 f8 ff ff       	call   f0101118 <page_insert>
f0101847:	83 c4 10             	add    $0x10,%esp
f010184a:	85 c0                	test   %eax,%eax
f010184c:	78 19                	js     f0101867 <mem_init+0x685>
f010184e:	68 20 65 10 f0       	push   $0xf0106520
f0101853:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101858:	68 d6 03 00 00       	push   $0x3d6
f010185d:	68 85 6c 10 f0       	push   $0xf0106c85
f0101862:	e8 d9 e7 ff ff       	call   f0100040 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101867:	83 ec 0c             	sub    $0xc,%esp
f010186a:	ff 75 d4             	pushl  -0x2c(%ebp)
f010186d:	e8 40 f6 ff ff       	call   f0100eb2 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101872:	6a 02                	push   $0x2
f0101874:	6a 00                	push   $0x0
f0101876:	53                   	push   %ebx
f0101877:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f010187d:	e8 96 f8 ff ff       	call   f0101118 <page_insert>
f0101882:	83 c4 20             	add    $0x20,%esp
f0101885:	85 c0                	test   %eax,%eax
f0101887:	74 19                	je     f01018a2 <mem_init+0x6c0>
f0101889:	68 50 65 10 f0       	push   $0xf0106550
f010188e:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101893:	68 da 03 00 00       	push   $0x3da
f0101898:	68 85 6c 10 f0       	push   $0xf0106c85
f010189d:	e8 9e e7 ff ff       	call   f0100040 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018a2:	8b 3d 8c ee 22 f0    	mov    0xf022ee8c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018a8:	a1 90 ee 22 f0       	mov    0xf022ee90,%eax
f01018ad:	89 c1                	mov    %eax,%ecx
f01018af:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018b2:	8b 17                	mov    (%edi),%edx
f01018b4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018ba:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018bd:	29 c8                	sub    %ecx,%eax
f01018bf:	c1 f8 03             	sar    $0x3,%eax
f01018c2:	c1 e0 0c             	shl    $0xc,%eax
f01018c5:	39 c2                	cmp    %eax,%edx
f01018c7:	74 19                	je     f01018e2 <mem_init+0x700>
f01018c9:	68 80 65 10 f0       	push   $0xf0106580
f01018ce:	68 ab 6c 10 f0       	push   $0xf0106cab
f01018d3:	68 db 03 00 00       	push   $0x3db
f01018d8:	68 85 6c 10 f0       	push   $0xf0106c85
f01018dd:	e8 5e e7 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01018e2:	ba 00 00 00 00       	mov    $0x0,%edx
f01018e7:	89 f8                	mov    %edi,%eax
f01018e9:	e8 51 f1 ff ff       	call   f0100a3f <check_va2pa>
f01018ee:	89 da                	mov    %ebx,%edx
f01018f0:	2b 55 cc             	sub    -0x34(%ebp),%edx
f01018f3:	c1 fa 03             	sar    $0x3,%edx
f01018f6:	c1 e2 0c             	shl    $0xc,%edx
f01018f9:	39 d0                	cmp    %edx,%eax
f01018fb:	74 19                	je     f0101916 <mem_init+0x734>
f01018fd:	68 a8 65 10 f0       	push   $0xf01065a8
f0101902:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101907:	68 dc 03 00 00       	push   $0x3dc
f010190c:	68 85 6c 10 f0       	push   $0xf0106c85
f0101911:	e8 2a e7 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101916:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010191b:	74 19                	je     f0101936 <mem_init+0x754>
f010191d:	68 9f 6e 10 f0       	push   $0xf0106e9f
f0101922:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101927:	68 dd 03 00 00       	push   $0x3dd
f010192c:	68 85 6c 10 f0       	push   $0xf0106c85
f0101931:	e8 0a e7 ff ff       	call   f0100040 <_panic>
	assert(pp0->pp_ref == 1);
f0101936:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101939:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010193e:	74 19                	je     f0101959 <mem_init+0x777>
f0101940:	68 b0 6e 10 f0       	push   $0xf0106eb0
f0101945:	68 ab 6c 10 f0       	push   $0xf0106cab
f010194a:	68 de 03 00 00       	push   $0x3de
f010194f:	68 85 6c 10 f0       	push   $0xf0106c85
f0101954:	e8 e7 e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101959:	6a 02                	push   $0x2
f010195b:	68 00 10 00 00       	push   $0x1000
f0101960:	56                   	push   %esi
f0101961:	57                   	push   %edi
f0101962:	e8 b1 f7 ff ff       	call   f0101118 <page_insert>
f0101967:	83 c4 10             	add    $0x10,%esp
f010196a:	85 c0                	test   %eax,%eax
f010196c:	74 19                	je     f0101987 <mem_init+0x7a5>
f010196e:	68 d8 65 10 f0       	push   $0xf01065d8
f0101973:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101978:	68 e1 03 00 00       	push   $0x3e1
f010197d:	68 85 6c 10 f0       	push   $0xf0106c85
f0101982:	e8 b9 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101987:	ba 00 10 00 00       	mov    $0x1000,%edx
f010198c:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f0101991:	e8 a9 f0 ff ff       	call   f0100a3f <check_va2pa>
f0101996:	89 f2                	mov    %esi,%edx
f0101998:	2b 15 90 ee 22 f0    	sub    0xf022ee90,%edx
f010199e:	c1 fa 03             	sar    $0x3,%edx
f01019a1:	c1 e2 0c             	shl    $0xc,%edx
f01019a4:	39 d0                	cmp    %edx,%eax
f01019a6:	74 19                	je     f01019c1 <mem_init+0x7df>
f01019a8:	68 14 66 10 f0       	push   $0xf0106614
f01019ad:	68 ab 6c 10 f0       	push   $0xf0106cab
f01019b2:	68 e2 03 00 00       	push   $0x3e2
f01019b7:	68 85 6c 10 f0       	push   $0xf0106c85
f01019bc:	e8 7f e6 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f01019c1:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019c6:	74 19                	je     f01019e1 <mem_init+0x7ff>
f01019c8:	68 c1 6e 10 f0       	push   $0xf0106ec1
f01019cd:	68 ab 6c 10 f0       	push   $0xf0106cab
f01019d2:	68 e3 03 00 00       	push   $0x3e3
f01019d7:	68 85 6c 10 f0       	push   $0xf0106c85
f01019dc:	e8 5f e6 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01019e1:	83 ec 0c             	sub    $0xc,%esp
f01019e4:	6a 00                	push   $0x0
f01019e6:	e8 57 f4 ff ff       	call   f0100e42 <page_alloc>
f01019eb:	83 c4 10             	add    $0x10,%esp
f01019ee:	85 c0                	test   %eax,%eax
f01019f0:	74 19                	je     f0101a0b <mem_init+0x829>
f01019f2:	68 4d 6e 10 f0       	push   $0xf0106e4d
f01019f7:	68 ab 6c 10 f0       	push   $0xf0106cab
f01019fc:	68 e6 03 00 00       	push   $0x3e6
f0101a01:	68 85 6c 10 f0       	push   $0xf0106c85
f0101a06:	e8 35 e6 ff ff       	call   f0100040 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a0b:	6a 02                	push   $0x2
f0101a0d:	68 00 10 00 00       	push   $0x1000
f0101a12:	56                   	push   %esi
f0101a13:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101a19:	e8 fa f6 ff ff       	call   f0101118 <page_insert>
f0101a1e:	83 c4 10             	add    $0x10,%esp
f0101a21:	85 c0                	test   %eax,%eax
f0101a23:	74 19                	je     f0101a3e <mem_init+0x85c>
f0101a25:	68 d8 65 10 f0       	push   $0xf01065d8
f0101a2a:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101a2f:	68 e9 03 00 00       	push   $0x3e9
f0101a34:	68 85 6c 10 f0       	push   $0xf0106c85
f0101a39:	e8 02 e6 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a3e:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a43:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f0101a48:	e8 f2 ef ff ff       	call   f0100a3f <check_va2pa>
f0101a4d:	89 f2                	mov    %esi,%edx
f0101a4f:	2b 15 90 ee 22 f0    	sub    0xf022ee90,%edx
f0101a55:	c1 fa 03             	sar    $0x3,%edx
f0101a58:	c1 e2 0c             	shl    $0xc,%edx
f0101a5b:	39 d0                	cmp    %edx,%eax
f0101a5d:	74 19                	je     f0101a78 <mem_init+0x896>
f0101a5f:	68 14 66 10 f0       	push   $0xf0106614
f0101a64:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101a69:	68 ea 03 00 00       	push   $0x3ea
f0101a6e:	68 85 6c 10 f0       	push   $0xf0106c85
f0101a73:	e8 c8 e5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101a78:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a7d:	74 19                	je     f0101a98 <mem_init+0x8b6>
f0101a7f:	68 c1 6e 10 f0       	push   $0xf0106ec1
f0101a84:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101a89:	68 eb 03 00 00       	push   $0x3eb
f0101a8e:	68 85 6c 10 f0       	push   $0xf0106c85
f0101a93:	e8 a8 e5 ff ff       	call   f0100040 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101a98:	83 ec 0c             	sub    $0xc,%esp
f0101a9b:	6a 00                	push   $0x0
f0101a9d:	e8 a0 f3 ff ff       	call   f0100e42 <page_alloc>
f0101aa2:	83 c4 10             	add    $0x10,%esp
f0101aa5:	85 c0                	test   %eax,%eax
f0101aa7:	74 19                	je     f0101ac2 <mem_init+0x8e0>
f0101aa9:	68 4d 6e 10 f0       	push   $0xf0106e4d
f0101aae:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101ab3:	68 ef 03 00 00       	push   $0x3ef
f0101ab8:	68 85 6c 10 f0       	push   $0xf0106c85
f0101abd:	e8 7e e5 ff ff       	call   f0100040 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ac2:	8b 15 8c ee 22 f0    	mov    0xf022ee8c,%edx
f0101ac8:	8b 02                	mov    (%edx),%eax
f0101aca:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101acf:	89 c1                	mov    %eax,%ecx
f0101ad1:	c1 e9 0c             	shr    $0xc,%ecx
f0101ad4:	3b 0d 88 ee 22 f0    	cmp    0xf022ee88,%ecx
f0101ada:	72 15                	jb     f0101af1 <mem_init+0x90f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101adc:	50                   	push   %eax
f0101add:	68 44 5e 10 f0       	push   $0xf0105e44
f0101ae2:	68 f2 03 00 00       	push   $0x3f2
f0101ae7:	68 85 6c 10 f0       	push   $0xf0106c85
f0101aec:	e8 4f e5 ff ff       	call   f0100040 <_panic>
f0101af1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101af6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101af9:	83 ec 04             	sub    $0x4,%esp
f0101afc:	6a 00                	push   $0x0
f0101afe:	68 00 10 00 00       	push   $0x1000
f0101b03:	52                   	push   %edx
f0101b04:	e8 43 f4 ff ff       	call   f0100f4c <pgdir_walk>
f0101b09:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0101b0c:	8d 51 04             	lea    0x4(%ecx),%edx
f0101b0f:	83 c4 10             	add    $0x10,%esp
f0101b12:	39 d0                	cmp    %edx,%eax
f0101b14:	74 19                	je     f0101b2f <mem_init+0x94d>
f0101b16:	68 44 66 10 f0       	push   $0xf0106644
f0101b1b:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101b20:	68 f3 03 00 00       	push   $0x3f3
f0101b25:	68 85 6c 10 f0       	push   $0xf0106c85
f0101b2a:	e8 11 e5 ff ff       	call   f0100040 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b2f:	6a 06                	push   $0x6
f0101b31:	68 00 10 00 00       	push   $0x1000
f0101b36:	56                   	push   %esi
f0101b37:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101b3d:	e8 d6 f5 ff ff       	call   f0101118 <page_insert>
f0101b42:	83 c4 10             	add    $0x10,%esp
f0101b45:	85 c0                	test   %eax,%eax
f0101b47:	74 19                	je     f0101b62 <mem_init+0x980>
f0101b49:	68 84 66 10 f0       	push   $0xf0106684
f0101b4e:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101b53:	68 f6 03 00 00       	push   $0x3f6
f0101b58:	68 85 6c 10 f0       	push   $0xf0106c85
f0101b5d:	e8 de e4 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b62:	8b 3d 8c ee 22 f0    	mov    0xf022ee8c,%edi
f0101b68:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b6d:	89 f8                	mov    %edi,%eax
f0101b6f:	e8 cb ee ff ff       	call   f0100a3f <check_va2pa>
f0101b74:	89 f2                	mov    %esi,%edx
f0101b76:	2b 15 90 ee 22 f0    	sub    0xf022ee90,%edx
f0101b7c:	c1 fa 03             	sar    $0x3,%edx
f0101b7f:	c1 e2 0c             	shl    $0xc,%edx
f0101b82:	39 d0                	cmp    %edx,%eax
f0101b84:	74 19                	je     f0101b9f <mem_init+0x9bd>
f0101b86:	68 14 66 10 f0       	push   $0xf0106614
f0101b8b:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101b90:	68 f7 03 00 00       	push   $0x3f7
f0101b95:	68 85 6c 10 f0       	push   $0xf0106c85
f0101b9a:	e8 a1 e4 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0101b9f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101ba4:	74 19                	je     f0101bbf <mem_init+0x9dd>
f0101ba6:	68 c1 6e 10 f0       	push   $0xf0106ec1
f0101bab:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101bb0:	68 f8 03 00 00       	push   $0x3f8
f0101bb5:	68 85 6c 10 f0       	push   $0xf0106c85
f0101bba:	e8 81 e4 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bbf:	83 ec 04             	sub    $0x4,%esp
f0101bc2:	6a 00                	push   $0x0
f0101bc4:	68 00 10 00 00       	push   $0x1000
f0101bc9:	57                   	push   %edi
f0101bca:	e8 7d f3 ff ff       	call   f0100f4c <pgdir_walk>
f0101bcf:	83 c4 10             	add    $0x10,%esp
f0101bd2:	f6 00 04             	testb  $0x4,(%eax)
f0101bd5:	75 19                	jne    f0101bf0 <mem_init+0xa0e>
f0101bd7:	68 c4 66 10 f0       	push   $0xf01066c4
f0101bdc:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101be1:	68 f9 03 00 00       	push   $0x3f9
f0101be6:	68 85 6c 10 f0       	push   $0xf0106c85
f0101beb:	e8 50 e4 ff ff       	call   f0100040 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101bf0:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f0101bf5:	f6 00 04             	testb  $0x4,(%eax)
f0101bf8:	75 19                	jne    f0101c13 <mem_init+0xa31>
f0101bfa:	68 d2 6e 10 f0       	push   $0xf0106ed2
f0101bff:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101c04:	68 fa 03 00 00       	push   $0x3fa
f0101c09:	68 85 6c 10 f0       	push   $0xf0106c85
f0101c0e:	e8 2d e4 ff ff       	call   f0100040 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c13:	6a 02                	push   $0x2
f0101c15:	68 00 10 00 00       	push   $0x1000
f0101c1a:	56                   	push   %esi
f0101c1b:	50                   	push   %eax
f0101c1c:	e8 f7 f4 ff ff       	call   f0101118 <page_insert>
f0101c21:	83 c4 10             	add    $0x10,%esp
f0101c24:	85 c0                	test   %eax,%eax
f0101c26:	74 19                	je     f0101c41 <mem_init+0xa5f>
f0101c28:	68 d8 65 10 f0       	push   $0xf01065d8
f0101c2d:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101c32:	68 fd 03 00 00       	push   $0x3fd
f0101c37:	68 85 6c 10 f0       	push   $0xf0106c85
f0101c3c:	e8 ff e3 ff ff       	call   f0100040 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c41:	83 ec 04             	sub    $0x4,%esp
f0101c44:	6a 00                	push   $0x0
f0101c46:	68 00 10 00 00       	push   $0x1000
f0101c4b:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101c51:	e8 f6 f2 ff ff       	call   f0100f4c <pgdir_walk>
f0101c56:	83 c4 10             	add    $0x10,%esp
f0101c59:	f6 00 02             	testb  $0x2,(%eax)
f0101c5c:	75 19                	jne    f0101c77 <mem_init+0xa95>
f0101c5e:	68 f8 66 10 f0       	push   $0xf01066f8
f0101c63:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101c68:	68 fe 03 00 00       	push   $0x3fe
f0101c6d:	68 85 6c 10 f0       	push   $0xf0106c85
f0101c72:	e8 c9 e3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c77:	83 ec 04             	sub    $0x4,%esp
f0101c7a:	6a 00                	push   $0x0
f0101c7c:	68 00 10 00 00       	push   $0x1000
f0101c81:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101c87:	e8 c0 f2 ff ff       	call   f0100f4c <pgdir_walk>
f0101c8c:	83 c4 10             	add    $0x10,%esp
f0101c8f:	f6 00 04             	testb  $0x4,(%eax)
f0101c92:	74 19                	je     f0101cad <mem_init+0xacb>
f0101c94:	68 2c 67 10 f0       	push   $0xf010672c
f0101c99:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101c9e:	68 ff 03 00 00       	push   $0x3ff
f0101ca3:	68 85 6c 10 f0       	push   $0xf0106c85
f0101ca8:	e8 93 e3 ff ff       	call   f0100040 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101cad:	6a 02                	push   $0x2
f0101caf:	68 00 00 40 00       	push   $0x400000
f0101cb4:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cb7:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101cbd:	e8 56 f4 ff ff       	call   f0101118 <page_insert>
f0101cc2:	83 c4 10             	add    $0x10,%esp
f0101cc5:	85 c0                	test   %eax,%eax
f0101cc7:	78 19                	js     f0101ce2 <mem_init+0xb00>
f0101cc9:	68 64 67 10 f0       	push   $0xf0106764
f0101cce:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101cd3:	68 02 04 00 00       	push   $0x402
f0101cd8:	68 85 6c 10 f0       	push   $0xf0106c85
f0101cdd:	e8 5e e3 ff ff       	call   f0100040 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101ce2:	6a 02                	push   $0x2
f0101ce4:	68 00 10 00 00       	push   $0x1000
f0101ce9:	53                   	push   %ebx
f0101cea:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101cf0:	e8 23 f4 ff ff       	call   f0101118 <page_insert>
f0101cf5:	83 c4 10             	add    $0x10,%esp
f0101cf8:	85 c0                	test   %eax,%eax
f0101cfa:	74 19                	je     f0101d15 <mem_init+0xb33>
f0101cfc:	68 9c 67 10 f0       	push   $0xf010679c
f0101d01:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101d06:	68 05 04 00 00       	push   $0x405
f0101d0b:	68 85 6c 10 f0       	push   $0xf0106c85
f0101d10:	e8 2b e3 ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d15:	83 ec 04             	sub    $0x4,%esp
f0101d18:	6a 00                	push   $0x0
f0101d1a:	68 00 10 00 00       	push   $0x1000
f0101d1f:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101d25:	e8 22 f2 ff ff       	call   f0100f4c <pgdir_walk>
f0101d2a:	83 c4 10             	add    $0x10,%esp
f0101d2d:	f6 00 04             	testb  $0x4,(%eax)
f0101d30:	74 19                	je     f0101d4b <mem_init+0xb69>
f0101d32:	68 2c 67 10 f0       	push   $0xf010672c
f0101d37:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101d3c:	68 06 04 00 00       	push   $0x406
f0101d41:	68 85 6c 10 f0       	push   $0xf0106c85
f0101d46:	e8 f5 e2 ff ff       	call   f0100040 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d4b:	8b 3d 8c ee 22 f0    	mov    0xf022ee8c,%edi
f0101d51:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d56:	89 f8                	mov    %edi,%eax
f0101d58:	e8 e2 ec ff ff       	call   f0100a3f <check_va2pa>
f0101d5d:	89 c1                	mov    %eax,%ecx
f0101d5f:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d62:	89 d8                	mov    %ebx,%eax
f0101d64:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f0101d6a:	c1 f8 03             	sar    $0x3,%eax
f0101d6d:	c1 e0 0c             	shl    $0xc,%eax
f0101d70:	39 c1                	cmp    %eax,%ecx
f0101d72:	74 19                	je     f0101d8d <mem_init+0xbab>
f0101d74:	68 d8 67 10 f0       	push   $0xf01067d8
f0101d79:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101d7e:	68 09 04 00 00       	push   $0x409
f0101d83:	68 85 6c 10 f0       	push   $0xf0106c85
f0101d88:	e8 b3 e2 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d8d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101d92:	89 f8                	mov    %edi,%eax
f0101d94:	e8 a6 ec ff ff       	call   f0100a3f <check_va2pa>
f0101d99:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101d9c:	74 19                	je     f0101db7 <mem_init+0xbd5>
f0101d9e:	68 04 68 10 f0       	push   $0xf0106804
f0101da3:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101da8:	68 0a 04 00 00       	push   $0x40a
f0101dad:	68 85 6c 10 f0       	push   $0xf0106c85
f0101db2:	e8 89 e2 ff ff       	call   f0100040 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101db7:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101dbc:	74 19                	je     f0101dd7 <mem_init+0xbf5>
f0101dbe:	68 e8 6e 10 f0       	push   $0xf0106ee8
f0101dc3:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101dc8:	68 0c 04 00 00       	push   $0x40c
f0101dcd:	68 85 6c 10 f0       	push   $0xf0106c85
f0101dd2:	e8 69 e2 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101dd7:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ddc:	74 19                	je     f0101df7 <mem_init+0xc15>
f0101dde:	68 f9 6e 10 f0       	push   $0xf0106ef9
f0101de3:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101de8:	68 0d 04 00 00       	push   $0x40d
f0101ded:	68 85 6c 10 f0       	push   $0xf0106c85
f0101df2:	e8 49 e2 ff ff       	call   f0100040 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101df7:	83 ec 0c             	sub    $0xc,%esp
f0101dfa:	6a 00                	push   $0x0
f0101dfc:	e8 41 f0 ff ff       	call   f0100e42 <page_alloc>
f0101e01:	83 c4 10             	add    $0x10,%esp
f0101e04:	85 c0                	test   %eax,%eax
f0101e06:	74 04                	je     f0101e0c <mem_init+0xc2a>
f0101e08:	39 c6                	cmp    %eax,%esi
f0101e0a:	74 19                	je     f0101e25 <mem_init+0xc43>
f0101e0c:	68 34 68 10 f0       	push   $0xf0106834
f0101e11:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101e16:	68 10 04 00 00       	push   $0x410
f0101e1b:	68 85 6c 10 f0       	push   $0xf0106c85
f0101e20:	e8 1b e2 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e25:	83 ec 08             	sub    $0x8,%esp
f0101e28:	6a 00                	push   $0x0
f0101e2a:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101e30:	e8 93 f2 ff ff       	call   f01010c8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e35:	8b 3d 8c ee 22 f0    	mov    0xf022ee8c,%edi
f0101e3b:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e40:	89 f8                	mov    %edi,%eax
f0101e42:	e8 f8 eb ff ff       	call   f0100a3f <check_va2pa>
f0101e47:	83 c4 10             	add    $0x10,%esp
f0101e4a:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e4d:	74 19                	je     f0101e68 <mem_init+0xc86>
f0101e4f:	68 58 68 10 f0       	push   $0xf0106858
f0101e54:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101e59:	68 14 04 00 00       	push   $0x414
f0101e5e:	68 85 6c 10 f0       	push   $0xf0106c85
f0101e63:	e8 d8 e1 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e68:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e6d:	89 f8                	mov    %edi,%eax
f0101e6f:	e8 cb eb ff ff       	call   f0100a3f <check_va2pa>
f0101e74:	89 da                	mov    %ebx,%edx
f0101e76:	2b 15 90 ee 22 f0    	sub    0xf022ee90,%edx
f0101e7c:	c1 fa 03             	sar    $0x3,%edx
f0101e7f:	c1 e2 0c             	shl    $0xc,%edx
f0101e82:	39 d0                	cmp    %edx,%eax
f0101e84:	74 19                	je     f0101e9f <mem_init+0xcbd>
f0101e86:	68 04 68 10 f0       	push   $0xf0106804
f0101e8b:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101e90:	68 15 04 00 00       	push   $0x415
f0101e95:	68 85 6c 10 f0       	push   $0xf0106c85
f0101e9a:	e8 a1 e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 1);
f0101e9f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101ea4:	74 19                	je     f0101ebf <mem_init+0xcdd>
f0101ea6:	68 9f 6e 10 f0       	push   $0xf0106e9f
f0101eab:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101eb0:	68 16 04 00 00       	push   $0x416
f0101eb5:	68 85 6c 10 f0       	push   $0xf0106c85
f0101eba:	e8 81 e1 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101ebf:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ec4:	74 19                	je     f0101edf <mem_init+0xcfd>
f0101ec6:	68 f9 6e 10 f0       	push   $0xf0106ef9
f0101ecb:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101ed0:	68 17 04 00 00       	push   $0x417
f0101ed5:	68 85 6c 10 f0       	push   $0xf0106c85
f0101eda:	e8 61 e1 ff ff       	call   f0100040 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101edf:	6a 00                	push   $0x0
f0101ee1:	68 00 10 00 00       	push   $0x1000
f0101ee6:	53                   	push   %ebx
f0101ee7:	57                   	push   %edi
f0101ee8:	e8 2b f2 ff ff       	call   f0101118 <page_insert>
f0101eed:	83 c4 10             	add    $0x10,%esp
f0101ef0:	85 c0                	test   %eax,%eax
f0101ef2:	74 19                	je     f0101f0d <mem_init+0xd2b>
f0101ef4:	68 7c 68 10 f0       	push   $0xf010687c
f0101ef9:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101efe:	68 1a 04 00 00       	push   $0x41a
f0101f03:	68 85 6c 10 f0       	push   $0xf0106c85
f0101f08:	e8 33 e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref);
f0101f0d:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f12:	75 19                	jne    f0101f2d <mem_init+0xd4b>
f0101f14:	68 0a 6f 10 f0       	push   $0xf0106f0a
f0101f19:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101f1e:	68 1b 04 00 00       	push   $0x41b
f0101f23:	68 85 6c 10 f0       	push   $0xf0106c85
f0101f28:	e8 13 e1 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_link == NULL);
f0101f2d:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f30:	74 19                	je     f0101f4b <mem_init+0xd69>
f0101f32:	68 16 6f 10 f0       	push   $0xf0106f16
f0101f37:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101f3c:	68 1c 04 00 00       	push   $0x41c
f0101f41:	68 85 6c 10 f0       	push   $0xf0106c85
f0101f46:	e8 f5 e0 ff ff       	call   f0100040 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f4b:	83 ec 08             	sub    $0x8,%esp
f0101f4e:	68 00 10 00 00       	push   $0x1000
f0101f53:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0101f59:	e8 6a f1 ff ff       	call   f01010c8 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f5e:	8b 3d 8c ee 22 f0    	mov    0xf022ee8c,%edi
f0101f64:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f69:	89 f8                	mov    %edi,%eax
f0101f6b:	e8 cf ea ff ff       	call   f0100a3f <check_va2pa>
f0101f70:	83 c4 10             	add    $0x10,%esp
f0101f73:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f76:	74 19                	je     f0101f91 <mem_init+0xdaf>
f0101f78:	68 58 68 10 f0       	push   $0xf0106858
f0101f7d:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101f82:	68 20 04 00 00       	push   $0x420
f0101f87:	68 85 6c 10 f0       	push   $0xf0106c85
f0101f8c:	e8 af e0 ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101f91:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101f96:	89 f8                	mov    %edi,%eax
f0101f98:	e8 a2 ea ff ff       	call   f0100a3f <check_va2pa>
f0101f9d:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101fa0:	74 19                	je     f0101fbb <mem_init+0xdd9>
f0101fa2:	68 b4 68 10 f0       	push   $0xf01068b4
f0101fa7:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101fac:	68 21 04 00 00       	push   $0x421
f0101fb1:	68 85 6c 10 f0       	push   $0xf0106c85
f0101fb6:	e8 85 e0 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0101fbb:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101fc0:	74 19                	je     f0101fdb <mem_init+0xdf9>
f0101fc2:	68 2b 6f 10 f0       	push   $0xf0106f2b
f0101fc7:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101fcc:	68 22 04 00 00       	push   $0x422
f0101fd1:	68 85 6c 10 f0       	push   $0xf0106c85
f0101fd6:	e8 65 e0 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 0);
f0101fdb:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fe0:	74 19                	je     f0101ffb <mem_init+0xe19>
f0101fe2:	68 f9 6e 10 f0       	push   $0xf0106ef9
f0101fe7:	68 ab 6c 10 f0       	push   $0xf0106cab
f0101fec:	68 23 04 00 00       	push   $0x423
f0101ff1:	68 85 6c 10 f0       	push   $0xf0106c85
f0101ff6:	e8 45 e0 ff ff       	call   f0100040 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0101ffb:	83 ec 0c             	sub    $0xc,%esp
f0101ffe:	6a 00                	push   $0x0
f0102000:	e8 3d ee ff ff       	call   f0100e42 <page_alloc>
f0102005:	83 c4 10             	add    $0x10,%esp
f0102008:	39 c3                	cmp    %eax,%ebx
f010200a:	75 04                	jne    f0102010 <mem_init+0xe2e>
f010200c:	85 c0                	test   %eax,%eax
f010200e:	75 19                	jne    f0102029 <mem_init+0xe47>
f0102010:	68 dc 68 10 f0       	push   $0xf01068dc
f0102015:	68 ab 6c 10 f0       	push   $0xf0106cab
f010201a:	68 26 04 00 00       	push   $0x426
f010201f:	68 85 6c 10 f0       	push   $0xf0106c85
f0102024:	e8 17 e0 ff ff       	call   f0100040 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102029:	83 ec 0c             	sub    $0xc,%esp
f010202c:	6a 00                	push   $0x0
f010202e:	e8 0f ee ff ff       	call   f0100e42 <page_alloc>
f0102033:	83 c4 10             	add    $0x10,%esp
f0102036:	85 c0                	test   %eax,%eax
f0102038:	74 19                	je     f0102053 <mem_init+0xe71>
f010203a:	68 4d 6e 10 f0       	push   $0xf0106e4d
f010203f:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102044:	68 29 04 00 00       	push   $0x429
f0102049:	68 85 6c 10 f0       	push   $0xf0106c85
f010204e:	e8 ed df ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102053:	8b 0d 8c ee 22 f0    	mov    0xf022ee8c,%ecx
f0102059:	8b 11                	mov    (%ecx),%edx
f010205b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102061:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102064:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f010206a:	c1 f8 03             	sar    $0x3,%eax
f010206d:	c1 e0 0c             	shl    $0xc,%eax
f0102070:	39 c2                	cmp    %eax,%edx
f0102072:	74 19                	je     f010208d <mem_init+0xeab>
f0102074:	68 80 65 10 f0       	push   $0xf0106580
f0102079:	68 ab 6c 10 f0       	push   $0xf0106cab
f010207e:	68 2c 04 00 00       	push   $0x42c
f0102083:	68 85 6c 10 f0       	push   $0xf0106c85
f0102088:	e8 b3 df ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f010208d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102093:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102096:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010209b:	74 19                	je     f01020b6 <mem_init+0xed4>
f010209d:	68 b0 6e 10 f0       	push   $0xf0106eb0
f01020a2:	68 ab 6c 10 f0       	push   $0xf0106cab
f01020a7:	68 2e 04 00 00       	push   $0x42e
f01020ac:	68 85 6c 10 f0       	push   $0xf0106c85
f01020b1:	e8 8a df ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f01020b6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020b9:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01020bf:	83 ec 0c             	sub    $0xc,%esp
f01020c2:	50                   	push   %eax
f01020c3:	e8 ea ed ff ff       	call   f0100eb2 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01020c8:	83 c4 0c             	add    $0xc,%esp
f01020cb:	6a 01                	push   $0x1
f01020cd:	68 00 10 40 00       	push   $0x401000
f01020d2:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f01020d8:	e8 6f ee ff ff       	call   f0100f4c <pgdir_walk>
f01020dd:	89 c7                	mov    %eax,%edi
f01020df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01020e2:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f01020e7:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020ea:	8b 40 04             	mov    0x4(%eax),%eax
f01020ed:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01020f2:	8b 0d 88 ee 22 f0    	mov    0xf022ee88,%ecx
f01020f8:	89 c2                	mov    %eax,%edx
f01020fa:	c1 ea 0c             	shr    $0xc,%edx
f01020fd:	83 c4 10             	add    $0x10,%esp
f0102100:	39 ca                	cmp    %ecx,%edx
f0102102:	72 15                	jb     f0102119 <mem_init+0xf37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102104:	50                   	push   %eax
f0102105:	68 44 5e 10 f0       	push   $0xf0105e44
f010210a:	68 35 04 00 00       	push   $0x435
f010210f:	68 85 6c 10 f0       	push   $0xf0106c85
f0102114:	e8 27 df ff ff       	call   f0100040 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102119:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010211e:	39 c7                	cmp    %eax,%edi
f0102120:	74 19                	je     f010213b <mem_init+0xf59>
f0102122:	68 3c 6f 10 f0       	push   $0xf0106f3c
f0102127:	68 ab 6c 10 f0       	push   $0xf0106cab
f010212c:	68 36 04 00 00       	push   $0x436
f0102131:	68 85 6c 10 f0       	push   $0xf0106c85
f0102136:	e8 05 df ff ff       	call   f0100040 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010213b:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010213e:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102145:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102148:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010214e:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f0102154:	c1 f8 03             	sar    $0x3,%eax
f0102157:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010215a:	89 c2                	mov    %eax,%edx
f010215c:	c1 ea 0c             	shr    $0xc,%edx
f010215f:	39 d1                	cmp    %edx,%ecx
f0102161:	77 12                	ja     f0102175 <mem_init+0xf93>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102163:	50                   	push   %eax
f0102164:	68 44 5e 10 f0       	push   $0xf0105e44
f0102169:	6a 58                	push   $0x58
f010216b:	68 91 6c 10 f0       	push   $0xf0106c91
f0102170:	e8 cb de ff ff       	call   f0100040 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102175:	83 ec 04             	sub    $0x4,%esp
f0102178:	68 00 10 00 00       	push   $0x1000
f010217d:	68 ff 00 00 00       	push   $0xff
f0102182:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102187:	50                   	push   %eax
f0102188:	e8 e5 2f 00 00       	call   f0105172 <memset>
	page_free(pp0);
f010218d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0102190:	89 3c 24             	mov    %edi,(%esp)
f0102193:	e8 1a ed ff ff       	call   f0100eb2 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102198:	83 c4 0c             	add    $0xc,%esp
f010219b:	6a 01                	push   $0x1
f010219d:	6a 00                	push   $0x0
f010219f:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f01021a5:	e8 a2 ed ff ff       	call   f0100f4c <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021aa:	89 fa                	mov    %edi,%edx
f01021ac:	2b 15 90 ee 22 f0    	sub    0xf022ee90,%edx
f01021b2:	c1 fa 03             	sar    $0x3,%edx
f01021b5:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021b8:	89 d0                	mov    %edx,%eax
f01021ba:	c1 e8 0c             	shr    $0xc,%eax
f01021bd:	83 c4 10             	add    $0x10,%esp
f01021c0:	3b 05 88 ee 22 f0    	cmp    0xf022ee88,%eax
f01021c6:	72 12                	jb     f01021da <mem_init+0xff8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01021c8:	52                   	push   %edx
f01021c9:	68 44 5e 10 f0       	push   $0xf0105e44
f01021ce:	6a 58                	push   $0x58
f01021d0:	68 91 6c 10 f0       	push   $0xf0106c91
f01021d5:	e8 66 de ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f01021da:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01021e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01021e3:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01021e9:	f6 00 01             	testb  $0x1,(%eax)
f01021ec:	74 19                	je     f0102207 <mem_init+0x1025>
f01021ee:	68 54 6f 10 f0       	push   $0xf0106f54
f01021f3:	68 ab 6c 10 f0       	push   $0xf0106cab
f01021f8:	68 40 04 00 00       	push   $0x440
f01021fd:	68 85 6c 10 f0       	push   $0xf0106c85
f0102202:	e8 39 de ff ff       	call   f0100040 <_panic>
f0102207:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f010220a:	39 c2                	cmp    %eax,%edx
f010220c:	75 db                	jne    f01021e9 <mem_init+0x1007>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010220e:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f0102213:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102219:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010221c:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102222:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0102225:	89 0d 40 e2 22 f0    	mov    %ecx,0xf022e240

	// free the pages we took
	page_free(pp0);
f010222b:	83 ec 0c             	sub    $0xc,%esp
f010222e:	50                   	push   %eax
f010222f:	e8 7e ec ff ff       	call   f0100eb2 <page_free>
	page_free(pp1);
f0102234:	89 1c 24             	mov    %ebx,(%esp)
f0102237:	e8 76 ec ff ff       	call   f0100eb2 <page_free>
	page_free(pp2);
f010223c:	89 34 24             	mov    %esi,(%esp)
f010223f:	e8 6e ec ff ff       	call   f0100eb2 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102244:	83 c4 08             	add    $0x8,%esp
f0102247:	68 01 10 00 00       	push   $0x1001
f010224c:	6a 00                	push   $0x0
f010224e:	e8 2b ef ff ff       	call   f010117e <mmio_map_region>
f0102253:	89 c3                	mov    %eax,%ebx
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102255:	83 c4 08             	add    $0x8,%esp
f0102258:	68 00 10 00 00       	push   $0x1000
f010225d:	6a 00                	push   $0x0
f010225f:	e8 1a ef ff ff       	call   f010117e <mmio_map_region>
f0102264:	89 c6                	mov    %eax,%esi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102266:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f010226c:	83 c4 10             	add    $0x10,%esp
f010226f:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102275:	76 07                	jbe    f010227e <mem_init+0x109c>
f0102277:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f010227c:	76 19                	jbe    f0102297 <mem_init+0x10b5>
f010227e:	68 00 69 10 f0       	push   $0xf0106900
f0102283:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102288:	68 50 04 00 00       	push   $0x450
f010228d:	68 85 6c 10 f0       	push   $0xf0106c85
f0102292:	e8 a9 dd ff ff       	call   f0100040 <_panic>
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102297:	8d 96 a0 1f 00 00    	lea    0x1fa0(%esi),%edx
f010229d:	81 fa ff ff bf ef    	cmp    $0xefbfffff,%edx
f01022a3:	77 08                	ja     f01022ad <mem_init+0x10cb>
f01022a5:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f01022ab:	77 19                	ja     f01022c6 <mem_init+0x10e4>
f01022ad:	68 28 69 10 f0       	push   $0xf0106928
f01022b2:	68 ab 6c 10 f0       	push   $0xf0106cab
f01022b7:	68 51 04 00 00       	push   $0x451
f01022bc:	68 85 6c 10 f0       	push   $0xf0106c85
f01022c1:	e8 7a dd ff ff       	call   f0100040 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f01022c6:	89 da                	mov    %ebx,%edx
f01022c8:	09 f2                	or     %esi,%edx
f01022ca:	f7 c2 ff 0f 00 00    	test   $0xfff,%edx
f01022d0:	74 19                	je     f01022eb <mem_init+0x1109>
f01022d2:	68 50 69 10 f0       	push   $0xf0106950
f01022d7:	68 ab 6c 10 f0       	push   $0xf0106cab
f01022dc:	68 53 04 00 00       	push   $0x453
f01022e1:	68 85 6c 10 f0       	push   $0xf0106c85
f01022e6:	e8 55 dd ff ff       	call   f0100040 <_panic>
	// check that they don't overlap
	assert(mm1 + 8096 <= mm2);
f01022eb:	39 c6                	cmp    %eax,%esi
f01022ed:	73 19                	jae    f0102308 <mem_init+0x1126>
f01022ef:	68 6b 6f 10 f0       	push   $0xf0106f6b
f01022f4:	68 ab 6c 10 f0       	push   $0xf0106cab
f01022f9:	68 55 04 00 00       	push   $0x455
f01022fe:	68 85 6c 10 f0       	push   $0xf0106c85
f0102303:	e8 38 dd ff ff       	call   f0100040 <_panic>
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102308:	8b 3d 8c ee 22 f0    	mov    0xf022ee8c,%edi
f010230e:	89 da                	mov    %ebx,%edx
f0102310:	89 f8                	mov    %edi,%eax
f0102312:	e8 28 e7 ff ff       	call   f0100a3f <check_va2pa>
f0102317:	85 c0                	test   %eax,%eax
f0102319:	74 19                	je     f0102334 <mem_init+0x1152>
f010231b:	68 78 69 10 f0       	push   $0xf0106978
f0102320:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102325:	68 57 04 00 00       	push   $0x457
f010232a:	68 85 6c 10 f0       	push   $0xf0106c85
f010232f:	e8 0c dd ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102334:	8d 83 00 10 00 00    	lea    0x1000(%ebx),%eax
f010233a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010233d:	89 c2                	mov    %eax,%edx
f010233f:	89 f8                	mov    %edi,%eax
f0102341:	e8 f9 e6 ff ff       	call   f0100a3f <check_va2pa>
f0102346:	3d 00 10 00 00       	cmp    $0x1000,%eax
f010234b:	74 19                	je     f0102366 <mem_init+0x1184>
f010234d:	68 9c 69 10 f0       	push   $0xf010699c
f0102352:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102357:	68 58 04 00 00       	push   $0x458
f010235c:	68 85 6c 10 f0       	push   $0xf0106c85
f0102361:	e8 da dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102366:	89 f2                	mov    %esi,%edx
f0102368:	89 f8                	mov    %edi,%eax
f010236a:	e8 d0 e6 ff ff       	call   f0100a3f <check_va2pa>
f010236f:	85 c0                	test   %eax,%eax
f0102371:	74 19                	je     f010238c <mem_init+0x11aa>
f0102373:	68 cc 69 10 f0       	push   $0xf01069cc
f0102378:	68 ab 6c 10 f0       	push   $0xf0106cab
f010237d:	68 59 04 00 00       	push   $0x459
f0102382:	68 85 6c 10 f0       	push   $0xf0106c85
f0102387:	e8 b4 dc ff ff       	call   f0100040 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f010238c:	8d 96 00 10 00 00    	lea    0x1000(%esi),%edx
f0102392:	89 f8                	mov    %edi,%eax
f0102394:	e8 a6 e6 ff ff       	call   f0100a3f <check_va2pa>
f0102399:	83 f8 ff             	cmp    $0xffffffff,%eax
f010239c:	74 19                	je     f01023b7 <mem_init+0x11d5>
f010239e:	68 f0 69 10 f0       	push   $0xf01069f0
f01023a3:	68 ab 6c 10 f0       	push   $0xf0106cab
f01023a8:	68 5a 04 00 00       	push   $0x45a
f01023ad:	68 85 6c 10 f0       	push   $0xf0106c85
f01023b2:	e8 89 dc ff ff       	call   f0100040 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f01023b7:	83 ec 04             	sub    $0x4,%esp
f01023ba:	6a 00                	push   $0x0
f01023bc:	53                   	push   %ebx
f01023bd:	57                   	push   %edi
f01023be:	e8 89 eb ff ff       	call   f0100f4c <pgdir_walk>
f01023c3:	83 c4 10             	add    $0x10,%esp
f01023c6:	f6 00 1a             	testb  $0x1a,(%eax)
f01023c9:	75 19                	jne    f01023e4 <mem_init+0x1202>
f01023cb:	68 1c 6a 10 f0       	push   $0xf0106a1c
f01023d0:	68 ab 6c 10 f0       	push   $0xf0106cab
f01023d5:	68 5c 04 00 00       	push   $0x45c
f01023da:	68 85 6c 10 f0       	push   $0xf0106c85
f01023df:	e8 5c dc ff ff       	call   f0100040 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f01023e4:	83 ec 04             	sub    $0x4,%esp
f01023e7:	6a 00                	push   $0x0
f01023e9:	53                   	push   %ebx
f01023ea:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f01023f0:	e8 57 eb ff ff       	call   f0100f4c <pgdir_walk>
f01023f5:	8b 00                	mov    (%eax),%eax
f01023f7:	83 c4 10             	add    $0x10,%esp
f01023fa:	83 e0 04             	and    $0x4,%eax
f01023fd:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0102400:	74 19                	je     f010241b <mem_init+0x1239>
f0102402:	68 60 6a 10 f0       	push   $0xf0106a60
f0102407:	68 ab 6c 10 f0       	push   $0xf0106cab
f010240c:	68 5d 04 00 00       	push   $0x45d
f0102411:	68 85 6c 10 f0       	push   $0xf0106c85
f0102416:	e8 25 dc ff ff       	call   f0100040 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f010241b:	83 ec 04             	sub    $0x4,%esp
f010241e:	6a 00                	push   $0x0
f0102420:	53                   	push   %ebx
f0102421:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0102427:	e8 20 eb ff ff       	call   f0100f4c <pgdir_walk>
f010242c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102432:	83 c4 0c             	add    $0xc,%esp
f0102435:	6a 00                	push   $0x0
f0102437:	ff 75 d4             	pushl  -0x2c(%ebp)
f010243a:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0102440:	e8 07 eb ff ff       	call   f0100f4c <pgdir_walk>
f0102445:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f010244b:	83 c4 0c             	add    $0xc,%esp
f010244e:	6a 00                	push   $0x0
f0102450:	56                   	push   %esi
f0102451:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0102457:	e8 f0 ea ff ff       	call   f0100f4c <pgdir_walk>
f010245c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	cprintf("check_page() succeeded!\n");
f0102462:	c7 04 24 7d 6f 10 f0 	movl   $0xf0106f7d,(%esp)
f0102469:	e8 33 11 00 00       	call   f01035a1 <cprintf>
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	// 把pages数组映射到线性地址UPAGES
	boot_map_region(kern_pgdir, UPAGES, PTSIZE, PADDR(pages), PTE_U);
f010246e:	a1 90 ee 22 f0       	mov    0xf022ee90,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102473:	83 c4 10             	add    $0x10,%esp
f0102476:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010247b:	77 15                	ja     f0102492 <mem_init+0x12b0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010247d:	50                   	push   %eax
f010247e:	68 68 5e 10 f0       	push   $0xf0105e68
f0102483:	68 d0 00 00 00       	push   $0xd0
f0102488:	68 85 6c 10 f0       	push   $0xf0106c85
f010248d:	e8 ae db ff ff       	call   f0100040 <_panic>
f0102492:	83 ec 08             	sub    $0x8,%esp
f0102495:	6a 04                	push   $0x4
f0102497:	05 00 00 00 10       	add    $0x10000000,%eax
f010249c:	50                   	push   %eax
f010249d:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01024a2:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01024a7:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f01024ac:	e8 2e eb ff ff       	call   f0100fdf <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	// 将envs映射到虚拟空间UENVS处
	boot_map_region(kern_pgdir, UENVS, PTSIZE, PADDR(envs), PTE_U);
f01024b1:	a1 48 e2 22 f0       	mov    0xf022e248,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024b6:	83 c4 10             	add    $0x10,%esp
f01024b9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01024be:	77 15                	ja     f01024d5 <mem_init+0x12f3>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01024c0:	50                   	push   %eax
f01024c1:	68 68 5e 10 f0       	push   $0xf0105e68
f01024c6:	68 da 00 00 00       	push   $0xda
f01024cb:	68 85 6c 10 f0       	push   $0xf0106c85
f01024d0:	e8 6b db ff ff       	call   f0100040 <_panic>
f01024d5:	83 ec 08             	sub    $0x8,%esp
f01024d8:	6a 04                	push   $0x4
f01024da:	05 00 00 00 10       	add    $0x10000000,%eax
f01024df:	50                   	push   %eax
f01024e0:	b9 00 00 40 00       	mov    $0x400000,%ecx
f01024e5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f01024ea:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f01024ef:	e8 eb ea ff ff       	call   f0100fdf <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024f4:	83 c4 10             	add    $0x10,%esp
f01024f7:	b8 00 50 11 f0       	mov    $0xf0115000,%eax
f01024fc:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102501:	77 15                	ja     f0102518 <mem_init+0x1336>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102503:	50                   	push   %eax
f0102504:	68 68 5e 10 f0       	push   $0xf0105e68
f0102509:	68 e9 00 00 00       	push   $0xe9
f010250e:	68 85 6c 10 f0       	push   $0xf0106c85
f0102513:	e8 28 db ff ff       	call   f0100040 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	// 把由bootstack变量所标记的物理地址范围映射给内核的堆栈
	boot_map_region(kern_pgdir, KSTACKTOP-KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f0102518:	83 ec 08             	sub    $0x8,%esp
f010251b:	6a 02                	push   $0x2
f010251d:	68 00 50 11 00       	push   $0x115000
f0102522:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102527:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f010252c:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f0102531:	e8 a9 ea ff ff       	call   f0100fdf <boot_map_region>
	// Your code goes here:
	//？？？？？
	// n = (uint32_t)(-1) - KERNBASE + 1;
	// 2^32 - 15*16^7 = 1*16^7 = 0x10000000
	// 将整个物理内存映射到虚拟地址空间KERNBASE
	boot_map_region(kern_pgdir, KERNBASE, 0x10000000, 0, PTE_W | PTE_P);
f0102536:	83 c4 08             	add    $0x8,%esp
f0102539:	6a 03                	push   $0x3
f010253b:	6a 00                	push   $0x0
f010253d:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102542:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f0102547:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f010254c:	e8 8e ea ff ff       	call   f0100fdf <boot_map_region>
f0102551:	c7 45 c4 00 00 23 f0 	movl   $0xf0230000,-0x3c(%ebp)
f0102558:	83 c4 10             	add    $0x10,%esp
f010255b:	bb 00 00 23 f0       	mov    $0xf0230000,%ebx
f0102560:	be 00 80 ff ef       	mov    $0xefff8000,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102565:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010256b:	77 15                	ja     f0102582 <mem_init+0x13a0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010256d:	53                   	push   %ebx
f010256e:	68 68 5e 10 f0       	push   $0xf0105e68
f0102573:	68 30 01 00 00       	push   $0x130
f0102578:	68 85 6c 10 f0       	push   $0xf0106c85
f010257d:	e8 be da ff ff       	call   f0100040 <_panic>
	// LAB 4: Your code here:
	// KSTKGAP -- 保护页
	int i;
	for (i = 0; i < NCPU; i++) {
		intptr_t kstacktop_i = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
		boot_map_region(kern_pgdir, kstacktop_i - KSTKSIZE, KSTKSIZE, 
f0102582:	83 ec 08             	sub    $0x8,%esp
f0102585:	6a 03                	push   $0x3
f0102587:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010258d:	50                   	push   %eax
f010258e:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0102593:	89 f2                	mov    %esi,%edx
f0102595:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
f010259a:	e8 40 ea ff ff       	call   f0100fdf <boot_map_region>
f010259f:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f01025a5:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	// KSTKGAP -- 保护页
	int i;
	for (i = 0; i < NCPU; i++) {
f01025ab:	83 c4 10             	add    $0x10,%esp
f01025ae:	b8 00 00 27 f0       	mov    $0xf0270000,%eax
f01025b3:	39 d8                	cmp    %ebx,%eax
f01025b5:	75 ae                	jne    f0102565 <mem_init+0x1383>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f01025b7:	8b 3d 8c ee 22 f0    	mov    0xf022ee8c,%edi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f01025bd:	a1 88 ee 22 f0       	mov    0xf022ee88,%eax
f01025c2:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01025c5:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f01025cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01025d1:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025d4:	8b 35 90 ee 22 f0    	mov    0xf022ee90,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01025da:	89 75 d0             	mov    %esi,-0x30(%ebp)

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01025dd:	bb 00 00 00 00       	mov    $0x0,%ebx
f01025e2:	eb 55                	jmp    f0102639 <mem_init+0x1457>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01025e4:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
f01025ea:	89 f8                	mov    %edi,%eax
f01025ec:	e8 4e e4 ff ff       	call   f0100a3f <check_va2pa>
f01025f1:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f01025f8:	77 15                	ja     f010260f <mem_init+0x142d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01025fa:	56                   	push   %esi
f01025fb:	68 68 5e 10 f0       	push   $0xf0105e68
f0102600:	68 75 03 00 00       	push   $0x375
f0102605:	68 85 6c 10 f0       	push   $0xf0106c85
f010260a:	e8 31 da ff ff       	call   f0100040 <_panic>
f010260f:	8d 94 1e 00 00 00 10 	lea    0x10000000(%esi,%ebx,1),%edx
f0102616:	39 c2                	cmp    %eax,%edx
f0102618:	74 19                	je     f0102633 <mem_init+0x1451>
f010261a:	68 94 6a 10 f0       	push   $0xf0106a94
f010261f:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102624:	68 75 03 00 00       	push   $0x375
f0102629:	68 85 6c 10 f0       	push   $0xf0106c85
f010262e:	e8 0d da ff ff       	call   f0100040 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102633:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102639:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010263c:	77 a6                	ja     f01025e4 <mem_init+0x1402>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010263e:	8b 35 48 e2 22 f0    	mov    0xf022e248,%esi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102644:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f0102647:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f010264c:	89 da                	mov    %ebx,%edx
f010264e:	89 f8                	mov    %edi,%eax
f0102650:	e8 ea e3 ff ff       	call   f0100a3f <check_va2pa>
f0102655:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f010265c:	77 15                	ja     f0102673 <mem_init+0x1491>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010265e:	56                   	push   %esi
f010265f:	68 68 5e 10 f0       	push   $0xf0105e68
f0102664:	68 7a 03 00 00       	push   $0x37a
f0102669:	68 85 6c 10 f0       	push   $0xf0106c85
f010266e:	e8 cd d9 ff ff       	call   f0100040 <_panic>
f0102673:	8d 94 1e 00 00 40 21 	lea    0x21400000(%esi,%ebx,1),%edx
f010267a:	39 d0                	cmp    %edx,%eax
f010267c:	74 19                	je     f0102697 <mem_init+0x14b5>
f010267e:	68 c8 6a 10 f0       	push   $0xf0106ac8
f0102683:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102688:	68 7a 03 00 00       	push   $0x37a
f010268d:	68 85 6c 10 f0       	push   $0xf0106c85
f0102692:	e8 a9 d9 ff ff       	call   f0100040 <_panic>
f0102697:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010269d:	81 fb 00 f0 c1 ee    	cmp    $0xeec1f000,%ebx
f01026a3:	75 a7                	jne    f010264c <mem_init+0x146a>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026a5:	8b 75 cc             	mov    -0x34(%ebp),%esi
f01026a8:	c1 e6 0c             	shl    $0xc,%esi
f01026ab:	bb 00 00 00 00       	mov    $0x0,%ebx
f01026b0:	eb 30                	jmp    f01026e2 <mem_init+0x1500>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01026b2:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
f01026b8:	89 f8                	mov    %edi,%eax
f01026ba:	e8 80 e3 ff ff       	call   f0100a3f <check_va2pa>
f01026bf:	39 c3                	cmp    %eax,%ebx
f01026c1:	74 19                	je     f01026dc <mem_init+0x14fa>
f01026c3:	68 fc 6a 10 f0       	push   $0xf0106afc
f01026c8:	68 ab 6c 10 f0       	push   $0xf0106cab
f01026cd:	68 7e 03 00 00       	push   $0x37e
f01026d2:	68 85 6c 10 f0       	push   $0xf0106c85
f01026d7:	e8 64 d9 ff ff       	call   f0100040 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01026dc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01026e2:	39 f3                	cmp    %esi,%ebx
f01026e4:	72 cc                	jb     f01026b2 <mem_init+0x14d0>
f01026e6:	be 00 80 ff ef       	mov    $0xefff8000,%esi
f01026eb:	89 75 cc             	mov    %esi,-0x34(%ebp)
f01026ee:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01026f1:	8b 45 cc             	mov    -0x34(%ebp),%eax
f01026f4:	8d 88 00 80 00 00    	lea    0x8000(%eax),%ecx
f01026fa:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01026fd:	89 c3                	mov    %eax,%ebx
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f01026ff:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102702:	05 00 80 00 20       	add    $0x20008000,%eax
f0102707:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010270a:	89 da                	mov    %ebx,%edx
f010270c:	89 f8                	mov    %edi,%eax
f010270e:	e8 2c e3 ff ff       	call   f0100a3f <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102713:	81 fe ff ff ff ef    	cmp    $0xefffffff,%esi
f0102719:	77 15                	ja     f0102730 <mem_init+0x154e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010271b:	56                   	push   %esi
f010271c:	68 68 5e 10 f0       	push   $0xf0105e68
f0102721:	68 86 03 00 00       	push   $0x386
f0102726:	68 85 6c 10 f0       	push   $0xf0106c85
f010272b:	e8 10 d9 ff ff       	call   f0100040 <_panic>
f0102730:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102733:	8d 94 0b 00 00 23 f0 	lea    -0xfdd0000(%ebx,%ecx,1),%edx
f010273a:	39 d0                	cmp    %edx,%eax
f010273c:	74 19                	je     f0102757 <mem_init+0x1575>
f010273e:	68 24 6b 10 f0       	push   $0xf0106b24
f0102743:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102748:	68 86 03 00 00       	push   $0x386
f010274d:	68 85 6c 10 f0       	push   $0xf0106c85
f0102752:	e8 e9 d8 ff ff       	call   f0100040 <_panic>
f0102757:	81 c3 00 10 00 00    	add    $0x1000,%ebx

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010275d:	3b 5d d0             	cmp    -0x30(%ebp),%ebx
f0102760:	75 a8                	jne    f010270a <mem_init+0x1528>
f0102762:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0102765:	8d 98 00 80 ff ff    	lea    -0x8000(%eax),%ebx
f010276b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f010276e:	89 c6                	mov    %eax,%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f0102770:	89 da                	mov    %ebx,%edx
f0102772:	89 f8                	mov    %edi,%eax
f0102774:	e8 c6 e2 ff ff       	call   f0100a3f <check_va2pa>
f0102779:	83 f8 ff             	cmp    $0xffffffff,%eax
f010277c:	74 19                	je     f0102797 <mem_init+0x15b5>
f010277e:	68 6c 6b 10 f0       	push   $0xf0106b6c
f0102783:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102788:	68 88 03 00 00       	push   $0x388
f010278d:	68 85 6c 10 f0       	push   $0xf0106c85
f0102792:	e8 a9 d8 ff ff       	call   f0100040 <_panic>
f0102797:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f010279d:	39 f3                	cmp    %esi,%ebx
f010279f:	75 cf                	jne    f0102770 <mem_init+0x158e>
f01027a1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
f01027a4:	81 6d cc 00 00 01 00 	subl   $0x10000,-0x34(%ebp)
f01027ab:	81 45 c8 00 80 01 00 	addl   $0x18000,-0x38(%ebp)
f01027b2:	81 c6 00 80 00 00    	add    $0x8000,%esi
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01027b8:	b8 00 00 27 f0       	mov    $0xf0270000,%eax
f01027bd:	39 f0                	cmp    %esi,%eax
f01027bf:	0f 85 2c ff ff ff    	jne    f01026f1 <mem_init+0x150f>
f01027c5:	b8 00 00 00 00       	mov    $0x0,%eax
f01027ca:	eb 2a                	jmp    f01027f6 <mem_init+0x1614>
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01027cc:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f01027d2:	83 fa 04             	cmp    $0x4,%edx
f01027d5:	77 1f                	ja     f01027f6 <mem_init+0x1614>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f01027d7:	f6 04 87 01          	testb  $0x1,(%edi,%eax,4)
f01027db:	75 7e                	jne    f010285b <mem_init+0x1679>
f01027dd:	68 96 6f 10 f0       	push   $0xf0106f96
f01027e2:	68 ab 6c 10 f0       	push   $0xf0106cab
f01027e7:	68 93 03 00 00       	push   $0x393
f01027ec:	68 85 6c 10 f0       	push   $0xf0106c85
f01027f1:	e8 4a d8 ff ff       	call   f0100040 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01027f6:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01027fb:	76 3f                	jbe    f010283c <mem_init+0x165a>
				assert(pgdir[i] & PTE_P);
f01027fd:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0102800:	f6 c2 01             	test   $0x1,%dl
f0102803:	75 19                	jne    f010281e <mem_init+0x163c>
f0102805:	68 96 6f 10 f0       	push   $0xf0106f96
f010280a:	68 ab 6c 10 f0       	push   $0xf0106cab
f010280f:	68 97 03 00 00       	push   $0x397
f0102814:	68 85 6c 10 f0       	push   $0xf0106c85
f0102819:	e8 22 d8 ff ff       	call   f0100040 <_panic>
				assert(pgdir[i] & PTE_W);
f010281e:	f6 c2 02             	test   $0x2,%dl
f0102821:	75 38                	jne    f010285b <mem_init+0x1679>
f0102823:	68 a7 6f 10 f0       	push   $0xf0106fa7
f0102828:	68 ab 6c 10 f0       	push   $0xf0106cab
f010282d:	68 98 03 00 00       	push   $0x398
f0102832:	68 85 6c 10 f0       	push   $0xf0106c85
f0102837:	e8 04 d8 ff ff       	call   f0100040 <_panic>
			} else
				assert(pgdir[i] == 0);
f010283c:	83 3c 87 00          	cmpl   $0x0,(%edi,%eax,4)
f0102840:	74 19                	je     f010285b <mem_init+0x1679>
f0102842:	68 b8 6f 10 f0       	push   $0xf0106fb8
f0102847:	68 ab 6c 10 f0       	push   $0xf0106cab
f010284c:	68 9a 03 00 00       	push   $0x39a
f0102851:	68 85 6c 10 f0       	push   $0xf0106c85
f0102856:	e8 e5 d7 ff ff       	call   f0100040 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f010285b:	83 c0 01             	add    $0x1,%eax
f010285e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f0102863:	0f 86 63 ff ff ff    	jbe    f01027cc <mem_init+0x15ea>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102869:	83 ec 0c             	sub    $0xc,%esp
f010286c:	68 90 6b 10 f0       	push   $0xf0106b90
f0102871:	e8 2b 0d 00 00       	call   f01035a1 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f0102876:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010287b:	83 c4 10             	add    $0x10,%esp
f010287e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102883:	77 15                	ja     f010289a <mem_init+0x16b8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102885:	50                   	push   %eax
f0102886:	68 68 5e 10 f0       	push   $0xf0105e68
f010288b:	68 06 01 00 00       	push   $0x106
f0102890:	68 85 6c 10 f0       	push   $0xf0106c85
f0102895:	e8 a6 d7 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010289a:	05 00 00 00 10       	add    $0x10000000,%eax
f010289f:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f01028a2:	b8 00 00 00 00       	mov    $0x0,%eax
f01028a7:	e8 f7 e1 ff ff       	call   f0100aa3 <check_page_free_list>

static inline uint32_t
rcr0(void)
{
	uint32_t val;
	asm volatile("movl %%cr0,%0" : "=r" (val));
f01028ac:	0f 20 c0             	mov    %cr0,%eax
f01028af:	83 e0 f3             	and    $0xfffffff3,%eax
}

static inline void
lcr0(uint32_t val)
{
	asm volatile("movl %0,%%cr0" : : "r" (val));
f01028b2:	0d 23 00 05 80       	or     $0x80050023,%eax
f01028b7:	0f 22 c0             	mov    %eax,%cr0
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01028ba:	83 ec 0c             	sub    $0xc,%esp
f01028bd:	6a 00                	push   $0x0
f01028bf:	e8 7e e5 ff ff       	call   f0100e42 <page_alloc>
f01028c4:	89 c3                	mov    %eax,%ebx
f01028c6:	83 c4 10             	add    $0x10,%esp
f01028c9:	85 c0                	test   %eax,%eax
f01028cb:	75 19                	jne    f01028e6 <mem_init+0x1704>
f01028cd:	68 a2 6d 10 f0       	push   $0xf0106da2
f01028d2:	68 ab 6c 10 f0       	push   $0xf0106cab
f01028d7:	68 72 04 00 00       	push   $0x472
f01028dc:	68 85 6c 10 f0       	push   $0xf0106c85
f01028e1:	e8 5a d7 ff ff       	call   f0100040 <_panic>
	assert((pp1 = page_alloc(0)));
f01028e6:	83 ec 0c             	sub    $0xc,%esp
f01028e9:	6a 00                	push   $0x0
f01028eb:	e8 52 e5 ff ff       	call   f0100e42 <page_alloc>
f01028f0:	89 c7                	mov    %eax,%edi
f01028f2:	83 c4 10             	add    $0x10,%esp
f01028f5:	85 c0                	test   %eax,%eax
f01028f7:	75 19                	jne    f0102912 <mem_init+0x1730>
f01028f9:	68 b8 6d 10 f0       	push   $0xf0106db8
f01028fe:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102903:	68 73 04 00 00       	push   $0x473
f0102908:	68 85 6c 10 f0       	push   $0xf0106c85
f010290d:	e8 2e d7 ff ff       	call   f0100040 <_panic>
	assert((pp2 = page_alloc(0)));
f0102912:	83 ec 0c             	sub    $0xc,%esp
f0102915:	6a 00                	push   $0x0
f0102917:	e8 26 e5 ff ff       	call   f0100e42 <page_alloc>
f010291c:	89 c6                	mov    %eax,%esi
f010291e:	83 c4 10             	add    $0x10,%esp
f0102921:	85 c0                	test   %eax,%eax
f0102923:	75 19                	jne    f010293e <mem_init+0x175c>
f0102925:	68 ce 6d 10 f0       	push   $0xf0106dce
f010292a:	68 ab 6c 10 f0       	push   $0xf0106cab
f010292f:	68 74 04 00 00       	push   $0x474
f0102934:	68 85 6c 10 f0       	push   $0xf0106c85
f0102939:	e8 02 d7 ff ff       	call   f0100040 <_panic>
	page_free(pp0);
f010293e:	83 ec 0c             	sub    $0xc,%esp
f0102941:	53                   	push   %ebx
f0102942:	e8 6b e5 ff ff       	call   f0100eb2 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102947:	89 f8                	mov    %edi,%eax
f0102949:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f010294f:	c1 f8 03             	sar    $0x3,%eax
f0102952:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102955:	89 c2                	mov    %eax,%edx
f0102957:	c1 ea 0c             	shr    $0xc,%edx
f010295a:	83 c4 10             	add    $0x10,%esp
f010295d:	3b 15 88 ee 22 f0    	cmp    0xf022ee88,%edx
f0102963:	72 12                	jb     f0102977 <mem_init+0x1795>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102965:	50                   	push   %eax
f0102966:	68 44 5e 10 f0       	push   $0xf0105e44
f010296b:	6a 58                	push   $0x58
f010296d:	68 91 6c 10 f0       	push   $0xf0106c91
f0102972:	e8 c9 d6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f0102977:	83 ec 04             	sub    $0x4,%esp
f010297a:	68 00 10 00 00       	push   $0x1000
f010297f:	6a 01                	push   $0x1
f0102981:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102986:	50                   	push   %eax
f0102987:	e8 e6 27 00 00       	call   f0105172 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010298c:	89 f0                	mov    %esi,%eax
f010298e:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f0102994:	c1 f8 03             	sar    $0x3,%eax
f0102997:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010299a:	89 c2                	mov    %eax,%edx
f010299c:	c1 ea 0c             	shr    $0xc,%edx
f010299f:	83 c4 10             	add    $0x10,%esp
f01029a2:	3b 15 88 ee 22 f0    	cmp    0xf022ee88,%edx
f01029a8:	72 12                	jb     f01029bc <mem_init+0x17da>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01029aa:	50                   	push   %eax
f01029ab:	68 44 5e 10 f0       	push   $0xf0105e44
f01029b0:	6a 58                	push   $0x58
f01029b2:	68 91 6c 10 f0       	push   $0xf0106c91
f01029b7:	e8 84 d6 ff ff       	call   f0100040 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f01029bc:	83 ec 04             	sub    $0x4,%esp
f01029bf:	68 00 10 00 00       	push   $0x1000
f01029c4:	6a 02                	push   $0x2
f01029c6:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01029cb:	50                   	push   %eax
f01029cc:	e8 a1 27 00 00       	call   f0105172 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01029d1:	6a 02                	push   $0x2
f01029d3:	68 00 10 00 00       	push   $0x1000
f01029d8:	57                   	push   %edi
f01029d9:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f01029df:	e8 34 e7 ff ff       	call   f0101118 <page_insert>
	assert(pp1->pp_ref == 1);
f01029e4:	83 c4 20             	add    $0x20,%esp
f01029e7:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01029ec:	74 19                	je     f0102a07 <mem_init+0x1825>
f01029ee:	68 9f 6e 10 f0       	push   $0xf0106e9f
f01029f3:	68 ab 6c 10 f0       	push   $0xf0106cab
f01029f8:	68 79 04 00 00       	push   $0x479
f01029fd:	68 85 6c 10 f0       	push   $0xf0106c85
f0102a02:	e8 39 d6 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102a07:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f0102a0e:	01 01 01 
f0102a11:	74 19                	je     f0102a2c <mem_init+0x184a>
f0102a13:	68 b0 6b 10 f0       	push   $0xf0106bb0
f0102a18:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102a1d:	68 7a 04 00 00       	push   $0x47a
f0102a22:	68 85 6c 10 f0       	push   $0xf0106c85
f0102a27:	e8 14 d6 ff ff       	call   f0100040 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102a2c:	6a 02                	push   $0x2
f0102a2e:	68 00 10 00 00       	push   $0x1000
f0102a33:	56                   	push   %esi
f0102a34:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0102a3a:	e8 d9 e6 ff ff       	call   f0101118 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102a3f:	83 c4 10             	add    $0x10,%esp
f0102a42:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102a49:	02 02 02 
f0102a4c:	74 19                	je     f0102a67 <mem_init+0x1885>
f0102a4e:	68 d4 6b 10 f0       	push   $0xf0106bd4
f0102a53:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102a58:	68 7c 04 00 00       	push   $0x47c
f0102a5d:	68 85 6c 10 f0       	push   $0xf0106c85
f0102a62:	e8 d9 d5 ff ff       	call   f0100040 <_panic>
	assert(pp2->pp_ref == 1);
f0102a67:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102a6c:	74 19                	je     f0102a87 <mem_init+0x18a5>
f0102a6e:	68 c1 6e 10 f0       	push   $0xf0106ec1
f0102a73:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102a78:	68 7d 04 00 00       	push   $0x47d
f0102a7d:	68 85 6c 10 f0       	push   $0xf0106c85
f0102a82:	e8 b9 d5 ff ff       	call   f0100040 <_panic>
	assert(pp1->pp_ref == 0);
f0102a87:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a8c:	74 19                	je     f0102aa7 <mem_init+0x18c5>
f0102a8e:	68 2b 6f 10 f0       	push   $0xf0106f2b
f0102a93:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102a98:	68 7e 04 00 00       	push   $0x47e
f0102a9d:	68 85 6c 10 f0       	push   $0xf0106c85
f0102aa2:	e8 99 d5 ff ff       	call   f0100040 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f0102aa7:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102aae:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ab1:	89 f0                	mov    %esi,%eax
f0102ab3:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f0102ab9:	c1 f8 03             	sar    $0x3,%eax
f0102abc:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102abf:	89 c2                	mov    %eax,%edx
f0102ac1:	c1 ea 0c             	shr    $0xc,%edx
f0102ac4:	3b 15 88 ee 22 f0    	cmp    0xf022ee88,%edx
f0102aca:	72 12                	jb     f0102ade <mem_init+0x18fc>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102acc:	50                   	push   %eax
f0102acd:	68 44 5e 10 f0       	push   $0xf0105e44
f0102ad2:	6a 58                	push   $0x58
f0102ad4:	68 91 6c 10 f0       	push   $0xf0106c91
f0102ad9:	e8 62 d5 ff ff       	call   f0100040 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102ade:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f0102ae5:	03 03 03 
f0102ae8:	74 19                	je     f0102b03 <mem_init+0x1921>
f0102aea:	68 f8 6b 10 f0       	push   $0xf0106bf8
f0102aef:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102af4:	68 80 04 00 00       	push   $0x480
f0102af9:	68 85 6c 10 f0       	push   $0xf0106c85
f0102afe:	e8 3d d5 ff ff       	call   f0100040 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f0102b03:	83 ec 08             	sub    $0x8,%esp
f0102b06:	68 00 10 00 00       	push   $0x1000
f0102b0b:	ff 35 8c ee 22 f0    	pushl  0xf022ee8c
f0102b11:	e8 b2 e5 ff ff       	call   f01010c8 <page_remove>
	assert(pp2->pp_ref == 0);
f0102b16:	83 c4 10             	add    $0x10,%esp
f0102b19:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0102b1e:	74 19                	je     f0102b39 <mem_init+0x1957>
f0102b20:	68 f9 6e 10 f0       	push   $0xf0106ef9
f0102b25:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102b2a:	68 82 04 00 00       	push   $0x482
f0102b2f:	68 85 6c 10 f0       	push   $0xf0106c85
f0102b34:	e8 07 d5 ff ff       	call   f0100040 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b39:	8b 0d 8c ee 22 f0    	mov    0xf022ee8c,%ecx
f0102b3f:	8b 11                	mov    (%ecx),%edx
f0102b41:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102b47:	89 d8                	mov    %ebx,%eax
f0102b49:	2b 05 90 ee 22 f0    	sub    0xf022ee90,%eax
f0102b4f:	c1 f8 03             	sar    $0x3,%eax
f0102b52:	c1 e0 0c             	shl    $0xc,%eax
f0102b55:	39 c2                	cmp    %eax,%edx
f0102b57:	74 19                	je     f0102b72 <mem_init+0x1990>
f0102b59:	68 80 65 10 f0       	push   $0xf0106580
f0102b5e:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102b63:	68 85 04 00 00       	push   $0x485
f0102b68:	68 85 6c 10 f0       	push   $0xf0106c85
f0102b6d:	e8 ce d4 ff ff       	call   f0100040 <_panic>
	kern_pgdir[0] = 0;
f0102b72:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f0102b78:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102b7d:	74 19                	je     f0102b98 <mem_init+0x19b6>
f0102b7f:	68 b0 6e 10 f0       	push   $0xf0106eb0
f0102b84:	68 ab 6c 10 f0       	push   $0xf0106cab
f0102b89:	68 87 04 00 00       	push   $0x487
f0102b8e:	68 85 6c 10 f0       	push   $0xf0106c85
f0102b93:	e8 a8 d4 ff ff       	call   f0100040 <_panic>
	pp0->pp_ref = 0;
f0102b98:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102b9e:	83 ec 0c             	sub    $0xc,%esp
f0102ba1:	53                   	push   %ebx
f0102ba2:	e8 0b e3 ff ff       	call   f0100eb2 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ba7:	c7 04 24 24 6c 10 f0 	movl   $0xf0106c24,(%esp)
f0102bae:	e8 ee 09 00 00       	call   f01035a1 <cprintf>
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f0102bb3:	83 c4 10             	add    $0x10,%esp
f0102bb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102bb9:	5b                   	pop    %ebx
f0102bba:	5e                   	pop    %esi
f0102bbb:	5f                   	pop    %edi
f0102bbc:	5d                   	pop    %ebp
f0102bbd:	c3                   	ret    

f0102bbe <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
// ?????
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f0102bbe:	55                   	push   %ebp
f0102bbf:	89 e5                	mov    %esp,%ebp
f0102bc1:	57                   	push   %edi
f0102bc2:	56                   	push   %esi
f0102bc3:	53                   	push   %ebx
f0102bc4:	83 ec 1c             	sub    $0x1c,%esp
f0102bc7:	8b 7d 08             	mov    0x8(%ebp),%edi
f0102bca:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 3: Your code here.
	char * end = NULL;
	char * start = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE); 
f0102bcd:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bd0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102bd5:	89 c3                	mov    %eax,%ebx
f0102bd7:	89 45 e0             	mov    %eax,-0x20(%ebp)
	end = ROUNDUP((char *)(va + len), PGSIZE);
f0102bda:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102bdd:	03 45 10             	add    0x10(%ebp),%eax
f0102be0:	05 ff 0f 00 00       	add    $0xfff,%eax
f0102be5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102bea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t *cur = NULL;

	for(; start < end; start += PGSIZE) {
f0102bed:	eb 4e                	jmp    f0102c3d <user_mem_check+0x7f>
		cur = pgdir_walk(env->env_pgdir, (void *)start, 0);
f0102bef:	83 ec 04             	sub    $0x4,%esp
f0102bf2:	6a 00                	push   $0x0
f0102bf4:	53                   	push   %ebx
f0102bf5:	ff 77 60             	pushl  0x60(%edi)
f0102bf8:	e8 4f e3 ff ff       	call   f0100f4c <pgdir_walk>
		if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
f0102bfd:	89 da                	mov    %ebx,%edx
f0102bff:	83 c4 10             	add    $0x10,%esp
f0102c02:	81 fb 00 00 80 ef    	cmp    $0xef800000,%ebx
f0102c08:	77 0c                	ja     f0102c16 <user_mem_check+0x58>
f0102c0a:	85 c0                	test   %eax,%eax
f0102c0c:	74 08                	je     f0102c16 <user_mem_check+0x58>
f0102c0e:	89 f1                	mov    %esi,%ecx
f0102c10:	23 08                	and    (%eax),%ecx
f0102c12:	39 ce                	cmp    %ecx,%esi
f0102c14:	74 21                	je     f0102c37 <user_mem_check+0x79>
			  if(start == ROUNDDOWN((char *)va, PGSIZE)) {
f0102c16:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
f0102c19:	75 0f                	jne    f0102c2a <user_mem_check+0x6c>
					user_mem_check_addr = (uintptr_t)va;
f0102c1b:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102c1e:	a3 3c e2 22 f0       	mov    %eax,0xf022e23c
			  }
			  else {
			  		user_mem_check_addr = (uintptr_t)start;
			  }
			  return -E_FAULT;
f0102c23:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102c28:	eb 1d                	jmp    f0102c47 <user_mem_check+0x89>
		if((int)start > ULIM || cur == NULL || ((uint32_t)(*cur) & perm) != perm) {
			  if(start == ROUNDDOWN((char *)va, PGSIZE)) {
					user_mem_check_addr = (uintptr_t)va;
			  }
			  else {
			  		user_mem_check_addr = (uintptr_t)start;
f0102c2a:	89 15 3c e2 22 f0    	mov    %edx,0xf022e23c
			  }
			  return -E_FAULT;
f0102c30:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102c35:	eb 10                	jmp    f0102c47 <user_mem_check+0x89>
	char * start = NULL;
	start = ROUNDDOWN((char *)va, PGSIZE); 
	end = ROUNDUP((char *)(va + len), PGSIZE);
	pte_t *cur = NULL;

	for(; start < end; start += PGSIZE) {
f0102c37:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102c3d:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102c40:	72 ad                	jb     f0102bef <user_mem_check+0x31>
			  return -E_FAULT;
		}
		
	}
		
	return 0;
f0102c42:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102c47:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102c4a:	5b                   	pop    %ebx
f0102c4b:	5e                   	pop    %esi
f0102c4c:	5f                   	pop    %edi
f0102c4d:	5d                   	pop    %ebp
f0102c4e:	c3                   	ret    

f0102c4f <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102c4f:	55                   	push   %ebp
f0102c50:	89 e5                	mov    %esp,%ebp
f0102c52:	53                   	push   %ebx
f0102c53:	83 ec 04             	sub    $0x4,%esp
f0102c56:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102c59:	8b 45 14             	mov    0x14(%ebp),%eax
f0102c5c:	83 c8 04             	or     $0x4,%eax
f0102c5f:	50                   	push   %eax
f0102c60:	ff 75 10             	pushl  0x10(%ebp)
f0102c63:	ff 75 0c             	pushl  0xc(%ebp)
f0102c66:	53                   	push   %ebx
f0102c67:	e8 52 ff ff ff       	call   f0102bbe <user_mem_check>
f0102c6c:	83 c4 10             	add    $0x10,%esp
f0102c6f:	85 c0                	test   %eax,%eax
f0102c71:	79 21                	jns    f0102c94 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102c73:	83 ec 04             	sub    $0x4,%esp
f0102c76:	ff 35 3c e2 22 f0    	pushl  0xf022e23c
f0102c7c:	ff 73 48             	pushl  0x48(%ebx)
f0102c7f:	68 50 6c 10 f0       	push   $0xf0106c50
f0102c84:	e8 18 09 00 00       	call   f01035a1 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102c89:	89 1c 24             	mov    %ebx,(%esp)
f0102c8c:	e8 20 06 00 00       	call   f01032b1 <env_destroy>
f0102c91:	83 c4 10             	add    $0x10,%esp
	}
}
f0102c94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102c97:	c9                   	leave  
f0102c98:	c3                   	ret    

f0102c99 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
// 为用户环境分配物理空间
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102c99:	55                   	push   %ebp
f0102c9a:	89 e5                	mov    %esp,%ebp
f0102c9c:	57                   	push   %edi
f0102c9d:	56                   	push   %esi
f0102c9e:	53                   	push   %ebx
f0102c9f:	83 ec 0c             	sub    $0xc,%esp
f0102ca2:	89 c7                	mov    %eax,%edi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *vas, *vat;

	vas = ROUNDDOWN(va, PGSIZE);
f0102ca4:	89 d3                	mov    %edx,%ebx
f0102ca6:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	vat = ROUNDUP(va + len, PGSIZE);
f0102cac:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102cb3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi

	for (; vas < vat; vas += PGSIZE) {
f0102cb9:	eb 3d                	jmp    f0102cf8 <region_alloc+0x5f>
		struct PageInfo *pp = page_alloc(0);
f0102cbb:	83 ec 0c             	sub    $0xc,%esp
f0102cbe:	6a 00                	push   $0x0
f0102cc0:	e8 7d e1 ff ff       	call   f0100e42 <page_alloc>
		if (pp == NULL)
f0102cc5:	83 c4 10             	add    $0x10,%esp
f0102cc8:	85 c0                	test   %eax,%eax
f0102cca:	75 17                	jne    f0102ce3 <region_alloc+0x4a>
			panic("region_alloc: allocation failed.");
f0102ccc:	83 ec 04             	sub    $0x4,%esp
f0102ccf:	68 c8 6f 10 f0       	push   $0xf0106fc8
f0102cd4:	68 38 01 00 00       	push   $0x138
f0102cd9:	68 0c 70 10 f0       	push   $0xf010700c
f0102cde:	e8 5d d3 ff ff       	call   f0100040 <_panic>
		page_insert(e->env_pgdir, pp, vas, PTE_U | PTE_W);
f0102ce3:	6a 06                	push   $0x6
f0102ce5:	53                   	push   %ebx
f0102ce6:	50                   	push   %eax
f0102ce7:	ff 77 60             	pushl  0x60(%edi)
f0102cea:	e8 29 e4 ff ff       	call   f0101118 <page_insert>
	void *vas, *vat;

	vas = ROUNDDOWN(va, PGSIZE);
	vat = ROUNDUP(va + len, PGSIZE);

	for (; vas < vat; vas += PGSIZE) {
f0102cef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102cf5:	83 c4 10             	add    $0x10,%esp
f0102cf8:	39 f3                	cmp    %esi,%ebx
f0102cfa:	72 bf                	jb     f0102cbb <region_alloc+0x22>
		struct PageInfo *pp = page_alloc(0);
		if (pp == NULL)
			panic("region_alloc: allocation failed.");
		page_insert(e->env_pgdir, pp, vas, PTE_U | PTE_W);
	}
}
f0102cfc:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102cff:	5b                   	pop    %ebx
f0102d00:	5e                   	pop    %esi
f0102d01:	5f                   	pop    %edi
f0102d02:	5d                   	pop    %ebp
f0102d03:	c3                   	ret    

f0102d04 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102d04:	55                   	push   %ebp
f0102d05:	89 e5                	mov    %esp,%ebp
f0102d07:	56                   	push   %esi
f0102d08:	53                   	push   %ebx
f0102d09:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d0c:	8b 55 10             	mov    0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102d0f:	85 c0                	test   %eax,%eax
f0102d11:	75 1a                	jne    f0102d2d <envid2env+0x29>
		*env_store = curenv;
f0102d13:	e8 7a 2a 00 00       	call   f0105792 <cpunum>
f0102d18:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d1b:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0102d21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102d24:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102d26:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d2b:	eb 70                	jmp    f0102d9d <envid2env+0x99>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102d2d:	89 c3                	mov    %eax,%ebx
f0102d2f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0102d35:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0102d38:	03 1d 48 e2 22 f0    	add    0xf022e248,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102d3e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0102d42:	74 05                	je     f0102d49 <envid2env+0x45>
f0102d44:	3b 43 48             	cmp    0x48(%ebx),%eax
f0102d47:	74 10                	je     f0102d59 <envid2env+0x55>
		*env_store = 0;
f0102d49:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d4c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102d52:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d57:	eb 44                	jmp    f0102d9d <envid2env+0x99>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102d59:	84 d2                	test   %dl,%dl
f0102d5b:	74 36                	je     f0102d93 <envid2env+0x8f>
f0102d5d:	e8 30 2a 00 00       	call   f0105792 <cpunum>
f0102d62:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d65:	3b 98 28 f0 22 f0    	cmp    -0xfdd0fd8(%eax),%ebx
f0102d6b:	74 26                	je     f0102d93 <envid2env+0x8f>
f0102d6d:	8b 73 4c             	mov    0x4c(%ebx),%esi
f0102d70:	e8 1d 2a 00 00       	call   f0105792 <cpunum>
f0102d75:	6b c0 74             	imul   $0x74,%eax,%eax
f0102d78:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0102d7e:	3b 70 48             	cmp    0x48(%eax),%esi
f0102d81:	74 10                	je     f0102d93 <envid2env+0x8f>
		*env_store = 0;
f0102d83:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d86:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102d8c:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102d91:	eb 0a                	jmp    f0102d9d <envid2env+0x99>
	}

	*env_store = e;
f0102d93:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102d96:	89 18                	mov    %ebx,(%eax)
	return 0;
f0102d98:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102d9d:	5b                   	pop    %ebx
f0102d9e:	5e                   	pop    %esi
f0102d9f:	5d                   	pop    %ebp
f0102da0:	c3                   	ret    

f0102da1 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102da1:	55                   	push   %ebp
f0102da2:	89 e5                	mov    %esp,%ebp
}

static inline void
lgdt(void *p)
{
	asm volatile("lgdt (%0)" : : "r" (p));
f0102da4:	b8 20 f3 11 f0       	mov    $0xf011f320,%eax
f0102da9:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" : : "a" (GD_UD|3));
f0102dac:	b8 23 00 00 00       	mov    $0x23,%eax
f0102db1:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" : : "a" (GD_UD|3));
f0102db3:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" : : "a" (GD_KD));
f0102db5:	b8 10 00 00 00       	mov    $0x10,%eax
f0102dba:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" : : "a" (GD_KD));
f0102dbc:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" : : "a" (GD_KD));
f0102dbe:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" : : "i" (GD_KT));
f0102dc0:	ea c7 2d 10 f0 08 00 	ljmp   $0x8,$0xf0102dc7
}

static inline void
lldt(uint16_t sel)
{
	asm volatile("lldt %0" : : "r" (sel));
f0102dc7:	b8 00 00 00 00       	mov    $0x0,%eax
f0102dcc:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102dcf:	5d                   	pop    %ebp
f0102dd0:	c3                   	ret    

f0102dd1 <env_init>:
// 初始化所有的在envs数组中的 Env结构体，并把它们加入到 env_free_list中
// 与page_init()类似
// 要求所有的 Env 在 env_free_list 中的顺序，要和它在 envs 中的顺序一致
void
env_init(void)
{
f0102dd1:	55                   	push   %ebp
f0102dd2:	89 e5                	mov    %esp,%ebp
f0102dd4:	56                   	push   %esi
f0102dd5:	53                   	push   %ebx
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	//从 NENV-1 到 0， 保证第一次分配的是envs[0]
	for (i = NENV-1; i >= 0; i--) {
		envs[i].env_status = ENV_FREE;
f0102dd6:	8b 35 48 e2 22 f0    	mov    0xf022e248,%esi
f0102ddc:	8b 15 4c e2 22 f0    	mov    0xf022e24c,%edx
f0102de2:	8d 86 84 ef 01 00    	lea    0x1ef84(%esi),%eax
f0102de8:	8d 5e 84             	lea    -0x7c(%esi),%ebx
f0102deb:	89 c1                	mov    %eax,%ecx
f0102ded:	c7 40 54 00 00 00 00 	movl   $0x0,0x54(%eax)
		envs[i].env_id = 0;
f0102df4:	c7 40 48 00 00 00 00 	movl   $0x0,0x48(%eax)
		envs[i].env_link = env_free_list;
f0102dfb:	89 50 44             	mov    %edx,0x44(%eax)
f0102dfe:	83 e8 7c             	sub    $0x7c,%eax
		env_free_list = envs + i;
f0102e01:	89 ca                	mov    %ecx,%edx
{
	// Set up envs array
	// LAB 3: Your code here.
	int i;
	//从 NENV-1 到 0， 保证第一次分配的是envs[0]
	for (i = NENV-1; i >= 0; i--) {
f0102e03:	39 d8                	cmp    %ebx,%eax
f0102e05:	75 e4                	jne    f0102deb <env_init+0x1a>
f0102e07:	89 35 4c e2 22 f0    	mov    %esi,0xf022e24c
		envs[i].env_id = 0;
		envs[i].env_link = env_free_list;
		env_free_list = envs + i;
	}
	// Per-CPU part of the initialization
	env_init_percpu();
f0102e0d:	e8 8f ff ff ff       	call   f0102da1 <env_init_percpu>
}
f0102e12:	5b                   	pop    %ebx
f0102e13:	5e                   	pop    %esi
f0102e14:	5d                   	pop    %ebp
f0102e15:	c3                   	ret    

f0102e16 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102e16:	55                   	push   %ebp
f0102e17:	89 e5                	mov    %esp,%ebp
f0102e19:	53                   	push   %ebx
f0102e1a:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0102e1d:	8b 1d 4c e2 22 f0    	mov    0xf022e24c,%ebx
f0102e23:	85 db                	test   %ebx,%ebx
f0102e25:	0f 84 73 01 00 00    	je     f0102f9e <env_alloc+0x188>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102e2b:	83 ec 0c             	sub    $0xc,%esp
f0102e2e:	6a 01                	push   $0x1
f0102e30:	e8 0d e0 ff ff       	call   f0100e42 <page_alloc>
f0102e35:	83 c4 10             	add    $0x10,%esp
f0102e38:	85 c0                	test   %eax,%eax
f0102e3a:	0f 84 65 01 00 00    	je     f0102fa5 <env_alloc+0x18f>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e40:	89 c2                	mov    %eax,%edx
f0102e42:	2b 15 90 ee 22 f0    	sub    0xf022ee90,%edx
f0102e48:	c1 fa 03             	sar    $0x3,%edx
f0102e4b:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102e4e:	89 d1                	mov    %edx,%ecx
f0102e50:	c1 e9 0c             	shr    $0xc,%ecx
f0102e53:	3b 0d 88 ee 22 f0    	cmp    0xf022ee88,%ecx
f0102e59:	72 12                	jb     f0102e6d <env_alloc+0x57>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102e5b:	52                   	push   %edx
f0102e5c:	68 44 5e 10 f0       	push   $0xf0105e44
f0102e61:	6a 58                	push   $0x58
f0102e63:	68 91 6c 10 f0       	push   $0xf0106c91
f0102e68:	e8 d3 d1 ff ff       	call   f0100040 <_panic>
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	
	// 初始化页目录
	e->env_pgdir = (pde_t *) page2kva(p);
f0102e6d:	81 ea 00 00 00 10    	sub    $0x10000000,%edx
f0102e73:	89 53 60             	mov    %edx,0x60(%ebx)
	p->pp_ref++;
f0102e76:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0102e7b:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	
	// 初始化与内核相关的页目录项
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
		e->env_pgdir[i] = kern_pgdir[i];
f0102e80:	8b 15 8c ee 22 f0    	mov    0xf022ee8c,%edx
f0102e86:	8b 0c 02             	mov    (%edx,%eax,1),%ecx
f0102e89:	8b 53 60             	mov    0x60(%ebx),%edx
f0102e8c:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0102e8f:	83 c0 04             	add    $0x4,%eax
	// 初始化页目录
	e->env_pgdir = (pde_t *) page2kva(p);
	p->pp_ref++;
	
	// 初始化与内核相关的页目录项
	for (i = PDX(UTOP); i < NPDENTRIES; i++)
f0102e92:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102e97:	75 e7                	jne    f0102e80 <env_alloc+0x6a>
	


	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102e99:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e9c:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ea1:	77 15                	ja     f0102eb8 <env_alloc+0xa2>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0102ea3:	50                   	push   %eax
f0102ea4:	68 68 5e 10 f0       	push   $0xf0105e68
f0102ea9:	68 d1 00 00 00       	push   $0xd1
f0102eae:	68 0c 70 10 f0       	push   $0xf010700c
f0102eb3:	e8 88 d1 ff ff       	call   f0100040 <_panic>
f0102eb8:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102ebe:	83 ca 05             	or     $0x5,%edx
f0102ec1:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102ec7:	8b 43 48             	mov    0x48(%ebx),%eax
f0102eca:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102ecf:	25 00 fc ff ff       	and    $0xfffffc00,%eax
		generation = 1 << ENVGENSHIFT;
f0102ed4:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102ed9:	0f 4e c2             	cmovle %edx,%eax
	e->env_id = generation | (e - envs);
f0102edc:	89 da                	mov    %ebx,%edx
f0102ede:	2b 15 48 e2 22 f0    	sub    0xf022e248,%edx
f0102ee4:	c1 fa 02             	sar    $0x2,%edx
f0102ee7:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0102eed:	09 d0                	or     %edx,%eax
f0102eef:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102ef2:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102ef5:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0102ef8:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0102eff:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102f06:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102f0d:	83 ec 04             	sub    $0x4,%esp
f0102f10:	6a 44                	push   $0x44
f0102f12:	6a 00                	push   $0x0
f0102f14:	53                   	push   %ebx
f0102f15:	e8 58 22 00 00       	call   f0105172 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0102f1a:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102f20:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102f26:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102f2c:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102f33:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
	// You will set e->env_tf.tf_eip later.

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.
	e->env_tf.tf_eflags |= FL_IF;
f0102f39:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0102f40:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0102f47:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0102f4b:	8b 43 44             	mov    0x44(%ebx),%eax
f0102f4e:	a3 4c e2 22 f0       	mov    %eax,0xf022e24c
	*newenv_store = e;
f0102f53:	8b 45 08             	mov    0x8(%ebp),%eax
f0102f56:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102f58:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0102f5b:	e8 32 28 00 00       	call   f0105792 <cpunum>
f0102f60:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f63:	83 c4 10             	add    $0x10,%esp
f0102f66:	ba 00 00 00 00       	mov    $0x0,%edx
f0102f6b:	83 b8 28 f0 22 f0 00 	cmpl   $0x0,-0xfdd0fd8(%eax)
f0102f72:	74 11                	je     f0102f85 <env_alloc+0x16f>
f0102f74:	e8 19 28 00 00       	call   f0105792 <cpunum>
f0102f79:	6b c0 74             	imul   $0x74,%eax,%eax
f0102f7c:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0102f82:	8b 50 48             	mov    0x48(%eax),%edx
f0102f85:	83 ec 04             	sub    $0x4,%esp
f0102f88:	53                   	push   %ebx
f0102f89:	52                   	push   %edx
f0102f8a:	68 17 70 10 f0       	push   $0xf0107017
f0102f8f:	e8 0d 06 00 00       	call   f01035a1 <cprintf>
	return 0;
f0102f94:	83 c4 10             	add    $0x10,%esp
f0102f97:	b8 00 00 00 00       	mov    $0x0,%eax
f0102f9c:	eb 0c                	jmp    f0102faa <env_alloc+0x194>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
		return -E_NO_FREE_ENV;
f0102f9e:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102fa3:	eb 05                	jmp    f0102faa <env_alloc+0x194>
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102fa5:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102faa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102fad:	c9                   	leave  
f0102fae:	c3                   	ret    

f0102faf <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, enum EnvType type)
{
f0102faf:	55                   	push   %ebp
f0102fb0:	89 e5                	mov    %esp,%ebp
f0102fb2:	57                   	push   %edi
f0102fb3:	56                   	push   %esi
f0102fb4:	53                   	push   %ebx
f0102fb5:	83 ec 34             	sub    $0x34,%esp
f0102fb8:	8b 7d 08             	mov    0x8(%ebp),%edi
	// LAB 3: Your code here.
	struct Env *e;
	int errorcode;

	if ((errorcode=env_alloc(&e, 0)) < 0)
f0102fbb:	6a 00                	push   $0x0
f0102fbd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102fc0:	50                   	push   %eax
f0102fc1:	e8 50 fe ff ff       	call   f0102e16 <env_alloc>
f0102fc6:	83 c4 10             	add    $0x10,%esp
f0102fc9:	85 c0                	test   %eax,%eax
f0102fcb:	79 15                	jns    f0102fe2 <env_create+0x33>
		panic("env_create: %e", errorcode);
f0102fcd:	50                   	push   %eax
f0102fce:	68 2c 70 10 f0       	push   $0xf010702c
f0102fd3:	68 a7 01 00 00       	push   $0x1a7
f0102fd8:	68 0c 70 10 f0       	push   $0xf010700c
f0102fdd:	e8 5e d0 ff ff       	call   f0100040 <_panic>

	load_icode(e, binary);
f0102fe2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102fe5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	struct Proghdr *ph, *eph;

	ELFHDR = (struct Elf *) binary;

	//根据文件魔数是否ELF文件
	if (ELFHDR->e_magic != ELF_MAGIC)
f0102fe8:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102fee:	74 17                	je     f0103007 <env_create+0x58>
		panic("load_icode: not ELF executable.");
f0102ff0:	83 ec 04             	sub    $0x4,%esp
f0102ff3:	68 ec 6f 10 f0       	push   $0xf0106fec
f0102ff8:	68 7a 01 00 00       	push   $0x17a
f0102ffd:	68 0c 70 10 f0       	push   $0xf010700c
f0103002:	e8 39 d0 ff ff       	call   f0100040 <_panic>

	ph = (struct Proghdr *) (binary + ELFHDR->e_phoff);
f0103007:	89 fb                	mov    %edi,%ebx
f0103009:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f010300c:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0103010:	c1 e6 05             	shl    $0x5,%esi
f0103013:	01 de                	add    %ebx,%esi

	lcr3(PADDR(e->env_pgdir));
f0103015:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103018:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010301b:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103020:	77 15                	ja     f0103037 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103022:	50                   	push   %eax
f0103023:	68 68 5e 10 f0       	push   $0xf0105e68
f0103028:	68 7f 01 00 00       	push   $0x17f
f010302d:	68 0c 70 10 f0       	push   $0xf010700c
f0103032:	e8 09 d0 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f0103037:	05 00 00 00 10       	add    $0x10000000,%eax
f010303c:	0f 22 d8             	mov    %eax,%cr3
f010303f:	eb 3d                	jmp    f010307e <env_create+0xcf>

	//program header记录着需要加载到内存里的部分
	for (; ph < eph; ph++) {
		if (ph->p_type == ELF_PROG_LOAD) {
f0103041:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103044:	75 35                	jne    f010307b <env_create+0xcc>
			region_alloc(e, (void *) ph->p_va, ph->p_memsz);
f0103046:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103049:	8b 53 08             	mov    0x8(%ebx),%edx
f010304c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010304f:	e8 45 fc ff ff       	call   f0102c99 <region_alloc>
			memset((void *) ph->p_va, 0, ph->p_memsz);
f0103054:	83 ec 04             	sub    $0x4,%esp
f0103057:	ff 73 14             	pushl  0x14(%ebx)
f010305a:	6a 00                	push   $0x0
f010305c:	ff 73 08             	pushl  0x8(%ebx)
f010305f:	e8 0e 21 00 00       	call   f0105172 <memset>
			memcpy((void *) ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103064:	83 c4 0c             	add    $0xc,%esp
f0103067:	ff 73 10             	pushl  0x10(%ebx)
f010306a:	89 f8                	mov    %edi,%eax
f010306c:	03 43 04             	add    0x4(%ebx),%eax
f010306f:	50                   	push   %eax
f0103070:	ff 73 08             	pushl  0x8(%ebx)
f0103073:	e8 af 21 00 00       	call   f0105227 <memcpy>
f0103078:	83 c4 10             	add    $0x10,%esp
	eph = ph + ELFHDR->e_phnum;

	lcr3(PADDR(e->env_pgdir));

	//program header记录着需要加载到内存里的部分
	for (; ph < eph; ph++) {
f010307b:	83 c3 20             	add    $0x20,%ebx
f010307e:	39 de                	cmp    %ebx,%esi
f0103080:	77 bf                	ja     f0103041 <env_create+0x92>
			memset((void *) ph->p_va, 0, ph->p_memsz);
			memcpy((void *) ph->p_va, binary + ph->p_offset, ph->p_filesz);
		}
	}

	lcr3(PADDR(kern_pgdir));
f0103082:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103087:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010308c:	77 15                	ja     f01030a3 <env_create+0xf4>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010308e:	50                   	push   %eax
f010308f:	68 68 5e 10 f0       	push   $0xf0105e68
f0103094:	68 8a 01 00 00       	push   $0x18a
f0103099:	68 0c 70 10 f0       	push   $0xf010700c
f010309e:	e8 9d cf ff ff       	call   f0100040 <_panic>
f01030a3:	05 00 00 00 10       	add    $0x10000000,%eax
f01030a8:	0f 22 d8             	mov    %eax,%cr3
	
	// 设置程序的入口位置
	// 最重要这一句啦
	e->env_tf.tf_eip = ELFHDR->e_entry;
f01030ab:	8b 47 18             	mov    0x18(%edi),%eax
f01030ae:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01030b1:	89 47 30             	mov    %eax,0x30(%edi)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.

	// LAB 3: Your code here.
	// 进程运行栈
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f01030b4:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01030b9:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f01030be:	89 f8                	mov    %edi,%eax
f01030c0:	e8 d4 fb ff ff       	call   f0102c99 <region_alloc>
	if ((errorcode=env_alloc(&e, 0)) < 0)
		panic("env_create: %e", errorcode);

	load_icode(e, binary);

	e->env_type = type;
f01030c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01030c8:	8b 55 0c             	mov    0xc(%ebp),%edx
f01030cb:	89 50 50             	mov    %edx,0x50(%eax)
}
f01030ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01030d1:	5b                   	pop    %ebx
f01030d2:	5e                   	pop    %esi
f01030d3:	5f                   	pop    %edi
f01030d4:	5d                   	pop    %ebp
f01030d5:	c3                   	ret    

f01030d6 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01030d6:	55                   	push   %ebp
f01030d7:	89 e5                	mov    %esp,%ebp
f01030d9:	57                   	push   %edi
f01030da:	56                   	push   %esi
f01030db:	53                   	push   %ebx
f01030dc:	83 ec 1c             	sub    $0x1c,%esp
f01030df:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01030e2:	e8 ab 26 00 00       	call   f0105792 <cpunum>
f01030e7:	6b c0 74             	imul   $0x74,%eax,%eax
f01030ea:	39 b8 28 f0 22 f0    	cmp    %edi,-0xfdd0fd8(%eax)
f01030f0:	75 29                	jne    f010311b <env_free+0x45>
		lcr3(PADDR(kern_pgdir));
f01030f2:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030f7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030fc:	77 15                	ja     f0103113 <env_free+0x3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030fe:	50                   	push   %eax
f01030ff:	68 68 5e 10 f0       	push   $0xf0105e68
f0103104:	68 bc 01 00 00       	push   $0x1bc
f0103109:	68 0c 70 10 f0       	push   $0xf010700c
f010310e:	e8 2d cf ff ff       	call   f0100040 <_panic>
f0103113:	05 00 00 00 10       	add    $0x10000000,%eax
f0103118:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f010311b:	8b 5f 48             	mov    0x48(%edi),%ebx
f010311e:	e8 6f 26 00 00       	call   f0105792 <cpunum>
f0103123:	6b c0 74             	imul   $0x74,%eax,%eax
f0103126:	ba 00 00 00 00       	mov    $0x0,%edx
f010312b:	83 b8 28 f0 22 f0 00 	cmpl   $0x0,-0xfdd0fd8(%eax)
f0103132:	74 11                	je     f0103145 <env_free+0x6f>
f0103134:	e8 59 26 00 00       	call   f0105792 <cpunum>
f0103139:	6b c0 74             	imul   $0x74,%eax,%eax
f010313c:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0103142:	8b 50 48             	mov    0x48(%eax),%edx
f0103145:	83 ec 04             	sub    $0x4,%esp
f0103148:	53                   	push   %ebx
f0103149:	52                   	push   %edx
f010314a:	68 3b 70 10 f0       	push   $0xf010703b
f010314f:	e8 4d 04 00 00       	call   f01035a1 <cprintf>
f0103154:	83 c4 10             	add    $0x10,%esp

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103157:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f010315e:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0103161:	89 d0                	mov    %edx,%eax
f0103163:	c1 e0 02             	shl    $0x2,%eax
f0103166:	89 45 dc             	mov    %eax,-0x24(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103169:	8b 47 60             	mov    0x60(%edi),%eax
f010316c:	8b 34 90             	mov    (%eax,%edx,4),%esi
f010316f:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0103175:	0f 84 a8 00 00 00    	je     f0103223 <env_free+0x14d>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f010317b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103181:	89 f0                	mov    %esi,%eax
f0103183:	c1 e8 0c             	shr    $0xc,%eax
f0103186:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103189:	39 05 88 ee 22 f0    	cmp    %eax,0xf022ee88
f010318f:	77 15                	ja     f01031a6 <env_free+0xd0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103191:	56                   	push   %esi
f0103192:	68 44 5e 10 f0       	push   $0xf0105e44
f0103197:	68 cb 01 00 00       	push   $0x1cb
f010319c:	68 0c 70 10 f0       	push   $0xf010700c
f01031a1:	e8 9a ce ff ff       	call   f0100040 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01031a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01031a9:	c1 e0 16             	shl    $0x16,%eax
f01031ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01031af:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f01031b4:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01031bb:	01 
f01031bc:	74 17                	je     f01031d5 <env_free+0xff>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01031be:	83 ec 08             	sub    $0x8,%esp
f01031c1:	89 d8                	mov    %ebx,%eax
f01031c3:	c1 e0 0c             	shl    $0xc,%eax
f01031c6:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01031c9:	50                   	push   %eax
f01031ca:	ff 77 60             	pushl  0x60(%edi)
f01031cd:	e8 f6 de ff ff       	call   f01010c8 <page_remove>
f01031d2:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01031d5:	83 c3 01             	add    $0x1,%ebx
f01031d8:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01031de:	75 d4                	jne    f01031b4 <env_free+0xde>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01031e0:	8b 47 60             	mov    0x60(%edi),%eax
f01031e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01031e6:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01031ed:	8b 45 d8             	mov    -0x28(%ebp),%eax
f01031f0:	3b 05 88 ee 22 f0    	cmp    0xf022ee88,%eax
f01031f6:	72 14                	jb     f010320c <env_free+0x136>
		panic("pa2page called with invalid pa");
f01031f8:	83 ec 04             	sub    $0x4,%esp
f01031fb:	68 24 64 10 f0       	push   $0xf0106424
f0103200:	6a 51                	push   $0x51
f0103202:	68 91 6c 10 f0       	push   $0xf0106c91
f0103207:	e8 34 ce ff ff       	call   f0100040 <_panic>
		page_decref(pa2page(pa));
f010320c:	83 ec 0c             	sub    $0xc,%esp
f010320f:	a1 90 ee 22 f0       	mov    0xf022ee90,%eax
f0103214:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0103217:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f010321a:	50                   	push   %eax
f010321b:	e8 05 dd ff ff       	call   f0100f25 <page_decref>
f0103220:	83 c4 10             	add    $0x10,%esp
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0103223:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103227:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010322a:	3d bb 03 00 00       	cmp    $0x3bb,%eax
f010322f:	0f 85 29 ff ff ff    	jne    f010315e <env_free+0x88>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0103235:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103238:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010323d:	77 15                	ja     f0103254 <env_free+0x17e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010323f:	50                   	push   %eax
f0103240:	68 68 5e 10 f0       	push   $0xf0105e68
f0103245:	68 d9 01 00 00       	push   $0x1d9
f010324a:	68 0c 70 10 f0       	push   $0xf010700c
f010324f:	e8 ec cd ff ff       	call   f0100040 <_panic>
	e->env_pgdir = 0;
f0103254:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010325b:	05 00 00 00 10       	add    $0x10000000,%eax
f0103260:	c1 e8 0c             	shr    $0xc,%eax
f0103263:	3b 05 88 ee 22 f0    	cmp    0xf022ee88,%eax
f0103269:	72 14                	jb     f010327f <env_free+0x1a9>
		panic("pa2page called with invalid pa");
f010326b:	83 ec 04             	sub    $0x4,%esp
f010326e:	68 24 64 10 f0       	push   $0xf0106424
f0103273:	6a 51                	push   $0x51
f0103275:	68 91 6c 10 f0       	push   $0xf0106c91
f010327a:	e8 c1 cd ff ff       	call   f0100040 <_panic>
	page_decref(pa2page(pa));
f010327f:	83 ec 0c             	sub    $0xc,%esp
f0103282:	8b 15 90 ee 22 f0    	mov    0xf022ee90,%edx
f0103288:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f010328b:	50                   	push   %eax
f010328c:	e8 94 dc ff ff       	call   f0100f25 <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f0103291:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103298:	a1 4c e2 22 f0       	mov    0xf022e24c,%eax
f010329d:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01032a0:	89 3d 4c e2 22 f0    	mov    %edi,0xf022e24c
}
f01032a6:	83 c4 10             	add    $0x10,%esp
f01032a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01032ac:	5b                   	pop    %ebx
f01032ad:	5e                   	pop    %esi
f01032ae:	5f                   	pop    %edi
f01032af:	5d                   	pop    %ebp
f01032b0:	c3                   	ret    

f01032b1 <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01032b1:	55                   	push   %ebp
f01032b2:	89 e5                	mov    %esp,%ebp
f01032b4:	53                   	push   %ebx
f01032b5:	83 ec 04             	sub    $0x4,%esp
f01032b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01032bb:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01032bf:	75 19                	jne    f01032da <env_destroy+0x29>
f01032c1:	e8 cc 24 00 00       	call   f0105792 <cpunum>
f01032c6:	6b c0 74             	imul   $0x74,%eax,%eax
f01032c9:	3b 98 28 f0 22 f0    	cmp    -0xfdd0fd8(%eax),%ebx
f01032cf:	74 09                	je     f01032da <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01032d1:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f01032d8:	eb 33                	jmp    f010330d <env_destroy+0x5c>
	}

	env_free(e);
f01032da:	83 ec 0c             	sub    $0xc,%esp
f01032dd:	53                   	push   %ebx
f01032de:	e8 f3 fd ff ff       	call   f01030d6 <env_free>

	if (curenv == e) {
f01032e3:	e8 aa 24 00 00       	call   f0105792 <cpunum>
f01032e8:	6b c0 74             	imul   $0x74,%eax,%eax
f01032eb:	83 c4 10             	add    $0x10,%esp
f01032ee:	3b 98 28 f0 22 f0    	cmp    -0xfdd0fd8(%eax),%ebx
f01032f4:	75 17                	jne    f010330d <env_destroy+0x5c>
		curenv = NULL;
f01032f6:	e8 97 24 00 00       	call   f0105792 <cpunum>
f01032fb:	6b c0 74             	imul   $0x74,%eax,%eax
f01032fe:	c7 80 28 f0 22 f0 00 	movl   $0x0,-0xfdd0fd8(%eax)
f0103305:	00 00 00 
		sched_yield();
f0103308:	e8 7d 0d 00 00       	call   f010408a <sched_yield>
	}
}
f010330d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103310:	c9                   	leave  
f0103311:	c3                   	ret    

f0103312 <env_pop_tf>:
//
// This function does not return.
// 将相应数据pop到寄存器，开始执行
void
env_pop_tf(struct Trapframe *tf)
{
f0103312:	55                   	push   %ebp
f0103313:	89 e5                	mov    %esp,%ebp
f0103315:	53                   	push   %ebx
f0103316:	83 ec 04             	sub    $0x4,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f0103319:	e8 74 24 00 00       	call   f0105792 <cpunum>
f010331e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103321:	8b 98 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%ebx
f0103327:	e8 66 24 00 00       	call   f0105792 <cpunum>
f010332c:	89 43 5c             	mov    %eax,0x5c(%ebx)

	asm volatile(
f010332f:	8b 65 08             	mov    0x8(%ebp),%esp
f0103332:	61                   	popa   
f0103333:	07                   	pop    %es
f0103334:	1f                   	pop    %ds
f0103335:	83 c4 08             	add    $0x8,%esp
f0103338:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret\n"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f0103339:	83 ec 04             	sub    $0x4,%esp
f010333c:	68 51 70 10 f0       	push   $0xf0107051
f0103341:	68 10 02 00 00       	push   $0x210
f0103346:	68 0c 70 10 f0       	push   $0xf010700c
f010334b:	e8 f0 cc ff ff       	call   f0100040 <_panic>

f0103350 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f0103350:	55                   	push   %ebp
f0103351:	89 e5                	mov    %esp,%ebp
f0103353:	83 ec 08             	sub    $0x8,%esp

	// LAB 3: Your code here.


	//panic("env_run not yet implemented");
	if (curenv != NULL && curenv->env_status == ENV_RUNNING)
f0103356:	e8 37 24 00 00       	call   f0105792 <cpunum>
f010335b:	6b c0 74             	imul   $0x74,%eax,%eax
f010335e:	83 b8 28 f0 22 f0 00 	cmpl   $0x0,-0xfdd0fd8(%eax)
f0103365:	74 29                	je     f0103390 <env_run+0x40>
f0103367:	e8 26 24 00 00       	call   f0105792 <cpunum>
f010336c:	6b c0 74             	imul   $0x74,%eax,%eax
f010336f:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0103375:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103379:	75 15                	jne    f0103390 <env_run+0x40>
		curenv->env_status = ENV_RUNNABLE;
f010337b:	e8 12 24 00 00       	call   f0105792 <cpunum>
f0103380:	6b c0 74             	imul   $0x74,%eax,%eax
f0103383:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0103389:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	curenv = e;
f0103390:	e8 fd 23 00 00       	call   f0105792 <cpunum>
f0103395:	6b c0 74             	imul   $0x74,%eax,%eax
f0103398:	8b 55 08             	mov    0x8(%ebp),%edx
f010339b:	89 90 28 f0 22 f0    	mov    %edx,-0xfdd0fd8(%eax)
	curenv->env_status = ENV_RUNNING;
f01033a1:	e8 ec 23 00 00       	call   f0105792 <cpunum>
f01033a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01033a9:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f01033af:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f01033b6:	e8 d7 23 00 00       	call   f0105792 <cpunum>
f01033bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01033be:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f01033c4:	83 40 58 01          	addl   $0x1,0x58(%eax)
	// 加载进程的页目录地址到cr3
	lcr3(PADDR(curenv->env_pgdir));
f01033c8:	e8 c5 23 00 00       	call   f0105792 <cpunum>
f01033cd:	6b c0 74             	imul   $0x74,%eax,%eax
f01033d0:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f01033d6:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01033d9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01033de:	77 15                	ja     f01033f5 <env_run+0xa5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01033e0:	50                   	push   %eax
f01033e1:	68 68 5e 10 f0       	push   $0xf0105e68
f01033e6:	68 37 02 00 00       	push   $0x237
f01033eb:	68 0c 70 10 f0       	push   $0xf010700c
f01033f0:	e8 4b cc ff ff       	call   f0100040 <_panic>
f01033f5:	05 00 00 00 10       	add    $0x10000000,%eax
f01033fa:	0f 22 d8             	mov    %eax,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01033fd:	83 ec 0c             	sub    $0xc,%esp
f0103400:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103405:	e8 93 26 00 00       	call   f0105a9d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f010340a:	f3 90                	pause  
	// 释放内核锁
	unlock_kernel();
	//开始执行
	env_pop_tf(&curenv->env_tf);
f010340c:	e8 81 23 00 00       	call   f0105792 <cpunum>
f0103411:	83 c4 04             	add    $0x4,%esp
f0103414:	6b c0 74             	imul   $0x74,%eax,%eax
f0103417:	ff b0 28 f0 22 f0    	pushl  -0xfdd0fd8(%eax)
f010341d:	e8 f0 fe ff ff       	call   f0103312 <env_pop_tf>

f0103422 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103422:	55                   	push   %ebp
f0103423:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103425:	ba 70 00 00 00       	mov    $0x70,%edx
f010342a:	8b 45 08             	mov    0x8(%ebp),%eax
f010342d:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010342e:	ba 71 00 00 00       	mov    $0x71,%edx
f0103433:	ec                   	in     (%dx),%al
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
f0103434:	0f b6 c0             	movzbl %al,%eax
}
f0103437:	5d                   	pop    %ebp
f0103438:	c3                   	ret    

f0103439 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103439:	55                   	push   %ebp
f010343a:	89 e5                	mov    %esp,%ebp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010343c:	ba 70 00 00 00       	mov    $0x70,%edx
f0103441:	8b 45 08             	mov    0x8(%ebp),%eax
f0103444:	ee                   	out    %al,(%dx)
f0103445:	ba 71 00 00 00       	mov    $0x71,%edx
f010344a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010344d:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f010344e:	5d                   	pop    %ebp
f010344f:	c3                   	ret    

f0103450 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103450:	55                   	push   %ebp
f0103451:	89 e5                	mov    %esp,%ebp
f0103453:	56                   	push   %esi
f0103454:	53                   	push   %ebx
f0103455:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f0103458:	66 a3 a8 f3 11 f0    	mov    %ax,0xf011f3a8
	if (!didinit)
f010345e:	80 3d 50 e2 22 f0 00 	cmpb   $0x0,0xf022e250
f0103465:	74 5a                	je     f01034c1 <irq_setmask_8259A+0x71>
f0103467:	89 c6                	mov    %eax,%esi
f0103469:	ba 21 00 00 00       	mov    $0x21,%edx
f010346e:	ee                   	out    %al,(%dx)
f010346f:	66 c1 e8 08          	shr    $0x8,%ax
f0103473:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103478:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103479:	83 ec 0c             	sub    $0xc,%esp
f010347c:	68 5d 70 10 f0       	push   $0xf010705d
f0103481:	e8 1b 01 00 00       	call   f01035a1 <cprintf>
f0103486:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103489:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010348e:	0f b7 f6             	movzwl %si,%esi
f0103491:	f7 d6                	not    %esi
f0103493:	0f a3 de             	bt     %ebx,%esi
f0103496:	73 11                	jae    f01034a9 <irq_setmask_8259A+0x59>
			cprintf(" %d", i);
f0103498:	83 ec 08             	sub    $0x8,%esp
f010349b:	53                   	push   %ebx
f010349c:	68 3b 75 10 f0       	push   $0xf010753b
f01034a1:	e8 fb 00 00 00       	call   f01035a1 <cprintf>
f01034a6:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f01034a9:	83 c3 01             	add    $0x1,%ebx
f01034ac:	83 fb 10             	cmp    $0x10,%ebx
f01034af:	75 e2                	jne    f0103493 <irq_setmask_8259A+0x43>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f01034b1:	83 ec 0c             	sub    $0xc,%esp
f01034b4:	68 94 6f 10 f0       	push   $0xf0106f94
f01034b9:	e8 e3 00 00 00       	call   f01035a1 <cprintf>
f01034be:	83 c4 10             	add    $0x10,%esp
}
f01034c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01034c4:	5b                   	pop    %ebx
f01034c5:	5e                   	pop    %esi
f01034c6:	5d                   	pop    %ebp
f01034c7:	c3                   	ret    

f01034c8 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f01034c8:	c6 05 50 e2 22 f0 01 	movb   $0x1,0xf022e250
f01034cf:	ba 21 00 00 00       	mov    $0x21,%edx
f01034d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01034d9:	ee                   	out    %al,(%dx)
f01034da:	ba a1 00 00 00       	mov    $0xa1,%edx
f01034df:	ee                   	out    %al,(%dx)
f01034e0:	ba 20 00 00 00       	mov    $0x20,%edx
f01034e5:	b8 11 00 00 00       	mov    $0x11,%eax
f01034ea:	ee                   	out    %al,(%dx)
f01034eb:	ba 21 00 00 00       	mov    $0x21,%edx
f01034f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01034f5:	ee                   	out    %al,(%dx)
f01034f6:	b8 04 00 00 00       	mov    $0x4,%eax
f01034fb:	ee                   	out    %al,(%dx)
f01034fc:	b8 03 00 00 00       	mov    $0x3,%eax
f0103501:	ee                   	out    %al,(%dx)
f0103502:	ba a0 00 00 00       	mov    $0xa0,%edx
f0103507:	b8 11 00 00 00       	mov    $0x11,%eax
f010350c:	ee                   	out    %al,(%dx)
f010350d:	ba a1 00 00 00       	mov    $0xa1,%edx
f0103512:	b8 28 00 00 00       	mov    $0x28,%eax
f0103517:	ee                   	out    %al,(%dx)
f0103518:	b8 02 00 00 00       	mov    $0x2,%eax
f010351d:	ee                   	out    %al,(%dx)
f010351e:	b8 01 00 00 00       	mov    $0x1,%eax
f0103523:	ee                   	out    %al,(%dx)
f0103524:	ba 20 00 00 00       	mov    $0x20,%edx
f0103529:	b8 68 00 00 00       	mov    $0x68,%eax
f010352e:	ee                   	out    %al,(%dx)
f010352f:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103534:	ee                   	out    %al,(%dx)
f0103535:	ba a0 00 00 00       	mov    $0xa0,%edx
f010353a:	b8 68 00 00 00       	mov    $0x68,%eax
f010353f:	ee                   	out    %al,(%dx)
f0103540:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103545:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103546:	0f b7 05 a8 f3 11 f0 	movzwl 0xf011f3a8,%eax
f010354d:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103551:	74 13                	je     f0103566 <pic_init+0x9e>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103553:	55                   	push   %ebp
f0103554:	89 e5                	mov    %esp,%ebp
f0103556:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f0103559:	0f b7 c0             	movzwl %ax,%eax
f010355c:	50                   	push   %eax
f010355d:	e8 ee fe ff ff       	call   f0103450 <irq_setmask_8259A>
f0103562:	83 c4 10             	add    $0x10,%esp
}
f0103565:	c9                   	leave  
f0103566:	f3 c3                	repz ret 

f0103568 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103568:	55                   	push   %ebp
f0103569:	89 e5                	mov    %esp,%ebp
f010356b:	83 ec 14             	sub    $0x14,%esp
	cputchar(ch);
f010356e:	ff 75 08             	pushl  0x8(%ebp)
f0103571:	e8 ee d1 ff ff       	call   f0100764 <cputchar>
	*cnt++;
}
f0103576:	83 c4 10             	add    $0x10,%esp
f0103579:	c9                   	leave  
f010357a:	c3                   	ret    

f010357b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f010357b:	55                   	push   %ebp
f010357c:	89 e5                	mov    %esp,%ebp
f010357e:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103581:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103588:	ff 75 0c             	pushl  0xc(%ebp)
f010358b:	ff 75 08             	pushl  0x8(%ebp)
f010358e:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103591:	50                   	push   %eax
f0103592:	68 68 35 10 f0       	push   $0xf0103568
f0103597:	e8 b1 14 00 00       	call   f0104a4d <vprintfmt>
	return cnt;
}
f010359c:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010359f:	c9                   	leave  
f01035a0:	c3                   	ret    

f01035a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01035a1:	55                   	push   %ebp
f01035a2:	89 e5                	mov    %esp,%ebp
f01035a4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01035a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f01035aa:	50                   	push   %eax
f01035ab:	ff 75 08             	pushl  0x8(%ebp)
f01035ae:	e8 c8 ff ff ff       	call   f010357b <vcprintf>
	va_end(ap);

	return cnt;
}
f01035b3:	c9                   	leave  
f01035b4:	c3                   	ret    

f01035b5 <trap_init_percpu>:

// Initialize and load the per-CPU TSS and IDT
// 加载CPU的TSS选择子和IDT中断描述符表
void
trap_init_percpu(void)
{
f01035b5:	55                   	push   %ebp
f01035b6:	89 e5                	mov    %esp,%ebp
f01035b8:	57                   	push   %edi
f01035b9:	56                   	push   %esi
f01035ba:	53                   	push   %ebx
f01035bb:	83 ec 0c             	sub    $0xc,%esp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	//ts.ts_esp0 = KSTACKTOP;
	//ts.ts_ss0 = GD_KD;
	//ts.ts_iomb = sizeof(struct Taskstate);
	int i = cpunum();
f01035be:	e8 cf 21 00 00       	call   f0105792 <cpunum>
f01035c3:	89 c3                	mov    %eax,%ebx

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	thiscpu->cpu_ts.ts_esp0 = KSTACKTOP - i * (KSTKSIZE + KSTKGAP);
f01035c5:	e8 c8 21 00 00       	call   f0105792 <cpunum>
f01035ca:	6b c0 74             	imul   $0x74,%eax,%eax
f01035cd:	89 d9                	mov    %ebx,%ecx
f01035cf:	c1 e1 10             	shl    $0x10,%ecx
f01035d2:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f01035d7:	29 ca                	sub    %ecx,%edx
f01035d9:	89 90 30 f0 22 f0    	mov    %edx,-0xfdd0fd0(%eax)
	thiscpu->cpu_ts.ts_ss0 = GD_KD;		
f01035df:	e8 ae 21 00 00       	call   f0105792 <cpunum>
f01035e4:	6b c0 74             	imul   $0x74,%eax,%eax
f01035e7:	66 c7 80 34 f0 22 f0 	movw   $0x10,-0xfdd0fcc(%eax)
f01035ee:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[(GD_TSS0 >> 3) + i] = SEG16(STS_T32A, (uint32_t)(&(thiscpu->cpu_ts)), 
f01035f0:	83 c3 05             	add    $0x5,%ebx
f01035f3:	e8 9a 21 00 00       	call   f0105792 <cpunum>
f01035f8:	89 c7                	mov    %eax,%edi
f01035fa:	e8 93 21 00 00       	call   f0105792 <cpunum>
f01035ff:	89 c6                	mov    %eax,%esi
f0103601:	e8 8c 21 00 00       	call   f0105792 <cpunum>
f0103606:	66 c7 04 dd 40 f3 11 	movw   $0x67,-0xfee0cc0(,%ebx,8)
f010360d:	f0 67 00 
f0103610:	6b ff 74             	imul   $0x74,%edi,%edi
f0103613:	81 c7 2c f0 22 f0    	add    $0xf022f02c,%edi
f0103619:	66 89 3c dd 42 f3 11 	mov    %di,-0xfee0cbe(,%ebx,8)
f0103620:	f0 
f0103621:	6b d6 74             	imul   $0x74,%esi,%edx
f0103624:	81 c2 2c f0 22 f0    	add    $0xf022f02c,%edx
f010362a:	c1 ea 10             	shr    $0x10,%edx
f010362d:	88 14 dd 44 f3 11 f0 	mov    %dl,-0xfee0cbc(,%ebx,8)
f0103634:	c6 04 dd 46 f3 11 f0 	movb   $0x40,-0xfee0cba(,%ebx,8)
f010363b:	40 
f010363c:	6b c0 74             	imul   $0x74,%eax,%eax
f010363f:	05 2c f0 22 f0       	add    $0xf022f02c,%eax
f0103644:	c1 e8 18             	shr    $0x18,%eax
f0103647:	88 04 dd 47 f3 11 f0 	mov    %al,-0xfee0cb9(,%ebx,8)
					sizeof(struct Taskstate) - 1, 0);
	gdt[(GD_TSS0 >> 3) + i].sd_s = 0;
f010364e:	c6 04 dd 45 f3 11 f0 	movb   $0x89,-0xfee0cbb(,%ebx,8)
f0103655:	89 
}

static inline void
ltr(uint16_t sel)
{
	asm volatile("ltr %0" : : "r" (sel));
f0103656:	c1 e3 03             	shl    $0x3,%ebx
f0103659:	0f 00 db             	ltr    %bx
}

static inline void
lidt(void *p)
{
	asm volatile("lidt (%0)" : : "r" (p));
f010365c:	b8 ac f3 11 f0       	mov    $0xf011f3ac,%eax
f0103661:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0 + 8 * i);

	// Load the IDT
	lidt(&idt_pd);
}
f0103664:	83 c4 0c             	add    $0xc,%esp
f0103667:	5b                   	pop    %ebx
f0103668:	5e                   	pop    %esi
f0103669:	5f                   	pop    %edi
f010366a:	5d                   	pop    %ebp
f010366b:	c3                   	ret    

f010366c <trap_init>:
}


void
trap_init(void)
{
f010366c:	55                   	push   %ebp
f010366d:	89 e5                	mov    %esp,%ebp
f010366f:	83 ec 08             	sub    $0x8,%esp
	extern struct Segdesc gdt[];

	// LAB 3: Your code here.
	SETGATE(idt[T_DIVIDE], 0, GD_KT, t_divide, 0);
f0103672:	b8 3a 3f 10 f0       	mov    $0xf0103f3a,%eax
f0103677:	66 a3 60 e2 22 f0    	mov    %ax,0xf022e260
f010367d:	66 c7 05 62 e2 22 f0 	movw   $0x8,0xf022e262
f0103684:	08 00 
f0103686:	c6 05 64 e2 22 f0 00 	movb   $0x0,0xf022e264
f010368d:	c6 05 65 e2 22 f0 8e 	movb   $0x8e,0xf022e265
f0103694:	c1 e8 10             	shr    $0x10,%eax
f0103697:	66 a3 66 e2 22 f0    	mov    %ax,0xf022e266
	SETGATE(idt[T_DEBUG], 0, GD_KT, t_debug, 0);
f010369d:	b8 40 3f 10 f0       	mov    $0xf0103f40,%eax
f01036a2:	66 a3 68 e2 22 f0    	mov    %ax,0xf022e268
f01036a8:	66 c7 05 6a e2 22 f0 	movw   $0x8,0xf022e26a
f01036af:	08 00 
f01036b1:	c6 05 6c e2 22 f0 00 	movb   $0x0,0xf022e26c
f01036b8:	c6 05 6d e2 22 f0 8e 	movb   $0x8e,0xf022e26d
f01036bf:	c1 e8 10             	shr    $0x10,%eax
f01036c2:	66 a3 6e e2 22 f0    	mov    %ax,0xf022e26e
	SETGATE(idt[T_NMI], 0, GD_KT, t_nmi, 0);
f01036c8:	b8 46 3f 10 f0       	mov    $0xf0103f46,%eax
f01036cd:	66 a3 70 e2 22 f0    	mov    %ax,0xf022e270
f01036d3:	66 c7 05 72 e2 22 f0 	movw   $0x8,0xf022e272
f01036da:	08 00 
f01036dc:	c6 05 74 e2 22 f0 00 	movb   $0x0,0xf022e274
f01036e3:	c6 05 75 e2 22 f0 8e 	movb   $0x8e,0xf022e275
f01036ea:	c1 e8 10             	shr    $0x10,%eax
f01036ed:	66 a3 76 e2 22 f0    	mov    %ax,0xf022e276
	SETGATE(idt[T_BRKPT], 0, GD_KT, t_brkpt, 3);
f01036f3:	b8 4c 3f 10 f0       	mov    $0xf0103f4c,%eax
f01036f8:	66 a3 78 e2 22 f0    	mov    %ax,0xf022e278
f01036fe:	66 c7 05 7a e2 22 f0 	movw   $0x8,0xf022e27a
f0103705:	08 00 
f0103707:	c6 05 7c e2 22 f0 00 	movb   $0x0,0xf022e27c
f010370e:	c6 05 7d e2 22 f0 ee 	movb   $0xee,0xf022e27d
f0103715:	c1 e8 10             	shr    $0x10,%eax
f0103718:	66 a3 7e e2 22 f0    	mov    %ax,0xf022e27e
	SETGATE(idt[T_OFLOW], 0, GD_KT, t_oflow, 0);
f010371e:	b8 52 3f 10 f0       	mov    $0xf0103f52,%eax
f0103723:	66 a3 80 e2 22 f0    	mov    %ax,0xf022e280
f0103729:	66 c7 05 82 e2 22 f0 	movw   $0x8,0xf022e282
f0103730:	08 00 
f0103732:	c6 05 84 e2 22 f0 00 	movb   $0x0,0xf022e284
f0103739:	c6 05 85 e2 22 f0 8e 	movb   $0x8e,0xf022e285
f0103740:	c1 e8 10             	shr    $0x10,%eax
f0103743:	66 a3 86 e2 22 f0    	mov    %ax,0xf022e286
	SETGATE(idt[T_BOUND], 0, GD_KT, t_bound, 0);
f0103749:	b8 58 3f 10 f0       	mov    $0xf0103f58,%eax
f010374e:	66 a3 88 e2 22 f0    	mov    %ax,0xf022e288
f0103754:	66 c7 05 8a e2 22 f0 	movw   $0x8,0xf022e28a
f010375b:	08 00 
f010375d:	c6 05 8c e2 22 f0 00 	movb   $0x0,0xf022e28c
f0103764:	c6 05 8d e2 22 f0 8e 	movb   $0x8e,0xf022e28d
f010376b:	c1 e8 10             	shr    $0x10,%eax
f010376e:	66 a3 8e e2 22 f0    	mov    %ax,0xf022e28e
	SETGATE(idt[T_ILLOP], 0, GD_KT, t_illop, 0);
f0103774:	b8 5e 3f 10 f0       	mov    $0xf0103f5e,%eax
f0103779:	66 a3 90 e2 22 f0    	mov    %ax,0xf022e290
f010377f:	66 c7 05 92 e2 22 f0 	movw   $0x8,0xf022e292
f0103786:	08 00 
f0103788:	c6 05 94 e2 22 f0 00 	movb   $0x0,0xf022e294
f010378f:	c6 05 95 e2 22 f0 8e 	movb   $0x8e,0xf022e295
f0103796:	c1 e8 10             	shr    $0x10,%eax
f0103799:	66 a3 96 e2 22 f0    	mov    %ax,0xf022e296
	SETGATE(idt[T_DEVICE], 0, GD_KT, t_device, 0);
f010379f:	b8 64 3f 10 f0       	mov    $0xf0103f64,%eax
f01037a4:	66 a3 98 e2 22 f0    	mov    %ax,0xf022e298
f01037aa:	66 c7 05 9a e2 22 f0 	movw   $0x8,0xf022e29a
f01037b1:	08 00 
f01037b3:	c6 05 9c e2 22 f0 00 	movb   $0x0,0xf022e29c
f01037ba:	c6 05 9d e2 22 f0 8e 	movb   $0x8e,0xf022e29d
f01037c1:	c1 e8 10             	shr    $0x10,%eax
f01037c4:	66 a3 9e e2 22 f0    	mov    %ax,0xf022e29e
	SETGATE(idt[T_DBLFLT], 0, GD_KT, t_dblflt, 0);
f01037ca:	b8 6a 3f 10 f0       	mov    $0xf0103f6a,%eax
f01037cf:	66 a3 a0 e2 22 f0    	mov    %ax,0xf022e2a0
f01037d5:	66 c7 05 a2 e2 22 f0 	movw   $0x8,0xf022e2a2
f01037dc:	08 00 
f01037de:	c6 05 a4 e2 22 f0 00 	movb   $0x0,0xf022e2a4
f01037e5:	c6 05 a5 e2 22 f0 8e 	movb   $0x8e,0xf022e2a5
f01037ec:	c1 e8 10             	shr    $0x10,%eax
f01037ef:	66 a3 a6 e2 22 f0    	mov    %ax,0xf022e2a6
	SETGATE(idt[T_TSS], 0, GD_KT, t_tss, 0);
f01037f5:	b8 6e 3f 10 f0       	mov    $0xf0103f6e,%eax
f01037fa:	66 a3 b0 e2 22 f0    	mov    %ax,0xf022e2b0
f0103800:	66 c7 05 b2 e2 22 f0 	movw   $0x8,0xf022e2b2
f0103807:	08 00 
f0103809:	c6 05 b4 e2 22 f0 00 	movb   $0x0,0xf022e2b4
f0103810:	c6 05 b5 e2 22 f0 8e 	movb   $0x8e,0xf022e2b5
f0103817:	c1 e8 10             	shr    $0x10,%eax
f010381a:	66 a3 b6 e2 22 f0    	mov    %ax,0xf022e2b6
	SETGATE(idt[T_SEGNP], 0, GD_KT, t_segnp, 0);
f0103820:	b8 72 3f 10 f0       	mov    $0xf0103f72,%eax
f0103825:	66 a3 b8 e2 22 f0    	mov    %ax,0xf022e2b8
f010382b:	66 c7 05 ba e2 22 f0 	movw   $0x8,0xf022e2ba
f0103832:	08 00 
f0103834:	c6 05 bc e2 22 f0 00 	movb   $0x0,0xf022e2bc
f010383b:	c6 05 bd e2 22 f0 8e 	movb   $0x8e,0xf022e2bd
f0103842:	c1 e8 10             	shr    $0x10,%eax
f0103845:	66 a3 be e2 22 f0    	mov    %ax,0xf022e2be
	SETGATE(idt[T_STACK], 0, GD_KT, t_stack, 0);
f010384b:	b8 76 3f 10 f0       	mov    $0xf0103f76,%eax
f0103850:	66 a3 c0 e2 22 f0    	mov    %ax,0xf022e2c0
f0103856:	66 c7 05 c2 e2 22 f0 	movw   $0x8,0xf022e2c2
f010385d:	08 00 
f010385f:	c6 05 c4 e2 22 f0 00 	movb   $0x0,0xf022e2c4
f0103866:	c6 05 c5 e2 22 f0 8e 	movb   $0x8e,0xf022e2c5
f010386d:	c1 e8 10             	shr    $0x10,%eax
f0103870:	66 a3 c6 e2 22 f0    	mov    %ax,0xf022e2c6
	SETGATE(idt[T_GPFLT], 0, GD_KT, t_gpflt, 0);
f0103876:	b8 7a 3f 10 f0       	mov    $0xf0103f7a,%eax
f010387b:	66 a3 c8 e2 22 f0    	mov    %ax,0xf022e2c8
f0103881:	66 c7 05 ca e2 22 f0 	movw   $0x8,0xf022e2ca
f0103888:	08 00 
f010388a:	c6 05 cc e2 22 f0 00 	movb   $0x0,0xf022e2cc
f0103891:	c6 05 cd e2 22 f0 8e 	movb   $0x8e,0xf022e2cd
f0103898:	c1 e8 10             	shr    $0x10,%eax
f010389b:	66 a3 ce e2 22 f0    	mov    %ax,0xf022e2ce
	SETGATE(idt[T_PGFLT], 0, GD_KT, t_pgflt, 0);
f01038a1:	b8 7e 3f 10 f0       	mov    $0xf0103f7e,%eax
f01038a6:	66 a3 d0 e2 22 f0    	mov    %ax,0xf022e2d0
f01038ac:	66 c7 05 d2 e2 22 f0 	movw   $0x8,0xf022e2d2
f01038b3:	08 00 
f01038b5:	c6 05 d4 e2 22 f0 00 	movb   $0x0,0xf022e2d4
f01038bc:	c6 05 d5 e2 22 f0 8e 	movb   $0x8e,0xf022e2d5
f01038c3:	c1 e8 10             	shr    $0x10,%eax
f01038c6:	66 a3 d6 e2 22 f0    	mov    %ax,0xf022e2d6
	SETGATE(idt[T_FPERR], 0, GD_KT, t_fperr, 0);
f01038cc:	b8 82 3f 10 f0       	mov    $0xf0103f82,%eax
f01038d1:	66 a3 e0 e2 22 f0    	mov    %ax,0xf022e2e0
f01038d7:	66 c7 05 e2 e2 22 f0 	movw   $0x8,0xf022e2e2
f01038de:	08 00 
f01038e0:	c6 05 e4 e2 22 f0 00 	movb   $0x0,0xf022e2e4
f01038e7:	c6 05 e5 e2 22 f0 8e 	movb   $0x8e,0xf022e2e5
f01038ee:	c1 e8 10             	shr    $0x10,%eax
f01038f1:	66 a3 e6 e2 22 f0    	mov    %ax,0xf022e2e6
	SETGATE(idt[T_ALIGN], 0, GD_KT, t_align, 0);
f01038f7:	b8 88 3f 10 f0       	mov    $0xf0103f88,%eax
f01038fc:	66 a3 e8 e2 22 f0    	mov    %ax,0xf022e2e8
f0103902:	66 c7 05 ea e2 22 f0 	movw   $0x8,0xf022e2ea
f0103909:	08 00 
f010390b:	c6 05 ec e2 22 f0 00 	movb   $0x0,0xf022e2ec
f0103912:	c6 05 ed e2 22 f0 8e 	movb   $0x8e,0xf022e2ed
f0103919:	c1 e8 10             	shr    $0x10,%eax
f010391c:	66 a3 ee e2 22 f0    	mov    %ax,0xf022e2ee
	SETGATE(idt[T_MCHK], 0, GD_KT, t_mchk, 0);
f0103922:	b8 8c 3f 10 f0       	mov    $0xf0103f8c,%eax
f0103927:	66 a3 f0 e2 22 f0    	mov    %ax,0xf022e2f0
f010392d:	66 c7 05 f2 e2 22 f0 	movw   $0x8,0xf022e2f2
f0103934:	08 00 
f0103936:	c6 05 f4 e2 22 f0 00 	movb   $0x0,0xf022e2f4
f010393d:	c6 05 f5 e2 22 f0 8e 	movb   $0x8e,0xf022e2f5
f0103944:	c1 e8 10             	shr    $0x10,%eax
f0103947:	66 a3 f6 e2 22 f0    	mov    %ax,0xf022e2f6
	SETGATE(idt[T_SIMDERR], 0, GD_KT, t_simderr, 0);
f010394d:	b8 92 3f 10 f0       	mov    $0xf0103f92,%eax
f0103952:	66 a3 f8 e2 22 f0    	mov    %ax,0xf022e2f8
f0103958:	66 c7 05 fa e2 22 f0 	movw   $0x8,0xf022e2fa
f010395f:	08 00 
f0103961:	c6 05 fc e2 22 f0 00 	movb   $0x0,0xf022e2fc
f0103968:	c6 05 fd e2 22 f0 8e 	movb   $0x8e,0xf022e2fd
f010396f:	c1 e8 10             	shr    $0x10,%eax
f0103972:	66 a3 fe e2 22 f0    	mov    %ax,0xf022e2fe

	SETGATE(idt[T_SYSCALL], 0, GD_KT, t_syscall, 3);
f0103978:	b8 98 3f 10 f0       	mov    $0xf0103f98,%eax
f010397d:	66 a3 e0 e3 22 f0    	mov    %ax,0xf022e3e0
f0103983:	66 c7 05 e2 e3 22 f0 	movw   $0x8,0xf022e3e2
f010398a:	08 00 
f010398c:	c6 05 e4 e3 22 f0 00 	movb   $0x0,0xf022e3e4
f0103993:	c6 05 e5 e3 22 f0 ee 	movb   $0xee,0xf022e3e5
f010399a:	c1 e8 10             	shr    $0x10,%eax
f010399d:	66 a3 e6 e3 22 f0    	mov    %ax,0xf022e3e6


	SETGATE(idt[IRQ_OFFSET+IRQ_TIMER], 0, GD_KT, timer, 0);
f01039a3:	b8 9e 3f 10 f0       	mov    $0xf0103f9e,%eax
f01039a8:	66 a3 60 e3 22 f0    	mov    %ax,0xf022e360
f01039ae:	66 c7 05 62 e3 22 f0 	movw   $0x8,0xf022e362
f01039b5:	08 00 
f01039b7:	c6 05 64 e3 22 f0 00 	movb   $0x0,0xf022e364
f01039be:	c6 05 65 e3 22 f0 8e 	movb   $0x8e,0xf022e365
f01039c5:	c1 e8 10             	shr    $0x10,%eax
f01039c8:	66 a3 66 e3 22 f0    	mov    %ax,0xf022e366

	// Per-CPU setup 
	trap_init_percpu();
f01039ce:	e8 e2 fb ff ff       	call   f01035b5 <trap_init_percpu>
}
f01039d3:	c9                   	leave  
f01039d4:	c3                   	ret    

f01039d5 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01039d5:	55                   	push   %ebp
f01039d6:	89 e5                	mov    %esp,%ebp
f01039d8:	53                   	push   %ebx
f01039d9:	83 ec 0c             	sub    $0xc,%esp
f01039dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f01039df:	ff 33                	pushl  (%ebx)
f01039e1:	68 71 70 10 f0       	push   $0xf0107071
f01039e6:	e8 b6 fb ff ff       	call   f01035a1 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f01039eb:	83 c4 08             	add    $0x8,%esp
f01039ee:	ff 73 04             	pushl  0x4(%ebx)
f01039f1:	68 80 70 10 f0       	push   $0xf0107080
f01039f6:	e8 a6 fb ff ff       	call   f01035a1 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f01039fb:	83 c4 08             	add    $0x8,%esp
f01039fe:	ff 73 08             	pushl  0x8(%ebx)
f0103a01:	68 8f 70 10 f0       	push   $0xf010708f
f0103a06:	e8 96 fb ff ff       	call   f01035a1 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103a0b:	83 c4 08             	add    $0x8,%esp
f0103a0e:	ff 73 0c             	pushl  0xc(%ebx)
f0103a11:	68 9e 70 10 f0       	push   $0xf010709e
f0103a16:	e8 86 fb ff ff       	call   f01035a1 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103a1b:	83 c4 08             	add    $0x8,%esp
f0103a1e:	ff 73 10             	pushl  0x10(%ebx)
f0103a21:	68 ad 70 10 f0       	push   $0xf01070ad
f0103a26:	e8 76 fb ff ff       	call   f01035a1 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103a2b:	83 c4 08             	add    $0x8,%esp
f0103a2e:	ff 73 14             	pushl  0x14(%ebx)
f0103a31:	68 bc 70 10 f0       	push   $0xf01070bc
f0103a36:	e8 66 fb ff ff       	call   f01035a1 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103a3b:	83 c4 08             	add    $0x8,%esp
f0103a3e:	ff 73 18             	pushl  0x18(%ebx)
f0103a41:	68 cb 70 10 f0       	push   $0xf01070cb
f0103a46:	e8 56 fb ff ff       	call   f01035a1 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103a4b:	83 c4 08             	add    $0x8,%esp
f0103a4e:	ff 73 1c             	pushl  0x1c(%ebx)
f0103a51:	68 da 70 10 f0       	push   $0xf01070da
f0103a56:	e8 46 fb ff ff       	call   f01035a1 <cprintf>
}
f0103a5b:	83 c4 10             	add    $0x10,%esp
f0103a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103a61:	c9                   	leave  
f0103a62:	c3                   	ret    

f0103a63 <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f0103a63:	55                   	push   %ebp
f0103a64:	89 e5                	mov    %esp,%ebp
f0103a66:	56                   	push   %esi
f0103a67:	53                   	push   %ebx
f0103a68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f0103a6b:	e8 22 1d 00 00       	call   f0105792 <cpunum>
f0103a70:	83 ec 04             	sub    $0x4,%esp
f0103a73:	50                   	push   %eax
f0103a74:	53                   	push   %ebx
f0103a75:	68 3e 71 10 f0       	push   $0xf010713e
f0103a7a:	e8 22 fb ff ff       	call   f01035a1 <cprintf>
	print_regs(&tf->tf_regs);
f0103a7f:	89 1c 24             	mov    %ebx,(%esp)
f0103a82:	e8 4e ff ff ff       	call   f01039d5 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103a87:	83 c4 08             	add    $0x8,%esp
f0103a8a:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103a8e:	50                   	push   %eax
f0103a8f:	68 5c 71 10 f0       	push   $0xf010715c
f0103a94:	e8 08 fb ff ff       	call   f01035a1 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103a99:	83 c4 08             	add    $0x8,%esp
f0103a9c:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103aa0:	50                   	push   %eax
f0103aa1:	68 6f 71 10 f0       	push   $0xf010716f
f0103aa6:	e8 f6 fa ff ff       	call   f01035a1 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103aab:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < ARRAY_SIZE(excnames))
f0103aae:	83 c4 10             	add    $0x10,%esp
f0103ab1:	83 f8 13             	cmp    $0x13,%eax
f0103ab4:	77 09                	ja     f0103abf <print_trapframe+0x5c>
		return excnames[trapno];
f0103ab6:	8b 14 85 20 74 10 f0 	mov    -0xfef8be0(,%eax,4),%edx
f0103abd:	eb 1f                	jmp    f0103ade <print_trapframe+0x7b>
	if (trapno == T_SYSCALL)
f0103abf:	83 f8 30             	cmp    $0x30,%eax
f0103ac2:	74 15                	je     f0103ad9 <print_trapframe+0x76>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103ac4:	8d 50 e0             	lea    -0x20(%eax),%edx
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103ac7:	83 fa 10             	cmp    $0x10,%edx
f0103aca:	b9 08 71 10 f0       	mov    $0xf0107108,%ecx
f0103acf:	ba f5 70 10 f0       	mov    $0xf01070f5,%edx
f0103ad4:	0f 43 d1             	cmovae %ecx,%edx
f0103ad7:	eb 05                	jmp    f0103ade <print_trapframe+0x7b>
	};

	if (trapno < ARRAY_SIZE(excnames))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103ad9:	ba e9 70 10 f0       	mov    $0xf01070e9,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103ade:	83 ec 04             	sub    $0x4,%esp
f0103ae1:	52                   	push   %edx
f0103ae2:	50                   	push   %eax
f0103ae3:	68 82 71 10 f0       	push   $0xf0107182
f0103ae8:	e8 b4 fa ff ff       	call   f01035a1 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103aed:	83 c4 10             	add    $0x10,%esp
f0103af0:	3b 1d 60 ea 22 f0    	cmp    0xf022ea60,%ebx
f0103af6:	75 1a                	jne    f0103b12 <print_trapframe+0xaf>
f0103af8:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103afc:	75 14                	jne    f0103b12 <print_trapframe+0xaf>

static inline uint32_t
rcr2(void)
{
	uint32_t val;
	asm volatile("movl %%cr2,%0" : "=r" (val));
f0103afe:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103b01:	83 ec 08             	sub    $0x8,%esp
f0103b04:	50                   	push   %eax
f0103b05:	68 94 71 10 f0       	push   $0xf0107194
f0103b0a:	e8 92 fa ff ff       	call   f01035a1 <cprintf>
f0103b0f:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103b12:	83 ec 08             	sub    $0x8,%esp
f0103b15:	ff 73 2c             	pushl  0x2c(%ebx)
f0103b18:	68 a3 71 10 f0       	push   $0xf01071a3
f0103b1d:	e8 7f fa ff ff       	call   f01035a1 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103b22:	83 c4 10             	add    $0x10,%esp
f0103b25:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103b29:	75 49                	jne    f0103b74 <print_trapframe+0x111>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103b2b:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103b2e:	89 c2                	mov    %eax,%edx
f0103b30:	83 e2 01             	and    $0x1,%edx
f0103b33:	ba 22 71 10 f0       	mov    $0xf0107122,%edx
f0103b38:	b9 17 71 10 f0       	mov    $0xf0107117,%ecx
f0103b3d:	0f 44 ca             	cmove  %edx,%ecx
f0103b40:	89 c2                	mov    %eax,%edx
f0103b42:	83 e2 02             	and    $0x2,%edx
f0103b45:	ba 34 71 10 f0       	mov    $0xf0107134,%edx
f0103b4a:	be 2e 71 10 f0       	mov    $0xf010712e,%esi
f0103b4f:	0f 45 d6             	cmovne %esi,%edx
f0103b52:	83 e0 04             	and    $0x4,%eax
f0103b55:	be 6e 72 10 f0       	mov    $0xf010726e,%esi
f0103b5a:	b8 39 71 10 f0       	mov    $0xf0107139,%eax
f0103b5f:	0f 44 c6             	cmove  %esi,%eax
f0103b62:	51                   	push   %ecx
f0103b63:	52                   	push   %edx
f0103b64:	50                   	push   %eax
f0103b65:	68 b1 71 10 f0       	push   $0xf01071b1
f0103b6a:	e8 32 fa ff ff       	call   f01035a1 <cprintf>
f0103b6f:	83 c4 10             	add    $0x10,%esp
f0103b72:	eb 10                	jmp    f0103b84 <print_trapframe+0x121>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103b74:	83 ec 0c             	sub    $0xc,%esp
f0103b77:	68 94 6f 10 f0       	push   $0xf0106f94
f0103b7c:	e8 20 fa ff ff       	call   f01035a1 <cprintf>
f0103b81:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103b84:	83 ec 08             	sub    $0x8,%esp
f0103b87:	ff 73 30             	pushl  0x30(%ebx)
f0103b8a:	68 c0 71 10 f0       	push   $0xf01071c0
f0103b8f:	e8 0d fa ff ff       	call   f01035a1 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103b94:	83 c4 08             	add    $0x8,%esp
f0103b97:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103b9b:	50                   	push   %eax
f0103b9c:	68 cf 71 10 f0       	push   $0xf01071cf
f0103ba1:	e8 fb f9 ff ff       	call   f01035a1 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103ba6:	83 c4 08             	add    $0x8,%esp
f0103ba9:	ff 73 38             	pushl  0x38(%ebx)
f0103bac:	68 e2 71 10 f0       	push   $0xf01071e2
f0103bb1:	e8 eb f9 ff ff       	call   f01035a1 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f0103bb6:	83 c4 10             	add    $0x10,%esp
f0103bb9:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103bbd:	74 25                	je     f0103be4 <print_trapframe+0x181>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103bbf:	83 ec 08             	sub    $0x8,%esp
f0103bc2:	ff 73 3c             	pushl  0x3c(%ebx)
f0103bc5:	68 f1 71 10 f0       	push   $0xf01071f1
f0103bca:	e8 d2 f9 ff ff       	call   f01035a1 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103bcf:	83 c4 08             	add    $0x8,%esp
f0103bd2:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103bd6:	50                   	push   %eax
f0103bd7:	68 00 72 10 f0       	push   $0xf0107200
f0103bdc:	e8 c0 f9 ff ff       	call   f01035a1 <cprintf>
f0103be1:	83 c4 10             	add    $0x10,%esp
	}
}
f0103be4:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103be7:	5b                   	pop    %ebx
f0103be8:	5e                   	pop    %esi
f0103be9:	5d                   	pop    %ebp
f0103bea:	c3                   	ret    

f0103beb <page_fault_handler>:
// 1.根据tf构造用户异常栈(借助utf)
// 2.esp 指向用户异常栈  eip 指向进程中断(页错误)处理函数的入口位置
// 3.重新运行进程，此时会将用户异常栈的值pop到寄存器
void
page_fault_handler(struct Trapframe *tf)
{
f0103beb:	55                   	push   %ebp
f0103bec:	89 e5                	mov    %esp,%ebp
f0103bee:	57                   	push   %edi
f0103bef:	56                   	push   %esi
f0103bf0:	53                   	push   %ebx
f0103bf1:	83 ec 0c             	sub    $0xc,%esp
f0103bf4:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103bf7:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 3: Your code here.
	if ((tf->tf_cs & 0x3) == 0) 
f0103bfa:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0103bfe:	75 17                	jne    f0103c17 <page_fault_handler+0x2c>
		panic("page_fault_handler: page fault in kernel mode");
f0103c00:	83 ec 04             	sub    $0x4,%esp
f0103c03:	68 b8 73 10 f0       	push   $0xf01073b8
f0103c08:	68 6f 01 00 00       	push   $0x16f
f0103c0d:	68 13 72 10 f0       	push   $0xf0107213
f0103c12:	e8 29 c4 ff ff       	call   f0100040 <_panic>

	// LAB 4: Your code here.
	// 用户态页错误
	// 把现场信息记录下来，构建用户异常栈数据结构，然后改变esp eip
	struct UTrapframe *utf;
	if (curenv->env_pgfault_upcall != NULL) {
f0103c17:	e8 76 1b 00 00       	call   f0105792 <cpunum>
f0103c1c:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c1f:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0103c25:	83 78 64 00          	cmpl   $0x0,0x64(%eax)
f0103c29:	0f 84 89 00 00 00    	je     f0103cb8 <page_fault_handler+0xcd>
		
		// 判断发生错误时堆栈指针是否处于用户异常栈，如果是，留出一个字的空间存返回值
        if (UXSTACKTOP - PGSIZE <= tf->tf_esp && tf->tf_esp <= UXSTACKTOP - 1)
f0103c2f:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103c32:	8d 90 00 10 40 11    	lea    0x11401000(%eax),%edx
                utf = (struct UTrapframe *)(tf->tf_esp - sizeof(struct UTrapframe) - 4);
f0103c38:	83 e8 38             	sub    $0x38,%eax
f0103c3b:	81 fa ff 0f 00 00    	cmp    $0xfff,%edx
f0103c41:	ba cc ff bf ee       	mov    $0xeebfffcc,%edx
f0103c46:	0f 46 d0             	cmovbe %eax,%edx
f0103c49:	89 d7                	mov    %edx,%edi
        else
                utf = (struct UTrapframe *)(UXSTACKTOP - sizeof(struct UTrapframe));
        user_mem_assert(curenv, (void *)utf, sizeof(struct UTrapframe), PTE_U | PTE_W);
f0103c4b:	e8 42 1b 00 00       	call   f0105792 <cpunum>
f0103c50:	6a 06                	push   $0x6
f0103c52:	6a 34                	push   $0x34
f0103c54:	57                   	push   %edi
f0103c55:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c58:	ff b0 28 f0 22 f0    	pushl  -0xfdd0fd8(%eax)
f0103c5e:	e8 ec ef ff ff       	call   f0102c4f <user_mem_assert>
		
		// 构构造utf(用户异常栈)
        utf->utf_fault_va = fault_va;
f0103c63:	89 fa                	mov    %edi,%edx
f0103c65:	89 37                	mov    %esi,(%edi)
        utf->utf_err = tf->tf_trapno;
f0103c67:	8b 43 28             	mov    0x28(%ebx),%eax
f0103c6a:	89 47 04             	mov    %eax,0x4(%edi)
        utf->utf_eip = tf->tf_eip;
f0103c6d:	8b 43 30             	mov    0x30(%ebx),%eax
f0103c70:	89 47 28             	mov    %eax,0x28(%edi)
        utf->utf_eflags = tf->tf_eflags;
f0103c73:	8b 43 38             	mov    0x38(%ebx),%eax
f0103c76:	89 47 2c             	mov    %eax,0x2c(%edi)
        utf->utf_esp = tf->tf_esp;
f0103c79:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103c7c:	89 47 30             	mov    %eax,0x30(%edi)
        utf->utf_regs = tf->tf_regs;
f0103c7f:	8d 7f 08             	lea    0x8(%edi),%edi
f0103c82:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103c87:	89 de                	mov    %ebx,%esi
f0103c89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		
		
		// 将进程的堆栈指针指向用户异常栈
        tf->tf_esp = (uint32_t)utf;
f0103c8b:	89 53 3c             	mov    %edx,0x3c(%ebx)

		// 将进程的下一条指令的指针指向进程的中断处理函数的入口位置
        tf->tf_eip = (uint32_t)curenv->env_pgfault_upcall;
f0103c8e:	e8 ff 1a 00 00       	call   f0105792 <cpunum>
f0103c93:	6b c0 74             	imul   $0x74,%eax,%eax
f0103c96:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0103c9c:	8b 40 64             	mov    0x64(%eax),%eax
f0103c9f:	89 43 30             	mov    %eax,0x30(%ebx)
	
		// 重新运行进程(将用户异常栈的值pop到寄存器)
        env_run(curenv);
f0103ca2:	e8 eb 1a 00 00       	call   f0105792 <cpunum>
f0103ca7:	83 c4 04             	add    $0x4,%esp
f0103caa:	6b c0 74             	imul   $0x74,%eax,%eax
f0103cad:	ff b0 28 f0 22 f0    	pushl  -0xfdd0fd8(%eax)
f0103cb3:	e8 98 f6 ff ff       	call   f0103350 <env_run>
	} 

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103cb8:	8b 7b 30             	mov    0x30(%ebx),%edi
	curenv->env_id, fault_va, tf->tf_eip);
f0103cbb:	e8 d2 1a 00 00       	call   f0105792 <cpunum>
		// 重新运行进程(将用户异常栈的值pop到寄存器)
        env_run(curenv);
	} 

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103cc0:	57                   	push   %edi
f0103cc1:	56                   	push   %esi
	curenv->env_id, fault_va, tf->tf_eip);
f0103cc2:	6b c0 74             	imul   $0x74,%eax,%eax
		// 重新运行进程(将用户异常栈的值pop到寄存器)
        env_run(curenv);
	} 

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103cc5:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0103ccb:	ff 70 48             	pushl  0x48(%eax)
f0103cce:	68 e8 73 10 f0       	push   $0xf01073e8
f0103cd3:	e8 c9 f8 ff ff       	call   f01035a1 <cprintf>
	curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103cd8:	89 1c 24             	mov    %ebx,(%esp)
f0103cdb:	e8 83 fd ff ff       	call   f0103a63 <print_trapframe>
	env_destroy(curenv);
f0103ce0:	e8 ad 1a 00 00       	call   f0105792 <cpunum>
f0103ce5:	83 c4 04             	add    $0x4,%esp
f0103ce8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ceb:	ff b0 28 f0 22 f0    	pushl  -0xfdd0fd8(%eax)
f0103cf1:	e8 bb f5 ff ff       	call   f01032b1 <env_destroy>
}
f0103cf6:	83 c4 10             	add    $0x10,%esp
f0103cf9:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103cfc:	5b                   	pop    %ebx
f0103cfd:	5e                   	pop    %esi
f0103cfe:	5f                   	pop    %edi
f0103cff:	5d                   	pop    %ebp
f0103d00:	c3                   	ret    

f0103d01 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f0103d01:	55                   	push   %ebp
f0103d02:	89 e5                	mov    %esp,%ebp
f0103d04:	57                   	push   %edi
f0103d05:	56                   	push   %esi
f0103d06:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103d09:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103d0a:	83 3d 80 ee 22 f0 00 	cmpl   $0x0,0xf022ee80
f0103d11:	74 01                	je     f0103d14 <trap+0x13>
		asm volatile("hlt");
f0103d13:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f0103d14:	e8 79 1a 00 00       	call   f0105792 <cpunum>
f0103d19:	6b d0 74             	imul   $0x74,%eax,%edx
f0103d1c:	81 c2 20 f0 22 f0    	add    $0xf022f020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0103d22:	b8 01 00 00 00       	mov    $0x1,%eax
f0103d27:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
f0103d2b:	83 f8 02             	cmp    $0x2,%eax
f0103d2e:	75 10                	jne    f0103d40 <trap+0x3f>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f0103d30:	83 ec 0c             	sub    $0xc,%esp
f0103d33:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103d38:	e8 c3 1c 00 00       	call   f0105a00 <spin_lock>
f0103d3d:	83 c4 10             	add    $0x10,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
f0103d40:	9c                   	pushf  
f0103d41:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103d42:	f6 c4 02             	test   $0x2,%ah
f0103d45:	74 19                	je     f0103d60 <trap+0x5f>
f0103d47:	68 1f 72 10 f0       	push   $0xf010721f
f0103d4c:	68 ab 6c 10 f0       	push   $0xf0106cab
f0103d51:	68 35 01 00 00       	push   $0x135
f0103d56:	68 13 72 10 f0       	push   $0xf0107213
f0103d5b:	e8 e0 c2 ff ff       	call   f0100040 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f0103d60:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f0103d64:	83 e0 03             	and    $0x3,%eax
f0103d67:	66 83 f8 03          	cmp    $0x3,%ax
f0103d6b:	0f 85 b2 01 00 00    	jne    f0103f23 <trap+0x222>
f0103d71:	83 ec 0c             	sub    $0xc,%esp
f0103d74:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0103d79:	e8 82 1c 00 00       	call   f0105a00 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0103d7e:	e8 0f 1a 00 00       	call   f0105792 <cpunum>
f0103d83:	6b c0 74             	imul   $0x74,%eax,%eax
f0103d86:	83 c4 10             	add    $0x10,%esp
f0103d89:	83 b8 28 f0 22 f0 00 	cmpl   $0x0,-0xfdd0fd8(%eax)
f0103d90:	75 19                	jne    f0103dab <trap+0xaa>
f0103d92:	68 38 72 10 f0       	push   $0xf0107238
f0103d97:	68 ab 6c 10 f0       	push   $0xf0106cab
f0103d9c:	68 3d 01 00 00       	push   $0x13d
f0103da1:	68 13 72 10 f0       	push   $0xf0107213
f0103da6:	e8 95 c2 ff ff       	call   f0100040 <_panic>

		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f0103dab:	e8 e2 19 00 00       	call   f0105792 <cpunum>
f0103db0:	6b c0 74             	imul   $0x74,%eax,%eax
f0103db3:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0103db9:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103dbd:	75 2d                	jne    f0103dec <trap+0xeb>
			env_free(curenv);
f0103dbf:	e8 ce 19 00 00       	call   f0105792 <cpunum>
f0103dc4:	83 ec 0c             	sub    $0xc,%esp
f0103dc7:	6b c0 74             	imul   $0x74,%eax,%eax
f0103dca:	ff b0 28 f0 22 f0    	pushl  -0xfdd0fd8(%eax)
f0103dd0:	e8 01 f3 ff ff       	call   f01030d6 <env_free>
			curenv = NULL;
f0103dd5:	e8 b8 19 00 00       	call   f0105792 <cpunum>
f0103dda:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ddd:	c7 80 28 f0 22 f0 00 	movl   $0x0,-0xfdd0fd8(%eax)
f0103de4:	00 00 00 
			sched_yield();
f0103de7:	e8 9e 02 00 00       	call   f010408a <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f0103dec:	e8 a1 19 00 00       	call   f0105792 <cpunum>
f0103df1:	6b c0 74             	imul   $0x74,%eax,%eax
f0103df4:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0103dfa:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103dff:	89 c7                	mov    %eax,%edi
f0103e01:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f0103e03:	e8 8a 19 00 00       	call   f0105792 <cpunum>
f0103e08:	6b c0 74             	imul   $0x74,%eax,%eax
f0103e0b:	8b b0 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103e11:	89 35 60 ea 22 f0    	mov    %esi,0xf022ea60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103e17:	8b 46 28             	mov    0x28(%esi),%eax
f0103e1a:	83 f8 27             	cmp    $0x27,%eax
f0103e1d:	75 1d                	jne    f0103e3c <trap+0x13b>
		cprintf("Spurious interrupt on irq 7\n");
f0103e1f:	83 ec 0c             	sub    $0xc,%esp
f0103e22:	68 3f 72 10 f0       	push   $0xf010723f
f0103e27:	e8 75 f7 ff ff       	call   f01035a1 <cprintf>
		print_trapframe(tf);
f0103e2c:	89 34 24             	mov    %esi,(%esp)
f0103e2f:	e8 2f fc ff ff       	call   f0103a63 <print_trapframe>
f0103e34:	83 c4 10             	add    $0x10,%esp
f0103e37:	e9 a7 00 00 00       	jmp    f0103ee3 <trap+0x1e2>
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
		cprintf("Spurious interrupt on irq 7\n");
		print_trapframe(tf);
		return;
	}
	switch(tf->tf_trapno){
f0103e3c:	83 f8 0e             	cmp    $0xe,%eax
f0103e3f:	74 18                	je     f0103e59 <trap+0x158>
f0103e41:	83 f8 0e             	cmp    $0xe,%eax
f0103e44:	77 07                	ja     f0103e4d <trap+0x14c>
f0103e46:	83 f8 03             	cmp    $0x3,%eax
f0103e49:	74 1c                	je     f0103e67 <trap+0x166>
f0103e4b:	eb 53                	jmp    f0103ea0 <trap+0x19f>
f0103e4d:	83 f8 20             	cmp    $0x20,%eax
f0103e50:	74 44                	je     f0103e96 <trap+0x195>
f0103e52:	83 f8 30             	cmp    $0x30,%eax
f0103e55:	74 1e                	je     f0103e75 <trap+0x174>
f0103e57:	eb 47                	jmp    f0103ea0 <trap+0x19f>
		case(T_PGFLT):
			page_fault_handler(tf);
f0103e59:	83 ec 0c             	sub    $0xc,%esp
f0103e5c:	56                   	push   %esi
f0103e5d:	e8 89 fd ff ff       	call   f0103beb <page_fault_handler>
f0103e62:	83 c4 10             	add    $0x10,%esp
f0103e65:	eb 7c                	jmp    f0103ee3 <trap+0x1e2>
			break;
		case(T_BRKPT):
			monitor(tf);
f0103e67:	83 ec 0c             	sub    $0xc,%esp
f0103e6a:	56                   	push   %esi
f0103e6b:	e8 11 ca ff ff       	call   f0100881 <monitor>
f0103e70:	83 c4 10             	add    $0x10,%esp
f0103e73:	eb 6e                	jmp    f0103ee3 <trap+0x1e2>
			break;
		case (T_SYSCALL):
			//print_trapframe(tf);

			tf->tf_regs.reg_eax = syscall(
f0103e75:	83 ec 08             	sub    $0x8,%esp
f0103e78:	ff 76 04             	pushl  0x4(%esi)
f0103e7b:	ff 36                	pushl  (%esi)
f0103e7d:	ff 76 10             	pushl  0x10(%esi)
f0103e80:	ff 76 18             	pushl  0x18(%esi)
f0103e83:	ff 76 14             	pushl  0x14(%esi)
f0103e86:	ff 76 1c             	pushl  0x1c(%esi)
f0103e89:	e8 af 02 00 00       	call   f010413d <syscall>
f0103e8e:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103e91:	83 c4 20             	add    $0x20,%esp
f0103e94:	eb 4d                	jmp    f0103ee3 <trap+0x1e2>
					tf->tf_regs.reg_ebx,
					tf->tf_regs.reg_edi,
					tf->tf_regs.reg_esi);
			break;
		case(IRQ_OFFSET + IRQ_TIMER):
			lapic_eoi();
f0103e96:	e8 42 1a 00 00       	call   f01058dd <lapic_eoi>
			sched_yield();
f0103e9b:	e8 ea 01 00 00       	call   f010408a <sched_yield>
			return;
		default:
			print_trapframe(tf);
f0103ea0:	83 ec 0c             	sub    $0xc,%esp
f0103ea3:	56                   	push   %esi
f0103ea4:	e8 ba fb ff ff       	call   f0103a63 <print_trapframe>
			if (tf->tf_cs == GD_KT)
f0103ea9:	83 c4 10             	add    $0x10,%esp
f0103eac:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103eb1:	75 17                	jne    f0103eca <trap+0x1c9>
				panic("unhandled trap in kernel");
f0103eb3:	83 ec 04             	sub    $0x4,%esp
f0103eb6:	68 5c 72 10 f0       	push   $0xf010725c
f0103ebb:	68 19 01 00 00       	push   $0x119
f0103ec0:	68 13 72 10 f0       	push   $0xf0107213
f0103ec5:	e8 76 c1 ff ff       	call   f0100040 <_panic>
			else {
				env_destroy(curenv);
f0103eca:	e8 c3 18 00 00       	call   f0105792 <cpunum>
f0103ecf:	83 ec 0c             	sub    $0xc,%esp
f0103ed2:	6b c0 74             	imul   $0x74,%eax,%eax
f0103ed5:	ff b0 28 f0 22 f0    	pushl  -0xfdd0fd8(%eax)
f0103edb:	e8 d1 f3 ff ff       	call   f01032b1 <env_destroy>
f0103ee0:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103ee3:	e8 aa 18 00 00       	call   f0105792 <cpunum>
f0103ee8:	6b c0 74             	imul   $0x74,%eax,%eax
f0103eeb:	83 b8 28 f0 22 f0 00 	cmpl   $0x0,-0xfdd0fd8(%eax)
f0103ef2:	74 2a                	je     f0103f1e <trap+0x21d>
f0103ef4:	e8 99 18 00 00       	call   f0105792 <cpunum>
f0103ef9:	6b c0 74             	imul   $0x74,%eax,%eax
f0103efc:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0103f02:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103f06:	75 16                	jne    f0103f1e <trap+0x21d>
		env_run(curenv);
f0103f08:	e8 85 18 00 00       	call   f0105792 <cpunum>
f0103f0d:	83 ec 0c             	sub    $0xc,%esp
f0103f10:	6b c0 74             	imul   $0x74,%eax,%eax
f0103f13:	ff b0 28 f0 22 f0    	pushl  -0xfdd0fd8(%eax)
f0103f19:	e8 32 f4 ff ff       	call   f0103350 <env_run>
	else
		sched_yield();
f0103f1e:	e8 67 01 00 00       	call   f010408a <sched_yield>
		tf = &curenv->env_tf;
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103f23:	89 35 60 ea 22 f0    	mov    %esi,0xf022ea60
	// LAB 3: Your code here.

	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103f29:	8b 46 28             	mov    0x28(%esi),%eax
f0103f2c:	83 f8 27             	cmp    $0x27,%eax
f0103f2f:	0f 85 07 ff ff ff    	jne    f0103e3c <trap+0x13b>
f0103f35:	e9 e5 fe ff ff       	jmp    f0103e1f <trap+0x11e>

f0103f3a <t_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
//中断处理程序生成
TRAPHANDLER_NOEC(t_divide, T_DIVIDE)
f0103f3a:	6a 00                	push   $0x0
f0103f3c:	6a 00                	push   $0x0
f0103f3e:	eb 64                	jmp    f0103fa4 <_alltraps>

f0103f40 <t_debug>:
TRAPHANDLER_NOEC(t_debug, T_DEBUG)
f0103f40:	6a 00                	push   $0x0
f0103f42:	6a 01                	push   $0x1
f0103f44:	eb 5e                	jmp    f0103fa4 <_alltraps>

f0103f46 <t_nmi>:
TRAPHANDLER_NOEC(t_nmi, T_NMI)
f0103f46:	6a 00                	push   $0x0
f0103f48:	6a 02                	push   $0x2
f0103f4a:	eb 58                	jmp    f0103fa4 <_alltraps>

f0103f4c <t_brkpt>:
TRAPHANDLER_NOEC(t_brkpt, T_BRKPT)
f0103f4c:	6a 00                	push   $0x0
f0103f4e:	6a 03                	push   $0x3
f0103f50:	eb 52                	jmp    f0103fa4 <_alltraps>

f0103f52 <t_oflow>:
TRAPHANDLER_NOEC(t_oflow, T_OFLOW)
f0103f52:	6a 00                	push   $0x0
f0103f54:	6a 04                	push   $0x4
f0103f56:	eb 4c                	jmp    f0103fa4 <_alltraps>

f0103f58 <t_bound>:
TRAPHANDLER_NOEC(t_bound, T_BOUND)
f0103f58:	6a 00                	push   $0x0
f0103f5a:	6a 05                	push   $0x5
f0103f5c:	eb 46                	jmp    f0103fa4 <_alltraps>

f0103f5e <t_illop>:
TRAPHANDLER_NOEC(t_illop, T_ILLOP)
f0103f5e:	6a 00                	push   $0x0
f0103f60:	6a 06                	push   $0x6
f0103f62:	eb 40                	jmp    f0103fa4 <_alltraps>

f0103f64 <t_device>:
TRAPHANDLER_NOEC(t_device, T_DEVICE)
f0103f64:	6a 00                	push   $0x0
f0103f66:	6a 07                	push   $0x7
f0103f68:	eb 3a                	jmp    f0103fa4 <_alltraps>

f0103f6a <t_dblflt>:
TRAPHANDLER(t_dblflt, T_DBLFLT)
f0103f6a:	6a 08                	push   $0x8
f0103f6c:	eb 36                	jmp    f0103fa4 <_alltraps>

f0103f6e <t_tss>:
TRAPHANDLER(t_tss, T_TSS)
f0103f6e:	6a 0a                	push   $0xa
f0103f70:	eb 32                	jmp    f0103fa4 <_alltraps>

f0103f72 <t_segnp>:
TRAPHANDLER(t_segnp, T_SEGNP)
f0103f72:	6a 0b                	push   $0xb
f0103f74:	eb 2e                	jmp    f0103fa4 <_alltraps>

f0103f76 <t_stack>:
TRAPHANDLER(t_stack, T_STACK)
f0103f76:	6a 0c                	push   $0xc
f0103f78:	eb 2a                	jmp    f0103fa4 <_alltraps>

f0103f7a <t_gpflt>:
TRAPHANDLER(t_gpflt, T_GPFLT)
f0103f7a:	6a 0d                	push   $0xd
f0103f7c:	eb 26                	jmp    f0103fa4 <_alltraps>

f0103f7e <t_pgflt>:
TRAPHANDLER(t_pgflt, T_PGFLT)
f0103f7e:	6a 0e                	push   $0xe
f0103f80:	eb 22                	jmp    f0103fa4 <_alltraps>

f0103f82 <t_fperr>:
TRAPHANDLER_NOEC(t_fperr, T_FPERR)
f0103f82:	6a 00                	push   $0x0
f0103f84:	6a 10                	push   $0x10
f0103f86:	eb 1c                	jmp    f0103fa4 <_alltraps>

f0103f88 <t_align>:
TRAPHANDLER(t_align, T_ALIGN)
f0103f88:	6a 11                	push   $0x11
f0103f8a:	eb 18                	jmp    f0103fa4 <_alltraps>

f0103f8c <t_mchk>:
TRAPHANDLER_NOEC(t_mchk, T_MCHK)
f0103f8c:	6a 00                	push   $0x0
f0103f8e:	6a 12                	push   $0x12
f0103f90:	eb 12                	jmp    f0103fa4 <_alltraps>

f0103f92 <t_simderr>:
TRAPHANDLER_NOEC(t_simderr, T_SIMDERR)
f0103f92:	6a 00                	push   $0x0
f0103f94:	6a 13                	push   $0x13
f0103f96:	eb 0c                	jmp    f0103fa4 <_alltraps>

f0103f98 <t_syscall>:


TRAPHANDLER_NOEC(t_syscall, T_SYSCALL)
f0103f98:	6a 00                	push   $0x0
f0103f9a:	6a 30                	push   $0x30
f0103f9c:	eb 06                	jmp    f0103fa4 <_alltraps>

f0103f9e <timer>:

TRAPHANDLER_NOEC(timer, IRQ_OFFSET + IRQ_TIMER);
f0103f9e:	6a 00                	push   $0x0
f0103fa0:	6a 20                	push   $0x20
f0103fa2:	eb 00                	jmp    f0103fa4 <_alltraps>

f0103fa4 <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
 /*公有部分，压入顺序和trapframe有关，因为MIT要求构建Trapframe在堆栈中
,以供trap函数使用*/
_alltraps:
	pushl %ds
f0103fa4:	1e                   	push   %ds
	pushl %es
f0103fa5:	06                   	push   %es
	pushal 
f0103fa6:	60                   	pusha  

	movl $GD_KD, %eax
f0103fa7:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f0103fac:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f0103fae:	8e c0                	mov    %eax,%es

	push %esp
f0103fb0:	54                   	push   %esp
	call trap
f0103fb1:	e8 4b fd ff ff       	call   f0103d01 <trap>

f0103fb6 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0103fb6:	55                   	push   %ebp
f0103fb7:	89 e5                	mov    %esp,%ebp
f0103fb9:	83 ec 08             	sub    $0x8,%esp
f0103fbc:	a1 48 e2 22 f0       	mov    0xf022e248,%eax
f0103fc1:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103fc4:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0103fc9:	8b 02                	mov    (%edx),%eax
f0103fcb:	83 e8 01             	sub    $0x1,%eax
f0103fce:	83 f8 02             	cmp    $0x2,%eax
f0103fd1:	76 10                	jbe    f0103fe3 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f0103fd3:	83 c1 01             	add    $0x1,%ecx
f0103fd6:	83 c2 7c             	add    $0x7c,%edx
f0103fd9:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103fdf:	75 e8                	jne    f0103fc9 <sched_halt+0x13>
f0103fe1:	eb 08                	jmp    f0103feb <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f0103fe3:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f0103fe9:	75 1f                	jne    f010400a <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f0103feb:	83 ec 0c             	sub    $0xc,%esp
f0103fee:	68 70 74 10 f0       	push   $0xf0107470
f0103ff3:	e8 a9 f5 ff ff       	call   f01035a1 <cprintf>
f0103ff8:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f0103ffb:	83 ec 0c             	sub    $0xc,%esp
f0103ffe:	6a 00                	push   $0x0
f0104000:	e8 7c c8 ff ff       	call   f0100881 <monitor>
f0104005:	83 c4 10             	add    $0x10,%esp
f0104008:	eb f1                	jmp    f0103ffb <sched_halt+0x45>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f010400a:	e8 83 17 00 00       	call   f0105792 <cpunum>
f010400f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104012:	c7 80 28 f0 22 f0 00 	movl   $0x0,-0xfdd0fd8(%eax)
f0104019:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f010401c:	a1 8c ee 22 f0       	mov    0xf022ee8c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0104021:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0104026:	77 12                	ja     f010403a <sched_halt+0x84>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0104028:	50                   	push   %eax
f0104029:	68 68 5e 10 f0       	push   $0xf0105e68
f010402e:	6a 4f                	push   $0x4f
f0104030:	68 99 74 10 f0       	push   $0xf0107499
f0104035:	e8 06 c0 ff ff       	call   f0100040 <_panic>
}

static inline void
lcr3(uint32_t val)
{
	asm volatile("movl %0,%%cr3" : : "r" (val));
f010403a:	05 00 00 00 10       	add    $0x10000000,%eax
f010403f:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104042:	e8 4b 17 00 00       	call   f0105792 <cpunum>
f0104047:	6b d0 74             	imul   $0x74,%eax,%edx
f010404a:	81 c2 20 f0 22 f0    	add    $0xf022f020,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0104050:	b8 02 00 00 00       	mov    $0x2,%eax
f0104055:	f0 87 42 04          	lock xchg %eax,0x4(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f0104059:	83 ec 0c             	sub    $0xc,%esp
f010405c:	68 c0 f3 11 f0       	push   $0xf011f3c0
f0104061:	e8 37 1a 00 00       	call   f0105a9d <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104066:	f3 90                	pause  
		"pushl $0\n"
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f0104068:	e8 25 17 00 00       	call   f0105792 <cpunum>
f010406d:	6b c0 74             	imul   $0x74,%eax,%eax

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104070:	8b 80 30 f0 22 f0    	mov    -0xfdd0fd0(%eax),%eax
f0104076:	bd 00 00 00 00       	mov    $0x0,%ebp
f010407b:	89 c4                	mov    %eax,%esp
f010407d:	6a 00                	push   $0x0
f010407f:	6a 00                	push   $0x0
f0104081:	fb                   	sti    
f0104082:	f4                   	hlt    
f0104083:	eb fd                	jmp    f0104082 <sched_halt+0xcc>
		"sti\n"
		"1:\n"
		"hlt\n"
		"jmp 1b\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104085:	83 c4 10             	add    $0x10,%esp
f0104088:	c9                   	leave  
f0104089:	c3                   	ret    

f010408a <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f010408a:	55                   	push   %ebp
f010408b:	89 e5                	mov    %esp,%ebp
f010408d:	53                   	push   %ebx
f010408e:	83 ec 04             	sub    $0x4,%esp
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, nexti = 0;
	if (curenv != NULL)
f0104091:	e8 fc 16 00 00       	call   f0105792 <cpunum>
f0104096:	6b d0 74             	imul   $0x74,%eax,%edx
	// another CPU (env_status == ENV_RUNNING). If there are
	// no runnable environments, simply drop through to the code
	// below to halt the cpu.

	// LAB 4: Your code here.
	int i, nexti = 0;
f0104099:	b8 00 00 00 00       	mov    $0x0,%eax
	if (curenv != NULL)
f010409e:	83 ba 28 f0 22 f0 00 	cmpl   $0x0,-0xfdd0fd8(%edx)
f01040a5:	74 19                	je     f01040c0 <sched_yield+0x36>
		nexti = (ENVX(curenv->env_id) + 1) % NENV;
f01040a7:	e8 e6 16 00 00       	call   f0105792 <cpunum>
f01040ac:	6b c0 74             	imul   $0x74,%eax,%eax
f01040af:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f01040b5:	8b 40 48             	mov    0x48(%eax),%eax
f01040b8:	8d 40 01             	lea    0x1(%eax),%eax
f01040bb:	25 ff 03 00 00       	and    $0x3ff,%eax
	
	// 轮询，找一个进程去运行
	for (i = 0; i < NENV; i++) {
		if (envs[nexti].env_status == ENV_RUNNABLE){
f01040c0:	8b 0d 48 e2 22 f0    	mov    0xf022e248,%ecx
f01040c6:	ba 00 04 00 00       	mov    $0x400,%edx
f01040cb:	6b d8 7c             	imul   $0x7c,%eax,%ebx
f01040ce:	01 cb                	add    %ecx,%ebx
f01040d0:	83 7b 54 02          	cmpl   $0x2,0x54(%ebx)
f01040d4:	75 09                	jne    f01040df <sched_yield+0x55>
			env_run(&envs[nexti]);
f01040d6:	83 ec 0c             	sub    $0xc,%esp
f01040d9:	53                   	push   %ebx
f01040da:	e8 71 f2 ff ff       	call   f0103350 <env_run>
			return;
		}
		nexti = (nexti + 1) % NENV;
f01040df:	83 c0 01             	add    $0x1,%eax
f01040e2:	89 c3                	mov    %eax,%ebx
f01040e4:	c1 fb 1f             	sar    $0x1f,%ebx
f01040e7:	c1 eb 16             	shr    $0x16,%ebx
f01040ea:	01 d8                	add    %ebx,%eax
f01040ec:	25 ff 03 00 00       	and    $0x3ff,%eax
f01040f1:	29 d8                	sub    %ebx,%eax
	int i, nexti = 0;
	if (curenv != NULL)
		nexti = (ENVX(curenv->env_id) + 1) % NENV;
	
	// 轮询，找一个进程去运行
	for (i = 0; i < NENV; i++) {
f01040f3:	83 ea 01             	sub    $0x1,%edx
f01040f6:	75 d3                	jne    f01040cb <sched_yield+0x41>
			return;
		}
		nexti = (nexti + 1) % NENV;
	}

	if (curenv != NULL && curenv->env_status == ENV_RUNNING){
f01040f8:	e8 95 16 00 00       	call   f0105792 <cpunum>
f01040fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104100:	83 b8 28 f0 22 f0 00 	cmpl   $0x0,-0xfdd0fd8(%eax)
f0104107:	74 2a                	je     f0104133 <sched_yield+0xa9>
f0104109:	e8 84 16 00 00       	call   f0105792 <cpunum>
f010410e:	6b c0 74             	imul   $0x74,%eax,%eax
f0104111:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0104117:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010411b:	75 16                	jne    f0104133 <sched_yield+0xa9>
			env_run(curenv);
f010411d:	e8 70 16 00 00       	call   f0105792 <cpunum>
f0104122:	83 ec 0c             	sub    $0xc,%esp
f0104125:	6b c0 74             	imul   $0x74,%eax,%eax
f0104128:	ff b0 28 f0 22 f0    	pushl  -0xfdd0fd8(%eax)
f010412e:	e8 1d f2 ff ff       	call   f0103350 <env_run>
			return;
	}


	// sched_halt never returns
	sched_halt();
f0104133:	e8 7e fe ff ff       	call   f0103fb6 <sched_halt>
}
f0104138:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010413b:	c9                   	leave  
f010413c:	c3                   	ret    

f010413d <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f010413d:	55                   	push   %ebp
f010413e:	89 e5                	mov    %esp,%ebp
f0104140:	57                   	push   %edi
f0104141:	56                   	push   %esi
f0104142:	53                   	push   %ebx
f0104143:	83 ec 1c             	sub    $0x1c,%esp
f0104146:	8b 45 08             	mov    0x8(%ebp),%eax
	// Return any appropriate return value.
	// LAB 3: Your code here.

	//panic("syscall not implemented");

	switch (syscallno) {
f0104149:	83 f8 0c             	cmp    $0xc,%eax
f010414c:	0f 87 38 05 00 00    	ja     f010468a <syscall+0x54d>
f0104152:	ff 24 85 e0 74 10 f0 	jmp    *-0xfef8b20(,%eax,4)
	// Destroy the environment if not.

	// LAB 3: Your code here.
	//user_mem_assert(curenv, s, len, 0);
	//检查用户传送过来的指针
	user_mem_assert(curenv, s, len, PTE_U | PTE_P);	
f0104159:	e8 34 16 00 00       	call   f0105792 <cpunum>
f010415e:	6a 05                	push   $0x5
f0104160:	ff 75 10             	pushl  0x10(%ebp)
f0104163:	ff 75 0c             	pushl  0xc(%ebp)
f0104166:	6b c0 74             	imul   $0x74,%eax,%eax
f0104169:	ff b0 28 f0 22 f0    	pushl  -0xfdd0fd8(%eax)
f010416f:	e8 db ea ff ff       	call   f0102c4f <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f0104174:	83 c4 0c             	add    $0xc,%esp
f0104177:	ff 75 0c             	pushl  0xc(%ebp)
f010417a:	ff 75 10             	pushl  0x10(%ebp)
f010417d:	68 a6 74 10 f0       	push   $0xf01074a6
f0104182:	e8 1a f4 ff ff       	call   f01035a1 <cprintf>
f0104187:	83 c4 10             	add    $0x10,%esp
	//panic("syscall not implemented");

	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *) a1, a2);
		return 0;
f010418a:	b8 00 00 00 00       	mov    $0x0,%eax
f010418f:	e9 02 05 00 00       	jmp    f0104696 <syscall+0x559>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104194:	e8 5c c4 ff ff       	call   f01005f5 <cons_getc>
	switch (syscallno) {
	case SYS_cputs:
		sys_cputs((char *) a1, a2);
		return 0;
	case SYS_cgetc:
		return sys_cgetc();
f0104199:	e9 f8 04 00 00       	jmp    f0104696 <syscall+0x559>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f010419e:	83 ec 04             	sub    $0x4,%esp
f01041a1:	6a 01                	push   $0x1
f01041a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01041a6:	50                   	push   %eax
f01041a7:	ff 75 0c             	pushl  0xc(%ebp)
f01041aa:	e8 55 eb ff ff       	call   f0102d04 <envid2env>
f01041af:	83 c4 10             	add    $0x10,%esp
f01041b2:	85 c0                	test   %eax,%eax
f01041b4:	0f 88 dc 04 00 00    	js     f0104696 <syscall+0x559>
		return r;
	if (e == curenv)
f01041ba:	e8 d3 15 00 00       	call   f0105792 <cpunum>
f01041bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01041c2:	6b c0 74             	imul   $0x74,%eax,%eax
f01041c5:	39 90 28 f0 22 f0    	cmp    %edx,-0xfdd0fd8(%eax)
f01041cb:	75 23                	jne    f01041f0 <syscall+0xb3>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f01041cd:	e8 c0 15 00 00       	call   f0105792 <cpunum>
f01041d2:	83 ec 08             	sub    $0x8,%esp
f01041d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01041d8:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f01041de:	ff 70 48             	pushl  0x48(%eax)
f01041e1:	68 ab 74 10 f0       	push   $0xf01074ab
f01041e6:	e8 b6 f3 ff ff       	call   f01035a1 <cprintf>
f01041eb:	83 c4 10             	add    $0x10,%esp
f01041ee:	eb 25                	jmp    f0104215 <syscall+0xd8>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f01041f0:	8b 5a 48             	mov    0x48(%edx),%ebx
f01041f3:	e8 9a 15 00 00       	call   f0105792 <cpunum>
f01041f8:	83 ec 04             	sub    $0x4,%esp
f01041fb:	53                   	push   %ebx
f01041fc:	6b c0 74             	imul   $0x74,%eax,%eax
f01041ff:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0104205:	ff 70 48             	pushl  0x48(%eax)
f0104208:	68 c6 74 10 f0       	push   $0xf01074c6
f010420d:	e8 8f f3 ff ff       	call   f01035a1 <cprintf>
f0104212:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104215:	83 ec 0c             	sub    $0xc,%esp
f0104218:	ff 75 e4             	pushl  -0x1c(%ebp)
f010421b:	e8 91 f0 ff ff       	call   f01032b1 <env_destroy>
f0104220:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104223:	b8 00 00 00 00       	mov    $0x0,%eax
f0104228:	e9 69 04 00 00       	jmp    f0104696 <syscall+0x559>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f010422d:	e8 60 15 00 00       	call   f0105792 <cpunum>
f0104232:	6b c0 74             	imul   $0x74,%eax,%eax
f0104235:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f010423b:	8b 40 48             	mov    0x48(%eax),%eax
	case SYS_cgetc:
		return sys_cgetc();
	case SYS_env_destroy:
		return sys_env_destroy(a1);
	case SYS_getenvid:
		return sys_getenvid();
f010423e:	e9 53 04 00 00       	jmp    f0104696 <syscall+0x559>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104243:	e8 42 fe ff ff       	call   f010408a <sched_yield>
	struct PageInfo *pp;
	int ret;

	//cprintf("id:--------%d\n",envid);

	if ((ret = envid2env(envid, &e, 1)) < 0)
f0104248:	83 ec 04             	sub    $0x4,%esp
f010424b:	6a 01                	push   $0x1
f010424d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104250:	50                   	push   %eax
f0104251:	ff 75 0c             	pushl  0xc(%ebp)
f0104254:	e8 ab ea ff ff       	call   f0102d04 <envid2env>
f0104259:	83 c4 10             	add    $0x10,%esp
f010425c:	85 c0                	test   %eax,%eax
f010425e:	0f 88 32 04 00 00    	js     f0104696 <syscall+0x559>
		return ret;

	if (va >= (void *)UTOP || PGOFF(va) != 0)
f0104264:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010426b:	77 60                	ja     f01042cd <syscall+0x190>
f010426d:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104274:	75 61                	jne    f01042d7 <syscall+0x19a>
		return -E_INVAL;

	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
f0104276:	8b 45 14             	mov    0x14(%ebp),%eax
f0104279:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f010427e:	83 f8 05             	cmp    $0x5,%eax
f0104281:	75 5e                	jne    f01042e1 <syscall+0x1a4>
		return -E_INVAL;

	// 申请一个物理页
	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
f0104283:	83 ec 0c             	sub    $0xc,%esp
f0104286:	6a 01                	push   $0x1
f0104288:	e8 b5 cb ff ff       	call   f0100e42 <page_alloc>
f010428d:	89 c3                	mov    %eax,%ebx
f010428f:	83 c4 10             	add    $0x10,%esp
f0104292:	85 c0                	test   %eax,%eax
f0104294:	74 55                	je     f01042eb <syscall+0x1ae>
		return -E_NO_MEM;
	
	// 映射物理页到进程的虚拟空间中
	if ((ret = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
f0104296:	ff 75 14             	pushl  0x14(%ebp)
f0104299:	ff 75 10             	pushl  0x10(%ebp)
f010429c:	50                   	push   %eax
f010429d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042a0:	ff 70 60             	pushl  0x60(%eax)
f01042a3:	e8 70 ce ff ff       	call   f0101118 <page_insert>
f01042a8:	89 c6                	mov    %eax,%esi
f01042aa:	83 c4 10             	add    $0x10,%esp
		page_free(pp);
		return ret;
	}

	return 0;
f01042ad:	b8 00 00 00 00       	mov    $0x0,%eax
	// 申请一个物理页
	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
		return -E_NO_MEM;
	
	// 映射物理页到进程的虚拟空间中
	if ((ret = page_insert(e->env_pgdir, pp, va, perm)) < 0) {
f01042b2:	85 f6                	test   %esi,%esi
f01042b4:	0f 89 dc 03 00 00    	jns    f0104696 <syscall+0x559>
		page_free(pp);
f01042ba:	83 ec 0c             	sub    $0xc,%esp
f01042bd:	53                   	push   %ebx
f01042be:	e8 ef cb ff ff       	call   f0100eb2 <page_free>
f01042c3:	83 c4 10             	add    $0x10,%esp
		return ret;
f01042c6:	89 f0                	mov    %esi,%eax
f01042c8:	e9 c9 03 00 00       	jmp    f0104696 <syscall+0x559>

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (va >= (void *)UTOP || PGOFF(va) != 0)
		return -E_INVAL;
f01042cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01042d2:	e9 bf 03 00 00       	jmp    f0104696 <syscall+0x559>
f01042d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01042dc:	e9 b5 03 00 00       	jmp    f0104696 <syscall+0x559>

	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;
f01042e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01042e6:	e9 ab 03 00 00       	jmp    f0104696 <syscall+0x559>

	// 申请一个物理页
	if ((pp = page_alloc(ALLOC_ZERO)) == NULL)
		return -E_NO_MEM;
f01042eb:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01042f0:	e9 a1 03 00 00       	jmp    f0104696 <syscall+0x559>
	struct Env *srcenv, *dstenv;
	struct PageInfo *pp;
	pte_t *pte;
	int ret;
	
	if ((ret = envid2env(srcenvid, &srcenv, 1)) < 0)
f01042f5:	83 ec 04             	sub    $0x4,%esp
f01042f8:	6a 01                	push   $0x1
f01042fa:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01042fd:	50                   	push   %eax
f01042fe:	ff 75 0c             	pushl  0xc(%ebp)
f0104301:	e8 fe e9 ff ff       	call   f0102d04 <envid2env>
f0104306:	83 c4 10             	add    $0x10,%esp
f0104309:	85 c0                	test   %eax,%eax
f010430b:	0f 88 85 03 00 00    	js     f0104696 <syscall+0x559>
		return ret;
	if ((ret = envid2env(dstenvid, &dstenv, 1)) < 0)
f0104311:	83 ec 04             	sub    $0x4,%esp
f0104314:	6a 01                	push   $0x1
f0104316:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104319:	50                   	push   %eax
f010431a:	ff 75 14             	pushl  0x14(%ebp)
f010431d:	e8 e2 e9 ff ff       	call   f0102d04 <envid2env>
f0104322:	83 c4 10             	add    $0x10,%esp
f0104325:	85 c0                	test   %eax,%eax
f0104327:	0f 88 69 03 00 00    	js     f0104696 <syscall+0x559>
		return ret;

	if (srcva >= (void *) UTOP || PGOFF(srcva) != 0)
f010432d:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f0104334:	77 76                	ja     f01043ac <syscall+0x26f>
		return -E_INVAL;
	if (dstva >= (void *) UTOP || PGOFF(dstva) != 0)
f0104336:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f010433d:	75 77                	jne    f01043b6 <syscall+0x279>
f010433f:	81 7d 18 ff ff bf ee 	cmpl   $0xeebfffff,0x18(%ebp)
f0104346:	77 6e                	ja     f01043b6 <syscall+0x279>
f0104348:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010434f:	75 6f                	jne    f01043c0 <syscall+0x283>
		return -E_INVAL;
	
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
f0104351:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104354:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f0104359:	83 f8 05             	cmp    $0x5,%eax
f010435c:	75 6c                	jne    f01043ca <syscall+0x28d>
		return -E_INVAL;
	
	// 查到进程 srcenv 的虚拟地址srcva对应的物理页
	if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
f010435e:	83 ec 04             	sub    $0x4,%esp
f0104361:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104364:	50                   	push   %eax
f0104365:	ff 75 10             	pushl  0x10(%ebp)
f0104368:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010436b:	ff 70 60             	pushl  0x60(%eax)
f010436e:	e8 bb cc ff ff       	call   f010102e <page_lookup>
f0104373:	83 c4 10             	add    $0x10,%esp
f0104376:	85 c0                	test   %eax,%eax
f0104378:	74 5a                	je     f01043d4 <syscall+0x297>
		return -E_INVAL;

	if ((perm & PTE_W) && !(*pte & PTE_W))
f010437a:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010437e:	74 08                	je     f0104388 <syscall+0x24b>
f0104380:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104383:	f6 02 02             	testb  $0x2,(%edx)
f0104386:	74 56                	je     f01043de <syscall+0x2a1>
		return -E_INVAL;
	
	
	// 将进程虚拟地址 dstva 对应的虚拟页映射到物理页pp 
	if ((ret = page_insert(dstenv->env_pgdir, pp, dstva, perm)) < 0)
f0104388:	ff 75 1c             	pushl  0x1c(%ebp)
f010438b:	ff 75 18             	pushl  0x18(%ebp)
f010438e:	50                   	push   %eax
f010438f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104392:	ff 70 60             	pushl  0x60(%eax)
f0104395:	e8 7e cd ff ff       	call   f0101118 <page_insert>
f010439a:	83 c4 10             	add    $0x10,%esp
f010439d:	85 c0                	test   %eax,%eax
f010439f:	ba 00 00 00 00       	mov    $0x0,%edx
f01043a4:	0f 4f c2             	cmovg  %edx,%eax
f01043a7:	e9 ea 02 00 00       	jmp    f0104696 <syscall+0x559>
		return ret;
	if ((ret = envid2env(dstenvid, &dstenv, 1)) < 0)
		return ret;

	if (srcva >= (void *) UTOP || PGOFF(srcva) != 0)
		return -E_INVAL;
f01043ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01043b1:	e9 e0 02 00 00       	jmp    f0104696 <syscall+0x559>
	if (dstva >= (void *) UTOP || PGOFF(dstva) != 0)
		return -E_INVAL;
f01043b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01043bb:	e9 d6 02 00 00       	jmp    f0104696 <syscall+0x559>
f01043c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01043c5:	e9 cc 02 00 00       	jmp    f0104696 <syscall+0x559>
	
	if ((perm & (PTE_U | PTE_P)) != (PTE_U | PTE_P) || (perm & ~PTE_SYSCALL) != 0)
		return -E_INVAL;
f01043ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01043cf:	e9 c2 02 00 00       	jmp    f0104696 <syscall+0x559>
	
	// 查到进程 srcenv 的虚拟地址srcva对应的物理页
	if ((pp = page_lookup(srcenv->env_pgdir, srcva, &pte)) == NULL)
		return -E_INVAL;
f01043d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01043d9:	e9 b8 02 00 00       	jmp    f0104696 <syscall+0x559>

	if ((perm & PTE_W) && !(*pte & PTE_W))
		return -E_INVAL;
f01043de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		sys_yield();
		return 0;
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *) a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
f01043e3:	e9 ae 02 00 00       	jmp    f0104696 <syscall+0x559>
	// LAB 4: Your code here.
	//panic("sys_page_unmap not implemented");
	struct Env* e;
	int ret;

	if ((ret = envid2env(envid, &e, 1)) < 0)
f01043e8:	83 ec 04             	sub    $0x4,%esp
f01043eb:	6a 01                	push   $0x1
f01043ed:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01043f0:	50                   	push   %eax
f01043f1:	ff 75 0c             	pushl  0xc(%ebp)
f01043f4:	e8 0b e9 ff ff       	call   f0102d04 <envid2env>
f01043f9:	83 c4 10             	add    $0x10,%esp
f01043fc:	85 c0                	test   %eax,%eax
f01043fe:	0f 88 92 02 00 00    	js     f0104696 <syscall+0x559>
		return ret;

	if (va >= (void *) UTOP || PGOFF(va) != 0)
f0104404:	81 7d 10 ff ff bf ee 	cmpl   $0xeebfffff,0x10(%ebp)
f010440b:	77 27                	ja     f0104434 <syscall+0x2f7>
f010440d:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104414:	75 28                	jne    f010443e <syscall+0x301>
		return -E_INVAL;
	
	// 解除映射
	page_remove(e->env_pgdir, va);
f0104416:	83 ec 08             	sub    $0x8,%esp
f0104419:	ff 75 10             	pushl  0x10(%ebp)
f010441c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010441f:	ff 70 60             	pushl  0x60(%eax)
f0104422:	e8 a1 cc ff ff       	call   f01010c8 <page_remove>
f0104427:	83 c4 10             	add    $0x10,%esp

	return 0;
f010442a:	b8 00 00 00 00       	mov    $0x0,%eax
f010442f:	e9 62 02 00 00       	jmp    f0104696 <syscall+0x559>

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (va >= (void *) UTOP || PGOFF(va) != 0)
		return -E_INVAL;
f0104434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104439:	e9 58 02 00 00       	jmp    f0104696 <syscall+0x559>
f010443e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_alloc:
		return sys_page_alloc(a1, (void *) a2, a3);
	case SYS_page_map:
		return sys_page_map(a1, (void *) a2, a3, (void *) a4, a5);
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *) a2);
f0104443:	e9 4e 02 00 00       	jmp    f0104696 <syscall+0x559>
	// LAB 4: Your code here.
	//panic("sys_exofork not implemented");

	struct Env *e;
	// 申请一个新进程
	int ret = env_alloc(&e, curenv->env_id);
f0104448:	e8 45 13 00 00       	call   f0105792 <cpunum>
f010444d:	83 ec 08             	sub    $0x8,%esp
f0104450:	6b c0 74             	imul   $0x74,%eax,%eax
f0104453:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0104459:	ff 70 48             	pushl  0x48(%eax)
f010445c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010445f:	50                   	push   %eax
f0104460:	e8 b1 e9 ff ff       	call   f0102e16 <env_alloc>
	if (ret < 0) 
f0104465:	83 c4 10             	add    $0x10,%esp
f0104468:	85 c0                	test   %eax,%eax
f010446a:	0f 88 26 02 00 00    	js     f0104696 <syscall+0x559>
		return ret;
	
	// 初始化新进程
	e->env_status = ENV_NOT_RUNNABLE;
f0104470:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104473:	c7 43 54 04 00 00 00 	movl   $0x4,0x54(%ebx)
	e->env_tf = curenv->env_tf;
f010447a:	e8 13 13 00 00       	call   f0105792 <cpunum>
f010447f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104482:	8b b0 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%esi
f0104488:	b9 11 00 00 00       	mov    $0x11,%ecx
f010448d:	89 df                	mov    %ebx,%edi
f010448f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// 将子进程的返回值设置为0
	e->env_tf.tf_regs.reg_eax = 0;
f0104491:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104494:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

	return e->env_id;
f010449b:	8b 40 48             	mov    0x48(%eax),%eax
f010449e:	e9 f3 01 00 00       	jmp    f0104696 <syscall+0x559>

	// LAB 4: Your code here.
	struct Env *e;
	int ret;

	if ((ret = envid2env(envid, &e, 1)) < 0)
f01044a3:	83 ec 04             	sub    $0x4,%esp
f01044a6:	6a 01                	push   $0x1
f01044a8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01044ab:	50                   	push   %eax
f01044ac:	ff 75 0c             	pushl  0xc(%ebp)
f01044af:	e8 50 e8 ff ff       	call   f0102d04 <envid2env>
f01044b4:	83 c4 10             	add    $0x10,%esp
f01044b7:	85 c0                	test   %eax,%eax
f01044b9:	0f 88 d7 01 00 00    	js     f0104696 <syscall+0x559>
		return ret;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01044bf:	8b 45 10             	mov    0x10(%ebp),%eax
f01044c2:	83 e8 02             	sub    $0x2,%eax
f01044c5:	a9 fd ff ff ff       	test   $0xfffffffd,%eax
f01044ca:	75 13                	jne    f01044df <syscall+0x3a2>
		return -E_INVAL;

	e->env_status = status;
f01044cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01044cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
f01044d2:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f01044d5:	b8 00 00 00 00       	mov    $0x0,%eax
f01044da:	e9 b7 01 00 00       	jmp    f0104696 <syscall+0x559>

	if ((ret = envid2env(envid, &e, 1)) < 0)
		return ret;

	if (status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f01044df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	case SYS_page_unmap:
		return sys_page_unmap(a1, (void *) a2);
	case SYS_exofork:
		return sys_exofork();
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
f01044e4:	e9 ad 01 00 00       	jmp    f0104696 <syscall+0x559>
	//panic("sys_env_set_pgfault_upcall not implemented");

	struct Env *e;
	int ret;
	
	if ((ret = envid2env(envid, &e, 1)) < 0)
f01044e9:	83 ec 04             	sub    $0x4,%esp
f01044ec:	6a 01                	push   $0x1
f01044ee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01044f1:	50                   	push   %eax
f01044f2:	ff 75 0c             	pushl  0xc(%ebp)
f01044f5:	e8 0a e8 ff ff       	call   f0102d04 <envid2env>
f01044fa:	83 c4 10             	add    $0x10,%esp
f01044fd:	85 c0                	test   %eax,%eax
f01044ff:	0f 88 91 01 00 00    	js     f0104696 <syscall+0x559>
		return ret;

	e->env_pgfault_upcall = func;
f0104505:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104508:	8b 7d 10             	mov    0x10(%ebp),%edi
f010450b:	89 78 64             	mov    %edi,0x64(%eax)
	return 0;
f010450e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104513:	e9 7e 01 00 00       	jmp    f0104696 <syscall+0x559>
{
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
	struct Env *env;
	int r;
	if ((r = envid2env(envid, &env, 0)) < 0)
f0104518:	83 ec 04             	sub    $0x4,%esp
f010451b:	6a 00                	push   $0x0
f010451d:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104520:	50                   	push   %eax
f0104521:	ff 75 0c             	pushl  0xc(%ebp)
f0104524:	e8 db e7 ff ff       	call   f0102d04 <envid2env>
f0104529:	83 c4 10             	add    $0x10,%esp
f010452c:	85 c0                	test   %eax,%eax
f010452e:	0f 88 f6 00 00 00    	js     f010462a <syscall+0x4ed>
		return -E_BAD_ENV;
	if (env->env_ipc_recving == 0)
f0104534:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104537:	80 78 68 00          	cmpb   $0x0,0x68(%eax)
f010453b:	0f 84 f0 00 00 00    	je     f0104631 <syscall+0x4f4>
		return -E_IPC_NOT_RECV;
	if (srcva < (void *) UTOP) {
f0104541:	81 7d 14 ff ff bf ee 	cmpl   $0xeebfffff,0x14(%ebp)
f0104548:	0f 87 a3 00 00 00    	ja     f01045f1 <syscall+0x4b4>

		// if (perm & (~(PTE_U | PTE_P | PTE_AVAIL | PTE_W)))
		// 	return -E_INVAL;

		if (srcva != ROUNDDOWN(srcva, PGSIZE))
			return -E_INVAL;
f010454e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		// 	return -E_INVAL;

		// if (perm & (~(PTE_U | PTE_P | PTE_AVAIL | PTE_W)))
		// 	return -E_INVAL;

		if (srcva != ROUNDDOWN(srcva, PGSIZE))
f0104553:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f010455a:	0f 85 36 01 00 00    	jne    f0104696 <syscall+0x559>
		
		// 根据发送者(当前进程)提供的虚拟地址找到对应的物理页，再将该物理页映射到接受者的虚拟空间

		pte_t *pte;
		// 1.根据发送者提供的虚拟地址查找发送内容所在的物理页
		struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
f0104560:	e8 2d 12 00 00       	call   f0105792 <cpunum>
f0104565:	83 ec 04             	sub    $0x4,%esp
f0104568:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f010456b:	52                   	push   %edx
f010456c:	ff 75 14             	pushl  0x14(%ebp)
f010456f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104572:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0104578:	ff 70 60             	pushl  0x60(%eax)
f010457b:	e8 ae ca ff ff       	call   f010102e <page_lookup>
f0104580:	89 c2                	mov    %eax,%edx
		if (!page)
f0104582:	83 c4 10             	add    $0x10,%esp
f0104585:	85 c0                	test   %eax,%eax
f0104587:	74 54                	je     f01045dd <syscall+0x4a0>
			return -E_INVAL;

		if ((*pte & perm) != perm) return -E_INVAL;
f0104589:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010458c:	8b 08                	mov    (%eax),%ecx
f010458e:	89 cb                	mov    %ecx,%ebx
f0104590:	23 5d 18             	and    0x18(%ebp),%ebx
f0104593:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104598:	39 5d 18             	cmp    %ebx,0x18(%ebp)
f010459b:	0f 85 f5 00 00 00    	jne    f0104696 <syscall+0x559>

		if ((perm & PTE_W) && !(*pte & PTE_W))
f01045a1:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f01045a5:	74 09                	je     f01045b0 <syscall+0x473>
f01045a7:	f6 c1 02             	test   $0x2,%cl
f01045aa:	0f 84 e6 00 00 00    	je     f0104696 <syscall+0x559>
			return -E_INVAL;
		// 2.将物理页映射到接受者的虚拟空间中
		if (env->env_ipc_dstva < (void *) UTOP) {
f01045b0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045b3:	8b 48 6c             	mov    0x6c(%eax),%ecx
f01045b6:	81 f9 ff ff bf ee    	cmp    $0xeebfffff,%ecx
f01045bc:	77 33                	ja     f01045f1 <syscall+0x4b4>
			if ((r = page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) < 0)
f01045be:	ff 75 18             	pushl  0x18(%ebp)
f01045c1:	51                   	push   %ecx
f01045c2:	52                   	push   %edx
f01045c3:	ff 70 60             	pushl  0x60(%eax)
f01045c6:	e8 4d cb ff ff       	call   f0101118 <page_insert>
f01045cb:	83 c4 10             	add    $0x10,%esp
f01045ce:	85 c0                	test   %eax,%eax
f01045d0:	78 15                	js     f01045e7 <syscall+0x4aa>
				return -E_NO_MEM;
			env->env_ipc_perm = perm;
f01045d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045d5:	8b 4d 18             	mov    0x18(%ebp),%ecx
f01045d8:	89 48 78             	mov    %ecx,0x78(%eax)
f01045db:	eb 14                	jmp    f01045f1 <syscall+0x4b4>

		pte_t *pte;
		// 1.根据发送者提供的虚拟地址查找发送内容所在的物理页
		struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
		if (!page)
			return -E_INVAL;
f01045dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f01045e2:	e9 af 00 00 00       	jmp    f0104696 <syscall+0x559>
		if ((perm & PTE_W) && !(*pte & PTE_W))
			return -E_INVAL;
		// 2.将物理页映射到接受者的虚拟空间中
		if (env->env_ipc_dstva < (void *) UTOP) {
			if ((r = page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) < 0)
				return -E_NO_MEM;
f01045e7:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f01045ec:	e9 a5 00 00 00       	jmp    f0104696 <syscall+0x559>
			env->env_ipc_perm = perm;
		}
	}
	// 3.更新接受者的信息，通知其消息已经发送
	env->env_ipc_recving = 0;
f01045f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f01045f4:	c6 43 68 00          	movb   $0x0,0x68(%ebx)
	env->env_ipc_from = curenv->env_id;
f01045f8:	e8 95 11 00 00       	call   f0105792 <cpunum>
f01045fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104600:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0104606:	8b 40 48             	mov    0x48(%eax),%eax
f0104609:	89 43 74             	mov    %eax,0x74(%ebx)
	env->env_ipc_value = value;
f010460c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010460f:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104612:	89 78 70             	mov    %edi,0x70(%eax)
	// 将接受进程设置为ENV_RUNNABLE，使得其可以重新参与调度
	env->env_status = ENV_RUNNABLE;
f0104615:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
	// ???
	env->env_tf.tf_regs.reg_eax = 0;
f010461c:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return 0;
f0104623:	b8 00 00 00 00       	mov    $0x0,%eax
f0104628:	eb 6c                	jmp    f0104696 <syscall+0x559>
	// LAB 4: Your code here.
	//panic("sys_ipc_try_send not implemented");
	struct Env *env;
	int r;
	if ((r = envid2env(envid, &env, 0)) < 0)
		return -E_BAD_ENV;
f010462a:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f010462f:	eb 65                	jmp    f0104696 <syscall+0x559>
	if (env->env_ipc_recving == 0)
		return -E_IPC_NOT_RECV;
f0104631:	b8 f9 ff ff ff       	mov    $0xfffffff9,%eax
	case SYS_env_set_status:
		return sys_env_set_status(a1, a2);
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *) a2);	
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
f0104636:	eb 5e                	jmp    f0104696 <syscall+0x559>
// 参数为接受消息的虚拟页的起始地址
static int
sys_ipc_recv(void *dstva)
{
	// LAB 4: Your code here.
	if (dstva < (void *) UTOP && dstva != ROUNDDOWN(dstva, PGSIZE))
f0104638:	81 7d 0c ff ff bf ee 	cmpl   $0xeebfffff,0xc(%ebp)
f010463f:	77 09                	ja     f010464a <syscall+0x50d>
f0104641:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f0104648:	75 47                	jne    f0104691 <syscall+0x554>
		return -E_INVAL;
	
	curenv->env_ipc_recving = 1;
f010464a:	e8 43 11 00 00       	call   f0105792 <cpunum>
f010464f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104652:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f0104658:	c6 40 68 01          	movb   $0x1,0x68(%eax)
	curenv->env_ipc_dstva = dstva;
f010465c:	e8 31 11 00 00       	call   f0105792 <cpunum>
f0104661:	6b c0 74             	imul   $0x74,%eax,%eax
f0104664:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f010466a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010466d:	89 48 6c             	mov    %ecx,0x6c(%eax)
	// 设置当前进程为
	curenv->env_status = ENV_NOT_RUNNABLE;
f0104670:	e8 1d 11 00 00       	call   f0105792 <cpunum>
f0104675:	6b c0 74             	imul   $0x74,%eax,%eax
f0104678:	8b 80 28 f0 22 f0    	mov    -0xfdd0fd8(%eax),%eax
f010467e:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104685:	e8 00 fa ff ff       	call   f010408a <sched_yield>
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *) a1);
	default:
		return -E_INVAL;
f010468a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f010468f:	eb 05                	jmp    f0104696 <syscall+0x559>
	case SYS_env_set_pgfault_upcall:
		return sys_env_set_pgfault_upcall(a1, (void *) a2);	
	case SYS_ipc_try_send:
		return sys_ipc_try_send(a1, a2, (void *) a3, a4);
	case SYS_ipc_recv:
		return sys_ipc_recv((void *) a1);
f0104691:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	default:
		return -E_INVAL;
	}
	panic("syscall not implemented");
}
f0104696:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104699:	5b                   	pop    %ebx
f010469a:	5e                   	pop    %esi
f010469b:	5f                   	pop    %edi
f010469c:	5d                   	pop    %ebp
f010469d:	c3                   	ret    

f010469e <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f010469e:	55                   	push   %ebp
f010469f:	89 e5                	mov    %esp,%ebp
f01046a1:	57                   	push   %edi
f01046a2:	56                   	push   %esi
f01046a3:	53                   	push   %ebx
f01046a4:	83 ec 14             	sub    $0x14,%esp
f01046a7:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01046aa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01046ad:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01046b0:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01046b3:	8b 1a                	mov    (%edx),%ebx
f01046b5:	8b 01                	mov    (%ecx),%eax
f01046b7:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01046ba:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01046c1:	eb 7f                	jmp    f0104742 <stab_binsearch+0xa4>
		int true_m = (l + r) / 2, m = true_m;
f01046c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01046c6:	01 d8                	add    %ebx,%eax
f01046c8:	89 c6                	mov    %eax,%esi
f01046ca:	c1 ee 1f             	shr    $0x1f,%esi
f01046cd:	01 c6                	add    %eax,%esi
f01046cf:	d1 fe                	sar    %esi
f01046d1:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01046d4:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01046d7:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01046da:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01046dc:	eb 03                	jmp    f01046e1 <stab_binsearch+0x43>
			m--;
f01046de:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01046e1:	39 c3                	cmp    %eax,%ebx
f01046e3:	7f 0d                	jg     f01046f2 <stab_binsearch+0x54>
f01046e5:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01046e9:	83 ea 0c             	sub    $0xc,%edx
f01046ec:	39 f9                	cmp    %edi,%ecx
f01046ee:	75 ee                	jne    f01046de <stab_binsearch+0x40>
f01046f0:	eb 05                	jmp    f01046f7 <stab_binsearch+0x59>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f01046f2:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f01046f5:	eb 4b                	jmp    f0104742 <stab_binsearch+0xa4>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01046f7:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01046fa:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01046fd:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104701:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104704:	76 11                	jbe    f0104717 <stab_binsearch+0x79>
			*region_left = m;
f0104706:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104709:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f010470b:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010470e:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104715:	eb 2b                	jmp    f0104742 <stab_binsearch+0xa4>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104717:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010471a:	73 14                	jae    f0104730 <stab_binsearch+0x92>
			*region_right = m - 1;
f010471c:	83 e8 01             	sub    $0x1,%eax
f010471f:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104722:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104725:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104727:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010472e:	eb 12                	jmp    f0104742 <stab_binsearch+0xa4>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104730:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104733:	89 06                	mov    %eax,(%esi)
			l = m;
			addr++;
f0104735:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104739:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010473b:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104742:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104745:	0f 8e 78 ff ff ff    	jle    f01046c3 <stab_binsearch+0x25>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010474b:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f010474f:	75 0f                	jne    f0104760 <stab_binsearch+0xc2>
		*region_right = *region_left - 1;
f0104751:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104754:	8b 00                	mov    (%eax),%eax
f0104756:	83 e8 01             	sub    $0x1,%eax
f0104759:	8b 75 e0             	mov    -0x20(%ebp),%esi
f010475c:	89 06                	mov    %eax,(%esi)
f010475e:	eb 2c                	jmp    f010478c <stab_binsearch+0xee>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104760:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104763:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104765:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104768:	8b 0e                	mov    (%esi),%ecx
f010476a:	8d 14 40             	lea    (%eax,%eax,2),%edx
f010476d:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104770:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104773:	eb 03                	jmp    f0104778 <stab_binsearch+0xda>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104775:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104778:	39 c8                	cmp    %ecx,%eax
f010477a:	7e 0b                	jle    f0104787 <stab_binsearch+0xe9>
		     l > *region_left && stabs[l].n_type != type;
f010477c:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104780:	83 ea 0c             	sub    $0xc,%edx
f0104783:	39 df                	cmp    %ebx,%edi
f0104785:	75 ee                	jne    f0104775 <stab_binsearch+0xd7>
		     l--)
			/* do nothing */;
		*region_left = l;
f0104787:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010478a:	89 06                	mov    %eax,(%esi)
	}
}
f010478c:	83 c4 14             	add    $0x14,%esp
f010478f:	5b                   	pop    %ebx
f0104790:	5e                   	pop    %esi
f0104791:	5f                   	pop    %edi
f0104792:	5d                   	pop    %ebp
f0104793:	c3                   	ret    

f0104794 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104794:	55                   	push   %ebp
f0104795:	89 e5                	mov    %esp,%ebp
f0104797:	57                   	push   %edi
f0104798:	56                   	push   %esi
f0104799:	53                   	push   %ebx
f010479a:	83 ec 2c             	sub    $0x2c,%esp
f010479d:	8b 7d 08             	mov    0x8(%ebp),%edi
f01047a0:	8b 75 0c             	mov    0xc(%ebp),%esi
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01047a3:	c7 06 14 75 10 f0    	movl   $0xf0107514,(%esi)
	info->eip_line = 0;
f01047a9:	c7 46 04 00 00 00 00 	movl   $0x0,0x4(%esi)
	info->eip_fn_name = "<unknown>";
f01047b0:	c7 46 08 14 75 10 f0 	movl   $0xf0107514,0x8(%esi)
	info->eip_fn_namelen = 9;
f01047b7:	c7 46 0c 09 00 00 00 	movl   $0x9,0xc(%esi)
	info->eip_fn_addr = addr;
f01047be:	89 7e 10             	mov    %edi,0x10(%esi)
	info->eip_fn_narg = 0;
f01047c1:	c7 46 14 00 00 00 00 	movl   $0x0,0x14(%esi)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01047c8:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01047ce:	77 21                	ja     f01047f1 <debuginfo_eip+0x5d>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.

		stabs = usd->stabs;
f01047d0:	a1 00 00 20 00       	mov    0x200000,%eax
f01047d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		stab_end = usd->stab_end;
f01047d8:	a1 04 00 20 00       	mov    0x200004,%eax
		stabstr = usd->stabstr;
f01047dd:	8b 0d 08 00 20 00    	mov    0x200008,%ecx
f01047e3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr_end = usd->stabstr_end;
f01047e6:	8b 0d 0c 00 20 00    	mov    0x20000c,%ecx
f01047ec:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f01047ef:	eb 1a                	jmp    f010480b <debuginfo_eip+0x77>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f01047f1:	c7 45 d0 fb 4d 11 f0 	movl   $0xf0114dfb,-0x30(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f01047f8:	c7 45 cc 99 17 11 f0 	movl   $0xf0111799,-0x34(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f01047ff:	b8 98 17 11 f0       	mov    $0xf0111798,%eax
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104804:	c7 45 d4 f4 79 10 f0 	movl   $0xf01079f4,-0x2c(%ebp)
		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010480b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010480e:	39 4d cc             	cmp    %ecx,-0x34(%ebp)
f0104811:	0f 83 2b 01 00 00    	jae    f0104942 <debuginfo_eip+0x1ae>
f0104817:	80 79 ff 00          	cmpb   $0x0,-0x1(%ecx)
f010481b:	0f 85 28 01 00 00    	jne    f0104949 <debuginfo_eip+0x1b5>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104821:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104828:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f010482b:	29 d8                	sub    %ebx,%eax
f010482d:	c1 f8 02             	sar    $0x2,%eax
f0104830:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104836:	83 e8 01             	sub    $0x1,%eax
f0104839:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f010483c:	57                   	push   %edi
f010483d:	6a 64                	push   $0x64
f010483f:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0104842:	89 c1                	mov    %eax,%ecx
f0104844:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104847:	89 d8                	mov    %ebx,%eax
f0104849:	e8 50 fe ff ff       	call   f010469e <stab_binsearch>
	if (lfile == 0)
f010484e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104851:	83 c4 08             	add    $0x8,%esp
f0104854:	85 c0                	test   %eax,%eax
f0104856:	0f 84 f4 00 00 00    	je     f0104950 <debuginfo_eip+0x1bc>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f010485c:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f010485f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104862:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104865:	57                   	push   %edi
f0104866:	6a 24                	push   $0x24
f0104868:	8d 45 d8             	lea    -0x28(%ebp),%eax
f010486b:	89 c1                	mov    %eax,%ecx
f010486d:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104870:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104873:	89 d8                	mov    %ebx,%eax
f0104875:	e8 24 fe ff ff       	call   f010469e <stab_binsearch>

	if (lfun <= rfun) {
f010487a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010487d:	83 c4 08             	add    $0x8,%esp
f0104880:	3b 5d d8             	cmp    -0x28(%ebp),%ebx
f0104883:	7f 24                	jg     f01048a9 <debuginfo_eip+0x115>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104885:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0104888:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f010488b:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f010488e:	8b 02                	mov    (%edx),%eax
f0104890:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104893:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104896:	29 f9                	sub    %edi,%ecx
f0104898:	39 c8                	cmp    %ecx,%eax
f010489a:	73 05                	jae    f01048a1 <debuginfo_eip+0x10d>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f010489c:	01 f8                	add    %edi,%eax
f010489e:	89 46 08             	mov    %eax,0x8(%esi)
		info->eip_fn_addr = stabs[lfun].n_value;
f01048a1:	8b 42 08             	mov    0x8(%edx),%eax
f01048a4:	89 46 10             	mov    %eax,0x10(%esi)
f01048a7:	eb 06                	jmp    f01048af <debuginfo_eip+0x11b>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f01048a9:	89 7e 10             	mov    %edi,0x10(%esi)
		lline = lfile;
f01048ac:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f01048af:	83 ec 08             	sub    $0x8,%esp
f01048b2:	6a 3a                	push   $0x3a
f01048b4:	ff 76 08             	pushl  0x8(%esi)
f01048b7:	e8 9a 08 00 00       	call   f0105156 <strfind>
f01048bc:	2b 46 08             	sub    0x8(%esi),%eax
f01048bf:	89 46 0c             	mov    %eax,0xc(%esi)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01048c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f01048c5:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01048c8:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f01048cb:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f01048ce:	83 c4 10             	add    $0x10,%esp
f01048d1:	eb 06                	jmp    f01048d9 <debuginfo_eip+0x145>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01048d3:	83 eb 01             	sub    $0x1,%ebx
f01048d6:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01048d9:	39 fb                	cmp    %edi,%ebx
f01048db:	7c 2d                	jl     f010490a <debuginfo_eip+0x176>
	       && stabs[lline].n_type != N_SOL
f01048dd:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f01048e1:	80 fa 84             	cmp    $0x84,%dl
f01048e4:	74 0b                	je     f01048f1 <debuginfo_eip+0x15d>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01048e6:	80 fa 64             	cmp    $0x64,%dl
f01048e9:	75 e8                	jne    f01048d3 <debuginfo_eip+0x13f>
f01048eb:	83 78 08 00          	cmpl   $0x0,0x8(%eax)
f01048ef:	74 e2                	je     f01048d3 <debuginfo_eip+0x13f>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01048f1:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f01048f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f01048f7:	8b 14 87             	mov    (%edi,%eax,4),%edx
f01048fa:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01048fd:	8b 7d cc             	mov    -0x34(%ebp),%edi
f0104900:	29 f8                	sub    %edi,%eax
f0104902:	39 c2                	cmp    %eax,%edx
f0104904:	73 04                	jae    f010490a <debuginfo_eip+0x176>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104906:	01 fa                	add    %edi,%edx
f0104908:	89 16                	mov    %edx,(%esi)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f010490a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f010490d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104910:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104915:	39 cb                	cmp    %ecx,%ebx
f0104917:	7d 43                	jge    f010495c <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
f0104919:	8d 53 01             	lea    0x1(%ebx),%edx
f010491c:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f010491f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104922:	8d 04 87             	lea    (%edi,%eax,4),%eax
f0104925:	eb 07                	jmp    f010492e <debuginfo_eip+0x19a>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104927:	83 46 14 01          	addl   $0x1,0x14(%esi)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f010492b:	83 c2 01             	add    $0x1,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f010492e:	39 ca                	cmp    %ecx,%edx
f0104930:	74 25                	je     f0104957 <debuginfo_eip+0x1c3>
f0104932:	83 c0 0c             	add    $0xc,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104935:	80 78 04 a0          	cmpb   $0xa0,0x4(%eax)
f0104939:	74 ec                	je     f0104927 <debuginfo_eip+0x193>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f010493b:	b8 00 00 00 00       	mov    $0x0,%eax
f0104940:	eb 1a                	jmp    f010495c <debuginfo_eip+0x1c8>
		// LAB 3: Your code here.
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104942:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104947:	eb 13                	jmp    f010495c <debuginfo_eip+0x1c8>
f0104949:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f010494e:	eb 0c                	jmp    f010495c <debuginfo_eip+0x1c8>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104950:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104955:	eb 05                	jmp    f010495c <debuginfo_eip+0x1c8>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104957:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010495c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010495f:	5b                   	pop    %ebx
f0104960:	5e                   	pop    %esi
f0104961:	5f                   	pop    %edi
f0104962:	5d                   	pop    %ebp
f0104963:	c3                   	ret    

f0104964 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104964:	55                   	push   %ebp
f0104965:	89 e5                	mov    %esp,%ebp
f0104967:	57                   	push   %edi
f0104968:	56                   	push   %esi
f0104969:	53                   	push   %ebx
f010496a:	83 ec 1c             	sub    $0x1c,%esp
f010496d:	89 c7                	mov    %eax,%edi
f010496f:	89 d6                	mov    %edx,%esi
f0104971:	8b 45 08             	mov    0x8(%ebp),%eax
f0104974:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104977:	89 45 d8             	mov    %eax,-0x28(%ebp)
f010497a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f010497d:	8b 4d 10             	mov    0x10(%ebp),%ecx
f0104980:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104985:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104988:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010498b:	39 d3                	cmp    %edx,%ebx
f010498d:	72 05                	jb     f0104994 <printnum+0x30>
f010498f:	39 45 10             	cmp    %eax,0x10(%ebp)
f0104992:	77 45                	ja     f01049d9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104994:	83 ec 0c             	sub    $0xc,%esp
f0104997:	ff 75 18             	pushl  0x18(%ebp)
f010499a:	8b 45 14             	mov    0x14(%ebp),%eax
f010499d:	8d 58 ff             	lea    -0x1(%eax),%ebx
f01049a0:	53                   	push   %ebx
f01049a1:	ff 75 10             	pushl  0x10(%ebp)
f01049a4:	83 ec 08             	sub    $0x8,%esp
f01049a7:	ff 75 e4             	pushl  -0x1c(%ebp)
f01049aa:	ff 75 e0             	pushl  -0x20(%ebp)
f01049ad:	ff 75 dc             	pushl  -0x24(%ebp)
f01049b0:	ff 75 d8             	pushl  -0x28(%ebp)
f01049b3:	e8 d8 11 00 00       	call   f0105b90 <__udivdi3>
f01049b8:	83 c4 18             	add    $0x18,%esp
f01049bb:	52                   	push   %edx
f01049bc:	50                   	push   %eax
f01049bd:	89 f2                	mov    %esi,%edx
f01049bf:	89 f8                	mov    %edi,%eax
f01049c1:	e8 9e ff ff ff       	call   f0104964 <printnum>
f01049c6:	83 c4 20             	add    $0x20,%esp
f01049c9:	eb 18                	jmp    f01049e3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f01049cb:	83 ec 08             	sub    $0x8,%esp
f01049ce:	56                   	push   %esi
f01049cf:	ff 75 18             	pushl  0x18(%ebp)
f01049d2:	ff d7                	call   *%edi
f01049d4:	83 c4 10             	add    $0x10,%esp
f01049d7:	eb 03                	jmp    f01049dc <printnum+0x78>
f01049d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f01049dc:	83 eb 01             	sub    $0x1,%ebx
f01049df:	85 db                	test   %ebx,%ebx
f01049e1:	7f e8                	jg     f01049cb <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f01049e3:	83 ec 08             	sub    $0x8,%esp
f01049e6:	56                   	push   %esi
f01049e7:	83 ec 04             	sub    $0x4,%esp
f01049ea:	ff 75 e4             	pushl  -0x1c(%ebp)
f01049ed:	ff 75 e0             	pushl  -0x20(%ebp)
f01049f0:	ff 75 dc             	pushl  -0x24(%ebp)
f01049f3:	ff 75 d8             	pushl  -0x28(%ebp)
f01049f6:	e8 c5 12 00 00       	call   f0105cc0 <__umoddi3>
f01049fb:	83 c4 14             	add    $0x14,%esp
f01049fe:	0f be 80 1e 75 10 f0 	movsbl -0xfef8ae2(%eax),%eax
f0104a05:	50                   	push   %eax
f0104a06:	ff d7                	call   *%edi
}
f0104a08:	83 c4 10             	add    $0x10,%esp
f0104a0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104a0e:	5b                   	pop    %ebx
f0104a0f:	5e                   	pop    %esi
f0104a10:	5f                   	pop    %edi
f0104a11:	5d                   	pop    %ebp
f0104a12:	c3                   	ret    

f0104a13 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104a13:	55                   	push   %ebp
f0104a14:	89 e5                	mov    %esp,%ebp
f0104a16:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104a19:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104a1d:	8b 10                	mov    (%eax),%edx
f0104a1f:	3b 50 04             	cmp    0x4(%eax),%edx
f0104a22:	73 0a                	jae    f0104a2e <sprintputch+0x1b>
		*b->buf++ = ch;
f0104a24:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104a27:	89 08                	mov    %ecx,(%eax)
f0104a29:	8b 45 08             	mov    0x8(%ebp),%eax
f0104a2c:	88 02                	mov    %al,(%edx)
}
f0104a2e:	5d                   	pop    %ebp
f0104a2f:	c3                   	ret    

f0104a30 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104a30:	55                   	push   %ebp
f0104a31:	89 e5                	mov    %esp,%ebp
f0104a33:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104a36:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104a39:	50                   	push   %eax
f0104a3a:	ff 75 10             	pushl  0x10(%ebp)
f0104a3d:	ff 75 0c             	pushl  0xc(%ebp)
f0104a40:	ff 75 08             	pushl  0x8(%ebp)
f0104a43:	e8 05 00 00 00       	call   f0104a4d <vprintfmt>
	va_end(ap);
}
f0104a48:	83 c4 10             	add    $0x10,%esp
f0104a4b:	c9                   	leave  
f0104a4c:	c3                   	ret    

f0104a4d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104a4d:	55                   	push   %ebp
f0104a4e:	89 e5                	mov    %esp,%ebp
f0104a50:	57                   	push   %edi
f0104a51:	56                   	push   %esi
f0104a52:	53                   	push   %ebx
f0104a53:	83 ec 2c             	sub    $0x2c,%esp
f0104a56:	8b 75 08             	mov    0x8(%ebp),%esi
f0104a59:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104a5c:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104a5f:	eb 12                	jmp    f0104a73 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104a61:	85 c0                	test   %eax,%eax
f0104a63:	0f 84 42 04 00 00    	je     f0104eab <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
f0104a69:	83 ec 08             	sub    $0x8,%esp
f0104a6c:	53                   	push   %ebx
f0104a6d:	50                   	push   %eax
f0104a6e:	ff d6                	call   *%esi
f0104a70:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104a73:	83 c7 01             	add    $0x1,%edi
f0104a76:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104a7a:	83 f8 25             	cmp    $0x25,%eax
f0104a7d:	75 e2                	jne    f0104a61 <vprintfmt+0x14>
f0104a7f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104a83:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104a8a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104a91:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104a98:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104a9d:	eb 07                	jmp    f0104aa6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104a9f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104aa2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104aa6:	8d 47 01             	lea    0x1(%edi),%eax
f0104aa9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104aac:	0f b6 07             	movzbl (%edi),%eax
f0104aaf:	0f b6 d0             	movzbl %al,%edx
f0104ab2:	83 e8 23             	sub    $0x23,%eax
f0104ab5:	3c 55                	cmp    $0x55,%al
f0104ab7:	0f 87 d3 03 00 00    	ja     f0104e90 <vprintfmt+0x443>
f0104abd:	0f b6 c0             	movzbl %al,%eax
f0104ac0:	ff 24 85 e0 75 10 f0 	jmp    *-0xfef8a20(,%eax,4)
f0104ac7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104aca:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104ace:	eb d6                	jmp    f0104aa6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ad0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104ad3:	b8 00 00 00 00       	mov    $0x0,%eax
f0104ad8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104adb:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104ade:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
f0104ae2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
f0104ae5:	8d 4a d0             	lea    -0x30(%edx),%ecx
f0104ae8:	83 f9 09             	cmp    $0x9,%ecx
f0104aeb:	77 3f                	ja     f0104b2c <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104aed:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104af0:	eb e9                	jmp    f0104adb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104af2:	8b 45 14             	mov    0x14(%ebp),%eax
f0104af5:	8b 00                	mov    (%eax),%eax
f0104af7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0104afa:	8b 45 14             	mov    0x14(%ebp),%eax
f0104afd:	8d 40 04             	lea    0x4(%eax),%eax
f0104b00:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b03:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104b06:	eb 2a                	jmp    f0104b32 <vprintfmt+0xe5>
f0104b08:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104b0b:	85 c0                	test   %eax,%eax
f0104b0d:	ba 00 00 00 00       	mov    $0x0,%edx
f0104b12:	0f 49 d0             	cmovns %eax,%edx
f0104b15:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104b1b:	eb 89                	jmp    f0104aa6 <vprintfmt+0x59>
f0104b1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104b20:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104b27:	e9 7a ff ff ff       	jmp    f0104aa6 <vprintfmt+0x59>
f0104b2c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104b2f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104b32:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104b36:	0f 89 6a ff ff ff    	jns    f0104aa6 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104b3c:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104b3f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104b42:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104b49:	e9 58 ff ff ff       	jmp    f0104aa6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104b4e:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b51:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104b54:	e9 4d ff ff ff       	jmp    f0104aa6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104b59:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b5c:	8d 78 04             	lea    0x4(%eax),%edi
f0104b5f:	83 ec 08             	sub    $0x8,%esp
f0104b62:	53                   	push   %ebx
f0104b63:	ff 30                	pushl  (%eax)
f0104b65:	ff d6                	call   *%esi
			break;
f0104b67:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104b6a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104b6d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104b70:	e9 fe fe ff ff       	jmp    f0104a73 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104b75:	8b 45 14             	mov    0x14(%ebp),%eax
f0104b78:	8d 78 04             	lea    0x4(%eax),%edi
f0104b7b:	8b 00                	mov    (%eax),%eax
f0104b7d:	99                   	cltd   
f0104b7e:	31 d0                	xor    %edx,%eax
f0104b80:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104b82:	83 f8 08             	cmp    $0x8,%eax
f0104b85:	7f 0b                	jg     f0104b92 <vprintfmt+0x145>
f0104b87:	8b 14 85 40 77 10 f0 	mov    -0xfef88c0(,%eax,4),%edx
f0104b8e:	85 d2                	test   %edx,%edx
f0104b90:	75 1b                	jne    f0104bad <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
f0104b92:	50                   	push   %eax
f0104b93:	68 36 75 10 f0       	push   $0xf0107536
f0104b98:	53                   	push   %ebx
f0104b99:	56                   	push   %esi
f0104b9a:	e8 91 fe ff ff       	call   f0104a30 <printfmt>
f0104b9f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104ba2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104ba5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104ba8:	e9 c6 fe ff ff       	jmp    f0104a73 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104bad:	52                   	push   %edx
f0104bae:	68 bd 6c 10 f0       	push   $0xf0106cbd
f0104bb3:	53                   	push   %ebx
f0104bb4:	56                   	push   %esi
f0104bb5:	e8 76 fe ff ff       	call   f0104a30 <printfmt>
f0104bba:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
f0104bbd:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104bc0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104bc3:	e9 ab fe ff ff       	jmp    f0104a73 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104bc8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bcb:	83 c0 04             	add    $0x4,%eax
f0104bce:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0104bd1:	8b 45 14             	mov    0x14(%ebp),%eax
f0104bd4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
f0104bd6:	85 ff                	test   %edi,%edi
f0104bd8:	b8 2f 75 10 f0       	mov    $0xf010752f,%eax
f0104bdd:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
f0104be0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104be4:	0f 8e 94 00 00 00    	jle    f0104c7e <vprintfmt+0x231>
f0104bea:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104bee:	0f 84 98 00 00 00    	je     f0104c8c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104bf4:	83 ec 08             	sub    $0x8,%esp
f0104bf7:	ff 75 d0             	pushl  -0x30(%ebp)
f0104bfa:	57                   	push   %edi
f0104bfb:	e8 0c 04 00 00       	call   f010500c <strnlen>
f0104c00:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104c03:	29 c1                	sub    %eax,%ecx
f0104c05:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0104c08:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104c0b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104c0f:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104c12:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104c15:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104c17:	eb 0f                	jmp    f0104c28 <vprintfmt+0x1db>
					putch(padc, putdat);
f0104c19:	83 ec 08             	sub    $0x8,%esp
f0104c1c:	53                   	push   %ebx
f0104c1d:	ff 75 e0             	pushl  -0x20(%ebp)
f0104c20:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104c22:	83 ef 01             	sub    $0x1,%edi
f0104c25:	83 c4 10             	add    $0x10,%esp
f0104c28:	85 ff                	test   %edi,%edi
f0104c2a:	7f ed                	jg     f0104c19 <vprintfmt+0x1cc>
f0104c2c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104c2f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
f0104c32:	85 c9                	test   %ecx,%ecx
f0104c34:	b8 00 00 00 00       	mov    $0x0,%eax
f0104c39:	0f 49 c1             	cmovns %ecx,%eax
f0104c3c:	29 c1                	sub    %eax,%ecx
f0104c3e:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c41:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c44:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c47:	89 cb                	mov    %ecx,%ebx
f0104c49:	eb 4d                	jmp    f0104c98 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104c4b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104c4f:	74 1b                	je     f0104c6c <vprintfmt+0x21f>
f0104c51:	0f be c0             	movsbl %al,%eax
f0104c54:	83 e8 20             	sub    $0x20,%eax
f0104c57:	83 f8 5e             	cmp    $0x5e,%eax
f0104c5a:	76 10                	jbe    f0104c6c <vprintfmt+0x21f>
					putch('?', putdat);
f0104c5c:	83 ec 08             	sub    $0x8,%esp
f0104c5f:	ff 75 0c             	pushl  0xc(%ebp)
f0104c62:	6a 3f                	push   $0x3f
f0104c64:	ff 55 08             	call   *0x8(%ebp)
f0104c67:	83 c4 10             	add    $0x10,%esp
f0104c6a:	eb 0d                	jmp    f0104c79 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
f0104c6c:	83 ec 08             	sub    $0x8,%esp
f0104c6f:	ff 75 0c             	pushl  0xc(%ebp)
f0104c72:	52                   	push   %edx
f0104c73:	ff 55 08             	call   *0x8(%ebp)
f0104c76:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104c79:	83 eb 01             	sub    $0x1,%ebx
f0104c7c:	eb 1a                	jmp    f0104c98 <vprintfmt+0x24b>
f0104c7e:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c81:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c84:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c87:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104c8a:	eb 0c                	jmp    f0104c98 <vprintfmt+0x24b>
f0104c8c:	89 75 08             	mov    %esi,0x8(%ebp)
f0104c8f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104c92:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104c95:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104c98:	83 c7 01             	add    $0x1,%edi
f0104c9b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104c9f:	0f be d0             	movsbl %al,%edx
f0104ca2:	85 d2                	test   %edx,%edx
f0104ca4:	74 23                	je     f0104cc9 <vprintfmt+0x27c>
f0104ca6:	85 f6                	test   %esi,%esi
f0104ca8:	78 a1                	js     f0104c4b <vprintfmt+0x1fe>
f0104caa:	83 ee 01             	sub    $0x1,%esi
f0104cad:	79 9c                	jns    f0104c4b <vprintfmt+0x1fe>
f0104caf:	89 df                	mov    %ebx,%edi
f0104cb1:	8b 75 08             	mov    0x8(%ebp),%esi
f0104cb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cb7:	eb 18                	jmp    f0104cd1 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104cb9:	83 ec 08             	sub    $0x8,%esp
f0104cbc:	53                   	push   %ebx
f0104cbd:	6a 20                	push   $0x20
f0104cbf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104cc1:	83 ef 01             	sub    $0x1,%edi
f0104cc4:	83 c4 10             	add    $0x10,%esp
f0104cc7:	eb 08                	jmp    f0104cd1 <vprintfmt+0x284>
f0104cc9:	89 df                	mov    %ebx,%edi
f0104ccb:	8b 75 08             	mov    0x8(%ebp),%esi
f0104cce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104cd1:	85 ff                	test   %edi,%edi
f0104cd3:	7f e4                	jg     f0104cb9 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104cd5:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104cd8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104cdb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104cde:	e9 90 fd ff ff       	jmp    f0104a73 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104ce3:	83 f9 01             	cmp    $0x1,%ecx
f0104ce6:	7e 19                	jle    f0104d01 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
f0104ce8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104ceb:	8b 50 04             	mov    0x4(%eax),%edx
f0104cee:	8b 00                	mov    (%eax),%eax
f0104cf0:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104cf3:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104cf6:	8b 45 14             	mov    0x14(%ebp),%eax
f0104cf9:	8d 40 08             	lea    0x8(%eax),%eax
f0104cfc:	89 45 14             	mov    %eax,0x14(%ebp)
f0104cff:	eb 38                	jmp    f0104d39 <vprintfmt+0x2ec>
	else if (lflag)
f0104d01:	85 c9                	test   %ecx,%ecx
f0104d03:	74 1b                	je     f0104d20 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
f0104d05:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d08:	8b 00                	mov    (%eax),%eax
f0104d0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d0d:	89 c1                	mov    %eax,%ecx
f0104d0f:	c1 f9 1f             	sar    $0x1f,%ecx
f0104d12:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104d15:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d18:	8d 40 04             	lea    0x4(%eax),%eax
f0104d1b:	89 45 14             	mov    %eax,0x14(%ebp)
f0104d1e:	eb 19                	jmp    f0104d39 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
f0104d20:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d23:	8b 00                	mov    (%eax),%eax
f0104d25:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104d28:	89 c1                	mov    %eax,%ecx
f0104d2a:	c1 f9 1f             	sar    $0x1f,%ecx
f0104d2d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104d30:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d33:	8d 40 04             	lea    0x4(%eax),%eax
f0104d36:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104d39:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104d3c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104d3f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104d44:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104d48:	0f 89 0e 01 00 00    	jns    f0104e5c <vprintfmt+0x40f>
				putch('-', putdat);
f0104d4e:	83 ec 08             	sub    $0x8,%esp
f0104d51:	53                   	push   %ebx
f0104d52:	6a 2d                	push   $0x2d
f0104d54:	ff d6                	call   *%esi
				num = -(long long) num;
f0104d56:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104d59:	8b 4d dc             	mov    -0x24(%ebp),%ecx
f0104d5c:	f7 da                	neg    %edx
f0104d5e:	83 d1 00             	adc    $0x0,%ecx
f0104d61:	f7 d9                	neg    %ecx
f0104d63:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104d66:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d6b:	e9 ec 00 00 00       	jmp    f0104e5c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104d70:	83 f9 01             	cmp    $0x1,%ecx
f0104d73:	7e 18                	jle    f0104d8d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
f0104d75:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d78:	8b 10                	mov    (%eax),%edx
f0104d7a:	8b 48 04             	mov    0x4(%eax),%ecx
f0104d7d:	8d 40 08             	lea    0x8(%eax),%eax
f0104d80:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104d83:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104d88:	e9 cf 00 00 00       	jmp    f0104e5c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0104d8d:	85 c9                	test   %ecx,%ecx
f0104d8f:	74 1a                	je     f0104dab <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
f0104d91:	8b 45 14             	mov    0x14(%ebp),%eax
f0104d94:	8b 10                	mov    (%eax),%edx
f0104d96:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104d9b:	8d 40 04             	lea    0x4(%eax),%eax
f0104d9e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104da1:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104da6:	e9 b1 00 00 00       	jmp    f0104e5c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104dab:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dae:	8b 10                	mov    (%eax),%edx
f0104db0:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104db5:	8d 40 04             	lea    0x4(%eax),%eax
f0104db8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
f0104dbb:	b8 0a 00 00 00       	mov    $0xa,%eax
f0104dc0:	e9 97 00 00 00       	jmp    f0104e5c <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f0104dc5:	83 ec 08             	sub    $0x8,%esp
f0104dc8:	53                   	push   %ebx
f0104dc9:	6a 58                	push   $0x58
f0104dcb:	ff d6                	call   *%esi
			putch('X', putdat);
f0104dcd:	83 c4 08             	add    $0x8,%esp
f0104dd0:	53                   	push   %ebx
f0104dd1:	6a 58                	push   $0x58
f0104dd3:	ff d6                	call   *%esi
			putch('X', putdat);
f0104dd5:	83 c4 08             	add    $0x8,%esp
f0104dd8:	53                   	push   %ebx
f0104dd9:	6a 58                	push   $0x58
f0104ddb:	ff d6                	call   *%esi
			break;
f0104ddd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104de0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
f0104de3:	e9 8b fc ff ff       	jmp    f0104a73 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
f0104de8:	83 ec 08             	sub    $0x8,%esp
f0104deb:	53                   	push   %ebx
f0104dec:	6a 30                	push   $0x30
f0104dee:	ff d6                	call   *%esi
			putch('x', putdat);
f0104df0:	83 c4 08             	add    $0x8,%esp
f0104df3:	53                   	push   %ebx
f0104df4:	6a 78                	push   $0x78
f0104df6:	ff d6                	call   *%esi
			num = (unsigned long long)
f0104df8:	8b 45 14             	mov    0x14(%ebp),%eax
f0104dfb:	8b 10                	mov    (%eax),%edx
f0104dfd:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f0104e02:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0104e05:	8d 40 04             	lea    0x4(%eax),%eax
f0104e08:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
f0104e0b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
f0104e10:	eb 4a                	jmp    f0104e5c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104e12:	83 f9 01             	cmp    $0x1,%ecx
f0104e15:	7e 15                	jle    f0104e2c <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
f0104e17:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e1a:	8b 10                	mov    (%eax),%edx
f0104e1c:	8b 48 04             	mov    0x4(%eax),%ecx
f0104e1f:	8d 40 08             	lea    0x8(%eax),%eax
f0104e22:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104e25:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e2a:	eb 30                	jmp    f0104e5c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
f0104e2c:	85 c9                	test   %ecx,%ecx
f0104e2e:	74 17                	je     f0104e47 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
f0104e30:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e33:	8b 10                	mov    (%eax),%edx
f0104e35:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e3a:	8d 40 04             	lea    0x4(%eax),%eax
f0104e3d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104e40:	b8 10 00 00 00       	mov    $0x10,%eax
f0104e45:	eb 15                	jmp    f0104e5c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f0104e47:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e4a:	8b 10                	mov    (%eax),%edx
f0104e4c:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104e51:	8d 40 04             	lea    0x4(%eax),%eax
f0104e54:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
f0104e57:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
f0104e5c:	83 ec 0c             	sub    $0xc,%esp
f0104e5f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0104e63:	57                   	push   %edi
f0104e64:	ff 75 e0             	pushl  -0x20(%ebp)
f0104e67:	50                   	push   %eax
f0104e68:	51                   	push   %ecx
f0104e69:	52                   	push   %edx
f0104e6a:	89 da                	mov    %ebx,%edx
f0104e6c:	89 f0                	mov    %esi,%eax
f0104e6e:	e8 f1 fa ff ff       	call   f0104964 <printnum>
			break;
f0104e73:	83 c4 20             	add    $0x20,%esp
f0104e76:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e79:	e9 f5 fb ff ff       	jmp    f0104a73 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0104e7e:	83 ec 08             	sub    $0x8,%esp
f0104e81:	53                   	push   %ebx
f0104e82:	52                   	push   %edx
f0104e83:	ff d6                	call   *%esi
			break;
f0104e85:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e88:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0104e8b:	e9 e3 fb ff ff       	jmp    f0104a73 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0104e90:	83 ec 08             	sub    $0x8,%esp
f0104e93:	53                   	push   %ebx
f0104e94:	6a 25                	push   $0x25
f0104e96:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0104e98:	83 c4 10             	add    $0x10,%esp
f0104e9b:	eb 03                	jmp    f0104ea0 <vprintfmt+0x453>
f0104e9d:	83 ef 01             	sub    $0x1,%edi
f0104ea0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f0104ea4:	75 f7                	jne    f0104e9d <vprintfmt+0x450>
f0104ea6:	e9 c8 fb ff ff       	jmp    f0104a73 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f0104eab:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104eae:	5b                   	pop    %ebx
f0104eaf:	5e                   	pop    %esi
f0104eb0:	5f                   	pop    %edi
f0104eb1:	5d                   	pop    %ebp
f0104eb2:	c3                   	ret    

f0104eb3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0104eb3:	55                   	push   %ebp
f0104eb4:	89 e5                	mov    %esp,%ebp
f0104eb6:	83 ec 18             	sub    $0x18,%esp
f0104eb9:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ebc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f0104ebf:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104ec2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f0104ec6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f0104ec9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f0104ed0:	85 c0                	test   %eax,%eax
f0104ed2:	74 26                	je     f0104efa <vsnprintf+0x47>
f0104ed4:	85 d2                	test   %edx,%edx
f0104ed6:	7e 22                	jle    f0104efa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0104ed8:	ff 75 14             	pushl  0x14(%ebp)
f0104edb:	ff 75 10             	pushl  0x10(%ebp)
f0104ede:	8d 45 ec             	lea    -0x14(%ebp),%eax
f0104ee1:	50                   	push   %eax
f0104ee2:	68 13 4a 10 f0       	push   $0xf0104a13
f0104ee7:	e8 61 fb ff ff       	call   f0104a4d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0104eec:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104eef:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0104ef2:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104ef5:	83 c4 10             	add    $0x10,%esp
f0104ef8:	eb 05                	jmp    f0104eff <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0104efa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0104eff:	c9                   	leave  
f0104f00:	c3                   	ret    

f0104f01 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0104f01:	55                   	push   %ebp
f0104f02:	89 e5                	mov    %esp,%ebp
f0104f04:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0104f07:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0104f0a:	50                   	push   %eax
f0104f0b:	ff 75 10             	pushl  0x10(%ebp)
f0104f0e:	ff 75 0c             	pushl  0xc(%ebp)
f0104f11:	ff 75 08             	pushl  0x8(%ebp)
f0104f14:	e8 9a ff ff ff       	call   f0104eb3 <vsnprintf>
	va_end(ap);

	return rc;
}
f0104f19:	c9                   	leave  
f0104f1a:	c3                   	ret    

f0104f1b <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0104f1b:	55                   	push   %ebp
f0104f1c:	89 e5                	mov    %esp,%ebp
f0104f1e:	57                   	push   %edi
f0104f1f:	56                   	push   %esi
f0104f20:	53                   	push   %ebx
f0104f21:	83 ec 0c             	sub    $0xc,%esp
f0104f24:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f0104f27:	85 c0                	test   %eax,%eax
f0104f29:	74 11                	je     f0104f3c <readline+0x21>
		cprintf("%s", prompt);
f0104f2b:	83 ec 08             	sub    $0x8,%esp
f0104f2e:	50                   	push   %eax
f0104f2f:	68 bd 6c 10 f0       	push   $0xf0106cbd
f0104f34:	e8 68 e6 ff ff       	call   f01035a1 <cprintf>
f0104f39:	83 c4 10             	add    $0x10,%esp

	i = 0;
	echoing = iscons(0);
f0104f3c:	83 ec 0c             	sub    $0xc,%esp
f0104f3f:	6a 00                	push   $0x0
f0104f41:	e8 3f b8 ff ff       	call   f0100785 <iscons>
f0104f46:	89 c7                	mov    %eax,%edi
f0104f48:	83 c4 10             	add    $0x10,%esp
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0104f4b:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0104f50:	e8 1f b8 ff ff       	call   f0100774 <getchar>
f0104f55:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f0104f57:	85 c0                	test   %eax,%eax
f0104f59:	79 18                	jns    f0104f73 <readline+0x58>
			cprintf("read error: %e\n", c);
f0104f5b:	83 ec 08             	sub    $0x8,%esp
f0104f5e:	50                   	push   %eax
f0104f5f:	68 64 77 10 f0       	push   $0xf0107764
f0104f64:	e8 38 e6 ff ff       	call   f01035a1 <cprintf>
			return NULL;
f0104f69:	83 c4 10             	add    $0x10,%esp
f0104f6c:	b8 00 00 00 00       	mov    $0x0,%eax
f0104f71:	eb 79                	jmp    f0104fec <readline+0xd1>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0104f73:	83 f8 08             	cmp    $0x8,%eax
f0104f76:	0f 94 c2             	sete   %dl
f0104f79:	83 f8 7f             	cmp    $0x7f,%eax
f0104f7c:	0f 94 c0             	sete   %al
f0104f7f:	08 c2                	or     %al,%dl
f0104f81:	74 1a                	je     f0104f9d <readline+0x82>
f0104f83:	85 f6                	test   %esi,%esi
f0104f85:	7e 16                	jle    f0104f9d <readline+0x82>
			if (echoing)
f0104f87:	85 ff                	test   %edi,%edi
f0104f89:	74 0d                	je     f0104f98 <readline+0x7d>
				cputchar('\b');
f0104f8b:	83 ec 0c             	sub    $0xc,%esp
f0104f8e:	6a 08                	push   $0x8
f0104f90:	e8 cf b7 ff ff       	call   f0100764 <cputchar>
f0104f95:	83 c4 10             	add    $0x10,%esp
			i--;
f0104f98:	83 ee 01             	sub    $0x1,%esi
f0104f9b:	eb b3                	jmp    f0104f50 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0104f9d:	83 fb 1f             	cmp    $0x1f,%ebx
f0104fa0:	7e 23                	jle    f0104fc5 <readline+0xaa>
f0104fa2:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0104fa8:	7f 1b                	jg     f0104fc5 <readline+0xaa>
			if (echoing)
f0104faa:	85 ff                	test   %edi,%edi
f0104fac:	74 0c                	je     f0104fba <readline+0x9f>
				cputchar(c);
f0104fae:	83 ec 0c             	sub    $0xc,%esp
f0104fb1:	53                   	push   %ebx
f0104fb2:	e8 ad b7 ff ff       	call   f0100764 <cputchar>
f0104fb7:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f0104fba:	88 9e 80 ea 22 f0    	mov    %bl,-0xfdd1580(%esi)
f0104fc0:	8d 76 01             	lea    0x1(%esi),%esi
f0104fc3:	eb 8b                	jmp    f0104f50 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f0104fc5:	83 fb 0a             	cmp    $0xa,%ebx
f0104fc8:	74 05                	je     f0104fcf <readline+0xb4>
f0104fca:	83 fb 0d             	cmp    $0xd,%ebx
f0104fcd:	75 81                	jne    f0104f50 <readline+0x35>
			if (echoing)
f0104fcf:	85 ff                	test   %edi,%edi
f0104fd1:	74 0d                	je     f0104fe0 <readline+0xc5>
				cputchar('\n');
f0104fd3:	83 ec 0c             	sub    $0xc,%esp
f0104fd6:	6a 0a                	push   $0xa
f0104fd8:	e8 87 b7 ff ff       	call   f0100764 <cputchar>
f0104fdd:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f0104fe0:	c6 86 80 ea 22 f0 00 	movb   $0x0,-0xfdd1580(%esi)
			return buf;
f0104fe7:	b8 80 ea 22 f0       	mov    $0xf022ea80,%eax
		}
	}
}
f0104fec:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104fef:	5b                   	pop    %ebx
f0104ff0:	5e                   	pop    %esi
f0104ff1:	5f                   	pop    %edi
f0104ff2:	5d                   	pop    %ebp
f0104ff3:	c3                   	ret    

f0104ff4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0104ff4:	55                   	push   %ebp
f0104ff5:	89 e5                	mov    %esp,%ebp
f0104ff7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0104ffa:	b8 00 00 00 00       	mov    $0x0,%eax
f0104fff:	eb 03                	jmp    f0105004 <strlen+0x10>
		n++;
f0105001:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105004:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105008:	75 f7                	jne    f0105001 <strlen+0xd>
		n++;
	return n;
}
f010500a:	5d                   	pop    %ebp
f010500b:	c3                   	ret    

f010500c <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010500c:	55                   	push   %ebp
f010500d:	89 e5                	mov    %esp,%ebp
f010500f:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105012:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105015:	ba 00 00 00 00       	mov    $0x0,%edx
f010501a:	eb 03                	jmp    f010501f <strnlen+0x13>
		n++;
f010501c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010501f:	39 c2                	cmp    %eax,%edx
f0105021:	74 08                	je     f010502b <strnlen+0x1f>
f0105023:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105027:	75 f3                	jne    f010501c <strnlen+0x10>
f0105029:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f010502b:	5d                   	pop    %ebp
f010502c:	c3                   	ret    

f010502d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010502d:	55                   	push   %ebp
f010502e:	89 e5                	mov    %esp,%ebp
f0105030:	53                   	push   %ebx
f0105031:	8b 45 08             	mov    0x8(%ebp),%eax
f0105034:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105037:	89 c2                	mov    %eax,%edx
f0105039:	83 c2 01             	add    $0x1,%edx
f010503c:	83 c1 01             	add    $0x1,%ecx
f010503f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105043:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105046:	84 db                	test   %bl,%bl
f0105048:	75 ef                	jne    f0105039 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f010504a:	5b                   	pop    %ebx
f010504b:	5d                   	pop    %ebp
f010504c:	c3                   	ret    

f010504d <strcat>:

char *
strcat(char *dst, const char *src)
{
f010504d:	55                   	push   %ebp
f010504e:	89 e5                	mov    %esp,%ebp
f0105050:	53                   	push   %ebx
f0105051:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105054:	53                   	push   %ebx
f0105055:	e8 9a ff ff ff       	call   f0104ff4 <strlen>
f010505a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010505d:	ff 75 0c             	pushl  0xc(%ebp)
f0105060:	01 d8                	add    %ebx,%eax
f0105062:	50                   	push   %eax
f0105063:	e8 c5 ff ff ff       	call   f010502d <strcpy>
	return dst;
}
f0105068:	89 d8                	mov    %ebx,%eax
f010506a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010506d:	c9                   	leave  
f010506e:	c3                   	ret    

f010506f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010506f:	55                   	push   %ebp
f0105070:	89 e5                	mov    %esp,%ebp
f0105072:	56                   	push   %esi
f0105073:	53                   	push   %ebx
f0105074:	8b 75 08             	mov    0x8(%ebp),%esi
f0105077:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f010507a:	89 f3                	mov    %esi,%ebx
f010507c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010507f:	89 f2                	mov    %esi,%edx
f0105081:	eb 0f                	jmp    f0105092 <strncpy+0x23>
		*dst++ = *src;
f0105083:	83 c2 01             	add    $0x1,%edx
f0105086:	0f b6 01             	movzbl (%ecx),%eax
f0105089:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010508c:	80 39 01             	cmpb   $0x1,(%ecx)
f010508f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105092:	39 da                	cmp    %ebx,%edx
f0105094:	75 ed                	jne    f0105083 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105096:	89 f0                	mov    %esi,%eax
f0105098:	5b                   	pop    %ebx
f0105099:	5e                   	pop    %esi
f010509a:	5d                   	pop    %ebp
f010509b:	c3                   	ret    

f010509c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f010509c:	55                   	push   %ebp
f010509d:	89 e5                	mov    %esp,%ebp
f010509f:	56                   	push   %esi
f01050a0:	53                   	push   %ebx
f01050a1:	8b 75 08             	mov    0x8(%ebp),%esi
f01050a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01050a7:	8b 55 10             	mov    0x10(%ebp),%edx
f01050aa:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01050ac:	85 d2                	test   %edx,%edx
f01050ae:	74 21                	je     f01050d1 <strlcpy+0x35>
f01050b0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01050b4:	89 f2                	mov    %esi,%edx
f01050b6:	eb 09                	jmp    f01050c1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01050b8:	83 c2 01             	add    $0x1,%edx
f01050bb:	83 c1 01             	add    $0x1,%ecx
f01050be:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01050c1:	39 c2                	cmp    %eax,%edx
f01050c3:	74 09                	je     f01050ce <strlcpy+0x32>
f01050c5:	0f b6 19             	movzbl (%ecx),%ebx
f01050c8:	84 db                	test   %bl,%bl
f01050ca:	75 ec                	jne    f01050b8 <strlcpy+0x1c>
f01050cc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01050ce:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01050d1:	29 f0                	sub    %esi,%eax
}
f01050d3:	5b                   	pop    %ebx
f01050d4:	5e                   	pop    %esi
f01050d5:	5d                   	pop    %ebp
f01050d6:	c3                   	ret    

f01050d7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01050d7:	55                   	push   %ebp
f01050d8:	89 e5                	mov    %esp,%ebp
f01050da:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01050dd:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01050e0:	eb 06                	jmp    f01050e8 <strcmp+0x11>
		p++, q++;
f01050e2:	83 c1 01             	add    $0x1,%ecx
f01050e5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01050e8:	0f b6 01             	movzbl (%ecx),%eax
f01050eb:	84 c0                	test   %al,%al
f01050ed:	74 04                	je     f01050f3 <strcmp+0x1c>
f01050ef:	3a 02                	cmp    (%edx),%al
f01050f1:	74 ef                	je     f01050e2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f01050f3:	0f b6 c0             	movzbl %al,%eax
f01050f6:	0f b6 12             	movzbl (%edx),%edx
f01050f9:	29 d0                	sub    %edx,%eax
}
f01050fb:	5d                   	pop    %ebp
f01050fc:	c3                   	ret    

f01050fd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01050fd:	55                   	push   %ebp
f01050fe:	89 e5                	mov    %esp,%ebp
f0105100:	53                   	push   %ebx
f0105101:	8b 45 08             	mov    0x8(%ebp),%eax
f0105104:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105107:	89 c3                	mov    %eax,%ebx
f0105109:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010510c:	eb 06                	jmp    f0105114 <strncmp+0x17>
		n--, p++, q++;
f010510e:	83 c0 01             	add    $0x1,%eax
f0105111:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105114:	39 d8                	cmp    %ebx,%eax
f0105116:	74 15                	je     f010512d <strncmp+0x30>
f0105118:	0f b6 08             	movzbl (%eax),%ecx
f010511b:	84 c9                	test   %cl,%cl
f010511d:	74 04                	je     f0105123 <strncmp+0x26>
f010511f:	3a 0a                	cmp    (%edx),%cl
f0105121:	74 eb                	je     f010510e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105123:	0f b6 00             	movzbl (%eax),%eax
f0105126:	0f b6 12             	movzbl (%edx),%edx
f0105129:	29 d0                	sub    %edx,%eax
f010512b:	eb 05                	jmp    f0105132 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010512d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105132:	5b                   	pop    %ebx
f0105133:	5d                   	pop    %ebp
f0105134:	c3                   	ret    

f0105135 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105135:	55                   	push   %ebp
f0105136:	89 e5                	mov    %esp,%ebp
f0105138:	8b 45 08             	mov    0x8(%ebp),%eax
f010513b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010513f:	eb 07                	jmp    f0105148 <strchr+0x13>
		if (*s == c)
f0105141:	38 ca                	cmp    %cl,%dl
f0105143:	74 0f                	je     f0105154 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105145:	83 c0 01             	add    $0x1,%eax
f0105148:	0f b6 10             	movzbl (%eax),%edx
f010514b:	84 d2                	test   %dl,%dl
f010514d:	75 f2                	jne    f0105141 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010514f:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105154:	5d                   	pop    %ebp
f0105155:	c3                   	ret    

f0105156 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105156:	55                   	push   %ebp
f0105157:	89 e5                	mov    %esp,%ebp
f0105159:	8b 45 08             	mov    0x8(%ebp),%eax
f010515c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105160:	eb 03                	jmp    f0105165 <strfind+0xf>
f0105162:	83 c0 01             	add    $0x1,%eax
f0105165:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105168:	38 ca                	cmp    %cl,%dl
f010516a:	74 04                	je     f0105170 <strfind+0x1a>
f010516c:	84 d2                	test   %dl,%dl
f010516e:	75 f2                	jne    f0105162 <strfind+0xc>
			break;
	return (char *) s;
}
f0105170:	5d                   	pop    %ebp
f0105171:	c3                   	ret    

f0105172 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105172:	55                   	push   %ebp
f0105173:	89 e5                	mov    %esp,%ebp
f0105175:	57                   	push   %edi
f0105176:	56                   	push   %esi
f0105177:	53                   	push   %ebx
f0105178:	8b 7d 08             	mov    0x8(%ebp),%edi
f010517b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f010517e:	85 c9                	test   %ecx,%ecx
f0105180:	74 36                	je     f01051b8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105182:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105188:	75 28                	jne    f01051b2 <memset+0x40>
f010518a:	f6 c1 03             	test   $0x3,%cl
f010518d:	75 23                	jne    f01051b2 <memset+0x40>
		c &= 0xFF;
f010518f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f0105193:	89 d3                	mov    %edx,%ebx
f0105195:	c1 e3 08             	shl    $0x8,%ebx
f0105198:	89 d6                	mov    %edx,%esi
f010519a:	c1 e6 18             	shl    $0x18,%esi
f010519d:	89 d0                	mov    %edx,%eax
f010519f:	c1 e0 10             	shl    $0x10,%eax
f01051a2:	09 f0                	or     %esi,%eax
f01051a4:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
f01051a6:	89 d8                	mov    %ebx,%eax
f01051a8:	09 d0                	or     %edx,%eax
f01051aa:	c1 e9 02             	shr    $0x2,%ecx
f01051ad:	fc                   	cld    
f01051ae:	f3 ab                	rep stos %eax,%es:(%edi)
f01051b0:	eb 06                	jmp    f01051b8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01051b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01051b5:	fc                   	cld    
f01051b6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01051b8:	89 f8                	mov    %edi,%eax
f01051ba:	5b                   	pop    %ebx
f01051bb:	5e                   	pop    %esi
f01051bc:	5f                   	pop    %edi
f01051bd:	5d                   	pop    %ebp
f01051be:	c3                   	ret    

f01051bf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01051bf:	55                   	push   %ebp
f01051c0:	89 e5                	mov    %esp,%ebp
f01051c2:	57                   	push   %edi
f01051c3:	56                   	push   %esi
f01051c4:	8b 45 08             	mov    0x8(%ebp),%eax
f01051c7:	8b 75 0c             	mov    0xc(%ebp),%esi
f01051ca:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01051cd:	39 c6                	cmp    %eax,%esi
f01051cf:	73 35                	jae    f0105206 <memmove+0x47>
f01051d1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01051d4:	39 d0                	cmp    %edx,%eax
f01051d6:	73 2e                	jae    f0105206 <memmove+0x47>
		s += n;
		d += n;
f01051d8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01051db:	89 d6                	mov    %edx,%esi
f01051dd:	09 fe                	or     %edi,%esi
f01051df:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01051e5:	75 13                	jne    f01051fa <memmove+0x3b>
f01051e7:	f6 c1 03             	test   $0x3,%cl
f01051ea:	75 0e                	jne    f01051fa <memmove+0x3b>
			asm volatile("std; rep movsl\n"
f01051ec:	83 ef 04             	sub    $0x4,%edi
f01051ef:	8d 72 fc             	lea    -0x4(%edx),%esi
f01051f2:	c1 e9 02             	shr    $0x2,%ecx
f01051f5:	fd                   	std    
f01051f6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f01051f8:	eb 09                	jmp    f0105203 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f01051fa:	83 ef 01             	sub    $0x1,%edi
f01051fd:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105200:	fd                   	std    
f0105201:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105203:	fc                   	cld    
f0105204:	eb 1d                	jmp    f0105223 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105206:	89 f2                	mov    %esi,%edx
f0105208:	09 c2                	or     %eax,%edx
f010520a:	f6 c2 03             	test   $0x3,%dl
f010520d:	75 0f                	jne    f010521e <memmove+0x5f>
f010520f:	f6 c1 03             	test   $0x3,%cl
f0105212:	75 0a                	jne    f010521e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
f0105214:	c1 e9 02             	shr    $0x2,%ecx
f0105217:	89 c7                	mov    %eax,%edi
f0105219:	fc                   	cld    
f010521a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010521c:	eb 05                	jmp    f0105223 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010521e:	89 c7                	mov    %eax,%edi
f0105220:	fc                   	cld    
f0105221:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105223:	5e                   	pop    %esi
f0105224:	5f                   	pop    %edi
f0105225:	5d                   	pop    %ebp
f0105226:	c3                   	ret    

f0105227 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105227:	55                   	push   %ebp
f0105228:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f010522a:	ff 75 10             	pushl  0x10(%ebp)
f010522d:	ff 75 0c             	pushl  0xc(%ebp)
f0105230:	ff 75 08             	pushl  0x8(%ebp)
f0105233:	e8 87 ff ff ff       	call   f01051bf <memmove>
}
f0105238:	c9                   	leave  
f0105239:	c3                   	ret    

f010523a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f010523a:	55                   	push   %ebp
f010523b:	89 e5                	mov    %esp,%ebp
f010523d:	56                   	push   %esi
f010523e:	53                   	push   %ebx
f010523f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105242:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105245:	89 c6                	mov    %eax,%esi
f0105247:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f010524a:	eb 1a                	jmp    f0105266 <memcmp+0x2c>
		if (*s1 != *s2)
f010524c:	0f b6 08             	movzbl (%eax),%ecx
f010524f:	0f b6 1a             	movzbl (%edx),%ebx
f0105252:	38 d9                	cmp    %bl,%cl
f0105254:	74 0a                	je     f0105260 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105256:	0f b6 c1             	movzbl %cl,%eax
f0105259:	0f b6 db             	movzbl %bl,%ebx
f010525c:	29 d8                	sub    %ebx,%eax
f010525e:	eb 0f                	jmp    f010526f <memcmp+0x35>
		s1++, s2++;
f0105260:	83 c0 01             	add    $0x1,%eax
f0105263:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105266:	39 f0                	cmp    %esi,%eax
f0105268:	75 e2                	jne    f010524c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f010526a:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010526f:	5b                   	pop    %ebx
f0105270:	5e                   	pop    %esi
f0105271:	5d                   	pop    %ebp
f0105272:	c3                   	ret    

f0105273 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105273:	55                   	push   %ebp
f0105274:	89 e5                	mov    %esp,%ebp
f0105276:	53                   	push   %ebx
f0105277:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f010527a:	89 c1                	mov    %eax,%ecx
f010527c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
f010527f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105283:	eb 0a                	jmp    f010528f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105285:	0f b6 10             	movzbl (%eax),%edx
f0105288:	39 da                	cmp    %ebx,%edx
f010528a:	74 07                	je     f0105293 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010528c:	83 c0 01             	add    $0x1,%eax
f010528f:	39 c8                	cmp    %ecx,%eax
f0105291:	72 f2                	jb     f0105285 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0105293:	5b                   	pop    %ebx
f0105294:	5d                   	pop    %ebp
f0105295:	c3                   	ret    

f0105296 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0105296:	55                   	push   %ebp
f0105297:	89 e5                	mov    %esp,%ebp
f0105299:	57                   	push   %edi
f010529a:	56                   	push   %esi
f010529b:	53                   	push   %ebx
f010529c:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010529f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01052a2:	eb 03                	jmp    f01052a7 <strtol+0x11>
		s++;
f01052a4:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01052a7:	0f b6 01             	movzbl (%ecx),%eax
f01052aa:	3c 20                	cmp    $0x20,%al
f01052ac:	74 f6                	je     f01052a4 <strtol+0xe>
f01052ae:	3c 09                	cmp    $0x9,%al
f01052b0:	74 f2                	je     f01052a4 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01052b2:	3c 2b                	cmp    $0x2b,%al
f01052b4:	75 0a                	jne    f01052c0 <strtol+0x2a>
		s++;
f01052b6:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01052b9:	bf 00 00 00 00       	mov    $0x0,%edi
f01052be:	eb 11                	jmp    f01052d1 <strtol+0x3b>
f01052c0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01052c5:	3c 2d                	cmp    $0x2d,%al
f01052c7:	75 08                	jne    f01052d1 <strtol+0x3b>
		s++, neg = 1;
f01052c9:	83 c1 01             	add    $0x1,%ecx
f01052cc:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01052d1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01052d7:	75 15                	jne    f01052ee <strtol+0x58>
f01052d9:	80 39 30             	cmpb   $0x30,(%ecx)
f01052dc:	75 10                	jne    f01052ee <strtol+0x58>
f01052de:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01052e2:	75 7c                	jne    f0105360 <strtol+0xca>
		s += 2, base = 16;
f01052e4:	83 c1 02             	add    $0x2,%ecx
f01052e7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01052ec:	eb 16                	jmp    f0105304 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
f01052ee:	85 db                	test   %ebx,%ebx
f01052f0:	75 12                	jne    f0105304 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01052f2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01052f7:	80 39 30             	cmpb   $0x30,(%ecx)
f01052fa:	75 08                	jne    f0105304 <strtol+0x6e>
		s++, base = 8;
f01052fc:	83 c1 01             	add    $0x1,%ecx
f01052ff:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105304:	b8 00 00 00 00       	mov    $0x0,%eax
f0105309:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010530c:	0f b6 11             	movzbl (%ecx),%edx
f010530f:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105312:	89 f3                	mov    %esi,%ebx
f0105314:	80 fb 09             	cmp    $0x9,%bl
f0105317:	77 08                	ja     f0105321 <strtol+0x8b>
			dig = *s - '0';
f0105319:	0f be d2             	movsbl %dl,%edx
f010531c:	83 ea 30             	sub    $0x30,%edx
f010531f:	eb 22                	jmp    f0105343 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
f0105321:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105324:	89 f3                	mov    %esi,%ebx
f0105326:	80 fb 19             	cmp    $0x19,%bl
f0105329:	77 08                	ja     f0105333 <strtol+0x9d>
			dig = *s - 'a' + 10;
f010532b:	0f be d2             	movsbl %dl,%edx
f010532e:	83 ea 57             	sub    $0x57,%edx
f0105331:	eb 10                	jmp    f0105343 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
f0105333:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105336:	89 f3                	mov    %esi,%ebx
f0105338:	80 fb 19             	cmp    $0x19,%bl
f010533b:	77 16                	ja     f0105353 <strtol+0xbd>
			dig = *s - 'A' + 10;
f010533d:	0f be d2             	movsbl %dl,%edx
f0105340:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105343:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105346:	7d 0b                	jge    f0105353 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
f0105348:	83 c1 01             	add    $0x1,%ecx
f010534b:	0f af 45 10          	imul   0x10(%ebp),%eax
f010534f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105351:	eb b9                	jmp    f010530c <strtol+0x76>

	if (endptr)
f0105353:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f0105357:	74 0d                	je     f0105366 <strtol+0xd0>
		*endptr = (char *) s;
f0105359:	8b 75 0c             	mov    0xc(%ebp),%esi
f010535c:	89 0e                	mov    %ecx,(%esi)
f010535e:	eb 06                	jmp    f0105366 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105360:	85 db                	test   %ebx,%ebx
f0105362:	74 98                	je     f01052fc <strtol+0x66>
f0105364:	eb 9e                	jmp    f0105304 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
f0105366:	89 c2                	mov    %eax,%edx
f0105368:	f7 da                	neg    %edx
f010536a:	85 ff                	test   %edi,%edi
f010536c:	0f 45 c2             	cmovne %edx,%eax
}
f010536f:	5b                   	pop    %ebx
f0105370:	5e                   	pop    %esi
f0105371:	5f                   	pop    %edi
f0105372:	5d                   	pop    %ebp
f0105373:	c3                   	ret    

f0105374 <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f0105374:	fa                   	cli    

	xorw    %ax, %ax
f0105375:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f0105377:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105379:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010537b:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f010537d:	0f 01 16             	lgdtl  (%esi)
f0105380:	74 70                	je     f01053f2 <mpsearch1+0x3>
	movl    %cr0, %eax
f0105382:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f0105385:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105389:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f010538c:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105392:	08 00                	or     %al,(%eax)

f0105394 <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105394:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105398:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f010539a:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f010539c:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f010539e:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f01053a2:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f01053a4:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f01053a6:	b8 00 d0 11 00       	mov    $0x11d000,%eax
	movl    %eax, %cr3
f01053ab:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f01053ae:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f01053b1:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f01053b6:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f01053b9:	8b 25 84 ee 22 f0    	mov    0xf022ee84,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f01053bf:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f01053c4:	b8 b3 01 10 f0       	mov    $0xf01001b3,%eax
	call    *%eax
f01053c9:	ff d0                	call   *%eax

f01053cb <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f01053cb:	eb fe                	jmp    f01053cb <spin>
f01053cd:	8d 76 00             	lea    0x0(%esi),%esi

f01053d0 <gdt>:
	...
f01053d8:	ff                   	(bad)  
f01053d9:	ff 00                	incl   (%eax)
f01053db:	00 00                	add    %al,(%eax)
f01053dd:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f01053e4:	00                   	.byte 0x0
f01053e5:	92                   	xchg   %eax,%edx
f01053e6:	cf                   	iret   
	...

f01053e8 <gdtdesc>:
f01053e8:	17                   	pop    %ss
f01053e9:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f01053ee <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f01053ee:	90                   	nop

f01053ef <mpsearch1>:
}

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f01053ef:	55                   	push   %ebp
f01053f0:	89 e5                	mov    %esp,%ebp
f01053f2:	57                   	push   %edi
f01053f3:	56                   	push   %esi
f01053f4:	53                   	push   %ebx
f01053f5:	83 ec 0c             	sub    $0xc,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01053f8:	8b 0d 88 ee 22 f0    	mov    0xf022ee88,%ecx
f01053fe:	89 c3                	mov    %eax,%ebx
f0105400:	c1 eb 0c             	shr    $0xc,%ebx
f0105403:	39 cb                	cmp    %ecx,%ebx
f0105405:	72 12                	jb     f0105419 <mpsearch1+0x2a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105407:	50                   	push   %eax
f0105408:	68 44 5e 10 f0       	push   $0xf0105e44
f010540d:	6a 57                	push   $0x57
f010540f:	68 01 79 10 f0       	push   $0xf0107901
f0105414:	e8 27 ac ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f0105419:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f010541f:	01 d0                	add    %edx,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105421:	89 c2                	mov    %eax,%edx
f0105423:	c1 ea 0c             	shr    $0xc,%edx
f0105426:	39 ca                	cmp    %ecx,%edx
f0105428:	72 12                	jb     f010543c <mpsearch1+0x4d>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010542a:	50                   	push   %eax
f010542b:	68 44 5e 10 f0       	push   $0xf0105e44
f0105430:	6a 57                	push   $0x57
f0105432:	68 01 79 10 f0       	push   $0xf0107901
f0105437:	e8 04 ac ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010543c:	8d b0 00 00 00 f0    	lea    -0x10000000(%eax),%esi

	for (; mp < end; mp++)
f0105442:	eb 2f                	jmp    f0105473 <mpsearch1+0x84>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105444:	83 ec 04             	sub    $0x4,%esp
f0105447:	6a 04                	push   $0x4
f0105449:	68 11 79 10 f0       	push   $0xf0107911
f010544e:	53                   	push   %ebx
f010544f:	e8 e6 fd ff ff       	call   f010523a <memcmp>
f0105454:	83 c4 10             	add    $0x10,%esp
f0105457:	85 c0                	test   %eax,%eax
f0105459:	75 15                	jne    f0105470 <mpsearch1+0x81>
f010545b:	89 da                	mov    %ebx,%edx
f010545d:	8d 7b 10             	lea    0x10(%ebx),%edi
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
		sum += ((uint8_t *)addr)[i];
f0105460:	0f b6 0a             	movzbl (%edx),%ecx
f0105463:	01 c8                	add    %ecx,%eax
f0105465:	83 c2 01             	add    $0x1,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105468:	39 d7                	cmp    %edx,%edi
f010546a:	75 f4                	jne    f0105460 <mpsearch1+0x71>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f010546c:	84 c0                	test   %al,%al
f010546e:	74 0e                	je     f010547e <mpsearch1+0x8f>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105470:	83 c3 10             	add    $0x10,%ebx
f0105473:	39 f3                	cmp    %esi,%ebx
f0105475:	72 cd                	jb     f0105444 <mpsearch1+0x55>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
f0105477:	b8 00 00 00 00       	mov    $0x0,%eax
f010547c:	eb 02                	jmp    f0105480 <mpsearch1+0x91>
f010547e:	89 d8                	mov    %ebx,%eax
}
f0105480:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105483:	5b                   	pop    %ebx
f0105484:	5e                   	pop    %esi
f0105485:	5f                   	pop    %edi
f0105486:	5d                   	pop    %ebp
f0105487:	c3                   	ret    

f0105488 <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105488:	55                   	push   %ebp
f0105489:	89 e5                	mov    %esp,%ebp
f010548b:	57                   	push   %edi
f010548c:	56                   	push   %esi
f010548d:	53                   	push   %ebx
f010548e:	83 ec 1c             	sub    $0x1c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105491:	c7 05 c0 f3 22 f0 20 	movl   $0xf022f020,0xf022f3c0
f0105498:	f0 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010549b:	83 3d 88 ee 22 f0 00 	cmpl   $0x0,0xf022ee88
f01054a2:	75 16                	jne    f01054ba <mp_init+0x32>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01054a4:	68 00 04 00 00       	push   $0x400
f01054a9:	68 44 5e 10 f0       	push   $0xf0105e44
f01054ae:	6a 6f                	push   $0x6f
f01054b0:	68 01 79 10 f0       	push   $0xf0107901
f01054b5:	e8 86 ab ff ff       	call   f0100040 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f01054ba:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f01054c1:	85 c0                	test   %eax,%eax
f01054c3:	74 16                	je     f01054db <mp_init+0x53>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f01054c5:	c1 e0 04             	shl    $0x4,%eax
f01054c8:	ba 00 04 00 00       	mov    $0x400,%edx
f01054cd:	e8 1d ff ff ff       	call   f01053ef <mpsearch1>
f01054d2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054d5:	85 c0                	test   %eax,%eax
f01054d7:	75 3c                	jne    f0105515 <mp_init+0x8d>
f01054d9:	eb 20                	jmp    f01054fb <mp_init+0x73>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f01054db:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f01054e2:	c1 e0 0a             	shl    $0xa,%eax
f01054e5:	2d 00 04 00 00       	sub    $0x400,%eax
f01054ea:	ba 00 04 00 00       	mov    $0x400,%edx
f01054ef:	e8 fb fe ff ff       	call   f01053ef <mpsearch1>
f01054f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01054f7:	85 c0                	test   %eax,%eax
f01054f9:	75 1a                	jne    f0105515 <mp_init+0x8d>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f01054fb:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105500:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105505:	e8 e5 fe ff ff       	call   f01053ef <mpsearch1>
f010550a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f010550d:	85 c0                	test   %eax,%eax
f010550f:	0f 84 5d 02 00 00    	je     f0105772 <mp_init+0x2ea>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105515:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105518:	8b 70 04             	mov    0x4(%eax),%esi
f010551b:	85 f6                	test   %esi,%esi
f010551d:	74 06                	je     f0105525 <mp_init+0x9d>
f010551f:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105523:	74 15                	je     f010553a <mp_init+0xb2>
		cprintf("SMP: Default configurations not implemented\n");
f0105525:	83 ec 0c             	sub    $0xc,%esp
f0105528:	68 74 77 10 f0       	push   $0xf0107774
f010552d:	e8 6f e0 ff ff       	call   f01035a1 <cprintf>
f0105532:	83 c4 10             	add    $0x10,%esp
f0105535:	e9 38 02 00 00       	jmp    f0105772 <mp_init+0x2ea>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010553a:	89 f0                	mov    %esi,%eax
f010553c:	c1 e8 0c             	shr    $0xc,%eax
f010553f:	3b 05 88 ee 22 f0    	cmp    0xf022ee88,%eax
f0105545:	72 15                	jb     f010555c <mp_init+0xd4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105547:	56                   	push   %esi
f0105548:	68 44 5e 10 f0       	push   $0xf0105e44
f010554d:	68 90 00 00 00       	push   $0x90
f0105552:	68 01 79 10 f0       	push   $0xf0107901
f0105557:	e8 e4 aa ff ff       	call   f0100040 <_panic>
	return (void *)(pa + KERNBASE);
f010555c:	8d 9e 00 00 00 f0    	lea    -0x10000000(%esi),%ebx
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105562:	83 ec 04             	sub    $0x4,%esp
f0105565:	6a 04                	push   $0x4
f0105567:	68 16 79 10 f0       	push   $0xf0107916
f010556c:	53                   	push   %ebx
f010556d:	e8 c8 fc ff ff       	call   f010523a <memcmp>
f0105572:	83 c4 10             	add    $0x10,%esp
f0105575:	85 c0                	test   %eax,%eax
f0105577:	74 15                	je     f010558e <mp_init+0x106>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105579:	83 ec 0c             	sub    $0xc,%esp
f010557c:	68 a4 77 10 f0       	push   $0xf01077a4
f0105581:	e8 1b e0 ff ff       	call   f01035a1 <cprintf>
f0105586:	83 c4 10             	add    $0x10,%esp
f0105589:	e9 e4 01 00 00       	jmp    f0105772 <mp_init+0x2ea>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f010558e:	0f b7 43 04          	movzwl 0x4(%ebx),%eax
f0105592:	66 89 45 e2          	mov    %ax,-0x1e(%ebp)
f0105596:	0f b7 f8             	movzwl %ax,%edi
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f0105599:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f010559e:	b8 00 00 00 00       	mov    $0x0,%eax
f01055a3:	eb 0d                	jmp    f01055b2 <mp_init+0x12a>
		sum += ((uint8_t *)addr)[i];
f01055a5:	0f b6 8c 30 00 00 00 	movzbl -0x10000000(%eax,%esi,1),%ecx
f01055ac:	f0 
f01055ad:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f01055af:	83 c0 01             	add    $0x1,%eax
f01055b2:	39 c7                	cmp    %eax,%edi
f01055b4:	75 ef                	jne    f01055a5 <mp_init+0x11d>
	conf = (struct mpconf *) KADDR(mp->physaddr);
	if (memcmp(conf, "PCMP", 4) != 0) {
		cprintf("SMP: Incorrect MP configuration table signature\n");
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f01055b6:	84 d2                	test   %dl,%dl
f01055b8:	74 15                	je     f01055cf <mp_init+0x147>
		cprintf("SMP: Bad MP configuration checksum\n");
f01055ba:	83 ec 0c             	sub    $0xc,%esp
f01055bd:	68 d8 77 10 f0       	push   $0xf01077d8
f01055c2:	e8 da df ff ff       	call   f01035a1 <cprintf>
f01055c7:	83 c4 10             	add    $0x10,%esp
f01055ca:	e9 a3 01 00 00       	jmp    f0105772 <mp_init+0x2ea>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f01055cf:	0f b6 43 06          	movzbl 0x6(%ebx),%eax
f01055d3:	3c 01                	cmp    $0x1,%al
f01055d5:	74 1d                	je     f01055f4 <mp_init+0x16c>
f01055d7:	3c 04                	cmp    $0x4,%al
f01055d9:	74 19                	je     f01055f4 <mp_init+0x16c>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f01055db:	83 ec 08             	sub    $0x8,%esp
f01055de:	0f b6 c0             	movzbl %al,%eax
f01055e1:	50                   	push   %eax
f01055e2:	68 fc 77 10 f0       	push   $0xf01077fc
f01055e7:	e8 b5 df ff ff       	call   f01035a1 <cprintf>
f01055ec:	83 c4 10             	add    $0x10,%esp
f01055ef:	e9 7e 01 00 00       	jmp    f0105772 <mp_init+0x2ea>
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f01055f4:	0f b7 7b 28          	movzwl 0x28(%ebx),%edi
f01055f8:	0f b7 4d e2          	movzwl -0x1e(%ebp),%ecx
static uint8_t
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
f01055fc:	ba 00 00 00 00       	mov    $0x0,%edx
	for (i = 0; i < len; i++)
f0105601:	b8 00 00 00 00       	mov    $0x0,%eax
		sum += ((uint8_t *)addr)[i];
f0105606:	01 ce                	add    %ecx,%esi
f0105608:	eb 0d                	jmp    f0105617 <mp_init+0x18f>
f010560a:	0f b6 8c 06 00 00 00 	movzbl -0x10000000(%esi,%eax,1),%ecx
f0105611:	f0 
f0105612:	01 ca                	add    %ecx,%edx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105614:	83 c0 01             	add    $0x1,%eax
f0105617:	39 c7                	cmp    %eax,%edi
f0105619:	75 ef                	jne    f010560a <mp_init+0x182>
	}
	if (conf->version != 1 && conf->version != 4) {
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
		return NULL;
	}
	if ((sum((uint8_t *)conf + conf->length, conf->xlength) + conf->xchecksum) & 0xff) {
f010561b:	89 d0                	mov    %edx,%eax
f010561d:	02 43 2a             	add    0x2a(%ebx),%al
f0105620:	74 15                	je     f0105637 <mp_init+0x1af>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105622:	83 ec 0c             	sub    $0xc,%esp
f0105625:	68 1c 78 10 f0       	push   $0xf010781c
f010562a:	e8 72 df ff ff       	call   f01035a1 <cprintf>
f010562f:	83 c4 10             	add    $0x10,%esp
f0105632:	e9 3b 01 00 00       	jmp    f0105772 <mp_init+0x2ea>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105637:	85 db                	test   %ebx,%ebx
f0105639:	0f 84 33 01 00 00    	je     f0105772 <mp_init+0x2ea>
		return;
	ismp = 1;
f010563f:	c7 05 00 f0 22 f0 01 	movl   $0x1,0xf022f000
f0105646:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105649:	8b 43 24             	mov    0x24(%ebx),%eax
f010564c:	a3 00 00 27 f0       	mov    %eax,0xf0270000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105651:	8d 7b 2c             	lea    0x2c(%ebx),%edi
f0105654:	be 00 00 00 00       	mov    $0x0,%esi
f0105659:	e9 85 00 00 00       	jmp    f01056e3 <mp_init+0x25b>
		switch (*p) {
f010565e:	0f b6 07             	movzbl (%edi),%eax
f0105661:	84 c0                	test   %al,%al
f0105663:	74 06                	je     f010566b <mp_init+0x1e3>
f0105665:	3c 04                	cmp    $0x4,%al
f0105667:	77 55                	ja     f01056be <mp_init+0x236>
f0105669:	eb 4e                	jmp    f01056b9 <mp_init+0x231>
		case MPPROC:
			proc = (struct mpproc *)p;
			if (proc->flags & MPPROC_BOOT)
f010566b:	f6 47 03 02          	testb  $0x2,0x3(%edi)
f010566f:	74 11                	je     f0105682 <mp_init+0x1fa>
				bootcpu = &cpus[ncpu];
f0105671:	6b 05 c4 f3 22 f0 74 	imul   $0x74,0xf022f3c4,%eax
f0105678:	05 20 f0 22 f0       	add    $0xf022f020,%eax
f010567d:	a3 c0 f3 22 f0       	mov    %eax,0xf022f3c0
			if (ncpu < NCPU) {
f0105682:	a1 c4 f3 22 f0       	mov    0xf022f3c4,%eax
f0105687:	83 f8 07             	cmp    $0x7,%eax
f010568a:	7f 13                	jg     f010569f <mp_init+0x217>
				cpus[ncpu].cpu_id = ncpu;
f010568c:	6b d0 74             	imul   $0x74,%eax,%edx
f010568f:	88 82 20 f0 22 f0    	mov    %al,-0xfdd0fe0(%edx)
				ncpu++;
f0105695:	83 c0 01             	add    $0x1,%eax
f0105698:	a3 c4 f3 22 f0       	mov    %eax,0xf022f3c4
f010569d:	eb 15                	jmp    f01056b4 <mp_init+0x22c>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f010569f:	83 ec 08             	sub    $0x8,%esp
f01056a2:	0f b6 47 01          	movzbl 0x1(%edi),%eax
f01056a6:	50                   	push   %eax
f01056a7:	68 4c 78 10 f0       	push   $0xf010784c
f01056ac:	e8 f0 de ff ff       	call   f01035a1 <cprintf>
f01056b1:	83 c4 10             	add    $0x10,%esp
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f01056b4:	83 c7 14             	add    $0x14,%edi
			continue;
f01056b7:	eb 27                	jmp    f01056e0 <mp_init+0x258>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f01056b9:	83 c7 08             	add    $0x8,%edi
			continue;
f01056bc:	eb 22                	jmp    f01056e0 <mp_init+0x258>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f01056be:	83 ec 08             	sub    $0x8,%esp
f01056c1:	0f b6 c0             	movzbl %al,%eax
f01056c4:	50                   	push   %eax
f01056c5:	68 74 78 10 f0       	push   $0xf0107874
f01056ca:	e8 d2 de ff ff       	call   f01035a1 <cprintf>
			ismp = 0;
f01056cf:	c7 05 00 f0 22 f0 00 	movl   $0x0,0xf022f000
f01056d6:	00 00 00 
			i = conf->entry;
f01056d9:	0f b7 73 22          	movzwl 0x22(%ebx),%esi
f01056dd:	83 c4 10             	add    $0x10,%esp
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f01056e0:	83 c6 01             	add    $0x1,%esi
f01056e3:	0f b7 43 22          	movzwl 0x22(%ebx),%eax
f01056e7:	39 c6                	cmp    %eax,%esi
f01056e9:	0f 82 6f ff ff ff    	jb     f010565e <mp_init+0x1d6>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f01056ef:	a1 c0 f3 22 f0       	mov    0xf022f3c0,%eax
f01056f4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f01056fb:	83 3d 00 f0 22 f0 00 	cmpl   $0x0,0xf022f000
f0105702:	75 26                	jne    f010572a <mp_init+0x2a2>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105704:	c7 05 c4 f3 22 f0 01 	movl   $0x1,0xf022f3c4
f010570b:	00 00 00 
		lapicaddr = 0;
f010570e:	c7 05 00 00 27 f0 00 	movl   $0x0,0xf0270000
f0105715:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105718:	83 ec 0c             	sub    $0xc,%esp
f010571b:	68 94 78 10 f0       	push   $0xf0107894
f0105720:	e8 7c de ff ff       	call   f01035a1 <cprintf>
		return;
f0105725:	83 c4 10             	add    $0x10,%esp
f0105728:	eb 48                	jmp    f0105772 <mp_init+0x2ea>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f010572a:	83 ec 04             	sub    $0x4,%esp
f010572d:	ff 35 c4 f3 22 f0    	pushl  0xf022f3c4
f0105733:	0f b6 00             	movzbl (%eax),%eax
f0105736:	50                   	push   %eax
f0105737:	68 1b 79 10 f0       	push   $0xf010791b
f010573c:	e8 60 de ff ff       	call   f01035a1 <cprintf>

	if (mp->imcrp) {
f0105741:	83 c4 10             	add    $0x10,%esp
f0105744:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105747:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f010574b:	74 25                	je     f0105772 <mp_init+0x2ea>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f010574d:	83 ec 0c             	sub    $0xc,%esp
f0105750:	68 c0 78 10 f0       	push   $0xf01078c0
f0105755:	e8 47 de ff ff       	call   f01035a1 <cprintf>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010575a:	ba 22 00 00 00       	mov    $0x22,%edx
f010575f:	b8 70 00 00 00       	mov    $0x70,%eax
f0105764:	ee                   	out    %al,(%dx)

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105765:	ba 23 00 00 00       	mov    $0x23,%edx
f010576a:	ec                   	in     (%dx),%al
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010576b:	83 c8 01             	or     $0x1,%eax
f010576e:	ee                   	out    %al,(%dx)
f010576f:	83 c4 10             	add    $0x10,%esp
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105772:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105775:	5b                   	pop    %ebx
f0105776:	5e                   	pop    %esi
f0105777:	5f                   	pop    %edi
f0105778:	5d                   	pop    %ebp
f0105779:	c3                   	ret    

f010577a <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f010577a:	55                   	push   %ebp
f010577b:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f010577d:	8b 0d 04 00 27 f0    	mov    0xf0270004,%ecx
f0105783:	8d 04 81             	lea    (%ecx,%eax,4),%eax
f0105786:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105788:	a1 04 00 27 f0       	mov    0xf0270004,%eax
f010578d:	8b 40 20             	mov    0x20(%eax),%eax
}
f0105790:	5d                   	pop    %ebp
f0105791:	c3                   	ret    

f0105792 <cpunum>:
}

// 获取CPU ID
int
cpunum(void)
{
f0105792:	55                   	push   %ebp
f0105793:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105795:	a1 04 00 27 f0       	mov    0xf0270004,%eax
f010579a:	85 c0                	test   %eax,%eax
f010579c:	74 08                	je     f01057a6 <cpunum+0x14>
		return lapic[ID] >> 24;
f010579e:	8b 40 20             	mov    0x20(%eax),%eax
f01057a1:	c1 e8 18             	shr    $0x18,%eax
f01057a4:	eb 05                	jmp    f01057ab <cpunum+0x19>
	return 0;
f01057a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01057ab:	5d                   	pop    %ebp
f01057ac:	c3                   	ret    

f01057ad <lapic_init>:
}

void
lapic_init(void)
{
	if (!lapicaddr)
f01057ad:	a1 00 00 27 f0       	mov    0xf0270000,%eax
f01057b2:	85 c0                	test   %eax,%eax
f01057b4:	0f 84 21 01 00 00    	je     f01058db <lapic_init+0x12e>
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f01057ba:	55                   	push   %ebp
f01057bb:	89 e5                	mov    %esp,%ebp
f01057bd:	83 ec 10             	sub    $0x10,%esp
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	// 将LAPIC 4KB的物理地址映射到虚拟地址
	lapic = mmio_map_region(lapicaddr, 4096);
f01057c0:	68 00 10 00 00       	push   $0x1000
f01057c5:	50                   	push   %eax
f01057c6:	e8 b3 b9 ff ff       	call   f010117e <mmio_map_region>
f01057cb:	a3 04 00 27 f0       	mov    %eax,0xf0270004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f01057d0:	ba 27 01 00 00       	mov    $0x127,%edx
f01057d5:	b8 3c 00 00 00       	mov    $0x3c,%eax
f01057da:	e8 9b ff ff ff       	call   f010577a <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f01057df:	ba 0b 00 00 00       	mov    $0xb,%edx
f01057e4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f01057e9:	e8 8c ff ff ff       	call   f010577a <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f01057ee:	ba 20 00 02 00       	mov    $0x20020,%edx
f01057f3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f01057f8:	e8 7d ff ff ff       	call   f010577a <lapicw>
	lapicw(TICR, 10000000); 
f01057fd:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105802:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105807:	e8 6e ff ff ff       	call   f010577a <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f010580c:	e8 81 ff ff ff       	call   f0105792 <cpunum>
f0105811:	6b c0 74             	imul   $0x74,%eax,%eax
f0105814:	05 20 f0 22 f0       	add    $0xf022f020,%eax
f0105819:	83 c4 10             	add    $0x10,%esp
f010581c:	39 05 c0 f3 22 f0    	cmp    %eax,0xf022f3c0
f0105822:	74 0f                	je     f0105833 <lapic_init+0x86>
		lapicw(LINT0, MASKED);
f0105824:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105829:	b8 d4 00 00 00       	mov    $0xd4,%eax
f010582e:	e8 47 ff ff ff       	call   f010577a <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105833:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105838:	b8 d8 00 00 00       	mov    $0xd8,%eax
f010583d:	e8 38 ff ff ff       	call   f010577a <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105842:	a1 04 00 27 f0       	mov    0xf0270004,%eax
f0105847:	8b 40 30             	mov    0x30(%eax),%eax
f010584a:	c1 e8 10             	shr    $0x10,%eax
f010584d:	3c 03                	cmp    $0x3,%al
f010584f:	76 0f                	jbe    f0105860 <lapic_init+0xb3>
		lapicw(PCINT, MASKED);
f0105851:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105856:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010585b:	e8 1a ff ff ff       	call   f010577a <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f0105860:	ba 33 00 00 00       	mov    $0x33,%edx
f0105865:	b8 dc 00 00 00       	mov    $0xdc,%eax
f010586a:	e8 0b ff ff ff       	call   f010577a <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010586f:	ba 00 00 00 00       	mov    $0x0,%edx
f0105874:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105879:	e8 fc fe ff ff       	call   f010577a <lapicw>
	lapicw(ESR, 0);
f010587e:	ba 00 00 00 00       	mov    $0x0,%edx
f0105883:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0105888:	e8 ed fe ff ff       	call   f010577a <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010588d:	ba 00 00 00 00       	mov    $0x0,%edx
f0105892:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105897:	e8 de fe ff ff       	call   f010577a <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010589c:	ba 00 00 00 00       	mov    $0x0,%edx
f01058a1:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01058a6:	e8 cf fe ff ff       	call   f010577a <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f01058ab:	ba 00 85 08 00       	mov    $0x88500,%edx
f01058b0:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01058b5:	e8 c0 fe ff ff       	call   f010577a <lapicw>
	while(lapic[ICRLO] & DELIVS)
f01058ba:	8b 15 04 00 27 f0    	mov    0xf0270004,%edx
f01058c0:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01058c6:	f6 c4 10             	test   $0x10,%ah
f01058c9:	75 f5                	jne    f01058c0 <lapic_init+0x113>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f01058cb:	ba 00 00 00 00       	mov    $0x0,%edx
f01058d0:	b8 20 00 00 00       	mov    $0x20,%eax
f01058d5:	e8 a0 fe ff ff       	call   f010577a <lapicw>
}
f01058da:	c9                   	leave  
f01058db:	f3 c3                	repz ret 

f01058dd <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
	if (lapic)
f01058dd:	83 3d 04 00 27 f0 00 	cmpl   $0x0,0xf0270004
f01058e4:	74 13                	je     f01058f9 <lapic_eoi+0x1c>
}

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f01058e6:	55                   	push   %ebp
f01058e7:	89 e5                	mov    %esp,%ebp
	if (lapic)
		lapicw(EOI, 0);
f01058e9:	ba 00 00 00 00       	mov    $0x0,%edx
f01058ee:	b8 2c 00 00 00       	mov    $0x2c,%eax
f01058f3:	e8 82 fe ff ff       	call   f010577a <lapicw>
}
f01058f8:	5d                   	pop    %ebp
f01058f9:	f3 c3                	repz ret 

f01058fb <lapic_startap>:
// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
// 唤醒某个CPU
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f01058fb:	55                   	push   %ebp
f01058fc:	89 e5                	mov    %esp,%ebp
f01058fe:	56                   	push   %esi
f01058ff:	53                   	push   %ebx
f0105900:	8b 75 08             	mov    0x8(%ebp),%esi
f0105903:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105906:	ba 70 00 00 00       	mov    $0x70,%edx
f010590b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105910:	ee                   	out    %al,(%dx)
f0105911:	ba 71 00 00 00       	mov    $0x71,%edx
f0105916:	b8 0a 00 00 00       	mov    $0xa,%eax
f010591b:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010591c:	83 3d 88 ee 22 f0 00 	cmpl   $0x0,0xf022ee88
f0105923:	75 19                	jne    f010593e <lapic_startap+0x43>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105925:	68 67 04 00 00       	push   $0x467
f010592a:	68 44 5e 10 f0       	push   $0xf0105e44
f010592f:	68 9b 00 00 00       	push   $0x9b
f0105934:	68 38 79 10 f0       	push   $0xf0107938
f0105939:	e8 02 a7 ff ff       	call   f0100040 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f010593e:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105945:	00 00 
	wrv[1] = addr >> 4;
f0105947:	89 d8                	mov    %ebx,%eax
f0105949:	c1 e8 04             	shr    $0x4,%eax
f010594c:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105952:	c1 e6 18             	shl    $0x18,%esi
f0105955:	89 f2                	mov    %esi,%edx
f0105957:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010595c:	e8 19 fe ff ff       	call   f010577a <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105961:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105966:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010596b:	e8 0a fe ff ff       	call   f010577a <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105970:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105975:	b8 c0 00 00 00       	mov    $0xc0,%eax
f010597a:	e8 fb fd ff ff       	call   f010577a <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f010597f:	c1 eb 0c             	shr    $0xc,%ebx
f0105982:	80 cf 06             	or     $0x6,%bh
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105985:	89 f2                	mov    %esi,%edx
f0105987:	b8 c4 00 00 00       	mov    $0xc4,%eax
f010598c:	e8 e9 fd ff ff       	call   f010577a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105991:	89 da                	mov    %ebx,%edx
f0105993:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105998:	e8 dd fd ff ff       	call   f010577a <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f010599d:	89 f2                	mov    %esi,%edx
f010599f:	b8 c4 00 00 00       	mov    $0xc4,%eax
f01059a4:	e8 d1 fd ff ff       	call   f010577a <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f01059a9:	89 da                	mov    %ebx,%edx
f01059ab:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01059b0:	e8 c5 fd ff ff       	call   f010577a <lapicw>
		microdelay(200);
	}
}
f01059b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01059b8:	5b                   	pop    %ebx
f01059b9:	5e                   	pop    %esi
f01059ba:	5d                   	pop    %ebp
f01059bb:	c3                   	ret    

f01059bc <lapic_ipi>:

void
lapic_ipi(int vector)
{
f01059bc:	55                   	push   %ebp
f01059bd:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f01059bf:	8b 55 08             	mov    0x8(%ebp),%edx
f01059c2:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f01059c8:	b8 c0 00 00 00       	mov    $0xc0,%eax
f01059cd:	e8 a8 fd ff ff       	call   f010577a <lapicw>
	while (lapic[ICRLO] & DELIVS)
f01059d2:	8b 15 04 00 27 f0    	mov    0xf0270004,%edx
f01059d8:	8b 82 00 03 00 00    	mov    0x300(%edx),%eax
f01059de:	f6 c4 10             	test   $0x10,%ah
f01059e1:	75 f5                	jne    f01059d8 <lapic_ipi+0x1c>
		;
}
f01059e3:	5d                   	pop    %ebp
f01059e4:	c3                   	ret    

f01059e5 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01059e5:	55                   	push   %ebp
f01059e6:	89 e5                	mov    %esp,%ebp
f01059e8:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01059eb:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01059f1:	8b 55 0c             	mov    0xc(%ebp),%edx
f01059f4:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01059f7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01059fe:	5d                   	pop    %ebp
f01059ff:	c3                   	ret    

f0105a00 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105a00:	55                   	push   %ebp
f0105a01:	89 e5                	mov    %esp,%ebp
f0105a03:	56                   	push   %esi
f0105a04:	53                   	push   %ebx
f0105a05:	8b 5d 08             	mov    0x8(%ebp),%ebx

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105a08:	83 3b 00             	cmpl   $0x0,(%ebx)
f0105a0b:	74 14                	je     f0105a21 <spin_lock+0x21>
f0105a0d:	8b 73 08             	mov    0x8(%ebx),%esi
f0105a10:	e8 7d fd ff ff       	call   f0105792 <cpunum>
f0105a15:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a18:	05 20 f0 22 f0       	add    $0xf022f020,%eax
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0105a1d:	39 c6                	cmp    %eax,%esi
f0105a1f:	74 07                	je     f0105a28 <spin_lock+0x28>
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105a21:	ba 01 00 00 00       	mov    $0x1,%edx
f0105a26:	eb 20                	jmp    f0105a48 <spin_lock+0x48>
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f0105a28:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0105a2b:	e8 62 fd ff ff       	call   f0105792 <cpunum>
f0105a30:	83 ec 0c             	sub    $0xc,%esp
f0105a33:	53                   	push   %ebx
f0105a34:	50                   	push   %eax
f0105a35:	68 48 79 10 f0       	push   $0xf0107948
f0105a3a:	6a 41                	push   $0x41
f0105a3c:	68 ac 79 10 f0       	push   $0xf01079ac
f0105a41:	e8 fa a5 ff ff       	call   f0100040 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0105a46:	f3 90                	pause  
f0105a48:	89 d0                	mov    %edx,%eax
f0105a4a:	f0 87 03             	lock xchg %eax,(%ebx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0105a4d:	85 c0                	test   %eax,%eax
f0105a4f:	75 f5                	jne    f0105a46 <spin_lock+0x46>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0105a51:	e8 3c fd ff ff       	call   f0105792 <cpunum>
f0105a56:	6b c0 74             	imul   $0x74,%eax,%eax
f0105a59:	05 20 f0 22 f0       	add    $0xf022f020,%eax
f0105a5e:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0105a61:	83 c3 0c             	add    $0xc,%ebx

static inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	asm volatile("movl %%ebp,%0" : "=r" (ebp));
f0105a64:	89 ea                	mov    %ebp,%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105a66:	b8 00 00 00 00       	mov    $0x0,%eax
f0105a6b:	eb 0b                	jmp    f0105a78 <spin_lock+0x78>
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f0105a6d:	8b 4a 04             	mov    0x4(%edx),%ecx
f0105a70:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0105a73:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0105a75:	83 c0 01             	add    $0x1,%eax
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0105a78:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0105a7e:	76 11                	jbe    f0105a91 <spin_lock+0x91>
f0105a80:	83 f8 09             	cmp    $0x9,%eax
f0105a83:	7e e8                	jle    f0105a6d <spin_lock+0x6d>
f0105a85:	eb 0a                	jmp    f0105a91 <spin_lock+0x91>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f0105a87:	c7 04 83 00 00 00 00 	movl   $0x0,(%ebx,%eax,4)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f0105a8e:	83 c0 01             	add    $0x1,%eax
f0105a91:	83 f8 09             	cmp    $0x9,%eax
f0105a94:	7e f1                	jle    f0105a87 <spin_lock+0x87>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f0105a96:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105a99:	5b                   	pop    %ebx
f0105a9a:	5e                   	pop    %esi
f0105a9b:	5d                   	pop    %ebp
f0105a9c:	c3                   	ret    

f0105a9d <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105a9d:	55                   	push   %ebp
f0105a9e:	89 e5                	mov    %esp,%ebp
f0105aa0:	57                   	push   %edi
f0105aa1:	56                   	push   %esi
f0105aa2:	53                   	push   %ebx
f0105aa3:	83 ec 4c             	sub    $0x4c,%esp
f0105aa6:	8b 75 08             	mov    0x8(%ebp),%esi

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
	return lock->locked && lock->cpu == thiscpu;
f0105aa9:	83 3e 00             	cmpl   $0x0,(%esi)
f0105aac:	74 18                	je     f0105ac6 <spin_unlock+0x29>
f0105aae:	8b 5e 08             	mov    0x8(%esi),%ebx
f0105ab1:	e8 dc fc ff ff       	call   f0105792 <cpunum>
f0105ab6:	6b c0 74             	imul   $0x74,%eax,%eax
f0105ab9:	05 20 f0 22 f0       	add    $0xf022f020,%eax
// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f0105abe:	39 c3                	cmp    %eax,%ebx
f0105ac0:	0f 84 a5 00 00 00    	je     f0105b6b <spin_unlock+0xce>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f0105ac6:	83 ec 04             	sub    $0x4,%esp
f0105ac9:	6a 28                	push   $0x28
f0105acb:	8d 46 0c             	lea    0xc(%esi),%eax
f0105ace:	50                   	push   %eax
f0105acf:	8d 5d c0             	lea    -0x40(%ebp),%ebx
f0105ad2:	53                   	push   %ebx
f0105ad3:	e8 e7 f6 ff ff       	call   f01051bf <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
f0105ad8:	8b 46 08             	mov    0x8(%esi),%eax
	if (!holding(lk)) {
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0105adb:	0f b6 38             	movzbl (%eax),%edi
f0105ade:	8b 76 04             	mov    0x4(%esi),%esi
f0105ae1:	e8 ac fc ff ff       	call   f0105792 <cpunum>
f0105ae6:	57                   	push   %edi
f0105ae7:	56                   	push   %esi
f0105ae8:	50                   	push   %eax
f0105ae9:	68 74 79 10 f0       	push   $0xf0107974
f0105aee:	e8 ae da ff ff       	call   f01035a1 <cprintf>
f0105af3:	83 c4 20             	add    $0x20,%esp
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f0105af6:	8d 7d a8             	lea    -0x58(%ebp),%edi
f0105af9:	eb 54                	jmp    f0105b4f <spin_unlock+0xb2>
f0105afb:	83 ec 08             	sub    $0x8,%esp
f0105afe:	57                   	push   %edi
f0105aff:	50                   	push   %eax
f0105b00:	e8 8f ec ff ff       	call   f0104794 <debuginfo_eip>
f0105b05:	83 c4 10             	add    $0x10,%esp
f0105b08:	85 c0                	test   %eax,%eax
f0105b0a:	78 27                	js     f0105b33 <spin_unlock+0x96>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f0105b0c:	8b 06                	mov    (%esi),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f0105b0e:	83 ec 04             	sub    $0x4,%esp
f0105b11:	89 c2                	mov    %eax,%edx
f0105b13:	2b 55 b8             	sub    -0x48(%ebp),%edx
f0105b16:	52                   	push   %edx
f0105b17:	ff 75 b0             	pushl  -0x50(%ebp)
f0105b1a:	ff 75 b4             	pushl  -0x4c(%ebp)
f0105b1d:	ff 75 ac             	pushl  -0x54(%ebp)
f0105b20:	ff 75 a8             	pushl  -0x58(%ebp)
f0105b23:	50                   	push   %eax
f0105b24:	68 bc 79 10 f0       	push   $0xf01079bc
f0105b29:	e8 73 da ff ff       	call   f01035a1 <cprintf>
f0105b2e:	83 c4 20             	add    $0x20,%esp
f0105b31:	eb 12                	jmp    f0105b45 <spin_unlock+0xa8>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f0105b33:	83 ec 08             	sub    $0x8,%esp
f0105b36:	ff 36                	pushl  (%esi)
f0105b38:	68 d3 79 10 f0       	push   $0xf01079d3
f0105b3d:	e8 5f da ff ff       	call   f01035a1 <cprintf>
f0105b42:	83 c4 10             	add    $0x10,%esp
f0105b45:	83 c3 04             	add    $0x4,%ebx
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f0105b48:	8d 45 e8             	lea    -0x18(%ebp),%eax
f0105b4b:	39 c3                	cmp    %eax,%ebx
f0105b4d:	74 08                	je     f0105b57 <spin_unlock+0xba>
f0105b4f:	89 de                	mov    %ebx,%esi
f0105b51:	8b 03                	mov    (%ebx),%eax
f0105b53:	85 c0                	test   %eax,%eax
f0105b55:	75 a4                	jne    f0105afb <spin_unlock+0x5e>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f0105b57:	83 ec 04             	sub    $0x4,%esp
f0105b5a:	68 db 79 10 f0       	push   $0xf01079db
f0105b5f:	6a 67                	push   $0x67
f0105b61:	68 ac 79 10 f0       	push   $0xf01079ac
f0105b66:	e8 d5 a4 ff ff       	call   f0100040 <_panic>
	}

	lk->pcs[0] = 0;
f0105b6b:	c7 46 0c 00 00 00 00 	movl   $0x0,0xc(%esi)
	lk->cpu = 0;
f0105b72:	c7 46 08 00 00 00 00 	movl   $0x0,0x8(%esi)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1"
f0105b79:	b8 00 00 00 00       	mov    $0x0,%eax
f0105b7e:	f0 87 06             	lock xchg %eax,(%esi)
	// respect to any other instruction which references the same memory.
	// x86 CPUs will not reorder loads/stores across locked instructions
	// (vol 3, 8.2.2). Because xchg() is implemented using asm volatile,
	// gcc will not reorder C statements across the xchg.
	xchg(&lk->locked, 0);
}
f0105b81:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0105b84:	5b                   	pop    %ebx
f0105b85:	5e                   	pop    %esi
f0105b86:	5f                   	pop    %edi
f0105b87:	5d                   	pop    %ebp
f0105b88:	c3                   	ret    
f0105b89:	66 90                	xchg   %ax,%ax
f0105b8b:	66 90                	xchg   %ax,%ax
f0105b8d:	66 90                	xchg   %ax,%ax
f0105b8f:	90                   	nop

f0105b90 <__udivdi3>:
f0105b90:	55                   	push   %ebp
f0105b91:	57                   	push   %edi
f0105b92:	56                   	push   %esi
f0105b93:	53                   	push   %ebx
f0105b94:	83 ec 1c             	sub    $0x1c,%esp
f0105b97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
f0105b9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
f0105b9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
f0105ba3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105ba7:	85 f6                	test   %esi,%esi
f0105ba9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105bad:	89 ca                	mov    %ecx,%edx
f0105baf:	89 f8                	mov    %edi,%eax
f0105bb1:	75 3d                	jne    f0105bf0 <__udivdi3+0x60>
f0105bb3:	39 cf                	cmp    %ecx,%edi
f0105bb5:	0f 87 c5 00 00 00    	ja     f0105c80 <__udivdi3+0xf0>
f0105bbb:	85 ff                	test   %edi,%edi
f0105bbd:	89 fd                	mov    %edi,%ebp
f0105bbf:	75 0b                	jne    f0105bcc <__udivdi3+0x3c>
f0105bc1:	b8 01 00 00 00       	mov    $0x1,%eax
f0105bc6:	31 d2                	xor    %edx,%edx
f0105bc8:	f7 f7                	div    %edi
f0105bca:	89 c5                	mov    %eax,%ebp
f0105bcc:	89 c8                	mov    %ecx,%eax
f0105bce:	31 d2                	xor    %edx,%edx
f0105bd0:	f7 f5                	div    %ebp
f0105bd2:	89 c1                	mov    %eax,%ecx
f0105bd4:	89 d8                	mov    %ebx,%eax
f0105bd6:	89 cf                	mov    %ecx,%edi
f0105bd8:	f7 f5                	div    %ebp
f0105bda:	89 c3                	mov    %eax,%ebx
f0105bdc:	89 d8                	mov    %ebx,%eax
f0105bde:	89 fa                	mov    %edi,%edx
f0105be0:	83 c4 1c             	add    $0x1c,%esp
f0105be3:	5b                   	pop    %ebx
f0105be4:	5e                   	pop    %esi
f0105be5:	5f                   	pop    %edi
f0105be6:	5d                   	pop    %ebp
f0105be7:	c3                   	ret    
f0105be8:	90                   	nop
f0105be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105bf0:	39 ce                	cmp    %ecx,%esi
f0105bf2:	77 74                	ja     f0105c68 <__udivdi3+0xd8>
f0105bf4:	0f bd fe             	bsr    %esi,%edi
f0105bf7:	83 f7 1f             	xor    $0x1f,%edi
f0105bfa:	0f 84 98 00 00 00    	je     f0105c98 <__udivdi3+0x108>
f0105c00:	bb 20 00 00 00       	mov    $0x20,%ebx
f0105c05:	89 f9                	mov    %edi,%ecx
f0105c07:	89 c5                	mov    %eax,%ebp
f0105c09:	29 fb                	sub    %edi,%ebx
f0105c0b:	d3 e6                	shl    %cl,%esi
f0105c0d:	89 d9                	mov    %ebx,%ecx
f0105c0f:	d3 ed                	shr    %cl,%ebp
f0105c11:	89 f9                	mov    %edi,%ecx
f0105c13:	d3 e0                	shl    %cl,%eax
f0105c15:	09 ee                	or     %ebp,%esi
f0105c17:	89 d9                	mov    %ebx,%ecx
f0105c19:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105c1d:	89 d5                	mov    %edx,%ebp
f0105c1f:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105c23:	d3 ed                	shr    %cl,%ebp
f0105c25:	89 f9                	mov    %edi,%ecx
f0105c27:	d3 e2                	shl    %cl,%edx
f0105c29:	89 d9                	mov    %ebx,%ecx
f0105c2b:	d3 e8                	shr    %cl,%eax
f0105c2d:	09 c2                	or     %eax,%edx
f0105c2f:	89 d0                	mov    %edx,%eax
f0105c31:	89 ea                	mov    %ebp,%edx
f0105c33:	f7 f6                	div    %esi
f0105c35:	89 d5                	mov    %edx,%ebp
f0105c37:	89 c3                	mov    %eax,%ebx
f0105c39:	f7 64 24 0c          	mull   0xc(%esp)
f0105c3d:	39 d5                	cmp    %edx,%ebp
f0105c3f:	72 10                	jb     f0105c51 <__udivdi3+0xc1>
f0105c41:	8b 74 24 08          	mov    0x8(%esp),%esi
f0105c45:	89 f9                	mov    %edi,%ecx
f0105c47:	d3 e6                	shl    %cl,%esi
f0105c49:	39 c6                	cmp    %eax,%esi
f0105c4b:	73 07                	jae    f0105c54 <__udivdi3+0xc4>
f0105c4d:	39 d5                	cmp    %edx,%ebp
f0105c4f:	75 03                	jne    f0105c54 <__udivdi3+0xc4>
f0105c51:	83 eb 01             	sub    $0x1,%ebx
f0105c54:	31 ff                	xor    %edi,%edi
f0105c56:	89 d8                	mov    %ebx,%eax
f0105c58:	89 fa                	mov    %edi,%edx
f0105c5a:	83 c4 1c             	add    $0x1c,%esp
f0105c5d:	5b                   	pop    %ebx
f0105c5e:	5e                   	pop    %esi
f0105c5f:	5f                   	pop    %edi
f0105c60:	5d                   	pop    %ebp
f0105c61:	c3                   	ret    
f0105c62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105c68:	31 ff                	xor    %edi,%edi
f0105c6a:	31 db                	xor    %ebx,%ebx
f0105c6c:	89 d8                	mov    %ebx,%eax
f0105c6e:	89 fa                	mov    %edi,%edx
f0105c70:	83 c4 1c             	add    $0x1c,%esp
f0105c73:	5b                   	pop    %ebx
f0105c74:	5e                   	pop    %esi
f0105c75:	5f                   	pop    %edi
f0105c76:	5d                   	pop    %ebp
f0105c77:	c3                   	ret    
f0105c78:	90                   	nop
f0105c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105c80:	89 d8                	mov    %ebx,%eax
f0105c82:	f7 f7                	div    %edi
f0105c84:	31 ff                	xor    %edi,%edi
f0105c86:	89 c3                	mov    %eax,%ebx
f0105c88:	89 d8                	mov    %ebx,%eax
f0105c8a:	89 fa                	mov    %edi,%edx
f0105c8c:	83 c4 1c             	add    $0x1c,%esp
f0105c8f:	5b                   	pop    %ebx
f0105c90:	5e                   	pop    %esi
f0105c91:	5f                   	pop    %edi
f0105c92:	5d                   	pop    %ebp
f0105c93:	c3                   	ret    
f0105c94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105c98:	39 ce                	cmp    %ecx,%esi
f0105c9a:	72 0c                	jb     f0105ca8 <__udivdi3+0x118>
f0105c9c:	31 db                	xor    %ebx,%ebx
f0105c9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
f0105ca2:	0f 87 34 ff ff ff    	ja     f0105bdc <__udivdi3+0x4c>
f0105ca8:	bb 01 00 00 00       	mov    $0x1,%ebx
f0105cad:	e9 2a ff ff ff       	jmp    f0105bdc <__udivdi3+0x4c>
f0105cb2:	66 90                	xchg   %ax,%ax
f0105cb4:	66 90                	xchg   %ax,%ax
f0105cb6:	66 90                	xchg   %ax,%ax
f0105cb8:	66 90                	xchg   %ax,%ax
f0105cba:	66 90                	xchg   %ax,%ax
f0105cbc:	66 90                	xchg   %ax,%ax
f0105cbe:	66 90                	xchg   %ax,%ax

f0105cc0 <__umoddi3>:
f0105cc0:	55                   	push   %ebp
f0105cc1:	57                   	push   %edi
f0105cc2:	56                   	push   %esi
f0105cc3:	53                   	push   %ebx
f0105cc4:	83 ec 1c             	sub    $0x1c,%esp
f0105cc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
f0105ccb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f0105ccf:	8b 74 24 34          	mov    0x34(%esp),%esi
f0105cd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105cd7:	85 d2                	test   %edx,%edx
f0105cd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0105cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105ce1:	89 f3                	mov    %esi,%ebx
f0105ce3:	89 3c 24             	mov    %edi,(%esp)
f0105ce6:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105cea:	75 1c                	jne    f0105d08 <__umoddi3+0x48>
f0105cec:	39 f7                	cmp    %esi,%edi
f0105cee:	76 50                	jbe    f0105d40 <__umoddi3+0x80>
f0105cf0:	89 c8                	mov    %ecx,%eax
f0105cf2:	89 f2                	mov    %esi,%edx
f0105cf4:	f7 f7                	div    %edi
f0105cf6:	89 d0                	mov    %edx,%eax
f0105cf8:	31 d2                	xor    %edx,%edx
f0105cfa:	83 c4 1c             	add    $0x1c,%esp
f0105cfd:	5b                   	pop    %ebx
f0105cfe:	5e                   	pop    %esi
f0105cff:	5f                   	pop    %edi
f0105d00:	5d                   	pop    %ebp
f0105d01:	c3                   	ret    
f0105d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0105d08:	39 f2                	cmp    %esi,%edx
f0105d0a:	89 d0                	mov    %edx,%eax
f0105d0c:	77 52                	ja     f0105d60 <__umoddi3+0xa0>
f0105d0e:	0f bd ea             	bsr    %edx,%ebp
f0105d11:	83 f5 1f             	xor    $0x1f,%ebp
f0105d14:	75 5a                	jne    f0105d70 <__umoddi3+0xb0>
f0105d16:	3b 54 24 04          	cmp    0x4(%esp),%edx
f0105d1a:	0f 82 e0 00 00 00    	jb     f0105e00 <__umoddi3+0x140>
f0105d20:	39 0c 24             	cmp    %ecx,(%esp)
f0105d23:	0f 86 d7 00 00 00    	jbe    f0105e00 <__umoddi3+0x140>
f0105d29:	8b 44 24 08          	mov    0x8(%esp),%eax
f0105d2d:	8b 54 24 04          	mov    0x4(%esp),%edx
f0105d31:	83 c4 1c             	add    $0x1c,%esp
f0105d34:	5b                   	pop    %ebx
f0105d35:	5e                   	pop    %esi
f0105d36:	5f                   	pop    %edi
f0105d37:	5d                   	pop    %ebp
f0105d38:	c3                   	ret    
f0105d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105d40:	85 ff                	test   %edi,%edi
f0105d42:	89 fd                	mov    %edi,%ebp
f0105d44:	75 0b                	jne    f0105d51 <__umoddi3+0x91>
f0105d46:	b8 01 00 00 00       	mov    $0x1,%eax
f0105d4b:	31 d2                	xor    %edx,%edx
f0105d4d:	f7 f7                	div    %edi
f0105d4f:	89 c5                	mov    %eax,%ebp
f0105d51:	89 f0                	mov    %esi,%eax
f0105d53:	31 d2                	xor    %edx,%edx
f0105d55:	f7 f5                	div    %ebp
f0105d57:	89 c8                	mov    %ecx,%eax
f0105d59:	f7 f5                	div    %ebp
f0105d5b:	89 d0                	mov    %edx,%eax
f0105d5d:	eb 99                	jmp    f0105cf8 <__umoddi3+0x38>
f0105d5f:	90                   	nop
f0105d60:	89 c8                	mov    %ecx,%eax
f0105d62:	89 f2                	mov    %esi,%edx
f0105d64:	83 c4 1c             	add    $0x1c,%esp
f0105d67:	5b                   	pop    %ebx
f0105d68:	5e                   	pop    %esi
f0105d69:	5f                   	pop    %edi
f0105d6a:	5d                   	pop    %ebp
f0105d6b:	c3                   	ret    
f0105d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105d70:	8b 34 24             	mov    (%esp),%esi
f0105d73:	bf 20 00 00 00       	mov    $0x20,%edi
f0105d78:	89 e9                	mov    %ebp,%ecx
f0105d7a:	29 ef                	sub    %ebp,%edi
f0105d7c:	d3 e0                	shl    %cl,%eax
f0105d7e:	89 f9                	mov    %edi,%ecx
f0105d80:	89 f2                	mov    %esi,%edx
f0105d82:	d3 ea                	shr    %cl,%edx
f0105d84:	89 e9                	mov    %ebp,%ecx
f0105d86:	09 c2                	or     %eax,%edx
f0105d88:	89 d8                	mov    %ebx,%eax
f0105d8a:	89 14 24             	mov    %edx,(%esp)
f0105d8d:	89 f2                	mov    %esi,%edx
f0105d8f:	d3 e2                	shl    %cl,%edx
f0105d91:	89 f9                	mov    %edi,%ecx
f0105d93:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105d97:	8b 54 24 0c          	mov    0xc(%esp),%edx
f0105d9b:	d3 e8                	shr    %cl,%eax
f0105d9d:	89 e9                	mov    %ebp,%ecx
f0105d9f:	89 c6                	mov    %eax,%esi
f0105da1:	d3 e3                	shl    %cl,%ebx
f0105da3:	89 f9                	mov    %edi,%ecx
f0105da5:	89 d0                	mov    %edx,%eax
f0105da7:	d3 e8                	shr    %cl,%eax
f0105da9:	89 e9                	mov    %ebp,%ecx
f0105dab:	09 d8                	or     %ebx,%eax
f0105dad:	89 d3                	mov    %edx,%ebx
f0105daf:	89 f2                	mov    %esi,%edx
f0105db1:	f7 34 24             	divl   (%esp)
f0105db4:	89 d6                	mov    %edx,%esi
f0105db6:	d3 e3                	shl    %cl,%ebx
f0105db8:	f7 64 24 04          	mull   0x4(%esp)
f0105dbc:	39 d6                	cmp    %edx,%esi
f0105dbe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0105dc2:	89 d1                	mov    %edx,%ecx
f0105dc4:	89 c3                	mov    %eax,%ebx
f0105dc6:	72 08                	jb     f0105dd0 <__umoddi3+0x110>
f0105dc8:	75 11                	jne    f0105ddb <__umoddi3+0x11b>
f0105dca:	39 44 24 08          	cmp    %eax,0x8(%esp)
f0105dce:	73 0b                	jae    f0105ddb <__umoddi3+0x11b>
f0105dd0:	2b 44 24 04          	sub    0x4(%esp),%eax
f0105dd4:	1b 14 24             	sbb    (%esp),%edx
f0105dd7:	89 d1                	mov    %edx,%ecx
f0105dd9:	89 c3                	mov    %eax,%ebx
f0105ddb:	8b 54 24 08          	mov    0x8(%esp),%edx
f0105ddf:	29 da                	sub    %ebx,%edx
f0105de1:	19 ce                	sbb    %ecx,%esi
f0105de3:	89 f9                	mov    %edi,%ecx
f0105de5:	89 f0                	mov    %esi,%eax
f0105de7:	d3 e0                	shl    %cl,%eax
f0105de9:	89 e9                	mov    %ebp,%ecx
f0105deb:	d3 ea                	shr    %cl,%edx
f0105ded:	89 e9                	mov    %ebp,%ecx
f0105def:	d3 ee                	shr    %cl,%esi
f0105df1:	09 d0                	or     %edx,%eax
f0105df3:	89 f2                	mov    %esi,%edx
f0105df5:	83 c4 1c             	add    $0x1c,%esp
f0105df8:	5b                   	pop    %ebx
f0105df9:	5e                   	pop    %esi
f0105dfa:	5f                   	pop    %edi
f0105dfb:	5d                   	pop    %ebp
f0105dfc:	c3                   	ret    
f0105dfd:	8d 76 00             	lea    0x0(%esi),%esi
f0105e00:	29 f9                	sub    %edi,%ecx
f0105e02:	19 d6                	sbb    %edx,%esi
f0105e04:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105e08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0105e0c:	e9 18 ff ff ff       	jmp    f0105d29 <__umoddi3+0x69>
