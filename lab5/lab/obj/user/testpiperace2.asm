
obj/user/testpiperace2.debug:     file format elf32-i386


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
  80002c:	e8 a5 01 00 00       	call   8001d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 38             	sub    $0x38,%esp
	int p[2], r, i;
	struct Fd *fd;
	const volatile struct Env *kid;

	cprintf("testing for pipeisclosed race...\n");
  80003c:	68 80 23 80 00       	push   $0x802380
  800041:	e8 c9 02 00 00       	call   80030f <cprintf>
	if ((r = pipe(p)) < 0)
  800046:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800049:	89 04 24             	mov    %eax,(%esp)
  80004c:	e8 95 1b 00 00       	call   801be6 <pipe>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	85 c0                	test   %eax,%eax
  800056:	79 12                	jns    80006a <umain+0x37>
		panic("pipe: %e", r);
  800058:	50                   	push   %eax
  800059:	68 ce 23 80 00       	push   $0x8023ce
  80005e:	6a 0d                	push   $0xd
  800060:	68 d7 23 80 00       	push   $0x8023d7
  800065:	e8 cc 01 00 00       	call   800236 <_panic>
	if ((r = fork()) < 0)
  80006a:	e8 92 0f 00 00       	call   801001 <fork>
  80006f:	89 c6                	mov    %eax,%esi
  800071:	85 c0                	test   %eax,%eax
  800073:	79 12                	jns    800087 <umain+0x54>
		panic("fork: %e", r);
  800075:	50                   	push   %eax
  800076:	68 ec 23 80 00       	push   $0x8023ec
  80007b:	6a 0f                	push   $0xf
  80007d:	68 d7 23 80 00       	push   $0x8023d7
  800082:	e8 af 01 00 00       	call   800236 <_panic>
	if (r == 0) {
  800087:	85 c0                	test   %eax,%eax
  800089:	75 76                	jne    800101 <umain+0xce>
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800091:	e8 09 13 00 00       	call   80139f <close>
  800096:	83 c4 10             	add    $0x10,%esp
		for (i = 0; i < 200; i++) {
  800099:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (i % 10 == 0)
  80009e:	bf 67 66 66 66       	mov    $0x66666667,%edi
  8000a3:	89 d8                	mov    %ebx,%eax
  8000a5:	f7 ef                	imul   %edi
  8000a7:	c1 fa 02             	sar    $0x2,%edx
  8000aa:	89 d8                	mov    %ebx,%eax
  8000ac:	c1 f8 1f             	sar    $0x1f,%eax
  8000af:	29 c2                	sub    %eax,%edx
  8000b1:	8d 04 92             	lea    (%edx,%edx,4),%eax
  8000b4:	01 c0                	add    %eax,%eax
  8000b6:	39 c3                	cmp    %eax,%ebx
  8000b8:	75 11                	jne    8000cb <umain+0x98>
				cprintf("%d.", i);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	53                   	push   %ebx
  8000be:	68 f5 23 80 00       	push   $0x8023f5
  8000c3:	e8 47 02 00 00       	call   80030f <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
			// dup, then close.  yield so that other guy will
			// see us while we're between them.
			dup(p[0], 10);
  8000cb:	83 ec 08             	sub    $0x8,%esp
  8000ce:	6a 0a                	push   $0xa
  8000d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000d3:	e8 17 13 00 00       	call   8013ef <dup>
			sys_yield();
  8000d8:	e8 1a 0c 00 00       	call   800cf7 <sys_yield>
			close(10);
  8000dd:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  8000e4:	e8 b6 12 00 00       	call   80139f <close>
			sys_yield();
  8000e9:	e8 09 0c 00 00       	call   800cf7 <sys_yield>
	if (r == 0) {
		// child just dups and closes repeatedly,
		// yielding so the parent can see
		// the fd state between the two.
		close(p[1]);
		for (i = 0; i < 200; i++) {
  8000ee:	83 c3 01             	add    $0x1,%ebx
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	81 fb c8 00 00 00    	cmp    $0xc8,%ebx
  8000fa:	75 a7                	jne    8000a3 <umain+0x70>
			dup(p[0], 10);
			sys_yield();
			close(10);
			sys_yield();
		}
		exit();
  8000fc:	e8 1b 01 00 00       	call   80021c <exit>
	// pageref(p[0]) and gets 3, then it will return true when
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
  800101:	89 f0                	mov    %esi,%eax
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
	while (kid->env_status == ENV_RUNNABLE)
  800108:	8d 3c 85 00 00 00 00 	lea    0x0(,%eax,4),%edi
  80010f:	c1 e0 07             	shl    $0x7,%eax
  800112:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800115:	eb 2f                	jmp    800146 <umain+0x113>
		if (pipeisclosed(p[0]) != 0) {
  800117:	83 ec 0c             	sub    $0xc,%esp
  80011a:	ff 75 e0             	pushl  -0x20(%ebp)
  80011d:	e8 17 1c 00 00       	call   801d39 <pipeisclosed>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	74 28                	je     800151 <umain+0x11e>
			cprintf("\nRACE: pipe appears closed\n");
  800129:	83 ec 0c             	sub    $0xc,%esp
  80012c:	68 f9 23 80 00       	push   $0x8023f9
  800131:	e8 d9 01 00 00       	call   80030f <cprintf>
			sys_env_destroy(r);
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 59 0b 00 00       	call   800c97 <sys_env_destroy>
			exit();
  80013e:	e8 d9 00 00 00       	call   80021c <exit>
  800143:	83 c4 10             	add    $0x10,%esp
	// it shouldn't.
	//
	// So either way, pipeisclosed is going give a wrong answer.
	//
	kid = &envs[ENVX(r)];
	while (kid->env_status == ENV_RUNNABLE)
  800146:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800149:	29 fb                	sub    %edi,%ebx
  80014b:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  800151:	8b 43 54             	mov    0x54(%ebx),%eax
  800154:	83 f8 02             	cmp    $0x2,%eax
  800157:	74 be                	je     800117 <umain+0xe4>
		if (pipeisclosed(p[0]) != 0) {
			cprintf("\nRACE: pipe appears closed\n");
			sys_env_destroy(r);
			exit();
		}
	cprintf("child done with loop\n");
  800159:	83 ec 0c             	sub    $0xc,%esp
  80015c:	68 15 24 80 00       	push   $0x802415
  800161:	e8 a9 01 00 00       	call   80030f <cprintf>
	if (pipeisclosed(p[0]))
  800166:	83 c4 04             	add    $0x4,%esp
  800169:	ff 75 e0             	pushl  -0x20(%ebp)
  80016c:	e8 c8 1b 00 00       	call   801d39 <pipeisclosed>
  800171:	83 c4 10             	add    $0x10,%esp
  800174:	85 c0                	test   %eax,%eax
  800176:	74 14                	je     80018c <umain+0x159>
		panic("somehow the other end of p[0] got closed!");
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	68 a4 23 80 00       	push   $0x8023a4
  800180:	6a 40                	push   $0x40
  800182:	68 d7 23 80 00       	push   $0x8023d7
  800187:	e8 aa 00 00 00       	call   800236 <_panic>
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80018c:	83 ec 08             	sub    $0x8,%esp
  80018f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  800192:	50                   	push   %eax
  800193:	ff 75 e0             	pushl  -0x20(%ebp)
  800196:	e8 da 10 00 00       	call   801275 <fd_lookup>
  80019b:	83 c4 10             	add    $0x10,%esp
  80019e:	85 c0                	test   %eax,%eax
  8001a0:	79 12                	jns    8001b4 <umain+0x181>
		panic("cannot look up p[0]: %e", r);
  8001a2:	50                   	push   %eax
  8001a3:	68 2b 24 80 00       	push   $0x80242b
  8001a8:	6a 42                	push   $0x42
  8001aa:	68 d7 23 80 00       	push   $0x8023d7
  8001af:	e8 82 00 00 00       	call   800236 <_panic>
	(void) fd2data(fd);
  8001b4:	83 ec 0c             	sub    $0xc,%esp
  8001b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8001ba:	e8 50 10 00 00       	call   80120f <fd2data>
	cprintf("race didn't happen\n");
  8001bf:	c7 04 24 43 24 80 00 	movl   $0x802443,(%esp)
  8001c6:	e8 44 01 00 00       	call   80030f <cprintf>
}
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    

008001d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	56                   	push   %esi
  8001da:	53                   	push   %ebx
  8001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8001e1:	e8 f2 0a 00 00       	call   800cd8 <sys_getenvid>
  8001e6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001eb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001ee:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f3:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f8:	85 db                	test   %ebx,%ebx
  8001fa:	7e 07                	jle    800203 <libmain+0x2d>
		binaryname = argv[0];
  8001fc:	8b 06                	mov    (%esi),%eax
  8001fe:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	56                   	push   %esi
  800207:	53                   	push   %ebx
  800208:	e8 26 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80020d:	e8 0a 00 00 00       	call   80021c <exit>
}
  800212:	83 c4 10             	add    $0x10,%esp
  800215:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800222:	e8 a3 11 00 00       	call   8013ca <close_all>
	sys_env_destroy(0);
  800227:	83 ec 0c             	sub    $0xc,%esp
  80022a:	6a 00                	push   $0x0
  80022c:	e8 66 0a 00 00       	call   800c97 <sys_env_destroy>
}
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	c9                   	leave  
  800235:	c3                   	ret    

00800236 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	56                   	push   %esi
  80023a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80023b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800244:	e8 8f 0a 00 00       	call   800cd8 <sys_getenvid>
  800249:	83 ec 0c             	sub    $0xc,%esp
  80024c:	ff 75 0c             	pushl  0xc(%ebp)
  80024f:	ff 75 08             	pushl  0x8(%ebp)
  800252:	56                   	push   %esi
  800253:	50                   	push   %eax
  800254:	68 64 24 80 00       	push   $0x802464
  800259:	e8 b1 00 00 00       	call   80030f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025e:	83 c4 18             	add    $0x18,%esp
  800261:	53                   	push   %ebx
  800262:	ff 75 10             	pushl  0x10(%ebp)
  800265:	e8 54 00 00 00       	call   8002be <vcprintf>
	cprintf("\n");
  80026a:	c7 04 24 57 29 80 00 	movl   $0x802957,(%esp)
  800271:	e8 99 00 00 00       	call   80030f <cprintf>
  800276:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800279:	cc                   	int3   
  80027a:	eb fd                	jmp    800279 <_panic+0x43>

0080027c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	53                   	push   %ebx
  800280:	83 ec 04             	sub    $0x4,%esp
  800283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800286:	8b 13                	mov    (%ebx),%edx
  800288:	8d 42 01             	lea    0x1(%edx),%eax
  80028b:	89 03                	mov    %eax,(%ebx)
  80028d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800290:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800294:	3d ff 00 00 00       	cmp    $0xff,%eax
  800299:	75 1a                	jne    8002b5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80029b:	83 ec 08             	sub    $0x8,%esp
  80029e:	68 ff 00 00 00       	push   $0xff
  8002a3:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a6:	50                   	push   %eax
  8002a7:	e8 ae 09 00 00       	call   800c5a <sys_cputs>
		b->idx = 0;
  8002ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002bc:	c9                   	leave  
  8002bd:	c3                   	ret    

008002be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002ce:	00 00 00 
	b.cnt = 0;
  8002d1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002db:	ff 75 0c             	pushl  0xc(%ebp)
  8002de:	ff 75 08             	pushl  0x8(%ebp)
  8002e1:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e7:	50                   	push   %eax
  8002e8:	68 7c 02 80 00       	push   $0x80027c
  8002ed:	e8 1a 01 00 00       	call   80040c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002f2:	83 c4 08             	add    $0x8,%esp
  8002f5:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002fb:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800301:	50                   	push   %eax
  800302:	e8 53 09 00 00       	call   800c5a <sys_cputs>

	return b.cnt;
}
  800307:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800315:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800318:	50                   	push   %eax
  800319:	ff 75 08             	pushl  0x8(%ebp)
  80031c:	e8 9d ff ff ff       	call   8002be <vcprintf>
	va_end(ap);

	return cnt;
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 1c             	sub    $0x1c,%esp
  80032c:	89 c7                	mov    %eax,%edi
  80032e:	89 d6                	mov    %edx,%esi
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800339:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80033f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800344:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800347:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80034a:	39 d3                	cmp    %edx,%ebx
  80034c:	72 05                	jb     800353 <printnum+0x30>
  80034e:	39 45 10             	cmp    %eax,0x10(%ebp)
  800351:	77 45                	ja     800398 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	ff 75 18             	pushl  0x18(%ebp)
  800359:	8b 45 14             	mov    0x14(%ebp),%eax
  80035c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80035f:	53                   	push   %ebx
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	83 ec 08             	sub    $0x8,%esp
  800366:	ff 75 e4             	pushl  -0x1c(%ebp)
  800369:	ff 75 e0             	pushl  -0x20(%ebp)
  80036c:	ff 75 dc             	pushl  -0x24(%ebp)
  80036f:	ff 75 d8             	pushl  -0x28(%ebp)
  800372:	e8 69 1d 00 00       	call   8020e0 <__udivdi3>
  800377:	83 c4 18             	add    $0x18,%esp
  80037a:	52                   	push   %edx
  80037b:	50                   	push   %eax
  80037c:	89 f2                	mov    %esi,%edx
  80037e:	89 f8                	mov    %edi,%eax
  800380:	e8 9e ff ff ff       	call   800323 <printnum>
  800385:	83 c4 20             	add    $0x20,%esp
  800388:	eb 18                	jmp    8003a2 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80038a:	83 ec 08             	sub    $0x8,%esp
  80038d:	56                   	push   %esi
  80038e:	ff 75 18             	pushl  0x18(%ebp)
  800391:	ff d7                	call   *%edi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb 03                	jmp    80039b <printnum+0x78>
  800398:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80039b:	83 eb 01             	sub    $0x1,%ebx
  80039e:	85 db                	test   %ebx,%ebx
  8003a0:	7f e8                	jg     80038a <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003a2:	83 ec 08             	sub    $0x8,%esp
  8003a5:	56                   	push   %esi
  8003a6:	83 ec 04             	sub    $0x4,%esp
  8003a9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8003af:	ff 75 dc             	pushl  -0x24(%ebp)
  8003b2:	ff 75 d8             	pushl  -0x28(%ebp)
  8003b5:	e8 56 1e 00 00       	call   802210 <__umoddi3>
  8003ba:	83 c4 14             	add    $0x14,%esp
  8003bd:	0f be 80 87 24 80 00 	movsbl 0x802487(%eax),%eax
  8003c4:	50                   	push   %eax
  8003c5:	ff d7                	call   *%edi
}
  8003c7:	83 c4 10             	add    $0x10,%esp
  8003ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003cd:	5b                   	pop    %ebx
  8003ce:	5e                   	pop    %esi
  8003cf:	5f                   	pop    %edi
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003dc:	8b 10                	mov    (%eax),%edx
  8003de:	3b 50 04             	cmp    0x4(%eax),%edx
  8003e1:	73 0a                	jae    8003ed <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003e6:	89 08                	mov    %ecx,(%eax)
  8003e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003eb:	88 02                	mov    %al,(%edx)
}
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8003f5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003f8:	50                   	push   %eax
  8003f9:	ff 75 10             	pushl  0x10(%ebp)
  8003fc:	ff 75 0c             	pushl  0xc(%ebp)
  8003ff:	ff 75 08             	pushl  0x8(%ebp)
  800402:	e8 05 00 00 00       	call   80040c <vprintfmt>
	va_end(ap);
}
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	c9                   	leave  
  80040b:	c3                   	ret    

