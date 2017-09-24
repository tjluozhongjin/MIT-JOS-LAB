
obj/user/testfdsharing.debug:     file format elf32-i386


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
  80002c:	e8 87 01 00 00       	call   8001b8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char buf[512], buf2[512];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 14             	sub    $0x14,%esp
	int fd, r, n, n2;

	if ((fd = open("motd", O_RDONLY)) < 0)
  80003c:	6a 00                	push   $0x0
  80003e:	68 a0 23 80 00       	push   $0x8023a0
  800043:	e8 06 19 00 00       	call   80194e <open>
  800048:	89 c3                	mov    %eax,%ebx
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <umain+0x30>
		panic("open motd: %e", fd);
  800051:	50                   	push   %eax
  800052:	68 a5 23 80 00       	push   $0x8023a5
  800057:	6a 0c                	push   $0xc
  800059:	68 b3 23 80 00       	push   $0x8023b3
  80005e:	e8 b5 01 00 00       	call   800218 <_panic>
	seek(fd, 0);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	6a 00                	push   $0x0
  800068:	50                   	push   %eax
  800069:	e8 b5 15 00 00       	call   801623 <seek>
	if ((n = readn(fd, buf, sizeof buf)) <= 0)
  80006e:	83 c4 0c             	add    $0xc,%esp
  800071:	68 00 02 00 00       	push   $0x200
  800076:	68 20 42 80 00       	push   $0x804220
  80007b:	53                   	push   %ebx
  80007c:	e8 cd 14 00 00       	call   80154e <readn>
  800081:	89 c6                	mov    %eax,%esi
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	85 c0                	test   %eax,%eax
  800088:	7f 12                	jg     80009c <umain+0x69>
		panic("readn: %e", n);
  80008a:	50                   	push   %eax
  80008b:	68 c8 23 80 00       	push   $0x8023c8
  800090:	6a 0f                	push   $0xf
  800092:	68 b3 23 80 00       	push   $0x8023b3
  800097:	e8 7c 01 00 00       	call   800218 <_panic>

	if ((r = fork()) < 0)
  80009c:	e8 42 0f 00 00       	call   800fe3 <fork>
  8000a1:	89 c7                	mov    %eax,%edi
  8000a3:	85 c0                	test   %eax,%eax
  8000a5:	79 12                	jns    8000b9 <umain+0x86>
		panic("fork: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 d2 23 80 00       	push   $0x8023d2
  8000ad:	6a 12                	push   $0x12
  8000af:	68 b3 23 80 00       	push   $0x8023b3
  8000b4:	e8 5f 01 00 00       	call   800218 <_panic>
	if (r == 0) {
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	0f 85 9d 00 00 00    	jne    80015e <umain+0x12b>
		seek(fd, 0);
  8000c1:	83 ec 08             	sub    $0x8,%esp
  8000c4:	6a 00                	push   $0x0
  8000c6:	53                   	push   %ebx
  8000c7:	e8 57 15 00 00       	call   801623 <seek>
		cprintf("going to read in child (might page fault if your sharing is buggy)\n");
  8000cc:	c7 04 24 10 24 80 00 	movl   $0x802410,(%esp)
  8000d3:	e8 19 02 00 00       	call   8002f1 <cprintf>
		if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  8000d8:	83 c4 0c             	add    $0xc,%esp
  8000db:	68 00 02 00 00       	push   $0x200
  8000e0:	68 20 40 80 00       	push   $0x804020
  8000e5:	53                   	push   %ebx
  8000e6:	e8 63 14 00 00       	call   80154e <readn>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	39 c6                	cmp    %eax,%esi
  8000f0:	74 16                	je     800108 <umain+0xd5>
			panic("read in parent got %d, read in child got %d", n, n2);
  8000f2:	83 ec 0c             	sub    $0xc,%esp
  8000f5:	50                   	push   %eax
  8000f6:	56                   	push   %esi
  8000f7:	68 54 24 80 00       	push   $0x802454
  8000fc:	6a 17                	push   $0x17
  8000fe:	68 b3 23 80 00       	push   $0x8023b3
  800103:	e8 10 01 00 00       	call   800218 <_panic>
		if (memcmp(buf, buf2, n) != 0)
  800108:	83 ec 04             	sub    $0x4,%esp
  80010b:	56                   	push   %esi
  80010c:	68 20 40 80 00       	push   $0x804020
  800111:	68 20 42 80 00       	push   $0x804220
  800116:	e8 e7 09 00 00       	call   800b02 <memcmp>
  80011b:	83 c4 10             	add    $0x10,%esp
  80011e:	85 c0                	test   %eax,%eax
  800120:	74 14                	je     800136 <umain+0x103>
			panic("read in parent got different bytes from read in child");
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	68 80 24 80 00       	push   $0x802480
  80012a:	6a 19                	push   $0x19
  80012c:	68 b3 23 80 00       	push   $0x8023b3
  800131:	e8 e2 00 00 00       	call   800218 <_panic>
		cprintf("read in child succeeded\n");
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	68 db 23 80 00       	push   $0x8023db
  80013e:	e8 ae 01 00 00       	call   8002f1 <cprintf>
		seek(fd, 0);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	6a 00                	push   $0x0
  800148:	53                   	push   %ebx
  800149:	e8 d5 14 00 00       	call   801623 <seek>
		close(fd);
  80014e:	89 1c 24             	mov    %ebx,(%esp)
  800151:	e8 2b 12 00 00       	call   801381 <close>
		exit();
  800156:	e8 a3 00 00 00       	call   8001fe <exit>
  80015b:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  80015e:	83 ec 0c             	sub    $0xc,%esp
  800161:	57                   	push   %edi
  800162:	e8 e7 1b 00 00       	call   801d4e <wait>
	if ((n2 = readn(fd, buf2, sizeof buf2)) != n)
  800167:	83 c4 0c             	add    $0xc,%esp
  80016a:	68 00 02 00 00       	push   $0x200
  80016f:	68 20 40 80 00       	push   $0x804020
  800174:	53                   	push   %ebx
  800175:	e8 d4 13 00 00       	call   80154e <readn>
  80017a:	83 c4 10             	add    $0x10,%esp
  80017d:	39 c6                	cmp    %eax,%esi
  80017f:	74 16                	je     800197 <umain+0x164>
		panic("read in parent got %d, then got %d", n, n2);
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	50                   	push   %eax
  800185:	56                   	push   %esi
  800186:	68 b8 24 80 00       	push   $0x8024b8
  80018b:	6a 21                	push   $0x21
  80018d:	68 b3 23 80 00       	push   $0x8023b3
  800192:	e8 81 00 00 00       	call   800218 <_panic>
	cprintf("read in parent succeeded\n");
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	68 f4 23 80 00       	push   $0x8023f4
  80019f:	e8 4d 01 00 00       	call   8002f1 <cprintf>
	close(fd);
  8001a4:	89 1c 24             	mov    %ebx,(%esp)
  8001a7:	e8 d5 11 00 00       	call   801381 <close>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  8001ac:	cc                   	int3   

	breakpoint();
}
  8001ad:	83 c4 10             	add    $0x10,%esp
  8001b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5f                   	pop    %edi
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001c3:	e8 f2 0a 00 00       	call   800cba <sys_getenvid>
  8001c8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d5:	a3 20 44 80 00       	mov    %eax,0x804420

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001da:	85 db                	test   %ebx,%ebx
  8001dc:	7e 07                	jle    8001e5 <libmain+0x2d>
		binaryname = argv[0];
  8001de:	8b 06                	mov    (%esi),%eax
  8001e0:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	56                   	push   %esi
  8001e9:	53                   	push   %ebx
  8001ea:	e8 44 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001ef:	e8 0a 00 00 00       	call   8001fe <exit>
}
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fa:	5b                   	pop    %ebx
  8001fb:	5e                   	pop    %esi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    

008001fe <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800204:	e8 a3 11 00 00       	call   8013ac <close_all>
	sys_env_destroy(0);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	6a 00                	push   $0x0
  80020e:	e8 66 0a 00 00       	call   800c79 <sys_env_destroy>
}
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	56                   	push   %esi
  80021c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80021d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800220:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800226:	e8 8f 0a 00 00       	call   800cba <sys_getenvid>
  80022b:	83 ec 0c             	sub    $0xc,%esp
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	56                   	push   %esi
  800235:	50                   	push   %eax
  800236:	68 e8 24 80 00       	push   $0x8024e8
  80023b:	e8 b1 00 00 00       	call   8002f1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800240:	83 c4 18             	add    $0x18,%esp
  800243:	53                   	push   %ebx
  800244:	ff 75 10             	pushl  0x10(%ebp)
  800247:	e8 54 00 00 00       	call   8002a0 <vcprintf>
	cprintf("\n");
  80024c:	c7 04 24 f2 23 80 00 	movl   $0x8023f2,(%esp)
  800253:	e8 99 00 00 00       	call   8002f1 <cprintf>
  800258:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80025b:	cc                   	int3   
  80025c:	eb fd                	jmp    80025b <_panic+0x43>

0080025e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	53                   	push   %ebx
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800268:	8b 13                	mov    (%ebx),%edx
  80026a:	8d 42 01             	lea    0x1(%edx),%eax
  80026d:	89 03                	mov    %eax,(%ebx)
  80026f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800272:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800276:	3d ff 00 00 00       	cmp    $0xff,%eax
  80027b:	75 1a                	jne    800297 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80027d:	83 ec 08             	sub    $0x8,%esp
  800280:	68 ff 00 00 00       	push   $0xff
  800285:	8d 43 08             	lea    0x8(%ebx),%eax
  800288:	50                   	push   %eax
  800289:	e8 ae 09 00 00       	call   800c3c <sys_cputs>
		b->idx = 0;
  80028e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800294:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800297:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002a9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002b0:	00 00 00 
	b.cnt = 0;
  8002b3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002ba:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002bd:	ff 75 0c             	pushl  0xc(%ebp)
  8002c0:	ff 75 08             	pushl  0x8(%ebp)
  8002c3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002c9:	50                   	push   %eax
  8002ca:	68 5e 02 80 00       	push   $0x80025e
  8002cf:	e8 1a 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002d4:	83 c4 08             	add    $0x8,%esp
  8002d7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002dd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002e3:	50                   	push   %eax
  8002e4:	e8 53 09 00 00       	call   800c3c <sys_cputs>

	return b.cnt;
}
  8002e9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002f7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002fa:	50                   	push   %eax
  8002fb:	ff 75 08             	pushl  0x8(%ebp)
  8002fe:	e8 9d ff ff ff       	call   8002a0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800303:	c9                   	leave  
  800304:	c3                   	ret    

