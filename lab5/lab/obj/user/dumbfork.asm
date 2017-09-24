
obj/user/dumbfork.debug:     file format elf32-i386


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
  80002c:	e8 aa 01 00 00       	call   8001db <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 d1 0c 00 00       	call   800d1b <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %e", r);
  800051:	50                   	push   %eax
  800052:	68 e0 1f 80 00       	push   $0x801fe0
  800057:	6a 20                	push   $0x20
  800059:	68 f3 1f 80 00       	push   $0x801ff3
  80005e:	e8 d8 01 00 00       	call   80023b <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 e8 0c 00 00       	call   800d5e <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %e", r);
  80007d:	50                   	push   %eax
  80007e:	68 03 20 80 00       	push   $0x802003
  800083:	6a 22                	push   $0x22
  800085:	68 f3 1f 80 00       	push   $0x801ff3
  80008a:	e8 ac 01 00 00       	call   80023b <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 08 0a 00 00       	call   800aaa <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 ef 0c 00 00       	call   800da0 <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %e", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 14 20 80 00       	push   $0x802014
  8000be:	6a 25                	push   $0x25
  8000c0:	68 f3 1f 80 00       	push   $0x801ff3
  8000c5:	e8 71 01 00 00       	call   80023b <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	// 调用系统调用创建一个进程
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %e", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 27 20 80 00       	push   $0x802027
  8000ec:	6a 38                	push   $0x38
  8000ee:	68 f3 1f 80 00       	push   $0x801ff3
  8000f3:	e8 43 01 00 00       	call   80023b <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	// 如果是子进程
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 da 0b 00 00       	call   800cdd <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}
	// 如果是父进程
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}
	// 如果是父进程
	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 81 0c 00 00       	call   800de2 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %e", r);
  800168:	50                   	push   %eax
  800169:	68 37 20 80 00       	push   $0x802037
  80016e:	6a 4e                	push   $0x4e
  800170:	68 f3 1f 80 00       	push   $0x801ff3
  800175:	e8 c1 00 00 00       	call   80023b <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	57                   	push   %edi
  800187:	56                   	push   %esi
  800188:	53                   	push   %ebx
  800189:	83 ec 0c             	sub    $0xc,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  80018c:	e8 40 ff ff ff       	call   8000d1 <dumbfork>
  800191:	89 c7                	mov    %eax,%edi
  800193:	85 c0                	test   %eax,%eax
  800195:	be 55 20 80 00       	mov    $0x802055,%esi
  80019a:	b8 4e 20 80 00       	mov    $0x80204e,%eax
  80019f:	0f 45 f0             	cmovne %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a7:	eb 1a                	jmp    8001c3 <umain+0x40>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a9:	83 ec 04             	sub    $0x4,%esp
  8001ac:	56                   	push   %esi
  8001ad:	53                   	push   %ebx
  8001ae:	68 5b 20 80 00       	push   $0x80205b
  8001b3:	e8 5c 01 00 00       	call   800314 <cprintf>
		sys_yield();
  8001b8:	e8 3f 0b 00 00       	call   800cfc <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001bd:	83 c3 01             	add    $0x1,%ebx
  8001c0:	83 c4 10             	add    $0x10,%esp
  8001c3:	85 ff                	test   %edi,%edi
  8001c5:	74 07                	je     8001ce <umain+0x4b>
  8001c7:	83 fb 09             	cmp    $0x9,%ebx
  8001ca:	7e dd                	jle    8001a9 <umain+0x26>
  8001cc:	eb 05                	jmp    8001d3 <umain+0x50>
  8001ce:	83 fb 13             	cmp    $0x13,%ebx
  8001d1:	7e d6                	jle    8001a9 <umain+0x26>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001e3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e6:	e8 f2 0a 00 00       	call   800cdd <sys_getenvid>
  8001eb:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001f0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001f3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f8:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001fd:	85 db                	test   %ebx,%ebx
  8001ff:	7e 07                	jle    800208 <libmain+0x2d>
		binaryname = argv[0];
  800201:	8b 06                	mov    (%esi),%eax
  800203:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	56                   	push   %esi
  80020c:	53                   	push   %ebx
  80020d:	e8 71 ff ff ff       	call   800183 <umain>

	// exit gracefully
	exit();
  800212:	e8 0a 00 00 00       	call   800221 <exit>
}
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800227:	e8 ab 0e 00 00       	call   8010d7 <close_all>
	sys_env_destroy(0);
  80022c:	83 ec 0c             	sub    $0xc,%esp
  80022f:	6a 00                	push   $0x0
  800231:	e8 66 0a 00 00       	call   800c9c <sys_env_destroy>
}
  800236:	83 c4 10             	add    $0x10,%esp
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80023b:	55                   	push   %ebp
  80023c:	89 e5                	mov    %esp,%ebp
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800240:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800243:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800249:	e8 8f 0a 00 00       	call   800cdd <sys_getenvid>
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 0c             	pushl  0xc(%ebp)
  800254:	ff 75 08             	pushl  0x8(%ebp)
  800257:	56                   	push   %esi
  800258:	50                   	push   %eax
  800259:	68 78 20 80 00       	push   $0x802078
  80025e:	e8 b1 00 00 00       	call   800314 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800263:	83 c4 18             	add    $0x18,%esp
  800266:	53                   	push   %ebx
  800267:	ff 75 10             	pushl  0x10(%ebp)
  80026a:	e8 54 00 00 00       	call   8002c3 <vcprintf>
	cprintf("\n");
  80026f:	c7 04 24 6b 20 80 00 	movl   $0x80206b,(%esp)
  800276:	e8 99 00 00 00       	call   800314 <cprintf>
  80027b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80027e:	cc                   	int3   
  80027f:	eb fd                	jmp    80027e <_panic+0x43>

00800281 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	53                   	push   %ebx
  800285:	83 ec 04             	sub    $0x4,%esp
  800288:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80028b:	8b 13                	mov    (%ebx),%edx
  80028d:	8d 42 01             	lea    0x1(%edx),%eax
  800290:	89 03                	mov    %eax,(%ebx)
  800292:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800295:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800299:	3d ff 00 00 00       	cmp    $0xff,%eax
  80029e:	75 1a                	jne    8002ba <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8002a0:	83 ec 08             	sub    $0x8,%esp
  8002a3:	68 ff 00 00 00       	push   $0xff
  8002a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 ae 09 00 00       	call   800c5f <sys_cputs>
		b->idx = 0;
  8002b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002ba:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c1:	c9                   	leave  
  8002c2:	c3                   	ret    

008002c3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002cc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002d3:	00 00 00 
	b.cnt = 0;
  8002d6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002dd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002e0:	ff 75 0c             	pushl  0xc(%ebp)
  8002e3:	ff 75 08             	pushl  0x8(%ebp)
  8002e6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002ec:	50                   	push   %eax
  8002ed:	68 81 02 80 00       	push   $0x800281
  8002f2:	e8 1a 01 00 00       	call   800411 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f7:	83 c4 08             	add    $0x8,%esp
  8002fa:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800300:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800306:	50                   	push   %eax
  800307:	e8 53 09 00 00       	call   800c5f <sys_cputs>

	return b.cnt;
}
  80030c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800312:	c9                   	leave  
  800313:	c3                   	ret    

00800314 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800314:	55                   	push   %ebp
  800315:	89 e5                	mov    %esp,%ebp
  800317:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80031a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80031d:	50                   	push   %eax
  80031e:	ff 75 08             	pushl  0x8(%ebp)
  800321:	e8 9d ff ff ff       	call   8002c3 <vcprintf>
	va_end(ap);

	return cnt;
}
  800326:	c9                   	leave  
  800327:	c3                   	ret    

00800328 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	57                   	push   %edi
  80032c:	56                   	push   %esi
  80032d:	53                   	push   %ebx
  80032e:	83 ec 1c             	sub    $0x1c,%esp
  800331:	89 c7                	mov    %eax,%edi
  800333:	89 d6                	mov    %edx,%esi
  800335:	8b 45 08             	mov    0x8(%ebp),%eax
  800338:	8b 55 0c             	mov    0xc(%ebp),%edx
  80033b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033e:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800344:	bb 00 00 00 00       	mov    $0x0,%ebx
  800349:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80034c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034f:	39 d3                	cmp    %edx,%ebx
  800351:	72 05                	jb     800358 <printnum+0x30>
  800353:	39 45 10             	cmp    %eax,0x10(%ebp)
  800356:	77 45                	ja     80039d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800358:	83 ec 0c             	sub    $0xc,%esp
  80035b:	ff 75 18             	pushl  0x18(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800364:	53                   	push   %ebx
  800365:	ff 75 10             	pushl  0x10(%ebp)
  800368:	83 ec 08             	sub    $0x8,%esp
  80036b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80036e:	ff 75 e0             	pushl  -0x20(%ebp)
  800371:	ff 75 dc             	pushl  -0x24(%ebp)
  800374:	ff 75 d8             	pushl  -0x28(%ebp)
  800377:	e8 d4 19 00 00       	call   801d50 <__udivdi3>
  80037c:	83 c4 18             	add    $0x18,%esp
  80037f:	52                   	push   %edx
  800380:	50                   	push   %eax
  800381:	89 f2                	mov    %esi,%edx
  800383:	89 f8                	mov    %edi,%eax
  800385:	e8 9e ff ff ff       	call   800328 <printnum>
  80038a:	83 c4 20             	add    $0x20,%esp
  80038d:	eb 18                	jmp    8003a7 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038f:	83 ec 08             	sub    $0x8,%esp
  800392:	56                   	push   %esi
  800393:	ff 75 18             	pushl  0x18(%ebp)
  800396:	ff d7                	call   *%edi
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	eb 03                	jmp    8003a0 <printnum+0x78>
  80039d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8003a0:	83 eb 01             	sub    $0x1,%ebx
  8003a3:	85 db                	test   %ebx,%ebx
  8003a5:	7f e8                	jg     80038f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a7:	83 ec 08             	sub    $0x8,%esp
  8003aa:	56                   	push   %esi
  8003ab:	83 ec 04             	sub    $0x4,%esp
  8003ae:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003b1:	ff 75 e0             	pushl  -0x20(%ebp)
  8003b4:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b7:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ba:	e8 c1 1a 00 00       	call   801e80 <__umoddi3>
  8003bf:	83 c4 14             	add    $0x14,%esp
  8003c2:	0f be 80 9b 20 80 00 	movsbl 0x80209b(%eax),%eax
  8003c9:	50                   	push   %eax
  8003ca:	ff d7                	call   *%edi
}
  8003cc:	83 c4 10             	add    $0x10,%esp
  8003cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d2:	5b                   	pop    %ebx
  8003d3:	5e                   	pop    %esi
  8003d4:	5f                   	pop    %edi
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    

008003d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d7:	55                   	push   %ebp
  8003d8:	89 e5                	mov    %esp,%ebp
  8003da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003e1:	8b 10                	mov    (%eax),%edx
  8003e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e6:	73 0a                	jae    8003f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003eb:	89 08                	mov    %ecx,(%eax)
  8003ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f0:	88 02                	mov    %al,(%edx)
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    

008003f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003f4:	55                   	push   %ebp
  8003f5:	89 e5                	mov    %esp,%ebp
  8003f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003fd:	50                   	push   %eax
  8003fe:	ff 75 10             	pushl  0x10(%ebp)
  800401:	ff 75 0c             	pushl  0xc(%ebp)
  800404:	ff 75 08             	pushl  0x8(%ebp)
  800407:	e8 05 00 00 00       	call   800411 <vprintfmt>
	va_end(ap);
}
  80040c:	83 c4 10             	add    $0x10,%esp
  80040f:	c9                   	leave  
  800410:	c3                   	ret    

