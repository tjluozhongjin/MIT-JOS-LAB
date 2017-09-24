
obj/user/pingpong.debug:     file format elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
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
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 62 0e 00 00       	call   800ea3 <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 2b 0b 00 00       	call   800b7a <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 60 22 80 00       	push   $0x802260
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 b7 10 00 00       	call   801123 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 22 10 00 00       	call   8010a1 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 f1 0a 00 00       	call   800b7a <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 76 22 80 00       	push   $0x802276
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 75 10 00 00       	call   801123 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 ac 0a 00 00       	call   800b7a <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
		binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 6c 12 00 00       	call   80137b <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 20 0a 00 00       	call   800b39 <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 ae 09 00 00       	call   800afc <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 1a 01 00 00       	call   8002ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 53 09 00 00       	call   800afc <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 a7 1d 00 00       	call   801fc0 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 94 1e 00 00       	call   8020f0 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 93 22 80 00 	movsbl 0x802293(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	3b 50 04             	cmp    0x4(%eax),%edx
  800283:	73 0a                	jae    80028f <sprintputch+0x1b>
		*b->buf++ = ch;
  800285:	8d 4a 01             	lea    0x1(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	88 02                	mov    %al,(%edx)
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800297:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 10             	pushl  0x10(%ebp)
  80029e:	ff 75 0c             	pushl  0xc(%ebp)
  8002a1:	ff 75 08             	pushl  0x8(%ebp)
  8002a4:	e8 05 00 00 00       	call   8002ae <vprintfmt>
	va_end(ap);
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c0:	eb 12                	jmp    8002d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	0f 84 42 04 00 00    	je     80070c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	53                   	push   %ebx
  8002ce:	50                   	push   %eax
  8002cf:	ff d6                	call   *%esi
  8002d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d4:	83 c7 01             	add    $0x1,%edi
  8002d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002db:	83 f8 25             	cmp    $0x25,%eax
  8002de:	75 e2                	jne    8002c2 <vprintfmt+0x14>
  8002e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fe:	eb 07                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800303:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8d 47 01             	lea    0x1(%edi),%eax
  80030a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030d:	0f b6 07             	movzbl (%edi),%eax
  800310:	0f b6 d0             	movzbl %al,%edx
  800313:	83 e8 23             	sub    $0x23,%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 d3 03 00 00    	ja     8006f1 <vprintfmt+0x443>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	ff 24 85 e0 23 80 00 	jmp    *0x8023e0(,%eax,4)
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032f:	eb d6                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800334:	b8 00 00 00 00       	mov    $0x0,%eax
  800339:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800343:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800346:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800349:	83 f9 09             	cmp    $0x9,%ecx
  80034c:	77 3f                	ja     80038d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800351:	eb e9                	jmp    80033c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8b 00                	mov    (%eax),%eax
  800358:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 40 04             	lea    0x4(%eax),%eax
  800361:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800367:	eb 2a                	jmp    800393 <vprintfmt+0xe5>
  800369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036c:	85 c0                	test   %eax,%eax
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	0f 49 d0             	cmovns %eax,%edx
  800376:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037c:	eb 89                	jmp    800307 <vprintfmt+0x59>
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800381:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800388:	e9 7a ff ff ff       	jmp    800307 <vprintfmt+0x59>
  80038d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800397:	0f 89 6a ff ff ff    	jns    800307 <vprintfmt+0x59>
				width = precision, precision = -1;
  80039d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003aa:	e9 58 ff ff ff       	jmp    800307 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003af:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b5:	e9 4d ff ff ff       	jmp    800307 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 78 04             	lea    0x4(%eax),%edi
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	ff 30                	pushl  (%eax)
  8003c6:	ff d6                	call   *%esi
			break;
  8003c8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d1:	e9 fe fe ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 78 04             	lea    0x4(%eax),%edi
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	99                   	cltd   
  8003df:	31 d0                	xor    %edx,%eax
  8003e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e3:	83 f8 0f             	cmp    $0xf,%eax
  8003e6:	7f 0b                	jg     8003f3 <vprintfmt+0x145>
  8003e8:	8b 14 85 40 25 80 00 	mov    0x802540(,%eax,4),%edx
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	75 1b                	jne    80040e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003f3:	50                   	push   %eax
  8003f4:	68 ab 22 80 00       	push   $0x8022ab
  8003f9:	53                   	push   %ebx
  8003fa:	56                   	push   %esi
  8003fb:	e8 91 fe ff ff       	call   800291 <printfmt>
  800400:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800403:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800409:	e9 c6 fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80040e:	52                   	push   %edx
  80040f:	68 61 27 80 00       	push   $0x802761
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 76 fe ff ff       	call   800291 <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800424:	e9 ab fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	83 c0 04             	add    $0x4,%eax
  80042f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800437:	85 ff                	test   %edi,%edi
  800439:	b8 a4 22 80 00       	mov    $0x8022a4,%eax
  80043e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800441:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800445:	0f 8e 94 00 00 00    	jle    8004df <vprintfmt+0x231>
  80044b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044f:	0f 84 98 00 00 00    	je     8004ed <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 d0             	pushl  -0x30(%ebp)
  80045b:	57                   	push   %edi
  80045c:	e8 33 03 00 00       	call   800794 <strnlen>
  800461:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800464:	29 c1                	sub    %eax,%ecx
  800466:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800469:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800470:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800473:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800476:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	eb 0f                	jmp    800489 <vprintfmt+0x1db>
					putch(padc, putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	ff 75 e0             	pushl  -0x20(%ebp)
  800481:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ef 01             	sub    $0x1,%edi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 ff                	test   %edi,%edi
  80048b:	7f ed                	jg     80047a <vprintfmt+0x1cc>
  80048d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800490:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800493:	85 c9                	test   %ecx,%ecx
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	0f 49 c1             	cmovns %ecx,%eax
  80049d:	29 c1                	sub    %eax,%ecx
  80049f:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a8:	89 cb                	mov    %ecx,%ebx
  8004aa:	eb 4d                	jmp    8004f9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b0:	74 1b                	je     8004cd <vprintfmt+0x21f>
  8004b2:	0f be c0             	movsbl %al,%eax
  8004b5:	83 e8 20             	sub    $0x20,%eax
  8004b8:	83 f8 5e             	cmp    $0x5e,%eax
  8004bb:	76 10                	jbe    8004cd <vprintfmt+0x21f>
					putch('?', putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	6a 3f                	push   $0x3f
  8004c5:	ff 55 08             	call   *0x8(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb 0d                	jmp    8004da <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 0c             	pushl  0xc(%ebp)
  8004d3:	52                   	push   %edx
  8004d4:	ff 55 08             	call   *0x8(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	83 eb 01             	sub    $0x1,%ebx
  8004dd:	eb 1a                	jmp    8004f9 <vprintfmt+0x24b>
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004eb:	eb 0c                	jmp    8004f9 <vprintfmt+0x24b>
  8004ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f9:	83 c7 01             	add    $0x1,%edi
  8004fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800500:	0f be d0             	movsbl %al,%edx
  800503:	85 d2                	test   %edx,%edx
  800505:	74 23                	je     80052a <vprintfmt+0x27c>
  800507:	85 f6                	test   %esi,%esi
  800509:	78 a1                	js     8004ac <vprintfmt+0x1fe>
  80050b:	83 ee 01             	sub    $0x1,%esi
  80050e:	79 9c                	jns    8004ac <vprintfmt+0x1fe>
  800510:	89 df                	mov    %ebx,%edi
  800512:	8b 75 08             	mov    0x8(%ebp),%esi
  800515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800518:	eb 18                	jmp    800532 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	6a 20                	push   $0x20
  800520:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800522:	83 ef 01             	sub    $0x1,%edi
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	eb 08                	jmp    800532 <vprintfmt+0x284>
  80052a:	89 df                	mov    %ebx,%edi
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	85 ff                	test   %edi,%edi
  800534:	7f e4                	jg     80051a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800536:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053f:	e9 90 fd ff ff       	jmp    8002d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800544:	83 f9 01             	cmp    $0x1,%ecx
  800547:	7e 19                	jle    800562 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 50 04             	mov    0x4(%eax),%edx
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 40 08             	lea    0x8(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
  800560:	eb 38                	jmp    80059a <vprintfmt+0x2ec>
	else if (lflag)
  800562:	85 c9                	test   %ecx,%ecx
  800564:	74 1b                	je     800581 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056e:	89 c1                	mov    %eax,%ecx
  800570:	c1 f9 1f             	sar    $0x1f,%ecx
  800573:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 40 04             	lea    0x4(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
  80057f:	eb 19                	jmp    80059a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 c1                	mov    %eax,%ecx
  80058b:	c1 f9 1f             	sar    $0x1f,%ecx
  80058e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 40 04             	lea    0x4(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a9:	0f 89 0e 01 00 00    	jns    8006bd <vprintfmt+0x40f>
				putch('-', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 2d                	push   $0x2d
  8005b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bd:	f7 da                	neg    %edx
  8005bf:	83 d1 00             	adc    $0x0,%ecx
  8005c2:	f7 d9                	neg    %ecx
  8005c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 ec 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d1:	83 f9 01             	cmp    $0x1,%ecx
  8005d4:	7e 18                	jle    8005ee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	8b 48 04             	mov    0x4(%eax),%ecx
  8005de:	8d 40 08             	lea    0x8(%eax),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e9:	e9 cf 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	74 1a                	je     80060c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 10                	mov    (%eax),%edx
  8005f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	e9 b1 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800621:	e9 97 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 58                	push   $0x58
  80062c:	ff d6                	call   *%esi
			putch('X', putdat);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 58                	push   $0x58
  800634:	ff d6                	call   *%esi
			putch('X', putdat);
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	6a 58                	push   $0x58
  80063c:	ff d6                	call   *%esi
			break;
  80063e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800644:	e9 8b fc ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 30                	push   $0x30
  80064f:	ff d6                	call   *%esi
			putch('x', putdat);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 78                	push   $0x78
  800657:	ff d6                	call   *%esi
			num = (unsigned long long)
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800663:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800671:	eb 4a                	jmp    8006bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800673:	83 f9 01             	cmp    $0x1,%ecx
  800676:	7e 15                	jle    80068d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	8b 48 04             	mov    0x4(%eax),%ecx
  800680:	8d 40 08             	lea    0x8(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800686:	b8 10 00 00 00       	mov    $0x10,%eax
  80068b:	eb 30                	jmp    8006bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80068d:	85 c9                	test   %ecx,%ecx
  80068f:	74 17                	je     8006a8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 10                	mov    (%eax),%edx
  800696:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069b:	8d 40 04             	lea    0x4(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a6:	eb 15                	jmp    8006bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006b8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c4:	57                   	push   %edi
  8006c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c8:	50                   	push   %eax
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	89 da                	mov    %ebx,%edx
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	e8 f1 fa ff ff       	call   8001c5 <printnum>
			break;
  8006d4:	83 c4 20             	add    $0x20,%esp
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	e9 f5 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	52                   	push   %edx
  8006e4:	ff d6                	call   *%esi
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ec:	e9 e3 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 25                	push   $0x25
  8006f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb 03                	jmp    800701 <vprintfmt+0x453>
  8006fe:	83 ef 01             	sub    $0x1,%edi
  800701:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800705:	75 f7                	jne    8006fe <vprintfmt+0x450>
  800707:	e9 c8 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070f:	5b                   	pop    %ebx
  800710:	5e                   	pop    %esi
  800711:	5f                   	pop    %edi
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 18             	sub    $0x18,%esp
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800720:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800723:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800727:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 26                	je     80075b <vsnprintf+0x47>
  800735:	85 d2                	test   %edx,%edx
  800737:	7e 22                	jle    80075b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800739:	ff 75 14             	pushl  0x14(%ebp)
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800742:	50                   	push   %eax
  800743:	68 74 02 80 00       	push   $0x800274
  800748:	e8 61 fb ff ff       	call   8002ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800750:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 05                	jmp    800760 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076b:	50                   	push   %eax
  80076c:	ff 75 10             	pushl  0x10(%ebp)
  80076f:	ff 75 0c             	pushl  0xc(%ebp)
  800772:	ff 75 08             	pushl  0x8(%ebp)
  800775:	e8 9a ff ff ff       	call   800714 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	eb 03                	jmp    80078c <strlen+0x10>
		n++;
  800789:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800790:	75 f7                	jne    800789 <strlen+0xd>
		n++;
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a2:	eb 03                	jmp    8007a7 <strnlen+0x13>
		n++;
  8007a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	39 c2                	cmp    %eax,%edx
  8007a9:	74 08                	je     8007b3 <strnlen+0x1f>
  8007ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007af:	75 f3                	jne    8007a4 <strnlen+0x10>
  8007b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ce:	84 db                	test   %bl,%bl
  8007d0:	75 ef                	jne    8007c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dc:	53                   	push   %ebx
  8007dd:	e8 9a ff ff ff       	call   80077c <strlen>
  8007e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	50                   	push   %eax
  8007eb:	e8 c5 ff ff ff       	call   8007b5 <strcpy>
	return dst;
}
  8007f0:	89 d8                	mov    %ebx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 0f                	jmp    80081a <strncpy+0x23>
		*dst++ = *src;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	0f b6 01             	movzbl (%ecx),%eax
  800811:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800814:	80 39 01             	cmpb   $0x1,(%ecx)
  800817:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081a:	39 da                	cmp    %ebx,%edx
  80081c:	75 ed                	jne    80080b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	8b 55 10             	mov    0x10(%ebp),%edx
  800832:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 d2                	test   %edx,%edx
  800836:	74 21                	je     800859 <strlcpy+0x35>
  800838:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083c:	89 f2                	mov    %esi,%edx
  80083e:	eb 09                	jmp    800849 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800849:	39 c2                	cmp    %eax,%edx
  80084b:	74 09                	je     800856 <strlcpy+0x32>
  80084d:	0f b6 19             	movzbl (%ecx),%ebx
  800850:	84 db                	test   %bl,%bl
  800852:	75 ec                	jne    800840 <strlcpy+0x1c>
  800854:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800856:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800859:	29 f0                	sub    %esi,%eax
}
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800868:	eb 06                	jmp    800870 <strcmp+0x11>
		p++, q++;
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	84 c0                	test   %al,%al
  800875:	74 04                	je     80087b <strcmp+0x1c>
  800877:	3a 02                	cmp    (%edx),%al
  800879:	74 ef                	je     80086a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 c0             	movzbl %al,%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	89 c3                	mov    %eax,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800894:	eb 06                	jmp    80089c <strncmp+0x17>
		n--, p++, q++;
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089c:	39 d8                	cmp    %ebx,%eax
  80089e:	74 15                	je     8008b5 <strncmp+0x30>
  8008a0:	0f b6 08             	movzbl (%eax),%ecx
  8008a3:	84 c9                	test   %cl,%cl
  8008a5:	74 04                	je     8008ab <strncmp+0x26>
  8008a7:	3a 0a                	cmp    (%edx),%cl
  8008a9:	74 eb                	je     800896 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
  8008b3:	eb 05                	jmp    8008ba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c7:	eb 07                	jmp    8008d0 <strchr+0x13>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 0f                	je     8008dc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	0f b6 10             	movzbl (%eax),%edx
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f2                	jne    8008c9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e8:	eb 03                	jmp    8008ed <strfind+0xf>
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 04                	je     8008f8 <strfind+0x1a>
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	75 f2                	jne    8008ea <strfind+0xc>
			break;
	return (char *) s;
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 7d 08             	mov    0x8(%ebp),%edi
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800906:	85 c9                	test   %ecx,%ecx
  800908:	74 36                	je     800940 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800910:	75 28                	jne    80093a <memset+0x40>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 23                	jne    80093a <memset+0x40>
		c &= 0xFF;
  800917:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091b:	89 d3                	mov    %edx,%ebx
  80091d:	c1 e3 08             	shl    $0x8,%ebx
  800920:	89 d6                	mov    %edx,%esi
  800922:	c1 e6 18             	shl    $0x18,%esi
  800925:	89 d0                	mov    %edx,%eax
  800927:	c1 e0 10             	shl    $0x10,%eax
  80092a:	09 f0                	or     %esi,%eax
  80092c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	09 d0                	or     %edx,%eax
  800932:	c1 e9 02             	shr    $0x2,%ecx
  800935:	fc                   	cld    
  800936:	f3 ab                	rep stos %eax,%es:(%edi)
  800938:	eb 06                	jmp    800940 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	fc                   	cld    
  80093e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800940:	89 f8                	mov    %edi,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800955:	39 c6                	cmp    %eax,%esi
  800957:	73 35                	jae    80098e <memmove+0x47>
  800959:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095c:	39 d0                	cmp    %edx,%eax
  80095e:	73 2e                	jae    80098e <memmove+0x47>
		s += n;
		d += n;
  800960:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800963:	89 d6                	mov    %edx,%esi
  800965:	09 fe                	or     %edi,%esi
  800967:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096d:	75 13                	jne    800982 <memmove+0x3b>
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 0e                	jne    800982 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800974:	83 ef 04             	sub    $0x4,%edi
  800977:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097a:	c1 e9 02             	shr    $0x2,%ecx
  80097d:	fd                   	std    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 09                	jmp    80098b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800982:	83 ef 01             	sub    $0x1,%edi
  800985:	8d 72 ff             	lea    -0x1(%edx),%esi
  800988:	fd                   	std    
  800989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098b:	fc                   	cld    
  80098c:	eb 1d                	jmp    8009ab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	89 f2                	mov    %esi,%edx
  800990:	09 c2                	or     %eax,%edx
  800992:	f6 c2 03             	test   $0x3,%dl
  800995:	75 0f                	jne    8009a6 <memmove+0x5f>
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 0a                	jne    8009a6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099c:	c1 e9 02             	shr    $0x2,%ecx
  80099f:	89 c7                	mov    %eax,%edi
  8009a1:	fc                   	cld    
  8009a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a4:	eb 05                	jmp    8009ab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a6:	89 c7                	mov    %eax,%edi
  8009a8:	fc                   	cld    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b2:	ff 75 10             	pushl  0x10(%ebp)
  8009b5:	ff 75 0c             	pushl  0xc(%ebp)
  8009b8:	ff 75 08             	pushl  0x8(%ebp)
  8009bb:	e8 87 ff ff ff       	call   800947 <memmove>
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	89 c6                	mov    %eax,%esi
  8009cf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d2:	eb 1a                	jmp    8009ee <memcmp+0x2c>
		if (*s1 != *s2)
  8009d4:	0f b6 08             	movzbl (%eax),%ecx
  8009d7:	0f b6 1a             	movzbl (%edx),%ebx
  8009da:	38 d9                	cmp    %bl,%cl
  8009dc:	74 0a                	je     8009e8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009de:	0f b6 c1             	movzbl %cl,%eax
  8009e1:	0f b6 db             	movzbl %bl,%ebx
  8009e4:	29 d8                	sub    %ebx,%eax
  8009e6:	eb 0f                	jmp    8009f7 <memcmp+0x35>
		s1++, s2++;
  8009e8:	83 c0 01             	add    $0x1,%eax
  8009eb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ee:	39 f0                	cmp    %esi,%eax
  8009f0:	75 e2                	jne    8009d4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a02:	89 c1                	mov    %eax,%ecx
  800a04:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0b:	eb 0a                	jmp    800a17 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	39 da                	cmp    %ebx,%edx
  800a12:	74 07                	je     800a1b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	39 c8                	cmp    %ecx,%eax
  800a19:	72 f2                	jb     800a0d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2a:	eb 03                	jmp    800a2f <strtol+0x11>
		s++;
  800a2c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	0f b6 01             	movzbl (%ecx),%eax
  800a32:	3c 20                	cmp    $0x20,%al
  800a34:	74 f6                	je     800a2c <strtol+0xe>
  800a36:	3c 09                	cmp    $0x9,%al
  800a38:	74 f2                	je     800a2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3a:	3c 2b                	cmp    $0x2b,%al
  800a3c:	75 0a                	jne    800a48 <strtol+0x2a>
		s++;
  800a3e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a41:	bf 00 00 00 00       	mov    $0x0,%edi
  800a46:	eb 11                	jmp    800a59 <strtol+0x3b>
  800a48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4d:	3c 2d                	cmp    $0x2d,%al
  800a4f:	75 08                	jne    800a59 <strtol+0x3b>
		s++, neg = 1;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5f:	75 15                	jne    800a76 <strtol+0x58>
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	75 10                	jne    800a76 <strtol+0x58>
  800a66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6a:	75 7c                	jne    800ae8 <strtol+0xca>
		s += 2, base = 16;
  800a6c:	83 c1 02             	add    $0x2,%ecx
  800a6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a74:	eb 16                	jmp    800a8c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	75 12                	jne    800a8c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	75 08                	jne    800a8c <strtol+0x6e>
		s++, base = 8;
  800a84:	83 c1 01             	add    $0x1,%ecx
  800a87:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a94:	0f b6 11             	movzbl (%ecx),%edx
  800a97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 09             	cmp    $0x9,%bl
  800a9f:	77 08                	ja     800aa9 <strtol+0x8b>
			dig = *s - '0';
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 30             	sub    $0x30,%edx
  800aa7:	eb 22                	jmp    800acb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 08                	ja     800abb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab3:	0f be d2             	movsbl %dl,%edx
  800ab6:	83 ea 57             	sub    $0x57,%edx
  800ab9:	eb 10                	jmp    800acb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abe:	89 f3                	mov    %esi,%ebx
  800ac0:	80 fb 19             	cmp    $0x19,%bl
  800ac3:	77 16                	ja     800adb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac5:	0f be d2             	movsbl %dl,%edx
  800ac8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ace:	7d 0b                	jge    800adb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad0:	83 c1 01             	add    $0x1,%ecx
  800ad3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad9:	eb b9                	jmp    800a94 <strtol+0x76>

	if (endptr)
  800adb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800adf:	74 0d                	je     800aee <strtol+0xd0>
		*endptr = (char *) s;
  800ae1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae4:	89 0e                	mov    %ecx,(%esi)
  800ae6:	eb 06                	jmp    800aee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae8:	85 db                	test   %ebx,%ebx
  800aea:	74 98                	je     800a84 <strtol+0x66>
  800aec:	eb 9e                	jmp    800a8c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aee:	89 c2                	mov    %eax,%edx
  800af0:	f7 da                	neg    %edx
  800af2:	85 ff                	test   %edi,%edi
  800af4:	0f 45 c2             	cmovne %edx,%eax
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
  800b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	89 c7                	mov    %eax,%edi
  800b11:	89 c6                	mov    %eax,%esi
  800b13:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_cgetc>:

int
sys_cgetc(void)
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
  800b25:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b47:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	89 cb                	mov    %ecx,%ebx
  800b51:	89 cf                	mov    %ecx,%edi
  800b53:	89 ce                	mov    %ecx,%esi
  800b55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b57:	85 c0                	test   %eax,%eax
  800b59:	7e 17                	jle    800b72 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	50                   	push   %eax
  800b5f:	6a 03                	push   $0x3
  800b61:	68 9f 25 80 00       	push   $0x80259f
  800b66:	6a 23                	push   $0x23
  800b68:	68 bc 25 80 00       	push   $0x8025bc
  800b6d:	e8 2e 13 00 00       	call   801ea0 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_yield>:

void
sys_yield(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba9:	89 d1                	mov    %edx,%ecx
  800bab:	89 d3                	mov    %edx,%ebx
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	be 00 00 00 00       	mov    $0x0,%esi
  800bc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	89 f7                	mov    %esi,%edi
  800bd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 04                	push   $0x4
  800be2:	68 9f 25 80 00       	push   $0x80259f
  800be7:	6a 23                	push   $0x23
  800be9:	68 bc 25 80 00       	push   $0x8025bc
  800bee:	e8 ad 12 00 00       	call   801ea0 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	b8 05 00 00 00       	mov    $0x5,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c15:	8b 75 18             	mov    0x18(%ebp),%esi
  800c18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 05                	push   $0x5
  800c24:	68 9f 25 80 00       	push   $0x80259f
  800c29:	6a 23                	push   $0x23
  800c2b:	68 bc 25 80 00       	push   $0x8025bc
  800c30:	e8 6b 12 00 00       	call   801ea0 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 06                	push   $0x6
  800c66:	68 9f 25 80 00       	push   $0x80259f
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 bc 25 80 00       	push   $0x8025bc
  800c72:	e8 29 12 00 00       	call   801ea0 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 08                	push   $0x8
  800ca8:	68 9f 25 80 00       	push   $0x80259f
  800cad:	6a 23                	push   $0x23
  800caf:	68 bc 25 80 00       	push   $0x8025bc
  800cb4:	e8 e7 11 00 00       	call   801ea0 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 09                	push   $0x9
  800cea:	68 9f 25 80 00       	push   $0x80259f
  800cef:	6a 23                	push   $0x23
  800cf1:	68 bc 25 80 00       	push   $0x8025bc
  800cf6:	e8 a5 11 00 00       	call   801ea0 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 17                	jle    800d3d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	6a 0a                	push   $0xa
  800d2c:	68 9f 25 80 00       	push   $0x80259f
  800d31:	6a 23                	push   $0x23
  800d33:	68 bc 25 80 00       	push   $0x8025bc
  800d38:	e8 63 11 00 00       	call   801ea0 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	be 00 00 00 00       	mov    $0x0,%esi
  800d50:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d61:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d76:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 cb                	mov    %ecx,%ebx
  800d80:	89 cf                	mov    %ecx,%edi
  800d82:	89 ce                	mov    %ecx,%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 0d                	push   $0xd
  800d90:	68 9f 25 80 00       	push   $0x80259f
  800d95:	6a 23                	push   $0x23
  800d97:	68 bc 25 80 00       	push   $0x8025bc
  800d9c:	e8 ff 10 00 00       	call   801ea0 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800db1:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800db3:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800db7:	74 11                	je     800dca <pgfault+0x21>
  800db9:	89 d8                	mov    %ebx,%eax
  800dbb:	c1 e8 0c             	shr    $0xc,%eax
  800dbe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dc5:	f6 c4 08             	test   $0x8,%ah
  800dc8:	75 14                	jne    800dde <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	68 cc 25 80 00       	push   $0x8025cc
  800dd2:	6a 1f                	push   $0x1f
  800dd4:	68 2f 26 80 00       	push   $0x80262f
  800dd9:	e8 c2 10 00 00       	call   801ea0 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800dde:	e8 97 fd ff ff       	call   800b7a <sys_getenvid>
  800de3:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800de5:	83 ec 04             	sub    $0x4,%esp
  800de8:	6a 07                	push   $0x7
  800dea:	68 00 f0 7f 00       	push   $0x7ff000
  800def:	50                   	push   %eax
  800df0:	e8 c3 fd ff ff       	call   800bb8 <sys_page_alloc>
  800df5:	83 c4 10             	add    $0x10,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	79 12                	jns    800e0e <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800dfc:	50                   	push   %eax
  800dfd:	68 0c 26 80 00       	push   $0x80260c
  800e02:	6a 2c                	push   $0x2c
  800e04:	68 2f 26 80 00       	push   $0x80262f
  800e09:	e8 92 10 00 00       	call   801ea0 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800e0e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800e14:	83 ec 04             	sub    $0x4,%esp
  800e17:	68 00 10 00 00       	push   $0x1000
  800e1c:	53                   	push   %ebx
  800e1d:	68 00 f0 7f 00       	push   $0x7ff000
  800e22:	e8 20 fb ff ff       	call   800947 <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800e27:	83 c4 08             	add    $0x8,%esp
  800e2a:	53                   	push   %ebx
  800e2b:	56                   	push   %esi
  800e2c:	e8 0c fe ff ff       	call   800c3d <sys_page_unmap>
  800e31:	83 c4 10             	add    $0x10,%esp
  800e34:	85 c0                	test   %eax,%eax
  800e36:	79 12                	jns    800e4a <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800e38:	50                   	push   %eax
  800e39:	68 3a 26 80 00       	push   $0x80263a
  800e3e:	6a 32                	push   $0x32
  800e40:	68 2f 26 80 00       	push   $0x80262f
  800e45:	e8 56 10 00 00       	call   801ea0 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e4a:	83 ec 0c             	sub    $0xc,%esp
  800e4d:	6a 07                	push   $0x7
  800e4f:	53                   	push   %ebx
  800e50:	56                   	push   %esi
  800e51:	68 00 f0 7f 00       	push   $0x7ff000
  800e56:	56                   	push   %esi
  800e57:	e8 9f fd ff ff       	call   800bfb <sys_page_map>
  800e5c:	83 c4 20             	add    $0x20,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	79 12                	jns    800e75 <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800e63:	50                   	push   %eax
  800e64:	68 58 26 80 00       	push   $0x802658
  800e69:	6a 35                	push   $0x35
  800e6b:	68 2f 26 80 00       	push   $0x80262f
  800e70:	e8 2b 10 00 00       	call   801ea0 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e75:	83 ec 08             	sub    $0x8,%esp
  800e78:	68 00 f0 7f 00       	push   $0x7ff000
  800e7d:	56                   	push   %esi
  800e7e:	e8 ba fd ff ff       	call   800c3d <sys_page_unmap>
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	85 c0                	test   %eax,%eax
  800e88:	79 12                	jns    800e9c <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800e8a:	50                   	push   %eax
  800e8b:	68 3a 26 80 00       	push   $0x80263a
  800e90:	6a 38                	push   $0x38
  800e92:	68 2f 26 80 00       	push   $0x80262f
  800e97:	e8 04 10 00 00       	call   801ea0 <_panic>
	//panic("pgfault not implemented");
}
  800e9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	57                   	push   %edi
  800ea7:	56                   	push   %esi
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800eac:	68 a9 0d 80 00       	push   $0x800da9
  800eb1:	e8 30 10 00 00       	call   801ee6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb6:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebb:	cd 30                	int    $0x30
  800ebd:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	0f 88 38 01 00 00    	js     801003 <fork+0x160>
  800ecb:	89 c7                	mov    %eax,%edi
  800ecd:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	75 21                	jne    800ef7 <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800ed6:	e8 9f fc ff ff       	call   800b7a <sys_getenvid>
  800edb:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ee0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ee3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ee8:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800eed:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef2:	e9 86 01 00 00       	jmp    80107d <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800ef7:	89 d8                	mov    %ebx,%eax
  800ef9:	c1 e8 16             	shr    $0x16,%eax
  800efc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f03:	a8 01                	test   $0x1,%al
  800f05:	0f 84 90 00 00 00    	je     800f9b <fork+0xf8>
  800f0b:	89 d8                	mov    %ebx,%eax
  800f0d:	c1 e8 0c             	shr    $0xc,%eax
  800f10:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f17:	f6 c2 01             	test   $0x1,%dl
  800f1a:	74 7f                	je     800f9b <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  800f1c:	89 c6                	mov    %eax,%esi
  800f1e:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  800f21:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f28:	f6 c6 04             	test   $0x4,%dh
  800f2b:	74 33                	je     800f60 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  800f2d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f34:	83 ec 0c             	sub    $0xc,%esp
  800f37:	25 07 0e 00 00       	and    $0xe07,%eax
  800f3c:	50                   	push   %eax
  800f3d:	56                   	push   %esi
  800f3e:	57                   	push   %edi
  800f3f:	56                   	push   %esi
  800f40:	6a 00                	push   $0x0
  800f42:	e8 b4 fc ff ff       	call   800bfb <sys_page_map>
  800f47:	83 c4 20             	add    $0x20,%esp
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	79 4d                	jns    800f9b <fork+0xf8>
		    panic("sys_page_map: %e", r);
  800f4e:	50                   	push   %eax
  800f4f:	68 74 26 80 00       	push   $0x802674
  800f54:	6a 54                	push   $0x54
  800f56:	68 2f 26 80 00       	push   $0x80262f
  800f5b:	e8 40 0f 00 00       	call   801ea0 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800f60:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f67:	a9 02 08 00 00       	test   $0x802,%eax
  800f6c:	0f 85 c6 00 00 00    	jne    801038 <fork+0x195>
  800f72:	e9 e3 00 00 00       	jmp    80105a <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800f77:	50                   	push   %eax
  800f78:	68 74 26 80 00       	push   $0x802674
  800f7d:	6a 5d                	push   $0x5d
  800f7f:	68 2f 26 80 00       	push   $0x80262f
  800f84:	e8 17 0f 00 00       	call   801ea0 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800f89:	50                   	push   %eax
  800f8a:	68 74 26 80 00       	push   $0x802674
  800f8f:	6a 64                	push   $0x64
  800f91:	68 2f 26 80 00       	push   $0x80262f
  800f96:	e8 05 0f 00 00       	call   801ea0 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  800f9b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fa1:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800fa7:	0f 85 4a ff ff ff    	jne    800ef7 <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	6a 07                	push   $0x7
  800fb2:	68 00 f0 bf ee       	push   $0xeebff000
  800fb7:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fba:	57                   	push   %edi
  800fbb:	e8 f8 fb ff ff       	call   800bb8 <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800fc0:	83 c4 10             	add    $0x10,%esp
		return ret;
  800fc3:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	0f 88 b0 00 00 00    	js     80107d <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800fcd:	a1 04 40 80 00       	mov    0x804004,%eax
  800fd2:	8b 40 64             	mov    0x64(%eax),%eax
  800fd5:	83 ec 08             	sub    $0x8,%esp
  800fd8:	50                   	push   %eax
  800fd9:	57                   	push   %edi
  800fda:	e8 24 fd ff ff       	call   800d03 <sys_env_set_pgfault_upcall>
  800fdf:	83 c4 10             	add    $0x10,%esp
		return ret;
  800fe2:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	0f 88 91 00 00 00    	js     80107d <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	6a 02                	push   $0x2
  800ff1:	57                   	push   %edi
  800ff2:	e8 88 fc ff ff       	call   800c7f <sys_env_set_status>
  800ff7:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	89 fa                	mov    %edi,%edx
  800ffe:	0f 48 d0             	cmovs  %eax,%edx
  801001:	eb 7a                	jmp    80107d <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  801003:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801006:	eb 75                	jmp    80107d <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  801008:	e8 6d fb ff ff       	call   800b7a <sys_getenvid>
  80100d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801010:	e8 65 fb ff ff       	call   800b7a <sys_getenvid>
  801015:	83 ec 0c             	sub    $0xc,%esp
  801018:	68 05 08 00 00       	push   $0x805
  80101d:	56                   	push   %esi
  80101e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801021:	56                   	push   %esi
  801022:	50                   	push   %eax
  801023:	e8 d3 fb ff ff       	call   800bfb <sys_page_map>
  801028:	83 c4 20             	add    $0x20,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	0f 89 68 ff ff ff    	jns    800f9b <fork+0xf8>
  801033:	e9 51 ff ff ff       	jmp    800f89 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  801038:	e8 3d fb ff ff       	call   800b7a <sys_getenvid>
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	68 05 08 00 00       	push   $0x805
  801045:	56                   	push   %esi
  801046:	57                   	push   %edi
  801047:	56                   	push   %esi
  801048:	50                   	push   %eax
  801049:	e8 ad fb ff ff       	call   800bfb <sys_page_map>
  80104e:	83 c4 20             	add    $0x20,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	79 b3                	jns    801008 <fork+0x165>
  801055:	e9 1d ff ff ff       	jmp    800f77 <fork+0xd4>
  80105a:	e8 1b fb ff ff       	call   800b7a <sys_getenvid>
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	6a 05                	push   $0x5
  801064:	56                   	push   %esi
  801065:	57                   	push   %edi
  801066:	56                   	push   %esi
  801067:	50                   	push   %eax
  801068:	e8 8e fb ff ff       	call   800bfb <sys_page_map>
  80106d:	83 c4 20             	add    $0x20,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	0f 89 23 ff ff ff    	jns    800f9b <fork+0xf8>
  801078:	e9 fa fe ff ff       	jmp    800f77 <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  80107d:	89 d0                	mov    %edx,%eax
  80107f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <sfork>:

// Challenge!
int
sfork(void)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80108d:	68 85 26 80 00       	push   $0x802685
  801092:	68 ac 00 00 00       	push   $0xac
  801097:	68 2f 26 80 00       	push   $0x80262f
  80109c:	e8 ff 0d 00 00       	call   801ea0 <_panic>

008010a1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	57                   	push   %edi
  8010a5:	56                   	push   %esi
  8010a6:	53                   	push   %ebx
  8010a7:	83 ec 0c             	sub    $0xc,%esp
  8010aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8010ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  8010b3:	85 f6                	test   %esi,%esi
  8010b5:	74 06                	je     8010bd <ipc_recv+0x1c>
		*from_env_store = 0;
  8010b7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  8010bd:	85 db                	test   %ebx,%ebx
  8010bf:	74 06                	je     8010c7 <ipc_recv+0x26>
		*perm_store = 0;
  8010c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  8010c7:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  8010c9:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  8010ce:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  8010d1:	83 ec 0c             	sub    $0xc,%esp
  8010d4:	50                   	push   %eax
  8010d5:	e8 8e fc ff ff       	call   800d68 <sys_ipc_recv>
  8010da:	89 c7                	mov    %eax,%edi
  8010dc:	83 c4 10             	add    $0x10,%esp
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	79 14                	jns    8010f7 <ipc_recv+0x56>
		cprintf("im dead");
  8010e3:	83 ec 0c             	sub    $0xc,%esp
  8010e6:	68 9b 26 80 00       	push   $0x80269b
  8010eb:	e8 c1 f0 ff ff       	call   8001b1 <cprintf>
		return r;
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	89 f8                	mov    %edi,%eax
  8010f5:	eb 24                	jmp    80111b <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  8010f7:	85 f6                	test   %esi,%esi
  8010f9:	74 0a                	je     801105 <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  8010fb:	a1 04 40 80 00       	mov    0x804004,%eax
  801100:	8b 40 74             	mov    0x74(%eax),%eax
  801103:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801105:	85 db                	test   %ebx,%ebx
  801107:	74 0a                	je     801113 <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801109:	a1 04 40 80 00       	mov    0x804004,%eax
  80110e:	8b 40 78             	mov    0x78(%eax),%eax
  801111:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801113:	a1 04 40 80 00       	mov    0x804004,%eax
  801118:	8b 40 70             	mov    0x70(%eax),%eax
}
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    

00801123 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	57                   	push   %edi
  801127:	56                   	push   %esi
  801128:	53                   	push   %ebx
  801129:	83 ec 0c             	sub    $0xc,%esp
  80112c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80112f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801132:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801135:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801137:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80113c:	0f 44 d8             	cmove  %eax,%ebx
  80113f:	eb 1c                	jmp    80115d <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801141:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801144:	74 12                	je     801158 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801146:	50                   	push   %eax
  801147:	68 a3 26 80 00       	push   $0x8026a3
  80114c:	6a 4e                	push   $0x4e
  80114e:	68 b0 26 80 00       	push   $0x8026b0
  801153:	e8 48 0d 00 00       	call   801ea0 <_panic>
		sys_yield();
  801158:	e8 3c fa ff ff       	call   800b99 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  80115d:	ff 75 14             	pushl  0x14(%ebp)
  801160:	53                   	push   %ebx
  801161:	56                   	push   %esi
  801162:	57                   	push   %edi
  801163:	e8 dd fb ff ff       	call   800d45 <sys_ipc_try_send>
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 d2                	js     801141 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  80116f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801172:	5b                   	pop    %ebx
  801173:	5e                   	pop    %esi
  801174:	5f                   	pop    %edi
  801175:	5d                   	pop    %ebp
  801176:	c3                   	ret    

00801177 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801177:	55                   	push   %ebp
  801178:	89 e5                	mov    %esp,%ebp
  80117a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80117d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801182:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801185:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80118b:	8b 52 50             	mov    0x50(%edx),%edx
  80118e:	39 ca                	cmp    %ecx,%edx
  801190:	75 0d                	jne    80119f <ipc_find_env+0x28>
			return envs[i].env_id;
  801192:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801195:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80119a:	8b 40 48             	mov    0x48(%eax),%eax
  80119d:	eb 0f                	jmp    8011ae <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80119f:	83 c0 01             	add    $0x1,%eax
  8011a2:	3d 00 04 00 00       	cmp    $0x400,%eax
  8011a7:	75 d9                	jne    801182 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011ae:	5d                   	pop    %ebp
  8011af:	c3                   	ret    

008011b0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8011c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8011cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d5:	5d                   	pop    %ebp
  8011d6:	c3                   	ret    

008011d7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011d7:	55                   	push   %ebp
  8011d8:	89 e5                	mov    %esp,%ebp
  8011da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011dd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e2:	89 c2                	mov    %eax,%edx
  8011e4:	c1 ea 16             	shr    $0x16,%edx
  8011e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ee:	f6 c2 01             	test   $0x1,%dl
  8011f1:	74 11                	je     801204 <fd_alloc+0x2d>
  8011f3:	89 c2                	mov    %eax,%edx
  8011f5:	c1 ea 0c             	shr    $0xc,%edx
  8011f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011ff:	f6 c2 01             	test   $0x1,%dl
  801202:	75 09                	jne    80120d <fd_alloc+0x36>
			*fd_store = fd;
  801204:	89 01                	mov    %eax,(%ecx)
			return 0;
  801206:	b8 00 00 00 00       	mov    $0x0,%eax
  80120b:	eb 17                	jmp    801224 <fd_alloc+0x4d>
  80120d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801212:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801217:	75 c9                	jne    8011e2 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801219:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80121f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801224:	5d                   	pop    %ebp
  801225:	c3                   	ret    

00801226 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80122c:	83 f8 1f             	cmp    $0x1f,%eax
  80122f:	77 36                	ja     801267 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801231:	c1 e0 0c             	shl    $0xc,%eax
  801234:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801239:	89 c2                	mov    %eax,%edx
  80123b:	c1 ea 16             	shr    $0x16,%edx
  80123e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801245:	f6 c2 01             	test   $0x1,%dl
  801248:	74 24                	je     80126e <fd_lookup+0x48>
  80124a:	89 c2                	mov    %eax,%edx
  80124c:	c1 ea 0c             	shr    $0xc,%edx
  80124f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801256:	f6 c2 01             	test   $0x1,%dl
  801259:	74 1a                	je     801275 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80125b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125e:	89 02                	mov    %eax,(%edx)
	return 0;
  801260:	b8 00 00 00 00       	mov    $0x0,%eax
  801265:	eb 13                	jmp    80127a <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801267:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126c:	eb 0c                	jmp    80127a <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80126e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801273:	eb 05                	jmp    80127a <fd_lookup+0x54>
  801275:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80127a:	5d                   	pop    %ebp
  80127b:	c3                   	ret    

0080127c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801285:	ba 38 27 80 00       	mov    $0x802738,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80128a:	eb 13                	jmp    80129f <dev_lookup+0x23>
  80128c:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80128f:	39 08                	cmp    %ecx,(%eax)
  801291:	75 0c                	jne    80129f <dev_lookup+0x23>
			*dev = devtab[i];
  801293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801296:	89 01                	mov    %eax,(%ecx)
			return 0;
  801298:	b8 00 00 00 00       	mov    $0x0,%eax
  80129d:	eb 2e                	jmp    8012cd <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80129f:	8b 02                	mov    (%edx),%eax
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	75 e7                	jne    80128c <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8012a5:	a1 04 40 80 00       	mov    0x804004,%eax
  8012aa:	8b 40 48             	mov    0x48(%eax),%eax
  8012ad:	83 ec 04             	sub    $0x4,%esp
  8012b0:	51                   	push   %ecx
  8012b1:	50                   	push   %eax
  8012b2:	68 bc 26 80 00       	push   $0x8026bc
  8012b7:	e8 f5 ee ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  8012bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012cd:	c9                   	leave  
  8012ce:	c3                   	ret    

008012cf <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8012cf:	55                   	push   %ebp
  8012d0:	89 e5                	mov    %esp,%ebp
  8012d2:	56                   	push   %esi
  8012d3:	53                   	push   %ebx
  8012d4:	83 ec 10             	sub    $0x10,%esp
  8012d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8012da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e7:	c1 e8 0c             	shr    $0xc,%eax
  8012ea:	50                   	push   %eax
  8012eb:	e8 36 ff ff ff       	call   801226 <fd_lookup>
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 05                	js     8012fc <fd_close+0x2d>
	    || fd != fd2)
  8012f7:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012fa:	74 0c                	je     801308 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012fc:	84 db                	test   %bl,%bl
  8012fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801303:	0f 44 c2             	cmove  %edx,%eax
  801306:	eb 41                	jmp    801349 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801308:	83 ec 08             	sub    $0x8,%esp
  80130b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130e:	50                   	push   %eax
  80130f:	ff 36                	pushl  (%esi)
  801311:	e8 66 ff ff ff       	call   80127c <dev_lookup>
  801316:	89 c3                	mov    %eax,%ebx
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 1a                	js     801339 <fd_close+0x6a>
		if (dev->dev_close)
  80131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801322:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801325:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80132a:	85 c0                	test   %eax,%eax
  80132c:	74 0b                	je     801339 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80132e:	83 ec 0c             	sub    $0xc,%esp
  801331:	56                   	push   %esi
  801332:	ff d0                	call   *%eax
  801334:	89 c3                	mov    %eax,%ebx
  801336:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	56                   	push   %esi
  80133d:	6a 00                	push   $0x0
  80133f:	e8 f9 f8 ff ff       	call   800c3d <sys_page_unmap>
	return r;
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	89 d8                	mov    %ebx,%eax
}
  801349:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134c:	5b                   	pop    %ebx
  80134d:	5e                   	pop    %esi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    

00801350 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801350:	55                   	push   %ebp
  801351:	89 e5                	mov    %esp,%ebp
  801353:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801356:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801359:	50                   	push   %eax
  80135a:	ff 75 08             	pushl  0x8(%ebp)
  80135d:	e8 c4 fe ff ff       	call   801226 <fd_lookup>
  801362:	83 c4 08             	add    $0x8,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	78 10                	js     801379 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	6a 01                	push   $0x1
  80136e:	ff 75 f4             	pushl  -0xc(%ebp)
  801371:	e8 59 ff ff ff       	call   8012cf <fd_close>
  801376:	83 c4 10             	add    $0x10,%esp
}
  801379:	c9                   	leave  
  80137a:	c3                   	ret    

0080137b <close_all>:

void
close_all(void)
{
  80137b:	55                   	push   %ebp
  80137c:	89 e5                	mov    %esp,%ebp
  80137e:	53                   	push   %ebx
  80137f:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801382:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801387:	83 ec 0c             	sub    $0xc,%esp
  80138a:	53                   	push   %ebx
  80138b:	e8 c0 ff ff ff       	call   801350 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801390:	83 c3 01             	add    $0x1,%ebx
  801393:	83 c4 10             	add    $0x10,%esp
  801396:	83 fb 20             	cmp    $0x20,%ebx
  801399:	75 ec                	jne    801387 <close_all+0xc>
		close(i);
}
  80139b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139e:	c9                   	leave  
  80139f:	c3                   	ret    

008013a0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	57                   	push   %edi
  8013a4:	56                   	push   %esi
  8013a5:	53                   	push   %ebx
  8013a6:	83 ec 2c             	sub    $0x2c,%esp
  8013a9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013af:	50                   	push   %eax
  8013b0:	ff 75 08             	pushl  0x8(%ebp)
  8013b3:	e8 6e fe ff ff       	call   801226 <fd_lookup>
  8013b8:	83 c4 08             	add    $0x8,%esp
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	0f 88 c1 00 00 00    	js     801484 <dup+0xe4>
		return r;
	close(newfdnum);
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	56                   	push   %esi
  8013c7:	e8 84 ff ff ff       	call   801350 <close>

	newfd = INDEX2FD(newfdnum);
  8013cc:	89 f3                	mov    %esi,%ebx
  8013ce:	c1 e3 0c             	shl    $0xc,%ebx
  8013d1:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013d7:	83 c4 04             	add    $0x4,%esp
  8013da:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013dd:	e8 de fd ff ff       	call   8011c0 <fd2data>
  8013e2:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013e4:	89 1c 24             	mov    %ebx,(%esp)
  8013e7:	e8 d4 fd ff ff       	call   8011c0 <fd2data>
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f2:	89 f8                	mov    %edi,%eax
  8013f4:	c1 e8 16             	shr    $0x16,%eax
  8013f7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013fe:	a8 01                	test   $0x1,%al
  801400:	74 37                	je     801439 <dup+0x99>
  801402:	89 f8                	mov    %edi,%eax
  801404:	c1 e8 0c             	shr    $0xc,%eax
  801407:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80140e:	f6 c2 01             	test   $0x1,%dl
  801411:	74 26                	je     801439 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801413:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	25 07 0e 00 00       	and    $0xe07,%eax
  801422:	50                   	push   %eax
  801423:	ff 75 d4             	pushl  -0x2c(%ebp)
  801426:	6a 00                	push   $0x0
  801428:	57                   	push   %edi
  801429:	6a 00                	push   $0x0
  80142b:	e8 cb f7 ff ff       	call   800bfb <sys_page_map>
  801430:	89 c7                	mov    %eax,%edi
  801432:	83 c4 20             	add    $0x20,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 2e                	js     801467 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801439:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80143c:	89 d0                	mov    %edx,%eax
  80143e:	c1 e8 0c             	shr    $0xc,%eax
  801441:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801448:	83 ec 0c             	sub    $0xc,%esp
  80144b:	25 07 0e 00 00       	and    $0xe07,%eax
  801450:	50                   	push   %eax
  801451:	53                   	push   %ebx
  801452:	6a 00                	push   $0x0
  801454:	52                   	push   %edx
  801455:	6a 00                	push   $0x0
  801457:	e8 9f f7 ff ff       	call   800bfb <sys_page_map>
  80145c:	89 c7                	mov    %eax,%edi
  80145e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801461:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801463:	85 ff                	test   %edi,%edi
  801465:	79 1d                	jns    801484 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	53                   	push   %ebx
  80146b:	6a 00                	push   $0x0
  80146d:	e8 cb f7 ff ff       	call   800c3d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801472:	83 c4 08             	add    $0x8,%esp
  801475:	ff 75 d4             	pushl  -0x2c(%ebp)
  801478:	6a 00                	push   $0x0
  80147a:	e8 be f7 ff ff       	call   800c3d <sys_page_unmap>
	return r;
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	89 f8                	mov    %edi,%eax
}
  801484:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801487:	5b                   	pop    %ebx
  801488:	5e                   	pop    %esi
  801489:	5f                   	pop    %edi
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    

0080148c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	53                   	push   %ebx
  801490:	83 ec 14             	sub    $0x14,%esp
  801493:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801496:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801499:	50                   	push   %eax
  80149a:	53                   	push   %ebx
  80149b:	e8 86 fd ff ff       	call   801226 <fd_lookup>
  8014a0:	83 c4 08             	add    $0x8,%esp
  8014a3:	89 c2                	mov    %eax,%edx
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	78 6d                	js     801516 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a9:	83 ec 08             	sub    $0x8,%esp
  8014ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b3:	ff 30                	pushl  (%eax)
  8014b5:	e8 c2 fd ff ff       	call   80127c <dev_lookup>
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 4c                	js     80150d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c4:	8b 42 08             	mov    0x8(%edx),%eax
  8014c7:	83 e0 03             	and    $0x3,%eax
  8014ca:	83 f8 01             	cmp    $0x1,%eax
  8014cd:	75 21                	jne    8014f0 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014cf:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d4:	8b 40 48             	mov    0x48(%eax),%eax
  8014d7:	83 ec 04             	sub    $0x4,%esp
  8014da:	53                   	push   %ebx
  8014db:	50                   	push   %eax
  8014dc:	68 fd 26 80 00       	push   $0x8026fd
  8014e1:	e8 cb ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8014e6:	83 c4 10             	add    $0x10,%esp
  8014e9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ee:	eb 26                	jmp    801516 <read+0x8a>
	}
	if (!dev->dev_read)
  8014f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f3:	8b 40 08             	mov    0x8(%eax),%eax
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	74 17                	je     801511 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014fa:	83 ec 04             	sub    $0x4,%esp
  8014fd:	ff 75 10             	pushl  0x10(%ebp)
  801500:	ff 75 0c             	pushl  0xc(%ebp)
  801503:	52                   	push   %edx
  801504:	ff d0                	call   *%eax
  801506:	89 c2                	mov    %eax,%edx
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	eb 09                	jmp    801516 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150d:	89 c2                	mov    %eax,%edx
  80150f:	eb 05                	jmp    801516 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801511:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801516:	89 d0                	mov    %edx,%eax
  801518:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151b:	c9                   	leave  
  80151c:	c3                   	ret    

0080151d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	57                   	push   %edi
  801521:	56                   	push   %esi
  801522:	53                   	push   %ebx
  801523:	83 ec 0c             	sub    $0xc,%esp
  801526:	8b 7d 08             	mov    0x8(%ebp),%edi
  801529:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80152c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801531:	eb 21                	jmp    801554 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801533:	83 ec 04             	sub    $0x4,%esp
  801536:	89 f0                	mov    %esi,%eax
  801538:	29 d8                	sub    %ebx,%eax
  80153a:	50                   	push   %eax
  80153b:	89 d8                	mov    %ebx,%eax
  80153d:	03 45 0c             	add    0xc(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	57                   	push   %edi
  801542:	e8 45 ff ff ff       	call   80148c <read>
		if (m < 0)
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	85 c0                	test   %eax,%eax
  80154c:	78 10                	js     80155e <readn+0x41>
			return m;
		if (m == 0)
  80154e:	85 c0                	test   %eax,%eax
  801550:	74 0a                	je     80155c <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801552:	01 c3                	add    %eax,%ebx
  801554:	39 f3                	cmp    %esi,%ebx
  801556:	72 db                	jb     801533 <readn+0x16>
  801558:	89 d8                	mov    %ebx,%eax
  80155a:	eb 02                	jmp    80155e <readn+0x41>
  80155c:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80155e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801561:	5b                   	pop    %ebx
  801562:	5e                   	pop    %esi
  801563:	5f                   	pop    %edi
  801564:	5d                   	pop    %ebp
  801565:	c3                   	ret    

00801566 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801566:	55                   	push   %ebp
  801567:	89 e5                	mov    %esp,%ebp
  801569:	53                   	push   %ebx
  80156a:	83 ec 14             	sub    $0x14,%esp
  80156d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801570:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801573:	50                   	push   %eax
  801574:	53                   	push   %ebx
  801575:	e8 ac fc ff ff       	call   801226 <fd_lookup>
  80157a:	83 c4 08             	add    $0x8,%esp
  80157d:	89 c2                	mov    %eax,%edx
  80157f:	85 c0                	test   %eax,%eax
  801581:	78 68                	js     8015eb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801583:	83 ec 08             	sub    $0x8,%esp
  801586:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801589:	50                   	push   %eax
  80158a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80158d:	ff 30                	pushl  (%eax)
  80158f:	e8 e8 fc ff ff       	call   80127c <dev_lookup>
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	85 c0                	test   %eax,%eax
  801599:	78 47                	js     8015e2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80159b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8015a2:	75 21                	jne    8015c5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a4:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a9:	8b 40 48             	mov    0x48(%eax),%eax
  8015ac:	83 ec 04             	sub    $0x4,%esp
  8015af:	53                   	push   %ebx
  8015b0:	50                   	push   %eax
  8015b1:	68 19 27 80 00       	push   $0x802719
  8015b6:	e8 f6 eb ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c3:	eb 26                	jmp    8015eb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015c5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015cb:	85 d2                	test   %edx,%edx
  8015cd:	74 17                	je     8015e6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015cf:	83 ec 04             	sub    $0x4,%esp
  8015d2:	ff 75 10             	pushl  0x10(%ebp)
  8015d5:	ff 75 0c             	pushl  0xc(%ebp)
  8015d8:	50                   	push   %eax
  8015d9:	ff d2                	call   *%edx
  8015db:	89 c2                	mov    %eax,%edx
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	eb 09                	jmp    8015eb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e2:	89 c2                	mov    %eax,%edx
  8015e4:	eb 05                	jmp    8015eb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015eb:	89 d0                	mov    %edx,%eax
  8015ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f0:	c9                   	leave  
  8015f1:	c3                   	ret    

008015f2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015f2:	55                   	push   %ebp
  8015f3:	89 e5                	mov    %esp,%ebp
  8015f5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015f8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015fb:	50                   	push   %eax
  8015fc:	ff 75 08             	pushl  0x8(%ebp)
  8015ff:	e8 22 fc ff ff       	call   801226 <fd_lookup>
  801604:	83 c4 08             	add    $0x8,%esp
  801607:	85 c0                	test   %eax,%eax
  801609:	78 0e                	js     801619 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80160b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80160e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801611:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801614:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	53                   	push   %ebx
  80161f:	83 ec 14             	sub    $0x14,%esp
  801622:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801625:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	53                   	push   %ebx
  80162a:	e8 f7 fb ff ff       	call   801226 <fd_lookup>
  80162f:	83 c4 08             	add    $0x8,%esp
  801632:	89 c2                	mov    %eax,%edx
  801634:	85 c0                	test   %eax,%eax
  801636:	78 65                	js     80169d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80163e:	50                   	push   %eax
  80163f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801642:	ff 30                	pushl  (%eax)
  801644:	e8 33 fc ff ff       	call   80127c <dev_lookup>
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	85 c0                	test   %eax,%eax
  80164e:	78 44                	js     801694 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801650:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801653:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801657:	75 21                	jne    80167a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801659:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80165e:	8b 40 48             	mov    0x48(%eax),%eax
  801661:	83 ec 04             	sub    $0x4,%esp
  801664:	53                   	push   %ebx
  801665:	50                   	push   %eax
  801666:	68 dc 26 80 00       	push   $0x8026dc
  80166b:	e8 41 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801678:	eb 23                	jmp    80169d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80167a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167d:	8b 52 18             	mov    0x18(%edx),%edx
  801680:	85 d2                	test   %edx,%edx
  801682:	74 14                	je     801698 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801684:	83 ec 08             	sub    $0x8,%esp
  801687:	ff 75 0c             	pushl  0xc(%ebp)
  80168a:	50                   	push   %eax
  80168b:	ff d2                	call   *%edx
  80168d:	89 c2                	mov    %eax,%edx
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	eb 09                	jmp    80169d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801694:	89 c2                	mov    %eax,%edx
  801696:	eb 05                	jmp    80169d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801698:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80169d:	89 d0                	mov    %edx,%eax
  80169f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a2:	c9                   	leave  
  8016a3:	c3                   	ret    

008016a4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016a4:	55                   	push   %ebp
  8016a5:	89 e5                	mov    %esp,%ebp
  8016a7:	53                   	push   %ebx
  8016a8:	83 ec 14             	sub    $0x14,%esp
  8016ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	ff 75 08             	pushl  0x8(%ebp)
  8016b5:	e8 6c fb ff ff       	call   801226 <fd_lookup>
  8016ba:	83 c4 08             	add    $0x8,%esp
  8016bd:	89 c2                	mov    %eax,%edx
  8016bf:	85 c0                	test   %eax,%eax
  8016c1:	78 58                	js     80171b <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c9:	50                   	push   %eax
  8016ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cd:	ff 30                	pushl  (%eax)
  8016cf:	e8 a8 fb ff ff       	call   80127c <dev_lookup>
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 37                	js     801712 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016de:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016e2:	74 32                	je     801716 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016e4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016e7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016ee:	00 00 00 
	stat->st_isdir = 0;
  8016f1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016f8:	00 00 00 
	stat->st_dev = dev;
  8016fb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	53                   	push   %ebx
  801705:	ff 75 f0             	pushl  -0x10(%ebp)
  801708:	ff 50 14             	call   *0x14(%eax)
  80170b:	89 c2                	mov    %eax,%edx
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	eb 09                	jmp    80171b <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801712:	89 c2                	mov    %eax,%edx
  801714:	eb 05                	jmp    80171b <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801716:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80171b:	89 d0                	mov    %edx,%eax
  80171d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801727:	83 ec 08             	sub    $0x8,%esp
  80172a:	6a 00                	push   $0x0
  80172c:	ff 75 08             	pushl  0x8(%ebp)
  80172f:	e8 e9 01 00 00       	call   80191d <open>
  801734:	89 c3                	mov    %eax,%ebx
  801736:	83 c4 10             	add    $0x10,%esp
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 1b                	js     801758 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80173d:	83 ec 08             	sub    $0x8,%esp
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	50                   	push   %eax
  801744:	e8 5b ff ff ff       	call   8016a4 <fstat>
  801749:	89 c6                	mov    %eax,%esi
	close(fd);
  80174b:	89 1c 24             	mov    %ebx,(%esp)
  80174e:	e8 fd fb ff ff       	call   801350 <close>
	return r;
  801753:	83 c4 10             	add    $0x10,%esp
  801756:	89 f0                	mov    %esi,%eax
}
  801758:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175b:	5b                   	pop    %ebx
  80175c:	5e                   	pop    %esi
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	56                   	push   %esi
  801763:	53                   	push   %ebx
  801764:	89 c6                	mov    %eax,%esi
  801766:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801768:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80176f:	75 12                	jne    801783 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801771:	83 ec 0c             	sub    $0xc,%esp
  801774:	6a 01                	push   $0x1
  801776:	e8 fc f9 ff ff       	call   801177 <ipc_find_env>
  80177b:	a3 00 40 80 00       	mov    %eax,0x804000
  801780:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801783:	6a 07                	push   $0x7
  801785:	68 00 50 80 00       	push   $0x805000
  80178a:	56                   	push   %esi
  80178b:	ff 35 00 40 80 00    	pushl  0x804000
  801791:	e8 8d f9 ff ff       	call   801123 <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  801796:	83 c4 0c             	add    $0xc,%esp
  801799:	6a 00                	push   $0x0
  80179b:	53                   	push   %ebx
  80179c:	6a 00                	push   $0x0
  80179e:	e8 fe f8 ff ff       	call   8010a1 <ipc_recv>
}
  8017a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a6:	5b                   	pop    %ebx
  8017a7:	5e                   	pop    %esi
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017be:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 02 00 00 00       	mov    $0x2,%eax
  8017cd:	e8 8d ff ff ff       	call   80175f <fsipc>
}
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017da:	8b 45 08             	mov    0x8(%ebp),%eax
  8017dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8017ef:	e8 6b ff ff ff       	call   80175f <fsipc>
}
  8017f4:	c9                   	leave  
  8017f5:	c3                   	ret    

008017f6 <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	53                   	push   %ebx
  8017fa:	83 ec 04             	sub    $0x4,%esp
  8017fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801800:	8b 45 08             	mov    0x8(%ebp),%eax
  801803:	8b 40 0c             	mov    0xc(%eax),%eax
  801806:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80180b:	ba 00 00 00 00       	mov    $0x0,%edx
  801810:	b8 05 00 00 00       	mov    $0x5,%eax
  801815:	e8 45 ff ff ff       	call   80175f <fsipc>
  80181a:	85 c0                	test   %eax,%eax
  80181c:	78 2c                	js     80184a <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80181e:	83 ec 08             	sub    $0x8,%esp
  801821:	68 00 50 80 00       	push   $0x805000
  801826:	53                   	push   %ebx
  801827:	e8 89 ef ff ff       	call   8007b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80182c:	a1 80 50 80 00       	mov    0x805080,%eax
  801831:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801837:	a1 84 50 80 00       	mov    0x805084,%eax
  80183c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80184a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80184d:	c9                   	leave  
  80184e:	c3                   	ret    

0080184f <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	8b 45 10             	mov    0x10(%ebp),%eax
  801858:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80185d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801862:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  801865:	8b 55 08             	mov    0x8(%ebp),%edx
  801868:	8b 52 0c             	mov    0xc(%edx),%edx
  80186b:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801871:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  801876:	50                   	push   %eax
  801877:	ff 75 0c             	pushl  0xc(%ebp)
  80187a:	68 08 50 80 00       	push   $0x805008
  80187f:	e8 c3 f0 ff ff       	call   800947 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  801884:	ba 00 00 00 00       	mov    $0x0,%edx
  801889:	b8 04 00 00 00       	mov    $0x4,%eax
  80188e:	e8 cc fe ff ff       	call   80175f <fsipc>
            return r;

    return r;
}
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	56                   	push   %esi
  801899:	53                   	push   %ebx
  80189a:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80189d:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018a3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018a8:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b3:	b8 03 00 00 00       	mov    $0x3,%eax
  8018b8:	e8 a2 fe ff ff       	call   80175f <fsipc>
  8018bd:	89 c3                	mov    %eax,%ebx
  8018bf:	85 c0                	test   %eax,%eax
  8018c1:	78 51                	js     801914 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8018c3:	39 c6                	cmp    %eax,%esi
  8018c5:	73 19                	jae    8018e0 <devfile_read+0x4b>
  8018c7:	68 48 27 80 00       	push   $0x802748
  8018cc:	68 4f 27 80 00       	push   $0x80274f
  8018d1:	68 82 00 00 00       	push   $0x82
  8018d6:	68 64 27 80 00       	push   $0x802764
  8018db:	e8 c0 05 00 00       	call   801ea0 <_panic>
	assert(r <= PGSIZE);
  8018e0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018e5:	7e 19                	jle    801900 <devfile_read+0x6b>
  8018e7:	68 6f 27 80 00       	push   $0x80276f
  8018ec:	68 4f 27 80 00       	push   $0x80274f
  8018f1:	68 83 00 00 00       	push   $0x83
  8018f6:	68 64 27 80 00       	push   $0x802764
  8018fb:	e8 a0 05 00 00       	call   801ea0 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801900:	83 ec 04             	sub    $0x4,%esp
  801903:	50                   	push   %eax
  801904:	68 00 50 80 00       	push   $0x805000
  801909:	ff 75 0c             	pushl  0xc(%ebp)
  80190c:	e8 36 f0 ff ff       	call   800947 <memmove>
	return r;
  801911:	83 c4 10             	add    $0x10,%esp
}
  801914:	89 d8                	mov    %ebx,%eax
  801916:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801919:	5b                   	pop    %ebx
  80191a:	5e                   	pop    %esi
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    

