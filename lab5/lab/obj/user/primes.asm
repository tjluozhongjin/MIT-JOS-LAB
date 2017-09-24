
obj/user/primes.debug:     file format elf32-i386


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
  80002c:	e8 c7 00 00 00       	call   8000f8 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	6a 00                	push   $0x0
  800044:	6a 00                	push   $0x0
  800046:	56                   	push   %esi
  800047:	e8 d5 10 00 00       	call   801121 <ipc_recv>
  80004c:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  80004e:	a1 04 40 80 00       	mov    0x804004,%eax
  800053:	8b 40 5c             	mov    0x5c(%eax),%eax
  800056:	83 c4 0c             	add    $0xc,%esp
  800059:	53                   	push   %ebx
  80005a:	50                   	push   %eax
  80005b:	68 a0 22 80 00       	push   $0x8022a0
  800060:	e8 cc 01 00 00       	call   800231 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800065:	e8 b9 0e 00 00       	call   800f23 <fork>
  80006a:	89 c7                	mov    %eax,%edi
  80006c:	83 c4 10             	add    $0x10,%esp
  80006f:	85 c0                	test   %eax,%eax
  800071:	79 12                	jns    800085 <primeproc+0x52>
		panic("fork: %e", id);
  800073:	50                   	push   %eax
  800074:	68 ac 22 80 00       	push   $0x8022ac
  800079:	6a 1a                	push   $0x1a
  80007b:	68 b5 22 80 00       	push   $0x8022b5
  800080:	e8 d3 00 00 00       	call   800158 <_panic>
	if (id == 0)
  800085:	85 c0                	test   %eax,%eax
  800087:	74 b6                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  800089:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80008c:	83 ec 04             	sub    $0x4,%esp
  80008f:	6a 00                	push   $0x0
  800091:	6a 00                	push   $0x0
  800093:	56                   	push   %esi
  800094:	e8 88 10 00 00       	call   801121 <ipc_recv>
  800099:	89 c1                	mov    %eax,%ecx
		if (i % p)
  80009b:	99                   	cltd   
  80009c:	f7 fb                	idiv   %ebx
  80009e:	83 c4 10             	add    $0x10,%esp
  8000a1:	85 d2                	test   %edx,%edx
  8000a3:	74 e7                	je     80008c <primeproc+0x59>
			ipc_send(id, i, 0, 0);
  8000a5:	6a 00                	push   $0x0
  8000a7:	6a 00                	push   $0x0
  8000a9:	51                   	push   %ecx
  8000aa:	57                   	push   %edi
  8000ab:	e8 f3 10 00 00       	call   8011a3 <ipc_send>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	eb d7                	jmp    80008c <primeproc+0x59>

008000b5 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000ba:	e8 64 0e 00 00       	call   800f23 <fork>
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	79 12                	jns    8000d7 <umain+0x22>
		panic("fork: %e", id);
  8000c5:	50                   	push   %eax
  8000c6:	68 ac 22 80 00       	push   $0x8022ac
  8000cb:	6a 2d                	push   $0x2d
  8000cd:	68 b5 22 80 00       	push   $0x8022b5
  8000d2:	e8 81 00 00 00       	call   800158 <_panic>
  8000d7:	bb 02 00 00 00       	mov    $0x2,%ebx
	if (id == 0)
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	75 05                	jne    8000e5 <umain+0x30>
		primeproc();
  8000e0:	e8 4e ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  8000e5:	6a 00                	push   $0x0
  8000e7:	6a 00                	push   $0x0
  8000e9:	53                   	push   %ebx
  8000ea:	56                   	push   %esi
  8000eb:	e8 b3 10 00 00       	call   8011a3 <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  8000f0:	83 c3 01             	add    $0x1,%ebx
  8000f3:	83 c4 10             	add    $0x10,%esp
  8000f6:	eb ed                	jmp    8000e5 <umain+0x30>

008000f8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f8:	55                   	push   %ebp
  8000f9:	89 e5                	mov    %esp,%ebp
  8000fb:	56                   	push   %esi
  8000fc:	53                   	push   %ebx
  8000fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800100:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800103:	e8 f2 0a 00 00       	call   800bfa <sys_getenvid>
  800108:	25 ff 03 00 00       	and    $0x3ff,%eax
  80010d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800110:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800115:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80011a:	85 db                	test   %ebx,%ebx
  80011c:	7e 07                	jle    800125 <libmain+0x2d>
		binaryname = argv[0];
  80011e:	8b 06                	mov    (%esi),%eax
  800120:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
  80012a:	e8 86 ff ff ff       	call   8000b5 <umain>

	// exit gracefully
	exit();
  80012f:	e8 0a 00 00 00       	call   80013e <exit>
}
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5d                   	pop    %ebp
  80013d:	c3                   	ret    

0080013e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800144:	e8 b2 12 00 00       	call   8013fb <close_all>
	sys_env_destroy(0);
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	6a 00                	push   $0x0
  80014e:	e8 66 0a 00 00       	call   800bb9 <sys_env_destroy>
}
  800153:	83 c4 10             	add    $0x10,%esp
  800156:	c9                   	leave  
  800157:	c3                   	ret    

00800158 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800158:	55                   	push   %ebp
  800159:	89 e5                	mov    %esp,%ebp
  80015b:	56                   	push   %esi
  80015c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800160:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800166:	e8 8f 0a 00 00       	call   800bfa <sys_getenvid>
  80016b:	83 ec 0c             	sub    $0xc,%esp
  80016e:	ff 75 0c             	pushl  0xc(%ebp)
  800171:	ff 75 08             	pushl  0x8(%ebp)
  800174:	56                   	push   %esi
  800175:	50                   	push   %eax
  800176:	68 d0 22 80 00       	push   $0x8022d0
  80017b:	e8 b1 00 00 00       	call   800231 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800180:	83 c4 18             	add    $0x18,%esp
  800183:	53                   	push   %ebx
  800184:	ff 75 10             	pushl  0x10(%ebp)
  800187:	e8 54 00 00 00       	call   8001e0 <vcprintf>
	cprintf("\n");
  80018c:	c7 04 24 f7 27 80 00 	movl   $0x8027f7,(%esp)
  800193:	e8 99 00 00 00       	call   800231 <cprintf>
  800198:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019b:	cc                   	int3   
  80019c:	eb fd                	jmp    80019b <_panic+0x43>

0080019e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001a8:	8b 13                	mov    (%ebx),%edx
  8001aa:	8d 42 01             	lea    0x1(%edx),%eax
  8001ad:	89 03                	mov    %eax,(%ebx)
  8001af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001bb:	75 1a                	jne    8001d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8001bd:	83 ec 08             	sub    $0x8,%esp
  8001c0:	68 ff 00 00 00       	push   $0xff
  8001c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8001c8:	50                   	push   %eax
  8001c9:	e8 ae 09 00 00       	call   800b7c <sys_cputs>
		b->idx = 0;
  8001ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8001d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001de:	c9                   	leave  
  8001df:	c3                   	ret    

008001e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f0:	00 00 00 
	b.cnt = 0;
  8001f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	ff 75 08             	pushl  0x8(%ebp)
  800203:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800209:	50                   	push   %eax
  80020a:	68 9e 01 80 00       	push   $0x80019e
  80020f:	e8 1a 01 00 00       	call   80032e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800214:	83 c4 08             	add    $0x8,%esp
  800217:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80021d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800223:	50                   	push   %eax
  800224:	e8 53 09 00 00       	call   800b7c <sys_cputs>

	return b.cnt;
}
  800229:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800237:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 08             	pushl  0x8(%ebp)
  80023e:	e8 9d ff ff ff       	call   8001e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800243:	c9                   	leave  
  800244:	c3                   	ret    

00800245 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800245:	55                   	push   %ebp
  800246:	89 e5                	mov    %esp,%ebp
  800248:	57                   	push   %edi
  800249:	56                   	push   %esi
  80024a:	53                   	push   %ebx
  80024b:	83 ec 1c             	sub    $0x1c,%esp
  80024e:	89 c7                	mov    %eax,%edi
  800250:	89 d6                	mov    %edx,%esi
  800252:	8b 45 08             	mov    0x8(%ebp),%eax
  800255:	8b 55 0c             	mov    0xc(%ebp),%edx
  800258:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80025b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80025e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800261:	bb 00 00 00 00       	mov    $0x0,%ebx
  800266:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800269:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80026c:	39 d3                	cmp    %edx,%ebx
  80026e:	72 05                	jb     800275 <printnum+0x30>
  800270:	39 45 10             	cmp    %eax,0x10(%ebp)
  800273:	77 45                	ja     8002ba <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800275:	83 ec 0c             	sub    $0xc,%esp
  800278:	ff 75 18             	pushl  0x18(%ebp)
  80027b:	8b 45 14             	mov    0x14(%ebp),%eax
  80027e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800281:	53                   	push   %ebx
  800282:	ff 75 10             	pushl  0x10(%ebp)
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 75 e4             	pushl  -0x1c(%ebp)
  80028b:	ff 75 e0             	pushl  -0x20(%ebp)
  80028e:	ff 75 dc             	pushl  -0x24(%ebp)
  800291:	ff 75 d8             	pushl  -0x28(%ebp)
  800294:	e8 67 1d 00 00       	call   802000 <__udivdi3>
  800299:	83 c4 18             	add    $0x18,%esp
  80029c:	52                   	push   %edx
  80029d:	50                   	push   %eax
  80029e:	89 f2                	mov    %esi,%edx
  8002a0:	89 f8                	mov    %edi,%eax
  8002a2:	e8 9e ff ff ff       	call   800245 <printnum>
  8002a7:	83 c4 20             	add    $0x20,%esp
  8002aa:	eb 18                	jmp    8002c4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ac:	83 ec 08             	sub    $0x8,%esp
  8002af:	56                   	push   %esi
  8002b0:	ff 75 18             	pushl  0x18(%ebp)
  8002b3:	ff d7                	call   *%edi
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	eb 03                	jmp    8002bd <printnum+0x78>
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	85 db                	test   %ebx,%ebx
  8002c2:	7f e8                	jg     8002ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002c4:	83 ec 08             	sub    $0x8,%esp
  8002c7:	56                   	push   %esi
  8002c8:	83 ec 04             	sub    $0x4,%esp
  8002cb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ce:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d1:	ff 75 dc             	pushl  -0x24(%ebp)
  8002d4:	ff 75 d8             	pushl  -0x28(%ebp)
  8002d7:	e8 54 1e 00 00       	call   802130 <__umoddi3>
  8002dc:	83 c4 14             	add    $0x14,%esp
  8002df:	0f be 80 f3 22 80 00 	movsbl 0x8022f3(%eax),%eax
  8002e6:	50                   	push   %eax
  8002e7:	ff d7                	call   *%edi
}
  8002e9:	83 c4 10             	add    $0x10,%esp
  8002ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ef:	5b                   	pop    %ebx
  8002f0:	5e                   	pop    %esi
  8002f1:	5f                   	pop    %edi
  8002f2:	5d                   	pop    %ebp
  8002f3:	c3                   	ret    

008002f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f4:	55                   	push   %ebp
  8002f5:	89 e5                	mov    %esp,%ebp
  8002f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002fa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	3b 50 04             	cmp    0x4(%eax),%edx
  800303:	73 0a                	jae    80030f <sprintputch+0x1b>
		*b->buf++ = ch;
  800305:	8d 4a 01             	lea    0x1(%edx),%ecx
  800308:	89 08                	mov    %ecx,(%eax)
  80030a:	8b 45 08             	mov    0x8(%ebp),%eax
  80030d:	88 02                	mov    %al,(%edx)
}
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031a:	50                   	push   %eax
  80031b:	ff 75 10             	pushl  0x10(%ebp)
  80031e:	ff 75 0c             	pushl  0xc(%ebp)
  800321:	ff 75 08             	pushl  0x8(%ebp)
  800324:	e8 05 00 00 00       	call   80032e <vprintfmt>
	va_end(ap);
}
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	c9                   	leave  
  80032d:	c3                   	ret    

