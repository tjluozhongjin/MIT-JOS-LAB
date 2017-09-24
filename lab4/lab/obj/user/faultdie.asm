
obj/user/faultdie:     file format elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 a0 10 80 00       	push   $0x8010a0
  80004a:	e8 1c 01 00 00       	call   80016b <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 e0 0a 00 00       	call   800b34 <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 97 0a 00 00       	call   800af3 <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 b0 0c 00 00       	call   800d21 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 a4 0a 00 00       	call   800b34 <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

	// exit gracefully
	exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000cc:	6a 00                	push   $0x0
  8000ce:	e8 20 0a 00 00       	call   800af3 <sys_env_destroy>
}
  8000d3:	83 c4 10             	add    $0x10,%esp
  8000d6:	c9                   	leave  
  8000d7:	c3                   	ret    

008000d8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000d8:	55                   	push   %ebp
  8000d9:	89 e5                	mov    %esp,%ebp
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 04             	sub    $0x4,%esp
  8000df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000e2:	8b 13                	mov    (%ebx),%edx
  8000e4:	8d 42 01             	lea    0x1(%edx),%eax
  8000e7:	89 03                	mov    %eax,(%ebx)
  8000e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ec:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000f5:	75 1a                	jne    800111 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 ff 00 00 00       	push   $0xff
  8000ff:	8d 43 08             	lea    0x8(%ebx),%eax
  800102:	50                   	push   %eax
  800103:	e8 ae 09 00 00       	call   800ab6 <sys_cputs>
		b->idx = 0;
  800108:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80010e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800111:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800115:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800118:	c9                   	leave  
  800119:	c3                   	ret    

0080011a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80011a:	55                   	push   %ebp
  80011b:	89 e5                	mov    %esp,%ebp
  80011d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800123:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80012a:	00 00 00 
	b.cnt = 0;
  80012d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800134:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800137:	ff 75 0c             	pushl  0xc(%ebp)
  80013a:	ff 75 08             	pushl  0x8(%ebp)
  80013d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	68 d8 00 80 00       	push   $0x8000d8
  800149:	e8 1a 01 00 00       	call   800268 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014e:	83 c4 08             	add    $0x8,%esp
  800151:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800157:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015d:	50                   	push   %eax
  80015e:	e8 53 09 00 00       	call   800ab6 <sys_cputs>

	return b.cnt;
}
  800163:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800169:	c9                   	leave  
  80016a:	c3                   	ret    

0080016b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800171:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800174:	50                   	push   %eax
  800175:	ff 75 08             	pushl  0x8(%ebp)
  800178:	e8 9d ff ff ff       	call   80011a <vcprintf>
	va_end(ap);

	return cnt;
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017f:	55                   	push   %ebp
  800180:	89 e5                	mov    %esp,%ebp
  800182:	57                   	push   %edi
  800183:	56                   	push   %esi
  800184:	53                   	push   %ebx
  800185:	83 ec 1c             	sub    $0x1c,%esp
  800188:	89 c7                	mov    %eax,%edi
  80018a:	89 d6                	mov    %edx,%esi
  80018c:	8b 45 08             	mov    0x8(%ebp),%eax
  80018f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800192:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800195:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800198:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80019b:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001a3:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001a6:	39 d3                	cmp    %edx,%ebx
  8001a8:	72 05                	jb     8001af <printnum+0x30>
  8001aa:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ad:	77 45                	ja     8001f4 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001af:	83 ec 0c             	sub    $0xc,%esp
  8001b2:	ff 75 18             	pushl  0x18(%ebp)
  8001b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8001b8:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001bb:	53                   	push   %ebx
  8001bc:	ff 75 10             	pushl  0x10(%ebp)
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c8:	ff 75 dc             	pushl  -0x24(%ebp)
  8001cb:	ff 75 d8             	pushl  -0x28(%ebp)
  8001ce:	e8 3d 0c 00 00       	call   800e10 <__udivdi3>
  8001d3:	83 c4 18             	add    $0x18,%esp
  8001d6:	52                   	push   %edx
  8001d7:	50                   	push   %eax
  8001d8:	89 f2                	mov    %esi,%edx
  8001da:	89 f8                	mov    %edi,%eax
  8001dc:	e8 9e ff ff ff       	call   80017f <printnum>
  8001e1:	83 c4 20             	add    $0x20,%esp
  8001e4:	eb 18                	jmp    8001fe <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	ff 75 18             	pushl  0x18(%ebp)
  8001ed:	ff d7                	call   *%edi
  8001ef:	83 c4 10             	add    $0x10,%esp
  8001f2:	eb 03                	jmp    8001f7 <printnum+0x78>
  8001f4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	85 db                	test   %ebx,%ebx
  8001fc:	7f e8                	jg     8001e6 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	56                   	push   %esi
  800202:	83 ec 04             	sub    $0x4,%esp
  800205:	ff 75 e4             	pushl  -0x1c(%ebp)
  800208:	ff 75 e0             	pushl  -0x20(%ebp)
  80020b:	ff 75 dc             	pushl  -0x24(%ebp)
  80020e:	ff 75 d8             	pushl  -0x28(%ebp)
  800211:	e8 2a 0d 00 00       	call   800f40 <__umoddi3>
  800216:	83 c4 14             	add    $0x14,%esp
  800219:	0f be 80 c6 10 80 00 	movsbl 0x8010c6(%eax),%eax
  800220:	50                   	push   %eax
  800221:	ff d7                	call   *%edi
}
  800223:	83 c4 10             	add    $0x10,%esp
  800226:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800229:	5b                   	pop    %ebx
  80022a:	5e                   	pop    %esi
  80022b:	5f                   	pop    %edi
  80022c:	5d                   	pop    %ebp
  80022d:	c3                   	ret    

0080022e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80022e:	55                   	push   %ebp
  80022f:	89 e5                	mov    %esp,%ebp
  800231:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800234:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800238:	8b 10                	mov    (%eax),%edx
  80023a:	3b 50 04             	cmp    0x4(%eax),%edx
  80023d:	73 0a                	jae    800249 <sprintputch+0x1b>
		*b->buf++ = ch;
  80023f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800242:	89 08                	mov    %ecx,(%eax)
  800244:	8b 45 08             	mov    0x8(%ebp),%eax
  800247:	88 02                	mov    %al,(%edx)
}
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    

0080024b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800251:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800254:	50                   	push   %eax
  800255:	ff 75 10             	pushl  0x10(%ebp)
  800258:	ff 75 0c             	pushl  0xc(%ebp)
  80025b:	ff 75 08             	pushl  0x8(%ebp)
  80025e:	e8 05 00 00 00       	call   800268 <vprintfmt>
	va_end(ap);
}
  800263:	83 c4 10             	add    $0x10,%esp
  800266:	c9                   	leave  
  800267:	c3                   	ret    