0080040c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	57                   	push   %edi
  800410:	56                   	push   %esi
  800411:	53                   	push   %ebx
  800412:	83 ec 2c             	sub    $0x2c,%esp
  800415:	8b 75 08             	mov    0x8(%ebp),%esi
  800418:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80041b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80041e:	eb 12                	jmp    800432 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800420:	85 c0                	test   %eax,%eax
  800422:	0f 84 42 04 00 00    	je     80086a <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	53                   	push   %ebx
  80042c:	50                   	push   %eax
  80042d:	ff d6                	call   *%esi
  80042f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800432:	83 c7 01             	add    $0x1,%edi
  800435:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800439:	83 f8 25             	cmp    $0x25,%eax
  80043c:	75 e2                	jne    800420 <vprintfmt+0x14>
  80043e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800442:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800449:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800450:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800457:	b9 00 00 00 00       	mov    $0x0,%ecx
  80045c:	eb 07                	jmp    800465 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800461:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800465:	8d 47 01             	lea    0x1(%edi),%eax
  800468:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80046b:	0f b6 07             	movzbl (%edi),%eax
  80046e:	0f b6 d0             	movzbl %al,%edx
  800471:	83 e8 23             	sub    $0x23,%eax
  800474:	3c 55                	cmp    $0x55,%al
  800476:	0f 87 d3 03 00 00    	ja     80084f <vprintfmt+0x443>
  80047c:	0f b6 c0             	movzbl %al,%eax
  80047f:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800489:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80048d:	eb d6                	jmp    800465 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80048f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800492:	b8 00 00 00 00       	mov    $0x0,%eax
  800497:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80049a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004a1:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a4:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a7:	83 f9 09             	cmp    $0x9,%ecx
  8004aa:	77 3f                	ja     8004eb <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004ac:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004af:	eb e9                	jmp    80049a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bc:	8d 40 04             	lea    0x4(%eax),%eax
  8004bf:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004c5:	eb 2a                	jmp    8004f1 <vprintfmt+0xe5>
  8004c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ca:	85 c0                	test   %eax,%eax
  8004cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d1:	0f 49 d0             	cmovns %eax,%edx
  8004d4:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004da:	eb 89                	jmp    800465 <vprintfmt+0x59>
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8004df:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8004e6:	e9 7a ff ff ff       	jmp    800465 <vprintfmt+0x59>
  8004eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004ee:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8004f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f5:	0f 89 6a ff ff ff    	jns    800465 <vprintfmt+0x59>
				width = precision, precision = -1;
  8004fb:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800501:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800508:	e9 58 ff ff ff       	jmp    800465 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80050d:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800510:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800513:	e9 4d ff ff ff       	jmp    800465 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 78 04             	lea    0x4(%eax),%edi
  80051e:	83 ec 08             	sub    $0x8,%esp
  800521:	53                   	push   %ebx
  800522:	ff 30                	pushl  (%eax)
  800524:	ff d6                	call   *%esi
			break;
  800526:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800529:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80052f:	e9 fe fe ff ff       	jmp    800432 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8d 78 04             	lea    0x4(%eax),%edi
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	99                   	cltd   
  80053d:	31 d0                	xor    %edx,%eax
  80053f:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800541:	83 f8 0f             	cmp    $0xf,%eax
  800544:	7f 0b                	jg     800551 <vprintfmt+0x145>
  800546:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  80054d:	85 d2                	test   %edx,%edx
  80054f:	75 1b                	jne    80056c <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800551:	50                   	push   %eax
  800552:	68 9f 24 80 00       	push   $0x80249f
  800557:	53                   	push   %ebx
  800558:	56                   	push   %esi
  800559:	e8 91 fe ff ff       	call   8003ef <printfmt>
  80055e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800561:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800564:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800567:	e9 c6 fe ff ff       	jmp    800432 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80056c:	52                   	push   %edx
  80056d:	68 25 29 80 00       	push   $0x802925
  800572:	53                   	push   %ebx
  800573:	56                   	push   %esi
  800574:	e8 76 fe ff ff       	call   8003ef <printfmt>
  800579:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80057c:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800582:	e9 ab fe ff ff       	jmp    800432 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800587:	8b 45 14             	mov    0x14(%ebp),%eax
  80058a:	83 c0 04             	add    $0x4,%eax
  80058d:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800595:	85 ff                	test   %edi,%edi
  800597:	b8 98 24 80 00       	mov    $0x802498,%eax
  80059c:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80059f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a3:	0f 8e 94 00 00 00    	jle    80063d <vprintfmt+0x231>
  8005a9:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005ad:	0f 84 98 00 00 00    	je     80064b <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005b3:	83 ec 08             	sub    $0x8,%esp
  8005b6:	ff 75 d0             	pushl  -0x30(%ebp)
  8005b9:	57                   	push   %edi
  8005ba:	e8 33 03 00 00       	call   8008f2 <strnlen>
  8005bf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c2:	29 c1                	sub    %eax,%ecx
  8005c4:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8005c7:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005ca:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d1:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005d4:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d6:	eb 0f                	jmp    8005e7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005d8:	83 ec 08             	sub    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005df:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e1:	83 ef 01             	sub    $0x1,%edi
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	85 ff                	test   %edi,%edi
  8005e9:	7f ed                	jg     8005d8 <vprintfmt+0x1cc>
  8005eb:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005ee:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005f8:	0f 49 c1             	cmovns %ecx,%eax
  8005fb:	29 c1                	sub    %eax,%ecx
  8005fd:	89 75 08             	mov    %esi,0x8(%ebp)
  800600:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800603:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800606:	89 cb                	mov    %ecx,%ebx
  800608:	eb 4d                	jmp    800657 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80060e:	74 1b                	je     80062b <vprintfmt+0x21f>
  800610:	0f be c0             	movsbl %al,%eax
  800613:	83 e8 20             	sub    $0x20,%eax
  800616:	83 f8 5e             	cmp    $0x5e,%eax
  800619:	76 10                	jbe    80062b <vprintfmt+0x21f>
					putch('?', putdat);
  80061b:	83 ec 08             	sub    $0x8,%esp
  80061e:	ff 75 0c             	pushl  0xc(%ebp)
  800621:	6a 3f                	push   $0x3f
  800623:	ff 55 08             	call   *0x8(%ebp)
  800626:	83 c4 10             	add    $0x10,%esp
  800629:	eb 0d                	jmp    800638 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80062b:	83 ec 08             	sub    $0x8,%esp
  80062e:	ff 75 0c             	pushl  0xc(%ebp)
  800631:	52                   	push   %edx
  800632:	ff 55 08             	call   *0x8(%ebp)
  800635:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800638:	83 eb 01             	sub    $0x1,%ebx
  80063b:	eb 1a                	jmp    800657 <vprintfmt+0x24b>
  80063d:	89 75 08             	mov    %esi,0x8(%ebp)
  800640:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800643:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800646:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800649:	eb 0c                	jmp    800657 <vprintfmt+0x24b>
  80064b:	89 75 08             	mov    %esi,0x8(%ebp)
  80064e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800651:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800654:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800657:	83 c7 01             	add    $0x1,%edi
  80065a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80065e:	0f be d0             	movsbl %al,%edx
  800661:	85 d2                	test   %edx,%edx
  800663:	74 23                	je     800688 <vprintfmt+0x27c>
  800665:	85 f6                	test   %esi,%esi
  800667:	78 a1                	js     80060a <vprintfmt+0x1fe>
  800669:	83 ee 01             	sub    $0x1,%esi
  80066c:	79 9c                	jns    80060a <vprintfmt+0x1fe>
  80066e:	89 df                	mov    %ebx,%edi
  800670:	8b 75 08             	mov    0x8(%ebp),%esi
  800673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800676:	eb 18                	jmp    800690 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800678:	83 ec 08             	sub    $0x8,%esp
  80067b:	53                   	push   %ebx
  80067c:	6a 20                	push   $0x20
  80067e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800680:	83 ef 01             	sub    $0x1,%edi
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	eb 08                	jmp    800690 <vprintfmt+0x284>
  800688:	89 df                	mov    %ebx,%edi
  80068a:	8b 75 08             	mov    0x8(%ebp),%esi
  80068d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800690:	85 ff                	test   %edi,%edi
  800692:	7f e4                	jg     800678 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800694:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80069a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069d:	e9 90 fd ff ff       	jmp    800432 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006a2:	83 f9 01             	cmp    $0x1,%ecx
  8006a5:	7e 19                	jle    8006c0 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8006a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006aa:	8b 50 04             	mov    0x4(%eax),%edx
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b8:	8d 40 08             	lea    0x8(%eax),%eax
  8006bb:	89 45 14             	mov    %eax,0x14(%ebp)
  8006be:	eb 38                	jmp    8006f8 <vprintfmt+0x2ec>
	else if (lflag)
  8006c0:	85 c9                	test   %ecx,%ecx
  8006c2:	74 1b                	je     8006df <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 00                	mov    (%eax),%eax
  8006c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006cc:	89 c1                	mov    %eax,%ecx
  8006ce:	c1 f9 1f             	sar    $0x1f,%ecx
  8006d1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
  8006dd:	eb 19                	jmp    8006f8 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8b 00                	mov    (%eax),%eax
  8006e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e7:	89 c1                	mov    %eax,%ecx
  8006e9:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006f8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006fb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800703:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800707:	0f 89 0e 01 00 00    	jns    80081b <vprintfmt+0x40f>
				putch('-', putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 2d                	push   $0x2d
  800713:	ff d6                	call   *%esi
				num = -(long long) num;
  800715:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800718:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071b:	f7 da                	neg    %edx
  80071d:	83 d1 00             	adc    $0x0,%ecx
  800720:	f7 d9                	neg    %ecx
  800722:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800725:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072a:	e9 ec 00 00 00       	jmp    80081b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80072f:	83 f9 01             	cmp    $0x1,%ecx
  800732:	7e 18                	jle    80074c <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 10                	mov    (%eax),%edx
  800739:	8b 48 04             	mov    0x4(%eax),%ecx
  80073c:	8d 40 08             	lea    0x8(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800742:	b8 0a 00 00 00       	mov    $0xa,%eax
  800747:	e9 cf 00 00 00       	jmp    80081b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80074c:	85 c9                	test   %ecx,%ecx
  80074e:	74 1a                	je     80076a <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8b 10                	mov    (%eax),%edx
  800755:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075a:	8d 40 04             	lea    0x4(%eax),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800760:	b8 0a 00 00 00       	mov    $0xa,%eax
  800765:	e9 b1 00 00 00       	jmp    80081b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80076a:	8b 45 14             	mov    0x14(%ebp),%eax
  80076d:	8b 10                	mov    (%eax),%edx
  80076f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800774:	8d 40 04             	lea    0x4(%eax),%eax
  800777:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80077a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80077f:	e9 97 00 00 00       	jmp    80081b <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800784:	83 ec 08             	sub    $0x8,%esp
  800787:	53                   	push   %ebx
  800788:	6a 58                	push   $0x58
  80078a:	ff d6                	call   *%esi
			putch('X', putdat);
  80078c:	83 c4 08             	add    $0x8,%esp
  80078f:	53                   	push   %ebx
  800790:	6a 58                	push   $0x58
  800792:	ff d6                	call   *%esi
			putch('X', putdat);
  800794:	83 c4 08             	add    $0x8,%esp
  800797:	53                   	push   %ebx
  800798:	6a 58                	push   $0x58
  80079a:	ff d6                	call   *%esi
			break;
  80079c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8007a2:	e9 8b fc ff ff       	jmp    800432 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	53                   	push   %ebx
  8007ab:	6a 30                	push   $0x30
  8007ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	53                   	push   %ebx
  8007b3:	6a 78                	push   $0x78
  8007b5:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ba:	8b 10                	mov    (%eax),%edx
  8007bc:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007c1:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8007c4:	8d 40 04             	lea    0x4(%eax),%eax
  8007c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007cf:	eb 4a                	jmp    80081b <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007d1:	83 f9 01             	cmp    $0x1,%ecx
  8007d4:	7e 15                	jle    8007eb <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8b 10                	mov    (%eax),%edx
  8007db:	8b 48 04             	mov    0x4(%eax),%ecx
  8007de:	8d 40 08             	lea    0x8(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007e4:	b8 10 00 00 00       	mov    $0x10,%eax
  8007e9:	eb 30                	jmp    80081b <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	74 17                	je     800806 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007ff:	b8 10 00 00 00       	mov    $0x10,%eax
  800804:	eb 15                	jmp    80081b <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8b 10                	mov    (%eax),%edx
  80080b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800810:	8d 40 04             	lea    0x4(%eax),%eax
  800813:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800816:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80081b:	83 ec 0c             	sub    $0xc,%esp
  80081e:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800822:	57                   	push   %edi
  800823:	ff 75 e0             	pushl  -0x20(%ebp)
  800826:	50                   	push   %eax
  800827:	51                   	push   %ecx
  800828:	52                   	push   %edx
  800829:	89 da                	mov    %ebx,%edx
  80082b:	89 f0                	mov    %esi,%eax
  80082d:	e8 f1 fa ff ff       	call   800323 <printnum>
			break;
  800832:	83 c4 20             	add    $0x20,%esp
  800835:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800838:	e9 f5 fb ff ff       	jmp    800432 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	53                   	push   %ebx
  800841:	52                   	push   %edx
  800842:	ff d6                	call   *%esi
			break;
  800844:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80084a:	e9 e3 fb ff ff       	jmp    800432 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 25                	push   $0x25
  800855:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800857:	83 c4 10             	add    $0x10,%esp
  80085a:	eb 03                	jmp    80085f <vprintfmt+0x453>
  80085c:	83 ef 01             	sub    $0x1,%edi
  80085f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800863:	75 f7                	jne    80085c <vprintfmt+0x450>
  800865:	e9 c8 fb ff ff       	jmp    800432 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80086a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80086d:	5b                   	pop    %ebx
  80086e:	5e                   	pop    %esi
  80086f:	5f                   	pop    %edi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	83 ec 18             	sub    $0x18,%esp
  800878:	8b 45 08             	mov    0x8(%ebp),%eax
  80087b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800881:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800885:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800888:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80088f:	85 c0                	test   %eax,%eax
  800891:	74 26                	je     8008b9 <vsnprintf+0x47>
  800893:	85 d2                	test   %edx,%edx
  800895:	7e 22                	jle    8008b9 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800897:	ff 75 14             	pushl  0x14(%ebp)
  80089a:	ff 75 10             	pushl  0x10(%ebp)
  80089d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008a0:	50                   	push   %eax
  8008a1:	68 d2 03 80 00       	push   $0x8003d2
  8008a6:	e8 61 fb ff ff       	call   80040c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	eb 05                	jmp    8008be <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008be:	c9                   	leave  
  8008bf:	c3                   	ret    

008008c0 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008c6:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008c9:	50                   	push   %eax
  8008ca:	ff 75 10             	pushl  0x10(%ebp)
  8008cd:	ff 75 0c             	pushl  0xc(%ebp)
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 9a ff ff ff       	call   800872 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008d8:	c9                   	leave  
  8008d9:	c3                   	ret    

008008da <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e5:	eb 03                	jmp    8008ea <strlen+0x10>
		n++;
  8008e7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ea:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008ee:	75 f7                	jne    8008e7 <strlen+0xd>
		n++;
	return n;
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fb:	ba 00 00 00 00       	mov    $0x0,%edx
  800900:	eb 03                	jmp    800905 <strnlen+0x13>
		n++;
  800902:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800905:	39 c2                	cmp    %eax,%edx
  800907:	74 08                	je     800911 <strnlen+0x1f>
  800909:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80090d:	75 f3                	jne    800902 <strnlen+0x10>
  80090f:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	53                   	push   %ebx
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80091d:	89 c2                	mov    %eax,%edx
  80091f:	83 c2 01             	add    $0x1,%edx
  800922:	83 c1 01             	add    $0x1,%ecx
  800925:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800929:	88 5a ff             	mov    %bl,-0x1(%edx)
  80092c:	84 db                	test   %bl,%bl
  80092e:	75 ef                	jne    80091f <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800930:	5b                   	pop    %ebx
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	53                   	push   %ebx
  800937:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80093a:	53                   	push   %ebx
  80093b:	e8 9a ff ff ff       	call   8008da <strlen>
  800940:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800943:	ff 75 0c             	pushl  0xc(%ebp)
  800946:	01 d8                	add    %ebx,%eax
  800948:	50                   	push   %eax
  800949:	e8 c5 ff ff ff       	call   800913 <strcpy>
	return dst;
}
  80094e:	89 d8                	mov    %ebx,%eax
  800950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 75 08             	mov    0x8(%ebp),%esi
  80095d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800960:	89 f3                	mov    %esi,%ebx
  800962:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800965:	89 f2                	mov    %esi,%edx
  800967:	eb 0f                	jmp    800978 <strncpy+0x23>
		*dst++ = *src;
  800969:	83 c2 01             	add    $0x1,%edx
  80096c:	0f b6 01             	movzbl (%ecx),%eax
  80096f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800972:	80 39 01             	cmpb   $0x1,(%ecx)
  800975:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800978:	39 da                	cmp    %ebx,%edx
  80097a:	75 ed                	jne    800969 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80097c:	89 f0                	mov    %esi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 75 08             	mov    0x8(%ebp),%esi
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	8b 55 10             	mov    0x10(%ebp),%edx
  800990:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800992:	85 d2                	test   %edx,%edx
  800994:	74 21                	je     8009b7 <strlcpy+0x35>
  800996:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80099a:	89 f2                	mov    %esi,%edx
  80099c:	eb 09                	jmp    8009a7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80099e:	83 c2 01             	add    $0x1,%edx
  8009a1:	83 c1 01             	add    $0x1,%ecx
  8009a4:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a7:	39 c2                	cmp    %eax,%edx
  8009a9:	74 09                	je     8009b4 <strlcpy+0x32>
  8009ab:	0f b6 19             	movzbl (%ecx),%ebx
  8009ae:	84 db                	test   %bl,%bl
  8009b0:	75 ec                	jne    80099e <strlcpy+0x1c>
  8009b2:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009b7:	29 f0                	sub    %esi,%eax
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c6:	eb 06                	jmp    8009ce <strcmp+0x11>
		p++, q++;
  8009c8:	83 c1 01             	add    $0x1,%ecx
  8009cb:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	84 c0                	test   %al,%al
  8009d3:	74 04                	je     8009d9 <strcmp+0x1c>
  8009d5:	3a 02                	cmp    (%edx),%al
  8009d7:	74 ef                	je     8009c8 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 12             	movzbl (%edx),%edx
  8009df:	29 d0                	sub    %edx,%eax
}
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ed:	89 c3                	mov    %eax,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f2:	eb 06                	jmp    8009fa <strncmp+0x17>
		n--, p++, q++;
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009fa:	39 d8                	cmp    %ebx,%eax
  8009fc:	74 15                	je     800a13 <strncmp+0x30>
  8009fe:	0f b6 08             	movzbl (%eax),%ecx
  800a01:	84 c9                	test   %cl,%cl
  800a03:	74 04                	je     800a09 <strncmp+0x26>
  800a05:	3a 0a                	cmp    (%edx),%cl
  800a07:	74 eb                	je     8009f4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a09:	0f b6 00             	movzbl (%eax),%eax
  800a0c:	0f b6 12             	movzbl (%edx),%edx
  800a0f:	29 d0                	sub    %edx,%eax
  800a11:	eb 05                	jmp    800a18 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a18:	5b                   	pop    %ebx
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a25:	eb 07                	jmp    800a2e <strchr+0x13>
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 0f                	je     800a3a <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2b:	83 c0 01             	add    $0x1,%eax
  800a2e:	0f b6 10             	movzbl (%eax),%edx
  800a31:	84 d2                	test   %dl,%dl
  800a33:	75 f2                	jne    800a27 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a35:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a46:	eb 03                	jmp    800a4b <strfind+0xf>
  800a48:	83 c0 01             	add    $0x1,%eax
  800a4b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a4e:	38 ca                	cmp    %cl,%dl
  800a50:	74 04                	je     800a56 <strfind+0x1a>
  800a52:	84 d2                	test   %dl,%dl
  800a54:	75 f2                	jne    800a48 <strfind+0xc>
			break;
	return (char *) s;
}
  800a56:	5d                   	pop    %ebp
  800a57:	c3                   	ret    

