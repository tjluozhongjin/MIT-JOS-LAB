
obj/fs/fs:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 eb 18 00 00       	call   80191c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static inline uint8_t
inb(int port)
{
	uint8_t data;
	asm volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800085:	eb 0b                	jmp    800092 <ide_probe_disk1+0x33>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800087:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80008a:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  800090:	74 05                	je     800097 <ide_probe_disk1+0x38>
  800092:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800093:	a8 a1                	test   $0xa1,%al
  800095:	75 f0                	jne    800087 <ide_probe_disk1+0x28>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800097:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80009c:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  8000a1:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  8000a2:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a8:	0f 9e c3             	setle  %bl
  8000ab:	83 ec 08             	sub    $0x8,%esp
  8000ae:	0f b6 c3             	movzbl %bl,%eax
  8000b1:	50                   	push   %eax
  8000b2:	68 c0 37 80 00       	push   $0x8037c0
  8000b7:	e8 99 19 00 00       	call   801a55 <cprintf>
	return (x < 1000);
}
  8000bc:	89 d8                	mov    %ebx,%eax
  8000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000c1:	c9                   	leave  
  8000c2:	c3                   	ret    

008000c3 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c3:	55                   	push   %ebp
  8000c4:	89 e5                	mov    %esp,%ebp
  8000c6:	83 ec 08             	sub    $0x8,%esp
  8000c9:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000cc:	83 f8 01             	cmp    $0x1,%eax
  8000cf:	76 14                	jbe    8000e5 <ide_set_disk+0x22>
		panic("bad disk number");
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	68 d7 37 80 00       	push   $0x8037d7
  8000d9:	6a 3a                	push   $0x3a
  8000db:	68 e7 37 80 00       	push   $0x8037e7
  8000e0:	e8 97 18 00 00       	call   80197c <_panic>
	diskno = d;
  8000e5:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000ea:	c9                   	leave  
  8000eb:	c3                   	ret    

008000ec <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000ec:	55                   	push   %ebp
  8000ed:	89 e5                	mov    %esp,%ebp
  8000ef:	57                   	push   %edi
  8000f0:	56                   	push   %esi
  8000f1:	53                   	push   %ebx
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fe:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800104:	76 16                	jbe    80011c <ide_read+0x30>
  800106:	68 f0 37 80 00       	push   $0x8037f0
  80010b:	68 fd 37 80 00       	push   $0x8037fd
  800110:	6a 44                	push   $0x44
  800112:	68 e7 37 80 00       	push   $0x8037e7
  800117:	e8 60 18 00 00       	call   80197c <_panic>

	ide_wait_ready(0);
  80011c:	b8 00 00 00 00       	mov    $0x0,%eax
  800121:	e8 0d ff ff ff       	call   800033 <ide_wait_ready>
  800126:	ba f2 01 00 00       	mov    $0x1f2,%edx
  80012b:	89 f0                	mov    %esi,%eax
  80012d:	ee                   	out    %al,(%dx)
  80012e:	ba f3 01 00 00       	mov    $0x1f3,%edx
  800133:	89 f8                	mov    %edi,%eax
  800135:	ee                   	out    %al,(%dx)
  800136:	89 f8                	mov    %edi,%eax
  800138:	c1 e8 08             	shr    $0x8,%eax
  80013b:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800140:	ee                   	out    %al,(%dx)
  800141:	89 f8                	mov    %edi,%eax
  800143:	c1 e8 10             	shr    $0x10,%eax
  800146:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80014b:	ee                   	out    %al,(%dx)
  80014c:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800153:	83 e0 01             	and    $0x1,%eax
  800156:	c1 e0 04             	shl    $0x4,%eax
  800159:	83 c8 e0             	or     $0xffffffe0,%eax
  80015c:	c1 ef 18             	shr    $0x18,%edi
  80015f:	83 e7 0f             	and    $0xf,%edi
  800162:	09 f8                	or     %edi,%eax
  800164:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800169:	ee                   	out    %al,(%dx)
  80016a:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80016f:	b8 20 00 00 00       	mov    $0x20,%eax
  800174:	ee                   	out    %al,(%dx)
  800175:	c1 e6 09             	shl    $0x9,%esi
  800178:	01 de                	add    %ebx,%esi
  80017a:	eb 23                	jmp    80019f <ide_read+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80017c:	b8 01 00 00 00       	mov    $0x1,%eax
  800181:	e8 ad fe ff ff       	call   800033 <ide_wait_ready>
  800186:	85 c0                	test   %eax,%eax
  800188:	78 1e                	js     8001a8 <ide_read+0xbc>
}

static inline void
insl(int port, void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\tinsl"
  80018a:	89 df                	mov    %ebx,%edi
  80018c:	b9 80 00 00 00       	mov    $0x80,%ecx
  800191:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800196:	fc                   	cld    
  800197:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800199:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80019f:	39 f3                	cmp    %esi,%ebx
  8001a1:	75 d9                	jne    80017c <ide_read+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  8001a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    

008001b0 <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	57                   	push   %edi
  8001b4:	56                   	push   %esi
  8001b5:	53                   	push   %ebx
  8001b6:	83 ec 0c             	sub    $0xc,%esp
  8001b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8001bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001bf:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001c2:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001c8:	76 16                	jbe    8001e0 <ide_write+0x30>
  8001ca:	68 f0 37 80 00       	push   $0x8037f0
  8001cf:	68 fd 37 80 00       	push   $0x8037fd
  8001d4:	6a 5d                	push   $0x5d
  8001d6:	68 e7 37 80 00       	push   $0x8037e7
  8001db:	e8 9c 17 00 00       	call   80197c <_panic>

	ide_wait_ready(0);
  8001e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8001e5:	e8 49 fe ff ff       	call   800033 <ide_wait_ready>
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001ea:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001ef:	89 f8                	mov    %edi,%eax
  8001f1:	ee                   	out    %al,(%dx)
  8001f2:	ba f3 01 00 00       	mov    $0x1f3,%edx
  8001f7:	89 f0                	mov    %esi,%eax
  8001f9:	ee                   	out    %al,(%dx)
  8001fa:	89 f0                	mov    %esi,%eax
  8001fc:	c1 e8 08             	shr    $0x8,%eax
  8001ff:	ba f4 01 00 00       	mov    $0x1f4,%edx
  800204:	ee                   	out    %al,(%dx)
  800205:	89 f0                	mov    %esi,%eax
  800207:	c1 e8 10             	shr    $0x10,%eax
  80020a:	ba f5 01 00 00       	mov    $0x1f5,%edx
  80020f:	ee                   	out    %al,(%dx)
  800210:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800217:	83 e0 01             	and    $0x1,%eax
  80021a:	c1 e0 04             	shl    $0x4,%eax
  80021d:	83 c8 e0             	or     $0xffffffe0,%eax
  800220:	c1 ee 18             	shr    $0x18,%esi
  800223:	83 e6 0f             	and    $0xf,%esi
  800226:	09 f0                	or     %esi,%eax
  800228:	ba f6 01 00 00       	mov    $0x1f6,%edx
  80022d:	ee                   	out    %al,(%dx)
  80022e:	ba f7 01 00 00       	mov    $0x1f7,%edx
  800233:	b8 30 00 00 00       	mov    $0x30,%eax
  800238:	ee                   	out    %al,(%dx)
  800239:	c1 e7 09             	shl    $0x9,%edi
  80023c:	01 df                	add    %ebx,%edi
  80023e:	eb 23                	jmp    800263 <ide_write+0xb3>
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  800240:	b8 01 00 00 00       	mov    $0x1,%eax
  800245:	e8 e9 fd ff ff       	call   800033 <ide_wait_ready>
  80024a:	85 c0                	test   %eax,%eax
  80024c:	78 1e                	js     80026c <ide_write+0xbc>
}

static inline void
outsl(int port, const void *addr, int cnt)
{
	asm volatile("cld\n\trepne\n\toutsl"
  80024e:	89 de                	mov    %ebx,%esi
  800250:	b9 80 00 00 00       	mov    $0x80,%ecx
  800255:	ba f0 01 00 00       	mov    $0x1f0,%edx
  80025a:	fc                   	cld    
  80025b:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80025d:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800263:	39 fb                	cmp    %edi,%ebx
  800265:	75 d9                	jne    800240 <ide_write+0x90>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800267:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
	// utf_fault_va is the page fault address in this time 
	void *addr = (void *) utf->utf_fault_va;
  80027c:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  80027e:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800284:	89 c6                	mov    %eax,%esi
  800286:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800289:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80028e:	76 1b                	jbe    8002ab <bc_pgfault+0x37>
		panic("page fault in FS: eip %08x, va %08x, err %04x",
  800290:	83 ec 08             	sub    $0x8,%esp
  800293:	ff 72 04             	pushl  0x4(%edx)
  800296:	53                   	push   %ebx
  800297:	ff 72 28             	pushl  0x28(%edx)
  80029a:	68 14 38 80 00       	push   $0x803814
  80029f:	6a 29                	push   $0x29
  8002a1:	68 18 39 80 00       	push   $0x803918
  8002a6:	e8 d1 16 00 00       	call   80197c <_panic>
		      utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002ab:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002b0:	85 c0                	test   %eax,%eax
  8002b2:	74 17                	je     8002cb <bc_pgfault+0x57>
  8002b4:	3b 70 04             	cmp    0x4(%eax),%esi
  8002b7:	72 12                	jb     8002cb <bc_pgfault+0x57>
		panic("reading non-existent block %08x\n", blockno);
  8002b9:	56                   	push   %esi
  8002ba:	68 44 38 80 00       	push   $0x803844
  8002bf:	6a 2d                	push   $0x2d
  8002c1:	68 18 39 80 00       	push   $0x803918
  8002c6:	e8 b1 16 00 00       	call   80197c <_panic>
	// page_alloc + page_insert  = sys_page_alloc
	// ide_read
	// addr 为啥要页进行页对其，因为其CPU企图访问一个地址的内容，
	// 其不一定是页首地址，有可能是页里的任何一页，但我们管理是按页管理的，
	// 故每次操作要用页首地址
	addr = ROUNDDOWN(addr, PGSIZE);
  8002cb:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	// 分配一个物理页
	if ((r = sys_page_alloc(0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	6a 07                	push   $0x7
  8002d6:	53                   	push   %ebx
  8002d7:	6a 00                	push   $0x0
  8002d9:	e8 7e 21 00 00       	call   80245c <sys_page_alloc>
  8002de:	83 c4 10             	add    $0x10,%esp
  8002e1:	85 c0                	test   %eax,%eax
  8002e3:	79 12                	jns    8002f7 <bc_pgfault+0x83>
		panic("in bc_pgfault, sys_page_alloc: %e", r);
  8002e5:	50                   	push   %eax
  8002e6:	68 68 38 80 00       	push   $0x803868
  8002eb:	6a 3d                	push   $0x3d
  8002ed:	68 18 39 80 00       	push   $0x803918
  8002f2:	e8 85 16 00 00       	call   80197c <_panic>
	// 从磁盘读取一块到物理页
	// 扇区号 = blockno * BLKSECTS
	// 读取一块 == 读取 BLKSECTS 个扇区
	if ((r = ide_read(blockno * BLKSECTS, addr, BLKSECTS)) < 0)
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	6a 08                	push   $0x8
  8002fc:	53                   	push   %ebx
  8002fd:	8d 04 f5 00 00 00 00 	lea    0x0(,%esi,8),%eax
  800304:	50                   	push   %eax
  800305:	e8 e2 fd ff ff       	call   8000ec <ide_read>
  80030a:	83 c4 10             	add    $0x10,%esp
  80030d:	85 c0                	test   %eax,%eax
  80030f:	79 12                	jns    800323 <bc_pgfault+0xaf>
		panic("in bc_pgfault, ide_read: %e", r);
  800311:	50                   	push   %eax
  800312:	68 20 39 80 00       	push   $0x803920
  800317:	6a 42                	push   $0x42
  800319:	68 18 39 80 00       	push   $0x803918
  80031e:	e8 59 16 00 00       	call   80197c <_panic>

	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800323:	89 d8                	mov    %ebx,%eax
  800325:	c1 e8 0c             	shr    $0xc,%eax
  800328:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80032f:	83 ec 0c             	sub    $0xc,%esp
  800332:	25 07 0e 00 00       	and    $0xe07,%eax
  800337:	50                   	push   %eax
  800338:	53                   	push   %ebx
  800339:	6a 00                	push   $0x0
  80033b:	53                   	push   %ebx
  80033c:	6a 00                	push   $0x0
  80033e:	e8 5c 21 00 00       	call   80249f <sys_page_map>
  800343:	83 c4 20             	add    $0x20,%esp
  800346:	85 c0                	test   %eax,%eax
  800348:	79 12                	jns    80035c <bc_pgfault+0xe8>
		panic("in bc_pgfault, sys_page_map: %e", r);
  80034a:	50                   	push   %eax
  80034b:	68 8c 38 80 00       	push   $0x80388c
  800350:	6a 47                	push   $0x47
  800352:	68 18 39 80 00       	push   $0x803918
  800357:	e8 20 16 00 00       	call   80197c <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80035c:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800363:	74 22                	je     800387 <bc_pgfault+0x113>
  800365:	83 ec 0c             	sub    $0xc,%esp
  800368:	56                   	push   %esi
  800369:	e8 60 03 00 00       	call   8006ce <block_is_free>
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	84 c0                	test   %al,%al
  800373:	74 12                	je     800387 <bc_pgfault+0x113>
		panic("reading free block %08x\n", blockno);
  800375:	56                   	push   %esi
  800376:	68 3c 39 80 00       	push   $0x80393c
  80037b:	6a 4d                	push   $0x4d
  80037d:	68 18 39 80 00       	push   $0x803918
  800382:	e8 f5 15 00 00       	call   80197c <_panic>
}
  800387:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038a:	5b                   	pop    %ebx
  80038b:	5e                   	pop    %esi
  80038c:	5d                   	pop    %ebp
  80038d:	c3                   	ret    

0080038e <diskaddr>:

// Return the virtual address of this disk block.
// 根据块号查找该块的虚拟地址
void*
diskaddr(uint32_t blockno)
{
  80038e:	55                   	push   %ebp
  80038f:	89 e5                	mov    %esp,%ebp
  800391:	83 ec 08             	sub    $0x8,%esp
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800397:	85 c0                	test   %eax,%eax
  800399:	74 0f                	je     8003aa <diskaddr+0x1c>
  80039b:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8003a1:	85 d2                	test   %edx,%edx
  8003a3:	74 17                	je     8003bc <diskaddr+0x2e>
  8003a5:	3b 42 04             	cmp    0x4(%edx),%eax
  8003a8:	72 12                	jb     8003bc <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  8003aa:	50                   	push   %eax
  8003ab:	68 ac 38 80 00       	push   $0x8038ac
  8003b0:	6a 0a                	push   $0xa
  8003b2:	68 18 39 80 00       	push   $0x803918
  8003b7:	e8 c0 15 00 00       	call   80197c <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003bc:	05 00 00 01 00       	add    $0x10000,%eax
  8003c1:	c1 e0 0c             	shl    $0xc,%eax
}
  8003c4:	c9                   	leave  
  8003c5:	c3                   	ret    

008003c6 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003cc:	89 d0                	mov    %edx,%eax
  8003ce:	c1 e8 16             	shr    $0x16,%eax
  8003d1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dd:	f6 c1 01             	test   $0x1,%cl
  8003e0:	74 0d                	je     8003ef <va_is_mapped+0x29>
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003ec:	83 e0 01             	and    $0x1,%eax
  8003ef:	83 e0 01             	and    $0x1,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c1 e8 0c             	shr    $0xc,%eax
  8003fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800404:	c1 e8 06             	shr    $0x6,%eax
  800407:	83 e0 01             	and    $0x1,%eax
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	56                   	push   %esi
  800410:	53                   	push   %ebx
  800411:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;

	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  800414:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  80041a:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  80041f:	76 12                	jbe    800433 <flush_block+0x27>
		panic("flush_block of bad va %08x", addr);
  800421:	53                   	push   %ebx
  800422:	68 55 39 80 00       	push   $0x803955
  800427:	6a 5d                	push   $0x5d
  800429:	68 18 39 80 00       	push   $0x803918
  80042e:	e8 49 15 00 00       	call   80197c <_panic>

	// LAB 5: Your code here.
	// panic("flush_block not implemented");
	// 检查地址的正确性以及是否是“脏页”
	if (!(va_is_mapped(addr) && va_is_dirty(addr)))
  800433:	83 ec 0c             	sub    $0xc,%esp
  800436:	53                   	push   %ebx
  800437:	e8 8a ff ff ff       	call   8003c6 <va_is_mapped>
  80043c:	83 c4 10             	add    $0x10,%esp
  80043f:	84 c0                	test   %al,%al
  800441:	0f 84 82 00 00 00    	je     8004c9 <flush_block+0xbd>
  800447:	83 ec 0c             	sub    $0xc,%esp
  80044a:	53                   	push   %ebx
  80044b:	e8 a4 ff ff ff       	call   8003f4 <va_is_dirty>
  800450:	83 c4 10             	add    $0x10,%esp
  800453:	84 c0                	test   %al,%al
  800455:	74 72                	je     8004c9 <flush_block+0xbd>
		return;
	// 对齐
	addr = ROUNDDOWN(addr, PGSIZE);
  800457:	89 de                	mov    %ebx,%esi
  800459:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	int r;
	// 从物理内存写数据到磁盘
	if ((r = ide_write(blockno*BLKSECTS, addr, BLKSECTS)) < 0)
  80045f:	83 ec 04             	sub    $0x4,%esp
  800462:	6a 08                	push   $0x8
  800464:	56                   	push   %esi
  800465:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  80046b:	c1 eb 0c             	shr    $0xc,%ebx
  80046e:	c1 e3 03             	shl    $0x3,%ebx
  800471:	53                   	push   %ebx
  800472:	e8 39 fd ff ff       	call   8001b0 <ide_write>
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	85 c0                	test   %eax,%eax
  80047c:	79 12                	jns    800490 <flush_block+0x84>
		panic("in flush_block, ide_write: %e", r);
  80047e:	50                   	push   %eax
  80047f:	68 70 39 80 00       	push   $0x803970
  800484:	6a 69                	push   $0x69
  800486:	68 18 39 80 00       	push   $0x803918
  80048b:	e8 ec 14 00 00       	call   80197c <_panic>
	// 0 表示当前进程 PTE_SYSCALL作用？？
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800490:	89 f0                	mov    %esi,%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80049c:	83 ec 0c             	sub    $0xc,%esp
  80049f:	25 07 0e 00 00       	and    $0xe07,%eax
  8004a4:	50                   	push   %eax
  8004a5:	56                   	push   %esi
  8004a6:	6a 00                	push   $0x0
  8004a8:	56                   	push   %esi
  8004a9:	6a 00                	push   $0x0
  8004ab:	e8 ef 1f 00 00       	call   80249f <sys_page_map>
  8004b0:	83 c4 20             	add    $0x20,%esp
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	79 12                	jns    8004c9 <flush_block+0xbd>
		panic("in flush_block, sys_page_map: %e", r);
  8004b7:	50                   	push   %eax
  8004b8:	68 d0 38 80 00       	push   $0x8038d0
  8004bd:	6a 6c                	push   $0x6c
  8004bf:	68 18 39 80 00       	push   $0x803918
  8004c4:	e8 b3 14 00 00       	call   80197c <_panic>
}
  8004c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004cc:	5b                   	pop    %ebx
  8004cd:	5e                   	pop    %esi
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    

008004d0 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004d9:	68 74 02 80 00       	push   $0x800274
  8004de:	e8 6a 21 00 00       	call   80264d <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004e3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004ea:	e8 9f fe ff ff       	call   80038e <diskaddr>
  8004ef:	83 c4 0c             	add    $0xc,%esp
  8004f2:	68 08 01 00 00       	push   $0x108
  8004f7:	50                   	push   %eax
  8004f8:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004fe:	50                   	push   %eax
  8004ff:	e8 e7 1c 00 00       	call   8021eb <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  800504:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80050b:	e8 7e fe ff ff       	call   80038e <diskaddr>
  800510:	83 c4 08             	add    $0x8,%esp
  800513:	68 8e 39 80 00       	push   $0x80398e
  800518:	50                   	push   %eax
  800519:	e8 3b 1b 00 00       	call   802059 <strcpy>
	flush_block(diskaddr(1));
  80051e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800525:	e8 64 fe ff ff       	call   80038e <diskaddr>
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	e8 da fe ff ff       	call   80040c <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800532:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800539:	e8 50 fe ff ff       	call   80038e <diskaddr>
  80053e:	89 04 24             	mov    %eax,(%esp)
  800541:	e8 80 fe ff ff       	call   8003c6 <va_is_mapped>
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	84 c0                	test   %al,%al
  80054b:	75 16                	jne    800563 <bc_init+0x93>
  80054d:	68 b0 39 80 00       	push   $0x8039b0
  800552:	68 fd 37 80 00       	push   $0x8037fd
  800557:	6a 7c                	push   $0x7c
  800559:	68 18 39 80 00       	push   $0x803918
  80055e:	e8 19 14 00 00       	call   80197c <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800563:	83 ec 0c             	sub    $0xc,%esp
  800566:	6a 01                	push   $0x1
  800568:	e8 21 fe ff ff       	call   80038e <diskaddr>
  80056d:	89 04 24             	mov    %eax,(%esp)
  800570:	e8 7f fe ff ff       	call   8003f4 <va_is_dirty>
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	84 c0                	test   %al,%al
  80057a:	74 16                	je     800592 <bc_init+0xc2>
  80057c:	68 95 39 80 00       	push   $0x803995
  800581:	68 fd 37 80 00       	push   $0x8037fd
  800586:	6a 7d                	push   $0x7d
  800588:	68 18 39 80 00       	push   $0x803918
  80058d:	e8 ea 13 00 00       	call   80197c <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800592:	83 ec 0c             	sub    $0xc,%esp
  800595:	6a 01                	push   $0x1
  800597:	e8 f2 fd ff ff       	call   80038e <diskaddr>
  80059c:	83 c4 08             	add    $0x8,%esp
  80059f:	50                   	push   %eax
  8005a0:	6a 00                	push   $0x0
  8005a2:	e8 3a 1f 00 00       	call   8024e1 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  8005a7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005ae:	e8 db fd ff ff       	call   80038e <diskaddr>
  8005b3:	89 04 24             	mov    %eax,(%esp)
  8005b6:	e8 0b fe ff ff       	call   8003c6 <va_is_mapped>
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	84 c0                	test   %al,%al
  8005c0:	74 19                	je     8005db <bc_init+0x10b>
  8005c2:	68 af 39 80 00       	push   $0x8039af
  8005c7:	68 fd 37 80 00       	push   $0x8037fd
  8005cc:	68 81 00 00 00       	push   $0x81
  8005d1:	68 18 39 80 00       	push   $0x803918
  8005d6:	e8 a1 13 00 00       	call   80197c <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005db:	83 ec 0c             	sub    $0xc,%esp
  8005de:	6a 01                	push   $0x1
  8005e0:	e8 a9 fd ff ff       	call   80038e <diskaddr>
  8005e5:	83 c4 08             	add    $0x8,%esp
  8005e8:	68 8e 39 80 00       	push   $0x80398e
  8005ed:	50                   	push   %eax
  8005ee:	e8 10 1b 00 00       	call   802103 <strcmp>
  8005f3:	83 c4 10             	add    $0x10,%esp
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	74 19                	je     800613 <bc_init+0x143>
  8005fa:	68 f4 38 80 00       	push   $0x8038f4
  8005ff:	68 fd 37 80 00       	push   $0x8037fd
  800604:	68 84 00 00 00       	push   $0x84
  800609:	68 18 39 80 00       	push   $0x803918
  80060e:	e8 69 13 00 00       	call   80197c <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800613:	83 ec 0c             	sub    $0xc,%esp
  800616:	6a 01                	push   $0x1
  800618:	e8 71 fd ff ff       	call   80038e <diskaddr>
  80061d:	83 c4 0c             	add    $0xc,%esp
  800620:	68 08 01 00 00       	push   $0x108
  800625:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80062b:	52                   	push   %edx
  80062c:	50                   	push   %eax
  80062d:	e8 b9 1b 00 00       	call   8021eb <memmove>
	flush_block(diskaddr(1));
  800632:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800639:	e8 50 fd ff ff       	call   80038e <diskaddr>
  80063e:	89 04 24             	mov    %eax,(%esp)
  800641:	e8 c6 fd ff ff       	call   80040c <flush_block>

	cprintf("block cache is good\n");
  800646:	c7 04 24 ca 39 80 00 	movl   $0x8039ca,(%esp)
  80064d:	e8 03 14 00 00       	call   801a55 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800652:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800659:	e8 30 fd ff ff       	call   80038e <diskaddr>
  80065e:	83 c4 0c             	add    $0xc,%esp
  800661:	68 08 01 00 00       	push   $0x108
  800666:	50                   	push   %eax
  800667:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	e8 78 1b 00 00       	call   8021eb <memmove>
}
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	c9                   	leave  
  800677:	c3                   	ret    

00800678 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800678:	55                   	push   %ebp
  800679:	89 e5                	mov    %esp,%ebp
  80067b:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80067e:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800683:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800689:	74 14                	je     80069f <check_super+0x27>
		panic("bad file system magic number");
  80068b:	83 ec 04             	sub    $0x4,%esp
  80068e:	68 df 39 80 00       	push   $0x8039df
  800693:	6a 0f                	push   $0xf
  800695:	68 fc 39 80 00       	push   $0x8039fc
  80069a:	e8 dd 12 00 00       	call   80197c <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80069f:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  8006a6:	76 14                	jbe    8006bc <check_super+0x44>
		panic("file system is too large");
  8006a8:	83 ec 04             	sub    $0x4,%esp
  8006ab:	68 04 3a 80 00       	push   $0x803a04
  8006b0:	6a 12                	push   $0x12
  8006b2:	68 fc 39 80 00       	push   $0x8039fc
  8006b7:	e8 c0 12 00 00       	call   80197c <_panic>

	cprintf("superblock is good\n");
  8006bc:	83 ec 0c             	sub    $0xc,%esp
  8006bf:	68 1d 3a 80 00       	push   $0x803a1d
  8006c4:	e8 8c 13 00 00       	call   801a55 <cprintf>
}
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	c9                   	leave  
  8006cd:	c3                   	ret    

008006ce <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006d5:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	74 24                	je     800703 <block_is_free+0x35>
		return 0;
  8006df:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8006e4:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8006e7:	76 1f                	jbe    800708 <block_is_free+0x3a>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006e9:	89 cb                	mov    %ecx,%ebx
  8006eb:	c1 eb 05             	shr    $0x5,%ebx
  8006ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8006f3:	d3 e0                	shl    %cl,%eax
  8006f5:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8006fb:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  8006fe:	0f 95 c0             	setne  %al
  800701:	eb 05                	jmp    800708 <block_is_free+0x3a>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  800703:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  800708:	5b                   	pop    %ebx
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	53                   	push   %ebx
  80070f:	83 ec 04             	sub    $0x4,%esp
  800712:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800715:	85 c9                	test   %ecx,%ecx
  800717:	75 14                	jne    80072d <free_block+0x22>
		panic("attempt to free zero block");
  800719:	83 ec 04             	sub    $0x4,%esp
  80071c:	68 31 3a 80 00       	push   $0x803a31
  800721:	6a 2d                	push   $0x2d
  800723:	68 fc 39 80 00       	push   $0x8039fc
  800728:	e8 4f 12 00 00       	call   80197c <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  80072d:	89 cb                	mov    %ecx,%ebx
  80072f:	c1 eb 05             	shr    $0x5,%ebx
  800732:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800738:	b8 01 00 00 00       	mov    $0x1,%eax
  80073d:	d3 e0                	shl    %cl,%eax
  80073f:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  800742:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <alloc_block>:
//
// Hint: use free_block as an example for manipulating the bitmap.
// 分配一个块，返回块号
int
alloc_block(void)
{
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	56                   	push   %esi
  80074b:	53                   	push   %ebx

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	//for()
	uint32_t blockno;
	for(blockno = 0; blockno < super->s_nblocks;blockno++){
  80074c:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800751:	8b 70 04             	mov    0x4(%eax),%esi
  800754:	bb 00 00 00 00       	mov    $0x0,%ebx
  800759:	eb 3c                	jmp    800797 <alloc_block+0x50>
		if(block_is_free(blockno)){
  80075b:	53                   	push   %ebx
  80075c:	e8 6d ff ff ff       	call   8006ce <block_is_free>
  800761:	83 c4 04             	add    $0x4,%esp
  800764:	84 c0                	test   %al,%al
  800766:	74 2c                	je     800794 <alloc_block+0x4d>
			// 更改空闲位图，怎么操作的？？？
			bitmap[blockno/32] ^= 1 << (blockno % 32);
  800768:	89 de                	mov    %ebx,%esi
  80076a:	c1 ee 05             	shr    $0x5,%esi
  80076d:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800773:	b8 01 00 00 00       	mov    $0x1,%eax
  800778:	89 d9                	mov    %ebx,%ecx
  80077a:	d3 e0                	shl    %cl,%eax
  80077c:	31 04 b2             	xor    %eax,(%edx,%esi,4)
			// 更新磁盘(写回)，保持文件的一致性
			flush_block(bitmap);
  80077f:	83 ec 0c             	sub    $0xc,%esp
  800782:	ff 35 04 a0 80 00    	pushl  0x80a004
  800788:	e8 7f fc ff ff       	call   80040c <flush_block>
			// 返回分配的块号
			return blockno;
  80078d:	89 d8                	mov    %ebx,%eax
  80078f:	83 c4 10             	add    $0x10,%esp
  800792:	eb 0c                	jmp    8007a0 <alloc_block+0x59>

	// LAB 5: Your code here.
	//panic("alloc_block not implemented");
	//for()
	uint32_t blockno;
	for(blockno = 0; blockno < super->s_nblocks;blockno++){
  800794:	83 c3 01             	add    $0x1,%ebx
  800797:	39 f3                	cmp    %esi,%ebx
  800799:	75 c0                	jne    80075b <alloc_block+0x14>
			flush_block(bitmap);
			// 返回分配的块号
			return blockno;
		}
	}
	return -E_NO_DISK;
  80079b:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
}
  8007a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007a3:	5b                   	pop    %ebx
  8007a4:	5e                   	pop    %esi
  8007a5:	5d                   	pop    %ebp
  8007a6:	c3                   	ret    

008007a7 <file_block_walk>:
// 根据文件结构和文件块号查找磁盘块号
// 类似page_walk??不同意
// zhe li shi cha zhao kuai hao
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	57                   	push   %edi
  8007ab:	56                   	push   %esi
  8007ac:	53                   	push   %ebx
  8007ad:	83 ec 1c             	sub    $0x1c,%esp
  8007b0:	8b 7d 08             	mov    0x8(%ebp),%edi
    // LAB 5: Your code here.
    //panic("file_block_walk not implemented");
	uint32_t blockno;
 
    if (filebno >= NDIRECT + NINDIRECT)
  8007b3:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8007b9:	0f 87 85 00 00 00    	ja     800844 <file_block_walk+0x9d>
        return -E_INVAL;

    // 如果块号小于NDIRECT，证明是文件的直接磁盘块
    if (filebno < NDIRECT) {
  8007bf:	83 fa 09             	cmp    $0x9,%edx
  8007c2:	77 10                	ja     8007d4 <file_block_walk+0x2d>
	// 记录磁盘块号的指针
        *ppdiskbno = &f->f_direct[filebno];
  8007c4:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007cb:	89 01                	mov    %eax,(%ecx)
        return 0;
  8007cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d2:	eb 7c                	jmp    800850 <file_block_walk+0xa9>
  8007d4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8007d7:	89 d3                	mov    %edx,%ebx
  8007d9:	89 c6                	mov    %eax,%esi
    }

    // 如果文件的间接磁盘块未分配
    if (f->f_indirect == 0) {
  8007db:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  8007e2:	75 3f                	jne    800823 <file_block_walk+0x7c>
        if (!alloc) 
  8007e4:	89 f8                	mov    %edi,%eax
  8007e6:	84 c0                	test   %al,%al
  8007e8:	74 61                	je     80084b <file_block_walk+0xa4>
            return -E_NOT_FOUND;
        
        if ((blockno = alloc_block()) < 0) 
  8007ea:	e8 58 ff ff ff       	call   800747 <alloc_block>
  8007ef:	89 c7                	mov    %eax,%edi
            return -E_NO_DISK;
        // 以下两步为磁盘块的清零，即先将磁盘块对应的内存块清零，再写回
        memset(diskaddr(blockno), 0, BLKSIZE);
  8007f1:	83 ec 0c             	sub    $0xc,%esp
  8007f4:	50                   	push   %eax
  8007f5:	e8 94 fb ff ff       	call   80038e <diskaddr>
  8007fa:	83 c4 0c             	add    $0xc,%esp
  8007fd:	68 00 10 00 00       	push   $0x1000
  800802:	6a 00                	push   $0x0
  800804:	50                   	push   %eax
  800805:	e8 94 19 00 00       	call   80219e <memset>
        flush_block(diskaddr(blockno));
  80080a:	89 3c 24             	mov    %edi,(%esp)
  80080d:	e8 7c fb ff ff       	call   80038e <diskaddr>
  800812:	89 04 24             	mov    %eax,(%esp)
  800815:	e8 f2 fb ff ff       	call   80040c <flush_block>

	// 设置文件的间接磁盘块块号
        f->f_indirect = blockno;
  80081a:	89 be b0 00 00 00    	mov    %edi,0xb0(%esi)
  800820:	83 c4 10             	add    $0x10,%esp
    } 

    // 记录磁盘块号的指针
    *ppdiskbno = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
  800823:	83 ec 0c             	sub    $0xc,%esp
  800826:	ff b6 b0 00 00 00    	pushl  0xb0(%esi)
  80082c:	e8 5d fb ff ff       	call   80038e <diskaddr>
  800831:	8d 44 98 d8          	lea    -0x28(%eax,%ebx,4),%eax
  800835:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800838:	89 03                	mov    %eax,(%ebx)
    
    return 0;
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
  800842:	eb 0c                	jmp    800850 <file_block_walk+0xa9>
    // LAB 5: Your code here.
    //panic("file_block_walk not implemented");
	uint32_t blockno;
 
    if (filebno >= NDIRECT + NINDIRECT)
        return -E_INVAL;
  800844:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800849:	eb 05                	jmp    800850 <file_block_walk+0xa9>
    }

    // 如果文件的间接磁盘块未分配
    if (f->f_indirect == 0) {
        if (!alloc) 
            return -E_NOT_FOUND;
  80084b:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
    // 记录磁盘块号的指针
    *ppdiskbno = (uint32_t*)diskaddr(f->f_indirect) + filebno - NDIRECT;
    
    return 0;

}
  800850:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800853:	5b                   	pop    %ebx
  800854:	5e                   	pop    %esi
  800855:	5f                   	pop    %edi
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  80085d:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800862:	8b 70 04             	mov    0x4(%eax),%esi
  800865:	bb 00 00 00 00       	mov    $0x0,%ebx
  80086a:	eb 29                	jmp    800895 <check_bitmap+0x3d>
		assert(!block_is_free(2+i));
  80086c:	8d 43 02             	lea    0x2(%ebx),%eax
  80086f:	50                   	push   %eax
  800870:	e8 59 fe ff ff       	call   8006ce <block_is_free>
  800875:	83 c4 04             	add    $0x4,%esp
  800878:	84 c0                	test   %al,%al
  80087a:	74 16                	je     800892 <check_bitmap+0x3a>
  80087c:	68 4c 3a 80 00       	push   $0x803a4c
  800881:	68 fd 37 80 00       	push   $0x8037fd
  800886:	6a 5d                	push   $0x5d
  800888:	68 fc 39 80 00       	push   $0x8039fc
  80088d:	e8 ea 10 00 00       	call   80197c <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800892:	83 c3 01             	add    $0x1,%ebx
  800895:	89 d8                	mov    %ebx,%eax
  800897:	c1 e0 0f             	shl    $0xf,%eax
  80089a:	39 f0                	cmp    %esi,%eax
  80089c:	72 ce                	jb     80086c <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  80089e:	83 ec 0c             	sub    $0xc,%esp
  8008a1:	6a 00                	push   $0x0
  8008a3:	e8 26 fe ff ff       	call   8006ce <block_is_free>
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	84 c0                	test   %al,%al
  8008ad:	74 16                	je     8008c5 <check_bitmap+0x6d>
  8008af:	68 60 3a 80 00       	push   $0x803a60
  8008b4:	68 fd 37 80 00       	push   $0x8037fd
  8008b9:	6a 60                	push   $0x60
  8008bb:	68 fc 39 80 00       	push   $0x8039fc
  8008c0:	e8 b7 10 00 00       	call   80197c <_panic>
	assert(!block_is_free(1));
  8008c5:	83 ec 0c             	sub    $0xc,%esp
  8008c8:	6a 01                	push   $0x1
  8008ca:	e8 ff fd ff ff       	call   8006ce <block_is_free>
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	84 c0                	test   %al,%al
  8008d4:	74 16                	je     8008ec <check_bitmap+0x94>
  8008d6:	68 72 3a 80 00       	push   $0x803a72
  8008db:	68 fd 37 80 00       	push   $0x8037fd
  8008e0:	6a 61                	push   $0x61
  8008e2:	68 fc 39 80 00       	push   $0x8039fc
  8008e7:	e8 90 10 00 00       	call   80197c <_panic>

	cprintf("bitmap is good\n");
  8008ec:	83 ec 0c             	sub    $0xc,%esp
  8008ef:	68 84 3a 80 00       	push   $0x803a84
  8008f4:	e8 5c 11 00 00       	call   801a55 <cprintf>
}
  8008f9:	83 c4 10             	add    $0x10,%esp
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	// Find a JOS disk.  Use the second IDE disk (number 1) if available
	if (ide_probe_disk1())
  800909:	e8 51 f7 ff ff       	call   80005f <ide_probe_disk1>
  80090e:	84 c0                	test   %al,%al
  800910:	74 0f                	je     800921 <fs_init+0x1e>
		ide_set_disk(1);
  800912:	83 ec 0c             	sub    $0xc,%esp
  800915:	6a 01                	push   $0x1
  800917:	e8 a7 f7 ff ff       	call   8000c3 <ide_set_disk>
  80091c:	83 c4 10             	add    $0x10,%esp
  80091f:	eb 0d                	jmp    80092e <fs_init+0x2b>
	else
		ide_set_disk(0);
  800921:	83 ec 0c             	sub    $0xc,%esp
  800924:	6a 00                	push   $0x0
  800926:	e8 98 f7 ff ff       	call   8000c3 <ide_set_disk>
  80092b:	83 c4 10             	add    $0x10,%esp
	bc_init();
  80092e:	e8 9d fb ff ff       	call   8004d0 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 51 fa ff ff       	call   80038e <diskaddr>
  80093d:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800942:	e8 31 fd ff ff       	call   800678 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	// 空闲位图位置
	bitmap = diskaddr(2);
  800947:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80094e:	e8 3b fa ff ff       	call   80038e <diskaddr>
  800953:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  800958:	e8 fb fe ff ff       	call   800858 <check_bitmap>
	
}
  80095d:	83 c4 10             	add    $0x10,%esp
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <file_get_block>:
// 
// 这里是查找块（的地址）
// 根据 filebno查找对应的磁盘块，返回磁盘块的地址
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	83 ec 24             	sub    $0x24,%esp
	int r;
	uint32_t *pdiskbno;
	uint32_t blkno;

	// 查找 filebno 对应的 块号
	if ((r = file_block_walk(f, filebno, &pdiskbno, true)) < 0)
  800968:	6a 01                	push   $0x1
  80096a:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  80096d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	e8 2f fe ff ff       	call   8007a7 <file_block_walk>
  800978:	83 c4 10             	add    $0x10,%esp
  80097b:	85 c0                	test   %eax,%eax
  80097d:	78 2c                	js     8009ab <file_get_block+0x49>
		return r;

	// 如果块号为0，证明 filebno 没有对应的块
	if (!*pdiskbno) {
  80097f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800982:	83 38 00             	cmpl   $0x0,(%eax)
  800985:	75 0a                	jne    800991 <file_get_block+0x2f>
		// 申请一个块给 filebno
		if ((blkno = alloc_block()) < 0)
  800987:	e8 bb fd ff ff       	call   800747 <alloc_block>
			return -E_NO_DISK;
		*pdiskbno = blkno;
  80098c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80098f:	89 02                	mov    %eax,(%edx)
	}

	// 记录 filebno 对应的磁盘块(的地址)
	*blk = diskaddr(*pdiskbno);
  800991:	83 ec 0c             	sub    $0xc,%esp
  800994:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800997:	ff 30                	pushl  (%eax)
  800999:	e8 f0 f9 ff ff       	call   80038e <diskaddr>
  80099e:	8b 55 10             	mov    0x10(%ebp),%edx
  8009a1:	89 02                	mov    %eax,(%edx)

	return 0;
  8009a3:	83 c4 10             	add    $0x10,%esp
  8009a6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ab:	c9                   	leave  
  8009ac:	c3                   	ret    