0080032e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	57                   	push   %edi
  800332:	56                   	push   %esi
  800333:	53                   	push   %ebx
  800334:	83 ec 2c             	sub    $0x2c,%esp
  800337:	8b 75 08             	mov    0x8(%ebp),%esi
  80033a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80033d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800340:	eb 12                	jmp    800354 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800342:	85 c0                	test   %eax,%eax
  800344:	0f 84 42 04 00 00    	je     80078c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80034a:	83 ec 08             	sub    $0x8,%esp
  80034d:	53                   	push   %ebx
  80034e:	50                   	push   %eax
  80034f:	ff d6                	call   *%esi
  800351:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800354:	83 c7 01             	add    $0x1,%edi
  800357:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80035b:	83 f8 25             	cmp    $0x25,%eax
  80035e:	75 e2                	jne    800342 <vprintfmt+0x14>
  800360:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800364:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80036b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800372:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	eb 07                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800380:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800383:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800387:	8d 47 01             	lea    0x1(%edi),%eax
  80038a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80038d:	0f b6 07             	movzbl (%edi),%eax
  800390:	0f b6 d0             	movzbl %al,%edx
  800393:	83 e8 23             	sub    $0x23,%eax
  800396:	3c 55                	cmp    $0x55,%al
  800398:	0f 87 d3 03 00 00    	ja     800771 <vprintfmt+0x443>
  80039e:	0f b6 c0             	movzbl %al,%eax
  8003a1:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8003ab:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8003af:	eb d6                	jmp    800387 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003bc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003bf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003c3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003c6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003c9:	83 f9 09             	cmp    $0x9,%ecx
  8003cc:	77 3f                	ja     80040d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ce:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8003d1:	eb e9                	jmp    8003bc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d6:	8b 00                	mov    (%eax),%eax
  8003d8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 40 04             	lea    0x4(%eax),%eax
  8003e1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8003e7:	eb 2a                	jmp    800413 <vprintfmt+0xe5>
  8003e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003ec:	85 c0                	test   %eax,%eax
  8003ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f3:	0f 49 d0             	cmovns %eax,%edx
  8003f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003fc:	eb 89                	jmp    800387 <vprintfmt+0x59>
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800401:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800408:	e9 7a ff ff ff       	jmp    800387 <vprintfmt+0x59>
  80040d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800410:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800417:	0f 89 6a ff ff ff    	jns    800387 <vprintfmt+0x59>
				width = precision, precision = -1;
  80041d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800423:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80042a:	e9 58 ff ff ff       	jmp    800387 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80042f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800432:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800435:	e9 4d ff ff ff       	jmp    800387 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80043a:	8b 45 14             	mov    0x14(%ebp),%eax
  80043d:	8d 78 04             	lea    0x4(%eax),%edi
  800440:	83 ec 08             	sub    $0x8,%esp
  800443:	53                   	push   %ebx
  800444:	ff 30                	pushl  (%eax)
  800446:	ff d6                	call   *%esi
			break;
  800448:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80044b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800451:	e9 fe fe ff ff       	jmp    800354 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800456:	8b 45 14             	mov    0x14(%ebp),%eax
  800459:	8d 78 04             	lea    0x4(%eax),%edi
  80045c:	8b 00                	mov    (%eax),%eax
  80045e:	99                   	cltd   
  80045f:	31 d0                	xor    %edx,%eax
  800461:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800463:	83 f8 0f             	cmp    $0xf,%eax
  800466:	7f 0b                	jg     800473 <vprintfmt+0x145>
  800468:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  80046f:	85 d2                	test   %edx,%edx
  800471:	75 1b                	jne    80048e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800473:	50                   	push   %eax
  800474:	68 0b 23 80 00       	push   $0x80230b
  800479:	53                   	push   %ebx
  80047a:	56                   	push   %esi
  80047b:	e8 91 fe ff ff       	call   800311 <printfmt>
  800480:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800483:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800486:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800489:	e9 c6 fe ff ff       	jmp    800354 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80048e:	52                   	push   %edx
  80048f:	68 c5 27 80 00       	push   $0x8027c5
  800494:	53                   	push   %ebx
  800495:	56                   	push   %esi
  800496:	e8 76 fe ff ff       	call   800311 <printfmt>
  80049b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80049e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a4:	e9 ab fe ff ff       	jmp    800354 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ac:	83 c0 04             	add    $0x4,%eax
  8004af:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8004b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8004b7:	85 ff                	test   %edi,%edi
  8004b9:	b8 04 23 80 00       	mov    $0x802304,%eax
  8004be:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8004c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c5:	0f 8e 94 00 00 00    	jle    80055f <vprintfmt+0x231>
  8004cb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8004cf:	0f 84 98 00 00 00    	je     80056d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ec 08             	sub    $0x8,%esp
  8004d8:	ff 75 d0             	pushl  -0x30(%ebp)
  8004db:	57                   	push   %edi
  8004dc:	e8 33 03 00 00       	call   800814 <strnlen>
  8004e1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004e4:	29 c1                	sub    %eax,%ecx
  8004e6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8004e9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004ec:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8004f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f3:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8004f6:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004f8:	eb 0f                	jmp    800509 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800501:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800503:	83 ef 01             	sub    $0x1,%edi
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	85 ff                	test   %edi,%edi
  80050b:	7f ed                	jg     8004fa <vprintfmt+0x1cc>
  80050d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800510:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800513:	85 c9                	test   %ecx,%ecx
  800515:	b8 00 00 00 00       	mov    $0x0,%eax
  80051a:	0f 49 c1             	cmovns %ecx,%eax
  80051d:	29 c1                	sub    %eax,%ecx
  80051f:	89 75 08             	mov    %esi,0x8(%ebp)
  800522:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800525:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800528:	89 cb                	mov    %ecx,%ebx
  80052a:	eb 4d                	jmp    800579 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80052c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800530:	74 1b                	je     80054d <vprintfmt+0x21f>
  800532:	0f be c0             	movsbl %al,%eax
  800535:	83 e8 20             	sub    $0x20,%eax
  800538:	83 f8 5e             	cmp    $0x5e,%eax
  80053b:	76 10                	jbe    80054d <vprintfmt+0x21f>
					putch('?', putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	ff 75 0c             	pushl  0xc(%ebp)
  800543:	6a 3f                	push   $0x3f
  800545:	ff 55 08             	call   *0x8(%ebp)
  800548:	83 c4 10             	add    $0x10,%esp
  80054b:	eb 0d                	jmp    80055a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80054d:	83 ec 08             	sub    $0x8,%esp
  800550:	ff 75 0c             	pushl  0xc(%ebp)
  800553:	52                   	push   %edx
  800554:	ff 55 08             	call   *0x8(%ebp)
  800557:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055a:	83 eb 01             	sub    $0x1,%ebx
  80055d:	eb 1a                	jmp    800579 <vprintfmt+0x24b>
  80055f:	89 75 08             	mov    %esi,0x8(%ebp)
  800562:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800565:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800568:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80056b:	eb 0c                	jmp    800579 <vprintfmt+0x24b>
  80056d:	89 75 08             	mov    %esi,0x8(%ebp)
  800570:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800573:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800576:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800579:	83 c7 01             	add    $0x1,%edi
  80057c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800580:	0f be d0             	movsbl %al,%edx
  800583:	85 d2                	test   %edx,%edx
  800585:	74 23                	je     8005aa <vprintfmt+0x27c>
  800587:	85 f6                	test   %esi,%esi
  800589:	78 a1                	js     80052c <vprintfmt+0x1fe>
  80058b:	83 ee 01             	sub    $0x1,%esi
  80058e:	79 9c                	jns    80052c <vprintfmt+0x1fe>
  800590:	89 df                	mov    %ebx,%edi
  800592:	8b 75 08             	mov    0x8(%ebp),%esi
  800595:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800598:	eb 18                	jmp    8005b2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 20                	push   $0x20
  8005a0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a2:	83 ef 01             	sub    $0x1,%edi
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	eb 08                	jmp    8005b2 <vprintfmt+0x284>
  8005aa:	89 df                	mov    %ebx,%edi
  8005ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8005af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005b2:	85 ff                	test   %edi,%edi
  8005b4:	7f e4                	jg     80059a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bf:	e9 90 fd ff ff       	jmp    800354 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c4:	83 f9 01             	cmp    $0x1,%ecx
  8005c7:	7e 19                	jle    8005e2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 50 04             	mov    0x4(%eax),%edx
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 40 08             	lea    0x8(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e0:	eb 38                	jmp    80061a <vprintfmt+0x2ec>
	else if (lflag)
  8005e2:	85 c9                	test   %ecx,%ecx
  8005e4:	74 1b                	je     800601 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 00                	mov    (%eax),%eax
  8005eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ee:	89 c1                	mov    %eax,%ecx
  8005f0:	c1 f9 1f             	sar    $0x1f,%ecx
  8005f3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ff:	eb 19                	jmp    80061a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 c1                	mov    %eax,%ecx
  80060b:	c1 f9 1f             	sar    $0x1f,%ecx
  80060e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 40 04             	lea    0x4(%eax),%eax
  800617:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80061d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800625:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800629:	0f 89 0e 01 00 00    	jns    80073d <vprintfmt+0x40f>
				putch('-', putdat);
  80062f:	83 ec 08             	sub    $0x8,%esp
  800632:	53                   	push   %ebx
  800633:	6a 2d                	push   $0x2d
  800635:	ff d6                	call   *%esi
				num = -(long long) num;
  800637:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80063d:	f7 da                	neg    %edx
  80063f:	83 d1 00             	adc    $0x0,%ecx
  800642:	f7 d9                	neg    %ecx
  800644:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800647:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064c:	e9 ec 00 00 00       	jmp    80073d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800651:	83 f9 01             	cmp    $0x1,%ecx
  800654:	7e 18                	jle    80066e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800656:	8b 45 14             	mov    0x14(%ebp),%eax
  800659:	8b 10                	mov    (%eax),%edx
  80065b:	8b 48 04             	mov    0x4(%eax),%ecx
  80065e:	8d 40 08             	lea    0x8(%eax),%eax
  800661:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800664:	b8 0a 00 00 00       	mov    $0xa,%eax
  800669:	e9 cf 00 00 00       	jmp    80073d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80066e:	85 c9                	test   %ecx,%ecx
  800670:	74 1a                	je     80068c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	b9 00 00 00 00       	mov    $0x0,%ecx
  80067c:	8d 40 04             	lea    0x4(%eax),%eax
  80067f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800682:	b8 0a 00 00 00       	mov    $0xa,%eax
  800687:	e9 b1 00 00 00       	jmp    80073d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
  800691:	b9 00 00 00 00       	mov    $0x0,%ecx
  800696:	8d 40 04             	lea    0x4(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80069c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006a1:	e9 97 00 00 00       	jmp    80073d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 58                	push   $0x58
  8006ac:	ff d6                	call   *%esi
			putch('X', putdat);
  8006ae:	83 c4 08             	add    $0x8,%esp
  8006b1:	53                   	push   %ebx
  8006b2:	6a 58                	push   $0x58
  8006b4:	ff d6                	call   *%esi
			putch('X', putdat);
  8006b6:	83 c4 08             	add    $0x8,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	6a 58                	push   $0x58
  8006bc:	ff d6                	call   *%esi
			break;
  8006be:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8006c4:	e9 8b fc ff ff       	jmp    800354 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	53                   	push   %ebx
  8006cd:	6a 30                	push   $0x30
  8006cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8006d1:	83 c4 08             	add    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	6a 78                	push   $0x78
  8006d7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8006e6:	8d 40 04             	lea    0x4(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ec:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f1:	eb 4a                	jmp    80073d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7e 15                	jle    80070d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8006f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fb:	8b 10                	mov    (%eax),%edx
  8006fd:	8b 48 04             	mov    0x4(%eax),%ecx
  800700:	8d 40 08             	lea    0x8(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800706:	b8 10 00 00 00       	mov    $0x10,%eax
  80070b:	eb 30                	jmp    80073d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80070d:	85 c9                	test   %ecx,%ecx
  80070f:	74 17                	je     800728 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800711:	8b 45 14             	mov    0x14(%ebp),%eax
  800714:	8b 10                	mov    (%eax),%edx
  800716:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071b:	8d 40 04             	lea    0x4(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800721:	b8 10 00 00 00       	mov    $0x10,%eax
  800726:	eb 15                	jmp    80073d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 10                	mov    (%eax),%edx
  80072d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800738:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80073d:	83 ec 0c             	sub    $0xc,%esp
  800740:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800744:	57                   	push   %edi
  800745:	ff 75 e0             	pushl  -0x20(%ebp)
  800748:	50                   	push   %eax
  800749:	51                   	push   %ecx
  80074a:	52                   	push   %edx
  80074b:	89 da                	mov    %ebx,%edx
  80074d:	89 f0                	mov    %esi,%eax
  80074f:	e8 f1 fa ff ff       	call   800245 <printnum>
			break;
  800754:	83 c4 20             	add    $0x20,%esp
  800757:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075a:	e9 f5 fb ff ff       	jmp    800354 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80075f:	83 ec 08             	sub    $0x8,%esp
  800762:	53                   	push   %ebx
  800763:	52                   	push   %edx
  800764:	ff d6                	call   *%esi
			break;
  800766:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800769:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80076c:	e9 e3 fb ff ff       	jmp    800354 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	6a 25                	push   $0x25
  800777:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800779:	83 c4 10             	add    $0x10,%esp
  80077c:	eb 03                	jmp    800781 <vprintfmt+0x453>
  80077e:	83 ef 01             	sub    $0x1,%edi
  800781:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800785:	75 f7                	jne    80077e <vprintfmt+0x450>
  800787:	e9 c8 fb ff ff       	jmp    800354 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80078c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078f:	5b                   	pop    %ebx
  800790:	5e                   	pop    %esi
  800791:	5f                   	pop    %edi
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	83 ec 18             	sub    $0x18,%esp
  80079a:	8b 45 08             	mov    0x8(%ebp),%eax
  80079d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007a3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007a7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007aa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	74 26                	je     8007db <vsnprintf+0x47>
  8007b5:	85 d2                	test   %edx,%edx
  8007b7:	7e 22                	jle    8007db <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007b9:	ff 75 14             	pushl  0x14(%ebp)
  8007bc:	ff 75 10             	pushl  0x10(%ebp)
  8007bf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007c2:	50                   	push   %eax
  8007c3:	68 f4 02 80 00       	push   $0x8002f4
  8007c8:	e8 61 fb ff ff       	call   80032e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d6:	83 c4 10             	add    $0x10,%esp
  8007d9:	eb 05                	jmp    8007e0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8007db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8007e0:	c9                   	leave  
  8007e1:	c3                   	ret    

008007e2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007e8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007eb:	50                   	push   %eax
  8007ec:	ff 75 10             	pushl  0x10(%ebp)
  8007ef:	ff 75 0c             	pushl  0xc(%ebp)
  8007f2:	ff 75 08             	pushl  0x8(%ebp)
  8007f5:	e8 9a ff ff ff       	call   800794 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
  800807:	eb 03                	jmp    80080c <strlen+0x10>
		n++;
  800809:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80080c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800810:	75 f7                	jne    800809 <strlen+0xd>
		n++;
	return n;
}
  800812:	5d                   	pop    %ebp
  800813:	c3                   	ret    

00800814 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800814:	55                   	push   %ebp
  800815:	89 e5                	mov    %esp,%ebp
  800817:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80081d:	ba 00 00 00 00       	mov    $0x0,%edx
  800822:	eb 03                	jmp    800827 <strnlen+0x13>
		n++;
  800824:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800827:	39 c2                	cmp    %eax,%edx
  800829:	74 08                	je     800833 <strnlen+0x1f>
  80082b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80082f:	75 f3                	jne    800824 <strnlen+0x10>
  800831:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800833:	5d                   	pop    %ebp
  800834:	c3                   	ret    

00800835 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	53                   	push   %ebx
  800839:	8b 45 08             	mov    0x8(%ebp),%eax
  80083c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80083f:	89 c2                	mov    %eax,%edx
  800841:	83 c2 01             	add    $0x1,%edx
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80084b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80084e:	84 db                	test   %bl,%bl
  800850:	75 ef                	jne    800841 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800855:	55                   	push   %ebp
  800856:	89 e5                	mov    %esp,%ebp
  800858:	53                   	push   %ebx
  800859:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085c:	53                   	push   %ebx
  80085d:	e8 9a ff ff ff       	call   8007fc <strlen>
  800862:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800865:	ff 75 0c             	pushl  0xc(%ebp)
  800868:	01 d8                	add    %ebx,%eax
  80086a:	50                   	push   %eax
  80086b:	e8 c5 ff ff ff       	call   800835 <strcpy>
	return dst;
}
  800870:	89 d8                	mov    %ebx,%eax
  800872:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800875:	c9                   	leave  
  800876:	c3                   	ret    

00800877 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	56                   	push   %esi
  80087b:	53                   	push   %ebx
  80087c:	8b 75 08             	mov    0x8(%ebp),%esi
  80087f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800882:	89 f3                	mov    %esi,%ebx
  800884:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800887:	89 f2                	mov    %esi,%edx
  800889:	eb 0f                	jmp    80089a <strncpy+0x23>
		*dst++ = *src;
  80088b:	83 c2 01             	add    $0x1,%edx
  80088e:	0f b6 01             	movzbl (%ecx),%eax
  800891:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800894:	80 39 01             	cmpb   $0x1,(%ecx)
  800897:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80089a:	39 da                	cmp    %ebx,%edx
  80089c:	75 ed                	jne    80088b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80089e:	89 f0                	mov    %esi,%eax
  8008a0:	5b                   	pop    %ebx
  8008a1:	5e                   	pop    %esi
  8008a2:	5d                   	pop    %ebp
  8008a3:	c3                   	ret    

008008a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a4:	55                   	push   %ebp
  8008a5:	89 e5                	mov    %esp,%ebp
  8008a7:	56                   	push   %esi
  8008a8:	53                   	push   %ebx
  8008a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008af:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008b4:	85 d2                	test   %edx,%edx
  8008b6:	74 21                	je     8008d9 <strlcpy+0x35>
  8008b8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008bc:	89 f2                	mov    %esi,%edx
  8008be:	eb 09                	jmp    8008c9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	83 c1 01             	add    $0x1,%ecx
  8008c6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c9:	39 c2                	cmp    %eax,%edx
  8008cb:	74 09                	je     8008d6 <strlcpy+0x32>
  8008cd:	0f b6 19             	movzbl (%ecx),%ebx
  8008d0:	84 db                	test   %bl,%bl
  8008d2:	75 ec                	jne    8008c0 <strlcpy+0x1c>
  8008d4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008d6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008d9:	29 f0                	sub    %esi,%eax
}
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008e8:	eb 06                	jmp    8008f0 <strcmp+0x11>
		p++, q++;
  8008ea:	83 c1 01             	add    $0x1,%ecx
  8008ed:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008f0:	0f b6 01             	movzbl (%ecx),%eax
  8008f3:	84 c0                	test   %al,%al
  8008f5:	74 04                	je     8008fb <strcmp+0x1c>
  8008f7:	3a 02                	cmp    (%edx),%al
  8008f9:	74 ef                	je     8008ea <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008fb:	0f b6 c0             	movzbl %al,%eax
  8008fe:	0f b6 12             	movzbl (%edx),%edx
  800901:	29 d0                	sub    %edx,%eax
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	53                   	push   %ebx
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090f:	89 c3                	mov    %eax,%ebx
  800911:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800914:	eb 06                	jmp    80091c <strncmp+0x17>
		n--, p++, q++;
  800916:	83 c0 01             	add    $0x1,%eax
  800919:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091c:	39 d8                	cmp    %ebx,%eax
  80091e:	74 15                	je     800935 <strncmp+0x30>
  800920:	0f b6 08             	movzbl (%eax),%ecx
  800923:	84 c9                	test   %cl,%cl
  800925:	74 04                	je     80092b <strncmp+0x26>
  800927:	3a 0a                	cmp    (%edx),%cl
  800929:	74 eb                	je     800916 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80092b:	0f b6 00             	movzbl (%eax),%eax
  80092e:	0f b6 12             	movzbl (%edx),%edx
  800931:	29 d0                	sub    %edx,%eax
  800933:	eb 05                	jmp    80093a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093a:	5b                   	pop    %ebx
  80093b:	5d                   	pop    %ebp
  80093c:	c3                   	ret    

0080093d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093d:	55                   	push   %ebp
  80093e:	89 e5                	mov    %esp,%ebp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800947:	eb 07                	jmp    800950 <strchr+0x13>
		if (*s == c)
  800949:	38 ca                	cmp    %cl,%dl
  80094b:	74 0f                	je     80095c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80094d:	83 c0 01             	add    $0x1,%eax
  800950:	0f b6 10             	movzbl (%eax),%edx
  800953:	84 d2                	test   %dl,%dl
  800955:	75 f2                	jne    800949 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800957:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800968:	eb 03                	jmp    80096d <strfind+0xf>
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800970:	38 ca                	cmp    %cl,%dl
  800972:	74 04                	je     800978 <strfind+0x1a>
  800974:	84 d2                	test   %dl,%dl
  800976:	75 f2                	jne    80096a <strfind+0xc>
			break;
	return (char *) s;
}
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	57                   	push   %edi
  80097e:	56                   	push   %esi
  80097f:	53                   	push   %ebx
  800980:	8b 7d 08             	mov    0x8(%ebp),%edi
  800983:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800986:	85 c9                	test   %ecx,%ecx
  800988:	74 36                	je     8009c0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80098a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800990:	75 28                	jne    8009ba <memset+0x40>
  800992:	f6 c1 03             	test   $0x3,%cl
  800995:	75 23                	jne    8009ba <memset+0x40>
		c &= 0xFF;
  800997:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80099b:	89 d3                	mov    %edx,%ebx
  80099d:	c1 e3 08             	shl    $0x8,%ebx
  8009a0:	89 d6                	mov    %edx,%esi
  8009a2:	c1 e6 18             	shl    $0x18,%esi
  8009a5:	89 d0                	mov    %edx,%eax
  8009a7:	c1 e0 10             	shl    $0x10,%eax
  8009aa:	09 f0                	or     %esi,%eax
  8009ac:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8009ae:	89 d8                	mov    %ebx,%eax
  8009b0:	09 d0                	or     %edx,%eax
  8009b2:	c1 e9 02             	shr    $0x2,%ecx
  8009b5:	fc                   	cld    
  8009b6:	f3 ab                	rep stos %eax,%es:(%edi)
  8009b8:	eb 06                	jmp    8009c0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	fc                   	cld    
  8009be:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009c0:	89 f8                	mov    %edi,%eax
  8009c2:	5b                   	pop    %ebx
  8009c3:	5e                   	pop    %esi
  8009c4:	5f                   	pop    %edi
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	57                   	push   %edi
  8009cb:	56                   	push   %esi
  8009cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009d2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009d5:	39 c6                	cmp    %eax,%esi
  8009d7:	73 35                	jae    800a0e <memmove+0x47>
  8009d9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009dc:	39 d0                	cmp    %edx,%eax
  8009de:	73 2e                	jae    800a0e <memmove+0x47>
		s += n;
		d += n;
  8009e0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009e3:	89 d6                	mov    %edx,%esi
  8009e5:	09 fe                	or     %edi,%esi
  8009e7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009ed:	75 13                	jne    800a02 <memmove+0x3b>
  8009ef:	f6 c1 03             	test   $0x3,%cl
  8009f2:	75 0e                	jne    800a02 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8009f4:	83 ef 04             	sub    $0x4,%edi
  8009f7:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009fa:	c1 e9 02             	shr    $0x2,%ecx
  8009fd:	fd                   	std    
  8009fe:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a00:	eb 09                	jmp    800a0b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a02:	83 ef 01             	sub    $0x1,%edi
  800a05:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a08:	fd                   	std    
  800a09:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a0b:	fc                   	cld    
  800a0c:	eb 1d                	jmp    800a2b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a0e:	89 f2                	mov    %esi,%edx
  800a10:	09 c2                	or     %eax,%edx
  800a12:	f6 c2 03             	test   $0x3,%dl
  800a15:	75 0f                	jne    800a26 <memmove+0x5f>
  800a17:	f6 c1 03             	test   $0x3,%cl
  800a1a:	75 0a                	jne    800a26 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800a1c:	c1 e9 02             	shr    $0x2,%ecx
  800a1f:	89 c7                	mov    %eax,%edi
  800a21:	fc                   	cld    
  800a22:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a24:	eb 05                	jmp    800a2b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a26:	89 c7                	mov    %eax,%edi
  800a28:	fc                   	cld    
  800a29:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a2b:	5e                   	pop    %esi
  800a2c:	5f                   	pop    %edi
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a2f:	55                   	push   %ebp
  800a30:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a32:	ff 75 10             	pushl  0x10(%ebp)
  800a35:	ff 75 0c             	pushl  0xc(%ebp)
  800a38:	ff 75 08             	pushl  0x8(%ebp)
  800a3b:	e8 87 ff ff ff       	call   8009c7 <memmove>
}
  800a40:	c9                   	leave  
  800a41:	c3                   	ret    

00800a42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a42:	55                   	push   %ebp
  800a43:	89 e5                	mov    %esp,%ebp
  800a45:	56                   	push   %esi
  800a46:	53                   	push   %ebx
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a4d:	89 c6                	mov    %eax,%esi
  800a4f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a52:	eb 1a                	jmp    800a6e <memcmp+0x2c>
		if (*s1 != *s2)
  800a54:	0f b6 08             	movzbl (%eax),%ecx
  800a57:	0f b6 1a             	movzbl (%edx),%ebx
  800a5a:	38 d9                	cmp    %bl,%cl
  800a5c:	74 0a                	je     800a68 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800a5e:	0f b6 c1             	movzbl %cl,%eax
  800a61:	0f b6 db             	movzbl %bl,%ebx
  800a64:	29 d8                	sub    %ebx,%eax
  800a66:	eb 0f                	jmp    800a77 <memcmp+0x35>
		s1++, s2++;
  800a68:	83 c0 01             	add    $0x1,%eax
  800a6b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6e:	39 f0                	cmp    %esi,%eax
  800a70:	75 e2                	jne    800a54 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800a72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5d                   	pop    %ebp
  800a7a:	c3                   	ret    

00800a7b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a7b:	55                   	push   %ebp
  800a7c:	89 e5                	mov    %esp,%ebp
  800a7e:	53                   	push   %ebx
  800a7f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a82:	89 c1                	mov    %eax,%ecx
  800a84:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a87:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a8b:	eb 0a                	jmp    800a97 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	39 da                	cmp    %ebx,%edx
  800a92:	74 07                	je     800a9b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a94:	83 c0 01             	add    $0x1,%eax
  800a97:	39 c8                	cmp    %ecx,%eax
  800a99:	72 f2                	jb     800a8d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a9b:	5b                   	pop    %ebx
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaa:	eb 03                	jmp    800aaf <strtol+0x11>
		s++;
  800aac:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aaf:	0f b6 01             	movzbl (%ecx),%eax
  800ab2:	3c 20                	cmp    $0x20,%al
  800ab4:	74 f6                	je     800aac <strtol+0xe>
  800ab6:	3c 09                	cmp    $0x9,%al
  800ab8:	74 f2                	je     800aac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800aba:	3c 2b                	cmp    $0x2b,%al
  800abc:	75 0a                	jne    800ac8 <strtol+0x2a>
		s++;
  800abe:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ac1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ac6:	eb 11                	jmp    800ad9 <strtol+0x3b>
  800ac8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800acd:	3c 2d                	cmp    $0x2d,%al
  800acf:	75 08                	jne    800ad9 <strtol+0x3b>
		s++, neg = 1;
  800ad1:	83 c1 01             	add    $0x1,%ecx
  800ad4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ad9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800adf:	75 15                	jne    800af6 <strtol+0x58>
  800ae1:	80 39 30             	cmpb   $0x30,(%ecx)
  800ae4:	75 10                	jne    800af6 <strtol+0x58>
  800ae6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aea:	75 7c                	jne    800b68 <strtol+0xca>
		s += 2, base = 16;
  800aec:	83 c1 02             	add    $0x2,%ecx
  800aef:	bb 10 00 00 00       	mov    $0x10,%ebx
  800af4:	eb 16                	jmp    800b0c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800af6:	85 db                	test   %ebx,%ebx
  800af8:	75 12                	jne    800b0c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800afa:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aff:	80 39 30             	cmpb   $0x30,(%ecx)
  800b02:	75 08                	jne    800b0c <strtol+0x6e>
		s++, base = 8;
  800b04:	83 c1 01             	add    $0x1,%ecx
  800b07:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b11:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b14:	0f b6 11             	movzbl (%ecx),%edx
  800b17:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b1a:	89 f3                	mov    %esi,%ebx
  800b1c:	80 fb 09             	cmp    $0x9,%bl
  800b1f:	77 08                	ja     800b29 <strtol+0x8b>
			dig = *s - '0';
  800b21:	0f be d2             	movsbl %dl,%edx
  800b24:	83 ea 30             	sub    $0x30,%edx
  800b27:	eb 22                	jmp    800b4b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800b29:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2c:	89 f3                	mov    %esi,%ebx
  800b2e:	80 fb 19             	cmp    $0x19,%bl
  800b31:	77 08                	ja     800b3b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800b33:	0f be d2             	movsbl %dl,%edx
  800b36:	83 ea 57             	sub    $0x57,%edx
  800b39:	eb 10                	jmp    800b4b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800b3b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3e:	89 f3                	mov    %esi,%ebx
  800b40:	80 fb 19             	cmp    $0x19,%bl
  800b43:	77 16                	ja     800b5b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800b45:	0f be d2             	movsbl %dl,%edx
  800b48:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800b4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b4e:	7d 0b                	jge    800b5b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800b50:	83 c1 01             	add    $0x1,%ecx
  800b53:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b57:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800b59:	eb b9                	jmp    800b14 <strtol+0x76>

	if (endptr)
  800b5b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b5f:	74 0d                	je     800b6e <strtol+0xd0>
		*endptr = (char *) s;
  800b61:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b64:	89 0e                	mov    %ecx,(%esi)
  800b66:	eb 06                	jmp    800b6e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b68:	85 db                	test   %ebx,%ebx
  800b6a:	74 98                	je     800b04 <strtol+0x66>
  800b6c:	eb 9e                	jmp    800b0c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800b6e:	89 c2                	mov    %eax,%edx
  800b70:	f7 da                	neg    %edx
  800b72:	85 ff                	test   %edi,%edi
  800b74:	0f 45 c2             	cmovne %edx,%eax
}
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	57                   	push   %edi
  800b80:	56                   	push   %esi
  800b81:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b82:	b8 00 00 00 00       	mov    $0x0,%eax
  800b87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8d:	89 c3                	mov    %eax,%ebx
  800b8f:	89 c7                	mov    %eax,%edi
  800b91:	89 c6                	mov    %eax,%esi
  800b93:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <sys_cgetc>:

int
sys_cgetc(void)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	57                   	push   %edi
  800b9e:	56                   	push   %esi
  800b9f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba5:	b8 01 00 00 00       	mov    $0x1,%eax
  800baa:	89 d1                	mov    %edx,%ecx
  800bac:	89 d3                	mov    %edx,%ebx
  800bae:	89 d7                	mov    %edx,%edi
  800bb0:	89 d6                	mov    %edx,%esi
  800bb2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5f                   	pop    %edi
  800bb7:	5d                   	pop    %ebp
  800bb8:	c3                   	ret    

00800bb9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	57                   	push   %edi
  800bbd:	56                   	push   %esi
  800bbe:	53                   	push   %ebx
  800bbf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc7:	b8 03 00 00 00       	mov    $0x3,%eax
  800bcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bcf:	89 cb                	mov    %ecx,%ebx
  800bd1:	89 cf                	mov    %ecx,%edi
  800bd3:	89 ce                	mov    %ecx,%esi
  800bd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd7:	85 c0                	test   %eax,%eax
  800bd9:	7e 17                	jle    800bf2 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdb:	83 ec 0c             	sub    $0xc,%esp
  800bde:	50                   	push   %eax
  800bdf:	6a 03                	push   $0x3
  800be1:	68 ff 25 80 00       	push   $0x8025ff
  800be6:	6a 23                	push   $0x23
  800be8:	68 1c 26 80 00       	push   $0x80261c
  800bed:	e8 66 f5 ff ff       	call   800158 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	57                   	push   %edi
  800bfe:	56                   	push   %esi
  800bff:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	ba 00 00 00 00       	mov    $0x0,%edx
  800c05:	b8 02 00 00 00       	mov    $0x2,%eax
  800c0a:	89 d1                	mov    %edx,%ecx
  800c0c:	89 d3                	mov    %edx,%ebx
  800c0e:	89 d7                	mov    %edx,%edi
  800c10:	89 d6                	mov    %edx,%esi
  800c12:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c14:	5b                   	pop    %ebx
  800c15:	5e                   	pop    %esi
  800c16:	5f                   	pop    %edi
  800c17:	5d                   	pop    %ebp
  800c18:	c3                   	ret    

00800c19 <sys_yield>:

void
sys_yield(void)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1f:	ba 00 00 00 00       	mov    $0x0,%edx
  800c24:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c29:	89 d1                	mov    %edx,%ecx
  800c2b:	89 d3                	mov    %edx,%ebx
  800c2d:	89 d7                	mov    %edx,%edi
  800c2f:	89 d6                	mov    %edx,%esi
  800c31:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c33:	5b                   	pop    %ebx
  800c34:	5e                   	pop    %esi
  800c35:	5f                   	pop    %edi
  800c36:	5d                   	pop    %ebp
  800c37:	c3                   	ret    