00800411 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800411:	55                   	push   %ebp
  800412:	89 e5                	mov    %esp,%ebp
  800414:	57                   	push   %edi
  800415:	56                   	push   %esi
  800416:	53                   	push   %ebx
  800417:	83 ec 2c             	sub    $0x2c,%esp
  80041a:	8b 75 08             	mov    0x8(%ebp),%esi
  80041d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800420:	8b 7d 10             	mov    0x10(%ebp),%edi
  800423:	eb 12                	jmp    800437 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800425:	85 c0                	test   %eax,%eax
  800427:	0f 84 42 04 00 00    	je     80086f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	53                   	push   %ebx
  800431:	50                   	push   %eax
  800432:	ff d6                	call   *%esi
  800434:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800437:	83 c7 01             	add    $0x1,%edi
  80043a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80043e:	83 f8 25             	cmp    $0x25,%eax
  800441:	75 e2                	jne    800425 <vprintfmt+0x14>
  800443:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800447:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80044e:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800455:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80045c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800461:	eb 07                	jmp    80046a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800463:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800466:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8d 47 01             	lea    0x1(%edi),%eax
  80046d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800470:	0f b6 07             	movzbl (%edi),%eax
  800473:	0f b6 d0             	movzbl %al,%edx
  800476:	83 e8 23             	sub    $0x23,%eax
  800479:	3c 55                	cmp    $0x55,%al
  80047b:	0f 87 d3 03 00 00    	ja     800854 <vprintfmt+0x443>
  800481:	0f b6 c0             	movzbl %al,%eax
  800484:	ff 24 85 e0 21 80 00 	jmp    *0x8021e0(,%eax,4)
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80048e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800492:	eb d6                	jmp    80046a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800494:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004a2:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a6:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a9:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004ac:	83 f9 09             	cmp    $0x9,%ecx
  8004af:	77 3f                	ja     8004f0 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004b4:	eb e9                	jmp    80049f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b9:	8b 00                	mov    (%eax),%eax
  8004bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 40 04             	lea    0x4(%eax),%eax
  8004c4:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004ca:	eb 2a                	jmp    8004f6 <vprintfmt+0xe5>
  8004cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d6:	0f 49 d0             	cmovns %eax,%edx
  8004d9:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	eb 89                	jmp    80046a <vprintfmt+0x59>
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004e4:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004eb:	e9 7a ff ff ff       	jmp    80046a <vprintfmt+0x59>
  8004f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004fa:	0f 89 6a ff ff ff    	jns    80046a <vprintfmt+0x59>
				width = precision, precision = -1;
  800500:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800503:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800506:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80050d:	e9 58 ff ff ff       	jmp    80046a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800512:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800515:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800518:	e9 4d ff ff ff       	jmp    80046a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80051d:	8b 45 14             	mov    0x14(%ebp),%eax
  800520:	8d 78 04             	lea    0x4(%eax),%edi
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	ff 30                	pushl  (%eax)
  800529:	ff d6                	call   *%esi
			break;
  80052b:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80052e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800534:	e9 fe fe ff ff       	jmp    800437 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800539:	8b 45 14             	mov    0x14(%ebp),%eax
  80053c:	8d 78 04             	lea    0x4(%eax),%edi
  80053f:	8b 00                	mov    (%eax),%eax
  800541:	99                   	cltd   
  800542:	31 d0                	xor    %edx,%eax
  800544:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800546:	83 f8 0f             	cmp    $0xf,%eax
  800549:	7f 0b                	jg     800556 <vprintfmt+0x145>
  80054b:	8b 14 85 40 23 80 00 	mov    0x802340(,%eax,4),%edx
  800552:	85 d2                	test   %edx,%edx
  800554:	75 1b                	jne    800571 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800556:	50                   	push   %eax
  800557:	68 b3 20 80 00       	push   $0x8020b3
  80055c:	53                   	push   %ebx
  80055d:	56                   	push   %esi
  80055e:	e8 91 fe ff ff       	call   8003f4 <printfmt>
  800563:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800566:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80056c:	e9 c6 fe ff ff       	jmp    800437 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800571:	52                   	push   %edx
  800572:	68 75 24 80 00       	push   $0x802475
  800577:	53                   	push   %ebx
  800578:	56                   	push   %esi
  800579:	e8 76 fe ff ff       	call   8003f4 <printfmt>
  80057e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800581:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800587:	e9 ab fe ff ff       	jmp    800437 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80058c:	8b 45 14             	mov    0x14(%ebp),%eax
  80058f:	83 c0 04             	add    $0x4,%eax
  800592:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80059a:	85 ff                	test   %edi,%edi
  80059c:	b8 ac 20 80 00       	mov    $0x8020ac,%eax
  8005a1:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8005a4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a8:	0f 8e 94 00 00 00    	jle    800642 <vprintfmt+0x231>
  8005ae:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005b2:	0f 84 98 00 00 00    	je     800650 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	ff 75 d0             	pushl  -0x30(%ebp)
  8005be:	57                   	push   %edi
  8005bf:	e8 33 03 00 00       	call   8008f7 <strnlen>
  8005c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c7:	29 c1                	sub    %eax,%ecx
  8005c9:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005cc:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005cf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005db:	eb 0f                	jmp    8005ec <vprintfmt+0x1db>
					putch(padc, putdat);
  8005dd:	83 ec 08             	sub    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	ff 75 e0             	pushl  -0x20(%ebp)
  8005e4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e6:	83 ef 01             	sub    $0x1,%edi
  8005e9:	83 c4 10             	add    $0x10,%esp
  8005ec:	85 ff                	test   %edi,%edi
  8005ee:	7f ed                	jg     8005dd <vprintfmt+0x1cc>
  8005f0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005f3:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005f6:	85 c9                	test   %ecx,%ecx
  8005f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8005fd:	0f 49 c1             	cmovns %ecx,%eax
  800600:	29 c1                	sub    %eax,%ecx
  800602:	89 75 08             	mov    %esi,0x8(%ebp)
  800605:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800608:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80060b:	89 cb                	mov    %ecx,%ebx
  80060d:	eb 4d                	jmp    80065c <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800613:	74 1b                	je     800630 <vprintfmt+0x21f>
  800615:	0f be c0             	movsbl %al,%eax
  800618:	83 e8 20             	sub    $0x20,%eax
  80061b:	83 f8 5e             	cmp    $0x5e,%eax
  80061e:	76 10                	jbe    800630 <vprintfmt+0x21f>
					putch('?', putdat);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	ff 75 0c             	pushl  0xc(%ebp)
  800626:	6a 3f                	push   $0x3f
  800628:	ff 55 08             	call   *0x8(%ebp)
  80062b:	83 c4 10             	add    $0x10,%esp
  80062e:	eb 0d                	jmp    80063d <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	ff 75 0c             	pushl  0xc(%ebp)
  800636:	52                   	push   %edx
  800637:	ff 55 08             	call   *0x8(%ebp)
  80063a:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063d:	83 eb 01             	sub    $0x1,%ebx
  800640:	eb 1a                	jmp    80065c <vprintfmt+0x24b>
  800642:	89 75 08             	mov    %esi,0x8(%ebp)
  800645:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800648:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80064b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80064e:	eb 0c                	jmp    80065c <vprintfmt+0x24b>
  800650:	89 75 08             	mov    %esi,0x8(%ebp)
  800653:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800656:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800659:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065c:	83 c7 01             	add    $0x1,%edi
  80065f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800663:	0f be d0             	movsbl %al,%edx
  800666:	85 d2                	test   %edx,%edx
  800668:	74 23                	je     80068d <vprintfmt+0x27c>
  80066a:	85 f6                	test   %esi,%esi
  80066c:	78 a1                	js     80060f <vprintfmt+0x1fe>
  80066e:	83 ee 01             	sub    $0x1,%esi
  800671:	79 9c                	jns    80060f <vprintfmt+0x1fe>
  800673:	89 df                	mov    %ebx,%edi
  800675:	8b 75 08             	mov    0x8(%ebp),%esi
  800678:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80067b:	eb 18                	jmp    800695 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 20                	push   $0x20
  800683:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800685:	83 ef 01             	sub    $0x1,%edi
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	eb 08                	jmp    800695 <vprintfmt+0x284>
  80068d:	89 df                	mov    %ebx,%edi
  80068f:	8b 75 08             	mov    0x8(%ebp),%esi
  800692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800695:	85 ff                	test   %edi,%edi
  800697:	7f e4                	jg     80067d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800699:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80069c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006a2:	e9 90 fd ff ff       	jmp    800437 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a7:	83 f9 01             	cmp    $0x1,%ecx
  8006aa:	7e 19                	jle    8006c5 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 50 04             	mov    0x4(%eax),%edx
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 40 08             	lea    0x8(%eax),%eax
  8006c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006c3:	eb 38                	jmp    8006fd <vprintfmt+0x2ec>
	else if (lflag)
  8006c5:	85 c9                	test   %ecx,%ecx
  8006c7:	74 1b                	je     8006e4 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d1:	89 c1                	mov    %eax,%ecx
  8006d3:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8d 40 04             	lea    0x4(%eax),%eax
  8006df:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e2:	eb 19                	jmp    8006fd <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8b 00                	mov    (%eax),%eax
  8006e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ec:	89 c1                	mov    %eax,%ecx
  8006ee:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 40 04             	lea    0x4(%eax),%eax
  8006fa:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800700:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800703:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800708:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80070c:	0f 89 0e 01 00 00    	jns    800820 <vprintfmt+0x40f>
				putch('-', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 2d                	push   $0x2d
  800718:	ff d6                	call   *%esi
				num = -(long long) num;
  80071a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80071d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800720:	f7 da                	neg    %edx
  800722:	83 d1 00             	adc    $0x0,%ecx
  800725:	f7 d9                	neg    %ecx
  800727:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80072a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072f:	e9 ec 00 00 00       	jmp    800820 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800734:	83 f9 01             	cmp    $0x1,%ecx
  800737:	7e 18                	jle    800751 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800739:	8b 45 14             	mov    0x14(%ebp),%eax
  80073c:	8b 10                	mov    (%eax),%edx
  80073e:	8b 48 04             	mov    0x4(%eax),%ecx
  800741:	8d 40 08             	lea    0x8(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800747:	b8 0a 00 00 00       	mov    $0xa,%eax
  80074c:	e9 cf 00 00 00       	jmp    800820 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800751:	85 c9                	test   %ecx,%ecx
  800753:	74 1a                	je     80076f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800755:	8b 45 14             	mov    0x14(%ebp),%eax
  800758:	8b 10                	mov    (%eax),%edx
  80075a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075f:	8d 40 04             	lea    0x4(%eax),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800765:	b8 0a 00 00 00       	mov    $0xa,%eax
  80076a:	e9 b1 00 00 00       	jmp    800820 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 10                	mov    (%eax),%edx
  800774:	b9 00 00 00 00       	mov    $0x0,%ecx
  800779:	8d 40 04             	lea    0x4(%eax),%eax
  80077c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80077f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800784:	e9 97 00 00 00       	jmp    800820 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	53                   	push   %ebx
  80078d:	6a 58                	push   $0x58
  80078f:	ff d6                	call   *%esi
			putch('X', putdat);
  800791:	83 c4 08             	add    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 58                	push   $0x58
  800797:	ff d6                	call   *%esi
			putch('X', putdat);
  800799:	83 c4 08             	add    $0x8,%esp
  80079c:	53                   	push   %ebx
  80079d:	6a 58                	push   $0x58
  80079f:	ff d6                	call   *%esi
			break;
  8007a1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007a7:	e9 8b fc ff ff       	jmp    800437 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	53                   	push   %ebx
  8007b0:	6a 30                	push   $0x30
  8007b2:	ff d6                	call   *%esi
			putch('x', putdat);
  8007b4:	83 c4 08             	add    $0x8,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	6a 78                	push   $0x78
  8007ba:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bf:	8b 10                	mov    (%eax),%edx
  8007c1:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007c6:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c9:	8d 40 04             	lea    0x4(%eax),%eax
  8007cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cf:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007d4:	eb 4a                	jmp    800820 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d6:	83 f9 01             	cmp    $0x1,%ecx
  8007d9:	7e 15                	jle    8007f0 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8b 10                	mov    (%eax),%edx
  8007e0:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e3:	8d 40 08             	lea    0x8(%eax),%eax
  8007e6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007e9:	b8 10 00 00 00       	mov    $0x10,%eax
  8007ee:	eb 30                	jmp    800820 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007f0:	85 c9                	test   %ecx,%ecx
  8007f2:	74 17                	je     80080b <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8b 10                	mov    (%eax),%edx
  8007f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fe:	8d 40 04             	lea    0x4(%eax),%eax
  800801:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800804:	b8 10 00 00 00       	mov    $0x10,%eax
  800809:	eb 15                	jmp    800820 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8b 10                	mov    (%eax),%edx
  800810:	b9 00 00 00 00       	mov    $0x0,%ecx
  800815:	8d 40 04             	lea    0x4(%eax),%eax
  800818:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80081b:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800820:	83 ec 0c             	sub    $0xc,%esp
  800823:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800827:	57                   	push   %edi
  800828:	ff 75 e0             	pushl  -0x20(%ebp)
  80082b:	50                   	push   %eax
  80082c:	51                   	push   %ecx
  80082d:	52                   	push   %edx
  80082e:	89 da                	mov    %ebx,%edx
  800830:	89 f0                	mov    %esi,%eax
  800832:	e8 f1 fa ff ff       	call   800328 <printnum>
			break;
  800837:	83 c4 20             	add    $0x20,%esp
  80083a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80083d:	e9 f5 fb ff ff       	jmp    800437 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800842:	83 ec 08             	sub    $0x8,%esp
  800845:	53                   	push   %ebx
  800846:	52                   	push   %edx
  800847:	ff d6                	call   *%esi
			break;
  800849:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084f:	e9 e3 fb ff ff       	jmp    800437 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	53                   	push   %ebx
  800858:	6a 25                	push   $0x25
  80085a:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	eb 03                	jmp    800864 <vprintfmt+0x453>
  800861:	83 ef 01             	sub    $0x1,%edi
  800864:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800868:	75 f7                	jne    800861 <vprintfmt+0x450>
  80086a:	e9 c8 fb ff ff       	jmp    800437 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80086f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800872:	5b                   	pop    %ebx
  800873:	5e                   	pop    %esi
  800874:	5f                   	pop    %edi
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	83 ec 18             	sub    $0x18,%esp
  80087d:	8b 45 08             	mov    0x8(%ebp),%eax
  800880:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800883:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800886:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80088a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80088d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800894:	85 c0                	test   %eax,%eax
  800896:	74 26                	je     8008be <vsnprintf+0x47>
  800898:	85 d2                	test   %edx,%edx
  80089a:	7e 22                	jle    8008be <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80089c:	ff 75 14             	pushl  0x14(%ebp)
  80089f:	ff 75 10             	pushl  0x10(%ebp)
  8008a2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	68 d7 03 80 00       	push   $0x8003d7
  8008ab:	e8 61 fb ff ff       	call   800411 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b9:	83 c4 10             	add    $0x10,%esp
  8008bc:	eb 05                	jmp    8008c3 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008c3:	c9                   	leave  
  8008c4:	c3                   	ret    

008008c5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008cb:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ce:	50                   	push   %eax
  8008cf:	ff 75 10             	pushl  0x10(%ebp)
  8008d2:	ff 75 0c             	pushl  0xc(%ebp)
  8008d5:	ff 75 08             	pushl  0x8(%ebp)
  8008d8:	e8 9a ff ff ff       	call   800877 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ea:	eb 03                	jmp    8008ef <strlen+0x10>
		n++;
  8008ec:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ef:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f3:	75 f7                	jne    8008ec <strlen+0xd>
		n++;
	return n;
}
  8008f5:	5d                   	pop    %ebp
  8008f6:	c3                   	ret    

008008f7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008fd:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800900:	ba 00 00 00 00       	mov    $0x0,%edx
  800905:	eb 03                	jmp    80090a <strnlen+0x13>
		n++;
  800907:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80090a:	39 c2                	cmp    %eax,%edx
  80090c:	74 08                	je     800916 <strnlen+0x1f>
  80090e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800912:	75 f3                	jne    800907 <strnlen+0x10>
  800914:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	53                   	push   %ebx
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800922:	89 c2                	mov    %eax,%edx
  800924:	83 c2 01             	add    $0x1,%edx
  800927:	83 c1 01             	add    $0x1,%ecx
  80092a:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80092e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800931:	84 db                	test   %bl,%bl
  800933:	75 ef                	jne    800924 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800935:	5b                   	pop    %ebx
  800936:	5d                   	pop    %ebp
  800937:	c3                   	ret    

00800938 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	53                   	push   %ebx
  80093c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80093f:	53                   	push   %ebx
  800940:	e8 9a ff ff ff       	call   8008df <strlen>
  800945:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800948:	ff 75 0c             	pushl  0xc(%ebp)
  80094b:	01 d8                	add    %ebx,%eax
  80094d:	50                   	push   %eax
  80094e:	e8 c5 ff ff ff       	call   800918 <strcpy>
	return dst;
}
  800953:	89 d8                	mov    %ebx,%eax
  800955:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800958:	c9                   	leave  
  800959:	c3                   	ret    

