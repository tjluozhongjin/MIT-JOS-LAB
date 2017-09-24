
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 60 1e 80 00       	push   $0x801e60
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 04 40 80 00       	mov    0x804004,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 6e 1e 80 00       	push   $0x801e6e
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 ac 0a 00 00       	call   800b1a <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
		binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 65 0e 00 00       	call   800f14 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 20 0a 00 00       	call   800ad9 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 ae 09 00 00       	call   800a9c <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 1a 01 00 00       	call   80024e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 53 09 00 00       	call   800a9c <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 45                	ja     8001da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 17 1a 00 00       	call   801bd0 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 18                	jmp    8001e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 03                	jmp    8001dd <printnum+0x78>
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f e8                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 04 1b 00 00       	call   801d00 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 8f 1e 80 00 	movsbl 0x801e8f(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	3b 50 04             	cmp    0x4(%eax),%edx
  800223:	73 0a                	jae    80022f <sprintputch+0x1b>
		*b->buf++ = ch;
  800225:	8d 4a 01             	lea    0x1(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	88 02                	mov    %al,(%edx)
}
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800237:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 10             	pushl  0x10(%ebp)
  80023e:	ff 75 0c             	pushl  0xc(%ebp)
  800241:	ff 75 08             	pushl  0x8(%ebp)
  800244:	e8 05 00 00 00       	call   80024e <vprintfmt>
	va_end(ap);
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	57                   	push   %edi
  800252:	56                   	push   %esi
  800253:	53                   	push   %ebx
  800254:	83 ec 2c             	sub    $0x2c,%esp
  800257:	8b 75 08             	mov    0x8(%ebp),%esi
  80025a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800260:	eb 12                	jmp    800274 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800262:	85 c0                	test   %eax,%eax
  800264:	0f 84 42 04 00 00    	je     8006ac <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	53                   	push   %ebx
  80026e:	50                   	push   %eax
  80026f:	ff d6                	call   *%esi
  800271:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800274:	83 c7 01             	add    $0x1,%edi
  800277:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80027b:	83 f8 25             	cmp    $0x25,%eax
  80027e:	75 e2                	jne    800262 <vprintfmt+0x14>
  800280:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800284:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80028b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800292:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800299:	b9 00 00 00 00       	mov    $0x0,%ecx
  80029e:	eb 07                	jmp    8002a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002a3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a7:	8d 47 01             	lea    0x1(%edi),%eax
  8002aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ad:	0f b6 07             	movzbl (%edi),%eax
  8002b0:	0f b6 d0             	movzbl %al,%edx
  8002b3:	83 e8 23             	sub    $0x23,%eax
  8002b6:	3c 55                	cmp    $0x55,%al
  8002b8:	0f 87 d3 03 00 00    	ja     800691 <vprintfmt+0x443>
  8002be:	0f b6 c0             	movzbl %al,%eax
  8002c1:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  8002c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002cb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002cf:	eb d6                	jmp    8002a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002df:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e9:	83 f9 09             	cmp    $0x9,%ecx
  8002ec:	77 3f                	ja     80032d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002f1:	eb e9                	jmp    8002dc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8b 00                	mov    (%eax),%eax
  8002f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 40 04             	lea    0x4(%eax),%eax
  800301:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800307:	eb 2a                	jmp    800333 <vprintfmt+0xe5>
  800309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030c:	85 c0                	test   %eax,%eax
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
  800313:	0f 49 d0             	cmovns %eax,%edx
  800316:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031c:	eb 89                	jmp    8002a7 <vprintfmt+0x59>
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800321:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800328:	e9 7a ff ff ff       	jmp    8002a7 <vprintfmt+0x59>
  80032d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800330:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800333:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800337:	0f 89 6a ff ff ff    	jns    8002a7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80033d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800340:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800343:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034a:	e9 58 ff ff ff       	jmp    8002a7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80034f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800355:	e9 4d ff ff ff       	jmp    8002a7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 78 04             	lea    0x4(%eax),%edi
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	53                   	push   %ebx
  800364:	ff 30                	pushl  (%eax)
  800366:	ff d6                	call   *%esi
			break;
  800368:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80036b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800371:	e9 fe fe ff ff       	jmp    800274 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8d 78 04             	lea    0x4(%eax),%edi
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	99                   	cltd   
  80037f:	31 d0                	xor    %edx,%eax
  800381:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800383:	83 f8 0f             	cmp    $0xf,%eax
  800386:	7f 0b                	jg     800393 <vprintfmt+0x145>
  800388:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  80038f:	85 d2                	test   %edx,%edx
  800391:	75 1b                	jne    8003ae <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800393:	50                   	push   %eax
  800394:	68 a7 1e 80 00       	push   $0x801ea7
  800399:	53                   	push   %ebx
  80039a:	56                   	push   %esi
  80039b:	e8 91 fe ff ff       	call   800231 <printfmt>
  8003a0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003a9:	e9 c6 fe ff ff       	jmp    800274 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ae:	52                   	push   %edx
  8003af:	68 71 22 80 00       	push   $0x802271
  8003b4:	53                   	push   %ebx
  8003b5:	56                   	push   %esi
  8003b6:	e8 76 fe ff ff       	call   800231 <printfmt>
  8003bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003be:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c4:	e9 ab fe ff ff       	jmp    800274 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	83 c0 04             	add    $0x4,%eax
  8003cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d7:	85 ff                	test   %edi,%edi
  8003d9:	b8 a0 1e 80 00       	mov    $0x801ea0,%eax
  8003de:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e5:	0f 8e 94 00 00 00    	jle    80047f <vprintfmt+0x231>
  8003eb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003ef:	0f 84 98 00 00 00    	je     80048d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	ff 75 d0             	pushl  -0x30(%ebp)
  8003fb:	57                   	push   %edi
  8003fc:	e8 33 03 00 00       	call   800734 <strnlen>
  800401:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800404:	29 c1                	sub    %eax,%ecx
  800406:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800409:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80040c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800410:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800413:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800416:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800418:	eb 0f                	jmp    800429 <vprintfmt+0x1db>
					putch(padc, putdat);
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	53                   	push   %ebx
  80041e:	ff 75 e0             	pushl  -0x20(%ebp)
  800421:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800423:	83 ef 01             	sub    $0x1,%edi
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	85 ff                	test   %edi,%edi
  80042b:	7f ed                	jg     80041a <vprintfmt+0x1cc>
  80042d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800430:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800433:	85 c9                	test   %ecx,%ecx
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	0f 49 c1             	cmovns %ecx,%eax
  80043d:	29 c1                	sub    %eax,%ecx
  80043f:	89 75 08             	mov    %esi,0x8(%ebp)
  800442:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800445:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800448:	89 cb                	mov    %ecx,%ebx
  80044a:	eb 4d                	jmp    800499 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80044c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800450:	74 1b                	je     80046d <vprintfmt+0x21f>
  800452:	0f be c0             	movsbl %al,%eax
  800455:	83 e8 20             	sub    $0x20,%eax
  800458:	83 f8 5e             	cmp    $0x5e,%eax
  80045b:	76 10                	jbe    80046d <vprintfmt+0x21f>
					putch('?', putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	ff 75 0c             	pushl  0xc(%ebp)
  800463:	6a 3f                	push   $0x3f
  800465:	ff 55 08             	call   *0x8(%ebp)
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	eb 0d                	jmp    80047a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	ff 75 0c             	pushl  0xc(%ebp)
  800473:	52                   	push   %edx
  800474:	ff 55 08             	call   *0x8(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047a:	83 eb 01             	sub    $0x1,%ebx
  80047d:	eb 1a                	jmp    800499 <vprintfmt+0x24b>
  80047f:	89 75 08             	mov    %esi,0x8(%ebp)
  800482:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800485:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800488:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048b:	eb 0c                	jmp    800499 <vprintfmt+0x24b>
  80048d:	89 75 08             	mov    %esi,0x8(%ebp)
  800490:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800493:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800496:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800499:	83 c7 01             	add    $0x1,%edi
  80049c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a0:	0f be d0             	movsbl %al,%edx
  8004a3:	85 d2                	test   %edx,%edx
  8004a5:	74 23                	je     8004ca <vprintfmt+0x27c>
  8004a7:	85 f6                	test   %esi,%esi
  8004a9:	78 a1                	js     80044c <vprintfmt+0x1fe>
  8004ab:	83 ee 01             	sub    $0x1,%esi
  8004ae:	79 9c                	jns    80044c <vprintfmt+0x1fe>
  8004b0:	89 df                	mov    %ebx,%edi
  8004b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b8:	eb 18                	jmp    8004d2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	6a 20                	push   $0x20
  8004c0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c2:	83 ef 01             	sub    $0x1,%edi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb 08                	jmp    8004d2 <vprintfmt+0x284>
  8004ca:	89 df                	mov    %ebx,%edi
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	7f e4                	jg     8004ba <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	e9 90 fd ff ff       	jmp    800274 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e4:	83 f9 01             	cmp    $0x1,%ecx
  8004e7:	7e 19                	jle    800502 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8b 50 04             	mov    0x4(%eax),%edx
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 40 08             	lea    0x8(%eax),%eax
  8004fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800500:	eb 38                	jmp    80053a <vprintfmt+0x2ec>
	else if (lflag)
  800502:	85 c9                	test   %ecx,%ecx
  800504:	74 1b                	je     800521 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050e:	89 c1                	mov    %eax,%ecx
  800510:	c1 f9 1f             	sar    $0x1f,%ecx
  800513:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 40 04             	lea    0x4(%eax),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
  80051f:	eb 19                	jmp    80053a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 40 04             	lea    0x4(%eax),%eax
  800537:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80053a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800540:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800545:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800549:	0f 89 0e 01 00 00    	jns    80065d <vprintfmt+0x40f>
				putch('-', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	6a 2d                	push   $0x2d
  800555:	ff d6                	call   *%esi
				num = -(long long) num;
  800557:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055d:	f7 da                	neg    %edx
  80055f:	83 d1 00             	adc    $0x0,%ecx
  800562:	f7 d9                	neg    %ecx
  800564:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800567:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056c:	e9 ec 00 00 00       	jmp    80065d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800571:	83 f9 01             	cmp    $0x1,%ecx
  800574:	7e 18                	jle    80058e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 10                	mov    (%eax),%edx
  80057b:	8b 48 04             	mov    0x4(%eax),%ecx
  80057e:	8d 40 08             	lea    0x8(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800584:	b8 0a 00 00 00       	mov    $0xa,%eax
  800589:	e9 cf 00 00 00       	jmp    80065d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80058e:	85 c9                	test   %ecx,%ecx
  800590:	74 1a                	je     8005ac <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 10                	mov    (%eax),%edx
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059c:	8d 40 04             	lea    0x4(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a7:	e9 b1 00 00 00       	jmp    80065d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
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
  8005c1:	e9 97 00 00 00       	jmp    80065d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 58                	push   $0x58
  8005cc:	ff d6                	call   *%esi
			putch('X', putdat);
  8005ce:	83 c4 08             	add    $0x8,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	6a 58                	push   $0x58
  8005d4:	ff d6                	call   *%esi
			putch('X', putdat);
  8005d6:	83 c4 08             	add    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 58                	push   $0x58
  8005dc:	ff d6                	call   *%esi
			break;
  8005de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005e4:	e9 8b fc ff ff       	jmp    800274 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	53                   	push   %ebx
  8005ed:	6a 30                	push   $0x30
  8005ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f1:	83 c4 08             	add    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	6a 78                	push   $0x78
  8005f7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800603:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800606:	8d 40 04             	lea    0x4(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80060c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800611:	eb 4a                	jmp    80065d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800613:	83 f9 01             	cmp    $0x1,%ecx
  800616:	7e 15                	jle    80062d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	8b 48 04             	mov    0x4(%eax),%ecx
  800620:	8d 40 08             	lea    0x8(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800626:	b8 10 00 00 00       	mov    $0x10,%eax
  80062b:	eb 30                	jmp    80065d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	74 17                	je     800648 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063b:	8d 40 04             	lea    0x4(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800641:	b8 10 00 00 00       	mov    $0x10,%eax
  800646:	eb 15                	jmp    80065d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800652:	8d 40 04             	lea    0x4(%eax),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800658:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065d:	83 ec 0c             	sub    $0xc,%esp
  800660:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800664:	57                   	push   %edi
  800665:	ff 75 e0             	pushl  -0x20(%ebp)
  800668:	50                   	push   %eax
  800669:	51                   	push   %ecx
  80066a:	52                   	push   %edx
  80066b:	89 da                	mov    %ebx,%edx
  80066d:	89 f0                	mov    %esi,%eax
  80066f:	e8 f1 fa ff ff       	call   800165 <printnum>
			break;
  800674:	83 c4 20             	add    $0x20,%esp
  800677:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067a:	e9 f5 fb ff ff       	jmp    800274 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	52                   	push   %edx
  800684:	ff d6                	call   *%esi
			break;
  800686:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068c:	e9 e3 fb ff ff       	jmp    800274 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 25                	push   $0x25
  800697:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	eb 03                	jmp    8006a1 <vprintfmt+0x453>
  80069e:	83 ef 01             	sub    $0x1,%edi
  8006a1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a5:	75 f7                	jne    80069e <vprintfmt+0x450>
  8006a7:	e9 c8 fb ff ff       	jmp    800274 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006af:	5b                   	pop    %ebx
  8006b0:	5e                   	pop    %esi
  8006b1:	5f                   	pop    %edi
  8006b2:	5d                   	pop    %ebp
  8006b3:	c3                   	ret    

008006b4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	83 ec 18             	sub    $0x18,%esp
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	74 26                	je     8006fb <vsnprintf+0x47>
  8006d5:	85 d2                	test   %edx,%edx
  8006d7:	7e 22                	jle    8006fb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d9:	ff 75 14             	pushl  0x14(%ebp)
  8006dc:	ff 75 10             	pushl  0x10(%ebp)
  8006df:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e2:	50                   	push   %eax
  8006e3:	68 14 02 80 00       	push   $0x800214
  8006e8:	e8 61 fb ff ff       	call   80024e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	eb 05                	jmp    800700 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800708:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070b:	50                   	push   %eax
  80070c:	ff 75 10             	pushl  0x10(%ebp)
  80070f:	ff 75 0c             	pushl  0xc(%ebp)
  800712:	ff 75 08             	pushl  0x8(%ebp)
  800715:	e8 9a ff ff ff       	call   8006b4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	b8 00 00 00 00       	mov    $0x0,%eax
  800727:	eb 03                	jmp    80072c <strlen+0x10>
		n++;
  800729:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800730:	75 f7                	jne    800729 <strlen+0xd>
		n++;
	return n;
}
  800732:	5d                   	pop    %ebp
  800733:	c3                   	ret    

00800734 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073d:	ba 00 00 00 00       	mov    $0x0,%edx
  800742:	eb 03                	jmp    800747 <strnlen+0x13>
		n++;
  800744:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	39 c2                	cmp    %eax,%edx
  800749:	74 08                	je     800753 <strnlen+0x1f>
  80074b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80074f:	75 f3                	jne    800744 <strnlen+0x10>
  800751:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	53                   	push   %ebx
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075f:	89 c2                	mov    %eax,%edx
  800761:	83 c2 01             	add    $0x1,%edx
  800764:	83 c1 01             	add    $0x1,%ecx
  800767:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076e:	84 db                	test   %bl,%bl
  800770:	75 ef                	jne    800761 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800772:	5b                   	pop    %ebx
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	53                   	push   %ebx
  800779:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077c:	53                   	push   %ebx
  80077d:	e8 9a ff ff ff       	call   80071c <strlen>
  800782:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800785:	ff 75 0c             	pushl  0xc(%ebp)
  800788:	01 d8                	add    %ebx,%eax
  80078a:	50                   	push   %eax
  80078b:	e8 c5 ff ff ff       	call   800755 <strcpy>
	return dst;
}
  800790:	89 d8                	mov    %ebx,%eax
  800792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	56                   	push   %esi
  80079b:	53                   	push   %ebx
  80079c:	8b 75 08             	mov    0x8(%ebp),%esi
  80079f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a2:	89 f3                	mov    %esi,%ebx
  8007a4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a7:	89 f2                	mov    %esi,%edx
  8007a9:	eb 0f                	jmp    8007ba <strncpy+0x23>
		*dst++ = *src;
  8007ab:	83 c2 01             	add    $0x1,%edx
  8007ae:	0f b6 01             	movzbl (%ecx),%eax
  8007b1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ba:	39 da                	cmp    %ebx,%edx
  8007bc:	75 ed                	jne    8007ab <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007be:	89 f0                	mov    %esi,%eax
  8007c0:	5b                   	pop    %ebx
  8007c1:	5e                   	pop    %esi
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	56                   	push   %esi
  8007c8:	53                   	push   %ebx
  8007c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cf:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d4:	85 d2                	test   %edx,%edx
  8007d6:	74 21                	je     8007f9 <strlcpy+0x35>
  8007d8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007dc:	89 f2                	mov    %esi,%edx
  8007de:	eb 09                	jmp    8007e9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	83 c1 01             	add    $0x1,%ecx
  8007e6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e9:	39 c2                	cmp    %eax,%edx
  8007eb:	74 09                	je     8007f6 <strlcpy+0x32>
  8007ed:	0f b6 19             	movzbl (%ecx),%ebx
  8007f0:	84 db                	test   %bl,%bl
  8007f2:	75 ec                	jne    8007e0 <strlcpy+0x1c>
  8007f4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f9:	29 f0                	sub    %esi,%eax
}
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800808:	eb 06                	jmp    800810 <strcmp+0x11>
		p++, q++;
  80080a:	83 c1 01             	add    $0x1,%ecx
  80080d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800810:	0f b6 01             	movzbl (%ecx),%eax
  800813:	84 c0                	test   %al,%al
  800815:	74 04                	je     80081b <strcmp+0x1c>
  800817:	3a 02                	cmp    (%edx),%al
  800819:	74 ef                	je     80080a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081b:	0f b6 c0             	movzbl %al,%eax
  80081e:	0f b6 12             	movzbl (%edx),%edx
  800821:	29 d0                	sub    %edx,%eax
}
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082f:	89 c3                	mov    %eax,%ebx
  800831:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800834:	eb 06                	jmp    80083c <strncmp+0x17>
		n--, p++, q++;
  800836:	83 c0 01             	add    $0x1,%eax
  800839:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083c:	39 d8                	cmp    %ebx,%eax
  80083e:	74 15                	je     800855 <strncmp+0x30>
  800840:	0f b6 08             	movzbl (%eax),%ecx
  800843:	84 c9                	test   %cl,%cl
  800845:	74 04                	je     80084b <strncmp+0x26>
  800847:	3a 0a                	cmp    (%edx),%cl
  800849:	74 eb                	je     800836 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 00             	movzbl (%eax),%eax
  80084e:	0f b6 12             	movzbl (%edx),%edx
  800851:	29 d0                	sub    %edx,%eax
  800853:	eb 05                	jmp    80085a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085a:	5b                   	pop    %ebx
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800867:	eb 07                	jmp    800870 <strchr+0x13>
		if (*s == c)
  800869:	38 ca                	cmp    %cl,%dl
  80086b:	74 0f                	je     80087c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086d:	83 c0 01             	add    $0x1,%eax
  800870:	0f b6 10             	movzbl (%eax),%edx
  800873:	84 d2                	test   %dl,%dl
  800875:	75 f2                	jne    800869 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800888:	eb 03                	jmp    80088d <strfind+0xf>
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	74 04                	je     800898 <strfind+0x1a>
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f2                	jne    80088a <strfind+0xc>
			break;
	return (char *) s;
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a6:	85 c9                	test   %ecx,%ecx
  8008a8:	74 36                	je     8008e0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008aa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b0:	75 28                	jne    8008da <memset+0x40>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 23                	jne    8008da <memset+0x40>
		c &= 0xFF;
  8008b7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bb:	89 d3                	mov    %edx,%ebx
  8008bd:	c1 e3 08             	shl    $0x8,%ebx
  8008c0:	89 d6                	mov    %edx,%esi
  8008c2:	c1 e6 18             	shl    $0x18,%esi
  8008c5:	89 d0                	mov    %edx,%eax
  8008c7:	c1 e0 10             	shl    $0x10,%eax
  8008ca:	09 f0                	or     %esi,%eax
  8008cc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ce:	89 d8                	mov    %ebx,%eax
  8008d0:	09 d0                	or     %edx,%eax
  8008d2:	c1 e9 02             	shr    $0x2,%ecx
  8008d5:	fc                   	cld    
  8008d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d8:	eb 06                	jmp    8008e0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dd:	fc                   	cld    
  8008de:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e0:	89 f8                	mov    %edi,%eax
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f5:	39 c6                	cmp    %eax,%esi
  8008f7:	73 35                	jae    80092e <memmove+0x47>
  8008f9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fc:	39 d0                	cmp    %edx,%eax
  8008fe:	73 2e                	jae    80092e <memmove+0x47>
		s += n;
		d += n;
  800900:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800903:	89 d6                	mov    %edx,%esi
  800905:	09 fe                	or     %edi,%esi
  800907:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090d:	75 13                	jne    800922 <memmove+0x3b>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	75 0e                	jne    800922 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800914:	83 ef 04             	sub    $0x4,%edi
  800917:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091a:	c1 e9 02             	shr    $0x2,%ecx
  80091d:	fd                   	std    
  80091e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800920:	eb 09                	jmp    80092b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800922:	83 ef 01             	sub    $0x1,%edi
  800925:	8d 72 ff             	lea    -0x1(%edx),%esi
  800928:	fd                   	std    
  800929:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092b:	fc                   	cld    
  80092c:	eb 1d                	jmp    80094b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	89 f2                	mov    %esi,%edx
  800930:	09 c2                	or     %eax,%edx
  800932:	f6 c2 03             	test   $0x3,%dl
  800935:	75 0f                	jne    800946 <memmove+0x5f>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 0a                	jne    800946 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093c:	c1 e9 02             	shr    $0x2,%ecx
  80093f:	89 c7                	mov    %eax,%edi
  800941:	fc                   	cld    
  800942:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800944:	eb 05                	jmp    80094b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800946:	89 c7                	mov    %eax,%edi
  800948:	fc                   	cld    
  800949:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094b:	5e                   	pop    %esi
  80094c:	5f                   	pop    %edi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800952:	ff 75 10             	pushl  0x10(%ebp)
  800955:	ff 75 0c             	pushl  0xc(%ebp)
  800958:	ff 75 08             	pushl  0x8(%ebp)
  80095b:	e8 87 ff ff ff       	call   8008e7 <memmove>
}
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096d:	89 c6                	mov    %eax,%esi
  80096f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800972:	eb 1a                	jmp    80098e <memcmp+0x2c>
		if (*s1 != *s2)
  800974:	0f b6 08             	movzbl (%eax),%ecx
  800977:	0f b6 1a             	movzbl (%edx),%ebx
  80097a:	38 d9                	cmp    %bl,%cl
  80097c:	74 0a                	je     800988 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80097e:	0f b6 c1             	movzbl %cl,%eax
  800981:	0f b6 db             	movzbl %bl,%ebx
  800984:	29 d8                	sub    %ebx,%eax
  800986:	eb 0f                	jmp    800997 <memcmp+0x35>
		s1++, s2++;
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098e:	39 f0                	cmp    %esi,%eax
  800990:	75 e2                	jne    800974 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a2:	89 c1                	mov    %eax,%ecx
  8009a4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ab:	eb 0a                	jmp    8009b7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	39 da                	cmp    %ebx,%edx
  8009b2:	74 07                	je     8009bb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b4:	83 c0 01             	add    $0x1,%eax
  8009b7:	39 c8                	cmp    %ecx,%eax
  8009b9:	72 f2                	jb     8009ad <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bb:	5b                   	pop    %ebx
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	57                   	push   %edi
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ca:	eb 03                	jmp    8009cf <strtol+0x11>
		s++;
  8009cc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cf:	0f b6 01             	movzbl (%ecx),%eax
  8009d2:	3c 20                	cmp    $0x20,%al
  8009d4:	74 f6                	je     8009cc <strtol+0xe>
  8009d6:	3c 09                	cmp    $0x9,%al
  8009d8:	74 f2                	je     8009cc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009da:	3c 2b                	cmp    $0x2b,%al
  8009dc:	75 0a                	jne    8009e8 <strtol+0x2a>
		s++;
  8009de:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e6:	eb 11                	jmp    8009f9 <strtol+0x3b>
  8009e8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ed:	3c 2d                	cmp    $0x2d,%al
  8009ef:	75 08                	jne    8009f9 <strtol+0x3b>
		s++, neg = 1;
  8009f1:	83 c1 01             	add    $0x1,%ecx
  8009f4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ff:	75 15                	jne    800a16 <strtol+0x58>
  800a01:	80 39 30             	cmpb   $0x30,(%ecx)
  800a04:	75 10                	jne    800a16 <strtol+0x58>
  800a06:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0a:	75 7c                	jne    800a88 <strtol+0xca>
		s += 2, base = 16;
  800a0c:	83 c1 02             	add    $0x2,%ecx
  800a0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a14:	eb 16                	jmp    800a2c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a16:	85 db                	test   %ebx,%ebx
  800a18:	75 12                	jne    800a2c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 08                	jne    800a2c <strtol+0x6e>
		s++, base = 8;
  800a24:	83 c1 01             	add    $0x1,%ecx
  800a27:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a34:	0f b6 11             	movzbl (%ecx),%edx
  800a37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3a:	89 f3                	mov    %esi,%ebx
  800a3c:	80 fb 09             	cmp    $0x9,%bl
  800a3f:	77 08                	ja     800a49 <strtol+0x8b>
			dig = *s - '0';
  800a41:	0f be d2             	movsbl %dl,%edx
  800a44:	83 ea 30             	sub    $0x30,%edx
  800a47:	eb 22                	jmp    800a6b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a49:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4c:	89 f3                	mov    %esi,%ebx
  800a4e:	80 fb 19             	cmp    $0x19,%bl
  800a51:	77 08                	ja     800a5b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a53:	0f be d2             	movsbl %dl,%edx
  800a56:	83 ea 57             	sub    $0x57,%edx
  800a59:	eb 10                	jmp    800a6b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a5e:	89 f3                	mov    %esi,%ebx
  800a60:	80 fb 19             	cmp    $0x19,%bl
  800a63:	77 16                	ja     800a7b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a65:	0f be d2             	movsbl %dl,%edx
  800a68:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a6e:	7d 0b                	jge    800a7b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a77:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a79:	eb b9                	jmp    800a34 <strtol+0x76>

	if (endptr)
  800a7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7f:	74 0d                	je     800a8e <strtol+0xd0>
		*endptr = (char *) s;
  800a81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a84:	89 0e                	mov    %ecx,(%esi)
  800a86:	eb 06                	jmp    800a8e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a88:	85 db                	test   %ebx,%ebx
  800a8a:	74 98                	je     800a24 <strtol+0x66>
  800a8c:	eb 9e                	jmp    800a2c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a8e:	89 c2                	mov    %eax,%edx
  800a90:	f7 da                	neg    %edx
  800a92:	85 ff                	test   %edi,%edi
  800a94:	0f 45 c2             	cmovne %edx,%eax
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800aad:	89 c3                	mov    %eax,%ebx
  800aaf:	89 c7                	mov    %eax,%edi
  800ab1:	89 c6                	mov    %eax,%esi
  800ab3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cgetc>:

int
sys_cgetc(void)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aca:	89 d1                	mov    %edx,%ecx
  800acc:	89 d3                	mov    %edx,%ebx
  800ace:	89 d7                	mov    %edx,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae7:	b8 03 00 00 00       	mov    $0x3,%eax
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	89 cb                	mov    %ecx,%ebx
  800af1:	89 cf                	mov    %ecx,%edi
  800af3:	89 ce                	mov    %ecx,%esi
  800af5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af7:	85 c0                	test   %eax,%eax
  800af9:	7e 17                	jle    800b12 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	50                   	push   %eax
  800aff:	6a 03                	push   $0x3
  800b01:	68 9f 21 80 00       	push   $0x80219f
  800b06:	6a 23                	push   $0x23
  800b08:	68 bc 21 80 00       	push   $0x8021bc
  800b0d:	e8 27 0f 00 00       	call   801a39 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_yield>:

void
sys_yield(void)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b49:	89 d1                	mov    %edx,%ecx
  800b4b:	89 d3                	mov    %edx,%ebx
  800b4d:	89 d7                	mov    %edx,%edi
  800b4f:	89 d6                	mov    %edx,%esi
  800b51:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	be 00 00 00 00       	mov    $0x0,%esi
  800b66:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b74:	89 f7                	mov    %esi,%edi
  800b76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	7e 17                	jle    800b93 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	50                   	push   %eax
  800b80:	6a 04                	push   $0x4
  800b82:	68 9f 21 80 00       	push   $0x80219f
  800b87:	6a 23                	push   $0x23
  800b89:	68 bc 21 80 00       	push   $0x8021bc
  800b8e:	e8 a6 0e 00 00       	call   801a39 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb5:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	7e 17                	jle    800bd5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 05                	push   $0x5
  800bc4:	68 9f 21 80 00       	push   $0x80219f
  800bc9:	6a 23                	push   $0x23
  800bcb:	68 bc 21 80 00       	push   $0x8021bc
  800bd0:	e8 64 0e 00 00       	call   801a39 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800beb:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	89 df                	mov    %ebx,%edi
  800bf8:	89 de                	mov    %ebx,%esi
  800bfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7e 17                	jle    800c17 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 06                	push   $0x6
  800c06:	68 9f 21 80 00       	push   $0x80219f
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 bc 21 80 00       	push   $0x8021bc
  800c12:	e8 22 0e 00 00       	call   801a39 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	89 df                	mov    %ebx,%edi
  800c3a:	89 de                	mov    %ebx,%esi
  800c3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 08                	push   $0x8
  800c48:	68 9f 21 80 00       	push   $0x80219f
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 bc 21 80 00       	push   $0x8021bc
  800c54:	e8 e0 0d 00 00       	call   801a39 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	89 df                	mov    %ebx,%edi
  800c7c:	89 de                	mov    %ebx,%esi
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 09                	push   $0x9
  800c8a:	68 9f 21 80 00       	push   $0x80219f
  800c8f:	6a 23                	push   $0x23
  800c91:	68 bc 21 80 00       	push   $0x8021bc
  800c96:	e8 9e 0d 00 00       	call   801a39 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 0a                	push   $0xa
  800ccc:	68 9f 21 80 00       	push   $0x80219f
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 bc 21 80 00       	push   $0x8021bc
  800cd8:	e8 5c 0d 00 00       	call   801a39 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	be 00 00 00 00       	mov    $0x0,%esi
  800cf0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d16:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 cb                	mov    %ecx,%ebx
  800d20:	89 cf                	mov    %ecx,%edi
  800d22:	89 ce                	mov    %ecx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 0d                	push   $0xd
  800d30:	68 9f 21 80 00       	push   $0x80219f
  800d35:	6a 23                	push   $0x23
  800d37:	68 bc 21 80 00       	push   $0x8021bc
  800d3c:	e8 f8 0c 00 00       	call   801a39 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	05 00 00 00 30       	add    $0x30000000,%eax
  800d54:	c1 e8 0c             	shr    $0xc,%eax
}
  800d57:	5d                   	pop    %ebp
  800d58:	c3                   	ret    

00800d59 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	05 00 00 00 30       	add    $0x30000000,%eax
  800d64:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d69:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d76:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d7b:	89 c2                	mov    %eax,%edx
  800d7d:	c1 ea 16             	shr    $0x16,%edx
  800d80:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d87:	f6 c2 01             	test   $0x1,%dl
  800d8a:	74 11                	je     800d9d <fd_alloc+0x2d>
  800d8c:	89 c2                	mov    %eax,%edx
  800d8e:	c1 ea 0c             	shr    $0xc,%edx
  800d91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d98:	f6 c2 01             	test   $0x1,%dl
  800d9b:	75 09                	jne    800da6 <fd_alloc+0x36>
			*fd_store = fd;
  800d9d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800da4:	eb 17                	jmp    800dbd <fd_alloc+0x4d>
  800da6:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dab:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db0:	75 c9                	jne    800d7b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800db8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dc5:	83 f8 1f             	cmp    $0x1f,%eax
  800dc8:	77 36                	ja     800e00 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dca:	c1 e0 0c             	shl    $0xc,%eax
  800dcd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd2:	89 c2                	mov    %eax,%edx
  800dd4:	c1 ea 16             	shr    $0x16,%edx
  800dd7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dde:	f6 c2 01             	test   $0x1,%dl
  800de1:	74 24                	je     800e07 <fd_lookup+0x48>
  800de3:	89 c2                	mov    %eax,%edx
  800de5:	c1 ea 0c             	shr    $0xc,%edx
  800de8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800def:	f6 c2 01             	test   $0x1,%dl
  800df2:	74 1a                	je     800e0e <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800df4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df7:	89 02                	mov    %eax,(%edx)
	return 0;
  800df9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dfe:	eb 13                	jmp    800e13 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e00:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e05:	eb 0c                	jmp    800e13 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e07:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0c:	eb 05                	jmp    800e13 <fd_lookup+0x54>
  800e0e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	83 ec 08             	sub    $0x8,%esp
  800e1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1e:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e23:	eb 13                	jmp    800e38 <dev_lookup+0x23>
  800e25:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e28:	39 08                	cmp    %ecx,(%eax)
  800e2a:	75 0c                	jne    800e38 <dev_lookup+0x23>
			*dev = devtab[i];
  800e2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e31:	b8 00 00 00 00       	mov    $0x0,%eax
  800e36:	eb 2e                	jmp    800e66 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e38:	8b 02                	mov    (%edx),%eax
  800e3a:	85 c0                	test   %eax,%eax
  800e3c:	75 e7                	jne    800e25 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e3e:	a1 04 40 80 00       	mov    0x804004,%eax
  800e43:	8b 40 48             	mov    0x48(%eax),%eax
  800e46:	83 ec 04             	sub    $0x4,%esp
  800e49:	51                   	push   %ecx
  800e4a:	50                   	push   %eax
  800e4b:	68 cc 21 80 00       	push   $0x8021cc
  800e50:	e8 fc f2 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800e55:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e58:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e5e:	83 c4 10             	add    $0x10,%esp
  800e61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e66:	c9                   	leave  
  800e67:	c3                   	ret    

00800e68 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 10             	sub    $0x10,%esp
  800e70:	8b 75 08             	mov    0x8(%ebp),%esi
  800e73:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e76:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e79:	50                   	push   %eax
  800e7a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e80:	c1 e8 0c             	shr    $0xc,%eax
  800e83:	50                   	push   %eax
  800e84:	e8 36 ff ff ff       	call   800dbf <fd_lookup>
  800e89:	83 c4 08             	add    $0x8,%esp
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	78 05                	js     800e95 <fd_close+0x2d>
	    || fd != fd2)
  800e90:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e93:	74 0c                	je     800ea1 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e95:	84 db                	test   %bl,%bl
  800e97:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9c:	0f 44 c2             	cmove  %edx,%eax
  800e9f:	eb 41                	jmp    800ee2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea1:	83 ec 08             	sub    $0x8,%esp
  800ea4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ea7:	50                   	push   %eax
  800ea8:	ff 36                	pushl  (%esi)
  800eaa:	e8 66 ff ff ff       	call   800e15 <dev_lookup>
  800eaf:	89 c3                	mov    %eax,%ebx
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	78 1a                	js     800ed2 <fd_close+0x6a>
		if (dev->dev_close)
  800eb8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ebe:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	74 0b                	je     800ed2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ec7:	83 ec 0c             	sub    $0xc,%esp
  800eca:	56                   	push   %esi
  800ecb:	ff d0                	call   *%eax
  800ecd:	89 c3                	mov    %eax,%ebx
  800ecf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed2:	83 ec 08             	sub    $0x8,%esp
  800ed5:	56                   	push   %esi
  800ed6:	6a 00                	push   $0x0
  800ed8:	e8 00 fd ff ff       	call   800bdd <sys_page_unmap>
	return r;
  800edd:	83 c4 10             	add    $0x10,%esp
  800ee0:	89 d8                	mov    %ebx,%eax
}
  800ee2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5d                   	pop    %ebp
  800ee8:	c3                   	ret    

00800ee9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ee9:	55                   	push   %ebp
  800eea:	89 e5                	mov    %esp,%ebp
  800eec:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef2:	50                   	push   %eax
  800ef3:	ff 75 08             	pushl  0x8(%ebp)
  800ef6:	e8 c4 fe ff ff       	call   800dbf <fd_lookup>
  800efb:	83 c4 08             	add    $0x8,%esp
  800efe:	85 c0                	test   %eax,%eax
  800f00:	78 10                	js     800f12 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f02:	83 ec 08             	sub    $0x8,%esp
  800f05:	6a 01                	push   $0x1
  800f07:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0a:	e8 59 ff ff ff       	call   800e68 <fd_close>
  800f0f:	83 c4 10             	add    $0x10,%esp
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <close_all>:

void
close_all(void)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	53                   	push   %ebx
  800f18:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f1b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	53                   	push   %ebx
  800f24:	e8 c0 ff ff ff       	call   800ee9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f29:	83 c3 01             	add    $0x1,%ebx
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	83 fb 20             	cmp    $0x20,%ebx
  800f32:	75 ec                	jne    800f20 <close_all+0xc>
		close(i);
}
  800f34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f37:	c9                   	leave  
  800f38:	c3                   	ret    

