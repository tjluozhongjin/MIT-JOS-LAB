
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 60 1e 80 00       	push   $0x801e60
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ac 0a 00 00       	call   800b0a <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 65 0e 00 00       	call   800f04 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 20 0a 00 00       	call   800ac9 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 ae 09 00 00       	call   800a8c <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 1a 01 00 00       	call   80023e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 53 09 00 00       	call   800a8c <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800171:	bb 00 00 00 00       	mov    $0x0,%ebx
  800176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017c:	39 d3                	cmp    %edx,%ebx
  80017e:	72 05                	jb     800185 <printnum+0x30>
  800180:	39 45 10             	cmp    %eax,0x10(%ebp)
  800183:	77 45                	ja     8001ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	8b 45 14             	mov    0x14(%ebp),%eax
  80018e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800191:	53                   	push   %ebx
  800192:	ff 75 10             	pushl  0x10(%ebp)
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 17 1a 00 00       	call   801bc0 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 18                	jmp    8001d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb 03                	jmp    8001cd <printnum+0x78>
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	83 eb 01             	sub    $0x1,%ebx
  8001d0:	85 db                	test   %ebx,%ebx
  8001d2:	7f e8                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 04 1b 00 00       	call   801cf0 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 91 1e 80 00 	movsbl 0x801e91(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
}
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80020a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80020e:	8b 10                	mov    (%eax),%edx
  800210:	3b 50 04             	cmp    0x4(%eax),%edx
  800213:	73 0a                	jae    80021f <sprintputch+0x1b>
		*b->buf++ = ch;
  800215:	8d 4a 01             	lea    0x1(%edx),%ecx
  800218:	89 08                	mov    %ecx,(%eax)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	88 02                	mov    %al,(%edx)
}
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800227:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80022a:	50                   	push   %eax
  80022b:	ff 75 10             	pushl  0x10(%ebp)
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	e8 05 00 00 00       	call   80023e <vprintfmt>
	va_end(ap);
}
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	57                   	push   %edi
  800242:	56                   	push   %esi
  800243:	53                   	push   %ebx
  800244:	83 ec 2c             	sub    $0x2c,%esp
  800247:	8b 75 08             	mov    0x8(%ebp),%esi
  80024a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80024d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800250:	eb 12                	jmp    800264 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800252:	85 c0                	test   %eax,%eax
  800254:	0f 84 42 04 00 00    	je     80069c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80025a:	83 ec 08             	sub    $0x8,%esp
  80025d:	53                   	push   %ebx
  80025e:	50                   	push   %eax
  80025f:	ff d6                	call   *%esi
  800261:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800264:	83 c7 01             	add    $0x1,%edi
  800267:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80026b:	83 f8 25             	cmp    $0x25,%eax
  80026e:	75 e2                	jne    800252 <vprintfmt+0x14>
  800270:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800274:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80027b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800282:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800289:	b9 00 00 00 00       	mov    $0x0,%ecx
  80028e:	eb 07                	jmp    800297 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800290:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800293:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800297:	8d 47 01             	lea    0x1(%edi),%eax
  80029a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029d:	0f b6 07             	movzbl (%edi),%eax
  8002a0:	0f b6 d0             	movzbl %al,%edx
  8002a3:	83 e8 23             	sub    $0x23,%eax
  8002a6:	3c 55                	cmp    $0x55,%al
  8002a8:	0f 87 d3 03 00 00    	ja     800681 <vprintfmt+0x443>
  8002ae:	0f b6 c0             	movzbl %al,%eax
  8002b1:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  8002b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002bf:	eb d6                	jmp    800297 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002cf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002d3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d9:	83 f9 09             	cmp    $0x9,%ecx
  8002dc:	77 3f                	ja     80031d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002e1:	eb e9                	jmp    8002cc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e6:	8b 00                	mov    (%eax),%eax
  8002e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ee:	8d 40 04             	lea    0x4(%eax),%eax
  8002f1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8002f7:	eb 2a                	jmp    800323 <vprintfmt+0xe5>
  8002f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800303:	0f 49 d0             	cmovns %eax,%edx
  800306:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030c:	eb 89                	jmp    800297 <vprintfmt+0x59>
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800311:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800318:	e9 7a ff ff ff       	jmp    800297 <vprintfmt+0x59>
  80031d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800320:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800323:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800327:	0f 89 6a ff ff ff    	jns    800297 <vprintfmt+0x59>
				width = precision, precision = -1;
  80032d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800330:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800333:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80033a:	e9 58 ff ff ff       	jmp    800297 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80033f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800345:	e9 4d ff ff ff       	jmp    800297 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8d 78 04             	lea    0x4(%eax),%edi
  800350:	83 ec 08             	sub    $0x8,%esp
  800353:	53                   	push   %ebx
  800354:	ff 30                	pushl  (%eax)
  800356:	ff d6                	call   *%esi
			break;
  800358:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800361:	e9 fe fe ff ff       	jmp    800264 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800366:	8b 45 14             	mov    0x14(%ebp),%eax
  800369:	8d 78 04             	lea    0x4(%eax),%edi
  80036c:	8b 00                	mov    (%eax),%eax
  80036e:	99                   	cltd   
  80036f:	31 d0                	xor    %edx,%eax
  800371:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800373:	83 f8 0f             	cmp    $0xf,%eax
  800376:	7f 0b                	jg     800383 <vprintfmt+0x145>
  800378:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  80037f:	85 d2                	test   %edx,%edx
  800381:	75 1b                	jne    80039e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800383:	50                   	push   %eax
  800384:	68 a9 1e 80 00       	push   $0x801ea9
  800389:	53                   	push   %ebx
  80038a:	56                   	push   %esi
  80038b:	e8 91 fe ff ff       	call   800221 <printfmt>
  800390:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800393:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800399:	e9 c6 fe ff ff       	jmp    800264 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80039e:	52                   	push   %edx
  80039f:	68 71 22 80 00       	push   $0x802271
  8003a4:	53                   	push   %ebx
  8003a5:	56                   	push   %esi
  8003a6:	e8 76 fe ff ff       	call   800221 <printfmt>
  8003ab:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	e9 ab fe ff ff       	jmp    800264 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	83 c0 04             	add    $0x4,%eax
  8003bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003c7:	85 ff                	test   %edi,%edi
  8003c9:	b8 a2 1e 80 00       	mov    $0x801ea2,%eax
  8003ce:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d5:	0f 8e 94 00 00 00    	jle    80046f <vprintfmt+0x231>
  8003db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003df:	0f 84 98 00 00 00    	je     80047d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	ff 75 d0             	pushl  -0x30(%ebp)
  8003eb:	57                   	push   %edi
  8003ec:	e8 33 03 00 00       	call   800724 <strnlen>
  8003f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f4:	29 c1                	sub    %eax,%ecx
  8003f6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003fc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800400:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800403:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800406:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800408:	eb 0f                	jmp    800419 <vprintfmt+0x1db>
					putch(padc, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	53                   	push   %ebx
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	83 ef 01             	sub    $0x1,%edi
  800416:	83 c4 10             	add    $0x10,%esp
  800419:	85 ff                	test   %edi,%edi
  80041b:	7f ed                	jg     80040a <vprintfmt+0x1cc>
  80041d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800420:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800423:	85 c9                	test   %ecx,%ecx
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
  80042a:	0f 49 c1             	cmovns %ecx,%eax
  80042d:	29 c1                	sub    %eax,%ecx
  80042f:	89 75 08             	mov    %esi,0x8(%ebp)
  800432:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800435:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800438:	89 cb                	mov    %ecx,%ebx
  80043a:	eb 4d                	jmp    800489 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80043c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800440:	74 1b                	je     80045d <vprintfmt+0x21f>
  800442:	0f be c0             	movsbl %al,%eax
  800445:	83 e8 20             	sub    $0x20,%eax
  800448:	83 f8 5e             	cmp    $0x5e,%eax
  80044b:	76 10                	jbe    80045d <vprintfmt+0x21f>
					putch('?', putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	ff 75 0c             	pushl  0xc(%ebp)
  800453:	6a 3f                	push   $0x3f
  800455:	ff 55 08             	call   *0x8(%ebp)
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	eb 0d                	jmp    80046a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	ff 75 0c             	pushl  0xc(%ebp)
  800463:	52                   	push   %edx
  800464:	ff 55 08             	call   *0x8(%ebp)
  800467:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80046a:	83 eb 01             	sub    $0x1,%ebx
  80046d:	eb 1a                	jmp    800489 <vprintfmt+0x24b>
  80046f:	89 75 08             	mov    %esi,0x8(%ebp)
  800472:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800478:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80047b:	eb 0c                	jmp    800489 <vprintfmt+0x24b>
  80047d:	89 75 08             	mov    %esi,0x8(%ebp)
  800480:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800483:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800486:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800489:	83 c7 01             	add    $0x1,%edi
  80048c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800490:	0f be d0             	movsbl %al,%edx
  800493:	85 d2                	test   %edx,%edx
  800495:	74 23                	je     8004ba <vprintfmt+0x27c>
  800497:	85 f6                	test   %esi,%esi
  800499:	78 a1                	js     80043c <vprintfmt+0x1fe>
  80049b:	83 ee 01             	sub    $0x1,%esi
  80049e:	79 9c                	jns    80043c <vprintfmt+0x1fe>
  8004a0:	89 df                	mov    %ebx,%edi
  8004a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a8:	eb 18                	jmp    8004c2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	6a 20                	push   $0x20
  8004b0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004b2:	83 ef 01             	sub    $0x1,%edi
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	eb 08                	jmp    8004c2 <vprintfmt+0x284>
  8004ba:	89 df                	mov    %ebx,%edi
  8004bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c2:	85 ff                	test   %edi,%edi
  8004c4:	7f e4                	jg     8004aa <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cf:	e9 90 fd ff ff       	jmp    800264 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004d4:	83 f9 01             	cmp    $0x1,%ecx
  8004d7:	7e 19                	jle    8004f2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8b 50 04             	mov    0x4(%eax),%edx
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 40 08             	lea    0x8(%eax),%eax
  8004ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f0:	eb 38                	jmp    80052a <vprintfmt+0x2ec>
	else if (lflag)
  8004f2:	85 c9                	test   %ecx,%ecx
  8004f4:	74 1b                	je     800511 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fe:	89 c1                	mov    %eax,%ecx
  800500:	c1 f9 1f             	sar    $0x1f,%ecx
  800503:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 40 04             	lea    0x4(%eax),%eax
  80050c:	89 45 14             	mov    %eax,0x14(%ebp)
  80050f:	eb 19                	jmp    80052a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8b 00                	mov    (%eax),%eax
  800516:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800519:	89 c1                	mov    %eax,%ecx
  80051b:	c1 f9 1f             	sar    $0x1f,%ecx
  80051e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 40 04             	lea    0x4(%eax),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80052a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800530:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800535:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800539:	0f 89 0e 01 00 00    	jns    80064d <vprintfmt+0x40f>
				putch('-', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	6a 2d                	push   $0x2d
  800545:	ff d6                	call   *%esi
				num = -(long long) num;
  800547:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054d:	f7 da                	neg    %edx
  80054f:	83 d1 00             	adc    $0x0,%ecx
  800552:	f7 d9                	neg    %ecx
  800554:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800557:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055c:	e9 ec 00 00 00       	jmp    80064d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800561:	83 f9 01             	cmp    $0x1,%ecx
  800564:	7e 18                	jle    80057e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 10                	mov    (%eax),%edx
  80056b:	8b 48 04             	mov    0x4(%eax),%ecx
  80056e:	8d 40 08             	lea    0x8(%eax),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800574:	b8 0a 00 00 00       	mov    $0xa,%eax
  800579:	e9 cf 00 00 00       	jmp    80064d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80057e:	85 c9                	test   %ecx,%ecx
  800580:	74 1a                	je     80059c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8b 10                	mov    (%eax),%edx
  800587:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058c:	8d 40 04             	lea    0x4(%eax),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 b1 00 00 00       	jmp    80064d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 10                	mov    (%eax),%edx
  8005a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a6:	8d 40 04             	lea    0x4(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b1:	e9 97 00 00 00       	jmp    80064d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	6a 58                	push   $0x58
  8005bc:	ff d6                	call   *%esi
			putch('X', putdat);
  8005be:	83 c4 08             	add    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 58                	push   $0x58
  8005c4:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c6:	83 c4 08             	add    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 58                	push   $0x58
  8005cc:	ff d6                	call   *%esi
			break;
  8005ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005d4:	e9 8b fc ff ff       	jmp    800264 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 30                	push   $0x30
  8005df:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e1:	83 c4 08             	add    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	6a 78                	push   $0x78
  8005e7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f6:	8d 40 04             	lea    0x4(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005fc:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800601:	eb 4a                	jmp    80064d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800603:	83 f9 01             	cmp    $0x1,%ecx
  800606:	7e 15                	jle    80061d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	8b 48 04             	mov    0x4(%eax),%ecx
  800610:	8d 40 08             	lea    0x8(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800616:	b8 10 00 00 00       	mov    $0x10,%eax
  80061b:	eb 30                	jmp    80064d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80061d:	85 c9                	test   %ecx,%ecx
  80061f:	74 17                	je     800638 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062b:	8d 40 04             	lea    0x4(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800631:	b8 10 00 00 00       	mov    $0x10,%eax
  800636:	eb 15                	jmp    80064d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800648:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064d:	83 ec 0c             	sub    $0xc,%esp
  800650:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800654:	57                   	push   %edi
  800655:	ff 75 e0             	pushl  -0x20(%ebp)
  800658:	50                   	push   %eax
  800659:	51                   	push   %ecx
  80065a:	52                   	push   %edx
  80065b:	89 da                	mov    %ebx,%edx
  80065d:	89 f0                	mov    %esi,%eax
  80065f:	e8 f1 fa ff ff       	call   800155 <printnum>
			break;
  800664:	83 c4 20             	add    $0x20,%esp
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066a:	e9 f5 fb ff ff       	jmp    800264 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	52                   	push   %edx
  800674:	ff d6                	call   *%esi
			break;
  800676:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067c:	e9 e3 fb ff ff       	jmp    800264 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 25                	push   $0x25
  800687:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	eb 03                	jmp    800691 <vprintfmt+0x453>
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800695:	75 f7                	jne    80068e <vprintfmt+0x450>
  800697:	e9 c8 fb ff ff       	jmp    800264 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80069c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069f:	5b                   	pop    %ebx
  8006a0:	5e                   	pop    %esi
  8006a1:	5f                   	pop    %edi
  8006a2:	5d                   	pop    %ebp
  8006a3:	c3                   	ret    

008006a4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 18             	sub    $0x18,%esp
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	74 26                	je     8006eb <vsnprintf+0x47>
  8006c5:	85 d2                	test   %edx,%edx
  8006c7:	7e 22                	jle    8006eb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c9:	ff 75 14             	pushl  0x14(%ebp)
  8006cc:	ff 75 10             	pushl  0x10(%ebp)
  8006cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	68 04 02 80 00       	push   $0x800204
  8006d8:	e8 61 fb ff ff       	call   80023e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 05                	jmp    8006f0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fb:	50                   	push   %eax
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	ff 75 08             	pushl  0x8(%ebp)
  800705:	e8 9a ff ff ff       	call   8006a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	eb 03                	jmp    80071c <strlen+0x10>
		n++;
  800719:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800720:	75 f7                	jne    800719 <strlen+0xd>
		n++;
	return n;
}
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	ba 00 00 00 00       	mov    $0x0,%edx
  800732:	eb 03                	jmp    800737 <strnlen+0x13>
		n++;
  800734:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800737:	39 c2                	cmp    %eax,%edx
  800739:	74 08                	je     800743 <strnlen+0x1f>
  80073b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80073f:	75 f3                	jne    800734 <strnlen+0x10>
  800741:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	53                   	push   %ebx
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074f:	89 c2                	mov    %eax,%edx
  800751:	83 c2 01             	add    $0x1,%edx
  800754:	83 c1 01             	add    $0x1,%ecx
  800757:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80075b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80075e:	84 db                	test   %bl,%bl
  800760:	75 ef                	jne    800751 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800762:	5b                   	pop    %ebx
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	53                   	push   %ebx
  800769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076c:	53                   	push   %ebx
  80076d:	e8 9a ff ff ff       	call   80070c <strlen>
  800772:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	01 d8                	add    %ebx,%eax
  80077a:	50                   	push   %eax
  80077b:	e8 c5 ff ff ff       	call   800745 <strcpy>
	return dst;
}
  800780:	89 d8                	mov    %ebx,%eax
  800782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800792:	89 f3                	mov    %esi,%ebx
  800794:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800797:	89 f2                	mov    %esi,%edx
  800799:	eb 0f                	jmp    8007aa <strncpy+0x23>
		*dst++ = *src;
  80079b:	83 c2 01             	add    $0x1,%edx
  80079e:	0f b6 01             	movzbl (%ecx),%eax
  8007a1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007aa:	39 da                	cmp    %ebx,%edx
  8007ac:	75 ed                	jne    80079b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	74 21                	je     8007e9 <strlcpy+0x35>
  8007c8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	eb 09                	jmp    8007d9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	83 c1 01             	add    $0x1,%ecx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d9:	39 c2                	cmp    %eax,%edx
  8007db:	74 09                	je     8007e6 <strlcpy+0x32>
  8007dd:	0f b6 19             	movzbl (%ecx),%ebx
  8007e0:	84 db                	test   %bl,%bl
  8007e2:	75 ec                	jne    8007d0 <strlcpy+0x1c>
  8007e4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e9:	29 f0                	sub    %esi,%eax
}
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strcmp+0x11>
		p++, q++;
  8007fa:	83 c1 01             	add    $0x1,%ecx
  8007fd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800800:	0f b6 01             	movzbl (%ecx),%eax
  800803:	84 c0                	test   %al,%al
  800805:	74 04                	je     80080b <strcmp+0x1c>
  800807:	3a 02                	cmp    (%edx),%al
  800809:	74 ef                	je     8007fa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 c0             	movzbl %al,%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081f:	89 c3                	mov    %eax,%ebx
  800821:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800824:	eb 06                	jmp    80082c <strncmp+0x17>
		n--, p++, q++;
  800826:	83 c0 01             	add    $0x1,%eax
  800829:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082c:	39 d8                	cmp    %ebx,%eax
  80082e:	74 15                	je     800845 <strncmp+0x30>
  800830:	0f b6 08             	movzbl (%eax),%ecx
  800833:	84 c9                	test   %cl,%cl
  800835:	74 04                	je     80083b <strncmp+0x26>
  800837:	3a 0a                	cmp    (%edx),%cl
  800839:	74 eb                	je     800826 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 00             	movzbl (%eax),%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
  800843:	eb 05                	jmp    80084a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084a:	5b                   	pop    %ebx
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800857:	eb 07                	jmp    800860 <strchr+0x13>
		if (*s == c)
  800859:	38 ca                	cmp    %cl,%dl
  80085b:	74 0f                	je     80086c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085d:	83 c0 01             	add    $0x1,%eax
  800860:	0f b6 10             	movzbl (%eax),%edx
  800863:	84 d2                	test   %dl,%dl
  800865:	75 f2                	jne    800859 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800878:	eb 03                	jmp    80087d <strfind+0xf>
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800880:	38 ca                	cmp    %cl,%dl
  800882:	74 04                	je     800888 <strfind+0x1a>
  800884:	84 d2                	test   %dl,%dl
  800886:	75 f2                	jne    80087a <strfind+0xc>
			break;
	return (char *) s;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 7d 08             	mov    0x8(%ebp),%edi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800896:	85 c9                	test   %ecx,%ecx
  800898:	74 36                	je     8008d0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a0:	75 28                	jne    8008ca <memset+0x40>
  8008a2:	f6 c1 03             	test   $0x3,%cl
  8008a5:	75 23                	jne    8008ca <memset+0x40>
		c &= 0xFF;
  8008a7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ab:	89 d3                	mov    %edx,%ebx
  8008ad:	c1 e3 08             	shl    $0x8,%ebx
  8008b0:	89 d6                	mov    %edx,%esi
  8008b2:	c1 e6 18             	shl    $0x18,%esi
  8008b5:	89 d0                	mov    %edx,%eax
  8008b7:	c1 e0 10             	shl    $0x10,%eax
  8008ba:	09 f0                	or     %esi,%eax
  8008bc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	09 d0                	or     %edx,%eax
  8008c2:	c1 e9 02             	shr    $0x2,%ecx
  8008c5:	fc                   	cld    
  8008c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c8:	eb 06                	jmp    8008d0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	fc                   	cld    
  8008ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d0:	89 f8                	mov    %edi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e5:	39 c6                	cmp    %eax,%esi
  8008e7:	73 35                	jae    80091e <memmove+0x47>
  8008e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ec:	39 d0                	cmp    %edx,%eax
  8008ee:	73 2e                	jae    80091e <memmove+0x47>
		s += n;
		d += n;
  8008f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	09 fe                	or     %edi,%esi
  8008f7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fd:	75 13                	jne    800912 <memmove+0x3b>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 0e                	jne    800912 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800904:	83 ef 04             	sub    $0x4,%edi
  800907:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090a:	c1 e9 02             	shr    $0x2,%ecx
  80090d:	fd                   	std    
  80090e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800910:	eb 09                	jmp    80091b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800912:	83 ef 01             	sub    $0x1,%edi
  800915:	8d 72 ff             	lea    -0x1(%edx),%esi
  800918:	fd                   	std    
  800919:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091b:	fc                   	cld    
  80091c:	eb 1d                	jmp    80093b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091e:	89 f2                	mov    %esi,%edx
  800920:	09 c2                	or     %eax,%edx
  800922:	f6 c2 03             	test   $0x3,%dl
  800925:	75 0f                	jne    800936 <memmove+0x5f>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 0a                	jne    800936 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80092c:	c1 e9 02             	shr    $0x2,%ecx
  80092f:	89 c7                	mov    %eax,%edi
  800931:	fc                   	cld    
  800932:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800934:	eb 05                	jmp    80093b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800942:	ff 75 10             	pushl  0x10(%ebp)
  800945:	ff 75 0c             	pushl  0xc(%ebp)
  800948:	ff 75 08             	pushl  0x8(%ebp)
  80094b:	e8 87 ff ff ff       	call   8008d7 <memmove>
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	89 c6                	mov    %eax,%esi
  80095f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800962:	eb 1a                	jmp    80097e <memcmp+0x2c>
		if (*s1 != *s2)
  800964:	0f b6 08             	movzbl (%eax),%ecx
  800967:	0f b6 1a             	movzbl (%edx),%ebx
  80096a:	38 d9                	cmp    %bl,%cl
  80096c:	74 0a                	je     800978 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80096e:	0f b6 c1             	movzbl %cl,%eax
  800971:	0f b6 db             	movzbl %bl,%ebx
  800974:	29 d8                	sub    %ebx,%eax
  800976:	eb 0f                	jmp    800987 <memcmp+0x35>
		s1++, s2++;
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	39 f0                	cmp    %esi,%eax
  800980:	75 e2                	jne    800964 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800992:	89 c1                	mov    %eax,%ecx
  800994:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800997:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099b:	eb 0a                	jmp    8009a7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	39 da                	cmp    %ebx,%edx
  8009a2:	74 07                	je     8009ab <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a4:	83 c0 01             	add    $0x1,%eax
  8009a7:	39 c8                	cmp    %ecx,%eax
  8009a9:	72 f2                	jb     80099d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ab:	5b                   	pop    %ebx
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	57                   	push   %edi
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	eb 03                	jmp    8009bf <strtol+0x11>
		s++;
  8009bc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bf:	0f b6 01             	movzbl (%ecx),%eax
  8009c2:	3c 20                	cmp    $0x20,%al
  8009c4:	74 f6                	je     8009bc <strtol+0xe>
  8009c6:	3c 09                	cmp    $0x9,%al
  8009c8:	74 f2                	je     8009bc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ca:	3c 2b                	cmp    $0x2b,%al
  8009cc:	75 0a                	jne    8009d8 <strtol+0x2a>
		s++;
  8009ce:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d6:	eb 11                	jmp    8009e9 <strtol+0x3b>
  8009d8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009dd:	3c 2d                	cmp    $0x2d,%al
  8009df:	75 08                	jne    8009e9 <strtol+0x3b>
		s++, neg = 1;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ef:	75 15                	jne    800a06 <strtol+0x58>
  8009f1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f4:	75 10                	jne    800a06 <strtol+0x58>
  8009f6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009fa:	75 7c                	jne    800a78 <strtol+0xca>
		s += 2, base = 16;
  8009fc:	83 c1 02             	add    $0x2,%ecx
  8009ff:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a04:	eb 16                	jmp    800a1c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a06:	85 db                	test   %ebx,%ebx
  800a08:	75 12                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a12:	75 08                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a24:	0f b6 11             	movzbl (%ecx),%edx
  800a27:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 09             	cmp    $0x9,%bl
  800a2f:	77 08                	ja     800a39 <strtol+0x8b>
			dig = *s - '0';
  800a31:	0f be d2             	movsbl %dl,%edx
  800a34:	83 ea 30             	sub    $0x30,%edx
  800a37:	eb 22                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a39:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 19             	cmp    $0x19,%bl
  800a41:	77 08                	ja     800a4b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a43:	0f be d2             	movsbl %dl,%edx
  800a46:	83 ea 57             	sub    $0x57,%edx
  800a49:	eb 10                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a4b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	80 fb 19             	cmp    $0x19,%bl
  800a53:	77 16                	ja     800a6b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5e:	7d 0b                	jge    800a6b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a67:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a69:	eb b9                	jmp    800a24 <strtol+0x76>

	if (endptr)
  800a6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6f:	74 0d                	je     800a7e <strtol+0xd0>
		*endptr = (char *) s;
  800a71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a74:	89 0e                	mov    %ecx,(%esi)
  800a76:	eb 06                	jmp    800a7e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	74 98                	je     800a14 <strtol+0x66>
  800a7c:	eb 9e                	jmp    800a1c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a7e:	89 c2                	mov    %eax,%edx
  800a80:	f7 da                	neg    %edx
  800a82:	85 ff                	test   %edi,%edi
  800a84:	0f 45 c2             	cmovne %edx,%eax
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	89 c3                	mov    %eax,%ebx
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	89 c6                	mov    %eax,%esi
  800aa3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_cgetc>:

int
sys_cgetc(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad7:	b8 03 00 00 00       	mov    $0x3,%eax
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	89 cb                	mov    %ecx,%ebx
  800ae1:	89 cf                	mov    %ecx,%edi
  800ae3:	89 ce                	mov    %ecx,%esi
  800ae5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	7e 17                	jle    800b02 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aeb:	83 ec 0c             	sub    $0xc,%esp
  800aee:	50                   	push   %eax
  800aef:	6a 03                	push   $0x3
  800af1:	68 9f 21 80 00       	push   $0x80219f
  800af6:	6a 23                	push   $0x23
  800af8:	68 bc 21 80 00       	push   $0x8021bc
  800afd:	e8 27 0f 00 00       	call   801a29 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_yield>:

void
sys_yield(void)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b39:	89 d1                	mov    %edx,%ecx
  800b3b:	89 d3                	mov    %edx,%ebx
  800b3d:	89 d7                	mov    %edx,%edi
  800b3f:	89 d6                	mov    %edx,%esi
  800b41:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	be 00 00 00 00       	mov    $0x0,%esi
  800b56:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b64:	89 f7                	mov    %esi,%edi
  800b66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7e 17                	jle    800b83 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 04                	push   $0x4
  800b72:	68 9f 21 80 00       	push   $0x80219f
  800b77:	6a 23                	push   $0x23
  800b79:	68 bc 21 80 00       	push   $0x8021bc
  800b7e:	e8 a6 0e 00 00       	call   801a29 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	b8 05 00 00 00       	mov    $0x5,%eax
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7e 17                	jle    800bc5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	50                   	push   %eax
  800bb2:	6a 05                	push   $0x5
  800bb4:	68 9f 21 80 00       	push   $0x80219f
  800bb9:	6a 23                	push   $0x23
  800bbb:	68 bc 21 80 00       	push   $0x8021bc
  800bc0:	e8 64 0e 00 00       	call   801a29 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bdb:	b8 06 00 00 00       	mov    $0x6,%eax
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	89 df                	mov    %ebx,%edi
  800be8:	89 de                	mov    %ebx,%esi
  800bea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	7e 17                	jle    800c07 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 06                	push   $0x6
  800bf6:	68 9f 21 80 00       	push   $0x80219f
  800bfb:	6a 23                	push   $0x23
  800bfd:	68 bc 21 80 00       	push   $0x8021bc
  800c02:	e8 22 0e 00 00       	call   801a29 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	89 df                	mov    %ebx,%edi
  800c2a:	89 de                	mov    %ebx,%esi
  800c2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 08                	push   $0x8
  800c38:	68 9f 21 80 00       	push   $0x80219f
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 bc 21 80 00       	push   $0x8021bc
  800c44:	e8 e0 0d 00 00       	call   801a29 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	89 df                	mov    %ebx,%edi
  800c6c:	89 de                	mov    %ebx,%esi
  800c6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 09                	push   $0x9
  800c7a:	68 9f 21 80 00       	push   $0x80219f
  800c7f:	6a 23                	push   $0x23
  800c81:	68 bc 21 80 00       	push   $0x8021bc
  800c86:	e8 9e 0d 00 00       	call   801a29 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 17                	jle    800ccd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 0a                	push   $0xa
  800cbc:	68 9f 21 80 00       	push   $0x80219f
  800cc1:	6a 23                	push   $0x23
  800cc3:	68 bc 21 80 00       	push   $0x8021bc
  800cc8:	e8 5c 0d 00 00       	call   801a29 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	be 00 00 00 00       	mov    $0x0,%esi
  800ce0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
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
  800d01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d06:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	89 cb                	mov    %ecx,%ebx
  800d10:	89 cf                	mov    %ecx,%edi
  800d12:	89 ce                	mov    %ecx,%esi
  800d14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 17                	jle    800d31 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 0d                	push   $0xd
  800d20:	68 9f 21 80 00       	push   $0x80219f
  800d25:	6a 23                	push   $0x23
  800d27:	68 bc 21 80 00       	push   $0x8021bc
  800d2c:	e8 f8 0c 00 00       	call   801a29 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3f:	05 00 00 00 30       	add    $0x30000000,%eax
  800d44:	c1 e8 0c             	shr    $0xc,%eax
}
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4f:	05 00 00 00 30       	add    $0x30000000,%eax
  800d54:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d59:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d5e:	5d                   	pop    %ebp
  800d5f:	c3                   	ret    

00800d60 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d60:	55                   	push   %ebp
  800d61:	89 e5                	mov    %esp,%ebp
  800d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d66:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d6b:	89 c2                	mov    %eax,%edx
  800d6d:	c1 ea 16             	shr    $0x16,%edx
  800d70:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d77:	f6 c2 01             	test   $0x1,%dl
  800d7a:	74 11                	je     800d8d <fd_alloc+0x2d>
  800d7c:	89 c2                	mov    %eax,%edx
  800d7e:	c1 ea 0c             	shr    $0xc,%edx
  800d81:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d88:	f6 c2 01             	test   $0x1,%dl
  800d8b:	75 09                	jne    800d96 <fd_alloc+0x36>
			*fd_store = fd;
  800d8d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d94:	eb 17                	jmp    800dad <fd_alloc+0x4d>
  800d96:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800d9b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800da0:	75 c9                	jne    800d6b <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800da2:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800da8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800db5:	83 f8 1f             	cmp    $0x1f,%eax
  800db8:	77 36                	ja     800df0 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dba:	c1 e0 0c             	shl    $0xc,%eax
  800dbd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dc2:	89 c2                	mov    %eax,%edx
  800dc4:	c1 ea 16             	shr    $0x16,%edx
  800dc7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dce:	f6 c2 01             	test   $0x1,%dl
  800dd1:	74 24                	je     800df7 <fd_lookup+0x48>
  800dd3:	89 c2                	mov    %eax,%edx
  800dd5:	c1 ea 0c             	shr    $0xc,%edx
  800dd8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ddf:	f6 c2 01             	test   $0x1,%dl
  800de2:	74 1a                	je     800dfe <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800de4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800de7:	89 02                	mov    %eax,(%edx)
	return 0;
  800de9:	b8 00 00 00 00       	mov    $0x0,%eax
  800dee:	eb 13                	jmp    800e03 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800df0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800df5:	eb 0c                	jmp    800e03 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800df7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800dfc:	eb 05                	jmp    800e03 <fd_lookup+0x54>
  800dfe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 08             	sub    $0x8,%esp
  800e0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0e:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e13:	eb 13                	jmp    800e28 <dev_lookup+0x23>
  800e15:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e18:	39 08                	cmp    %ecx,(%eax)
  800e1a:	75 0c                	jne    800e28 <dev_lookup+0x23>
			*dev = devtab[i];
  800e1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e21:	b8 00 00 00 00       	mov    $0x0,%eax
  800e26:	eb 2e                	jmp    800e56 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e28:	8b 02                	mov    (%edx),%eax
  800e2a:	85 c0                	test   %eax,%eax
  800e2c:	75 e7                	jne    800e15 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e2e:	a1 04 40 80 00       	mov    0x804004,%eax
  800e33:	8b 40 48             	mov    0x48(%eax),%eax
  800e36:	83 ec 04             	sub    $0x4,%esp
  800e39:	51                   	push   %ecx
  800e3a:	50                   	push   %eax
  800e3b:	68 cc 21 80 00       	push   $0x8021cc
  800e40:	e8 fc f2 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800e45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e48:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e56:	c9                   	leave  
  800e57:	c3                   	ret    

00800e58 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	56                   	push   %esi
  800e5c:	53                   	push   %ebx
  800e5d:	83 ec 10             	sub    $0x10,%esp
  800e60:	8b 75 08             	mov    0x8(%ebp),%esi
  800e63:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e69:	50                   	push   %eax
  800e6a:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e70:	c1 e8 0c             	shr    $0xc,%eax
  800e73:	50                   	push   %eax
  800e74:	e8 36 ff ff ff       	call   800daf <fd_lookup>
  800e79:	83 c4 08             	add    $0x8,%esp
  800e7c:	85 c0                	test   %eax,%eax
  800e7e:	78 05                	js     800e85 <fd_close+0x2d>
	    || fd != fd2)
  800e80:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e83:	74 0c                	je     800e91 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e85:	84 db                	test   %bl,%bl
  800e87:	ba 00 00 00 00       	mov    $0x0,%edx
  800e8c:	0f 44 c2             	cmove  %edx,%eax
  800e8f:	eb 41                	jmp    800ed2 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e91:	83 ec 08             	sub    $0x8,%esp
  800e94:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800e97:	50                   	push   %eax
  800e98:	ff 36                	pushl  (%esi)
  800e9a:	e8 66 ff ff ff       	call   800e05 <dev_lookup>
  800e9f:	89 c3                	mov    %eax,%ebx
  800ea1:	83 c4 10             	add    $0x10,%esp
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	78 1a                	js     800ec2 <fd_close+0x6a>
		if (dev->dev_close)
  800ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eab:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eae:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800eb3:	85 c0                	test   %eax,%eax
  800eb5:	74 0b                	je     800ec2 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800eb7:	83 ec 0c             	sub    $0xc,%esp
  800eba:	56                   	push   %esi
  800ebb:	ff d0                	call   *%eax
  800ebd:	89 c3                	mov    %eax,%ebx
  800ebf:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	56                   	push   %esi
  800ec6:	6a 00                	push   $0x0
  800ec8:	e8 00 fd ff ff       	call   800bcd <sys_page_unmap>
	return r;
  800ecd:	83 c4 10             	add    $0x10,%esp
  800ed0:	89 d8                	mov    %ebx,%eax
}
  800ed2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800edf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ee2:	50                   	push   %eax
  800ee3:	ff 75 08             	pushl  0x8(%ebp)
  800ee6:	e8 c4 fe ff ff       	call   800daf <fd_lookup>
  800eeb:	83 c4 08             	add    $0x8,%esp
  800eee:	85 c0                	test   %eax,%eax
  800ef0:	78 10                	js     800f02 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800ef2:	83 ec 08             	sub    $0x8,%esp
  800ef5:	6a 01                	push   $0x1
  800ef7:	ff 75 f4             	pushl  -0xc(%ebp)
  800efa:	e8 59 ff ff ff       	call   800e58 <fd_close>
  800eff:	83 c4 10             	add    $0x10,%esp
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <close_all>:

void
close_all(void)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	53                   	push   %ebx
  800f08:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f0b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	53                   	push   %ebx
  800f14:	e8 c0 ff ff ff       	call   800ed9 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f19:	83 c3 01             	add    $0x1,%ebx
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	83 fb 20             	cmp    $0x20,%ebx
  800f22:	75 ec                	jne    800f10 <close_all+0xc>
		close(i);
}
  800f24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f27:	c9                   	leave  
  800f28:	c3                   	ret    

00800f29 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	57                   	push   %edi
  800f2d:	56                   	push   %esi
  800f2e:	53                   	push   %ebx
  800f2f:	83 ec 2c             	sub    $0x2c,%esp
  800f32:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f35:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f38:	50                   	push   %eax
  800f39:	ff 75 08             	pushl  0x8(%ebp)
  800f3c:	e8 6e fe ff ff       	call   800daf <fd_lookup>
  800f41:	83 c4 08             	add    $0x8,%esp
  800f44:	85 c0                	test   %eax,%eax
  800f46:	0f 88 c1 00 00 00    	js     80100d <dup+0xe4>
		return r;
	close(newfdnum);
  800f4c:	83 ec 0c             	sub    $0xc,%esp
  800f4f:	56                   	push   %esi
  800f50:	e8 84 ff ff ff       	call   800ed9 <close>

	newfd = INDEX2FD(newfdnum);
  800f55:	89 f3                	mov    %esi,%ebx
  800f57:	c1 e3 0c             	shl    $0xc,%ebx
  800f5a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f60:	83 c4 04             	add    $0x4,%esp
  800f63:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f66:	e8 de fd ff ff       	call   800d49 <fd2data>
  800f6b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f6d:	89 1c 24             	mov    %ebx,(%esp)
  800f70:	e8 d4 fd ff ff       	call   800d49 <fd2data>
  800f75:	83 c4 10             	add    $0x10,%esp
  800f78:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f7b:	89 f8                	mov    %edi,%eax
  800f7d:	c1 e8 16             	shr    $0x16,%eax
  800f80:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f87:	a8 01                	test   $0x1,%al
  800f89:	74 37                	je     800fc2 <dup+0x99>
  800f8b:	89 f8                	mov    %edi,%eax
  800f8d:	c1 e8 0c             	shr    $0xc,%eax
  800f90:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f97:	f6 c2 01             	test   $0x1,%dl
  800f9a:	74 26                	je     800fc2 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f9c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	25 07 0e 00 00       	and    $0xe07,%eax
  800fab:	50                   	push   %eax
  800fac:	ff 75 d4             	pushl  -0x2c(%ebp)
  800faf:	6a 00                	push   $0x0
  800fb1:	57                   	push   %edi
  800fb2:	6a 00                	push   $0x0
  800fb4:	e8 d2 fb ff ff       	call   800b8b <sys_page_map>
  800fb9:	89 c7                	mov    %eax,%edi
  800fbb:	83 c4 20             	add    $0x20,%esp
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	78 2e                	js     800ff0 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fc2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fc5:	89 d0                	mov    %edx,%eax
  800fc7:	c1 e8 0c             	shr    $0xc,%eax
  800fca:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fd1:	83 ec 0c             	sub    $0xc,%esp
  800fd4:	25 07 0e 00 00       	and    $0xe07,%eax
  800fd9:	50                   	push   %eax
  800fda:	53                   	push   %ebx
  800fdb:	6a 00                	push   $0x0
  800fdd:	52                   	push   %edx
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 a6 fb ff ff       	call   800b8b <sys_page_map>
  800fe5:	89 c7                	mov    %eax,%edi
  800fe7:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800fea:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fec:	85 ff                	test   %edi,%edi
  800fee:	79 1d                	jns    80100d <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800ff0:	83 ec 08             	sub    $0x8,%esp
  800ff3:	53                   	push   %ebx
  800ff4:	6a 00                	push   $0x0
  800ff6:	e8 d2 fb ff ff       	call   800bcd <sys_page_unmap>
	sys_page_unmap(0, nva);
  800ffb:	83 c4 08             	add    $0x8,%esp
  800ffe:	ff 75 d4             	pushl  -0x2c(%ebp)
  801001:	6a 00                	push   $0x0
  801003:	e8 c5 fb ff ff       	call   800bcd <sys_page_unmap>
	return r;
  801008:	83 c4 10             	add    $0x10,%esp
  80100b:	89 f8                	mov    %edi,%eax
}
  80100d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801010:	5b                   	pop    %ebx
  801011:	5e                   	pop    %esi
  801012:	5f                   	pop    %edi
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	53                   	push   %ebx
  801019:	83 ec 14             	sub    $0x14,%esp
  80101c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80101f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801022:	50                   	push   %eax
  801023:	53                   	push   %ebx
  801024:	e8 86 fd ff ff       	call   800daf <fd_lookup>
  801029:	83 c4 08             	add    $0x8,%esp
  80102c:	89 c2                	mov    %eax,%edx
  80102e:	85 c0                	test   %eax,%eax
  801030:	78 6d                	js     80109f <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801032:	83 ec 08             	sub    $0x8,%esp
  801035:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801038:	50                   	push   %eax
  801039:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80103c:	ff 30                	pushl  (%eax)
  80103e:	e8 c2 fd ff ff       	call   800e05 <dev_lookup>
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	85 c0                	test   %eax,%eax
  801048:	78 4c                	js     801096 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80104a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80104d:	8b 42 08             	mov    0x8(%edx),%eax
  801050:	83 e0 03             	and    $0x3,%eax
  801053:	83 f8 01             	cmp    $0x1,%eax
  801056:	75 21                	jne    801079 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801058:	a1 04 40 80 00       	mov    0x804004,%eax
  80105d:	8b 40 48             	mov    0x48(%eax),%eax
  801060:	83 ec 04             	sub    $0x4,%esp
  801063:	53                   	push   %ebx
  801064:	50                   	push   %eax
  801065:	68 0d 22 80 00       	push   $0x80220d
  80106a:	e8 d2 f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801077:	eb 26                	jmp    80109f <read+0x8a>
	}
	if (!dev->dev_read)
  801079:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80107c:	8b 40 08             	mov    0x8(%eax),%eax
  80107f:	85 c0                	test   %eax,%eax
  801081:	74 17                	je     80109a <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801083:	83 ec 04             	sub    $0x4,%esp
  801086:	ff 75 10             	pushl  0x10(%ebp)
  801089:	ff 75 0c             	pushl  0xc(%ebp)
  80108c:	52                   	push   %edx
  80108d:	ff d0                	call   *%eax
  80108f:	89 c2                	mov    %eax,%edx
  801091:	83 c4 10             	add    $0x10,%esp
  801094:	eb 09                	jmp    80109f <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801096:	89 c2                	mov    %eax,%edx
  801098:	eb 05                	jmp    80109f <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80109a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80109f:	89 d0                	mov    %edx,%eax
  8010a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010a4:	c9                   	leave  
  8010a5:	c3                   	ret    