00800305 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 1c             	sub    $0x1c,%esp
  80030e:	89 c7                	mov    %eax,%edi
  800310:	89 d6                	mov    %edx,%esi
  800312:	8b 45 08             	mov    0x8(%ebp),%eax
  800315:	8b 55 0c             	mov    0xc(%ebp),%edx
  800318:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80031b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80031e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800321:	bb 00 00 00 00       	mov    $0x0,%ebx
  800326:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800329:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80032c:	39 d3                	cmp    %edx,%ebx
  80032e:	72 05                	jb     800335 <printnum+0x30>
  800330:	39 45 10             	cmp    %eax,0x10(%ebp)
  800333:	77 45                	ja     80037a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	ff 75 18             	pushl  0x18(%ebp)
  80033b:	8b 45 14             	mov    0x14(%ebp),%eax
  80033e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800341:	53                   	push   %ebx
  800342:	ff 75 10             	pushl  0x10(%ebp)
  800345:	83 ec 08             	sub    $0x8,%esp
  800348:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034b:	ff 75 e0             	pushl  -0x20(%ebp)
  80034e:	ff 75 dc             	pushl  -0x24(%ebp)
  800351:	ff 75 d8             	pushl  -0x28(%ebp)
  800354:	e8 b7 1d 00 00       	call   802110 <__udivdi3>
  800359:	83 c4 18             	add    $0x18,%esp
  80035c:	52                   	push   %edx
  80035d:	50                   	push   %eax
  80035e:	89 f2                	mov    %esi,%edx
  800360:	89 f8                	mov    %edi,%eax
  800362:	e8 9e ff ff ff       	call   800305 <printnum>
  800367:	83 c4 20             	add    $0x20,%esp
  80036a:	eb 18                	jmp    800384 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80036c:	83 ec 08             	sub    $0x8,%esp
  80036f:	56                   	push   %esi
  800370:	ff 75 18             	pushl  0x18(%ebp)
  800373:	ff d7                	call   *%edi
  800375:	83 c4 10             	add    $0x10,%esp
  800378:	eb 03                	jmp    80037d <printnum+0x78>
  80037a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f e8                	jg     80036c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	83 ec 08             	sub    $0x8,%esp
  800387:	56                   	push   %esi
  800388:	83 ec 04             	sub    $0x4,%esp
  80038b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80038e:	ff 75 e0             	pushl  -0x20(%ebp)
  800391:	ff 75 dc             	pushl  -0x24(%ebp)
  800394:	ff 75 d8             	pushl  -0x28(%ebp)
  800397:	e8 a4 1e 00 00       	call   802240 <__umoddi3>
  80039c:	83 c4 14             	add    $0x14,%esp
  80039f:	0f be 80 0b 25 80 00 	movsbl 0x80250b(%eax),%eax
  8003a6:	50                   	push   %eax
  8003a7:	ff d7                	call   *%edi
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003af:	5b                   	pop    %ebx
  8003b0:	5e                   	pop    %esi
  8003b1:	5f                   	pop    %edi
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
  8003b7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003ba:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003be:	8b 10                	mov    (%eax),%edx
  8003c0:	3b 50 04             	cmp    0x4(%eax),%edx
  8003c3:	73 0a                	jae    8003cf <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c8:	89 08                	mov    %ecx,(%eax)
  8003ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8003cd:	88 02                	mov    %al,(%edx)
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 10             	pushl  0x10(%ebp)
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 05 00 00 00       	call   8003ee <vprintfmt>
	va_end(ap);
}
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 2c             	sub    $0x2c,%esp
  8003f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003fd:	8b 7d 10             	mov    0x10(%ebp),%edi
  800400:	eb 12                	jmp    800414 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800402:	85 c0                	test   %eax,%eax
  800404:	0f 84 42 04 00 00    	je     80084c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	53                   	push   %ebx
  80040e:	50                   	push   %eax
  80040f:	ff d6                	call   *%esi
  800411:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800414:	83 c7 01             	add    $0x1,%edi
  800417:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80041b:	83 f8 25             	cmp    $0x25,%eax
  80041e:	75 e2                	jne    800402 <vprintfmt+0x14>
  800420:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800424:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80042b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800432:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800439:	b9 00 00 00 00       	mov    $0x0,%ecx
  80043e:	eb 07                	jmp    800447 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800443:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800447:	8d 47 01             	lea    0x1(%edi),%eax
  80044a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044d:	0f b6 07             	movzbl (%edi),%eax
  800450:	0f b6 d0             	movzbl %al,%edx
  800453:	83 e8 23             	sub    $0x23,%eax
  800456:	3c 55                	cmp    $0x55,%al
  800458:	0f 87 d3 03 00 00    	ja     800831 <vprintfmt+0x443>
  80045e:	0f b6 c0             	movzbl %al,%eax
  800461:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  800468:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80046b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80046f:	eb d6                	jmp    800447 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80047c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80047f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800483:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800486:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800489:	83 f9 09             	cmp    $0x9,%ecx
  80048c:	77 3f                	ja     8004cd <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800491:	eb e9                	jmp    80047c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800493:	8b 45 14             	mov    0x14(%ebp),%eax
  800496:	8b 00                	mov    (%eax),%eax
  800498:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80049b:	8b 45 14             	mov    0x14(%ebp),%eax
  80049e:	8d 40 04             	lea    0x4(%eax),%eax
  8004a1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004a7:	eb 2a                	jmp    8004d3 <vprintfmt+0xe5>
  8004a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ac:	85 c0                	test   %eax,%eax
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8004b3:	0f 49 d0             	cmovns %eax,%edx
  8004b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004bc:	eb 89                	jmp    800447 <vprintfmt+0x59>
  8004be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004c1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004c8:	e9 7a ff ff ff       	jmp    800447 <vprintfmt+0x59>
  8004cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004d0:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004d3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004d7:	0f 89 6a ff ff ff    	jns    800447 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004dd:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004e3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004ea:	e9 58 ff ff ff       	jmp    800447 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004ef:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004f5:	e9 4d ff ff ff       	jmp    800447 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fd:	8d 78 04             	lea    0x4(%eax),%edi
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	53                   	push   %ebx
  800504:	ff 30                	pushl  (%eax)
  800506:	ff d6                	call   *%esi
			break;
  800508:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80050b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80050e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800511:	e9 fe fe ff ff       	jmp    800414 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 78 04             	lea    0x4(%eax),%edi
  80051c:	8b 00                	mov    (%eax),%eax
  80051e:	99                   	cltd   
  80051f:	31 d0                	xor    %edx,%eax
  800521:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800523:	83 f8 0f             	cmp    $0xf,%eax
  800526:	7f 0b                	jg     800533 <vprintfmt+0x145>
  800528:	8b 14 85 a0 27 80 00 	mov    0x8027a0(,%eax,4),%edx
  80052f:	85 d2                	test   %edx,%edx
  800531:	75 1b                	jne    80054e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800533:	50                   	push   %eax
  800534:	68 23 25 80 00       	push   $0x802523
  800539:	53                   	push   %ebx
  80053a:	56                   	push   %esi
  80053b:	e8 91 fe ff ff       	call   8003d1 <printfmt>
  800540:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800543:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800546:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800549:	e9 c6 fe ff ff       	jmp    800414 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80054e:	52                   	push   %edx
  80054f:	68 a5 29 80 00       	push   $0x8029a5
  800554:	53                   	push   %ebx
  800555:	56                   	push   %esi
  800556:	e8 76 fe ff ff       	call   8003d1 <printfmt>
  80055b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80055e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800561:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800564:	e9 ab fe ff ff       	jmp    800414 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	83 c0 04             	add    $0x4,%eax
  80056f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800577:	85 ff                	test   %edi,%edi
  800579:	b8 1c 25 80 00       	mov    $0x80251c,%eax
  80057e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800581:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800585:	0f 8e 94 00 00 00    	jle    80061f <vprintfmt+0x231>
  80058b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80058f:	0f 84 98 00 00 00    	je     80062d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	ff 75 d0             	pushl  -0x30(%ebp)
  80059b:	57                   	push   %edi
  80059c:	e8 33 03 00 00       	call   8008d4 <strnlen>
  8005a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005a4:	29 c1                	sub    %eax,%ecx
  8005a6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005a9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ac:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b8:	eb 0f                	jmp    8005c9 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	53                   	push   %ebx
  8005be:	ff 75 e0             	pushl  -0x20(%ebp)
  8005c1:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c3:	83 ef 01             	sub    $0x1,%edi
  8005c6:	83 c4 10             	add    $0x10,%esp
  8005c9:	85 ff                	test   %edi,%edi
  8005cb:	7f ed                	jg     8005ba <vprintfmt+0x1cc>
  8005cd:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d0:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005d3:	85 c9                	test   %ecx,%ecx
  8005d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8005da:	0f 49 c1             	cmovns %ecx,%eax
  8005dd:	29 c1                	sub    %eax,%ecx
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	89 cb                	mov    %ecx,%ebx
  8005ea:	eb 4d                	jmp    800639 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f0:	74 1b                	je     80060d <vprintfmt+0x21f>
  8005f2:	0f be c0             	movsbl %al,%eax
  8005f5:	83 e8 20             	sub    $0x20,%eax
  8005f8:	83 f8 5e             	cmp    $0x5e,%eax
  8005fb:	76 10                	jbe    80060d <vprintfmt+0x21f>
					putch('?', putdat);
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	ff 75 0c             	pushl  0xc(%ebp)
  800603:	6a 3f                	push   $0x3f
  800605:	ff 55 08             	call   *0x8(%ebp)
  800608:	83 c4 10             	add    $0x10,%esp
  80060b:	eb 0d                	jmp    80061a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	ff 75 0c             	pushl  0xc(%ebp)
  800613:	52                   	push   %edx
  800614:	ff 55 08             	call   *0x8(%ebp)
  800617:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061a:	83 eb 01             	sub    $0x1,%ebx
  80061d:	eb 1a                	jmp    800639 <vprintfmt+0x24b>
  80061f:	89 75 08             	mov    %esi,0x8(%ebp)
  800622:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800625:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800628:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80062b:	eb 0c                	jmp    800639 <vprintfmt+0x24b>
  80062d:	89 75 08             	mov    %esi,0x8(%ebp)
  800630:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800633:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800636:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800639:	83 c7 01             	add    $0x1,%edi
  80063c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800640:	0f be d0             	movsbl %al,%edx
  800643:	85 d2                	test   %edx,%edx
  800645:	74 23                	je     80066a <vprintfmt+0x27c>
  800647:	85 f6                	test   %esi,%esi
  800649:	78 a1                	js     8005ec <vprintfmt+0x1fe>
  80064b:	83 ee 01             	sub    $0x1,%esi
  80064e:	79 9c                	jns    8005ec <vprintfmt+0x1fe>
  800650:	89 df                	mov    %ebx,%edi
  800652:	8b 75 08             	mov    0x8(%ebp),%esi
  800655:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800658:	eb 18                	jmp    800672 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80065a:	83 ec 08             	sub    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 20                	push   $0x20
  800660:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800662:	83 ef 01             	sub    $0x1,%edi
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	eb 08                	jmp    800672 <vprintfmt+0x284>
  80066a:	89 df                	mov    %ebx,%edi
  80066c:	8b 75 08             	mov    0x8(%ebp),%esi
  80066f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800672:	85 ff                	test   %edi,%edi
  800674:	7f e4                	jg     80065a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800676:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800679:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067f:	e9 90 fd ff ff       	jmp    800414 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800684:	83 f9 01             	cmp    $0x1,%ecx
  800687:	7e 19                	jle    8006a2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8b 50 04             	mov    0x4(%eax),%edx
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800694:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800697:	8b 45 14             	mov    0x14(%ebp),%eax
  80069a:	8d 40 08             	lea    0x8(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a0:	eb 38                	jmp    8006da <vprintfmt+0x2ec>
	else if (lflag)
  8006a2:	85 c9                	test   %ecx,%ecx
  8006a4:	74 1b                	je     8006c1 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006ae:	89 c1                	mov    %eax,%ecx
  8006b0:	c1 f9 1f             	sar    $0x1f,%ecx
  8006b3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 40 04             	lea    0x4(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bf:	eb 19                	jmp    8006da <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 c1                	mov    %eax,%ecx
  8006cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8d 40 04             	lea    0x4(%eax),%eax
  8006d7:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006e5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006e9:	0f 89 0e 01 00 00    	jns    8007fd <vprintfmt+0x40f>
				putch('-', putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	53                   	push   %ebx
  8006f3:	6a 2d                	push   $0x2d
  8006f5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006fd:	f7 da                	neg    %edx
  8006ff:	83 d1 00             	adc    $0x0,%ecx
  800702:	f7 d9                	neg    %ecx
  800704:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800707:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070c:	e9 ec 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800711:	83 f9 01             	cmp    $0x1,%ecx
  800714:	7e 18                	jle    80072e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800716:	8b 45 14             	mov    0x14(%ebp),%eax
  800719:	8b 10                	mov    (%eax),%edx
  80071b:	8b 48 04             	mov    0x4(%eax),%ecx
  80071e:	8d 40 08             	lea    0x8(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800724:	b8 0a 00 00 00       	mov    $0xa,%eax
  800729:	e9 cf 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80072e:	85 c9                	test   %ecx,%ecx
  800730:	74 1a                	je     80074c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800742:	b8 0a 00 00 00       	mov    $0xa,%eax
  800747:	e9 b1 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80074c:	8b 45 14             	mov    0x14(%ebp),%eax
  80074f:	8b 10                	mov    (%eax),%edx
  800751:	b9 00 00 00 00       	mov    $0x0,%ecx
  800756:	8d 40 04             	lea    0x4(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80075c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800761:	e9 97 00 00 00       	jmp    8007fd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	53                   	push   %ebx
  80076a:	6a 58                	push   $0x58
  80076c:	ff d6                	call   *%esi
			putch('X', putdat);
  80076e:	83 c4 08             	add    $0x8,%esp
  800771:	53                   	push   %ebx
  800772:	6a 58                	push   $0x58
  800774:	ff d6                	call   *%esi
			putch('X', putdat);
  800776:	83 c4 08             	add    $0x8,%esp
  800779:	53                   	push   %ebx
  80077a:	6a 58                	push   $0x58
  80077c:	ff d6                	call   *%esi
			break;
  80077e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800781:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800784:	e9 8b fc ff ff       	jmp    800414 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	53                   	push   %ebx
  80078d:	6a 30                	push   $0x30
  80078f:	ff d6                	call   *%esi
			putch('x', putdat);
  800791:	83 c4 08             	add    $0x8,%esp
  800794:	53                   	push   %ebx
  800795:	6a 78                	push   $0x78
  800797:	ff d6                	call   *%esi
			num = (unsigned long long)
  800799:	8b 45 14             	mov    0x14(%ebp),%eax
  80079c:	8b 10                	mov    (%eax),%edx
  80079e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007a3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007a6:	8d 40 04             	lea    0x4(%eax),%eax
  8007a9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ac:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007b1:	eb 4a                	jmp    8007fd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b3:	83 f9 01             	cmp    $0x1,%ecx
  8007b6:	7e 15                	jle    8007cd <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bb:	8b 10                	mov    (%eax),%edx
  8007bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c0:	8d 40 08             	lea    0x8(%eax),%eax
  8007c3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8007cb:	eb 30                	jmp    8007fd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007cd:	85 c9                	test   %ecx,%ecx
  8007cf:	74 17                	je     8007e8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8b 10                	mov    (%eax),%edx
  8007d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007db:	8d 40 04             	lea    0x4(%eax),%eax
  8007de:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007e1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e6:	eb 15                	jmp    8007fd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f2:	8d 40 04             	lea    0x4(%eax),%eax
  8007f5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007f8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007fd:	83 ec 0c             	sub    $0xc,%esp
  800800:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800804:	57                   	push   %edi
  800805:	ff 75 e0             	pushl  -0x20(%ebp)
  800808:	50                   	push   %eax
  800809:	51                   	push   %ecx
  80080a:	52                   	push   %edx
  80080b:	89 da                	mov    %ebx,%edx
  80080d:	89 f0                	mov    %esi,%eax
  80080f:	e8 f1 fa ff ff       	call   800305 <printnum>
			break;
  800814:	83 c4 20             	add    $0x20,%esp
  800817:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80081a:	e9 f5 fb ff ff       	jmp    800414 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	53                   	push   %ebx
  800823:	52                   	push   %edx
  800824:	ff d6                	call   *%esi
			break;
  800826:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800829:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80082c:	e9 e3 fb ff ff       	jmp    800414 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800831:	83 ec 08             	sub    $0x8,%esp
  800834:	53                   	push   %ebx
  800835:	6a 25                	push   $0x25
  800837:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	eb 03                	jmp    800841 <vprintfmt+0x453>
  80083e:	83 ef 01             	sub    $0x1,%edi
  800841:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800845:	75 f7                	jne    80083e <vprintfmt+0x450>
  800847:	e9 c8 fb ff ff       	jmp    800414 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80084c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5f                   	pop    %edi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    

00800854 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800854:	55                   	push   %ebp
  800855:	89 e5                	mov    %esp,%ebp
  800857:	83 ec 18             	sub    $0x18,%esp
  80085a:	8b 45 08             	mov    0x8(%ebp),%eax
  80085d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800860:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800863:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800867:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80086a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800871:	85 c0                	test   %eax,%eax
  800873:	74 26                	je     80089b <vsnprintf+0x47>
  800875:	85 d2                	test   %edx,%edx
  800877:	7e 22                	jle    80089b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800879:	ff 75 14             	pushl  0x14(%ebp)
  80087c:	ff 75 10             	pushl  0x10(%ebp)
  80087f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800882:	50                   	push   %eax
  800883:	68 b4 03 80 00       	push   $0x8003b4
  800888:	e8 61 fb ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800890:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800893:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	eb 05                	jmp    8008a0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80089b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008a0:	c9                   	leave  
  8008a1:	c3                   	ret    

008008a2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008a2:	55                   	push   %ebp
  8008a3:	89 e5                	mov    %esp,%ebp
  8008a5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008a8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008ab:	50                   	push   %eax
  8008ac:	ff 75 10             	pushl  0x10(%ebp)
  8008af:	ff 75 0c             	pushl  0xc(%ebp)
  8008b2:	ff 75 08             	pushl  0x8(%ebp)
  8008b5:	e8 9a ff ff ff       	call   800854 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    

008008bc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	eb 03                	jmp    8008cc <strlen+0x10>
		n++;
  8008c9:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008cc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d0:	75 f7                	jne    8008c9 <strlen+0xd>
		n++;
	return n;
}
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008da:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	eb 03                	jmp    8008e7 <strnlen+0x13>
		n++;
  8008e4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e7:	39 c2                	cmp    %eax,%edx
  8008e9:	74 08                	je     8008f3 <strnlen+0x1f>
  8008eb:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008ef:	75 f3                	jne    8008e4 <strnlen+0x10>
  8008f1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008f3:	5d                   	pop    %ebp
  8008f4:	c3                   	ret    

008008f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	53                   	push   %ebx
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ff:	89 c2                	mov    %eax,%edx
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	83 c1 01             	add    $0x1,%ecx
  800907:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80090b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80090e:	84 db                	test   %bl,%bl
  800910:	75 ef                	jne    800901 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800912:	5b                   	pop    %ebx
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	53                   	push   %ebx
  800919:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80091c:	53                   	push   %ebx
  80091d:	e8 9a ff ff ff       	call   8008bc <strlen>
  800922:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800925:	ff 75 0c             	pushl  0xc(%ebp)
  800928:	01 d8                	add    %ebx,%eax
  80092a:	50                   	push   %eax
  80092b:	e8 c5 ff ff ff       	call   8008f5 <strcpy>
	return dst;
}
  800930:	89 d8                	mov    %ebx,%eax
  800932:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800935:	c9                   	leave  
  800936:	c3                   	ret    

00800937 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	8b 75 08             	mov    0x8(%ebp),%esi
  80093f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800942:	89 f3                	mov    %esi,%ebx
  800944:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800947:	89 f2                	mov    %esi,%edx
  800949:	eb 0f                	jmp    80095a <strncpy+0x23>
		*dst++ = *src;
  80094b:	83 c2 01             	add    $0x1,%edx
  80094e:	0f b6 01             	movzbl (%ecx),%eax
  800951:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800954:	80 39 01             	cmpb   $0x1,(%ecx)
  800957:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80095a:	39 da                	cmp    %ebx,%edx
  80095c:	75 ed                	jne    80094b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80095e:	89 f0                	mov    %esi,%eax
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 75 08             	mov    0x8(%ebp),%esi
  80096c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096f:	8b 55 10             	mov    0x10(%ebp),%edx
  800972:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800974:	85 d2                	test   %edx,%edx
  800976:	74 21                	je     800999 <strlcpy+0x35>
  800978:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80097c:	89 f2                	mov    %esi,%edx
  80097e:	eb 09                	jmp    800989 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800980:	83 c2 01             	add    $0x1,%edx
  800983:	83 c1 01             	add    $0x1,%ecx
  800986:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800989:	39 c2                	cmp    %eax,%edx
  80098b:	74 09                	je     800996 <strlcpy+0x32>
  80098d:	0f b6 19             	movzbl (%ecx),%ebx
  800990:	84 db                	test   %bl,%bl
  800992:	75 ec                	jne    800980 <strlcpy+0x1c>
  800994:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800996:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800999:	29 f0                	sub    %esi,%eax
}
  80099b:	5b                   	pop    %ebx
  80099c:	5e                   	pop    %esi
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a8:	eb 06                	jmp    8009b0 <strcmp+0x11>
		p++, q++;
  8009aa:	83 c1 01             	add    $0x1,%ecx
  8009ad:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009b0:	0f b6 01             	movzbl (%ecx),%eax
  8009b3:	84 c0                	test   %al,%al
  8009b5:	74 04                	je     8009bb <strcmp+0x1c>
  8009b7:	3a 02                	cmp    (%edx),%al
  8009b9:	74 ef                	je     8009aa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009bb:	0f b6 c0             	movzbl %al,%eax
  8009be:	0f b6 12             	movzbl (%edx),%edx
  8009c1:	29 d0                	sub    %edx,%eax
}
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	53                   	push   %ebx
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cf:	89 c3                	mov    %eax,%ebx
  8009d1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009d4:	eb 06                	jmp    8009dc <strncmp+0x17>
		n--, p++, q++;
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009dc:	39 d8                	cmp    %ebx,%eax
  8009de:	74 15                	je     8009f5 <strncmp+0x30>
  8009e0:	0f b6 08             	movzbl (%eax),%ecx
  8009e3:	84 c9                	test   %cl,%cl
  8009e5:	74 04                	je     8009eb <strncmp+0x26>
  8009e7:	3a 0a                	cmp    (%edx),%cl
  8009e9:	74 eb                	je     8009d6 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009eb:	0f b6 00             	movzbl (%eax),%eax
  8009ee:	0f b6 12             	movzbl (%edx),%edx
  8009f1:	29 d0                	sub    %edx,%eax
  8009f3:	eb 05                	jmp    8009fa <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a07:	eb 07                	jmp    800a10 <strchr+0x13>
		if (*s == c)
  800a09:	38 ca                	cmp    %cl,%dl
  800a0b:	74 0f                	je     800a1c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0d:	83 c0 01             	add    $0x1,%eax
  800a10:	0f b6 10             	movzbl (%eax),%edx
  800a13:	84 d2                	test   %dl,%dl
  800a15:	75 f2                	jne    800a09 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	8b 45 08             	mov    0x8(%ebp),%eax
  800a24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a28:	eb 03                	jmp    800a2d <strfind+0xf>
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a30:	38 ca                	cmp    %cl,%dl
  800a32:	74 04                	je     800a38 <strfind+0x1a>
  800a34:	84 d2                	test   %dl,%dl
  800a36:	75 f2                	jne    800a2a <strfind+0xc>
			break;
	return (char *) s;
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	57                   	push   %edi
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a46:	85 c9                	test   %ecx,%ecx
  800a48:	74 36                	je     800a80 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a50:	75 28                	jne    800a7a <memset+0x40>
  800a52:	f6 c1 03             	test   $0x3,%cl
  800a55:	75 23                	jne    800a7a <memset+0x40>
		c &= 0xFF;
  800a57:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a5b:	89 d3                	mov    %edx,%ebx
  800a5d:	c1 e3 08             	shl    $0x8,%ebx
  800a60:	89 d6                	mov    %edx,%esi
  800a62:	c1 e6 18             	shl    $0x18,%esi
  800a65:	89 d0                	mov    %edx,%eax
  800a67:	c1 e0 10             	shl    $0x10,%eax
  800a6a:	09 f0                	or     %esi,%eax
  800a6c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a6e:	89 d8                	mov    %ebx,%eax
  800a70:	09 d0                	or     %edx,%eax
  800a72:	c1 e9 02             	shr    $0x2,%ecx
  800a75:	fc                   	cld    
  800a76:	f3 ab                	rep stos %eax,%es:(%edi)
  800a78:	eb 06                	jmp    800a80 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	fc                   	cld    
  800a7e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a80:	89 f8                	mov    %edi,%eax
  800a82:	5b                   	pop    %ebx
  800a83:	5e                   	pop    %esi
  800a84:	5f                   	pop    %edi
  800a85:	5d                   	pop    %ebp
  800a86:	c3                   	ret    

00800a87 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	57                   	push   %edi
  800a8b:	56                   	push   %esi
  800a8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a92:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a95:	39 c6                	cmp    %eax,%esi
  800a97:	73 35                	jae    800ace <memmove+0x47>
  800a99:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a9c:	39 d0                	cmp    %edx,%eax
  800a9e:	73 2e                	jae    800ace <memmove+0x47>
		s += n;
		d += n;
  800aa0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa3:	89 d6                	mov    %edx,%esi
  800aa5:	09 fe                	or     %edi,%esi
  800aa7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aad:	75 13                	jne    800ac2 <memmove+0x3b>
  800aaf:	f6 c1 03             	test   $0x3,%cl
  800ab2:	75 0e                	jne    800ac2 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ab4:	83 ef 04             	sub    $0x4,%edi
  800ab7:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aba:	c1 e9 02             	shr    $0x2,%ecx
  800abd:	fd                   	std    
  800abe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac0:	eb 09                	jmp    800acb <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ac2:	83 ef 01             	sub    $0x1,%edi
  800ac5:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ac8:	fd                   	std    
  800ac9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800acb:	fc                   	cld    
  800acc:	eb 1d                	jmp    800aeb <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ace:	89 f2                	mov    %esi,%edx
  800ad0:	09 c2                	or     %eax,%edx
  800ad2:	f6 c2 03             	test   $0x3,%dl
  800ad5:	75 0f                	jne    800ae6 <memmove+0x5f>
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 0a                	jne    800ae6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800adc:	c1 e9 02             	shr    $0x2,%ecx
  800adf:	89 c7                	mov    %eax,%edi
  800ae1:	fc                   	cld    
  800ae2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae4:	eb 05                	jmp    800aeb <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ae6:	89 c7                	mov    %eax,%edi
  800ae8:	fc                   	cld    
  800ae9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aeb:	5e                   	pop    %esi
  800aec:	5f                   	pop    %edi
  800aed:	5d                   	pop    %ebp
  800aee:	c3                   	ret    

00800aef <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aef:	55                   	push   %ebp
  800af0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800af2:	ff 75 10             	pushl  0x10(%ebp)
  800af5:	ff 75 0c             	pushl  0xc(%ebp)
  800af8:	ff 75 08             	pushl  0x8(%ebp)
  800afb:	e8 87 ff ff ff       	call   800a87 <memmove>
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	8b 45 08             	mov    0x8(%ebp),%eax
  800b0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b0d:	89 c6                	mov    %eax,%esi
  800b0f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b12:	eb 1a                	jmp    800b2e <memcmp+0x2c>
		if (*s1 != *s2)
  800b14:	0f b6 08             	movzbl (%eax),%ecx
  800b17:	0f b6 1a             	movzbl (%edx),%ebx
  800b1a:	38 d9                	cmp    %bl,%cl
  800b1c:	74 0a                	je     800b28 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b1e:	0f b6 c1             	movzbl %cl,%eax
  800b21:	0f b6 db             	movzbl %bl,%ebx
  800b24:	29 d8                	sub    %ebx,%eax
  800b26:	eb 0f                	jmp    800b37 <memcmp+0x35>
		s1++, s2++;
  800b28:	83 c0 01             	add    $0x1,%eax
  800b2b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2e:	39 f0                	cmp    %esi,%eax
  800b30:	75 e2                	jne    800b14 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b32:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	53                   	push   %ebx
  800b3f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b42:	89 c1                	mov    %eax,%ecx
  800b44:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b47:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b4b:	eb 0a                	jmp    800b57 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b4d:	0f b6 10             	movzbl (%eax),%edx
  800b50:	39 da                	cmp    %ebx,%edx
  800b52:	74 07                	je     800b5b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b54:	83 c0 01             	add    $0x1,%eax
  800b57:	39 c8                	cmp    %ecx,%eax
  800b59:	72 f2                	jb     800b4d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	57                   	push   %edi
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6a:	eb 03                	jmp    800b6f <strtol+0x11>
		s++;
  800b6c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6f:	0f b6 01             	movzbl (%ecx),%eax
  800b72:	3c 20                	cmp    $0x20,%al
  800b74:	74 f6                	je     800b6c <strtol+0xe>
  800b76:	3c 09                	cmp    $0x9,%al
  800b78:	74 f2                	je     800b6c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b7a:	3c 2b                	cmp    $0x2b,%al
  800b7c:	75 0a                	jne    800b88 <strtol+0x2a>
		s++;
  800b7e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b81:	bf 00 00 00 00       	mov    $0x0,%edi
  800b86:	eb 11                	jmp    800b99 <strtol+0x3b>
  800b88:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b8d:	3c 2d                	cmp    $0x2d,%al
  800b8f:	75 08                	jne    800b99 <strtol+0x3b>
		s++, neg = 1;
  800b91:	83 c1 01             	add    $0x1,%ecx
  800b94:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9f:	75 15                	jne    800bb6 <strtol+0x58>
  800ba1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ba4:	75 10                	jne    800bb6 <strtol+0x58>
  800ba6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800baa:	75 7c                	jne    800c28 <strtol+0xca>
		s += 2, base = 16;
  800bac:	83 c1 02             	add    $0x2,%ecx
  800baf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb4:	eb 16                	jmp    800bcc <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bb6:	85 db                	test   %ebx,%ebx
  800bb8:	75 12                	jne    800bcc <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bba:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbf:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc2:	75 08                	jne    800bcc <strtol+0x6e>
		s++, base = 8;
  800bc4:	83 c1 01             	add    $0x1,%ecx
  800bc7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd4:	0f b6 11             	movzbl (%ecx),%edx
  800bd7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bda:	89 f3                	mov    %esi,%ebx
  800bdc:	80 fb 09             	cmp    $0x9,%bl
  800bdf:	77 08                	ja     800be9 <strtol+0x8b>
			dig = *s - '0';
  800be1:	0f be d2             	movsbl %dl,%edx
  800be4:	83 ea 30             	sub    $0x30,%edx
  800be7:	eb 22                	jmp    800c0b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800be9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bec:	89 f3                	mov    %esi,%ebx
  800bee:	80 fb 19             	cmp    $0x19,%bl
  800bf1:	77 08                	ja     800bfb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bf3:	0f be d2             	movsbl %dl,%edx
  800bf6:	83 ea 57             	sub    $0x57,%edx
  800bf9:	eb 10                	jmp    800c0b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bfb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bfe:	89 f3                	mov    %esi,%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 16                	ja     800c1b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c05:	0f be d2             	movsbl %dl,%edx
  800c08:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c0b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c0e:	7d 0b                	jge    800c1b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c10:	83 c1 01             	add    $0x1,%ecx
  800c13:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c17:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c19:	eb b9                	jmp    800bd4 <strtol+0x76>

	if (endptr)
  800c1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c1f:	74 0d                	je     800c2e <strtol+0xd0>
		*endptr = (char *) s;
  800c21:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c24:	89 0e                	mov    %ecx,(%esi)
  800c26:	eb 06                	jmp    800c2e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c28:	85 db                	test   %ebx,%ebx
  800c2a:	74 98                	je     800bc4 <strtol+0x66>
  800c2c:	eb 9e                	jmp    800bcc <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c2e:	89 c2                	mov    %eax,%edx
  800c30:	f7 da                	neg    %edx
  800c32:	85 ff                	test   %edi,%edi
  800c34:	0f 45 c2             	cmovne %edx,%eax
}
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b8 00 00 00 00       	mov    $0x0,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 c3                	mov    %eax,%ebx
  800c4f:	89 c7                	mov    %eax,%edi
  800c51:	89 c6                	mov    %eax,%esi
  800c53:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c60:	ba 00 00 00 00       	mov    $0x0,%edx
  800c65:	b8 01 00 00 00       	mov    $0x1,%eax
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	89 d3                	mov    %edx,%ebx
  800c6e:	89 d7                	mov    %edx,%edi
  800c70:	89 d6                	mov    %edx,%esi
  800c72:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c74:	5b                   	pop    %ebx
  800c75:	5e                   	pop    %esi
  800c76:	5f                   	pop    %edi
  800c77:	5d                   	pop    %ebp
  800c78:	c3                   	ret    