008009ad <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	57                   	push   %edi
  8009b1:	56                   	push   %esi
  8009b2:	53                   	push   %ebx
  8009b3:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  8009b9:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  8009bf:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  8009c5:	eb 03                	jmp    8009ca <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8009c7:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8009ca:	80 38 2f             	cmpb   $0x2f,(%eax)
  8009cd:	74 f8                	je     8009c7 <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8009cf:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  8009d5:	83 c1 08             	add    $0x8,%ecx
  8009d8:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  8009de:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  8009e5:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  8009eb:	85 c9                	test   %ecx,%ecx
  8009ed:	74 06                	je     8009f5 <walk_path+0x48>
		*pdir = 0;
  8009ef:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  8009f5:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  8009fb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800a01:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a06:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a0c:	e9 5f 01 00 00       	jmp    800b70 <walk_path+0x1c3>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a11:	83 c7 01             	add    $0x1,%edi
  800a14:	eb 02                	jmp    800a18 <walk_path+0x6b>
  800a16:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a18:	0f b6 17             	movzbl (%edi),%edx
  800a1b:	80 fa 2f             	cmp    $0x2f,%dl
  800a1e:	74 04                	je     800a24 <walk_path+0x77>
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 ed                	jne    800a11 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a24:	89 fb                	mov    %edi,%ebx
  800a26:	29 c3                	sub    %eax,%ebx
  800a28:	83 fb 7f             	cmp    $0x7f,%ebx
  800a2b:	0f 8f 69 01 00 00    	jg     800b9a <walk_path+0x1ed>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a31:	83 ec 04             	sub    $0x4,%esp
  800a34:	53                   	push   %ebx
  800a35:	50                   	push   %eax
  800a36:	56                   	push   %esi
  800a37:	e8 af 17 00 00       	call   8021eb <memmove>
		name[path - p] = '\0';
  800a3c:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a43:	00 
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	eb 03                	jmp    800a4c <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a49:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a4c:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a4f:	74 f8                	je     800a49 <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800a51:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800a57:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800a5e:	0f 85 3d 01 00 00    	jne    800ba1 <walk_path+0x1f4>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800a64:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800a6a:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800a6f:	74 19                	je     800a8a <walk_path+0xdd>
  800a71:	68 94 3a 80 00       	push   $0x803a94
  800a76:	68 fd 37 80 00       	push   $0x8037fd
  800a7b:	68 f3 00 00 00       	push   $0xf3
  800a80:	68 fc 39 80 00       	push   $0x8039fc
  800a85:	e8 f2 0e 00 00       	call   80197c <_panic>
	nblock = dir->f_size / BLKSIZE;
  800a8a:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800a90:	85 c0                	test   %eax,%eax
  800a92:	0f 48 c2             	cmovs  %edx,%eax
  800a95:	c1 f8 0c             	sar    $0xc,%eax
  800a98:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800a9e:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800aa5:	00 00 00 
  800aa8:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800aae:	eb 5e                	jmp    800b0e <walk_path+0x161>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800ab0:	83 ec 04             	sub    $0x4,%esp
  800ab3:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800ab9:	50                   	push   %eax
  800aba:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800ac0:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800ac6:	e8 97 fe ff ff       	call   800962 <file_get_block>
  800acb:	83 c4 10             	add    $0x10,%esp
  800ace:	85 c0                	test   %eax,%eax
  800ad0:	0f 88 ee 00 00 00    	js     800bc4 <walk_path+0x217>
			return r;
		f = (struct File*) blk;
  800ad6:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800adc:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800ae2:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800ae8:	83 ec 08             	sub    $0x8,%esp
  800aeb:	56                   	push   %esi
  800aec:	53                   	push   %ebx
  800aed:	e8 11 16 00 00       	call   802103 <strcmp>
  800af2:	83 c4 10             	add    $0x10,%esp
  800af5:	85 c0                	test   %eax,%eax
  800af7:	0f 84 ab 00 00 00    	je     800ba8 <walk_path+0x1fb>
  800afd:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800b03:	39 fb                	cmp    %edi,%ebx
  800b05:	75 db                	jne    800ae2 <walk_path+0x135>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800b07:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b0e:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b14:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b1a:	75 94                	jne    800ab0 <walk_path+0x103>
  800b1c:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
					*pdir = dir;
				if (lastelem)
					strcpy(lastelem, name);
				*pf = 0;
			}
			return r;
  800b22:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b27:	80 3f 00             	cmpb   $0x0,(%edi)
  800b2a:	0f 85 a3 00 00 00    	jne    800bd3 <walk_path+0x226>
				if (pdir)
  800b30:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b36:	85 c0                	test   %eax,%eax
  800b38:	74 08                	je     800b42 <walk_path+0x195>
					*pdir = dir;
  800b3a:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b40:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b42:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b46:	74 15                	je     800b5d <walk_path+0x1b0>
					strcpy(lastelem, name);
  800b48:	83 ec 08             	sub    $0x8,%esp
  800b4b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b51:	50                   	push   %eax
  800b52:	ff 75 08             	pushl  0x8(%ebp)
  800b55:	e8 ff 14 00 00       	call   802059 <strcpy>
  800b5a:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800b5d:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b63:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800b69:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800b6e:	eb 63                	jmp    800bd3 <walk_path+0x226>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b70:	80 38 00             	cmpb   $0x0,(%eax)
  800b73:	0f 85 9d fe ff ff    	jne    800a16 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800b79:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b7f:	85 c0                	test   %eax,%eax
  800b81:	74 02                	je     800b85 <walk_path+0x1d8>
		*pdir = dir;
  800b83:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800b85:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b8b:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b91:	89 08                	mov    %ecx,(%eax)
	return 0;
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	eb 39                	jmp    800bd3 <walk_path+0x226>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800b9a:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800b9f:	eb 32                	jmp    800bd3 <walk_path+0x226>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800ba1:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800ba6:	eb 2b                	jmp    800bd3 <walk_path+0x226>
  800ba8:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800bae:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800bb4:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800bba:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800bc0:	89 f8                	mov    %edi,%eax
  800bc2:	eb ac                	jmp    800b70 <walk_path+0x1c3>
  800bc4:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800bca:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800bcd:	0f 84 4f ff ff ff    	je     800b22 <walk_path+0x175>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd6:	5b                   	pop    %ebx
  800bd7:	5e                   	pop    %esi
  800bd8:	5f                   	pop    %edi
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800be1:	6a 00                	push   $0x0
  800be3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be6:	ba 00 00 00 00       	mov    $0x0,%edx
  800beb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bee:	e8 ba fd ff ff       	call   8009ad <walk_path>
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 2c             	sub    $0x2c,%esp
  800bfe:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c01:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c0d:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c12:	39 ca                	cmp    %ecx,%edx
  800c14:	7e 7c                	jle    800c92 <file_read+0x9d>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c16:	29 ca                	sub    %ecx,%edx
  800c18:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c1b:	0f 47 55 10          	cmova  0x10(%ebp),%edx
  800c1f:	89 55 d0             	mov    %edx,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c22:	89 ce                	mov    %ecx,%esi
  800c24:	01 d1                	add    %edx,%ecx
  800c26:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c29:	eb 5d                	jmp    800c88 <file_read+0x93>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c2b:	83 ec 04             	sub    $0x4,%esp
  800c2e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c31:	50                   	push   %eax
  800c32:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800c38:	85 f6                	test   %esi,%esi
  800c3a:	0f 49 c6             	cmovns %esi,%eax
  800c3d:	c1 f8 0c             	sar    $0xc,%eax
  800c40:	50                   	push   %eax
  800c41:	ff 75 08             	pushl  0x8(%ebp)
  800c44:	e8 19 fd ff ff       	call   800962 <file_get_block>
  800c49:	83 c4 10             	add    $0x10,%esp
  800c4c:	85 c0                	test   %eax,%eax
  800c4e:	78 42                	js     800c92 <file_read+0x9d>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800c50:	89 f2                	mov    %esi,%edx
  800c52:	c1 fa 1f             	sar    $0x1f,%edx
  800c55:	c1 ea 14             	shr    $0x14,%edx
  800c58:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800c5b:	25 ff 0f 00 00       	and    $0xfff,%eax
  800c60:	29 d0                	sub    %edx,%eax
  800c62:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800c65:	29 da                	sub    %ebx,%edx
  800c67:	bb 00 10 00 00       	mov    $0x1000,%ebx
  800c6c:	29 c3                	sub    %eax,%ebx
  800c6e:	39 da                	cmp    %ebx,%edx
  800c70:	0f 46 da             	cmovbe %edx,%ebx
		memmove(buf, blk + pos % BLKSIZE, bn);
  800c73:	83 ec 04             	sub    $0x4,%esp
  800c76:	53                   	push   %ebx
  800c77:	03 45 e4             	add    -0x1c(%ebp),%eax
  800c7a:	50                   	push   %eax
  800c7b:	57                   	push   %edi
  800c7c:	e8 6a 15 00 00       	call   8021eb <memmove>
		pos += bn;
  800c81:	01 de                	add    %ebx,%esi
		buf += bn;
  800c83:	01 df                	add    %ebx,%edi
  800c85:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800c88:	89 f3                	mov    %esi,%ebx
  800c8a:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800c8d:	77 9c                	ja     800c2b <file_read+0x36>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800c8f:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800c92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 2c             	sub    $0x2c,%esp
  800ca3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (f->f_size > newsize)
  800ca6:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800cac:	3b 45 0c             	cmp    0xc(%ebp),%eax
  800caf:	0f 8e a7 00 00 00    	jle    800d5c <file_set_size+0xc2>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800cb5:	8d b8 fe 1f 00 00    	lea    0x1ffe(%eax),%edi
  800cbb:	05 ff 0f 00 00       	add    $0xfff,%eax
  800cc0:	0f 49 f8             	cmovns %eax,%edi
  800cc3:	c1 ff 0c             	sar    $0xc,%edi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800cc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc9:	05 fe 1f 00 00       	add    $0x1ffe,%eax
  800cce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd1:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
  800cd7:	0f 49 c2             	cmovns %edx,%eax
  800cda:	c1 f8 0c             	sar    $0xc,%eax
  800cdd:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800ce0:	89 c3                	mov    %eax,%ebx
  800ce2:	eb 39                	jmp    800d1d <file_set_size+0x83>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	6a 00                	push   $0x0
  800ce9:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800cec:	89 da                	mov    %ebx,%edx
  800cee:	89 f0                	mov    %esi,%eax
  800cf0:	e8 b2 fa ff ff       	call   8007a7 <file_block_walk>
  800cf5:	83 c4 10             	add    $0x10,%esp
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	78 4d                	js     800d49 <file_set_size+0xaf>
		return r;
	if (*ptr) {
  800cfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800cff:	8b 00                	mov    (%eax),%eax
  800d01:	85 c0                	test   %eax,%eax
  800d03:	74 15                	je     800d1a <file_set_size+0x80>
		free_block(*ptr);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	e8 fd f9 ff ff       	call   80070b <free_block>
		*ptr = 0;
  800d0e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d11:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d17:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d1a:	83 c3 01             	add    $0x1,%ebx
  800d1d:	39 df                	cmp    %ebx,%edi
  800d1f:	77 c3                	ja     800ce4 <file_set_size+0x4a>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d21:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d25:	77 35                	ja     800d5c <file_set_size+0xc2>
  800d27:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	74 2b                	je     800d5c <file_set_size+0xc2>
		free_block(f->f_indirect);
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	50                   	push   %eax
  800d35:	e8 d1 f9 ff ff       	call   80070b <free_block>
		f->f_indirect = 0;
  800d3a:	c7 86 b0 00 00 00 00 	movl   $0x0,0xb0(%esi)
  800d41:	00 00 00 
  800d44:	83 c4 10             	add    $0x10,%esp
  800d47:	eb 13                	jmp    800d5c <file_set_size+0xc2>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %e", r);
  800d49:	83 ec 08             	sub    $0x8,%esp
  800d4c:	50                   	push   %eax
  800d4d:	68 b1 3a 80 00       	push   $0x803ab1
  800d52:	e8 fe 0c 00 00       	call   801a55 <cprintf>
  800d57:	83 c4 10             	add    $0x10,%esp
  800d5a:	eb be                	jmp    800d1a <file_set_size+0x80>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800d5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5f:	89 86 80 00 00 00    	mov    %eax,0x80(%esi)
	flush_block(f);
  800d65:	83 ec 0c             	sub    $0xc,%esp
  800d68:	56                   	push   %esi
  800d69:	e8 9e f6 ff ff       	call   80040c <flush_block>
	return 0;
}
  800d6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d76:	5b                   	pop    %ebx
  800d77:	5e                   	pop    %esi
  800d78:	5f                   	pop    %edi
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 2c             	sub    $0x2c,%esp
  800d84:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d87:	8b 75 14             	mov    0x14(%ebp),%esi
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800d8a:	89 f0                	mov    %esi,%eax
  800d8c:	03 45 10             	add    0x10(%ebp),%eax
  800d8f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800d92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d95:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800d9b:	76 72                	jbe    800e0f <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800d9d:	83 ec 08             	sub    $0x8,%esp
  800da0:	50                   	push   %eax
  800da1:	51                   	push   %ecx
  800da2:	e8 f3 fe ff ff       	call   800c9a <file_set_size>
  800da7:	83 c4 10             	add    $0x10,%esp
  800daa:	85 c0                	test   %eax,%eax
  800dac:	79 61                	jns    800e0f <file_write+0x94>
  800dae:	eb 69                	jmp    800e19 <file_write+0x9e>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800db0:	83 ec 04             	sub    $0x4,%esp
  800db3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800db6:	50                   	push   %eax
  800db7:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
  800dbd:	85 f6                	test   %esi,%esi
  800dbf:	0f 49 c6             	cmovns %esi,%eax
  800dc2:	c1 f8 0c             	sar    $0xc,%eax
  800dc5:	50                   	push   %eax
  800dc6:	ff 75 08             	pushl  0x8(%ebp)
  800dc9:	e8 94 fb ff ff       	call   800962 <file_get_block>
  800dce:	83 c4 10             	add    $0x10,%esp
  800dd1:	85 c0                	test   %eax,%eax
  800dd3:	78 44                	js     800e19 <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800dd5:	89 f2                	mov    %esi,%edx
  800dd7:	c1 fa 1f             	sar    $0x1f,%edx
  800dda:	c1 ea 14             	shr    $0x14,%edx
  800ddd:	8d 04 16             	lea    (%esi,%edx,1),%eax
  800de0:	25 ff 0f 00 00       	and    $0xfff,%eax
  800de5:	29 d0                	sub    %edx,%eax
  800de7:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800dea:	29 d9                	sub    %ebx,%ecx
  800dec:	89 cb                	mov    %ecx,%ebx
  800dee:	ba 00 10 00 00       	mov    $0x1000,%edx
  800df3:	29 c2                	sub    %eax,%edx
  800df5:	39 d1                	cmp    %edx,%ecx
  800df7:	0f 47 da             	cmova  %edx,%ebx
		memmove(blk + pos % BLKSIZE, buf, bn);
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	53                   	push   %ebx
  800dfe:	57                   	push   %edi
  800dff:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e02:	50                   	push   %eax
  800e03:	e8 e3 13 00 00       	call   8021eb <memmove>
		pos += bn;
  800e08:	01 de                	add    %ebx,%esi
		buf += bn;
  800e0a:	01 df                	add    %ebx,%edi
  800e0c:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e0f:	89 f3                	mov    %esi,%ebx
  800e11:	39 75 d4             	cmp    %esi,-0x2c(%ebp)
  800e14:	77 9a                	ja     800db0 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e16:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1c:	5b                   	pop    %ebx
  800e1d:	5e                   	pop    %esi
  800e1e:	5f                   	pop    %edi
  800e1f:	5d                   	pop    %ebp
  800e20:	c3                   	ret    