0080191d <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80191d:	55                   	push   %ebp
  80191e:	89 e5                	mov    %esp,%ebp
  801920:	53                   	push   %ebx
  801921:	83 ec 20             	sub    $0x20,%esp
  801924:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801927:	53                   	push   %ebx
  801928:	e8 4f ee ff ff       	call   80077c <strlen>
  80192d:	83 c4 10             	add    $0x10,%esp
  801930:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801935:	7f 67                	jg     80199e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193d:	50                   	push   %eax
  80193e:	e8 94 f8 ff ff       	call   8011d7 <fd_alloc>
  801943:	83 c4 10             	add    $0x10,%esp
		return r;
  801946:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 57                	js     8019a3 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	53                   	push   %ebx
  801950:	68 00 50 80 00       	push   $0x805000
  801955:	e8 5b ee ff ff       	call   8007b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80195a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80195d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801962:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801965:	b8 01 00 00 00       	mov    $0x1,%eax
  80196a:	e8 f0 fd ff ff       	call   80175f <fsipc>
  80196f:	89 c3                	mov    %eax,%ebx
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	79 14                	jns    80198c <open+0x6f>
		fd_close(fd, 0);
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	6a 00                	push   $0x0
  80197d:	ff 75 f4             	pushl  -0xc(%ebp)
  801980:	e8 4a f9 ff ff       	call   8012cf <fd_close>
		return r;
  801985:	83 c4 10             	add    $0x10,%esp
  801988:	89 da                	mov    %ebx,%edx
  80198a:	eb 17                	jmp    8019a3 <open+0x86>
	}

	return fd2num(fd);
  80198c:	83 ec 0c             	sub    $0xc,%esp
  80198f:	ff 75 f4             	pushl  -0xc(%ebp)
  801992:	e8 19 f8 ff ff       	call   8011b0 <fd2num>
  801997:	89 c2                	mov    %eax,%edx
  801999:	83 c4 10             	add    $0x10,%esp
  80199c:	eb 05                	jmp    8019a3 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80199e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8019a3:	89 d0                	mov    %edx,%eax
  8019a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a8:	c9                   	leave  
  8019a9:	c3                   	ret    