0080095a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	56                   	push   %esi
  80095e:	53                   	push   %ebx
  80095f:	8b 75 08             	mov    0x8(%ebp),%esi
  800962:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800965:	89 f3                	mov    %esi,%ebx
  800967:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80096a:	89 f2                	mov    %esi,%edx
  80096c:	eb 0f                	jmp    80097d <strncpy+0x23>
		*dst++ = *src;
  80096e:	83 c2 01             	add    $0x1,%edx
  800971:	0f b6 01             	movzbl (%ecx),%eax
  800974:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800977:	80 39 01             	cmpb   $0x1,(%ecx)
  80097a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097d:	39 da                	cmp    %ebx,%edx
  80097f:	75 ed                	jne    80096e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800981:	89 f0                	mov    %esi,%eax
  800983:	5b                   	pop    %ebx
  800984:	5e                   	pop    %esi
  800985:	5d                   	pop    %ebp
  800986:	c3                   	ret    

00800987 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	56                   	push   %esi
  80098b:	53                   	push   %ebx
  80098c:	8b 75 08             	mov    0x8(%ebp),%esi
  80098f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800992:	8b 55 10             	mov    0x10(%ebp),%edx
  800995:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800997:	85 d2                	test   %edx,%edx
  800999:	74 21                	je     8009bc <strlcpy+0x35>
  80099b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80099f:	89 f2                	mov    %esi,%edx
  8009a1:	eb 09                	jmp    8009ac <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009a3:	83 c2 01             	add    $0x1,%edx
  8009a6:	83 c1 01             	add    $0x1,%ecx
  8009a9:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009ac:	39 c2                	cmp    %eax,%edx
  8009ae:	74 09                	je     8009b9 <strlcpy+0x32>
  8009b0:	0f b6 19             	movzbl (%ecx),%ebx
  8009b3:	84 db                	test   %bl,%bl
  8009b5:	75 ec                	jne    8009a3 <strlcpy+0x1c>
  8009b7:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009b9:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009bc:	29 f0                	sub    %esi,%eax
}
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009cb:	eb 06                	jmp    8009d3 <strcmp+0x11>
		p++, q++;
  8009cd:	83 c1 01             	add    $0x1,%ecx
  8009d0:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009d3:	0f b6 01             	movzbl (%ecx),%eax
  8009d6:	84 c0                	test   %al,%al
  8009d8:	74 04                	je     8009de <strcmp+0x1c>
  8009da:	3a 02                	cmp    (%edx),%al
  8009dc:	74 ef                	je     8009cd <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009de:	0f b6 c0             	movzbl %al,%eax
  8009e1:	0f b6 12             	movzbl (%edx),%edx
  8009e4:	29 d0                	sub    %edx,%eax
}
  8009e6:	5d                   	pop    %ebp
  8009e7:	c3                   	ret    

008009e8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e8:	55                   	push   %ebp
  8009e9:	89 e5                	mov    %esp,%ebp
  8009eb:	53                   	push   %ebx
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f2:	89 c3                	mov    %eax,%ebx
  8009f4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f7:	eb 06                	jmp    8009ff <strncmp+0x17>
		n--, p++, q++;
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ff:	39 d8                	cmp    %ebx,%eax
  800a01:	74 15                	je     800a18 <strncmp+0x30>
  800a03:	0f b6 08             	movzbl (%eax),%ecx
  800a06:	84 c9                	test   %cl,%cl
  800a08:	74 04                	je     800a0e <strncmp+0x26>
  800a0a:	3a 0a                	cmp    (%edx),%cl
  800a0c:	74 eb                	je     8009f9 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a0e:	0f b6 00             	movzbl (%eax),%eax
  800a11:	0f b6 12             	movzbl (%edx),%edx
  800a14:	29 d0                	sub    %edx,%eax
  800a16:	eb 05                	jmp    800a1d <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a1d:	5b                   	pop    %ebx
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	8b 45 08             	mov    0x8(%ebp),%eax
  800a26:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a2a:	eb 07                	jmp    800a33 <strchr+0x13>
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	74 0f                	je     800a3f <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a30:	83 c0 01             	add    $0x1,%eax
  800a33:	0f b6 10             	movzbl (%eax),%edx
  800a36:	84 d2                	test   %dl,%dl
  800a38:	75 f2                	jne    800a2c <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3f:	5d                   	pop    %ebp
  800a40:	c3                   	ret    

00800a41 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a41:	55                   	push   %ebp
  800a42:	89 e5                	mov    %esp,%ebp
  800a44:	8b 45 08             	mov    0x8(%ebp),%eax
  800a47:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4b:	eb 03                	jmp    800a50 <strfind+0xf>
  800a4d:	83 c0 01             	add    $0x1,%eax
  800a50:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a53:	38 ca                	cmp    %cl,%dl
  800a55:	74 04                	je     800a5b <strfind+0x1a>
  800a57:	84 d2                	test   %dl,%dl
  800a59:	75 f2                	jne    800a4d <strfind+0xc>
			break;
	return (char *) s;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	57                   	push   %edi
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a66:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a69:	85 c9                	test   %ecx,%ecx
  800a6b:	74 36                	je     800aa3 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a73:	75 28                	jne    800a9d <memset+0x40>
  800a75:	f6 c1 03             	test   $0x3,%cl
  800a78:	75 23                	jne    800a9d <memset+0x40>
		c &= 0xFF;
  800a7a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a7e:	89 d3                	mov    %edx,%ebx
  800a80:	c1 e3 08             	shl    $0x8,%ebx
  800a83:	89 d6                	mov    %edx,%esi
  800a85:	c1 e6 18             	shl    $0x18,%esi
  800a88:	89 d0                	mov    %edx,%eax
  800a8a:	c1 e0 10             	shl    $0x10,%eax
  800a8d:	09 f0                	or     %esi,%eax
  800a8f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a91:	89 d8                	mov    %ebx,%eax
  800a93:	09 d0                	or     %edx,%eax
  800a95:	c1 e9 02             	shr    $0x2,%ecx
  800a98:	fc                   	cld    
  800a99:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9b:	eb 06                	jmp    800aa3 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa0:	fc                   	cld    
  800aa1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa3:	89 f8                	mov    %edi,%eax
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab8:	39 c6                	cmp    %eax,%esi
  800aba:	73 35                	jae    800af1 <memmove+0x47>
  800abc:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800abf:	39 d0                	cmp    %edx,%eax
  800ac1:	73 2e                	jae    800af1 <memmove+0x47>
		s += n;
		d += n;
  800ac3:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac6:	89 d6                	mov    %edx,%esi
  800ac8:	09 fe                	or     %edi,%esi
  800aca:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ad0:	75 13                	jne    800ae5 <memmove+0x3b>
  800ad2:	f6 c1 03             	test   $0x3,%cl
  800ad5:	75 0e                	jne    800ae5 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ad7:	83 ef 04             	sub    $0x4,%edi
  800ada:	8d 72 fc             	lea    -0x4(%edx),%esi
  800add:	c1 e9 02             	shr    $0x2,%ecx
  800ae0:	fd                   	std    
  800ae1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae3:	eb 09                	jmp    800aee <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae5:	83 ef 01             	sub    $0x1,%edi
  800ae8:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aeb:	fd                   	std    
  800aec:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aee:	fc                   	cld    
  800aef:	eb 1d                	jmp    800b0e <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af1:	89 f2                	mov    %esi,%edx
  800af3:	09 c2                	or     %eax,%edx
  800af5:	f6 c2 03             	test   $0x3,%dl
  800af8:	75 0f                	jne    800b09 <memmove+0x5f>
  800afa:	f6 c1 03             	test   $0x3,%cl
  800afd:	75 0a                	jne    800b09 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800aff:	c1 e9 02             	shr    $0x2,%ecx
  800b02:	89 c7                	mov    %eax,%edi
  800b04:	fc                   	cld    
  800b05:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b07:	eb 05                	jmp    800b0e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b09:	89 c7                	mov    %eax,%edi
  800b0b:	fc                   	cld    
  800b0c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b15:	ff 75 10             	pushl  0x10(%ebp)
  800b18:	ff 75 0c             	pushl  0xc(%ebp)
  800b1b:	ff 75 08             	pushl  0x8(%ebp)
  800b1e:	e8 87 ff ff ff       	call   800aaa <memmove>
}
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b30:	89 c6                	mov    %eax,%esi
  800b32:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b35:	eb 1a                	jmp    800b51 <memcmp+0x2c>
		if (*s1 != *s2)
  800b37:	0f b6 08             	movzbl (%eax),%ecx
  800b3a:	0f b6 1a             	movzbl (%edx),%ebx
  800b3d:	38 d9                	cmp    %bl,%cl
  800b3f:	74 0a                	je     800b4b <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b41:	0f b6 c1             	movzbl %cl,%eax
  800b44:	0f b6 db             	movzbl %bl,%ebx
  800b47:	29 d8                	sub    %ebx,%eax
  800b49:	eb 0f                	jmp    800b5a <memcmp+0x35>
		s1++, s2++;
  800b4b:	83 c0 01             	add    $0x1,%eax
  800b4e:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b51:	39 f0                	cmp    %esi,%eax
  800b53:	75 e2                	jne    800b37 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	53                   	push   %ebx
  800b62:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b65:	89 c1                	mov    %eax,%ecx
  800b67:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b6e:	eb 0a                	jmp    800b7a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b70:	0f b6 10             	movzbl (%eax),%edx
  800b73:	39 da                	cmp    %ebx,%edx
  800b75:	74 07                	je     800b7e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b77:	83 c0 01             	add    $0x1,%eax
  800b7a:	39 c8                	cmp    %ecx,%eax
  800b7c:	72 f2                	jb     800b70 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b7e:	5b                   	pop    %ebx
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	53                   	push   %ebx
  800b87:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b8a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8d:	eb 03                	jmp    800b92 <strtol+0x11>
		s++;
  800b8f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b92:	0f b6 01             	movzbl (%ecx),%eax
  800b95:	3c 20                	cmp    $0x20,%al
  800b97:	74 f6                	je     800b8f <strtol+0xe>
  800b99:	3c 09                	cmp    $0x9,%al
  800b9b:	74 f2                	je     800b8f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b9d:	3c 2b                	cmp    $0x2b,%al
  800b9f:	75 0a                	jne    800bab <strtol+0x2a>
		s++;
  800ba1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ba4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba9:	eb 11                	jmp    800bbc <strtol+0x3b>
  800bab:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bb0:	3c 2d                	cmp    $0x2d,%al
  800bb2:	75 08                	jne    800bbc <strtol+0x3b>
		s++, neg = 1;
  800bb4:	83 c1 01             	add    $0x1,%ecx
  800bb7:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bbc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bc2:	75 15                	jne    800bd9 <strtol+0x58>
  800bc4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc7:	75 10                	jne    800bd9 <strtol+0x58>
  800bc9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bcd:	75 7c                	jne    800c4b <strtol+0xca>
		s += 2, base = 16;
  800bcf:	83 c1 02             	add    $0x2,%ecx
  800bd2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd7:	eb 16                	jmp    800bef <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bd9:	85 db                	test   %ebx,%ebx
  800bdb:	75 12                	jne    800bef <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bdd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be2:	80 39 30             	cmpb   $0x30,(%ecx)
  800be5:	75 08                	jne    800bef <strtol+0x6e>
		s++, base = 8;
  800be7:	83 c1 01             	add    $0x1,%ecx
  800bea:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bef:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf7:	0f b6 11             	movzbl (%ecx),%edx
  800bfa:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bfd:	89 f3                	mov    %esi,%ebx
  800bff:	80 fb 09             	cmp    $0x9,%bl
  800c02:	77 08                	ja     800c0c <strtol+0x8b>
			dig = *s - '0';
  800c04:	0f be d2             	movsbl %dl,%edx
  800c07:	83 ea 30             	sub    $0x30,%edx
  800c0a:	eb 22                	jmp    800c2e <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c0c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0f:	89 f3                	mov    %esi,%ebx
  800c11:	80 fb 19             	cmp    $0x19,%bl
  800c14:	77 08                	ja     800c1e <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c16:	0f be d2             	movsbl %dl,%edx
  800c19:	83 ea 57             	sub    $0x57,%edx
  800c1c:	eb 10                	jmp    800c2e <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c1e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c21:	89 f3                	mov    %esi,%ebx
  800c23:	80 fb 19             	cmp    $0x19,%bl
  800c26:	77 16                	ja     800c3e <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c28:	0f be d2             	movsbl %dl,%edx
  800c2b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c31:	7d 0b                	jge    800c3e <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c33:	83 c1 01             	add    $0x1,%ecx
  800c36:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c3a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c3c:	eb b9                	jmp    800bf7 <strtol+0x76>

	if (endptr)
  800c3e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c42:	74 0d                	je     800c51 <strtol+0xd0>
		*endptr = (char *) s;
  800c44:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c47:	89 0e                	mov    %ecx,(%esi)
  800c49:	eb 06                	jmp    800c51 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4b:	85 db                	test   %ebx,%ebx
  800c4d:	74 98                	je     800be7 <strtol+0x66>
  800c4f:	eb 9e                	jmp    800bef <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c51:	89 c2                	mov    %eax,%edx
  800c53:	f7 da                	neg    %edx
  800c55:	85 ff                	test   %edi,%edi
  800c57:	0f 45 c2             	cmovne %edx,%eax
}
  800c5a:	5b                   	pop    %ebx
  800c5b:	5e                   	pop    %esi
  800c5c:	5f                   	pop    %edi
  800c5d:	5d                   	pop    %ebp
  800c5e:	c3                   	ret    

00800c5f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c5f:	55                   	push   %ebp
  800c60:	89 e5                	mov    %esp,%ebp
  800c62:	57                   	push   %edi
  800c63:	56                   	push   %esi
  800c64:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c65:	b8 00 00 00 00       	mov    $0x0,%eax
  800c6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c70:	89 c3                	mov    %eax,%ebx
  800c72:	89 c7                	mov    %eax,%edi
  800c74:	89 c6                	mov    %eax,%esi
  800c76:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c78:	5b                   	pop    %ebx
  800c79:	5e                   	pop    %esi
  800c7a:	5f                   	pop    %edi
  800c7b:	5d                   	pop    %ebp
  800c7c:	c3                   	ret    

00800c7d <sys_cgetc>:

int
sys_cgetc(void)
{
  800c7d:	55                   	push   %ebp
  800c7e:	89 e5                	mov    %esp,%ebp
  800c80:	57                   	push   %edi
  800c81:	56                   	push   %esi
  800c82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c83:	ba 00 00 00 00       	mov    $0x0,%edx
  800c88:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8d:	89 d1                	mov    %edx,%ecx
  800c8f:	89 d3                	mov    %edx,%ebx
  800c91:	89 d7                	mov    %edx,%edi
  800c93:	89 d6                	mov    %edx,%esi
  800c95:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c97:	5b                   	pop    %ebx
  800c98:	5e                   	pop    %esi
  800c99:	5f                   	pop    %edi
  800c9a:	5d                   	pop    %ebp
  800c9b:	c3                   	ret    

00800c9c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	57                   	push   %edi
  800ca0:	56                   	push   %esi
  800ca1:	53                   	push   %ebx
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800caa:	b8 03 00 00 00       	mov    $0x3,%eax
  800caf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb2:	89 cb                	mov    %ecx,%ebx
  800cb4:	89 cf                	mov    %ecx,%edi
  800cb6:	89 ce                	mov    %ecx,%esi
  800cb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 17                	jle    800cd5 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 03                	push   $0x3
  800cc4:	68 9f 23 80 00       	push   $0x80239f
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 bc 23 80 00       	push   $0x8023bc
  800cd0:	e8 66 f5 ff ff       	call   80023b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce8:	b8 02 00 00 00       	mov    $0x2,%eax
  800ced:	89 d1                	mov    %edx,%ecx
  800cef:	89 d3                	mov    %edx,%ebx
  800cf1:	89 d7                	mov    %edx,%edi
  800cf3:	89 d6                	mov    %edx,%esi
  800cf5:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    

00800cfc <sys_yield>:

void
sys_yield(void)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d02:	ba 00 00 00 00       	mov    $0x0,%edx
  800d07:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d0c:	89 d1                	mov    %edx,%ecx
  800d0e:	89 d3                	mov    %edx,%ebx
  800d10:	89 d7                	mov    %edx,%edi
  800d12:	89 d6                	mov    %edx,%esi
  800d14:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d16:	5b                   	pop    %ebx
  800d17:	5e                   	pop    %esi
  800d18:	5f                   	pop    %edi
  800d19:	5d                   	pop    %ebp
  800d1a:	c3                   	ret    

00800d1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	57                   	push   %edi
  800d1f:	56                   	push   %esi
  800d20:	53                   	push   %ebx
  800d21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d24:	be 00 00 00 00       	mov    $0x0,%esi
  800d29:	b8 04 00 00 00       	mov    $0x4,%eax
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	8b 55 08             	mov    0x8(%ebp),%edx
  800d34:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d37:	89 f7                	mov    %esi,%edi
  800d39:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7e 17                	jle    800d56 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3f:	83 ec 0c             	sub    $0xc,%esp
  800d42:	50                   	push   %eax
  800d43:	6a 04                	push   $0x4
  800d45:	68 9f 23 80 00       	push   $0x80239f
  800d4a:	6a 23                	push   $0x23
  800d4c:	68 bc 23 80 00       	push   $0x8023bc
  800d51:	e8 e5 f4 ff ff       	call   80023b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d67:	b8 05 00 00 00       	mov    $0x5,%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d75:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d78:	8b 75 18             	mov    0x18(%ebp),%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 05                	push   $0x5
  800d87:	68 9f 23 80 00       	push   $0x80239f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 bc 23 80 00       	push   $0x8023bc
  800d93:	e8 a3 f4 ff ff       	call   80023b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
  800da6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dae:	b8 06 00 00 00       	mov    $0x6,%eax
  800db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db6:	8b 55 08             	mov    0x8(%ebp),%edx
  800db9:	89 df                	mov    %ebx,%edi
  800dbb:	89 de                	mov    %ebx,%esi
  800dbd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	7e 17                	jle    800dda <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc3:	83 ec 0c             	sub    $0xc,%esp
  800dc6:	50                   	push   %eax
  800dc7:	6a 06                	push   $0x6
  800dc9:	68 9f 23 80 00       	push   $0x80239f
  800dce:	6a 23                	push   $0x23
  800dd0:	68 bc 23 80 00       	push   $0x8023bc
  800dd5:	e8 61 f4 ff ff       	call   80023b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df0:	b8 08 00 00 00       	mov    $0x8,%eax
  800df5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df8:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfb:	89 df                	mov    %ebx,%edi
  800dfd:	89 de                	mov    %ebx,%esi
  800dff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e01:	85 c0                	test   %eax,%eax
  800e03:	7e 17                	jle    800e1c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e05:	83 ec 0c             	sub    $0xc,%esp
  800e08:	50                   	push   %eax
  800e09:	6a 08                	push   $0x8
  800e0b:	68 9f 23 80 00       	push   $0x80239f
  800e10:	6a 23                	push   $0x23
  800e12:	68 bc 23 80 00       	push   $0x8023bc
  800e17:	e8 1f f4 ff ff       	call   80023b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1f:	5b                   	pop    %ebx
  800e20:	5e                   	pop    %esi
  800e21:	5f                   	pop    %edi
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	57                   	push   %edi
  800e28:	56                   	push   %esi
  800e29:	53                   	push   %ebx
  800e2a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e32:	b8 09 00 00 00       	mov    $0x9,%eax
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	89 df                	mov    %ebx,%edi
  800e3f:	89 de                	mov    %ebx,%esi
  800e41:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e43:	85 c0                	test   %eax,%eax
  800e45:	7e 17                	jle    800e5e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e47:	83 ec 0c             	sub    $0xc,%esp
  800e4a:	50                   	push   %eax
  800e4b:	6a 09                	push   $0x9
  800e4d:	68 9f 23 80 00       	push   $0x80239f
  800e52:	6a 23                	push   $0x23
  800e54:	68 bc 23 80 00       	push   $0x8023bc
  800e59:	e8 dd f3 ff ff       	call   80023b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	53                   	push   %ebx
  800e6c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e74:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	89 df                	mov    %ebx,%edi
  800e81:	89 de                	mov    %ebx,%esi
  800e83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 17                	jle    800ea0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	83 ec 0c             	sub    $0xc,%esp
  800e8c:	50                   	push   %eax
  800e8d:	6a 0a                	push   $0xa
  800e8f:	68 9f 23 80 00       	push   $0x80239f
  800e94:	6a 23                	push   $0x23
  800e96:	68 bc 23 80 00       	push   $0x8023bc
  800e9b:	e8 9b f3 ff ff       	call   80023b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ea0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eae:	be 00 00 00 00       	mov    $0x0,%esi
  800eb3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec6:	5b                   	pop    %ebx
  800ec7:	5e                   	pop    %esi
  800ec8:	5f                   	pop    %edi
  800ec9:	5d                   	pop    %ebp
  800eca:	c3                   	ret    

00800ecb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
  800ece:	57                   	push   %edi
  800ecf:	56                   	push   %esi
  800ed0:	53                   	push   %ebx
  800ed1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ed4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ede:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee1:	89 cb                	mov    %ecx,%ebx
  800ee3:	89 cf                	mov    %ecx,%edi
  800ee5:	89 ce                	mov    %ecx,%esi
  800ee7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee9:	85 c0                	test   %eax,%eax
  800eeb:	7e 17                	jle    800f04 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eed:	83 ec 0c             	sub    $0xc,%esp
  800ef0:	50                   	push   %eax
  800ef1:	6a 0d                	push   $0xd
  800ef3:	68 9f 23 80 00       	push   $0x80239f
  800ef8:	6a 23                	push   $0x23
  800efa:	68 bc 23 80 00       	push   $0x8023bc
  800eff:	e8 37 f3 ff ff       	call   80023b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f07:	5b                   	pop    %ebx
  800f08:	5e                   	pop    %esi
  800f09:	5f                   	pop    %edi
  800f0a:	5d                   	pop    %ebp
  800f0b:	c3                   	ret    

00800f0c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f12:	05 00 00 00 30       	add    $0x30000000,%eax
  800f17:	c1 e8 0c             	shr    $0xc,%eax
}
  800f1a:	5d                   	pop    %ebp
  800f1b:	c3                   	ret    

00800f1c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	05 00 00 00 30       	add    $0x30000000,%eax
  800f27:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f2c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f31:	5d                   	pop    %ebp
  800f32:	c3                   	ret    

00800f33 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f33:	55                   	push   %ebp
  800f34:	89 e5                	mov    %esp,%ebp
  800f36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f39:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f3e:	89 c2                	mov    %eax,%edx
  800f40:	c1 ea 16             	shr    $0x16,%edx
  800f43:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f4a:	f6 c2 01             	test   $0x1,%dl
  800f4d:	74 11                	je     800f60 <fd_alloc+0x2d>
  800f4f:	89 c2                	mov    %eax,%edx
  800f51:	c1 ea 0c             	shr    $0xc,%edx
  800f54:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f5b:	f6 c2 01             	test   $0x1,%dl
  800f5e:	75 09                	jne    800f69 <fd_alloc+0x36>
			*fd_store = fd;
  800f60:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f62:	b8 00 00 00 00       	mov    $0x0,%eax
  800f67:	eb 17                	jmp    800f80 <fd_alloc+0x4d>
  800f69:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f6e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f73:	75 c9                	jne    800f3e <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f75:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f7b:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    

00800f82 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f88:	83 f8 1f             	cmp    $0x1f,%eax
  800f8b:	77 36                	ja     800fc3 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f8d:	c1 e0 0c             	shl    $0xc,%eax
  800f90:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f95:	89 c2                	mov    %eax,%edx
  800f97:	c1 ea 16             	shr    $0x16,%edx
  800f9a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fa1:	f6 c2 01             	test   $0x1,%dl
  800fa4:	74 24                	je     800fca <fd_lookup+0x48>
  800fa6:	89 c2                	mov    %eax,%edx
  800fa8:	c1 ea 0c             	shr    $0xc,%edx
  800fab:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fb2:	f6 c2 01             	test   $0x1,%dl
  800fb5:	74 1a                	je     800fd1 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fba:	89 02                	mov    %eax,(%edx)
	return 0;
  800fbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc1:	eb 13                	jmp    800fd6 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fc3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fc8:	eb 0c                	jmp    800fd6 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800fca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fcf:	eb 05                	jmp    800fd6 <fd_lookup+0x54>
  800fd1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    

00800fd8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 08             	sub    $0x8,%esp
  800fde:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe1:	ba 4c 24 80 00       	mov    $0x80244c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fe6:	eb 13                	jmp    800ffb <dev_lookup+0x23>
  800fe8:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800feb:	39 08                	cmp    %ecx,(%eax)
  800fed:	75 0c                	jne    800ffb <dev_lookup+0x23>
			*dev = devtab[i];
  800fef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ff2:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ff4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff9:	eb 2e                	jmp    801029 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ffb:	8b 02                	mov    (%edx),%eax
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	75 e7                	jne    800fe8 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801001:	a1 04 40 80 00       	mov    0x804004,%eax
  801006:	8b 40 48             	mov    0x48(%eax),%eax
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	51                   	push   %ecx
  80100d:	50                   	push   %eax
  80100e:	68 cc 23 80 00       	push   $0x8023cc
  801013:	e8 fc f2 ff ff       	call   800314 <cprintf>
	*dev = 0;
  801018:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801021:	83 c4 10             	add    $0x10,%esp
  801024:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	56                   	push   %esi
  80102f:	53                   	push   %ebx
  801030:	83 ec 10             	sub    $0x10,%esp
  801033:	8b 75 08             	mov    0x8(%ebp),%esi
  801036:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801043:	c1 e8 0c             	shr    $0xc,%eax
  801046:	50                   	push   %eax
  801047:	e8 36 ff ff ff       	call   800f82 <fd_lookup>
  80104c:	83 c4 08             	add    $0x8,%esp
  80104f:	85 c0                	test   %eax,%eax
  801051:	78 05                	js     801058 <fd_close+0x2d>
	    || fd != fd2)
  801053:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801056:	74 0c                	je     801064 <fd_close+0x39>
		return (must_exist ? r : 0);
  801058:	84 db                	test   %bl,%bl
  80105a:	ba 00 00 00 00       	mov    $0x0,%edx
  80105f:	0f 44 c2             	cmove  %edx,%eax
  801062:	eb 41                	jmp    8010a5 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80106a:	50                   	push   %eax
  80106b:	ff 36                	pushl  (%esi)
  80106d:	e8 66 ff ff ff       	call   800fd8 <dev_lookup>
  801072:	89 c3                	mov    %eax,%ebx
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 1a                	js     801095 <fd_close+0x6a>
		if (dev->dev_close)
  80107b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801081:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801086:	85 c0                	test   %eax,%eax
  801088:	74 0b                	je     801095 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	56                   	push   %esi
  80108e:	ff d0                	call   *%eax
  801090:	89 c3                	mov    %eax,%ebx
  801092:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801095:	83 ec 08             	sub    $0x8,%esp
  801098:	56                   	push   %esi
  801099:	6a 00                	push   $0x0
  80109b:	e8 00 fd ff ff       	call   800da0 <sys_page_unmap>
	return r;
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	89 d8                	mov    %ebx,%eax
}
  8010a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a8:	5b                   	pop    %ebx
  8010a9:	5e                   	pop    %esi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010b2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010b5:	50                   	push   %eax
  8010b6:	ff 75 08             	pushl  0x8(%ebp)
  8010b9:	e8 c4 fe ff ff       	call   800f82 <fd_lookup>
  8010be:	83 c4 08             	add    $0x8,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 10                	js     8010d5 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8010c5:	83 ec 08             	sub    $0x8,%esp
  8010c8:	6a 01                	push   $0x1
  8010ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8010cd:	e8 59 ff ff ff       	call   80102b <fd_close>
  8010d2:	83 c4 10             	add    $0x10,%esp
}
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <close_all>:

void
close_all(void)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	53                   	push   %ebx
  8010db:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010de:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	53                   	push   %ebx
  8010e7:	e8 c0 ff ff ff       	call   8010ac <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ec:	83 c3 01             	add    $0x1,%ebx
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	83 fb 20             	cmp    $0x20,%ebx
  8010f5:	75 ec                	jne    8010e3 <close_all+0xc>
		close(i);
}
  8010f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fa:	c9                   	leave  
  8010fb:	c3                   	ret    