00800f39 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
  800f3f:	83 ec 2c             	sub    $0x2c,%esp
  800f42:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f45:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f48:	50                   	push   %eax
  800f49:	ff 75 08             	pushl  0x8(%ebp)
  800f4c:	e8 6e fe ff ff       	call   800dbf <fd_lookup>
  800f51:	83 c4 08             	add    $0x8,%esp
  800f54:	85 c0                	test   %eax,%eax
  800f56:	0f 88 c1 00 00 00    	js     80101d <dup+0xe4>
		return r;
	close(newfdnum);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	56                   	push   %esi
  800f60:	e8 84 ff ff ff       	call   800ee9 <close>

	newfd = INDEX2FD(newfdnum);
  800f65:	89 f3                	mov    %esi,%ebx
  800f67:	c1 e3 0c             	shl    $0xc,%ebx
  800f6a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f70:	83 c4 04             	add    $0x4,%esp
  800f73:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f76:	e8 de fd ff ff       	call   800d59 <fd2data>
  800f7b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f7d:	89 1c 24             	mov    %ebx,(%esp)
  800f80:	e8 d4 fd ff ff       	call   800d59 <fd2data>
  800f85:	83 c4 10             	add    $0x10,%esp
  800f88:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f8b:	89 f8                	mov    %edi,%eax
  800f8d:	c1 e8 16             	shr    $0x16,%eax
  800f90:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f97:	a8 01                	test   $0x1,%al
  800f99:	74 37                	je     800fd2 <dup+0x99>
  800f9b:	89 f8                	mov    %edi,%eax
  800f9d:	c1 e8 0c             	shr    $0xc,%eax
  800fa0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa7:	f6 c2 01             	test   $0x1,%dl
  800faa:	74 26                	je     800fd2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fac:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb3:	83 ec 0c             	sub    $0xc,%esp
  800fb6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fbb:	50                   	push   %eax
  800fbc:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fbf:	6a 00                	push   $0x0
  800fc1:	57                   	push   %edi
  800fc2:	6a 00                	push   $0x0
  800fc4:	e8 d2 fb ff ff       	call   800b9b <sys_page_map>
  800fc9:	89 c7                	mov    %eax,%edi
  800fcb:	83 c4 20             	add    $0x20,%esp
  800fce:	85 c0                	test   %eax,%eax
  800fd0:	78 2e                	js     801000 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fd5:	89 d0                	mov    %edx,%eax
  800fd7:	c1 e8 0c             	shr    $0xc,%eax
  800fda:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe1:	83 ec 0c             	sub    $0xc,%esp
  800fe4:	25 07 0e 00 00       	and    $0xe07,%eax
  800fe9:	50                   	push   %eax
  800fea:	53                   	push   %ebx
  800feb:	6a 00                	push   $0x0
  800fed:	52                   	push   %edx
  800fee:	6a 00                	push   $0x0
  800ff0:	e8 a6 fb ff ff       	call   800b9b <sys_page_map>
  800ff5:	89 c7                	mov    %eax,%edi
  800ff7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800ffa:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ffc:	85 ff                	test   %edi,%edi
  800ffe:	79 1d                	jns    80101d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801000:	83 ec 08             	sub    $0x8,%esp
  801003:	53                   	push   %ebx
  801004:	6a 00                	push   $0x0
  801006:	e8 d2 fb ff ff       	call   800bdd <sys_page_unmap>
	sys_page_unmap(0, nva);
  80100b:	83 c4 08             	add    $0x8,%esp
  80100e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801011:	6a 00                	push   $0x0
  801013:	e8 c5 fb ff ff       	call   800bdd <sys_page_unmap>
	return r;
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	89 f8                	mov    %edi,%eax
}
  80101d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	53                   	push   %ebx
  801029:	83 ec 14             	sub    $0x14,%esp
  80102c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80102f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801032:	50                   	push   %eax
  801033:	53                   	push   %ebx
  801034:	e8 86 fd ff ff       	call   800dbf <fd_lookup>
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	89 c2                	mov    %eax,%edx
  80103e:	85 c0                	test   %eax,%eax
  801040:	78 6d                	js     8010af <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801042:	83 ec 08             	sub    $0x8,%esp
  801045:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801048:	50                   	push   %eax
  801049:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80104c:	ff 30                	pushl  (%eax)
  80104e:	e8 c2 fd ff ff       	call   800e15 <dev_lookup>
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	78 4c                	js     8010a6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80105a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80105d:	8b 42 08             	mov    0x8(%edx),%eax
  801060:	83 e0 03             	and    $0x3,%eax
  801063:	83 f8 01             	cmp    $0x1,%eax
  801066:	75 21                	jne    801089 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801068:	a1 04 40 80 00       	mov    0x804004,%eax
  80106d:	8b 40 48             	mov    0x48(%eax),%eax
  801070:	83 ec 04             	sub    $0x4,%esp
  801073:	53                   	push   %ebx
  801074:	50                   	push   %eax
  801075:	68 0d 22 80 00       	push   $0x80220d
  80107a:	e8 d2 f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  80107f:	83 c4 10             	add    $0x10,%esp
  801082:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801087:	eb 26                	jmp    8010af <read+0x8a>
	}
	if (!dev->dev_read)
  801089:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108c:	8b 40 08             	mov    0x8(%eax),%eax
  80108f:	85 c0                	test   %eax,%eax
  801091:	74 17                	je     8010aa <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801093:	83 ec 04             	sub    $0x4,%esp
  801096:	ff 75 10             	pushl  0x10(%ebp)
  801099:	ff 75 0c             	pushl  0xc(%ebp)
  80109c:	52                   	push   %edx
  80109d:	ff d0                	call   *%eax
  80109f:	89 c2                	mov    %eax,%edx
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	eb 09                	jmp    8010af <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a6:	89 c2                	mov    %eax,%edx
  8010a8:	eb 05                	jmp    8010af <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010aa:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010af:	89 d0                	mov    %edx,%eax
  8010b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b4:	c9                   	leave  
  8010b5:	c3                   	ret    