008019aa <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019aa:	55                   	push   %ebp
  8019ab:	89 e5                	mov    %esp,%ebp
  8019ad:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b5:	b8 08 00 00 00       	mov    $0x8,%eax
  8019ba:	e8 a0 fd ff ff       	call   80175f <fsipc>
}
  8019bf:	c9                   	leave  
  8019c0:	c3                   	ret    

008019c1 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019c1:	55                   	push   %ebp
  8019c2:	89 e5                	mov    %esp,%ebp
  8019c4:	56                   	push   %esi
  8019c5:	53                   	push   %ebx
  8019c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019c9:	83 ec 0c             	sub    $0xc,%esp
  8019cc:	ff 75 08             	pushl  0x8(%ebp)
  8019cf:	e8 ec f7 ff ff       	call   8011c0 <fd2data>
  8019d4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019d6:	83 c4 08             	add    $0x8,%esp
  8019d9:	68 7b 27 80 00       	push   $0x80277b
  8019de:	53                   	push   %ebx
  8019df:	e8 d1 ed ff ff       	call   8007b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019e4:	8b 46 04             	mov    0x4(%esi),%eax
  8019e7:	2b 06                	sub    (%esi),%eax
  8019e9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019ef:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019f6:	00 00 00 
	stat->st_dev = &devpipe;
  8019f9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a00:	30 80 00 
	return 0;
}
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
  801a08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5e                   	pop    %esi
  801a0d:	5d                   	pop    %ebp
  801a0e:	c3                   	ret    