008010a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	57                   	push   %edi
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	83 ec 0c             	sub    $0xc,%esp
  8010af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010b2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010ba:	eb 21                	jmp    8010dd <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010bc:	83 ec 04             	sub    $0x4,%esp
  8010bf:	89 f0                	mov    %esi,%eax
  8010c1:	29 d8                	sub    %ebx,%eax
  8010c3:	50                   	push   %eax
  8010c4:	89 d8                	mov    %ebx,%eax
  8010c6:	03 45 0c             	add    0xc(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	57                   	push   %edi
  8010cb:	e8 45 ff ff ff       	call   801015 <read>
		if (m < 0)
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	85 c0                	test   %eax,%eax
  8010d5:	78 10                	js     8010e7 <readn+0x41>
			return m;
		if (m == 0)
  8010d7:	85 c0                	test   %eax,%eax
  8010d9:	74 0a                	je     8010e5 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010db:	01 c3                	add    %eax,%ebx
  8010dd:	39 f3                	cmp    %esi,%ebx
  8010df:	72 db                	jb     8010bc <readn+0x16>
  8010e1:	89 d8                	mov    %ebx,%eax
  8010e3:	eb 02                	jmp    8010e7 <readn+0x41>
  8010e5:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ea:	5b                   	pop    %ebx
  8010eb:	5e                   	pop    %esi
  8010ec:	5f                   	pop    %edi
  8010ed:	5d                   	pop    %ebp
  8010ee:	c3                   	ret    

008010ef <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8010ef:	55                   	push   %ebp
  8010f0:	89 e5                	mov    %esp,%ebp
  8010f2:	53                   	push   %ebx
  8010f3:	83 ec 14             	sub    $0x14,%esp
  8010f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	53                   	push   %ebx
  8010fe:	e8 ac fc ff ff       	call   800daf <fd_lookup>
  801103:	83 c4 08             	add    $0x8,%esp
  801106:	89 c2                	mov    %eax,%edx
  801108:	85 c0                	test   %eax,%eax
  80110a:	78 68                	js     801174 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80110c:	83 ec 08             	sub    $0x8,%esp
  80110f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801112:	50                   	push   %eax
  801113:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801116:	ff 30                	pushl  (%eax)
  801118:	e8 e8 fc ff ff       	call   800e05 <dev_lookup>
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	85 c0                	test   %eax,%eax
  801122:	78 47                	js     80116b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801124:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801127:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80112b:	75 21                	jne    80114e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80112d:	a1 04 40 80 00       	mov    0x804004,%eax
  801132:	8b 40 48             	mov    0x48(%eax),%eax
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	53                   	push   %ebx
  801139:	50                   	push   %eax
  80113a:	68 29 22 80 00       	push   $0x802229
  80113f:	e8 fd ef ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  801144:	83 c4 10             	add    $0x10,%esp
  801147:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80114c:	eb 26                	jmp    801174 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80114e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801151:	8b 52 0c             	mov    0xc(%edx),%edx
  801154:	85 d2                	test   %edx,%edx
  801156:	74 17                	je     80116f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	ff 75 10             	pushl  0x10(%ebp)
  80115e:	ff 75 0c             	pushl  0xc(%ebp)
  801161:	50                   	push   %eax
  801162:	ff d2                	call   *%edx
  801164:	89 c2                	mov    %eax,%edx
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	eb 09                	jmp    801174 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116b:	89 c2                	mov    %eax,%edx
  80116d:	eb 05                	jmp    801174 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80116f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801174:	89 d0                	mov    %edx,%eax
  801176:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <seek>:

int
seek(int fdnum, off_t offset)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801181:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801184:	50                   	push   %eax
  801185:	ff 75 08             	pushl  0x8(%ebp)
  801188:	e8 22 fc ff ff       	call   800daf <fd_lookup>
  80118d:	83 c4 08             	add    $0x8,%esp
  801190:	85 c0                	test   %eax,%eax
  801192:	78 0e                	js     8011a2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801194:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80119d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011a2:	c9                   	leave  
  8011a3:	c3                   	ret    

008011a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	53                   	push   %ebx
  8011a8:	83 ec 14             	sub    $0x14,%esp
  8011ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b1:	50                   	push   %eax
  8011b2:	53                   	push   %ebx
  8011b3:	e8 f7 fb ff ff       	call   800daf <fd_lookup>
  8011b8:	83 c4 08             	add    $0x8,%esp
  8011bb:	89 c2                	mov    %eax,%edx
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 65                	js     801226 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c1:	83 ec 08             	sub    $0x8,%esp
  8011c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c7:	50                   	push   %eax
  8011c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cb:	ff 30                	pushl  (%eax)
  8011cd:	e8 33 fc ff ff       	call   800e05 <dev_lookup>
  8011d2:	83 c4 10             	add    $0x10,%esp
  8011d5:	85 c0                	test   %eax,%eax
  8011d7:	78 44                	js     80121d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dc:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e0:	75 21                	jne    801203 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011e2:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011e7:	8b 40 48             	mov    0x48(%eax),%eax
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	53                   	push   %ebx
  8011ee:	50                   	push   %eax
  8011ef:	68 ec 21 80 00       	push   $0x8021ec
  8011f4:	e8 48 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8011f9:	83 c4 10             	add    $0x10,%esp
  8011fc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801201:	eb 23                	jmp    801226 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801203:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801206:	8b 52 18             	mov    0x18(%edx),%edx
  801209:	85 d2                	test   %edx,%edx
  80120b:	74 14                	je     801221 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80120d:	83 ec 08             	sub    $0x8,%esp
  801210:	ff 75 0c             	pushl  0xc(%ebp)
  801213:	50                   	push   %eax
  801214:	ff d2                	call   *%edx
  801216:	89 c2                	mov    %eax,%edx
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	eb 09                	jmp    801226 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	eb 05                	jmp    801226 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801221:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801226:	89 d0                	mov    %edx,%eax
  801228:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122b:	c9                   	leave  
  80122c:	c3                   	ret    

0080122d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	53                   	push   %ebx
  801231:	83 ec 14             	sub    $0x14,%esp
  801234:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801237:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80123a:	50                   	push   %eax
  80123b:	ff 75 08             	pushl  0x8(%ebp)
  80123e:	e8 6c fb ff ff       	call   800daf <fd_lookup>
  801243:	83 c4 08             	add    $0x8,%esp
  801246:	89 c2                	mov    %eax,%edx
  801248:	85 c0                	test   %eax,%eax
  80124a:	78 58                	js     8012a4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801252:	50                   	push   %eax
  801253:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801256:	ff 30                	pushl  (%eax)
  801258:	e8 a8 fb ff ff       	call   800e05 <dev_lookup>
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	78 37                	js     80129b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801264:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801267:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80126b:	74 32                	je     80129f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80126d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801270:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801277:	00 00 00 
	stat->st_isdir = 0;
  80127a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801281:	00 00 00 
	stat->st_dev = dev;
  801284:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80128a:	83 ec 08             	sub    $0x8,%esp
  80128d:	53                   	push   %ebx
  80128e:	ff 75 f0             	pushl  -0x10(%ebp)
  801291:	ff 50 14             	call   *0x14(%eax)
  801294:	89 c2                	mov    %eax,%edx
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	eb 09                	jmp    8012a4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129b:	89 c2                	mov    %eax,%edx
  80129d:	eb 05                	jmp    8012a4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80129f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012a4:	89 d0                	mov    %edx,%eax
  8012a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a9:	c9                   	leave  
  8012aa:	c3                   	ret    

008012ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012ab:	55                   	push   %ebp
  8012ac:	89 e5                	mov    %esp,%ebp
  8012ae:	56                   	push   %esi
  8012af:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012b0:	83 ec 08             	sub    $0x8,%esp
  8012b3:	6a 00                	push   $0x0
  8012b5:	ff 75 08             	pushl  0x8(%ebp)
  8012b8:	e8 e9 01 00 00       	call   8014a6 <open>
  8012bd:	89 c3                	mov    %eax,%ebx
  8012bf:	83 c4 10             	add    $0x10,%esp
  8012c2:	85 c0                	test   %eax,%eax
  8012c4:	78 1b                	js     8012e1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	ff 75 0c             	pushl  0xc(%ebp)
  8012cc:	50                   	push   %eax
  8012cd:	e8 5b ff ff ff       	call   80122d <fstat>
  8012d2:	89 c6                	mov    %eax,%esi
	close(fd);
  8012d4:	89 1c 24             	mov    %ebx,(%esp)
  8012d7:	e8 fd fb ff ff       	call   800ed9 <close>
	return r;
  8012dc:	83 c4 10             	add    $0x10,%esp
  8012df:	89 f0                	mov    %esi,%eax
}
  8012e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012e4:	5b                   	pop    %ebx
  8012e5:	5e                   	pop    %esi
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    