00800c38 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c38:	55                   	push   %ebp
  800c39:	89 e5                	mov    %esp,%ebp
  800c3b:	57                   	push   %edi
  800c3c:	56                   	push   %esi
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c41:	be 00 00 00 00       	mov    $0x0,%esi
  800c46:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c54:	89 f7                	mov    %esi,%edi
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 04                	push   $0x4
  800c62:	68 ff 25 80 00       	push   $0x8025ff
  800c67:	6a 23                	push   $0x23
  800c69:	68 1c 26 80 00       	push   $0x80261c
  800c6e:	e8 e5 f4 ff ff       	call   800158 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c84:	b8 05 00 00 00       	mov    $0x5,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c92:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c95:	8b 75 18             	mov    0x18(%ebp),%esi
  800c98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 05                	push   $0x5
  800ca4:	68 ff 25 80 00       	push   $0x8025ff
  800ca9:	6a 23                	push   $0x23
  800cab:	68 1c 26 80 00       	push   $0x80261c
  800cb0:	e8 a3 f4 ff ff       	call   800158 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
  800cc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccb:	b8 06 00 00 00       	mov    $0x6,%eax
  800cd0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd6:	89 df                	mov    %ebx,%edi
  800cd8:	89 de                	mov    %ebx,%esi
  800cda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cdc:	85 c0                	test   %eax,%eax
  800cde:	7e 17                	jle    800cf7 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce0:	83 ec 0c             	sub    $0xc,%esp
  800ce3:	50                   	push   %eax
  800ce4:	6a 06                	push   $0x6
  800ce6:	68 ff 25 80 00       	push   $0x8025ff
  800ceb:	6a 23                	push   $0x23
  800ced:	68 1c 26 80 00       	push   $0x80261c
  800cf2:	e8 61 f4 ff ff       	call   800158 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    

00800cff <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cff:	55                   	push   %ebp
  800d00:	89 e5                	mov    %esp,%ebp
  800d02:	57                   	push   %edi
  800d03:	56                   	push   %esi
  800d04:	53                   	push   %ebx
  800d05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0d:	b8 08 00 00 00       	mov    $0x8,%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	89 df                	mov    %ebx,%edi
  800d1a:	89 de                	mov    %ebx,%esi
  800d1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	7e 17                	jle    800d39 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d22:	83 ec 0c             	sub    $0xc,%esp
  800d25:	50                   	push   %eax
  800d26:	6a 08                	push   $0x8
  800d28:	68 ff 25 80 00       	push   $0x8025ff
  800d2d:	6a 23                	push   $0x23
  800d2f:	68 1c 26 80 00       	push   $0x80261c
  800d34:	e8 1f f4 ff ff       	call   800158 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3c:	5b                   	pop    %ebx
  800d3d:	5e                   	pop    %esi
  800d3e:	5f                   	pop    %edi
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	57                   	push   %edi
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4f:	b8 09 00 00 00       	mov    $0x9,%eax
  800d54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d57:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5a:	89 df                	mov    %ebx,%edi
  800d5c:	89 de                	mov    %ebx,%esi
  800d5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d60:	85 c0                	test   %eax,%eax
  800d62:	7e 17                	jle    800d7b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d64:	83 ec 0c             	sub    $0xc,%esp
  800d67:	50                   	push   %eax
  800d68:	6a 09                	push   $0x9
  800d6a:	68 ff 25 80 00       	push   $0x8025ff
  800d6f:	6a 23                	push   $0x23
  800d71:	68 1c 26 80 00       	push   $0x80261c
  800d76:	e8 dd f3 ff ff       	call   800158 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7e:	5b                   	pop    %ebx
  800d7f:	5e                   	pop    %esi
  800d80:	5f                   	pop    %edi
  800d81:	5d                   	pop    %ebp
  800d82:	c3                   	ret    

00800d83 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d83:	55                   	push   %ebp
  800d84:	89 e5                	mov    %esp,%ebp
  800d86:	57                   	push   %edi
  800d87:	56                   	push   %esi
  800d88:	53                   	push   %ebx
  800d89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d99:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9c:	89 df                	mov    %ebx,%edi
  800d9e:	89 de                	mov    %ebx,%esi
  800da0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800da2:	85 c0                	test   %eax,%eax
  800da4:	7e 17                	jle    800dbd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	50                   	push   %eax
  800daa:	6a 0a                	push   $0xa
  800dac:	68 ff 25 80 00       	push   $0x8025ff
  800db1:	6a 23                	push   $0x23
  800db3:	68 1c 26 80 00       	push   $0x80261c
  800db8:	e8 9b f3 ff ff       	call   800158 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc0:	5b                   	pop    %ebx
  800dc1:	5e                   	pop    %esi
  800dc2:	5f                   	pop    %edi
  800dc3:	5d                   	pop    %ebp
  800dc4:	c3                   	ret    

00800dc5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dc5:	55                   	push   %ebp
  800dc6:	89 e5                	mov    %esp,%ebp
  800dc8:	57                   	push   %edi
  800dc9:	56                   	push   %esi
  800dca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcb:	be 00 00 00 00       	mov    $0x0,%esi
  800dd0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dd5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dde:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	57                   	push   %edi
  800dec:	56                   	push   %esi
  800ded:	53                   	push   %ebx
  800dee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df6:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 cb                	mov    %ecx,%ebx
  800e00:	89 cf                	mov    %ecx,%edi
  800e02:	89 ce                	mov    %ecx,%esi
  800e04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 0d                	push   $0xd
  800e10:	68 ff 25 80 00       	push   $0x8025ff
  800e15:	6a 23                	push   $0x23
  800e17:	68 1c 26 80 00       	push   $0x80261c
  800e1c:	e8 37 f3 ff ff       	call   800158 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	56                   	push   %esi
  800e2d:	53                   	push   %ebx
  800e2e:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800e31:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800e33:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e37:	74 11                	je     800e4a <pgfault+0x21>
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	c1 e8 0c             	shr    $0xc,%eax
  800e3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e45:	f6 c4 08             	test   $0x8,%ah
  800e48:	75 14                	jne    800e5e <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800e4a:	83 ec 04             	sub    $0x4,%esp
  800e4d:	68 2c 26 80 00       	push   $0x80262c
  800e52:	6a 1f                	push   $0x1f
  800e54:	68 8f 26 80 00       	push   $0x80268f
  800e59:	e8 fa f2 ff ff       	call   800158 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800e5e:	e8 97 fd ff ff       	call   800bfa <sys_getenvid>
  800e63:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	6a 07                	push   $0x7
  800e6a:	68 00 f0 7f 00       	push   $0x7ff000
  800e6f:	50                   	push   %eax
  800e70:	e8 c3 fd ff ff       	call   800c38 <sys_page_alloc>
  800e75:	83 c4 10             	add    $0x10,%esp
  800e78:	85 c0                	test   %eax,%eax
  800e7a:	79 12                	jns    800e8e <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800e7c:	50                   	push   %eax
  800e7d:	68 6c 26 80 00       	push   $0x80266c
  800e82:	6a 2c                	push   $0x2c
  800e84:	68 8f 26 80 00       	push   $0x80268f
  800e89:	e8 ca f2 ff ff       	call   800158 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800e8e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	68 00 10 00 00       	push   $0x1000
  800e9c:	53                   	push   %ebx
  800e9d:	68 00 f0 7f 00       	push   $0x7ff000
  800ea2:	e8 20 fb ff ff       	call   8009c7 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800ea7:	83 c4 08             	add    $0x8,%esp
  800eaa:	53                   	push   %ebx
  800eab:	56                   	push   %esi
  800eac:	e8 0c fe ff ff       	call   800cbd <sys_page_unmap>
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	79 12                	jns    800eca <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800eb8:	50                   	push   %eax
  800eb9:	68 9a 26 80 00       	push   $0x80269a
  800ebe:	6a 32                	push   $0x32
  800ec0:	68 8f 26 80 00       	push   $0x80268f
  800ec5:	e8 8e f2 ff ff       	call   800158 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800eca:	83 ec 0c             	sub    $0xc,%esp
  800ecd:	6a 07                	push   $0x7
  800ecf:	53                   	push   %ebx
  800ed0:	56                   	push   %esi
  800ed1:	68 00 f0 7f 00       	push   $0x7ff000
  800ed6:	56                   	push   %esi
  800ed7:	e8 9f fd ff ff       	call   800c7b <sys_page_map>
  800edc:	83 c4 20             	add    $0x20,%esp
  800edf:	85 c0                	test   %eax,%eax
  800ee1:	79 12                	jns    800ef5 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800ee3:	50                   	push   %eax
  800ee4:	68 b8 26 80 00       	push   $0x8026b8
  800ee9:	6a 35                	push   $0x35
  800eeb:	68 8f 26 80 00       	push   $0x80268f
  800ef0:	e8 63 f2 ff ff       	call   800158 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800ef5:	83 ec 08             	sub    $0x8,%esp
  800ef8:	68 00 f0 7f 00       	push   $0x7ff000
  800efd:	56                   	push   %esi
  800efe:	e8 ba fd ff ff       	call   800cbd <sys_page_unmap>
  800f03:	83 c4 10             	add    $0x10,%esp
  800f06:	85 c0                	test   %eax,%eax
  800f08:	79 12                	jns    800f1c <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800f0a:	50                   	push   %eax
  800f0b:	68 9a 26 80 00       	push   $0x80269a
  800f10:	6a 38                	push   $0x38
  800f12:	68 8f 26 80 00       	push   $0x80268f
  800f17:	e8 3c f2 ff ff       	call   800158 <_panic>
	//panic("pgfault not implemented");
}
  800f1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5d                   	pop    %ebp
  800f22:	c3                   	ret    

00800f23 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	57                   	push   %edi
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800f2c:	68 29 0e 80 00       	push   $0x800e29
  800f31:	e8 ea 0f 00 00       	call   801f20 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f36:	b8 07 00 00 00       	mov    $0x7,%eax
  800f3b:	cd 30                	int    $0x30
  800f3d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	85 c0                	test   %eax,%eax
  800f45:	0f 88 38 01 00 00    	js     801083 <fork+0x160>
  800f4b:	89 c7                	mov    %eax,%edi
  800f4d:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800f52:	85 c0                	test   %eax,%eax
  800f54:	75 21                	jne    800f77 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800f56:	e8 9f fc ff ff       	call   800bfa <sys_getenvid>
  800f5b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f60:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f63:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f68:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f72:	e9 86 01 00 00       	jmp    8010fd <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800f77:	89 d8                	mov    %ebx,%eax
  800f79:	c1 e8 16             	shr    $0x16,%eax
  800f7c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f83:	a8 01                	test   $0x1,%al
  800f85:	0f 84 90 00 00 00    	je     80101b <fork+0xf8>
  800f8b:	89 d8                	mov    %ebx,%eax
  800f8d:	c1 e8 0c             	shr    $0xc,%eax
  800f90:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f97:	f6 c2 01             	test   $0x1,%dl
  800f9a:	74 7f                	je     80101b <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  800f9c:	89 c6                	mov    %eax,%esi
  800f9e:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  800fa1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa8:	f6 c6 04             	test   $0x4,%dh
  800fab:	74 33                	je     800fe0 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  800fad:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	25 07 0e 00 00       	and    $0xe07,%eax
  800fbc:	50                   	push   %eax
  800fbd:	56                   	push   %esi
  800fbe:	57                   	push   %edi
  800fbf:	56                   	push   %esi
  800fc0:	6a 00                	push   $0x0
  800fc2:	e8 b4 fc ff ff       	call   800c7b <sys_page_map>
  800fc7:	83 c4 20             	add    $0x20,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	79 4d                	jns    80101b <fork+0xf8>
		    panic("sys_page_map: %e", r);
  800fce:	50                   	push   %eax
  800fcf:	68 d4 26 80 00       	push   $0x8026d4
  800fd4:	6a 54                	push   $0x54
  800fd6:	68 8f 26 80 00       	push   $0x80268f
  800fdb:	e8 78 f1 ff ff       	call   800158 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800fe0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe7:	a9 02 08 00 00       	test   $0x802,%eax
  800fec:	0f 85 c6 00 00 00    	jne    8010b8 <fork+0x195>
  800ff2:	e9 e3 00 00 00       	jmp    8010da <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800ff7:	50                   	push   %eax
  800ff8:	68 d4 26 80 00       	push   $0x8026d4
  800ffd:	6a 5d                	push   $0x5d
  800fff:	68 8f 26 80 00       	push   $0x80268f
  801004:	e8 4f f1 ff ff       	call   800158 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  801009:	50                   	push   %eax
  80100a:	68 d4 26 80 00       	push   $0x8026d4
  80100f:	6a 64                	push   $0x64
  801011:	68 8f 26 80 00       	push   $0x80268f
  801016:	e8 3d f1 ff ff       	call   800158 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  80101b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801021:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801027:	0f 85 4a ff ff ff    	jne    800f77 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	6a 07                	push   $0x7
  801032:	68 00 f0 bf ee       	push   $0xeebff000
  801037:	8b 7d e0             	mov    -0x20(%ebp),%edi
  80103a:	57                   	push   %edi
  80103b:	e8 f8 fb ff ff       	call   800c38 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801040:	83 c4 10             	add    $0x10,%esp
		return ret;
  801043:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  801045:	85 c0                	test   %eax,%eax
  801047:	0f 88 b0 00 00 00    	js     8010fd <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  80104d:	a1 04 40 80 00       	mov    0x804004,%eax
  801052:	8b 40 64             	mov    0x64(%eax),%eax
  801055:	83 ec 08             	sub    $0x8,%esp
  801058:	50                   	push   %eax
  801059:	57                   	push   %edi
  80105a:	e8 24 fd ff ff       	call   800d83 <sys_env_set_pgfault_upcall>
  80105f:	83 c4 10             	add    $0x10,%esp
		return ret;
  801062:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  801064:	85 c0                	test   %eax,%eax
  801066:	0f 88 91 00 00 00    	js     8010fd <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80106c:	83 ec 08             	sub    $0x8,%esp
  80106f:	6a 02                	push   $0x2
  801071:	57                   	push   %edi
  801072:	e8 88 fc ff ff       	call   800cff <sys_env_set_status>
  801077:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  80107a:	85 c0                	test   %eax,%eax
  80107c:	89 fa                	mov    %edi,%edx
  80107e:	0f 48 d0             	cmovs  %eax,%edx
  801081:	eb 7a                	jmp    8010fd <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  801083:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801086:	eb 75                	jmp    8010fd <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801088:	e8 6d fb ff ff       	call   800bfa <sys_getenvid>
  80108d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801090:	e8 65 fb ff ff       	call   800bfa <sys_getenvid>
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	68 05 08 00 00       	push   $0x805
  80109d:	56                   	push   %esi
  80109e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010a1:	56                   	push   %esi
  8010a2:	50                   	push   %eax
  8010a3:	e8 d3 fb ff ff       	call   800c7b <sys_page_map>
  8010a8:	83 c4 20             	add    $0x20,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	0f 89 68 ff ff ff    	jns    80101b <fork+0xf8>
  8010b3:	e9 51 ff ff ff       	jmp    801009 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  8010b8:	e8 3d fb ff ff       	call   800bfa <sys_getenvid>
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	68 05 08 00 00       	push   $0x805
  8010c5:	56                   	push   %esi
  8010c6:	57                   	push   %edi
  8010c7:	56                   	push   %esi
  8010c8:	50                   	push   %eax
  8010c9:	e8 ad fb ff ff       	call   800c7b <sys_page_map>
  8010ce:	83 c4 20             	add    $0x20,%esp
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	79 b3                	jns    801088 <fork+0x165>
  8010d5:	e9 1d ff ff ff       	jmp    800ff7 <fork+0xd4>
  8010da:	e8 1b fb ff ff       	call   800bfa <sys_getenvid>
  8010df:	83 ec 0c             	sub    $0xc,%esp
  8010e2:	6a 05                	push   $0x5
  8010e4:	56                   	push   %esi
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	50                   	push   %eax
  8010e8:	e8 8e fb ff ff       	call   800c7b <sys_page_map>
  8010ed:	83 c4 20             	add    $0x20,%esp
  8010f0:	85 c0                	test   %eax,%eax
  8010f2:	0f 89 23 ff ff ff    	jns    80101b <fork+0xf8>
  8010f8:	e9 fa fe ff ff       	jmp    800ff7 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  8010fd:	89 d0                	mov    %edx,%eax
  8010ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801102:	5b                   	pop    %ebx
  801103:	5e                   	pop    %esi
  801104:	5f                   	pop    %edi
  801105:	5d                   	pop    %ebp
  801106:	c3                   	ret    