00800a58 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a58:	55                   	push   %ebp
  800a59:	89 e5                	mov    %esp,%ebp
  800a5b:	57                   	push   %edi
  800a5c:	56                   	push   %esi
  800a5d:	53                   	push   %ebx
  800a5e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a61:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a64:	85 c9                	test   %ecx,%ecx
  800a66:	74 36                	je     800a9e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a68:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6e:	75 28                	jne    800a98 <memset+0x40>
  800a70:	f6 c1 03             	test   $0x3,%cl
  800a73:	75 23                	jne    800a98 <memset+0x40>
		c &= 0xFF;
  800a75:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a79:	89 d3                	mov    %edx,%ebx
  800a7b:	c1 e3 08             	shl    $0x8,%ebx
  800a7e:	89 d6                	mov    %edx,%esi
  800a80:	c1 e6 18             	shl    $0x18,%esi
  800a83:	89 d0                	mov    %edx,%eax
  800a85:	c1 e0 10             	shl    $0x10,%eax
  800a88:	09 f0                	or     %esi,%eax
  800a8a:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a8c:	89 d8                	mov    %ebx,%eax
  800a8e:	09 d0                	or     %edx,%eax
  800a90:	c1 e9 02             	shr    $0x2,%ecx
  800a93:	fc                   	cld    
  800a94:	f3 ab                	rep stos %eax,%es:(%edi)
  800a96:	eb 06                	jmp    800a9e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9b:	fc                   	cld    
  800a9c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9e:	89 f8                	mov    %edi,%eax
  800aa0:	5b                   	pop    %ebx
  800aa1:	5e                   	pop    %esi
  800aa2:	5f                   	pop    %edi
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	57                   	push   %edi
  800aa9:	56                   	push   %esi
  800aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800aad:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ab0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab3:	39 c6                	cmp    %eax,%esi
  800ab5:	73 35                	jae    800aec <memmove+0x47>
  800ab7:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aba:	39 d0                	cmp    %edx,%eax
  800abc:	73 2e                	jae    800aec <memmove+0x47>
		s += n;
		d += n;
  800abe:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac1:	89 d6                	mov    %edx,%esi
  800ac3:	09 fe                	or     %edi,%esi
  800ac5:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800acb:	75 13                	jne    800ae0 <memmove+0x3b>
  800acd:	f6 c1 03             	test   $0x3,%cl
  800ad0:	75 0e                	jne    800ae0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800ad2:	83 ef 04             	sub    $0x4,%edi
  800ad5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad8:	c1 e9 02             	shr    $0x2,%ecx
  800adb:	fd                   	std    
  800adc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ade:	eb 09                	jmp    800ae9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ae0:	83 ef 01             	sub    $0x1,%edi
  800ae3:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ae6:	fd                   	std    
  800ae7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae9:	fc                   	cld    
  800aea:	eb 1d                	jmp    800b09 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aec:	89 f2                	mov    %esi,%edx
  800aee:	09 c2                	or     %eax,%edx
  800af0:	f6 c2 03             	test   $0x3,%dl
  800af3:	75 0f                	jne    800b04 <memmove+0x5f>
  800af5:	f6 c1 03             	test   $0x3,%cl
  800af8:	75 0a                	jne    800b04 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800afa:	c1 e9 02             	shr    $0x2,%ecx
  800afd:	89 c7                	mov    %eax,%edi
  800aff:	fc                   	cld    
  800b00:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b02:	eb 05                	jmp    800b09 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b09:	5e                   	pop    %esi
  800b0a:	5f                   	pop    %edi
  800b0b:	5d                   	pop    %ebp
  800b0c:	c3                   	ret    

00800b0d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b0d:	55                   	push   %ebp
  800b0e:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b10:	ff 75 10             	pushl  0x10(%ebp)
  800b13:	ff 75 0c             	pushl  0xc(%ebp)
  800b16:	ff 75 08             	pushl  0x8(%ebp)
  800b19:	e8 87 ff ff ff       	call   800aa5 <memmove>
}
  800b1e:	c9                   	leave  
  800b1f:	c3                   	ret    

00800b20 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	56                   	push   %esi
  800b24:	53                   	push   %ebx
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b2b:	89 c6                	mov    %eax,%esi
  800b2d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b30:	eb 1a                	jmp    800b4c <memcmp+0x2c>
		if (*s1 != *s2)
  800b32:	0f b6 08             	movzbl (%eax),%ecx
  800b35:	0f b6 1a             	movzbl (%edx),%ebx
  800b38:	38 d9                	cmp    %bl,%cl
  800b3a:	74 0a                	je     800b46 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b3c:	0f b6 c1             	movzbl %cl,%eax
  800b3f:	0f b6 db             	movzbl %bl,%ebx
  800b42:	29 d8                	sub    %ebx,%eax
  800b44:	eb 0f                	jmp    800b55 <memcmp+0x35>
		s1++, s2++;
  800b46:	83 c0 01             	add    $0x1,%eax
  800b49:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b4c:	39 f0                	cmp    %esi,%eax
  800b4e:	75 e2                	jne    800b32 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b50:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	53                   	push   %ebx
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b60:	89 c1                	mov    %eax,%ecx
  800b62:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b65:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b69:	eb 0a                	jmp    800b75 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6b:	0f b6 10             	movzbl (%eax),%edx
  800b6e:	39 da                	cmp    %ebx,%edx
  800b70:	74 07                	je     800b79 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	39 c8                	cmp    %ecx,%eax
  800b77:	72 f2                	jb     800b6b <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b79:	5b                   	pop    %ebx
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
  800b82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b88:	eb 03                	jmp    800b8d <strtol+0x11>
		s++;
  800b8a:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8d:	0f b6 01             	movzbl (%ecx),%eax
  800b90:	3c 20                	cmp    $0x20,%al
  800b92:	74 f6                	je     800b8a <strtol+0xe>
  800b94:	3c 09                	cmp    $0x9,%al
  800b96:	74 f2                	je     800b8a <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b98:	3c 2b                	cmp    $0x2b,%al
  800b9a:	75 0a                	jne    800ba6 <strtol+0x2a>
		s++;
  800b9c:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b9f:	bf 00 00 00 00       	mov    $0x0,%edi
  800ba4:	eb 11                	jmp    800bb7 <strtol+0x3b>
  800ba6:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bab:	3c 2d                	cmp    $0x2d,%al
  800bad:	75 08                	jne    800bb7 <strtol+0x3b>
		s++, neg = 1;
  800baf:	83 c1 01             	add    $0x1,%ecx
  800bb2:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb7:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bbd:	75 15                	jne    800bd4 <strtol+0x58>
  800bbf:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc2:	75 10                	jne    800bd4 <strtol+0x58>
  800bc4:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bc8:	75 7c                	jne    800c46 <strtol+0xca>
		s += 2, base = 16;
  800bca:	83 c1 02             	add    $0x2,%ecx
  800bcd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bd2:	eb 16                	jmp    800bea <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800bd4:	85 db                	test   %ebx,%ebx
  800bd6:	75 12                	jne    800bea <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bd8:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdd:	80 39 30             	cmpb   $0x30,(%ecx)
  800be0:	75 08                	jne    800bea <strtol+0x6e>
		s++, base = 8;
  800be2:	83 c1 01             	add    $0x1,%ecx
  800be5:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
  800bef:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf2:	0f b6 11             	movzbl (%ecx),%edx
  800bf5:	8d 72 d0             	lea    -0x30(%edx),%esi
  800bf8:	89 f3                	mov    %esi,%ebx
  800bfa:	80 fb 09             	cmp    $0x9,%bl
  800bfd:	77 08                	ja     800c07 <strtol+0x8b>
			dig = *s - '0';
  800bff:	0f be d2             	movsbl %dl,%edx
  800c02:	83 ea 30             	sub    $0x30,%edx
  800c05:	eb 22                	jmp    800c29 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c07:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c0a:	89 f3                	mov    %esi,%ebx
  800c0c:	80 fb 19             	cmp    $0x19,%bl
  800c0f:	77 08                	ja     800c19 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800c11:	0f be d2             	movsbl %dl,%edx
  800c14:	83 ea 57             	sub    $0x57,%edx
  800c17:	eb 10                	jmp    800c29 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800c19:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c1c:	89 f3                	mov    %esi,%ebx
  800c1e:	80 fb 19             	cmp    $0x19,%bl
  800c21:	77 16                	ja     800c39 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800c23:	0f be d2             	movsbl %dl,%edx
  800c26:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c29:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c2c:	7d 0b                	jge    800c39 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800c2e:	83 c1 01             	add    $0x1,%ecx
  800c31:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c35:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c37:	eb b9                	jmp    800bf2 <strtol+0x76>

	if (endptr)
  800c39:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3d:	74 0d                	je     800c4c <strtol+0xd0>
		*endptr = (char *) s;
  800c3f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c42:	89 0e                	mov    %ecx,(%esi)
  800c44:	eb 06                	jmp    800c4c <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c46:	85 db                	test   %ebx,%ebx
  800c48:	74 98                	je     800be2 <strtol+0x66>
  800c4a:	eb 9e                	jmp    800bea <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800c4c:	89 c2                	mov    %eax,%edx
  800c4e:	f7 da                	neg    %edx
  800c50:	85 ff                	test   %edi,%edi
  800c52:	0f 45 c2             	cmovne %edx,%eax
}
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800c60:	b8 00 00 00 00       	mov    $0x0,%eax
  800c65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c68:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6b:	89 c3                	mov    %eax,%ebx
  800c6d:	89 c7                	mov    %eax,%edi
  800c6f:	89 c6                	mov    %eax,%esi
  800c71:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c83:	b8 01 00 00 00       	mov    $0x1,%eax
  800c88:	89 d1                	mov    %edx,%ecx
  800c8a:	89 d3                	mov    %edx,%ebx
  800c8c:	89 d7                	mov    %edx,%edi
  800c8e:	89 d6                	mov    %edx,%esi
  800c90:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    

00800c97 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	57                   	push   %edi
  800c9b:	56                   	push   %esi
  800c9c:	53                   	push   %ebx
  800c9d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ca5:	b8 03 00 00 00       	mov    $0x3,%eax
  800caa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cad:	89 cb                	mov    %ecx,%ebx
  800caf:	89 cf                	mov    %ecx,%edi
  800cb1:	89 ce                	mov    %ecx,%esi
  800cb3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb5:	85 c0                	test   %eax,%eax
  800cb7:	7e 17                	jle    800cd0 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb9:	83 ec 0c             	sub    $0xc,%esp
  800cbc:	50                   	push   %eax
  800cbd:	6a 03                	push   $0x3
  800cbf:	68 7f 27 80 00       	push   $0x80277f
  800cc4:	6a 23                	push   $0x23
  800cc6:	68 9c 27 80 00       	push   $0x80279c
  800ccb:	e8 66 f5 ff ff       	call   800236 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd3:	5b                   	pop    %ebx
  800cd4:	5e                   	pop    %esi
  800cd5:	5f                   	pop    %edi
  800cd6:	5d                   	pop    %ebp
  800cd7:	c3                   	ret    

00800cd8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cd8:	55                   	push   %ebp
  800cd9:	89 e5                	mov    %esp,%ebp
  800cdb:	57                   	push   %edi
  800cdc:	56                   	push   %esi
  800cdd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cde:	ba 00 00 00 00       	mov    $0x0,%edx
  800ce3:	b8 02 00 00 00       	mov    $0x2,%eax
  800ce8:	89 d1                	mov    %edx,%ecx
  800cea:	89 d3                	mov    %edx,%ebx
  800cec:	89 d7                	mov    %edx,%edi
  800cee:	89 d6                	mov    %edx,%esi
  800cf0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cf2:	5b                   	pop    %ebx
  800cf3:	5e                   	pop    %esi
  800cf4:	5f                   	pop    %edi
  800cf5:	5d                   	pop    %ebp
  800cf6:	c3                   	ret    

00800cf7 <sys_yield>:

void
sys_yield(void)
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	57                   	push   %edi
  800cfb:	56                   	push   %esi
  800cfc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfd:	ba 00 00 00 00       	mov    $0x0,%edx
  800d02:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d07:	89 d1                	mov    %edx,%ecx
  800d09:	89 d3                	mov    %edx,%ebx
  800d0b:	89 d7                	mov    %edx,%edi
  800d0d:	89 d6                	mov    %edx,%esi
  800d0f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d11:	5b                   	pop    %ebx
  800d12:	5e                   	pop    %esi
  800d13:	5f                   	pop    %edi
  800d14:	5d                   	pop    %ebp
  800d15:	c3                   	ret    

00800d16 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	57                   	push   %edi
  800d1a:	56                   	push   %esi
  800d1b:	53                   	push   %ebx
  800d1c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	be 00 00 00 00       	mov    $0x0,%esi
  800d24:	b8 04 00 00 00       	mov    $0x4,%eax
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d32:	89 f7                	mov    %esi,%edi
  800d34:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7e 17                	jle    800d51 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3a:	83 ec 0c             	sub    $0xc,%esp
  800d3d:	50                   	push   %eax
  800d3e:	6a 04                	push   $0x4
  800d40:	68 7f 27 80 00       	push   $0x80277f
  800d45:	6a 23                	push   $0x23
  800d47:	68 9c 27 80 00       	push   $0x80279c
  800d4c:	e8 e5 f4 ff ff       	call   800236 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d54:	5b                   	pop    %ebx
  800d55:	5e                   	pop    %esi
  800d56:	5f                   	pop    %edi
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d62:	b8 05 00 00 00       	mov    $0x5,%eax
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d70:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d73:	8b 75 18             	mov    0x18(%ebp),%esi
  800d76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7e 17                	jle    800d93 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	50                   	push   %eax
  800d80:	6a 05                	push   $0x5
  800d82:	68 7f 27 80 00       	push   $0x80277f
  800d87:	6a 23                	push   $0x23
  800d89:	68 9c 27 80 00       	push   $0x80279c
  800d8e:	e8 a3 f4 ff ff       	call   800236 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d96:	5b                   	pop    %ebx
  800d97:	5e                   	pop    %esi
  800d98:	5f                   	pop    %edi
  800d99:	5d                   	pop    %ebp
  800d9a:	c3                   	ret    