008010b6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	57                   	push   %edi
  8010ba:	56                   	push   %esi
  8010bb:	53                   	push   %ebx
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ca:	eb 21                	jmp    8010ed <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010cc:	83 ec 04             	sub    $0x4,%esp
  8010cf:	89 f0                	mov    %esi,%eax
  8010d1:	29 d8                	sub    %ebx,%eax
  8010d3:	50                   	push   %eax
  8010d4:	89 d8                	mov    %ebx,%eax
  8010d6:	03 45 0c             	add    0xc(%ebp),%eax
  8010d9:	50                   	push   %eax
  8010da:	57                   	push   %edi
  8010db:	e8 45 ff ff ff       	call   801025 <read>
		if (m < 0)
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 10                	js     8010f7 <readn+0x41>
			return m;
		if (m == 0)
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	74 0a                	je     8010f5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010eb:	01 c3                	add    %eax,%ebx
  8010ed:	39 f3                	cmp    %esi,%ebx
  8010ef:	72 db                	jb     8010cc <readn+0x16>
  8010f1:	89 d8                	mov    %ebx,%eax
  8010f3:	eb 02                	jmp    8010f7 <readn+0x41>
  8010f5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fa:	5b                   	pop    %ebx
  8010fb:	5e                   	pop    %esi
  8010fc:	5f                   	pop    %edi
  8010fd:	5d                   	pop    %ebp
  8010fe:	c3                   	ret    