00800268 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800268:	55                   	push   %ebp
  800269:	89 e5                	mov    %esp,%ebp
  80026b:	57                   	push   %edi
  80026c:	56                   	push   %esi
  80026d:	53                   	push   %ebx
  80026e:	83 ec 2c             	sub    $0x2c,%esp
  800271:	8b 75 08             	mov    0x8(%ebp),%esi
  800274:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800277:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027a:	eb 12                	jmp    80028e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80027c:	85 c0                	test   %eax,%eax
  80027e:	0f 84 42 04 00 00    	je     8006c6 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800284:	83 ec 08             	sub    $0x8,%esp
  800287:	53                   	push   %ebx
  800288:	50                   	push   %eax
  800289:	ff d6                	call   *%esi
  80028b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80028e:	83 c7 01             	add    $0x1,%edi
  800291:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800295:	83 f8 25             	cmp    $0x25,%eax
  800298:	75 e2                	jne    80027c <vprintfmt+0x14>
  80029a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80029e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002a5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002ac:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002b8:	eb 07                	jmp    8002c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002bd:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c1:	8d 47 01             	lea    0x1(%edi),%eax
  8002c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002c7:	0f b6 07             	movzbl (%edi),%eax
  8002ca:	0f b6 d0             	movzbl %al,%edx
  8002cd:	83 e8 23             	sub    $0x23,%eax
  8002d0:	3c 55                	cmp    $0x55,%al
  8002d2:	0f 87 d3 03 00 00    	ja     8006ab <vprintfmt+0x443>
  8002d8:	0f b6 c0             	movzbl %al,%eax
  8002db:	ff 24 85 80 11 80 00 	jmp    *0x801180(,%eax,4)
  8002e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002e5:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002e9:	eb d6                	jmp    8002c1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8002f3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002f6:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002f9:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002fd:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800300:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800303:	83 f9 09             	cmp    $0x9,%ecx
  800306:	77 3f                	ja     800347 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800308:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80030b:	eb e9                	jmp    8002f6 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80030d:	8b 45 14             	mov    0x14(%ebp),%eax
  800310:	8b 00                	mov    (%eax),%eax
  800312:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8d 40 04             	lea    0x4(%eax),%eax
  80031b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800321:	eb 2a                	jmp    80034d <vprintfmt+0xe5>
  800323:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800326:	85 c0                	test   %eax,%eax
  800328:	ba 00 00 00 00       	mov    $0x0,%edx
  80032d:	0f 49 d0             	cmovns %eax,%edx
  800330:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800333:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800336:	eb 89                	jmp    8002c1 <vprintfmt+0x59>
  800338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80033b:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800342:	e9 7a ff ff ff       	jmp    8002c1 <vprintfmt+0x59>
  800347:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80034a:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80034d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800351:	0f 89 6a ff ff ff    	jns    8002c1 <vprintfmt+0x59>
				width = precision, precision = -1;
  800357:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80035a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80035d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800364:	e9 58 ff ff ff       	jmp    8002c1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800369:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80036f:	e9 4d ff ff ff       	jmp    8002c1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800374:	8b 45 14             	mov    0x14(%ebp),%eax
  800377:	8d 78 04             	lea    0x4(%eax),%edi
  80037a:	83 ec 08             	sub    $0x8,%esp
  80037d:	53                   	push   %ebx
  80037e:	ff 30                	pushl  (%eax)
  800380:	ff d6                	call   *%esi
			break;
  800382:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800385:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80038b:	e9 fe fe ff ff       	jmp    80028e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800390:	8b 45 14             	mov    0x14(%ebp),%eax
  800393:	8d 78 04             	lea    0x4(%eax),%edi
  800396:	8b 00                	mov    (%eax),%eax
  800398:	99                   	cltd   
  800399:	31 d0                	xor    %edx,%eax
  80039b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80039d:	83 f8 08             	cmp    $0x8,%eax
  8003a0:	7f 0b                	jg     8003ad <vprintfmt+0x145>
  8003a2:	8b 14 85 e0 12 80 00 	mov    0x8012e0(,%eax,4),%edx
  8003a9:	85 d2                	test   %edx,%edx
  8003ab:	75 1b                	jne    8003c8 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003ad:	50                   	push   %eax
  8003ae:	68 de 10 80 00       	push   $0x8010de
  8003b3:	53                   	push   %ebx
  8003b4:	56                   	push   %esi
  8003b5:	e8 91 fe ff ff       	call   80024b <printfmt>
  8003ba:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003bd:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003c3:	e9 c6 fe ff ff       	jmp    80028e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003c8:	52                   	push   %edx
  8003c9:	68 e7 10 80 00       	push   $0x8010e7
  8003ce:	53                   	push   %ebx
  8003cf:	56                   	push   %esi
  8003d0:	e8 76 fe ff ff       	call   80024b <printfmt>
  8003d5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d8:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003de:	e9 ab fe ff ff       	jmp    80028e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e6:	83 c0 04             	add    $0x4,%eax
  8003e9:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ef:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f1:	85 ff                	test   %edi,%edi
  8003f3:	b8 d7 10 80 00       	mov    $0x8010d7,%eax
  8003f8:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003ff:	0f 8e 94 00 00 00    	jle    800499 <vprintfmt+0x231>
  800405:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800409:	0f 84 98 00 00 00    	je     8004a7 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	ff 75 d0             	pushl  -0x30(%ebp)
  800415:	57                   	push   %edi
  800416:	e8 33 03 00 00       	call   80074e <strnlen>
  80041b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80041e:	29 c1                	sub    %eax,%ecx
  800420:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800423:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800426:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80042a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042d:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800430:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800432:	eb 0f                	jmp    800443 <vprintfmt+0x1db>
					putch(padc, putdat);
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	53                   	push   %ebx
  800438:	ff 75 e0             	pushl  -0x20(%ebp)
  80043b:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043d:	83 ef 01             	sub    $0x1,%edi
  800440:	83 c4 10             	add    $0x10,%esp
  800443:	85 ff                	test   %edi,%edi
  800445:	7f ed                	jg     800434 <vprintfmt+0x1cc>
  800447:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80044a:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80044d:	85 c9                	test   %ecx,%ecx
  80044f:	b8 00 00 00 00       	mov    $0x0,%eax
  800454:	0f 49 c1             	cmovns %ecx,%eax
  800457:	29 c1                	sub    %eax,%ecx
  800459:	89 75 08             	mov    %esi,0x8(%ebp)
  80045c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80045f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800462:	89 cb                	mov    %ecx,%ebx
  800464:	eb 4d                	jmp    8004b3 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800466:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80046a:	74 1b                	je     800487 <vprintfmt+0x21f>
  80046c:	0f be c0             	movsbl %al,%eax
  80046f:	83 e8 20             	sub    $0x20,%eax
  800472:	83 f8 5e             	cmp    $0x5e,%eax
  800475:	76 10                	jbe    800487 <vprintfmt+0x21f>
					putch('?', putdat);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 75 0c             	pushl  0xc(%ebp)
  80047d:	6a 3f                	push   $0x3f
  80047f:	ff 55 08             	call   *0x8(%ebp)
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	eb 0d                	jmp    800494 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	ff 75 0c             	pushl  0xc(%ebp)
  80048d:	52                   	push   %edx
  80048e:	ff 55 08             	call   *0x8(%ebp)
  800491:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800494:	83 eb 01             	sub    $0x1,%ebx
  800497:	eb 1a                	jmp    8004b3 <vprintfmt+0x24b>
  800499:	89 75 08             	mov    %esi,0x8(%ebp)
  80049c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a5:	eb 0c                	jmp    8004b3 <vprintfmt+0x24b>
  8004a7:	89 75 08             	mov    %esi,0x8(%ebp)
  8004aa:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ad:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b0:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004b3:	83 c7 01             	add    $0x1,%edi
  8004b6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ba:	0f be d0             	movsbl %al,%edx
  8004bd:	85 d2                	test   %edx,%edx
  8004bf:	74 23                	je     8004e4 <vprintfmt+0x27c>
  8004c1:	85 f6                	test   %esi,%esi
  8004c3:	78 a1                	js     800466 <vprintfmt+0x1fe>
  8004c5:	83 ee 01             	sub    $0x1,%esi
  8004c8:	79 9c                	jns    800466 <vprintfmt+0x1fe>
  8004ca:	89 df                	mov    %ebx,%edi
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d2:	eb 18                	jmp    8004ec <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	53                   	push   %ebx
  8004d8:	6a 20                	push   $0x20
  8004da:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004dc:	83 ef 01             	sub    $0x1,%edi
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	eb 08                	jmp    8004ec <vprintfmt+0x284>
  8004e4:	89 df                	mov    %ebx,%edi
  8004e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ec:	85 ff                	test   %edi,%edi
  8004ee:	7f e4                	jg     8004d4 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004f3:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004f9:	e9 90 fd ff ff       	jmp    80028e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004fe:	83 f9 01             	cmp    $0x1,%ecx
  800501:	7e 19                	jle    80051c <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800503:	8b 45 14             	mov    0x14(%ebp),%eax
  800506:	8b 50 04             	mov    0x4(%eax),%edx
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8d 40 08             	lea    0x8(%eax),%eax
  800517:	89 45 14             	mov    %eax,0x14(%ebp)
  80051a:	eb 38                	jmp    800554 <vprintfmt+0x2ec>
	else if (lflag)
  80051c:	85 c9                	test   %ecx,%ecx
  80051e:	74 1b                	je     80053b <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8b 00                	mov    (%eax),%eax
  800525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800528:	89 c1                	mov    %eax,%ecx
  80052a:	c1 f9 1f             	sar    $0x1f,%ecx
  80052d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 40 04             	lea    0x4(%eax),%eax
  800536:	89 45 14             	mov    %eax,0x14(%ebp)
  800539:	eb 19                	jmp    800554 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80053b:	8b 45 14             	mov    0x14(%ebp),%eax
  80053e:	8b 00                	mov    (%eax),%eax
  800540:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800543:	89 c1                	mov    %eax,%ecx
  800545:	c1 f9 1f             	sar    $0x1f,%ecx
  800548:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80054b:	8b 45 14             	mov    0x14(%ebp),%eax
  80054e:	8d 40 04             	lea    0x4(%eax),%eax
  800551:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800554:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800557:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80055a:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80055f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800563:	0f 89 0e 01 00 00    	jns    800677 <vprintfmt+0x40f>
				putch('-', putdat);
  800569:	83 ec 08             	sub    $0x8,%esp
  80056c:	53                   	push   %ebx
  80056d:	6a 2d                	push   $0x2d
  80056f:	ff d6                	call   *%esi
				num = -(long long) num;
  800571:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800574:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800577:	f7 da                	neg    %edx
  800579:	83 d1 00             	adc    $0x0,%ecx
  80057c:	f7 d9                	neg    %ecx
  80057e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800581:	b8 0a 00 00 00       	mov    $0xa,%eax
  800586:	e9 ec 00 00 00       	jmp    800677 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058b:	83 f9 01             	cmp    $0x1,%ecx
  80058e:	7e 18                	jle    8005a8 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8b 10                	mov    (%eax),%edx
  800595:	8b 48 04             	mov    0x4(%eax),%ecx
  800598:	8d 40 08             	lea    0x8(%eax),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80059e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a3:	e9 cf 00 00 00       	jmp    800677 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005a8:	85 c9                	test   %ecx,%ecx
  8005aa:	74 1a                	je     8005c6 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c1:	e9 b1 00 00 00       	jmp    800677 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8b 10                	mov    (%eax),%edx
  8005cb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d0:	8d 40 04             	lea    0x4(%eax),%eax
  8005d3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005d6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005db:	e9 97 00 00 00       	jmp    800677 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	53                   	push   %ebx
  8005e4:	6a 58                	push   $0x58
  8005e6:	ff d6                	call   *%esi
			putch('X', putdat);
  8005e8:	83 c4 08             	add    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	6a 58                	push   $0x58
  8005ee:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f0:	83 c4 08             	add    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 58                	push   $0x58
  8005f6:	ff d6                	call   *%esi
			break;
  8005f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005fe:	e9 8b fc ff ff       	jmp    80028e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	6a 30                	push   $0x30
  800609:	ff d6                	call   *%esi
			putch('x', putdat);
  80060b:	83 c4 08             	add    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 78                	push   $0x78
  800611:	ff d6                	call   *%esi
			num = (unsigned long long)
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8b 10                	mov    (%eax),%edx
  800618:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80061d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800620:	8d 40 04             	lea    0x4(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800626:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80062b:	eb 4a                	jmp    800677 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80062d:	83 f9 01             	cmp    $0x1,%ecx
  800630:	7e 15                	jle    800647 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 10                	mov    (%eax),%edx
  800637:	8b 48 04             	mov    0x4(%eax),%ecx
  80063a:	8d 40 08             	lea    0x8(%eax),%eax
  80063d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800640:	b8 10 00 00 00       	mov    $0x10,%eax
  800645:	eb 30                	jmp    800677 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800647:	85 c9                	test   %ecx,%ecx
  800649:	74 17                	je     800662 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  80064b:	8b 45 14             	mov    0x14(%ebp),%eax
  80064e:	8b 10                	mov    (%eax),%edx
  800650:	b9 00 00 00 00       	mov    $0x0,%ecx
  800655:	8d 40 04             	lea    0x4(%eax),%eax
  800658:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80065b:	b8 10 00 00 00       	mov    $0x10,%eax
  800660:	eb 15                	jmp    800677 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8b 10                	mov    (%eax),%edx
  800667:	b9 00 00 00 00       	mov    $0x0,%ecx
  80066c:	8d 40 04             	lea    0x4(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800672:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800677:	83 ec 0c             	sub    $0xc,%esp
  80067a:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80067e:	57                   	push   %edi
  80067f:	ff 75 e0             	pushl  -0x20(%ebp)
  800682:	50                   	push   %eax
  800683:	51                   	push   %ecx
  800684:	52                   	push   %edx
  800685:	89 da                	mov    %ebx,%edx
  800687:	89 f0                	mov    %esi,%eax
  800689:	e8 f1 fa ff ff       	call   80017f <printnum>
			break;
  80068e:	83 c4 20             	add    $0x20,%esp
  800691:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800694:	e9 f5 fb ff ff       	jmp    80028e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	53                   	push   %ebx
  80069d:	52                   	push   %edx
  80069e:	ff d6                	call   *%esi
			break;
  8006a0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006a3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006a6:	e9 e3 fb ff ff       	jmp    80028e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	6a 25                	push   $0x25
  8006b1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 03                	jmp    8006bb <vprintfmt+0x453>
  8006b8:	83 ef 01             	sub    $0x1,%edi
  8006bb:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006bf:	75 f7                	jne    8006b8 <vprintfmt+0x450>
  8006c1:	e9 c8 fb ff ff       	jmp    80028e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c9:	5b                   	pop    %ebx
  8006ca:	5e                   	pop    %esi
  8006cb:	5f                   	pop    %edi
  8006cc:	5d                   	pop    %ebp
  8006cd:	c3                   	ret    

008006ce <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	83 ec 18             	sub    $0x18,%esp
  8006d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	74 26                	je     800715 <vsnprintf+0x47>
  8006ef:	85 d2                	test   %edx,%edx
  8006f1:	7e 22                	jle    800715 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f3:	ff 75 14             	pushl  0x14(%ebp)
  8006f6:	ff 75 10             	pushl  0x10(%ebp)
  8006f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006fc:	50                   	push   %eax
  8006fd:	68 2e 02 80 00       	push   $0x80022e
  800702:	e8 61 fb ff ff       	call   800268 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800707:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80070a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb 05                	jmp    80071a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800715:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800722:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800725:	50                   	push   %eax
  800726:	ff 75 10             	pushl  0x10(%ebp)
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	ff 75 08             	pushl  0x8(%ebp)
  80072f:	e8 9a ff ff ff       	call   8006ce <vsnprintf>
	va_end(ap);

	return rc;
}
  800734:	c9                   	leave  
  800735:	c3                   	ret    

00800736 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80073c:	b8 00 00 00 00       	mov    $0x0,%eax
  800741:	eb 03                	jmp    800746 <strlen+0x10>
		n++;
  800743:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800746:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074a:	75 f7                	jne    800743 <strlen+0xd>
		n++;
	return n;
}
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800754:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800757:	ba 00 00 00 00       	mov    $0x0,%edx
  80075c:	eb 03                	jmp    800761 <strnlen+0x13>
		n++;
  80075e:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800761:	39 c2                	cmp    %eax,%edx
  800763:	74 08                	je     80076d <strnlen+0x1f>
  800765:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800769:	75 f3                	jne    80075e <strnlen+0x10>
  80076b:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80076d:	5d                   	pop    %ebp
  80076e:	c3                   	ret    