00801107 <sfork>:

// Challenge!
int
sfork(void)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80110d:	68 e5 26 80 00       	push   $0x8026e5
  801112:	68 ac 00 00 00       	push   $0xac
  801117:	68 8f 26 80 00       	push   $0x80268f
  80111c:	e8 37 f0 ff ff       	call   800158 <_panic>

00801121 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	57                   	push   %edi
  801125:	56                   	push   %esi
  801126:	53                   	push   %ebx
  801127:	83 ec 0c             	sub    $0xc,%esp
  80112a:	8b 75 08             	mov    0x8(%ebp),%esi
  80112d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801130:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801133:	85 f6                	test   %esi,%esi
  801135:	74 06                	je     80113d <ipc_recv+0x1c>
		*from_env_store = 0;
  801137:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  80113d:	85 db                	test   %ebx,%ebx
  80113f:	74 06                	je     801147 <ipc_recv+0x26>
		*perm_store = 0;
  801141:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801147:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801149:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  80114e:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801151:	83 ec 0c             	sub    $0xc,%esp
  801154:	50                   	push   %eax
  801155:	e8 8e fc ff ff       	call   800de8 <sys_ipc_recv>
  80115a:	89 c7                	mov    %eax,%edi
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	79 14                	jns    801177 <ipc_recv+0x56>
		cprintf("im dead");
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	68 fb 26 80 00       	push   $0x8026fb
  80116b:	e8 c1 f0 ff ff       	call   800231 <cprintf>
		return r;
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	89 f8                	mov    %edi,%eax
  801175:	eb 24                	jmp    80119b <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801177:	85 f6                	test   %esi,%esi
  801179:	74 0a                	je     801185 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  80117b:	a1 04 40 80 00       	mov    0x804004,%eax
  801180:	8b 40 74             	mov    0x74(%eax),%eax
  801183:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801185:	85 db                	test   %ebx,%ebx
  801187:	74 0a                	je     801193 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801189:	a1 04 40 80 00       	mov    0x804004,%eax
  80118e:	8b 40 78             	mov    0x78(%eax),%eax
  801191:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801193:	a1 04 40 80 00       	mov    0x804004,%eax
  801198:	8b 40 70             	mov    0x70(%eax),%eax
}
  80119b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 0c             	sub    $0xc,%esp
  8011ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  8011b5:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  8011b7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  8011bc:	0f 44 d8             	cmove  %eax,%ebx
  8011bf:	eb 1c                	jmp    8011dd <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  8011c1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8011c4:	74 12                	je     8011d8 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  8011c6:	50                   	push   %eax
  8011c7:	68 03 27 80 00       	push   $0x802703
  8011cc:	6a 4e                	push   $0x4e
  8011ce:	68 10 27 80 00       	push   $0x802710
  8011d3:	e8 80 ef ff ff       	call   800158 <_panic>
		sys_yield();
  8011d8:	e8 3c fa ff ff       	call   800c19 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  8011dd:	ff 75 14             	pushl  0x14(%ebp)
  8011e0:	53                   	push   %ebx
  8011e1:	56                   	push   %esi
  8011e2:	57                   	push   %edi
  8011e3:	e8 dd fb ff ff       	call   800dc5 <sys_ipc_try_send>
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 d2                	js     8011c1 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  8011ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801202:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801205:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80120b:	8b 52 50             	mov    0x50(%edx),%edx
  80120e:	39 ca                	cmp    %ecx,%edx
  801210:	75 0d                	jne    80121f <ipc_find_env+0x28>
			return envs[i].env_id;
  801212:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801215:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80121a:	8b 40 48             	mov    0x48(%eax),%eax
  80121d:	eb 0f                	jmp    80122e <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80121f:	83 c0 01             	add    $0x1,%eax
  801222:	3d 00 04 00 00       	cmp    $0x400,%eax
  801227:	75 d9                	jne    801202 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801229:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801233:	8b 45 08             	mov    0x8(%ebp),%eax
  801236:	05 00 00 00 30       	add    $0x30000000,%eax
  80123b:	c1 e8 0c             	shr    $0xc,%eax
}
  80123e:	5d                   	pop    %ebp
  80123f:	c3                   	ret    

00801240 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801243:	8b 45 08             	mov    0x8(%ebp),%eax
  801246:	05 00 00 00 30       	add    $0x30000000,%eax
  80124b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801250:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801255:	5d                   	pop    %ebp
  801256:	c3                   	ret    

00801257 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801257:	55                   	push   %ebp
  801258:	89 e5                	mov    %esp,%ebp
  80125a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801262:	89 c2                	mov    %eax,%edx
  801264:	c1 ea 16             	shr    $0x16,%edx
  801267:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80126e:	f6 c2 01             	test   $0x1,%dl
  801271:	74 11                	je     801284 <fd_alloc+0x2d>
  801273:	89 c2                	mov    %eax,%edx
  801275:	c1 ea 0c             	shr    $0xc,%edx
  801278:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	75 09                	jne    80128d <fd_alloc+0x36>
			*fd_store = fd;
  801284:	89 01                	mov    %eax,(%ecx)
			return 0;
  801286:	b8 00 00 00 00       	mov    $0x0,%eax
  80128b:	eb 17                	jmp    8012a4 <fd_alloc+0x4d>
  80128d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801292:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801297:	75 c9                	jne    801262 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801299:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80129f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ac:	83 f8 1f             	cmp    $0x1f,%eax
  8012af:	77 36                	ja     8012e7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012b1:	c1 e0 0c             	shl    $0xc,%eax
  8012b4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012b9:	89 c2                	mov    %eax,%edx
  8012bb:	c1 ea 16             	shr    $0x16,%edx
  8012be:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c5:	f6 c2 01             	test   $0x1,%dl
  8012c8:	74 24                	je     8012ee <fd_lookup+0x48>
  8012ca:	89 c2                	mov    %eax,%edx
  8012cc:	c1 ea 0c             	shr    $0xc,%edx
  8012cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d6:	f6 c2 01             	test   $0x1,%dl
  8012d9:	74 1a                	je     8012f5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012de:	89 02                	mov    %eax,(%edx)
	return 0;
  8012e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e5:	eb 13                	jmp    8012fa <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ec:	eb 0c                	jmp    8012fa <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012f3:	eb 05                	jmp    8012fa <fd_lookup+0x54>
  8012f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801305:	ba 9c 27 80 00       	mov    $0x80279c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80130a:	eb 13                	jmp    80131f <dev_lookup+0x23>
  80130c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80130f:	39 08                	cmp    %ecx,(%eax)
  801311:	75 0c                	jne    80131f <dev_lookup+0x23>
			*dev = devtab[i];
  801313:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801316:	89 01                	mov    %eax,(%ecx)
			return 0;
  801318:	b8 00 00 00 00       	mov    $0x0,%eax
  80131d:	eb 2e                	jmp    80134d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80131f:	8b 02                	mov    (%edx),%eax
  801321:	85 c0                	test   %eax,%eax
  801323:	75 e7                	jne    80130c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801325:	a1 04 40 80 00       	mov    0x804004,%eax
  80132a:	8b 40 48             	mov    0x48(%eax),%eax
  80132d:	83 ec 04             	sub    $0x4,%esp
  801330:	51                   	push   %ecx
  801331:	50                   	push   %eax
  801332:	68 1c 27 80 00       	push   $0x80271c
  801337:	e8 f5 ee ff ff       	call   800231 <cprintf>
	*dev = 0;
  80133c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801345:	83 c4 10             	add    $0x10,%esp
  801348:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80134d:	c9                   	leave  
  80134e:	c3                   	ret    

0080134f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	56                   	push   %esi
  801353:	53                   	push   %ebx
  801354:	83 ec 10             	sub    $0x10,%esp
  801357:	8b 75 08             	mov    0x8(%ebp),%esi
  80135a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80135d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801360:	50                   	push   %eax
  801361:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801367:	c1 e8 0c             	shr    $0xc,%eax
  80136a:	50                   	push   %eax
  80136b:	e8 36 ff ff ff       	call   8012a6 <fd_lookup>
  801370:	83 c4 08             	add    $0x8,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 05                	js     80137c <fd_close+0x2d>
	    || fd != fd2)
  801377:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80137a:	74 0c                	je     801388 <fd_close+0x39>
		return (must_exist ? r : 0);
  80137c:	84 db                	test   %bl,%bl
  80137e:	ba 00 00 00 00       	mov    $0x0,%edx
  801383:	0f 44 c2             	cmove  %edx,%eax
  801386:	eb 41                	jmp    8013c9 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801388:	83 ec 08             	sub    $0x8,%esp
  80138b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	ff 36                	pushl  (%esi)
  801391:	e8 66 ff ff ff       	call   8012fc <dev_lookup>
  801396:	89 c3                	mov    %eax,%ebx
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	85 c0                	test   %eax,%eax
  80139d:	78 1a                	js     8013b9 <fd_close+0x6a>
		if (dev->dev_close)
  80139f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013a2:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	74 0b                	je     8013b9 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8013ae:	83 ec 0c             	sub    $0xc,%esp
  8013b1:	56                   	push   %esi
  8013b2:	ff d0                	call   *%eax
  8013b4:	89 c3                	mov    %eax,%ebx
  8013b6:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	56                   	push   %esi
  8013bd:	6a 00                	push   $0x0
  8013bf:	e8 f9 f8 ff ff       	call   800cbd <sys_page_unmap>
	return r;
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	89 d8                	mov    %ebx,%eax
}
  8013c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013cc:	5b                   	pop    %ebx
  8013cd:	5e                   	pop    %esi
  8013ce:	5d                   	pop    %ebp
  8013cf:	c3                   	ret    

008013d0 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013d9:	50                   	push   %eax
  8013da:	ff 75 08             	pushl  0x8(%ebp)
  8013dd:	e8 c4 fe ff ff       	call   8012a6 <fd_lookup>
  8013e2:	83 c4 08             	add    $0x8,%esp
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	78 10                	js     8013f9 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	6a 01                	push   $0x1
  8013ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8013f1:	e8 59 ff ff ff       	call   80134f <fd_close>
  8013f6:	83 c4 10             	add    $0x10,%esp
}
  8013f9:	c9                   	leave  
  8013fa:	c3                   	ret    

008013fb <close_all>:

void
close_all(void)
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	53                   	push   %ebx
  8013ff:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801402:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	53                   	push   %ebx
  80140b:	e8 c0 ff ff ff       	call   8013d0 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801410:	83 c3 01             	add    $0x1,%ebx
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	83 fb 20             	cmp    $0x20,%ebx
  801419:	75 ec                	jne    801407 <close_all+0xc>
		close(i);
}
  80141b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80141e:	c9                   	leave  
  80141f:	c3                   	ret    

00801420 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801420:	55                   	push   %ebp
  801421:	89 e5                	mov    %esp,%ebp
  801423:	57                   	push   %edi
  801424:	56                   	push   %esi
  801425:	53                   	push   %ebx
  801426:	83 ec 2c             	sub    $0x2c,%esp
  801429:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80142c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	ff 75 08             	pushl  0x8(%ebp)
  801433:	e8 6e fe ff ff       	call   8012a6 <fd_lookup>
  801438:	83 c4 08             	add    $0x8,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	0f 88 c1 00 00 00    	js     801504 <dup+0xe4>
		return r;
	close(newfdnum);
  801443:	83 ec 0c             	sub    $0xc,%esp
  801446:	56                   	push   %esi
  801447:	e8 84 ff ff ff       	call   8013d0 <close>

	newfd = INDEX2FD(newfdnum);
  80144c:	89 f3                	mov    %esi,%ebx
  80144e:	c1 e3 0c             	shl    $0xc,%ebx
  801451:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801457:	83 c4 04             	add    $0x4,%esp
  80145a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80145d:	e8 de fd ff ff       	call   801240 <fd2data>
  801462:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801464:	89 1c 24             	mov    %ebx,(%esp)
  801467:	e8 d4 fd ff ff       	call   801240 <fd2data>
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801472:	89 f8                	mov    %edi,%eax
  801474:	c1 e8 16             	shr    $0x16,%eax
  801477:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80147e:	a8 01                	test   $0x1,%al
  801480:	74 37                	je     8014b9 <dup+0x99>
  801482:	89 f8                	mov    %edi,%eax
  801484:	c1 e8 0c             	shr    $0xc,%eax
  801487:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80148e:	f6 c2 01             	test   $0x1,%dl
  801491:	74 26                	je     8014b9 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801493:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80149a:	83 ec 0c             	sub    $0xc,%esp
  80149d:	25 07 0e 00 00       	and    $0xe07,%eax
  8014a2:	50                   	push   %eax
  8014a3:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014a6:	6a 00                	push   $0x0
  8014a8:	57                   	push   %edi
  8014a9:	6a 00                	push   $0x0
  8014ab:	e8 cb f7 ff ff       	call   800c7b <sys_page_map>
  8014b0:	89 c7                	mov    %eax,%edi
  8014b2:	83 c4 20             	add    $0x20,%esp
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 2e                	js     8014e7 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014bc:	89 d0                	mov    %edx,%eax
  8014be:	c1 e8 0c             	shr    $0xc,%eax
  8014c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c8:	83 ec 0c             	sub    $0xc,%esp
  8014cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d0:	50                   	push   %eax
  8014d1:	53                   	push   %ebx
  8014d2:	6a 00                	push   $0x0
  8014d4:	52                   	push   %edx
  8014d5:	6a 00                	push   $0x0
  8014d7:	e8 9f f7 ff ff       	call   800c7b <sys_page_map>
  8014dc:	89 c7                	mov    %eax,%edi
  8014de:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014e1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014e3:	85 ff                	test   %edi,%edi
  8014e5:	79 1d                	jns    801504 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014e7:	83 ec 08             	sub    $0x8,%esp
  8014ea:	53                   	push   %ebx
  8014eb:	6a 00                	push   $0x0
  8014ed:	e8 cb f7 ff ff       	call   800cbd <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014f2:	83 c4 08             	add    $0x8,%esp
  8014f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f8:	6a 00                	push   $0x0
  8014fa:	e8 be f7 ff ff       	call   800cbd <sys_page_unmap>
	return r;
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	89 f8                	mov    %edi,%eax
}
  801504:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801507:	5b                   	pop    %ebx
  801508:	5e                   	pop    %esi
  801509:	5f                   	pop    %edi
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    