008010ff <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	53                   	push   %ebx
  801103:	83 ec 14             	sub    $0x14,%esp
  801106:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801109:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	53                   	push   %ebx
  80110e:	e8 ac fc ff ff       	call   800dbf <fd_lookup>
  801113:	83 c4 08             	add    $0x8,%esp
  801116:	89 c2                	mov    %eax,%edx
  801118:	85 c0                	test   %eax,%eax
  80111a:	78 68                	js     801184 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111c:	83 ec 08             	sub    $0x8,%esp
  80111f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801122:	50                   	push   %eax
  801123:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801126:	ff 30                	pushl  (%eax)
  801128:	e8 e8 fc ff ff       	call   800e15 <dev_lookup>
  80112d:	83 c4 10             	add    $0x10,%esp
  801130:	85 c0                	test   %eax,%eax
  801132:	78 47                	js     80117b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801134:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801137:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80113b:	75 21                	jne    80115e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80113d:	a1 04 40 80 00       	mov    0x804004,%eax
  801142:	8b 40 48             	mov    0x48(%eax),%eax
  801145:	83 ec 04             	sub    $0x4,%esp
  801148:	53                   	push   %ebx
  801149:	50                   	push   %eax
  80114a:	68 29 22 80 00       	push   $0x802229
  80114f:	e8 fd ef ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80115c:	eb 26                	jmp    801184 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80115e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801161:	8b 52 0c             	mov    0xc(%edx),%edx
  801164:	85 d2                	test   %edx,%edx
  801166:	74 17                	je     80117f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	ff 75 10             	pushl  0x10(%ebp)
  80116e:	ff 75 0c             	pushl  0xc(%ebp)
  801171:	50                   	push   %eax
  801172:	ff d2                	call   *%edx
  801174:	89 c2                	mov    %eax,%edx
  801176:	83 c4 10             	add    $0x10,%esp
  801179:	eb 09                	jmp    801184 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117b:	89 c2                	mov    %eax,%edx
  80117d:	eb 05                	jmp    801184 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80117f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801184:	89 d0                	mov    %edx,%eax
  801186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801189:	c9                   	leave  
  80118a:	c3                   	ret    

0080118b <seek>:

int
seek(int fdnum, off_t offset)
{
  80118b:	55                   	push   %ebp
  80118c:	89 e5                	mov    %esp,%ebp
  80118e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801191:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	ff 75 08             	pushl  0x8(%ebp)
  801198:	e8 22 fc ff ff       	call   800dbf <fd_lookup>
  80119d:	83 c4 08             	add    $0x8,%esp
  8011a0:	85 c0                	test   %eax,%eax
  8011a2:	78 0e                	js     8011b2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011aa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b2:	c9                   	leave  
  8011b3:	c3                   	ret    

008011b4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
  8011b7:	53                   	push   %ebx
  8011b8:	83 ec 14             	sub    $0x14,%esp
  8011bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	53                   	push   %ebx
  8011c3:	e8 f7 fb ff ff       	call   800dbf <fd_lookup>
  8011c8:	83 c4 08             	add    $0x8,%esp
  8011cb:	89 c2                	mov    %eax,%edx
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	78 65                	js     801236 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d1:	83 ec 08             	sub    $0x8,%esp
  8011d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d7:	50                   	push   %eax
  8011d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011db:	ff 30                	pushl  (%eax)
  8011dd:	e8 33 fc ff ff       	call   800e15 <dev_lookup>
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	78 44                	js     80122d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f0:	75 21                	jne    801213 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011f2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011f7:	8b 40 48             	mov    0x48(%eax),%eax
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	53                   	push   %ebx
  8011fe:	50                   	push   %eax
  8011ff:	68 ec 21 80 00       	push   $0x8021ec
  801204:	e8 48 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801211:	eb 23                	jmp    801236 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801213:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801216:	8b 52 18             	mov    0x18(%edx),%edx
  801219:	85 d2                	test   %edx,%edx
  80121b:	74 14                	je     801231 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80121d:	83 ec 08             	sub    $0x8,%esp
  801220:	ff 75 0c             	pushl  0xc(%ebp)
  801223:	50                   	push   %eax
  801224:	ff d2                	call   *%edx
  801226:	89 c2                	mov    %eax,%edx
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	eb 09                	jmp    801236 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122d:	89 c2                	mov    %eax,%edx
  80122f:	eb 05                	jmp    801236 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801231:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801236:	89 d0                	mov    %edx,%eax
  801238:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    

0080123d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	53                   	push   %ebx
  801241:	83 ec 14             	sub    $0x14,%esp
  801244:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801247:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124a:	50                   	push   %eax
  80124b:	ff 75 08             	pushl  0x8(%ebp)
  80124e:	e8 6c fb ff ff       	call   800dbf <fd_lookup>
  801253:	83 c4 08             	add    $0x8,%esp
  801256:	89 c2                	mov    %eax,%edx
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 58                	js     8012b4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801262:	50                   	push   %eax
  801263:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801266:	ff 30                	pushl  (%eax)
  801268:	e8 a8 fb ff ff       	call   800e15 <dev_lookup>
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	78 37                	js     8012ab <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801274:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801277:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80127b:	74 32                	je     8012af <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80127d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801280:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801287:	00 00 00 
	stat->st_isdir = 0;
  80128a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801291:	00 00 00 
	stat->st_dev = dev;
  801294:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80129a:	83 ec 08             	sub    $0x8,%esp
  80129d:	53                   	push   %ebx
  80129e:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a1:	ff 50 14             	call   *0x14(%eax)
  8012a4:	89 c2                	mov    %eax,%edx
  8012a6:	83 c4 10             	add    $0x10,%esp
  8012a9:	eb 09                	jmp    8012b4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ab:	89 c2                	mov    %eax,%edx
  8012ad:	eb 05                	jmp    8012b4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012af:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012b4:	89 d0                	mov    %edx,%eax
  8012b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b9:	c9                   	leave  
  8012ba:	c3                   	ret    

008012bb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012bb:	55                   	push   %ebp
  8012bc:	89 e5                	mov    %esp,%ebp
  8012be:	56                   	push   %esi
  8012bf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	6a 00                	push   $0x0
  8012c5:	ff 75 08             	pushl  0x8(%ebp)
  8012c8:	e8 e9 01 00 00       	call   8014b6 <open>
  8012cd:	89 c3                	mov    %eax,%ebx
  8012cf:	83 c4 10             	add    $0x10,%esp
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	78 1b                	js     8012f1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	ff 75 0c             	pushl  0xc(%ebp)
  8012dc:	50                   	push   %eax
  8012dd:	e8 5b ff ff ff       	call   80123d <fstat>
  8012e2:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e4:	89 1c 24             	mov    %ebx,(%esp)
  8012e7:	e8 fd fb ff ff       	call   800ee9 <close>
	return r;
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	89 f0                	mov    %esi,%eax
}
  8012f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f4:	5b                   	pop    %ebx
  8012f5:	5e                   	pop    %esi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	89 c6                	mov    %eax,%esi
  8012ff:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801301:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801308:	75 12                	jne    80131c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80130a:	83 ec 0c             	sub    $0xc,%esp
  80130d:	6a 01                	push   $0x1
  80130f:	e8 41 08 00 00       	call   801b55 <ipc_find_env>
  801314:	a3 00 40 80 00       	mov    %eax,0x804000
  801319:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80131c:	6a 07                	push   $0x7
  80131e:	68 00 50 80 00       	push   $0x805000
  801323:	56                   	push   %esi
  801324:	ff 35 00 40 80 00    	pushl  0x804000
  80132a:	e8 d2 07 00 00       	call   801b01 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80132f:	83 c4 0c             	add    $0xc,%esp
  801332:	6a 00                	push   $0x0
  801334:	53                   	push   %ebx
  801335:	6a 00                	push   $0x0
  801337:	e8 43 07 00 00       	call   801a7f <ipc_recv>
}
  80133c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80133f:	5b                   	pop    %ebx
  801340:	5e                   	pop    %esi
  801341:	5d                   	pop    %ebp
  801342:	c3                   	ret    

00801343 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801349:	8b 45 08             	mov    0x8(%ebp),%eax
  80134c:	8b 40 0c             	mov    0xc(%eax),%eax
  80134f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801354:	8b 45 0c             	mov    0xc(%ebp),%eax
  801357:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80135c:	ba 00 00 00 00       	mov    $0x0,%edx
  801361:	b8 02 00 00 00       	mov    $0x2,%eax
  801366:	e8 8d ff ff ff       	call   8012f8 <fsipc>
}
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801373:	8b 45 08             	mov    0x8(%ebp),%eax
  801376:	8b 40 0c             	mov    0xc(%eax),%eax
  801379:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80137e:	ba 00 00 00 00       	mov    $0x0,%edx
  801383:	b8 06 00 00 00       	mov    $0x6,%eax
  801388:	e8 6b ff ff ff       	call   8012f8 <fsipc>
}
  80138d:	c9                   	leave  
  80138e:	c3                   	ret    

0080138f <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	53                   	push   %ebx
  801393:	83 ec 04             	sub    $0x4,%esp
  801396:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801399:	8b 45 08             	mov    0x8(%ebp),%eax
  80139c:	8b 40 0c             	mov    0xc(%eax),%eax
  80139f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a9:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ae:	e8 45 ff ff ff       	call   8012f8 <fsipc>
  8013b3:	85 c0                	test   %eax,%eax
  8013b5:	78 2c                	js     8013e3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	68 00 50 80 00       	push   $0x805000
  8013bf:	53                   	push   %ebx
  8013c0:	e8 90 f3 ff ff       	call   800755 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c5:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ca:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d0:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    

008013e8 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013e8:	55                   	push   %ebp
  8013e9:	89 e5                	mov    %esp,%ebp
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	8b 45 10             	mov    0x10(%ebp),%eax
  8013f1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013f6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013fb:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801401:	8b 52 0c             	mov    0xc(%edx),%edx
  801404:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  80140a:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  80140f:	50                   	push   %eax
  801410:	ff 75 0c             	pushl  0xc(%ebp)
  801413:	68 08 50 80 00       	push   $0x805008
  801418:	e8 ca f4 ff ff       	call   8008e7 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80141d:	ba 00 00 00 00       	mov    $0x0,%edx
  801422:	b8 04 00 00 00       	mov    $0x4,%eax
  801427:	e8 cc fe ff ff       	call   8012f8 <fsipc>
            return r;

    return r;
}
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	56                   	push   %esi
  801432:	53                   	push   %ebx
  801433:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801436:	8b 45 08             	mov    0x8(%ebp),%eax
  801439:	8b 40 0c             	mov    0xc(%eax),%eax
  80143c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801441:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801447:	ba 00 00 00 00       	mov    $0x0,%edx
  80144c:	b8 03 00 00 00       	mov    $0x3,%eax
  801451:	e8 a2 fe ff ff       	call   8012f8 <fsipc>
  801456:	89 c3                	mov    %eax,%ebx
  801458:	85 c0                	test   %eax,%eax
  80145a:	78 51                	js     8014ad <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80145c:	39 c6                	cmp    %eax,%esi
  80145e:	73 19                	jae    801479 <devfile_read+0x4b>
  801460:	68 58 22 80 00       	push   $0x802258
  801465:	68 5f 22 80 00       	push   $0x80225f
  80146a:	68 82 00 00 00       	push   $0x82
  80146f:	68 74 22 80 00       	push   $0x802274
  801474:	e8 c0 05 00 00       	call   801a39 <_panic>
	assert(r <= PGSIZE);
  801479:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80147e:	7e 19                	jle    801499 <devfile_read+0x6b>
  801480:	68 7f 22 80 00       	push   $0x80227f
  801485:	68 5f 22 80 00       	push   $0x80225f
  80148a:	68 83 00 00 00       	push   $0x83
  80148f:	68 74 22 80 00       	push   $0x802274
  801494:	e8 a0 05 00 00       	call   801a39 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801499:	83 ec 04             	sub    $0x4,%esp
  80149c:	50                   	push   %eax
  80149d:	68 00 50 80 00       	push   $0x805000
  8014a2:	ff 75 0c             	pushl  0xc(%ebp)
  8014a5:	e8 3d f4 ff ff       	call   8008e7 <memmove>
	return r;
  8014aa:	83 c4 10             	add    $0x10,%esp
}
  8014ad:	89 d8                	mov    %ebx,%eax
  8014af:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b2:	5b                   	pop    %ebx
  8014b3:	5e                   	pop    %esi
  8014b4:	5d                   	pop    %ebp
  8014b5:	c3                   	ret    

008014b6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b6:	55                   	push   %ebp
  8014b7:	89 e5                	mov    %esp,%ebp
  8014b9:	53                   	push   %ebx
  8014ba:	83 ec 20             	sub    $0x20,%esp
  8014bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c0:	53                   	push   %ebx
  8014c1:	e8 56 f2 ff ff       	call   80071c <strlen>
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ce:	7f 67                	jg     801537 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	e8 94 f8 ff ff       	call   800d70 <fd_alloc>
  8014dc:	83 c4 10             	add    $0x10,%esp
		return r;
  8014df:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 57                	js     80153c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	53                   	push   %ebx
  8014e9:	68 00 50 80 00       	push   $0x805000
  8014ee:	e8 62 f2 ff ff       	call   800755 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fe:	b8 01 00 00 00       	mov    $0x1,%eax
  801503:	e8 f0 fd ff ff       	call   8012f8 <fsipc>
  801508:	89 c3                	mov    %eax,%ebx
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	85 c0                	test   %eax,%eax
  80150f:	79 14                	jns    801525 <open+0x6f>
		fd_close(fd, 0);
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	6a 00                	push   $0x0
  801516:	ff 75 f4             	pushl  -0xc(%ebp)
  801519:	e8 4a f9 ff ff       	call   800e68 <fd_close>
		return r;
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	89 da                	mov    %ebx,%edx
  801523:	eb 17                	jmp    80153c <open+0x86>
	}

	return fd2num(fd);
  801525:	83 ec 0c             	sub    $0xc,%esp
  801528:	ff 75 f4             	pushl  -0xc(%ebp)
  80152b:	e8 19 f8 ff ff       	call   800d49 <fd2num>
  801530:	89 c2                	mov    %eax,%edx
  801532:	83 c4 10             	add    $0x10,%esp
  801535:	eb 05                	jmp    80153c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801537:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80153c:	89 d0                	mov    %edx,%eax
  80153e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801541:	c9                   	leave  
  801542:	c3                   	ret    