00800e21 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	56                   	push   %esi
  800e25:	53                   	push   %ebx
  800e26:	83 ec 10             	sub    $0x10,%esp
  800e29:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e2c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e31:	eb 3c                	jmp    800e6f <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	6a 00                	push   $0x0
  800e38:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e3b:	89 da                	mov    %ebx,%edx
  800e3d:	89 f0                	mov    %esi,%eax
  800e3f:	e8 63 f9 ff ff       	call   8007a7 <file_block_walk>
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	85 c0                	test   %eax,%eax
  800e49:	78 21                	js     800e6c <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	74 1a                	je     800e6c <file_flush+0x4b>
		    pdiskbno == NULL || *pdiskbno == 0)
  800e52:	8b 00                	mov    (%eax),%eax
  800e54:	85 c0                	test   %eax,%eax
  800e56:	74 14                	je     800e6c <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	50                   	push   %eax
  800e5c:	e8 2d f5 ff ff       	call   80038e <diskaddr>
  800e61:	89 04 24             	mov    %eax,(%esp)
  800e64:	e8 a3 f5 ff ff       	call   80040c <flush_block>
  800e69:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e6c:	83 c3 01             	add    $0x1,%ebx
  800e6f:	8b 96 80 00 00 00    	mov    0x80(%esi),%edx
  800e75:	8d 8a ff 0f 00 00    	lea    0xfff(%edx),%ecx
  800e7b:	8d 82 fe 1f 00 00    	lea    0x1ffe(%edx),%eax
  800e81:	85 c9                	test   %ecx,%ecx
  800e83:	0f 49 c1             	cmovns %ecx,%eax
  800e86:	c1 f8 0c             	sar    $0xc,%eax
  800e89:	39 c3                	cmp    %eax,%ebx
  800e8b:	7c a6                	jl     800e33 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
		    pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800e8d:	83 ec 0c             	sub    $0xc,%esp
  800e90:	56                   	push   %esi
  800e91:	e8 76 f5 ff ff       	call   80040c <flush_block>
	if (f->f_indirect)
  800e96:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800e9c:	83 c4 10             	add    $0x10,%esp
  800e9f:	85 c0                	test   %eax,%eax
  800ea1:	74 14                	je     800eb7 <file_flush+0x96>
		flush_block(diskaddr(f->f_indirect));
  800ea3:	83 ec 0c             	sub    $0xc,%esp
  800ea6:	50                   	push   %eax
  800ea7:	e8 e2 f4 ff ff       	call   80038e <diskaddr>
  800eac:	89 04 24             	mov    %eax,(%esp)
  800eaf:	e8 58 f5 ff ff       	call   80040c <flush_block>
  800eb4:	83 c4 10             	add    $0x10,%esp
}
  800eb7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eba:	5b                   	pop    %ebx
  800ebb:	5e                   	pop    %esi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	57                   	push   %edi
  800ec2:	56                   	push   %esi
  800ec3:	53                   	push   %ebx
  800ec4:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800eca:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ed0:	50                   	push   %eax
  800ed1:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800ed7:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800edd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee0:	e8 c8 fa ff ff       	call   8009ad <walk_path>
  800ee5:	83 c4 10             	add    $0x10,%esp
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	0f 84 d1 00 00 00    	je     800fc1 <file_create+0x103>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800ef0:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800ef3:	0f 85 0c 01 00 00    	jne    801005 <file_create+0x147>
  800ef9:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800eff:	85 f6                	test   %esi,%esi
  800f01:	0f 84 c1 00 00 00    	je     800fc8 <file_create+0x10a>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800f07:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f0d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f12:	74 19                	je     800f2d <file_create+0x6f>
  800f14:	68 94 3a 80 00       	push   $0x803a94
  800f19:	68 fd 37 80 00       	push   $0x8037fd
  800f1e:	68 0c 01 00 00       	push   $0x10c
  800f23:	68 fc 39 80 00       	push   $0x8039fc
  800f28:	e8 4f 0a 00 00       	call   80197c <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f2d:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
  800f33:	85 c0                	test   %eax,%eax
  800f35:	0f 48 c2             	cmovs  %edx,%eax
  800f38:	c1 f8 0c             	sar    $0xc,%eax
  800f3b:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f41:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f46:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f4c:	eb 3b                	jmp    800f89 <file_create+0xcb>
  800f4e:	83 ec 04             	sub    $0x4,%esp
  800f51:	57                   	push   %edi
  800f52:	53                   	push   %ebx
  800f53:	56                   	push   %esi
  800f54:	e8 09 fa ff ff       	call   800962 <file_get_block>
  800f59:	83 c4 10             	add    $0x10,%esp
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	0f 88 a1 00 00 00    	js     801005 <file_create+0x147>
			return r;
		f = (struct File*) blk;
  800f64:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f6a:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800f70:	80 38 00             	cmpb   $0x0,(%eax)
  800f73:	75 08                	jne    800f7d <file_create+0xbf>
				*file = &f[j];
  800f75:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800f7b:	eb 52                	jmp    800fcf <file_create+0x111>
  800f7d:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800f82:	39 d0                	cmp    %edx,%eax
  800f84:	75 ea                	jne    800f70 <file_create+0xb2>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800f86:	83 c3 01             	add    $0x1,%ebx
  800f89:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800f8f:	75 bd                	jne    800f4e <file_create+0x90>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800f91:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800f98:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800fa4:	50                   	push   %eax
  800fa5:	53                   	push   %ebx
  800fa6:	56                   	push   %esi
  800fa7:	e8 b6 f9 ff ff       	call   800962 <file_get_block>
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 52                	js     801005 <file_create+0x147>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  800fb3:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fb9:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fbf:	eb 0e                	jmp    800fcf <file_create+0x111>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800fc1:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800fc6:	eb 3d                	jmp    801005 <file_create+0x147>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800fc8:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800fcd:	eb 36                	jmp    801005 <file_create+0x147>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  800fcf:	83 ec 08             	sub    $0x8,%esp
  800fd2:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  800fdf:	e8 75 10 00 00       	call   802059 <strcpy>
	*pf = f;
  800fe4:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800fea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fed:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  800fef:	83 c4 04             	add    $0x4,%esp
  800ff2:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  800ff8:	e8 24 fe ff ff       	call   800e21 <file_flush>
	return 0;
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801005:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801008:	5b                   	pop    %ebx
  801009:	5e                   	pop    %esi
  80100a:	5f                   	pop    %edi
  80100b:	5d                   	pop    %ebp
  80100c:	c3                   	ret    

0080100d <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80100d:	55                   	push   %ebp
  80100e:	89 e5                	mov    %esp,%ebp
  801010:	53                   	push   %ebx
  801011:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801014:	bb 01 00 00 00       	mov    $0x1,%ebx
  801019:	eb 17                	jmp    801032 <fs_sync+0x25>
		flush_block(diskaddr(i));
  80101b:	83 ec 0c             	sub    $0xc,%esp
  80101e:	53                   	push   %ebx
  80101f:	e8 6a f3 ff ff       	call   80038e <diskaddr>
  801024:	89 04 24             	mov    %eax,(%esp)
  801027:	e8 e0 f3 ff ff       	call   80040c <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80102c:	83 c3 01             	add    $0x1,%ebx
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801037:	39 58 04             	cmp    %ebx,0x4(%eax)
  80103a:	77 df                	ja     80101b <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80103c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80103f:	c9                   	leave  
  801040:	c3                   	ret    

00801041 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801047:	e8 c1 ff ff ff       	call   80100d <fs_sync>
	return 0;
}
  80104c:	b8 00 00 00 00       	mov    $0x0,%eax
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	ba 60 50 80 00       	mov    $0x805060,%edx
	int i;
	uintptr_t va = FILEVA;
  80105b:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801060:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801065:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801067:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80106a:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801070:	83 c0 01             	add    $0x1,%eax
  801073:	83 c2 10             	add    $0x10,%edx
  801076:	3d 00 04 00 00       	cmp    $0x400,%eax
  80107b:	75 e8                	jne    801065 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    

0080107f <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  80107f:	55                   	push   %ebp
  801080:	89 e5                	mov    %esp,%ebp
  801082:	56                   	push   %esi
  801083:	53                   	push   %ebx
  801084:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801087:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  80108c:	83 ec 0c             	sub    $0xc,%esp
  80108f:	89 d8                	mov    %ebx,%eax
  801091:	c1 e0 04             	shl    $0x4,%eax
  801094:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  80109a:	e8 68 1f 00 00       	call   803007 <pageref>
  80109f:	83 c4 10             	add    $0x10,%esp
  8010a2:	85 c0                	test   %eax,%eax
  8010a4:	74 07                	je     8010ad <openfile_alloc+0x2e>
  8010a6:	83 f8 01             	cmp    $0x1,%eax
  8010a9:	74 20                	je     8010cb <openfile_alloc+0x4c>
  8010ab:	eb 51                	jmp    8010fe <openfile_alloc+0x7f>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8010ad:	83 ec 04             	sub    $0x4,%esp
  8010b0:	6a 07                	push   $0x7
  8010b2:	89 d8                	mov    %ebx,%eax
  8010b4:	c1 e0 04             	shl    $0x4,%eax
  8010b7:	ff b0 6c 50 80 00    	pushl  0x80506c(%eax)
  8010bd:	6a 00                	push   $0x0
  8010bf:	e8 98 13 00 00       	call   80245c <sys_page_alloc>
  8010c4:	83 c4 10             	add    $0x10,%esp
  8010c7:	85 c0                	test   %eax,%eax
  8010c9:	78 43                	js     80110e <openfile_alloc+0x8f>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8010cb:	c1 e3 04             	shl    $0x4,%ebx
  8010ce:	8d 83 60 50 80 00    	lea    0x805060(%ebx),%eax
  8010d4:	81 83 60 50 80 00 00 	addl   $0x400,0x805060(%ebx)
  8010db:	04 00 00 
			*o = &opentab[i];
  8010de:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8010e0:	83 ec 04             	sub    $0x4,%esp
  8010e3:	68 00 10 00 00       	push   $0x1000
  8010e8:	6a 00                	push   $0x0
  8010ea:	ff b3 6c 50 80 00    	pushl  0x80506c(%ebx)
  8010f0:	e8 a9 10 00 00       	call   80219e <memset>
			return (*o)->o_fileid;
  8010f5:	8b 06                	mov    (%esi),%eax
  8010f7:	8b 00                	mov    (%eax),%eax
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	eb 10                	jmp    80110e <openfile_alloc+0x8f>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  8010fe:	83 c3 01             	add    $0x1,%ebx
  801101:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801107:	75 83                	jne    80108c <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  801109:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80110e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801111:	5b                   	pop    %ebx
  801112:	5e                   	pop    %esi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <openfile_lookup>:

// Look up an open file for envid.
// 根据fileid从文件打开表里面查找对应的文件
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	57                   	push   %edi
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	83 ec 18             	sub    $0x18,%esp
  80111e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801121:	89 fb                	mov    %edi,%ebx
  801123:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  801129:	89 de                	mov    %ebx,%esi
  80112b:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80112e:	ff b6 6c 50 80 00    	pushl  0x80506c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801134:	81 c6 60 50 80 00    	add    $0x805060,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80113a:	e8 c8 1e 00 00       	call   803007 <pageref>
  80113f:	83 c4 10             	add    $0x10,%esp
  801142:	83 f8 01             	cmp    $0x1,%eax
  801145:	7e 17                	jle    80115e <openfile_lookup+0x49>
  801147:	c1 e3 04             	shl    $0x4,%ebx
  80114a:	3b bb 60 50 80 00    	cmp    0x805060(%ebx),%edi
  801150:	75 13                	jne    801165 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801152:	8b 45 10             	mov    0x10(%ebp),%eax
  801155:	89 30                	mov    %esi,(%eax)
	return 0;
  801157:	b8 00 00 00 00       	mov    $0x0,%eax
  80115c:	eb 0c                	jmp    80116a <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  80115e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801163:	eb 05                	jmp    80116a <openfile_lookup+0x55>
  801165:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80116a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116d:	5b                   	pop    %ebx
  80116e:	5e                   	pop    %esi
  80116f:	5f                   	pop    %edi
  801170:	5d                   	pop    %ebp
  801171:	c3                   	ret    

00801172 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	53                   	push   %ebx
  801176:	83 ec 18             	sub    $0x18,%esp
  801179:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80117c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80117f:	50                   	push   %eax
  801180:	ff 33                	pushl  (%ebx)
  801182:	ff 75 08             	pushl  0x8(%ebp)
  801185:	e8 8b ff ff ff       	call   801115 <openfile_lookup>
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 14                	js     8011a5 <serve_set_size+0x33>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  801191:	83 ec 08             	sub    $0x8,%esp
  801194:	ff 73 04             	pushl  0x4(%ebx)
  801197:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80119a:	ff 70 04             	pushl  0x4(%eax)
  80119d:	e8 f8 fa ff ff       	call   800c9a <file_set_size>
  8011a2:	83 c4 10             	add    $0x10,%esp
}
  8011a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a8:	c9                   	leave  
  8011a9:	c3                   	ret    

008011aa <serve_read>:
// the number of bytes successfully read, or < 0 on error.
// 分发函数  -- 写操作
// 把文件拿到，然后做读操作
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	53                   	push   %ebx
  8011ae:	83 ec 18             	sub    $0x18,%esp
  8011b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Lab 5: Your code here:
    struct OpenFile *o;
    int r, req_n;

    //  从打开文件表里查找相应的文件(存在o里面)
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011b7:	50                   	push   %eax
  8011b8:	ff 33                	pushl  (%ebx)
  8011ba:	ff 75 08             	pushl  0x8(%ebp)
  8011bd:	e8 53 ff ff ff       	call   801115 <openfile_lookup>
  8011c2:	83 c4 10             	add    $0x10,%esp
        return r;
  8011c5:	89 c2                	mov    %eax,%edx
	// Lab 5: Your code here:
    struct OpenFile *o;
    int r, req_n;

    //  从打开文件表里查找相应的文件(存在o里面)
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	78 39                	js     801204 <serve_read+0x5a>
        return r;
    // ？？
    req_n = req->req_n > PGSIZE ? PGSIZE : req->req_n;
    // 将文件内容读到 ret_buf
    if ((r = file_read(o->o_file, ret->ret_buf, req_n, o->o_fd->fd_offset)) < 0)
  8011cb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ce:	8b 42 0c             	mov    0xc(%edx),%eax
  8011d1:	ff 70 04             	pushl  0x4(%eax)
  8011d4:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  8011db:	b8 00 10 00 00       	mov    $0x1000,%eax
  8011e0:	0f 46 43 04          	cmovbe 0x4(%ebx),%eax
  8011e4:	50                   	push   %eax
  8011e5:	53                   	push   %ebx
  8011e6:	ff 72 04             	pushl  0x4(%edx)
  8011e9:	e8 07 fa ff ff       	call   800bf5 <file_read>
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 0d                	js     801202 <serve_read+0x58>
        return r;
    o->o_fd->fd_offset += r;
  8011f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011f8:	8b 52 0c             	mov    0xc(%edx),%edx
  8011fb:	01 42 04             	add    %eax,0x4(%edx)
    return r;
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	eb 02                	jmp    801204 <serve_read+0x5a>
        return r;
    // ？？
    req_n = req->req_n > PGSIZE ? PGSIZE : req->req_n;
    // 将文件内容读到 ret_buf
    if ((r = file_read(o->o_file, ret->ret_buf, req_n, o->o_fd->fd_offset)) < 0)
        return r;
  801202:	89 c2                	mov    %eax,%edx
    o->o_fd->fd_offset += r;
    return r;
}
  801204:	89 d0                	mov    %edx,%eax
  801206:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801209:	c9                   	leave  
  80120a:	c3                   	ret    

0080120b <serve_write>:
// bytes written, or < 0 on error.
// 分发函数  -- 读操作
// 把文件查到，然后做写操作
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  80120b:	55                   	push   %ebp
  80120c:	89 e5                	mov    %esp,%ebp
  80120e:	53                   	push   %ebx
  80120f:	83 ec 18             	sub    $0x18,%esp
  801212:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//panic("serve_write not implemented");
    struct OpenFile *o;
    int r, req_n;

    // 同样的，在文件打开表里面查找相应的文件
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	ff 33                	pushl  (%ebx)
  80121b:	ff 75 08             	pushl  0x8(%ebp)
  80121e:	e8 f2 fe ff ff       	call   801115 <openfile_lookup>
  801223:	83 c4 10             	add    $0x10,%esp
            return r;
  801226:	89 c2                	mov    %eax,%edx
	//panic("serve_write not implemented");
    struct OpenFile *o;
    int r, req_n;

    // 同样的，在文件打开表里面查找相应的文件
    if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 3c                	js     801268 <serve_write+0x5d>
            return r;
    req_n = req->req_n > PGSIZE ? PGSIZE : req->req_n;
    
    // 将 buf 里面的东西写到文件里（文件对应的物理内存）
    if ((r = file_write(o->o_file, req->req_buf, req_n, o->o_fd->fd_offset)) < 0)
  80122c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80122f:	8b 42 0c             	mov    0xc(%edx),%eax
  801232:	ff 70 04             	pushl  0x4(%eax)
  801235:	81 7b 04 00 10 00 00 	cmpl   $0x1000,0x4(%ebx)
  80123c:	b8 00 10 00 00       	mov    $0x1000,%eax
  801241:	0f 46 43 04          	cmovbe 0x4(%ebx),%eax
  801245:	50                   	push   %eax
  801246:	83 c3 08             	add    $0x8,%ebx
  801249:	53                   	push   %ebx
  80124a:	ff 72 04             	pushl  0x4(%edx)
  80124d:	e8 29 fb ff ff       	call   800d7b <file_write>
  801252:	83 c4 10             	add    $0x10,%esp
  801255:	85 c0                	test   %eax,%eax
  801257:	78 0d                	js     801266 <serve_write+0x5b>
            return r;
    o->o_fd->fd_offset += r;
  801259:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80125c:	8b 52 0c             	mov    0xc(%edx),%edx
  80125f:	01 42 04             	add    %eax,0x4(%edx)

    return r;
  801262:	89 c2                	mov    %eax,%edx
  801264:	eb 02                	jmp    801268 <serve_write+0x5d>
            return r;
    req_n = req->req_n > PGSIZE ? PGSIZE : req->req_n;
    
    // 将 buf 里面的东西写到文件里（文件对应的物理内存）
    if ((r = file_write(o->o_file, req->req_buf, req_n, o->o_fd->fd_offset)) < 0)
            return r;
  801266:	89 c2                	mov    %eax,%edx
    o->o_fd->fd_offset += r;

    return r;
}
  801268:	89 d0                	mov    %edx,%eax
  80126a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126d:	c9                   	leave  
  80126e:	c3                   	ret    

0080126f <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80126f:	55                   	push   %ebp
  801270:	89 e5                	mov    %esp,%ebp
  801272:	53                   	push   %ebx
  801273:	83 ec 18             	sub    $0x18,%esp
  801276:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801279:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	ff 33                	pushl  (%ebx)
  80127f:	ff 75 08             	pushl  0x8(%ebp)
  801282:	e8 8e fe ff ff       	call   801115 <openfile_lookup>
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 3f                	js     8012cd <serve_stat+0x5e>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  80128e:	83 ec 08             	sub    $0x8,%esp
  801291:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801294:	ff 70 04             	pushl  0x4(%eax)
  801297:	53                   	push   %ebx
  801298:	e8 bc 0d 00 00       	call   802059 <strcpy>
	ret->ret_size = o->o_file->f_size;
  80129d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a0:	8b 50 04             	mov    0x4(%eax),%edx
  8012a3:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012a9:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012af:	8b 40 04             	mov    0x4(%eax),%eax
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8012bc:	0f 94 c0             	sete   %al
  8012bf:	0f b6 c0             	movzbl %al,%eax
  8012c2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8012c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012d0:	c9                   	leave  
  8012d1:	c3                   	ret    

008012d2 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  8012d2:	55                   	push   %ebp
  8012d3:	89 e5                	mov    %esp,%ebp
  8012d5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012df:	ff 30                	pushl  (%eax)
  8012e1:	ff 75 08             	pushl  0x8(%ebp)
  8012e4:	e8 2c fe ff ff       	call   801115 <openfile_lookup>
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 16                	js     801306 <serve_flush+0x34>
		return r;
	file_flush(o->o_file);
  8012f0:	83 ec 0c             	sub    $0xc,%esp
  8012f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f6:	ff 70 04             	pushl  0x4(%eax)
  8012f9:	e8 23 fb ff ff       	call   800e21 <file_flush>
	return 0;
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801306:	c9                   	leave  
  801307:	c3                   	ret    

00801308 <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  801308:	55                   	push   %ebp
  801309:	89 e5                	mov    %esp,%ebp
  80130b:	53                   	push   %ebx
  80130c:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801312:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801315:	68 00 04 00 00       	push   $0x400
  80131a:	53                   	push   %ebx
  80131b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	e8 c4 0e 00 00       	call   8021eb <memmove>
	path[MAXPATHLEN-1] = 0;
  801327:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80132b:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801331:	89 04 24             	mov    %eax,(%esp)
  801334:	e8 46 fd ff ff       	call   80107f <openfile_alloc>
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	0f 88 f0 00 00 00    	js     801434 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801344:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80134b:	74 33                	je     801380 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801356:	50                   	push   %eax
  801357:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  80135d:	50                   	push   %eax
  80135e:	e8 5b fb ff ff       	call   800ebe <file_create>
  801363:	83 c4 10             	add    $0x10,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	79 37                	jns    8013a1 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80136a:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  801371:	0f 85 bd 00 00 00    	jne    801434 <serve_open+0x12c>
  801377:	83 f8 f3             	cmp    $0xfffffff3,%eax
  80137a:	0f 85 b4 00 00 00    	jne    801434 <serve_open+0x12c>
				cprintf("file_create failed: %e", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  801380:	83 ec 08             	sub    $0x8,%esp
  801383:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801390:	50                   	push   %eax
  801391:	e8 45 f8 ff ff       	call   800bdb <file_open>
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	85 c0                	test   %eax,%eax
  80139b:	0f 88 93 00 00 00    	js     801434 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8013a1:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8013a8:	74 17                	je     8013c1 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8013aa:	83 ec 08             	sub    $0x8,%esp
  8013ad:	6a 00                	push   $0x0
  8013af:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8013b5:	e8 e0 f8 ff ff       	call   800c9a <file_set_size>
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	78 73                	js     801434 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %e", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013ca:	50                   	push   %eax
  8013cb:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013d1:	50                   	push   %eax
  8013d2:	e8 04 f8 ff ff       	call   800bdb <file_open>
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	85 c0                	test   %eax,%eax
  8013dc:	78 56                	js     801434 <serve_open+0x12c>
			cprintf("file_open failed: %e", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  8013de:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  8013e4:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  8013ea:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  8013ed:	8b 50 0c             	mov    0xc(%eax),%edx
  8013f0:	8b 08                	mov    (%eax),%ecx
  8013f2:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  8013f5:	8b 48 0c             	mov    0xc(%eax),%ecx
  8013f8:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  8013fe:	83 e2 03             	and    $0x3,%edx
  801401:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801404:	8b 40 0c             	mov    0xc(%eax),%eax
  801407:	8b 15 64 90 80 00    	mov    0x809064,%edx
  80140d:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  80140f:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801415:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80141b:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  80141e:	8b 50 0c             	mov    0xc(%eax),%edx
  801421:	8b 45 10             	mov    0x10(%ebp),%eax
  801424:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  801426:	8b 45 14             	mov    0x14(%ebp),%eax
  801429:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  80142f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801434:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801437:	c9                   	leave  
  801438:	c3                   	ret    

00801439 <serve>:
	[FSREQ_SYNC] =		serve_sync
};

void
serve(void)
{
  801439:	55                   	push   %ebp
  80143a:	89 e5                	mov    %esp,%ebp
  80143c:	56                   	push   %esi
  80143d:	53                   	push   %ebx
  80143e:	83 ec 10             	sub    $0x10,%esp
		perm = 0;
		// 客户端将文件操作操作的类型作为value发送到文件系统服务进程
		// 进程通信包括值和页映射，其它进程会将操作类型放在value里
		// 将请求相关的数据放在 数据页 里面
		// 文件系统进程会将相关内容放到  数据页
 		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801441:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801444:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  801447:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		// 客户端将文件操作操作的类型作为value发送到文件系统服务进程
		// 进程通信包括值和页映射，其它进程会将操作类型放在value里
		// 将请求相关的数据放在 数据页 里面
		// 文件系统进程会将相关内容放到  数据页
 		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  80144e:	83 ec 04             	sub    $0x4,%esp
  801451:	53                   	push   %ebx
  801452:	ff 35 44 50 80 00    	pushl  0x805044
  801458:	56                   	push   %esi
  801459:	e8 89 12 00 00       	call   8026e7 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801465:	75 15                	jne    80147c <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	ff 75 f4             	pushl  -0xc(%ebp)
  80146d:	68 d0 3a 80 00       	push   $0x803ad0
  801472:	e8 de 05 00 00       	call   801a55 <cprintf>
				whom);
			continue; // just leave it hanging...
  801477:	83 c4 10             	add    $0x10,%esp
  80147a:	eb cb                	jmp    801447 <serve+0xe>
		}

		pg = NULL;
  80147c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		
		// 根据操作类型进行分发
		if (req == FSREQ_OPEN) {
  801483:	83 f8 01             	cmp    $0x1,%eax
  801486:	75 18                	jne    8014a0 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  801488:	53                   	push   %ebx
  801489:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80148c:	50                   	push   %eax
  80148d:	ff 35 44 50 80 00    	pushl  0x805044
  801493:	ff 75 f4             	pushl  -0xc(%ebp)
  801496:	e8 6d fe ff ff       	call   801308 <serve_open>
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	eb 3c                	jmp    8014dc <serve+0xa3>
		} else if (req < ARRAY_SIZE(handlers) && handlers[req]) {
  8014a0:	83 f8 08             	cmp    $0x8,%eax
  8014a3:	77 1e                	ja     8014c3 <serve+0x8a>
  8014a5:	8b 14 85 20 50 80 00 	mov    0x805020(,%eax,4),%edx
  8014ac:	85 d2                	test   %edx,%edx
  8014ae:	74 13                	je     8014c3 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8014b0:	83 ec 08             	sub    $0x8,%esp
  8014b3:	ff 35 44 50 80 00    	pushl  0x805044
  8014b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8014bc:	ff d2                	call   *%edx
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	eb 19                	jmp    8014dc <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8014c3:	83 ec 04             	sub    $0x4,%esp
  8014c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c9:	50                   	push   %eax
  8014ca:	68 00 3b 80 00       	push   $0x803b00
  8014cf:	e8 81 05 00 00       	call   801a55 <cprintf>
  8014d4:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  8014d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  8014dc:	ff 75 f0             	pushl  -0x10(%ebp)
  8014df:	ff 75 ec             	pushl  -0x14(%ebp)
  8014e2:	50                   	push   %eax
  8014e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8014e6:	e8 7e 12 00 00       	call   802769 <ipc_send>
		sys_page_unmap(0, fsreq);
  8014eb:	83 c4 08             	add    $0x8,%esp
  8014ee:	ff 35 44 50 80 00    	pushl  0x805044
  8014f4:	6a 00                	push   $0x0
  8014f6:	e8 e6 0f 00 00       	call   8024e1 <sys_page_unmap>
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	e9 44 ff ff ff       	jmp    801447 <serve+0xe>

00801503 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  801509:	c7 05 60 90 80 00 23 	movl   $0x803b23,0x809060
  801510:	3b 80 00 
	cprintf("FS is running\n");
  801513:	68 26 3b 80 00       	push   $0x803b26
  801518:	e8 38 05 00 00       	call   801a55 <cprintf>
}