0080076f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076f:	55                   	push   %ebp
  800770:	89 e5                	mov    %esp,%ebp
  800772:	53                   	push   %ebx
  800773:	8b 45 08             	mov    0x8(%ebp),%eax
  800776:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800779:	89 c2                	mov    %eax,%edx
  80077b:	83 c2 01             	add    $0x1,%edx
  80077e:	83 c1 01             	add    $0x1,%ecx
  800781:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800785:	88 5a ff             	mov    %bl,-0x1(%edx)
  800788:	84 db                	test   %bl,%bl
  80078a:	75 ef                	jne    80077b <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80078c:	5b                   	pop    %ebx
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strcat>:

char *
strcat(char *dst, const char *src)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	53                   	push   %ebx
  800793:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800796:	53                   	push   %ebx
  800797:	e8 9a ff ff ff       	call   800736 <strlen>
  80079c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80079f:	ff 75 0c             	pushl  0xc(%ebp)
  8007a2:	01 d8                	add    %ebx,%eax
  8007a4:	50                   	push   %eax
  8007a5:	e8 c5 ff ff ff       	call   80076f <strcpy>
	return dst;
}
  8007aa:	89 d8                	mov    %ebx,%eax
  8007ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007af:	c9                   	leave  
  8007b0:	c3                   	ret    