00800d9b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	b8 06 00 00 00       	mov    $0x6,%eax
  800dae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7e 17                	jle    800dd5 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	50                   	push   %eax
  800dc2:	6a 06                	push   $0x6
  800dc4:	68 7f 27 80 00       	push   $0x80277f
  800dc9:	6a 23                	push   $0x23
  800dcb:	68 9c 27 80 00       	push   $0x80279c
  800dd0:	e8 61 f4 ff ff       	call   800236 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dd8:	5b                   	pop    %ebx
  800dd9:	5e                   	pop    %esi
  800dda:	5f                   	pop    %edi
  800ddb:	5d                   	pop    %ebp
  800ddc:	c3                   	ret    

00800ddd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	b8 08 00 00 00       	mov    $0x8,%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7e 17                	jle    800e17 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e00:	83 ec 0c             	sub    $0xc,%esp
  800e03:	50                   	push   %eax
  800e04:	6a 08                	push   $0x8
  800e06:	68 7f 27 80 00       	push   $0x80277f
  800e0b:	6a 23                	push   $0x23
  800e0d:	68 9c 27 80 00       	push   $0x80279c
  800e12:	e8 1f f4 ff ff       	call   800236 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1a:	5b                   	pop    %ebx
  800e1b:	5e                   	pop    %esi
  800e1c:	5f                   	pop    %edi
  800e1d:	5d                   	pop    %ebp
  800e1e:	c3                   	ret    

00800e1f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	89 df                	mov    %ebx,%edi
  800e3a:	89 de                	mov    %ebx,%esi
  800e3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e3e:	85 c0                	test   %eax,%eax
  800e40:	7e 17                	jle    800e59 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	50                   	push   %eax
  800e46:	6a 09                	push   $0x9
  800e48:	68 7f 27 80 00       	push   $0x80277f
  800e4d:	6a 23                	push   $0x23
  800e4f:	68 9c 27 80 00       	push   $0x80279c
  800e54:	e8 dd f3 ff ff       	call   800236 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	57                   	push   %edi
  800e65:	56                   	push   %esi
  800e66:	53                   	push   %ebx
  800e67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	89 df                	mov    %ebx,%edi
  800e7c:	89 de                	mov    %ebx,%esi
  800e7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e80:	85 c0                	test   %eax,%eax
  800e82:	7e 17                	jle    800e9b <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e84:	83 ec 0c             	sub    $0xc,%esp
  800e87:	50                   	push   %eax
  800e88:	6a 0a                	push   $0xa
  800e8a:	68 7f 27 80 00       	push   $0x80277f
  800e8f:	6a 23                	push   $0x23
  800e91:	68 9c 27 80 00       	push   $0x80279c
  800e96:	e8 9b f3 ff ff       	call   800236 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5f                   	pop    %edi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea9:	be 00 00 00 00       	mov    $0x0,%esi
  800eae:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ebc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ebf:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5f                   	pop    %edi
  800ec4:	5d                   	pop    %ebp
  800ec5:	c3                   	ret    

00800ec6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
  800ec9:	57                   	push   %edi
  800eca:	56                   	push   %esi
  800ecb:	53                   	push   %ebx
  800ecc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ed4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ed9:	8b 55 08             	mov    0x8(%ebp),%edx
  800edc:	89 cb                	mov    %ecx,%ebx
  800ede:	89 cf                	mov    %ecx,%edi
  800ee0:	89 ce                	mov    %ecx,%esi
  800ee2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 17                	jle    800eff <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	83 ec 0c             	sub    $0xc,%esp
  800eeb:	50                   	push   %eax
  800eec:	6a 0d                	push   $0xd
  800eee:	68 7f 27 80 00       	push   $0x80277f
  800ef3:	6a 23                	push   $0x23
  800ef5:	68 9c 27 80 00       	push   $0x80279c
  800efa:	e8 37 f3 ff ff       	call   800236 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f02:	5b                   	pop    %ebx
  800f03:	5e                   	pop    %esi
  800f04:	5f                   	pop    %edi
  800f05:	5d                   	pop    %ebp
  800f06:	c3                   	ret    

00800f07 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800f07:	55                   	push   %ebp
  800f08:	89 e5                	mov    %esp,%ebp
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800f0f:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800f11:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f15:	74 11                	je     800f28 <pgfault+0x21>
  800f17:	89 d8                	mov    %ebx,%eax
  800f19:	c1 e8 0c             	shr    $0xc,%eax
  800f1c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f23:	f6 c4 08             	test   $0x8,%ah
  800f26:	75 14                	jne    800f3c <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800f28:	83 ec 04             	sub    $0x4,%esp
  800f2b:	68 ac 27 80 00       	push   $0x8027ac
  800f30:	6a 1f                	push   $0x1f
  800f32:	68 0f 28 80 00       	push   $0x80280f
  800f37:	e8 fa f2 ff ff       	call   800236 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800f3c:	e8 97 fd ff ff       	call   800cd8 <sys_getenvid>
  800f41:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	6a 07                	push   $0x7
  800f48:	68 00 f0 7f 00       	push   $0x7ff000
  800f4d:	50                   	push   %eax
  800f4e:	e8 c3 fd ff ff       	call   800d16 <sys_page_alloc>
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	79 12                	jns    800f6c <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800f5a:	50                   	push   %eax
  800f5b:	68 ec 27 80 00       	push   $0x8027ec
  800f60:	6a 2c                	push   $0x2c
  800f62:	68 0f 28 80 00       	push   $0x80280f
  800f67:	e8 ca f2 ff ff       	call   800236 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800f6c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	68 00 10 00 00       	push   $0x1000
  800f7a:	53                   	push   %ebx
  800f7b:	68 00 f0 7f 00       	push   $0x7ff000
  800f80:	e8 20 fb ff ff       	call   800aa5 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800f85:	83 c4 08             	add    $0x8,%esp
  800f88:	53                   	push   %ebx
  800f89:	56                   	push   %esi
  800f8a:	e8 0c fe ff ff       	call   800d9b <sys_page_unmap>
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	79 12                	jns    800fa8 <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800f96:	50                   	push   %eax
  800f97:	68 1a 28 80 00       	push   $0x80281a
  800f9c:	6a 32                	push   $0x32
  800f9e:	68 0f 28 80 00       	push   $0x80280f
  800fa3:	e8 8e f2 ff ff       	call   800236 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800fa8:	83 ec 0c             	sub    $0xc,%esp
  800fab:	6a 07                	push   $0x7
  800fad:	53                   	push   %ebx
  800fae:	56                   	push   %esi
  800faf:	68 00 f0 7f 00       	push   $0x7ff000
  800fb4:	56                   	push   %esi
  800fb5:	e8 9f fd ff ff       	call   800d59 <sys_page_map>
  800fba:	83 c4 20             	add    $0x20,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	79 12                	jns    800fd3 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800fc1:	50                   	push   %eax
  800fc2:	68 38 28 80 00       	push   $0x802838
  800fc7:	6a 35                	push   $0x35
  800fc9:	68 0f 28 80 00       	push   $0x80280f
  800fce:	e8 63 f2 ff ff       	call   800236 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fd3:	83 ec 08             	sub    $0x8,%esp
  800fd6:	68 00 f0 7f 00       	push   $0x7ff000
  800fdb:	56                   	push   %esi
  800fdc:	e8 ba fd ff ff       	call   800d9b <sys_page_unmap>
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	79 12                	jns    800ffa <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800fe8:	50                   	push   %eax
  800fe9:	68 1a 28 80 00       	push   $0x80281a
  800fee:	6a 38                	push   $0x38
  800ff0:	68 0f 28 80 00       	push   $0x80280f
  800ff5:	e8 3c f2 ff ff       	call   800236 <_panic>
	//panic("pgfault not implemented");
}
  800ffa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ffd:	5b                   	pop    %ebx
  800ffe:	5e                   	pop    %esi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
  801007:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  80100a:	68 07 0f 80 00       	push   $0x800f07
  80100f:	e8 db 0e 00 00       	call   801eef <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801014:	b8 07 00 00 00       	mov    $0x7,%eax
  801019:	cd 30                	int    $0x30
  80101b:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	0f 88 38 01 00 00    	js     801161 <fork+0x160>
  801029:	89 c7                	mov    %eax,%edi
  80102b:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  801030:	85 c0                	test   %eax,%eax
  801032:	75 21                	jne    801055 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  801034:	e8 9f fc ff ff       	call   800cd8 <sys_getenvid>
  801039:	25 ff 03 00 00       	and    $0x3ff,%eax
  80103e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801041:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801046:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80104b:	ba 00 00 00 00       	mov    $0x0,%edx
  801050:	e9 86 01 00 00       	jmp    8011db <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  801055:	89 d8                	mov    %ebx,%eax
  801057:	c1 e8 16             	shr    $0x16,%eax
  80105a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801061:	a8 01                	test   $0x1,%al
  801063:	0f 84 90 00 00 00    	je     8010f9 <fork+0xf8>
  801069:	89 d8                	mov    %ebx,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
  80106e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801075:	f6 c2 01             	test   $0x1,%dl
  801078:	74 7f                	je     8010f9 <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  80107a:	89 c6                	mov    %eax,%esi
  80107c:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  80107f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801086:	f6 c6 04             	test   $0x4,%dh
  801089:	74 33                	je     8010be <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  80108b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801092:	83 ec 0c             	sub    $0xc,%esp
  801095:	25 07 0e 00 00       	and    $0xe07,%eax
  80109a:	50                   	push   %eax
  80109b:	56                   	push   %esi
  80109c:	57                   	push   %edi
  80109d:	56                   	push   %esi
  80109e:	6a 00                	push   $0x0
  8010a0:	e8 b4 fc ff ff       	call   800d59 <sys_page_map>
  8010a5:	83 c4 20             	add    $0x20,%esp
  8010a8:	85 c0                	test   %eax,%eax
  8010aa:	79 4d                	jns    8010f9 <fork+0xf8>
		    panic("sys_page_map: %e", r);
  8010ac:	50                   	push   %eax
  8010ad:	68 54 28 80 00       	push   $0x802854
  8010b2:	6a 54                	push   $0x54
  8010b4:	68 0f 28 80 00       	push   $0x80280f
  8010b9:	e8 78 f1 ff ff       	call   800236 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  8010be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c5:	a9 02 08 00 00       	test   $0x802,%eax
  8010ca:	0f 85 c6 00 00 00    	jne    801196 <fork+0x195>
  8010d0:	e9 e3 00 00 00       	jmp    8011b8 <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8010d5:	50                   	push   %eax
  8010d6:	68 54 28 80 00       	push   $0x802854
  8010db:	6a 5d                	push   $0x5d
  8010dd:	68 0f 28 80 00       	push   $0x80280f
  8010e2:	e8 4f f1 ff ff       	call   800236 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  8010e7:	50                   	push   %eax
  8010e8:	68 54 28 80 00       	push   $0x802854
  8010ed:	6a 64                	push   $0x64
  8010ef:	68 0f 28 80 00       	push   $0x80280f
  8010f4:	e8 3d f1 ff ff       	call   800236 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  8010f9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010ff:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801105:	0f 85 4a ff ff ff    	jne    801055 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  80110b:	83 ec 04             	sub    $0x4,%esp
  80110e:	6a 07                	push   $0x7
  801110:	68 00 f0 bf ee       	push   $0xeebff000
  801115:	8b 7d e0             	mov    -0x20(%ebp),%edi
  801118:	57                   	push   %edi
  801119:	e8 f8 fb ff ff       	call   800d16 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  80111e:	83 c4 10             	add    $0x10,%esp
		return ret;
  801121:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801123:	85 c0                	test   %eax,%eax
  801125:	0f 88 b0 00 00 00    	js     8011db <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80112b:	a1 04 40 80 00       	mov    0x804004,%eax
  801130:	8b 40 64             	mov    0x64(%eax),%eax
  801133:	83 ec 08             	sub    $0x8,%esp
  801136:	50                   	push   %eax
  801137:	57                   	push   %edi
  801138:	e8 24 fd ff ff       	call   800e61 <sys_env_set_pgfault_upcall>
  80113d:	83 c4 10             	add    $0x10,%esp
		return ret;
  801140:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801142:	85 c0                	test   %eax,%eax
  801144:	0f 88 91 00 00 00    	js     8011db <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80114a:	83 ec 08             	sub    $0x8,%esp
  80114d:	6a 02                	push   $0x2
  80114f:	57                   	push   %edi
  801150:	e8 88 fc ff ff       	call   800ddd <sys_env_set_status>
  801155:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  801158:	85 c0                	test   %eax,%eax
  80115a:	89 fa                	mov    %edi,%edx
  80115c:	0f 48 d0             	cmovs  %eax,%edx
  80115f:	eb 7a                	jmp    8011db <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  801161:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801164:	eb 75                	jmp    8011db <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801166:	e8 6d fb ff ff       	call   800cd8 <sys_getenvid>
  80116b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80116e:	e8 65 fb ff ff       	call   800cd8 <sys_getenvid>
  801173:	83 ec 0c             	sub    $0xc,%esp
  801176:	68 05 08 00 00       	push   $0x805
  80117b:	56                   	push   %esi
  80117c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117f:	56                   	push   %esi
  801180:	50                   	push   %eax
  801181:	e8 d3 fb ff ff       	call   800d59 <sys_page_map>
  801186:	83 c4 20             	add    $0x20,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	0f 89 68 ff ff ff    	jns    8010f9 <fork+0xf8>
  801191:	e9 51 ff ff ff       	jmp    8010e7 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  801196:	e8 3d fb ff ff       	call   800cd8 <sys_getenvid>
  80119b:	83 ec 0c             	sub    $0xc,%esp
  80119e:	68 05 08 00 00       	push   $0x805
  8011a3:	56                   	push   %esi
  8011a4:	57                   	push   %edi
  8011a5:	56                   	push   %esi
  8011a6:	50                   	push   %eax
  8011a7:	e8 ad fb ff ff       	call   800d59 <sys_page_map>
  8011ac:	83 c4 20             	add    $0x20,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	79 b3                	jns    801166 <fork+0x165>
  8011b3:	e9 1d ff ff ff       	jmp    8010d5 <fork+0xd4>
  8011b8:	e8 1b fb ff ff       	call   800cd8 <sys_getenvid>
  8011bd:	83 ec 0c             	sub    $0xc,%esp
  8011c0:	6a 05                	push   $0x5
  8011c2:	56                   	push   %esi
  8011c3:	57                   	push   %edi
  8011c4:	56                   	push   %esi
  8011c5:	50                   	push   %eax
  8011c6:	e8 8e fb ff ff       	call   800d59 <sys_page_map>
  8011cb:	83 c4 20             	add    $0x20,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	0f 89 23 ff ff ff    	jns    8010f9 <fork+0xf8>
  8011d6:	e9 fa fe ff ff       	jmp    8010d5 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  8011db:	89 d0                	mov    %edx,%eax
  8011dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sfork>:

// Challenge!
int
sfork(void)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011eb:	68 65 28 80 00       	push   $0x802865
  8011f0:	68 ac 00 00 00       	push   $0xac
  8011f5:	68 0f 28 80 00       	push   $0x80280f
  8011fa:	e8 37 f0 ff ff       	call   800236 <_panic>

008011ff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011ff:	55                   	push   %ebp
  801200:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801202:	8b 45 08             	mov    0x8(%ebp),%eax
  801205:	05 00 00 00 30       	add    $0x30000000,%eax
  80120a:	c1 e8 0c             	shr    $0xc,%eax
}
  80120d:	5d                   	pop    %ebp
  80120e:	c3                   	ret    

0080120f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801212:	8b 45 08             	mov    0x8(%ebp),%eax
  801215:	05 00 00 00 30       	add    $0x30000000,%eax
  80121a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80121f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80122c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801231:	89 c2                	mov    %eax,%edx
  801233:	c1 ea 16             	shr    $0x16,%edx
  801236:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80123d:	f6 c2 01             	test   $0x1,%dl
  801240:	74 11                	je     801253 <fd_alloc+0x2d>
  801242:	89 c2                	mov    %eax,%edx
  801244:	c1 ea 0c             	shr    $0xc,%edx
  801247:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80124e:	f6 c2 01             	test   $0x1,%dl
  801251:	75 09                	jne    80125c <fd_alloc+0x36>
			*fd_store = fd;
  801253:	89 01                	mov    %eax,(%ecx)
			return 0;
  801255:	b8 00 00 00 00       	mov    $0x0,%eax
  80125a:	eb 17                	jmp    801273 <fd_alloc+0x4d>
  80125c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801261:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801266:	75 c9                	jne    801231 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801268:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80126e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801273:	5d                   	pop    %ebp
  801274:	c3                   	ret    

