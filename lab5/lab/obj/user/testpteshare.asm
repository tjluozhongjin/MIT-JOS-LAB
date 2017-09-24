
obj/user/testpteshare.debug:     file format elf32-i386


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
  80002c:	e8 47 01 00 00       	call   800178 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <childofspawn>:
	breakpoint();
}

void
childofspawn(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	strcpy(VA, msg2);
  800039:	ff 35 00 40 80 00    	pushl  0x804000
  80003f:	68 00 00 00 a0       	push   $0xa0000000
  800044:	e8 6c 08 00 00       	call   8008b5 <strcpy>
	exit();
  800049:	e8 70 01 00 00       	call   8001be <exit>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	c9                   	leave  
  800052:	c3                   	ret    

00800053 <umain>:

void childofspawn(void);

void
umain(int argc, char **argv)
{
  800053:	55                   	push   %ebp
  800054:	89 e5                	mov    %esp,%ebp
  800056:	53                   	push   %ebx
  800057:	83 ec 04             	sub    $0x4,%esp
	int r;

	if (argc != 0)
  80005a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80005e:	74 05                	je     800065 <umain+0x12>
		childofspawn();
  800060:	e8 ce ff ff ff       	call   800033 <childofspawn>

	if ((r = sys_page_alloc(0, VA, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800065:	83 ec 04             	sub    $0x4,%esp
  800068:	68 07 04 00 00       	push   $0x407
  80006d:	68 00 00 00 a0       	push   $0xa0000000
  800072:	6a 00                	push   $0x0
  800074:	e8 3f 0c 00 00       	call   800cb8 <sys_page_alloc>
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 12                	jns    800092 <umain+0x3f>
		panic("sys_page_alloc: %e", r);
  800080:	50                   	push   %eax
  800081:	68 4c 29 80 00       	push   $0x80294c
  800086:	6a 13                	push   $0x13
  800088:	68 5f 29 80 00       	push   $0x80295f
  80008d:	e8 46 01 00 00       	call   8001d8 <_panic>

	// check fork
	if ((r = fork()) < 0)
  800092:	e8 0c 0f 00 00       	call   800fa3 <fork>
  800097:	89 c3                	mov    %eax,%ebx
  800099:	85 c0                	test   %eax,%eax
  80009b:	79 12                	jns    8000af <umain+0x5c>
		panic("fork: %e", r);
  80009d:	50                   	push   %eax
  80009e:	68 73 29 80 00       	push   $0x802973
  8000a3:	6a 17                	push   $0x17
  8000a5:	68 5f 29 80 00       	push   $0x80295f
  8000aa:	e8 29 01 00 00       	call   8001d8 <_panic>
	if (r == 0) {
  8000af:	85 c0                	test   %eax,%eax
  8000b1:	75 1b                	jne    8000ce <umain+0x7b>
		strcpy(VA, msg);
  8000b3:	83 ec 08             	sub    $0x8,%esp
  8000b6:	ff 35 04 40 80 00    	pushl  0x804004
  8000bc:	68 00 00 00 a0       	push   $0xa0000000
  8000c1:	e8 ef 07 00 00       	call   8008b5 <strcpy>
		exit();
  8000c6:	e8 f3 00 00 00       	call   8001be <exit>
  8000cb:	83 c4 10             	add    $0x10,%esp
	}
	wait(r);
  8000ce:	83 ec 0c             	sub    $0xc,%esp
  8000d1:	53                   	push   %ebx
  8000d2:	e8 15 22 00 00       	call   8022ec <wait>
	cprintf("fork handles PTE_SHARE %s\n", strcmp(VA, msg) == 0 ? "right" : "wrong");
  8000d7:	83 c4 08             	add    $0x8,%esp
  8000da:	ff 35 04 40 80 00    	pushl  0x804004
  8000e0:	68 00 00 00 a0       	push   $0xa0000000
  8000e5:	e8 75 08 00 00       	call   80095f <strcmp>
  8000ea:	83 c4 08             	add    $0x8,%esp
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	ba 46 29 80 00       	mov    $0x802946,%edx
  8000f4:	b8 40 29 80 00       	mov    $0x802940,%eax
  8000f9:	0f 45 c2             	cmovne %edx,%eax
  8000fc:	50                   	push   %eax
  8000fd:	68 7c 29 80 00       	push   $0x80297c
  800102:	e8 aa 01 00 00       	call   8002b1 <cprintf>

	// check spawn
	if ((r = spawnl("/testpteshare", "testpteshare", "arg", 0)) < 0)
  800107:	6a 00                	push   $0x0
  800109:	68 97 29 80 00       	push   $0x802997
  80010e:	68 9c 29 80 00       	push   $0x80299c
  800113:	68 9b 29 80 00       	push   $0x80299b
  800118:	e8 00 1e 00 00       	call   801f1d <spawnl>
  80011d:	83 c4 20             	add    $0x20,%esp
  800120:	85 c0                	test   %eax,%eax
  800122:	79 12                	jns    800136 <umain+0xe3>
		panic("spawn: %e", r);
  800124:	50                   	push   %eax
  800125:	68 a9 29 80 00       	push   $0x8029a9
  80012a:	6a 21                	push   $0x21
  80012c:	68 5f 29 80 00       	push   $0x80295f
  800131:	e8 a2 00 00 00       	call   8001d8 <_panic>
	wait(r);
  800136:	83 ec 0c             	sub    $0xc,%esp
  800139:	50                   	push   %eax
  80013a:	e8 ad 21 00 00       	call   8022ec <wait>
	cprintf("spawn handles PTE_SHARE %s\n", strcmp(VA, msg2) == 0 ? "right" : "wrong");
  80013f:	83 c4 08             	add    $0x8,%esp
  800142:	ff 35 00 40 80 00    	pushl  0x804000
  800148:	68 00 00 00 a0       	push   $0xa0000000
  80014d:	e8 0d 08 00 00       	call   80095f <strcmp>
  800152:	83 c4 08             	add    $0x8,%esp
  800155:	85 c0                	test   %eax,%eax
  800157:	ba 46 29 80 00       	mov    $0x802946,%edx
  80015c:	b8 40 29 80 00       	mov    $0x802940,%eax
  800161:	0f 45 c2             	cmovne %edx,%eax
  800164:	50                   	push   %eax
  800165:	68 b3 29 80 00       	push   $0x8029b3
  80016a:	e8 42 01 00 00       	call   8002b1 <cprintf>
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  80016f:	cc                   	int3   

	breakpoint();
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	56                   	push   %esi
  80017c:	53                   	push   %ebx
  80017d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800180:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800183:	e8 f2 0a 00 00       	call   800c7a <sys_getenvid>
  800188:	25 ff 03 00 00       	and    $0x3ff,%eax
  80018d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800190:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800195:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80019a:	85 db                	test   %ebx,%ebx
  80019c:	7e 07                	jle    8001a5 <libmain+0x2d>
		binaryname = argv[0];
  80019e:	8b 06                	mov    (%esi),%eax
  8001a0:	a3 08 40 80 00       	mov    %eax,0x804008

	// call user main routine
	umain(argc, argv);
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
  8001aa:	e8 a4 fe ff ff       	call   800053 <umain>

	// exit gracefully
	exit();
  8001af:	e8 0a 00 00 00       	call   8001be <exit>
}
  8001b4:	83 c4 10             	add    $0x10,%esp
  8001b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5d                   	pop    %ebp
  8001bd:	c3                   	ret    

008001be <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8001c4:	e8 a3 11 00 00       	call   80136c <close_all>
	sys_env_destroy(0);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	6a 00                	push   $0x0
  8001ce:	e8 66 0a 00 00       	call   800c39 <sys_env_destroy>
}
  8001d3:	83 c4 10             	add    $0x10,%esp
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001dd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001e0:	8b 35 08 40 80 00    	mov    0x804008,%esi
  8001e6:	e8 8f 0a 00 00       	call   800c7a <sys_getenvid>
  8001eb:	83 ec 0c             	sub    $0xc,%esp
  8001ee:	ff 75 0c             	pushl  0xc(%ebp)
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	56                   	push   %esi
  8001f5:	50                   	push   %eax
  8001f6:	68 f8 29 80 00       	push   $0x8029f8
  8001fb:	e8 b1 00 00 00       	call   8002b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800200:	83 c4 18             	add    $0x18,%esp
  800203:	53                   	push   %ebx
  800204:	ff 75 10             	pushl  0x10(%ebp)
  800207:	e8 54 00 00 00       	call   800260 <vcprintf>
	cprintf("\n");
  80020c:	c7 04 24 a8 2f 80 00 	movl   $0x802fa8,(%esp)
  800213:	e8 99 00 00 00       	call   8002b1 <cprintf>
  800218:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80021b:	cc                   	int3   
  80021c:	eb fd                	jmp    80021b <_panic+0x43>

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 04             	sub    $0x4,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 13                	mov    (%ebx),%edx
  80022a:	8d 42 01             	lea    0x1(%edx),%eax
  80022d:	89 03                	mov    %eax,(%ebx)
  80022f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800232:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 1a                	jne    800257 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80023d:	83 ec 08             	sub    $0x8,%esp
  800240:	68 ff 00 00 00       	push   $0xff
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	50                   	push   %eax
  800249:	e8 ae 09 00 00       	call   800bfc <sys_cputs>
		b->idx = 0;
  80024e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800254:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800257:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800269:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800270:	00 00 00 
	b.cnt = 0;
  800273:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80027a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80027d:	ff 75 0c             	pushl  0xc(%ebp)
  800280:	ff 75 08             	pushl  0x8(%ebp)
  800283:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800289:	50                   	push   %eax
  80028a:	68 1e 02 80 00       	push   $0x80021e
  80028f:	e8 1a 01 00 00       	call   8003ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800294:	83 c4 08             	add    $0x8,%esp
  800297:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80029d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 53 09 00 00       	call   800bfc <sys_cputs>

	return b.cnt;
}
  8002a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ba:	50                   	push   %eax
  8002bb:	ff 75 08             	pushl  0x8(%ebp)
  8002be:	e8 9d ff ff ff       	call   800260 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    

008002c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002c5:	55                   	push   %ebp
  8002c6:	89 e5                	mov    %esp,%ebp
  8002c8:	57                   	push   %edi
  8002c9:	56                   	push   %esi
  8002ca:	53                   	push   %ebx
  8002cb:	83 ec 1c             	sub    $0x1c,%esp
  8002ce:	89 c7                	mov    %eax,%edi
  8002d0:	89 d6                	mov    %edx,%esi
  8002d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8002e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8002ec:	39 d3                	cmp    %edx,%ebx
  8002ee:	72 05                	jb     8002f5 <printnum+0x30>
  8002f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8002f3:	77 45                	ja     80033a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f5:	83 ec 0c             	sub    $0xc,%esp
  8002f8:	ff 75 18             	pushl  0x18(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800301:	53                   	push   %ebx
  800302:	ff 75 10             	pushl  0x10(%ebp)
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	ff 75 e4             	pushl  -0x1c(%ebp)
  80030b:	ff 75 e0             	pushl  -0x20(%ebp)
  80030e:	ff 75 dc             	pushl  -0x24(%ebp)
  800311:	ff 75 d8             	pushl  -0x28(%ebp)
  800314:	e8 97 23 00 00       	call   8026b0 <__udivdi3>
  800319:	83 c4 18             	add    $0x18,%esp
  80031c:	52                   	push   %edx
  80031d:	50                   	push   %eax
  80031e:	89 f2                	mov    %esi,%edx
  800320:	89 f8                	mov    %edi,%eax
  800322:	e8 9e ff ff ff       	call   8002c5 <printnum>
  800327:	83 c4 20             	add    $0x20,%esp
  80032a:	eb 18                	jmp    800344 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80032c:	83 ec 08             	sub    $0x8,%esp
  80032f:	56                   	push   %esi
  800330:	ff 75 18             	pushl  0x18(%ebp)
  800333:	ff d7                	call   *%edi
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	eb 03                	jmp    80033d <printnum+0x78>
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80033d:	83 eb 01             	sub    $0x1,%ebx
  800340:	85 db                	test   %ebx,%ebx
  800342:	7f e8                	jg     80032c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800344:	83 ec 08             	sub    $0x8,%esp
  800347:	56                   	push   %esi
  800348:	83 ec 04             	sub    $0x4,%esp
  80034b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80034e:	ff 75 e0             	pushl  -0x20(%ebp)
  800351:	ff 75 dc             	pushl  -0x24(%ebp)
  800354:	ff 75 d8             	pushl  -0x28(%ebp)
  800357:	e8 84 24 00 00       	call   8027e0 <__umoddi3>
  80035c:	83 c4 14             	add    $0x14,%esp
  80035f:	0f be 80 1b 2a 80 00 	movsbl 0x802a1b(%eax),%eax
  800366:	50                   	push   %eax
  800367:	ff d7                	call   *%edi
}
  800369:	83 c4 10             	add    $0x10,%esp
  80036c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036f:	5b                   	pop    %ebx
  800370:	5e                   	pop    %esi
  800371:	5f                   	pop    %edi
  800372:	5d                   	pop    %ebp
  800373:	c3                   	ret    

00800374 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800374:	55                   	push   %ebp
  800375:	89 e5                	mov    %esp,%ebp
  800377:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80037a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	3b 50 04             	cmp    0x4(%eax),%edx
  800383:	73 0a                	jae    80038f <sprintputch+0x1b>
		*b->buf++ = ch;
  800385:	8d 4a 01             	lea    0x1(%edx),%ecx
  800388:	89 08                	mov    %ecx,(%eax)
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	88 02                	mov    %al,(%edx)
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800397:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80039a:	50                   	push   %eax
  80039b:	ff 75 10             	pushl  0x10(%ebp)
  80039e:	ff 75 0c             	pushl  0xc(%ebp)
  8003a1:	ff 75 08             	pushl  0x8(%ebp)
  8003a4:	e8 05 00 00 00       	call   8003ae <vprintfmt>
	va_end(ap);
}
  8003a9:	83 c4 10             	add    $0x10,%esp
  8003ac:	c9                   	leave  
  8003ad:	c3                   	ret    

008003ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	57                   	push   %edi
  8003b2:	56                   	push   %esi
  8003b3:	53                   	push   %ebx
  8003b4:	83 ec 2c             	sub    $0x2c,%esp
  8003b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8003ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8003bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003c0:	eb 12                	jmp    8003d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c2:	85 c0                	test   %eax,%eax
  8003c4:	0f 84 42 04 00 00    	je     80080c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8003ca:	83 ec 08             	sub    $0x8,%esp
  8003cd:	53                   	push   %ebx
  8003ce:	50                   	push   %eax
  8003cf:	ff d6                	call   *%esi
  8003d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d4:	83 c7 01             	add    $0x1,%edi
  8003d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8003db:	83 f8 25             	cmp    $0x25,%eax
  8003de:	75 e2                	jne    8003c2 <vprintfmt+0x14>
  8003e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8003e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8003f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fe:	eb 07                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800400:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800403:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800407:	8d 47 01             	lea    0x1(%edi),%eax
  80040a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80040d:	0f b6 07             	movzbl (%edi),%eax
  800410:	0f b6 d0             	movzbl %al,%edx
  800413:	83 e8 23             	sub    $0x23,%eax
  800416:	3c 55                	cmp    $0x55,%al
  800418:	0f 87 d3 03 00 00    	ja     8007f1 <vprintfmt+0x443>
  80041e:	0f b6 c0             	movzbl %al,%eax
  800421:	ff 24 85 60 2b 80 00 	jmp    *0x802b60(,%eax,4)
  800428:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80042b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80042f:	eb d6                	jmp    800407 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800431:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800434:	b8 00 00 00 00       	mov    $0x0,%eax
  800439:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80043c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80043f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800443:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800446:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800449:	83 f9 09             	cmp    $0x9,%ecx
  80044c:	77 3f                	ja     80048d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800451:	eb e9                	jmp    80043c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800453:	8b 45 14             	mov    0x14(%ebp),%eax
  800456:	8b 00                	mov    (%eax),%eax
  800458:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80045b:	8b 45 14             	mov    0x14(%ebp),%eax
  80045e:	8d 40 04             	lea    0x4(%eax),%eax
  800461:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800464:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800467:	eb 2a                	jmp    800493 <vprintfmt+0xe5>
  800469:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80046c:	85 c0                	test   %eax,%eax
  80046e:	ba 00 00 00 00       	mov    $0x0,%edx
  800473:	0f 49 d0             	cmovns %eax,%edx
  800476:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047c:	eb 89                	jmp    800407 <vprintfmt+0x59>
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800481:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800488:	e9 7a ff ff ff       	jmp    800407 <vprintfmt+0x59>
  80048d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800490:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800493:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800497:	0f 89 6a ff ff ff    	jns    800407 <vprintfmt+0x59>
				width = precision, precision = -1;
  80049d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8004aa:	e9 58 ff ff ff       	jmp    800407 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004af:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8004b5:	e9 4d ff ff ff       	jmp    800407 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bd:	8d 78 04             	lea    0x4(%eax),%edi
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	53                   	push   %ebx
  8004c4:	ff 30                	pushl  (%eax)
  8004c6:	ff d6                	call   *%esi
			break;
  8004c8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004cb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8004d1:	e9 fe fe ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 78 04             	lea    0x4(%eax),%edi
  8004dc:	8b 00                	mov    (%eax),%eax
  8004de:	99                   	cltd   
  8004df:	31 d0                	xor    %edx,%eax
  8004e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004e3:	83 f8 0f             	cmp    $0xf,%eax
  8004e6:	7f 0b                	jg     8004f3 <vprintfmt+0x145>
  8004e8:	8b 14 85 c0 2c 80 00 	mov    0x802cc0(,%eax,4),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	75 1b                	jne    80050e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8004f3:	50                   	push   %eax
  8004f4:	68 33 2a 80 00       	push   $0x802a33
  8004f9:	53                   	push   %ebx
  8004fa:	56                   	push   %esi
  8004fb:	e8 91 fe ff ff       	call   800391 <printfmt>
  800500:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800503:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800506:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800509:	e9 c6 fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80050e:	52                   	push   %edx
  80050f:	68 c1 2e 80 00       	push   $0x802ec1
  800514:	53                   	push   %ebx
  800515:	56                   	push   %esi
  800516:	e8 76 fe ff ff       	call   800391 <printfmt>
  80051b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800521:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800524:	e9 ab fe ff ff       	jmp    8003d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800529:	8b 45 14             	mov    0x14(%ebp),%eax
  80052c:	83 c0 04             	add    $0x4,%eax
  80052f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800532:	8b 45 14             	mov    0x14(%ebp),%eax
  800535:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800537:	85 ff                	test   %edi,%edi
  800539:	b8 2c 2a 80 00       	mov    $0x802a2c,%eax
  80053e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800541:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800545:	0f 8e 94 00 00 00    	jle    8005df <vprintfmt+0x231>
  80054b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80054f:	0f 84 98 00 00 00    	je     8005ed <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800555:	83 ec 08             	sub    $0x8,%esp
  800558:	ff 75 d0             	pushl  -0x30(%ebp)
  80055b:	57                   	push   %edi
  80055c:	e8 33 03 00 00       	call   800894 <strnlen>
  800561:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800564:	29 c1                	sub    %eax,%ecx
  800566:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800569:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80056c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800570:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800573:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800576:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800578:	eb 0f                	jmp    800589 <vprintfmt+0x1db>
					putch(padc, putdat);
  80057a:	83 ec 08             	sub    $0x8,%esp
  80057d:	53                   	push   %ebx
  80057e:	ff 75 e0             	pushl  -0x20(%ebp)
  800581:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800583:	83 ef 01             	sub    $0x1,%edi
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	85 ff                	test   %edi,%edi
  80058b:	7f ed                	jg     80057a <vprintfmt+0x1cc>
  80058d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800590:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800593:	85 c9                	test   %ecx,%ecx
  800595:	b8 00 00 00 00       	mov    $0x0,%eax
  80059a:	0f 49 c1             	cmovns %ecx,%eax
  80059d:	29 c1                	sub    %eax,%ecx
  80059f:	89 75 08             	mov    %esi,0x8(%ebp)
  8005a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005a8:	89 cb                	mov    %ecx,%ebx
  8005aa:	eb 4d                	jmp    8005f9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005b0:	74 1b                	je     8005cd <vprintfmt+0x21f>
  8005b2:	0f be c0             	movsbl %al,%eax
  8005b5:	83 e8 20             	sub    $0x20,%eax
  8005b8:	83 f8 5e             	cmp    $0x5e,%eax
  8005bb:	76 10                	jbe    8005cd <vprintfmt+0x21f>
					putch('?', putdat);
  8005bd:	83 ec 08             	sub    $0x8,%esp
  8005c0:	ff 75 0c             	pushl  0xc(%ebp)
  8005c3:	6a 3f                	push   $0x3f
  8005c5:	ff 55 08             	call   *0x8(%ebp)
  8005c8:	83 c4 10             	add    $0x10,%esp
  8005cb:	eb 0d                	jmp    8005da <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8005cd:	83 ec 08             	sub    $0x8,%esp
  8005d0:	ff 75 0c             	pushl  0xc(%ebp)
  8005d3:	52                   	push   %edx
  8005d4:	ff 55 08             	call   *0x8(%ebp)
  8005d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005da:	83 eb 01             	sub    $0x1,%ebx
  8005dd:	eb 1a                	jmp    8005f9 <vprintfmt+0x24b>
  8005df:	89 75 08             	mov    %esi,0x8(%ebp)
  8005e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005eb:	eb 0c                	jmp    8005f9 <vprintfmt+0x24b>
  8005ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8005f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8005f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8005f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005f9:	83 c7 01             	add    $0x1,%edi
  8005fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800600:	0f be d0             	movsbl %al,%edx
  800603:	85 d2                	test   %edx,%edx
  800605:	74 23                	je     80062a <vprintfmt+0x27c>
  800607:	85 f6                	test   %esi,%esi
  800609:	78 a1                	js     8005ac <vprintfmt+0x1fe>
  80060b:	83 ee 01             	sub    $0x1,%esi
  80060e:	79 9c                	jns    8005ac <vprintfmt+0x1fe>
  800610:	89 df                	mov    %ebx,%edi
  800612:	8b 75 08             	mov    0x8(%ebp),%esi
  800615:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800618:	eb 18                	jmp    800632 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061a:	83 ec 08             	sub    $0x8,%esp
  80061d:	53                   	push   %ebx
  80061e:	6a 20                	push   $0x20
  800620:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800622:	83 ef 01             	sub    $0x1,%edi
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	eb 08                	jmp    800632 <vprintfmt+0x284>
  80062a:	89 df                	mov    %ebx,%edi
  80062c:	8b 75 08             	mov    0x8(%ebp),%esi
  80062f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800632:	85 ff                	test   %edi,%edi
  800634:	7f e4                	jg     80061a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800636:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063f:	e9 90 fd ff ff       	jmp    8003d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800644:	83 f9 01             	cmp    $0x1,%ecx
  800647:	7e 19                	jle    800662 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800649:	8b 45 14             	mov    0x14(%ebp),%eax
  80064c:	8b 50 04             	mov    0x4(%eax),%edx
  80064f:	8b 00                	mov    (%eax),%eax
  800651:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800654:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8d 40 08             	lea    0x8(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
  800660:	eb 38                	jmp    80069a <vprintfmt+0x2ec>
	else if (lflag)
  800662:	85 c9                	test   %ecx,%ecx
  800664:	74 1b                	je     800681 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 00                	mov    (%eax),%eax
  80066b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066e:	89 c1                	mov    %eax,%ecx
  800670:	c1 f9 1f             	sar    $0x1f,%ecx
  800673:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800676:	8b 45 14             	mov    0x14(%ebp),%eax
  800679:	8d 40 04             	lea    0x4(%eax),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
  80067f:	eb 19                	jmp    80069a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 00                	mov    (%eax),%eax
  800686:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800689:	89 c1                	mov    %eax,%ecx
  80068b:	c1 f9 1f             	sar    $0x1f,%ecx
  80068e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8d 40 04             	lea    0x4(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80069a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8006a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8006a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006a9:	0f 89 0e 01 00 00    	jns    8007bd <vprintfmt+0x40f>
				putch('-', putdat);
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	6a 2d                	push   $0x2d
  8006b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006bd:	f7 da                	neg    %edx
  8006bf:	83 d1 00             	adc    $0x0,%ecx
  8006c2:	f7 d9                	neg    %ecx
  8006c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8006c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006cc:	e9 ec 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006d1:	83 f9 01             	cmp    $0x1,%ecx
  8006d4:	7e 18                	jle    8006ee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	8b 48 04             	mov    0x4(%eax),%ecx
  8006de:	8d 40 08             	lea    0x8(%eax),%eax
  8006e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8006e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006e9:	e9 cf 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006ee:	85 c9                	test   %ecx,%ecx
  8006f0:	74 1a                	je     80070c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8006f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f5:	8b 10                	mov    (%eax),%edx
  8006f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fc:	8d 40 04             	lea    0x4(%eax),%eax
  8006ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800702:	b8 0a 00 00 00       	mov    $0xa,%eax
  800707:	e9 b1 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80070c:	8b 45 14             	mov    0x14(%ebp),%eax
  80070f:	8b 10                	mov    (%eax),%edx
  800711:	b9 00 00 00 00       	mov    $0x0,%ecx
  800716:	8d 40 04             	lea    0x4(%eax),%eax
  800719:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80071c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800721:	e9 97 00 00 00       	jmp    8007bd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800726:	83 ec 08             	sub    $0x8,%esp
  800729:	53                   	push   %ebx
  80072a:	6a 58                	push   $0x58
  80072c:	ff d6                	call   *%esi
			putch('X', putdat);
  80072e:	83 c4 08             	add    $0x8,%esp
  800731:	53                   	push   %ebx
  800732:	6a 58                	push   $0x58
  800734:	ff d6                	call   *%esi
			putch('X', putdat);
  800736:	83 c4 08             	add    $0x8,%esp
  800739:	53                   	push   %ebx
  80073a:	6a 58                	push   $0x58
  80073c:	ff d6                	call   *%esi
			break;
  80073e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800741:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800744:	e9 8b fc ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800749:	83 ec 08             	sub    $0x8,%esp
  80074c:	53                   	push   %ebx
  80074d:	6a 30                	push   $0x30
  80074f:	ff d6                	call   *%esi
			putch('x', putdat);
  800751:	83 c4 08             	add    $0x8,%esp
  800754:	53                   	push   %ebx
  800755:	6a 78                	push   $0x78
  800757:	ff d6                	call   *%esi
			num = (unsigned long long)
  800759:	8b 45 14             	mov    0x14(%ebp),%eax
  80075c:	8b 10                	mov    (%eax),%edx
  80075e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800763:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800766:	8d 40 04             	lea    0x4(%eax),%eax
  800769:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800771:	eb 4a                	jmp    8007bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800773:	83 f9 01             	cmp    $0x1,%ecx
  800776:	7e 15                	jle    80078d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8b 10                	mov    (%eax),%edx
  80077d:	8b 48 04             	mov    0x4(%eax),%ecx
  800780:	8d 40 08             	lea    0x8(%eax),%eax
  800783:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800786:	b8 10 00 00 00       	mov    $0x10,%eax
  80078b:	eb 30                	jmp    8007bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80078d:	85 c9                	test   %ecx,%ecx
  80078f:	74 17                	je     8007a8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8b 10                	mov    (%eax),%edx
  800796:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079b:	8d 40 04             	lea    0x4(%eax),%eax
  80079e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8007a6:	eb 15                	jmp    8007bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8007a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ab:	8b 10                	mov    (%eax),%edx
  8007ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b2:	8d 40 04             	lea    0x4(%eax),%eax
  8007b5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8007b8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007bd:	83 ec 0c             	sub    $0xc,%esp
  8007c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8007c4:	57                   	push   %edi
  8007c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c8:	50                   	push   %eax
  8007c9:	51                   	push   %ecx
  8007ca:	52                   	push   %edx
  8007cb:	89 da                	mov    %ebx,%edx
  8007cd:	89 f0                	mov    %esi,%eax
  8007cf:	e8 f1 fa ff ff       	call   8002c5 <printnum>
			break;
  8007d4:	83 c4 20             	add    $0x20,%esp
  8007d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007da:	e9 f5 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007df:	83 ec 08             	sub    $0x8,%esp
  8007e2:	53                   	push   %ebx
  8007e3:	52                   	push   %edx
  8007e4:	ff d6                	call   *%esi
			break;
  8007e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007ec:	e9 e3 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	53                   	push   %ebx
  8007f5:	6a 25                	push   $0x25
  8007f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f9:	83 c4 10             	add    $0x10,%esp
  8007fc:	eb 03                	jmp    800801 <vprintfmt+0x453>
  8007fe:	83 ef 01             	sub    $0x1,%edi
  800801:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800805:	75 f7                	jne    8007fe <vprintfmt+0x450>
  800807:	e9 c8 fb ff ff       	jmp    8003d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80080c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80080f:	5b                   	pop    %ebx
  800810:	5e                   	pop    %esi
  800811:	5f                   	pop    %edi
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	83 ec 18             	sub    $0x18,%esp
  80081a:	8b 45 08             	mov    0x8(%ebp),%eax
  80081d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800820:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800823:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800827:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80082a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800831:	85 c0                	test   %eax,%eax
  800833:	74 26                	je     80085b <vsnprintf+0x47>
  800835:	85 d2                	test   %edx,%edx
  800837:	7e 22                	jle    80085b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800839:	ff 75 14             	pushl  0x14(%ebp)
  80083c:	ff 75 10             	pushl  0x10(%ebp)
  80083f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800842:	50                   	push   %eax
  800843:	68 74 03 80 00       	push   $0x800374
  800848:	e8 61 fb ff ff       	call   8003ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80084d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800850:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800853:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	eb 05                	jmp    800860 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80085b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800860:	c9                   	leave  
  800861:	c3                   	ret    

00800862 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80086b:	50                   	push   %eax
  80086c:	ff 75 10             	pushl  0x10(%ebp)
  80086f:	ff 75 0c             	pushl  0xc(%ebp)
  800872:	ff 75 08             	pushl  0x8(%ebp)
  800875:	e8 9a ff ff ff       	call   800814 <vsnprintf>
	va_end(ap);

	return rc;
}
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    

0080087c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	eb 03                	jmp    80088c <strlen+0x10>
		n++;
  800889:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80088c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800890:	75 f7                	jne    800889 <strlen+0xd>
		n++;
	return n;
}
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80089d:	ba 00 00 00 00       	mov    $0x0,%edx
  8008a2:	eb 03                	jmp    8008a7 <strnlen+0x13>
		n++;
  8008a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a7:	39 c2                	cmp    %eax,%edx
  8008a9:	74 08                	je     8008b3 <strnlen+0x1f>
  8008ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8008af:	75 f3                	jne    8008a4 <strnlen+0x10>
  8008b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	53                   	push   %ebx
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008bf:	89 c2                	mov    %eax,%edx
  8008c1:	83 c2 01             	add    $0x1,%edx
  8008c4:	83 c1 01             	add    $0x1,%ecx
  8008c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008ce:	84 db                	test   %bl,%bl
  8008d0:	75 ef                	jne    8008c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008d2:	5b                   	pop    %ebx
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	53                   	push   %ebx
  8008d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008dc:	53                   	push   %ebx
  8008dd:	e8 9a ff ff ff       	call   80087c <strlen>
  8008e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008e5:	ff 75 0c             	pushl  0xc(%ebp)
  8008e8:	01 d8                	add    %ebx,%eax
  8008ea:	50                   	push   %eax
  8008eb:	e8 c5 ff ff ff       	call   8008b5 <strcpy>
	return dst;
}
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f5:	c9                   	leave  
  8008f6:	c3                   	ret    