00801a0f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	53                   	push   %ebx
  801a13:	83 ec 0c             	sub    $0xc,%esp
  801a16:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a19:	53                   	push   %ebx
  801a1a:	6a 00                	push   $0x0
  801a1c:	e8 1c f2 ff ff       	call   800c3d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a21:	89 1c 24             	mov    %ebx,(%esp)
  801a24:	e8 97 f7 ff ff       	call   8011c0 <fd2data>
  801a29:	83 c4 08             	add    $0x8,%esp
  801a2c:	50                   	push   %eax
  801a2d:	6a 00                	push   $0x0
  801a2f:	e8 09 f2 ff ff       	call   800c3d <sys_page_unmap>
}
  801a34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a37:	c9                   	leave  
  801a38:	c3                   	ret    

00801a39 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a39:	55                   	push   %ebp
  801a3a:	89 e5                	mov    %esp,%ebp
  801a3c:	57                   	push   %edi
  801a3d:	56                   	push   %esi
  801a3e:	53                   	push   %ebx
  801a3f:	83 ec 1c             	sub    $0x1c,%esp
  801a42:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a45:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a47:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4c:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	ff 75 e0             	pushl  -0x20(%ebp)
  801a55:	e8 26 05 00 00       	call   801f80 <pageref>
  801a5a:	89 c3                	mov    %eax,%ebx
  801a5c:	89 3c 24             	mov    %edi,(%esp)
  801a5f:	e8 1c 05 00 00       	call   801f80 <pageref>
  801a64:	83 c4 10             	add    $0x10,%esp
  801a67:	39 c3                	cmp    %eax,%ebx
  801a69:	0f 94 c1             	sete   %cl
  801a6c:	0f b6 c9             	movzbl %cl,%ecx
  801a6f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a72:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a78:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a7b:	39 ce                	cmp    %ecx,%esi
  801a7d:	74 1b                	je     801a9a <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801a7f:	39 c3                	cmp    %eax,%ebx
  801a81:	75 c4                	jne    801a47 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a83:	8b 42 58             	mov    0x58(%edx),%eax
  801a86:	ff 75 e4             	pushl  -0x1c(%ebp)
  801a89:	50                   	push   %eax
  801a8a:	56                   	push   %esi
  801a8b:	68 82 27 80 00       	push   $0x802782
  801a90:	e8 1c e7 ff ff       	call   8001b1 <cprintf>
  801a95:	83 c4 10             	add    $0x10,%esp
  801a98:	eb ad                	jmp    801a47 <_pipeisclosed+0xe>
	}
}
  801a9a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa0:	5b                   	pop    %ebx
  801aa1:	5e                   	pop    %esi
  801aa2:	5f                   	pop    %edi
  801aa3:	5d                   	pop    %ebp
  801aa4:	c3                   	ret    