008012e8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012e8:	55                   	push   %ebp
  8012e9:	89 e5                	mov    %esp,%ebp
  8012eb:	56                   	push   %esi
  8012ec:	53                   	push   %ebx
  8012ed:	89 c6                	mov    %eax,%esi
  8012ef:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8012f1:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012f8:	75 12                	jne    80130c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	6a 01                	push   $0x1
  8012ff:	e8 41 08 00 00       	call   801b45 <ipc_find_env>
  801304:	a3 00 40 80 00       	mov    %eax,0x804000
  801309:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80130c:	6a 07                	push   $0x7
  80130e:	68 00 50 80 00       	push   $0x805000
  801313:	56                   	push   %esi
  801314:	ff 35 00 40 80 00    	pushl  0x804000
  80131a:	e8 d2 07 00 00       	call   801af1 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80131f:	83 c4 0c             	add    $0xc,%esp
  801322:	6a 00                	push   $0x0
  801324:	53                   	push   %ebx
  801325:	6a 00                	push   $0x0
  801327:	e8 43 07 00 00       	call   801a6f <ipc_recv>
}
  80132c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132f:	5b                   	pop    %ebx
  801330:	5e                   	pop    %esi
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801339:	8b 45 08             	mov    0x8(%ebp),%eax
  80133c:	8b 40 0c             	mov    0xc(%eax),%eax
  80133f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801344:	8b 45 0c             	mov    0xc(%ebp),%eax
  801347:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80134c:	ba 00 00 00 00       	mov    $0x0,%edx
  801351:	b8 02 00 00 00       	mov    $0x2,%eax
  801356:	e8 8d ff ff ff       	call   8012e8 <fsipc>
}
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801363:	8b 45 08             	mov    0x8(%ebp),%eax
  801366:	8b 40 0c             	mov    0xc(%eax),%eax
  801369:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80136e:	ba 00 00 00 00       	mov    $0x0,%edx
  801373:	b8 06 00 00 00       	mov    $0x6,%eax
  801378:	e8 6b ff ff ff       	call   8012e8 <fsipc>
}
  80137d:	c9                   	leave  
  80137e:	c3                   	ret    