008008f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	56                   	push   %esi
  8008fb:	53                   	push   %ebx
  8008fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800902:	89 f3                	mov    %esi,%ebx
  800904:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800907:	89 f2                	mov    %esi,%edx
  800909:	eb 0f                	jmp    80091a <strncpy+0x23>
		*dst++ = *src;
  80090b:	83 c2 01             	add    $0x1,%edx
  80090e:	0f b6 01             	movzbl (%ecx),%eax
  800911:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800914:	80 39 01             	cmpb   $0x1,(%ecx)
  800917:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80091a:	39 da                	cmp    %ebx,%edx
  80091c:	75 ed                	jne    80090b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80091e:	89 f0                	mov    %esi,%eax
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80092f:	8b 55 10             	mov    0x10(%ebp),%edx
  800932:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800934:	85 d2                	test   %edx,%edx
  800936:	74 21                	je     800959 <strlcpy+0x35>
  800938:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80093c:	89 f2                	mov    %esi,%edx
  80093e:	eb 09                	jmp    800949 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800940:	83 c2 01             	add    $0x1,%edx
  800943:	83 c1 01             	add    $0x1,%ecx
  800946:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800949:	39 c2                	cmp    %eax,%edx
  80094b:	74 09                	je     800956 <strlcpy+0x32>
  80094d:	0f b6 19             	movzbl (%ecx),%ebx
  800950:	84 db                	test   %bl,%bl
  800952:	75 ec                	jne    800940 <strlcpy+0x1c>
  800954:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800956:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800959:	29 f0                	sub    %esi,%eax
}
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800965:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800968:	eb 06                	jmp    800970 <strcmp+0x11>
		p++, q++;
  80096a:	83 c1 01             	add    $0x1,%ecx
  80096d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800970:	0f b6 01             	movzbl (%ecx),%eax
  800973:	84 c0                	test   %al,%al
  800975:	74 04                	je     80097b <strcmp+0x1c>
  800977:	3a 02                	cmp    (%edx),%al
  800979:	74 ef                	je     80096a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80097b:	0f b6 c0             	movzbl %al,%eax
  80097e:	0f b6 12             	movzbl (%edx),%edx
  800981:	29 d0                	sub    %edx,%eax
}
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	53                   	push   %ebx
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 c3                	mov    %eax,%ebx
  800991:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800994:	eb 06                	jmp    80099c <strncmp+0x17>
		n--, p++, q++;
  800996:	83 c0 01             	add    $0x1,%eax
  800999:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80099c:	39 d8                	cmp    %ebx,%eax
  80099e:	74 15                	je     8009b5 <strncmp+0x30>
  8009a0:	0f b6 08             	movzbl (%eax),%ecx
  8009a3:	84 c9                	test   %cl,%cl
  8009a5:	74 04                	je     8009ab <strncmp+0x26>
  8009a7:	3a 0a                	cmp    (%edx),%cl
  8009a9:	74 eb                	je     800996 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ab:	0f b6 00             	movzbl (%eax),%eax
  8009ae:	0f b6 12             	movzbl (%edx),%edx
  8009b1:	29 d0                	sub    %edx,%eax
  8009b3:	eb 05                	jmp    8009ba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ba:	5b                   	pop    %ebx
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c7:	eb 07                	jmp    8009d0 <strchr+0x13>
		if (*s == c)
  8009c9:	38 ca                	cmp    %cl,%dl
  8009cb:	74 0f                	je     8009dc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009cd:	83 c0 01             	add    $0x1,%eax
  8009d0:	0f b6 10             	movzbl (%eax),%edx
  8009d3:	84 d2                	test   %dl,%dl
  8009d5:	75 f2                	jne    8009c9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009dc:	5d                   	pop    %ebp
  8009dd:	c3                   	ret    

008009de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e8:	eb 03                	jmp    8009ed <strfind+0xf>
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009f0:	38 ca                	cmp    %cl,%dl
  8009f2:	74 04                	je     8009f8 <strfind+0x1a>
  8009f4:	84 d2                	test   %dl,%dl
  8009f6:	75 f2                	jne    8009ea <strfind+0xc>
			break;
	return (char *) s;
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	57                   	push   %edi
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a03:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a06:	85 c9                	test   %ecx,%ecx
  800a08:	74 36                	je     800a40 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a0a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a10:	75 28                	jne    800a3a <memset+0x40>
  800a12:	f6 c1 03             	test   $0x3,%cl
  800a15:	75 23                	jne    800a3a <memset+0x40>
		c &= 0xFF;
  800a17:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a1b:	89 d3                	mov    %edx,%ebx
  800a1d:	c1 e3 08             	shl    $0x8,%ebx
  800a20:	89 d6                	mov    %edx,%esi
  800a22:	c1 e6 18             	shl    $0x18,%esi
  800a25:	89 d0                	mov    %edx,%eax
  800a27:	c1 e0 10             	shl    $0x10,%eax
  800a2a:	09 f0                	or     %esi,%eax
  800a2c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800a2e:	89 d8                	mov    %ebx,%eax
  800a30:	09 d0                	or     %edx,%eax
  800a32:	c1 e9 02             	shr    $0x2,%ecx
  800a35:	fc                   	cld    
  800a36:	f3 ab                	rep stos %eax,%es:(%edi)
  800a38:	eb 06                	jmp    800a40 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	fc                   	cld    
  800a3e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a40:	89 f8                	mov    %edi,%eax
  800a42:	5b                   	pop    %ebx
  800a43:	5e                   	pop    %esi
  800a44:	5f                   	pop    %edi
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a52:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a55:	39 c6                	cmp    %eax,%esi
  800a57:	73 35                	jae    800a8e <memmove+0x47>
  800a59:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a5c:	39 d0                	cmp    %edx,%eax
  800a5e:	73 2e                	jae    800a8e <memmove+0x47>
		s += n;
		d += n;
  800a60:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a63:	89 d6                	mov    %edx,%esi
  800a65:	09 fe                	or     %edi,%esi
  800a67:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a6d:	75 13                	jne    800a82 <memmove+0x3b>
  800a6f:	f6 c1 03             	test   $0x3,%cl
  800a72:	75 0e                	jne    800a82 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800a74:	83 ef 04             	sub    $0x4,%edi
  800a77:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a7a:	c1 e9 02             	shr    $0x2,%ecx
  800a7d:	fd                   	std    
  800a7e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a80:	eb 09                	jmp    800a8b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a82:	83 ef 01             	sub    $0x1,%edi
  800a85:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a88:	fd                   	std    
  800a89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a8b:	fc                   	cld    
  800a8c:	eb 1d                	jmp    800aab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8e:	89 f2                	mov    %esi,%edx
  800a90:	09 c2                	or     %eax,%edx
  800a92:	f6 c2 03             	test   $0x3,%dl
  800a95:	75 0f                	jne    800aa6 <memmove+0x5f>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 0a                	jne    800aa6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a9c:	c1 e9 02             	shr    $0x2,%ecx
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	fc                   	cld    
  800aa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa4:	eb 05                	jmp    800aab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa6:	89 c7                	mov    %eax,%edi
  800aa8:	fc                   	cld    
  800aa9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aab:	5e                   	pop    %esi
  800aac:	5f                   	pop    %edi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ab2:	ff 75 10             	pushl  0x10(%ebp)
  800ab5:	ff 75 0c             	pushl  0xc(%ebp)
  800ab8:	ff 75 08             	pushl  0x8(%ebp)
  800abb:	e8 87 ff ff ff       	call   800a47 <memmove>
}
  800ac0:	c9                   	leave  
  800ac1:	c3                   	ret    