00800c79 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c79:	55                   	push   %ebp
  800c7a:	89 e5                	mov    %esp,%ebp
  800c7c:	57                   	push   %edi
  800c7d:	56                   	push   %esi
  800c7e:	53                   	push   %ebx
  800c7f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c82:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c87:	b8 03 00 00 00       	mov    $0x3,%eax
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 cb                	mov    %ecx,%ebx
  800c91:	89 cf                	mov    %ecx,%edi
  800c93:	89 ce                	mov    %ecx,%esi
  800c95:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7e 17                	jle    800cb2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	6a 03                	push   $0x3
  800ca1:	68 ff 27 80 00       	push   $0x8027ff
  800ca6:	6a 23                	push   $0x23
  800ca8:	68 1c 28 80 00       	push   $0x80281c
  800cad:	e8 66 f5 ff ff       	call   800218 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    

00800cba <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc5:	b8 02 00 00 00       	mov    $0x2,%eax
  800cca:	89 d1                	mov    %edx,%ecx
  800ccc:	89 d3                	mov    %edx,%ebx
  800cce:	89 d7                	mov    %edx,%edi
  800cd0:	89 d6                	mov    %edx,%esi
  800cd2:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cd4:	5b                   	pop    %ebx
  800cd5:	5e                   	pop    %esi
  800cd6:	5f                   	pop    %edi
  800cd7:	5d                   	pop    %ebp
  800cd8:	c3                   	ret    

00800cd9 <sys_yield>:

void
sys_yield(void)
{
  800cd9:	55                   	push   %ebp
  800cda:	89 e5                	mov    %esp,%ebp
  800cdc:	57                   	push   %edi
  800cdd:	56                   	push   %esi
  800cde:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce9:	89 d1                	mov    %edx,%ecx
  800ceb:	89 d3                	mov    %edx,%ebx
  800ced:	89 d7                	mov    %edx,%edi
  800cef:	89 d6                	mov    %edx,%esi
  800cf1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	be 00 00 00 00       	mov    $0x0,%esi
  800d06:	b8 04 00 00 00       	mov    $0x4,%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d11:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d14:	89 f7                	mov    %esi,%edi
  800d16:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7e 17                	jle    800d33 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1c:	83 ec 0c             	sub    $0xc,%esp
  800d1f:	50                   	push   %eax
  800d20:	6a 04                	push   $0x4
  800d22:	68 ff 27 80 00       	push   $0x8027ff
  800d27:	6a 23                	push   $0x23
  800d29:	68 1c 28 80 00       	push   $0x80281c
  800d2e:	e8 e5 f4 ff ff       	call   800218 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d36:	5b                   	pop    %ebx
  800d37:	5e                   	pop    %esi
  800d38:	5f                   	pop    %edi
  800d39:	5d                   	pop    %ebp
  800d3a:	c3                   	ret    

00800d3b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
  800d41:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d44:	b8 05 00 00 00       	mov    $0x5,%eax
  800d49:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d52:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d55:	8b 75 18             	mov    0x18(%ebp),%esi
  800d58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	7e 17                	jle    800d75 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5e:	83 ec 0c             	sub    $0xc,%esp
  800d61:	50                   	push   %eax
  800d62:	6a 05                	push   $0x5
  800d64:	68 ff 27 80 00       	push   $0x8027ff
  800d69:	6a 23                	push   $0x23
  800d6b:	68 1c 28 80 00       	push   $0x80281c
  800d70:	e8 a3 f4 ff ff       	call   800218 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d78:	5b                   	pop    %ebx
  800d79:	5e                   	pop    %esi
  800d7a:	5f                   	pop    %edi
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	57                   	push   %edi
  800d81:	56                   	push   %esi
  800d82:	53                   	push   %ebx
  800d83:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d86:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d93:	8b 55 08             	mov    0x8(%ebp),%edx
  800d96:	89 df                	mov    %ebx,%edi
  800d98:	89 de                	mov    %ebx,%esi
  800d9a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7e 17                	jle    800db7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da0:	83 ec 0c             	sub    $0xc,%esp
  800da3:	50                   	push   %eax
  800da4:	6a 06                	push   $0x6
  800da6:	68 ff 27 80 00       	push   $0x8027ff
  800dab:	6a 23                	push   $0x23
  800dad:	68 1c 28 80 00       	push   $0x80281c
  800db2:	e8 61 f4 ff ff       	call   800218 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcd:	b8 08 00 00 00       	mov    $0x8,%eax
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd8:	89 df                	mov    %ebx,%edi
  800dda:	89 de                	mov    %ebx,%esi
  800ddc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dde:	85 c0                	test   %eax,%eax
  800de0:	7e 17                	jle    800df9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	50                   	push   %eax
  800de6:	6a 08                	push   $0x8
  800de8:	68 ff 27 80 00       	push   $0x8027ff
  800ded:	6a 23                	push   $0x23
  800def:	68 1c 28 80 00       	push   $0x80281c
  800df4:	e8 1f f4 ff ff       	call   800218 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfc:	5b                   	pop    %ebx
  800dfd:	5e                   	pop    %esi
  800dfe:	5f                   	pop    %edi
  800dff:	5d                   	pop    %ebp
  800e00:	c3                   	ret    

00800e01 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	57                   	push   %edi
  800e05:	56                   	push   %esi
  800e06:	53                   	push   %ebx
  800e07:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0f:	b8 09 00 00 00       	mov    $0x9,%eax
  800e14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e17:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1a:	89 df                	mov    %ebx,%edi
  800e1c:	89 de                	mov    %ebx,%esi
  800e1e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e20:	85 c0                	test   %eax,%eax
  800e22:	7e 17                	jle    800e3b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	50                   	push   %eax
  800e28:	6a 09                	push   $0x9
  800e2a:	68 ff 27 80 00       	push   $0x8027ff
  800e2f:	6a 23                	push   $0x23
  800e31:	68 1c 28 80 00       	push   $0x80281c
  800e36:	e8 dd f3 ff ff       	call   800218 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5f                   	pop    %edi
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e43:	55                   	push   %ebp
  800e44:	89 e5                	mov    %esp,%ebp
  800e46:	57                   	push   %edi
  800e47:	56                   	push   %esi
  800e48:	53                   	push   %ebx
  800e49:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e59:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5c:	89 df                	mov    %ebx,%edi
  800e5e:	89 de                	mov    %ebx,%esi
  800e60:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e62:	85 c0                	test   %eax,%eax
  800e64:	7e 17                	jle    800e7d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e66:	83 ec 0c             	sub    $0xc,%esp
  800e69:	50                   	push   %eax
  800e6a:	6a 0a                	push   $0xa
  800e6c:	68 ff 27 80 00       	push   $0x8027ff
  800e71:	6a 23                	push   $0x23
  800e73:	68 1c 28 80 00       	push   $0x80281c
  800e78:	e8 9b f3 ff ff       	call   800218 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e80:	5b                   	pop    %ebx
  800e81:	5e                   	pop    %esi
  800e82:	5f                   	pop    %edi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	57                   	push   %edi
  800e89:	56                   	push   %esi
  800e8a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8b:	be 00 00 00 00       	mov    $0x0,%esi
  800e90:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e98:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ea1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ea3:	5b                   	pop    %ebx
  800ea4:	5e                   	pop    %esi
  800ea5:	5f                   	pop    %edi
  800ea6:	5d                   	pop    %ebp
  800ea7:	c3                   	ret    

00800ea8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eb6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	89 cb                	mov    %ecx,%ebx
  800ec0:	89 cf                	mov    %ecx,%edi
  800ec2:	89 ce                	mov    %ecx,%esi
  800ec4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ec6:	85 c0                	test   %eax,%eax
  800ec8:	7e 17                	jle    800ee1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	50                   	push   %eax
  800ece:	6a 0d                	push   $0xd
  800ed0:	68 ff 27 80 00       	push   $0x8027ff
  800ed5:	6a 23                	push   $0x23
  800ed7:	68 1c 28 80 00       	push   $0x80281c
  800edc:	e8 37 f3 ff ff       	call   800218 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ee1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee4:	5b                   	pop    %ebx
  800ee5:	5e                   	pop    %esi
  800ee6:	5f                   	pop    %edi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800ef1:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800ef3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ef7:	74 11                	je     800f0a <pgfault+0x21>
  800ef9:	89 d8                	mov    %ebx,%eax
  800efb:	c1 e8 0c             	shr    $0xc,%eax
  800efe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f05:	f6 c4 08             	test   $0x8,%ah
  800f08:	75 14                	jne    800f1e <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800f0a:	83 ec 04             	sub    $0x4,%esp
  800f0d:	68 2c 28 80 00       	push   $0x80282c
  800f12:	6a 1f                	push   $0x1f
  800f14:	68 8f 28 80 00       	push   $0x80288f
  800f19:	e8 fa f2 ff ff       	call   800218 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800f1e:	e8 97 fd ff ff       	call   800cba <sys_getenvid>
  800f23:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	6a 07                	push   $0x7
  800f2a:	68 00 f0 7f 00       	push   $0x7ff000
  800f2f:	50                   	push   %eax
  800f30:	e8 c3 fd ff ff       	call   800cf8 <sys_page_alloc>
  800f35:	83 c4 10             	add    $0x10,%esp
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	79 12                	jns    800f4e <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800f3c:	50                   	push   %eax
  800f3d:	68 6c 28 80 00       	push   $0x80286c
  800f42:	6a 2c                	push   $0x2c
  800f44:	68 8f 28 80 00       	push   $0x80288f
  800f49:	e8 ca f2 ff ff       	call   800218 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800f4e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800f54:	83 ec 04             	sub    $0x4,%esp
  800f57:	68 00 10 00 00       	push   $0x1000
  800f5c:	53                   	push   %ebx
  800f5d:	68 00 f0 7f 00       	push   $0x7ff000
  800f62:	e8 20 fb ff ff       	call   800a87 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800f67:	83 c4 08             	add    $0x8,%esp
  800f6a:	53                   	push   %ebx
  800f6b:	56                   	push   %esi
  800f6c:	e8 0c fe ff ff       	call   800d7d <sys_page_unmap>
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	79 12                	jns    800f8a <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800f78:	50                   	push   %eax
  800f79:	68 9a 28 80 00       	push   $0x80289a
  800f7e:	6a 32                	push   $0x32
  800f80:	68 8f 28 80 00       	push   $0x80288f
  800f85:	e8 8e f2 ff ff       	call   800218 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f8a:	83 ec 0c             	sub    $0xc,%esp
  800f8d:	6a 07                	push   $0x7
  800f8f:	53                   	push   %ebx
  800f90:	56                   	push   %esi
  800f91:	68 00 f0 7f 00       	push   $0x7ff000
  800f96:	56                   	push   %esi
  800f97:	e8 9f fd ff ff       	call   800d3b <sys_page_map>
  800f9c:	83 c4 20             	add    $0x20,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	79 12                	jns    800fb5 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800fa3:	50                   	push   %eax
  800fa4:	68 b8 28 80 00       	push   $0x8028b8
  800fa9:	6a 35                	push   $0x35
  800fab:	68 8f 28 80 00       	push   $0x80288f
  800fb0:	e8 63 f2 ff ff       	call   800218 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fb5:	83 ec 08             	sub    $0x8,%esp
  800fb8:	68 00 f0 7f 00       	push   $0x7ff000
  800fbd:	56                   	push   %esi
  800fbe:	e8 ba fd ff ff       	call   800d7d <sys_page_unmap>
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	79 12                	jns    800fdc <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800fca:	50                   	push   %eax
  800fcb:	68 9a 28 80 00       	push   $0x80289a
  800fd0:	6a 38                	push   $0x38
  800fd2:	68 8f 28 80 00       	push   $0x80288f
  800fd7:	e8 3c f2 ff ff       	call   800218 <_panic>
	//panic("pgfault not implemented");
}
  800fdc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fdf:	5b                   	pop    %ebx
  800fe0:	5e                   	pop    %esi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	57                   	push   %edi
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
  800fe9:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800fec:	68 e9 0e 80 00       	push   $0x800ee9
  800ff1:	e8 2a 0f 00 00       	call   801f20 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ff6:	b8 07 00 00 00       	mov    $0x7,%eax
  800ffb:	cd 30                	int    $0x30
  800ffd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	0f 88 38 01 00 00    	js     801143 <fork+0x160>
  80100b:	89 c7                	mov    %eax,%edi
  80100d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  801012:	85 c0                	test   %eax,%eax
  801014:	75 21                	jne    801037 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  801016:	e8 9f fc ff ff       	call   800cba <sys_getenvid>
  80101b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801020:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801023:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801028:	a3 20 44 80 00       	mov    %eax,0x804420
		return 0;
  80102d:	ba 00 00 00 00       	mov    $0x0,%edx
  801032:	e9 86 01 00 00       	jmp    8011bd <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  801037:	89 d8                	mov    %ebx,%eax
  801039:	c1 e8 16             	shr    $0x16,%eax
  80103c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801043:	a8 01                	test   $0x1,%al
  801045:	0f 84 90 00 00 00    	je     8010db <fork+0xf8>
  80104b:	89 d8                	mov    %ebx,%eax
  80104d:	c1 e8 0c             	shr    $0xc,%eax
  801050:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801057:	f6 c2 01             	test   $0x1,%dl
  80105a:	74 7f                	je     8010db <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  80105c:	89 c6                	mov    %eax,%esi
  80105e:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  801061:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801068:	f6 c6 04             	test   $0x4,%dh
  80106b:	74 33                	je     8010a0 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  80106d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801074:	83 ec 0c             	sub    $0xc,%esp
  801077:	25 07 0e 00 00       	and    $0xe07,%eax
  80107c:	50                   	push   %eax
  80107d:	56                   	push   %esi
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	6a 00                	push   $0x0
  801082:	e8 b4 fc ff ff       	call   800d3b <sys_page_map>
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	79 4d                	jns    8010db <fork+0xf8>
		    panic("sys_page_map: %e", r);
  80108e:	50                   	push   %eax
  80108f:	68 d4 28 80 00       	push   $0x8028d4
  801094:	6a 54                	push   $0x54
  801096:	68 8f 28 80 00       	push   $0x80288f
  80109b:	e8 78 f1 ff ff       	call   800218 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  8010a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010a7:	a9 02 08 00 00       	test   $0x802,%eax
  8010ac:	0f 85 c6 00 00 00    	jne    801178 <fork+0x195>
  8010b2:	e9 e3 00 00 00       	jmp    80119a <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8010b7:	50                   	push   %eax
  8010b8:	68 d4 28 80 00       	push   $0x8028d4
  8010bd:	6a 5d                	push   $0x5d
  8010bf:	68 8f 28 80 00       	push   $0x80288f
  8010c4:	e8 4f f1 ff ff       	call   800218 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8010c9:	50                   	push   %eax
  8010ca:	68 d4 28 80 00       	push   $0x8028d4
  8010cf:	6a 64                	push   $0x64
  8010d1:	68 8f 28 80 00       	push   $0x80288f
  8010d6:	e8 3d f1 ff ff       	call   800218 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  8010db:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010e1:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010e7:	0f 85 4a ff ff ff    	jne    801037 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  8010ed:	83 ec 04             	sub    $0x4,%esp
  8010f0:	6a 07                	push   $0x7
  8010f2:	68 00 f0 bf ee       	push   $0xeebff000
  8010f7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010fa:	57                   	push   %edi
  8010fb:	e8 f8 fb ff ff       	call   800cf8 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801100:	83 c4 10             	add    $0x10,%esp
		return ret;
  801103:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801105:	85 c0                	test   %eax,%eax
  801107:	0f 88 b0 00 00 00    	js     8011bd <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80110d:	a1 20 44 80 00       	mov    0x804420,%eax
  801112:	8b 40 64             	mov    0x64(%eax),%eax
  801115:	83 ec 08             	sub    $0x8,%esp
  801118:	50                   	push   %eax
  801119:	57                   	push   %edi
  80111a:	e8 24 fd ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
  80111f:	83 c4 10             	add    $0x10,%esp
		return ret;
  801122:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801124:	85 c0                	test   %eax,%eax
  801126:	0f 88 91 00 00 00    	js     8011bd <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80112c:	83 ec 08             	sub    $0x8,%esp
  80112f:	6a 02                	push   $0x2
  801131:	57                   	push   %edi
  801132:	e8 88 fc ff ff       	call   800dbf <sys_env_set_status>
  801137:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  80113a:	85 c0                	test   %eax,%eax
  80113c:	89 fa                	mov    %edi,%edx
  80113e:	0f 48 d0             	cmovs  %eax,%edx
  801141:	eb 7a                	jmp    8011bd <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  801143:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801146:	eb 75                	jmp    8011bd <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801148:	e8 6d fb ff ff       	call   800cba <sys_getenvid>
  80114d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801150:	e8 65 fb ff ff       	call   800cba <sys_getenvid>
  801155:	83 ec 0c             	sub    $0xc,%esp
  801158:	68 05 08 00 00       	push   $0x805
  80115d:	56                   	push   %esi
  80115e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801161:	56                   	push   %esi
  801162:	50                   	push   %eax
  801163:	e8 d3 fb ff ff       	call   800d3b <sys_page_map>
  801168:	83 c4 20             	add    $0x20,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	0f 89 68 ff ff ff    	jns    8010db <fork+0xf8>
  801173:	e9 51 ff ff ff       	jmp    8010c9 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  801178:	e8 3d fb ff ff       	call   800cba <sys_getenvid>
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	68 05 08 00 00       	push   $0x805
  801185:	56                   	push   %esi
  801186:	57                   	push   %edi
  801187:	56                   	push   %esi
  801188:	50                   	push   %eax
  801189:	e8 ad fb ff ff       	call   800d3b <sys_page_map>
  80118e:	83 c4 20             	add    $0x20,%esp
  801191:	85 c0                	test   %eax,%eax
  801193:	79 b3                	jns    801148 <fork+0x165>
  801195:	e9 1d ff ff ff       	jmp    8010b7 <fork+0xd4>
  80119a:	e8 1b fb ff ff       	call   800cba <sys_getenvid>
  80119f:	83 ec 0c             	sub    $0xc,%esp
  8011a2:	6a 05                	push   $0x5
  8011a4:	56                   	push   %esi
  8011a5:	57                   	push   %edi
  8011a6:	56                   	push   %esi
  8011a7:	50                   	push   %eax
  8011a8:	e8 8e fb ff ff       	call   800d3b <sys_page_map>
  8011ad:	83 c4 20             	add    $0x20,%esp
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	0f 89 23 ff ff ff    	jns    8010db <fork+0xf8>
  8011b8:	e9 fa fe ff ff       	jmp    8010b7 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  8011bd:	89 d0                	mov    %edx,%eax
  8011bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c2:	5b                   	pop    %ebx
  8011c3:	5e                   	pop    %esi
  8011c4:	5f                   	pop    %edi
  8011c5:	5d                   	pop    %ebp
  8011c6:	c3                   	ret    

008011c7 <sfork>:

// Challenge!
int
sfork(void)
{
  8011c7:	55                   	push   %ebp
  8011c8:	89 e5                	mov    %esp,%ebp
  8011ca:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011cd:	68 e5 28 80 00       	push   $0x8028e5
  8011d2:	68 ac 00 00 00       	push   $0xac
  8011d7:	68 8f 28 80 00       	push   $0x80288f
  8011dc:	e8 37 f0 ff ff       	call   800218 <_panic>

008011e1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ec:	c1 e8 0c             	shr    $0xc,%eax
}
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801201:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801213:	89 c2                	mov    %eax,%edx
  801215:	c1 ea 16             	shr    $0x16,%edx
  801218:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80121f:	f6 c2 01             	test   $0x1,%dl
  801222:	74 11                	je     801235 <fd_alloc+0x2d>
  801224:	89 c2                	mov    %eax,%edx
  801226:	c1 ea 0c             	shr    $0xc,%edx
  801229:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801230:	f6 c2 01             	test   $0x1,%dl
  801233:	75 09                	jne    80123e <fd_alloc+0x36>
			*fd_store = fd;
  801235:	89 01                	mov    %eax,(%ecx)
			return 0;
  801237:	b8 00 00 00 00       	mov    $0x0,%eax
  80123c:	eb 17                	jmp    801255 <fd_alloc+0x4d>
  80123e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801243:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801248:	75 c9                	jne    801213 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80124a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801250:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80125d:	83 f8 1f             	cmp    $0x1f,%eax
  801260:	77 36                	ja     801298 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801262:	c1 e0 0c             	shl    $0xc,%eax
  801265:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80126a:	89 c2                	mov    %eax,%edx
  80126c:	c1 ea 16             	shr    $0x16,%edx
  80126f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801276:	f6 c2 01             	test   $0x1,%dl
  801279:	74 24                	je     80129f <fd_lookup+0x48>
  80127b:	89 c2                	mov    %eax,%edx
  80127d:	c1 ea 0c             	shr    $0xc,%edx
  801280:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801287:	f6 c2 01             	test   $0x1,%dl
  80128a:	74 1a                	je     8012a6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80128c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128f:	89 02                	mov    %eax,(%edx)
	return 0;
  801291:	b8 00 00 00 00       	mov    $0x0,%eax
  801296:	eb 13                	jmp    8012ab <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801298:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80129d:	eb 0c                	jmp    8012ab <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80129f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012a4:	eb 05                	jmp    8012ab <fd_lookup+0x54>
  8012a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b6:	ba 7c 29 80 00       	mov    $0x80297c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012bb:	eb 13                	jmp    8012d0 <dev_lookup+0x23>
  8012bd:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012c0:	39 08                	cmp    %ecx,(%eax)
  8012c2:	75 0c                	jne    8012d0 <dev_lookup+0x23>
			*dev = devtab[i];
  8012c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ce:	eb 2e                	jmp    8012fe <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012d0:	8b 02                	mov    (%edx),%eax
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	75 e7                	jne    8012bd <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012d6:	a1 20 44 80 00       	mov    0x804420,%eax
  8012db:	8b 40 48             	mov    0x48(%eax),%eax
  8012de:	83 ec 04             	sub    $0x4,%esp
  8012e1:	51                   	push   %ecx
  8012e2:	50                   	push   %eax
  8012e3:	68 fc 28 80 00       	push   $0x8028fc
  8012e8:	e8 04 f0 ff ff       	call   8002f1 <cprintf>
	*dev = 0;
  8012ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012f6:	83 c4 10             	add    $0x10,%esp
  8012f9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012fe:	c9                   	leave  
  8012ff:	c3                   	ret    