0080137f <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	53                   	push   %ebx
  801383:	83 ec 04             	sub    $0x4,%esp
  801386:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801389:	8b 45 08             	mov    0x8(%ebp),%eax
  80138c:	8b 40 0c             	mov    0xc(%eax),%eax
  80138f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801394:	ba 00 00 00 00       	mov    $0x0,%edx
  801399:	b8 05 00 00 00       	mov    $0x5,%eax
  80139e:	e8 45 ff ff ff       	call   8012e8 <fsipc>
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	78 2c                	js     8013d3 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013a7:	83 ec 08             	sub    $0x8,%esp
  8013aa:	68 00 50 80 00       	push   $0x805000
  8013af:	53                   	push   %ebx
  8013b0:	e8 90 f3 ff ff       	call   800745 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013b5:	a1 80 50 80 00       	mov    0x805080,%eax
  8013ba:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013c0:	a1 84 50 80 00       	mov    0x805084,%eax
  8013c5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013d8:	55                   	push   %ebp
  8013d9:	89 e5                	mov    %esp,%ebp
  8013db:	83 ec 0c             	sub    $0xc,%esp
  8013de:	8b 45 10             	mov    0x10(%ebp),%eax
  8013e1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013e6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013eb:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8013ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8013f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8013f4:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8013fa:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8013ff:	50                   	push   %eax
  801400:	ff 75 0c             	pushl  0xc(%ebp)
  801403:	68 08 50 80 00       	push   $0x805008
  801408:	e8 ca f4 ff ff       	call   8008d7 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80140d:	ba 00 00 00 00       	mov    $0x0,%edx
  801412:	b8 04 00 00 00       	mov    $0x4,%eax
  801417:	e8 cc fe ff ff       	call   8012e8 <fsipc>
            return r;

    return r;
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
  801423:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801426:	8b 45 08             	mov    0x8(%ebp),%eax
  801429:	8b 40 0c             	mov    0xc(%eax),%eax
  80142c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801431:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801437:	ba 00 00 00 00       	mov    $0x0,%edx
  80143c:	b8 03 00 00 00       	mov    $0x3,%eax
  801441:	e8 a2 fe ff ff       	call   8012e8 <fsipc>
  801446:	89 c3                	mov    %eax,%ebx
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 51                	js     80149d <devfile_read+0x7f>
		return r;
	assert(r <= n);
  80144c:	39 c6                	cmp    %eax,%esi
  80144e:	73 19                	jae    801469 <devfile_read+0x4b>
  801450:	68 58 22 80 00       	push   $0x802258
  801455:	68 5f 22 80 00       	push   $0x80225f
  80145a:	68 82 00 00 00       	push   $0x82
  80145f:	68 74 22 80 00       	push   $0x802274
  801464:	e8 c0 05 00 00       	call   801a29 <_panic>
	assert(r <= PGSIZE);
  801469:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80146e:	7e 19                	jle    801489 <devfile_read+0x6b>
  801470:	68 7f 22 80 00       	push   $0x80227f
  801475:	68 5f 22 80 00       	push   $0x80225f
  80147a:	68 83 00 00 00       	push   $0x83
  80147f:	68 74 22 80 00       	push   $0x802274
  801484:	e8 a0 05 00 00       	call   801a29 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801489:	83 ec 04             	sub    $0x4,%esp
  80148c:	50                   	push   %eax
  80148d:	68 00 50 80 00       	push   $0x805000
  801492:	ff 75 0c             	pushl  0xc(%ebp)
  801495:	e8 3d f4 ff ff       	call   8008d7 <memmove>
	return r;
  80149a:	83 c4 10             	add    $0x10,%esp
}
  80149d:	89 d8                	mov    %ebx,%eax
  80149f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014a2:	5b                   	pop    %ebx
  8014a3:	5e                   	pop    %esi
  8014a4:	5d                   	pop    %ebp
  8014a5:	c3                   	ret    