00800ac2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acd:	89 c6                	mov    %eax,%esi
  800acf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ad2:	eb 1a                	jmp    800aee <memcmp+0x2c>
		if (*s1 != *s2)
  800ad4:	0f b6 08             	movzbl (%eax),%ecx
  800ad7:	0f b6 1a             	movzbl (%edx),%ebx
  800ada:	38 d9                	cmp    %bl,%cl
  800adc:	74 0a                	je     800ae8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ade:	0f b6 c1             	movzbl %cl,%eax
  800ae1:	0f b6 db             	movzbl %bl,%ebx
  800ae4:	29 d8                	sub    %ebx,%eax
  800ae6:	eb 0f                	jmp    800af7 <memcmp+0x35>
		s1++, s2++;
  800ae8:	83 c0 01             	add    $0x1,%eax
  800aeb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aee:	39 f0                	cmp    %esi,%eax
  800af0:	75 e2                	jne    800ad4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800af2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b02:	89 c1                	mov    %eax,%ecx
  800b04:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800b07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b0b:	eb 0a                	jmp    800b17 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b0d:	0f b6 10             	movzbl (%eax),%edx
  800b10:	39 da                	cmp    %ebx,%edx
  800b12:	74 07                	je     800b1b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b14:	83 c0 01             	add    $0x1,%eax
  800b17:	39 c8                	cmp    %ecx,%eax
  800b19:	72 f2                	jb     800b0d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
  800b24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2a:	eb 03                	jmp    800b2f <strtol+0x11>
		s++;
  800b2c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2f:	0f b6 01             	movzbl (%ecx),%eax
  800b32:	3c 20                	cmp    $0x20,%al
  800b34:	74 f6                	je     800b2c <strtol+0xe>
  800b36:	3c 09                	cmp    $0x9,%al
  800b38:	74 f2                	je     800b2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b3a:	3c 2b                	cmp    $0x2b,%al
  800b3c:	75 0a                	jne    800b48 <strtol+0x2a>
		s++;
  800b3e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b41:	bf 00 00 00 00       	mov    $0x0,%edi
  800b46:	eb 11                	jmp    800b59 <strtol+0x3b>
  800b48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b4d:	3c 2d                	cmp    $0x2d,%al
  800b4f:	75 08                	jne    800b59 <strtol+0x3b>
		s++, neg = 1;
  800b51:	83 c1 01             	add    $0x1,%ecx
  800b54:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5f:	75 15                	jne    800b76 <strtol+0x58>
  800b61:	80 39 30             	cmpb   $0x30,(%ecx)
  800b64:	75 10                	jne    800b76 <strtol+0x58>
  800b66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b6a:	75 7c                	jne    800be8 <strtol+0xca>
		s += 2, base = 16;
  800b6c:	83 c1 02             	add    $0x2,%ecx
  800b6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b74:	eb 16                	jmp    800b8c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800b76:	85 db                	test   %ebx,%ebx
  800b78:	75 12                	jne    800b8c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800b82:	75 08                	jne    800b8c <strtol+0x6e>
		s++, base = 8;
  800b84:	83 c1 01             	add    $0x1,%ecx
  800b87:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b91:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b94:	0f b6 11             	movzbl (%ecx),%edx
  800b97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b9a:	89 f3                	mov    %esi,%ebx
  800b9c:	80 fb 09             	cmp    $0x9,%bl
  800b9f:	77 08                	ja     800ba9 <strtol+0x8b>
			dig = *s - '0';
  800ba1:	0f be d2             	movsbl %dl,%edx
  800ba4:	83 ea 30             	sub    $0x30,%edx
  800ba7:	eb 22                	jmp    800bcb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ba9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800bac:	89 f3                	mov    %esi,%ebx
  800bae:	80 fb 19             	cmp    $0x19,%bl
  800bb1:	77 08                	ja     800bbb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800bb3:	0f be d2             	movsbl %dl,%edx
  800bb6:	83 ea 57             	sub    $0x57,%edx
  800bb9:	eb 10                	jmp    800bcb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800bbb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800bbe:	89 f3                	mov    %esi,%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 16                	ja     800bdb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800bc5:	0f be d2             	movsbl %dl,%edx
  800bc8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800bcb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bce:	7d 0b                	jge    800bdb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800bd0:	83 c1 01             	add    $0x1,%ecx
  800bd3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bd7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bd9:	eb b9                	jmp    800b94 <strtol+0x76>

	if (endptr)
  800bdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bdf:	74 0d                	je     800bee <strtol+0xd0>
		*endptr = (char *) s;
  800be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800be4:	89 0e                	mov    %ecx,(%esi)
  800be6:	eb 06                	jmp    800bee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be8:	85 db                	test   %ebx,%ebx
  800bea:	74 98                	je     800b84 <strtol+0x66>
  800bec:	eb 9e                	jmp    800b8c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800bee:	89 c2                	mov    %eax,%edx
  800bf0:	f7 da                	neg    %edx
  800bf2:	85 ff                	test   %edi,%edi
  800bf4:	0f 45 c2             	cmovne %edx,%eax
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
  800c07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0d:	89 c3                	mov    %eax,%ebx
  800c0f:	89 c7                	mov    %eax,%edi
  800c11:	89 c6                	mov    %eax,%esi
  800c13:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c20:	ba 00 00 00 00       	mov    $0x0,%edx
  800c25:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2a:	89 d1                	mov    %edx,%ecx
  800c2c:	89 d3                	mov    %edx,%ebx
  800c2e:	89 d7                	mov    %edx,%edi
  800c30:	89 d6                	mov    %edx,%esi
  800c32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	53                   	push   %ebx
  800c3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c47:	b8 03 00 00 00       	mov    $0x3,%eax
  800c4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4f:	89 cb                	mov    %ecx,%ebx
  800c51:	89 cf                	mov    %ecx,%edi
  800c53:	89 ce                	mov    %ecx,%esi
  800c55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c57:	85 c0                	test   %eax,%eax
  800c59:	7e 17                	jle    800c72 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5b:	83 ec 0c             	sub    $0xc,%esp
  800c5e:	50                   	push   %eax
  800c5f:	6a 03                	push   $0x3
  800c61:	68 1f 2d 80 00       	push   $0x802d1f
  800c66:	6a 23                	push   $0x23
  800c68:	68 3c 2d 80 00       	push   $0x802d3c
  800c6d:	e8 66 f5 ff ff       	call   8001d8 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    

00800c7a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c7a:	55                   	push   %ebp
  800c7b:	89 e5                	mov    %esp,%ebp
  800c7d:	57                   	push   %edi
  800c7e:	56                   	push   %esi
  800c7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	ba 00 00 00 00       	mov    $0x0,%edx
  800c85:	b8 02 00 00 00       	mov    $0x2,%eax
  800c8a:	89 d1                	mov    %edx,%ecx
  800c8c:	89 d3                	mov    %edx,%ebx
  800c8e:	89 d7                	mov    %edx,%edi
  800c90:	89 d6                	mov    %edx,%esi
  800c92:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c94:	5b                   	pop    %ebx
  800c95:	5e                   	pop    %esi
  800c96:	5f                   	pop    %edi
  800c97:	5d                   	pop    %ebp
  800c98:	c3                   	ret    

00800c99 <sys_yield>:

void
sys_yield(void)
{
  800c99:	55                   	push   %ebp
  800c9a:	89 e5                	mov    %esp,%ebp
  800c9c:	57                   	push   %edi
  800c9d:	56                   	push   %esi
  800c9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca9:	89 d1                	mov    %edx,%ecx
  800cab:	89 d3                	mov    %edx,%ebx
  800cad:	89 d7                	mov    %edx,%edi
  800caf:	89 d6                	mov    %edx,%esi
  800cb1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	be 00 00 00 00       	mov    $0x0,%esi
  800cc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd4:	89 f7                	mov    %esi,%edi
  800cd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	7e 17                	jle    800cf3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdc:	83 ec 0c             	sub    $0xc,%esp
  800cdf:	50                   	push   %eax
  800ce0:	6a 04                	push   $0x4
  800ce2:	68 1f 2d 80 00       	push   $0x802d1f
  800ce7:	6a 23                	push   $0x23
  800ce9:	68 3c 2d 80 00       	push   $0x802d3c
  800cee:	e8 e5 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf6:	5b                   	pop    %ebx
  800cf7:	5e                   	pop    %esi
  800cf8:	5f                   	pop    %edi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	57                   	push   %edi
  800cff:	56                   	push   %esi
  800d00:	53                   	push   %ebx
  800d01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d04:	b8 05 00 00 00       	mov    $0x5,%eax
  800d09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d15:	8b 75 18             	mov    0x18(%ebp),%esi
  800d18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1a:	85 c0                	test   %eax,%eax
  800d1c:	7e 17                	jle    800d35 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	50                   	push   %eax
  800d22:	6a 05                	push   $0x5
  800d24:	68 1f 2d 80 00       	push   $0x802d1f
  800d29:	6a 23                	push   $0x23
  800d2b:	68 3c 2d 80 00       	push   $0x802d3c
  800d30:	e8 a3 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d38:	5b                   	pop    %ebx
  800d39:	5e                   	pop    %esi
  800d3a:	5f                   	pop    %edi
  800d3b:	5d                   	pop    %ebp
  800d3c:	c3                   	ret    

00800d3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d3d:	55                   	push   %ebp
  800d3e:	89 e5                	mov    %esp,%ebp
  800d40:	57                   	push   %edi
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	89 df                	mov    %ebx,%edi
  800d58:	89 de                	mov    %ebx,%esi
  800d5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d5c:	85 c0                	test   %eax,%eax
  800d5e:	7e 17                	jle    800d77 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d60:	83 ec 0c             	sub    $0xc,%esp
  800d63:	50                   	push   %eax
  800d64:	6a 06                	push   $0x6
  800d66:	68 1f 2d 80 00       	push   $0x802d1f
  800d6b:	6a 23                	push   $0x23
  800d6d:	68 3c 2d 80 00       	push   $0x802d3c
  800d72:	e8 61 f4 ff ff       	call   8001d8 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5f                   	pop    %edi
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	57                   	push   %edi
  800d83:	56                   	push   %esi
  800d84:	53                   	push   %ebx
  800d85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d95:	8b 55 08             	mov    0x8(%ebp),%edx
  800d98:	89 df                	mov    %ebx,%edi
  800d9a:	89 de                	mov    %ebx,%esi
  800d9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	7e 17                	jle    800db9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da2:	83 ec 0c             	sub    $0xc,%esp
  800da5:	50                   	push   %eax
  800da6:	6a 08                	push   $0x8
  800da8:	68 1f 2d 80 00       	push   $0x802d1f
  800dad:	6a 23                	push   $0x23
  800daf:	68 3c 2d 80 00       	push   $0x802d3c
  800db4:	e8 1f f4 ff ff       	call   8001d8 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
  800dc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcf:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dda:	89 df                	mov    %ebx,%edi
  800ddc:	89 de                	mov    %ebx,%esi
  800dde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800de0:	85 c0                	test   %eax,%eax
  800de2:	7e 17                	jle    800dfb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800de4:	83 ec 0c             	sub    $0xc,%esp
  800de7:	50                   	push   %eax
  800de8:	6a 09                	push   $0x9
  800dea:	68 1f 2d 80 00       	push   $0x802d1f
  800def:	6a 23                	push   $0x23
  800df1:	68 3c 2d 80 00       	push   $0x802d3c
  800df6:	e8 dd f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800dfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	57                   	push   %edi
  800e07:	56                   	push   %esi
  800e08:	53                   	push   %ebx
  800e09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e19:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1c:	89 df                	mov    %ebx,%edi
  800e1e:	89 de                	mov    %ebx,%esi
  800e20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e22:	85 c0                	test   %eax,%eax
  800e24:	7e 17                	jle    800e3d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	50                   	push   %eax
  800e2a:	6a 0a                	push   $0xa
  800e2c:	68 1f 2d 80 00       	push   $0x802d1f
  800e31:	6a 23                	push   $0x23
  800e33:	68 3c 2d 80 00       	push   $0x802d3c
  800e38:	e8 9b f3 ff ff       	call   8001d8 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	57                   	push   %edi
  800e49:	56                   	push   %esi
  800e4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4b:	be 00 00 00 00       	mov    $0x0,%esi
  800e50:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e58:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e61:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e76:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	89 cb                	mov    %ecx,%ebx
  800e80:	89 cf                	mov    %ecx,%edi
  800e82:	89 ce                	mov    %ecx,%esi
  800e84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e86:	85 c0                	test   %eax,%eax
  800e88:	7e 17                	jle    800ea1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	50                   	push   %eax
  800e8e:	6a 0d                	push   $0xd
  800e90:	68 1f 2d 80 00       	push   $0x802d1f
  800e95:	6a 23                	push   $0x23
  800e97:	68 3c 2d 80 00       	push   $0x802d3c
  800e9c:	e8 37 f3 ff ff       	call   8001d8 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ea1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800eb1:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800eb3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eb7:	74 11                	je     800eca <pgfault+0x21>
  800eb9:	89 d8                	mov    %ebx,%eax
  800ebb:	c1 e8 0c             	shr    $0xc,%eax
  800ebe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ec5:	f6 c4 08             	test   $0x8,%ah
  800ec8:	75 14                	jne    800ede <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	68 4c 2d 80 00       	push   $0x802d4c
  800ed2:	6a 1f                	push   $0x1f
  800ed4:	68 af 2d 80 00       	push   $0x802daf
  800ed9:	e8 fa f2 ff ff       	call   8001d8 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800ede:	e8 97 fd ff ff       	call   800c7a <sys_getenvid>
  800ee3:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800ee5:	83 ec 04             	sub    $0x4,%esp
  800ee8:	6a 07                	push   $0x7
  800eea:	68 00 f0 7f 00       	push   $0x7ff000
  800eef:	50                   	push   %eax
  800ef0:	e8 c3 fd ff ff       	call   800cb8 <sys_page_alloc>
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	79 12                	jns    800f0e <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800efc:	50                   	push   %eax
  800efd:	68 8c 2d 80 00       	push   $0x802d8c
  800f02:	6a 2c                	push   $0x2c
  800f04:	68 af 2d 80 00       	push   $0x802daf
  800f09:	e8 ca f2 ff ff       	call   8001d8 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800f0e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	68 00 10 00 00       	push   $0x1000
  800f1c:	53                   	push   %ebx
  800f1d:	68 00 f0 7f 00       	push   $0x7ff000
  800f22:	e8 20 fb ff ff       	call   800a47 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800f27:	83 c4 08             	add    $0x8,%esp
  800f2a:	53                   	push   %ebx
  800f2b:	56                   	push   %esi
  800f2c:	e8 0c fe ff ff       	call   800d3d <sys_page_unmap>
  800f31:	83 c4 10             	add    $0x10,%esp
  800f34:	85 c0                	test   %eax,%eax
  800f36:	79 12                	jns    800f4a <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800f38:	50                   	push   %eax
  800f39:	68 ba 2d 80 00       	push   $0x802dba
  800f3e:	6a 32                	push   $0x32
  800f40:	68 af 2d 80 00       	push   $0x802daf
  800f45:	e8 8e f2 ff ff       	call   8001d8 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f4a:	83 ec 0c             	sub    $0xc,%esp
  800f4d:	6a 07                	push   $0x7
  800f4f:	53                   	push   %ebx
  800f50:	56                   	push   %esi
  800f51:	68 00 f0 7f 00       	push   $0x7ff000
  800f56:	56                   	push   %esi
  800f57:	e8 9f fd ff ff       	call   800cfb <sys_page_map>
  800f5c:	83 c4 20             	add    $0x20,%esp
  800f5f:	85 c0                	test   %eax,%eax
  800f61:	79 12                	jns    800f75 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800f63:	50                   	push   %eax
  800f64:	68 d8 2d 80 00       	push   $0x802dd8
  800f69:	6a 35                	push   $0x35
  800f6b:	68 af 2d 80 00       	push   $0x802daf
  800f70:	e8 63 f2 ff ff       	call   8001d8 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f75:	83 ec 08             	sub    $0x8,%esp
  800f78:	68 00 f0 7f 00       	push   $0x7ff000
  800f7d:	56                   	push   %esi
  800f7e:	e8 ba fd ff ff       	call   800d3d <sys_page_unmap>
  800f83:	83 c4 10             	add    $0x10,%esp
  800f86:	85 c0                	test   %eax,%eax
  800f88:	79 12                	jns    800f9c <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800f8a:	50                   	push   %eax
  800f8b:	68 ba 2d 80 00       	push   $0x802dba
  800f90:	6a 38                	push   $0x38
  800f92:	68 af 2d 80 00       	push   $0x802daf
  800f97:	e8 3c f2 ff ff       	call   8001d8 <_panic>
	//panic("pgfault not implemented");
}
  800f9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f9f:	5b                   	pop    %ebx
  800fa0:	5e                   	pop    %esi
  800fa1:	5d                   	pop    %ebp
  800fa2:	c3                   	ret    