008007b1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b1:	55                   	push   %ebp
  8007b2:	89 e5                	mov    %esp,%ebp
  8007b4:	56                   	push   %esi
  8007b5:	53                   	push   %ebx
  8007b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bc:	89 f3                	mov    %esi,%ebx
  8007be:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c1:	89 f2                	mov    %esi,%edx
  8007c3:	eb 0f                	jmp    8007d4 <strncpy+0x23>
		*dst++ = *src;
  8007c5:	83 c2 01             	add    $0x1,%edx
  8007c8:	0f b6 01             	movzbl (%ecx),%eax
  8007cb:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ce:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d1:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007d4:	39 da                	cmp    %ebx,%edx
  8007d6:	75 ed                	jne    8007c5 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007d8:	89 f0                	mov    %esi,%eax
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    

008007de <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	56                   	push   %esi
  8007e2:	53                   	push   %ebx
  8007e3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007e9:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ec:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007ee:	85 d2                	test   %edx,%edx
  8007f0:	74 21                	je     800813 <strlcpy+0x35>
  8007f2:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f6:	89 f2                	mov    %esi,%edx
  8007f8:	eb 09                	jmp    800803 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007fa:	83 c2 01             	add    $0x1,%edx
  8007fd:	83 c1 01             	add    $0x1,%ecx
  800800:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800803:	39 c2                	cmp    %eax,%edx
  800805:	74 09                	je     800810 <strlcpy+0x32>
  800807:	0f b6 19             	movzbl (%ecx),%ebx
  80080a:	84 db                	test   %bl,%bl
  80080c:	75 ec                	jne    8007fa <strlcpy+0x1c>
  80080e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800810:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800813:	29 f0                	sub    %esi,%eax
}
  800815:	5b                   	pop    %ebx
  800816:	5e                   	pop    %esi
  800817:	5d                   	pop    %ebp
  800818:	c3                   	ret    

00800819 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800822:	eb 06                	jmp    80082a <strcmp+0x11>
		p++, q++;
  800824:	83 c1 01             	add    $0x1,%ecx
  800827:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80082a:	0f b6 01             	movzbl (%ecx),%eax
  80082d:	84 c0                	test   %al,%al
  80082f:	74 04                	je     800835 <strcmp+0x1c>
  800831:	3a 02                	cmp    (%edx),%al
  800833:	74 ef                	je     800824 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800835:	0f b6 c0             	movzbl %al,%eax
  800838:	0f b6 12             	movzbl (%edx),%edx
  80083b:	29 d0                	sub    %edx,%eax
}
  80083d:	5d                   	pop    %ebp
  80083e:	c3                   	ret    

0080083f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
  800849:	89 c3                	mov    %eax,%ebx
  80084b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80084e:	eb 06                	jmp    800856 <strncmp+0x17>
		n--, p++, q++;
  800850:	83 c0 01             	add    $0x1,%eax
  800853:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800856:	39 d8                	cmp    %ebx,%eax
  800858:	74 15                	je     80086f <strncmp+0x30>
  80085a:	0f b6 08             	movzbl (%eax),%ecx
  80085d:	84 c9                	test   %cl,%cl
  80085f:	74 04                	je     800865 <strncmp+0x26>
  800861:	3a 0a                	cmp    (%edx),%cl
  800863:	74 eb                	je     800850 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800865:	0f b6 00             	movzbl (%eax),%eax
  800868:	0f b6 12             	movzbl (%edx),%edx
  80086b:	29 d0                	sub    %edx,%eax
  80086d:	eb 05                	jmp    800874 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  80086f:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800874:	5b                   	pop    %ebx
  800875:	5d                   	pop    %ebp
  800876:	c3                   	ret    

00800877 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800877:	55                   	push   %ebp
  800878:	89 e5                	mov    %esp,%ebp
  80087a:	8b 45 08             	mov    0x8(%ebp),%eax
  80087d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800881:	eb 07                	jmp    80088a <strchr+0x13>
		if (*s == c)
  800883:	38 ca                	cmp    %cl,%dl
  800885:	74 0f                	je     800896 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800887:	83 c0 01             	add    $0x1,%eax
  80088a:	0f b6 10             	movzbl (%eax),%edx
  80088d:	84 d2                	test   %dl,%dl
  80088f:	75 f2                	jne    800883 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800891:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800898:	55                   	push   %ebp
  800899:	89 e5                	mov    %esp,%ebp
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008a2:	eb 03                	jmp    8008a7 <strfind+0xf>
  8008a4:	83 c0 01             	add    $0x1,%eax
  8008a7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008aa:	38 ca                	cmp    %cl,%dl
  8008ac:	74 04                	je     8008b2 <strfind+0x1a>
  8008ae:	84 d2                	test   %dl,%dl
  8008b0:	75 f2                	jne    8008a4 <strfind+0xc>
			break;
	return (char *) s;
}
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	53                   	push   %ebx
  8008ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c0:	85 c9                	test   %ecx,%ecx
  8008c2:	74 36                	je     8008fa <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008ca:	75 28                	jne    8008f4 <memset+0x40>
  8008cc:	f6 c1 03             	test   $0x3,%cl
  8008cf:	75 23                	jne    8008f4 <memset+0x40>
		c &= 0xFF;
  8008d1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d5:	89 d3                	mov    %edx,%ebx
  8008d7:	c1 e3 08             	shl    $0x8,%ebx
  8008da:	89 d6                	mov    %edx,%esi
  8008dc:	c1 e6 18             	shl    $0x18,%esi
  8008df:	89 d0                	mov    %edx,%eax
  8008e1:	c1 e0 10             	shl    $0x10,%eax
  8008e4:	09 f0                	or     %esi,%eax
  8008e6:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008e8:	89 d8                	mov    %ebx,%eax
  8008ea:	09 d0                	or     %edx,%eax
  8008ec:	c1 e9 02             	shr    $0x2,%ecx
  8008ef:	fc                   	cld    
  8008f0:	f3 ab                	rep stos %eax,%es:(%edi)
  8008f2:	eb 06                	jmp    8008fa <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f7:	fc                   	cld    
  8008f8:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008fa:	89 f8                	mov    %edi,%eax
  8008fc:	5b                   	pop    %ebx
  8008fd:	5e                   	pop    %esi
  8008fe:	5f                   	pop    %edi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	57                   	push   %edi
  800905:	56                   	push   %esi
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	8b 75 0c             	mov    0xc(%ebp),%esi
  80090c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80090f:	39 c6                	cmp    %eax,%esi
  800911:	73 35                	jae    800948 <memmove+0x47>
  800913:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800916:	39 d0                	cmp    %edx,%eax
  800918:	73 2e                	jae    800948 <memmove+0x47>
		s += n;
		d += n;
  80091a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091d:	89 d6                	mov    %edx,%esi
  80091f:	09 fe                	or     %edi,%esi
  800921:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800927:	75 13                	jne    80093c <memmove+0x3b>
  800929:	f6 c1 03             	test   $0x3,%cl
  80092c:	75 0e                	jne    80093c <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80092e:	83 ef 04             	sub    $0x4,%edi
  800931:	8d 72 fc             	lea    -0x4(%edx),%esi
  800934:	c1 e9 02             	shr    $0x2,%ecx
  800937:	fd                   	std    
  800938:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80093a:	eb 09                	jmp    800945 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80093c:	83 ef 01             	sub    $0x1,%edi
  80093f:	8d 72 ff             	lea    -0x1(%edx),%esi
  800942:	fd                   	std    
  800943:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800945:	fc                   	cld    
  800946:	eb 1d                	jmp    800965 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800948:	89 f2                	mov    %esi,%edx
  80094a:	09 c2                	or     %eax,%edx
  80094c:	f6 c2 03             	test   $0x3,%dl
  80094f:	75 0f                	jne    800960 <memmove+0x5f>
  800951:	f6 c1 03             	test   $0x3,%cl
  800954:	75 0a                	jne    800960 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800956:	c1 e9 02             	shr    $0x2,%ecx
  800959:	89 c7                	mov    %eax,%edi
  80095b:	fc                   	cld    
  80095c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095e:	eb 05                	jmp    800965 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800960:	89 c7                	mov    %eax,%edi
  800962:	fc                   	cld    
  800963:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800965:	5e                   	pop    %esi
  800966:	5f                   	pop    %edi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    