008014a6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014a6:	55                   	push   %ebp
  8014a7:	89 e5                	mov    %esp,%ebp
  8014a9:	53                   	push   %ebx
  8014aa:	83 ec 20             	sub    $0x20,%esp
  8014ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014b0:	53                   	push   %ebx
  8014b1:	e8 56 f2 ff ff       	call   80070c <strlen>
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014be:	7f 67                	jg     801527 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	e8 94 f8 ff ff       	call   800d60 <fd_alloc>
  8014cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8014cf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 57                	js     80152c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014d5:	83 ec 08             	sub    $0x8,%esp
  8014d8:	53                   	push   %ebx
  8014d9:	68 00 50 80 00       	push   $0x805000
  8014de:	e8 62 f2 ff ff       	call   800745 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014e6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8014f3:	e8 f0 fd ff ff       	call   8012e8 <fsipc>
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	79 14                	jns    801515 <open+0x6f>
		fd_close(fd, 0);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	6a 00                	push   $0x0
  801506:	ff 75 f4             	pushl  -0xc(%ebp)
  801509:	e8 4a f9 ff ff       	call   800e58 <fd_close>
		return r;
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	89 da                	mov    %ebx,%edx
  801513:	eb 17                	jmp    80152c <open+0x86>
	}

	return fd2num(fd);
  801515:	83 ec 0c             	sub    $0xc,%esp
  801518:	ff 75 f4             	pushl  -0xc(%ebp)
  80151b:	e8 19 f8 ff ff       	call   800d39 <fd2num>
  801520:	89 c2                	mov    %eax,%edx
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	eb 05                	jmp    80152c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801527:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80152c:	89 d0                	mov    %edx,%eax
  80152e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 08 00 00 00       	mov    $0x8,%eax
  801543:	e8 a0 fd ff ff       	call   8012e8 <fsipc>
}
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	56                   	push   %esi
  80154e:	53                   	push   %ebx
  80154f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801552:	83 ec 0c             	sub    $0xc,%esp
  801555:	ff 75 08             	pushl  0x8(%ebp)
  801558:	e8 ec f7 ff ff       	call   800d49 <fd2data>
  80155d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80155f:	83 c4 08             	add    $0x8,%esp
  801562:	68 8b 22 80 00       	push   $0x80228b
  801567:	53                   	push   %ebx
  801568:	e8 d8 f1 ff ff       	call   800745 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80156d:	8b 46 04             	mov    0x4(%esi),%eax
  801570:	2b 06                	sub    (%esi),%eax
  801572:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801578:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80157f:	00 00 00 
	stat->st_dev = &devpipe;
  801582:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801589:	30 80 00 
	return 0;
}
  80158c:	b8 00 00 00 00       	mov    $0x0,%eax
  801591:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 0c             	sub    $0xc,%esp
  80159f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015a2:	53                   	push   %ebx
  8015a3:	6a 00                	push   $0x0
  8015a5:	e8 23 f6 ff ff       	call   800bcd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015aa:	89 1c 24             	mov    %ebx,(%esp)
  8015ad:	e8 97 f7 ff ff       	call   800d49 <fd2data>
  8015b2:	83 c4 08             	add    $0x8,%esp
  8015b5:	50                   	push   %eax
  8015b6:	6a 00                	push   $0x0
  8015b8:	e8 10 f6 ff ff       	call   800bcd <sys_page_unmap>
}
  8015bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c0:	c9                   	leave  
  8015c1:	c3                   	ret    