00800fa3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	57                   	push   %edi
  800fa7:	56                   	push   %esi
  800fa8:	53                   	push   %ebx
  800fa9:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800fac:	68 a9 0e 80 00       	push   $0x800ea9
  800fb1:	e8 08 15 00 00       	call   8024be <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fb6:	b8 07 00 00 00       	mov    $0x7,%eax
  800fbb:	cd 30                	int    $0x30
  800fbd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	0f 88 38 01 00 00    	js     801103 <fork+0x160>
  800fcb:	89 c7                	mov    %eax,%edi
  800fcd:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800fd2:	85 c0                	test   %eax,%eax
  800fd4:	75 21                	jne    800ff7 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800fd6:	e8 9f fc ff ff       	call   800c7a <sys_getenvid>
  800fdb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fe0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800fe3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe8:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  800fed:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff2:	e9 86 01 00 00       	jmp    80117d <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800ff7:	89 d8                	mov    %ebx,%eax
  800ff9:	c1 e8 16             	shr    $0x16,%eax
  800ffc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801003:	a8 01                	test   $0x1,%al
  801005:	0f 84 90 00 00 00    	je     80109b <fork+0xf8>
  80100b:	89 d8                	mov    %ebx,%eax
  80100d:	c1 e8 0c             	shr    $0xc,%eax
  801010:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801017:	f6 c2 01             	test   $0x1,%dl
  80101a:	74 7f                	je     80109b <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  80101c:	89 c6                	mov    %eax,%esi
  80101e:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  801021:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801028:	f6 c6 04             	test   $0x4,%dh
  80102b:	74 33                	je     801060 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  80102d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	25 07 0e 00 00       	and    $0xe07,%eax
  80103c:	50                   	push   %eax
  80103d:	56                   	push   %esi
  80103e:	57                   	push   %edi
  80103f:	56                   	push   %esi
  801040:	6a 00                	push   $0x0
  801042:	e8 b4 fc ff ff       	call   800cfb <sys_page_map>
  801047:	83 c4 20             	add    $0x20,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	79 4d                	jns    80109b <fork+0xf8>
		    panic("sys_page_map: %e", r);
  80104e:	50                   	push   %eax
  80104f:	68 f4 2d 80 00       	push   $0x802df4
  801054:	6a 54                	push   $0x54
  801056:	68 af 2d 80 00       	push   $0x802daf
  80105b:	e8 78 f1 ff ff       	call   8001d8 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  801060:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801067:	a9 02 08 00 00       	test   $0x802,%eax
  80106c:	0f 85 c6 00 00 00    	jne    801138 <fork+0x195>
  801072:	e9 e3 00 00 00       	jmp    80115a <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  801077:	50                   	push   %eax
  801078:	68 f4 2d 80 00       	push   $0x802df4
  80107d:	6a 5d                	push   $0x5d
  80107f:	68 af 2d 80 00       	push   $0x802daf
  801084:	e8 4f f1 ff ff       	call   8001d8 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  801089:	50                   	push   %eax
  80108a:	68 f4 2d 80 00       	push   $0x802df4
  80108f:	6a 64                	push   $0x64
  801091:	68 af 2d 80 00       	push   $0x802daf
  801096:	e8 3d f1 ff ff       	call   8001d8 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  80109b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010a1:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8010a7:	0f 85 4a ff ff ff    	jne    800ff7 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  8010ad:	83 ec 04             	sub    $0x4,%esp
  8010b0:	6a 07                	push   $0x7
  8010b2:	68 00 f0 bf ee       	push   $0xeebff000
  8010b7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  8010ba:	57                   	push   %edi
  8010bb:	e8 f8 fb ff ff       	call   800cb8 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  8010c0:	83 c4 10             	add    $0x10,%esp
		return ret;
  8010c3:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  8010c5:	85 c0                	test   %eax,%eax
  8010c7:	0f 88 b0 00 00 00    	js     80117d <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8010cd:	a1 04 50 80 00       	mov    0x805004,%eax
  8010d2:	8b 40 64             	mov    0x64(%eax),%eax
  8010d5:	83 ec 08             	sub    $0x8,%esp
  8010d8:	50                   	push   %eax
  8010d9:	57                   	push   %edi
  8010da:	e8 24 fd ff ff       	call   800e03 <sys_env_set_pgfault_upcall>
  8010df:	83 c4 10             	add    $0x10,%esp
		return ret;
  8010e2:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	0f 88 91 00 00 00    	js     80117d <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010ec:	83 ec 08             	sub    $0x8,%esp
  8010ef:	6a 02                	push   $0x2
  8010f1:	57                   	push   %edi
  8010f2:	e8 88 fc ff ff       	call   800d7f <sys_env_set_status>
  8010f7:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	89 fa                	mov    %edi,%edx
  8010fe:	0f 48 d0             	cmovs  %eax,%edx
  801101:	eb 7a                	jmp    80117d <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  801103:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801106:	eb 75                	jmp    80117d <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801108:	e8 6d fb ff ff       	call   800c7a <sys_getenvid>
  80110d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801110:	e8 65 fb ff ff       	call   800c7a <sys_getenvid>
  801115:	83 ec 0c             	sub    $0xc,%esp
  801118:	68 05 08 00 00       	push   $0x805
  80111d:	56                   	push   %esi
  80111e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801121:	56                   	push   %esi
  801122:	50                   	push   %eax
  801123:	e8 d3 fb ff ff       	call   800cfb <sys_page_map>
  801128:	83 c4 20             	add    $0x20,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	0f 89 68 ff ff ff    	jns    80109b <fork+0xf8>
  801133:	e9 51 ff ff ff       	jmp    801089 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  801138:	e8 3d fb ff ff       	call   800c7a <sys_getenvid>
  80113d:	83 ec 0c             	sub    $0xc,%esp
  801140:	68 05 08 00 00       	push   $0x805
  801145:	56                   	push   %esi
  801146:	57                   	push   %edi
  801147:	56                   	push   %esi
  801148:	50                   	push   %eax
  801149:	e8 ad fb ff ff       	call   800cfb <sys_page_map>
  80114e:	83 c4 20             	add    $0x20,%esp
  801151:	85 c0                	test   %eax,%eax
  801153:	79 b3                	jns    801108 <fork+0x165>
  801155:	e9 1d ff ff ff       	jmp    801077 <fork+0xd4>
  80115a:	e8 1b fb ff ff       	call   800c7a <sys_getenvid>
  80115f:	83 ec 0c             	sub    $0xc,%esp
  801162:	6a 05                	push   $0x5
  801164:	56                   	push   %esi
  801165:	57                   	push   %edi
  801166:	56                   	push   %esi
  801167:	50                   	push   %eax
  801168:	e8 8e fb ff ff       	call   800cfb <sys_page_map>
  80116d:	83 c4 20             	add    $0x20,%esp
  801170:	85 c0                	test   %eax,%eax
  801172:	0f 89 23 ff ff ff    	jns    80109b <fork+0xf8>
  801178:	e9 fa fe ff ff       	jmp    801077 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  80117d:	89 d0                	mov    %edx,%eax
  80117f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801182:	5b                   	pop    %ebx
  801183:	5e                   	pop    %esi
  801184:	5f                   	pop    %edi
  801185:	5d                   	pop    %ebp
  801186:	c3                   	ret    

00801187 <sfork>:

// Challenge!
int
sfork(void)
{
  801187:	55                   	push   %ebp
  801188:	89 e5                	mov    %esp,%ebp
  80118a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80118d:	68 05 2e 80 00       	push   $0x802e05
  801192:	68 ac 00 00 00       	push   $0xac
  801197:	68 af 2d 80 00       	push   $0x802daf
  80119c:	e8 37 f0 ff ff       	call   8001d8 <_panic>

008011a1 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011ac:	c1 e8 0c             	shr    $0xc,%eax
}
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b7:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011c1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011d3:	89 c2                	mov    %eax,%edx
  8011d5:	c1 ea 16             	shr    $0x16,%edx
  8011d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011df:	f6 c2 01             	test   $0x1,%dl
  8011e2:	74 11                	je     8011f5 <fd_alloc+0x2d>
  8011e4:	89 c2                	mov    %eax,%edx
  8011e6:	c1 ea 0c             	shr    $0xc,%edx
  8011e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f0:	f6 c2 01             	test   $0x1,%dl
  8011f3:	75 09                	jne    8011fe <fd_alloc+0x36>
			*fd_store = fd;
  8011f5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8011fc:	eb 17                	jmp    801215 <fd_alloc+0x4d>
  8011fe:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801203:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801208:	75 c9                	jne    8011d3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80120a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801210:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801217:	55                   	push   %ebp
  801218:	89 e5                	mov    %esp,%ebp
  80121a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80121d:	83 f8 1f             	cmp    $0x1f,%eax
  801220:	77 36                	ja     801258 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801222:	c1 e0 0c             	shl    $0xc,%eax
  801225:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80122a:	89 c2                	mov    %eax,%edx
  80122c:	c1 ea 16             	shr    $0x16,%edx
  80122f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801236:	f6 c2 01             	test   $0x1,%dl
  801239:	74 24                	je     80125f <fd_lookup+0x48>
  80123b:	89 c2                	mov    %eax,%edx
  80123d:	c1 ea 0c             	shr    $0xc,%edx
  801240:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801247:	f6 c2 01             	test   $0x1,%dl
  80124a:	74 1a                	je     801266 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80124c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124f:	89 02                	mov    %eax,(%edx)
	return 0;
  801251:	b8 00 00 00 00       	mov    $0x0,%eax
  801256:	eb 13                	jmp    80126b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801258:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125d:	eb 0c                	jmp    80126b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80125f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801264:	eb 05                	jmp    80126b <fd_lookup+0x54>
  801266:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    

0080126d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 08             	sub    $0x8,%esp
  801273:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801276:	ba 98 2e 80 00       	mov    $0x802e98,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80127b:	eb 13                	jmp    801290 <dev_lookup+0x23>
  80127d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801280:	39 08                	cmp    %ecx,(%eax)
  801282:	75 0c                	jne    801290 <dev_lookup+0x23>
			*dev = devtab[i];
  801284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801287:	89 01                	mov    %eax,(%ecx)
			return 0;
  801289:	b8 00 00 00 00       	mov    $0x0,%eax
  80128e:	eb 2e                	jmp    8012be <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801290:	8b 02                	mov    (%edx),%eax
  801292:	85 c0                	test   %eax,%eax
  801294:	75 e7                	jne    80127d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801296:	a1 04 50 80 00       	mov    0x805004,%eax
  80129b:	8b 40 48             	mov    0x48(%eax),%eax
  80129e:	83 ec 04             	sub    $0x4,%esp
  8012a1:	51                   	push   %ecx
  8012a2:	50                   	push   %eax
  8012a3:	68 1c 2e 80 00       	push   $0x802e1c
  8012a8:	e8 04 f0 ff ff       	call   8002b1 <cprintf>
	*dev = 0;
  8012ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012b0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012be:	c9                   	leave  
  8012bf:	c3                   	ret    

008012c0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	56                   	push   %esi
  8012c4:	53                   	push   %ebx
  8012c5:	83 ec 10             	sub    $0x10,%esp
  8012c8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d1:	50                   	push   %eax
  8012d2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012d8:	c1 e8 0c             	shr    $0xc,%eax
  8012db:	50                   	push   %eax
  8012dc:	e8 36 ff ff ff       	call   801217 <fd_lookup>
  8012e1:	83 c4 08             	add    $0x8,%esp
  8012e4:	85 c0                	test   %eax,%eax
  8012e6:	78 05                	js     8012ed <fd_close+0x2d>
	    || fd != fd2)
  8012e8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012eb:	74 0c                	je     8012f9 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012ed:	84 db                	test   %bl,%bl
  8012ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f4:	0f 44 c2             	cmove  %edx,%eax
  8012f7:	eb 41                	jmp    80133a <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ff:	50                   	push   %eax
  801300:	ff 36                	pushl  (%esi)
  801302:	e8 66 ff ff ff       	call   80126d <dev_lookup>
  801307:	89 c3                	mov    %eax,%ebx
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 1a                	js     80132a <fd_close+0x6a>
		if (dev->dev_close)
  801310:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801313:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801316:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80131b:	85 c0                	test   %eax,%eax
  80131d:	74 0b                	je     80132a <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80131f:	83 ec 0c             	sub    $0xc,%esp
  801322:	56                   	push   %esi
  801323:	ff d0                	call   *%eax
  801325:	89 c3                	mov    %eax,%ebx
  801327:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80132a:	83 ec 08             	sub    $0x8,%esp
  80132d:	56                   	push   %esi
  80132e:	6a 00                	push   $0x0
  801330:	e8 08 fa ff ff       	call   800d3d <sys_page_unmap>
	return r;
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	89 d8                	mov    %ebx,%eax
}
  80133a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133d:	5b                   	pop    %ebx
  80133e:	5e                   	pop    %esi
  80133f:	5d                   	pop    %ebp
  801340:	c3                   	ret    

00801341 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801341:	55                   	push   %ebp
  801342:	89 e5                	mov    %esp,%ebp
  801344:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801347:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	ff 75 08             	pushl  0x8(%ebp)
  80134e:	e8 c4 fe ff ff       	call   801217 <fd_lookup>
  801353:	83 c4 08             	add    $0x8,%esp
  801356:	85 c0                	test   %eax,%eax
  801358:	78 10                	js     80136a <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80135a:	83 ec 08             	sub    $0x8,%esp
  80135d:	6a 01                	push   $0x1
  80135f:	ff 75 f4             	pushl  -0xc(%ebp)
  801362:	e8 59 ff ff ff       	call   8012c0 <fd_close>
  801367:	83 c4 10             	add    $0x10,%esp
}
  80136a:	c9                   	leave  
  80136b:	c3                   	ret    

0080136c <close_all>:

void
close_all(void)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	53                   	push   %ebx
  801370:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801373:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801378:	83 ec 0c             	sub    $0xc,%esp
  80137b:	53                   	push   %ebx
  80137c:	e8 c0 ff ff ff       	call   801341 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801381:	83 c3 01             	add    $0x1,%ebx
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	83 fb 20             	cmp    $0x20,%ebx
  80138a:	75 ec                	jne    801378 <close_all+0xc>
		close(i);
}
  80138c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	57                   	push   %edi
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
  801397:	83 ec 2c             	sub    $0x2c,%esp
  80139a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80139d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013a0:	50                   	push   %eax
  8013a1:	ff 75 08             	pushl  0x8(%ebp)
  8013a4:	e8 6e fe ff ff       	call   801217 <fd_lookup>
  8013a9:	83 c4 08             	add    $0x8,%esp
  8013ac:	85 c0                	test   %eax,%eax
  8013ae:	0f 88 c1 00 00 00    	js     801475 <dup+0xe4>
		return r;
	close(newfdnum);
  8013b4:	83 ec 0c             	sub    $0xc,%esp
  8013b7:	56                   	push   %esi
  8013b8:	e8 84 ff ff ff       	call   801341 <close>

	newfd = INDEX2FD(newfdnum);
  8013bd:	89 f3                	mov    %esi,%ebx
  8013bf:	c1 e3 0c             	shl    $0xc,%ebx
  8013c2:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013c8:	83 c4 04             	add    $0x4,%esp
  8013cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013ce:	e8 de fd ff ff       	call   8011b1 <fd2data>
  8013d3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013d5:	89 1c 24             	mov    %ebx,(%esp)
  8013d8:	e8 d4 fd ff ff       	call   8011b1 <fd2data>
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013e3:	89 f8                	mov    %edi,%eax
  8013e5:	c1 e8 16             	shr    $0x16,%eax
  8013e8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013ef:	a8 01                	test   $0x1,%al
  8013f1:	74 37                	je     80142a <dup+0x99>
  8013f3:	89 f8                	mov    %edi,%eax
  8013f5:	c1 e8 0c             	shr    $0xc,%eax
  8013f8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013ff:	f6 c2 01             	test   $0x1,%dl
  801402:	74 26                	je     80142a <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801404:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80140b:	83 ec 0c             	sub    $0xc,%esp
  80140e:	25 07 0e 00 00       	and    $0xe07,%eax
  801413:	50                   	push   %eax
  801414:	ff 75 d4             	pushl  -0x2c(%ebp)
  801417:	6a 00                	push   $0x0
  801419:	57                   	push   %edi
  80141a:	6a 00                	push   $0x0
  80141c:	e8 da f8 ff ff       	call   800cfb <sys_page_map>
  801421:	89 c7                	mov    %eax,%edi
  801423:	83 c4 20             	add    $0x20,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	78 2e                	js     801458 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80142a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80142d:	89 d0                	mov    %edx,%eax
  80142f:	c1 e8 0c             	shr    $0xc,%eax
  801432:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801439:	83 ec 0c             	sub    $0xc,%esp
  80143c:	25 07 0e 00 00       	and    $0xe07,%eax
  801441:	50                   	push   %eax
  801442:	53                   	push   %ebx
  801443:	6a 00                	push   $0x0
  801445:	52                   	push   %edx
  801446:	6a 00                	push   $0x0
  801448:	e8 ae f8 ff ff       	call   800cfb <sys_page_map>
  80144d:	89 c7                	mov    %eax,%edi
  80144f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801452:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801454:	85 ff                	test   %edi,%edi
  801456:	79 1d                	jns    801475 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801458:	83 ec 08             	sub    $0x8,%esp
  80145b:	53                   	push   %ebx
  80145c:	6a 00                	push   $0x0
  80145e:	e8 da f8 ff ff       	call   800d3d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801463:	83 c4 08             	add    $0x8,%esp
  801466:	ff 75 d4             	pushl  -0x2c(%ebp)
  801469:	6a 00                	push   $0x0
  80146b:	e8 cd f8 ff ff       	call   800d3d <sys_page_unmap>
	return r;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	89 f8                	mov    %edi,%eax
}
  801475:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801478:	5b                   	pop    %ebx
  801479:	5e                   	pop    %esi
  80147a:	5f                   	pop    %edi
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    

0080147d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	53                   	push   %ebx
  801481:	83 ec 14             	sub    $0x14,%esp
  801484:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801487:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	53                   	push   %ebx
  80148c:	e8 86 fd ff ff       	call   801217 <fd_lookup>
  801491:	83 c4 08             	add    $0x8,%esp
  801494:	89 c2                	mov    %eax,%edx
  801496:	85 c0                	test   %eax,%eax
  801498:	78 6d                	js     801507 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80149a:	83 ec 08             	sub    $0x8,%esp
  80149d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a0:	50                   	push   %eax
  8014a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014a4:	ff 30                	pushl  (%eax)
  8014a6:	e8 c2 fd ff ff       	call   80126d <dev_lookup>
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 4c                	js     8014fe <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014b5:	8b 42 08             	mov    0x8(%edx),%eax
  8014b8:	83 e0 03             	and    $0x3,%eax
  8014bb:	83 f8 01             	cmp    $0x1,%eax
  8014be:	75 21                	jne    8014e1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c0:	a1 04 50 80 00       	mov    0x805004,%eax
  8014c5:	8b 40 48             	mov    0x48(%eax),%eax
  8014c8:	83 ec 04             	sub    $0x4,%esp
  8014cb:	53                   	push   %ebx
  8014cc:	50                   	push   %eax
  8014cd:	68 5d 2e 80 00       	push   $0x802e5d
  8014d2:	e8 da ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8014d7:	83 c4 10             	add    $0x10,%esp
  8014da:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014df:	eb 26                	jmp    801507 <read+0x8a>
	}
	if (!dev->dev_read)
  8014e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e4:	8b 40 08             	mov    0x8(%eax),%eax
  8014e7:	85 c0                	test   %eax,%eax
  8014e9:	74 17                	je     801502 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014eb:	83 ec 04             	sub    $0x4,%esp
  8014ee:	ff 75 10             	pushl  0x10(%ebp)
  8014f1:	ff 75 0c             	pushl  0xc(%ebp)
  8014f4:	52                   	push   %edx
  8014f5:	ff d0                	call   *%eax
  8014f7:	89 c2                	mov    %eax,%edx
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	eb 09                	jmp    801507 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fe:	89 c2                	mov    %eax,%edx
  801500:	eb 05                	jmp    801507 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801502:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801507:	89 d0                	mov    %edx,%eax
  801509:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80150c:	c9                   	leave  
  80150d:	c3                   	ret    

0080150e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	83 ec 0c             	sub    $0xc,%esp
  801517:	8b 7d 08             	mov    0x8(%ebp),%edi
  80151a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801522:	eb 21                	jmp    801545 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	89 f0                	mov    %esi,%eax
  801529:	29 d8                	sub    %ebx,%eax
  80152b:	50                   	push   %eax
  80152c:	89 d8                	mov    %ebx,%eax
  80152e:	03 45 0c             	add    0xc(%ebp),%eax
  801531:	50                   	push   %eax
  801532:	57                   	push   %edi
  801533:	e8 45 ff ff ff       	call   80147d <read>
		if (m < 0)
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	85 c0                	test   %eax,%eax
  80153d:	78 10                	js     80154f <readn+0x41>
			return m;
		if (m == 0)
  80153f:	85 c0                	test   %eax,%eax
  801541:	74 0a                	je     80154d <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801543:	01 c3                	add    %eax,%ebx
  801545:	39 f3                	cmp    %esi,%ebx
  801547:	72 db                	jb     801524 <readn+0x16>
  801549:	89 d8                	mov    %ebx,%eax
  80154b:	eb 02                	jmp    80154f <readn+0x41>
  80154d:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80154f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801552:	5b                   	pop    %ebx
  801553:	5e                   	pop    %esi
  801554:	5f                   	pop    %edi
  801555:	5d                   	pop    %ebp
  801556:	c3                   	ret    