0080150c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	53                   	push   %ebx
  801510:	83 ec 14             	sub    $0x14,%esp
  801513:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801516:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	53                   	push   %ebx
  80151b:	e8 86 fd ff ff       	call   8012a6 <fd_lookup>
  801520:	83 c4 08             	add    $0x8,%esp
  801523:	89 c2                	mov    %eax,%edx
  801525:	85 c0                	test   %eax,%eax
  801527:	78 6d                	js     801596 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801529:	83 ec 08             	sub    $0x8,%esp
  80152c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80152f:	50                   	push   %eax
  801530:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801533:	ff 30                	pushl  (%eax)
  801535:	e8 c2 fd ff ff       	call   8012fc <dev_lookup>
  80153a:	83 c4 10             	add    $0x10,%esp
  80153d:	85 c0                	test   %eax,%eax
  80153f:	78 4c                	js     80158d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801541:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801544:	8b 42 08             	mov    0x8(%edx),%eax
  801547:	83 e0 03             	and    $0x3,%eax
  80154a:	83 f8 01             	cmp    $0x1,%eax
  80154d:	75 21                	jne    801570 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80154f:	a1 04 40 80 00       	mov    0x804004,%eax
  801554:	8b 40 48             	mov    0x48(%eax),%eax
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	53                   	push   %ebx
  80155b:	50                   	push   %eax
  80155c:	68 60 27 80 00       	push   $0x802760
  801561:	e8 cb ec ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80156e:	eb 26                	jmp    801596 <read+0x8a>
	}
	if (!dev->dev_read)
  801570:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801573:	8b 40 08             	mov    0x8(%eax),%eax
  801576:	85 c0                	test   %eax,%eax
  801578:	74 17                	je     801591 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80157a:	83 ec 04             	sub    $0x4,%esp
  80157d:	ff 75 10             	pushl  0x10(%ebp)
  801580:	ff 75 0c             	pushl  0xc(%ebp)
  801583:	52                   	push   %edx
  801584:	ff d0                	call   *%eax
  801586:	89 c2                	mov    %eax,%edx
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	eb 09                	jmp    801596 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80158d:	89 c2                	mov    %eax,%edx
  80158f:	eb 05                	jmp    801596 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801591:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801596:	89 d0                	mov    %edx,%eax
  801598:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80159b:	c9                   	leave  
  80159c:	c3                   	ret    

0080159d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	57                   	push   %edi
  8015a1:	56                   	push   %esi
  8015a2:	53                   	push   %ebx
  8015a3:	83 ec 0c             	sub    $0xc,%esp
  8015a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015a9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015b1:	eb 21                	jmp    8015d4 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b3:	83 ec 04             	sub    $0x4,%esp
  8015b6:	89 f0                	mov    %esi,%eax
  8015b8:	29 d8                	sub    %ebx,%eax
  8015ba:	50                   	push   %eax
  8015bb:	89 d8                	mov    %ebx,%eax
  8015bd:	03 45 0c             	add    0xc(%ebp),%eax
  8015c0:	50                   	push   %eax
  8015c1:	57                   	push   %edi
  8015c2:	e8 45 ff ff ff       	call   80150c <read>
		if (m < 0)
  8015c7:	83 c4 10             	add    $0x10,%esp
  8015ca:	85 c0                	test   %eax,%eax
  8015cc:	78 10                	js     8015de <readn+0x41>
			return m;
		if (m == 0)
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	74 0a                	je     8015dc <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d2:	01 c3                	add    %eax,%ebx
  8015d4:	39 f3                	cmp    %esi,%ebx
  8015d6:	72 db                	jb     8015b3 <readn+0x16>
  8015d8:	89 d8                	mov    %ebx,%eax
  8015da:	eb 02                	jmp    8015de <readn+0x41>
  8015dc:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e1:	5b                   	pop    %ebx
  8015e2:	5e                   	pop    %esi
  8015e3:	5f                   	pop    %edi
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    

008015e6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 14             	sub    $0x14,%esp
  8015ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f3:	50                   	push   %eax
  8015f4:	53                   	push   %ebx
  8015f5:	e8 ac fc ff ff       	call   8012a6 <fd_lookup>
  8015fa:	83 c4 08             	add    $0x8,%esp
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	85 c0                	test   %eax,%eax
  801601:	78 68                	js     80166b <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160d:	ff 30                	pushl  (%eax)
  80160f:	e8 e8 fc ff ff       	call   8012fc <dev_lookup>
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	78 47                	js     801662 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801622:	75 21                	jne    801645 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801624:	a1 04 40 80 00       	mov    0x804004,%eax
  801629:	8b 40 48             	mov    0x48(%eax),%eax
  80162c:	83 ec 04             	sub    $0x4,%esp
  80162f:	53                   	push   %ebx
  801630:	50                   	push   %eax
  801631:	68 7c 27 80 00       	push   $0x80277c
  801636:	e8 f6 eb ff ff       	call   800231 <cprintf>
		return -E_INVAL;
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801643:	eb 26                	jmp    80166b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801645:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801648:	8b 52 0c             	mov    0xc(%edx),%edx
  80164b:	85 d2                	test   %edx,%edx
  80164d:	74 17                	je     801666 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80164f:	83 ec 04             	sub    $0x4,%esp
  801652:	ff 75 10             	pushl  0x10(%ebp)
  801655:	ff 75 0c             	pushl  0xc(%ebp)
  801658:	50                   	push   %eax
  801659:	ff d2                	call   *%edx
  80165b:	89 c2                	mov    %eax,%edx
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	eb 09                	jmp    80166b <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801662:	89 c2                	mov    %eax,%edx
  801664:	eb 05                	jmp    80166b <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801666:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80166b:	89 d0                	mov    %edx,%eax
  80166d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <seek>:

int
seek(int fdnum, off_t offset)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801678:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80167b:	50                   	push   %eax
  80167c:	ff 75 08             	pushl  0x8(%ebp)
  80167f:	e8 22 fc ff ff       	call   8012a6 <fd_lookup>
  801684:	83 c4 08             	add    $0x8,%esp
  801687:	85 c0                	test   %eax,%eax
  801689:	78 0e                	js     801699 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80168b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80168e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801691:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801694:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801699:	c9                   	leave  
  80169a:	c3                   	ret    

0080169b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	53                   	push   %ebx
  80169f:	83 ec 14             	sub    $0x14,%esp
  8016a2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016a8:	50                   	push   %eax
  8016a9:	53                   	push   %ebx
  8016aa:	e8 f7 fb ff ff       	call   8012a6 <fd_lookup>
  8016af:	83 c4 08             	add    $0x8,%esp
  8016b2:	89 c2                	mov    %eax,%edx
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	78 65                	js     80171d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b8:	83 ec 08             	sub    $0x8,%esp
  8016bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016be:	50                   	push   %eax
  8016bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c2:	ff 30                	pushl  (%eax)
  8016c4:	e8 33 fc ff ff       	call   8012fc <dev_lookup>
  8016c9:	83 c4 10             	add    $0x10,%esp
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	78 44                	js     801714 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016d7:	75 21                	jne    8016fa <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016d9:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016de:	8b 40 48             	mov    0x48(%eax),%eax
  8016e1:	83 ec 04             	sub    $0x4,%esp
  8016e4:	53                   	push   %ebx
  8016e5:	50                   	push   %eax
  8016e6:	68 3c 27 80 00       	push   $0x80273c
  8016eb:	e8 41 eb ff ff       	call   800231 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016f0:	83 c4 10             	add    $0x10,%esp
  8016f3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016f8:	eb 23                	jmp    80171d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8016fa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016fd:	8b 52 18             	mov    0x18(%edx),%edx
  801700:	85 d2                	test   %edx,%edx
  801702:	74 14                	je     801718 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801704:	83 ec 08             	sub    $0x8,%esp
  801707:	ff 75 0c             	pushl  0xc(%ebp)
  80170a:	50                   	push   %eax
  80170b:	ff d2                	call   *%edx
  80170d:	89 c2                	mov    %eax,%edx
  80170f:	83 c4 10             	add    $0x10,%esp
  801712:	eb 09                	jmp    80171d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801714:	89 c2                	mov    %eax,%edx
  801716:	eb 05                	jmp    80171d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801718:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80171d:	89 d0                	mov    %edx,%eax
  80171f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	53                   	push   %ebx
  801728:	83 ec 14             	sub    $0x14,%esp
  80172b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80172e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801731:	50                   	push   %eax
  801732:	ff 75 08             	pushl  0x8(%ebp)
  801735:	e8 6c fb ff ff       	call   8012a6 <fd_lookup>
  80173a:	83 c4 08             	add    $0x8,%esp
  80173d:	89 c2                	mov    %eax,%edx
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 58                	js     80179b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801743:	83 ec 08             	sub    $0x8,%esp
  801746:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80174d:	ff 30                	pushl  (%eax)
  80174f:	e8 a8 fb ff ff       	call   8012fc <dev_lookup>
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	85 c0                	test   %eax,%eax
  801759:	78 37                	js     801792 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80175b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801762:	74 32                	je     801796 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801764:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801767:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80176e:	00 00 00 
	stat->st_isdir = 0;
  801771:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801778:	00 00 00 
	stat->st_dev = dev;
  80177b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801781:	83 ec 08             	sub    $0x8,%esp
  801784:	53                   	push   %ebx
  801785:	ff 75 f0             	pushl  -0x10(%ebp)
  801788:	ff 50 14             	call   *0x14(%eax)
  80178b:	89 c2                	mov    %eax,%edx
  80178d:	83 c4 10             	add    $0x10,%esp
  801790:	eb 09                	jmp    80179b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801792:	89 c2                	mov    %eax,%edx
  801794:	eb 05                	jmp    80179b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801796:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80179b:	89 d0                	mov    %edx,%eax
  80179d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    

008017a2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	56                   	push   %esi
  8017a6:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017a7:	83 ec 08             	sub    $0x8,%esp
  8017aa:	6a 00                	push   $0x0
  8017ac:	ff 75 08             	pushl  0x8(%ebp)
  8017af:	e8 e9 01 00 00       	call   80199d <open>
  8017b4:	89 c3                	mov    %eax,%ebx
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	85 c0                	test   %eax,%eax
  8017bb:	78 1b                	js     8017d8 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017bd:	83 ec 08             	sub    $0x8,%esp
  8017c0:	ff 75 0c             	pushl  0xc(%ebp)
  8017c3:	50                   	push   %eax
  8017c4:	e8 5b ff ff ff       	call   801724 <fstat>
  8017c9:	89 c6                	mov    %eax,%esi
	close(fd);
  8017cb:	89 1c 24             	mov    %ebx,(%esp)
  8017ce:	e8 fd fb ff ff       	call   8013d0 <close>
	return r;
  8017d3:	83 c4 10             	add    $0x10,%esp
  8017d6:	89 f0                	mov    %esi,%eax
}
  8017d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5e                   	pop    %esi
  8017dd:	5d                   	pop    %ebp
  8017de:	c3                   	ret    

008017df <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	56                   	push   %esi
  8017e3:	53                   	push   %ebx
  8017e4:	89 c6                	mov    %eax,%esi
  8017e6:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017e8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017ef:	75 12                	jne    801803 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017f1:	83 ec 0c             	sub    $0xc,%esp
  8017f4:	6a 01                	push   $0x1
  8017f6:	e8 fc f9 ff ff       	call   8011f7 <ipc_find_env>
  8017fb:	a3 00 40 80 00       	mov    %eax,0x804000
  801800:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801803:	6a 07                	push   $0x7
  801805:	68 00 50 80 00       	push   $0x805000
  80180a:	56                   	push   %esi
  80180b:	ff 35 00 40 80 00    	pushl  0x804000
  801811:	e8 8d f9 ff ff       	call   8011a3 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801816:	83 c4 0c             	add    $0xc,%esp
  801819:	6a 00                	push   $0x0
  80181b:	53                   	push   %ebx
  80181c:	6a 00                	push   $0x0
  80181e:	e8 fe f8 ff ff       	call   801121 <ipc_recv>
}
  801823:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801826:	5b                   	pop    %ebx
  801827:	5e                   	pop    %esi
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80182a:	55                   	push   %ebp
  80182b:	89 e5                	mov    %esp,%ebp
  80182d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801830:	8b 45 08             	mov    0x8(%ebp),%eax
  801833:	8b 40 0c             	mov    0xc(%eax),%eax
  801836:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80183b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801843:	ba 00 00 00 00       	mov    $0x0,%edx
  801848:	b8 02 00 00 00       	mov    $0x2,%eax
  80184d:	e8 8d ff ff ff       	call   8017df <fsipc>
}
  801852:	c9                   	leave  
  801853:	c3                   	ret    

00801854 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801854:	55                   	push   %ebp
  801855:	89 e5                	mov    %esp,%ebp
  801857:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	8b 40 0c             	mov    0xc(%eax),%eax
  801860:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801865:	ba 00 00 00 00       	mov    $0x0,%edx
  80186a:	b8 06 00 00 00       	mov    $0x6,%eax
  80186f:	e8 6b ff ff ff       	call   8017df <fsipc>
}
  801874:	c9                   	leave  
  801875:	c3                   	ret    