00801543 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801549:	ba 00 00 00 00       	mov    $0x0,%edx
  80154e:	b8 08 00 00 00       	mov    $0x8,%eax
  801553:	e8 a0 fd ff ff       	call   8012f8 <fsipc>
}
  801558:	c9                   	leave  
  801559:	c3                   	ret    

0080155a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	56                   	push   %esi
  80155e:	53                   	push   %ebx
  80155f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801562:	83 ec 0c             	sub    $0xc,%esp
  801565:	ff 75 08             	pushl  0x8(%ebp)
  801568:	e8 ec f7 ff ff       	call   800d59 <fd2data>
  80156d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	68 8b 22 80 00       	push   $0x80228b
  801577:	53                   	push   %ebx
  801578:	e8 d8 f1 ff ff       	call   800755 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80157d:	8b 46 04             	mov    0x4(%esi),%eax
  801580:	2b 06                	sub    (%esi),%eax
  801582:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801588:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80158f:	00 00 00 
	stat->st_dev = &devpipe;
  801592:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801599:	30 80 00 
	return 0;
}
  80159c:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a4:	5b                   	pop    %ebx
  8015a5:	5e                   	pop    %esi
  8015a6:	5d                   	pop    %ebp
  8015a7:	c3                   	ret    

008015a8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	53                   	push   %ebx
  8015ac:	83 ec 0c             	sub    $0xc,%esp
  8015af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015b2:	53                   	push   %ebx
  8015b3:	6a 00                	push   $0x0
  8015b5:	e8 23 f6 ff ff       	call   800bdd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015ba:	89 1c 24             	mov    %ebx,(%esp)
  8015bd:	e8 97 f7 ff ff       	call   800d59 <fd2data>
  8015c2:	83 c4 08             	add    $0x8,%esp
  8015c5:	50                   	push   %eax
  8015c6:	6a 00                	push   $0x0
  8015c8:	e8 10 f6 ff ff       	call   800bdd <sys_page_unmap>
}
  8015cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d0:	c9                   	leave  
  8015d1:	c3                   	ret    

008015d2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015d2:	55                   	push   %ebp
  8015d3:	89 e5                	mov    %esp,%ebp
  8015d5:	57                   	push   %edi
  8015d6:	56                   	push   %esi
  8015d7:	53                   	push   %ebx
  8015d8:	83 ec 1c             	sub    $0x1c,%esp
  8015db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015de:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015e8:	83 ec 0c             	sub    $0xc,%esp
  8015eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ee:	e8 9b 05 00 00       	call   801b8e <pageref>
  8015f3:	89 c3                	mov    %eax,%ebx
  8015f5:	89 3c 24             	mov    %edi,(%esp)
  8015f8:	e8 91 05 00 00       	call   801b8e <pageref>
  8015fd:	83 c4 10             	add    $0x10,%esp
  801600:	39 c3                	cmp    %eax,%ebx
  801602:	0f 94 c1             	sete   %cl
  801605:	0f b6 c9             	movzbl %cl,%ecx
  801608:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80160b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801611:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801614:	39 ce                	cmp    %ecx,%esi
  801616:	74 1b                	je     801633 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801618:	39 c3                	cmp    %eax,%ebx
  80161a:	75 c4                	jne    8015e0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80161c:	8b 42 58             	mov    0x58(%edx),%eax
  80161f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801622:	50                   	push   %eax
  801623:	56                   	push   %esi
  801624:	68 92 22 80 00       	push   $0x802292
  801629:	e8 23 eb ff ff       	call   800151 <cprintf>
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	eb ad                	jmp    8015e0 <_pipeisclosed+0xe>
	}
}
  801633:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801636:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801639:	5b                   	pop    %ebx
  80163a:	5e                   	pop    %esi
  80163b:	5f                   	pop    %edi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	57                   	push   %edi
  801642:	56                   	push   %esi
  801643:	53                   	push   %ebx
  801644:	83 ec 28             	sub    $0x28,%esp
  801647:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80164a:	56                   	push   %esi
  80164b:	e8 09 f7 ff ff       	call   800d59 <fd2data>
  801650:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	bf 00 00 00 00       	mov    $0x0,%edi
  80165a:	eb 4b                	jmp    8016a7 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80165c:	89 da                	mov    %ebx,%edx
  80165e:	89 f0                	mov    %esi,%eax
  801660:	e8 6d ff ff ff       	call   8015d2 <_pipeisclosed>
  801665:	85 c0                	test   %eax,%eax
  801667:	75 48                	jne    8016b1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801669:	e8 cb f4 ff ff       	call   800b39 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80166e:	8b 43 04             	mov    0x4(%ebx),%eax
  801671:	8b 0b                	mov    (%ebx),%ecx
  801673:	8d 51 20             	lea    0x20(%ecx),%edx
  801676:	39 d0                	cmp    %edx,%eax
  801678:	73 e2                	jae    80165c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80167a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80167d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801681:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801684:	89 c2                	mov    %eax,%edx
  801686:	c1 fa 1f             	sar    $0x1f,%edx
  801689:	89 d1                	mov    %edx,%ecx
  80168b:	c1 e9 1b             	shr    $0x1b,%ecx
  80168e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801691:	83 e2 1f             	and    $0x1f,%edx
  801694:	29 ca                	sub    %ecx,%edx
  801696:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80169a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80169e:	83 c0 01             	add    $0x1,%eax
  8016a1:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a4:	83 c7 01             	add    $0x1,%edi
  8016a7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016aa:	75 c2                	jne    80166e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016ac:	8b 45 10             	mov    0x10(%ebp),%eax
  8016af:	eb 05                	jmp    8016b6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016b1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b9:	5b                   	pop    %ebx
  8016ba:	5e                   	pop    %esi
  8016bb:	5f                   	pop    %edi
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	57                   	push   %edi
  8016c2:	56                   	push   %esi
  8016c3:	53                   	push   %ebx
  8016c4:	83 ec 18             	sub    $0x18,%esp
  8016c7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016ca:	57                   	push   %edi
  8016cb:	e8 89 f6 ff ff       	call   800d59 <fd2data>
  8016d0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016da:	eb 3d                	jmp    801719 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016dc:	85 db                	test   %ebx,%ebx
  8016de:	74 04                	je     8016e4 <devpipe_read+0x26>
				return i;
  8016e0:	89 d8                	mov    %ebx,%eax
  8016e2:	eb 44                	jmp    801728 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016e4:	89 f2                	mov    %esi,%edx
  8016e6:	89 f8                	mov    %edi,%eax
  8016e8:	e8 e5 fe ff ff       	call   8015d2 <_pipeisclosed>
  8016ed:	85 c0                	test   %eax,%eax
  8016ef:	75 32                	jne    801723 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016f1:	e8 43 f4 ff ff       	call   800b39 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016f6:	8b 06                	mov    (%esi),%eax
  8016f8:	3b 46 04             	cmp    0x4(%esi),%eax
  8016fb:	74 df                	je     8016dc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016fd:	99                   	cltd   
  8016fe:	c1 ea 1b             	shr    $0x1b,%edx
  801701:	01 d0                	add    %edx,%eax
  801703:	83 e0 1f             	and    $0x1f,%eax
  801706:	29 d0                	sub    %edx,%eax
  801708:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  80170d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801710:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801713:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801716:	83 c3 01             	add    $0x1,%ebx
  801719:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80171c:	75 d8                	jne    8016f6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80171e:	8b 45 10             	mov    0x10(%ebp),%eax
  801721:	eb 05                	jmp    801728 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801723:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801728:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5f                   	pop    %edi
  80172e:	5d                   	pop    %ebp
  80172f:	c3                   	ret    

00801730 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	56                   	push   %esi
  801734:	53                   	push   %ebx
  801735:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801738:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80173b:	50                   	push   %eax
  80173c:	e8 2f f6 ff ff       	call   800d70 <fd_alloc>
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	89 c2                	mov    %eax,%edx
  801746:	85 c0                	test   %eax,%eax
  801748:	0f 88 2c 01 00 00    	js     80187a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174e:	83 ec 04             	sub    $0x4,%esp
  801751:	68 07 04 00 00       	push   $0x407
  801756:	ff 75 f4             	pushl  -0xc(%ebp)
  801759:	6a 00                	push   $0x0
  80175b:	e8 f8 f3 ff ff       	call   800b58 <sys_page_alloc>
  801760:	83 c4 10             	add    $0x10,%esp
  801763:	89 c2                	mov    %eax,%edx
  801765:	85 c0                	test   %eax,%eax
  801767:	0f 88 0d 01 00 00    	js     80187a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80176d:	83 ec 0c             	sub    $0xc,%esp
  801770:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801773:	50                   	push   %eax
  801774:	e8 f7 f5 ff ff       	call   800d70 <fd_alloc>
  801779:	89 c3                	mov    %eax,%ebx
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	0f 88 e2 00 00 00    	js     801868 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801786:	83 ec 04             	sub    $0x4,%esp
  801789:	68 07 04 00 00       	push   $0x407
  80178e:	ff 75 f0             	pushl  -0x10(%ebp)
  801791:	6a 00                	push   $0x0
  801793:	e8 c0 f3 ff ff       	call   800b58 <sys_page_alloc>
  801798:	89 c3                	mov    %eax,%ebx
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	85 c0                	test   %eax,%eax
  80179f:	0f 88 c3 00 00 00    	js     801868 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017a5:	83 ec 0c             	sub    $0xc,%esp
  8017a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ab:	e8 a9 f5 ff ff       	call   800d59 <fd2data>
  8017b0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017b2:	83 c4 0c             	add    $0xc,%esp
  8017b5:	68 07 04 00 00       	push   $0x407
  8017ba:	50                   	push   %eax
  8017bb:	6a 00                	push   $0x0
  8017bd:	e8 96 f3 ff ff       	call   800b58 <sys_page_alloc>
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	85 c0                	test   %eax,%eax
  8017c9:	0f 88 89 00 00 00    	js     801858 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017cf:	83 ec 0c             	sub    $0xc,%esp
  8017d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d5:	e8 7f f5 ff ff       	call   800d59 <fd2data>
  8017da:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017e1:	50                   	push   %eax
  8017e2:	6a 00                	push   $0x0
  8017e4:	56                   	push   %esi
  8017e5:	6a 00                	push   $0x0
  8017e7:	e8 af f3 ff ff       	call   800b9b <sys_page_map>
  8017ec:	89 c3                	mov    %eax,%ebx
  8017ee:	83 c4 20             	add    $0x20,%esp
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 55                	js     80184a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017f5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fe:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801800:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801803:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80180a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801810:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801813:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801818:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	ff 75 f4             	pushl  -0xc(%ebp)
  801825:	e8 1f f5 ff ff       	call   800d49 <fd2num>
  80182a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80182d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80182f:	83 c4 04             	add    $0x4,%esp
  801832:	ff 75 f0             	pushl  -0x10(%ebp)
  801835:	e8 0f f5 ff ff       	call   800d49 <fd2num>
  80183a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80183d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	ba 00 00 00 00       	mov    $0x0,%edx
  801848:	eb 30                	jmp    80187a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80184a:	83 ec 08             	sub    $0x8,%esp
  80184d:	56                   	push   %esi
  80184e:	6a 00                	push   $0x0
  801850:	e8 88 f3 ff ff       	call   800bdd <sys_page_unmap>
  801855:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	ff 75 f0             	pushl  -0x10(%ebp)
  80185e:	6a 00                	push   $0x0
  801860:	e8 78 f3 ff ff       	call   800bdd <sys_page_unmap>
  801865:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	ff 75 f4             	pushl  -0xc(%ebp)
  80186e:	6a 00                	push   $0x0
  801870:	e8 68 f3 ff ff       	call   800bdd <sys_page_unmap>
  801875:	83 c4 10             	add    $0x10,%esp
  801878:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80187a:	89 d0                	mov    %edx,%eax
  80187c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187f:	5b                   	pop    %ebx
  801880:	5e                   	pop    %esi
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801889:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188c:	50                   	push   %eax
  80188d:	ff 75 08             	pushl  0x8(%ebp)
  801890:	e8 2a f5 ff ff       	call   800dbf <fd_lookup>
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 18                	js     8018b4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80189c:	83 ec 0c             	sub    $0xc,%esp
  80189f:	ff 75 f4             	pushl  -0xc(%ebp)
  8018a2:	e8 b2 f4 ff ff       	call   800d59 <fd2data>
	return _pipeisclosed(fd, p);
  8018a7:	89 c2                	mov    %eax,%edx
  8018a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ac:	e8 21 fd ff ff       	call   8015d2 <_pipeisclosed>
  8018b1:	83 c4 10             	add    $0x10,%esp
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    