008015c2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	57                   	push   %edi
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 1c             	sub    $0x1c,%esp
  8015cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015ce:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8015d5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015d8:	83 ec 0c             	sub    $0xc,%esp
  8015db:	ff 75 e0             	pushl  -0x20(%ebp)
  8015de:	e8 9b 05 00 00       	call   801b7e <pageref>
  8015e3:	89 c3                	mov    %eax,%ebx
  8015e5:	89 3c 24             	mov    %edi,(%esp)
  8015e8:	e8 91 05 00 00       	call   801b7e <pageref>
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	39 c3                	cmp    %eax,%ebx
  8015f2:	0f 94 c1             	sete   %cl
  8015f5:	0f b6 c9             	movzbl %cl,%ecx
  8015f8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8015fb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801601:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801604:	39 ce                	cmp    %ecx,%esi
  801606:	74 1b                	je     801623 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801608:	39 c3                	cmp    %eax,%ebx
  80160a:	75 c4                	jne    8015d0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80160c:	8b 42 58             	mov    0x58(%edx),%eax
  80160f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801612:	50                   	push   %eax
  801613:	56                   	push   %esi
  801614:	68 92 22 80 00       	push   $0x802292
  801619:	e8 23 eb ff ff       	call   800141 <cprintf>
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	eb ad                	jmp    8015d0 <_pipeisclosed+0xe>
	}
}
  801623:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801626:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801629:	5b                   	pop    %ebx
  80162a:	5e                   	pop    %esi
  80162b:	5f                   	pop    %edi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    