00801557 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801557:	55                   	push   %ebp
  801558:	89 e5                	mov    %esp,%ebp
  80155a:	53                   	push   %ebx
  80155b:	83 ec 14             	sub    $0x14,%esp
  80155e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801561:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	53                   	push   %ebx
  801566:	e8 ac fc ff ff       	call   801217 <fd_lookup>
  80156b:	83 c4 08             	add    $0x8,%esp
  80156e:	89 c2                	mov    %eax,%edx
  801570:	85 c0                	test   %eax,%eax
  801572:	78 68                	js     8015dc <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157e:	ff 30                	pushl  (%eax)
  801580:	e8 e8 fc ff ff       	call   80126d <dev_lookup>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	85 c0                	test   %eax,%eax
  80158a:	78 47                	js     8015d3 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801593:	75 21                	jne    8015b6 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801595:	a1 04 50 80 00       	mov    0x805004,%eax
  80159a:	8b 40 48             	mov    0x48(%eax),%eax
  80159d:	83 ec 04             	sub    $0x4,%esp
  8015a0:	53                   	push   %ebx
  8015a1:	50                   	push   %eax
  8015a2:	68 79 2e 80 00       	push   $0x802e79
  8015a7:	e8 05 ed ff ff       	call   8002b1 <cprintf>
		return -E_INVAL;
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b4:	eb 26                	jmp    8015dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b9:	8b 52 0c             	mov    0xc(%edx),%edx
  8015bc:	85 d2                	test   %edx,%edx
  8015be:	74 17                	je     8015d7 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015c0:	83 ec 04             	sub    $0x4,%esp
  8015c3:	ff 75 10             	pushl  0x10(%ebp)
  8015c6:	ff 75 0c             	pushl  0xc(%ebp)
  8015c9:	50                   	push   %eax
  8015ca:	ff d2                	call   *%edx
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	eb 09                	jmp    8015dc <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	eb 05                	jmp    8015dc <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015dc:	89 d0                	mov    %edx,%eax
  8015de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e1:	c9                   	leave  
  8015e2:	c3                   	ret    

008015e3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e9:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	ff 75 08             	pushl  0x8(%ebp)
  8015f0:	e8 22 fc ff ff       	call   801217 <fd_lookup>
  8015f5:	83 c4 08             	add    $0x8,%esp
  8015f8:	85 c0                	test   %eax,%eax
  8015fa:	78 0e                	js     80160a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015fc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801602:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801605:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80160a:	c9                   	leave  
  80160b:	c3                   	ret    

0080160c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	53                   	push   %ebx
  801610:	83 ec 14             	sub    $0x14,%esp
  801613:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801616:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801619:	50                   	push   %eax
  80161a:	53                   	push   %ebx
  80161b:	e8 f7 fb ff ff       	call   801217 <fd_lookup>
  801620:	83 c4 08             	add    $0x8,%esp
  801623:	89 c2                	mov    %eax,%edx
  801625:	85 c0                	test   %eax,%eax
  801627:	78 65                	js     80168e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801629:	83 ec 08             	sub    $0x8,%esp
  80162c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162f:	50                   	push   %eax
  801630:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801633:	ff 30                	pushl  (%eax)
  801635:	e8 33 fc ff ff       	call   80126d <dev_lookup>
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	85 c0                	test   %eax,%eax
  80163f:	78 44                	js     801685 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801641:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801644:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801648:	75 21                	jne    80166b <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80164a:	a1 04 50 80 00       	mov    0x805004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80164f:	8b 40 48             	mov    0x48(%eax),%eax
  801652:	83 ec 04             	sub    $0x4,%esp
  801655:	53                   	push   %ebx
  801656:	50                   	push   %eax
  801657:	68 3c 2e 80 00       	push   $0x802e3c
  80165c:	e8 50 ec ff ff       	call   8002b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801661:	83 c4 10             	add    $0x10,%esp
  801664:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801669:	eb 23                	jmp    80168e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80166b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80166e:	8b 52 18             	mov    0x18(%edx),%edx
  801671:	85 d2                	test   %edx,%edx
  801673:	74 14                	je     801689 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801675:	83 ec 08             	sub    $0x8,%esp
  801678:	ff 75 0c             	pushl  0xc(%ebp)
  80167b:	50                   	push   %eax
  80167c:	ff d2                	call   *%edx
  80167e:	89 c2                	mov    %eax,%edx
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	eb 09                	jmp    80168e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801685:	89 c2                	mov    %eax,%edx
  801687:	eb 05                	jmp    80168e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801689:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80168e:	89 d0                	mov    %edx,%eax
  801690:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801693:	c9                   	leave  
  801694:	c3                   	ret    

00801695 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	53                   	push   %ebx
  801699:	83 ec 14             	sub    $0x14,%esp
  80169c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a2:	50                   	push   %eax
  8016a3:	ff 75 08             	pushl  0x8(%ebp)
  8016a6:	e8 6c fb ff ff       	call   801217 <fd_lookup>
  8016ab:	83 c4 08             	add    $0x8,%esp
  8016ae:	89 c2                	mov    %eax,%edx
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	78 58                	js     80170c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b4:	83 ec 08             	sub    $0x8,%esp
  8016b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ba:	50                   	push   %eax
  8016bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016be:	ff 30                	pushl  (%eax)
  8016c0:	e8 a8 fb ff ff       	call   80126d <dev_lookup>
  8016c5:	83 c4 10             	add    $0x10,%esp
  8016c8:	85 c0                	test   %eax,%eax
  8016ca:	78 37                	js     801703 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016cf:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016d3:	74 32                	je     801707 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016df:	00 00 00 
	stat->st_isdir = 0;
  8016e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e9:	00 00 00 
	stat->st_dev = dev;
  8016ec:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016f2:	83 ec 08             	sub    $0x8,%esp
  8016f5:	53                   	push   %ebx
  8016f6:	ff 75 f0             	pushl  -0x10(%ebp)
  8016f9:	ff 50 14             	call   *0x14(%eax)
  8016fc:	89 c2                	mov    %eax,%edx
  8016fe:	83 c4 10             	add    $0x10,%esp
  801701:	eb 09                	jmp    80170c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801703:	89 c2                	mov    %eax,%edx
  801705:	eb 05                	jmp    80170c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801707:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80170c:	89 d0                	mov    %edx,%eax
  80170e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	56                   	push   %esi
  801717:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801718:	83 ec 08             	sub    $0x8,%esp
  80171b:	6a 00                	push   $0x0
  80171d:	ff 75 08             	pushl  0x8(%ebp)
  801720:	e8 e9 01 00 00       	call   80190e <open>
  801725:	89 c3                	mov    %eax,%ebx
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 1b                	js     801749 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80172e:	83 ec 08             	sub    $0x8,%esp
  801731:	ff 75 0c             	pushl  0xc(%ebp)
  801734:	50                   	push   %eax
  801735:	e8 5b ff ff ff       	call   801695 <fstat>
  80173a:	89 c6                	mov    %eax,%esi
	close(fd);
  80173c:	89 1c 24             	mov    %ebx,(%esp)
  80173f:	e8 fd fb ff ff       	call   801341 <close>
	return r;
  801744:	83 c4 10             	add    $0x10,%esp
  801747:	89 f0                	mov    %esi,%eax
}
  801749:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80174c:	5b                   	pop    %ebx
  80174d:	5e                   	pop    %esi
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801750:	55                   	push   %ebp
  801751:	89 e5                	mov    %esp,%ebp
  801753:	56                   	push   %esi
  801754:	53                   	push   %ebx
  801755:	89 c6                	mov    %eax,%esi
  801757:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801759:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801760:	75 12                	jne    801774 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801762:	83 ec 0c             	sub    $0xc,%esp
  801765:	6a 01                	push   $0x1
  801767:	e8 c2 0e 00 00       	call   80262e <ipc_find_env>
  80176c:	a3 00 50 80 00       	mov    %eax,0x805000
  801771:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801774:	6a 07                	push   $0x7
  801776:	68 00 60 80 00       	push   $0x806000
  80177b:	56                   	push   %esi
  80177c:	ff 35 00 50 80 00    	pushl  0x805000
  801782:	e8 53 0e 00 00       	call   8025da <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801787:	83 c4 0c             	add    $0xc,%esp
  80178a:	6a 00                	push   $0x0
  80178c:	53                   	push   %ebx
  80178d:	6a 00                	push   $0x0
  80178f:	e8 c4 0d 00 00       	call   802558 <ipc_recv>
}
  801794:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801797:	5b                   	pop    %ebx
  801798:	5e                   	pop    %esi
  801799:	5d                   	pop    %ebp
  80179a:	c3                   	ret    

0080179b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80179b:	55                   	push   %ebp
  80179c:	89 e5                	mov    %esp,%ebp
  80179e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a7:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8017ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017af:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b9:	b8 02 00 00 00       	mov    $0x2,%eax
  8017be:	e8 8d ff ff ff       	call   801750 <fsipc>
}
  8017c3:	c9                   	leave  
  8017c4:	c3                   	ret    

008017c5 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d1:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8017d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017db:	b8 06 00 00 00       	mov    $0x6,%eax
  8017e0:	e8 6b ff ff ff       	call   801750 <fsipc>
}
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    

008017e7 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	53                   	push   %ebx
  8017eb:	83 ec 04             	sub    $0x4,%esp
  8017ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017f7:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017fc:	ba 00 00 00 00       	mov    $0x0,%edx
  801801:	b8 05 00 00 00       	mov    $0x5,%eax
  801806:	e8 45 ff ff ff       	call   801750 <fsipc>
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 2c                	js     80183b <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80180f:	83 ec 08             	sub    $0x8,%esp
  801812:	68 00 60 80 00       	push   $0x806000
  801817:	53                   	push   %ebx
  801818:	e8 98 f0 ff ff       	call   8008b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80181d:	a1 80 60 80 00       	mov    0x806080,%eax
  801822:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801828:	a1 84 60 80 00       	mov    0x806084,%eax
  80182d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801833:	83 c4 10             	add    $0x10,%esp
  801836:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80183b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	83 ec 0c             	sub    $0xc,%esp
  801846:	8b 45 10             	mov    0x10(%ebp),%eax
  801849:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80184e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801853:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801856:	8b 55 08             	mov    0x8(%ebp),%edx
  801859:	8b 52 0c             	mov    0xc(%edx),%edx
  80185c:	89 15 00 60 80 00    	mov    %edx,0x806000
    fsipcbuf.write.req_n = n;
  801862:	a3 04 60 80 00       	mov    %eax,0x806004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801867:	50                   	push   %eax
  801868:	ff 75 0c             	pushl  0xc(%ebp)
  80186b:	68 08 60 80 00       	push   $0x806008
  801870:	e8 d2 f1 ff ff       	call   800a47 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801875:	ba 00 00 00 00       	mov    $0x0,%edx
  80187a:	b8 04 00 00 00       	mov    $0x4,%eax
  80187f:	e8 cc fe ff ff       	call   801750 <fsipc>
            return r;

    return r;
}
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80188e:	8b 45 08             	mov    0x8(%ebp),%eax
  801891:	8b 40 0c             	mov    0xc(%eax),%eax
  801894:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801899:	89 35 04 60 80 00    	mov    %esi,0x806004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80189f:	ba 00 00 00 00       	mov    $0x0,%edx
  8018a4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018a9:	e8 a2 fe ff ff       	call   801750 <fsipc>
  8018ae:	89 c3                	mov    %eax,%ebx
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 51                	js     801905 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8018b4:	39 c6                	cmp    %eax,%esi
  8018b6:	73 19                	jae    8018d1 <devfile_read+0x4b>
  8018b8:	68 a8 2e 80 00       	push   $0x802ea8
  8018bd:	68 af 2e 80 00       	push   $0x802eaf
  8018c2:	68 82 00 00 00       	push   $0x82
  8018c7:	68 c4 2e 80 00       	push   $0x802ec4
  8018cc:	e8 07 e9 ff ff       	call   8001d8 <_panic>
	assert(r <= PGSIZE);
  8018d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018d6:	7e 19                	jle    8018f1 <devfile_read+0x6b>
  8018d8:	68 cf 2e 80 00       	push   $0x802ecf
  8018dd:	68 af 2e 80 00       	push   $0x802eaf
  8018e2:	68 83 00 00 00       	push   $0x83
  8018e7:	68 c4 2e 80 00       	push   $0x802ec4
  8018ec:	e8 e7 e8 ff ff       	call   8001d8 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018f1:	83 ec 04             	sub    $0x4,%esp
  8018f4:	50                   	push   %eax
  8018f5:	68 00 60 80 00       	push   $0x806000
  8018fa:	ff 75 0c             	pushl  0xc(%ebp)
  8018fd:	e8 45 f1 ff ff       	call   800a47 <memmove>
	return r;
  801902:	83 c4 10             	add    $0x10,%esp
}
  801905:	89 d8                	mov    %ebx,%eax
  801907:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	53                   	push   %ebx
  801912:	83 ec 20             	sub    $0x20,%esp
  801915:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801918:	53                   	push   %ebx
  801919:	e8 5e ef ff ff       	call   80087c <strlen>
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801926:	7f 67                	jg     80198f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801928:	83 ec 0c             	sub    $0xc,%esp
  80192b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192e:	50                   	push   %eax
  80192f:	e8 94 f8 ff ff       	call   8011c8 <fd_alloc>
  801934:	83 c4 10             	add    $0x10,%esp
		return r;
  801937:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801939:	85 c0                	test   %eax,%eax
  80193b:	78 57                	js     801994 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80193d:	83 ec 08             	sub    $0x8,%esp
  801940:	53                   	push   %ebx
  801941:	68 00 60 80 00       	push   $0x806000
  801946:	e8 6a ef ff ff       	call   8008b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80194b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194e:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801953:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801956:	b8 01 00 00 00       	mov    $0x1,%eax
  80195b:	e8 f0 fd ff ff       	call   801750 <fsipc>
  801960:	89 c3                	mov    %eax,%ebx
  801962:	83 c4 10             	add    $0x10,%esp
  801965:	85 c0                	test   %eax,%eax
  801967:	79 14                	jns    80197d <open+0x6f>
		fd_close(fd, 0);
  801969:	83 ec 08             	sub    $0x8,%esp
  80196c:	6a 00                	push   $0x0
  80196e:	ff 75 f4             	pushl  -0xc(%ebp)
  801971:	e8 4a f9 ff ff       	call   8012c0 <fd_close>
		return r;
  801976:	83 c4 10             	add    $0x10,%esp
  801979:	89 da                	mov    %ebx,%edx
  80197b:	eb 17                	jmp    801994 <open+0x86>
	}

	return fd2num(fd);
  80197d:	83 ec 0c             	sub    $0xc,%esp
  801980:	ff 75 f4             	pushl  -0xc(%ebp)
  801983:	e8 19 f8 ff ff       	call   8011a1 <fd2num>
  801988:	89 c2                	mov    %eax,%edx
  80198a:	83 c4 10             	add    $0x10,%esp
  80198d:	eb 05                	jmp    801994 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80198f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801994:	89 d0                	mov    %edx,%eax
  801996:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801999:	c9                   	leave  
  80199a:	c3                   	ret    