static inline void
outw(int port, uint16_t data)
{
	asm volatile("outw %0,%w1" : : "a" (data), "d" (port));
  80151d:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801522:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  801527:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  801529:	c7 04 24 35 3b 80 00 	movl   $0x803b35,(%esp)
  801530:	e8 20 05 00 00       	call   801a55 <cprintf>

	serve_init();
  801535:	e8 19 fb ff ff       	call   801053 <serve_init>
	fs_init();
  80153a:	e8 c4 f3 ff ff       	call   800903 <fs_init>
        fs_test();
  80153f:	e8 05 00 00 00       	call   801549 <fs_test>
	serve();
  801544:	e8 f0 fe ff ff       	call   801439 <serve>

00801549 <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	53                   	push   %ebx
  80154d:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801550:	6a 07                	push   $0x7
  801552:	68 00 10 00 00       	push   $0x1000
  801557:	6a 00                	push   $0x0
  801559:	e8 fe 0e 00 00       	call   80245c <sys_page_alloc>
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	85 c0                	test   %eax,%eax
  801563:	79 12                	jns    801577 <fs_test+0x2e>
		panic("sys_page_alloc: %e", r);
  801565:	50                   	push   %eax
  801566:	68 44 3b 80 00       	push   $0x803b44
  80156b:	6a 12                	push   $0x12
  80156d:	68 57 3b 80 00       	push   $0x803b57
  801572:	e8 05 04 00 00       	call   80197c <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  801577:	83 ec 04             	sub    $0x4,%esp
  80157a:	68 00 10 00 00       	push   $0x1000
  80157f:	ff 35 04 a0 80 00    	pushl  0x80a004
  801585:	68 00 10 00 00       	push   $0x1000
  80158a:	e8 5c 0c 00 00       	call   8021eb <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  80158f:	e8 b3 f1 ff ff       	call   800747 <alloc_block>
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	79 12                	jns    8015ad <fs_test+0x64>
		panic("alloc_block: %e", r);
  80159b:	50                   	push   %eax
  80159c:	68 61 3b 80 00       	push   $0x803b61
  8015a1:	6a 17                	push   $0x17
  8015a3:	68 57 3b 80 00       	push   $0x803b57
  8015a8:	e8 cf 03 00 00       	call   80197c <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015ad:	8d 50 1f             	lea    0x1f(%eax),%edx
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	0f 49 d0             	cmovns %eax,%edx
  8015b5:	c1 fa 05             	sar    $0x5,%edx
  8015b8:	89 c3                	mov    %eax,%ebx
  8015ba:	c1 fb 1f             	sar    $0x1f,%ebx
  8015bd:	c1 eb 1b             	shr    $0x1b,%ebx
  8015c0:	8d 0c 18             	lea    (%eax,%ebx,1),%ecx
  8015c3:	83 e1 1f             	and    $0x1f,%ecx
  8015c6:	29 d9                	sub    %ebx,%ecx
  8015c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015cd:	d3 e0                	shl    %cl,%eax
  8015cf:	85 04 95 00 10 00 00 	test   %eax,0x1000(,%edx,4)
  8015d6:	75 16                	jne    8015ee <fs_test+0xa5>
  8015d8:	68 71 3b 80 00       	push   $0x803b71
  8015dd:	68 fd 37 80 00       	push   $0x8037fd
  8015e2:	6a 19                	push   $0x19
  8015e4:	68 57 3b 80 00       	push   $0x803b57
  8015e9:	e8 8e 03 00 00       	call   80197c <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  8015ee:	8b 0d 04 a0 80 00    	mov    0x80a004,%ecx
  8015f4:	85 04 91             	test   %eax,(%ecx,%edx,4)
  8015f7:	74 16                	je     80160f <fs_test+0xc6>
  8015f9:	68 ec 3c 80 00       	push   $0x803cec
  8015fe:	68 fd 37 80 00       	push   $0x8037fd
  801603:	6a 1b                	push   $0x1b
  801605:	68 57 3b 80 00       	push   $0x803b57
  80160a:	e8 6d 03 00 00       	call   80197c <_panic>
	cprintf("alloc_block is good\n");
  80160f:	83 ec 0c             	sub    $0xc,%esp
  801612:	68 8c 3b 80 00       	push   $0x803b8c
  801617:	e8 39 04 00 00       	call   801a55 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  80161c:	83 c4 08             	add    $0x8,%esp
  80161f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	68 a1 3b 80 00       	push   $0x803ba1
  801628:	e8 ae f5 ff ff       	call   800bdb <file_open>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801633:	74 1b                	je     801650 <fs_test+0x107>
  801635:	89 c2                	mov    %eax,%edx
  801637:	c1 ea 1f             	shr    $0x1f,%edx
  80163a:	84 d2                	test   %dl,%dl
  80163c:	74 12                	je     801650 <fs_test+0x107>
		panic("file_open /not-found: %e", r);
  80163e:	50                   	push   %eax
  80163f:	68 ac 3b 80 00       	push   $0x803bac
  801644:	6a 1f                	push   $0x1f
  801646:	68 57 3b 80 00       	push   $0x803b57
  80164b:	e8 2c 03 00 00       	call   80197c <_panic>
	else if (r == 0)
  801650:	85 c0                	test   %eax,%eax
  801652:	75 14                	jne    801668 <fs_test+0x11f>
		panic("file_open /not-found succeeded!");
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	68 0c 3d 80 00       	push   $0x803d0c
  80165c:	6a 21                	push   $0x21
  80165e:	68 57 3b 80 00       	push   $0x803b57
  801663:	e8 14 03 00 00       	call   80197c <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801668:	83 ec 08             	sub    $0x8,%esp
  80166b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	68 c5 3b 80 00       	push   $0x803bc5
  801674:	e8 62 f5 ff ff       	call   800bdb <file_open>
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	79 12                	jns    801692 <fs_test+0x149>
		panic("file_open /newmotd: %e", r);
  801680:	50                   	push   %eax
  801681:	68 ce 3b 80 00       	push   $0x803bce
  801686:	6a 23                	push   $0x23
  801688:	68 57 3b 80 00       	push   $0x803b57
  80168d:	e8 ea 02 00 00       	call   80197c <_panic>
	cprintf("file_open is good\n");
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	68 e5 3b 80 00       	push   $0x803be5
  80169a:	e8 b6 03 00 00       	call   801a55 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  80169f:	83 c4 0c             	add    $0xc,%esp
  8016a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a5:	50                   	push   %eax
  8016a6:	6a 00                	push   $0x0
  8016a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ab:	e8 b2 f2 ff ff       	call   800962 <file_get_block>
  8016b0:	83 c4 10             	add    $0x10,%esp
  8016b3:	85 c0                	test   %eax,%eax
  8016b5:	79 12                	jns    8016c9 <fs_test+0x180>
		panic("file_get_block: %e", r);
  8016b7:	50                   	push   %eax
  8016b8:	68 f8 3b 80 00       	push   $0x803bf8
  8016bd:	6a 27                	push   $0x27
  8016bf:	68 57 3b 80 00       	push   $0x803b57
  8016c4:	e8 b3 02 00 00       	call   80197c <_panic>
	if (strcmp(blk, msg) != 0)
  8016c9:	83 ec 08             	sub    $0x8,%esp
  8016cc:	68 2c 3d 80 00       	push   $0x803d2c
  8016d1:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d4:	e8 2a 0a 00 00       	call   802103 <strcmp>
  8016d9:	83 c4 10             	add    $0x10,%esp
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	74 14                	je     8016f4 <fs_test+0x1ab>
		panic("file_get_block returned wrong data");
  8016e0:	83 ec 04             	sub    $0x4,%esp
  8016e3:	68 54 3d 80 00       	push   $0x803d54
  8016e8:	6a 29                	push   $0x29
  8016ea:	68 57 3b 80 00       	push   $0x803b57
  8016ef:	e8 88 02 00 00       	call   80197c <_panic>
	cprintf("file_get_block is good\n");
  8016f4:	83 ec 0c             	sub    $0xc,%esp
  8016f7:	68 0b 3c 80 00       	push   $0x803c0b
  8016fc:	e8 54 03 00 00       	call   801a55 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  801701:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801704:	0f b6 10             	movzbl (%eax),%edx
  801707:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801709:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80170c:	c1 e8 0c             	shr    $0xc,%eax
  80170f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801716:	83 c4 10             	add    $0x10,%esp
  801719:	a8 40                	test   $0x40,%al
  80171b:	75 16                	jne    801733 <fs_test+0x1ea>
  80171d:	68 24 3c 80 00       	push   $0x803c24
  801722:	68 fd 37 80 00       	push   $0x8037fd
  801727:	6a 2d                	push   $0x2d
  801729:	68 57 3b 80 00       	push   $0x803b57
  80172e:	e8 49 02 00 00       	call   80197c <_panic>
	file_flush(f);
  801733:	83 ec 0c             	sub    $0xc,%esp
  801736:	ff 75 f4             	pushl  -0xc(%ebp)
  801739:	e8 e3 f6 ff ff       	call   800e21 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  80173e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801741:	c1 e8 0c             	shr    $0xc,%eax
  801744:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80174b:	83 c4 10             	add    $0x10,%esp
  80174e:	a8 40                	test   $0x40,%al
  801750:	74 16                	je     801768 <fs_test+0x21f>
  801752:	68 23 3c 80 00       	push   $0x803c23
  801757:	68 fd 37 80 00       	push   $0x8037fd
  80175c:	6a 2f                	push   $0x2f
  80175e:	68 57 3b 80 00       	push   $0x803b57
  801763:	e8 14 02 00 00       	call   80197c <_panic>
	cprintf("file_flush is good\n");
  801768:	83 ec 0c             	sub    $0xc,%esp
  80176b:	68 3f 3c 80 00       	push   $0x803c3f
  801770:	e8 e0 02 00 00       	call   801a55 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  801775:	83 c4 08             	add    $0x8,%esp
  801778:	6a 00                	push   $0x0
  80177a:	ff 75 f4             	pushl  -0xc(%ebp)
  80177d:	e8 18 f5 ff ff       	call   800c9a <file_set_size>
  801782:	83 c4 10             	add    $0x10,%esp
  801785:	85 c0                	test   %eax,%eax
  801787:	79 12                	jns    80179b <fs_test+0x252>
		panic("file_set_size: %e", r);
  801789:	50                   	push   %eax
  80178a:	68 53 3c 80 00       	push   $0x803c53
  80178f:	6a 33                	push   $0x33
  801791:	68 57 3b 80 00       	push   $0x803b57
  801796:	e8 e1 01 00 00       	call   80197c <_panic>
	assert(f->f_direct[0] == 0);
  80179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179e:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8017a5:	74 16                	je     8017bd <fs_test+0x274>
  8017a7:	68 65 3c 80 00       	push   $0x803c65
  8017ac:	68 fd 37 80 00       	push   $0x8037fd
  8017b1:	6a 34                	push   $0x34
  8017b3:	68 57 3b 80 00       	push   $0x803b57
  8017b8:	e8 bf 01 00 00       	call   80197c <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017bd:	c1 e8 0c             	shr    $0xc,%eax
  8017c0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017c7:	a8 40                	test   $0x40,%al
  8017c9:	74 16                	je     8017e1 <fs_test+0x298>
  8017cb:	68 79 3c 80 00       	push   $0x803c79
  8017d0:	68 fd 37 80 00       	push   $0x8037fd
  8017d5:	6a 35                	push   $0x35
  8017d7:	68 57 3b 80 00       	push   $0x803b57
  8017dc:	e8 9b 01 00 00       	call   80197c <_panic>
	cprintf("file_truncate is good\n");
  8017e1:	83 ec 0c             	sub    $0xc,%esp
  8017e4:	68 93 3c 80 00       	push   $0x803c93
  8017e9:	e8 67 02 00 00       	call   801a55 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  8017ee:	c7 04 24 2c 3d 80 00 	movl   $0x803d2c,(%esp)
  8017f5:	e8 26 08 00 00       	call   802020 <strlen>
  8017fa:	83 c4 08             	add    $0x8,%esp
  8017fd:	50                   	push   %eax
  8017fe:	ff 75 f4             	pushl  -0xc(%ebp)
  801801:	e8 94 f4 ff ff       	call   800c9a <file_set_size>
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	85 c0                	test   %eax,%eax
  80180b:	79 12                	jns    80181f <fs_test+0x2d6>
		panic("file_set_size 2: %e", r);
  80180d:	50                   	push   %eax
  80180e:	68 aa 3c 80 00       	push   $0x803caa
  801813:	6a 39                	push   $0x39
  801815:	68 57 3b 80 00       	push   $0x803b57
  80181a:	e8 5d 01 00 00       	call   80197c <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80181f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801822:	89 c2                	mov    %eax,%edx
  801824:	c1 ea 0c             	shr    $0xc,%edx
  801827:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80182e:	f6 c2 40             	test   $0x40,%dl
  801831:	74 16                	je     801849 <fs_test+0x300>
  801833:	68 79 3c 80 00       	push   $0x803c79
  801838:	68 fd 37 80 00       	push   $0x8037fd
  80183d:	6a 3a                	push   $0x3a
  80183f:	68 57 3b 80 00       	push   $0x803b57
  801844:	e8 33 01 00 00       	call   80197c <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801849:	83 ec 04             	sub    $0x4,%esp
  80184c:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80184f:	52                   	push   %edx
  801850:	6a 00                	push   $0x0
  801852:	50                   	push   %eax
  801853:	e8 0a f1 ff ff       	call   800962 <file_get_block>
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	85 c0                	test   %eax,%eax
  80185d:	79 12                	jns    801871 <fs_test+0x328>
		panic("file_get_block 2: %e", r);
  80185f:	50                   	push   %eax
  801860:	68 be 3c 80 00       	push   $0x803cbe
  801865:	6a 3c                	push   $0x3c
  801867:	68 57 3b 80 00       	push   $0x803b57
  80186c:	e8 0b 01 00 00       	call   80197c <_panic>
	strcpy(blk, msg);
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	68 2c 3d 80 00       	push   $0x803d2c
  801879:	ff 75 f0             	pushl  -0x10(%ebp)
  80187c:	e8 d8 07 00 00       	call   802059 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801881:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801884:	c1 e8 0c             	shr    $0xc,%eax
  801887:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	a8 40                	test   $0x40,%al
  801893:	75 16                	jne    8018ab <fs_test+0x362>
  801895:	68 24 3c 80 00       	push   $0x803c24
  80189a:	68 fd 37 80 00       	push   $0x8037fd
  80189f:	6a 3e                	push   $0x3e
  8018a1:	68 57 3b 80 00       	push   $0x803b57
  8018a6:	e8 d1 00 00 00       	call   80197c <_panic>
	file_flush(f);
  8018ab:	83 ec 0c             	sub    $0xc,%esp
  8018ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8018b1:	e8 6b f5 ff ff       	call   800e21 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b9:	c1 e8 0c             	shr    $0xc,%eax
  8018bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	a8 40                	test   $0x40,%al
  8018c8:	74 16                	je     8018e0 <fs_test+0x397>
  8018ca:	68 23 3c 80 00       	push   $0x803c23
  8018cf:	68 fd 37 80 00       	push   $0x8037fd
  8018d4:	6a 40                	push   $0x40
  8018d6:	68 57 3b 80 00       	push   $0x803b57
  8018db:	e8 9c 00 00 00       	call   80197c <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8018e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e3:	c1 e8 0c             	shr    $0xc,%eax
  8018e6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ed:	a8 40                	test   $0x40,%al
  8018ef:	74 16                	je     801907 <fs_test+0x3be>
  8018f1:	68 79 3c 80 00       	push   $0x803c79
  8018f6:	68 fd 37 80 00       	push   $0x8037fd
  8018fb:	6a 41                	push   $0x41
  8018fd:	68 57 3b 80 00       	push   $0x803b57
  801902:	e8 75 00 00 00       	call   80197c <_panic>
	cprintf("file rewrite is good\n");
  801907:	83 ec 0c             	sub    $0xc,%esp
  80190a:	68 d3 3c 80 00       	push   $0x803cd3
  80190f:	e8 41 01 00 00       	call   801a55 <cprintf>
}
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801924:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  801927:	e8 f2 0a 00 00       	call   80241e <sys_getenvid>
  80192c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801931:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801934:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801939:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80193e:	85 db                	test   %ebx,%ebx
  801940:	7e 07                	jle    801949 <libmain+0x2d>
		binaryname = argv[0];
  801942:	8b 06                	mov    (%esi),%eax
  801944:	a3 60 90 80 00       	mov    %eax,0x809060

	// call user main routine
	umain(argc, argv);
  801949:	83 ec 08             	sub    $0x8,%esp
  80194c:	56                   	push   %esi
  80194d:	53                   	push   %ebx
  80194e:	e8 b0 fb ff ff       	call   801503 <umain>

	// exit gracefully
	exit();
  801953:	e8 0a 00 00 00       	call   801962 <exit>
}
  801958:	83 c4 10             	add    $0x10,%esp
  80195b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5e                   	pop    %esi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801968:	e8 54 10 00 00       	call   8029c1 <close_all>
	sys_env_destroy(0);
  80196d:	83 ec 0c             	sub    $0xc,%esp
  801970:	6a 00                	push   $0x0
  801972:	e8 66 0a 00 00       	call   8023dd <sys_env_destroy>
}
  801977:	83 c4 10             	add    $0x10,%esp
  80197a:	c9                   	leave  
  80197b:	c3                   	ret    

0080197c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	56                   	push   %esi
  801980:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801981:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801984:	8b 35 60 90 80 00    	mov    0x809060,%esi
  80198a:	e8 8f 0a 00 00       	call   80241e <sys_getenvid>
  80198f:	83 ec 0c             	sub    $0xc,%esp
  801992:	ff 75 0c             	pushl  0xc(%ebp)
  801995:	ff 75 08             	pushl  0x8(%ebp)
  801998:	56                   	push   %esi
  801999:	50                   	push   %eax
  80199a:	68 84 3d 80 00       	push   $0x803d84
  80199f:	e8 b1 00 00 00       	call   801a55 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019a4:	83 c4 18             	add    $0x18,%esp
  8019a7:	53                   	push   %ebx
  8019a8:	ff 75 10             	pushl  0x10(%ebp)
  8019ab:	e8 54 00 00 00       	call   801a04 <vcprintf>
	cprintf("\n");
  8019b0:	c7 04 24 93 39 80 00 	movl   $0x803993,(%esp)
  8019b7:	e8 99 00 00 00       	call   801a55 <cprintf>
  8019bc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019bf:	cc                   	int3   
  8019c0:	eb fd                	jmp    8019bf <_panic+0x43>

008019c2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019c2:	55                   	push   %ebp
  8019c3:	89 e5                	mov    %esp,%ebp
  8019c5:	53                   	push   %ebx
  8019c6:	83 ec 04             	sub    $0x4,%esp
  8019c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019cc:	8b 13                	mov    (%ebx),%edx
  8019ce:	8d 42 01             	lea    0x1(%edx),%eax
  8019d1:	89 03                	mov    %eax,(%ebx)
  8019d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019d6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8019da:	3d ff 00 00 00       	cmp    $0xff,%eax
  8019df:	75 1a                	jne    8019fb <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8019e1:	83 ec 08             	sub    $0x8,%esp
  8019e4:	68 ff 00 00 00       	push   $0xff
  8019e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8019ec:	50                   	push   %eax
  8019ed:	e8 ae 09 00 00       	call   8023a0 <sys_cputs>
		b->idx = 0;
  8019f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8019f8:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8019fb:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8019ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a02:	c9                   	leave  
  801a03:	c3                   	ret    

00801a04 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a04:	55                   	push   %ebp
  801a05:	89 e5                	mov    %esp,%ebp
  801a07:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a0d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a14:	00 00 00 
	b.cnt = 0;
  801a17:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a1e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	ff 75 08             	pushl  0x8(%ebp)
  801a27:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a2d:	50                   	push   %eax
  801a2e:	68 c2 19 80 00       	push   $0x8019c2
  801a33:	e8 1a 01 00 00       	call   801b52 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a38:	83 c4 08             	add    $0x8,%esp
  801a3b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a41:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a47:	50                   	push   %eax
  801a48:	e8 53 09 00 00       	call   8023a0 <sys_cputs>

	return b.cnt;
}
  801a4d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a5b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a5e:	50                   	push   %eax
  801a5f:	ff 75 08             	pushl  0x8(%ebp)
  801a62:	e8 9d ff ff ff       	call   801a04 <vcprintf>
	va_end(ap);

	return cnt;
}
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	57                   	push   %edi
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 1c             	sub    $0x1c,%esp
  801a72:	89 c7                	mov    %eax,%edi
  801a74:	89 d6                	mov    %edx,%esi
  801a76:	8b 45 08             	mov    0x8(%ebp),%eax
  801a79:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801a7f:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801a82:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801a85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a8a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801a8d:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801a90:	39 d3                	cmp    %edx,%ebx
  801a92:	72 05                	jb     801a99 <printnum+0x30>
  801a94:	39 45 10             	cmp    %eax,0x10(%ebp)
  801a97:	77 45                	ja     801ade <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801a99:	83 ec 0c             	sub    $0xc,%esp
  801a9c:	ff 75 18             	pushl  0x18(%ebp)
  801a9f:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801aa5:	53                   	push   %ebx
  801aa6:	ff 75 10             	pushl  0x10(%ebp)
  801aa9:	83 ec 08             	sub    $0x8,%esp
  801aac:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aaf:	ff 75 e0             	pushl  -0x20(%ebp)
  801ab2:	ff 75 dc             	pushl  -0x24(%ebp)
  801ab5:	ff 75 d8             	pushl  -0x28(%ebp)
  801ab8:	e8 73 1a 00 00       	call   803530 <__udivdi3>
  801abd:	83 c4 18             	add    $0x18,%esp
  801ac0:	52                   	push   %edx
  801ac1:	50                   	push   %eax
  801ac2:	89 f2                	mov    %esi,%edx
  801ac4:	89 f8                	mov    %edi,%eax
  801ac6:	e8 9e ff ff ff       	call   801a69 <printnum>
  801acb:	83 c4 20             	add    $0x20,%esp
  801ace:	eb 18                	jmp    801ae8 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801ad0:	83 ec 08             	sub    $0x8,%esp
  801ad3:	56                   	push   %esi
  801ad4:	ff 75 18             	pushl  0x18(%ebp)
  801ad7:	ff d7                	call   *%edi
  801ad9:	83 c4 10             	add    $0x10,%esp
  801adc:	eb 03                	jmp    801ae1 <printnum+0x78>
  801ade:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801ae1:	83 eb 01             	sub    $0x1,%ebx
  801ae4:	85 db                	test   %ebx,%ebx
  801ae6:	7f e8                	jg     801ad0 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801ae8:	83 ec 08             	sub    $0x8,%esp
  801aeb:	56                   	push   %esi
  801aec:	83 ec 04             	sub    $0x4,%esp
  801aef:	ff 75 e4             	pushl  -0x1c(%ebp)
  801af2:	ff 75 e0             	pushl  -0x20(%ebp)
  801af5:	ff 75 dc             	pushl  -0x24(%ebp)
  801af8:	ff 75 d8             	pushl  -0x28(%ebp)
  801afb:	e8 60 1b 00 00       	call   803660 <__umoddi3>
  801b00:	83 c4 14             	add    $0x14,%esp
  801b03:	0f be 80 a7 3d 80 00 	movsbl 0x803da7(%eax),%eax
  801b0a:	50                   	push   %eax
  801b0b:	ff d7                	call   *%edi
}
  801b0d:	83 c4 10             	add    $0x10,%esp
  801b10:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5f                   	pop    %edi
  801b16:	5d                   	pop    %ebp
  801b17:	c3                   	ret    

00801b18 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b18:	55                   	push   %ebp
  801b19:	89 e5                	mov    %esp,%ebp
  801b1b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b1e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b22:	8b 10                	mov    (%eax),%edx
  801b24:	3b 50 04             	cmp    0x4(%eax),%edx
  801b27:	73 0a                	jae    801b33 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b29:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b2c:	89 08                	mov    %ecx,(%eax)
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	88 02                	mov    %al,(%edx)
}
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    

00801b35 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b3b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b3e:	50                   	push   %eax
  801b3f:	ff 75 10             	pushl  0x10(%ebp)
  801b42:	ff 75 0c             	pushl  0xc(%ebp)
  801b45:	ff 75 08             	pushl  0x8(%ebp)
  801b48:	e8 05 00 00 00       	call   801b52 <vprintfmt>
	va_end(ap);
}
  801b4d:	83 c4 10             	add    $0x10,%esp
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	57                   	push   %edi
  801b56:	56                   	push   %esi
  801b57:	53                   	push   %ebx
  801b58:	83 ec 2c             	sub    $0x2c,%esp
  801b5b:	8b 75 08             	mov    0x8(%ebp),%esi
  801b5e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b61:	8b 7d 10             	mov    0x10(%ebp),%edi
  801b64:	eb 12                	jmp    801b78 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801b66:	85 c0                	test   %eax,%eax
  801b68:	0f 84 42 04 00 00    	je     801fb0 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  801b6e:	83 ec 08             	sub    $0x8,%esp
  801b71:	53                   	push   %ebx
  801b72:	50                   	push   %eax
  801b73:	ff d6                	call   *%esi
  801b75:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801b78:	83 c7 01             	add    $0x1,%edi
  801b7b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801b7f:	83 f8 25             	cmp    $0x25,%eax
  801b82:	75 e2                	jne    801b66 <vprintfmt+0x14>
  801b84:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801b88:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801b8f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801b96:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801b9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ba2:	eb 07                	jmp    801bab <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ba4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801ba7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bab:	8d 47 01             	lea    0x1(%edi),%eax
  801bae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801bb1:	0f b6 07             	movzbl (%edi),%eax
  801bb4:	0f b6 d0             	movzbl %al,%edx
  801bb7:	83 e8 23             	sub    $0x23,%eax
  801bba:	3c 55                	cmp    $0x55,%al
  801bbc:	0f 87 d3 03 00 00    	ja     801f95 <vprintfmt+0x443>
  801bc2:	0f b6 c0             	movzbl %al,%eax
  801bc5:	ff 24 85 e0 3e 80 00 	jmp    *0x803ee0(,%eax,4)
  801bcc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801bcf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801bd3:	eb d6                	jmp    801bab <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801bd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801bd8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bdd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801be0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801be3:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801be7:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801bea:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801bed:	83 f9 09             	cmp    $0x9,%ecx
  801bf0:	77 3f                	ja     801c31 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801bf2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801bf5:	eb e9                	jmp    801be0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801bf7:	8b 45 14             	mov    0x14(%ebp),%eax
  801bfa:	8b 00                	mov    (%eax),%eax
  801bfc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801bff:	8b 45 14             	mov    0x14(%ebp),%eax
  801c02:	8d 40 04             	lea    0x4(%eax),%eax
  801c05:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c0b:	eb 2a                	jmp    801c37 <vprintfmt+0xe5>
  801c0d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c10:	85 c0                	test   %eax,%eax
  801c12:	ba 00 00 00 00       	mov    $0x0,%edx
  801c17:	0f 49 d0             	cmovns %eax,%edx
  801c1a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c1d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c20:	eb 89                	jmp    801bab <vprintfmt+0x59>
  801c22:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c25:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c2c:	e9 7a ff ff ff       	jmp    801bab <vprintfmt+0x59>
  801c31:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801c34:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c37:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c3b:	0f 89 6a ff ff ff    	jns    801bab <vprintfmt+0x59>
				width = precision, precision = -1;
  801c41:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c44:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801c47:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801c4e:	e9 58 ff ff ff       	jmp    801bab <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801c53:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c56:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801c59:	e9 4d ff ff ff       	jmp    801bab <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c5e:	8b 45 14             	mov    0x14(%ebp),%eax
  801c61:	8d 78 04             	lea    0x4(%eax),%edi
  801c64:	83 ec 08             	sub    $0x8,%esp
  801c67:	53                   	push   %ebx
  801c68:	ff 30                	pushl  (%eax)
  801c6a:	ff d6                	call   *%esi
			break;
  801c6c:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801c6f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801c75:	e9 fe fe ff ff       	jmp    801b78 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801c7a:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7d:	8d 78 04             	lea    0x4(%eax),%edi
  801c80:	8b 00                	mov    (%eax),%eax
  801c82:	99                   	cltd   
  801c83:	31 d0                	xor    %edx,%eax
  801c85:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801c87:	83 f8 0f             	cmp    $0xf,%eax
  801c8a:	7f 0b                	jg     801c97 <vprintfmt+0x145>
  801c8c:	8b 14 85 40 40 80 00 	mov    0x804040(,%eax,4),%edx
  801c93:	85 d2                	test   %edx,%edx
  801c95:	75 1b                	jne    801cb2 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  801c97:	50                   	push   %eax
  801c98:	68 bf 3d 80 00       	push   $0x803dbf
  801c9d:	53                   	push   %ebx
  801c9e:	56                   	push   %esi
  801c9f:	e8 91 fe ff ff       	call   801b35 <printfmt>
  801ca4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801ca7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801caa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801cad:	e9 c6 fe ff ff       	jmp    801b78 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801cb2:	52                   	push   %edx
  801cb3:	68 0f 38 80 00       	push   $0x80380f
  801cb8:	53                   	push   %ebx
  801cb9:	56                   	push   %esi
  801cba:	e8 76 fe ff ff       	call   801b35 <printfmt>
  801cbf:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  801cc2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801cc5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801cc8:	e9 ab fe ff ff       	jmp    801b78 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801ccd:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd0:	83 c0 04             	add    $0x4,%eax
  801cd3:	89 45 cc             	mov    %eax,-0x34(%ebp)
  801cd6:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801cdb:	85 ff                	test   %edi,%edi
  801cdd:	b8 b8 3d 80 00       	mov    $0x803db8,%eax
  801ce2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  801ce5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801ce9:	0f 8e 94 00 00 00    	jle    801d83 <vprintfmt+0x231>
  801cef:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801cf3:	0f 84 98 00 00 00    	je     801d91 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801cf9:	83 ec 08             	sub    $0x8,%esp
  801cfc:	ff 75 d0             	pushl  -0x30(%ebp)
  801cff:	57                   	push   %edi
  801d00:	e8 33 03 00 00       	call   802038 <strnlen>
  801d05:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801d08:	29 c1                	sub    %eax,%ecx
  801d0a:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801d0d:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d10:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d14:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d17:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d1a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d1c:	eb 0f                	jmp    801d2d <vprintfmt+0x1db>
					putch(padc, putdat);
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	53                   	push   %ebx
  801d22:	ff 75 e0             	pushl  -0x20(%ebp)
  801d25:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d27:	83 ef 01             	sub    $0x1,%edi
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	85 ff                	test   %edi,%edi
  801d2f:	7f ed                	jg     801d1e <vprintfmt+0x1cc>
  801d31:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d34:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  801d37:	85 c9                	test   %ecx,%ecx
  801d39:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3e:	0f 49 c1             	cmovns %ecx,%eax
  801d41:	29 c1                	sub    %eax,%ecx
  801d43:	89 75 08             	mov    %esi,0x8(%ebp)
  801d46:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d49:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d4c:	89 cb                	mov    %ecx,%ebx
  801d4e:	eb 4d                	jmp    801d9d <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801d50:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801d54:	74 1b                	je     801d71 <vprintfmt+0x21f>
  801d56:	0f be c0             	movsbl %al,%eax
  801d59:	83 e8 20             	sub    $0x20,%eax
  801d5c:	83 f8 5e             	cmp    $0x5e,%eax
  801d5f:	76 10                	jbe    801d71 <vprintfmt+0x21f>
					putch('?', putdat);
  801d61:	83 ec 08             	sub    $0x8,%esp
  801d64:	ff 75 0c             	pushl  0xc(%ebp)
  801d67:	6a 3f                	push   $0x3f
  801d69:	ff 55 08             	call   *0x8(%ebp)
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	eb 0d                	jmp    801d7e <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  801d71:	83 ec 08             	sub    $0x8,%esp
  801d74:	ff 75 0c             	pushl  0xc(%ebp)
  801d77:	52                   	push   %edx
  801d78:	ff 55 08             	call   *0x8(%ebp)
  801d7b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801d7e:	83 eb 01             	sub    $0x1,%ebx
  801d81:	eb 1a                	jmp    801d9d <vprintfmt+0x24b>
  801d83:	89 75 08             	mov    %esi,0x8(%ebp)
  801d86:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d89:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d8c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d8f:	eb 0c                	jmp    801d9d <vprintfmt+0x24b>
  801d91:	89 75 08             	mov    %esi,0x8(%ebp)
  801d94:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801d97:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801d9a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801d9d:	83 c7 01             	add    $0x1,%edi
  801da0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801da4:	0f be d0             	movsbl %al,%edx
  801da7:	85 d2                	test   %edx,%edx
  801da9:	74 23                	je     801dce <vprintfmt+0x27c>
  801dab:	85 f6                	test   %esi,%esi
  801dad:	78 a1                	js     801d50 <vprintfmt+0x1fe>
  801daf:	83 ee 01             	sub    $0x1,%esi
  801db2:	79 9c                	jns    801d50 <vprintfmt+0x1fe>
  801db4:	89 df                	mov    %ebx,%edi
  801db6:	8b 75 08             	mov    0x8(%ebp),%esi
  801db9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dbc:	eb 18                	jmp    801dd6 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801dbe:	83 ec 08             	sub    $0x8,%esp
  801dc1:	53                   	push   %ebx
  801dc2:	6a 20                	push   $0x20
  801dc4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801dc6:	83 ef 01             	sub    $0x1,%edi
  801dc9:	83 c4 10             	add    $0x10,%esp
  801dcc:	eb 08                	jmp    801dd6 <vprintfmt+0x284>
  801dce:	89 df                	mov    %ebx,%edi
  801dd0:	8b 75 08             	mov    0x8(%ebp),%esi
  801dd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801dd6:	85 ff                	test   %edi,%edi
  801dd8:	7f e4                	jg     801dbe <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801dda:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801ddd:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801de0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801de3:	e9 90 fd ff ff       	jmp    801b78 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801de8:	83 f9 01             	cmp    $0x1,%ecx
  801deb:	7e 19                	jle    801e06 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801ded:	8b 45 14             	mov    0x14(%ebp),%eax
  801df0:	8b 50 04             	mov    0x4(%eax),%edx
  801df3:	8b 00                	mov    (%eax),%eax
  801df5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801df8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801dfb:	8b 45 14             	mov    0x14(%ebp),%eax
  801dfe:	8d 40 08             	lea    0x8(%eax),%eax
  801e01:	89 45 14             	mov    %eax,0x14(%ebp)
  801e04:	eb 38                	jmp    801e3e <vprintfmt+0x2ec>
	else if (lflag)
  801e06:	85 c9                	test   %ecx,%ecx
  801e08:	74 1b                	je     801e25 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801e0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e0d:	8b 00                	mov    (%eax),%eax
  801e0f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e12:	89 c1                	mov    %eax,%ecx
  801e14:	c1 f9 1f             	sar    $0x1f,%ecx
  801e17:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e1a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e1d:	8d 40 04             	lea    0x4(%eax),%eax
  801e20:	89 45 14             	mov    %eax,0x14(%ebp)
  801e23:	eb 19                	jmp    801e3e <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  801e25:	8b 45 14             	mov    0x14(%ebp),%eax
  801e28:	8b 00                	mov    (%eax),%eax
  801e2a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e2d:	89 c1                	mov    %eax,%ecx
  801e2f:	c1 f9 1f             	sar    $0x1f,%ecx
  801e32:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e35:	8b 45 14             	mov    0x14(%ebp),%eax
  801e38:	8d 40 04             	lea    0x4(%eax),%eax
  801e3b:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e3e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801e41:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e44:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e49:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e4d:	0f 89 0e 01 00 00    	jns    801f61 <vprintfmt+0x40f>
				putch('-', putdat);
  801e53:	83 ec 08             	sub    $0x8,%esp
  801e56:	53                   	push   %ebx
  801e57:	6a 2d                	push   $0x2d
  801e59:	ff d6                	call   *%esi
				num = -(long long) num;
  801e5b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801e5e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801e61:	f7 da                	neg    %edx
  801e63:	83 d1 00             	adc    $0x0,%ecx
  801e66:	f7 d9                	neg    %ecx
  801e68:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801e6b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e70:	e9 ec 00 00 00       	jmp    801f61 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e75:	83 f9 01             	cmp    $0x1,%ecx
  801e78:	7e 18                	jle    801e92 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  801e7a:	8b 45 14             	mov    0x14(%ebp),%eax
  801e7d:	8b 10                	mov    (%eax),%edx
  801e7f:	8b 48 04             	mov    0x4(%eax),%ecx
  801e82:	8d 40 08             	lea    0x8(%eax),%eax
  801e85:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801e88:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e8d:	e9 cf 00 00 00       	jmp    801f61 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801e92:	85 c9                	test   %ecx,%ecx
  801e94:	74 1a                	je     801eb0 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  801e96:	8b 45 14             	mov    0x14(%ebp),%eax
  801e99:	8b 10                	mov    (%eax),%edx
  801e9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ea0:	8d 40 04             	lea    0x4(%eax),%eax
  801ea3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801ea6:	b8 0a 00 00 00       	mov    $0xa,%eax
  801eab:	e9 b1 00 00 00       	jmp    801f61 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801eb0:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb3:	8b 10                	mov    (%eax),%edx
  801eb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  801eba:	8d 40 04             	lea    0x4(%eax),%eax
  801ebd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801ec0:	b8 0a 00 00 00       	mov    $0xa,%eax
  801ec5:	e9 97 00 00 00       	jmp    801f61 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801eca:	83 ec 08             	sub    $0x8,%esp
  801ecd:	53                   	push   %ebx
  801ece:	6a 58                	push   $0x58
  801ed0:	ff d6                	call   *%esi
			putch('X', putdat);
  801ed2:	83 c4 08             	add    $0x8,%esp
  801ed5:	53                   	push   %ebx
  801ed6:	6a 58                	push   $0x58
  801ed8:	ff d6                	call   *%esi
			putch('X', putdat);
  801eda:	83 c4 08             	add    $0x8,%esp
  801edd:	53                   	push   %ebx
  801ede:	6a 58                	push   $0x58
  801ee0:	ff d6                	call   *%esi
			break;
  801ee2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ee5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801ee8:	e9 8b fc ff ff       	jmp    801b78 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801eed:	83 ec 08             	sub    $0x8,%esp
  801ef0:	53                   	push   %ebx
  801ef1:	6a 30                	push   $0x30
  801ef3:	ff d6                	call   *%esi
			putch('x', putdat);
  801ef5:	83 c4 08             	add    $0x8,%esp
  801ef8:	53                   	push   %ebx
  801ef9:	6a 78                	push   $0x78
  801efb:	ff d6                	call   *%esi
			num = (unsigned long long)
  801efd:	8b 45 14             	mov    0x14(%ebp),%eax
  801f00:	8b 10                	mov    (%eax),%edx
  801f02:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801f07:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801f0a:	8d 40 04             	lea    0x4(%eax),%eax
  801f0d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801f10:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801f15:	eb 4a                	jmp    801f61 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801f17:	83 f9 01             	cmp    $0x1,%ecx
  801f1a:	7e 15                	jle    801f31 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801f1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f1f:	8b 10                	mov    (%eax),%edx
  801f21:	8b 48 04             	mov    0x4(%eax),%ecx
  801f24:	8d 40 08             	lea    0x8(%eax),%eax
  801f27:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801f2a:	b8 10 00 00 00       	mov    $0x10,%eax
  801f2f:	eb 30                	jmp    801f61 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801f31:	85 c9                	test   %ecx,%ecx
  801f33:	74 17                	je     801f4c <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801f35:	8b 45 14             	mov    0x14(%ebp),%eax
  801f38:	8b 10                	mov    (%eax),%edx
  801f3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f3f:	8d 40 04             	lea    0x4(%eax),%eax
  801f42:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801f45:	b8 10 00 00 00       	mov    $0x10,%eax
  801f4a:	eb 15                	jmp    801f61 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801f4c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f4f:	8b 10                	mov    (%eax),%edx
  801f51:	b9 00 00 00 00       	mov    $0x0,%ecx
  801f56:	8d 40 04             	lea    0x4(%eax),%eax
  801f59:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801f5c:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f61:	83 ec 0c             	sub    $0xc,%esp
  801f64:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f68:	57                   	push   %edi
  801f69:	ff 75 e0             	pushl  -0x20(%ebp)
  801f6c:	50                   	push   %eax
  801f6d:	51                   	push   %ecx
  801f6e:	52                   	push   %edx
  801f6f:	89 da                	mov    %ebx,%edx
  801f71:	89 f0                	mov    %esi,%eax
  801f73:	e8 f1 fa ff ff       	call   801a69 <printnum>
			break;
  801f78:	83 c4 20             	add    $0x20,%esp
  801f7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f7e:	e9 f5 fb ff ff       	jmp    801b78 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f83:	83 ec 08             	sub    $0x8,%esp
  801f86:	53                   	push   %ebx
  801f87:	52                   	push   %edx
  801f88:	ff d6                	call   *%esi
			break;
  801f8a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f90:	e9 e3 fb ff ff       	jmp    801b78 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f95:	83 ec 08             	sub    $0x8,%esp
  801f98:	53                   	push   %ebx
  801f99:	6a 25                	push   $0x25
  801f9b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f9d:	83 c4 10             	add    $0x10,%esp
  801fa0:	eb 03                	jmp    801fa5 <vprintfmt+0x453>
  801fa2:	83 ef 01             	sub    $0x1,%edi
  801fa5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801fa9:	75 f7                	jne    801fa2 <vprintfmt+0x450>
  801fab:	e9 c8 fb ff ff       	jmp    801b78 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801fb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fb3:	5b                   	pop    %ebx
  801fb4:	5e                   	pop    %esi
  801fb5:	5f                   	pop    %edi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	83 ec 18             	sub    $0x18,%esp
  801fbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801fc4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801fc7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801fcb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801fce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	74 26                	je     801fff <vsnprintf+0x47>
  801fd9:	85 d2                	test   %edx,%edx
  801fdb:	7e 22                	jle    801fff <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801fdd:	ff 75 14             	pushl  0x14(%ebp)
  801fe0:	ff 75 10             	pushl  0x10(%ebp)
  801fe3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801fe6:	50                   	push   %eax
  801fe7:	68 18 1b 80 00       	push   $0x801b18
  801fec:	e8 61 fb ff ff       	call   801b52 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801ff4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801ff7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	eb 05                	jmp    802004 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801fff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  802004:	c9                   	leave  
  802005:	c3                   	ret    