00800969 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  80096c:	ff 75 10             	pushl  0x10(%ebp)
  80096f:	ff 75 0c             	pushl  0xc(%ebp)
  800972:	ff 75 08             	pushl  0x8(%ebp)
  800975:	e8 87 ff ff ff       	call   800901 <memmove>
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	56                   	push   %esi
  800980:	53                   	push   %ebx
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 55 0c             	mov    0xc(%ebp),%edx
  800987:	89 c6                	mov    %eax,%esi
  800989:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098c:	eb 1a                	jmp    8009a8 <memcmp+0x2c>
		if (*s1 != *s2)
  80098e:	0f b6 08             	movzbl (%eax),%ecx
  800991:	0f b6 1a             	movzbl (%edx),%ebx
  800994:	38 d9                	cmp    %bl,%cl
  800996:	74 0a                	je     8009a2 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800998:	0f b6 c1             	movzbl %cl,%eax
  80099b:	0f b6 db             	movzbl %bl,%ebx
  80099e:	29 d8                	sub    %ebx,%eax
  8009a0:	eb 0f                	jmp    8009b1 <memcmp+0x35>
		s1++, s2++;
  8009a2:	83 c0 01             	add    $0x1,%eax
  8009a5:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a8:	39 f0                	cmp    %esi,%eax
  8009aa:	75 e2                	jne    80098e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009b5:	55                   	push   %ebp
  8009b6:	89 e5                	mov    %esp,%ebp
  8009b8:	53                   	push   %ebx
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009bc:	89 c1                	mov    %eax,%ecx
  8009be:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c1:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c5:	eb 0a                	jmp    8009d1 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c7:	0f b6 10             	movzbl (%eax),%edx
  8009ca:	39 da                	cmp    %ebx,%edx
  8009cc:	74 07                	je     8009d5 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	39 c8                	cmp    %ecx,%eax
  8009d3:	72 f2                	jb     8009c7 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009d5:	5b                   	pop    %ebx
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	57                   	push   %edi
  8009dc:	56                   	push   %esi
  8009dd:	53                   	push   %ebx
  8009de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e4:	eb 03                	jmp    8009e9 <strtol+0x11>
		s++;
  8009e6:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009e9:	0f b6 01             	movzbl (%ecx),%eax
  8009ec:	3c 20                	cmp    $0x20,%al
  8009ee:	74 f6                	je     8009e6 <strtol+0xe>
  8009f0:	3c 09                	cmp    $0x9,%al
  8009f2:	74 f2                	je     8009e6 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009f4:	3c 2b                	cmp    $0x2b,%al
  8009f6:	75 0a                	jne    800a02 <strtol+0x2a>
		s++;
  8009f8:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009fb:	bf 00 00 00 00       	mov    $0x0,%edi
  800a00:	eb 11                	jmp    800a13 <strtol+0x3b>
  800a02:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a07:	3c 2d                	cmp    $0x2d,%al
  800a09:	75 08                	jne    800a13 <strtol+0x3b>
		s++, neg = 1;
  800a0b:	83 c1 01             	add    $0x1,%ecx
  800a0e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a13:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a19:	75 15                	jne    800a30 <strtol+0x58>
  800a1b:	80 39 30             	cmpb   $0x30,(%ecx)
  800a1e:	75 10                	jne    800a30 <strtol+0x58>
  800a20:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a24:	75 7c                	jne    800aa2 <strtol+0xca>
		s += 2, base = 16;
  800a26:	83 c1 02             	add    $0x2,%ecx
  800a29:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a2e:	eb 16                	jmp    800a46 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a30:	85 db                	test   %ebx,%ebx
  800a32:	75 12                	jne    800a46 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a34:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a39:	80 39 30             	cmpb   $0x30,(%ecx)
  800a3c:	75 08                	jne    800a46 <strtol+0x6e>
		s++, base = 8;
  800a3e:	83 c1 01             	add    $0x1,%ecx
  800a41:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a46:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a4e:	0f b6 11             	movzbl (%ecx),%edx
  800a51:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a54:	89 f3                	mov    %esi,%ebx
  800a56:	80 fb 09             	cmp    $0x9,%bl
  800a59:	77 08                	ja     800a63 <strtol+0x8b>
			dig = *s - '0';
  800a5b:	0f be d2             	movsbl %dl,%edx
  800a5e:	83 ea 30             	sub    $0x30,%edx
  800a61:	eb 22                	jmp    800a85 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a63:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a66:	89 f3                	mov    %esi,%ebx
  800a68:	80 fb 19             	cmp    $0x19,%bl
  800a6b:	77 08                	ja     800a75 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a6d:	0f be d2             	movsbl %dl,%edx
  800a70:	83 ea 57             	sub    $0x57,%edx
  800a73:	eb 10                	jmp    800a85 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a75:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a78:	89 f3                	mov    %esi,%ebx
  800a7a:	80 fb 19             	cmp    $0x19,%bl
  800a7d:	77 16                	ja     800a95 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a7f:	0f be d2             	movsbl %dl,%edx
  800a82:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a85:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a88:	7d 0b                	jge    800a95 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a8a:	83 c1 01             	add    $0x1,%ecx
  800a8d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a91:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a93:	eb b9                	jmp    800a4e <strtol+0x76>

	if (endptr)
  800a95:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a99:	74 0d                	je     800aa8 <strtol+0xd0>
		*endptr = (char *) s;
  800a9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9e:	89 0e                	mov    %ecx,(%esi)
  800aa0:	eb 06                	jmp    800aa8 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	74 98                	je     800a3e <strtol+0x66>
  800aa6:	eb 9e                	jmp    800a46 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aa8:	89 c2                	mov    %eax,%edx
  800aaa:	f7 da                	neg    %edx
  800aac:	85 ff                	test   %edi,%edi
  800aae:	0f 45 c2             	cmovne %edx,%eax
}
  800ab1:	5b                   	pop    %ebx
  800ab2:	5e                   	pop    %esi
  800ab3:	5f                   	pop    %edi
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	57                   	push   %edi
  800aba:	56                   	push   %esi
  800abb:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ac4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ac7:	89 c3                	mov    %eax,%ebx
  800ac9:	89 c7                	mov    %eax,%edi
  800acb:	89 c6                	mov    %eax,%esi
  800acd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5f                   	pop    %edi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	57                   	push   %edi
  800ad8:	56                   	push   %esi
  800ad9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ada:	ba 00 00 00 00       	mov    $0x0,%edx
  800adf:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae4:	89 d1                	mov    %edx,%ecx
  800ae6:	89 d3                	mov    %edx,%ebx
  800ae8:	89 d7                	mov    %edx,%edi
  800aea:	89 d6                	mov    %edx,%esi
  800aec:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800afc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b01:	b8 03 00 00 00       	mov    $0x3,%eax
  800b06:	8b 55 08             	mov    0x8(%ebp),%edx
  800b09:	89 cb                	mov    %ecx,%ebx
  800b0b:	89 cf                	mov    %ecx,%edi
  800b0d:	89 ce                	mov    %ecx,%esi
  800b0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b11:	85 c0                	test   %eax,%eax
  800b13:	7e 17                	jle    800b2c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b15:	83 ec 0c             	sub    $0xc,%esp
  800b18:	50                   	push   %eax
  800b19:	6a 03                	push   $0x3
  800b1b:	68 04 13 80 00       	push   $0x801304
  800b20:	6a 23                	push   $0x23
  800b22:	68 21 13 80 00       	push   $0x801321
  800b27:	e8 8f 02 00 00       	call   800dbb <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3f:	b8 02 00 00 00       	mov    $0x2,%eax
  800b44:	89 d1                	mov    %edx,%ecx
  800b46:	89 d3                	mov    %edx,%ebx
  800b48:	89 d7                	mov    %edx,%edi
  800b4a:	89 d6                	mov    %edx,%esi
  800b4c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b4e:	5b                   	pop    %ebx
  800b4f:	5e                   	pop    %esi
  800b50:	5f                   	pop    %edi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <sys_yield>:

void
sys_yield(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	57                   	push   %edi
  800b57:	56                   	push   %esi
  800b58:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b63:	89 d1                	mov    %edx,%ecx
  800b65:	89 d3                	mov    %edx,%ebx
  800b67:	89 d7                	mov    %edx,%edi
  800b69:	89 d6                	mov    %edx,%esi
  800b6b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b6d:	5b                   	pop    %ebx
  800b6e:	5e                   	pop    %esi
  800b6f:	5f                   	pop    %edi
  800b70:	5d                   	pop    %ebp
  800b71:	c3                   	ret    

00800b72 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7b:	be 00 00 00 00       	mov    $0x0,%esi
  800b80:	b8 04 00 00 00       	mov    $0x4,%eax
  800b85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b88:	8b 55 08             	mov    0x8(%ebp),%edx
  800b8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b8e:	89 f7                	mov    %esi,%edi
  800b90:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b92:	85 c0                	test   %eax,%eax
  800b94:	7e 17                	jle    800bad <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b96:	83 ec 0c             	sub    $0xc,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 04                	push   $0x4
  800b9c:	68 04 13 80 00       	push   $0x801304
  800ba1:	6a 23                	push   $0x23
  800ba3:	68 21 13 80 00       	push   $0x801321
  800ba8:	e8 0e 02 00 00       	call   800dbb <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	57                   	push   %edi
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bbe:	b8 05 00 00 00       	mov    $0x5,%eax
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcc:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bcf:	8b 75 18             	mov    0x18(%ebp),%esi
  800bd2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd4:	85 c0                	test   %eax,%eax
  800bd6:	7e 17                	jle    800bef <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	50                   	push   %eax
  800bdc:	6a 05                	push   $0x5
  800bde:	68 04 13 80 00       	push   $0x801304
  800be3:	6a 23                	push   $0x23
  800be5:	68 21 13 80 00       	push   $0x801321
  800bea:	e8 cc 01 00 00       	call   800dbb <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    

00800bf7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	57                   	push   %edi
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c00:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c05:	b8 06 00 00 00       	mov    $0x6,%eax
  800c0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c10:	89 df                	mov    %ebx,%edi
  800c12:	89 de                	mov    %ebx,%esi
  800c14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c16:	85 c0                	test   %eax,%eax
  800c18:	7e 17                	jle    800c31 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 06                	push   $0x6
  800c20:	68 04 13 80 00       	push   $0x801304
  800c25:	6a 23                	push   $0x23
  800c27:	68 21 13 80 00       	push   $0x801321
  800c2c:	e8 8a 01 00 00       	call   800dbb <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c34:	5b                   	pop    %ebx
  800c35:	5e                   	pop    %esi
  800c36:	5f                   	pop    %edi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
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
  800c42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c47:	b8 08 00 00 00       	mov    $0x8,%eax
  800c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c52:	89 df                	mov    %ebx,%edi
  800c54:	89 de                	mov    %ebx,%esi
  800c56:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	7e 17                	jle    800c73 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5c:	83 ec 0c             	sub    $0xc,%esp
  800c5f:	50                   	push   %eax
  800c60:	6a 08                	push   $0x8
  800c62:	68 04 13 80 00       	push   $0x801304
  800c67:	6a 23                	push   $0x23
  800c69:	68 21 13 80 00       	push   $0x801321
  800c6e:	e8 48 01 00 00       	call   800dbb <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
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
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	b8 09 00 00 00       	mov    $0x9,%eax
  800c8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c91:	8b 55 08             	mov    0x8(%ebp),%edx
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7e 17                	jle    800cb5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	50                   	push   %eax
  800ca2:	6a 09                	push   $0x9
  800ca4:	68 04 13 80 00       	push   $0x801304
  800ca9:	6a 23                	push   $0x23
  800cab:	68 21 13 80 00       	push   $0x801321
  800cb0:	e8 06 01 00 00       	call   800dbb <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc3:	be 00 00 00 00       	mov    $0x0,%esi
  800cc8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cd6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cd9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    

00800ce0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ce0:	55                   	push   %ebp
  800ce1:	89 e5                	mov    %esp,%ebp
  800ce3:	57                   	push   %edi
  800ce4:	56                   	push   %esi
  800ce5:	53                   	push   %ebx
  800ce6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cee:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	89 cb                	mov    %ecx,%ebx
  800cf8:	89 cf                	mov    %ecx,%edi
  800cfa:	89 ce                	mov    %ecx,%esi
  800cfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cfe:	85 c0                	test   %eax,%eax
  800d00:	7e 17                	jle    800d19 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 0c                	push   $0xc
  800d08:	68 04 13 80 00       	push   $0x801304
  800d0d:	6a 23                	push   $0x23
  800d0f:	68 21 13 80 00       	push   $0x801321
  800d14:	e8 a2 00 00 00       	call   800dbb <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1c:	5b                   	pop    %ebx
  800d1d:	5e                   	pop    %esi
  800d1e:	5f                   	pop    %edi
  800d1f:	5d                   	pop    %ebp
  800d20:	c3                   	ret    

00800d21 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	53                   	push   %ebx
  800d25:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  800d28:	e8 07 fe ff ff       	call   800b34 <sys_getenvid>
  800d2d:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  800d2f:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d36:	75 29                	jne    800d61 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  800d38:	83 ec 04             	sub    $0x4,%esp
  800d3b:	6a 07                	push   $0x7
  800d3d:	68 00 f0 bf ee       	push   $0xeebff000
  800d42:	50                   	push   %eax
  800d43:	e8 2a fe ff ff       	call   800b72 <sys_page_alloc>
  800d48:	83 c4 10             	add    $0x10,%esp
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	79 12                	jns    800d61 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  800d4f:	50                   	push   %eax
  800d50:	68 2f 13 80 00       	push   $0x80132f
  800d55:	6a 24                	push   $0x24
  800d57:	68 48 13 80 00       	push   $0x801348
  800d5c:	e8 5a 00 00 00       	call   800dbb <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	a3 08 20 80 00       	mov    %eax,0x802008
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  800d69:	83 ec 08             	sub    $0x8,%esp
  800d6c:	68 95 0d 80 00       	push   $0x800d95
  800d71:	53                   	push   %ebx
  800d72:	e8 04 ff ff ff       	call   800c7b <sys_env_set_pgfault_upcall>
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	85 c0                	test   %eax,%eax
  800d7c:	79 12                	jns    800d90 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  800d7e:	50                   	push   %eax
  800d7f:	68 2f 13 80 00       	push   $0x80132f
  800d84:	6a 2e                	push   $0x2e
  800d86:	68 48 13 80 00       	push   $0x801348
  800d8b:	e8 2b 00 00 00       	call   800dbb <_panic>
}
  800d90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d95:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d96:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800d9b:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800d9d:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800da0:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800da4:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  800da7:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800dab:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  800dad:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800db1:	83 c4 08             	add    $0x8,%esp
	popal
  800db4:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800db5:	83 c4 04             	add    $0x4,%esp
	popfl
  800db8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  800db9:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800dba:	c3                   	ret    