00801876 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801876:	55                   	push   %ebp
  801877:	89 e5                	mov    %esp,%ebp
  801879:	53                   	push   %ebx
  80187a:	83 ec 04             	sub    $0x4,%esp
  80187d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801880:	8b 45 08             	mov    0x8(%ebp),%eax
  801883:	8b 40 0c             	mov    0xc(%eax),%eax
  801886:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80188b:	ba 00 00 00 00       	mov    $0x0,%edx
  801890:	b8 05 00 00 00       	mov    $0x5,%eax
  801895:	e8 45 ff ff ff       	call   8017df <fsipc>
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 2c                	js     8018ca <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80189e:	83 ec 08             	sub    $0x8,%esp
  8018a1:	68 00 50 80 00       	push   $0x805000
  8018a6:	53                   	push   %ebx
  8018a7:	e8 89 ef ff ff       	call   800835 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018ac:	a1 80 50 80 00       	mov    0x805080,%eax
  8018b1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b7:	a1 84 50 80 00       	mov    0x805084,%eax
  8018bc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 0c             	sub    $0xc,%esp
  8018d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018dd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018e2:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e8:	8b 52 0c             	mov    0xc(%edx),%edx
  8018eb:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8018f1:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8018f6:	50                   	push   %eax
  8018f7:	ff 75 0c             	pushl  0xc(%ebp)
  8018fa:	68 08 50 80 00       	push   $0x805008
  8018ff:	e8 c3 f0 ff ff       	call   8009c7 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801904:	ba 00 00 00 00       	mov    $0x0,%edx
  801909:	b8 04 00 00 00       	mov    $0x4,%eax
  80190e:	e8 cc fe ff ff       	call   8017df <fsipc>
            return r;

    return r;
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	8b 40 0c             	mov    0xc(%eax),%eax
  801923:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801928:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80192e:	ba 00 00 00 00       	mov    $0x0,%edx
  801933:	b8 03 00 00 00       	mov    $0x3,%eax
  801938:	e8 a2 fe ff ff       	call   8017df <fsipc>
  80193d:	89 c3                	mov    %eax,%ebx
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 51                	js     801994 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801943:	39 c6                	cmp    %eax,%esi
  801945:	73 19                	jae    801960 <devfile_read+0x4b>
  801947:	68 ac 27 80 00       	push   $0x8027ac
  80194c:	68 b3 27 80 00       	push   $0x8027b3
  801951:	68 82 00 00 00       	push   $0x82
  801956:	68 c8 27 80 00       	push   $0x8027c8
  80195b:	e8 f8 e7 ff ff       	call   800158 <_panic>
	assert(r <= PGSIZE);
  801960:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801965:	7e 19                	jle    801980 <devfile_read+0x6b>
  801967:	68 d3 27 80 00       	push   $0x8027d3
  80196c:	68 b3 27 80 00       	push   $0x8027b3
  801971:	68 83 00 00 00       	push   $0x83
  801976:	68 c8 27 80 00       	push   $0x8027c8
  80197b:	e8 d8 e7 ff ff       	call   800158 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801980:	83 ec 04             	sub    $0x4,%esp
  801983:	50                   	push   %eax
  801984:	68 00 50 80 00       	push   $0x805000
  801989:	ff 75 0c             	pushl  0xc(%ebp)
  80198c:	e8 36 f0 ff ff       	call   8009c7 <memmove>
	return r;
  801991:	83 c4 10             	add    $0x10,%esp
}
  801994:	89 d8                	mov    %ebx,%eax
  801996:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    

0080199d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80199d:	55                   	push   %ebp
  80199e:	89 e5                	mov    %esp,%ebp
  8019a0:	53                   	push   %ebx
  8019a1:	83 ec 20             	sub    $0x20,%esp
  8019a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019a7:	53                   	push   %ebx
  8019a8:	e8 4f ee ff ff       	call   8007fc <strlen>
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b5:	7f 67                	jg     801a1e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019b7:	83 ec 0c             	sub    $0xc,%esp
  8019ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bd:	50                   	push   %eax
  8019be:	e8 94 f8 ff ff       	call   801257 <fd_alloc>
  8019c3:	83 c4 10             	add    $0x10,%esp
		return r;
  8019c6:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 57                	js     801a23 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019cc:	83 ec 08             	sub    $0x8,%esp
  8019cf:	53                   	push   %ebx
  8019d0:	68 00 50 80 00       	push   $0x805000
  8019d5:	e8 5b ee ff ff       	call   800835 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019dd:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e5:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ea:	e8 f0 fd ff ff       	call   8017df <fsipc>
  8019ef:	89 c3                	mov    %eax,%ebx
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	79 14                	jns    801a0c <open+0x6f>
		fd_close(fd, 0);
  8019f8:	83 ec 08             	sub    $0x8,%esp
  8019fb:	6a 00                	push   $0x0
  8019fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801a00:	e8 4a f9 ff ff       	call   80134f <fd_close>
		return r;
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	89 da                	mov    %ebx,%edx
  801a0a:	eb 17                	jmp    801a23 <open+0x86>
	}

	return fd2num(fd);
  801a0c:	83 ec 0c             	sub    $0xc,%esp
  801a0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a12:	e8 19 f8 ff ff       	call   801230 <fd2num>
  801a17:	89 c2                	mov    %eax,%edx
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	eb 05                	jmp    801a23 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a1e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a23:	89 d0                	mov    %edx,%eax
  801a25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a28:	c9                   	leave  
  801a29:	c3                   	ret    

00801a2a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a2a:	55                   	push   %ebp
  801a2b:	89 e5                	mov    %esp,%ebp
  801a2d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a30:	ba 00 00 00 00       	mov    $0x0,%edx
  801a35:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3a:	e8 a0 fd ff ff       	call   8017df <fsipc>
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a49:	83 ec 0c             	sub    $0xc,%esp
  801a4c:	ff 75 08             	pushl  0x8(%ebp)
  801a4f:	e8 ec f7 ff ff       	call   801240 <fd2data>
  801a54:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a56:	83 c4 08             	add    $0x8,%esp
  801a59:	68 df 27 80 00       	push   $0x8027df
  801a5e:	53                   	push   %ebx
  801a5f:	e8 d1 ed ff ff       	call   800835 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a64:	8b 46 04             	mov    0x4(%esi),%eax
  801a67:	2b 06                	sub    (%esi),%eax
  801a69:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a6f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a76:	00 00 00 
	stat->st_dev = &devpipe;
  801a79:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a80:	30 80 00 
	return 0;
}
  801a83:	b8 00 00 00 00       	mov    $0x0,%eax
  801a88:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a8b:	5b                   	pop    %ebx
  801a8c:	5e                   	pop    %esi
  801a8d:	5d                   	pop    %ebp
  801a8e:	c3                   	ret    

00801a8f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	53                   	push   %ebx
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a99:	53                   	push   %ebx
  801a9a:	6a 00                	push   $0x0
  801a9c:	e8 1c f2 ff ff       	call   800cbd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aa1:	89 1c 24             	mov    %ebx,(%esp)
  801aa4:	e8 97 f7 ff ff       	call   801240 <fd2data>
  801aa9:	83 c4 08             	add    $0x8,%esp
  801aac:	50                   	push   %eax
  801aad:	6a 00                	push   $0x0
  801aaf:	e8 09 f2 ff ff       	call   800cbd <sys_page_unmap>
}
  801ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    

00801ab9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	57                   	push   %edi
  801abd:	56                   	push   %esi
  801abe:	53                   	push   %ebx
  801abf:	83 ec 1c             	sub    $0x1c,%esp
  801ac2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ac5:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ac7:	a1 04 40 80 00       	mov    0x804004,%eax
  801acc:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801acf:	83 ec 0c             	sub    $0xc,%esp
  801ad2:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad5:	e8 e0 04 00 00       	call   801fba <pageref>
  801ada:	89 c3                	mov    %eax,%ebx
  801adc:	89 3c 24             	mov    %edi,(%esp)
  801adf:	e8 d6 04 00 00       	call   801fba <pageref>
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	39 c3                	cmp    %eax,%ebx
  801ae9:	0f 94 c1             	sete   %cl
  801aec:	0f b6 c9             	movzbl %cl,%ecx
  801aef:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801af2:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801af8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801afb:	39 ce                	cmp    %ecx,%esi
  801afd:	74 1b                	je     801b1a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aff:	39 c3                	cmp    %eax,%ebx
  801b01:	75 c4                	jne    801ac7 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b03:	8b 42 58             	mov    0x58(%edx),%eax
  801b06:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b09:	50                   	push   %eax
  801b0a:	56                   	push   %esi
  801b0b:	68 e6 27 80 00       	push   $0x8027e6
  801b10:	e8 1c e7 ff ff       	call   800231 <cprintf>
  801b15:	83 c4 10             	add    $0x10,%esp
  801b18:	eb ad                	jmp    801ac7 <_pipeisclosed+0xe>
	}
}
  801b1a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5f                   	pop    %edi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	57                   	push   %edi
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 28             	sub    $0x28,%esp
  801b2e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b31:	56                   	push   %esi
  801b32:	e8 09 f7 ff ff       	call   801240 <fd2data>
  801b37:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b41:	eb 4b                	jmp    801b8e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b43:	89 da                	mov    %ebx,%edx
  801b45:	89 f0                	mov    %esi,%eax
  801b47:	e8 6d ff ff ff       	call   801ab9 <_pipeisclosed>
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	75 48                	jne    801b98 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b50:	e8 c4 f0 ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b55:	8b 43 04             	mov    0x4(%ebx),%eax
  801b58:	8b 0b                	mov    (%ebx),%ecx
  801b5a:	8d 51 20             	lea    0x20(%ecx),%edx
  801b5d:	39 d0                	cmp    %edx,%eax
  801b5f:	73 e2                	jae    801b43 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b64:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b68:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b6b:	89 c2                	mov    %eax,%edx
  801b6d:	c1 fa 1f             	sar    $0x1f,%edx
  801b70:	89 d1                	mov    %edx,%ecx
  801b72:	c1 e9 1b             	shr    $0x1b,%ecx
  801b75:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b78:	83 e2 1f             	and    $0x1f,%edx
  801b7b:	29 ca                	sub    %ecx,%edx
  801b7d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b81:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b85:	83 c0 01             	add    $0x1,%eax
  801b88:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8b:	83 c7 01             	add    $0x1,%edi
  801b8e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b91:	75 c2                	jne    801b55 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b93:	8b 45 10             	mov    0x10(%ebp),%eax
  801b96:	eb 05                	jmp    801b9d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b98:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	57                   	push   %edi
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	83 ec 18             	sub    $0x18,%esp
  801bae:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bb1:	57                   	push   %edi
  801bb2:	e8 89 f6 ff ff       	call   801240 <fd2data>
  801bb7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc1:	eb 3d                	jmp    801c00 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bc3:	85 db                	test   %ebx,%ebx
  801bc5:	74 04                	je     801bcb <devpipe_read+0x26>
				return i;
  801bc7:	89 d8                	mov    %ebx,%eax
  801bc9:	eb 44                	jmp    801c0f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bcb:	89 f2                	mov    %esi,%edx
  801bcd:	89 f8                	mov    %edi,%eax
  801bcf:	e8 e5 fe ff ff       	call   801ab9 <_pipeisclosed>
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	75 32                	jne    801c0a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bd8:	e8 3c f0 ff ff       	call   800c19 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bdd:	8b 06                	mov    (%esi),%eax
  801bdf:	3b 46 04             	cmp    0x4(%esi),%eax
  801be2:	74 df                	je     801bc3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801be4:	99                   	cltd   
  801be5:	c1 ea 1b             	shr    $0x1b,%edx
  801be8:	01 d0                	add    %edx,%eax
  801bea:	83 e0 1f             	and    $0x1f,%eax
  801bed:	29 d0                	sub    %edx,%eax
  801bef:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bfa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfd:	83 c3 01             	add    $0x1,%ebx
  801c00:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c03:	75 d8                	jne    801bdd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c05:	8b 45 10             	mov    0x10(%ebp),%eax
  801c08:	eb 05                	jmp    801c0f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
  801c1c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c22:	50                   	push   %eax
  801c23:	e8 2f f6 ff ff       	call   801257 <fd_alloc>
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	89 c2                	mov    %eax,%edx
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 2c 01 00 00    	js     801d61 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c35:	83 ec 04             	sub    $0x4,%esp
  801c38:	68 07 04 00 00       	push   $0x407
  801c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c40:	6a 00                	push   $0x0
  801c42:	e8 f1 ef ff ff       	call   800c38 <sys_page_alloc>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 0d 01 00 00    	js     801d61 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c54:	83 ec 0c             	sub    $0xc,%esp
  801c57:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c5a:	50                   	push   %eax
  801c5b:	e8 f7 f5 ff ff       	call   801257 <fd_alloc>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	0f 88 e2 00 00 00    	js     801d4f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6d:	83 ec 04             	sub    $0x4,%esp
  801c70:	68 07 04 00 00       	push   $0x407
  801c75:	ff 75 f0             	pushl  -0x10(%ebp)
  801c78:	6a 00                	push   $0x0
  801c7a:	e8 b9 ef ff ff       	call   800c38 <sys_page_alloc>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	85 c0                	test   %eax,%eax
  801c86:	0f 88 c3 00 00 00    	js     801d4f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c8c:	83 ec 0c             	sub    $0xc,%esp
  801c8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c92:	e8 a9 f5 ff ff       	call   801240 <fd2data>
  801c97:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c99:	83 c4 0c             	add    $0xc,%esp
  801c9c:	68 07 04 00 00       	push   $0x407
  801ca1:	50                   	push   %eax
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 8f ef ff ff       	call   800c38 <sys_page_alloc>
  801ca9:	89 c3                	mov    %eax,%ebx
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	0f 88 89 00 00 00    	js     801d3f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cbc:	e8 7f f5 ff ff       	call   801240 <fd2data>
  801cc1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cc8:	50                   	push   %eax
  801cc9:	6a 00                	push   $0x0
  801ccb:	56                   	push   %esi
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 a8 ef ff ff       	call   800c7b <sys_page_map>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	83 c4 20             	add    $0x20,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	78 55                	js     801d31 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cdc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cf1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cff:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d06:	83 ec 0c             	sub    $0xc,%esp
  801d09:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0c:	e8 1f f5 ff ff       	call   801230 <fd2num>
  801d11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d14:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d16:	83 c4 04             	add    $0x4,%esp
  801d19:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1c:	e8 0f f5 ff ff       	call   801230 <fd2num>
  801d21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d24:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2f:	eb 30                	jmp    801d61 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d31:	83 ec 08             	sub    $0x8,%esp
  801d34:	56                   	push   %esi
  801d35:	6a 00                	push   $0x0
  801d37:	e8 81 ef ff ff       	call   800cbd <sys_page_unmap>
  801d3c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d3f:	83 ec 08             	sub    $0x8,%esp
  801d42:	ff 75 f0             	pushl  -0x10(%ebp)
  801d45:	6a 00                	push   $0x0
  801d47:	e8 71 ef ff ff       	call   800cbd <sys_page_unmap>
  801d4c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d4f:	83 ec 08             	sub    $0x8,%esp
  801d52:	ff 75 f4             	pushl  -0xc(%ebp)
  801d55:	6a 00                	push   $0x0
  801d57:	e8 61 ef ff ff       	call   800cbd <sys_page_unmap>
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d61:	89 d0                	mov    %edx,%eax
  801d63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d73:	50                   	push   %eax
  801d74:	ff 75 08             	pushl  0x8(%ebp)
  801d77:	e8 2a f5 ff ff       	call   8012a6 <fd_lookup>
  801d7c:	83 c4 10             	add    $0x10,%esp
  801d7f:	85 c0                	test   %eax,%eax
  801d81:	78 18                	js     801d9b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	ff 75 f4             	pushl  -0xc(%ebp)
  801d89:	e8 b2 f4 ff ff       	call   801240 <fd2data>
	return _pipeisclosed(fd, p);
  801d8e:	89 c2                	mov    %eax,%edx
  801d90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d93:	e8 21 fd ff ff       	call   801ab9 <_pipeisclosed>
  801d98:	83 c4 10             	add    $0x10,%esp
}
  801d9b:	c9                   	leave  
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
  801dad:	68 fe 27 80 00       	push   $0x8027fe
  801db2:	ff 75 0c             	pushl  0xc(%ebp)
  801db5:	e8 7b ea ff ff       	call   800835 <strcpy>
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
  801df3:	e8 cf eb ff ff       	call   8009c7 <memmove>
		sys_cputs(buf, m);
  801df8:	83 c4 08             	add    $0x8,%esp
  801dfb:	53                   	push   %ebx
  801dfc:	57                   	push   %edi
  801dfd:	e8 7a ed ff ff       	call   800b7c <sys_cputs>
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
  801e29:	e8 eb ed ff ff       	call   800c19 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e2e:	e8 67 ed ff ff       	call   800b9a <sys_cgetc>
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
  801e65:	e8 12 ed ff ff       	call   800b7c <sys_cputs>
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
  801e7d:	e8 8a f6 ff ff       	call   80150c <read>
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
  801ea7:	e8 fa f3 ff ff       	call   8012a6 <fd_lookup>
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
  801ed0:	e8 82 f3 ff ff       	call   801257 <fd_alloc>
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
  801eeb:	e8 48 ed ff ff       	call   800c38 <sys_page_alloc>
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
  801f12:	e8 19 f3 ff ff       	call   801230 <fd2num>
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
  801f27:	e8 ce ec ff ff       	call   800bfa <sys_getenvid>
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
  801f42:	e8 f1 ec ff ff       	call   800c38 <sys_page_alloc>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	79 12                	jns    801f60 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801f4e:	50                   	push   %eax
  801f4f:	68 0a 28 80 00       	push   $0x80280a
  801f54:	6a 24                	push   $0x24
  801f56:	68 23 28 80 00       	push   $0x802823
  801f5b:	e8 f8 e1 ff ff       	call   800158 <_panic>
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
  801f71:	e8 0d ee ff ff       	call   800d83 <sys_env_set_pgfault_upcall>
  801f76:	83 c4 10             	add    $0x10,%esp
  801f79:	85 c0                	test   %eax,%eax
  801f7b:	79 12                	jns    801f8f <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801f7d:	50                   	push   %eax
  801f7e:	68 0a 28 80 00       	push   $0x80280a
  801f83:	6a 2e                	push   $0x2e
  801f85:	68 23 28 80 00       	push   $0x802823
  801f8a:	e8 c9 e1 ff ff       	call   800158 <_panic>
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