0080162e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	57                   	push   %edi
  801632:	56                   	push   %esi
  801633:	53                   	push   %ebx
  801634:	83 ec 28             	sub    $0x28,%esp
  801637:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80163a:	56                   	push   %esi
  80163b:	e8 09 f7 ff ff       	call   800d49 <fd2data>
  801640:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801642:	83 c4 10             	add    $0x10,%esp
  801645:	bf 00 00 00 00       	mov    $0x0,%edi
  80164a:	eb 4b                	jmp    801697 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80164c:	89 da                	mov    %ebx,%edx
  80164e:	89 f0                	mov    %esi,%eax
  801650:	e8 6d ff ff ff       	call   8015c2 <_pipeisclosed>
  801655:	85 c0                	test   %eax,%eax
  801657:	75 48                	jne    8016a1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801659:	e8 cb f4 ff ff       	call   800b29 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80165e:	8b 43 04             	mov    0x4(%ebx),%eax
  801661:	8b 0b                	mov    (%ebx),%ecx
  801663:	8d 51 20             	lea    0x20(%ecx),%edx
  801666:	39 d0                	cmp    %edx,%eax
  801668:	73 e2                	jae    80164c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80166a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80166d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801671:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801674:	89 c2                	mov    %eax,%edx
  801676:	c1 fa 1f             	sar    $0x1f,%edx
  801679:	89 d1                	mov    %edx,%ecx
  80167b:	c1 e9 1b             	shr    $0x1b,%ecx
  80167e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801681:	83 e2 1f             	and    $0x1f,%edx
  801684:	29 ca                	sub    %ecx,%edx
  801686:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80168a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80168e:	83 c0 01             	add    $0x1,%eax
  801691:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801694:	83 c7 01             	add    $0x1,%edi
  801697:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80169a:	75 c2                	jne    80165e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80169c:	8b 45 10             	mov    0x10(%ebp),%eax
  80169f:	eb 05                	jmp    8016a6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016a1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a9:	5b                   	pop    %ebx
  8016aa:	5e                   	pop    %esi
  8016ab:	5f                   	pop    %edi
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	57                   	push   %edi
  8016b2:	56                   	push   %esi
  8016b3:	53                   	push   %ebx
  8016b4:	83 ec 18             	sub    $0x18,%esp
  8016b7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016ba:	57                   	push   %edi
  8016bb:	e8 89 f6 ff ff       	call   800d49 <fd2data>
  8016c0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ca:	eb 3d                	jmp    801709 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016cc:	85 db                	test   %ebx,%ebx
  8016ce:	74 04                	je     8016d4 <devpipe_read+0x26>
				return i;
  8016d0:	89 d8                	mov    %ebx,%eax
  8016d2:	eb 44                	jmp    801718 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016d4:	89 f2                	mov    %esi,%edx
  8016d6:	89 f8                	mov    %edi,%eax
  8016d8:	e8 e5 fe ff ff       	call   8015c2 <_pipeisclosed>
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	75 32                	jne    801713 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016e1:	e8 43 f4 ff ff       	call   800b29 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016e6:	8b 06                	mov    (%esi),%eax
  8016e8:	3b 46 04             	cmp    0x4(%esi),%eax
  8016eb:	74 df                	je     8016cc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ed:	99                   	cltd   
  8016ee:	c1 ea 1b             	shr    $0x1b,%edx
  8016f1:	01 d0                	add    %edx,%eax
  8016f3:	83 e0 1f             	and    $0x1f,%eax
  8016f6:	29 d0                	sub    %edx,%eax
  8016f8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8016fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801700:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801703:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801706:	83 c3 01             	add    $0x1,%ebx
  801709:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80170c:	75 d8                	jne    8016e6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80170e:	8b 45 10             	mov    0x10(%ebp),%eax
  801711:	eb 05                	jmp    801718 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801713:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801718:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80171b:	5b                   	pop    %ebx
  80171c:	5e                   	pop    %esi
  80171d:	5f                   	pop    %edi
  80171e:	5d                   	pop    %ebp
  80171f:	c3                   	ret    

00801720 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801720:	55                   	push   %ebp
  801721:	89 e5                	mov    %esp,%ebp
  801723:	56                   	push   %esi
  801724:	53                   	push   %ebx
  801725:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801728:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172b:	50                   	push   %eax
  80172c:	e8 2f f6 ff ff       	call   800d60 <fd_alloc>
  801731:	83 c4 10             	add    $0x10,%esp
  801734:	89 c2                	mov    %eax,%edx
  801736:	85 c0                	test   %eax,%eax
  801738:	0f 88 2c 01 00 00    	js     80186a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80173e:	83 ec 04             	sub    $0x4,%esp
  801741:	68 07 04 00 00       	push   $0x407
  801746:	ff 75 f4             	pushl  -0xc(%ebp)
  801749:	6a 00                	push   $0x0
  80174b:	e8 f8 f3 ff ff       	call   800b48 <sys_page_alloc>
  801750:	83 c4 10             	add    $0x10,%esp
  801753:	89 c2                	mov    %eax,%edx
  801755:	85 c0                	test   %eax,%eax
  801757:	0f 88 0d 01 00 00    	js     80186a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80175d:	83 ec 0c             	sub    $0xc,%esp
  801760:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801763:	50                   	push   %eax
  801764:	e8 f7 f5 ff ff       	call   800d60 <fd_alloc>
  801769:	89 c3                	mov    %eax,%ebx
  80176b:	83 c4 10             	add    $0x10,%esp
  80176e:	85 c0                	test   %eax,%eax
  801770:	0f 88 e2 00 00 00    	js     801858 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	68 07 04 00 00       	push   $0x407
  80177e:	ff 75 f0             	pushl  -0x10(%ebp)
  801781:	6a 00                	push   $0x0
  801783:	e8 c0 f3 ff ff       	call   800b48 <sys_page_alloc>
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	83 c4 10             	add    $0x10,%esp
  80178d:	85 c0                	test   %eax,%eax
  80178f:	0f 88 c3 00 00 00    	js     801858 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801795:	83 ec 0c             	sub    $0xc,%esp
  801798:	ff 75 f4             	pushl  -0xc(%ebp)
  80179b:	e8 a9 f5 ff ff       	call   800d49 <fd2data>
  8017a0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017a2:	83 c4 0c             	add    $0xc,%esp
  8017a5:	68 07 04 00 00       	push   $0x407
  8017aa:	50                   	push   %eax
  8017ab:	6a 00                	push   $0x0
  8017ad:	e8 96 f3 ff ff       	call   800b48 <sys_page_alloc>
  8017b2:	89 c3                	mov    %eax,%ebx
  8017b4:	83 c4 10             	add    $0x10,%esp
  8017b7:	85 c0                	test   %eax,%eax
  8017b9:	0f 88 89 00 00 00    	js     801848 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017bf:	83 ec 0c             	sub    $0xc,%esp
  8017c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8017c5:	e8 7f f5 ff ff       	call   800d49 <fd2data>
  8017ca:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017d1:	50                   	push   %eax
  8017d2:	6a 00                	push   $0x0
  8017d4:	56                   	push   %esi
  8017d5:	6a 00                	push   $0x0
  8017d7:	e8 af f3 ff ff       	call   800b8b <sys_page_map>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	83 c4 20             	add    $0x20,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 55                	js     80183a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017e5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ee:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017f3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8017fa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801800:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801803:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801808:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80180f:	83 ec 0c             	sub    $0xc,%esp
  801812:	ff 75 f4             	pushl  -0xc(%ebp)
  801815:	e8 1f f5 ff ff       	call   800d39 <fd2num>
  80181a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80181d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80181f:	83 c4 04             	add    $0x4,%esp
  801822:	ff 75 f0             	pushl  -0x10(%ebp)
  801825:	e8 0f f5 ff ff       	call   800d39 <fd2num>
  80182a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80182d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801830:	83 c4 10             	add    $0x10,%esp
  801833:	ba 00 00 00 00       	mov    $0x0,%edx
  801838:	eb 30                	jmp    80186a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80183a:	83 ec 08             	sub    $0x8,%esp
  80183d:	56                   	push   %esi
  80183e:	6a 00                	push   $0x0
  801840:	e8 88 f3 ff ff       	call   800bcd <sys_page_unmap>
  801845:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801848:	83 ec 08             	sub    $0x8,%esp
  80184b:	ff 75 f0             	pushl  -0x10(%ebp)
  80184e:	6a 00                	push   $0x0
  801850:	e8 78 f3 ff ff       	call   800bcd <sys_page_unmap>
  801855:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801858:	83 ec 08             	sub    $0x8,%esp
  80185b:	ff 75 f4             	pushl  -0xc(%ebp)
  80185e:	6a 00                	push   $0x0
  801860:	e8 68 f3 ff ff       	call   800bcd <sys_page_unmap>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80186a:	89 d0                	mov    %edx,%eax
  80186c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80186f:	5b                   	pop    %ebx
  801870:	5e                   	pop    %esi
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801879:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187c:	50                   	push   %eax
  80187d:	ff 75 08             	pushl  0x8(%ebp)
  801880:	e8 2a f5 ff ff       	call   800daf <fd_lookup>
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 18                	js     8018a4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80188c:	83 ec 0c             	sub    $0xc,%esp
  80188f:	ff 75 f4             	pushl  -0xc(%ebp)
  801892:	e8 b2 f4 ff ff       	call   800d49 <fd2data>
	return _pipeisclosed(fd, p);
  801897:	89 c2                	mov    %eax,%edx
  801899:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189c:	e8 21 fd ff ff       	call   8015c2 <_pipeisclosed>
  8018a1:	83 c4 10             	add    $0x10,%esp
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ae:	5d                   	pop    %ebp
  8018af:	c3                   	ret    