00802006 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  802006:	55                   	push   %ebp
  802007:	89 e5                	mov    %esp,%ebp
  802009:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80200c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80200f:	50                   	push   %eax
  802010:	ff 75 10             	pushl  0x10(%ebp)
  802013:	ff 75 0c             	pushl  0xc(%ebp)
  802016:	ff 75 08             	pushl  0x8(%ebp)
  802019:	e8 9a ff ff ff       	call   801fb8 <vsnprintf>
	va_end(ap);

	return rc;
}
  80201e:	c9                   	leave  
  80201f:	c3                   	ret    

00802020 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  802026:	b8 00 00 00 00       	mov    $0x0,%eax
  80202b:	eb 03                	jmp    802030 <strlen+0x10>
		n++;
  80202d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  802030:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  802034:	75 f7                	jne    80202d <strlen+0xd>
		n++;
	return n;
}
  802036:	5d                   	pop    %ebp
  802037:	c3                   	ret    

00802038 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80203e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  802041:	ba 00 00 00 00       	mov    $0x0,%edx
  802046:	eb 03                	jmp    80204b <strnlen+0x13>
		n++;
  802048:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80204b:	39 c2                	cmp    %eax,%edx
  80204d:	74 08                	je     802057 <strnlen+0x1f>
  80204f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  802053:	75 f3                	jne    802048 <strnlen+0x10>
  802055:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802057:	5d                   	pop    %ebp
  802058:	c3                   	ret    

00802059 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	53                   	push   %ebx
  80205d:	8b 45 08             	mov    0x8(%ebp),%eax
  802060:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  802063:	89 c2                	mov    %eax,%edx
  802065:	83 c2 01             	add    $0x1,%edx
  802068:	83 c1 01             	add    $0x1,%ecx
  80206b:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80206f:	88 5a ff             	mov    %bl,-0x1(%edx)
  802072:	84 db                	test   %bl,%bl
  802074:	75 ef                	jne    802065 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802076:	5b                   	pop    %ebx
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    

00802079 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802079:	55                   	push   %ebp
  80207a:	89 e5                	mov    %esp,%ebp
  80207c:	53                   	push   %ebx
  80207d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  802080:	53                   	push   %ebx
  802081:	e8 9a ff ff ff       	call   802020 <strlen>
  802086:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802089:	ff 75 0c             	pushl  0xc(%ebp)
  80208c:	01 d8                	add    %ebx,%eax
  80208e:	50                   	push   %eax
  80208f:	e8 c5 ff ff ff       	call   802059 <strcpy>
	return dst;
}
  802094:	89 d8                	mov    %ebx,%eax
  802096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802099:	c9                   	leave  
  80209a:	c3                   	ret    

0080209b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	56                   	push   %esi
  80209f:	53                   	push   %ebx
  8020a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8020a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020a6:	89 f3                	mov    %esi,%ebx
  8020a8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8020ab:	89 f2                	mov    %esi,%edx
  8020ad:	eb 0f                	jmp    8020be <strncpy+0x23>
		*dst++ = *src;
  8020af:	83 c2 01             	add    $0x1,%edx
  8020b2:	0f b6 01             	movzbl (%ecx),%eax
  8020b5:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8020b8:	80 39 01             	cmpb   $0x1,(%ecx)
  8020bb:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8020be:	39 da                	cmp    %ebx,%edx
  8020c0:	75 ed                	jne    8020af <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8020c2:	89 f0                	mov    %esi,%eax
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5d                   	pop    %ebp
  8020c7:	c3                   	ret    

008020c8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8020c8:	55                   	push   %ebp
  8020c9:	89 e5                	mov    %esp,%ebp
  8020cb:	56                   	push   %esi
  8020cc:	53                   	push   %ebx
  8020cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8020d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020d3:	8b 55 10             	mov    0x10(%ebp),%edx
  8020d6:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8020d8:	85 d2                	test   %edx,%edx
  8020da:	74 21                	je     8020fd <strlcpy+0x35>
  8020dc:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8020e0:	89 f2                	mov    %esi,%edx
  8020e2:	eb 09                	jmp    8020ed <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8020e4:	83 c2 01             	add    $0x1,%edx
  8020e7:	83 c1 01             	add    $0x1,%ecx
  8020ea:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8020ed:	39 c2                	cmp    %eax,%edx
  8020ef:	74 09                	je     8020fa <strlcpy+0x32>
  8020f1:	0f b6 19             	movzbl (%ecx),%ebx
  8020f4:	84 db                	test   %bl,%bl
  8020f6:	75 ec                	jne    8020e4 <strlcpy+0x1c>
  8020f8:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8020fa:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8020fd:	29 f0                	sub    %esi,%eax
}
  8020ff:	5b                   	pop    %ebx
  802100:	5e                   	pop    %esi
  802101:	5d                   	pop    %ebp
  802102:	c3                   	ret    

00802103 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  802103:	55                   	push   %ebp
  802104:	89 e5                	mov    %esp,%ebp
  802106:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802109:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80210c:	eb 06                	jmp    802114 <strcmp+0x11>
		p++, q++;
  80210e:	83 c1 01             	add    $0x1,%ecx
  802111:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  802114:	0f b6 01             	movzbl (%ecx),%eax
  802117:	84 c0                	test   %al,%al
  802119:	74 04                	je     80211f <strcmp+0x1c>
  80211b:	3a 02                	cmp    (%edx),%al
  80211d:	74 ef                	je     80210e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80211f:	0f b6 c0             	movzbl %al,%eax
  802122:	0f b6 12             	movzbl (%edx),%edx
  802125:	29 d0                	sub    %edx,%eax
}
  802127:	5d                   	pop    %ebp
  802128:	c3                   	ret    

00802129 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	53                   	push   %ebx
  80212d:	8b 45 08             	mov    0x8(%ebp),%eax
  802130:	8b 55 0c             	mov    0xc(%ebp),%edx
  802133:	89 c3                	mov    %eax,%ebx
  802135:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  802138:	eb 06                	jmp    802140 <strncmp+0x17>
		n--, p++, q++;
  80213a:	83 c0 01             	add    $0x1,%eax
  80213d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  802140:	39 d8                	cmp    %ebx,%eax
  802142:	74 15                	je     802159 <strncmp+0x30>
  802144:	0f b6 08             	movzbl (%eax),%ecx
  802147:	84 c9                	test   %cl,%cl
  802149:	74 04                	je     80214f <strncmp+0x26>
  80214b:	3a 0a                	cmp    (%edx),%cl
  80214d:	74 eb                	je     80213a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80214f:	0f b6 00             	movzbl (%eax),%eax
  802152:	0f b6 12             	movzbl (%edx),%edx
  802155:	29 d0                	sub    %edx,%eax
  802157:	eb 05                	jmp    80215e <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802159:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80215e:	5b                   	pop    %ebx
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    

00802161 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  802161:	55                   	push   %ebp
  802162:	89 e5                	mov    %esp,%ebp
  802164:	8b 45 08             	mov    0x8(%ebp),%eax
  802167:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80216b:	eb 07                	jmp    802174 <strchr+0x13>
		if (*s == c)
  80216d:	38 ca                	cmp    %cl,%dl
  80216f:	74 0f                	je     802180 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  802171:	83 c0 01             	add    $0x1,%eax
  802174:	0f b6 10             	movzbl (%eax),%edx
  802177:	84 d2                	test   %dl,%dl
  802179:	75 f2                	jne    80216d <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80217b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	8b 45 08             	mov    0x8(%ebp),%eax
  802188:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80218c:	eb 03                	jmp    802191 <strfind+0xf>
  80218e:	83 c0 01             	add    $0x1,%eax
  802191:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  802194:	38 ca                	cmp    %cl,%dl
  802196:	74 04                	je     80219c <strfind+0x1a>
  802198:	84 d2                	test   %dl,%dl
  80219a:	75 f2                	jne    80218e <strfind+0xc>
			break;
	return (char *) s;
}
  80219c:	5d                   	pop    %ebp
  80219d:	c3                   	ret    

0080219e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80219e:	55                   	push   %ebp
  80219f:	89 e5                	mov    %esp,%ebp
  8021a1:	57                   	push   %edi
  8021a2:	56                   	push   %esi
  8021a3:	53                   	push   %ebx
  8021a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021a7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8021aa:	85 c9                	test   %ecx,%ecx
  8021ac:	74 36                	je     8021e4 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8021ae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8021b4:	75 28                	jne    8021de <memset+0x40>
  8021b6:	f6 c1 03             	test   $0x3,%cl
  8021b9:	75 23                	jne    8021de <memset+0x40>
		c &= 0xFF;
  8021bb:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8021bf:	89 d3                	mov    %edx,%ebx
  8021c1:	c1 e3 08             	shl    $0x8,%ebx
  8021c4:	89 d6                	mov    %edx,%esi
  8021c6:	c1 e6 18             	shl    $0x18,%esi
  8021c9:	89 d0                	mov    %edx,%eax
  8021cb:	c1 e0 10             	shl    $0x10,%eax
  8021ce:	09 f0                	or     %esi,%eax
  8021d0:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8021d2:	89 d8                	mov    %ebx,%eax
  8021d4:	09 d0                	or     %edx,%eax
  8021d6:	c1 e9 02             	shr    $0x2,%ecx
  8021d9:	fc                   	cld    
  8021da:	f3 ab                	rep stos %eax,%es:(%edi)
  8021dc:	eb 06                	jmp    8021e4 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8021de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021e1:	fc                   	cld    
  8021e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8021e4:	89 f8                	mov    %edi,%eax
  8021e6:	5b                   	pop    %ebx
  8021e7:	5e                   	pop    %esi
  8021e8:	5f                   	pop    %edi
  8021e9:	5d                   	pop    %ebp
  8021ea:	c3                   	ret    

008021eb <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8021eb:	55                   	push   %ebp
  8021ec:	89 e5                	mov    %esp,%ebp
  8021ee:	57                   	push   %edi
  8021ef:	56                   	push   %esi
  8021f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8021f3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8021f9:	39 c6                	cmp    %eax,%esi
  8021fb:	73 35                	jae    802232 <memmove+0x47>
  8021fd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  802200:	39 d0                	cmp    %edx,%eax
  802202:	73 2e                	jae    802232 <memmove+0x47>
		s += n;
		d += n;
  802204:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802207:	89 d6                	mov    %edx,%esi
  802209:	09 fe                	or     %edi,%esi
  80220b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  802211:	75 13                	jne    802226 <memmove+0x3b>
  802213:	f6 c1 03             	test   $0x3,%cl
  802216:	75 0e                	jne    802226 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  802218:	83 ef 04             	sub    $0x4,%edi
  80221b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80221e:	c1 e9 02             	shr    $0x2,%ecx
  802221:	fd                   	std    
  802222:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802224:	eb 09                	jmp    80222f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  802226:	83 ef 01             	sub    $0x1,%edi
  802229:	8d 72 ff             	lea    -0x1(%edx),%esi
  80222c:	fd                   	std    
  80222d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80222f:	fc                   	cld    
  802230:	eb 1d                	jmp    80224f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  802232:	89 f2                	mov    %esi,%edx
  802234:	09 c2                	or     %eax,%edx
  802236:	f6 c2 03             	test   $0x3,%dl
  802239:	75 0f                	jne    80224a <memmove+0x5f>
  80223b:	f6 c1 03             	test   $0x3,%cl
  80223e:	75 0a                	jne    80224a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  802240:	c1 e9 02             	shr    $0x2,%ecx
  802243:	89 c7                	mov    %eax,%edi
  802245:	fc                   	cld    
  802246:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  802248:	eb 05                	jmp    80224f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80224a:	89 c7                	mov    %eax,%edi
  80224c:	fc                   	cld    
  80224d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80224f:	5e                   	pop    %esi
  802250:	5f                   	pop    %edi
  802251:	5d                   	pop    %ebp
  802252:	c3                   	ret    

00802253 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802256:	ff 75 10             	pushl  0x10(%ebp)
  802259:	ff 75 0c             	pushl  0xc(%ebp)
  80225c:	ff 75 08             	pushl  0x8(%ebp)
  80225f:	e8 87 ff ff ff       	call   8021eb <memmove>
}
  802264:	c9                   	leave  
  802265:	c3                   	ret    

00802266 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	56                   	push   %esi
  80226a:	53                   	push   %ebx
  80226b:	8b 45 08             	mov    0x8(%ebp),%eax
  80226e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802271:	89 c6                	mov    %eax,%esi
  802273:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802276:	eb 1a                	jmp    802292 <memcmp+0x2c>
		if (*s1 != *s2)
  802278:	0f b6 08             	movzbl (%eax),%ecx
  80227b:	0f b6 1a             	movzbl (%edx),%ebx
  80227e:	38 d9                	cmp    %bl,%cl
  802280:	74 0a                	je     80228c <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  802282:	0f b6 c1             	movzbl %cl,%eax
  802285:	0f b6 db             	movzbl %bl,%ebx
  802288:	29 d8                	sub    %ebx,%eax
  80228a:	eb 0f                	jmp    80229b <memcmp+0x35>
		s1++, s2++;
  80228c:	83 c0 01             	add    $0x1,%eax
  80228f:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802292:	39 f0                	cmp    %esi,%eax
  802294:	75 e2                	jne    802278 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802296:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80229b:	5b                   	pop    %ebx
  80229c:	5e                   	pop    %esi
  80229d:	5d                   	pop    %ebp
  80229e:	c3                   	ret    

0080229f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	53                   	push   %ebx
  8022a3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8022a6:	89 c1                	mov    %eax,%ecx
  8022a8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8022ab:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8022af:	eb 0a                	jmp    8022bb <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8022b1:	0f b6 10             	movzbl (%eax),%edx
  8022b4:	39 da                	cmp    %ebx,%edx
  8022b6:	74 07                	je     8022bf <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8022b8:	83 c0 01             	add    $0x1,%eax
  8022bb:	39 c8                	cmp    %ecx,%eax
  8022bd:	72 f2                	jb     8022b1 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8022bf:	5b                   	pop    %ebx
  8022c0:	5d                   	pop    %ebp
  8022c1:	c3                   	ret    

008022c2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8022c2:	55                   	push   %ebp
  8022c3:	89 e5                	mov    %esp,%ebp
  8022c5:	57                   	push   %edi
  8022c6:	56                   	push   %esi
  8022c7:	53                   	push   %ebx
  8022c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022cb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8022ce:	eb 03                	jmp    8022d3 <strtol+0x11>
		s++;
  8022d0:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8022d3:	0f b6 01             	movzbl (%ecx),%eax
  8022d6:	3c 20                	cmp    $0x20,%al
  8022d8:	74 f6                	je     8022d0 <strtol+0xe>
  8022da:	3c 09                	cmp    $0x9,%al
  8022dc:	74 f2                	je     8022d0 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8022de:	3c 2b                	cmp    $0x2b,%al
  8022e0:	75 0a                	jne    8022ec <strtol+0x2a>
		s++;
  8022e2:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8022e5:	bf 00 00 00 00       	mov    $0x0,%edi
  8022ea:	eb 11                	jmp    8022fd <strtol+0x3b>
  8022ec:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8022f1:	3c 2d                	cmp    $0x2d,%al
  8022f3:	75 08                	jne    8022fd <strtol+0x3b>
		s++, neg = 1;
  8022f5:	83 c1 01             	add    $0x1,%ecx
  8022f8:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022fd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  802303:	75 15                	jne    80231a <strtol+0x58>
  802305:	80 39 30             	cmpb   $0x30,(%ecx)
  802308:	75 10                	jne    80231a <strtol+0x58>
  80230a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80230e:	75 7c                	jne    80238c <strtol+0xca>
		s += 2, base = 16;
  802310:	83 c1 02             	add    $0x2,%ecx
  802313:	bb 10 00 00 00       	mov    $0x10,%ebx
  802318:	eb 16                	jmp    802330 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80231a:	85 db                	test   %ebx,%ebx
  80231c:	75 12                	jne    802330 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80231e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802323:	80 39 30             	cmpb   $0x30,(%ecx)
  802326:	75 08                	jne    802330 <strtol+0x6e>
		s++, base = 8;
  802328:	83 c1 01             	add    $0x1,%ecx
  80232b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  802330:	b8 00 00 00 00       	mov    $0x0,%eax
  802335:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  802338:	0f b6 11             	movzbl (%ecx),%edx
  80233b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80233e:	89 f3                	mov    %esi,%ebx
  802340:	80 fb 09             	cmp    $0x9,%bl
  802343:	77 08                	ja     80234d <strtol+0x8b>
			dig = *s - '0';
  802345:	0f be d2             	movsbl %dl,%edx
  802348:	83 ea 30             	sub    $0x30,%edx
  80234b:	eb 22                	jmp    80236f <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  80234d:	8d 72 9f             	lea    -0x61(%edx),%esi
  802350:	89 f3                	mov    %esi,%ebx
  802352:	80 fb 19             	cmp    $0x19,%bl
  802355:	77 08                	ja     80235f <strtol+0x9d>
			dig = *s - 'a' + 10;
  802357:	0f be d2             	movsbl %dl,%edx
  80235a:	83 ea 57             	sub    $0x57,%edx
  80235d:	eb 10                	jmp    80236f <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80235f:	8d 72 bf             	lea    -0x41(%edx),%esi
  802362:	89 f3                	mov    %esi,%ebx
  802364:	80 fb 19             	cmp    $0x19,%bl
  802367:	77 16                	ja     80237f <strtol+0xbd>
			dig = *s - 'A' + 10;
  802369:	0f be d2             	movsbl %dl,%edx
  80236c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80236f:	3b 55 10             	cmp    0x10(%ebp),%edx
  802372:	7d 0b                	jge    80237f <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  802374:	83 c1 01             	add    $0x1,%ecx
  802377:	0f af 45 10          	imul   0x10(%ebp),%eax
  80237b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80237d:	eb b9                	jmp    802338 <strtol+0x76>

	if (endptr)
  80237f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802383:	74 0d                	je     802392 <strtol+0xd0>
		*endptr = (char *) s;
  802385:	8b 75 0c             	mov    0xc(%ebp),%esi
  802388:	89 0e                	mov    %ecx,(%esi)
  80238a:	eb 06                	jmp    802392 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80238c:	85 db                	test   %ebx,%ebx
  80238e:	74 98                	je     802328 <strtol+0x66>
  802390:	eb 9e                	jmp    802330 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  802392:	89 c2                	mov    %eax,%edx
  802394:	f7 da                	neg    %edx
  802396:	85 ff                	test   %edi,%edi
  802398:	0f 45 c2             	cmovne %edx,%eax
}
  80239b:	5b                   	pop    %ebx
  80239c:	5e                   	pop    %esi
  80239d:	5f                   	pop    %edi
  80239e:	5d                   	pop    %ebp
  80239f:	c3                   	ret    

008023a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8023a0:	55                   	push   %ebp
  8023a1:	89 e5                	mov    %esp,%ebp
  8023a3:	57                   	push   %edi
  8023a4:	56                   	push   %esi
  8023a5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8023ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8023b1:	89 c3                	mov    %eax,%ebx
  8023b3:	89 c7                	mov    %eax,%edi
  8023b5:	89 c6                	mov    %eax,%esi
  8023b7:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8023b9:	5b                   	pop    %ebx
  8023ba:	5e                   	pop    %esi
  8023bb:	5f                   	pop    %edi
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    

008023be <sys_cgetc>:

int
sys_cgetc(void)
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	57                   	push   %edi
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8023c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ce:	89 d1                	mov    %edx,%ecx
  8023d0:	89 d3                	mov    %edx,%ebx
  8023d2:	89 d7                	mov    %edx,%edi
  8023d4:	89 d6                	mov    %edx,%esi
  8023d6:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8023d8:	5b                   	pop    %ebx
  8023d9:	5e                   	pop    %esi
  8023da:	5f                   	pop    %edi
  8023db:	5d                   	pop    %ebp
  8023dc:	c3                   	ret    

008023dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8023dd:	55                   	push   %ebp
  8023de:	89 e5                	mov    %esp,%ebp
  8023e0:	57                   	push   %edi
  8023e1:	56                   	push   %esi
  8023e2:	53                   	push   %ebx
  8023e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8023eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8023f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8023f3:	89 cb                	mov    %ecx,%ebx
  8023f5:	89 cf                	mov    %ecx,%edi
  8023f7:	89 ce                	mov    %ecx,%esi
  8023f9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8023fb:	85 c0                	test   %eax,%eax
  8023fd:	7e 17                	jle    802416 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8023ff:	83 ec 0c             	sub    $0xc,%esp
  802402:	50                   	push   %eax
  802403:	6a 03                	push   $0x3
  802405:	68 9f 40 80 00       	push   $0x80409f
  80240a:	6a 23                	push   $0x23
  80240c:	68 bc 40 80 00       	push   $0x8040bc
  802411:	e8 66 f5 ff ff       	call   80197c <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  802416:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802419:	5b                   	pop    %ebx
  80241a:	5e                   	pop    %esi
  80241b:	5f                   	pop    %edi
  80241c:	5d                   	pop    %ebp
  80241d:	c3                   	ret    

0080241e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80241e:	55                   	push   %ebp
  80241f:	89 e5                	mov    %esp,%ebp
  802421:	57                   	push   %edi
  802422:	56                   	push   %esi
  802423:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802424:	ba 00 00 00 00       	mov    $0x0,%edx
  802429:	b8 02 00 00 00       	mov    $0x2,%eax
  80242e:	89 d1                	mov    %edx,%ecx
  802430:	89 d3                	mov    %edx,%ebx
  802432:	89 d7                	mov    %edx,%edi
  802434:	89 d6                	mov    %edx,%esi
  802436:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  802438:	5b                   	pop    %ebx
  802439:	5e                   	pop    %esi
  80243a:	5f                   	pop    %edi
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    

0080243d <sys_yield>:

void
sys_yield(void)
{
  80243d:	55                   	push   %ebp
  80243e:	89 e5                	mov    %esp,%ebp
  802440:	57                   	push   %edi
  802441:	56                   	push   %esi
  802442:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802443:	ba 00 00 00 00       	mov    $0x0,%edx
  802448:	b8 0b 00 00 00       	mov    $0xb,%eax
  80244d:	89 d1                	mov    %edx,%ecx
  80244f:	89 d3                	mov    %edx,%ebx
  802451:	89 d7                	mov    %edx,%edi
  802453:	89 d6                	mov    %edx,%esi
  802455:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802457:	5b                   	pop    %ebx
  802458:	5e                   	pop    %esi
  802459:	5f                   	pop    %edi
  80245a:	5d                   	pop    %ebp
  80245b:	c3                   	ret    

0080245c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80245c:	55                   	push   %ebp
  80245d:	89 e5                	mov    %esp,%ebp
  80245f:	57                   	push   %edi
  802460:	56                   	push   %esi
  802461:	53                   	push   %ebx
  802462:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802465:	be 00 00 00 00       	mov    $0x0,%esi
  80246a:	b8 04 00 00 00       	mov    $0x4,%eax
  80246f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802472:	8b 55 08             	mov    0x8(%ebp),%edx
  802475:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802478:	89 f7                	mov    %esi,%edi
  80247a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80247c:	85 c0                	test   %eax,%eax
  80247e:	7e 17                	jle    802497 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802480:	83 ec 0c             	sub    $0xc,%esp
  802483:	50                   	push   %eax
  802484:	6a 04                	push   $0x4
  802486:	68 9f 40 80 00       	push   $0x80409f
  80248b:	6a 23                	push   $0x23
  80248d:	68 bc 40 80 00       	push   $0x8040bc
  802492:	e8 e5 f4 ff ff       	call   80197c <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80249a:	5b                   	pop    %ebx
  80249b:	5e                   	pop    %esi
  80249c:	5f                   	pop    %edi
  80249d:	5d                   	pop    %ebp
  80249e:	c3                   	ret    

0080249f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80249f:	55                   	push   %ebp
  8024a0:	89 e5                	mov    %esp,%ebp
  8024a2:	57                   	push   %edi
  8024a3:	56                   	push   %esi
  8024a4:	53                   	push   %ebx
  8024a5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024a8:	b8 05 00 00 00       	mov    $0x5,%eax
  8024ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8024b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8024b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8024b9:	8b 75 18             	mov    0x18(%ebp),%esi
  8024bc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8024be:	85 c0                	test   %eax,%eax
  8024c0:	7e 17                	jle    8024d9 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024c2:	83 ec 0c             	sub    $0xc,%esp
  8024c5:	50                   	push   %eax
  8024c6:	6a 05                	push   $0x5
  8024c8:	68 9f 40 80 00       	push   $0x80409f
  8024cd:	6a 23                	push   $0x23
  8024cf:	68 bc 40 80 00       	push   $0x8040bc
  8024d4:	e8 a3 f4 ff ff       	call   80197c <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8024d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024dc:	5b                   	pop    %ebx
  8024dd:	5e                   	pop    %esi
  8024de:	5f                   	pop    %edi
  8024df:	5d                   	pop    %ebp
  8024e0:	c3                   	ret    

008024e1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8024e1:	55                   	push   %ebp
  8024e2:	89 e5                	mov    %esp,%ebp
  8024e4:	57                   	push   %edi
  8024e5:	56                   	push   %esi
  8024e6:	53                   	push   %ebx
  8024e7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024ea:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8024f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8024fa:	89 df                	mov    %ebx,%edi
  8024fc:	89 de                	mov    %ebx,%esi
  8024fe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802500:	85 c0                	test   %eax,%eax
  802502:	7e 17                	jle    80251b <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802504:	83 ec 0c             	sub    $0xc,%esp
  802507:	50                   	push   %eax
  802508:	6a 06                	push   $0x6
  80250a:	68 9f 40 80 00       	push   $0x80409f
  80250f:	6a 23                	push   $0x23
  802511:	68 bc 40 80 00       	push   $0x8040bc
  802516:	e8 61 f4 ff ff       	call   80197c <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80251b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80251e:	5b                   	pop    %ebx
  80251f:	5e                   	pop    %esi
  802520:	5f                   	pop    %edi
  802521:	5d                   	pop    %ebp
  802522:	c3                   	ret    

00802523 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  802523:	55                   	push   %ebp
  802524:	89 e5                	mov    %esp,%ebp
  802526:	57                   	push   %edi
  802527:	56                   	push   %esi
  802528:	53                   	push   %ebx
  802529:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80252c:	bb 00 00 00 00       	mov    $0x0,%ebx
  802531:	b8 08 00 00 00       	mov    $0x8,%eax
  802536:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802539:	8b 55 08             	mov    0x8(%ebp),%edx
  80253c:	89 df                	mov    %ebx,%edi
  80253e:	89 de                	mov    %ebx,%esi
  802540:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802542:	85 c0                	test   %eax,%eax
  802544:	7e 17                	jle    80255d <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802546:	83 ec 0c             	sub    $0xc,%esp
  802549:	50                   	push   %eax
  80254a:	6a 08                	push   $0x8
  80254c:	68 9f 40 80 00       	push   $0x80409f
  802551:	6a 23                	push   $0x23
  802553:	68 bc 40 80 00       	push   $0x8040bc
  802558:	e8 1f f4 ff ff       	call   80197c <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80255d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802560:	5b                   	pop    %ebx
  802561:	5e                   	pop    %esi
  802562:	5f                   	pop    %edi
  802563:	5d                   	pop    %ebp
  802564:	c3                   	ret    

00802565 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802565:	55                   	push   %ebp
  802566:	89 e5                	mov    %esp,%ebp
  802568:	57                   	push   %edi
  802569:	56                   	push   %esi
  80256a:	53                   	push   %ebx
  80256b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80256e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802573:	b8 09 00 00 00       	mov    $0x9,%eax
  802578:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80257b:	8b 55 08             	mov    0x8(%ebp),%edx
  80257e:	89 df                	mov    %ebx,%edi
  802580:	89 de                	mov    %ebx,%esi
  802582:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  802584:	85 c0                	test   %eax,%eax
  802586:	7e 17                	jle    80259f <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802588:	83 ec 0c             	sub    $0xc,%esp
  80258b:	50                   	push   %eax
  80258c:	6a 09                	push   $0x9
  80258e:	68 9f 40 80 00       	push   $0x80409f
  802593:	6a 23                	push   $0x23
  802595:	68 bc 40 80 00       	push   $0x8040bc
  80259a:	e8 dd f3 ff ff       	call   80197c <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80259f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025a2:	5b                   	pop    %ebx
  8025a3:	5e                   	pop    %esi
  8025a4:	5f                   	pop    %edi
  8025a5:	5d                   	pop    %ebp
  8025a6:	c3                   	ret    

008025a7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8025a7:	55                   	push   %ebp
  8025a8:	89 e5                	mov    %esp,%ebp
  8025aa:	57                   	push   %edi
  8025ab:	56                   	push   %esi
  8025ac:	53                   	push   %ebx
  8025ad:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8025b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8025ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8025c0:	89 df                	mov    %ebx,%edi
  8025c2:	89 de                	mov    %ebx,%esi
  8025c4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8025c6:	85 c0                	test   %eax,%eax
  8025c8:	7e 17                	jle    8025e1 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025ca:	83 ec 0c             	sub    $0xc,%esp
  8025cd:	50                   	push   %eax
  8025ce:	6a 0a                	push   $0xa
  8025d0:	68 9f 40 80 00       	push   $0x80409f
  8025d5:	6a 23                	push   $0x23
  8025d7:	68 bc 40 80 00       	push   $0x8040bc
  8025dc:	e8 9b f3 ff ff       	call   80197c <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8025e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025e4:	5b                   	pop    %ebx
  8025e5:	5e                   	pop    %esi
  8025e6:	5f                   	pop    %edi
  8025e7:	5d                   	pop    %ebp
  8025e8:	c3                   	ret    

008025e9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8025e9:	55                   	push   %ebp
  8025ea:	89 e5                	mov    %esp,%ebp
  8025ec:	57                   	push   %edi
  8025ed:	56                   	push   %esi
  8025ee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025ef:	be 00 00 00 00       	mov    $0x0,%esi
  8025f4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8025f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8025ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802602:	8b 7d 14             	mov    0x14(%ebp),%edi
  802605:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  802607:	5b                   	pop    %ebx
  802608:	5e                   	pop    %esi
  802609:	5f                   	pop    %edi
  80260a:	5d                   	pop    %ebp
  80260b:	c3                   	ret    

0080260c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80260c:	55                   	push   %ebp
  80260d:	89 e5                	mov    %esp,%ebp
  80260f:	57                   	push   %edi
  802610:	56                   	push   %esi
  802611:	53                   	push   %ebx
  802612:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802615:	b9 00 00 00 00       	mov    $0x0,%ecx
  80261a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80261f:	8b 55 08             	mov    0x8(%ebp),%edx
  802622:	89 cb                	mov    %ecx,%ebx
  802624:	89 cf                	mov    %ecx,%edi
  802626:	89 ce                	mov    %ecx,%esi
  802628:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80262a:	85 c0                	test   %eax,%eax
  80262c:	7e 17                	jle    802645 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80262e:	83 ec 0c             	sub    $0xc,%esp
  802631:	50                   	push   %eax
  802632:	6a 0d                	push   $0xd
  802634:	68 9f 40 80 00       	push   $0x80409f
  802639:	6a 23                	push   $0x23
  80263b:	68 bc 40 80 00       	push   $0x8040bc
  802640:	e8 37 f3 ff ff       	call   80197c <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  802645:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802648:	5b                   	pop    %ebx
  802649:	5e                   	pop    %esi
  80264a:	5f                   	pop    %edi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    

0080264d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80264d:	55                   	push   %ebp
  80264e:	89 e5                	mov    %esp,%ebp
  802650:	53                   	push   %ebx
  802651:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  802654:	e8 c5 fd ff ff       	call   80241e <sys_getenvid>
  802659:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  80265b:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  802662:	75 29                	jne    80268d <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  802664:	83 ec 04             	sub    $0x4,%esp
  802667:	6a 07                	push   $0x7
  802669:	68 00 f0 bf ee       	push   $0xeebff000
  80266e:	50                   	push   %eax
  80266f:	e8 e8 fd ff ff       	call   80245c <sys_page_alloc>
  802674:	83 c4 10             	add    $0x10,%esp
  802677:	85 c0                	test   %eax,%eax
  802679:	79 12                	jns    80268d <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  80267b:	50                   	push   %eax
  80267c:	68 ca 40 80 00       	push   $0x8040ca
  802681:	6a 24                	push   $0x24
  802683:	68 e3 40 80 00       	push   $0x8040e3
  802688:	e8 ef f2 ff ff       	call   80197c <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  80268d:	8b 45 08             	mov    0x8(%ebp),%eax
  802690:	a3 10 a0 80 00       	mov    %eax,0x80a010
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  802695:	83 ec 08             	sub    $0x8,%esp
  802698:	68 c1 26 80 00       	push   $0x8026c1
  80269d:	53                   	push   %ebx
  80269e:	e8 04 ff ff ff       	call   8025a7 <sys_env_set_pgfault_upcall>
  8026a3:	83 c4 10             	add    $0x10,%esp
  8026a6:	85 c0                	test   %eax,%eax
  8026a8:	79 12                	jns    8026bc <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  8026aa:	50                   	push   %eax
  8026ab:	68 ca 40 80 00       	push   $0x8040ca
  8026b0:	6a 2e                	push   $0x2e
  8026b2:	68 e3 40 80 00       	push   $0x8040e3
  8026b7:	e8 c0 f2 ff ff       	call   80197c <_panic>
}
  8026bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026bf:	c9                   	leave  
  8026c0:	c3                   	ret    

008026c1 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8026c1:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8026c2:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  8026c7:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8026c9:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  8026cc:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  8026d0:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  8026d3:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8026d7:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  8026d9:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8026dd:	83 c4 08             	add    $0x8,%esp
	popal
  8026e0:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8026e1:	83 c4 04             	add    $0x4,%esp
	popfl
  8026e4:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  8026e5:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8026e6:	c3                   	ret    

008026e7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026e7:	55                   	push   %ebp
  8026e8:	89 e5                	mov    %esp,%ebp
  8026ea:	57                   	push   %edi
  8026eb:	56                   	push   %esi
  8026ec:	53                   	push   %ebx
  8026ed:	83 ec 0c             	sub    $0xc,%esp
  8026f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8026f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  8026f9:	85 f6                	test   %esi,%esi
  8026fb:	74 06                	je     802703 <ipc_recv+0x1c>
		*from_env_store = 0;
  8026fd:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  802703:	85 db                	test   %ebx,%ebx
  802705:	74 06                	je     80270d <ipc_recv+0x26>
		*perm_store = 0;
  802707:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  80270d:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  80270f:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802714:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  802717:	83 ec 0c             	sub    $0xc,%esp
  80271a:	50                   	push   %eax
  80271b:	e8 ec fe ff ff       	call   80260c <sys_ipc_recv>
  802720:	89 c7                	mov    %eax,%edi
  802722:	83 c4 10             	add    $0x10,%esp
  802725:	85 c0                	test   %eax,%eax
  802727:	79 14                	jns    80273d <ipc_recv+0x56>
		cprintf("im dead");
  802729:	83 ec 0c             	sub    $0xc,%esp
  80272c:	68 f1 40 80 00       	push   $0x8040f1
  802731:	e8 1f f3 ff ff       	call   801a55 <cprintf>
		return r;
  802736:	83 c4 10             	add    $0x10,%esp
  802739:	89 f8                	mov    %edi,%eax
  80273b:	eb 24                	jmp    802761 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  80273d:	85 f6                	test   %esi,%esi
  80273f:	74 0a                	je     80274b <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  802741:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802746:	8b 40 74             	mov    0x74(%eax),%eax
  802749:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  80274b:	85 db                	test   %ebx,%ebx
  80274d:	74 0a                	je     802759 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  80274f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802754:	8b 40 78             	mov    0x78(%eax),%eax
  802757:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  802759:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80275e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802761:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802764:	5b                   	pop    %ebx
  802765:	5e                   	pop    %esi
  802766:	5f                   	pop    %edi
  802767:	5d                   	pop    %ebp
  802768:	c3                   	ret    

00802769 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802769:	55                   	push   %ebp
  80276a:	89 e5                	mov    %esp,%ebp
  80276c:	57                   	push   %edi
  80276d:	56                   	push   %esi
  80276e:	53                   	push   %ebx
  80276f:	83 ec 0c             	sub    $0xc,%esp
  802772:	8b 7d 08             	mov    0x8(%ebp),%edi
  802775:	8b 75 0c             	mov    0xc(%ebp),%esi
  802778:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  80277b:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  80277d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802782:	0f 44 d8             	cmove  %eax,%ebx
  802785:	eb 1c                	jmp    8027a3 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  802787:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80278a:	74 12                	je     80279e <ipc_send+0x35>
			panic("ipc_send: %e", r);
  80278c:	50                   	push   %eax
  80278d:	68 f9 40 80 00       	push   $0x8040f9
  802792:	6a 4e                	push   $0x4e
  802794:	68 06 41 80 00       	push   $0x804106
  802799:	e8 de f1 ff ff       	call   80197c <_panic>
		sys_yield();
  80279e:	e8 9a fc ff ff       	call   80243d <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8027a3:	ff 75 14             	pushl  0x14(%ebp)
  8027a6:	53                   	push   %ebx
  8027a7:	56                   	push   %esi
  8027a8:	57                   	push   %edi
  8027a9:	e8 3b fe ff ff       	call   8025e9 <sys_ipc_try_send>
  8027ae:	83 c4 10             	add    $0x10,%esp
  8027b1:	85 c0                	test   %eax,%eax
  8027b3:	78 d2                	js     802787 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  8027b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8027b8:	5b                   	pop    %ebx
  8027b9:	5e                   	pop    %esi
  8027ba:	5f                   	pop    %edi
  8027bb:	5d                   	pop    %ebp
  8027bc:	c3                   	ret    

008027bd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8027bd:	55                   	push   %ebp
  8027be:	89 e5                	mov    %esp,%ebp
  8027c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8027c3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8027c8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8027cb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8027d1:	8b 52 50             	mov    0x50(%edx),%edx
  8027d4:	39 ca                	cmp    %ecx,%edx
  8027d6:	75 0d                	jne    8027e5 <ipc_find_env+0x28>
			return envs[i].env_id;
  8027d8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8027db:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8027e0:	8b 40 48             	mov    0x48(%eax),%eax
  8027e3:	eb 0f                	jmp    8027f4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8027e5:	83 c0 01             	add    $0x1,%eax
  8027e8:	3d 00 04 00 00       	cmp    $0x400,%eax
  8027ed:	75 d9                	jne    8027c8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8027ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8027f4:	5d                   	pop    %ebp
  8027f5:	c3                   	ret    

008027f6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8027f6:	55                   	push   %ebp
  8027f7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8027f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8027fc:	05 00 00 00 30       	add    $0x30000000,%eax
  802801:	c1 e8 0c             	shr    $0xc,%eax
}
  802804:	5d                   	pop    %ebp
  802805:	c3                   	ret    

00802806 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  802806:	55                   	push   %ebp
  802807:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  802809:	8b 45 08             	mov    0x8(%ebp),%eax
  80280c:	05 00 00 00 30       	add    $0x30000000,%eax
  802811:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  802816:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80281b:	5d                   	pop    %ebp
  80281c:	c3                   	ret    

0080281d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80281d:	55                   	push   %ebp
  80281e:	89 e5                	mov    %esp,%ebp
  802820:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802823:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  802828:	89 c2                	mov    %eax,%edx
  80282a:	c1 ea 16             	shr    $0x16,%edx
  80282d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802834:	f6 c2 01             	test   $0x1,%dl
  802837:	74 11                	je     80284a <fd_alloc+0x2d>
  802839:	89 c2                	mov    %eax,%edx
  80283b:	c1 ea 0c             	shr    $0xc,%edx
  80283e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  802845:	f6 c2 01             	test   $0x1,%dl
  802848:	75 09                	jne    802853 <fd_alloc+0x36>
			*fd_store = fd;
  80284a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80284c:	b8 00 00 00 00       	mov    $0x0,%eax
  802851:	eb 17                	jmp    80286a <fd_alloc+0x4d>
  802853:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802858:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80285d:	75 c9                	jne    802828 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80285f:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802865:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80286a:	5d                   	pop    %ebp
  80286b:	c3                   	ret    

0080286c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80286c:	55                   	push   %ebp
  80286d:	89 e5                	mov    %esp,%ebp
  80286f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802872:	83 f8 1f             	cmp    $0x1f,%eax
  802875:	77 36                	ja     8028ad <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802877:	c1 e0 0c             	shl    $0xc,%eax
  80287a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80287f:	89 c2                	mov    %eax,%edx
  802881:	c1 ea 16             	shr    $0x16,%edx
  802884:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80288b:	f6 c2 01             	test   $0x1,%dl
  80288e:	74 24                	je     8028b4 <fd_lookup+0x48>
  802890:	89 c2                	mov    %eax,%edx
  802892:	c1 ea 0c             	shr    $0xc,%edx
  802895:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80289c:	f6 c2 01             	test   $0x1,%dl
  80289f:	74 1a                	je     8028bb <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8028a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8028a4:	89 02                	mov    %eax,(%edx)
	return 0;
  8028a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8028ab:	eb 13                	jmp    8028c0 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8028ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028b2:	eb 0c                	jmp    8028c0 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8028b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8028b9:	eb 05                	jmp    8028c0 <fd_lookup+0x54>
  8028bb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8028c0:	5d                   	pop    %ebp
  8028c1:	c3                   	ret    

008028c2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8028c2:	55                   	push   %ebp
  8028c3:	89 e5                	mov    %esp,%ebp
  8028c5:	83 ec 08             	sub    $0x8,%esp
  8028c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8028cb:	ba 90 41 80 00       	mov    $0x804190,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8028d0:	eb 13                	jmp    8028e5 <dev_lookup+0x23>
  8028d2:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8028d5:	39 08                	cmp    %ecx,(%eax)
  8028d7:	75 0c                	jne    8028e5 <dev_lookup+0x23>
			*dev = devtab[i];
  8028d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8028dc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8028de:	b8 00 00 00 00       	mov    $0x0,%eax
  8028e3:	eb 2e                	jmp    802913 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8028e5:	8b 02                	mov    (%edx),%eax
  8028e7:	85 c0                	test   %eax,%eax
  8028e9:	75 e7                	jne    8028d2 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8028eb:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8028f0:	8b 40 48             	mov    0x48(%eax),%eax
  8028f3:	83 ec 04             	sub    $0x4,%esp
  8028f6:	51                   	push   %ecx
  8028f7:	50                   	push   %eax
  8028f8:	68 10 41 80 00       	push   $0x804110
  8028fd:	e8 53 f1 ff ff       	call   801a55 <cprintf>
	*dev = 0;
  802902:	8b 45 0c             	mov    0xc(%ebp),%eax
  802905:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80290b:	83 c4 10             	add    $0x10,%esp
  80290e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  802913:	c9                   	leave  
  802914:	c3                   	ret    

00802915 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  802915:	55                   	push   %ebp
  802916:	89 e5                	mov    %esp,%ebp
  802918:	56                   	push   %esi
  802919:	53                   	push   %ebx
  80291a:	83 ec 10             	sub    $0x10,%esp
  80291d:	8b 75 08             	mov    0x8(%ebp),%esi
  802920:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  802923:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802926:	50                   	push   %eax
  802927:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80292d:	c1 e8 0c             	shr    $0xc,%eax
  802930:	50                   	push   %eax
  802931:	e8 36 ff ff ff       	call   80286c <fd_lookup>
  802936:	83 c4 08             	add    $0x8,%esp
  802939:	85 c0                	test   %eax,%eax
  80293b:	78 05                	js     802942 <fd_close+0x2d>
	    || fd != fd2)
  80293d:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  802940:	74 0c                	je     80294e <fd_close+0x39>
		return (must_exist ? r : 0);
  802942:	84 db                	test   %bl,%bl
  802944:	ba 00 00 00 00       	mov    $0x0,%edx
  802949:	0f 44 c2             	cmove  %edx,%eax
  80294c:	eb 41                	jmp    80298f <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80294e:	83 ec 08             	sub    $0x8,%esp
  802951:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802954:	50                   	push   %eax
  802955:	ff 36                	pushl  (%esi)
  802957:	e8 66 ff ff ff       	call   8028c2 <dev_lookup>
  80295c:	89 c3                	mov    %eax,%ebx
  80295e:	83 c4 10             	add    $0x10,%esp
  802961:	85 c0                	test   %eax,%eax
  802963:	78 1a                	js     80297f <fd_close+0x6a>
		if (dev->dev_close)
  802965:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802968:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80296b:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  802970:	85 c0                	test   %eax,%eax
  802972:	74 0b                	je     80297f <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  802974:	83 ec 0c             	sub    $0xc,%esp
  802977:	56                   	push   %esi
  802978:	ff d0                	call   *%eax
  80297a:	89 c3                	mov    %eax,%ebx
  80297c:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80297f:	83 ec 08             	sub    $0x8,%esp
  802982:	56                   	push   %esi
  802983:	6a 00                	push   $0x0
  802985:	e8 57 fb ff ff       	call   8024e1 <sys_page_unmap>
	return r;
  80298a:	83 c4 10             	add    $0x10,%esp
  80298d:	89 d8                	mov    %ebx,%eax
}
  80298f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802992:	5b                   	pop    %ebx
  802993:	5e                   	pop    %esi
  802994:	5d                   	pop    %ebp
  802995:	c3                   	ret    

00802996 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802996:	55                   	push   %ebp
  802997:	89 e5                	mov    %esp,%ebp
  802999:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80299c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80299f:	50                   	push   %eax
  8029a0:	ff 75 08             	pushl  0x8(%ebp)
  8029a3:	e8 c4 fe ff ff       	call   80286c <fd_lookup>
  8029a8:	83 c4 08             	add    $0x8,%esp
  8029ab:	85 c0                	test   %eax,%eax
  8029ad:	78 10                	js     8029bf <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8029af:	83 ec 08             	sub    $0x8,%esp
  8029b2:	6a 01                	push   $0x1
  8029b4:	ff 75 f4             	pushl  -0xc(%ebp)
  8029b7:	e8 59 ff ff ff       	call   802915 <fd_close>
  8029bc:	83 c4 10             	add    $0x10,%esp
}
  8029bf:	c9                   	leave  
  8029c0:	c3                   	ret    

008029c1 <close_all>:

void
close_all(void)
{
  8029c1:	55                   	push   %ebp
  8029c2:	89 e5                	mov    %esp,%ebp
  8029c4:	53                   	push   %ebx
  8029c5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8029c8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8029cd:	83 ec 0c             	sub    $0xc,%esp
  8029d0:	53                   	push   %ebx
  8029d1:	e8 c0 ff ff ff       	call   802996 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8029d6:	83 c3 01             	add    $0x1,%ebx
  8029d9:	83 c4 10             	add    $0x10,%esp
  8029dc:	83 fb 20             	cmp    $0x20,%ebx
  8029df:	75 ec                	jne    8029cd <close_all+0xc>
		close(i);
}
  8029e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8029e4:	c9                   	leave  
  8029e5:	c3                   	ret    

008029e6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8029e6:	55                   	push   %ebp
  8029e7:	89 e5                	mov    %esp,%ebp
  8029e9:	57                   	push   %edi
  8029ea:	56                   	push   %esi
  8029eb:	53                   	push   %ebx
  8029ec:	83 ec 2c             	sub    $0x2c,%esp
  8029ef:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8029f2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8029f5:	50                   	push   %eax
  8029f6:	ff 75 08             	pushl  0x8(%ebp)
  8029f9:	e8 6e fe ff ff       	call   80286c <fd_lookup>
  8029fe:	83 c4 08             	add    $0x8,%esp
  802a01:	85 c0                	test   %eax,%eax
  802a03:	0f 88 c1 00 00 00    	js     802aca <dup+0xe4>
		return r;
	close(newfdnum);
  802a09:	83 ec 0c             	sub    $0xc,%esp
  802a0c:	56                   	push   %esi
  802a0d:	e8 84 ff ff ff       	call   802996 <close>

	newfd = INDEX2FD(newfdnum);
  802a12:	89 f3                	mov    %esi,%ebx
  802a14:	c1 e3 0c             	shl    $0xc,%ebx
  802a17:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  802a1d:	83 c4 04             	add    $0x4,%esp
  802a20:	ff 75 e4             	pushl  -0x1c(%ebp)
  802a23:	e8 de fd ff ff       	call   802806 <fd2data>
  802a28:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  802a2a:	89 1c 24             	mov    %ebx,(%esp)
  802a2d:	e8 d4 fd ff ff       	call   802806 <fd2data>
  802a32:	83 c4 10             	add    $0x10,%esp
  802a35:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  802a38:	89 f8                	mov    %edi,%eax
  802a3a:	c1 e8 16             	shr    $0x16,%eax
  802a3d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  802a44:	a8 01                	test   $0x1,%al
  802a46:	74 37                	je     802a7f <dup+0x99>
  802a48:	89 f8                	mov    %edi,%eax
  802a4a:	c1 e8 0c             	shr    $0xc,%eax
  802a4d:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a54:	f6 c2 01             	test   $0x1,%dl
  802a57:	74 26                	je     802a7f <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802a59:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a60:	83 ec 0c             	sub    $0xc,%esp
  802a63:	25 07 0e 00 00       	and    $0xe07,%eax
  802a68:	50                   	push   %eax
  802a69:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a6c:	6a 00                	push   $0x0
  802a6e:	57                   	push   %edi
  802a6f:	6a 00                	push   $0x0
  802a71:	e8 29 fa ff ff       	call   80249f <sys_page_map>
  802a76:	89 c7                	mov    %eax,%edi
  802a78:	83 c4 20             	add    $0x20,%esp
  802a7b:	85 c0                	test   %eax,%eax
  802a7d:	78 2e                	js     802aad <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a7f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802a82:	89 d0                	mov    %edx,%eax
  802a84:	c1 e8 0c             	shr    $0xc,%eax
  802a87:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a8e:	83 ec 0c             	sub    $0xc,%esp
  802a91:	25 07 0e 00 00       	and    $0xe07,%eax
  802a96:	50                   	push   %eax
  802a97:	53                   	push   %ebx
  802a98:	6a 00                	push   $0x0
  802a9a:	52                   	push   %edx
  802a9b:	6a 00                	push   $0x0
  802a9d:	e8 fd f9 ff ff       	call   80249f <sys_page_map>
  802aa2:	89 c7                	mov    %eax,%edi
  802aa4:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802aa7:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802aa9:	85 ff                	test   %edi,%edi
  802aab:	79 1d                	jns    802aca <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802aad:	83 ec 08             	sub    $0x8,%esp
  802ab0:	53                   	push   %ebx
  802ab1:	6a 00                	push   $0x0
  802ab3:	e8 29 fa ff ff       	call   8024e1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802ab8:	83 c4 08             	add    $0x8,%esp
  802abb:	ff 75 d4             	pushl  -0x2c(%ebp)
  802abe:	6a 00                	push   $0x0
  802ac0:	e8 1c fa ff ff       	call   8024e1 <sys_page_unmap>
	return r;
  802ac5:	83 c4 10             	add    $0x10,%esp
  802ac8:	89 f8                	mov    %edi,%eax
}
  802aca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802acd:	5b                   	pop    %ebx
  802ace:	5e                   	pop    %esi
  802acf:	5f                   	pop    %edi
  802ad0:	5d                   	pop    %ebp
  802ad1:	c3                   	ret    