00801aa5 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aa5:	55                   	push   %ebp
  801aa6:	89 e5                	mov    %esp,%ebp
  801aa8:	57                   	push   %edi
  801aa9:	56                   	push   %esi
  801aaa:	53                   	push   %ebx
  801aab:	83 ec 28             	sub    $0x28,%esp
  801aae:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ab1:	56                   	push   %esi
  801ab2:	e8 09 f7 ff ff       	call   8011c0 <fd2data>
  801ab7:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	bf 00 00 00 00       	mov    $0x0,%edi
  801ac1:	eb 4b                	jmp    801b0e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ac3:	89 da                	mov    %ebx,%edx
  801ac5:	89 f0                	mov    %esi,%eax
  801ac7:	e8 6d ff ff ff       	call   801a39 <_pipeisclosed>
  801acc:	85 c0                	test   %eax,%eax
  801ace:	75 48                	jne    801b18 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801ad0:	e8 c4 f0 ff ff       	call   800b99 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ad5:	8b 43 04             	mov    0x4(%ebx),%eax
  801ad8:	8b 0b                	mov    (%ebx),%ecx
  801ada:	8d 51 20             	lea    0x20(%ecx),%edx
  801add:	39 d0                	cmp    %edx,%eax
  801adf:	73 e2                	jae    801ac3 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ae1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ae4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ae8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801aeb:	89 c2                	mov    %eax,%edx
  801aed:	c1 fa 1f             	sar    $0x1f,%edx
  801af0:	89 d1                	mov    %edx,%ecx
  801af2:	c1 e9 1b             	shr    $0x1b,%ecx
  801af5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801af8:	83 e2 1f             	and    $0x1f,%edx
  801afb:	29 ca                	sub    %ecx,%edx
  801afd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b01:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b05:	83 c0 01             	add    $0x1,%eax
  801b08:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0b:	83 c7 01             	add    $0x1,%edi
  801b0e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b11:	75 c2                	jne    801ad5 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b13:	8b 45 10             	mov    0x10(%ebp),%eax
  801b16:	eb 05                	jmp    801b1d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5f                   	pop    %edi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	57                   	push   %edi
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 18             	sub    $0x18,%esp
  801b2e:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b31:	57                   	push   %edi
  801b32:	e8 89 f6 ff ff       	call   8011c0 <fd2data>
  801b37:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b41:	eb 3d                	jmp    801b80 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b43:	85 db                	test   %ebx,%ebx
  801b45:	74 04                	je     801b4b <devpipe_read+0x26>
				return i;
  801b47:	89 d8                	mov    %ebx,%eax
  801b49:	eb 44                	jmp    801b8f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b4b:	89 f2                	mov    %esi,%edx
  801b4d:	89 f8                	mov    %edi,%eax
  801b4f:	e8 e5 fe ff ff       	call   801a39 <_pipeisclosed>
  801b54:	85 c0                	test   %eax,%eax
  801b56:	75 32                	jne    801b8a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b58:	e8 3c f0 ff ff       	call   800b99 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b5d:	8b 06                	mov    (%esi),%eax
  801b5f:	3b 46 04             	cmp    0x4(%esi),%eax
  801b62:	74 df                	je     801b43 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b64:	99                   	cltd   
  801b65:	c1 ea 1b             	shr    $0x1b,%edx
  801b68:	01 d0                	add    %edx,%eax
  801b6a:	83 e0 1f             	and    $0x1f,%eax
  801b6d:	29 d0                	sub    %edx,%eax
  801b6f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b77:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b7a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7d:	83 c3 01             	add    $0x1,%ebx
  801b80:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b83:	75 d8                	jne    801b5d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b85:	8b 45 10             	mov    0x10(%ebp),%eax
  801b88:	eb 05                	jmp    801b8f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b8a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b92:	5b                   	pop    %ebx
  801b93:	5e                   	pop    %esi
  801b94:	5f                   	pop    %edi
  801b95:	5d                   	pop    %ebp
  801b96:	c3                   	ret    