008018b0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018b0:	55                   	push   %ebp
  8018b1:	89 e5                	mov    %esp,%ebp
  8018b3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018b6:	68 aa 22 80 00       	push   $0x8022aa
  8018bb:	ff 75 0c             	pushl  0xc(%ebp)
  8018be:	e8 82 ee ff ff       	call   800745 <strcpy>
	return 0;
}
  8018c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c8:	c9                   	leave  
  8018c9:	c3                   	ret    

008018ca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018ca:	55                   	push   %ebp
  8018cb:	89 e5                	mov    %esp,%ebp
  8018cd:	57                   	push   %edi
  8018ce:	56                   	push   %esi
  8018cf:	53                   	push   %ebx
  8018d0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018d6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018db:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e1:	eb 2d                	jmp    801910 <devcons_write+0x46>
		m = n - tot;
  8018e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018e6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018e8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018eb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018f0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018f3:	83 ec 04             	sub    $0x4,%esp
  8018f6:	53                   	push   %ebx
  8018f7:	03 45 0c             	add    0xc(%ebp),%eax
  8018fa:	50                   	push   %eax
  8018fb:	57                   	push   %edi
  8018fc:	e8 d6 ef ff ff       	call   8008d7 <memmove>
		sys_cputs(buf, m);
  801901:	83 c4 08             	add    $0x8,%esp
  801904:	53                   	push   %ebx
  801905:	57                   	push   %edi
  801906:	e8 81 f1 ff ff       	call   800a8c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80190b:	01 de                	add    %ebx,%esi
  80190d:	83 c4 10             	add    $0x10,%esp
  801910:	89 f0                	mov    %esi,%eax
  801912:	3b 75 10             	cmp    0x10(%ebp),%esi
  801915:	72 cc                	jb     8018e3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801917:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5f                   	pop    %edi
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  80192a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80192e:	74 2a                	je     80195a <devcons_read+0x3b>
  801930:	eb 05                	jmp    801937 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801932:	e8 f2 f1 ff ff       	call   800b29 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801937:	e8 6e f1 ff ff       	call   800aaa <sys_cgetc>
  80193c:	85 c0                	test   %eax,%eax
  80193e:	74 f2                	je     801932 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801940:	85 c0                	test   %eax,%eax
  801942:	78 16                	js     80195a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801944:	83 f8 04             	cmp    $0x4,%eax
  801947:	74 0c                	je     801955 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801949:	8b 55 0c             	mov    0xc(%ebp),%edx
  80194c:	88 02                	mov    %al,(%edx)
	return 1;
  80194e:	b8 01 00 00 00       	mov    $0x1,%eax
  801953:	eb 05                	jmp    80195a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801955:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801968:	6a 01                	push   $0x1
  80196a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80196d:	50                   	push   %eax
  80196e:	e8 19 f1 ff ff       	call   800a8c <sys_cputs>
}
  801973:	83 c4 10             	add    $0x10,%esp
  801976:	c9                   	leave  
  801977:	c3                   	ret    

00801978 <getchar>:

int
getchar(void)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80197e:	6a 01                	push   $0x1
  801980:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801983:	50                   	push   %eax
  801984:	6a 00                	push   $0x0
  801986:	e8 8a f6 ff ff       	call   801015 <read>
	if (r < 0)
  80198b:	83 c4 10             	add    $0x10,%esp
  80198e:	85 c0                	test   %eax,%eax
  801990:	78 0f                	js     8019a1 <getchar+0x29>
		return r;
	if (r < 1)
  801992:	85 c0                	test   %eax,%eax
  801994:	7e 06                	jle    80199c <getchar+0x24>
		return -E_EOF;
	return c;
  801996:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80199a:	eb 05                	jmp    8019a1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80199c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019a1:	c9                   	leave  
  8019a2:	c3                   	ret    

008019a3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ac:	50                   	push   %eax
  8019ad:	ff 75 08             	pushl  0x8(%ebp)
  8019b0:	e8 fa f3 ff ff       	call   800daf <fd_lookup>
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	78 11                	js     8019cd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019c5:	39 10                	cmp    %edx,(%eax)
  8019c7:	0f 94 c0             	sete   %al
  8019ca:	0f b6 c0             	movzbl %al,%eax
}
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <opencons>:

int
opencons(void)
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d8:	50                   	push   %eax
  8019d9:	e8 82 f3 ff ff       	call   800d60 <fd_alloc>
  8019de:	83 c4 10             	add    $0x10,%esp
		return r;
  8019e1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	78 3e                	js     801a25 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019e7:	83 ec 04             	sub    $0x4,%esp
  8019ea:	68 07 04 00 00       	push   $0x407
  8019ef:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f2:	6a 00                	push   $0x0
  8019f4:	e8 4f f1 ff ff       	call   800b48 <sys_page_alloc>
  8019f9:	83 c4 10             	add    $0x10,%esp
		return r;
  8019fc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 23                	js     801a25 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a02:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a10:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	50                   	push   %eax
  801a1b:	e8 19 f3 ff ff       	call   800d39 <fd2num>
  801a20:	89 c2                	mov    %eax,%edx
  801a22:	83 c4 10             	add    $0x10,%esp
}
  801a25:	89 d0                	mov    %edx,%eax
  801a27:	c9                   	leave  
  801a28:	c3                   	ret    

00801a29 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a29:	55                   	push   %ebp
  801a2a:	89 e5                	mov    %esp,%ebp
  801a2c:	56                   	push   %esi
  801a2d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a2e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a31:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a37:	e8 ce f0 ff ff       	call   800b0a <sys_getenvid>
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	ff 75 0c             	pushl  0xc(%ebp)
  801a42:	ff 75 08             	pushl  0x8(%ebp)
  801a45:	56                   	push   %esi
  801a46:	50                   	push   %eax
  801a47:	68 b8 22 80 00       	push   $0x8022b8
  801a4c:	e8 f0 e6 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a51:	83 c4 18             	add    $0x18,%esp
  801a54:	53                   	push   %ebx
  801a55:	ff 75 10             	pushl  0x10(%ebp)
  801a58:	e8 93 e6 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801a5d:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a64:	e8 d8 e6 ff ff       	call   800141 <cprintf>
  801a69:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a6c:	cc                   	int3   
  801a6d:	eb fd                	jmp    801a6c <_panic+0x43>

00801a6f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	57                   	push   %edi
  801a73:	56                   	push   %esi
  801a74:	53                   	push   %ebx
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	8b 75 08             	mov    0x8(%ebp),%esi
  801a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801a81:	85 f6                	test   %esi,%esi
  801a83:	74 06                	je     801a8b <ipc_recv+0x1c>
		*from_env_store = 0;
  801a85:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801a8b:	85 db                	test   %ebx,%ebx
  801a8d:	74 06                	je     801a95 <ipc_recv+0x26>
		*perm_store = 0;
  801a8f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801a95:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801a97:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801a9c:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	50                   	push   %eax
  801aa3:	e8 50 f2 ff ff       	call   800cf8 <sys_ipc_recv>
  801aa8:	89 c7                	mov    %eax,%edi
  801aaa:	83 c4 10             	add    $0x10,%esp
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	79 14                	jns    801ac5 <ipc_recv+0x56>
		cprintf("im dead");
  801ab1:	83 ec 0c             	sub    $0xc,%esp
  801ab4:	68 dc 22 80 00       	push   $0x8022dc
  801ab9:	e8 83 e6 ff ff       	call   800141 <cprintf>
		return r;
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	89 f8                	mov    %edi,%eax
  801ac3:	eb 24                	jmp    801ae9 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ac5:	85 f6                	test   %esi,%esi
  801ac7:	74 0a                	je     801ad3 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ac9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ace:	8b 40 74             	mov    0x74(%eax),%eax
  801ad1:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801ad3:	85 db                	test   %ebx,%ebx
  801ad5:	74 0a                	je     801ae1 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ad7:	a1 04 40 80 00       	mov    0x804004,%eax
  801adc:	8b 40 78             	mov    0x78(%eax),%eax
  801adf:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801ae1:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae6:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ae9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aec:	5b                   	pop    %ebx
  801aed:	5e                   	pop    %esi
  801aee:	5f                   	pop    %edi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	57                   	push   %edi
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801b03:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801b05:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b0a:	0f 44 d8             	cmove  %eax,%ebx
  801b0d:	eb 1c                	jmp    801b2b <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801b0f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b12:	74 12                	je     801b26 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801b14:	50                   	push   %eax
  801b15:	68 e4 22 80 00       	push   $0x8022e4
  801b1a:	6a 4e                	push   $0x4e
  801b1c:	68 f1 22 80 00       	push   $0x8022f1
  801b21:	e8 03 ff ff ff       	call   801a29 <_panic>
		sys_yield();
  801b26:	e8 fe ef ff ff       	call   800b29 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801b2b:	ff 75 14             	pushl  0x14(%ebp)
  801b2e:	53                   	push   %ebx
  801b2f:	56                   	push   %esi
  801b30:	57                   	push   %edi
  801b31:	e8 9f f1 ff ff       	call   800cd5 <sys_ipc_try_send>
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 d2                	js     801b0f <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5f                   	pop    %edi
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b50:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b53:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b59:	8b 52 50             	mov    0x50(%edx),%edx
  801b5c:	39 ca                	cmp    %ecx,%edx
  801b5e:	75 0d                	jne    801b6d <ipc_find_env+0x28>
			return envs[i].env_id;
  801b60:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b63:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b68:	8b 40 48             	mov    0x48(%eax),%eax
  801b6b:	eb 0f                	jmp    801b7c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6d:	83 c0 01             	add    $0x1,%eax
  801b70:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b75:	75 d9                	jne    801b50 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b84:	89 d0                	mov    %edx,%eax
  801b86:	c1 e8 16             	shr    $0x16,%eax
  801b89:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b95:	f6 c1 01             	test   $0x1,%cl
  801b98:	74 1d                	je     801bb7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b9a:	c1 ea 0c             	shr    $0xc,%edx
  801b9d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba4:	f6 c2 01             	test   $0x1,%dl
  801ba7:	74 0e                	je     801bb7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba9:	c1 ea 0c             	shr    $0xc,%edx
  801bac:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bb3:	ef 
  801bb4:	0f b7 c0             	movzwl %ax,%eax
}
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    
  801bb9:	66 90                	xchg   %ax,%ax
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