00801300 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801300:	55                   	push   %ebp
  801301:	89 e5                	mov    %esp,%ebp
  801303:	56                   	push   %esi
  801304:	53                   	push   %ebx
  801305:	83 ec 10             	sub    $0x10,%esp
  801308:	8b 75 08             	mov    0x8(%ebp),%esi
  80130b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80130e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801318:	c1 e8 0c             	shr    $0xc,%eax
  80131b:	50                   	push   %eax
  80131c:	e8 36 ff ff ff       	call   801257 <fd_lookup>
  801321:	83 c4 08             	add    $0x8,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 05                	js     80132d <fd_close+0x2d>
	    || fd != fd2)
  801328:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80132b:	74 0c                	je     801339 <fd_close+0x39>
		return (must_exist ? r : 0);
  80132d:	84 db                	test   %bl,%bl
  80132f:	ba 00 00 00 00       	mov    $0x0,%edx
  801334:	0f 44 c2             	cmove  %edx,%eax
  801337:	eb 41                	jmp    80137a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	ff 36                	pushl  (%esi)
  801342:	e8 66 ff ff ff       	call   8012ad <dev_lookup>
  801347:	89 c3                	mov    %eax,%ebx
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 1a                	js     80136a <fd_close+0x6a>
		if (dev->dev_close)
  801350:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801353:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801356:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80135b:	85 c0                	test   %eax,%eax
  80135d:	74 0b                	je     80136a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80135f:	83 ec 0c             	sub    $0xc,%esp
  801362:	56                   	push   %esi
  801363:	ff d0                	call   *%eax
  801365:	89 c3                	mov    %eax,%ebx
  801367:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	56                   	push   %esi
  80136e:	6a 00                	push   $0x0
  801370:	e8 08 fa ff ff       	call   800d7d <sys_page_unmap>
	return r;
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	89 d8                	mov    %ebx,%eax
}
  80137a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137d:	5b                   	pop    %ebx
  80137e:	5e                   	pop    %esi
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    

00801381 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801387:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	ff 75 08             	pushl  0x8(%ebp)
  80138e:	e8 c4 fe ff ff       	call   801257 <fd_lookup>
  801393:	83 c4 08             	add    $0x8,%esp
  801396:	85 c0                	test   %eax,%eax
  801398:	78 10                	js     8013aa <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	6a 01                	push   $0x1
  80139f:	ff 75 f4             	pushl  -0xc(%ebp)
  8013a2:	e8 59 ff ff ff       	call   801300 <fd_close>
  8013a7:	83 c4 10             	add    $0x10,%esp
}
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <close_all>:

void
close_all(void)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	53                   	push   %ebx
  8013b0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013b3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013b8:	83 ec 0c             	sub    $0xc,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	e8 c0 ff ff ff       	call   801381 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013c1:	83 c3 01             	add    $0x1,%ebx
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	83 fb 20             	cmp    $0x20,%ebx
  8013ca:	75 ec                	jne    8013b8 <close_all+0xc>
		close(i);
}
  8013cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cf:	c9                   	leave  
  8013d0:	c3                   	ret    

008013d1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013d1:	55                   	push   %ebp
  8013d2:	89 e5                	mov    %esp,%ebp
  8013d4:	57                   	push   %edi
  8013d5:	56                   	push   %esi
  8013d6:	53                   	push   %ebx
  8013d7:	83 ec 2c             	sub    $0x2c,%esp
  8013da:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 75 08             	pushl  0x8(%ebp)
  8013e4:	e8 6e fe ff ff       	call   801257 <fd_lookup>
  8013e9:	83 c4 08             	add    $0x8,%esp
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	0f 88 c1 00 00 00    	js     8014b5 <dup+0xe4>
		return r;
	close(newfdnum);
  8013f4:	83 ec 0c             	sub    $0xc,%esp
  8013f7:	56                   	push   %esi
  8013f8:	e8 84 ff ff ff       	call   801381 <close>

	newfd = INDEX2FD(newfdnum);
  8013fd:	89 f3                	mov    %esi,%ebx
  8013ff:	c1 e3 0c             	shl    $0xc,%ebx
  801402:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801408:	83 c4 04             	add    $0x4,%esp
  80140b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80140e:	e8 de fd ff ff       	call   8011f1 <fd2data>
  801413:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801415:	89 1c 24             	mov    %ebx,(%esp)
  801418:	e8 d4 fd ff ff       	call   8011f1 <fd2data>
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801423:	89 f8                	mov    %edi,%eax
  801425:	c1 e8 16             	shr    $0x16,%eax
  801428:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80142f:	a8 01                	test   $0x1,%al
  801431:	74 37                	je     80146a <dup+0x99>
  801433:	89 f8                	mov    %edi,%eax
  801435:	c1 e8 0c             	shr    $0xc,%eax
  801438:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80143f:	f6 c2 01             	test   $0x1,%dl
  801442:	74 26                	je     80146a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801444:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144b:	83 ec 0c             	sub    $0xc,%esp
  80144e:	25 07 0e 00 00       	and    $0xe07,%eax
  801453:	50                   	push   %eax
  801454:	ff 75 d4             	pushl  -0x2c(%ebp)
  801457:	6a 00                	push   $0x0
  801459:	57                   	push   %edi
  80145a:	6a 00                	push   $0x0
  80145c:	e8 da f8 ff ff       	call   800d3b <sys_page_map>
  801461:	89 c7                	mov    %eax,%edi
  801463:	83 c4 20             	add    $0x20,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	78 2e                	js     801498 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80146a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80146d:	89 d0                	mov    %edx,%eax
  80146f:	c1 e8 0c             	shr    $0xc,%eax
  801472:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801479:	83 ec 0c             	sub    $0xc,%esp
  80147c:	25 07 0e 00 00       	and    $0xe07,%eax
  801481:	50                   	push   %eax
  801482:	53                   	push   %ebx
  801483:	6a 00                	push   $0x0
  801485:	52                   	push   %edx
  801486:	6a 00                	push   $0x0
  801488:	e8 ae f8 ff ff       	call   800d3b <sys_page_map>
  80148d:	89 c7                	mov    %eax,%edi
  80148f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801492:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801494:	85 ff                	test   %edi,%edi
  801496:	79 1d                	jns    8014b5 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	53                   	push   %ebx
  80149c:	6a 00                	push   $0x0
  80149e:	e8 da f8 ff ff       	call   800d7d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014a3:	83 c4 08             	add    $0x8,%esp
  8014a6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 cd f8 ff ff       	call   800d7d <sys_page_unmap>
	return r;
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	89 f8                	mov    %edi,%eax
}
  8014b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b8:	5b                   	pop    %ebx
  8014b9:	5e                   	pop    %esi
  8014ba:	5f                   	pop    %edi
  8014bb:	5d                   	pop    %ebp
  8014bc:	c3                   	ret    

008014bd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014bd:	55                   	push   %ebp
  8014be:	89 e5                	mov    %esp,%ebp
  8014c0:	53                   	push   %ebx
  8014c1:	83 ec 14             	sub    $0x14,%esp
  8014c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ca:	50                   	push   %eax
  8014cb:	53                   	push   %ebx
  8014cc:	e8 86 fd ff ff       	call   801257 <fd_lookup>
  8014d1:	83 c4 08             	add    $0x8,%esp
  8014d4:	89 c2                	mov    %eax,%edx
  8014d6:	85 c0                	test   %eax,%eax
  8014d8:	78 6d                	js     801547 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	83 ec 08             	sub    $0x8,%esp
  8014dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e4:	ff 30                	pushl  (%eax)
  8014e6:	e8 c2 fd ff ff       	call   8012ad <dev_lookup>
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 4c                	js     80153e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014f2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014f5:	8b 42 08             	mov    0x8(%edx),%eax
  8014f8:	83 e0 03             	and    $0x3,%eax
  8014fb:	83 f8 01             	cmp    $0x1,%eax
  8014fe:	75 21                	jne    801521 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801500:	a1 20 44 80 00       	mov    0x804420,%eax
  801505:	8b 40 48             	mov    0x48(%eax),%eax
  801508:	83 ec 04             	sub    $0x4,%esp
  80150b:	53                   	push   %ebx
  80150c:	50                   	push   %eax
  80150d:	68 40 29 80 00       	push   $0x802940
  801512:	e8 da ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80151f:	eb 26                	jmp    801547 <read+0x8a>
	}
	if (!dev->dev_read)
  801521:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801524:	8b 40 08             	mov    0x8(%eax),%eax
  801527:	85 c0                	test   %eax,%eax
  801529:	74 17                	je     801542 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	ff 75 10             	pushl  0x10(%ebp)
  801531:	ff 75 0c             	pushl  0xc(%ebp)
  801534:	52                   	push   %edx
  801535:	ff d0                	call   *%eax
  801537:	89 c2                	mov    %eax,%edx
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	eb 09                	jmp    801547 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153e:	89 c2                	mov    %eax,%edx
  801540:	eb 05                	jmp    801547 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801542:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801547:	89 d0                	mov    %edx,%eax
  801549:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154c:	c9                   	leave  
  80154d:	c3                   	ret    

0080154e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80154e:	55                   	push   %ebp
  80154f:	89 e5                	mov    %esp,%ebp
  801551:	57                   	push   %edi
  801552:	56                   	push   %esi
  801553:	53                   	push   %ebx
  801554:	83 ec 0c             	sub    $0xc,%esp
  801557:	8b 7d 08             	mov    0x8(%ebp),%edi
  80155a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80155d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801562:	eb 21                	jmp    801585 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801564:	83 ec 04             	sub    $0x4,%esp
  801567:	89 f0                	mov    %esi,%eax
  801569:	29 d8                	sub    %ebx,%eax
  80156b:	50                   	push   %eax
  80156c:	89 d8                	mov    %ebx,%eax
  80156e:	03 45 0c             	add    0xc(%ebp),%eax
  801571:	50                   	push   %eax
  801572:	57                   	push   %edi
  801573:	e8 45 ff ff ff       	call   8014bd <read>
		if (m < 0)
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	85 c0                	test   %eax,%eax
  80157d:	78 10                	js     80158f <readn+0x41>
			return m;
		if (m == 0)
  80157f:	85 c0                	test   %eax,%eax
  801581:	74 0a                	je     80158d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801583:	01 c3                	add    %eax,%ebx
  801585:	39 f3                	cmp    %esi,%ebx
  801587:	72 db                	jb     801564 <readn+0x16>
  801589:	89 d8                	mov    %ebx,%eax
  80158b:	eb 02                	jmp    80158f <readn+0x41>
  80158d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80158f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801592:	5b                   	pop    %ebx
  801593:	5e                   	pop    %esi
  801594:	5f                   	pop    %edi
  801595:	5d                   	pop    %ebp
  801596:	c3                   	ret    

00801597 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801597:	55                   	push   %ebp
  801598:	89 e5                	mov    %esp,%ebp
  80159a:	53                   	push   %ebx
  80159b:	83 ec 14             	sub    $0x14,%esp
  80159e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a4:	50                   	push   %eax
  8015a5:	53                   	push   %ebx
  8015a6:	e8 ac fc ff ff       	call   801257 <fd_lookup>
  8015ab:	83 c4 08             	add    $0x8,%esp
  8015ae:	89 c2                	mov    %eax,%edx
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	78 68                	js     80161c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ba:	50                   	push   %eax
  8015bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015be:	ff 30                	pushl  (%eax)
  8015c0:	e8 e8 fc ff ff       	call   8012ad <dev_lookup>
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 47                	js     801613 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015cf:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015d3:	75 21                	jne    8015f6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015d5:	a1 20 44 80 00       	mov    0x804420,%eax
  8015da:	8b 40 48             	mov    0x48(%eax),%eax
  8015dd:	83 ec 04             	sub    $0x4,%esp
  8015e0:	53                   	push   %ebx
  8015e1:	50                   	push   %eax
  8015e2:	68 5c 29 80 00       	push   $0x80295c
  8015e7:	e8 05 ed ff ff       	call   8002f1 <cprintf>
		return -E_INVAL;
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015f4:	eb 26                	jmp    80161c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015f6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015f9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015fc:	85 d2                	test   %edx,%edx
  8015fe:	74 17                	je     801617 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	ff 75 10             	pushl  0x10(%ebp)
  801606:	ff 75 0c             	pushl  0xc(%ebp)
  801609:	50                   	push   %eax
  80160a:	ff d2                	call   *%edx
  80160c:	89 c2                	mov    %eax,%edx
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	eb 09                	jmp    80161c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801613:	89 c2                	mov    %eax,%edx
  801615:	eb 05                	jmp    80161c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801617:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80161c:	89 d0                	mov    %edx,%eax
  80161e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801621:	c9                   	leave  
  801622:	c3                   	ret    

00801623 <seek>:

int
seek(int fdnum, off_t offset)
{
  801623:	55                   	push   %ebp
  801624:	89 e5                	mov    %esp,%ebp
  801626:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801629:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	ff 75 08             	pushl  0x8(%ebp)
  801630:	e8 22 fc ff ff       	call   801257 <fd_lookup>
  801635:	83 c4 08             	add    $0x8,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 0e                	js     80164a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80163c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80163f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801642:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801645:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80164a:	c9                   	leave  
  80164b:	c3                   	ret    

0080164c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	53                   	push   %ebx
  801650:	83 ec 14             	sub    $0x14,%esp
  801653:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801656:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801659:	50                   	push   %eax
  80165a:	53                   	push   %ebx
  80165b:	e8 f7 fb ff ff       	call   801257 <fd_lookup>
  801660:	83 c4 08             	add    $0x8,%esp
  801663:	89 c2                	mov    %eax,%edx
  801665:	85 c0                	test   %eax,%eax
  801667:	78 65                	js     8016ce <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801669:	83 ec 08             	sub    $0x8,%esp
  80166c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166f:	50                   	push   %eax
  801670:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801673:	ff 30                	pushl  (%eax)
  801675:	e8 33 fc ff ff       	call   8012ad <dev_lookup>
  80167a:	83 c4 10             	add    $0x10,%esp
  80167d:	85 c0                	test   %eax,%eax
  80167f:	78 44                	js     8016c5 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801684:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801688:	75 21                	jne    8016ab <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80168a:	a1 20 44 80 00       	mov    0x804420,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80168f:	8b 40 48             	mov    0x48(%eax),%eax
  801692:	83 ec 04             	sub    $0x4,%esp
  801695:	53                   	push   %ebx
  801696:	50                   	push   %eax
  801697:	68 1c 29 80 00       	push   $0x80291c
  80169c:	e8 50 ec ff ff       	call   8002f1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016a9:	eb 23                	jmp    8016ce <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ae:	8b 52 18             	mov    0x18(%edx),%edx
  8016b1:	85 d2                	test   %edx,%edx
  8016b3:	74 14                	je     8016c9 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b5:	83 ec 08             	sub    $0x8,%esp
  8016b8:	ff 75 0c             	pushl  0xc(%ebp)
  8016bb:	50                   	push   %eax
  8016bc:	ff d2                	call   *%edx
  8016be:	89 c2                	mov    %eax,%edx
  8016c0:	83 c4 10             	add    $0x10,%esp
  8016c3:	eb 09                	jmp    8016ce <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c5:	89 c2                	mov    %eax,%edx
  8016c7:	eb 05                	jmp    8016ce <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ce:	89 d0                	mov    %edx,%eax
  8016d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 14             	sub    $0x14,%esp
  8016dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016e2:	50                   	push   %eax
  8016e3:	ff 75 08             	pushl  0x8(%ebp)
  8016e6:	e8 6c fb ff ff       	call   801257 <fd_lookup>
  8016eb:	83 c4 08             	add    $0x8,%esp
  8016ee:	89 c2                	mov    %eax,%edx
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 58                	js     80174c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fa:	50                   	push   %eax
  8016fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016fe:	ff 30                	pushl  (%eax)
  801700:	e8 a8 fb ff ff       	call   8012ad <dev_lookup>
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 37                	js     801743 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80170c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80170f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801713:	74 32                	je     801747 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801715:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801718:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80171f:	00 00 00 
	stat->st_isdir = 0;
  801722:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801729:	00 00 00 
	stat->st_dev = dev;
  80172c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801732:	83 ec 08             	sub    $0x8,%esp
  801735:	53                   	push   %ebx
  801736:	ff 75 f0             	pushl  -0x10(%ebp)
  801739:	ff 50 14             	call   *0x14(%eax)
  80173c:	89 c2                	mov    %eax,%edx
  80173e:	83 c4 10             	add    $0x10,%esp
  801741:	eb 09                	jmp    80174c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801743:	89 c2                	mov    %eax,%edx
  801745:	eb 05                	jmp    80174c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801747:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80174c:	89 d0                	mov    %edx,%eax
  80174e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801751:	c9                   	leave  
  801752:	c3                   	ret    

00801753 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801758:	83 ec 08             	sub    $0x8,%esp
  80175b:	6a 00                	push   $0x0
  80175d:	ff 75 08             	pushl  0x8(%ebp)
  801760:	e8 e9 01 00 00       	call   80194e <open>
  801765:	89 c3                	mov    %eax,%ebx
  801767:	83 c4 10             	add    $0x10,%esp
  80176a:	85 c0                	test   %eax,%eax
  80176c:	78 1b                	js     801789 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80176e:	83 ec 08             	sub    $0x8,%esp
  801771:	ff 75 0c             	pushl  0xc(%ebp)
  801774:	50                   	push   %eax
  801775:	e8 5b ff ff ff       	call   8016d5 <fstat>
  80177a:	89 c6                	mov    %eax,%esi
	close(fd);
  80177c:	89 1c 24             	mov    %ebx,(%esp)
  80177f:	e8 fd fb ff ff       	call   801381 <close>
	return r;
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	89 f0                	mov    %esi,%eax
}
  801789:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178c:	5b                   	pop    %ebx
  80178d:	5e                   	pop    %esi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	56                   	push   %esi
  801794:	53                   	push   %ebx
  801795:	89 c6                	mov    %eax,%esi
  801797:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801799:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017a0:	75 12                	jne    8017b4 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017a2:	83 ec 0c             	sub    $0xc,%esp
  8017a5:	6a 01                	push   $0x1
  8017a7:	e8 e4 08 00 00       	call   802090 <ipc_find_env>
  8017ac:	a3 00 40 80 00       	mov    %eax,0x804000
  8017b1:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b4:	6a 07                	push   $0x7
  8017b6:	68 00 50 80 00       	push   $0x805000
  8017bb:	56                   	push   %esi
  8017bc:	ff 35 00 40 80 00    	pushl  0x804000
  8017c2:	e8 75 08 00 00       	call   80203c <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  8017c7:	83 c4 0c             	add    $0xc,%esp
  8017ca:	6a 00                	push   $0x0
  8017cc:	53                   	push   %ebx
  8017cd:	6a 00                	push   $0x0
  8017cf:	e8 e6 07 00 00       	call   801fba <ipc_recv>
}
  8017d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d7:	5b                   	pop    %ebx
  8017d8:	5e                   	pop    %esi
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ef:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8017fe:	e8 8d ff ff ff       	call   801790 <fsipc>
}
  801803:	c9                   	leave  
  801804:	c3                   	ret    

00801805 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	8b 40 0c             	mov    0xc(%eax),%eax
  801811:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801816:	ba 00 00 00 00       	mov    $0x0,%edx
  80181b:	b8 06 00 00 00       	mov    $0x6,%eax
  801820:	e8 6b ff ff ff       	call   801790 <fsipc>
}
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801827:	55                   	push   %ebp
  801828:	89 e5                	mov    %esp,%ebp
  80182a:	53                   	push   %ebx
  80182b:	83 ec 04             	sub    $0x4,%esp
  80182e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801831:	8b 45 08             	mov    0x8(%ebp),%eax
  801834:	8b 40 0c             	mov    0xc(%eax),%eax
  801837:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80183c:	ba 00 00 00 00       	mov    $0x0,%edx
  801841:	b8 05 00 00 00       	mov    $0x5,%eax
  801846:	e8 45 ff ff ff       	call   801790 <fsipc>
  80184b:	85 c0                	test   %eax,%eax
  80184d:	78 2c                	js     80187b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	68 00 50 80 00       	push   $0x805000
  801857:	53                   	push   %ebx
  801858:	e8 98 f0 ff ff       	call   8008f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80185d:	a1 80 50 80 00       	mov    0x805080,%eax
  801862:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801868:	a1 84 50 80 00       	mov    0x805084,%eax
  80186d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80187b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	83 ec 0c             	sub    $0xc,%esp
  801886:	8b 45 10             	mov    0x10(%ebp),%eax
  801889:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80188e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801893:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801896:	8b 55 08             	mov    0x8(%ebp),%edx
  801899:	8b 52 0c             	mov    0xc(%edx),%edx
  80189c:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8018a2:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8018a7:	50                   	push   %eax
  8018a8:	ff 75 0c             	pushl  0xc(%ebp)
  8018ab:	68 08 50 80 00       	push   $0x805008
  8018b0:	e8 d2 f1 ff ff       	call   800a87 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ba:	b8 04 00 00 00       	mov    $0x4,%eax
  8018bf:	e8 cc fe ff ff       	call   801790 <fsipc>
            return r;

    return r;
}
  8018c4:	c9                   	leave  
  8018c5:	c3                   	ret    

008018c6 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	56                   	push   %esi
  8018ca:	53                   	push   %ebx
  8018cb:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018d9:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018e9:	e8 a2 fe ff ff       	call   801790 <fsipc>
  8018ee:	89 c3                	mov    %eax,%ebx
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 51                	js     801945 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8018f4:	39 c6                	cmp    %eax,%esi
  8018f6:	73 19                	jae    801911 <devfile_read+0x4b>
  8018f8:	68 8c 29 80 00       	push   $0x80298c
  8018fd:	68 93 29 80 00       	push   $0x802993
  801902:	68 82 00 00 00       	push   $0x82
  801907:	68 a8 29 80 00       	push   $0x8029a8
  80190c:	e8 07 e9 ff ff       	call   800218 <_panic>
	assert(r <= PGSIZE);
  801911:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801916:	7e 19                	jle    801931 <devfile_read+0x6b>
  801918:	68 b3 29 80 00       	push   $0x8029b3
  80191d:	68 93 29 80 00       	push   $0x802993
  801922:	68 83 00 00 00       	push   $0x83
  801927:	68 a8 29 80 00       	push   $0x8029a8
  80192c:	e8 e7 e8 ff ff       	call   800218 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801931:	83 ec 04             	sub    $0x4,%esp
  801934:	50                   	push   %eax
  801935:	68 00 50 80 00       	push   $0x805000
  80193a:	ff 75 0c             	pushl  0xc(%ebp)
  80193d:	e8 45 f1 ff ff       	call   800a87 <memmove>
	return r;
  801942:	83 c4 10             	add    $0x10,%esp
}
  801945:	89 d8                	mov    %ebx,%eax
  801947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80194a:	5b                   	pop    %ebx
  80194b:	5e                   	pop    %esi
  80194c:	5d                   	pop    %ebp
  80194d:	c3                   	ret    

0080194e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80194e:	55                   	push   %ebp
  80194f:	89 e5                	mov    %esp,%ebp
  801951:	53                   	push   %ebx
  801952:	83 ec 20             	sub    $0x20,%esp
  801955:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801958:	53                   	push   %ebx
  801959:	e8 5e ef ff ff       	call   8008bc <strlen>
  80195e:	83 c4 10             	add    $0x10,%esp
  801961:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801966:	7f 67                	jg     8019cf <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801968:	83 ec 0c             	sub    $0xc,%esp
  80196b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80196e:	50                   	push   %eax
  80196f:	e8 94 f8 ff ff       	call   801208 <fd_alloc>
  801974:	83 c4 10             	add    $0x10,%esp
		return r;
  801977:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801979:	85 c0                	test   %eax,%eax
  80197b:	78 57                	js     8019d4 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80197d:	83 ec 08             	sub    $0x8,%esp
  801980:	53                   	push   %ebx
  801981:	68 00 50 80 00       	push   $0x805000
  801986:	e8 6a ef ff ff       	call   8008f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80198b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801993:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801996:	b8 01 00 00 00       	mov    $0x1,%eax
  80199b:	e8 f0 fd ff ff       	call   801790 <fsipc>
  8019a0:	89 c3                	mov    %eax,%ebx
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	79 14                	jns    8019bd <open+0x6f>
		fd_close(fd, 0);
  8019a9:	83 ec 08             	sub    $0x8,%esp
  8019ac:	6a 00                	push   $0x0
  8019ae:	ff 75 f4             	pushl  -0xc(%ebp)
  8019b1:	e8 4a f9 ff ff       	call   801300 <fd_close>
		return r;
  8019b6:	83 c4 10             	add    $0x10,%esp
  8019b9:	89 da                	mov    %ebx,%edx
  8019bb:	eb 17                	jmp    8019d4 <open+0x86>
	}

	return fd2num(fd);
  8019bd:	83 ec 0c             	sub    $0xc,%esp
  8019c0:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c3:	e8 19 f8 ff ff       	call   8011e1 <fd2num>
  8019c8:	89 c2                	mov    %eax,%edx
  8019ca:	83 c4 10             	add    $0x10,%esp
  8019cd:	eb 05                	jmp    8019d4 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019cf:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019d4:	89 d0                	mov    %edx,%eax
  8019d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019eb:	e8 a0 fd ff ff       	call   801790 <fsipc>
}
  8019f0:	c9                   	leave  
  8019f1:	c3                   	ret    

008019f2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019f2:	55                   	push   %ebp
  8019f3:	89 e5                	mov    %esp,%ebp
  8019f5:	56                   	push   %esi
  8019f6:	53                   	push   %ebx
  8019f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019fa:	83 ec 0c             	sub    $0xc,%esp
  8019fd:	ff 75 08             	pushl  0x8(%ebp)
  801a00:	e8 ec f7 ff ff       	call   8011f1 <fd2data>
  801a05:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a07:	83 c4 08             	add    $0x8,%esp
  801a0a:	68 bf 29 80 00       	push   $0x8029bf
  801a0f:	53                   	push   %ebx
  801a10:	e8 e0 ee ff ff       	call   8008f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a15:	8b 46 04             	mov    0x4(%esi),%eax
  801a18:	2b 06                	sub    (%esi),%eax
  801a1a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a20:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a27:	00 00 00 
	stat->st_dev = &devpipe;
  801a2a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a31:	30 80 00 
	return 0;
}
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
  801a39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3c:	5b                   	pop    %ebx
  801a3d:	5e                   	pop    %esi
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	53                   	push   %ebx
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a4a:	53                   	push   %ebx
  801a4b:	6a 00                	push   $0x0
  801a4d:	e8 2b f3 ff ff       	call   800d7d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a52:	89 1c 24             	mov    %ebx,(%esp)
  801a55:	e8 97 f7 ff ff       	call   8011f1 <fd2data>
  801a5a:	83 c4 08             	add    $0x8,%esp
  801a5d:	50                   	push   %eax
  801a5e:	6a 00                	push   $0x0
  801a60:	e8 18 f3 ff ff       	call   800d7d <sys_page_unmap>
}
  801a65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a6a:	55                   	push   %ebp
  801a6b:	89 e5                	mov    %esp,%ebp
  801a6d:	57                   	push   %edi
  801a6e:	56                   	push   %esi
  801a6f:	53                   	push   %ebx
  801a70:	83 ec 1c             	sub    $0x1c,%esp
  801a73:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a76:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a78:	a1 20 44 80 00       	mov    0x804420,%eax
  801a7d:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	ff 75 e0             	pushl  -0x20(%ebp)
  801a86:	e8 3e 06 00 00       	call   8020c9 <pageref>
  801a8b:	89 c3                	mov    %eax,%ebx
  801a8d:	89 3c 24             	mov    %edi,(%esp)
  801a90:	e8 34 06 00 00       	call   8020c9 <pageref>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	39 c3                	cmp    %eax,%ebx
  801a9a:	0f 94 c1             	sete   %cl
  801a9d:	0f b6 c9             	movzbl %cl,%ecx
  801aa0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aa3:	8b 15 20 44 80 00    	mov    0x804420,%edx
  801aa9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aac:	39 ce                	cmp    %ecx,%esi
  801aae:	74 1b                	je     801acb <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ab0:	39 c3                	cmp    %eax,%ebx
  801ab2:	75 c4                	jne    801a78 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ab4:	8b 42 58             	mov    0x58(%edx),%eax
  801ab7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801aba:	50                   	push   %eax
  801abb:	56                   	push   %esi
  801abc:	68 c6 29 80 00       	push   $0x8029c6
  801ac1:	e8 2b e8 ff ff       	call   8002f1 <cprintf>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	eb ad                	jmp    801a78 <_pipeisclosed+0xe>
	}
}
  801acb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ace:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad1:	5b                   	pop    %ebx
  801ad2:	5e                   	pop    %esi
  801ad3:	5f                   	pop    %edi
  801ad4:	5d                   	pop    %ebp
  801ad5:	c3                   	ret    

00801ad6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ad6:	55                   	push   %ebp
  801ad7:	89 e5                	mov    %esp,%ebp
  801ad9:	57                   	push   %edi
  801ada:	56                   	push   %esi
  801adb:	53                   	push   %ebx
  801adc:	83 ec 28             	sub    $0x28,%esp
  801adf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ae2:	56                   	push   %esi
  801ae3:	e8 09 f7 ff ff       	call   8011f1 <fd2data>
  801ae8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	bf 00 00 00 00       	mov    $0x0,%edi
  801af2:	eb 4b                	jmp    801b3f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801af4:	89 da                	mov    %ebx,%edx
  801af6:	89 f0                	mov    %esi,%eax
  801af8:	e8 6d ff ff ff       	call   801a6a <_pipeisclosed>
  801afd:	85 c0                	test   %eax,%eax
  801aff:	75 48                	jne    801b49 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b01:	e8 d3 f1 ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b06:	8b 43 04             	mov    0x4(%ebx),%eax
  801b09:	8b 0b                	mov    (%ebx),%ecx
  801b0b:	8d 51 20             	lea    0x20(%ecx),%edx
  801b0e:	39 d0                	cmp    %edx,%eax
  801b10:	73 e2                	jae    801af4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b15:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b19:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b1c:	89 c2                	mov    %eax,%edx
  801b1e:	c1 fa 1f             	sar    $0x1f,%edx
  801b21:	89 d1                	mov    %edx,%ecx
  801b23:	c1 e9 1b             	shr    $0x1b,%ecx
  801b26:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b29:	83 e2 1f             	and    $0x1f,%edx
  801b2c:	29 ca                	sub    %ecx,%edx
  801b2e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b32:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b36:	83 c0 01             	add    $0x1,%eax
  801b39:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b3c:	83 c7 01             	add    $0x1,%edi
  801b3f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b42:	75 c2                	jne    801b06 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b44:	8b 45 10             	mov    0x10(%ebp),%eax
  801b47:	eb 05                	jmp    801b4e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b49:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5f                   	pop    %edi
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    

00801b56 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	57                   	push   %edi
  801b5a:	56                   	push   %esi
  801b5b:	53                   	push   %ebx
  801b5c:	83 ec 18             	sub    $0x18,%esp
  801b5f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b62:	57                   	push   %edi
  801b63:	e8 89 f6 ff ff       	call   8011f1 <fd2data>
  801b68:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b72:	eb 3d                	jmp    801bb1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b74:	85 db                	test   %ebx,%ebx
  801b76:	74 04                	je     801b7c <devpipe_read+0x26>
				return i;
  801b78:	89 d8                	mov    %ebx,%eax
  801b7a:	eb 44                	jmp    801bc0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b7c:	89 f2                	mov    %esi,%edx
  801b7e:	89 f8                	mov    %edi,%eax
  801b80:	e8 e5 fe ff ff       	call   801a6a <_pipeisclosed>
  801b85:	85 c0                	test   %eax,%eax
  801b87:	75 32                	jne    801bbb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b89:	e8 4b f1 ff ff       	call   800cd9 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b8e:	8b 06                	mov    (%esi),%eax
  801b90:	3b 46 04             	cmp    0x4(%esi),%eax
  801b93:	74 df                	je     801b74 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b95:	99                   	cltd   
  801b96:	c1 ea 1b             	shr    $0x1b,%edx
  801b99:	01 d0                	add    %edx,%eax
  801b9b:	83 e0 1f             	and    $0x1f,%eax
  801b9e:	29 d0                	sub    %edx,%eax
  801ba0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ba5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bab:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bae:	83 c3 01             	add    $0x1,%ebx
  801bb1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bb4:	75 d8                	jne    801b8e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bb6:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb9:	eb 05                	jmp    801bc0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bbb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bc3:	5b                   	pop    %ebx
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    