008010fc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010fc:	55                   	push   %ebp
  8010fd:	89 e5                	mov    %esp,%ebp
  8010ff:	57                   	push   %edi
  801100:	56                   	push   %esi
  801101:	53                   	push   %ebx
  801102:	83 ec 2c             	sub    $0x2c,%esp
  801105:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801108:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80110b:	50                   	push   %eax
  80110c:	ff 75 08             	pushl  0x8(%ebp)
  80110f:	e8 6e fe ff ff       	call   800f82 <fd_lookup>
  801114:	83 c4 08             	add    $0x8,%esp
  801117:	85 c0                	test   %eax,%eax
  801119:	0f 88 c1 00 00 00    	js     8011e0 <dup+0xe4>
		return r;
	close(newfdnum);
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	56                   	push   %esi
  801123:	e8 84 ff ff ff       	call   8010ac <close>

	newfd = INDEX2FD(newfdnum);
  801128:	89 f3                	mov    %esi,%ebx
  80112a:	c1 e3 0c             	shl    $0xc,%ebx
  80112d:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801133:	83 c4 04             	add    $0x4,%esp
  801136:	ff 75 e4             	pushl  -0x1c(%ebp)
  801139:	e8 de fd ff ff       	call   800f1c <fd2data>
  80113e:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801140:	89 1c 24             	mov    %ebx,(%esp)
  801143:	e8 d4 fd ff ff       	call   800f1c <fd2data>
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80114e:	89 f8                	mov    %edi,%eax
  801150:	c1 e8 16             	shr    $0x16,%eax
  801153:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80115a:	a8 01                	test   $0x1,%al
  80115c:	74 37                	je     801195 <dup+0x99>
  80115e:	89 f8                	mov    %edi,%eax
  801160:	c1 e8 0c             	shr    $0xc,%eax
  801163:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80116a:	f6 c2 01             	test   $0x1,%dl
  80116d:	74 26                	je     801195 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80116f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	25 07 0e 00 00       	and    $0xe07,%eax
  80117e:	50                   	push   %eax
  80117f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801182:	6a 00                	push   $0x0
  801184:	57                   	push   %edi
  801185:	6a 00                	push   $0x0
  801187:	e8 d2 fb ff ff       	call   800d5e <sys_page_map>
  80118c:	89 c7                	mov    %eax,%edi
  80118e:	83 c4 20             	add    $0x20,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	78 2e                	js     8011c3 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801195:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801198:	89 d0                	mov    %edx,%eax
  80119a:	c1 e8 0c             	shr    $0xc,%eax
  80119d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8011ac:	50                   	push   %eax
  8011ad:	53                   	push   %ebx
  8011ae:	6a 00                	push   $0x0
  8011b0:	52                   	push   %edx
  8011b1:	6a 00                	push   $0x0
  8011b3:	e8 a6 fb ff ff       	call   800d5e <sys_page_map>
  8011b8:	89 c7                	mov    %eax,%edi
  8011ba:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8011bd:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011bf:	85 ff                	test   %edi,%edi
  8011c1:	79 1d                	jns    8011e0 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	53                   	push   %ebx
  8011c7:	6a 00                	push   $0x0
  8011c9:	e8 d2 fb ff ff       	call   800da0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011ce:	83 c4 08             	add    $0x8,%esp
  8011d1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8011d4:	6a 00                	push   $0x0
  8011d6:	e8 c5 fb ff ff       	call   800da0 <sys_page_unmap>
	return r;
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	89 f8                	mov    %edi,%eax
}
  8011e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 14             	sub    $0x14,%esp
  8011ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f5:	50                   	push   %eax
  8011f6:	53                   	push   %ebx
  8011f7:	e8 86 fd ff ff       	call   800f82 <fd_lookup>
  8011fc:	83 c4 08             	add    $0x8,%esp
  8011ff:	89 c2                	mov    %eax,%edx
  801201:	85 c0                	test   %eax,%eax
  801203:	78 6d                	js     801272 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801205:	83 ec 08             	sub    $0x8,%esp
  801208:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120b:	50                   	push   %eax
  80120c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120f:	ff 30                	pushl  (%eax)
  801211:	e8 c2 fd ff ff       	call   800fd8 <dev_lookup>
  801216:	83 c4 10             	add    $0x10,%esp
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 4c                	js     801269 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80121d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801220:	8b 42 08             	mov    0x8(%edx),%eax
  801223:	83 e0 03             	and    $0x3,%eax
  801226:	83 f8 01             	cmp    $0x1,%eax
  801229:	75 21                	jne    80124c <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80122b:	a1 04 40 80 00       	mov    0x804004,%eax
  801230:	8b 40 48             	mov    0x48(%eax),%eax
  801233:	83 ec 04             	sub    $0x4,%esp
  801236:	53                   	push   %ebx
  801237:	50                   	push   %eax
  801238:	68 10 24 80 00       	push   $0x802410
  80123d:	e8 d2 f0 ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80124a:	eb 26                	jmp    801272 <read+0x8a>
	}
	if (!dev->dev_read)
  80124c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124f:	8b 40 08             	mov    0x8(%eax),%eax
  801252:	85 c0                	test   %eax,%eax
  801254:	74 17                	je     80126d <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801256:	83 ec 04             	sub    $0x4,%esp
  801259:	ff 75 10             	pushl  0x10(%ebp)
  80125c:	ff 75 0c             	pushl  0xc(%ebp)
  80125f:	52                   	push   %edx
  801260:	ff d0                	call   *%eax
  801262:	89 c2                	mov    %eax,%edx
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	eb 09                	jmp    801272 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801269:	89 c2                	mov    %eax,%edx
  80126b:	eb 05                	jmp    801272 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80126d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801272:	89 d0                	mov    %edx,%eax
  801274:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801277:	c9                   	leave  
  801278:	c3                   	ret    

00801279 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	57                   	push   %edi
  80127d:	56                   	push   %esi
  80127e:	53                   	push   %ebx
  80127f:	83 ec 0c             	sub    $0xc,%esp
  801282:	8b 7d 08             	mov    0x8(%ebp),%edi
  801285:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801288:	bb 00 00 00 00       	mov    $0x0,%ebx
  80128d:	eb 21                	jmp    8012b0 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	89 f0                	mov    %esi,%eax
  801294:	29 d8                	sub    %ebx,%eax
  801296:	50                   	push   %eax
  801297:	89 d8                	mov    %ebx,%eax
  801299:	03 45 0c             	add    0xc(%ebp),%eax
  80129c:	50                   	push   %eax
  80129d:	57                   	push   %edi
  80129e:	e8 45 ff ff ff       	call   8011e8 <read>
		if (m < 0)
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 10                	js     8012ba <readn+0x41>
			return m;
		if (m == 0)
  8012aa:	85 c0                	test   %eax,%eax
  8012ac:	74 0a                	je     8012b8 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012ae:	01 c3                	add    %eax,%ebx
  8012b0:	39 f3                	cmp    %esi,%ebx
  8012b2:	72 db                	jb     80128f <readn+0x16>
  8012b4:	89 d8                	mov    %ebx,%eax
  8012b6:	eb 02                	jmp    8012ba <readn+0x41>
  8012b8:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8012ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bd:	5b                   	pop    %ebx
  8012be:	5e                   	pop    %esi
  8012bf:	5f                   	pop    %edi
  8012c0:	5d                   	pop    %ebp
  8012c1:	c3                   	ret    

008012c2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c2:	55                   	push   %ebp
  8012c3:	89 e5                	mov    %esp,%ebp
  8012c5:	53                   	push   %ebx
  8012c6:	83 ec 14             	sub    $0x14,%esp
  8012c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012cf:	50                   	push   %eax
  8012d0:	53                   	push   %ebx
  8012d1:	e8 ac fc ff ff       	call   800f82 <fd_lookup>
  8012d6:	83 c4 08             	add    $0x8,%esp
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 68                	js     801347 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012df:	83 ec 08             	sub    $0x8,%esp
  8012e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e5:	50                   	push   %eax
  8012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e9:	ff 30                	pushl  (%eax)
  8012eb:	e8 e8 fc ff ff       	call   800fd8 <dev_lookup>
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 47                	js     80133e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fa:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012fe:	75 21                	jne    801321 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801300:	a1 04 40 80 00       	mov    0x804004,%eax
  801305:	8b 40 48             	mov    0x48(%eax),%eax
  801308:	83 ec 04             	sub    $0x4,%esp
  80130b:	53                   	push   %ebx
  80130c:	50                   	push   %eax
  80130d:	68 2c 24 80 00       	push   $0x80242c
  801312:	e8 fd ef ff ff       	call   800314 <cprintf>
		return -E_INVAL;
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80131f:	eb 26                	jmp    801347 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801321:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801324:	8b 52 0c             	mov    0xc(%edx),%edx
  801327:	85 d2                	test   %edx,%edx
  801329:	74 17                	je     801342 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80132b:	83 ec 04             	sub    $0x4,%esp
  80132e:	ff 75 10             	pushl  0x10(%ebp)
  801331:	ff 75 0c             	pushl  0xc(%ebp)
  801334:	50                   	push   %eax
  801335:	ff d2                	call   *%edx
  801337:	89 c2                	mov    %eax,%edx
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	eb 09                	jmp    801347 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133e:	89 c2                	mov    %eax,%edx
  801340:	eb 05                	jmp    801347 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801342:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801347:	89 d0                	mov    %edx,%eax
  801349:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80134c:	c9                   	leave  
  80134d:	c3                   	ret    

0080134e <seek>:

int
seek(int fdnum, off_t offset)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801354:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801357:	50                   	push   %eax
  801358:	ff 75 08             	pushl  0x8(%ebp)
  80135b:	e8 22 fc ff ff       	call   800f82 <fd_lookup>
  801360:	83 c4 08             	add    $0x8,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 0e                	js     801375 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801367:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80136a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	53                   	push   %ebx
  80137b:	83 ec 14             	sub    $0x14,%esp
  80137e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801381:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	53                   	push   %ebx
  801386:	e8 f7 fb ff ff       	call   800f82 <fd_lookup>
  80138b:	83 c4 08             	add    $0x8,%esp
  80138e:	89 c2                	mov    %eax,%edx
  801390:	85 c0                	test   %eax,%eax
  801392:	78 65                	js     8013f9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801394:	83 ec 08             	sub    $0x8,%esp
  801397:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80139a:	50                   	push   %eax
  80139b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139e:	ff 30                	pushl  (%eax)
  8013a0:	e8 33 fc ff ff       	call   800fd8 <dev_lookup>
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 44                	js     8013f0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013af:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8013b3:	75 21                	jne    8013d6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8013b5:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ba:	8b 40 48             	mov    0x48(%eax),%eax
  8013bd:	83 ec 04             	sub    $0x4,%esp
  8013c0:	53                   	push   %ebx
  8013c1:	50                   	push   %eax
  8013c2:	68 ec 23 80 00       	push   $0x8023ec
  8013c7:	e8 48 ef ff ff       	call   800314 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8013cc:	83 c4 10             	add    $0x10,%esp
  8013cf:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d4:	eb 23                	jmp    8013f9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8013d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013d9:	8b 52 18             	mov    0x18(%edx),%edx
  8013dc:	85 d2                	test   %edx,%edx
  8013de:	74 14                	je     8013f4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013e0:	83 ec 08             	sub    $0x8,%esp
  8013e3:	ff 75 0c             	pushl  0xc(%ebp)
  8013e6:	50                   	push   %eax
  8013e7:	ff d2                	call   *%edx
  8013e9:	89 c2                	mov    %eax,%edx
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	eb 09                	jmp    8013f9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f0:	89 c2                	mov    %eax,%edx
  8013f2:	eb 05                	jmp    8013f9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8013f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8013f9:	89 d0                	mov    %edx,%eax
  8013fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801400:	55                   	push   %ebp
  801401:	89 e5                	mov    %esp,%ebp
  801403:	53                   	push   %ebx
  801404:	83 ec 14             	sub    $0x14,%esp
  801407:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	ff 75 08             	pushl  0x8(%ebp)
  801411:	e8 6c fb ff ff       	call   800f82 <fd_lookup>
  801416:	83 c4 08             	add    $0x8,%esp
  801419:	89 c2                	mov    %eax,%edx
  80141b:	85 c0                	test   %eax,%eax
  80141d:	78 58                	js     801477 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801425:	50                   	push   %eax
  801426:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801429:	ff 30                	pushl  (%eax)
  80142b:	e8 a8 fb ff ff       	call   800fd8 <dev_lookup>
  801430:	83 c4 10             	add    $0x10,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 37                	js     80146e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801437:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80143e:	74 32                	je     801472 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801440:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801443:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80144a:	00 00 00 
	stat->st_isdir = 0;
  80144d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801454:	00 00 00 
	stat->st_dev = dev;
  801457:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	53                   	push   %ebx
  801461:	ff 75 f0             	pushl  -0x10(%ebp)
  801464:	ff 50 14             	call   *0x14(%eax)
  801467:	89 c2                	mov    %eax,%edx
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	eb 09                	jmp    801477 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146e:	89 c2                	mov    %eax,%edx
  801470:	eb 05                	jmp    801477 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801472:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801477:	89 d0                	mov    %edx,%eax
  801479:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147c:	c9                   	leave  
  80147d:	c3                   	ret    

0080147e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80147e:	55                   	push   %ebp
  80147f:	89 e5                	mov    %esp,%ebp
  801481:	56                   	push   %esi
  801482:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801483:	83 ec 08             	sub    $0x8,%esp
  801486:	6a 00                	push   $0x0
  801488:	ff 75 08             	pushl  0x8(%ebp)
  80148b:	e8 e9 01 00 00       	call   801679 <open>
  801490:	89 c3                	mov    %eax,%ebx
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	85 c0                	test   %eax,%eax
  801497:	78 1b                	js     8014b4 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801499:	83 ec 08             	sub    $0x8,%esp
  80149c:	ff 75 0c             	pushl  0xc(%ebp)
  80149f:	50                   	push   %eax
  8014a0:	e8 5b ff ff ff       	call   801400 <fstat>
  8014a5:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a7:	89 1c 24             	mov    %ebx,(%esp)
  8014aa:	e8 fd fb ff ff       	call   8010ac <close>
	return r;
  8014af:	83 c4 10             	add    $0x10,%esp
  8014b2:	89 f0                	mov    %esi,%eax
}
  8014b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b7:	5b                   	pop    %ebx
  8014b8:	5e                   	pop    %esi
  8014b9:	5d                   	pop    %ebp
  8014ba:	c3                   	ret    