0080199b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a6:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ab:	e8 a0 fd ff ff       	call   801750 <fsipc>
}
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	57                   	push   %edi
  8019b6:	56                   	push   %esi
  8019b7:	53                   	push   %ebx
  8019b8:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().
	
	// 打开文件
	if ((r = open(prog, O_RDONLY)) < 0)
  8019be:	6a 00                	push   $0x0
  8019c0:	ff 75 08             	pushl  0x8(%ebp)
  8019c3:	e8 46 ff ff ff       	call   80190e <open>
  8019c8:	89 c7                	mov    %eax,%edi
  8019ca:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	0f 88 95 04 00 00    	js     801e70 <spawn+0x4be>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8019db:	83 ec 04             	sub    $0x4,%esp
  8019de:	68 00 02 00 00       	push   $0x200
  8019e3:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8019e9:	50                   	push   %eax
  8019ea:	57                   	push   %edi
  8019eb:	e8 1e fb ff ff       	call   80150e <readn>
  8019f0:	83 c4 10             	add    $0x10,%esp
  8019f3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8019f8:	75 0c                	jne    801a06 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8019fa:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801a01:	45 4c 46 
  801a04:	74 33                	je     801a39 <spawn+0x87>
		close(fd);
  801a06:	83 ec 0c             	sub    $0xc,%esp
  801a09:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a0f:	e8 2d f9 ff ff       	call   801341 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801a14:	83 c4 0c             	add    $0xc,%esp
  801a17:	68 7f 45 4c 46       	push   $0x464c457f
  801a1c:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a22:	68 db 2e 80 00       	push   $0x802edb
  801a27:	e8 85 e8 ff ff       	call   8002b1 <cprintf>
		return -E_NOT_EXEC;
  801a2c:	83 c4 10             	add    $0x10,%esp
  801a2f:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801a34:	e9 da 04 00 00       	jmp    801f13 <spawn+0x561>
  801a39:	b8 07 00 00 00       	mov    $0x7,%eax
  801a3e:	cd 30                	int    $0x30
  801a40:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801a46:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	0f 88 27 04 00 00    	js     801e7b <spawn+0x4c9>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	// 设置寄存器信息
	child_tf = envs[ENVX(child)].env_tf;
  801a54:	89 c6                	mov    %eax,%esi
  801a56:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801a5c:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801a5f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801a65:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801a6b:	b9 11 00 00 00       	mov    $0x11,%ecx
  801a70:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801a72:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801a78:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a7e:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801a83:	be 00 00 00 00       	mov    $0x0,%esi
  801a88:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a8b:	eb 13                	jmp    801aa0 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	50                   	push   %eax
  801a91:	e8 e6 ed ff ff       	call   80087c <strlen>
  801a96:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801a9a:	83 c3 01             	add    $0x1,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  801aa7:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	75 df                	jne    801a8d <spawn+0xdb>
  801aae:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801ab4:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  801aba:	bf 00 10 40 00       	mov    $0x401000,%edi
  801abf:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801ac1:	89 fa                	mov    %edi,%edx
  801ac3:	83 e2 fc             	and    $0xfffffffc,%edx
  801ac6:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801acd:	29 c2                	sub    %eax,%edx
  801acf:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801ad5:	8d 42 f8             	lea    -0x8(%edx),%eax
  801ad8:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801add:	0f 86 ae 03 00 00    	jbe    801e91 <spawn+0x4df>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ae3:	83 ec 04             	sub    $0x4,%esp
  801ae6:	6a 07                	push   $0x7
  801ae8:	68 00 00 40 00       	push   $0x400000
  801aed:	6a 00                	push   $0x0
  801aef:	e8 c4 f1 ff ff       	call   800cb8 <sys_page_alloc>
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	0f 88 99 03 00 00    	js     801e98 <spawn+0x4e6>
  801aff:	be 00 00 00 00       	mov    $0x0,%esi
  801b04:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  801b0a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801b0d:	eb 30                	jmp    801b3f <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801b0f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801b15:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  801b1b:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801b1e:	83 ec 08             	sub    $0x8,%esp
  801b21:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b24:	57                   	push   %edi
  801b25:	e8 8b ed ff ff       	call   8008b5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801b2a:	83 c4 04             	add    $0x4,%esp
  801b2d:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801b30:	e8 47 ed ff ff       	call   80087c <strlen>
  801b35:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801b39:	83 c6 01             	add    $0x1,%esi
  801b3c:	83 c4 10             	add    $0x10,%esp
  801b3f:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801b45:	7f c8                	jg     801b0f <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801b47:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b4d:	8b 95 80 fd ff ff    	mov    -0x280(%ebp),%edx
  801b53:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801b5a:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801b60:	74 19                	je     801b7b <spawn+0x1c9>
  801b62:	68 68 2f 80 00       	push   $0x802f68
  801b67:	68 af 2e 80 00       	push   $0x802eaf
  801b6c:	68 f8 00 00 00       	push   $0xf8
  801b71:	68 f5 2e 80 00       	push   $0x802ef5
  801b76:	e8 5d e6 ff ff       	call   8001d8 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801b7b:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801b81:	89 f8                	mov    %edi,%eax
  801b83:	2d 00 30 80 11       	sub    $0x11803000,%eax
  801b88:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801b8b:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801b91:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801b94:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  801b9a:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801ba0:	83 ec 0c             	sub    $0xc,%esp
  801ba3:	6a 07                	push   $0x7
  801ba5:	68 00 d0 bf ee       	push   $0xeebfd000
  801baa:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801bb0:	68 00 00 40 00       	push   $0x400000
  801bb5:	6a 00                	push   $0x0
  801bb7:	e8 3f f1 ff ff       	call   800cfb <sys_page_map>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	83 c4 20             	add    $0x20,%esp
  801bc1:	85 c0                	test   %eax,%eax
  801bc3:	0f 88 38 03 00 00    	js     801f01 <spawn+0x54f>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801bc9:	83 ec 08             	sub    $0x8,%esp
  801bcc:	68 00 00 40 00       	push   $0x400000
  801bd1:	6a 00                	push   $0x0
  801bd3:	e8 65 f1 ff ff       	call   800d3d <sys_page_unmap>
  801bd8:	89 c3                	mov    %eax,%ebx
  801bda:	83 c4 10             	add    $0x10,%esp
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	0f 88 1c 03 00 00    	js     801f01 <spawn+0x54f>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// 加载程序到进程空间
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801be5:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801beb:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801bf2:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801bf8:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801bff:	00 00 00 
  801c02:	e9 88 01 00 00       	jmp    801d8f <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  801c07:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801c0d:	83 38 01             	cmpl   $0x1,(%eax)
  801c10:	0f 85 6b 01 00 00    	jne    801d81 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801c16:	89 c7                	mov    %eax,%edi
  801c18:	8b 40 18             	mov    0x18(%eax),%eax
  801c1b:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801c21:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801c24:	83 f8 01             	cmp    $0x1,%eax
  801c27:	19 c0                	sbb    %eax,%eax
  801c29:	83 e0 fe             	and    $0xfffffffe,%eax
  801c2c:	83 c0 07             	add    $0x7,%eax
  801c2f:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801c35:	89 f8                	mov    %edi,%eax
  801c37:	8b 7f 04             	mov    0x4(%edi),%edi
  801c3a:	89 fa                	mov    %edi,%edx
  801c3c:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801c42:	8b 78 10             	mov    0x10(%eax),%edi
  801c45:	8b 48 14             	mov    0x14(%eax),%ecx
  801c48:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801c4e:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801c51:	89 f0                	mov    %esi,%eax
  801c53:	25 ff 0f 00 00       	and    $0xfff,%eax
  801c58:	74 14                	je     801c6e <spawn+0x2bc>
		va -= i;
  801c5a:	29 c6                	sub    %eax,%esi
		memsz += i;
  801c5c:	01 c1                	add    %eax,%ecx
  801c5e:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
		filesz += i;
  801c64:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801c66:	29 c2                	sub    %eax,%edx
  801c68:	89 95 80 fd ff ff    	mov    %edx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c6e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c73:	e9 f7 00 00 00       	jmp    801d6f <spawn+0x3bd>
		if (i >= filesz) {
  801c78:	39 fb                	cmp    %edi,%ebx
  801c7a:	72 27                	jb     801ca3 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801c7c:	83 ec 04             	sub    $0x4,%esp
  801c7f:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801c85:	56                   	push   %esi
  801c86:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801c8c:	e8 27 f0 ff ff       	call   800cb8 <sys_page_alloc>
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	85 c0                	test   %eax,%eax
  801c96:	0f 89 c7 00 00 00    	jns    801d63 <spawn+0x3b1>
  801c9c:	89 c3                	mov    %eax,%ebx
  801c9e:	e9 03 02 00 00       	jmp    801ea6 <spawn+0x4f4>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ca3:	83 ec 04             	sub    $0x4,%esp
  801ca6:	6a 07                	push   $0x7
  801ca8:	68 00 00 40 00       	push   $0x400000
  801cad:	6a 00                	push   $0x0
  801caf:	e8 04 f0 ff ff       	call   800cb8 <sys_page_alloc>
  801cb4:	83 c4 10             	add    $0x10,%esp
  801cb7:	85 c0                	test   %eax,%eax
  801cb9:	0f 88 dd 01 00 00    	js     801e9c <spawn+0x4ea>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801cbf:	83 ec 08             	sub    $0x8,%esp
  801cc2:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  801cc8:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801cce:	50                   	push   %eax
  801ccf:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cd5:	e8 09 f9 ff ff       	call   8015e3 <seek>
  801cda:	83 c4 10             	add    $0x10,%esp
  801cdd:	85 c0                	test   %eax,%eax
  801cdf:	0f 88 bb 01 00 00    	js     801ea0 <spawn+0x4ee>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ce5:	83 ec 04             	sub    $0x4,%esp
  801ce8:	89 f8                	mov    %edi,%eax
  801cea:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801cf0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801cf5:	ba 00 10 00 00       	mov    $0x1000,%edx
  801cfa:	0f 47 c2             	cmova  %edx,%eax
  801cfd:	50                   	push   %eax
  801cfe:	68 00 00 40 00       	push   $0x400000
  801d03:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d09:	e8 00 f8 ff ff       	call   80150e <readn>
  801d0e:	83 c4 10             	add    $0x10,%esp
  801d11:	85 c0                	test   %eax,%eax
  801d13:	0f 88 8b 01 00 00    	js     801ea4 <spawn+0x4f2>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801d19:	83 ec 0c             	sub    $0xc,%esp
  801d1c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801d22:	56                   	push   %esi
  801d23:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801d29:	68 00 00 40 00       	push   $0x400000
  801d2e:	6a 00                	push   $0x0
  801d30:	e8 c6 ef ff ff       	call   800cfb <sys_page_map>
  801d35:	83 c4 20             	add    $0x20,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	79 15                	jns    801d51 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801d3c:	50                   	push   %eax
  801d3d:	68 01 2f 80 00       	push   $0x802f01
  801d42:	68 2b 01 00 00       	push   $0x12b
  801d47:	68 f5 2e 80 00       	push   $0x802ef5
  801d4c:	e8 87 e4 ff ff       	call   8001d8 <_panic>
			sys_page_unmap(0, UTEMP);
  801d51:	83 ec 08             	sub    $0x8,%esp
  801d54:	68 00 00 40 00       	push   $0x400000
  801d59:	6a 00                	push   $0x0
  801d5b:	e8 dd ef ff ff       	call   800d3d <sys_page_unmap>
  801d60:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801d63:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801d69:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801d6f:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801d75:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801d7b:	0f 82 f7 fe ff ff    	jb     801c78 <spawn+0x2c6>
		return r;

	// 加载程序到进程空间
	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801d81:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801d88:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801d8f:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801d96:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801d9c:	0f 8c 65 fe ff ff    	jl     801c07 <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801da2:	83 ec 0c             	sub    $0xc,%esp
  801da5:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801dab:	e8 91 f5 ff ff       	call   801341 <close>
  801db0:	83 c4 10             	add    $0x10,%esp
{
	// LAB 5: Your code here.
	int r;
	void *addr;

	for (addr = 0; addr < (void *) USTACKTOP; addr += PGSIZE) {
  801db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  801db8:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P)
  801dbe:	89 d8                	mov    %ebx,%eax
  801dc0:	c1 e8 16             	shr    $0x16,%eax
  801dc3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801dca:	a8 01                	test   $0x1,%al
  801dcc:	74 4e                	je     801e1c <spawn+0x46a>
  801dce:	89 d8                	mov    %ebx,%eax
  801dd0:	c1 e8 0c             	shr    $0xc,%eax
  801dd3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801dda:	f6 c2 01             	test   $0x1,%dl
  801ddd:	74 3d                	je     801e1c <spawn+0x46a>
			&& (uvpt[PGNUM(addr)] & PTE_U) && (uvpt[PGNUM(addr)] & PTE_SHARE))
  801ddf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801de6:	f6 c2 04             	test   $0x4,%dl
  801de9:	74 31                	je     801e1c <spawn+0x46a>
  801deb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801df2:	f6 c6 04             	test   $0x4,%dh
  801df5:	74 25                	je     801e1c <spawn+0x46a>
			if ((r = sys_page_map(0, addr, child, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0) 
  801df7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801dfe:	83 ec 0c             	sub    $0xc,%esp
  801e01:	25 07 0e 00 00       	and    $0xe07,%eax
  801e06:	50                   	push   %eax
  801e07:	53                   	push   %ebx
  801e08:	56                   	push   %esi
  801e09:	53                   	push   %ebx
  801e0a:	6a 00                	push   $0x0
  801e0c:	e8 ea ee ff ff       	call   800cfb <sys_page_map>
  801e11:	83 c4 20             	add    $0x20,%esp
  801e14:	85 c0                	test   %eax,%eax
  801e16:	0f 88 ab 00 00 00    	js     801ec7 <spawn+0x515>
{
	// LAB 5: Your code here.
	int r;
	void *addr;

	for (addr = 0; addr < (void *) USTACKTOP; addr += PGSIZE) {
  801e1c:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801e22:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801e28:	75 94                	jne    801dbe <spawn+0x40c>
  801e2a:	e9 ad 00 00 00       	jmp    801edc <spawn+0x52a>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	// 初始化新建进程的寄存器信息
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801e2f:	50                   	push   %eax
  801e30:	68 1e 2f 80 00       	push   $0x802f1e
  801e35:	68 8b 00 00 00       	push   $0x8b
  801e3a:	68 f5 2e 80 00       	push   $0x802ef5
  801e3f:	e8 94 e3 ff ff       	call   8001d8 <_panic>

	// 设置进程状态
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801e44:	83 ec 08             	sub    $0x8,%esp
  801e47:	6a 02                	push   $0x2
  801e49:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801e4f:	e8 2b ef ff ff       	call   800d7f <sys_env_set_status>
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	85 c0                	test   %eax,%eax
  801e59:	79 2b                	jns    801e86 <spawn+0x4d4>
		panic("sys_env_set_status: %e", r);
  801e5b:	50                   	push   %eax
  801e5c:	68 38 2f 80 00       	push   $0x802f38
  801e61:	68 8f 00 00 00       	push   $0x8f
  801e66:	68 f5 2e 80 00       	push   $0x802ef5
  801e6b:	e8 68 e3 ff ff       	call   8001d8 <_panic>
	//
	//   - Start the child process running with sys_env_set_status().
	
	// 打开文件
	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801e70:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801e76:	e9 98 00 00 00       	jmp    801f13 <spawn+0x561>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801e7b:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e81:	e9 8d 00 00 00       	jmp    801f13 <spawn+0x561>

	// 设置进程状态
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801e86:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801e8c:	e9 82 00 00 00       	jmp    801f13 <spawn+0x561>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801e91:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801e96:	eb 7b                	jmp    801f13 <spawn+0x561>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801e98:	89 c3                	mov    %eax,%ebx
  801e9a:	eb 77                	jmp    801f13 <spawn+0x561>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801e9c:	89 c3                	mov    %eax,%ebx
  801e9e:	eb 06                	jmp    801ea6 <spawn+0x4f4>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ea0:	89 c3                	mov    %eax,%ebx
  801ea2:	eb 02                	jmp    801ea6 <spawn+0x4f4>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801ea4:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801eaf:	e8 85 ed ff ff       	call   800c39 <sys_env_destroy>
	close(fd);
  801eb4:	83 c4 04             	add    $0x4,%esp
  801eb7:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ebd:	e8 7f f4 ff ff       	call   801341 <close>
	return r;
  801ec2:	83 c4 10             	add    $0x10,%esp
  801ec5:	eb 4c                	jmp    801f13 <spawn+0x561>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801ec7:	50                   	push   %eax
  801ec8:	68 4f 2f 80 00       	push   $0x802f4f
  801ecd:	68 87 00 00 00       	push   $0x87
  801ed2:	68 f5 2e 80 00       	push   $0x802ef5
  801ed7:	e8 fc e2 ff ff       	call   8001d8 <_panic>

	// 初始化新建进程的寄存器信息
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801edc:	83 ec 08             	sub    $0x8,%esp
  801edf:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ee5:	50                   	push   %eax
  801ee6:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801eec:	e8 d0 ee ff ff       	call   800dc1 <sys_env_set_trapframe>
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	85 c0                	test   %eax,%eax
  801ef6:	0f 89 48 ff ff ff    	jns    801e44 <spawn+0x492>
  801efc:	e9 2e ff ff ff       	jmp    801e2f <spawn+0x47d>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801f01:	83 ec 08             	sub    $0x8,%esp
  801f04:	68 00 00 40 00       	push   $0x400000
  801f09:	6a 00                	push   $0x0
  801f0b:	e8 2d ee ff ff       	call   800d3d <sys_page_unmap>
  801f10:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801f13:	89 d8                	mov    %ebx,%eax
  801f15:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f18:	5b                   	pop    %ebx
  801f19:	5e                   	pop    %esi
  801f1a:	5f                   	pop    %edi
  801f1b:	5d                   	pop    %ebp
  801f1c:	c3                   	ret    

00801f1d <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801f1d:	55                   	push   %ebp
  801f1e:	89 e5                	mov    %esp,%ebp
  801f20:	56                   	push   %esi
  801f21:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f22:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801f25:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f2a:	eb 03                	jmp    801f2f <spawnl+0x12>
		argc++;
  801f2c:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801f2f:	83 c2 04             	add    $0x4,%edx
  801f32:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801f36:	75 f4                	jne    801f2c <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801f38:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801f3f:	83 e2 f0             	and    $0xfffffff0,%edx
  801f42:	29 d4                	sub    %edx,%esp
  801f44:	8d 54 24 03          	lea    0x3(%esp),%edx
  801f48:	c1 ea 02             	shr    $0x2,%edx
  801f4b:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801f52:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801f54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f57:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801f5e:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801f65:	00 
  801f66:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f68:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6d:	eb 0a                	jmp    801f79 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801f6f:	83 c0 01             	add    $0x1,%eax
  801f72:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801f76:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801f79:	39 d0                	cmp    %edx,%eax
  801f7b:	75 f2                	jne    801f6f <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801f7d:	83 ec 08             	sub    $0x8,%esp
  801f80:	56                   	push   %esi
  801f81:	ff 75 08             	pushl  0x8(%ebp)
  801f84:	e8 29 fa ff ff       	call   8019b2 <spawn>
}
  801f89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f8c:	5b                   	pop    %ebx
  801f8d:	5e                   	pop    %esi
  801f8e:	5d                   	pop    %ebp
  801f8f:	c3                   	ret    

00801f90 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f90:	55                   	push   %ebp
  801f91:	89 e5                	mov    %esp,%ebp
  801f93:	56                   	push   %esi
  801f94:	53                   	push   %ebx
  801f95:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f98:	83 ec 0c             	sub    $0xc,%esp
  801f9b:	ff 75 08             	pushl  0x8(%ebp)
  801f9e:	e8 0e f2 ff ff       	call   8011b1 <fd2data>
  801fa3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801fa5:	83 c4 08             	add    $0x8,%esp
  801fa8:	68 90 2f 80 00       	push   $0x802f90
  801fad:	53                   	push   %ebx
  801fae:	e8 02 e9 ff ff       	call   8008b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801fb3:	8b 46 04             	mov    0x4(%esi),%eax
  801fb6:	2b 06                	sub    (%esi),%eax
  801fb8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801fbe:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801fc5:	00 00 00 
	stat->st_dev = &devpipe;
  801fc8:	c7 83 88 00 00 00 28 	movl   $0x804028,0x88(%ebx)
  801fcf:	40 80 00 
	return 0;
}
  801fd2:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fda:	5b                   	pop    %ebx
  801fdb:	5e                   	pop    %esi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	53                   	push   %ebx
  801fe2:	83 ec 0c             	sub    $0xc,%esp
  801fe5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fe8:	53                   	push   %ebx
  801fe9:	6a 00                	push   $0x0
  801feb:	e8 4d ed ff ff       	call   800d3d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ff0:	89 1c 24             	mov    %ebx,(%esp)
  801ff3:	e8 b9 f1 ff ff       	call   8011b1 <fd2data>
  801ff8:	83 c4 08             	add    $0x8,%esp
  801ffb:	50                   	push   %eax
  801ffc:	6a 00                	push   $0x0
  801ffe:	e8 3a ed ff ff       	call   800d3d <sys_page_unmap>
}
  802003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802006:	c9                   	leave  
  802007:	c3                   	ret    

00802008 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802008:	55                   	push   %ebp
  802009:	89 e5                	mov    %esp,%ebp
  80200b:	57                   	push   %edi
  80200c:	56                   	push   %esi
  80200d:	53                   	push   %ebx
  80200e:	83 ec 1c             	sub    $0x1c,%esp
  802011:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802014:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802016:	a1 04 50 80 00       	mov    0x805004,%eax
  80201b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80201e:	83 ec 0c             	sub    $0xc,%esp
  802021:	ff 75 e0             	pushl  -0x20(%ebp)
  802024:	e8 3e 06 00 00       	call   802667 <pageref>
  802029:	89 c3                	mov    %eax,%ebx
  80202b:	89 3c 24             	mov    %edi,(%esp)
  80202e:	e8 34 06 00 00       	call   802667 <pageref>
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	39 c3                	cmp    %eax,%ebx
  802038:	0f 94 c1             	sete   %cl
  80203b:	0f b6 c9             	movzbl %cl,%ecx
  80203e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  802041:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802047:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80204a:	39 ce                	cmp    %ecx,%esi
  80204c:	74 1b                	je     802069 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  80204e:	39 c3                	cmp    %eax,%ebx
  802050:	75 c4                	jne    802016 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802052:	8b 42 58             	mov    0x58(%edx),%eax
  802055:	ff 75 e4             	pushl  -0x1c(%ebp)
  802058:	50                   	push   %eax
  802059:	56                   	push   %esi
  80205a:	68 97 2f 80 00       	push   $0x802f97
  80205f:	e8 4d e2 ff ff       	call   8002b1 <cprintf>
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	eb ad                	jmp    802016 <_pipeisclosed+0xe>
	}
}
  802069:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80206c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5f                   	pop    %edi
  802072:	5d                   	pop    %ebp
  802073:	c3                   	ret    

00802074 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802074:	55                   	push   %ebp
  802075:	89 e5                	mov    %esp,%ebp
  802077:	57                   	push   %edi
  802078:	56                   	push   %esi
  802079:	53                   	push   %ebx
  80207a:	83 ec 28             	sub    $0x28,%esp
  80207d:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802080:	56                   	push   %esi
  802081:	e8 2b f1 ff ff       	call   8011b1 <fd2data>
  802086:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802088:	83 c4 10             	add    $0x10,%esp
  80208b:	bf 00 00 00 00       	mov    $0x0,%edi
  802090:	eb 4b                	jmp    8020dd <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802092:	89 da                	mov    %ebx,%edx
  802094:	89 f0                	mov    %esi,%eax
  802096:	e8 6d ff ff ff       	call   802008 <_pipeisclosed>
  80209b:	85 c0                	test   %eax,%eax
  80209d:	75 48                	jne    8020e7 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80209f:	e8 f5 eb ff ff       	call   800c99 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8020a4:	8b 43 04             	mov    0x4(%ebx),%eax
  8020a7:	8b 0b                	mov    (%ebx),%ecx
  8020a9:	8d 51 20             	lea    0x20(%ecx),%edx
  8020ac:	39 d0                	cmp    %edx,%eax
  8020ae:	73 e2                	jae    802092 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8020b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020b3:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8020b7:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020ba:	89 c2                	mov    %eax,%edx
  8020bc:	c1 fa 1f             	sar    $0x1f,%edx
  8020bf:	89 d1                	mov    %edx,%ecx
  8020c1:	c1 e9 1b             	shr    $0x1b,%ecx
  8020c4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020c7:	83 e2 1f             	and    $0x1f,%edx
  8020ca:	29 ca                	sub    %ecx,%edx
  8020cc:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020d0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020d4:	83 c0 01             	add    $0x1,%eax
  8020d7:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020da:	83 c7 01             	add    $0x1,%edi
  8020dd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8020e0:	75 c2                	jne    8020a4 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8020e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8020e5:	eb 05                	jmp    8020ec <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8020e7:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8020ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    