00801bc8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	56                   	push   %esi
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bd0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bd3:	50                   	push   %eax
  801bd4:	e8 2f f6 ff ff       	call   801208 <fd_alloc>
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	89 c2                	mov    %eax,%edx
  801bde:	85 c0                	test   %eax,%eax
  801be0:	0f 88 2c 01 00 00    	js     801d12 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be6:	83 ec 04             	sub    $0x4,%esp
  801be9:	68 07 04 00 00       	push   $0x407
  801bee:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf1:	6a 00                	push   $0x0
  801bf3:	e8 00 f1 ff ff       	call   800cf8 <sys_page_alloc>
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	89 c2                	mov    %eax,%edx
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	0f 88 0d 01 00 00    	js     801d12 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c0b:	50                   	push   %eax
  801c0c:	e8 f7 f5 ff ff       	call   801208 <fd_alloc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	83 c4 10             	add    $0x10,%esp
  801c16:	85 c0                	test   %eax,%eax
  801c18:	0f 88 e2 00 00 00    	js     801d00 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c1e:	83 ec 04             	sub    $0x4,%esp
  801c21:	68 07 04 00 00       	push   $0x407
  801c26:	ff 75 f0             	pushl  -0x10(%ebp)
  801c29:	6a 00                	push   $0x0
  801c2b:	e8 c8 f0 ff ff       	call   800cf8 <sys_page_alloc>
  801c30:	89 c3                	mov    %eax,%ebx
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	85 c0                	test   %eax,%eax
  801c37:	0f 88 c3 00 00 00    	js     801d00 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c3d:	83 ec 0c             	sub    $0xc,%esp
  801c40:	ff 75 f4             	pushl  -0xc(%ebp)
  801c43:	e8 a9 f5 ff ff       	call   8011f1 <fd2data>
  801c48:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c4a:	83 c4 0c             	add    $0xc,%esp
  801c4d:	68 07 04 00 00       	push   $0x407
  801c52:	50                   	push   %eax
  801c53:	6a 00                	push   $0x0
  801c55:	e8 9e f0 ff ff       	call   800cf8 <sys_page_alloc>
  801c5a:	89 c3                	mov    %eax,%ebx
  801c5c:	83 c4 10             	add    $0x10,%esp
  801c5f:	85 c0                	test   %eax,%eax
  801c61:	0f 88 89 00 00 00    	js     801cf0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c67:	83 ec 0c             	sub    $0xc,%esp
  801c6a:	ff 75 f0             	pushl  -0x10(%ebp)
  801c6d:	e8 7f f5 ff ff       	call   8011f1 <fd2data>
  801c72:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c79:	50                   	push   %eax
  801c7a:	6a 00                	push   $0x0
  801c7c:	56                   	push   %esi
  801c7d:	6a 00                	push   $0x0
  801c7f:	e8 b7 f0 ff ff       	call   800d3b <sys_page_map>
  801c84:	89 c3                	mov    %eax,%ebx
  801c86:	83 c4 20             	add    $0x20,%esp
  801c89:	85 c0                	test   %eax,%eax
  801c8b:	78 55                	js     801ce2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c8d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c96:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ca2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cab:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cb7:	83 ec 0c             	sub    $0xc,%esp
  801cba:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbd:	e8 1f f5 ff ff       	call   8011e1 <fd2num>
  801cc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cc5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cc7:	83 c4 04             	add    $0x4,%esp
  801cca:	ff 75 f0             	pushl  -0x10(%ebp)
  801ccd:	e8 0f f5 ff ff       	call   8011e1 <fd2num>
  801cd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce0:	eb 30                	jmp    801d12 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ce2:	83 ec 08             	sub    $0x8,%esp
  801ce5:	56                   	push   %esi
  801ce6:	6a 00                	push   $0x0
  801ce8:	e8 90 f0 ff ff       	call   800d7d <sys_page_unmap>
  801ced:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf0:	83 ec 08             	sub    $0x8,%esp
  801cf3:	ff 75 f0             	pushl  -0x10(%ebp)
  801cf6:	6a 00                	push   $0x0
  801cf8:	e8 80 f0 ff ff       	call   800d7d <sys_page_unmap>
  801cfd:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d00:	83 ec 08             	sub    $0x8,%esp
  801d03:	ff 75 f4             	pushl  -0xc(%ebp)
  801d06:	6a 00                	push   $0x0
  801d08:	e8 70 f0 ff ff       	call   800d7d <sys_page_unmap>
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d12:	89 d0                	mov    %edx,%eax
  801d14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d17:	5b                   	pop    %ebx
  801d18:	5e                   	pop    %esi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    

00801d1b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d1b:	55                   	push   %ebp
  801d1c:	89 e5                	mov    %esp,%ebp
  801d1e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d21:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d24:	50                   	push   %eax
  801d25:	ff 75 08             	pushl  0x8(%ebp)
  801d28:	e8 2a f5 ff ff       	call   801257 <fd_lookup>
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 18                	js     801d4c <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d34:	83 ec 0c             	sub    $0xc,%esp
  801d37:	ff 75 f4             	pushl  -0xc(%ebp)
  801d3a:	e8 b2 f4 ff ff       	call   8011f1 <fd2data>
	return _pipeisclosed(fd, p);
  801d3f:	89 c2                	mov    %eax,%edx
  801d41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d44:	e8 21 fd ff ff       	call   801a6a <_pipeisclosed>
  801d49:	83 c4 10             	add    $0x10,%esp
}
  801d4c:	c9                   	leave  
  801d4d:	c3                   	ret    

00801d4e <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	56                   	push   %esi
  801d52:	53                   	push   %ebx
  801d53:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d56:	85 f6                	test   %esi,%esi
  801d58:	75 16                	jne    801d70 <wait+0x22>
  801d5a:	68 de 29 80 00       	push   $0x8029de
  801d5f:	68 93 29 80 00       	push   $0x802993
  801d64:	6a 09                	push   $0x9
  801d66:	68 e9 29 80 00       	push   $0x8029e9
  801d6b:	e8 a8 e4 ff ff       	call   800218 <_panic>
	e = &envs[ENVX(envid)];
  801d70:	89 f3                	mov    %esi,%ebx
  801d72:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d78:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d7b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d81:	eb 05                	jmp    801d88 <wait+0x3a>
		sys_yield();
  801d83:	e8 51 ef ff ff       	call   800cd9 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d88:	8b 43 48             	mov    0x48(%ebx),%eax
  801d8b:	39 c6                	cmp    %eax,%esi
  801d8d:	75 07                	jne    801d96 <wait+0x48>
  801d8f:	8b 43 54             	mov    0x54(%ebx),%eax
  801d92:	85 c0                	test   %eax,%eax
  801d94:	75 ed                	jne    801d83 <wait+0x35>
		sys_yield();
}
  801d96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d99:	5b                   	pop    %ebx
  801d9a:	5e                   	pop    %esi
  801d9b:	5d                   	pop    %ebp
  801d9c:	c3                   	ret    

00801d9d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801da0:	b8 00 00 00 00       	mov    $0x0,%eax
  801da5:	5d                   	pop    %ebp
  801da6:	c3                   	ret    

00801da7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dad:	68 f4 29 80 00       	push   $0x8029f4
  801db2:	ff 75 0c             	pushl  0xc(%ebp)
  801db5:	e8 3b eb ff ff       	call   8008f5 <strcpy>
	return 0;
}
  801dba:	b8 00 00 00 00       	mov    $0x0,%eax
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	57                   	push   %edi
  801dc5:	56                   	push   %esi
  801dc6:	53                   	push   %ebx
  801dc7:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcd:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd2:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd8:	eb 2d                	jmp    801e07 <devcons_write+0x46>
		m = n - tot;
  801dda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ddd:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801ddf:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801de2:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801de7:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dea:	83 ec 04             	sub    $0x4,%esp
  801ded:	53                   	push   %ebx
  801dee:	03 45 0c             	add    0xc(%ebp),%eax
  801df1:	50                   	push   %eax
  801df2:	57                   	push   %edi
  801df3:	e8 8f ec ff ff       	call   800a87 <memmove>
		sys_cputs(buf, m);
  801df8:	83 c4 08             	add    $0x8,%esp
  801dfb:	53                   	push   %ebx
  801dfc:	57                   	push   %edi
  801dfd:	e8 3a ee ff ff       	call   800c3c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e02:	01 de                	add    %ebx,%esi
  801e04:	83 c4 10             	add    $0x10,%esp
  801e07:	89 f0                	mov    %esi,%eax
  801e09:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e0c:	72 cc                	jb     801dda <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e11:	5b                   	pop    %ebx
  801e12:	5e                   	pop    %esi
  801e13:	5f                   	pop    %edi
  801e14:	5d                   	pop    %ebp
  801e15:	c3                   	ret    

00801e16 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e16:	55                   	push   %ebp
  801e17:	89 e5                	mov    %esp,%ebp
  801e19:	83 ec 08             	sub    $0x8,%esp
  801e1c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e25:	74 2a                	je     801e51 <devcons_read+0x3b>
  801e27:	eb 05                	jmp    801e2e <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e29:	e8 ab ee ff ff       	call   800cd9 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e2e:	e8 27 ee ff ff       	call   800c5a <sys_cgetc>
  801e33:	85 c0                	test   %eax,%eax
  801e35:	74 f2                	je     801e29 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e37:	85 c0                	test   %eax,%eax
  801e39:	78 16                	js     801e51 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e3b:	83 f8 04             	cmp    $0x4,%eax
  801e3e:	74 0c                	je     801e4c <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e40:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e43:	88 02                	mov    %al,(%edx)
	return 1;
  801e45:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4a:	eb 05                	jmp    801e51 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e4c:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e59:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5c:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e5f:	6a 01                	push   $0x1
  801e61:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e64:	50                   	push   %eax
  801e65:	e8 d2 ed ff ff       	call   800c3c <sys_cputs>
}
  801e6a:	83 c4 10             	add    $0x10,%esp
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <getchar>:

int
getchar(void)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e75:	6a 01                	push   $0x1
  801e77:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7a:	50                   	push   %eax
  801e7b:	6a 00                	push   $0x0
  801e7d:	e8 3b f6 ff ff       	call   8014bd <read>
	if (r < 0)
  801e82:	83 c4 10             	add    $0x10,%esp
  801e85:	85 c0                	test   %eax,%eax
  801e87:	78 0f                	js     801e98 <getchar+0x29>
		return r;
	if (r < 1)
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	7e 06                	jle    801e93 <getchar+0x24>
		return -E_EOF;
	return c;
  801e8d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e91:	eb 05                	jmp    801e98 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e93:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e98:	c9                   	leave  
  801e99:	c3                   	ret    

00801e9a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e9a:	55                   	push   %ebp
  801e9b:	89 e5                	mov    %esp,%ebp
  801e9d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea3:	50                   	push   %eax
  801ea4:	ff 75 08             	pushl  0x8(%ebp)
  801ea7:	e8 ab f3 ff ff       	call   801257 <fd_lookup>
  801eac:	83 c4 10             	add    $0x10,%esp
  801eaf:	85 c0                	test   %eax,%eax
  801eb1:	78 11                	js     801ec4 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ebc:	39 10                	cmp    %edx,(%eax)
  801ebe:	0f 94 c0             	sete   %al
  801ec1:	0f b6 c0             	movzbl %al,%eax
}
  801ec4:	c9                   	leave  
  801ec5:	c3                   	ret    

00801ec6 <opencons>:

int
opencons(void)
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ecc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecf:	50                   	push   %eax
  801ed0:	e8 33 f3 ff ff       	call   801208 <fd_alloc>
  801ed5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ed8:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801eda:	85 c0                	test   %eax,%eax
  801edc:	78 3e                	js     801f1c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ede:	83 ec 04             	sub    $0x4,%esp
  801ee1:	68 07 04 00 00       	push   $0x407
  801ee6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee9:	6a 00                	push   $0x0
  801eeb:	e8 08 ee ff ff       	call   800cf8 <sys_page_alloc>
  801ef0:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef3:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef5:	85 c0                	test   %eax,%eax
  801ef7:	78 23                	js     801f1c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ef9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801eff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f02:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f04:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f07:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f0e:	83 ec 0c             	sub    $0xc,%esp
  801f11:	50                   	push   %eax
  801f12:	e8 ca f2 ff ff       	call   8011e1 <fd2num>
  801f17:	89 c2                	mov    %eax,%edx
  801f19:	83 c4 10             	add    $0x10,%esp
}
  801f1c:	89 d0                	mov    %edx,%eax
  801f1e:	c9                   	leave  
  801f1f:	c3                   	ret    

00801f20 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f20:	55                   	push   %ebp
  801f21:	89 e5                	mov    %esp,%ebp
  801f23:	53                   	push   %ebx
  801f24:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801f27:	e8 8e ed ff ff       	call   800cba <sys_getenvid>
  801f2c:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801f2e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f35:	75 29                	jne    801f60 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801f37:	83 ec 04             	sub    $0x4,%esp
  801f3a:	6a 07                	push   $0x7
  801f3c:	68 00 f0 bf ee       	push   $0xeebff000
  801f41:	50                   	push   %eax
  801f42:	e8 b1 ed ff ff       	call   800cf8 <sys_page_alloc>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	79 12                	jns    801f60 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801f4e:	50                   	push   %eax
  801f4f:	68 00 2a 80 00       	push   $0x802a00
  801f54:	6a 24                	push   $0x24
  801f56:	68 19 2a 80 00       	push   $0x802a19
  801f5b:	e8 b8 e2 ff ff       	call   800218 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801f60:	8b 45 08             	mov    0x8(%ebp),%eax
  801f63:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801f68:	83 ec 08             	sub    $0x8,%esp
  801f6b:	68 94 1f 80 00       	push   $0x801f94
  801f70:	53                   	push   %ebx
  801f71:	e8 cd ee ff ff       	call   800e43 <sys_env_set_pgfault_upcall>
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	79 12                	jns    801f8f <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801f7d:	50                   	push   %eax
  801f7e:	68 00 2a 80 00       	push   $0x802a00
  801f83:	6a 2e                	push   $0x2e
  801f85:	68 19 2a 80 00       	push   $0x802a19
  801f8a:	e8 89 e2 ff ff       	call   800218 <_panic>
}
  801f8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f92:	c9                   	leave  
  801f93:	c3                   	ret    

00801f94 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f94:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f95:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f9a:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f9c:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801f9f:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801fa3:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  801fa6:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801faa:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801fac:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801fb0:	83 c4 08             	add    $0x8,%esp
	popal
  801fb3:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801fb4:	83 c4 04             	add    $0x4,%esp
	popfl
  801fb7:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  801fb8:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801fb9:	c3                   	ret    

00801fba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	57                   	push   %edi
  801fbe:	56                   	push   %esi
  801fbf:	53                   	push   %ebx
  801fc0:	83 ec 0c             	sub    $0xc,%esp
  801fc3:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801fcc:	85 f6                	test   %esi,%esi
  801fce:	74 06                	je     801fd6 <ipc_recv+0x1c>
		*from_env_store = 0;
  801fd0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801fd6:	85 db                	test   %ebx,%ebx
  801fd8:	74 06                	je     801fe0 <ipc_recv+0x26>
		*perm_store = 0;
  801fda:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801fe0:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801fe2:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801fe7:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801fea:	83 ec 0c             	sub    $0xc,%esp
  801fed:	50                   	push   %eax
  801fee:	e8 b5 ee ff ff       	call   800ea8 <sys_ipc_recv>
  801ff3:	89 c7                	mov    %eax,%edi
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	85 c0                	test   %eax,%eax
  801ffa:	79 14                	jns    802010 <ipc_recv+0x56>
		cprintf("im dead");
  801ffc:	83 ec 0c             	sub    $0xc,%esp
  801fff:	68 27 2a 80 00       	push   $0x802a27
  802004:	e8 e8 e2 ff ff       	call   8002f1 <cprintf>
		return r;
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	89 f8                	mov    %edi,%eax
  80200e:	eb 24                	jmp    802034 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  802010:	85 f6                	test   %esi,%esi
  802012:	74 0a                	je     80201e <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  802014:	a1 20 44 80 00       	mov    0x804420,%eax
  802019:	8b 40 74             	mov    0x74(%eax),%eax
  80201c:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  80201e:	85 db                	test   %ebx,%ebx
  802020:	74 0a                	je     80202c <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  802022:	a1 20 44 80 00       	mov    0x804420,%eax
  802027:	8b 40 78             	mov    0x78(%eax),%eax
  80202a:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  80202c:	a1 20 44 80 00       	mov    0x804420,%eax
  802031:	8b 40 70             	mov    0x70(%eax),%eax
}
  802034:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802037:	5b                   	pop    %ebx
  802038:	5e                   	pop    %esi
  802039:	5f                   	pop    %edi
  80203a:	5d                   	pop    %ebp
  80203b:	c3                   	ret    