00801fba <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc0:	89 d0                	mov    %edx,%eax
  801fc2:	c1 e8 16             	shr    $0x16,%eax
  801fc5:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fcc:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd1:	f6 c1 01             	test   $0x1,%cl
  801fd4:	74 1d                	je     801ff3 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801fd6:	c1 ea 0c             	shr    $0xc,%edx
  801fd9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fe0:	f6 c2 01             	test   $0x1,%dl
  801fe3:	74 0e                	je     801ff3 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fe5:	c1 ea 0c             	shr    $0xc,%edx
  801fe8:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fef:	ef 
  801ff0:	0f b7 c0             	movzwl %ax,%eax
}
  801ff3:	5d                   	pop    %ebp
  801ff4:	c3                   	ret    
  801ff5:	66 90                	xchg   %ax,%ax
  801ff7:	66 90                	xchg   %ax,%ax
  801ff9:	66 90                	xchg   %ax,%ax
  801ffb:	66 90                	xchg   %ax,%ax
  801ffd:	66 90                	xchg   %ax,%ax
  801fff:	90                   	nop

00802000 <__udivdi3>:
  802000:	55                   	push   %ebp
  802001:	57                   	push   %edi
  802002:	56                   	push   %esi
  802003:	53                   	push   %ebx
  802004:	83 ec 1c             	sub    $0x1c,%esp
  802007:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80200b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80200f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802013:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802017:	85 f6                	test   %esi,%esi
  802019:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80201d:	89 ca                	mov    %ecx,%edx
  80201f:	89 f8                	mov    %edi,%eax
  802021:	75 3d                	jne    802060 <__udivdi3+0x60>
  802023:	39 cf                	cmp    %ecx,%edi
  802025:	0f 87 c5 00 00 00    	ja     8020f0 <__udivdi3+0xf0>
  80202b:	85 ff                	test   %edi,%edi
  80202d:	89 fd                	mov    %edi,%ebp
  80202f:	75 0b                	jne    80203c <__udivdi3+0x3c>
  802031:	b8 01 00 00 00       	mov    $0x1,%eax
  802036:	31 d2                	xor    %edx,%edx
  802038:	f7 f7                	div    %edi
  80203a:	89 c5                	mov    %eax,%ebp
  80203c:	89 c8                	mov    %ecx,%eax
  80203e:	31 d2                	xor    %edx,%edx
  802040:	f7 f5                	div    %ebp
  802042:	89 c1                	mov    %eax,%ecx
  802044:	89 d8                	mov    %ebx,%eax
  802046:	89 cf                	mov    %ecx,%edi
  802048:	f7 f5                	div    %ebp
  80204a:	89 c3                	mov    %eax,%ebx
  80204c:	89 d8                	mov    %ebx,%eax
  80204e:	89 fa                	mov    %edi,%edx
  802050:	83 c4 1c             	add    $0x1c,%esp
  802053:	5b                   	pop    %ebx
  802054:	5e                   	pop    %esi
  802055:	5f                   	pop    %edi
  802056:	5d                   	pop    %ebp
  802057:	c3                   	ret    
  802058:	90                   	nop
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	39 ce                	cmp    %ecx,%esi
  802062:	77 74                	ja     8020d8 <__udivdi3+0xd8>
  802064:	0f bd fe             	bsr    %esi,%edi
  802067:	83 f7 1f             	xor    $0x1f,%edi
  80206a:	0f 84 98 00 00 00    	je     802108 <__udivdi3+0x108>
  802070:	bb 20 00 00 00       	mov    $0x20,%ebx
  802075:	89 f9                	mov    %edi,%ecx
  802077:	89 c5                	mov    %eax,%ebp
  802079:	29 fb                	sub    %edi,%ebx
  80207b:	d3 e6                	shl    %cl,%esi
  80207d:	89 d9                	mov    %ebx,%ecx
  80207f:	d3 ed                	shr    %cl,%ebp
  802081:	89 f9                	mov    %edi,%ecx
  802083:	d3 e0                	shl    %cl,%eax
  802085:	09 ee                	or     %ebp,%esi
  802087:	89 d9                	mov    %ebx,%ecx
  802089:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80208d:	89 d5                	mov    %edx,%ebp
  80208f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802093:	d3 ed                	shr    %cl,%ebp
  802095:	89 f9                	mov    %edi,%ecx
  802097:	d3 e2                	shl    %cl,%edx
  802099:	89 d9                	mov    %ebx,%ecx
  80209b:	d3 e8                	shr    %cl,%eax
  80209d:	09 c2                	or     %eax,%edx
  80209f:	89 d0                	mov    %edx,%eax
  8020a1:	89 ea                	mov    %ebp,%edx
  8020a3:	f7 f6                	div    %esi
  8020a5:	89 d5                	mov    %edx,%ebp
  8020a7:	89 c3                	mov    %eax,%ebx
  8020a9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ad:	39 d5                	cmp    %edx,%ebp
  8020af:	72 10                	jb     8020c1 <__udivdi3+0xc1>
  8020b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	d3 e6                	shl    %cl,%esi
  8020b9:	39 c6                	cmp    %eax,%esi
  8020bb:	73 07                	jae    8020c4 <__udivdi3+0xc4>
  8020bd:	39 d5                	cmp    %edx,%ebp
  8020bf:	75 03                	jne    8020c4 <__udivdi3+0xc4>
  8020c1:	83 eb 01             	sub    $0x1,%ebx
  8020c4:	31 ff                	xor    %edi,%edi
  8020c6:	89 d8                	mov    %ebx,%eax
  8020c8:	89 fa                	mov    %edi,%edx
  8020ca:	83 c4 1c             	add    $0x1c,%esp
  8020cd:	5b                   	pop    %ebx
  8020ce:	5e                   	pop    %esi
  8020cf:	5f                   	pop    %edi
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    
  8020d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020d8:	31 ff                	xor    %edi,%edi
  8020da:	31 db                	xor    %ebx,%ebx
  8020dc:	89 d8                	mov    %ebx,%eax
  8020de:	89 fa                	mov    %edi,%edx
  8020e0:	83 c4 1c             	add    $0x1c,%esp
  8020e3:	5b                   	pop    %ebx
  8020e4:	5e                   	pop    %esi
  8020e5:	5f                   	pop    %edi
  8020e6:	5d                   	pop    %ebp
  8020e7:	c3                   	ret    
  8020e8:	90                   	nop
  8020e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020f0:	89 d8                	mov    %ebx,%eax
  8020f2:	f7 f7                	div    %edi
  8020f4:	31 ff                	xor    %edi,%edi
  8020f6:	89 c3                	mov    %eax,%ebx
  8020f8:	89 d8                	mov    %ebx,%eax
  8020fa:	89 fa                	mov    %edi,%edx
  8020fc:	83 c4 1c             	add    $0x1c,%esp
  8020ff:	5b                   	pop    %ebx
  802100:	5e                   	pop    %esi
  802101:	5f                   	pop    %edi
  802102:	5d                   	pop    %ebp
  802103:	c3                   	ret    
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	39 ce                	cmp    %ecx,%esi
  80210a:	72 0c                	jb     802118 <__udivdi3+0x118>
  80210c:	31 db                	xor    %ebx,%ebx
  80210e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802112:	0f 87 34 ff ff ff    	ja     80204c <__udivdi3+0x4c>
  802118:	bb 01 00 00 00       	mov    $0x1,%ebx
  80211d:	e9 2a ff ff ff       	jmp    80204c <__udivdi3+0x4c>
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	55                   	push   %ebp
  802131:	57                   	push   %edi
  802132:	56                   	push   %esi
  802133:	53                   	push   %ebx
  802134:	83 ec 1c             	sub    $0x1c,%esp
  802137:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80213b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80213f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802143:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802147:	85 d2                	test   %edx,%edx
  802149:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80214d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802151:	89 f3                	mov    %esi,%ebx
  802153:	89 3c 24             	mov    %edi,(%esp)
  802156:	89 74 24 04          	mov    %esi,0x4(%esp)
  80215a:	75 1c                	jne    802178 <__umoddi3+0x48>
  80215c:	39 f7                	cmp    %esi,%edi
  80215e:	76 50                	jbe    8021b0 <__umoddi3+0x80>
  802160:	89 c8                	mov    %ecx,%eax
  802162:	89 f2                	mov    %esi,%edx
  802164:	f7 f7                	div    %edi
  802166:	89 d0                	mov    %edx,%eax
  802168:	31 d2                	xor    %edx,%edx
  80216a:	83 c4 1c             	add    $0x1c,%esp
  80216d:	5b                   	pop    %ebx
  80216e:	5e                   	pop    %esi
  80216f:	5f                   	pop    %edi
  802170:	5d                   	pop    %ebp
  802171:	c3                   	ret    
  802172:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802178:	39 f2                	cmp    %esi,%edx
  80217a:	89 d0                	mov    %edx,%eax
  80217c:	77 52                	ja     8021d0 <__umoddi3+0xa0>
  80217e:	0f bd ea             	bsr    %edx,%ebp
  802181:	83 f5 1f             	xor    $0x1f,%ebp
  802184:	75 5a                	jne    8021e0 <__umoddi3+0xb0>
  802186:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80218a:	0f 82 e0 00 00 00    	jb     802270 <__umoddi3+0x140>
  802190:	39 0c 24             	cmp    %ecx,(%esp)
  802193:	0f 86 d7 00 00 00    	jbe    802270 <__umoddi3+0x140>
  802199:	8b 44 24 08          	mov    0x8(%esp),%eax
  80219d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	85 ff                	test   %edi,%edi
  8021b2:	89 fd                	mov    %edi,%ebp
  8021b4:	75 0b                	jne    8021c1 <__umoddi3+0x91>
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f7                	div    %edi
  8021bf:	89 c5                	mov    %eax,%ebp
  8021c1:	89 f0                	mov    %esi,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	f7 f5                	div    %ebp
  8021c7:	89 c8                	mov    %ecx,%eax
  8021c9:	f7 f5                	div    %ebp
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	eb 99                	jmp    802168 <__umoddi3+0x38>
  8021cf:	90                   	nop
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	83 c4 1c             	add    $0x1c,%esp
  8021d7:	5b                   	pop    %ebx
  8021d8:	5e                   	pop    %esi
  8021d9:	5f                   	pop    %edi
  8021da:	5d                   	pop    %ebp
  8021db:	c3                   	ret    
  8021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	8b 34 24             	mov    (%esp),%esi
  8021e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021e8:	89 e9                	mov    %ebp,%ecx
  8021ea:	29 ef                	sub    %ebp,%edi
  8021ec:	d3 e0                	shl    %cl,%eax
  8021ee:	89 f9                	mov    %edi,%ecx
  8021f0:	89 f2                	mov    %esi,%edx
  8021f2:	d3 ea                	shr    %cl,%edx
  8021f4:	89 e9                	mov    %ebp,%ecx
  8021f6:	09 c2                	or     %eax,%edx
  8021f8:	89 d8                	mov    %ebx,%eax
  8021fa:	89 14 24             	mov    %edx,(%esp)
  8021fd:	89 f2                	mov    %esi,%edx
  8021ff:	d3 e2                	shl    %cl,%edx
  802201:	89 f9                	mov    %edi,%ecx
  802203:	89 54 24 04          	mov    %edx,0x4(%esp)
  802207:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80220b:	d3 e8                	shr    %cl,%eax
  80220d:	89 e9                	mov    %ebp,%ecx
  80220f:	89 c6                	mov    %eax,%esi
  802211:	d3 e3                	shl    %cl,%ebx
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 d0                	mov    %edx,%eax
  802217:	d3 e8                	shr    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	09 d8                	or     %ebx,%eax
  80221d:	89 d3                	mov    %edx,%ebx
  80221f:	89 f2                	mov    %esi,%edx
  802221:	f7 34 24             	divl   (%esp)
  802224:	89 d6                	mov    %edx,%esi
  802226:	d3 e3                	shl    %cl,%ebx
  802228:	f7 64 24 04          	mull   0x4(%esp)
  80222c:	39 d6                	cmp    %edx,%esi
  80222e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802232:	89 d1                	mov    %edx,%ecx
  802234:	89 c3                	mov    %eax,%ebx
  802236:	72 08                	jb     802240 <__umoddi3+0x110>
  802238:	75 11                	jne    80224b <__umoddi3+0x11b>
  80223a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80223e:	73 0b                	jae    80224b <__umoddi3+0x11b>
  802240:	2b 44 24 04          	sub    0x4(%esp),%eax
  802244:	1b 14 24             	sbb    (%esp),%edx
  802247:	89 d1                	mov    %edx,%ecx
  802249:	89 c3                	mov    %eax,%ebx
  80224b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80224f:	29 da                	sub    %ebx,%edx
  802251:	19 ce                	sbb    %ecx,%esi
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 f0                	mov    %esi,%eax
  802257:	d3 e0                	shl    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	d3 ea                	shr    %cl,%edx
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	d3 ee                	shr    %cl,%esi
  802261:	09 d0                	or     %edx,%eax
  802263:	89 f2                	mov    %esi,%edx
  802265:	83 c4 1c             	add    $0x1c,%esp
  802268:	5b                   	pop    %ebx
  802269:	5e                   	pop    %esi
  80226a:	5f                   	pop    %edi
  80226b:	5d                   	pop    %ebp
  80226c:	c3                   	ret    
  80226d:	8d 76 00             	lea    0x0(%esi),%esi
  802270:	29 f9                	sub    %edi,%ecx
  802272:	19 d6                	sbb    %edx,%esi
  802274:	89 74 24 04          	mov    %esi,0x4(%esp)
  802278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80227c:	e9 18 ff ff ff       	jmp    802199 <__umoddi3+0x69>