008014bb <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014bb:	55                   	push   %ebp
  8014bc:	89 e5                	mov    %esp,%ebp
  8014be:	56                   	push   %esi
  8014bf:	53                   	push   %ebx
  8014c0:	89 c6                	mov    %eax,%esi
  8014c2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014c4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8014cb:	75 12                	jne    8014df <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	6a 01                	push   $0x1
  8014d2:	e8 fb 07 00 00       	call   801cd2 <ipc_find_env>
  8014d7:	a3 00 40 80 00       	mov    %eax,0x804000
  8014dc:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014df:	6a 07                	push   $0x7
  8014e1:	68 00 50 80 00       	push   $0x805000
  8014e6:	56                   	push   %esi
  8014e7:	ff 35 00 40 80 00    	pushl  0x804000
  8014ed:	e8 8c 07 00 00       	call   801c7e <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  8014f2:	83 c4 0c             	add    $0xc,%esp
  8014f5:	6a 00                	push   $0x0
  8014f7:	53                   	push   %ebx
  8014f8:	6a 00                	push   $0x0
  8014fa:	e8 fd 06 00 00       	call   801bfc <ipc_recv>
}
  8014ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801502:	5b                   	pop    %ebx
  801503:	5e                   	pop    %esi
  801504:	5d                   	pop    %ebp
  801505:	c3                   	ret    

00801506 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801506:	55                   	push   %ebp
  801507:	89 e5                	mov    %esp,%ebp
  801509:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80150c:	8b 45 08             	mov    0x8(%ebp),%eax
  80150f:	8b 40 0c             	mov    0xc(%eax),%eax
  801512:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801517:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80151f:	ba 00 00 00 00       	mov    $0x0,%edx
  801524:	b8 02 00 00 00       	mov    $0x2,%eax
  801529:	e8 8d ff ff ff       	call   8014bb <fsipc>
}
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    

00801530 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801530:	55                   	push   %ebp
  801531:	89 e5                	mov    %esp,%ebp
  801533:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801536:	8b 45 08             	mov    0x8(%ebp),%eax
  801539:	8b 40 0c             	mov    0xc(%eax),%eax
  80153c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801541:	ba 00 00 00 00       	mov    $0x0,%edx
  801546:	b8 06 00 00 00       	mov    $0x6,%eax
  80154b:	e8 6b ff ff ff       	call   8014bb <fsipc>
}
  801550:	c9                   	leave  
  801551:	c3                   	ret    

00801552 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	53                   	push   %ebx
  801556:	83 ec 04             	sub    $0x4,%esp
  801559:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80155c:	8b 45 08             	mov    0x8(%ebp),%eax
  80155f:	8b 40 0c             	mov    0xc(%eax),%eax
  801562:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801567:	ba 00 00 00 00       	mov    $0x0,%edx
  80156c:	b8 05 00 00 00       	mov    $0x5,%eax
  801571:	e8 45 ff ff ff       	call   8014bb <fsipc>
  801576:	85 c0                	test   %eax,%eax
  801578:	78 2c                	js     8015a6 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	68 00 50 80 00       	push   $0x805000
  801582:	53                   	push   %ebx
  801583:	e8 90 f3 ff ff       	call   800918 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801588:	a1 80 50 80 00       	mov    0x805080,%eax
  80158d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801593:	a1 84 50 80 00       	mov    0x805084,%eax
  801598:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a9:	c9                   	leave  
  8015aa:	c3                   	ret    

008015ab <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8015ab:	55                   	push   %ebp
  8015ac:	89 e5                	mov    %esp,%ebp
  8015ae:	83 ec 0c             	sub    $0xc,%esp
  8015b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8015b4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8015b9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015be:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015c1:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c4:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c7:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8015cd:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8015d2:	50                   	push   %eax
  8015d3:	ff 75 0c             	pushl  0xc(%ebp)
  8015d6:	68 08 50 80 00       	push   $0x805008
  8015db:	e8 ca f4 ff ff       	call   800aaa <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8015e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e5:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ea:	e8 cc fe ff ff       	call   8014bb <fsipc>
            return r;

    return r;
}
  8015ef:	c9                   	leave  
  8015f0:	c3                   	ret    

008015f1 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	56                   	push   %esi
  8015f5:	53                   	push   %ebx
  8015f6:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8015ff:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801604:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80160a:	ba 00 00 00 00       	mov    $0x0,%edx
  80160f:	b8 03 00 00 00       	mov    $0x3,%eax
  801614:	e8 a2 fe ff ff       	call   8014bb <fsipc>
  801619:	89 c3                	mov    %eax,%ebx
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 51                	js     801670 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80161f:	39 c6                	cmp    %eax,%esi
  801621:	73 19                	jae    80163c <devfile_read+0x4b>
  801623:	68 5c 24 80 00       	push   $0x80245c
  801628:	68 63 24 80 00       	push   $0x802463
  80162d:	68 82 00 00 00       	push   $0x82
  801632:	68 78 24 80 00       	push   $0x802478
  801637:	e8 ff eb ff ff       	call   80023b <_panic>
	assert(r <= PGSIZE);
  80163c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801641:	7e 19                	jle    80165c <devfile_read+0x6b>
  801643:	68 83 24 80 00       	push   $0x802483
  801648:	68 63 24 80 00       	push   $0x802463
  80164d:	68 83 00 00 00       	push   $0x83
  801652:	68 78 24 80 00       	push   $0x802478
  801657:	e8 df eb ff ff       	call   80023b <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80165c:	83 ec 04             	sub    $0x4,%esp
  80165f:	50                   	push   %eax
  801660:	68 00 50 80 00       	push   $0x805000
  801665:	ff 75 0c             	pushl  0xc(%ebp)
  801668:	e8 3d f4 ff ff       	call   800aaa <memmove>
	return r;
  80166d:	83 c4 10             	add    $0x10,%esp
}
  801670:	89 d8                	mov    %ebx,%eax
  801672:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	53                   	push   %ebx
  80167d:	83 ec 20             	sub    $0x20,%esp
  801680:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801683:	53                   	push   %ebx
  801684:	e8 56 f2 ff ff       	call   8008df <strlen>
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801691:	7f 67                	jg     8016fa <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801693:	83 ec 0c             	sub    $0xc,%esp
  801696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	e8 94 f8 ff ff       	call   800f33 <fd_alloc>
  80169f:	83 c4 10             	add    $0x10,%esp
		return r;
  8016a2:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 57                	js     8016ff <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	53                   	push   %ebx
  8016ac:	68 00 50 80 00       	push   $0x805000
  8016b1:	e8 62 f2 ff ff       	call   800918 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c6:	e8 f0 fd ff ff       	call   8014bb <fsipc>
  8016cb:	89 c3                	mov    %eax,%ebx
  8016cd:	83 c4 10             	add    $0x10,%esp
  8016d0:	85 c0                	test   %eax,%eax
  8016d2:	79 14                	jns    8016e8 <open+0x6f>
		fd_close(fd, 0);
  8016d4:	83 ec 08             	sub    $0x8,%esp
  8016d7:	6a 00                	push   $0x0
  8016d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8016dc:	e8 4a f9 ff ff       	call   80102b <fd_close>
		return r;
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	89 da                	mov    %ebx,%edx
  8016e6:	eb 17                	jmp    8016ff <open+0x86>
	}

	return fd2num(fd);
  8016e8:	83 ec 0c             	sub    $0xc,%esp
  8016eb:	ff 75 f4             	pushl  -0xc(%ebp)
  8016ee:	e8 19 f8 ff ff       	call   800f0c <fd2num>
  8016f3:	89 c2                	mov    %eax,%edx
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	eb 05                	jmp    8016ff <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8016fa:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8016ff:	89 d0                	mov    %edx,%eax
  801701:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80170c:	ba 00 00 00 00       	mov    $0x0,%edx
  801711:	b8 08 00 00 00       	mov    $0x8,%eax
  801716:	e8 a0 fd ff ff       	call   8014bb <fsipc>
}
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
  801722:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801725:	83 ec 0c             	sub    $0xc,%esp
  801728:	ff 75 08             	pushl  0x8(%ebp)
  80172b:	e8 ec f7 ff ff       	call   800f1c <fd2data>
  801730:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801732:	83 c4 08             	add    $0x8,%esp
  801735:	68 8f 24 80 00       	push   $0x80248f
  80173a:	53                   	push   %ebx
  80173b:	e8 d8 f1 ff ff       	call   800918 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801740:	8b 46 04             	mov    0x4(%esi),%eax
  801743:	2b 06                	sub    (%esi),%eax
  801745:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80174b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801752:	00 00 00 
	stat->st_dev = &devpipe;
  801755:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80175c:	30 80 00 
	return 0;
}
  80175f:	b8 00 00 00 00       	mov    $0x0,%eax
  801764:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801767:	5b                   	pop    %ebx
  801768:	5e                   	pop    %esi
  801769:	5d                   	pop    %ebp
  80176a:	c3                   	ret    

0080176b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	53                   	push   %ebx
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801775:	53                   	push   %ebx
  801776:	6a 00                	push   $0x0
  801778:	e8 23 f6 ff ff       	call   800da0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80177d:	89 1c 24             	mov    %ebx,(%esp)
  801780:	e8 97 f7 ff ff       	call   800f1c <fd2data>
  801785:	83 c4 08             	add    $0x8,%esp
  801788:	50                   	push   %eax
  801789:	6a 00                	push   $0x0
  80178b:	e8 10 f6 ff ff       	call   800da0 <sys_page_unmap>
}
  801790:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	57                   	push   %edi
  801799:	56                   	push   %esi
  80179a:	53                   	push   %ebx
  80179b:	83 ec 1c             	sub    $0x1c,%esp
  80179e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017a1:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8017a3:	a1 04 40 80 00       	mov    0x804004,%eax
  8017a8:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8017ab:	83 ec 0c             	sub    $0xc,%esp
  8017ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8017b1:	e8 55 05 00 00       	call   801d0b <pageref>
  8017b6:	89 c3                	mov    %eax,%ebx
  8017b8:	89 3c 24             	mov    %edi,(%esp)
  8017bb:	e8 4b 05 00 00       	call   801d0b <pageref>
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	39 c3                	cmp    %eax,%ebx
  8017c5:	0f 94 c1             	sete   %cl
  8017c8:	0f b6 c9             	movzbl %cl,%ecx
  8017cb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8017ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8017d4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017d7:	39 ce                	cmp    %ecx,%esi
  8017d9:	74 1b                	je     8017f6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8017db:	39 c3                	cmp    %eax,%ebx
  8017dd:	75 c4                	jne    8017a3 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017df:	8b 42 58             	mov    0x58(%edx),%eax
  8017e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8017e5:	50                   	push   %eax
  8017e6:	56                   	push   %esi
  8017e7:	68 96 24 80 00       	push   $0x802496
  8017ec:	e8 23 eb ff ff       	call   800314 <cprintf>
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	eb ad                	jmp    8017a3 <_pipeisclosed+0xe>
	}
}
  8017f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017fc:	5b                   	pop    %ebx
  8017fd:	5e                   	pop    %esi
  8017fe:	5f                   	pop    %edi
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	57                   	push   %edi
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	83 ec 28             	sub    $0x28,%esp
  80180a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80180d:	56                   	push   %esi
  80180e:	e8 09 f7 ff ff       	call   800f1c <fd2data>
  801813:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	bf 00 00 00 00       	mov    $0x0,%edi
  80181d:	eb 4b                	jmp    80186a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80181f:	89 da                	mov    %ebx,%edx
  801821:	89 f0                	mov    %esi,%eax
  801823:	e8 6d ff ff ff       	call   801795 <_pipeisclosed>
  801828:	85 c0                	test   %eax,%eax
  80182a:	75 48                	jne    801874 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80182c:	e8 cb f4 ff ff       	call   800cfc <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801831:	8b 43 04             	mov    0x4(%ebx),%eax
  801834:	8b 0b                	mov    (%ebx),%ecx
  801836:	8d 51 20             	lea    0x20(%ecx),%edx
  801839:	39 d0                	cmp    %edx,%eax
  80183b:	73 e2                	jae    80181f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80183d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801840:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801844:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801847:	89 c2                	mov    %eax,%edx
  801849:	c1 fa 1f             	sar    $0x1f,%edx
  80184c:	89 d1                	mov    %edx,%ecx
  80184e:	c1 e9 1b             	shr    $0x1b,%ecx
  801851:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801854:	83 e2 1f             	and    $0x1f,%edx
  801857:	29 ca                	sub    %ecx,%edx
  801859:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80185d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801861:	83 c0 01             	add    $0x1,%eax
  801864:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801867:	83 c7 01             	add    $0x1,%edi
  80186a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80186d:	75 c2                	jne    801831 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80186f:	8b 45 10             	mov    0x10(%ebp),%eax
  801872:	eb 05                	jmp    801879 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801874:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801879:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187c:	5b                   	pop    %ebx
  80187d:	5e                   	pop    %esi
  80187e:	5f                   	pop    %edi
  80187f:	5d                   	pop    %ebp
  801880:	c3                   	ret    

00801881 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	57                   	push   %edi
  801885:	56                   	push   %esi
  801886:	53                   	push   %ebx
  801887:	83 ec 18             	sub    $0x18,%esp
  80188a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80188d:	57                   	push   %edi
  80188e:	e8 89 f6 ff ff       	call   800f1c <fd2data>
  801893:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	bb 00 00 00 00       	mov    $0x0,%ebx
  80189d:	eb 3d                	jmp    8018dc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80189f:	85 db                	test   %ebx,%ebx
  8018a1:	74 04                	je     8018a7 <devpipe_read+0x26>
				return i;
  8018a3:	89 d8                	mov    %ebx,%eax
  8018a5:	eb 44                	jmp    8018eb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8018a7:	89 f2                	mov    %esi,%edx
  8018a9:	89 f8                	mov    %edi,%eax
  8018ab:	e8 e5 fe ff ff       	call   801795 <_pipeisclosed>
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	75 32                	jne    8018e6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8018b4:	e8 43 f4 ff ff       	call   800cfc <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8018b9:	8b 06                	mov    (%esi),%eax
  8018bb:	3b 46 04             	cmp    0x4(%esi),%eax
  8018be:	74 df                	je     80189f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018c0:	99                   	cltd   
  8018c1:	c1 ea 1b             	shr    $0x1b,%edx
  8018c4:	01 d0                	add    %edx,%eax
  8018c6:	83 e0 1f             	and    $0x1f,%eax
  8018c9:	29 d0                	sub    %edx,%eax
  8018cb:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8018d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018d3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8018d6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8018d9:	83 c3 01             	add    $0x1,%ebx
  8018dc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8018df:	75 d8                	jne    8018b9 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8018e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e4:	eb 05                	jmp    8018eb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8018e6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8018eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	5f                   	pop    %edi
  8018f1:	5d                   	pop    %ebp
  8018f2:	c3                   	ret    