00800dbb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
  800dbe:	56                   	push   %esi
  800dbf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dc0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dc3:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dc9:	e8 66 fd ff ff       	call   800b34 <sys_getenvid>
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	ff 75 0c             	pushl  0xc(%ebp)
  800dd4:	ff 75 08             	pushl  0x8(%ebp)
  800dd7:	56                   	push   %esi
  800dd8:	50                   	push   %eax
  800dd9:	68 58 13 80 00       	push   $0x801358
  800dde:	e8 88 f3 ff ff       	call   80016b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800de3:	83 c4 18             	add    $0x18,%esp
  800de6:	53                   	push   %ebx
  800de7:	ff 75 10             	pushl  0x10(%ebp)
  800dea:	e8 2b f3 ff ff       	call   80011a <vcprintf>
	cprintf("\n");
  800def:	c7 04 24 46 13 80 00 	movl   $0x801346,(%esp)
  800df6:	e8 70 f3 ff ff       	call   80016b <cprintf>
  800dfb:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dfe:	cc                   	int3   
  800dff:	eb fd                	jmp    800dfe <_panic+0x43>
  800e01:	66 90                	xchg   %ax,%ax
  800e03:	66 90                	xchg   %ax,%ax
  800e05:	66 90                	xchg   %ax,%ax
  800e07:	66 90                	xchg   %ax,%ax
  800e09:	66 90                	xchg   %ax,%ax
  800e0b:	66 90                	xchg   %ax,%ax
  800e0d:	66 90                	xchg   %ax,%ax
  800e0f:	90                   	nop

00800e10 <__udivdi3>:
  800e10:	55                   	push   %ebp
  800e11:	57                   	push   %edi
  800e12:	56                   	push   %esi
  800e13:	53                   	push   %ebx
  800e14:	83 ec 1c             	sub    $0x1c,%esp
  800e17:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800e1b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800e1f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800e23:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e27:	85 f6                	test   %esi,%esi
  800e29:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800e2d:	89 ca                	mov    %ecx,%edx
  800e2f:	89 f8                	mov    %edi,%eax
  800e31:	75 3d                	jne    800e70 <__udivdi3+0x60>
  800e33:	39 cf                	cmp    %ecx,%edi
  800e35:	0f 87 c5 00 00 00    	ja     800f00 <__udivdi3+0xf0>
  800e3b:	85 ff                	test   %edi,%edi
  800e3d:	89 fd                	mov    %edi,%ebp
  800e3f:	75 0b                	jne    800e4c <__udivdi3+0x3c>
  800e41:	b8 01 00 00 00       	mov    $0x1,%eax
  800e46:	31 d2                	xor    %edx,%edx
  800e48:	f7 f7                	div    %edi
  800e4a:	89 c5                	mov    %eax,%ebp
  800e4c:	89 c8                	mov    %ecx,%eax
  800e4e:	31 d2                	xor    %edx,%edx
  800e50:	f7 f5                	div    %ebp
  800e52:	89 c1                	mov    %eax,%ecx
  800e54:	89 d8                	mov    %ebx,%eax
  800e56:	89 cf                	mov    %ecx,%edi
  800e58:	f7 f5                	div    %ebp
  800e5a:	89 c3                	mov    %eax,%ebx
  800e5c:	89 d8                	mov    %ebx,%eax
  800e5e:	89 fa                	mov    %edi,%edx
  800e60:	83 c4 1c             	add    $0x1c,%esp
  800e63:	5b                   	pop    %ebx
  800e64:	5e                   	pop    %esi
  800e65:	5f                   	pop    %edi
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    
  800e68:	90                   	nop
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	39 ce                	cmp    %ecx,%esi
  800e72:	77 74                	ja     800ee8 <__udivdi3+0xd8>
  800e74:	0f bd fe             	bsr    %esi,%edi
  800e77:	83 f7 1f             	xor    $0x1f,%edi
  800e7a:	0f 84 98 00 00 00    	je     800f18 <__udivdi3+0x108>
  800e80:	bb 20 00 00 00       	mov    $0x20,%ebx
  800e85:	89 f9                	mov    %edi,%ecx
  800e87:	89 c5                	mov    %eax,%ebp
  800e89:	29 fb                	sub    %edi,%ebx
  800e8b:	d3 e6                	shl    %cl,%esi
  800e8d:	89 d9                	mov    %ebx,%ecx
  800e8f:	d3 ed                	shr    %cl,%ebp
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e0                	shl    %cl,%eax
  800e95:	09 ee                	or     %ebp,%esi
  800e97:	89 d9                	mov    %ebx,%ecx
  800e99:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800e9d:	89 d5                	mov    %edx,%ebp
  800e9f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800ea3:	d3 ed                	shr    %cl,%ebp
  800ea5:	89 f9                	mov    %edi,%ecx
  800ea7:	d3 e2                	shl    %cl,%edx
  800ea9:	89 d9                	mov    %ebx,%ecx
  800eab:	d3 e8                	shr    %cl,%eax
  800ead:	09 c2                	or     %eax,%edx
  800eaf:	89 d0                	mov    %edx,%eax
  800eb1:	89 ea                	mov    %ebp,%edx
  800eb3:	f7 f6                	div    %esi
  800eb5:	89 d5                	mov    %edx,%ebp
  800eb7:	89 c3                	mov    %eax,%ebx
  800eb9:	f7 64 24 0c          	mull   0xc(%esp)
  800ebd:	39 d5                	cmp    %edx,%ebp
  800ebf:	72 10                	jb     800ed1 <__udivdi3+0xc1>
  800ec1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800ec5:	89 f9                	mov    %edi,%ecx
  800ec7:	d3 e6                	shl    %cl,%esi
  800ec9:	39 c6                	cmp    %eax,%esi
  800ecb:	73 07                	jae    800ed4 <__udivdi3+0xc4>
  800ecd:	39 d5                	cmp    %edx,%ebp
  800ecf:	75 03                	jne    800ed4 <__udivdi3+0xc4>
  800ed1:	83 eb 01             	sub    $0x1,%ebx
  800ed4:	31 ff                	xor    %edi,%edi
  800ed6:	89 d8                	mov    %ebx,%eax
  800ed8:	89 fa                	mov    %edi,%edx
  800eda:	83 c4 1c             	add    $0x1c,%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
  800ee2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee8:	31 ff                	xor    %edi,%edi
  800eea:	31 db                	xor    %ebx,%ebx
  800eec:	89 d8                	mov    %ebx,%eax
  800eee:	89 fa                	mov    %edi,%edx
  800ef0:	83 c4 1c             	add    $0x1c,%esp
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    
  800ef8:	90                   	nop
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d8                	mov    %ebx,%eax
  800f02:	f7 f7                	div    %edi
  800f04:	31 ff                	xor    %edi,%edi
  800f06:	89 c3                	mov    %eax,%ebx
  800f08:	89 d8                	mov    %ebx,%eax
  800f0a:	89 fa                	mov    %edi,%edx
  800f0c:	83 c4 1c             	add    $0x1c,%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    
  800f14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f18:	39 ce                	cmp    %ecx,%esi
  800f1a:	72 0c                	jb     800f28 <__udivdi3+0x118>
  800f1c:	31 db                	xor    %ebx,%ebx
  800f1e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800f22:	0f 87 34 ff ff ff    	ja     800e5c <__udivdi3+0x4c>
  800f28:	bb 01 00 00 00       	mov    $0x1,%ebx
  800f2d:	e9 2a ff ff ff       	jmp    800e5c <__udivdi3+0x4c>
  800f32:	66 90                	xchg   %ax,%ax
  800f34:	66 90                	xchg   %ax,%ax
  800f36:	66 90                	xchg   %ax,%ax
  800f38:	66 90                	xchg   %ax,%ax
  800f3a:	66 90                	xchg   %ax,%ax
  800f3c:	66 90                	xchg   %ax,%ax
  800f3e:	66 90                	xchg   %ax,%ax