008018c0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018c6:	68 aa 22 80 00       	push   $0x8022aa
  8018cb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ce:	e8 82 ee ff ff       	call   800755 <strcpy>
	return 0;
}
  8018d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d8:	c9                   	leave  
  8018d9:	c3                   	ret    

008018da <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018da:	55                   	push   %ebp
  8018db:	89 e5                	mov    %esp,%ebp
  8018dd:	57                   	push   %edi
  8018de:	56                   	push   %esi
  8018df:	53                   	push   %ebx
  8018e0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018eb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018f1:	eb 2d                	jmp    801920 <devcons_write+0x46>
		m = n - tot;
  8018f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018f8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018fb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801900:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801903:	83 ec 04             	sub    $0x4,%esp
  801906:	53                   	push   %ebx
  801907:	03 45 0c             	add    0xc(%ebp),%eax
  80190a:	50                   	push   %eax
  80190b:	57                   	push   %edi
  80190c:	e8 d6 ef ff ff       	call   8008e7 <memmove>
		sys_cputs(buf, m);
  801911:	83 c4 08             	add    $0x8,%esp
  801914:	53                   	push   %ebx
  801915:	57                   	push   %edi
  801916:	e8 81 f1 ff ff       	call   800a9c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80191b:	01 de                	add    %ebx,%esi
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	89 f0                	mov    %esi,%eax
  801922:	3b 75 10             	cmp    0x10(%ebp),%esi
  801925:	72 cc                	jb     8018f3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801927:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80192a:	5b                   	pop    %ebx
  80192b:	5e                   	pop    %esi
  80192c:	5f                   	pop    %edi
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	83 ec 08             	sub    $0x8,%esp
  801935:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80193a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80193e:	74 2a                	je     80196a <devcons_read+0x3b>
  801940:	eb 05                	jmp    801947 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801942:	e8 f2 f1 ff ff       	call   800b39 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801947:	e8 6e f1 ff ff       	call   800aba <sys_cgetc>
  80194c:	85 c0                	test   %eax,%eax
  80194e:	74 f2                	je     801942 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801950:	85 c0                	test   %eax,%eax
  801952:	78 16                	js     80196a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801954:	83 f8 04             	cmp    $0x4,%eax
  801957:	74 0c                	je     801965 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801959:	8b 55 0c             	mov    0xc(%ebp),%edx
  80195c:	88 02                	mov    %al,(%edx)
	return 1;
  80195e:	b8 01 00 00 00       	mov    $0x1,%eax
  801963:	eb 05                	jmp    80196a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801965:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80196a:	c9                   	leave  
  80196b:	c3                   	ret    

0080196c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80196c:	55                   	push   %ebp
  80196d:	89 e5                	mov    %esp,%ebp
  80196f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801972:	8b 45 08             	mov    0x8(%ebp),%eax
  801975:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801978:	6a 01                	push   $0x1
  80197a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80197d:	50                   	push   %eax
  80197e:	e8 19 f1 ff ff       	call   800a9c <sys_cputs>
}
  801983:	83 c4 10             	add    $0x10,%esp
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <getchar>:

int
getchar(void)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80198e:	6a 01                	push   $0x1
  801990:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801993:	50                   	push   %eax
  801994:	6a 00                	push   $0x0
  801996:	e8 8a f6 ff ff       	call   801025 <read>
	if (r < 0)
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 0f                	js     8019b1 <getchar+0x29>
		return r;
	if (r < 1)
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	7e 06                	jle    8019ac <getchar+0x24>
		return -E_EOF;
	return c;
  8019a6:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019aa:	eb 05                	jmp    8019b1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019ac:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019b3:	55                   	push   %ebp
  8019b4:	89 e5                	mov    %esp,%ebp
  8019b6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bc:	50                   	push   %eax
  8019bd:	ff 75 08             	pushl  0x8(%ebp)
  8019c0:	e8 fa f3 ff ff       	call   800dbf <fd_lookup>
  8019c5:	83 c4 10             	add    $0x10,%esp
  8019c8:	85 c0                	test   %eax,%eax
  8019ca:	78 11                	js     8019dd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d5:	39 10                	cmp    %edx,(%eax)
  8019d7:	0f 94 c0             	sete   %al
  8019da:	0f b6 c0             	movzbl %al,%eax
}
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    

008019df <opencons>:

int
opencons(void)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e8:	50                   	push   %eax
  8019e9:	e8 82 f3 ff ff       	call   800d70 <fd_alloc>
  8019ee:	83 c4 10             	add    $0x10,%esp
		return r;
  8019f1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 3e                	js     801a35 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f7:	83 ec 04             	sub    $0x4,%esp
  8019fa:	68 07 04 00 00       	push   $0x407
  8019ff:	ff 75 f4             	pushl  -0xc(%ebp)
  801a02:	6a 00                	push   $0x0
  801a04:	e8 4f f1 ff ff       	call   800b58 <sys_page_alloc>
  801a09:	83 c4 10             	add    $0x10,%esp
		return r;
  801a0c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 23                	js     801a35 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a12:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a1d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a20:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	50                   	push   %eax
  801a2b:	e8 19 f3 ff ff       	call   800d49 <fd2num>
  801a30:	89 c2                	mov    %eax,%edx
  801a32:	83 c4 10             	add    $0x10,%esp
}
  801a35:	89 d0                	mov    %edx,%eax
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	56                   	push   %esi
  801a3d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a3e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a41:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a47:	e8 ce f0 ff ff       	call   800b1a <sys_getenvid>
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	ff 75 0c             	pushl  0xc(%ebp)
  801a52:	ff 75 08             	pushl  0x8(%ebp)
  801a55:	56                   	push   %esi
  801a56:	50                   	push   %eax
  801a57:	68 b8 22 80 00       	push   $0x8022b8
  801a5c:	e8 f0 e6 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a61:	83 c4 18             	add    $0x18,%esp
  801a64:	53                   	push   %ebx
  801a65:	ff 75 10             	pushl  0x10(%ebp)
  801a68:	e8 93 e6 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801a6d:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a74:	e8 d8 e6 ff ff       	call   800151 <cprintf>
  801a79:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a7c:	cc                   	int3   
  801a7d:	eb fd                	jmp    801a7c <_panic+0x43>

00801a7f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	57                   	push   %edi
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	8b 75 08             	mov    0x8(%ebp),%esi
  801a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a91:	85 f6                	test   %esi,%esi
  801a93:	74 06                	je     801a9b <ipc_recv+0x1c>
		*from_env_store = 0;
  801a95:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801a9b:	85 db                	test   %ebx,%ebx
  801a9d:	74 06                	je     801aa5 <ipc_recv+0x26>
		*perm_store = 0;
  801a9f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801aa5:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801aa7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801aac:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	50                   	push   %eax
  801ab3:	e8 50 f2 ff ff       	call   800d08 <sys_ipc_recv>
  801ab8:	89 c7                	mov    %eax,%edi
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	85 c0                	test   %eax,%eax
  801abf:	79 14                	jns    801ad5 <ipc_recv+0x56>
		cprintf("im dead");
  801ac1:	83 ec 0c             	sub    $0xc,%esp
  801ac4:	68 dc 22 80 00       	push   $0x8022dc
  801ac9:	e8 83 e6 ff ff       	call   800151 <cprintf>
		return r;
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	89 f8                	mov    %edi,%eax
  801ad3:	eb 24                	jmp    801af9 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ad5:	85 f6                	test   %esi,%esi
  801ad7:	74 0a                	je     801ae3 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ad9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ade:	8b 40 74             	mov    0x74(%eax),%eax
  801ae1:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801ae3:	85 db                	test   %ebx,%ebx
  801ae5:	74 0a                	je     801af1 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ae7:	a1 04 40 80 00       	mov    0x804004,%eax
  801aec:	8b 40 78             	mov    0x78(%eax),%eax
  801aef:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801af1:	a1 04 40 80 00       	mov    0x804004,%eax
  801af6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801af9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801afc:	5b                   	pop    %ebx
  801afd:	5e                   	pop    %esi
  801afe:	5f                   	pop    %edi
  801aff:	5d                   	pop    %ebp
  801b00:	c3                   	ret    

00801b01 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b01:	55                   	push   %ebp
  801b02:	89 e5                	mov    %esp,%ebp
  801b04:	57                   	push   %edi
  801b05:	56                   	push   %esi
  801b06:	53                   	push   %ebx
  801b07:	83 ec 0c             	sub    $0xc,%esp
  801b0a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b0d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801b13:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801b15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b1a:	0f 44 d8             	cmove  %eax,%ebx
  801b1d:	eb 1c                	jmp    801b3b <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801b1f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b22:	74 12                	je     801b36 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b24:	50                   	push   %eax
  801b25:	68 e4 22 80 00       	push   $0x8022e4
  801b2a:	6a 4e                	push   $0x4e
  801b2c:	68 f1 22 80 00       	push   $0x8022f1
  801b31:	e8 03 ff ff ff       	call   801a39 <_panic>
		sys_yield();
  801b36:	e8 fe ef ff ff       	call   800b39 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b3b:	ff 75 14             	pushl  0x14(%ebp)
  801b3e:	53                   	push   %ebx
  801b3f:	56                   	push   %esi
  801b40:	57                   	push   %edi
  801b41:	e8 9f f1 ff ff       	call   800ce5 <sys_ipc_try_send>
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 d2                	js     801b1f <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5f                   	pop    %edi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b5b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b60:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b63:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b69:	8b 52 50             	mov    0x50(%edx),%edx
  801b6c:	39 ca                	cmp    %ecx,%edx
  801b6e:	75 0d                	jne    801b7d <ipc_find_env+0x28>
			return envs[i].env_id;
  801b70:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b73:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b78:	8b 40 48             	mov    0x48(%eax),%eax
  801b7b:	eb 0f                	jmp    801b8c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b7d:	83 c0 01             	add    $0x1,%eax
  801b80:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b85:	75 d9                	jne    801b60 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    