00802ad2 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802ad2:	55                   	push   %ebp
  802ad3:	89 e5                	mov    %esp,%ebp
  802ad5:	53                   	push   %ebx
  802ad6:	83 ec 14             	sub    $0x14,%esp
  802ad9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802adc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802adf:	50                   	push   %eax
  802ae0:	53                   	push   %ebx
  802ae1:	e8 86 fd ff ff       	call   80286c <fd_lookup>
  802ae6:	83 c4 08             	add    $0x8,%esp
  802ae9:	89 c2                	mov    %eax,%edx
  802aeb:	85 c0                	test   %eax,%eax
  802aed:	78 6d                	js     802b5c <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802aef:	83 ec 08             	sub    $0x8,%esp
  802af2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802af5:	50                   	push   %eax
  802af6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802af9:	ff 30                	pushl  (%eax)
  802afb:	e8 c2 fd ff ff       	call   8028c2 <dev_lookup>
  802b00:	83 c4 10             	add    $0x10,%esp
  802b03:	85 c0                	test   %eax,%eax
  802b05:	78 4c                	js     802b53 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802b07:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802b0a:	8b 42 08             	mov    0x8(%edx),%eax
  802b0d:	83 e0 03             	and    $0x3,%eax
  802b10:	83 f8 01             	cmp    $0x1,%eax
  802b13:	75 21                	jne    802b36 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802b15:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b1a:	8b 40 48             	mov    0x48(%eax),%eax
  802b1d:	83 ec 04             	sub    $0x4,%esp
  802b20:	53                   	push   %ebx
  802b21:	50                   	push   %eax
  802b22:	68 54 41 80 00       	push   $0x804154
  802b27:	e8 29 ef ff ff       	call   801a55 <cprintf>
		return -E_INVAL;
  802b2c:	83 c4 10             	add    $0x10,%esp
  802b2f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802b34:	eb 26                	jmp    802b5c <read+0x8a>
	}
	if (!dev->dev_read)
  802b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802b39:	8b 40 08             	mov    0x8(%eax),%eax
  802b3c:	85 c0                	test   %eax,%eax
  802b3e:	74 17                	je     802b57 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802b40:	83 ec 04             	sub    $0x4,%esp
  802b43:	ff 75 10             	pushl  0x10(%ebp)
  802b46:	ff 75 0c             	pushl  0xc(%ebp)
  802b49:	52                   	push   %edx
  802b4a:	ff d0                	call   *%eax
  802b4c:	89 c2                	mov    %eax,%edx
  802b4e:	83 c4 10             	add    $0x10,%esp
  802b51:	eb 09                	jmp    802b5c <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b53:	89 c2                	mov    %eax,%edx
  802b55:	eb 05                	jmp    802b5c <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802b57:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802b5c:	89 d0                	mov    %edx,%eax
  802b5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b61:	c9                   	leave  
  802b62:	c3                   	ret    

00802b63 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802b63:	55                   	push   %ebp
  802b64:	89 e5                	mov    %esp,%ebp
  802b66:	57                   	push   %edi
  802b67:	56                   	push   %esi
  802b68:	53                   	push   %ebx
  802b69:	83 ec 0c             	sub    $0xc,%esp
  802b6c:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b6f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b72:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b77:	eb 21                	jmp    802b9a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802b79:	83 ec 04             	sub    $0x4,%esp
  802b7c:	89 f0                	mov    %esi,%eax
  802b7e:	29 d8                	sub    %ebx,%eax
  802b80:	50                   	push   %eax
  802b81:	89 d8                	mov    %ebx,%eax
  802b83:	03 45 0c             	add    0xc(%ebp),%eax
  802b86:	50                   	push   %eax
  802b87:	57                   	push   %edi
  802b88:	e8 45 ff ff ff       	call   802ad2 <read>
		if (m < 0)
  802b8d:	83 c4 10             	add    $0x10,%esp
  802b90:	85 c0                	test   %eax,%eax
  802b92:	78 10                	js     802ba4 <readn+0x41>
			return m;
		if (m == 0)
  802b94:	85 c0                	test   %eax,%eax
  802b96:	74 0a                	je     802ba2 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b98:	01 c3                	add    %eax,%ebx
  802b9a:	39 f3                	cmp    %esi,%ebx
  802b9c:	72 db                	jb     802b79 <readn+0x16>
  802b9e:	89 d8                	mov    %ebx,%eax
  802ba0:	eb 02                	jmp    802ba4 <readn+0x41>
  802ba2:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  802ba4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802ba7:	5b                   	pop    %ebx
  802ba8:	5e                   	pop    %esi
  802ba9:	5f                   	pop    %edi
  802baa:	5d                   	pop    %ebp
  802bab:	c3                   	ret    

00802bac <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802bac:	55                   	push   %ebp
  802bad:	89 e5                	mov    %esp,%ebp
  802baf:	53                   	push   %ebx
  802bb0:	83 ec 14             	sub    $0x14,%esp
  802bb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802bb6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802bb9:	50                   	push   %eax
  802bba:	53                   	push   %ebx
  802bbb:	e8 ac fc ff ff       	call   80286c <fd_lookup>
  802bc0:	83 c4 08             	add    $0x8,%esp
  802bc3:	89 c2                	mov    %eax,%edx
  802bc5:	85 c0                	test   %eax,%eax
  802bc7:	78 68                	js     802c31 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bc9:	83 ec 08             	sub    $0x8,%esp
  802bcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802bcf:	50                   	push   %eax
  802bd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802bd3:	ff 30                	pushl  (%eax)
  802bd5:	e8 e8 fc ff ff       	call   8028c2 <dev_lookup>
  802bda:	83 c4 10             	add    $0x10,%esp
  802bdd:	85 c0                	test   %eax,%eax
  802bdf:	78 47                	js     802c28 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802be1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802be4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802be8:	75 21                	jne    802c0b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802bea:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802bef:	8b 40 48             	mov    0x48(%eax),%eax
  802bf2:	83 ec 04             	sub    $0x4,%esp
  802bf5:	53                   	push   %ebx
  802bf6:	50                   	push   %eax
  802bf7:	68 70 41 80 00       	push   $0x804170
  802bfc:	e8 54 ee ff ff       	call   801a55 <cprintf>
		return -E_INVAL;
  802c01:	83 c4 10             	add    $0x10,%esp
  802c04:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c09:	eb 26                	jmp    802c31 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802c0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c0e:	8b 52 0c             	mov    0xc(%edx),%edx
  802c11:	85 d2                	test   %edx,%edx
  802c13:	74 17                	je     802c2c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802c15:	83 ec 04             	sub    $0x4,%esp
  802c18:	ff 75 10             	pushl  0x10(%ebp)
  802c1b:	ff 75 0c             	pushl  0xc(%ebp)
  802c1e:	50                   	push   %eax
  802c1f:	ff d2                	call   *%edx
  802c21:	89 c2                	mov    %eax,%edx
  802c23:	83 c4 10             	add    $0x10,%esp
  802c26:	eb 09                	jmp    802c31 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c28:	89 c2                	mov    %eax,%edx
  802c2a:	eb 05                	jmp    802c31 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802c2c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802c31:	89 d0                	mov    %edx,%eax
  802c33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c36:	c9                   	leave  
  802c37:	c3                   	ret    

00802c38 <seek>:

int
seek(int fdnum, off_t offset)
{
  802c38:	55                   	push   %ebp
  802c39:	89 e5                	mov    %esp,%ebp
  802c3b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802c3e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802c41:	50                   	push   %eax
  802c42:	ff 75 08             	pushl  0x8(%ebp)
  802c45:	e8 22 fc ff ff       	call   80286c <fd_lookup>
  802c4a:	83 c4 08             	add    $0x8,%esp
  802c4d:	85 c0                	test   %eax,%eax
  802c4f:	78 0e                	js     802c5f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802c51:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802c54:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c57:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802c5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802c5f:	c9                   	leave  
  802c60:	c3                   	ret    

00802c61 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802c61:	55                   	push   %ebp
  802c62:	89 e5                	mov    %esp,%ebp
  802c64:	53                   	push   %ebx
  802c65:	83 ec 14             	sub    $0x14,%esp
  802c68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c6b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c6e:	50                   	push   %eax
  802c6f:	53                   	push   %ebx
  802c70:	e8 f7 fb ff ff       	call   80286c <fd_lookup>
  802c75:	83 c4 08             	add    $0x8,%esp
  802c78:	89 c2                	mov    %eax,%edx
  802c7a:	85 c0                	test   %eax,%eax
  802c7c:	78 65                	js     802ce3 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c7e:	83 ec 08             	sub    $0x8,%esp
  802c81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c84:	50                   	push   %eax
  802c85:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c88:	ff 30                	pushl  (%eax)
  802c8a:	e8 33 fc ff ff       	call   8028c2 <dev_lookup>
  802c8f:	83 c4 10             	add    $0x10,%esp
  802c92:	85 c0                	test   %eax,%eax
  802c94:	78 44                	js     802cda <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c96:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c99:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c9d:	75 21                	jne    802cc0 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802c9f:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802ca4:	8b 40 48             	mov    0x48(%eax),%eax
  802ca7:	83 ec 04             	sub    $0x4,%esp
  802caa:	53                   	push   %ebx
  802cab:	50                   	push   %eax
  802cac:	68 30 41 80 00       	push   $0x804130
  802cb1:	e8 9f ed ff ff       	call   801a55 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802cb6:	83 c4 10             	add    $0x10,%esp
  802cb9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802cbe:	eb 23                	jmp    802ce3 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802cc0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802cc3:	8b 52 18             	mov    0x18(%edx),%edx
  802cc6:	85 d2                	test   %edx,%edx
  802cc8:	74 14                	je     802cde <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802cca:	83 ec 08             	sub    $0x8,%esp
  802ccd:	ff 75 0c             	pushl  0xc(%ebp)
  802cd0:	50                   	push   %eax
  802cd1:	ff d2                	call   *%edx
  802cd3:	89 c2                	mov    %eax,%edx
  802cd5:	83 c4 10             	add    $0x10,%esp
  802cd8:	eb 09                	jmp    802ce3 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cda:	89 c2                	mov    %eax,%edx
  802cdc:	eb 05                	jmp    802ce3 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802cde:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802ce3:	89 d0                	mov    %edx,%eax
  802ce5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802ce8:	c9                   	leave  
  802ce9:	c3                   	ret    

00802cea <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802cea:	55                   	push   %ebp
  802ceb:	89 e5                	mov    %esp,%ebp
  802ced:	53                   	push   %ebx
  802cee:	83 ec 14             	sub    $0x14,%esp
  802cf1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802cf4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cf7:	50                   	push   %eax
  802cf8:	ff 75 08             	pushl  0x8(%ebp)
  802cfb:	e8 6c fb ff ff       	call   80286c <fd_lookup>
  802d00:	83 c4 08             	add    $0x8,%esp
  802d03:	89 c2                	mov    %eax,%edx
  802d05:	85 c0                	test   %eax,%eax
  802d07:	78 58                	js     802d61 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d09:	83 ec 08             	sub    $0x8,%esp
  802d0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802d0f:	50                   	push   %eax
  802d10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d13:	ff 30                	pushl  (%eax)
  802d15:	e8 a8 fb ff ff       	call   8028c2 <dev_lookup>
  802d1a:	83 c4 10             	add    $0x10,%esp
  802d1d:	85 c0                	test   %eax,%eax
  802d1f:	78 37                	js     802d58 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d24:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802d28:	74 32                	je     802d5c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802d2a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802d2d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802d34:	00 00 00 
	stat->st_isdir = 0;
  802d37:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802d3e:	00 00 00 
	stat->st_dev = dev;
  802d41:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802d47:	83 ec 08             	sub    $0x8,%esp
  802d4a:	53                   	push   %ebx
  802d4b:	ff 75 f0             	pushl  -0x10(%ebp)
  802d4e:	ff 50 14             	call   *0x14(%eax)
  802d51:	89 c2                	mov    %eax,%edx
  802d53:	83 c4 10             	add    $0x10,%esp
  802d56:	eb 09                	jmp    802d61 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d58:	89 c2                	mov    %eax,%edx
  802d5a:	eb 05                	jmp    802d61 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802d5c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802d61:	89 d0                	mov    %edx,%eax
  802d63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d66:	c9                   	leave  
  802d67:	c3                   	ret    

00802d68 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802d68:	55                   	push   %ebp
  802d69:	89 e5                	mov    %esp,%ebp
  802d6b:	56                   	push   %esi
  802d6c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802d6d:	83 ec 08             	sub    $0x8,%esp
  802d70:	6a 00                	push   $0x0
  802d72:	ff 75 08             	pushl  0x8(%ebp)
  802d75:	e8 e9 01 00 00       	call   802f63 <open>
  802d7a:	89 c3                	mov    %eax,%ebx
  802d7c:	83 c4 10             	add    $0x10,%esp
  802d7f:	85 c0                	test   %eax,%eax
  802d81:	78 1b                	js     802d9e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802d83:	83 ec 08             	sub    $0x8,%esp
  802d86:	ff 75 0c             	pushl  0xc(%ebp)
  802d89:	50                   	push   %eax
  802d8a:	e8 5b ff ff ff       	call   802cea <fstat>
  802d8f:	89 c6                	mov    %eax,%esi
	close(fd);
  802d91:	89 1c 24             	mov    %ebx,(%esp)
  802d94:	e8 fd fb ff ff       	call   802996 <close>
	return r;
  802d99:	83 c4 10             	add    $0x10,%esp
  802d9c:	89 f0                	mov    %esi,%eax
}
  802d9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802da1:	5b                   	pop    %ebx
  802da2:	5e                   	pop    %esi
  802da3:	5d                   	pop    %ebp
  802da4:	c3                   	ret    

00802da5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802da5:	55                   	push   %ebp
  802da6:	89 e5                	mov    %esp,%ebp
  802da8:	56                   	push   %esi
  802da9:	53                   	push   %ebx
  802daa:	89 c6                	mov    %eax,%esi
  802dac:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802dae:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802db5:	75 12                	jne    802dc9 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802db7:	83 ec 0c             	sub    $0xc,%esp
  802dba:	6a 01                	push   $0x1
  802dbc:	e8 fc f9 ff ff       	call   8027bd <ipc_find_env>
  802dc1:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802dc6:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802dc9:	6a 07                	push   $0x7
  802dcb:	68 00 b0 80 00       	push   $0x80b000
  802dd0:	56                   	push   %esi
  802dd1:	ff 35 00 a0 80 00    	pushl  0x80a000
  802dd7:	e8 8d f9 ff ff       	call   802769 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  802ddc:	83 c4 0c             	add    $0xc,%esp
  802ddf:	6a 00                	push   $0x0
  802de1:	53                   	push   %ebx
  802de2:	6a 00                	push   $0x0
  802de4:	e8 fe f8 ff ff       	call   8026e7 <ipc_recv>
}
  802de9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dec:	5b                   	pop    %ebx
  802ded:	5e                   	pop    %esi
  802dee:	5d                   	pop    %ebp
  802def:	c3                   	ret    

00802df0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802df0:	55                   	push   %ebp
  802df1:	89 e5                	mov    %esp,%ebp
  802df3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802df6:	8b 45 08             	mov    0x8(%ebp),%eax
  802df9:	8b 40 0c             	mov    0xc(%eax),%eax
  802dfc:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802e01:	8b 45 0c             	mov    0xc(%ebp),%eax
  802e04:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802e09:	ba 00 00 00 00       	mov    $0x0,%edx
  802e0e:	b8 02 00 00 00       	mov    $0x2,%eax
  802e13:	e8 8d ff ff ff       	call   802da5 <fsipc>
}
  802e18:	c9                   	leave  
  802e19:	c3                   	ret    

00802e1a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802e1a:	55                   	push   %ebp
  802e1b:	89 e5                	mov    %esp,%ebp
  802e1d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802e20:	8b 45 08             	mov    0x8(%ebp),%eax
  802e23:	8b 40 0c             	mov    0xc(%eax),%eax
  802e26:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802e2b:	ba 00 00 00 00       	mov    $0x0,%edx
  802e30:	b8 06 00 00 00       	mov    $0x6,%eax
  802e35:	e8 6b ff ff ff       	call   802da5 <fsipc>
}
  802e3a:	c9                   	leave  
  802e3b:	c3                   	ret    

00802e3c <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802e3c:	55                   	push   %ebp
  802e3d:	89 e5                	mov    %esp,%ebp
  802e3f:	53                   	push   %ebx
  802e40:	83 ec 04             	sub    $0x4,%esp
  802e43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802e46:	8b 45 08             	mov    0x8(%ebp),%eax
  802e49:	8b 40 0c             	mov    0xc(%eax),%eax
  802e4c:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802e51:	ba 00 00 00 00       	mov    $0x0,%edx
  802e56:	b8 05 00 00 00       	mov    $0x5,%eax
  802e5b:	e8 45 ff ff ff       	call   802da5 <fsipc>
  802e60:	85 c0                	test   %eax,%eax
  802e62:	78 2c                	js     802e90 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802e64:	83 ec 08             	sub    $0x8,%esp
  802e67:	68 00 b0 80 00       	push   $0x80b000
  802e6c:	53                   	push   %ebx
  802e6d:	e8 e7 f1 ff ff       	call   802059 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802e72:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802e77:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802e7d:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802e82:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802e88:	83 c4 10             	add    $0x10,%esp
  802e8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e93:	c9                   	leave  
  802e94:	c3                   	ret    

00802e95 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802e95:	55                   	push   %ebp
  802e96:	89 e5                	mov    %esp,%ebp
  802e98:	83 ec 0c             	sub    $0xc,%esp
  802e9b:	8b 45 10             	mov    0x10(%ebp),%eax
  802e9e:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  802ea3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802ea8:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  802eab:	8b 55 08             	mov    0x8(%ebp),%edx
  802eae:	8b 52 0c             	mov    0xc(%edx),%edx
  802eb1:	89 15 00 b0 80 00    	mov    %edx,0x80b000
    fsipcbuf.write.req_n = n;
  802eb7:	a3 04 b0 80 00       	mov    %eax,0x80b004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  802ebc:	50                   	push   %eax
  802ebd:	ff 75 0c             	pushl  0xc(%ebp)
  802ec0:	68 08 b0 80 00       	push   $0x80b008
  802ec5:	e8 21 f3 ff ff       	call   8021eb <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  802eca:	ba 00 00 00 00       	mov    $0x0,%edx
  802ecf:	b8 04 00 00 00       	mov    $0x4,%eax
  802ed4:	e8 cc fe ff ff       	call   802da5 <fsipc>
            return r;

    return r;
}
  802ed9:	c9                   	leave  
  802eda:	c3                   	ret    

00802edb <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802edb:	55                   	push   %ebp
  802edc:	89 e5                	mov    %esp,%ebp
  802ede:	56                   	push   %esi
  802edf:	53                   	push   %ebx
  802ee0:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  802ee6:	8b 40 0c             	mov    0xc(%eax),%eax
  802ee9:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802eee:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802ef4:	ba 00 00 00 00       	mov    $0x0,%edx
  802ef9:	b8 03 00 00 00       	mov    $0x3,%eax
  802efe:	e8 a2 fe ff ff       	call   802da5 <fsipc>
  802f03:	89 c3                	mov    %eax,%ebx
  802f05:	85 c0                	test   %eax,%eax
  802f07:	78 51                	js     802f5a <devfile_read+0x7f>
		return r;
	assert(r <= n);
  802f09:	39 c6                	cmp    %eax,%esi
  802f0b:	73 19                	jae    802f26 <devfile_read+0x4b>
  802f0d:	68 a0 41 80 00       	push   $0x8041a0
  802f12:	68 fd 37 80 00       	push   $0x8037fd
  802f17:	68 82 00 00 00       	push   $0x82
  802f1c:	68 a7 41 80 00       	push   $0x8041a7
  802f21:	e8 56 ea ff ff       	call   80197c <_panic>
	assert(r <= PGSIZE);
  802f26:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802f2b:	7e 19                	jle    802f46 <devfile_read+0x6b>
  802f2d:	68 b2 41 80 00       	push   $0x8041b2
  802f32:	68 fd 37 80 00       	push   $0x8037fd
  802f37:	68 83 00 00 00       	push   $0x83
  802f3c:	68 a7 41 80 00       	push   $0x8041a7
  802f41:	e8 36 ea ff ff       	call   80197c <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802f46:	83 ec 04             	sub    $0x4,%esp
  802f49:	50                   	push   %eax
  802f4a:	68 00 b0 80 00       	push   $0x80b000
  802f4f:	ff 75 0c             	pushl  0xc(%ebp)
  802f52:	e8 94 f2 ff ff       	call   8021eb <memmove>
	return r;
  802f57:	83 c4 10             	add    $0x10,%esp
}
  802f5a:	89 d8                	mov    %ebx,%eax
  802f5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f5f:	5b                   	pop    %ebx
  802f60:	5e                   	pop    %esi
  802f61:	5d                   	pop    %ebp
  802f62:	c3                   	ret    

00802f63 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802f63:	55                   	push   %ebp
  802f64:	89 e5                	mov    %esp,%ebp
  802f66:	53                   	push   %ebx
  802f67:	83 ec 20             	sub    $0x20,%esp
  802f6a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802f6d:	53                   	push   %ebx
  802f6e:	e8 ad f0 ff ff       	call   802020 <strlen>
  802f73:	83 c4 10             	add    $0x10,%esp
  802f76:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802f7b:	7f 67                	jg     802fe4 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f7d:	83 ec 0c             	sub    $0xc,%esp
  802f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f83:	50                   	push   %eax
  802f84:	e8 94 f8 ff ff       	call   80281d <fd_alloc>
  802f89:	83 c4 10             	add    $0x10,%esp
		return r;
  802f8c:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f8e:	85 c0                	test   %eax,%eax
  802f90:	78 57                	js     802fe9 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802f92:	83 ec 08             	sub    $0x8,%esp
  802f95:	53                   	push   %ebx
  802f96:	68 00 b0 80 00       	push   $0x80b000
  802f9b:	e8 b9 f0 ff ff       	call   802059 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802fa0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802fa3:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802fa8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802fab:	b8 01 00 00 00       	mov    $0x1,%eax
  802fb0:	e8 f0 fd ff ff       	call   802da5 <fsipc>
  802fb5:	89 c3                	mov    %eax,%ebx
  802fb7:	83 c4 10             	add    $0x10,%esp
  802fba:	85 c0                	test   %eax,%eax
  802fbc:	79 14                	jns    802fd2 <open+0x6f>
		fd_close(fd, 0);
  802fbe:	83 ec 08             	sub    $0x8,%esp
  802fc1:	6a 00                	push   $0x0
  802fc3:	ff 75 f4             	pushl  -0xc(%ebp)
  802fc6:	e8 4a f9 ff ff       	call   802915 <fd_close>
		return r;
  802fcb:	83 c4 10             	add    $0x10,%esp
  802fce:	89 da                	mov    %ebx,%edx
  802fd0:	eb 17                	jmp    802fe9 <open+0x86>
	}

	return fd2num(fd);
  802fd2:	83 ec 0c             	sub    $0xc,%esp
  802fd5:	ff 75 f4             	pushl  -0xc(%ebp)
  802fd8:	e8 19 f8 ff ff       	call   8027f6 <fd2num>
  802fdd:	89 c2                	mov    %eax,%edx
  802fdf:	83 c4 10             	add    $0x10,%esp
  802fe2:	eb 05                	jmp    802fe9 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802fe4:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802fe9:	89 d0                	mov    %edx,%eax
  802feb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802fee:	c9                   	leave  
  802fef:	c3                   	ret    

00802ff0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802ff0:	55                   	push   %ebp
  802ff1:	89 e5                	mov    %esp,%ebp
  802ff3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802ff6:	ba 00 00 00 00       	mov    $0x0,%edx
  802ffb:	b8 08 00 00 00       	mov    $0x8,%eax
  803000:	e8 a0 fd ff ff       	call   802da5 <fsipc>
}
  803005:	c9                   	leave  
  803006:	c3                   	ret    

00803007 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  803007:	55                   	push   %ebp
  803008:	89 e5                	mov    %esp,%ebp
  80300a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80300d:	89 d0                	mov    %edx,%eax
  80300f:	c1 e8 16             	shr    $0x16,%eax
  803012:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  803019:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80301e:	f6 c1 01             	test   $0x1,%cl
  803021:	74 1d                	je     803040 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  803023:	c1 ea 0c             	shr    $0xc,%edx
  803026:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80302d:	f6 c2 01             	test   $0x1,%dl
  803030:	74 0e                	je     803040 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803032:	c1 ea 0c             	shr    $0xc,%edx
  803035:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80303c:	ef 
  80303d:	0f b7 c0             	movzwl %ax,%eax
}
  803040:	5d                   	pop    %ebp
  803041:	c3                   	ret    

00803042 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  803042:	55                   	push   %ebp
  803043:	89 e5                	mov    %esp,%ebp
  803045:	56                   	push   %esi
  803046:	53                   	push   %ebx
  803047:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80304a:	83 ec 0c             	sub    $0xc,%esp
  80304d:	ff 75 08             	pushl  0x8(%ebp)
  803050:	e8 b1 f7 ff ff       	call   802806 <fd2data>
  803055:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803057:	83 c4 08             	add    $0x8,%esp
  80305a:	68 be 41 80 00       	push   $0x8041be
  80305f:	53                   	push   %ebx
  803060:	e8 f4 ef ff ff       	call   802059 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803065:	8b 46 04             	mov    0x4(%esi),%eax
  803068:	2b 06                	sub    (%esi),%eax
  80306a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  803070:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803077:	00 00 00 
	stat->st_dev = &devpipe;
  80307a:	c7 83 88 00 00 00 80 	movl   $0x809080,0x88(%ebx)
  803081:	90 80 00 
	return 0;
}
  803084:	b8 00 00 00 00       	mov    $0x0,%eax
  803089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80308c:	5b                   	pop    %ebx
  80308d:	5e                   	pop    %esi
  80308e:	5d                   	pop    %ebp
  80308f:	c3                   	ret    

00803090 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  803090:	55                   	push   %ebp
  803091:	89 e5                	mov    %esp,%ebp
  803093:	53                   	push   %ebx
  803094:	83 ec 0c             	sub    $0xc,%esp
  803097:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80309a:	53                   	push   %ebx
  80309b:	6a 00                	push   $0x0
  80309d:	e8 3f f4 ff ff       	call   8024e1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8030a2:	89 1c 24             	mov    %ebx,(%esp)
  8030a5:	e8 5c f7 ff ff       	call   802806 <fd2data>
  8030aa:	83 c4 08             	add    $0x8,%esp
  8030ad:	50                   	push   %eax
  8030ae:	6a 00                	push   $0x0
  8030b0:	e8 2c f4 ff ff       	call   8024e1 <sys_page_unmap>
}
  8030b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8030b8:	c9                   	leave  
  8030b9:	c3                   	ret    

008030ba <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8030ba:	55                   	push   %ebp
  8030bb:	89 e5                	mov    %esp,%ebp
  8030bd:	57                   	push   %edi
  8030be:	56                   	push   %esi
  8030bf:	53                   	push   %ebx
  8030c0:	83 ec 1c             	sub    $0x1c,%esp
  8030c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8030c6:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8030c8:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8030cd:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8030d0:	83 ec 0c             	sub    $0xc,%esp
  8030d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8030d6:	e8 2c ff ff ff       	call   803007 <pageref>
  8030db:	89 c3                	mov    %eax,%ebx
  8030dd:	89 3c 24             	mov    %edi,(%esp)
  8030e0:	e8 22 ff ff ff       	call   803007 <pageref>
  8030e5:	83 c4 10             	add    $0x10,%esp
  8030e8:	39 c3                	cmp    %eax,%ebx
  8030ea:	0f 94 c1             	sete   %cl
  8030ed:	0f b6 c9             	movzbl %cl,%ecx
  8030f0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8030f3:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8030f9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8030fc:	39 ce                	cmp    %ecx,%esi
  8030fe:	74 1b                	je     80311b <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  803100:	39 c3                	cmp    %eax,%ebx
  803102:	75 c4                	jne    8030c8 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  803104:	8b 42 58             	mov    0x58(%edx),%eax
  803107:	ff 75 e4             	pushl  -0x1c(%ebp)
  80310a:	50                   	push   %eax
  80310b:	56                   	push   %esi
  80310c:	68 c5 41 80 00       	push   $0x8041c5
  803111:	e8 3f e9 ff ff       	call   801a55 <cprintf>
  803116:	83 c4 10             	add    $0x10,%esp
  803119:	eb ad                	jmp    8030c8 <_pipeisclosed+0xe>
	}
}
  80311b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80311e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803121:	5b                   	pop    %ebx
  803122:	5e                   	pop    %esi
  803123:	5f                   	pop    %edi
  803124:	5d                   	pop    %ebp
  803125:	c3                   	ret    

00803126 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803126:	55                   	push   %ebp
  803127:	89 e5                	mov    %esp,%ebp
  803129:	57                   	push   %edi
  80312a:	56                   	push   %esi
  80312b:	53                   	push   %ebx
  80312c:	83 ec 28             	sub    $0x28,%esp
  80312f:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  803132:	56                   	push   %esi
  803133:	e8 ce f6 ff ff       	call   802806 <fd2data>
  803138:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80313a:	83 c4 10             	add    $0x10,%esp
  80313d:	bf 00 00 00 00       	mov    $0x0,%edi
  803142:	eb 4b                	jmp    80318f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  803144:	89 da                	mov    %ebx,%edx
  803146:	89 f0                	mov    %esi,%eax
  803148:	e8 6d ff ff ff       	call   8030ba <_pipeisclosed>
  80314d:	85 c0                	test   %eax,%eax
  80314f:	75 48                	jne    803199 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  803151:	e8 e7 f2 ff ff       	call   80243d <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  803156:	8b 43 04             	mov    0x4(%ebx),%eax
  803159:	8b 0b                	mov    (%ebx),%ecx
  80315b:	8d 51 20             	lea    0x20(%ecx),%edx
  80315e:	39 d0                	cmp    %edx,%eax
  803160:	73 e2                	jae    803144 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803162:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803165:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803169:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80316c:	89 c2                	mov    %eax,%edx
  80316e:	c1 fa 1f             	sar    $0x1f,%edx
  803171:	89 d1                	mov    %edx,%ecx
  803173:	c1 e9 1b             	shr    $0x1b,%ecx
  803176:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803179:	83 e2 1f             	and    $0x1f,%edx
  80317c:	29 ca                	sub    %ecx,%edx
  80317e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803182:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803186:	83 c0 01             	add    $0x1,%eax
  803189:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80318c:	83 c7 01             	add    $0x1,%edi
  80318f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803192:	75 c2                	jne    803156 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803194:	8b 45 10             	mov    0x10(%ebp),%eax
  803197:	eb 05                	jmp    80319e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803199:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80319e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031a1:	5b                   	pop    %ebx
  8031a2:	5e                   	pop    %esi
  8031a3:	5f                   	pop    %edi
  8031a4:	5d                   	pop    %ebp
  8031a5:	c3                   	ret    