00801275 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80127b:	83 f8 1f             	cmp    $0x1f,%eax
  80127e:	77 36                	ja     8012b6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801280:	c1 e0 0c             	shl    $0xc,%eax
  801283:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801288:	89 c2                	mov    %eax,%edx
  80128a:	c1 ea 16             	shr    $0x16,%edx
  80128d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801294:	f6 c2 01             	test   $0x1,%dl
  801297:	74 24                	je     8012bd <fd_lookup+0x48>
  801299:	89 c2                	mov    %eax,%edx
  80129b:	c1 ea 0c             	shr    $0xc,%edx
  80129e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012a5:	f6 c2 01             	test   $0x1,%dl
  8012a8:	74 1a                	je     8012c4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ad:	89 02                	mov    %eax,(%edx)
	return 0;
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
  8012b4:	eb 13                	jmp    8012c9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012bb:	eb 0c                	jmp    8012c9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c2:	eb 05                	jmp    8012c9 <fd_lookup+0x54>
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    

008012cb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012cb:	55                   	push   %ebp
  8012cc:	89 e5                	mov    %esp,%ebp
  8012ce:	83 ec 08             	sub    $0x8,%esp
  8012d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d4:	ba fc 28 80 00       	mov    $0x8028fc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012d9:	eb 13                	jmp    8012ee <dev_lookup+0x23>
  8012db:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8012de:	39 08                	cmp    %ecx,(%eax)
  8012e0:	75 0c                	jne    8012ee <dev_lookup+0x23>
			*dev = devtab[i];
  8012e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ec:	eb 2e                	jmp    80131c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8012ee:	8b 02                	mov    (%edx),%eax
  8012f0:	85 c0                	test   %eax,%eax
  8012f2:	75 e7                	jne    8012db <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012f4:	a1 04 40 80 00       	mov    0x804004,%eax
  8012f9:	8b 40 48             	mov    0x48(%eax),%eax
  8012fc:	83 ec 04             	sub    $0x4,%esp
  8012ff:	51                   	push   %ecx
  801300:	50                   	push   %eax
  801301:	68 7c 28 80 00       	push   $0x80287c
  801306:	e8 04 f0 ff ff       	call   80030f <cprintf>
	*dev = 0;
  80130b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80130e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80131c:	c9                   	leave  
  80131d:	c3                   	ret    

0080131e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80131e:	55                   	push   %ebp
  80131f:	89 e5                	mov    %esp,%ebp
  801321:	56                   	push   %esi
  801322:	53                   	push   %ebx
  801323:	83 ec 10             	sub    $0x10,%esp
  801326:	8b 75 08             	mov    0x8(%ebp),%esi
  801329:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80132c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801336:	c1 e8 0c             	shr    $0xc,%eax
  801339:	50                   	push   %eax
  80133a:	e8 36 ff ff ff       	call   801275 <fd_lookup>
  80133f:	83 c4 08             	add    $0x8,%esp
  801342:	85 c0                	test   %eax,%eax
  801344:	78 05                	js     80134b <fd_close+0x2d>
	    || fd != fd2)
  801346:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801349:	74 0c                	je     801357 <fd_close+0x39>
		return (must_exist ? r : 0);
  80134b:	84 db                	test   %bl,%bl
  80134d:	ba 00 00 00 00       	mov    $0x0,%edx
  801352:	0f 44 c2             	cmove  %edx,%eax
  801355:	eb 41                	jmp    801398 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801357:	83 ec 08             	sub    $0x8,%esp
  80135a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135d:	50                   	push   %eax
  80135e:	ff 36                	pushl  (%esi)
  801360:	e8 66 ff ff ff       	call   8012cb <dev_lookup>
  801365:	89 c3                	mov    %eax,%ebx
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	85 c0                	test   %eax,%eax
  80136c:	78 1a                	js     801388 <fd_close+0x6a>
		if (dev->dev_close)
  80136e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801371:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801374:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801379:	85 c0                	test   %eax,%eax
  80137b:	74 0b                	je     801388 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80137d:	83 ec 0c             	sub    $0xc,%esp
  801380:	56                   	push   %esi
  801381:	ff d0                	call   *%eax
  801383:	89 c3                	mov    %eax,%ebx
  801385:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	56                   	push   %esi
  80138c:	6a 00                	push   $0x0
  80138e:	e8 08 fa ff ff       	call   800d9b <sys_page_unmap>
	return r;
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	89 d8                	mov    %ebx,%eax
}
  801398:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5e                   	pop    %esi
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    

0080139f <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	ff 75 08             	pushl  0x8(%ebp)
  8013ac:	e8 c4 fe ff ff       	call   801275 <fd_lookup>
  8013b1:	83 c4 08             	add    $0x8,%esp
  8013b4:	85 c0                	test   %eax,%eax
  8013b6:	78 10                	js     8013c8 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013b8:	83 ec 08             	sub    $0x8,%esp
  8013bb:	6a 01                	push   $0x1
  8013bd:	ff 75 f4             	pushl  -0xc(%ebp)
  8013c0:	e8 59 ff ff ff       	call   80131e <fd_close>
  8013c5:	83 c4 10             	add    $0x10,%esp
}
  8013c8:	c9                   	leave  
  8013c9:	c3                   	ret    

008013ca <close_all>:

void
close_all(void)
{
  8013ca:	55                   	push   %ebp
  8013cb:	89 e5                	mov    %esp,%ebp
  8013cd:	53                   	push   %ebx
  8013ce:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013d1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	53                   	push   %ebx
  8013da:	e8 c0 ff ff ff       	call   80139f <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8013df:	83 c3 01             	add    $0x1,%ebx
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	83 fb 20             	cmp    $0x20,%ebx
  8013e8:	75 ec                	jne    8013d6 <close_all+0xc>
		close(i);
}
  8013ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    

008013ef <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	57                   	push   %edi
  8013f3:	56                   	push   %esi
  8013f4:	53                   	push   %ebx
  8013f5:	83 ec 2c             	sub    $0x2c,%esp
  8013f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013fb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	ff 75 08             	pushl  0x8(%ebp)
  801402:	e8 6e fe ff ff       	call   801275 <fd_lookup>
  801407:	83 c4 08             	add    $0x8,%esp
  80140a:	85 c0                	test   %eax,%eax
  80140c:	0f 88 c1 00 00 00    	js     8014d3 <dup+0xe4>
		return r;
	close(newfdnum);
  801412:	83 ec 0c             	sub    $0xc,%esp
  801415:	56                   	push   %esi
  801416:	e8 84 ff ff ff       	call   80139f <close>

	newfd = INDEX2FD(newfdnum);
  80141b:	89 f3                	mov    %esi,%ebx
  80141d:	c1 e3 0c             	shl    $0xc,%ebx
  801420:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801426:	83 c4 04             	add    $0x4,%esp
  801429:	ff 75 e4             	pushl  -0x1c(%ebp)
  80142c:	e8 de fd ff ff       	call   80120f <fd2data>
  801431:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801433:	89 1c 24             	mov    %ebx,(%esp)
  801436:	e8 d4 fd ff ff       	call   80120f <fd2data>
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801441:	89 f8                	mov    %edi,%eax
  801443:	c1 e8 16             	shr    $0x16,%eax
  801446:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80144d:	a8 01                	test   $0x1,%al
  80144f:	74 37                	je     801488 <dup+0x99>
  801451:	89 f8                	mov    %edi,%eax
  801453:	c1 e8 0c             	shr    $0xc,%eax
  801456:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80145d:	f6 c2 01             	test   $0x1,%dl
  801460:	74 26                	je     801488 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801462:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801469:	83 ec 0c             	sub    $0xc,%esp
  80146c:	25 07 0e 00 00       	and    $0xe07,%eax
  801471:	50                   	push   %eax
  801472:	ff 75 d4             	pushl  -0x2c(%ebp)
  801475:	6a 00                	push   $0x0
  801477:	57                   	push   %edi
  801478:	6a 00                	push   $0x0
  80147a:	e8 da f8 ff ff       	call   800d59 <sys_page_map>
  80147f:	89 c7                	mov    %eax,%edi
  801481:	83 c4 20             	add    $0x20,%esp
  801484:	85 c0                	test   %eax,%eax
  801486:	78 2e                	js     8014b6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801488:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80148b:	89 d0                	mov    %edx,%eax
  80148d:	c1 e8 0c             	shr    $0xc,%eax
  801490:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801497:	83 ec 0c             	sub    $0xc,%esp
  80149a:	25 07 0e 00 00       	and    $0xe07,%eax
  80149f:	50                   	push   %eax
  8014a0:	53                   	push   %ebx
  8014a1:	6a 00                	push   $0x0
  8014a3:	52                   	push   %edx
  8014a4:	6a 00                	push   $0x0
  8014a6:	e8 ae f8 ff ff       	call   800d59 <sys_page_map>
  8014ab:	89 c7                	mov    %eax,%edi
  8014ad:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014b0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b2:	85 ff                	test   %edi,%edi
  8014b4:	79 1d                	jns    8014d3 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	53                   	push   %ebx
  8014ba:	6a 00                	push   $0x0
  8014bc:	e8 da f8 ff ff       	call   800d9b <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014c1:	83 c4 08             	add    $0x8,%esp
  8014c4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014c7:	6a 00                	push   $0x0
  8014c9:	e8 cd f8 ff ff       	call   800d9b <sys_page_unmap>
	return r;
  8014ce:	83 c4 10             	add    $0x10,%esp
  8014d1:	89 f8                	mov    %edi,%eax
}
  8014d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d6:	5b                   	pop    %ebx
  8014d7:	5e                   	pop    %esi
  8014d8:	5f                   	pop    %edi
  8014d9:	5d                   	pop    %ebp
  8014da:	c3                   	ret    

008014db <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 14             	sub    $0x14,%esp
  8014e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	53                   	push   %ebx
  8014ea:	e8 86 fd ff ff       	call   801275 <fd_lookup>
  8014ef:	83 c4 08             	add    $0x8,%esp
  8014f2:	89 c2                	mov    %eax,%edx
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 6d                	js     801565 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801502:	ff 30                	pushl  (%eax)
  801504:	e8 c2 fd ff ff       	call   8012cb <dev_lookup>
  801509:	83 c4 10             	add    $0x10,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	78 4c                	js     80155c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801510:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801513:	8b 42 08             	mov    0x8(%edx),%eax
  801516:	83 e0 03             	and    $0x3,%eax
  801519:	83 f8 01             	cmp    $0x1,%eax
  80151c:	75 21                	jne    80153f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80151e:	a1 04 40 80 00       	mov    0x804004,%eax
  801523:	8b 40 48             	mov    0x48(%eax),%eax
  801526:	83 ec 04             	sub    $0x4,%esp
  801529:	53                   	push   %ebx
  80152a:	50                   	push   %eax
  80152b:	68 c0 28 80 00       	push   $0x8028c0
  801530:	e8 da ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  801535:	83 c4 10             	add    $0x10,%esp
  801538:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153d:	eb 26                	jmp    801565 <read+0x8a>
	}
	if (!dev->dev_read)
  80153f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801542:	8b 40 08             	mov    0x8(%eax),%eax
  801545:	85 c0                	test   %eax,%eax
  801547:	74 17                	je     801560 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	ff 75 10             	pushl  0x10(%ebp)
  80154f:	ff 75 0c             	pushl  0xc(%ebp)
  801552:	52                   	push   %edx
  801553:	ff d0                	call   *%eax
  801555:	89 c2                	mov    %eax,%edx
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	eb 09                	jmp    801565 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155c:	89 c2                	mov    %eax,%edx
  80155e:	eb 05                	jmp    801565 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801560:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801565:	89 d0                	mov    %edx,%eax
  801567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	57                   	push   %edi
  801570:	56                   	push   %esi
  801571:	53                   	push   %ebx
  801572:	83 ec 0c             	sub    $0xc,%esp
  801575:	8b 7d 08             	mov    0x8(%ebp),%edi
  801578:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80157b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801580:	eb 21                	jmp    8015a3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801582:	83 ec 04             	sub    $0x4,%esp
  801585:	89 f0                	mov    %esi,%eax
  801587:	29 d8                	sub    %ebx,%eax
  801589:	50                   	push   %eax
  80158a:	89 d8                	mov    %ebx,%eax
  80158c:	03 45 0c             	add    0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	57                   	push   %edi
  801591:	e8 45 ff ff ff       	call   8014db <read>
		if (m < 0)
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	78 10                	js     8015ad <readn+0x41>
			return m;
		if (m == 0)
  80159d:	85 c0                	test   %eax,%eax
  80159f:	74 0a                	je     8015ab <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015a1:	01 c3                	add    %eax,%ebx
  8015a3:	39 f3                	cmp    %esi,%ebx
  8015a5:	72 db                	jb     801582 <readn+0x16>
  8015a7:	89 d8                	mov    %ebx,%eax
  8015a9:	eb 02                	jmp    8015ad <readn+0x41>
  8015ab:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015b0:	5b                   	pop    %ebx
  8015b1:	5e                   	pop    %esi
  8015b2:	5f                   	pop    %edi
  8015b3:	5d                   	pop    %ebp
  8015b4:	c3                   	ret    

008015b5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	53                   	push   %ebx
  8015b9:	83 ec 14             	sub    $0x14,%esp
  8015bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c2:	50                   	push   %eax
  8015c3:	53                   	push   %ebx
  8015c4:	e8 ac fc ff ff       	call   801275 <fd_lookup>
  8015c9:	83 c4 08             	add    $0x8,%esp
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 68                	js     80163a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015d8:	50                   	push   %eax
  8015d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015dc:	ff 30                	pushl  (%eax)
  8015de:	e8 e8 fc ff ff       	call   8012cb <dev_lookup>
  8015e3:	83 c4 10             	add    $0x10,%esp
  8015e6:	85 c0                	test   %eax,%eax
  8015e8:	78 47                	js     801631 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015ed:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015f1:	75 21                	jne    801614 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f3:	a1 04 40 80 00       	mov    0x804004,%eax
  8015f8:	8b 40 48             	mov    0x48(%eax),%eax
  8015fb:	83 ec 04             	sub    $0x4,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	50                   	push   %eax
  801600:	68 dc 28 80 00       	push   $0x8028dc
  801605:	e8 05 ed ff ff       	call   80030f <cprintf>
		return -E_INVAL;
  80160a:	83 c4 10             	add    $0x10,%esp
  80160d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801612:	eb 26                	jmp    80163a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801614:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801617:	8b 52 0c             	mov    0xc(%edx),%edx
  80161a:	85 d2                	test   %edx,%edx
  80161c:	74 17                	je     801635 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	ff 75 10             	pushl  0x10(%ebp)
  801624:	ff 75 0c             	pushl  0xc(%ebp)
  801627:	50                   	push   %eax
  801628:	ff d2                	call   *%edx
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	eb 09                	jmp    80163a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801631:	89 c2                	mov    %eax,%edx
  801633:	eb 05                	jmp    80163a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801635:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80163a:	89 d0                	mov    %edx,%eax
  80163c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <seek>:

int
seek(int fdnum, off_t offset)
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801647:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80164a:	50                   	push   %eax
  80164b:	ff 75 08             	pushl  0x8(%ebp)
  80164e:	e8 22 fc ff ff       	call   801275 <fd_lookup>
  801653:	83 c4 08             	add    $0x8,%esp
  801656:	85 c0                	test   %eax,%eax
  801658:	78 0e                	js     801668 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80165a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80165d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801660:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801668:	c9                   	leave  
  801669:	c3                   	ret    

0080166a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
  80166e:	83 ec 14             	sub    $0x14,%esp
  801671:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801674:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	53                   	push   %ebx
  801679:	e8 f7 fb ff ff       	call   801275 <fd_lookup>
  80167e:	83 c4 08             	add    $0x8,%esp
  801681:	89 c2                	mov    %eax,%edx
  801683:	85 c0                	test   %eax,%eax
  801685:	78 65                	js     8016ec <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801687:	83 ec 08             	sub    $0x8,%esp
  80168a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168d:	50                   	push   %eax
  80168e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801691:	ff 30                	pushl  (%eax)
  801693:	e8 33 fc ff ff       	call   8012cb <dev_lookup>
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 44                	js     8016e3 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016a2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016a6:	75 21                	jne    8016c9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016a8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016ad:	8b 40 48             	mov    0x48(%eax),%eax
  8016b0:	83 ec 04             	sub    $0x4,%esp
  8016b3:	53                   	push   %ebx
  8016b4:	50                   	push   %eax
  8016b5:	68 9c 28 80 00       	push   $0x80289c
  8016ba:	e8 50 ec ff ff       	call   80030f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016c7:	eb 23                	jmp    8016ec <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cc:	8b 52 18             	mov    0x18(%edx),%edx
  8016cf:	85 d2                	test   %edx,%edx
  8016d1:	74 14                	je     8016e7 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016d3:	83 ec 08             	sub    $0x8,%esp
  8016d6:	ff 75 0c             	pushl  0xc(%ebp)
  8016d9:	50                   	push   %eax
  8016da:	ff d2                	call   *%edx
  8016dc:	89 c2                	mov    %eax,%edx
  8016de:	83 c4 10             	add    $0x10,%esp
  8016e1:	eb 09                	jmp    8016ec <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	eb 05                	jmp    8016ec <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8016e7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8016ec:	89 d0                	mov    %edx,%eax
  8016ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f1:	c9                   	leave  
  8016f2:	c3                   	ret    