0080203c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	57                   	push   %edi
  802040:	56                   	push   %esi
  802041:	53                   	push   %ebx
  802042:	83 ec 0c             	sub    $0xc,%esp
  802045:	8b 7d 08             	mov    0x8(%ebp),%edi
  802048:	8b 75 0c             	mov    0xc(%ebp),%esi
  80204b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  80204e:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  802050:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802055:	0f 44 d8             	cmove  %eax,%ebx
  802058:	eb 1c                	jmp    802076 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  80205a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80205d:	74 12                	je     802071 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  80205f:	50                   	push   %eax
  802060:	68 2f 2a 80 00       	push   $0x802a2f
  802065:	6a 4e                	push   $0x4e
  802067:	68 3c 2a 80 00       	push   $0x802a3c
  80206c:	e8 a7 e1 ff ff       	call   800218 <_panic>
		sys_yield();
  802071:	e8 63 ec ff ff       	call   800cd9 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802076:	ff 75 14             	pushl  0x14(%ebp)
  802079:	53                   	push   %ebx
  80207a:	56                   	push   %esi
  80207b:	57                   	push   %edi
  80207c:	e8 04 ee ff ff       	call   800e85 <sys_ipc_try_send>
  802081:	83 c4 10             	add    $0x10,%esp
  802084:	85 c0                	test   %eax,%eax
  802086:	78 d2                	js     80205a <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  802088:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208b:	5b                   	pop    %ebx
  80208c:	5e                   	pop    %esi
  80208d:	5f                   	pop    %edi
  80208e:	5d                   	pop    %ebp
  80208f:	c3                   	ret    

00802090 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802090:	55                   	push   %ebp
  802091:	89 e5                	mov    %esp,%ebp
  802093:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802096:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80209b:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80209e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020a4:	8b 52 50             	mov    0x50(%edx),%edx
  8020a7:	39 ca                	cmp    %ecx,%edx
  8020a9:	75 0d                	jne    8020b8 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020ab:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020b3:	8b 40 48             	mov    0x48(%eax),%eax
  8020b6:	eb 0f                	jmp    8020c7 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020b8:	83 c0 01             	add    $0x1,%eax
  8020bb:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020c0:	75 d9                	jne    80209b <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    

008020c9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020cf:	89 d0                	mov    %edx,%eax
  8020d1:	c1 e8 16             	shr    $0x16,%eax
  8020d4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020db:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e0:	f6 c1 01             	test   $0x1,%cl
  8020e3:	74 1d                	je     802102 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020e5:	c1 ea 0c             	shr    $0xc,%edx
  8020e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020ef:	f6 c2 01             	test   $0x1,%dl
  8020f2:	74 0e                	je     802102 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020f4:	c1 ea 0c             	shr    $0xc,%edx
  8020f7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020fe:	ef 
  8020ff:	0f b7 c0             	movzwl %ax,%eax
}
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	83 ec 1c             	sub    $0x1c,%esp
  802117:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80211b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80211f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802123:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802127:	85 f6                	test   %esi,%esi
  802129:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80212d:	89 ca                	mov    %ecx,%edx
  80212f:	89 f8                	mov    %edi,%eax
  802131:	75 3d                	jne    802170 <__udivdi3+0x60>
  802133:	39 cf                	cmp    %ecx,%edi
  802135:	0f 87 c5 00 00 00    	ja     802200 <__udivdi3+0xf0>
  80213b:	85 ff                	test   %edi,%edi
  80213d:	89 fd                	mov    %edi,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f7                	div    %edi
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 c8                	mov    %ecx,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c1                	mov    %eax,%ecx
  802154:	89 d8                	mov    %ebx,%eax
  802156:	89 cf                	mov    %ecx,%edi
  802158:	f7 f5                	div    %ebp
  80215a:	89 c3                	mov    %eax,%ebx
  80215c:	89 d8                	mov    %ebx,%eax
  80215e:	89 fa                	mov    %edi,%edx
  802160:	83 c4 1c             	add    $0x1c,%esp
  802163:	5b                   	pop    %ebx
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
  802168:	90                   	nop
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	39 ce                	cmp    %ecx,%esi
  802172:	77 74                	ja     8021e8 <__udivdi3+0xd8>
  802174:	0f bd fe             	bsr    %esi,%edi
  802177:	83 f7 1f             	xor    $0x1f,%edi
  80217a:	0f 84 98 00 00 00    	je     802218 <__udivdi3+0x108>
  802180:	bb 20 00 00 00       	mov    $0x20,%ebx
  802185:	89 f9                	mov    %edi,%ecx
  802187:	89 c5                	mov    %eax,%ebp
  802189:	29 fb                	sub    %edi,%ebx
  80218b:	d3 e6                	shl    %cl,%esi
  80218d:	89 d9                	mov    %ebx,%ecx
  80218f:	d3 ed                	shr    %cl,%ebp
  802191:	89 f9                	mov    %edi,%ecx
  802193:	d3 e0                	shl    %cl,%eax
  802195:	09 ee                	or     %ebp,%esi
  802197:	89 d9                	mov    %ebx,%ecx
  802199:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219d:	89 d5                	mov    %edx,%ebp
  80219f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021a3:	d3 ed                	shr    %cl,%ebp
  8021a5:	89 f9                	mov    %edi,%ecx
  8021a7:	d3 e2                	shl    %cl,%edx
  8021a9:	89 d9                	mov    %ebx,%ecx
  8021ab:	d3 e8                	shr    %cl,%eax
  8021ad:	09 c2                	or     %eax,%edx
  8021af:	89 d0                	mov    %edx,%eax
  8021b1:	89 ea                	mov    %ebp,%edx
  8021b3:	f7 f6                	div    %esi
  8021b5:	89 d5                	mov    %edx,%ebp
  8021b7:	89 c3                	mov    %eax,%ebx
  8021b9:	f7 64 24 0c          	mull   0xc(%esp)
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	72 10                	jb     8021d1 <__udivdi3+0xc1>
  8021c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021c5:	89 f9                	mov    %edi,%ecx
  8021c7:	d3 e6                	shl    %cl,%esi
  8021c9:	39 c6                	cmp    %eax,%esi
  8021cb:	73 07                	jae    8021d4 <__udivdi3+0xc4>
  8021cd:	39 d5                	cmp    %edx,%ebp
  8021cf:	75 03                	jne    8021d4 <__udivdi3+0xc4>
  8021d1:	83 eb 01             	sub    $0x1,%ebx
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 d8                	mov    %ebx,%eax
  8021d8:	89 fa                	mov    %edi,%edx
  8021da:	83 c4 1c             	add    $0x1c,%esp
  8021dd:	5b                   	pop    %ebx
  8021de:	5e                   	pop    %esi
  8021df:	5f                   	pop    %edi
  8021e0:	5d                   	pop    %ebp
  8021e1:	c3                   	ret    
  8021e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e8:	31 ff                	xor    %edi,%edi
  8021ea:	31 db                	xor    %ebx,%ebx
  8021ec:	89 d8                	mov    %ebx,%eax
  8021ee:	89 fa                	mov    %edi,%edx
  8021f0:	83 c4 1c             	add    $0x1c,%esp
  8021f3:	5b                   	pop    %ebx
  8021f4:	5e                   	pop    %esi
  8021f5:	5f                   	pop    %edi
  8021f6:	5d                   	pop    %ebp
  8021f7:	c3                   	ret    
  8021f8:	90                   	nop
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d8                	mov    %ebx,%eax
  802202:	f7 f7                	div    %edi
  802204:	31 ff                	xor    %edi,%edi
  802206:	89 c3                	mov    %eax,%ebx
  802208:	89 d8                	mov    %ebx,%eax
  80220a:	89 fa                	mov    %edi,%edx
  80220c:	83 c4 1c             	add    $0x1c,%esp
  80220f:	5b                   	pop    %ebx
  802210:	5e                   	pop    %esi
  802211:	5f                   	pop    %edi
  802212:	5d                   	pop    %ebp
  802213:	c3                   	ret    
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	39 ce                	cmp    %ecx,%esi
  80221a:	72 0c                	jb     802228 <__udivdi3+0x118>
  80221c:	31 db                	xor    %ebx,%ebx
  80221e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802222:	0f 87 34 ff ff ff    	ja     80215c <__udivdi3+0x4c>
  802228:	bb 01 00 00 00       	mov    $0x1,%ebx
  80222d:	e9 2a ff ff ff       	jmp    80215c <__udivdi3+0x4c>
  802232:	66 90                	xchg   %ax,%ax
  802234:	66 90                	xchg   %ax,%ax
  802236:	66 90                	xchg   %ax,%ax
  802238:	66 90                	xchg   %ax,%ax
  80223a:	66 90                	xchg   %ax,%ax
  80223c:	66 90                	xchg   %ax,%ax
  80223e:	66 90                	xchg   %ax,%ax

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	53                   	push   %ebx
  802244:	83 ec 1c             	sub    $0x1c,%esp
  802247:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80224b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802253:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802257:	85 d2                	test   %edx,%edx
  802259:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80225d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802261:	89 f3                	mov    %esi,%ebx
  802263:	89 3c 24             	mov    %edi,(%esp)
  802266:	89 74 24 04          	mov    %esi,0x4(%esp)
  80226a:	75 1c                	jne    802288 <__umoddi3+0x48>
  80226c:	39 f7                	cmp    %esi,%edi
  80226e:	76 50                	jbe    8022c0 <__umoddi3+0x80>
  802270:	89 c8                	mov    %ecx,%eax
  802272:	89 f2                	mov    %esi,%edx
  802274:	f7 f7                	div    %edi
  802276:	89 d0                	mov    %edx,%eax
  802278:	31 d2                	xor    %edx,%edx
  80227a:	83 c4 1c             	add    $0x1c,%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5f                   	pop    %edi
  802280:	5d                   	pop    %ebp
  802281:	c3                   	ret    
  802282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802288:	39 f2                	cmp    %esi,%edx
  80228a:	89 d0                	mov    %edx,%eax
  80228c:	77 52                	ja     8022e0 <__umoddi3+0xa0>
  80228e:	0f bd ea             	bsr    %edx,%ebp
  802291:	83 f5 1f             	xor    $0x1f,%ebp
  802294:	75 5a                	jne    8022f0 <__umoddi3+0xb0>
  802296:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80229a:	0f 82 e0 00 00 00    	jb     802380 <__umoddi3+0x140>
  8022a0:	39 0c 24             	cmp    %ecx,(%esp)
  8022a3:	0f 86 d7 00 00 00    	jbe    802380 <__umoddi3+0x140>
  8022a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8022ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022b1:	83 c4 1c             	add    $0x1c,%esp
  8022b4:	5b                   	pop    %ebx
  8022b5:	5e                   	pop    %esi
  8022b6:	5f                   	pop    %edi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    
  8022b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	85 ff                	test   %edi,%edi
  8022c2:	89 fd                	mov    %edi,%ebp
  8022c4:	75 0b                	jne    8022d1 <__umoddi3+0x91>
  8022c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022cb:	31 d2                	xor    %edx,%edx
  8022cd:	f7 f7                	div    %edi
  8022cf:	89 c5                	mov    %eax,%ebp
  8022d1:	89 f0                	mov    %esi,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f5                	div    %ebp
  8022d7:	89 c8                	mov    %ecx,%eax
  8022d9:	f7 f5                	div    %ebp
  8022db:	89 d0                	mov    %edx,%eax
  8022dd:	eb 99                	jmp    802278 <__umoddi3+0x38>
  8022df:	90                   	nop
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	83 c4 1c             	add    $0x1c,%esp
  8022e7:	5b                   	pop    %ebx
  8022e8:	5e                   	pop    %esi
  8022e9:	5f                   	pop    %edi
  8022ea:	5d                   	pop    %ebp
  8022eb:	c3                   	ret    
  8022ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f0:	8b 34 24             	mov    (%esp),%esi
  8022f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022f8:	89 e9                	mov    %ebp,%ecx
  8022fa:	29 ef                	sub    %ebp,%edi
  8022fc:	d3 e0                	shl    %cl,%eax
  8022fe:	89 f9                	mov    %edi,%ecx
  802300:	89 f2                	mov    %esi,%edx
  802302:	d3 ea                	shr    %cl,%edx
  802304:	89 e9                	mov    %ebp,%ecx
  802306:	09 c2                	or     %eax,%edx
  802308:	89 d8                	mov    %ebx,%eax
  80230a:	89 14 24             	mov    %edx,(%esp)
  80230d:	89 f2                	mov    %esi,%edx
  80230f:	d3 e2                	shl    %cl,%edx
  802311:	89 f9                	mov    %edi,%ecx
  802313:	89 54 24 04          	mov    %edx,0x4(%esp)
  802317:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80231b:	d3 e8                	shr    %cl,%eax
  80231d:	89 e9                	mov    %ebp,%ecx
  80231f:	89 c6                	mov    %eax,%esi
  802321:	d3 e3                	shl    %cl,%ebx
  802323:	89 f9                	mov    %edi,%ecx
  802325:	89 d0                	mov    %edx,%eax
  802327:	d3 e8                	shr    %cl,%eax
  802329:	89 e9                	mov    %ebp,%ecx
  80232b:	09 d8                	or     %ebx,%eax
  80232d:	89 d3                	mov    %edx,%ebx
  80232f:	89 f2                	mov    %esi,%edx
  802331:	f7 34 24             	divl   (%esp)
  802334:	89 d6                	mov    %edx,%esi
  802336:	d3 e3                	shl    %cl,%ebx
  802338:	f7 64 24 04          	mull   0x4(%esp)
  80233c:	39 d6                	cmp    %edx,%esi
  80233e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802342:	89 d1                	mov    %edx,%ecx
  802344:	89 c3                	mov    %eax,%ebx
  802346:	72 08                	jb     802350 <__umoddi3+0x110>
  802348:	75 11                	jne    80235b <__umoddi3+0x11b>
  80234a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80234e:	73 0b                	jae    80235b <__umoddi3+0x11b>
  802350:	2b 44 24 04          	sub    0x4(%esp),%eax
  802354:	1b 14 24             	sbb    (%esp),%edx
  802357:	89 d1                	mov    %edx,%ecx
  802359:	89 c3                	mov    %eax,%ebx
  80235b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80235f:	29 da                	sub    %ebx,%edx
  802361:	19 ce                	sbb    %ecx,%esi
  802363:	89 f9                	mov    %edi,%ecx
  802365:	89 f0                	mov    %esi,%eax
  802367:	d3 e0                	shl    %cl,%eax
  802369:	89 e9                	mov    %ebp,%ecx
  80236b:	d3 ea                	shr    %cl,%edx
  80236d:	89 e9                	mov    %ebp,%ecx
  80236f:	d3 ee                	shr    %cl,%esi
  802371:	09 d0                	or     %edx,%eax
  802373:	89 f2                	mov    %esi,%edx
  802375:	83 c4 1c             	add    $0x1c,%esp
  802378:	5b                   	pop    %ebx
  802379:	5e                   	pop    %esi
  80237a:	5f                   	pop    %edi
  80237b:	5d                   	pop    %ebp
  80237c:	c3                   	ret    
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	29 f9                	sub    %edi,%ecx
  802382:	19 d6                	sbb    %edx,%esi
  802384:	89 74 24 04          	mov    %esi,0x4(%esp)
  802388:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80238c:	e9 18 ff ff ff       	jmp    8022a9 <__umoddi3+0x69>