008031a6 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8031a6:	55                   	push   %ebp
  8031a7:	89 e5                	mov    %esp,%ebp
  8031a9:	57                   	push   %edi
  8031aa:	56                   	push   %esi
  8031ab:	53                   	push   %ebx
  8031ac:	83 ec 18             	sub    $0x18,%esp
  8031af:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8031b2:	57                   	push   %edi
  8031b3:	e8 4e f6 ff ff       	call   802806 <fd2data>
  8031b8:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8031ba:	83 c4 10             	add    $0x10,%esp
  8031bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8031c2:	eb 3d                	jmp    803201 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8031c4:	85 db                	test   %ebx,%ebx
  8031c6:	74 04                	je     8031cc <devpipe_read+0x26>
				return i;
  8031c8:	89 d8                	mov    %ebx,%eax
  8031ca:	eb 44                	jmp    803210 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8031cc:	89 f2                	mov    %esi,%edx
  8031ce:	89 f8                	mov    %edi,%eax
  8031d0:	e8 e5 fe ff ff       	call   8030ba <_pipeisclosed>
  8031d5:	85 c0                	test   %eax,%eax
  8031d7:	75 32                	jne    80320b <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8031d9:	e8 5f f2 ff ff       	call   80243d <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8031de:	8b 06                	mov    (%esi),%eax
  8031e0:	3b 46 04             	cmp    0x4(%esi),%eax
  8031e3:	74 df                	je     8031c4 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8031e5:	99                   	cltd   
  8031e6:	c1 ea 1b             	shr    $0x1b,%edx
  8031e9:	01 d0                	add    %edx,%eax
  8031eb:	83 e0 1f             	and    $0x1f,%eax
  8031ee:	29 d0                	sub    %edx,%eax
  8031f0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8031f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8031f8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8031fb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8031fe:	83 c3 01             	add    $0x1,%ebx
  803201:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  803204:	75 d8                	jne    8031de <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  803206:	8b 45 10             	mov    0x10(%ebp),%eax
  803209:	eb 05                	jmp    803210 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80320b:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  803210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803213:	5b                   	pop    %ebx
  803214:	5e                   	pop    %esi
  803215:	5f                   	pop    %edi
  803216:	5d                   	pop    %ebp
  803217:	c3                   	ret    

00803218 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  803218:	55                   	push   %ebp
  803219:	89 e5                	mov    %esp,%ebp
  80321b:	56                   	push   %esi
  80321c:	53                   	push   %ebx
  80321d:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  803220:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803223:	50                   	push   %eax
  803224:	e8 f4 f5 ff ff       	call   80281d <fd_alloc>
  803229:	83 c4 10             	add    $0x10,%esp
  80322c:	89 c2                	mov    %eax,%edx
  80322e:	85 c0                	test   %eax,%eax
  803230:	0f 88 2c 01 00 00    	js     803362 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803236:	83 ec 04             	sub    $0x4,%esp
  803239:	68 07 04 00 00       	push   $0x407
  80323e:	ff 75 f4             	pushl  -0xc(%ebp)
  803241:	6a 00                	push   $0x0
  803243:	e8 14 f2 ff ff       	call   80245c <sys_page_alloc>
  803248:	83 c4 10             	add    $0x10,%esp
  80324b:	89 c2                	mov    %eax,%edx
  80324d:	85 c0                	test   %eax,%eax
  80324f:	0f 88 0d 01 00 00    	js     803362 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  803255:	83 ec 0c             	sub    $0xc,%esp
  803258:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80325b:	50                   	push   %eax
  80325c:	e8 bc f5 ff ff       	call   80281d <fd_alloc>
  803261:	89 c3                	mov    %eax,%ebx
  803263:	83 c4 10             	add    $0x10,%esp
  803266:	85 c0                	test   %eax,%eax
  803268:	0f 88 e2 00 00 00    	js     803350 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80326e:	83 ec 04             	sub    $0x4,%esp
  803271:	68 07 04 00 00       	push   $0x407
  803276:	ff 75 f0             	pushl  -0x10(%ebp)
  803279:	6a 00                	push   $0x0
  80327b:	e8 dc f1 ff ff       	call   80245c <sys_page_alloc>
  803280:	89 c3                	mov    %eax,%ebx
  803282:	83 c4 10             	add    $0x10,%esp
  803285:	85 c0                	test   %eax,%eax
  803287:	0f 88 c3 00 00 00    	js     803350 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80328d:	83 ec 0c             	sub    $0xc,%esp
  803290:	ff 75 f4             	pushl  -0xc(%ebp)
  803293:	e8 6e f5 ff ff       	call   802806 <fd2data>
  803298:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80329a:	83 c4 0c             	add    $0xc,%esp
  80329d:	68 07 04 00 00       	push   $0x407
  8032a2:	50                   	push   %eax
  8032a3:	6a 00                	push   $0x0
  8032a5:	e8 b2 f1 ff ff       	call   80245c <sys_page_alloc>
  8032aa:	89 c3                	mov    %eax,%ebx
  8032ac:	83 c4 10             	add    $0x10,%esp
  8032af:	85 c0                	test   %eax,%eax
  8032b1:	0f 88 89 00 00 00    	js     803340 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8032b7:	83 ec 0c             	sub    $0xc,%esp
  8032ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8032bd:	e8 44 f5 ff ff       	call   802806 <fd2data>
  8032c2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8032c9:	50                   	push   %eax
  8032ca:	6a 00                	push   $0x0
  8032cc:	56                   	push   %esi
  8032cd:	6a 00                	push   $0x0
  8032cf:	e8 cb f1 ff ff       	call   80249f <sys_page_map>
  8032d4:	89 c3                	mov    %eax,%ebx
  8032d6:	83 c4 20             	add    $0x20,%esp
  8032d9:	85 c0                	test   %eax,%eax
  8032db:	78 55                	js     803332 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8032dd:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8032e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032e6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8032e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8032eb:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8032f2:	8b 15 80 90 80 00    	mov    0x809080,%edx
  8032f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8032fb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8032fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  803300:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  803307:	83 ec 0c             	sub    $0xc,%esp
  80330a:	ff 75 f4             	pushl  -0xc(%ebp)
  80330d:	e8 e4 f4 ff ff       	call   8027f6 <fd2num>
  803312:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803315:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803317:	83 c4 04             	add    $0x4,%esp
  80331a:	ff 75 f0             	pushl  -0x10(%ebp)
  80331d:	e8 d4 f4 ff ff       	call   8027f6 <fd2num>
  803322:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803325:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803328:	83 c4 10             	add    $0x10,%esp
  80332b:	ba 00 00 00 00       	mov    $0x0,%edx
  803330:	eb 30                	jmp    803362 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  803332:	83 ec 08             	sub    $0x8,%esp
  803335:	56                   	push   %esi
  803336:	6a 00                	push   $0x0
  803338:	e8 a4 f1 ff ff       	call   8024e1 <sys_page_unmap>
  80333d:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  803340:	83 ec 08             	sub    $0x8,%esp
  803343:	ff 75 f0             	pushl  -0x10(%ebp)
  803346:	6a 00                	push   $0x0
  803348:	e8 94 f1 ff ff       	call   8024e1 <sys_page_unmap>
  80334d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  803350:	83 ec 08             	sub    $0x8,%esp
  803353:	ff 75 f4             	pushl  -0xc(%ebp)
  803356:	6a 00                	push   $0x0
  803358:	e8 84 f1 ff ff       	call   8024e1 <sys_page_unmap>
  80335d:	83 c4 10             	add    $0x10,%esp
  803360:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803362:	89 d0                	mov    %edx,%eax
  803364:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803367:	5b                   	pop    %ebx
  803368:	5e                   	pop    %esi
  803369:	5d                   	pop    %ebp
  80336a:	c3                   	ret    

0080336b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80336b:	55                   	push   %ebp
  80336c:	89 e5                	mov    %esp,%ebp
  80336e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803371:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803374:	50                   	push   %eax
  803375:	ff 75 08             	pushl  0x8(%ebp)
  803378:	e8 ef f4 ff ff       	call   80286c <fd_lookup>
  80337d:	83 c4 10             	add    $0x10,%esp
  803380:	85 c0                	test   %eax,%eax
  803382:	78 18                	js     80339c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803384:	83 ec 0c             	sub    $0xc,%esp
  803387:	ff 75 f4             	pushl  -0xc(%ebp)
  80338a:	e8 77 f4 ff ff       	call   802806 <fd2data>
	return _pipeisclosed(fd, p);
  80338f:	89 c2                	mov    %eax,%edx
  803391:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803394:	e8 21 fd ff ff       	call   8030ba <_pipeisclosed>
  803399:	83 c4 10             	add    $0x10,%esp
}
  80339c:	c9                   	leave  
  80339d:	c3                   	ret    

0080339e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80339e:	55                   	push   %ebp
  80339f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8033a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8033a6:	5d                   	pop    %ebp
  8033a7:	c3                   	ret    

008033a8 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8033a8:	55                   	push   %ebp
  8033a9:	89 e5                	mov    %esp,%ebp
  8033ab:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8033ae:	68 dd 41 80 00       	push   $0x8041dd
  8033b3:	ff 75 0c             	pushl  0xc(%ebp)
  8033b6:	e8 9e ec ff ff       	call   802059 <strcpy>
	return 0;
}
  8033bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8033c0:	c9                   	leave  
  8033c1:	c3                   	ret    

008033c2 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8033c2:	55                   	push   %ebp
  8033c3:	89 e5                	mov    %esp,%ebp
  8033c5:	57                   	push   %edi
  8033c6:	56                   	push   %esi
  8033c7:	53                   	push   %ebx
  8033c8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8033ce:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8033d3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8033d9:	eb 2d                	jmp    803408 <devcons_write+0x46>
		m = n - tot;
  8033db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8033de:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8033e0:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8033e3:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8033e8:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8033eb:	83 ec 04             	sub    $0x4,%esp
  8033ee:	53                   	push   %ebx
  8033ef:	03 45 0c             	add    0xc(%ebp),%eax
  8033f2:	50                   	push   %eax
  8033f3:	57                   	push   %edi
  8033f4:	e8 f2 ed ff ff       	call   8021eb <memmove>
		sys_cputs(buf, m);
  8033f9:	83 c4 08             	add    $0x8,%esp
  8033fc:	53                   	push   %ebx
  8033fd:	57                   	push   %edi
  8033fe:	e8 9d ef ff ff       	call   8023a0 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803403:	01 de                	add    %ebx,%esi
  803405:	83 c4 10             	add    $0x10,%esp
  803408:	89 f0                	mov    %esi,%eax
  80340a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80340d:	72 cc                	jb     8033db <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80340f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803412:	5b                   	pop    %ebx
  803413:	5e                   	pop    %esi
  803414:	5f                   	pop    %edi
  803415:	5d                   	pop    %ebp
  803416:	c3                   	ret    

00803417 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  803417:	55                   	push   %ebp
  803418:	89 e5                	mov    %esp,%ebp
  80341a:	83 ec 08             	sub    $0x8,%esp
  80341d:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  803422:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  803426:	74 2a                	je     803452 <devcons_read+0x3b>
  803428:	eb 05                	jmp    80342f <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80342a:	e8 0e f0 ff ff       	call   80243d <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80342f:	e8 8a ef ff ff       	call   8023be <sys_cgetc>
  803434:	85 c0                	test   %eax,%eax
  803436:	74 f2                	je     80342a <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  803438:	85 c0                	test   %eax,%eax
  80343a:	78 16                	js     803452 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80343c:	83 f8 04             	cmp    $0x4,%eax
  80343f:	74 0c                	je     80344d <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  803441:	8b 55 0c             	mov    0xc(%ebp),%edx
  803444:	88 02                	mov    %al,(%edx)
	return 1;
  803446:	b8 01 00 00 00       	mov    $0x1,%eax
  80344b:	eb 05                	jmp    803452 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80344d:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  803452:	c9                   	leave  
  803453:	c3                   	ret    

00803454 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  803454:	55                   	push   %ebp
  803455:	89 e5                	mov    %esp,%ebp
  803457:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80345a:	8b 45 08             	mov    0x8(%ebp),%eax
  80345d:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803460:	6a 01                	push   $0x1
  803462:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803465:	50                   	push   %eax
  803466:	e8 35 ef ff ff       	call   8023a0 <sys_cputs>
}
  80346b:	83 c4 10             	add    $0x10,%esp
  80346e:	c9                   	leave  
  80346f:	c3                   	ret    

00803470 <getchar>:

int
getchar(void)
{
  803470:	55                   	push   %ebp
  803471:	89 e5                	mov    %esp,%ebp
  803473:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803476:	6a 01                	push   $0x1
  803478:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80347b:	50                   	push   %eax
  80347c:	6a 00                	push   $0x0
  80347e:	e8 4f f6 ff ff       	call   802ad2 <read>
	if (r < 0)
  803483:	83 c4 10             	add    $0x10,%esp
  803486:	85 c0                	test   %eax,%eax
  803488:	78 0f                	js     803499 <getchar+0x29>
		return r;
	if (r < 1)
  80348a:	85 c0                	test   %eax,%eax
  80348c:	7e 06                	jle    803494 <getchar+0x24>
		return -E_EOF;
	return c;
  80348e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803492:	eb 05                	jmp    803499 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803494:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  803499:	c9                   	leave  
  80349a:	c3                   	ret    

0080349b <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80349b:	55                   	push   %ebp
  80349c:	89 e5                	mov    %esp,%ebp
  80349e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8034a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8034a4:	50                   	push   %eax
  8034a5:	ff 75 08             	pushl  0x8(%ebp)
  8034a8:	e8 bf f3 ff ff       	call   80286c <fd_lookup>
  8034ad:	83 c4 10             	add    $0x10,%esp
  8034b0:	85 c0                	test   %eax,%eax
  8034b2:	78 11                	js     8034c5 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8034b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034b7:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  8034bd:	39 10                	cmp    %edx,(%eax)
  8034bf:	0f 94 c0             	sete   %al
  8034c2:	0f b6 c0             	movzbl %al,%eax
}
  8034c5:	c9                   	leave  
  8034c6:	c3                   	ret    

008034c7 <opencons>:

int
opencons(void)
{
  8034c7:	55                   	push   %ebp
  8034c8:	89 e5                	mov    %esp,%ebp
  8034ca:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8034cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8034d0:	50                   	push   %eax
  8034d1:	e8 47 f3 ff ff       	call   80281d <fd_alloc>
  8034d6:	83 c4 10             	add    $0x10,%esp
		return r;
  8034d9:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8034db:	85 c0                	test   %eax,%eax
  8034dd:	78 3e                	js     80351d <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8034df:	83 ec 04             	sub    $0x4,%esp
  8034e2:	68 07 04 00 00       	push   $0x407
  8034e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8034ea:	6a 00                	push   $0x0
  8034ec:	e8 6b ef ff ff       	call   80245c <sys_page_alloc>
  8034f1:	83 c4 10             	add    $0x10,%esp
		return r;
  8034f4:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8034f6:	85 c0                	test   %eax,%eax
  8034f8:	78 23                	js     80351d <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8034fa:	8b 15 9c 90 80 00    	mov    0x80909c,%edx
  803500:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803503:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  803505:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803508:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80350f:	83 ec 0c             	sub    $0xc,%esp
  803512:	50                   	push   %eax
  803513:	e8 de f2 ff ff       	call   8027f6 <fd2num>
  803518:	89 c2                	mov    %eax,%edx
  80351a:	83 c4 10             	add    $0x10,%esp
}
  80351d:	89 d0                	mov    %edx,%eax
  80351f:	c9                   	leave  
  803520:	c3                   	ret    
  803521:	66 90                	xchg   %ax,%ax
  803523:	66 90                	xchg   %ax,%ax
  803525:	66 90                	xchg   %ax,%ax
  803527:	66 90                	xchg   %ax,%ax
  803529:	66 90                	xchg   %ax,%ax
  80352b:	66 90                	xchg   %ax,%ax
  80352d:	66 90                	xchg   %ax,%ax
  80352f:	90                   	nop

00803530 <__udivdi3>:
  803530:	55                   	push   %ebp
  803531:	57                   	push   %edi
  803532:	56                   	push   %esi
  803533:	53                   	push   %ebx
  803534:	83 ec 1c             	sub    $0x1c,%esp
  803537:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80353b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80353f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  803543:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803547:	85 f6                	test   %esi,%esi
  803549:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80354d:	89 ca                	mov    %ecx,%edx
  80354f:	89 f8                	mov    %edi,%eax
  803551:	75 3d                	jne    803590 <__udivdi3+0x60>
  803553:	39 cf                	cmp    %ecx,%edi
  803555:	0f 87 c5 00 00 00    	ja     803620 <__udivdi3+0xf0>
  80355b:	85 ff                	test   %edi,%edi
  80355d:	89 fd                	mov    %edi,%ebp
  80355f:	75 0b                	jne    80356c <__udivdi3+0x3c>
  803561:	b8 01 00 00 00       	mov    $0x1,%eax
  803566:	31 d2                	xor    %edx,%edx
  803568:	f7 f7                	div    %edi
  80356a:	89 c5                	mov    %eax,%ebp
  80356c:	89 c8                	mov    %ecx,%eax
  80356e:	31 d2                	xor    %edx,%edx
  803570:	f7 f5                	div    %ebp
  803572:	89 c1                	mov    %eax,%ecx
  803574:	89 d8                	mov    %ebx,%eax
  803576:	89 cf                	mov    %ecx,%edi
  803578:	f7 f5                	div    %ebp
  80357a:	89 c3                	mov    %eax,%ebx
  80357c:	89 d8                	mov    %ebx,%eax
  80357e:	89 fa                	mov    %edi,%edx
  803580:	83 c4 1c             	add    $0x1c,%esp
  803583:	5b                   	pop    %ebx
  803584:	5e                   	pop    %esi
  803585:	5f                   	pop    %edi
  803586:	5d                   	pop    %ebp
  803587:	c3                   	ret    
  803588:	90                   	nop
  803589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803590:	39 ce                	cmp    %ecx,%esi
  803592:	77 74                	ja     803608 <__udivdi3+0xd8>
  803594:	0f bd fe             	bsr    %esi,%edi
  803597:	83 f7 1f             	xor    $0x1f,%edi
  80359a:	0f 84 98 00 00 00    	je     803638 <__udivdi3+0x108>
  8035a0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8035a5:	89 f9                	mov    %edi,%ecx
  8035a7:	89 c5                	mov    %eax,%ebp
  8035a9:	29 fb                	sub    %edi,%ebx
  8035ab:	d3 e6                	shl    %cl,%esi
  8035ad:	89 d9                	mov    %ebx,%ecx
  8035af:	d3 ed                	shr    %cl,%ebp
  8035b1:	89 f9                	mov    %edi,%ecx
  8035b3:	d3 e0                	shl    %cl,%eax
  8035b5:	09 ee                	or     %ebp,%esi
  8035b7:	89 d9                	mov    %ebx,%ecx
  8035b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8035bd:	89 d5                	mov    %edx,%ebp
  8035bf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8035c3:	d3 ed                	shr    %cl,%ebp
  8035c5:	89 f9                	mov    %edi,%ecx
  8035c7:	d3 e2                	shl    %cl,%edx
  8035c9:	89 d9                	mov    %ebx,%ecx
  8035cb:	d3 e8                	shr    %cl,%eax
  8035cd:	09 c2                	or     %eax,%edx
  8035cf:	89 d0                	mov    %edx,%eax
  8035d1:	89 ea                	mov    %ebp,%edx
  8035d3:	f7 f6                	div    %esi
  8035d5:	89 d5                	mov    %edx,%ebp
  8035d7:	89 c3                	mov    %eax,%ebx
  8035d9:	f7 64 24 0c          	mull   0xc(%esp)
  8035dd:	39 d5                	cmp    %edx,%ebp
  8035df:	72 10                	jb     8035f1 <__udivdi3+0xc1>
  8035e1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8035e5:	89 f9                	mov    %edi,%ecx
  8035e7:	d3 e6                	shl    %cl,%esi
  8035e9:	39 c6                	cmp    %eax,%esi
  8035eb:	73 07                	jae    8035f4 <__udivdi3+0xc4>
  8035ed:	39 d5                	cmp    %edx,%ebp
  8035ef:	75 03                	jne    8035f4 <__udivdi3+0xc4>
  8035f1:	83 eb 01             	sub    $0x1,%ebx
  8035f4:	31 ff                	xor    %edi,%edi
  8035f6:	89 d8                	mov    %ebx,%eax
  8035f8:	89 fa                	mov    %edi,%edx
  8035fa:	83 c4 1c             	add    $0x1c,%esp
  8035fd:	5b                   	pop    %ebx
  8035fe:	5e                   	pop    %esi
  8035ff:	5f                   	pop    %edi
  803600:	5d                   	pop    %ebp
  803601:	c3                   	ret    
  803602:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803608:	31 ff                	xor    %edi,%edi
  80360a:	31 db                	xor    %ebx,%ebx
  80360c:	89 d8                	mov    %ebx,%eax
  80360e:	89 fa                	mov    %edi,%edx
  803610:	83 c4 1c             	add    $0x1c,%esp
  803613:	5b                   	pop    %ebx
  803614:	5e                   	pop    %esi
  803615:	5f                   	pop    %edi
  803616:	5d                   	pop    %ebp
  803617:	c3                   	ret    
  803618:	90                   	nop
  803619:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803620:	89 d8                	mov    %ebx,%eax
  803622:	f7 f7                	div    %edi
  803624:	31 ff                	xor    %edi,%edi
  803626:	89 c3                	mov    %eax,%ebx
  803628:	89 d8                	mov    %ebx,%eax
  80362a:	89 fa                	mov    %edi,%edx
  80362c:	83 c4 1c             	add    $0x1c,%esp
  80362f:	5b                   	pop    %ebx
  803630:	5e                   	pop    %esi
  803631:	5f                   	pop    %edi
  803632:	5d                   	pop    %ebp
  803633:	c3                   	ret    
  803634:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803638:	39 ce                	cmp    %ecx,%esi
  80363a:	72 0c                	jb     803648 <__udivdi3+0x118>
  80363c:	31 db                	xor    %ebx,%ebx
  80363e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  803642:	0f 87 34 ff ff ff    	ja     80357c <__udivdi3+0x4c>
  803648:	bb 01 00 00 00       	mov    $0x1,%ebx
  80364d:	e9 2a ff ff ff       	jmp    80357c <__udivdi3+0x4c>
  803652:	66 90                	xchg   %ax,%ax
  803654:	66 90                	xchg   %ax,%ax
  803656:	66 90                	xchg   %ax,%ax
  803658:	66 90                	xchg   %ax,%ax
  80365a:	66 90                	xchg   %ax,%ax
  80365c:	66 90                	xchg   %ax,%ax
  80365e:	66 90                	xchg   %ax,%ax

00803660 <__umoddi3>:
  803660:	55                   	push   %ebp
  803661:	57                   	push   %edi
  803662:	56                   	push   %esi
  803663:	53                   	push   %ebx
  803664:	83 ec 1c             	sub    $0x1c,%esp
  803667:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80366b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80366f:	8b 74 24 34          	mov    0x34(%esp),%esi
  803673:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803677:	85 d2                	test   %edx,%edx
  803679:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80367d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803681:	89 f3                	mov    %esi,%ebx
  803683:	89 3c 24             	mov    %edi,(%esp)
  803686:	89 74 24 04          	mov    %esi,0x4(%esp)
  80368a:	75 1c                	jne    8036a8 <__umoddi3+0x48>
  80368c:	39 f7                	cmp    %esi,%edi
  80368e:	76 50                	jbe    8036e0 <__umoddi3+0x80>
  803690:	89 c8                	mov    %ecx,%eax
  803692:	89 f2                	mov    %esi,%edx
  803694:	f7 f7                	div    %edi
  803696:	89 d0                	mov    %edx,%eax
  803698:	31 d2                	xor    %edx,%edx
  80369a:	83 c4 1c             	add    $0x1c,%esp
  80369d:	5b                   	pop    %ebx
  80369e:	5e                   	pop    %esi
  80369f:	5f                   	pop    %edi
  8036a0:	5d                   	pop    %ebp
  8036a1:	c3                   	ret    
  8036a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8036a8:	39 f2                	cmp    %esi,%edx
  8036aa:	89 d0                	mov    %edx,%eax
  8036ac:	77 52                	ja     803700 <__umoddi3+0xa0>
  8036ae:	0f bd ea             	bsr    %edx,%ebp
  8036b1:	83 f5 1f             	xor    $0x1f,%ebp
  8036b4:	75 5a                	jne    803710 <__umoddi3+0xb0>
  8036b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8036ba:	0f 82 e0 00 00 00    	jb     8037a0 <__umoddi3+0x140>
  8036c0:	39 0c 24             	cmp    %ecx,(%esp)
  8036c3:	0f 86 d7 00 00 00    	jbe    8037a0 <__umoddi3+0x140>
  8036c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8036cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8036d1:	83 c4 1c             	add    $0x1c,%esp
  8036d4:	5b                   	pop    %ebx
  8036d5:	5e                   	pop    %esi
  8036d6:	5f                   	pop    %edi
  8036d7:	5d                   	pop    %ebp
  8036d8:	c3                   	ret    
  8036d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8036e0:	85 ff                	test   %edi,%edi
  8036e2:	89 fd                	mov    %edi,%ebp
  8036e4:	75 0b                	jne    8036f1 <__umoddi3+0x91>
  8036e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8036eb:	31 d2                	xor    %edx,%edx
  8036ed:	f7 f7                	div    %edi
  8036ef:	89 c5                	mov    %eax,%ebp
  8036f1:	89 f0                	mov    %esi,%eax
  8036f3:	31 d2                	xor    %edx,%edx
  8036f5:	f7 f5                	div    %ebp
  8036f7:	89 c8                	mov    %ecx,%eax
  8036f9:	f7 f5                	div    %ebp
  8036fb:	89 d0                	mov    %edx,%eax
  8036fd:	eb 99                	jmp    803698 <__umoddi3+0x38>
  8036ff:	90                   	nop
  803700:	89 c8                	mov    %ecx,%eax
  803702:	89 f2                	mov    %esi,%edx
  803704:	83 c4 1c             	add    $0x1c,%esp
  803707:	5b                   	pop    %ebx
  803708:	5e                   	pop    %esi
  803709:	5f                   	pop    %edi
  80370a:	5d                   	pop    %ebp
  80370b:	c3                   	ret    
  80370c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803710:	8b 34 24             	mov    (%esp),%esi
  803713:	bf 20 00 00 00       	mov    $0x20,%edi
  803718:	89 e9                	mov    %ebp,%ecx
  80371a:	29 ef                	sub    %ebp,%edi
  80371c:	d3 e0                	shl    %cl,%eax
  80371e:	89 f9                	mov    %edi,%ecx
  803720:	89 f2                	mov    %esi,%edx
  803722:	d3 ea                	shr    %cl,%edx
  803724:	89 e9                	mov    %ebp,%ecx
  803726:	09 c2                	or     %eax,%edx
  803728:	89 d8                	mov    %ebx,%eax
  80372a:	89 14 24             	mov    %edx,(%esp)
  80372d:	89 f2                	mov    %esi,%edx
  80372f:	d3 e2                	shl    %cl,%edx
  803731:	89 f9                	mov    %edi,%ecx
  803733:	89 54 24 04          	mov    %edx,0x4(%esp)
  803737:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80373b:	d3 e8                	shr    %cl,%eax
  80373d:	89 e9                	mov    %ebp,%ecx
  80373f:	89 c6                	mov    %eax,%esi
  803741:	d3 e3                	shl    %cl,%ebx
  803743:	89 f9                	mov    %edi,%ecx
  803745:	89 d0                	mov    %edx,%eax
  803747:	d3 e8                	shr    %cl,%eax
  803749:	89 e9                	mov    %ebp,%ecx
  80374b:	09 d8                	or     %ebx,%eax
  80374d:	89 d3                	mov    %edx,%ebx
  80374f:	89 f2                	mov    %esi,%edx
  803751:	f7 34 24             	divl   (%esp)
  803754:	89 d6                	mov    %edx,%esi
  803756:	d3 e3                	shl    %cl,%ebx
  803758:	f7 64 24 04          	mull   0x4(%esp)
  80375c:	39 d6                	cmp    %edx,%esi
  80375e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  803762:	89 d1                	mov    %edx,%ecx
  803764:	89 c3                	mov    %eax,%ebx
  803766:	72 08                	jb     803770 <__umoddi3+0x110>
  803768:	75 11                	jne    80377b <__umoddi3+0x11b>
  80376a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80376e:	73 0b                	jae    80377b <__umoddi3+0x11b>
  803770:	2b 44 24 04          	sub    0x4(%esp),%eax
  803774:	1b 14 24             	sbb    (%esp),%edx
  803777:	89 d1                	mov    %edx,%ecx
  803779:	89 c3                	mov    %eax,%ebx
  80377b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80377f:	29 da                	sub    %ebx,%edx
  803781:	19 ce                	sbb    %ecx,%esi
  803783:	89 f9                	mov    %edi,%ecx
  803785:	89 f0                	mov    %esi,%eax
  803787:	d3 e0                	shl    %cl,%eax
  803789:	89 e9                	mov    %ebp,%ecx
  80378b:	d3 ea                	shr    %cl,%edx
  80378d:	89 e9                	mov    %ebp,%ecx
  80378f:	d3 ee                	shr    %cl,%esi
  803791:	09 d0                	or     %edx,%eax
  803793:	89 f2                	mov    %esi,%edx
  803795:	83 c4 1c             	add    $0x1c,%esp
  803798:	5b                   	pop    %ebx
  803799:	5e                   	pop    %esi
  80379a:	5f                   	pop    %edi
  80379b:	5d                   	pop    %ebp
  80379c:	c3                   	ret    
  80379d:	8d 76 00             	lea    0x0(%esi),%esi
  8037a0:	29 f9                	sub    %edi,%ecx
  8037a2:	19 d6                	sbb    %edx,%esi
  8037a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8037a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8037ac:	e9 18 ff ff ff       	jmp    8036c9 <__umoddi3+0x69>