008018f3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8018fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018fe:	50                   	push   %eax
  8018ff:	e8 2f f6 ff ff       	call   800f33 <fd_alloc>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	89 c2                	mov    %eax,%edx
  801909:	85 c0                	test   %eax,%eax
  80190b:	0f 88 2c 01 00 00    	js     801a3d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801911:	83 ec 04             	sub    $0x4,%esp
  801914:	68 07 04 00 00       	push   $0x407
  801919:	ff 75 f4             	pushl  -0xc(%ebp)
  80191c:	6a 00                	push   $0x0
  80191e:	e8 f8 f3 ff ff       	call   800d1b <sys_page_alloc>
  801923:	83 c4 10             	add    $0x10,%esp
  801926:	89 c2                	mov    %eax,%edx
  801928:	85 c0                	test   %eax,%eax
  80192a:	0f 88 0d 01 00 00    	js     801a3d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801930:	83 ec 0c             	sub    $0xc,%esp
  801933:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801936:	50                   	push   %eax
  801937:	e8 f7 f5 ff ff       	call   800f33 <fd_alloc>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	83 c4 10             	add    $0x10,%esp
  801941:	85 c0                	test   %eax,%eax
  801943:	0f 88 e2 00 00 00    	js     801a2b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801949:	83 ec 04             	sub    $0x4,%esp
  80194c:	68 07 04 00 00       	push   $0x407
  801951:	ff 75 f0             	pushl  -0x10(%ebp)
  801954:	6a 00                	push   $0x0
  801956:	e8 c0 f3 ff ff       	call   800d1b <sys_page_alloc>
  80195b:	89 c3                	mov    %eax,%ebx
  80195d:	83 c4 10             	add    $0x10,%esp
  801960:	85 c0                	test   %eax,%eax
  801962:	0f 88 c3 00 00 00    	js     801a2b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	ff 75 f4             	pushl  -0xc(%ebp)
  80196e:	e8 a9 f5 ff ff       	call   800f1c <fd2data>
  801973:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801975:	83 c4 0c             	add    $0xc,%esp
  801978:	68 07 04 00 00       	push   $0x407
  80197d:	50                   	push   %eax
  80197e:	6a 00                	push   $0x0
  801980:	e8 96 f3 ff ff       	call   800d1b <sys_page_alloc>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	85 c0                	test   %eax,%eax
  80198c:	0f 88 89 00 00 00    	js     801a1b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801992:	83 ec 0c             	sub    $0xc,%esp
  801995:	ff 75 f0             	pushl  -0x10(%ebp)
  801998:	e8 7f f5 ff ff       	call   800f1c <fd2data>
  80199d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019a4:	50                   	push   %eax
  8019a5:	6a 00                	push   $0x0
  8019a7:	56                   	push   %esi
  8019a8:	6a 00                	push   $0x0
  8019aa:	e8 af f3 ff ff       	call   800d5e <sys_page_map>
  8019af:	89 c3                	mov    %eax,%ebx
  8019b1:	83 c4 20             	add    $0x20,%esp
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	78 55                	js     801a0d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8019b8:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8019c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019c6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8019cd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019d6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8019d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019db:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8019e2:	83 ec 0c             	sub    $0xc,%esp
  8019e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e8:	e8 1f f5 ff ff       	call   800f0c <fd2num>
  8019ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8019f0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8019f2:	83 c4 04             	add    $0x4,%esp
  8019f5:	ff 75 f0             	pushl  -0x10(%ebp)
  8019f8:	e8 0f f5 ff ff       	call   800f0c <fd2num>
  8019fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a00:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a03:	83 c4 10             	add    $0x10,%esp
  801a06:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0b:	eb 30                	jmp    801a3d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801a0d:	83 ec 08             	sub    $0x8,%esp
  801a10:	56                   	push   %esi
  801a11:	6a 00                	push   $0x0
  801a13:	e8 88 f3 ff ff       	call   800da0 <sys_page_unmap>
  801a18:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801a1b:	83 ec 08             	sub    $0x8,%esp
  801a1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801a21:	6a 00                	push   $0x0
  801a23:	e8 78 f3 ff ff       	call   800da0 <sys_page_unmap>
  801a28:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801a2b:	83 ec 08             	sub    $0x8,%esp
  801a2e:	ff 75 f4             	pushl  -0xc(%ebp)
  801a31:	6a 00                	push   $0x0
  801a33:	e8 68 f3 ff ff       	call   800da0 <sys_page_unmap>
  801a38:	83 c4 10             	add    $0x10,%esp
  801a3b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801a3d:	89 d0                	mov    %edx,%eax
  801a3f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a42:	5b                   	pop    %ebx
  801a43:	5e                   	pop    %esi
  801a44:	5d                   	pop    %ebp
  801a45:	c3                   	ret    

00801a46 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801a46:	55                   	push   %ebp
  801a47:	89 e5                	mov    %esp,%ebp
  801a49:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a4f:	50                   	push   %eax
  801a50:	ff 75 08             	pushl  0x8(%ebp)
  801a53:	e8 2a f5 ff ff       	call   800f82 <fd_lookup>
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	78 18                	js     801a77 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801a5f:	83 ec 0c             	sub    $0xc,%esp
  801a62:	ff 75 f4             	pushl  -0xc(%ebp)
  801a65:	e8 b2 f4 ff ff       	call   800f1c <fd2data>
	return _pipeisclosed(fd, p);
  801a6a:	89 c2                	mov    %eax,%edx
  801a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6f:	e8 21 fd ff ff       	call   801795 <_pipeisclosed>
  801a74:	83 c4 10             	add    $0x10,%esp
}
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a89:	68 ae 24 80 00       	push   $0x8024ae
  801a8e:	ff 75 0c             	pushl  0xc(%ebp)
  801a91:	e8 82 ee ff ff       	call   800918 <strcpy>
	return 0;
}
  801a96:	b8 00 00 00 00       	mov    $0x0,%eax
  801a9b:	c9                   	leave  
  801a9c:	c3                   	ret    

00801a9d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	57                   	push   %edi
  801aa1:	56                   	push   %esi
  801aa2:	53                   	push   %ebx
  801aa3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801aa9:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801aae:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ab4:	eb 2d                	jmp    801ae3 <devcons_write+0x46>
		m = n - tot;
  801ab6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ab9:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801abb:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801abe:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801ac3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ac6:	83 ec 04             	sub    $0x4,%esp
  801ac9:	53                   	push   %ebx
  801aca:	03 45 0c             	add    0xc(%ebp),%eax
  801acd:	50                   	push   %eax
  801ace:	57                   	push   %edi
  801acf:	e8 d6 ef ff ff       	call   800aaa <memmove>
		sys_cputs(buf, m);
  801ad4:	83 c4 08             	add    $0x8,%esp
  801ad7:	53                   	push   %ebx
  801ad8:	57                   	push   %edi
  801ad9:	e8 81 f1 ff ff       	call   800c5f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ade:	01 de                	add    %ebx,%esi
  801ae0:	83 c4 10             	add    $0x10,%esp
  801ae3:	89 f0                	mov    %esi,%eax
  801ae5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ae8:	72 cc                	jb     801ab6 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801aea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5f                   	pop    %edi
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	83 ec 08             	sub    $0x8,%esp
  801af8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801afd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b01:	74 2a                	je     801b2d <devcons_read+0x3b>
  801b03:	eb 05                	jmp    801b0a <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801b05:	e8 f2 f1 ff ff       	call   800cfc <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801b0a:	e8 6e f1 ff ff       	call   800c7d <sys_cgetc>
  801b0f:	85 c0                	test   %eax,%eax
  801b11:	74 f2                	je     801b05 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 16                	js     801b2d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801b17:	83 f8 04             	cmp    $0x4,%eax
  801b1a:	74 0c                	je     801b28 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801b1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1f:	88 02                	mov    %al,(%edx)
	return 1;
  801b21:	b8 01 00 00 00       	mov    $0x1,%eax
  801b26:	eb 05                	jmp    801b2d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801b28:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801b3b:	6a 01                	push   $0x1
  801b3d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b40:	50                   	push   %eax
  801b41:	e8 19 f1 ff ff       	call   800c5f <sys_cputs>
}
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	c9                   	leave  
  801b4a:	c3                   	ret    

00801b4b <getchar>:

int
getchar(void)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801b51:	6a 01                	push   $0x1
  801b53:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b56:	50                   	push   %eax
  801b57:	6a 00                	push   $0x0
  801b59:	e8 8a f6 ff ff       	call   8011e8 <read>
	if (r < 0)
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	85 c0                	test   %eax,%eax
  801b63:	78 0f                	js     801b74 <getchar+0x29>
		return r;
	if (r < 1)
  801b65:	85 c0                	test   %eax,%eax
  801b67:	7e 06                	jle    801b6f <getchar+0x24>
		return -E_EOF;
	return c;
  801b69:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b6d:	eb 05                	jmp    801b74 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b6f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b74:	c9                   	leave  
  801b75:	c3                   	ret    

00801b76 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7f:	50                   	push   %eax
  801b80:	ff 75 08             	pushl  0x8(%ebp)
  801b83:	e8 fa f3 ff ff       	call   800f82 <fd_lookup>
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	78 11                	js     801ba0 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b92:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b98:	39 10                	cmp    %edx,(%eax)
  801b9a:	0f 94 c0             	sete   %al
  801b9d:	0f b6 c0             	movzbl %al,%eax
}
  801ba0:	c9                   	leave  
  801ba1:	c3                   	ret    

00801ba2 <opencons>:

int
opencons(void)
{
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ba8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bab:	50                   	push   %eax
  801bac:	e8 82 f3 ff ff       	call   800f33 <fd_alloc>
  801bb1:	83 c4 10             	add    $0x10,%esp
		return r;
  801bb4:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801bb6:	85 c0                	test   %eax,%eax
  801bb8:	78 3e                	js     801bf8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bba:	83 ec 04             	sub    $0x4,%esp
  801bbd:	68 07 04 00 00       	push   $0x407
  801bc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc5:	6a 00                	push   $0x0
  801bc7:	e8 4f f1 ff ff       	call   800d1b <sys_page_alloc>
  801bcc:	83 c4 10             	add    $0x10,%esp
		return r;
  801bcf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	78 23                	js     801bf8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801bd5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bdb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bde:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801be0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801be3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801bea:	83 ec 0c             	sub    $0xc,%esp
  801bed:	50                   	push   %eax
  801bee:	e8 19 f3 ff ff       	call   800f0c <fd2num>
  801bf3:	89 c2                	mov    %eax,%edx
  801bf5:	83 c4 10             	add    $0x10,%esp
}
  801bf8:	89 d0                	mov    %edx,%eax
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	83 ec 0c             	sub    $0xc,%esp
  801c05:	8b 75 08             	mov    0x8(%ebp),%esi
  801c08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801c0e:	85 f6                	test   %esi,%esi
  801c10:	74 06                	je     801c18 <ipc_recv+0x1c>
		*from_env_store = 0;
  801c12:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801c18:	85 db                	test   %ebx,%ebx
  801c1a:	74 06                	je     801c22 <ipc_recv+0x26>
		*perm_store = 0;
  801c1c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801c22:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801c24:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801c29:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801c2c:	83 ec 0c             	sub    $0xc,%esp
  801c2f:	50                   	push   %eax
  801c30:	e8 96 f2 ff ff       	call   800ecb <sys_ipc_recv>
  801c35:	89 c7                	mov    %eax,%edi
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	79 14                	jns    801c52 <ipc_recv+0x56>
		cprintf("im dead");
  801c3e:	83 ec 0c             	sub    $0xc,%esp
  801c41:	68 ba 24 80 00       	push   $0x8024ba
  801c46:	e8 c9 e6 ff ff       	call   800314 <cprintf>
		return r;
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	89 f8                	mov    %edi,%eax
  801c50:	eb 24                	jmp    801c76 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801c52:	85 f6                	test   %esi,%esi
  801c54:	74 0a                	je     801c60 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801c56:	a1 04 40 80 00       	mov    0x804004,%eax
  801c5b:	8b 40 74             	mov    0x74(%eax),%eax
  801c5e:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801c60:	85 db                	test   %ebx,%ebx
  801c62:	74 0a                	je     801c6e <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801c64:	a1 04 40 80 00       	mov    0x804004,%eax
  801c69:	8b 40 78             	mov    0x78(%eax),%eax
  801c6c:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801c6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801c73:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 0c             	sub    $0xc,%esp
  801c87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801c90:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801c92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801c97:	0f 44 d8             	cmove  %eax,%ebx
  801c9a:	eb 1c                	jmp    801cb8 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801c9c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c9f:	74 12                	je     801cb3 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801ca1:	50                   	push   %eax
  801ca2:	68 c2 24 80 00       	push   $0x8024c2
  801ca7:	6a 4e                	push   $0x4e
  801ca9:	68 cf 24 80 00       	push   $0x8024cf
  801cae:	e8 88 e5 ff ff       	call   80023b <_panic>
		sys_yield();
  801cb3:	e8 44 f0 ff ff       	call   800cfc <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801cb8:	ff 75 14             	pushl  0x14(%ebp)
  801cbb:	53                   	push   %ebx
  801cbc:	56                   	push   %esi
  801cbd:	57                   	push   %edi
  801cbe:	e8 e5 f1 ff ff       	call   800ea8 <sys_ipc_try_send>
  801cc3:	83 c4 10             	add    $0x10,%esp
  801cc6:	85 c0                	test   %eax,%eax
  801cc8:	78 d2                	js     801c9c <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801cca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    

00801cd2 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801cdd:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ce0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ce6:	8b 52 50             	mov    0x50(%edx),%edx
  801ce9:	39 ca                	cmp    %ecx,%edx
  801ceb:	75 0d                	jne    801cfa <ipc_find_env+0x28>
			return envs[i].env_id;
  801ced:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801cf0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801cf5:	8b 40 48             	mov    0x48(%eax),%eax
  801cf8:	eb 0f                	jmp    801d09 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801cfa:	83 c0 01             	add    $0x1,%eax
  801cfd:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d02:	75 d9                	jne    801cdd <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    