008020f4 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020f4:	55                   	push   %ebp
  8020f5:	89 e5                	mov    %esp,%ebp
  8020f7:	57                   	push   %edi
  8020f8:	56                   	push   %esi
  8020f9:	53                   	push   %ebx
  8020fa:	83 ec 18             	sub    $0x18,%esp
  8020fd:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802100:	57                   	push   %edi
  802101:	e8 ab f0 ff ff       	call   8011b1 <fd2data>
  802106:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802110:	eb 3d                	jmp    80214f <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802112:	85 db                	test   %ebx,%ebx
  802114:	74 04                	je     80211a <devpipe_read+0x26>
				return i;
  802116:	89 d8                	mov    %ebx,%eax
  802118:	eb 44                	jmp    80215e <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80211a:	89 f2                	mov    %esi,%edx
  80211c:	89 f8                	mov    %edi,%eax
  80211e:	e8 e5 fe ff ff       	call   802008 <_pipeisclosed>
  802123:	85 c0                	test   %eax,%eax
  802125:	75 32                	jne    802159 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802127:	e8 6d eb ff ff       	call   800c99 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80212c:	8b 06                	mov    (%esi),%eax
  80212e:	3b 46 04             	cmp    0x4(%esi),%eax
  802131:	74 df                	je     802112 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802133:	99                   	cltd   
  802134:	c1 ea 1b             	shr    $0x1b,%edx
  802137:	01 d0                	add    %edx,%eax
  802139:	83 e0 1f             	and    $0x1f,%eax
  80213c:	29 d0                	sub    %edx,%eax
  80213e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802143:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802146:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802149:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80214c:	83 c3 01             	add    $0x1,%ebx
  80214f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802152:	75 d8                	jne    80212c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802154:	8b 45 10             	mov    0x10(%ebp),%eax
  802157:	eb 05                	jmp    80215e <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802159:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80215e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802161:	5b                   	pop    %ebx
  802162:	5e                   	pop    %esi
  802163:	5f                   	pop    %edi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    

00802166 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	56                   	push   %esi
  80216a:	53                   	push   %ebx
  80216b:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80216e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802171:	50                   	push   %eax
  802172:	e8 51 f0 ff ff       	call   8011c8 <fd_alloc>
  802177:	83 c4 10             	add    $0x10,%esp
  80217a:	89 c2                	mov    %eax,%edx
  80217c:	85 c0                	test   %eax,%eax
  80217e:	0f 88 2c 01 00 00    	js     8022b0 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802184:	83 ec 04             	sub    $0x4,%esp
  802187:	68 07 04 00 00       	push   $0x407
  80218c:	ff 75 f4             	pushl  -0xc(%ebp)
  80218f:	6a 00                	push   $0x0
  802191:	e8 22 eb ff ff       	call   800cb8 <sys_page_alloc>
  802196:	83 c4 10             	add    $0x10,%esp
  802199:	89 c2                	mov    %eax,%edx
  80219b:	85 c0                	test   %eax,%eax
  80219d:	0f 88 0d 01 00 00    	js     8022b0 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8021a3:	83 ec 0c             	sub    $0xc,%esp
  8021a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8021a9:	50                   	push   %eax
  8021aa:	e8 19 f0 ff ff       	call   8011c8 <fd_alloc>
  8021af:	89 c3                	mov    %eax,%ebx
  8021b1:	83 c4 10             	add    $0x10,%esp
  8021b4:	85 c0                	test   %eax,%eax
  8021b6:	0f 88 e2 00 00 00    	js     80229e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021bc:	83 ec 04             	sub    $0x4,%esp
  8021bf:	68 07 04 00 00       	push   $0x407
  8021c4:	ff 75 f0             	pushl  -0x10(%ebp)
  8021c7:	6a 00                	push   $0x0
  8021c9:	e8 ea ea ff ff       	call   800cb8 <sys_page_alloc>
  8021ce:	89 c3                	mov    %eax,%ebx
  8021d0:	83 c4 10             	add    $0x10,%esp
  8021d3:	85 c0                	test   %eax,%eax
  8021d5:	0f 88 c3 00 00 00    	js     80229e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8021db:	83 ec 0c             	sub    $0xc,%esp
  8021de:	ff 75 f4             	pushl  -0xc(%ebp)
  8021e1:	e8 cb ef ff ff       	call   8011b1 <fd2data>
  8021e6:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021e8:	83 c4 0c             	add    $0xc,%esp
  8021eb:	68 07 04 00 00       	push   $0x407
  8021f0:	50                   	push   %eax
  8021f1:	6a 00                	push   $0x0
  8021f3:	e8 c0 ea ff ff       	call   800cb8 <sys_page_alloc>
  8021f8:	89 c3                	mov    %eax,%ebx
  8021fa:	83 c4 10             	add    $0x10,%esp
  8021fd:	85 c0                	test   %eax,%eax
  8021ff:	0f 88 89 00 00 00    	js     80228e <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802205:	83 ec 0c             	sub    $0xc,%esp
  802208:	ff 75 f0             	pushl  -0x10(%ebp)
  80220b:	e8 a1 ef ff ff       	call   8011b1 <fd2data>
  802210:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802217:	50                   	push   %eax
  802218:	6a 00                	push   $0x0
  80221a:	56                   	push   %esi
  80221b:	6a 00                	push   $0x0
  80221d:	e8 d9 ea ff ff       	call   800cfb <sys_page_map>
  802222:	89 c3                	mov    %eax,%ebx
  802224:	83 c4 20             	add    $0x20,%esp
  802227:	85 c0                	test   %eax,%eax
  802229:	78 55                	js     802280 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80222b:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802231:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802234:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802239:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802240:	8b 15 28 40 80 00    	mov    0x804028,%edx
  802246:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802249:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80224b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80224e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802255:	83 ec 0c             	sub    $0xc,%esp
  802258:	ff 75 f4             	pushl  -0xc(%ebp)
  80225b:	e8 41 ef ff ff       	call   8011a1 <fd2num>
  802260:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802263:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802265:	83 c4 04             	add    $0x4,%esp
  802268:	ff 75 f0             	pushl  -0x10(%ebp)
  80226b:	e8 31 ef ff ff       	call   8011a1 <fd2num>
  802270:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802273:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802276:	83 c4 10             	add    $0x10,%esp
  802279:	ba 00 00 00 00       	mov    $0x0,%edx
  80227e:	eb 30                	jmp    8022b0 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802280:	83 ec 08             	sub    $0x8,%esp
  802283:	56                   	push   %esi
  802284:	6a 00                	push   $0x0
  802286:	e8 b2 ea ff ff       	call   800d3d <sys_page_unmap>
  80228b:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  80228e:	83 ec 08             	sub    $0x8,%esp
  802291:	ff 75 f0             	pushl  -0x10(%ebp)
  802294:	6a 00                	push   $0x0
  802296:	e8 a2 ea ff ff       	call   800d3d <sys_page_unmap>
  80229b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80229e:	83 ec 08             	sub    $0x8,%esp
  8022a1:	ff 75 f4             	pushl  -0xc(%ebp)
  8022a4:	6a 00                	push   $0x0
  8022a6:	e8 92 ea ff ff       	call   800d3d <sys_page_unmap>
  8022ab:	83 c4 10             	add    $0x10,%esp
  8022ae:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8022b0:	89 d0                	mov    %edx,%eax
  8022b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022b5:	5b                   	pop    %ebx
  8022b6:	5e                   	pop    %esi
  8022b7:	5d                   	pop    %ebp
  8022b8:	c3                   	ret    

008022b9 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8022b9:	55                   	push   %ebp
  8022ba:	89 e5                	mov    %esp,%ebp
  8022bc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022c2:	50                   	push   %eax
  8022c3:	ff 75 08             	pushl  0x8(%ebp)
  8022c6:	e8 4c ef ff ff       	call   801217 <fd_lookup>
  8022cb:	83 c4 10             	add    $0x10,%esp
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	78 18                	js     8022ea <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8022d2:	83 ec 0c             	sub    $0xc,%esp
  8022d5:	ff 75 f4             	pushl  -0xc(%ebp)
  8022d8:	e8 d4 ee ff ff       	call   8011b1 <fd2data>
	return _pipeisclosed(fd, p);
  8022dd:	89 c2                	mov    %eax,%edx
  8022df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e2:	e8 21 fd ff ff       	call   802008 <_pipeisclosed>
  8022e7:	83 c4 10             	add    $0x10,%esp
}
  8022ea:	c9                   	leave  
  8022eb:	c3                   	ret    

008022ec <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	56                   	push   %esi
  8022f0:	53                   	push   %ebx
  8022f1:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8022f4:	85 f6                	test   %esi,%esi
  8022f6:	75 16                	jne    80230e <wait+0x22>
  8022f8:	68 af 2f 80 00       	push   $0x802faf
  8022fd:	68 af 2e 80 00       	push   $0x802eaf
  802302:	6a 09                	push   $0x9
  802304:	68 ba 2f 80 00       	push   $0x802fba
  802309:	e8 ca de ff ff       	call   8001d8 <_panic>
	e = &envs[ENVX(envid)];
  80230e:	89 f3                	mov    %esi,%ebx
  802310:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802316:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802319:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80231f:	eb 05                	jmp    802326 <wait+0x3a>
		sys_yield();
  802321:	e8 73 e9 ff ff       	call   800c99 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802326:	8b 43 48             	mov    0x48(%ebx),%eax
  802329:	39 c6                	cmp    %eax,%esi
  80232b:	75 07                	jne    802334 <wait+0x48>
  80232d:	8b 43 54             	mov    0x54(%ebx),%eax
  802330:	85 c0                	test   %eax,%eax
  802332:	75 ed                	jne    802321 <wait+0x35>
		sys_yield();
}
  802334:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802337:	5b                   	pop    %ebx
  802338:	5e                   	pop    %esi
  802339:	5d                   	pop    %ebp
  80233a:	c3                   	ret    

0080233b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80233b:	55                   	push   %ebp
  80233c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80233e:	b8 00 00 00 00       	mov    $0x0,%eax
  802343:	5d                   	pop    %ebp
  802344:	c3                   	ret    

00802345 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802345:	55                   	push   %ebp
  802346:	89 e5                	mov    %esp,%ebp
  802348:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80234b:	68 c5 2f 80 00       	push   $0x802fc5
  802350:	ff 75 0c             	pushl  0xc(%ebp)
  802353:	e8 5d e5 ff ff       	call   8008b5 <strcpy>
	return 0;
}
  802358:	b8 00 00 00 00       	mov    $0x0,%eax
  80235d:	c9                   	leave  
  80235e:	c3                   	ret    

0080235f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80235f:	55                   	push   %ebp
  802360:	89 e5                	mov    %esp,%ebp
  802362:	57                   	push   %edi
  802363:	56                   	push   %esi
  802364:	53                   	push   %ebx
  802365:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80236b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802370:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802376:	eb 2d                	jmp    8023a5 <devcons_write+0x46>
		m = n - tot;
  802378:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80237b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80237d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802380:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802385:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802388:	83 ec 04             	sub    $0x4,%esp
  80238b:	53                   	push   %ebx
  80238c:	03 45 0c             	add    0xc(%ebp),%eax
  80238f:	50                   	push   %eax
  802390:	57                   	push   %edi
  802391:	e8 b1 e6 ff ff       	call   800a47 <memmove>
		sys_cputs(buf, m);
  802396:	83 c4 08             	add    $0x8,%esp
  802399:	53                   	push   %ebx
  80239a:	57                   	push   %edi
  80239b:	e8 5c e8 ff ff       	call   800bfc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023a0:	01 de                	add    %ebx,%esi
  8023a2:	83 c4 10             	add    $0x10,%esp
  8023a5:	89 f0                	mov    %esi,%eax
  8023a7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023aa:	72 cc                	jb     802378 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023af:	5b                   	pop    %ebx
  8023b0:	5e                   	pop    %esi
  8023b1:	5f                   	pop    %edi
  8023b2:	5d                   	pop    %ebp
  8023b3:	c3                   	ret    

008023b4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023b4:	55                   	push   %ebp
  8023b5:	89 e5                	mov    %esp,%ebp
  8023b7:	83 ec 08             	sub    $0x8,%esp
  8023ba:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8023bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023c3:	74 2a                	je     8023ef <devcons_read+0x3b>
  8023c5:	eb 05                	jmp    8023cc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023c7:	e8 cd e8 ff ff       	call   800c99 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023cc:	e8 49 e8 ff ff       	call   800c1a <sys_cgetc>
  8023d1:	85 c0                	test   %eax,%eax
  8023d3:	74 f2                	je     8023c7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023d5:	85 c0                	test   %eax,%eax
  8023d7:	78 16                	js     8023ef <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023d9:	83 f8 04             	cmp    $0x4,%eax
  8023dc:	74 0c                	je     8023ea <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8023e1:	88 02                	mov    %al,(%edx)
	return 1;
  8023e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8023e8:	eb 05                	jmp    8023ef <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8023ea:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8023ef:	c9                   	leave  
  8023f0:	c3                   	ret    

008023f1 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8023f1:	55                   	push   %ebp
  8023f2:	89 e5                	mov    %esp,%ebp
  8023f4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8023f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8023fa:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8023fd:	6a 01                	push   $0x1
  8023ff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802402:	50                   	push   %eax
  802403:	e8 f4 e7 ff ff       	call   800bfc <sys_cputs>
}
  802408:	83 c4 10             	add    $0x10,%esp
  80240b:	c9                   	leave  
  80240c:	c3                   	ret    

0080240d <getchar>:

int
getchar(void)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802413:	6a 01                	push   $0x1
  802415:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802418:	50                   	push   %eax
  802419:	6a 00                	push   $0x0
  80241b:	e8 5d f0 ff ff       	call   80147d <read>
	if (r < 0)
  802420:	83 c4 10             	add    $0x10,%esp
  802423:	85 c0                	test   %eax,%eax
  802425:	78 0f                	js     802436 <getchar+0x29>
		return r;
	if (r < 1)
  802427:	85 c0                	test   %eax,%eax
  802429:	7e 06                	jle    802431 <getchar+0x24>
		return -E_EOF;
	return c;
  80242b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80242f:	eb 05                	jmp    802436 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802431:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802436:	c9                   	leave  
  802437:	c3                   	ret    

00802438 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802438:	55                   	push   %ebp
  802439:	89 e5                	mov    %esp,%ebp
  80243b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80243e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802441:	50                   	push   %eax
  802442:	ff 75 08             	pushl  0x8(%ebp)
  802445:	e8 cd ed ff ff       	call   801217 <fd_lookup>
  80244a:	83 c4 10             	add    $0x10,%esp
  80244d:	85 c0                	test   %eax,%eax
  80244f:	78 11                	js     802462 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802451:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802454:	8b 15 44 40 80 00    	mov    0x804044,%edx
  80245a:	39 10                	cmp    %edx,(%eax)
  80245c:	0f 94 c0             	sete   %al
  80245f:	0f b6 c0             	movzbl %al,%eax
}
  802462:	c9                   	leave  
  802463:	c3                   	ret    

00802464 <opencons>:

int
opencons(void)
{
  802464:	55                   	push   %ebp
  802465:	89 e5                	mov    %esp,%ebp
  802467:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80246a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80246d:	50                   	push   %eax
  80246e:	e8 55 ed ff ff       	call   8011c8 <fd_alloc>
  802473:	83 c4 10             	add    $0x10,%esp
		return r;
  802476:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802478:	85 c0                	test   %eax,%eax
  80247a:	78 3e                	js     8024ba <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80247c:	83 ec 04             	sub    $0x4,%esp
  80247f:	68 07 04 00 00       	push   $0x407
  802484:	ff 75 f4             	pushl  -0xc(%ebp)
  802487:	6a 00                	push   $0x0
  802489:	e8 2a e8 ff ff       	call   800cb8 <sys_page_alloc>
  80248e:	83 c4 10             	add    $0x10,%esp
		return r;
  802491:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802493:	85 c0                	test   %eax,%eax
  802495:	78 23                	js     8024ba <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  802497:	8b 15 44 40 80 00    	mov    0x804044,%edx
  80249d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024a5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024ac:	83 ec 0c             	sub    $0xc,%esp
  8024af:	50                   	push   %eax
  8024b0:	e8 ec ec ff ff       	call   8011a1 <fd2num>
  8024b5:	89 c2                	mov    %eax,%edx
  8024b7:	83 c4 10             	add    $0x10,%esp
}
  8024ba:	89 d0                	mov    %edx,%eax
  8024bc:	c9                   	leave  
  8024bd:	c3                   	ret    

008024be <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8024be:	55                   	push   %ebp
  8024bf:	89 e5                	mov    %esp,%ebp
  8024c1:	53                   	push   %ebx
  8024c2:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  8024c5:	e8 b0 e7 ff ff       	call   800c7a <sys_getenvid>
  8024ca:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  8024cc:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  8024d3:	75 29                	jne    8024fe <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  8024d5:	83 ec 04             	sub    $0x4,%esp
  8024d8:	6a 07                	push   $0x7
  8024da:	68 00 f0 bf ee       	push   $0xeebff000
  8024df:	50                   	push   %eax
  8024e0:	e8 d3 e7 ff ff       	call   800cb8 <sys_page_alloc>
  8024e5:	83 c4 10             	add    $0x10,%esp
  8024e8:	85 c0                	test   %eax,%eax
  8024ea:	79 12                	jns    8024fe <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  8024ec:	50                   	push   %eax
  8024ed:	68 d1 2f 80 00       	push   $0x802fd1
  8024f2:	6a 24                	push   $0x24
  8024f4:	68 ea 2f 80 00       	push   $0x802fea
  8024f9:	e8 da dc ff ff       	call   8001d8 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  8024fe:	8b 45 08             	mov    0x8(%ebp),%eax
  802501:	a3 00 70 80 00       	mov    %eax,0x807000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  802506:	83 ec 08             	sub    $0x8,%esp
  802509:	68 32 25 80 00       	push   $0x802532
  80250e:	53                   	push   %ebx
  80250f:	e8 ef e8 ff ff       	call   800e03 <sys_env_set_pgfault_upcall>
  802514:	83 c4 10             	add    $0x10,%esp
  802517:	85 c0                	test   %eax,%eax
  802519:	79 12                	jns    80252d <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  80251b:	50                   	push   %eax
  80251c:	68 d1 2f 80 00       	push   $0x802fd1
  802521:	6a 2e                	push   $0x2e
  802523:	68 ea 2f 80 00       	push   $0x802fea
  802528:	e8 ab dc ff ff       	call   8001d8 <_panic>
}
  80252d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802530:	c9                   	leave  
  802531:	c3                   	ret    

00802532 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802532:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802533:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802538:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80253a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  80253d:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  802541:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  802544:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802548:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  80254a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80254e:	83 c4 08             	add    $0x8,%esp
	popal
  802551:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802552:	83 c4 04             	add    $0x4,%esp
	popfl
  802555:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  802556:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  802557:	c3                   	ret    