008016f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	83 ec 14             	sub    $0x14,%esp
  8016fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801700:	50                   	push   %eax
  801701:	ff 75 08             	pushl  0x8(%ebp)
  801704:	e8 6c fb ff ff       	call   801275 <fd_lookup>
  801709:	83 c4 08             	add    $0x8,%esp
  80170c:	89 c2                	mov    %eax,%edx
  80170e:	85 c0                	test   %eax,%eax
  801710:	78 58                	js     80176a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801712:	83 ec 08             	sub    $0x8,%esp
  801715:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801718:	50                   	push   %eax
  801719:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80171c:	ff 30                	pushl  (%eax)
  80171e:	e8 a8 fb ff ff       	call   8012cb <dev_lookup>
  801723:	83 c4 10             	add    $0x10,%esp
  801726:	85 c0                	test   %eax,%eax
  801728:	78 37                	js     801761 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80172a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801731:	74 32                	je     801765 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801733:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801736:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173d:	00 00 00 
	stat->st_isdir = 0;
  801740:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801747:	00 00 00 
	stat->st_dev = dev;
  80174a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	53                   	push   %ebx
  801754:	ff 75 f0             	pushl  -0x10(%ebp)
  801757:	ff 50 14             	call   *0x14(%eax)
  80175a:	89 c2                	mov    %eax,%edx
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	eb 09                	jmp    80176a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801761:	89 c2                	mov    %eax,%edx
  801763:	eb 05                	jmp    80176a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801765:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80176a:	89 d0                	mov    %edx,%eax
  80176c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176f:	c9                   	leave  
  801770:	c3                   	ret    

00801771 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801771:	55                   	push   %ebp
  801772:	89 e5                	mov    %esp,%ebp
  801774:	56                   	push   %esi
  801775:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801776:	83 ec 08             	sub    $0x8,%esp
  801779:	6a 00                	push   $0x0
  80177b:	ff 75 08             	pushl  0x8(%ebp)
  80177e:	e8 e9 01 00 00       	call   80196c <open>
  801783:	89 c3                	mov    %eax,%ebx
  801785:	83 c4 10             	add    $0x10,%esp
  801788:	85 c0                	test   %eax,%eax
  80178a:	78 1b                	js     8017a7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80178c:	83 ec 08             	sub    $0x8,%esp
  80178f:	ff 75 0c             	pushl  0xc(%ebp)
  801792:	50                   	push   %eax
  801793:	e8 5b ff ff ff       	call   8016f3 <fstat>
  801798:	89 c6                	mov    %eax,%esi
	close(fd);
  80179a:	89 1c 24             	mov    %ebx,(%esp)
  80179d:	e8 fd fb ff ff       	call   80139f <close>
	return r;
  8017a2:	83 c4 10             	add    $0x10,%esp
  8017a5:	89 f0                	mov    %esi,%eax
}
  8017a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017aa:	5b                   	pop    %ebx
  8017ab:	5e                   	pop    %esi
  8017ac:	5d                   	pop    %ebp
  8017ad:	c3                   	ret    

008017ae <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ae:	55                   	push   %ebp
  8017af:	89 e5                	mov    %esp,%ebp
  8017b1:	56                   	push   %esi
  8017b2:	53                   	push   %ebx
  8017b3:	89 c6                	mov    %eax,%esi
  8017b5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017b7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017be:	75 12                	jne    8017d2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017c0:	83 ec 0c             	sub    $0xc,%esp
  8017c3:	6a 01                	push   $0x1
  8017c5:	e8 95 08 00 00       	call   80205f <ipc_find_env>
  8017ca:	a3 00 40 80 00       	mov    %eax,0x804000
  8017cf:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017d2:	6a 07                	push   $0x7
  8017d4:	68 00 50 80 00       	push   $0x805000
  8017d9:	56                   	push   %esi
  8017da:	ff 35 00 40 80 00    	pushl  0x804000
  8017e0:	e8 26 08 00 00       	call   80200b <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  8017e5:	83 c4 0c             	add    $0xc,%esp
  8017e8:	6a 00                	push   $0x0
  8017ea:	53                   	push   %ebx
  8017eb:	6a 00                	push   $0x0
  8017ed:	e8 97 07 00 00       	call   801f89 <ipc_recv>
}
  8017f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    

008017f9 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	8b 40 0c             	mov    0xc(%eax),%eax
  801805:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80180a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801812:	ba 00 00 00 00       	mov    $0x0,%edx
  801817:	b8 02 00 00 00       	mov    $0x2,%eax
  80181c:	e8 8d ff ff ff       	call   8017ae <fsipc>
}
  801821:	c9                   	leave  
  801822:	c3                   	ret    

00801823 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801823:	55                   	push   %ebp
  801824:	89 e5                	mov    %esp,%ebp
  801826:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	8b 40 0c             	mov    0xc(%eax),%eax
  80182f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801834:	ba 00 00 00 00       	mov    $0x0,%edx
  801839:	b8 06 00 00 00       	mov    $0x6,%eax
  80183e:	e8 6b ff ff ff       	call   8017ae <fsipc>
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	53                   	push   %ebx
  801849:	83 ec 04             	sub    $0x4,%esp
  80184c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	8b 40 0c             	mov    0xc(%eax),%eax
  801855:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80185a:	ba 00 00 00 00       	mov    $0x0,%edx
  80185f:	b8 05 00 00 00       	mov    $0x5,%eax
  801864:	e8 45 ff ff ff       	call   8017ae <fsipc>
  801869:	85 c0                	test   %eax,%eax
  80186b:	78 2c                	js     801899 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80186d:	83 ec 08             	sub    $0x8,%esp
  801870:	68 00 50 80 00       	push   $0x805000
  801875:	53                   	push   %ebx
  801876:	e8 98 f0 ff ff       	call   800913 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80187b:	a1 80 50 80 00       	mov    0x805080,%eax
  801880:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801886:	a1 84 50 80 00       	mov    0x805084,%eax
  80188b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801899:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80189c:	c9                   	leave  
  80189d:	c3                   	ret    

0080189e <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80189e:	55                   	push   %ebp
  80189f:	89 e5                	mov    %esp,%ebp
  8018a1:	83 ec 0c             	sub    $0xc,%esp
  8018a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018ac:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018b1:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8018b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ba:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8018c0:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8018c5:	50                   	push   %eax
  8018c6:	ff 75 0c             	pushl  0xc(%ebp)
  8018c9:	68 08 50 80 00       	push   $0x805008
  8018ce:	e8 d2 f1 ff ff       	call   800aa5 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8018d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d8:	b8 04 00 00 00       	mov    $0x4,%eax
  8018dd:	e8 cc fe ff ff       	call   8017ae <fsipc>
            return r;

    return r;
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	56                   	push   %esi
  8018e8:	53                   	push   %ebx
  8018e9:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8018f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018f7:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 03 00 00 00       	mov    $0x3,%eax
  801907:	e8 a2 fe ff ff       	call   8017ae <fsipc>
  80190c:	89 c3                	mov    %eax,%ebx
  80190e:	85 c0                	test   %eax,%eax
  801910:	78 51                	js     801963 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801912:	39 c6                	cmp    %eax,%esi
  801914:	73 19                	jae    80192f <devfile_read+0x4b>
  801916:	68 0c 29 80 00       	push   $0x80290c
  80191b:	68 13 29 80 00       	push   $0x802913
  801920:	68 82 00 00 00       	push   $0x82
  801925:	68 28 29 80 00       	push   $0x802928
  80192a:	e8 07 e9 ff ff       	call   800236 <_panic>
	assert(r <= PGSIZE);
  80192f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801934:	7e 19                	jle    80194f <devfile_read+0x6b>
  801936:	68 33 29 80 00       	push   $0x802933
  80193b:	68 13 29 80 00       	push   $0x802913
  801940:	68 83 00 00 00       	push   $0x83
  801945:	68 28 29 80 00       	push   $0x802928
  80194a:	e8 e7 e8 ff ff       	call   800236 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80194f:	83 ec 04             	sub    $0x4,%esp
  801952:	50                   	push   %eax
  801953:	68 00 50 80 00       	push   $0x805000
  801958:	ff 75 0c             	pushl  0xc(%ebp)
  80195b:	e8 45 f1 ff ff       	call   800aa5 <memmove>
	return r;
  801960:	83 c4 10             	add    $0x10,%esp
}
  801963:	89 d8                	mov    %ebx,%eax
  801965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801968:	5b                   	pop    %ebx
  801969:	5e                   	pop    %esi
  80196a:	5d                   	pop    %ebp
  80196b:	c3                   	ret    

0080196c <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	53                   	push   %ebx
  801970:	83 ec 20             	sub    $0x20,%esp
  801973:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801976:	53                   	push   %ebx
  801977:	e8 5e ef ff ff       	call   8008da <strlen>
  80197c:	83 c4 10             	add    $0x10,%esp
  80197f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801984:	7f 67                	jg     8019ed <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801986:	83 ec 0c             	sub    $0xc,%esp
  801989:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198c:	50                   	push   %eax
  80198d:	e8 94 f8 ff ff       	call   801226 <fd_alloc>
  801992:	83 c4 10             	add    $0x10,%esp
		return r;
  801995:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801997:	85 c0                	test   %eax,%eax
  801999:	78 57                	js     8019f2 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80199b:	83 ec 08             	sub    $0x8,%esp
  80199e:	53                   	push   %ebx
  80199f:	68 00 50 80 00       	push   $0x805000
  8019a4:	e8 6a ef ff ff       	call   800913 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019a9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ac:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019b1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8019b9:	e8 f0 fd ff ff       	call   8017ae <fsipc>
  8019be:	89 c3                	mov    %eax,%ebx
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	79 14                	jns    8019db <open+0x6f>
		fd_close(fd, 0);
  8019c7:	83 ec 08             	sub    $0x8,%esp
  8019ca:	6a 00                	push   $0x0
  8019cc:	ff 75 f4             	pushl  -0xc(%ebp)
  8019cf:	e8 4a f9 ff ff       	call   80131e <fd_close>
		return r;
  8019d4:	83 c4 10             	add    $0x10,%esp
  8019d7:	89 da                	mov    %ebx,%edx
  8019d9:	eb 17                	jmp    8019f2 <open+0x86>
	}

	return fd2num(fd);
  8019db:	83 ec 0c             	sub    $0xc,%esp
  8019de:	ff 75 f4             	pushl  -0xc(%ebp)
  8019e1:	e8 19 f8 ff ff       	call   8011ff <fd2num>
  8019e6:	89 c2                	mov    %eax,%edx
  8019e8:	83 c4 10             	add    $0x10,%esp
  8019eb:	eb 05                	jmp    8019f2 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8019ed:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019f2:	89 d0                	mov    %edx,%eax
  8019f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f7:	c9                   	leave  
  8019f8:	c3                   	ret    

008019f9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801a04:	b8 08 00 00 00       	mov    $0x8,%eax
  801a09:	e8 a0 fd ff ff       	call   8017ae <fsipc>
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	ff 75 08             	pushl  0x8(%ebp)
  801a1e:	e8 ec f7 ff ff       	call   80120f <fd2data>
  801a23:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a25:	83 c4 08             	add    $0x8,%esp
  801a28:	68 3f 29 80 00       	push   $0x80293f
  801a2d:	53                   	push   %ebx
  801a2e:	e8 e0 ee ff ff       	call   800913 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a33:	8b 46 04             	mov    0x4(%esi),%eax
  801a36:	2b 06                	sub    (%esi),%eax
  801a38:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a3e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a45:	00 00 00 
	stat->st_dev = &devpipe;
  801a48:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a4f:	30 80 00 
	return 0;
}
  801a52:	b8 00 00 00 00       	mov    $0x0,%eax
  801a57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	53                   	push   %ebx
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a68:	53                   	push   %ebx
  801a69:	6a 00                	push   $0x0
  801a6b:	e8 2b f3 ff ff       	call   800d9b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a70:	89 1c 24             	mov    %ebx,(%esp)
  801a73:	e8 97 f7 ff ff       	call   80120f <fd2data>
  801a78:	83 c4 08             	add    $0x8,%esp
  801a7b:	50                   	push   %eax
  801a7c:	6a 00                	push   $0x0
  801a7e:	e8 18 f3 ff ff       	call   800d9b <sys_page_unmap>
}
  801a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    

00801a88 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	57                   	push   %edi
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 1c             	sub    $0x1c,%esp
  801a91:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a94:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a96:	a1 04 40 80 00       	mov    0x804004,%eax
  801a9b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a9e:	83 ec 0c             	sub    $0xc,%esp
  801aa1:	ff 75 e0             	pushl  -0x20(%ebp)
  801aa4:	e8 ef 05 00 00       	call   802098 <pageref>
  801aa9:	89 c3                	mov    %eax,%ebx
  801aab:	89 3c 24             	mov    %edi,(%esp)
  801aae:	e8 e5 05 00 00       	call   802098 <pageref>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	39 c3                	cmp    %eax,%ebx
  801ab8:	0f 94 c1             	sete   %cl
  801abb:	0f b6 c9             	movzbl %cl,%ecx
  801abe:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ac1:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801ac7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aca:	39 ce                	cmp    %ecx,%esi
  801acc:	74 1b                	je     801ae9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ace:	39 c3                	cmp    %eax,%ebx
  801ad0:	75 c4                	jne    801a96 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ad2:	8b 42 58             	mov    0x58(%edx),%eax
  801ad5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ad8:	50                   	push   %eax
  801ad9:	56                   	push   %esi
  801ada:	68 46 29 80 00       	push   $0x802946
  801adf:	e8 2b e8 ff ff       	call   80030f <cprintf>
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	eb ad                	jmp    801a96 <_pipeisclosed+0xe>
	}
}
  801ae9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5f                   	pop    %edi
  801af2:	5d                   	pop    %ebp
  801af3:	c3                   	ret    

00801af4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	57                   	push   %edi
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
  801afa:	83 ec 28             	sub    $0x28,%esp
  801afd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b00:	56                   	push   %esi
  801b01:	e8 09 f7 ff ff       	call   80120f <fd2data>
  801b06:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	bf 00 00 00 00       	mov    $0x0,%edi
  801b10:	eb 4b                	jmp    801b5d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b12:	89 da                	mov    %ebx,%edx
  801b14:	89 f0                	mov    %esi,%eax
  801b16:	e8 6d ff ff ff       	call   801a88 <_pipeisclosed>
  801b1b:	85 c0                	test   %eax,%eax
  801b1d:	75 48                	jne    801b67 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b1f:	e8 d3 f1 ff ff       	call   800cf7 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b24:	8b 43 04             	mov    0x4(%ebx),%eax
  801b27:	8b 0b                	mov    (%ebx),%ecx
  801b29:	8d 51 20             	lea    0x20(%ecx),%edx
  801b2c:	39 d0                	cmp    %edx,%eax
  801b2e:	73 e2                	jae    801b12 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b33:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b37:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b3a:	89 c2                	mov    %eax,%edx
  801b3c:	c1 fa 1f             	sar    $0x1f,%edx
  801b3f:	89 d1                	mov    %edx,%ecx
  801b41:	c1 e9 1b             	shr    $0x1b,%ecx
  801b44:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b47:	83 e2 1f             	and    $0x1f,%edx
  801b4a:	29 ca                	sub    %ecx,%edx
  801b4c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b50:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b54:	83 c0 01             	add    $0x1,%eax
  801b57:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b5a:	83 c7 01             	add    $0x1,%edi
  801b5d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b60:	75 c2                	jne    801b24 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b62:	8b 45 10             	mov    0x10(%ebp),%eax
  801b65:	eb 05                	jmp    801b6c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b67:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5f                   	pop    %edi
  801b72:	5d                   	pop    %ebp
  801b73:	c3                   	ret    