00801d0b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d0b:	55                   	push   %ebp
  801d0c:	89 e5                	mov    %esp,%ebp
  801d0e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d11:	89 d0                	mov    %edx,%eax
  801d13:	c1 e8 16             	shr    $0x16,%eax
  801d16:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801d1d:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d22:	f6 c1 01             	test   $0x1,%cl
  801d25:	74 1d                	je     801d44 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801d27:	c1 ea 0c             	shr    $0xc,%edx
  801d2a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801d31:	f6 c2 01             	test   $0x1,%dl
  801d34:	74 0e                	je     801d44 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d36:	c1 ea 0c             	shr    $0xc,%edx
  801d39:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801d40:	ef 
  801d41:	0f b7 c0             	movzwl %ax,%eax
}
  801d44:	5d                   	pop    %ebp
  801d45:	c3                   	ret    
  801d46:	66 90                	xchg   %ax,%ax
  801d48:	66 90                	xchg   %ax,%ax
  801d4a:	66 90                	xchg   %ax,%ax
  801d4c:	66 90                	xchg   %ax,%ax
  801d4e:	66 90                	xchg   %ax,%ax

00801d50 <__udivdi3>:
  801d50:	55                   	push   %ebp
  801d51:	57                   	push   %edi
  801d52:	56                   	push   %esi
  801d53:	53                   	push   %ebx
  801d54:	83 ec 1c             	sub    $0x1c,%esp
  801d57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801d5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801d5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801d63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d67:	85 f6                	test   %esi,%esi
  801d69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d6d:	89 ca                	mov    %ecx,%edx
  801d6f:	89 f8                	mov    %edi,%eax
  801d71:	75 3d                	jne    801db0 <__udivdi3+0x60>
  801d73:	39 cf                	cmp    %ecx,%edi
  801d75:	0f 87 c5 00 00 00    	ja     801e40 <__udivdi3+0xf0>
  801d7b:	85 ff                	test   %edi,%edi
  801d7d:	89 fd                	mov    %edi,%ebp
  801d7f:	75 0b                	jne    801d8c <__udivdi3+0x3c>
  801d81:	b8 01 00 00 00       	mov    $0x1,%eax
  801d86:	31 d2                	xor    %edx,%edx
  801d88:	f7 f7                	div    %edi
  801d8a:	89 c5                	mov    %eax,%ebp
  801d8c:	89 c8                	mov    %ecx,%eax
  801d8e:	31 d2                	xor    %edx,%edx
  801d90:	f7 f5                	div    %ebp
  801d92:	89 c1                	mov    %eax,%ecx
  801d94:	89 d8                	mov    %ebx,%eax
  801d96:	89 cf                	mov    %ecx,%edi
  801d98:	f7 f5                	div    %ebp
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	89 d8                	mov    %ebx,%eax
  801d9e:	89 fa                	mov    %edi,%edx
  801da0:	83 c4 1c             	add    $0x1c,%esp
  801da3:	5b                   	pop    %ebx
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    
  801da8:	90                   	nop
  801da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801db0:	39 ce                	cmp    %ecx,%esi
  801db2:	77 74                	ja     801e28 <__udivdi3+0xd8>
  801db4:	0f bd fe             	bsr    %esi,%edi
  801db7:	83 f7 1f             	xor    $0x1f,%edi
  801dba:	0f 84 98 00 00 00    	je     801e58 <__udivdi3+0x108>
  801dc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801dc5:	89 f9                	mov    %edi,%ecx
  801dc7:	89 c5                	mov    %eax,%ebp
  801dc9:	29 fb                	sub    %edi,%ebx
  801dcb:	d3 e6                	shl    %cl,%esi
  801dcd:	89 d9                	mov    %ebx,%ecx
  801dcf:	d3 ed                	shr    %cl,%ebp
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	d3 e0                	shl    %cl,%eax
  801dd5:	09 ee                	or     %ebp,%esi
  801dd7:	89 d9                	mov    %ebx,%ecx
  801dd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ddd:	89 d5                	mov    %edx,%ebp
  801ddf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801de3:	d3 ed                	shr    %cl,%ebp
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	d3 e2                	shl    %cl,%edx
  801de9:	89 d9                	mov    %ebx,%ecx
  801deb:	d3 e8                	shr    %cl,%eax
  801ded:	09 c2                	or     %eax,%edx
  801def:	89 d0                	mov    %edx,%eax
  801df1:	89 ea                	mov    %ebp,%edx
  801df3:	f7 f6                	div    %esi
  801df5:	89 d5                	mov    %edx,%ebp
  801df7:	89 c3                	mov    %eax,%ebx
  801df9:	f7 64 24 0c          	mull   0xc(%esp)
  801dfd:	39 d5                	cmp    %edx,%ebp
  801dff:	72 10                	jb     801e11 <__udivdi3+0xc1>
  801e01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801e05:	89 f9                	mov    %edi,%ecx
  801e07:	d3 e6                	shl    %cl,%esi
  801e09:	39 c6                	cmp    %eax,%esi
  801e0b:	73 07                	jae    801e14 <__udivdi3+0xc4>
  801e0d:	39 d5                	cmp    %edx,%ebp
  801e0f:	75 03                	jne    801e14 <__udivdi3+0xc4>
  801e11:	83 eb 01             	sub    $0x1,%ebx
  801e14:	31 ff                	xor    %edi,%edi
  801e16:	89 d8                	mov    %ebx,%eax
  801e18:	89 fa                	mov    %edi,%edx
  801e1a:	83 c4 1c             	add    $0x1c,%esp
  801e1d:	5b                   	pop    %ebx
  801e1e:	5e                   	pop    %esi
  801e1f:	5f                   	pop    %edi
  801e20:	5d                   	pop    %ebp
  801e21:	c3                   	ret    
  801e22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e28:	31 ff                	xor    %edi,%edi
  801e2a:	31 db                	xor    %ebx,%ebx
  801e2c:	89 d8                	mov    %ebx,%eax
  801e2e:	89 fa                	mov    %edi,%edx
  801e30:	83 c4 1c             	add    $0x1c,%esp
  801e33:	5b                   	pop    %ebx
  801e34:	5e                   	pop    %esi
  801e35:	5f                   	pop    %edi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    
  801e38:	90                   	nop
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	89 d8                	mov    %ebx,%eax
  801e42:	f7 f7                	div    %edi
  801e44:	31 ff                	xor    %edi,%edi
  801e46:	89 c3                	mov    %eax,%ebx
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	89 fa                	mov    %edi,%edx
  801e4c:	83 c4 1c             	add    $0x1c,%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    
  801e54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e58:	39 ce                	cmp    %ecx,%esi
  801e5a:	72 0c                	jb     801e68 <__udivdi3+0x118>
  801e5c:	31 db                	xor    %ebx,%ebx
  801e5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801e62:	0f 87 34 ff ff ff    	ja     801d9c <__udivdi3+0x4c>
  801e68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801e6d:	e9 2a ff ff ff       	jmp    801d9c <__udivdi3+0x4c>
  801e72:	66 90                	xchg   %ax,%ax
  801e74:	66 90                	xchg   %ax,%ax
  801e76:	66 90                	xchg   %ax,%ax
  801e78:	66 90                	xchg   %ax,%ax
  801e7a:	66 90                	xchg   %ax,%ax
  801e7c:	66 90                	xchg   %ax,%ax
  801e7e:	66 90                	xchg   %ax,%ax

00801e80 <__umoddi3>:
  801e80:	55                   	push   %ebp
  801e81:	57                   	push   %edi
  801e82:	56                   	push   %esi
  801e83:	53                   	push   %ebx
  801e84:	83 ec 1c             	sub    $0x1c,%esp
  801e87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801e8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e97:	85 d2                	test   %edx,%edx
  801e99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801e9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ea1:	89 f3                	mov    %esi,%ebx
  801ea3:	89 3c 24             	mov    %edi,(%esp)
  801ea6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801eaa:	75 1c                	jne    801ec8 <__umoddi3+0x48>
  801eac:	39 f7                	cmp    %esi,%edi
  801eae:	76 50                	jbe    801f00 <__umoddi3+0x80>
  801eb0:	89 c8                	mov    %ecx,%eax
  801eb2:	89 f2                	mov    %esi,%edx
  801eb4:	f7 f7                	div    %edi
  801eb6:	89 d0                	mov    %edx,%eax
  801eb8:	31 d2                	xor    %edx,%edx
  801eba:	83 c4 1c             	add    $0x1c,%esp
  801ebd:	5b                   	pop    %ebx
  801ebe:	5e                   	pop    %esi
  801ebf:	5f                   	pop    %edi
  801ec0:	5d                   	pop    %ebp
  801ec1:	c3                   	ret    
  801ec2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ec8:	39 f2                	cmp    %esi,%edx
  801eca:	89 d0                	mov    %edx,%eax
  801ecc:	77 52                	ja     801f20 <__umoddi3+0xa0>
  801ece:	0f bd ea             	bsr    %edx,%ebp
  801ed1:	83 f5 1f             	xor    $0x1f,%ebp
  801ed4:	75 5a                	jne    801f30 <__umoddi3+0xb0>
  801ed6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801eda:	0f 82 e0 00 00 00    	jb     801fc0 <__umoddi3+0x140>
  801ee0:	39 0c 24             	cmp    %ecx,(%esp)
  801ee3:	0f 86 d7 00 00 00    	jbe    801fc0 <__umoddi3+0x140>
  801ee9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801eed:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ef1:	83 c4 1c             	add    $0x1c,%esp
  801ef4:	5b                   	pop    %ebx
  801ef5:	5e                   	pop    %esi
  801ef6:	5f                   	pop    %edi
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    
  801ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f00:	85 ff                	test   %edi,%edi
  801f02:	89 fd                	mov    %edi,%ebp
  801f04:	75 0b                	jne    801f11 <__umoddi3+0x91>
  801f06:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0b:	31 d2                	xor    %edx,%edx
  801f0d:	f7 f7                	div    %edi
  801f0f:	89 c5                	mov    %eax,%ebp
  801f11:	89 f0                	mov    %esi,%eax
  801f13:	31 d2                	xor    %edx,%edx
  801f15:	f7 f5                	div    %ebp
  801f17:	89 c8                	mov    %ecx,%eax
  801f19:	f7 f5                	div    %ebp
  801f1b:	89 d0                	mov    %edx,%eax
  801f1d:	eb 99                	jmp    801eb8 <__umoddi3+0x38>
  801f1f:	90                   	nop
  801f20:	89 c8                	mov    %ecx,%eax
  801f22:	89 f2                	mov    %esi,%edx
  801f24:	83 c4 1c             	add    $0x1c,%esp
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5f                   	pop    %edi
  801f2a:	5d                   	pop    %ebp
  801f2b:	c3                   	ret    
  801f2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f30:	8b 34 24             	mov    (%esp),%esi
  801f33:	bf 20 00 00 00       	mov    $0x20,%edi
  801f38:	89 e9                	mov    %ebp,%ecx
  801f3a:	29 ef                	sub    %ebp,%edi
  801f3c:	d3 e0                	shl    %cl,%eax
  801f3e:	89 f9                	mov    %edi,%ecx
  801f40:	89 f2                	mov    %esi,%edx
  801f42:	d3 ea                	shr    %cl,%edx
  801f44:	89 e9                	mov    %ebp,%ecx
  801f46:	09 c2                	or     %eax,%edx
  801f48:	89 d8                	mov    %ebx,%eax
  801f4a:	89 14 24             	mov    %edx,(%esp)
  801f4d:	89 f2                	mov    %esi,%edx
  801f4f:	d3 e2                	shl    %cl,%edx
  801f51:	89 f9                	mov    %edi,%ecx
  801f53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801f5b:	d3 e8                	shr    %cl,%eax
  801f5d:	89 e9                	mov    %ebp,%ecx
  801f5f:	89 c6                	mov    %eax,%esi
  801f61:	d3 e3                	shl    %cl,%ebx
  801f63:	89 f9                	mov    %edi,%ecx
  801f65:	89 d0                	mov    %edx,%eax
  801f67:	d3 e8                	shr    %cl,%eax
  801f69:	89 e9                	mov    %ebp,%ecx
  801f6b:	09 d8                	or     %ebx,%eax
  801f6d:	89 d3                	mov    %edx,%ebx
  801f6f:	89 f2                	mov    %esi,%edx
  801f71:	f7 34 24             	divl   (%esp)
  801f74:	89 d6                	mov    %edx,%esi
  801f76:	d3 e3                	shl    %cl,%ebx
  801f78:	f7 64 24 04          	mull   0x4(%esp)
  801f7c:	39 d6                	cmp    %edx,%esi
  801f7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f82:	89 d1                	mov    %edx,%ecx
  801f84:	89 c3                	mov    %eax,%ebx
  801f86:	72 08                	jb     801f90 <__umoddi3+0x110>
  801f88:	75 11                	jne    801f9b <__umoddi3+0x11b>
  801f8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801f8e:	73 0b                	jae    801f9b <__umoddi3+0x11b>
  801f90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801f94:	1b 14 24             	sbb    (%esp),%edx
  801f97:	89 d1                	mov    %edx,%ecx
  801f99:	89 c3                	mov    %eax,%ebx
  801f9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801f9f:	29 da                	sub    %ebx,%edx
  801fa1:	19 ce                	sbb    %ecx,%esi
  801fa3:	89 f9                	mov    %edi,%ecx
  801fa5:	89 f0                	mov    %esi,%eax
  801fa7:	d3 e0                	shl    %cl,%eax
  801fa9:	89 e9                	mov    %ebp,%ecx
  801fab:	d3 ea                	shr    %cl,%edx
  801fad:	89 e9                	mov    %ebp,%ecx
  801faf:	d3 ee                	shr    %cl,%esi
  801fb1:	09 d0                	or     %edx,%eax
  801fb3:	89 f2                	mov    %esi,%edx
  801fb5:	83 c4 1c             	add    $0x1c,%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5f                   	pop    %edi
  801fbb:	5d                   	pop    %ebp
  801fbc:	c3                   	ret    
  801fbd:	8d 76 00             	lea    0x0(%esi),%esi
  801fc0:	29 f9                	sub    %edi,%ecx
  801fc2:	19 d6                	sbb    %edx,%esi
  801fc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801fc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fcc:	e9 18 ff ff ff       	jmp    801ee9 <__umoddi3+0x69>