00802558 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802558:	55                   	push   %ebp
  802559:	89 e5                	mov    %esp,%ebp
  80255b:	57                   	push   %edi
  80255c:	56                   	push   %esi
  80255d:	53                   	push   %ebx
  80255e:	83 ec 0c             	sub    $0xc,%esp
  802561:	8b 75 08             	mov    0x8(%ebp),%esi
  802564:	8b 45 0c             	mov    0xc(%ebp),%eax
  802567:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  80256a:	85 f6                	test   %esi,%esi
  80256c:	74 06                	je     802574 <ipc_recv+0x1c>
		*from_env_store = 0;
  80256e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  802574:	85 db                	test   %ebx,%ebx
  802576:	74 06                	je     80257e <ipc_recv+0x26>
		*perm_store = 0;
  802578:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  80257e:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  802580:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  802585:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  802588:	83 ec 0c             	sub    $0xc,%esp
  80258b:	50                   	push   %eax
  80258c:	e8 d7 e8 ff ff       	call   800e68 <sys_ipc_recv>
  802591:	89 c7                	mov    %eax,%edi
  802593:	83 c4 10             	add    $0x10,%esp
  802596:	85 c0                	test   %eax,%eax
  802598:	79 14                	jns    8025ae <ipc_recv+0x56>
		cprintf("im dead");
  80259a:	83 ec 0c             	sub    $0xc,%esp
  80259d:	68 f8 2f 80 00       	push   $0x802ff8
  8025a2:	e8 0a dd ff ff       	call   8002b1 <cprintf>
		return r;
  8025a7:	83 c4 10             	add    $0x10,%esp
  8025aa:	89 f8                	mov    %edi,%eax
  8025ac:	eb 24                	jmp    8025d2 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  8025ae:	85 f6                	test   %esi,%esi
  8025b0:	74 0a                	je     8025bc <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  8025b2:	a1 04 50 80 00       	mov    0x805004,%eax
  8025b7:	8b 40 74             	mov    0x74(%eax),%eax
  8025ba:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  8025bc:	85 db                	test   %ebx,%ebx
  8025be:	74 0a                	je     8025ca <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  8025c0:	a1 04 50 80 00       	mov    0x805004,%eax
  8025c5:	8b 40 78             	mov    0x78(%eax),%eax
  8025c8:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  8025ca:	a1 04 50 80 00       	mov    0x805004,%eax
  8025cf:	8b 40 70             	mov    0x70(%eax),%eax
}
  8025d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025d5:	5b                   	pop    %ebx
  8025d6:	5e                   	pop    %esi
  8025d7:	5f                   	pop    %edi
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    

008025da <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8025da:	55                   	push   %ebp
  8025db:	89 e5                	mov    %esp,%ebp
  8025dd:	57                   	push   %edi
  8025de:	56                   	push   %esi
  8025df:	53                   	push   %ebx
  8025e0:	83 ec 0c             	sub    $0xc,%esp
  8025e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8025e6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8025e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  8025ec:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  8025ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8025f3:	0f 44 d8             	cmove  %eax,%ebx
  8025f6:	eb 1c                	jmp    802614 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  8025f8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025fb:	74 12                	je     80260f <ipc_send+0x35>
			panic("ipc_send: %e", r);
  8025fd:	50                   	push   %eax
  8025fe:	68 00 30 80 00       	push   $0x803000
  802603:	6a 4e                	push   $0x4e
  802605:	68 0d 30 80 00       	push   $0x80300d
  80260a:	e8 c9 db ff ff       	call   8001d8 <_panic>
		sys_yield();
  80260f:	e8 85 e6 ff ff       	call   800c99 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  802614:	ff 75 14             	pushl  0x14(%ebp)
  802617:	53                   	push   %ebx
  802618:	56                   	push   %esi
  802619:	57                   	push   %edi
  80261a:	e8 26 e8 ff ff       	call   800e45 <sys_ipc_try_send>
  80261f:	83 c4 10             	add    $0x10,%esp
  802622:	85 c0                	test   %eax,%eax
  802624:	78 d2                	js     8025f8 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  802626:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802629:	5b                   	pop    %ebx
  80262a:	5e                   	pop    %esi
  80262b:	5f                   	pop    %edi
  80262c:	5d                   	pop    %ebp
  80262d:	c3                   	ret    

0080262e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80262e:	55                   	push   %ebp
  80262f:	89 e5                	mov    %esp,%ebp
  802631:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802634:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802639:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80263c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802642:	8b 52 50             	mov    0x50(%edx),%edx
  802645:	39 ca                	cmp    %ecx,%edx
  802647:	75 0d                	jne    802656 <ipc_find_env+0x28>
			return envs[i].env_id;
  802649:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80264c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802651:	8b 40 48             	mov    0x48(%eax),%eax
  802654:	eb 0f                	jmp    802665 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802656:	83 c0 01             	add    $0x1,%eax
  802659:	3d 00 04 00 00       	cmp    $0x400,%eax
  80265e:	75 d9                	jne    802639 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802660:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802665:	5d                   	pop    %ebp
  802666:	c3                   	ret    

00802667 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802667:	55                   	push   %ebp
  802668:	89 e5                	mov    %esp,%ebp
  80266a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80266d:	89 d0                	mov    %edx,%eax
  80266f:	c1 e8 16             	shr    $0x16,%eax
  802672:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802679:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80267e:	f6 c1 01             	test   $0x1,%cl
  802681:	74 1d                	je     8026a0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802683:	c1 ea 0c             	shr    $0xc,%edx
  802686:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80268d:	f6 c2 01             	test   $0x1,%dl
  802690:	74 0e                	je     8026a0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802692:	c1 ea 0c             	shr    $0xc,%edx
  802695:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80269c:	ef 
  80269d:	0f b7 c0             	movzwl %ax,%eax
}
  8026a0:	5d                   	pop    %ebp
  8026a1:	c3                   	ret    
  8026a2:	66 90                	xchg   %ax,%ax
  8026a4:	66 90                	xchg   %ax,%ax
  8026a6:	66 90                	xchg   %ax,%ax
  8026a8:	66 90                	xchg   %ax,%ax
  8026aa:	66 90                	xchg   %ax,%ax
  8026ac:	66 90                	xchg   %ax,%ax
  8026ae:	66 90                	xchg   %ax,%ax

008026b0 <__udivdi3>:
  8026b0:	55                   	push   %ebp
  8026b1:	57                   	push   %edi
  8026b2:	56                   	push   %esi
  8026b3:	53                   	push   %ebx
  8026b4:	83 ec 1c             	sub    $0x1c,%esp
  8026b7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8026bb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8026bf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8026c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8026c7:	85 f6                	test   %esi,%esi
  8026c9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8026cd:	89 ca                	mov    %ecx,%edx
  8026cf:	89 f8                	mov    %edi,%eax
  8026d1:	75 3d                	jne    802710 <__udivdi3+0x60>
  8026d3:	39 cf                	cmp    %ecx,%edi
  8026d5:	0f 87 c5 00 00 00    	ja     8027a0 <__udivdi3+0xf0>
  8026db:	85 ff                	test   %edi,%edi
  8026dd:	89 fd                	mov    %edi,%ebp
  8026df:	75 0b                	jne    8026ec <__udivdi3+0x3c>
  8026e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8026e6:	31 d2                	xor    %edx,%edx
  8026e8:	f7 f7                	div    %edi
  8026ea:	89 c5                	mov    %eax,%ebp
  8026ec:	89 c8                	mov    %ecx,%eax
  8026ee:	31 d2                	xor    %edx,%edx
  8026f0:	f7 f5                	div    %ebp
  8026f2:	89 c1                	mov    %eax,%ecx
  8026f4:	89 d8                	mov    %ebx,%eax
  8026f6:	89 cf                	mov    %ecx,%edi
  8026f8:	f7 f5                	div    %ebp
  8026fa:	89 c3                	mov    %eax,%ebx
  8026fc:	89 d8                	mov    %ebx,%eax
  8026fe:	89 fa                	mov    %edi,%edx
  802700:	83 c4 1c             	add    $0x1c,%esp
  802703:	5b                   	pop    %ebx
  802704:	5e                   	pop    %esi
  802705:	5f                   	pop    %edi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    
  802708:	90                   	nop
  802709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802710:	39 ce                	cmp    %ecx,%esi
  802712:	77 74                	ja     802788 <__udivdi3+0xd8>
  802714:	0f bd fe             	bsr    %esi,%edi
  802717:	83 f7 1f             	xor    $0x1f,%edi
  80271a:	0f 84 98 00 00 00    	je     8027b8 <__udivdi3+0x108>
  802720:	bb 20 00 00 00       	mov    $0x20,%ebx
  802725:	89 f9                	mov    %edi,%ecx
  802727:	89 c5                	mov    %eax,%ebp
  802729:	29 fb                	sub    %edi,%ebx
  80272b:	d3 e6                	shl    %cl,%esi
  80272d:	89 d9                	mov    %ebx,%ecx
  80272f:	d3 ed                	shr    %cl,%ebp
  802731:	89 f9                	mov    %edi,%ecx
  802733:	d3 e0                	shl    %cl,%eax
  802735:	09 ee                	or     %ebp,%esi
  802737:	89 d9                	mov    %ebx,%ecx
  802739:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80273d:	89 d5                	mov    %edx,%ebp
  80273f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802743:	d3 ed                	shr    %cl,%ebp
  802745:	89 f9                	mov    %edi,%ecx
  802747:	d3 e2                	shl    %cl,%edx
  802749:	89 d9                	mov    %ebx,%ecx
  80274b:	d3 e8                	shr    %cl,%eax
  80274d:	09 c2                	or     %eax,%edx
  80274f:	89 d0                	mov    %edx,%eax
  802751:	89 ea                	mov    %ebp,%edx
  802753:	f7 f6                	div    %esi
  802755:	89 d5                	mov    %edx,%ebp
  802757:	89 c3                	mov    %eax,%ebx
  802759:	f7 64 24 0c          	mull   0xc(%esp)
  80275d:	39 d5                	cmp    %edx,%ebp
  80275f:	72 10                	jb     802771 <__udivdi3+0xc1>
  802761:	8b 74 24 08          	mov    0x8(%esp),%esi
  802765:	89 f9                	mov    %edi,%ecx
  802767:	d3 e6                	shl    %cl,%esi
  802769:	39 c6                	cmp    %eax,%esi
  80276b:	73 07                	jae    802774 <__udivdi3+0xc4>
  80276d:	39 d5                	cmp    %edx,%ebp
  80276f:	75 03                	jne    802774 <__udivdi3+0xc4>
  802771:	83 eb 01             	sub    $0x1,%ebx
  802774:	31 ff                	xor    %edi,%edi
  802776:	89 d8                	mov    %ebx,%eax
  802778:	89 fa                	mov    %edi,%edx
  80277a:	83 c4 1c             	add    $0x1c,%esp
  80277d:	5b                   	pop    %ebx
  80277e:	5e                   	pop    %esi
  80277f:	5f                   	pop    %edi
  802780:	5d                   	pop    %ebp
  802781:	c3                   	ret    
  802782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802788:	31 ff                	xor    %edi,%edi
  80278a:	31 db                	xor    %ebx,%ebx
  80278c:	89 d8                	mov    %ebx,%eax
  80278e:	89 fa                	mov    %edi,%edx
  802790:	83 c4 1c             	add    $0x1c,%esp
  802793:	5b                   	pop    %ebx
  802794:	5e                   	pop    %esi
  802795:	5f                   	pop    %edi
  802796:	5d                   	pop    %ebp
  802797:	c3                   	ret    
  802798:	90                   	nop
  802799:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a0:	89 d8                	mov    %ebx,%eax
  8027a2:	f7 f7                	div    %edi
  8027a4:	31 ff                	xor    %edi,%edi
  8027a6:	89 c3                	mov    %eax,%ebx
  8027a8:	89 d8                	mov    %ebx,%eax
  8027aa:	89 fa                	mov    %edi,%edx
  8027ac:	83 c4 1c             	add    $0x1c,%esp
  8027af:	5b                   	pop    %ebx
  8027b0:	5e                   	pop    %esi
  8027b1:	5f                   	pop    %edi
  8027b2:	5d                   	pop    %ebp
  8027b3:	c3                   	ret    
  8027b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027b8:	39 ce                	cmp    %ecx,%esi
  8027ba:	72 0c                	jb     8027c8 <__udivdi3+0x118>
  8027bc:	31 db                	xor    %ebx,%ebx
  8027be:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8027c2:	0f 87 34 ff ff ff    	ja     8026fc <__udivdi3+0x4c>
  8027c8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8027cd:	e9 2a ff ff ff       	jmp    8026fc <__udivdi3+0x4c>
  8027d2:	66 90                	xchg   %ax,%ax
  8027d4:	66 90                	xchg   %ax,%ax
  8027d6:	66 90                	xchg   %ax,%ax
  8027d8:	66 90                	xchg   %ax,%ax
  8027da:	66 90                	xchg   %ax,%ax
  8027dc:	66 90                	xchg   %ax,%ax
  8027de:	66 90                	xchg   %ax,%ax

008027e0 <__umoddi3>:
  8027e0:	55                   	push   %ebp
  8027e1:	57                   	push   %edi
  8027e2:	56                   	push   %esi
  8027e3:	53                   	push   %ebx
  8027e4:	83 ec 1c             	sub    $0x1c,%esp
  8027e7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8027eb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8027ef:	8b 74 24 34          	mov    0x34(%esp),%esi
  8027f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8027f7:	85 d2                	test   %edx,%edx
  8027f9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8027fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802801:	89 f3                	mov    %esi,%ebx
  802803:	89 3c 24             	mov    %edi,(%esp)
  802806:	89 74 24 04          	mov    %esi,0x4(%esp)
  80280a:	75 1c                	jne    802828 <__umoddi3+0x48>
  80280c:	39 f7                	cmp    %esi,%edi
  80280e:	76 50                	jbe    802860 <__umoddi3+0x80>
  802810:	89 c8                	mov    %ecx,%eax
  802812:	89 f2                	mov    %esi,%edx
  802814:	f7 f7                	div    %edi
  802816:	89 d0                	mov    %edx,%eax
  802818:	31 d2                	xor    %edx,%edx
  80281a:	83 c4 1c             	add    $0x1c,%esp
  80281d:	5b                   	pop    %ebx
  80281e:	5e                   	pop    %esi
  80281f:	5f                   	pop    %edi
  802820:	5d                   	pop    %ebp
  802821:	c3                   	ret    
  802822:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802828:	39 f2                	cmp    %esi,%edx
  80282a:	89 d0                	mov    %edx,%eax
  80282c:	77 52                	ja     802880 <__umoddi3+0xa0>
  80282e:	0f bd ea             	bsr    %edx,%ebp
  802831:	83 f5 1f             	xor    $0x1f,%ebp
  802834:	75 5a                	jne    802890 <__umoddi3+0xb0>
  802836:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80283a:	0f 82 e0 00 00 00    	jb     802920 <__umoddi3+0x140>
  802840:	39 0c 24             	cmp    %ecx,(%esp)
  802843:	0f 86 d7 00 00 00    	jbe    802920 <__umoddi3+0x140>
  802849:	8b 44 24 08          	mov    0x8(%esp),%eax
  80284d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802851:	83 c4 1c             	add    $0x1c,%esp
  802854:	5b                   	pop    %ebx
  802855:	5e                   	pop    %esi
  802856:	5f                   	pop    %edi
  802857:	5d                   	pop    %ebp
  802858:	c3                   	ret    
  802859:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802860:	85 ff                	test   %edi,%edi
  802862:	89 fd                	mov    %edi,%ebp
  802864:	75 0b                	jne    802871 <__umoddi3+0x91>
  802866:	b8 01 00 00 00       	mov    $0x1,%eax
  80286b:	31 d2                	xor    %edx,%edx
  80286d:	f7 f7                	div    %edi
  80286f:	89 c5                	mov    %eax,%ebp
  802871:	89 f0                	mov    %esi,%eax
  802873:	31 d2                	xor    %edx,%edx
  802875:	f7 f5                	div    %ebp
  802877:	89 c8                	mov    %ecx,%eax
  802879:	f7 f5                	div    %ebp
  80287b:	89 d0                	mov    %edx,%eax
  80287d:	eb 99                	jmp    802818 <__umoddi3+0x38>
  80287f:	90                   	nop
  802880:	89 c8                	mov    %ecx,%eax
  802882:	89 f2                	mov    %esi,%edx
  802884:	83 c4 1c             	add    $0x1c,%esp
  802887:	5b                   	pop    %ebx
  802888:	5e                   	pop    %esi
  802889:	5f                   	pop    %edi
  80288a:	5d                   	pop    %ebp
  80288b:	c3                   	ret    
  80288c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802890:	8b 34 24             	mov    (%esp),%esi
  802893:	bf 20 00 00 00       	mov    $0x20,%edi
  802898:	89 e9                	mov    %ebp,%ecx
  80289a:	29 ef                	sub    %ebp,%edi
  80289c:	d3 e0                	shl    %cl,%eax
  80289e:	89 f9                	mov    %edi,%ecx
  8028a0:	89 f2                	mov    %esi,%edx
  8028a2:	d3 ea                	shr    %cl,%edx
  8028a4:	89 e9                	mov    %ebp,%ecx
  8028a6:	09 c2                	or     %eax,%edx
  8028a8:	89 d8                	mov    %ebx,%eax
  8028aa:	89 14 24             	mov    %edx,(%esp)
  8028ad:	89 f2                	mov    %esi,%edx
  8028af:	d3 e2                	shl    %cl,%edx
  8028b1:	89 f9                	mov    %edi,%ecx
  8028b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8028b7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8028bb:	d3 e8                	shr    %cl,%eax
  8028bd:	89 e9                	mov    %ebp,%ecx
  8028bf:	89 c6                	mov    %eax,%esi
  8028c1:	d3 e3                	shl    %cl,%ebx
  8028c3:	89 f9                	mov    %edi,%ecx
  8028c5:	89 d0                	mov    %edx,%eax
  8028c7:	d3 e8                	shr    %cl,%eax
  8028c9:	89 e9                	mov    %ebp,%ecx
  8028cb:	09 d8                	or     %ebx,%eax
  8028cd:	89 d3                	mov    %edx,%ebx
  8028cf:	89 f2                	mov    %esi,%edx
  8028d1:	f7 34 24             	divl   (%esp)
  8028d4:	89 d6                	mov    %edx,%esi
  8028d6:	d3 e3                	shl    %cl,%ebx
  8028d8:	f7 64 24 04          	mull   0x4(%esp)
  8028dc:	39 d6                	cmp    %edx,%esi
  8028de:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8028e2:	89 d1                	mov    %edx,%ecx
  8028e4:	89 c3                	mov    %eax,%ebx
  8028e6:	72 08                	jb     8028f0 <__umoddi3+0x110>
  8028e8:	75 11                	jne    8028fb <__umoddi3+0x11b>
  8028ea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8028ee:	73 0b                	jae    8028fb <__umoddi3+0x11b>
  8028f0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8028f4:	1b 14 24             	sbb    (%esp),%edx
  8028f7:	89 d1                	mov    %edx,%ecx
  8028f9:	89 c3                	mov    %eax,%ebx
  8028fb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8028ff:	29 da                	sub    %ebx,%edx
  802901:	19 ce                	sbb    %ecx,%esi
  802903:	89 f9                	mov    %edi,%ecx
  802905:	89 f0                	mov    %esi,%eax
  802907:	d3 e0                	shl    %cl,%eax
  802909:	89 e9                	mov    %ebp,%ecx
  80290b:	d3 ea                	shr    %cl,%edx
  80290d:	89 e9                	mov    %ebp,%ecx
  80290f:	d3 ee                	shr    %cl,%esi
  802911:	09 d0                	or     %edx,%eax
  802913:	89 f2                	mov    %esi,%edx
  802915:	83 c4 1c             	add    $0x1c,%esp
  802918:	5b                   	pop    %ebx
  802919:	5e                   	pop    %esi
  80291a:	5f                   	pop    %edi
  80291b:	5d                   	pop    %ebp
  80291c:	c3                   	ret    
  80291d:	8d 76 00             	lea    0x0(%esi),%esi
  802920:	29 f9                	sub    %edi,%ecx
  802922:	19 d6                	sbb    %edx,%esi
  802924:	89 74 24 04          	mov    %esi,0x4(%esp)
  802928:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80292c:	e9 18 ff ff ff       	jmp    802849 <__umoddi3+0x69>