00801b74 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b74:	55                   	push   %ebp
  801b75:	89 e5                	mov    %esp,%ebp
  801b77:	57                   	push   %edi
  801b78:	56                   	push   %esi
  801b79:	53                   	push   %ebx
  801b7a:	83 ec 18             	sub    $0x18,%esp
  801b7d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b80:	57                   	push   %edi
  801b81:	e8 89 f6 ff ff       	call   80120f <fd2data>
  801b86:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b90:	eb 3d                	jmp    801bcf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b92:	85 db                	test   %ebx,%ebx
  801b94:	74 04                	je     801b9a <devpipe_read+0x26>
				return i;
  801b96:	89 d8                	mov    %ebx,%eax
  801b98:	eb 44                	jmp    801bde <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b9a:	89 f2                	mov    %esi,%edx
  801b9c:	89 f8                	mov    %edi,%eax
  801b9e:	e8 e5 fe ff ff       	call   801a88 <_pipeisclosed>
  801ba3:	85 c0                	test   %eax,%eax
  801ba5:	75 32                	jne    801bd9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ba7:	e8 4b f1 ff ff       	call   800cf7 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bac:	8b 06                	mov    (%esi),%eax
  801bae:	3b 46 04             	cmp    0x4(%esi),%eax
  801bb1:	74 df                	je     801b92 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bb3:	99                   	cltd   
  801bb4:	c1 ea 1b             	shr    $0x1b,%edx
  801bb7:	01 d0                	add    %edx,%eax
  801bb9:	83 e0 1f             	and    $0x1f,%eax
  801bbc:	29 d0                	sub    %edx,%eax
  801bbe:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bc9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bcc:	83 c3 01             	add    $0x1,%ebx
  801bcf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bd2:	75 d8                	jne    801bac <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bd4:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd7:	eb 05                	jmp    801bde <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bd9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be1:	5b                   	pop    %ebx
  801be2:	5e                   	pop    %esi
  801be3:	5f                   	pop    %edi
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	56                   	push   %esi
  801bea:	53                   	push   %ebx
  801beb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bf1:	50                   	push   %eax
  801bf2:	e8 2f f6 ff ff       	call   801226 <fd_alloc>
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	89 c2                	mov    %eax,%edx
  801bfc:	85 c0                	test   %eax,%eax
  801bfe:	0f 88 2c 01 00 00    	js     801d30 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	68 07 04 00 00       	push   $0x407
  801c0c:	ff 75 f4             	pushl  -0xc(%ebp)
  801c0f:	6a 00                	push   $0x0
  801c11:	e8 00 f1 ff ff       	call   800d16 <sys_page_alloc>
  801c16:	83 c4 10             	add    $0x10,%esp
  801c19:	89 c2                	mov    %eax,%edx
  801c1b:	85 c0                	test   %eax,%eax
  801c1d:	0f 88 0d 01 00 00    	js     801d30 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c23:	83 ec 0c             	sub    $0xc,%esp
  801c26:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c29:	50                   	push   %eax
  801c2a:	e8 f7 f5 ff ff       	call   801226 <fd_alloc>
  801c2f:	89 c3                	mov    %eax,%ebx
  801c31:	83 c4 10             	add    $0x10,%esp
  801c34:	85 c0                	test   %eax,%eax
  801c36:	0f 88 e2 00 00 00    	js     801d1e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c3c:	83 ec 04             	sub    $0x4,%esp
  801c3f:	68 07 04 00 00       	push   $0x407
  801c44:	ff 75 f0             	pushl  -0x10(%ebp)
  801c47:	6a 00                	push   $0x0
  801c49:	e8 c8 f0 ff ff       	call   800d16 <sys_page_alloc>
  801c4e:	89 c3                	mov    %eax,%ebx
  801c50:	83 c4 10             	add    $0x10,%esp
  801c53:	85 c0                	test   %eax,%eax
  801c55:	0f 88 c3 00 00 00    	js     801d1e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c61:	e8 a9 f5 ff ff       	call   80120f <fd2data>
  801c66:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c68:	83 c4 0c             	add    $0xc,%esp
  801c6b:	68 07 04 00 00       	push   $0x407
  801c70:	50                   	push   %eax
  801c71:	6a 00                	push   $0x0
  801c73:	e8 9e f0 ff ff       	call   800d16 <sys_page_alloc>
  801c78:	89 c3                	mov    %eax,%ebx
  801c7a:	83 c4 10             	add    $0x10,%esp
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	0f 88 89 00 00 00    	js     801d0e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c85:	83 ec 0c             	sub    $0xc,%esp
  801c88:	ff 75 f0             	pushl  -0x10(%ebp)
  801c8b:	e8 7f f5 ff ff       	call   80120f <fd2data>
  801c90:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c97:	50                   	push   %eax
  801c98:	6a 00                	push   $0x0
  801c9a:	56                   	push   %esi
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 b7 f0 ff ff       	call   800d59 <sys_page_map>
  801ca2:	89 c3                	mov    %eax,%ebx
  801ca4:	83 c4 20             	add    $0x20,%esp
  801ca7:	85 c0                	test   %eax,%eax
  801ca9:	78 55                	js     801d00 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cab:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cc0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cc6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ccb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cce:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	ff 75 f4             	pushl  -0xc(%ebp)
  801cdb:	e8 1f f5 ff ff       	call   8011ff <fd2num>
  801ce0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ce5:	83 c4 04             	add    $0x4,%esp
  801ce8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ceb:	e8 0f f5 ff ff       	call   8011ff <fd2num>
  801cf0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cf6:	83 c4 10             	add    $0x10,%esp
  801cf9:	ba 00 00 00 00       	mov    $0x0,%edx
  801cfe:	eb 30                	jmp    801d30 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d00:	83 ec 08             	sub    $0x8,%esp
  801d03:	56                   	push   %esi
  801d04:	6a 00                	push   $0x0
  801d06:	e8 90 f0 ff ff       	call   800d9b <sys_page_unmap>
  801d0b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d0e:	83 ec 08             	sub    $0x8,%esp
  801d11:	ff 75 f0             	pushl  -0x10(%ebp)
  801d14:	6a 00                	push   $0x0
  801d16:	e8 80 f0 ff ff       	call   800d9b <sys_page_unmap>
  801d1b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d1e:	83 ec 08             	sub    $0x8,%esp
  801d21:	ff 75 f4             	pushl  -0xc(%ebp)
  801d24:	6a 00                	push   $0x0
  801d26:	e8 70 f0 ff ff       	call   800d9b <sys_page_unmap>
  801d2b:	83 c4 10             	add    $0x10,%esp
  801d2e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d30:	89 d0                	mov    %edx,%eax
  801d32:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d35:	5b                   	pop    %ebx
  801d36:	5e                   	pop    %esi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    

00801d39 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d39:	55                   	push   %ebp
  801d3a:	89 e5                	mov    %esp,%ebp
  801d3c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d42:	50                   	push   %eax
  801d43:	ff 75 08             	pushl  0x8(%ebp)
  801d46:	e8 2a f5 ff ff       	call   801275 <fd_lookup>
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	85 c0                	test   %eax,%eax
  801d50:	78 18                	js     801d6a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d52:	83 ec 0c             	sub    $0xc,%esp
  801d55:	ff 75 f4             	pushl  -0xc(%ebp)
  801d58:	e8 b2 f4 ff ff       	call   80120f <fd2data>
	return _pipeisclosed(fd, p);
  801d5d:	89 c2                	mov    %eax,%edx
  801d5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d62:	e8 21 fd ff ff       	call   801a88 <_pipeisclosed>
  801d67:	83 c4 10             	add    $0x10,%esp
}
  801d6a:	c9                   	leave  
  801d6b:	c3                   	ret    

00801d6c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d6c:	55                   	push   %ebp
  801d6d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d6f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d74:	5d                   	pop    %ebp
  801d75:	c3                   	ret    

00801d76 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d7c:	68 5e 29 80 00       	push   $0x80295e
  801d81:	ff 75 0c             	pushl  0xc(%ebp)
  801d84:	e8 8a eb ff ff       	call   800913 <strcpy>
	return 0;
}
  801d89:	b8 00 00 00 00       	mov    $0x0,%eax
  801d8e:	c9                   	leave  
  801d8f:	c3                   	ret    

00801d90 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d90:	55                   	push   %ebp
  801d91:	89 e5                	mov    %esp,%ebp
  801d93:	57                   	push   %edi
  801d94:	56                   	push   %esi
  801d95:	53                   	push   %ebx
  801d96:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da7:	eb 2d                	jmp    801dd6 <devcons_write+0x46>
		m = n - tot;
  801da9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801dac:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801dae:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801db1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801db6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db9:	83 ec 04             	sub    $0x4,%esp
  801dbc:	53                   	push   %ebx
  801dbd:	03 45 0c             	add    0xc(%ebp),%eax
  801dc0:	50                   	push   %eax
  801dc1:	57                   	push   %edi
  801dc2:	e8 de ec ff ff       	call   800aa5 <memmove>
		sys_cputs(buf, m);
  801dc7:	83 c4 08             	add    $0x8,%esp
  801dca:	53                   	push   %ebx
  801dcb:	57                   	push   %edi
  801dcc:	e8 89 ee ff ff       	call   800c5a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dd1:	01 de                	add    %ebx,%esi
  801dd3:	83 c4 10             	add    $0x10,%esp
  801dd6:	89 f0                	mov    %esi,%eax
  801dd8:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ddb:	72 cc                	jb     801da9 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de0:	5b                   	pop    %ebx
  801de1:	5e                   	pop    %esi
  801de2:	5f                   	pop    %edi
  801de3:	5d                   	pop    %ebp
  801de4:	c3                   	ret    

00801de5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801de5:	55                   	push   %ebp
  801de6:	89 e5                	mov    %esp,%ebp
  801de8:	83 ec 08             	sub    $0x8,%esp
  801deb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801df0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801df4:	74 2a                	je     801e20 <devcons_read+0x3b>
  801df6:	eb 05                	jmp    801dfd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801df8:	e8 fa ee ff ff       	call   800cf7 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dfd:	e8 76 ee ff ff       	call   800c78 <sys_cgetc>
  801e02:	85 c0                	test   %eax,%eax
  801e04:	74 f2                	je     801df8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e06:	85 c0                	test   %eax,%eax
  801e08:	78 16                	js     801e20 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e0a:	83 f8 04             	cmp    $0x4,%eax
  801e0d:	74 0c                	je     801e1b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e12:	88 02                	mov    %al,(%edx)
	return 1;
  801e14:	b8 01 00 00 00       	mov    $0x1,%eax
  801e19:	eb 05                	jmp    801e20 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e1b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e20:	c9                   	leave  
  801e21:	c3                   	ret    

00801e22 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e22:	55                   	push   %ebp
  801e23:	89 e5                	mov    %esp,%ebp
  801e25:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e28:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e2e:	6a 01                	push   $0x1
  801e30:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e33:	50                   	push   %eax
  801e34:	e8 21 ee ff ff       	call   800c5a <sys_cputs>
}
  801e39:	83 c4 10             	add    $0x10,%esp
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <getchar>:

int
getchar(void)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e44:	6a 01                	push   $0x1
  801e46:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e49:	50                   	push   %eax
  801e4a:	6a 00                	push   $0x0
  801e4c:	e8 8a f6 ff ff       	call   8014db <read>
	if (r < 0)
  801e51:	83 c4 10             	add    $0x10,%esp
  801e54:	85 c0                	test   %eax,%eax
  801e56:	78 0f                	js     801e67 <getchar+0x29>
		return r;
	if (r < 1)
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	7e 06                	jle    801e62 <getchar+0x24>
		return -E_EOF;
	return c;
  801e5c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e60:	eb 05                	jmp    801e67 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e62:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e67:	c9                   	leave  
  801e68:	c3                   	ret    

00801e69 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e69:	55                   	push   %ebp
  801e6a:	89 e5                	mov    %esp,%ebp
  801e6c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e72:	50                   	push   %eax
  801e73:	ff 75 08             	pushl  0x8(%ebp)
  801e76:	e8 fa f3 ff ff       	call   801275 <fd_lookup>
  801e7b:	83 c4 10             	add    $0x10,%esp
  801e7e:	85 c0                	test   %eax,%eax
  801e80:	78 11                	js     801e93 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e8b:	39 10                	cmp    %edx,(%eax)
  801e8d:	0f 94 c0             	sete   %al
  801e90:	0f b6 c0             	movzbl %al,%eax
}
  801e93:	c9                   	leave  
  801e94:	c3                   	ret    

00801e95 <opencons>:

int
opencons(void)
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	e8 82 f3 ff ff       	call   801226 <fd_alloc>
  801ea4:	83 c4 10             	add    $0x10,%esp
		return r;
  801ea7:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea9:	85 c0                	test   %eax,%eax
  801eab:	78 3e                	js     801eeb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ead:	83 ec 04             	sub    $0x4,%esp
  801eb0:	68 07 04 00 00       	push   $0x407
  801eb5:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb8:	6a 00                	push   $0x0
  801eba:	e8 57 ee ff ff       	call   800d16 <sys_page_alloc>
  801ebf:	83 c4 10             	add    $0x10,%esp
		return r;
  801ec2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ec4:	85 c0                	test   %eax,%eax
  801ec6:	78 23                	js     801eeb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ec8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ed3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ed6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801edd:	83 ec 0c             	sub    $0xc,%esp
  801ee0:	50                   	push   %eax
  801ee1:	e8 19 f3 ff ff       	call   8011ff <fd2num>
  801ee6:	89 c2                	mov    %eax,%edx
  801ee8:	83 c4 10             	add    $0x10,%esp
}
  801eeb:	89 d0                	mov    %edx,%eax
  801eed:	c9                   	leave  
  801eee:	c3                   	ret    

00801eef <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eef:	55                   	push   %ebp
  801ef0:	89 e5                	mov    %esp,%ebp
  801ef2:	53                   	push   %ebx
  801ef3:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801ef6:	e8 dd ed ff ff       	call   800cd8 <sys_getenvid>
  801efb:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801efd:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f04:	75 29                	jne    801f2f <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801f06:	83 ec 04             	sub    $0x4,%esp
  801f09:	6a 07                	push   $0x7
  801f0b:	68 00 f0 bf ee       	push   $0xeebff000
  801f10:	50                   	push   %eax
  801f11:	e8 00 ee ff ff       	call   800d16 <sys_page_alloc>
  801f16:	83 c4 10             	add    $0x10,%esp
  801f19:	85 c0                	test   %eax,%eax
  801f1b:	79 12                	jns    801f2f <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801f1d:	50                   	push   %eax
  801f1e:	68 6a 29 80 00       	push   $0x80296a
  801f23:	6a 24                	push   $0x24
  801f25:	68 83 29 80 00       	push   $0x802983
  801f2a:	e8 07 e3 ff ff       	call   800236 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f32:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801f37:	83 ec 08             	sub    $0x8,%esp
  801f3a:	68 63 1f 80 00       	push   $0x801f63
  801f3f:	53                   	push   %ebx
  801f40:	e8 1c ef ff ff       	call   800e61 <sys_env_set_pgfault_upcall>
  801f45:	83 c4 10             	add    $0x10,%esp
  801f48:	85 c0                	test   %eax,%eax
  801f4a:	79 12                	jns    801f5e <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801f4c:	50                   	push   %eax
  801f4d:	68 6a 29 80 00       	push   $0x80296a
  801f52:	6a 2e                	push   $0x2e
  801f54:	68 83 29 80 00       	push   $0x802983
  801f59:	e8 d8 e2 ff ff       	call   800236 <_panic>
}
  801f5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f61:	c9                   	leave  
  801f62:	c3                   	ret    

00801f63 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f63:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f64:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f69:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f6b:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801f6e:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801f72:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  801f75:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801f79:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801f7b:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801f7f:	83 c4 08             	add    $0x8,%esp
	popal
  801f82:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801f83:	83 c4 04             	add    $0x4,%esp
	popfl
  801f86:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  801f87:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f88:	c3                   	ret    