00801b8e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b8e:	55                   	push   %ebp
  801b8f:	89 e5                	mov    %esp,%ebp
  801b91:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b94:	89 d0                	mov    %edx,%eax
  801b96:	c1 e8 16             	shr    $0x16,%eax
  801b99:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba5:	f6 c1 01             	test   $0x1,%cl
  801ba8:	74 1d                	je     801bc7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801baa:	c1 ea 0c             	shr    $0xc,%edx
  801bad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bb4:	f6 c2 01             	test   $0x1,%dl
  801bb7:	74 0e                	je     801bc7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb9:	c1 ea 0c             	shr    $0xc,%edx
  801bbc:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bc3:	ef 
  801bc4:	0f b7 c0             	movzwl %ax,%eax
}
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    
  801bc9:	66 90                	xchg   %ax,%ax
  801bcb:	66 90                	xchg   %ax,%ax
  801bcd:	66 90                	xchg   %ax,%ax
  801bcf:	90                   	nop

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	53                   	push   %ebx
  801bd4:	83 ec 1c             	sub    $0x1c,%esp
  801bd7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bdb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bdf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801be3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801be7:	85 f6                	test   %esi,%esi
  801be9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bed:	89 ca                	mov    %ecx,%edx
  801bef:	89 f8                	mov    %edi,%eax
  801bf1:	75 3d                	jne    801c30 <__udivdi3+0x60>
  801bf3:	39 cf                	cmp    %ecx,%edi
  801bf5:	0f 87 c5 00 00 00    	ja     801cc0 <__udivdi3+0xf0>
  801bfb:	85 ff                	test   %edi,%edi
  801bfd:	89 fd                	mov    %edi,%ebp
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x3c>
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f7                	div    %edi
  801c0a:	89 c5                	mov    %eax,%ebp
  801c0c:	89 c8                	mov    %ecx,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c1                	mov    %eax,%ecx
  801c14:	89 d8                	mov    %ebx,%eax
  801c16:	89 cf                	mov    %ecx,%edi
  801c18:	f7 f5                	div    %ebp
  801c1a:	89 c3                	mov    %eax,%ebx
  801c1c:	89 d8                	mov    %ebx,%eax
  801c1e:	89 fa                	mov    %edi,%edx
  801c20:	83 c4 1c             	add    $0x1c,%esp
  801c23:	5b                   	pop    %ebx
  801c24:	5e                   	pop    %esi
  801c25:	5f                   	pop    %edi
  801c26:	5d                   	pop    %ebp
  801c27:	c3                   	ret    
  801c28:	90                   	nop
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	39 ce                	cmp    %ecx,%esi
  801c32:	77 74                	ja     801ca8 <__udivdi3+0xd8>
  801c34:	0f bd fe             	bsr    %esi,%edi
  801c37:	83 f7 1f             	xor    $0x1f,%edi
  801c3a:	0f 84 98 00 00 00    	je     801cd8 <__udivdi3+0x108>
  801c40:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	89 c5                	mov    %eax,%ebp
  801c49:	29 fb                	sub    %edi,%ebx
  801c4b:	d3 e6                	shl    %cl,%esi
  801c4d:	89 d9                	mov    %ebx,%ecx
  801c4f:	d3 ed                	shr    %cl,%ebp
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	09 ee                	or     %ebp,%esi
  801c57:	89 d9                	mov    %ebx,%ecx
  801c59:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5d:	89 d5                	mov    %edx,%ebp
  801c5f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c63:	d3 ed                	shr    %cl,%ebp
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e2                	shl    %cl,%edx
  801c69:	89 d9                	mov    %ebx,%ecx
  801c6b:	d3 e8                	shr    %cl,%eax
  801c6d:	09 c2                	or     %eax,%edx
  801c6f:	89 d0                	mov    %edx,%eax
  801c71:	89 ea                	mov    %ebp,%edx
  801c73:	f7 f6                	div    %esi
  801c75:	89 d5                	mov    %edx,%ebp
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	f7 64 24 0c          	mull   0xc(%esp)
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	72 10                	jb     801c91 <__udivdi3+0xc1>
  801c81:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c85:	89 f9                	mov    %edi,%ecx
  801c87:	d3 e6                	shl    %cl,%esi
  801c89:	39 c6                	cmp    %eax,%esi
  801c8b:	73 07                	jae    801c94 <__udivdi3+0xc4>
  801c8d:	39 d5                	cmp    %edx,%ebp
  801c8f:	75 03                	jne    801c94 <__udivdi3+0xc4>
  801c91:	83 eb 01             	sub    $0x1,%ebx
  801c94:	31 ff                	xor    %edi,%edi
  801c96:	89 d8                	mov    %ebx,%eax
  801c98:	89 fa                	mov    %edi,%edx
  801c9a:	83 c4 1c             	add    $0x1c,%esp
  801c9d:	5b                   	pop    %ebx
  801c9e:	5e                   	pop    %esi
  801c9f:	5f                   	pop    %edi
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    
  801ca2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca8:	31 ff                	xor    %edi,%edi
  801caa:	31 db                	xor    %ebx,%ebx
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	89 fa                	mov    %edi,%edx
  801cb0:	83 c4 1c             	add    $0x1c,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	90                   	nop
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	89 d8                	mov    %ebx,%eax
  801cc2:	f7 f7                	div    %edi
  801cc4:	31 ff                	xor    %edi,%edi
  801cc6:	89 c3                	mov    %eax,%ebx
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	89 fa                	mov    %edi,%edx
  801ccc:	83 c4 1c             	add    $0x1c,%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	39 ce                	cmp    %ecx,%esi
  801cda:	72 0c                	jb     801ce8 <__udivdi3+0x118>
  801cdc:	31 db                	xor    %ebx,%ebx
  801cde:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801ce2:	0f 87 34 ff ff ff    	ja     801c1c <__udivdi3+0x4c>
  801ce8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ced:	e9 2a ff ff ff       	jmp    801c1c <__udivdi3+0x4c>
  801cf2:	66 90                	xchg   %ax,%ax
  801cf4:	66 90                	xchg   %ax,%ax
  801cf6:	66 90                	xchg   %ax,%ax
  801cf8:	66 90                	xchg   %ax,%ax
  801cfa:	66 90                	xchg   %ax,%ax
  801cfc:	66 90                	xchg   %ax,%ax
  801cfe:	66 90                	xchg   %ax,%ax

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	83 ec 1c             	sub    $0x1c,%esp
  801d07:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d0b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d17:	85 d2                	test   %edx,%edx
  801d19:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f3                	mov    %esi,%ebx
  801d23:	89 3c 24             	mov    %edi,(%esp)
  801d26:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d2a:	75 1c                	jne    801d48 <__umoddi3+0x48>
  801d2c:	39 f7                	cmp    %esi,%edi
  801d2e:	76 50                	jbe    801d80 <__umoddi3+0x80>
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	f7 f7                	div    %edi
  801d36:	89 d0                	mov    %edx,%eax
  801d38:	31 d2                	xor    %edx,%edx
  801d3a:	83 c4 1c             	add    $0x1c,%esp
  801d3d:	5b                   	pop    %ebx
  801d3e:	5e                   	pop    %esi
  801d3f:	5f                   	pop    %edi
  801d40:	5d                   	pop    %ebp
  801d41:	c3                   	ret    
  801d42:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d48:	39 f2                	cmp    %esi,%edx
  801d4a:	89 d0                	mov    %edx,%eax
  801d4c:	77 52                	ja     801da0 <__umoddi3+0xa0>
  801d4e:	0f bd ea             	bsr    %edx,%ebp
  801d51:	83 f5 1f             	xor    $0x1f,%ebp
  801d54:	75 5a                	jne    801db0 <__umoddi3+0xb0>
  801d56:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d5a:	0f 82 e0 00 00 00    	jb     801e40 <__umoddi3+0x140>
  801d60:	39 0c 24             	cmp    %ecx,(%esp)
  801d63:	0f 86 d7 00 00 00    	jbe    801e40 <__umoddi3+0x140>
  801d69:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d6d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d71:	83 c4 1c             	add    $0x1c,%esp
  801d74:	5b                   	pop    %ebx
  801d75:	5e                   	pop    %esi
  801d76:	5f                   	pop    %edi
  801d77:	5d                   	pop    %ebp
  801d78:	c3                   	ret    
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	85 ff                	test   %edi,%edi
  801d82:	89 fd                	mov    %edi,%ebp
  801d84:	75 0b                	jne    801d91 <__umoddi3+0x91>
  801d86:	b8 01 00 00 00       	mov    $0x1,%eax
  801d8b:	31 d2                	xor    %edx,%edx
  801d8d:	f7 f7                	div    %edi
  801d8f:	89 c5                	mov    %eax,%ebp
  801d91:	89 f0                	mov    %esi,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f5                	div    %ebp
  801d97:	89 c8                	mov    %ecx,%eax
  801d99:	f7 f5                	div    %ebp
  801d9b:	89 d0                	mov    %edx,%eax
  801d9d:	eb 99                	jmp    801d38 <__umoddi3+0x38>
  801d9f:	90                   	nop
  801da0:	89 c8                	mov    %ecx,%eax
  801da2:	89 f2                	mov    %esi,%edx
  801da4:	83 c4 1c             	add    $0x1c,%esp
  801da7:	5b                   	pop    %ebx
  801da8:	5e                   	pop    %esi
  801da9:	5f                   	pop    %edi
  801daa:	5d                   	pop    %ebp
  801dab:	c3                   	ret    
  801dac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db0:	8b 34 24             	mov    (%esp),%esi
  801db3:	bf 20 00 00 00       	mov    $0x20,%edi
  801db8:	89 e9                	mov    %ebp,%ecx
  801dba:	29 ef                	sub    %ebp,%edi
  801dbc:	d3 e0                	shl    %cl,%eax
  801dbe:	89 f9                	mov    %edi,%ecx
  801dc0:	89 f2                	mov    %esi,%edx
  801dc2:	d3 ea                	shr    %cl,%edx
  801dc4:	89 e9                	mov    %ebp,%ecx
  801dc6:	09 c2                	or     %eax,%edx
  801dc8:	89 d8                	mov    %ebx,%eax
  801dca:	89 14 24             	mov    %edx,(%esp)
  801dcd:	89 f2                	mov    %esi,%edx
  801dcf:	d3 e2                	shl    %cl,%edx
  801dd1:	89 f9                	mov    %edi,%ecx
  801dd3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dd7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801ddb:	d3 e8                	shr    %cl,%eax
  801ddd:	89 e9                	mov    %ebp,%ecx
  801ddf:	89 c6                	mov    %eax,%esi
  801de1:	d3 e3                	shl    %cl,%ebx
  801de3:	89 f9                	mov    %edi,%ecx
  801de5:	89 d0                	mov    %edx,%eax
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 e9                	mov    %ebp,%ecx
  801deb:	09 d8                	or     %ebx,%eax
  801ded:	89 d3                	mov    %edx,%ebx
  801def:	89 f2                	mov    %esi,%edx
  801df1:	f7 34 24             	divl   (%esp)
  801df4:	89 d6                	mov    %edx,%esi
  801df6:	d3 e3                	shl    %cl,%ebx
  801df8:	f7 64 24 04          	mull   0x4(%esp)
  801dfc:	39 d6                	cmp    %edx,%esi
  801dfe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e02:	89 d1                	mov    %edx,%ecx
  801e04:	89 c3                	mov    %eax,%ebx
  801e06:	72 08                	jb     801e10 <__umoddi3+0x110>
  801e08:	75 11                	jne    801e1b <__umoddi3+0x11b>
  801e0a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e0e:	73 0b                	jae    801e1b <__umoddi3+0x11b>
  801e10:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e14:	1b 14 24             	sbb    (%esp),%edx
  801e17:	89 d1                	mov    %edx,%ecx
  801e19:	89 c3                	mov    %eax,%ebx
  801e1b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e1f:	29 da                	sub    %ebx,%edx
  801e21:	19 ce                	sbb    %ecx,%esi
  801e23:	89 f9                	mov    %edi,%ecx
  801e25:	89 f0                	mov    %esi,%eax
  801e27:	d3 e0                	shl    %cl,%eax
  801e29:	89 e9                	mov    %ebp,%ecx
  801e2b:	d3 ea                	shr    %cl,%edx
  801e2d:	89 e9                	mov    %ebp,%ecx
  801e2f:	d3 ee                	shr    %cl,%esi
  801e31:	09 d0                	or     %edx,%eax
  801e33:	89 f2                	mov    %esi,%edx
  801e35:	83 c4 1c             	add    $0x1c,%esp
  801e38:	5b                   	pop    %ebx
  801e39:	5e                   	pop    %esi
  801e3a:	5f                   	pop    %edi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    
  801e3d:	8d 76 00             	lea    0x0(%esi),%esi
  801e40:	29 f9                	sub    %edi,%ecx
  801e42:	19 d6                	sbb    %edx,%esi
  801e44:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e48:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e4c:	e9 18 ff ff ff       	jmp    801d69 <__umoddi3+0x69>