00801b97 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b97:	55                   	push   %ebp
  801b98:	89 e5                	mov    %esp,%ebp
  801b9a:	56                   	push   %esi
  801b9b:	53                   	push   %ebx
  801b9c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ba2:	50                   	push   %eax
  801ba3:	e8 2f f6 ff ff       	call   8011d7 <fd_alloc>
  801ba8:	83 c4 10             	add    $0x10,%esp
  801bab:	89 c2                	mov    %eax,%edx
  801bad:	85 c0                	test   %eax,%eax
  801baf:	0f 88 2c 01 00 00    	js     801ce1 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	68 07 04 00 00       	push   $0x407
  801bbd:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc0:	6a 00                	push   $0x0
  801bc2:	e8 f1 ef ff ff       	call   800bb8 <sys_page_alloc>
  801bc7:	83 c4 10             	add    $0x10,%esp
  801bca:	89 c2                	mov    %eax,%edx
  801bcc:	85 c0                	test   %eax,%eax
  801bce:	0f 88 0d 01 00 00    	js     801ce1 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bd4:	83 ec 0c             	sub    $0xc,%esp
  801bd7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801bda:	50                   	push   %eax
  801bdb:	e8 f7 f5 ff ff       	call   8011d7 <fd_alloc>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 10             	add    $0x10,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	0f 88 e2 00 00 00    	js     801ccf <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bed:	83 ec 04             	sub    $0x4,%esp
  801bf0:	68 07 04 00 00       	push   $0x407
  801bf5:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 b9 ef ff ff       	call   800bb8 <sys_page_alloc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	83 c4 10             	add    $0x10,%esp
  801c04:	85 c0                	test   %eax,%eax
  801c06:	0f 88 c3 00 00 00    	js     801ccf <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c0c:	83 ec 0c             	sub    $0xc,%esp
  801c0f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c12:	e8 a9 f5 ff ff       	call   8011c0 <fd2data>
  801c17:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c19:	83 c4 0c             	add    $0xc,%esp
  801c1c:	68 07 04 00 00       	push   $0x407
  801c21:	50                   	push   %eax
  801c22:	6a 00                	push   $0x0
  801c24:	e8 8f ef ff ff       	call   800bb8 <sys_page_alloc>
  801c29:	89 c3                	mov    %eax,%ebx
  801c2b:	83 c4 10             	add    $0x10,%esp
  801c2e:	85 c0                	test   %eax,%eax
  801c30:	0f 88 89 00 00 00    	js     801cbf <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c36:	83 ec 0c             	sub    $0xc,%esp
  801c39:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3c:	e8 7f f5 ff ff       	call   8011c0 <fd2data>
  801c41:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c48:	50                   	push   %eax
  801c49:	6a 00                	push   $0x0
  801c4b:	56                   	push   %esi
  801c4c:	6a 00                	push   $0x0
  801c4e:	e8 a8 ef ff ff       	call   800bfb <sys_page_map>
  801c53:	89 c3                	mov    %eax,%ebx
  801c55:	83 c4 20             	add    $0x20,%esp
  801c58:	85 c0                	test   %eax,%eax
  801c5a:	78 55                	js     801cb1 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c5c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c65:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c71:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c77:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c7c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c7f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c86:	83 ec 0c             	sub    $0xc,%esp
  801c89:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8c:	e8 1f f5 ff ff       	call   8011b0 <fd2num>
  801c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c94:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c96:	83 c4 04             	add    $0x4,%esp
  801c99:	ff 75 f0             	pushl  -0x10(%ebp)
  801c9c:	e8 0f f5 ff ff       	call   8011b0 <fd2num>
  801ca1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ca4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ca7:	83 c4 10             	add    $0x10,%esp
  801caa:	ba 00 00 00 00       	mov    $0x0,%edx
  801caf:	eb 30                	jmp    801ce1 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cb1:	83 ec 08             	sub    $0x8,%esp
  801cb4:	56                   	push   %esi
  801cb5:	6a 00                	push   $0x0
  801cb7:	e8 81 ef ff ff       	call   800c3d <sys_page_unmap>
  801cbc:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cbf:	83 ec 08             	sub    $0x8,%esp
  801cc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc5:	6a 00                	push   $0x0
  801cc7:	e8 71 ef ff ff       	call   800c3d <sys_page_unmap>
  801ccc:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ccf:	83 ec 08             	sub    $0x8,%esp
  801cd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd5:	6a 00                	push   $0x0
  801cd7:	e8 61 ef ff ff       	call   800c3d <sys_page_unmap>
  801cdc:	83 c4 10             	add    $0x10,%esp
  801cdf:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801ce1:	89 d0                	mov    %edx,%eax
  801ce3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ce6:	5b                   	pop    %ebx
  801ce7:	5e                   	pop    %esi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cf0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cf3:	50                   	push   %eax
  801cf4:	ff 75 08             	pushl  0x8(%ebp)
  801cf7:	e8 2a f5 ff ff       	call   801226 <fd_lookup>
  801cfc:	83 c4 10             	add    $0x10,%esp
  801cff:	85 c0                	test   %eax,%eax
  801d01:	78 18                	js     801d1b <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d03:	83 ec 0c             	sub    $0xc,%esp
  801d06:	ff 75 f4             	pushl  -0xc(%ebp)
  801d09:	e8 b2 f4 ff ff       	call   8011c0 <fd2data>
	return _pipeisclosed(fd, p);
  801d0e:	89 c2                	mov    %eax,%edx
  801d10:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d13:	e8 21 fd ff ff       	call   801a39 <_pipeisclosed>
  801d18:	83 c4 10             	add    $0x10,%esp
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
  801d25:	5d                   	pop    %ebp
  801d26:	c3                   	ret    