00801f89 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f89:	55                   	push   %ebp
  801f8a:	89 e5                	mov    %esp,%ebp
  801f8c:	57                   	push   %edi
  801f8d:	56                   	push   %esi
  801f8e:	53                   	push   %ebx
  801f8f:	83 ec 0c             	sub    $0xc,%esp
  801f92:	8b 75 08             	mov    0x8(%ebp),%esi
  801f95:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801f9b:	85 f6                	test   %esi,%esi
  801f9d:	74 06                	je     801fa5 <ipc_recv+0x1c>
		*from_env_store = 0;
  801f9f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801fa5:	85 db                	test   %ebx,%ebx
  801fa7:	74 06                	je     801faf <ipc_recv+0x26>
		*perm_store = 0;
  801fa9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801faf:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801fb1:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801fb6:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801fb9:	83 ec 0c             	sub    $0xc,%esp
  801fbc:	50                   	push   %eax
  801fbd:	e8 04 ef ff ff       	call   800ec6 <sys_ipc_recv>
  801fc2:	89 c7                	mov    %eax,%edi
  801fc4:	83 c4 10             	add    $0x10,%esp
  801fc7:	85 c0                	test   %eax,%eax
  801fc9:	79 14                	jns    801fdf <ipc_recv+0x56>
		cprintf("im dead");
  801fcb:	83 ec 0c             	sub    $0xc,%esp
  801fce:	68 91 29 80 00       	push   $0x802991
  801fd3:	e8 37 e3 ff ff       	call   80030f <cprintf>
		return r;
  801fd8:	83 c4 10             	add    $0x10,%esp
  801fdb:	89 f8                	mov    %edi,%eax
  801fdd:	eb 24                	jmp    802003 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801fdf:	85 f6                	test   %esi,%esi
  801fe1:	74 0a                	je     801fed <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801fe3:	a1 04 40 80 00       	mov    0x804004,%eax
  801fe8:	8b 40 74             	mov    0x74(%eax),%eax
  801feb:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801fed:	85 db                	test   %ebx,%ebx
  801fef:	74 0a                	je     801ffb <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ff1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ff6:	8b 40 78             	mov    0x78(%eax),%eax
  801ff9:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801ffb:	a1 04 40 80 00       	mov    0x804004,%eax
  802000:	8b 40 70             	mov    0x70(%eax),%eax
}
  802003:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802006:	5b                   	pop    %ebx
  802007:	5e                   	pop    %esi
  802008:	5f                   	pop    %edi
  802009:	5d                   	pop    %ebp
  80200a:	c3                   	ret    

0080200b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80200b:	55                   	push   %ebp
  80200c:	89 e5                	mov    %esp,%ebp
  80200e:	57                   	push   %edi
  80200f:	56                   	push   %esi
  802010:	53                   	push   %ebx
  802011:	83 ec 0c             	sub    $0xc,%esp
  802014:	8b 7d 08             	mov    0x8(%ebp),%edi
  802017:	8b 75 0c             	mov    0xc(%ebp),%esi
  80201a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  80201d:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  80201f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  802024:	0f 44 d8             	cmove  %eax,%ebx
  802027:	eb 1c                	jmp    802045 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  802029:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80202c:	74 12                	je     802040 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  80202e:	50                   	push   %eax
  80202f:	68 99 29 80 00       	push   $0x802999
  802034:	6a 4e                	push   $0x4e
  802036:	68 a6 29 80 00       	push   $0x8029a6
  80203b:	e8 f6 e1 ff ff       	call   800236 <_panic>
		sys_yield();
  802040:	e8 b2 ec ff ff       	call   800cf7 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802045:	ff 75 14             	pushl  0x14(%ebp)
  802048:	53                   	push   %ebx
  802049:	56                   	push   %esi
  80204a:	57                   	push   %edi
  80204b:	e8 53 ee ff ff       	call   800ea3 <sys_ipc_try_send>
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	85 c0                	test   %eax,%eax
  802055:	78 d2                	js     802029 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  802057:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80205a:	5b                   	pop    %ebx
  80205b:	5e                   	pop    %esi
  80205c:	5f                   	pop    %edi
  80205d:	5d                   	pop    %ebp
  80205e:	c3                   	ret    

0080205f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802065:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80206a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80206d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802073:	8b 52 50             	mov    0x50(%edx),%edx
  802076:	39 ca                	cmp    %ecx,%edx
  802078:	75 0d                	jne    802087 <ipc_find_env+0x28>
			return envs[i].env_id;
  80207a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80207d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802082:	8b 40 48             	mov    0x48(%eax),%eax
  802085:	eb 0f                	jmp    802096 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802087:	83 c0 01             	add    $0x1,%eax
  80208a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80208f:	75 d9                	jne    80206a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802091:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    

00802098 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80209e:	89 d0                	mov    %edx,%eax
  8020a0:	c1 e8 16             	shr    $0x16,%eax
  8020a3:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020aa:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020af:	f6 c1 01             	test   $0x1,%cl
  8020b2:	74 1d                	je     8020d1 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020b4:	c1 ea 0c             	shr    $0xc,%edx
  8020b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020be:	f6 c2 01             	test   $0x1,%dl
  8020c1:	74 0e                	je     8020d1 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020c3:	c1 ea 0c             	shr    $0xc,%edx
  8020c6:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020cd:	ef 
  8020ce:	0f b7 c0             	movzwl %ax,%eax
}
  8020d1:	5d                   	pop    %ebp
  8020d2:	c3                   	ret    
  8020d3:	66 90                	xchg   %ax,%ax
  8020d5:	66 90                	xchg   %ax,%ax
  8020d7:	66 90                	xchg   %ax,%ax
  8020d9:	66 90                	xchg   %ax,%ax
  8020db:	66 90                	xchg   %ax,%ax
  8020dd:	66 90                	xchg   %ax,%ax
  8020df:	90                   	nop

008020e0 <__udivdi3>:
  8020e0:	55                   	push   %ebp
  8020e1:	57                   	push   %edi
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
  8020e4:	83 ec 1c             	sub    $0x1c,%esp
  8020e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8020eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8020ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8020f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8020f7:	85 f6                	test   %esi,%esi
  8020f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8020fd:	89 ca                	mov    %ecx,%edx
  8020ff:	89 f8                	mov    %edi,%eax
  802101:	75 3d                	jne    802140 <__udivdi3+0x60>
  802103:	39 cf                	cmp    %ecx,%edi
  802105:	0f 87 c5 00 00 00    	ja     8021d0 <__udivdi3+0xf0>
  80210b:	85 ff                	test   %edi,%edi
  80210d:	89 fd                	mov    %edi,%ebp
  80210f:	75 0b                	jne    80211c <__udivdi3+0x3c>
  802111:	b8 01 00 00 00       	mov    $0x1,%eax
  802116:	31 d2                	xor    %edx,%edx
  802118:	f7 f7                	div    %edi
  80211a:	89 c5                	mov    %eax,%ebp
  80211c:	89 c8                	mov    %ecx,%eax
  80211e:	31 d2                	xor    %edx,%edx
  802120:	f7 f5                	div    %ebp
  802122:	89 c1                	mov    %eax,%ecx
  802124:	89 d8                	mov    %ebx,%eax
  802126:	89 cf                	mov    %ecx,%edi
  802128:	f7 f5                	div    %ebp
  80212a:	89 c3                	mov    %eax,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	39 ce                	cmp    %ecx,%esi
  802142:	77 74                	ja     8021b8 <__udivdi3+0xd8>
  802144:	0f bd fe             	bsr    %esi,%edi
  802147:	83 f7 1f             	xor    $0x1f,%edi
  80214a:	0f 84 98 00 00 00    	je     8021e8 <__udivdi3+0x108>
  802150:	bb 20 00 00 00       	mov    $0x20,%ebx
  802155:	89 f9                	mov    %edi,%ecx
  802157:	89 c5                	mov    %eax,%ebp
  802159:	29 fb                	sub    %edi,%ebx
  80215b:	d3 e6                	shl    %cl,%esi
  80215d:	89 d9                	mov    %ebx,%ecx
  80215f:	d3 ed                	shr    %cl,%ebp
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e0                	shl    %cl,%eax
  802165:	09 ee                	or     %ebp,%esi
  802167:	89 d9                	mov    %ebx,%ecx
  802169:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80216d:	89 d5                	mov    %edx,%ebp
  80216f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802173:	d3 ed                	shr    %cl,%ebp
  802175:	89 f9                	mov    %edi,%ecx
  802177:	d3 e2                	shl    %cl,%edx
  802179:	89 d9                	mov    %ebx,%ecx
  80217b:	d3 e8                	shr    %cl,%eax
  80217d:	09 c2                	or     %eax,%edx
  80217f:	89 d0                	mov    %edx,%eax
  802181:	89 ea                	mov    %ebp,%edx
  802183:	f7 f6                	div    %esi
  802185:	89 d5                	mov    %edx,%ebp
  802187:	89 c3                	mov    %eax,%ebx
  802189:	f7 64 24 0c          	mull   0xc(%esp)
  80218d:	39 d5                	cmp    %edx,%ebp
  80218f:	72 10                	jb     8021a1 <__udivdi3+0xc1>
  802191:	8b 74 24 08          	mov    0x8(%esp),%esi
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e6                	shl    %cl,%esi
  802199:	39 c6                	cmp    %eax,%esi
  80219b:	73 07                	jae    8021a4 <__udivdi3+0xc4>
  80219d:	39 d5                	cmp    %edx,%ebp
  80219f:	75 03                	jne    8021a4 <__udivdi3+0xc4>
  8021a1:	83 eb 01             	sub    $0x1,%ebx
  8021a4:	31 ff                	xor    %edi,%edi
  8021a6:	89 d8                	mov    %ebx,%eax
  8021a8:	89 fa                	mov    %edi,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	31 ff                	xor    %edi,%edi
  8021ba:	31 db                	xor    %ebx,%ebx
  8021bc:	89 d8                	mov    %ebx,%eax
  8021be:	89 fa                	mov    %edi,%edx
  8021c0:	83 c4 1c             	add    $0x1c,%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	90                   	nop
  8021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 d8                	mov    %ebx,%eax
  8021d2:	f7 f7                	div    %edi
  8021d4:	31 ff                	xor    %edi,%edi
  8021d6:	89 c3                	mov    %eax,%ebx
  8021d8:	89 d8                	mov    %ebx,%eax
  8021da:	89 fa                	mov    %edi,%edx
  8021dc:	83 c4 1c             	add    $0x1c,%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    
  8021e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e8:	39 ce                	cmp    %ecx,%esi
  8021ea:	72 0c                	jb     8021f8 <__udivdi3+0x118>
  8021ec:	31 db                	xor    %ebx,%ebx
  8021ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8021f2:	0f 87 34 ff ff ff    	ja     80212c <__udivdi3+0x4c>
  8021f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8021fd:	e9 2a ff ff ff       	jmp    80212c <__udivdi3+0x4c>
  802202:	66 90                	xchg   %ax,%ax
  802204:	66 90                	xchg   %ax,%ax
  802206:	66 90                	xchg   %ax,%ax
  802208:	66 90                	xchg   %ax,%ax
  80220a:	66 90                	xchg   %ax,%ax
  80220c:	66 90                	xchg   %ax,%ax
  80220e:	66 90                	xchg   %ax,%ax

00802210 <__umoddi3>:
  802210:	55                   	push   %ebp
  802211:	57                   	push   %edi
  802212:	56                   	push   %esi
  802213:	53                   	push   %ebx
  802214:	83 ec 1c             	sub    $0x1c,%esp
  802217:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80221b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80221f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802223:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802227:	85 d2                	test   %edx,%edx
  802229:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f3                	mov    %esi,%ebx
  802233:	89 3c 24             	mov    %edi,(%esp)
  802236:	89 74 24 04          	mov    %esi,0x4(%esp)
  80223a:	75 1c                	jne    802258 <__umoddi3+0x48>
  80223c:	39 f7                	cmp    %esi,%edi
  80223e:	76 50                	jbe    802290 <__umoddi3+0x80>
  802240:	89 c8                	mov    %ecx,%eax
  802242:	89 f2                	mov    %esi,%edx
  802244:	f7 f7                	div    %edi
  802246:	89 d0                	mov    %edx,%eax
  802248:	31 d2                	xor    %edx,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	39 f2                	cmp    %esi,%edx
  80225a:	89 d0                	mov    %edx,%eax
  80225c:	77 52                	ja     8022b0 <__umoddi3+0xa0>
  80225e:	0f bd ea             	bsr    %edx,%ebp
  802261:	83 f5 1f             	xor    $0x1f,%ebp
  802264:	75 5a                	jne    8022c0 <__umoddi3+0xb0>
  802266:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80226a:	0f 82 e0 00 00 00    	jb     802350 <__umoddi3+0x140>
  802270:	39 0c 24             	cmp    %ecx,(%esp)
  802273:	0f 86 d7 00 00 00    	jbe    802350 <__umoddi3+0x140>
  802279:	8b 44 24 08          	mov    0x8(%esp),%eax
  80227d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	85 ff                	test   %edi,%edi
  802292:	89 fd                	mov    %edi,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x91>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f7                	div    %edi
  80229f:	89 c5                	mov    %eax,%ebp
  8022a1:	89 f0                	mov    %esi,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f5                	div    %ebp
  8022a7:	89 c8                	mov    %ecx,%eax
  8022a9:	f7 f5                	div    %ebp
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	eb 99                	jmp    802248 <__umoddi3+0x38>
  8022af:	90                   	nop
  8022b0:	89 c8                	mov    %ecx,%eax
  8022b2:	89 f2                	mov    %esi,%edx
  8022b4:	83 c4 1c             	add    $0x1c,%esp
  8022b7:	5b                   	pop    %ebx
  8022b8:	5e                   	pop    %esi
  8022b9:	5f                   	pop    %edi
  8022ba:	5d                   	pop    %ebp
  8022bb:	c3                   	ret    
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	8b 34 24             	mov    (%esp),%esi
  8022c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022c8:	89 e9                	mov    %ebp,%ecx
  8022ca:	29 ef                	sub    %ebp,%edi
  8022cc:	d3 e0                	shl    %cl,%eax
  8022ce:	89 f9                	mov    %edi,%ecx
  8022d0:	89 f2                	mov    %esi,%edx
  8022d2:	d3 ea                	shr    %cl,%edx
  8022d4:	89 e9                	mov    %ebp,%ecx
  8022d6:	09 c2                	or     %eax,%edx
  8022d8:	89 d8                	mov    %ebx,%eax
  8022da:	89 14 24             	mov    %edx,(%esp)
  8022dd:	89 f2                	mov    %esi,%edx
  8022df:	d3 e2                	shl    %cl,%edx
  8022e1:	89 f9                	mov    %edi,%ecx
  8022e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8022e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8022eb:	d3 e8                	shr    %cl,%eax
  8022ed:	89 e9                	mov    %ebp,%ecx
  8022ef:	89 c6                	mov    %eax,%esi
  8022f1:	d3 e3                	shl    %cl,%ebx
  8022f3:	89 f9                	mov    %edi,%ecx
  8022f5:	89 d0                	mov    %edx,%eax
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 e9                	mov    %ebp,%ecx
  8022fb:	09 d8                	or     %ebx,%eax
  8022fd:	89 d3                	mov    %edx,%ebx
  8022ff:	89 f2                	mov    %esi,%edx
  802301:	f7 34 24             	divl   (%esp)
  802304:	89 d6                	mov    %edx,%esi
  802306:	d3 e3                	shl    %cl,%ebx
  802308:	f7 64 24 04          	mull   0x4(%esp)
  80230c:	39 d6                	cmp    %edx,%esi
  80230e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802312:	89 d1                	mov    %edx,%ecx
  802314:	89 c3                	mov    %eax,%ebx
  802316:	72 08                	jb     802320 <__umoddi3+0x110>
  802318:	75 11                	jne    80232b <__umoddi3+0x11b>
  80231a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80231e:	73 0b                	jae    80232b <__umoddi3+0x11b>
  802320:	2b 44 24 04          	sub    0x4(%esp),%eax
  802324:	1b 14 24             	sbb    (%esp),%edx
  802327:	89 d1                	mov    %edx,%ecx
  802329:	89 c3                	mov    %eax,%ebx
  80232b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80232f:	29 da                	sub    %ebx,%edx
  802331:	19 ce                	sbb    %ecx,%esi
  802333:	89 f9                	mov    %edi,%ecx
  802335:	89 f0                	mov    %esi,%eax
  802337:	d3 e0                	shl    %cl,%eax
  802339:	89 e9                	mov    %ebp,%ecx
  80233b:	d3 ea                	shr    %cl,%edx
  80233d:	89 e9                	mov    %ebp,%ecx
  80233f:	d3 ee                	shr    %cl,%esi
  802341:	09 d0                	or     %edx,%eax
  802343:	89 f2                	mov    %esi,%edx
  802345:	83 c4 1c             	add    $0x1c,%esp
  802348:	5b                   	pop    %ebx
  802349:	5e                   	pop    %esi
  80234a:	5f                   	pop    %edi
  80234b:	5d                   	pop    %ebp
  80234c:	c3                   	ret    
  80234d:	8d 76 00             	lea    0x0(%esi),%esi
  802350:	29 f9                	sub    %edi,%ecx
  802352:	19 d6                	sbb    %edx,%esi
  802354:	89 74 24 04          	mov    %esi,0x4(%esp)
  802358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235c:	e9 18 ff ff ff       	jmp    802279 <__umoddi3+0x69>