00800f40 <__umoddi3>:
  800f40:	55                   	push   %ebp
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	53                   	push   %ebx
  800f44:	83 ec 1c             	sub    $0x1c,%esp
  800f47:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f4b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800f4f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f53:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f57:	85 d2                	test   %edx,%edx
  800f59:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800f5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f61:	89 f3                	mov    %esi,%ebx
  800f63:	89 3c 24             	mov    %edi,(%esp)
  800f66:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f6a:	75 1c                	jne    800f88 <__umoddi3+0x48>
  800f6c:	39 f7                	cmp    %esi,%edi
  800f6e:	76 50                	jbe    800fc0 <__umoddi3+0x80>
  800f70:	89 c8                	mov    %ecx,%eax
  800f72:	89 f2                	mov    %esi,%edx
  800f74:	f7 f7                	div    %edi
  800f76:	89 d0                	mov    %edx,%eax
  800f78:	31 d2                	xor    %edx,%edx
  800f7a:	83 c4 1c             	add    $0x1c,%esp
  800f7d:	5b                   	pop    %ebx
  800f7e:	5e                   	pop    %esi
  800f7f:	5f                   	pop    %edi
  800f80:	5d                   	pop    %ebp
  800f81:	c3                   	ret    
  800f82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f88:	39 f2                	cmp    %esi,%edx
  800f8a:	89 d0                	mov    %edx,%eax
  800f8c:	77 52                	ja     800fe0 <__umoddi3+0xa0>
  800f8e:	0f bd ea             	bsr    %edx,%ebp
  800f91:	83 f5 1f             	xor    $0x1f,%ebp
  800f94:	75 5a                	jne    800ff0 <__umoddi3+0xb0>
  800f96:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800f9a:	0f 82 e0 00 00 00    	jb     801080 <__umoddi3+0x140>
  800fa0:	39 0c 24             	cmp    %ecx,(%esp)
  800fa3:	0f 86 d7 00 00 00    	jbe    801080 <__umoddi3+0x140>
  800fa9:	8b 44 24 08          	mov    0x8(%esp),%eax
  800fad:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fb1:	83 c4 1c             	add    $0x1c,%esp
  800fb4:	5b                   	pop    %ebx
  800fb5:	5e                   	pop    %esi
  800fb6:	5f                   	pop    %edi
  800fb7:	5d                   	pop    %ebp
  800fb8:	c3                   	ret    
  800fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fc0:	85 ff                	test   %edi,%edi
  800fc2:	89 fd                	mov    %edi,%ebp
  800fc4:	75 0b                	jne    800fd1 <__umoddi3+0x91>
  800fc6:	b8 01 00 00 00       	mov    $0x1,%eax
  800fcb:	31 d2                	xor    %edx,%edx
  800fcd:	f7 f7                	div    %edi
  800fcf:	89 c5                	mov    %eax,%ebp
  800fd1:	89 f0                	mov    %esi,%eax
  800fd3:	31 d2                	xor    %edx,%edx
  800fd5:	f7 f5                	div    %ebp
  800fd7:	89 c8                	mov    %ecx,%eax
  800fd9:	f7 f5                	div    %ebp
  800fdb:	89 d0                	mov    %edx,%eax
  800fdd:	eb 99                	jmp    800f78 <__umoddi3+0x38>
  800fdf:	90                   	nop
  800fe0:	89 c8                	mov    %ecx,%eax
  800fe2:	89 f2                	mov    %esi,%edx
  800fe4:	83 c4 1c             	add    $0x1c,%esp
  800fe7:	5b                   	pop    %ebx
  800fe8:	5e                   	pop    %esi
  800fe9:	5f                   	pop    %edi
  800fea:	5d                   	pop    %ebp
  800feb:	c3                   	ret    
  800fec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ff0:	8b 34 24             	mov    (%esp),%esi
  800ff3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ff8:	89 e9                	mov    %ebp,%ecx
  800ffa:	29 ef                	sub    %ebp,%edi
  800ffc:	d3 e0                	shl    %cl,%eax
  800ffe:	89 f9                	mov    %edi,%ecx
  801000:	89 f2                	mov    %esi,%edx
  801002:	d3 ea                	shr    %cl,%edx
  801004:	89 e9                	mov    %ebp,%ecx
  801006:	09 c2                	or     %eax,%edx
  801008:	89 d8                	mov    %ebx,%eax
  80100a:	89 14 24             	mov    %edx,(%esp)
  80100d:	89 f2                	mov    %esi,%edx
  80100f:	d3 e2                	shl    %cl,%edx
  801011:	89 f9                	mov    %edi,%ecx
  801013:	89 54 24 04          	mov    %edx,0x4(%esp)
  801017:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80101b:	d3 e8                	shr    %cl,%eax
  80101d:	89 e9                	mov    %ebp,%ecx
  80101f:	89 c6                	mov    %eax,%esi
  801021:	d3 e3                	shl    %cl,%ebx
  801023:	89 f9                	mov    %edi,%ecx
  801025:	89 d0                	mov    %edx,%eax
  801027:	d3 e8                	shr    %cl,%eax
  801029:	89 e9                	mov    %ebp,%ecx
  80102b:	09 d8                	or     %ebx,%eax
  80102d:	89 d3                	mov    %edx,%ebx
  80102f:	89 f2                	mov    %esi,%edx
  801031:	f7 34 24             	divl   (%esp)
  801034:	89 d6                	mov    %edx,%esi
  801036:	d3 e3                	shl    %cl,%ebx
  801038:	f7 64 24 04          	mull   0x4(%esp)
  80103c:	39 d6                	cmp    %edx,%esi
  80103e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801042:	89 d1                	mov    %edx,%ecx
  801044:	89 c3                	mov    %eax,%ebx
  801046:	72 08                	jb     801050 <__umoddi3+0x110>
  801048:	75 11                	jne    80105b <__umoddi3+0x11b>
  80104a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80104e:	73 0b                	jae    80105b <__umoddi3+0x11b>
  801050:	2b 44 24 04          	sub    0x4(%esp),%eax
  801054:	1b 14 24             	sbb    (%esp),%edx
  801057:	89 d1                	mov    %edx,%ecx
  801059:	89 c3                	mov    %eax,%ebx
  80105b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80105f:	29 da                	sub    %ebx,%edx
  801061:	19 ce                	sbb    %ecx,%esi
  801063:	89 f9                	mov    %edi,%ecx
  801065:	89 f0                	mov    %esi,%eax
  801067:	d3 e0                	shl    %cl,%eax
  801069:	89 e9                	mov    %ebp,%ecx
  80106b:	d3 ea                	shr    %cl,%edx
  80106d:	89 e9                	mov    %ebp,%ecx
  80106f:	d3 ee                	shr    %cl,%esi
  801071:	09 d0                	or     %edx,%eax
  801073:	89 f2                	mov    %esi,%edx
  801075:	83 c4 1c             	add    $0x1c,%esp
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    
  80107d:	8d 76 00             	lea    0x0(%esi),%esi
  801080:	29 f9                	sub    %edi,%ecx
  801082:	19 d6                	sbb    %edx,%esi
  801084:	89 74 24 04          	mov    %esi,0x4(%esp)
  801088:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80108c:	e9 18 ff ff ff       	jmp    800fa9 <__umoddi3+0x69>