00801d27 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d27:	55                   	push   %ebp
  801d28:	89 e5                	mov    %esp,%ebp
  801d2a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d2d:	68 9a 27 80 00       	push   $0x80279a
  801d32:	ff 75 0c             	pushl  0xc(%ebp)
  801d35:	e8 7b ea ff ff       	call   8007b5 <strcpy>
	return 0;
}
  801d3a:	b8 00 00 00 00       	mov    $0x0,%eax
  801d3f:	c9                   	leave  
  801d40:	c3                   	ret    

00801d41 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	57                   	push   %edi
  801d45:	56                   	push   %esi
  801d46:	53                   	push   %ebx
  801d47:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d4d:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d52:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d58:	eb 2d                	jmp    801d87 <devcons_write+0x46>
		m = n - tot;
  801d5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d5d:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d5f:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d62:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d67:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d6a:	83 ec 04             	sub    $0x4,%esp
  801d6d:	53                   	push   %ebx
  801d6e:	03 45 0c             	add    0xc(%ebp),%eax
  801d71:	50                   	push   %eax
  801d72:	57                   	push   %edi
  801d73:	e8 cf eb ff ff       	call   800947 <memmove>
		sys_cputs(buf, m);
  801d78:	83 c4 08             	add    $0x8,%esp
  801d7b:	53                   	push   %ebx
  801d7c:	57                   	push   %edi
  801d7d:	e8 7a ed ff ff       	call   800afc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d82:	01 de                	add    %ebx,%esi
  801d84:	83 c4 10             	add    $0x10,%esp
  801d87:	89 f0                	mov    %esi,%eax
  801d89:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d8c:	72 cc                	jb     801d5a <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801d8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d91:	5b                   	pop    %ebx
  801d92:	5e                   	pop    %esi
  801d93:	5f                   	pop    %edi
  801d94:	5d                   	pop    %ebp
  801d95:	c3                   	ret    

00801d96 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d96:	55                   	push   %ebp
  801d97:	89 e5                	mov    %esp,%ebp
  801d99:	83 ec 08             	sub    $0x8,%esp
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801da1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801da5:	74 2a                	je     801dd1 <devcons_read+0x3b>
  801da7:	eb 05                	jmp    801dae <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801da9:	e8 eb ed ff ff       	call   800b99 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dae:	e8 67 ed ff ff       	call   800b1a <sys_cgetc>
  801db3:	85 c0                	test   %eax,%eax
  801db5:	74 f2                	je     801da9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801db7:	85 c0                	test   %eax,%eax
  801db9:	78 16                	js     801dd1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801dbb:	83 f8 04             	cmp    $0x4,%eax
  801dbe:	74 0c                	je     801dcc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dc0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc3:	88 02                	mov    %al,(%edx)
	return 1;
  801dc5:	b8 01 00 00 00       	mov    $0x1,%eax
  801dca:	eb 05                	jmp    801dd1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801dcc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dd1:	c9                   	leave  
  801dd2:	c3                   	ret    

00801dd3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801dd3:	55                   	push   %ebp
  801dd4:	89 e5                	mov    %esp,%ebp
  801dd6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801dd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ddf:	6a 01                	push   $0x1
  801de1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801de4:	50                   	push   %eax
  801de5:	e8 12 ed ff ff       	call   800afc <sys_cputs>
}
  801dea:	83 c4 10             	add    $0x10,%esp
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <getchar>:

int
getchar(void)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801df5:	6a 01                	push   $0x1
  801df7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801dfa:	50                   	push   %eax
  801dfb:	6a 00                	push   $0x0
  801dfd:	e8 8a f6 ff ff       	call   80148c <read>
	if (r < 0)
  801e02:	83 c4 10             	add    $0x10,%esp
  801e05:	85 c0                	test   %eax,%eax
  801e07:	78 0f                	js     801e18 <getchar+0x29>
		return r;
	if (r < 1)
  801e09:	85 c0                	test   %eax,%eax
  801e0b:	7e 06                	jle    801e13 <getchar+0x24>
		return -E_EOF;
	return c;
  801e0d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e11:	eb 05                	jmp    801e18 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e13:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e20:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e23:	50                   	push   %eax
  801e24:	ff 75 08             	pushl  0x8(%ebp)
  801e27:	e8 fa f3 ff ff       	call   801226 <fd_lookup>
  801e2c:	83 c4 10             	add    $0x10,%esp
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	78 11                	js     801e44 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e36:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e3c:	39 10                	cmp    %edx,(%eax)
  801e3e:	0f 94 c0             	sete   %al
  801e41:	0f b6 c0             	movzbl %al,%eax
}
  801e44:	c9                   	leave  
  801e45:	c3                   	ret    

00801e46 <opencons>:

int
opencons(void)
{
  801e46:	55                   	push   %ebp
  801e47:	89 e5                	mov    %esp,%ebp
  801e49:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4f:	50                   	push   %eax
  801e50:	e8 82 f3 ff ff       	call   8011d7 <fd_alloc>
  801e55:	83 c4 10             	add    $0x10,%esp
		return r;
  801e58:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e5a:	85 c0                	test   %eax,%eax
  801e5c:	78 3e                	js     801e9c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e5e:	83 ec 04             	sub    $0x4,%esp
  801e61:	68 07 04 00 00       	push   $0x407
  801e66:	ff 75 f4             	pushl  -0xc(%ebp)
  801e69:	6a 00                	push   $0x0
  801e6b:	e8 48 ed ff ff       	call   800bb8 <sys_page_alloc>
  801e70:	83 c4 10             	add    $0x10,%esp
		return r;
  801e73:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e75:	85 c0                	test   %eax,%eax
  801e77:	78 23                	js     801e9c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801e79:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e82:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e87:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e8e:	83 ec 0c             	sub    $0xc,%esp
  801e91:	50                   	push   %eax
  801e92:	e8 19 f3 ff ff       	call   8011b0 <fd2num>
  801e97:	89 c2                	mov    %eax,%edx
  801e99:	83 c4 10             	add    $0x10,%esp
}
  801e9c:	89 d0                	mov    %edx,%eax
  801e9e:	c9                   	leave  
  801e9f:	c3                   	ret    

00801ea0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	56                   	push   %esi
  801ea4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ea5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ea8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801eae:	e8 c7 ec ff ff       	call   800b7a <sys_getenvid>
  801eb3:	83 ec 0c             	sub    $0xc,%esp
  801eb6:	ff 75 0c             	pushl  0xc(%ebp)
  801eb9:	ff 75 08             	pushl  0x8(%ebp)
  801ebc:	56                   	push   %esi
  801ebd:	50                   	push   %eax
  801ebe:	68 a8 27 80 00       	push   $0x8027a8
  801ec3:	e8 e9 e2 ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ec8:	83 c4 18             	add    $0x18,%esp
  801ecb:	53                   	push   %ebx
  801ecc:	ff 75 10             	pushl  0x10(%ebp)
  801ecf:	e8 8c e2 ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  801ed4:	c7 04 24 93 27 80 00 	movl   $0x802793,(%esp)
  801edb:	e8 d1 e2 ff ff       	call   8001b1 <cprintf>
  801ee0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ee3:	cc                   	int3   
  801ee4:	eb fd                	jmp    801ee3 <_panic+0x43>

00801ee6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ee6:	55                   	push   %ebp
  801ee7:	89 e5                	mov    %esp,%ebp
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801eed:	e8 88 ec ff ff       	call   800b7a <sys_getenvid>
  801ef2:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801ef4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801efb:	75 29                	jne    801f26 <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801efd:	83 ec 04             	sub    $0x4,%esp
  801f00:	6a 07                	push   $0x7
  801f02:	68 00 f0 bf ee       	push   $0xeebff000
  801f07:	50                   	push   %eax
  801f08:	e8 ab ec ff ff       	call   800bb8 <sys_page_alloc>
  801f0d:	83 c4 10             	add    $0x10,%esp
  801f10:	85 c0                	test   %eax,%eax
  801f12:	79 12                	jns    801f26 <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801f14:	50                   	push   %eax
  801f15:	68 cc 27 80 00       	push   $0x8027cc
  801f1a:	6a 24                	push   $0x24
  801f1c:	68 e5 27 80 00       	push   $0x8027e5
  801f21:	e8 7a ff ff ff       	call   801ea0 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801f26:	8b 45 08             	mov    0x8(%ebp),%eax
  801f29:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801f2e:	83 ec 08             	sub    $0x8,%esp
  801f31:	68 5a 1f 80 00       	push   $0x801f5a
  801f36:	53                   	push   %ebx
  801f37:	e8 c7 ed ff ff       	call   800d03 <sys_env_set_pgfault_upcall>
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	85 c0                	test   %eax,%eax
  801f41:	79 12                	jns    801f55 <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801f43:	50                   	push   %eax
  801f44:	68 cc 27 80 00       	push   $0x8027cc
  801f49:	6a 2e                	push   $0x2e
  801f4b:	68 e5 27 80 00       	push   $0x8027e5
  801f50:	e8 4b ff ff ff       	call   801ea0 <_panic>
}
  801f55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    

00801f5a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f5a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f5b:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f60:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f62:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801f65:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801f69:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  801f6c:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801f70:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801f72:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801f76:	83 c4 08             	add    $0x8,%esp
	popal
  801f79:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801f7a:	83 c4 04             	add    $0x4,%esp
	popfl
  801f7d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  801f7e:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801f7f:	c3                   	ret    

00801f80 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f86:	89 d0                	mov    %edx,%eax
  801f88:	c1 e8 16             	shr    $0x16,%eax
  801f8b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f92:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f97:	f6 c1 01             	test   $0x1,%cl
  801f9a:	74 1d                	je     801fb9 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f9c:	c1 ea 0c             	shr    $0xc,%edx
  801f9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801fa6:	f6 c2 01             	test   $0x1,%dl
  801fa9:	74 0e                	je     801fb9 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fab:	c1 ea 0c             	shr    $0xc,%edx
  801fae:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fb5:	ef 
  801fb6:	0f b7 c0             	movzwl %ax,%eax
}
  801fb9:	5d                   	pop    %ebp
  801fba:	c3                   	ret    
  801fbb:	66 90                	xchg   %ax,%ax
  801fbd:	66 90                	xchg   %ax,%ax
  801fbf:	90                   	nop

00801fc0 <__udivdi3>:
  801fc0:	55                   	push   %ebp
  801fc1:	57                   	push   %edi
  801fc2:	56                   	push   %esi
  801fc3:	53                   	push   %ebx
  801fc4:	83 ec 1c             	sub    $0x1c,%esp
  801fc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801fcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801fcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801fd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801fd7:	85 f6                	test   %esi,%esi
  801fd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801fdd:	89 ca                	mov    %ecx,%edx
  801fdf:	89 f8                	mov    %edi,%eax
  801fe1:	75 3d                	jne    802020 <__udivdi3+0x60>
  801fe3:	39 cf                	cmp    %ecx,%edi
  801fe5:	0f 87 c5 00 00 00    	ja     8020b0 <__udivdi3+0xf0>
  801feb:	85 ff                	test   %edi,%edi
  801fed:	89 fd                	mov    %edi,%ebp
  801fef:	75 0b                	jne    801ffc <__udivdi3+0x3c>
  801ff1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff6:	31 d2                	xor    %edx,%edx
  801ff8:	f7 f7                	div    %edi
  801ffa:	89 c5                	mov    %eax,%ebp
  801ffc:	89 c8                	mov    %ecx,%eax
  801ffe:	31 d2                	xor    %edx,%edx
  802000:	f7 f5                	div    %ebp
  802002:	89 c1                	mov    %eax,%ecx
  802004:	89 d8                	mov    %ebx,%eax
  802006:	89 cf                	mov    %ecx,%edi
  802008:	f7 f5                	div    %ebp
  80200a:	89 c3                	mov    %eax,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	39 ce                	cmp    %ecx,%esi
  802022:	77 74                	ja     802098 <__udivdi3+0xd8>
  802024:	0f bd fe             	bsr    %esi,%edi
  802027:	83 f7 1f             	xor    $0x1f,%edi
  80202a:	0f 84 98 00 00 00    	je     8020c8 <__udivdi3+0x108>
  802030:	bb 20 00 00 00       	mov    $0x20,%ebx
  802035:	89 f9                	mov    %edi,%ecx
  802037:	89 c5                	mov    %eax,%ebp
  802039:	29 fb                	sub    %edi,%ebx
  80203b:	d3 e6                	shl    %cl,%esi
  80203d:	89 d9                	mov    %ebx,%ecx
  80203f:	d3 ed                	shr    %cl,%ebp
  802041:	89 f9                	mov    %edi,%ecx
  802043:	d3 e0                	shl    %cl,%eax
  802045:	09 ee                	or     %ebp,%esi
  802047:	89 d9                	mov    %ebx,%ecx
  802049:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80204d:	89 d5                	mov    %edx,%ebp
  80204f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802053:	d3 ed                	shr    %cl,%ebp
  802055:	89 f9                	mov    %edi,%ecx
  802057:	d3 e2                	shl    %cl,%edx
  802059:	89 d9                	mov    %ebx,%ecx
  80205b:	d3 e8                	shr    %cl,%eax
  80205d:	09 c2                	or     %eax,%edx
  80205f:	89 d0                	mov    %edx,%eax
  802061:	89 ea                	mov    %ebp,%edx
  802063:	f7 f6                	div    %esi
  802065:	89 d5                	mov    %edx,%ebp
  802067:	89 c3                	mov    %eax,%ebx
  802069:	f7 64 24 0c          	mull   0xc(%esp)
  80206d:	39 d5                	cmp    %edx,%ebp
  80206f:	72 10                	jb     802081 <__udivdi3+0xc1>
  802071:	8b 74 24 08          	mov    0x8(%esp),%esi
  802075:	89 f9                	mov    %edi,%ecx
  802077:	d3 e6                	shl    %cl,%esi
  802079:	39 c6                	cmp    %eax,%esi
  80207b:	73 07                	jae    802084 <__udivdi3+0xc4>
  80207d:	39 d5                	cmp    %edx,%ebp
  80207f:	75 03                	jne    802084 <__udivdi3+0xc4>
  802081:	83 eb 01             	sub    $0x1,%ebx
  802084:	31 ff                	xor    %edi,%edi
  802086:	89 d8                	mov    %ebx,%eax
  802088:	89 fa                	mov    %edi,%edx
  80208a:	83 c4 1c             	add    $0x1c,%esp
  80208d:	5b                   	pop    %ebx
  80208e:	5e                   	pop    %esi
  80208f:	5f                   	pop    %edi
  802090:	5d                   	pop    %ebp
  802091:	c3                   	ret    
  802092:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802098:	31 ff                	xor    %edi,%edi
  80209a:	31 db                	xor    %ebx,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 d8                	mov    %ebx,%eax
  8020b2:	f7 f7                	div    %edi
  8020b4:	31 ff                	xor    %edi,%edi
  8020b6:	89 c3                	mov    %eax,%ebx
  8020b8:	89 d8                	mov    %ebx,%eax
  8020ba:	89 fa                	mov    %edi,%edx
  8020bc:	83 c4 1c             	add    $0x1c,%esp
  8020bf:	5b                   	pop    %ebx
  8020c0:	5e                   	pop    %esi
  8020c1:	5f                   	pop    %edi
  8020c2:	5d                   	pop    %ebp
  8020c3:	c3                   	ret    
  8020c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020c8:	39 ce                	cmp    %ecx,%esi
  8020ca:	72 0c                	jb     8020d8 <__udivdi3+0x118>
  8020cc:	31 db                	xor    %ebx,%ebx
  8020ce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8020d2:	0f 87 34 ff ff ff    	ja     80200c <__udivdi3+0x4c>
  8020d8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8020dd:	e9 2a ff ff ff       	jmp    80200c <__udivdi3+0x4c>
  8020e2:	66 90                	xchg   %ax,%ax
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__umoddi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	53                   	push   %ebx
  8020f4:	83 ec 1c             	sub    $0x1c,%esp
  8020f7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8020fb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8020ff:	8b 74 24 34          	mov    0x34(%esp),%esi
  802103:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802107:	85 d2                	test   %edx,%edx
  802109:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80210d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802111:	89 f3                	mov    %esi,%ebx
  802113:	89 3c 24             	mov    %edi,(%esp)
  802116:	89 74 24 04          	mov    %esi,0x4(%esp)
  80211a:	75 1c                	jne    802138 <__umoddi3+0x48>
  80211c:	39 f7                	cmp    %esi,%edi
  80211e:	76 50                	jbe    802170 <__umoddi3+0x80>
  802120:	89 c8                	mov    %ecx,%eax
  802122:	89 f2                	mov    %esi,%edx
  802124:	f7 f7                	div    %edi
  802126:	89 d0                	mov    %edx,%eax
  802128:	31 d2                	xor    %edx,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	39 f2                	cmp    %esi,%edx
  80213a:	89 d0                	mov    %edx,%eax
  80213c:	77 52                	ja     802190 <__umoddi3+0xa0>
  80213e:	0f bd ea             	bsr    %edx,%ebp
  802141:	83 f5 1f             	xor    $0x1f,%ebp
  802144:	75 5a                	jne    8021a0 <__umoddi3+0xb0>
  802146:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80214a:	0f 82 e0 00 00 00    	jb     802230 <__umoddi3+0x140>
  802150:	39 0c 24             	cmp    %ecx,(%esp)
  802153:	0f 86 d7 00 00 00    	jbe    802230 <__umoddi3+0x140>
  802159:	8b 44 24 08          	mov    0x8(%esp),%eax
  80215d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802161:	83 c4 1c             	add    $0x1c,%esp
  802164:	5b                   	pop    %ebx
  802165:	5e                   	pop    %esi
  802166:	5f                   	pop    %edi
  802167:	5d                   	pop    %ebp
  802168:	c3                   	ret    
  802169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802170:	85 ff                	test   %edi,%edi
  802172:	89 fd                	mov    %edi,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x91>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f7                	div    %edi
  80217f:	89 c5                	mov    %eax,%ebp
  802181:	89 f0                	mov    %esi,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f5                	div    %ebp
  802187:	89 c8                	mov    %ecx,%eax
  802189:	f7 f5                	div    %ebp
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	eb 99                	jmp    802128 <__umoddi3+0x38>
  80218f:	90                   	nop
  802190:	89 c8                	mov    %ecx,%eax
  802192:	89 f2                	mov    %esi,%edx
  802194:	83 c4 1c             	add    $0x1c,%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	8b 34 24             	mov    (%esp),%esi
  8021a3:	bf 20 00 00 00       	mov    $0x20,%edi
  8021a8:	89 e9                	mov    %ebp,%ecx
  8021aa:	29 ef                	sub    %ebp,%edi
  8021ac:	d3 e0                	shl    %cl,%eax
  8021ae:	89 f9                	mov    %edi,%ecx
  8021b0:	89 f2                	mov    %esi,%edx
  8021b2:	d3 ea                	shr    %cl,%edx
  8021b4:	89 e9                	mov    %ebp,%ecx
  8021b6:	09 c2                	or     %eax,%edx
  8021b8:	89 d8                	mov    %ebx,%eax
  8021ba:	89 14 24             	mov    %edx,(%esp)
  8021bd:	89 f2                	mov    %esi,%edx
  8021bf:	d3 e2                	shl    %cl,%edx
  8021c1:	89 f9                	mov    %edi,%ecx
  8021c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021c7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8021cb:	d3 e8                	shr    %cl,%eax
  8021cd:	89 e9                	mov    %ebp,%ecx
  8021cf:	89 c6                	mov    %eax,%esi
  8021d1:	d3 e3                	shl    %cl,%ebx
  8021d3:	89 f9                	mov    %edi,%ecx
  8021d5:	89 d0                	mov    %edx,%eax
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 e9                	mov    %ebp,%ecx
  8021db:	09 d8                	or     %ebx,%eax
  8021dd:	89 d3                	mov    %edx,%ebx
  8021df:	89 f2                	mov    %esi,%edx
  8021e1:	f7 34 24             	divl   (%esp)
  8021e4:	89 d6                	mov    %edx,%esi
  8021e6:	d3 e3                	shl    %cl,%ebx
  8021e8:	f7 64 24 04          	mull   0x4(%esp)
  8021ec:	39 d6                	cmp    %edx,%esi
  8021ee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8021f2:	89 d1                	mov    %edx,%ecx
  8021f4:	89 c3                	mov    %eax,%ebx
  8021f6:	72 08                	jb     802200 <__umoddi3+0x110>
  8021f8:	75 11                	jne    80220b <__umoddi3+0x11b>
  8021fa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8021fe:	73 0b                	jae    80220b <__umoddi3+0x11b>
  802200:	2b 44 24 04          	sub    0x4(%esp),%eax
  802204:	1b 14 24             	sbb    (%esp),%edx
  802207:	89 d1                	mov    %edx,%ecx
  802209:	89 c3                	mov    %eax,%ebx
  80220b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80220f:	29 da                	sub    %ebx,%edx
  802211:	19 ce                	sbb    %ecx,%esi
  802213:	89 f9                	mov    %edi,%ecx
  802215:	89 f0                	mov    %esi,%eax
  802217:	d3 e0                	shl    %cl,%eax
  802219:	89 e9                	mov    %ebp,%ecx
  80221b:	d3 ea                	shr    %cl,%edx
  80221d:	89 e9                	mov    %ebp,%ecx
  80221f:	d3 ee                	shr    %cl,%esi
  802221:	09 d0                	or     %edx,%eax
  802223:	89 f2                	mov    %esi,%edx
  802225:	83 c4 1c             	add    $0x1c,%esp
  802228:	5b                   	pop    %ebx
  802229:	5e                   	pop    %esi
  80222a:	5f                   	pop    %edi
  80222b:	5d                   	pop    %ebp
  80222c:	c3                   	ret    
  80222d:	8d 76 00             	lea    0x0(%esi),%esi
  802230:	29 f9                	sub    %edi,%ecx
  802232:	19 d6                	sbb    %edx,%esi
  802234:	89 74 24 04          	mov    %esi,0x4(%esp)
  802238:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80223c:	e9 18 ff ff ff       	jmp    802159 <__umoddi3+0x69>
