
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 60 22 80 00       	push   $0x802260
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 51 0e 00 00       	call   800e9a <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 d8 22 80 00       	push   $0x8022d8
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 88 22 80 00       	push   $0x802288
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 1a 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800076:	e8 15 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  80007b:	e8 10 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800080:	e8 0b 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800085:	e8 06 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  80008a:	e8 01 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  80008f:	e8 fc 0a 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800094:	e8 f7 0a 00 00       	call   800b90 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 b0 22 80 00 	movl   $0x8022b0,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 83 0a 00 00       	call   800b30 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 ac 0a 00 00       	call   800b71 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
		binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 5d 11 00 00       	call   801263 <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 20 0a 00 00       	call   800b30 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 ae 09 00 00       	call   800af3 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 1a 01 00 00       	call   8002a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 53 09 00 00       	call   800af3 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 b0 1d 00 00       	call   801fc0 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 9d 1e 00 00       	call   8020f0 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 00 23 80 00 	movsbl 0x802300(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800271:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800275:	8b 10                	mov    (%eax),%edx
  800277:	3b 50 04             	cmp    0x4(%eax),%edx
  80027a:	73 0a                	jae    800286 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 45 08             	mov    0x8(%ebp),%eax
  800284:	88 02                	mov    %al,(%edx)
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 05 00 00 00       	call   8002a5 <vprintfmt>
	va_end(ap);
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 2c             	sub    $0x2c,%esp
  8002ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b7:	eb 12                	jmp    8002cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	0f 84 42 04 00 00    	je     800703 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	ff d6                	call   *%esi
  8002c8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cb:	83 c7 01             	add    $0x1,%edi
  8002ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d2:	83 f8 25             	cmp    $0x25,%eax
  8002d5:	75 e2                	jne    8002b9 <vprintfmt+0x14>
  8002d7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	eb 07                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8d 47 01             	lea    0x1(%edi),%eax
  800301:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800304:	0f b6 07             	movzbl (%edi),%eax
  800307:	0f b6 d0             	movzbl %al,%edx
  80030a:	83 e8 23             	sub    $0x23,%eax
  80030d:	3c 55                	cmp    $0x55,%al
  80030f:	0f 87 d3 03 00 00    	ja     8006e8 <vprintfmt+0x443>
  800315:	0f b6 c0             	movzbl %al,%eax
  800318:	ff 24 85 40 24 80 00 	jmp    *0x802440(,%eax,4)
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800322:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800326:	eb d6                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	b8 00 00 00 00       	mov    $0x0,%eax
  800330:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800333:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800336:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800340:	83 f9 09             	cmp    $0x9,%ecx
  800343:	77 3f                	ja     800384 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800345:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800348:	eb e9                	jmp    800333 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8b 00                	mov    (%eax),%eax
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8d 40 04             	lea    0x4(%eax),%eax
  800358:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80035e:	eb 2a                	jmp    80038a <vprintfmt+0xe5>
  800360:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800363:	85 c0                	test   %eax,%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	0f 49 d0             	cmovns %eax,%edx
  80036d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800373:	eb 89                	jmp    8002fe <vprintfmt+0x59>
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800378:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037f:	e9 7a ff ff ff       	jmp    8002fe <vprintfmt+0x59>
  800384:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800387:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80038a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038e:	0f 89 6a ff ff ff    	jns    8002fe <vprintfmt+0x59>
				width = precision, precision = -1;
  800394:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800397:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	e9 58 ff ff ff       	jmp    8002fe <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a6:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ac:	e9 4d ff ff ff       	jmp    8002fe <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 78 04             	lea    0x4(%eax),%edi
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	53                   	push   %ebx
  8003bb:	ff 30                	pushl  (%eax)
  8003bd:	ff d6                	call   *%esi
			break;
  8003bf:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c8:	e9 fe fe ff ff       	jmp    8002cb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 78 04             	lea    0x4(%eax),%edi
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	99                   	cltd   
  8003d6:	31 d0                	xor    %edx,%eax
  8003d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003da:	83 f8 0f             	cmp    $0xf,%eax
  8003dd:	7f 0b                	jg     8003ea <vprintfmt+0x145>
  8003df:	8b 14 85 a0 25 80 00 	mov    0x8025a0(,%eax,4),%edx
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	75 1b                	jne    800405 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003ea:	50                   	push   %eax
  8003eb:	68 18 23 80 00       	push   $0x802318
  8003f0:	53                   	push   %ebx
  8003f1:	56                   	push   %esi
  8003f2:	e8 91 fe ff ff       	call   800288 <printfmt>
  8003f7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800400:	e9 c6 fe ff ff       	jmp    8002cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800405:	52                   	push   %edx
  800406:	68 a1 27 80 00       	push   $0x8027a1
  80040b:	53                   	push   %ebx
  80040c:	56                   	push   %esi
  80040d:	e8 76 fe ff ff       	call   800288 <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800415:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041b:	e9 ab fe ff ff       	jmp    8002cb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	83 c0 04             	add    $0x4,%eax
  800426:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042e:	85 ff                	test   %edi,%edi
  800430:	b8 11 23 80 00       	mov    $0x802311,%eax
  800435:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800438:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043c:	0f 8e 94 00 00 00    	jle    8004d6 <vprintfmt+0x231>
  800442:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800446:	0f 84 98 00 00 00    	je     8004e4 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	ff 75 d0             	pushl  -0x30(%ebp)
  800452:	57                   	push   %edi
  800453:	e8 33 03 00 00       	call   80078b <strnlen>
  800458:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045b:	29 c1                	sub    %eax,%ecx
  80045d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800460:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800463:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800467:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	eb 0f                	jmp    800480 <vprintfmt+0x1db>
					putch(padc, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	ff 75 e0             	pushl  -0x20(%ebp)
  800478:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ef 01             	sub    $0x1,%edi
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	85 ff                	test   %edi,%edi
  800482:	7f ed                	jg     800471 <vprintfmt+0x1cc>
  800484:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800487:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80048a:	85 c9                	test   %ecx,%ecx
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	0f 49 c1             	cmovns %ecx,%eax
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 75 08             	mov    %esi,0x8(%ebp)
  800499:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049f:	89 cb                	mov    %ecx,%ebx
  8004a1:	eb 4d                	jmp    8004f0 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a7:	74 1b                	je     8004c4 <vprintfmt+0x21f>
  8004a9:	0f be c0             	movsbl %al,%eax
  8004ac:	83 e8 20             	sub    $0x20,%eax
  8004af:	83 f8 5e             	cmp    $0x5e,%eax
  8004b2:	76 10                	jbe    8004c4 <vprintfmt+0x21f>
					putch('?', putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ba:	6a 3f                	push   $0x3f
  8004bc:	ff 55 08             	call   *0x8(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	eb 0d                	jmp    8004d1 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ca:	52                   	push   %edx
  8004cb:	ff 55 08             	call   *0x8(%ebp)
  8004ce:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d1:	83 eb 01             	sub    $0x1,%ebx
  8004d4:	eb 1a                	jmp    8004f0 <vprintfmt+0x24b>
  8004d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e2:	eb 0c                	jmp    8004f0 <vprintfmt+0x24b>
  8004e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f0:	83 c7 01             	add    $0x1,%edi
  8004f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f7:	0f be d0             	movsbl %al,%edx
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	74 23                	je     800521 <vprintfmt+0x27c>
  8004fe:	85 f6                	test   %esi,%esi
  800500:	78 a1                	js     8004a3 <vprintfmt+0x1fe>
  800502:	83 ee 01             	sub    $0x1,%esi
  800505:	79 9c                	jns    8004a3 <vprintfmt+0x1fe>
  800507:	89 df                	mov    %ebx,%edi
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	eb 18                	jmp    800529 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	6a 20                	push   $0x20
  800517:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800519:	83 ef 01             	sub    $0x1,%edi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb 08                	jmp    800529 <vprintfmt+0x284>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	85 ff                	test   %edi,%edi
  80052b:	7f e4                	jg     800511 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800536:	e9 90 fd ff ff       	jmp    8002cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053b:	83 f9 01             	cmp    $0x1,%ecx
  80053e:	7e 19                	jle    800559 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8b 50 04             	mov    0x4(%eax),%edx
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 40 08             	lea    0x8(%eax),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
  800557:	eb 38                	jmp    800591 <vprintfmt+0x2ec>
	else if (lflag)
  800559:	85 c9                	test   %ecx,%ecx
  80055b:	74 1b                	je     800578 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	eb 19                	jmp    800591 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	89 c1                	mov    %eax,%ecx
  800582:	c1 f9 1f             	sar    $0x1f,%ecx
  800585:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 40 04             	lea    0x4(%eax),%eax
  80058e:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800591:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a0:	0f 89 0e 01 00 00    	jns    8006b4 <vprintfmt+0x40f>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b4:	f7 da                	neg    %edx
  8005b6:	83 d1 00             	adc    $0x0,%ecx
  8005b9:	f7 d9                	neg    %ecx
  8005bb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 ec 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	7e 18                	jle    8005e5 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d5:	8d 40 08             	lea    0x8(%eax),%eax
  8005d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e0:	e9 cf 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	74 1a                	je     800603 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f3:	8d 40 04             	lea    0x4(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fe:	e9 b1 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
  800618:	e9 97 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 58                	push   $0x58
  800623:	ff d6                	call   *%esi
			putch('X', putdat);
  800625:	83 c4 08             	add    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 58                	push   $0x58
  80062b:	ff d6                	call   *%esi
			putch('X', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 58                	push   $0x58
  800633:	ff d6                	call   *%esi
			break;
  800635:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80063b:	e9 8b fc ff ff       	jmp    8002cb <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 30                	push   $0x30
  800646:	ff d6                	call   *%esi
			putch('x', putdat);
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 78                	push   $0x78
  80064e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800663:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800668:	eb 4a                	jmp    8006b4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066a:	83 f9 01             	cmp    $0x1,%ecx
  80066d:	7e 15                	jle    800684 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067d:	b8 10 00 00 00       	mov    $0x10,%eax
  800682:	eb 30                	jmp    8006b4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800684:	85 c9                	test   %ecx,%ecx
  800686:	74 17                	je     80069f <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800698:	b8 10 00 00 00       	mov    $0x10,%eax
  80069d:	eb 15                	jmp    8006b4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bb:	57                   	push   %edi
  8006bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bf:	50                   	push   %eax
  8006c0:	51                   	push   %ecx
  8006c1:	52                   	push   %edx
  8006c2:	89 da                	mov    %ebx,%edx
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	e8 f1 fa ff ff       	call   8001bc <printnum>
			break;
  8006cb:	83 c4 20             	add    $0x20,%esp
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d1:	e9 f5 fb ff ff       	jmp    8002cb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	52                   	push   %edx
  8006db:	ff d6                	call   *%esi
			break;
  8006dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e3:	e9 e3 fb ff ff       	jmp    8002cb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 25                	push   $0x25
  8006ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	eb 03                	jmp    8006f8 <vprintfmt+0x453>
  8006f5:	83 ef 01             	sub    $0x1,%edi
  8006f8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fc:	75 f7                	jne    8006f5 <vprintfmt+0x450>
  8006fe:	e9 c8 fb ff ff       	jmp    8002cb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800706:	5b                   	pop    %ebx
  800707:	5e                   	pop    %esi
  800708:	5f                   	pop    %edi
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 18             	sub    $0x18,%esp
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800717:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 26                	je     800752 <vsnprintf+0x47>
  80072c:	85 d2                	test   %edx,%edx
  80072e:	7e 22                	jle    800752 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800730:	ff 75 14             	pushl  0x14(%ebp)
  800733:	ff 75 10             	pushl  0x10(%ebp)
  800736:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 6b 02 80 00       	push   $0x80026b
  80073f:	e8 61 fb ff ff       	call   8002a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800744:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800747:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	eb 05                	jmp    800757 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	50                   	push   %eax
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	ff 75 08             	pushl  0x8(%ebp)
  80076c:	e8 9a ff ff ff       	call   80070b <vsnprintf>
	va_end(ap);

	return rc;
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	eb 03                	jmp    800783 <strlen+0x10>
		n++;
  800780:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800787:	75 f7                	jne    800780 <strlen+0xd>
		n++;
	return n;
}
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	ba 00 00 00 00       	mov    $0x0,%edx
  800799:	eb 03                	jmp    80079e <strnlen+0x13>
		n++;
  80079b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	39 c2                	cmp    %eax,%edx
  8007a0:	74 08                	je     8007aa <strnlen+0x1f>
  8007a2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a6:	75 f3                	jne    80079b <strnlen+0x10>
  8007a8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b6:	89 c2                	mov    %eax,%edx
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c5:	84 db                	test   %bl,%bl
  8007c7:	75 ef                	jne    8007b8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d3:	53                   	push   %ebx
  8007d4:	e8 9a ff ff ff       	call   800773 <strlen>
  8007d9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	01 d8                	add    %ebx,%eax
  8007e1:	50                   	push   %eax
  8007e2:	e8 c5 ff ff ff       	call   8007ac <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f9:	89 f3                	mov    %esi,%ebx
  8007fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 0f                	jmp    800811 <strncpy+0x23>
		*dst++ = *src;
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	0f b6 01             	movzbl (%ecx),%eax
  800808:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080b:	80 39 01             	cmpb   $0x1,(%ecx)
  80080e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800811:	39 da                	cmp    %ebx,%edx
  800813:	75 ed                	jne    800802 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800815:	89 f0                	mov    %esi,%eax
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800826:	8b 55 10             	mov    0x10(%ebp),%edx
  800829:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 21                	je     800850 <strlcpy+0x35>
  80082f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800833:	89 f2                	mov    %esi,%edx
  800835:	eb 09                	jmp    800840 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800837:	83 c2 01             	add    $0x1,%edx
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800840:	39 c2                	cmp    %eax,%edx
  800842:	74 09                	je     80084d <strlcpy+0x32>
  800844:	0f b6 19             	movzbl (%ecx),%ebx
  800847:	84 db                	test   %bl,%bl
  800849:	75 ec                	jne    800837 <strlcpy+0x1c>
  80084b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800850:	29 f0                	sub    %esi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strcmp+0x11>
		p++, q++;
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800867:	0f b6 01             	movzbl (%ecx),%eax
  80086a:	84 c0                	test   %al,%al
  80086c:	74 04                	je     800872 <strcmp+0x1c>
  80086e:	3a 02                	cmp    (%edx),%al
  800870:	74 ef                	je     800861 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800872:	0f b6 c0             	movzbl %al,%eax
  800875:	0f b6 12             	movzbl (%edx),%edx
  800878:	29 d0                	sub    %edx,%eax
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 c3                	mov    %eax,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strncmp+0x17>
		n--, p++, q++;
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800893:	39 d8                	cmp    %ebx,%eax
  800895:	74 15                	je     8008ac <strncmp+0x30>
  800897:	0f b6 08             	movzbl (%eax),%ecx
  80089a:	84 c9                	test   %cl,%cl
  80089c:	74 04                	je     8008a2 <strncmp+0x26>
  80089e:	3a 0a                	cmp    (%edx),%cl
  8008a0:	74 eb                	je     80088d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 00             	movzbl (%eax),%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
  8008aa:	eb 05                	jmp    8008b1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008be:	eb 07                	jmp    8008c7 <strchr+0x13>
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 0f                	je     8008d3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c4:	83 c0 01             	add    $0x1,%eax
  8008c7:	0f b6 10             	movzbl (%eax),%edx
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	75 f2                	jne    8008c0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008df:	eb 03                	jmp    8008e4 <strfind+0xf>
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 04                	je     8008ef <strfind+0x1a>
  8008eb:	84 d2                	test   %dl,%dl
  8008ed:	75 f2                	jne    8008e1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fd:	85 c9                	test   %ecx,%ecx
  8008ff:	74 36                	je     800937 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800901:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800907:	75 28                	jne    800931 <memset+0x40>
  800909:	f6 c1 03             	test   $0x3,%cl
  80090c:	75 23                	jne    800931 <memset+0x40>
		c &= 0xFF;
  80090e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800912:	89 d3                	mov    %edx,%ebx
  800914:	c1 e3 08             	shl    $0x8,%ebx
  800917:	89 d6                	mov    %edx,%esi
  800919:	c1 e6 18             	shl    $0x18,%esi
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	c1 e0 10             	shl    $0x10,%eax
  800921:	09 f0                	or     %esi,%eax
  800923:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800925:	89 d8                	mov    %ebx,%eax
  800927:	09 d0                	or     %edx,%eax
  800929:	c1 e9 02             	shr    $0x2,%ecx
  80092c:	fc                   	cld    
  80092d:	f3 ab                	rep stos %eax,%es:(%edi)
  80092f:	eb 06                	jmp    800937 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800931:	8b 45 0c             	mov    0xc(%ebp),%eax
  800934:	fc                   	cld    
  800935:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800937:	89 f8                	mov    %edi,%eax
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 75 0c             	mov    0xc(%ebp),%esi
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094c:	39 c6                	cmp    %eax,%esi
  80094e:	73 35                	jae    800985 <memmove+0x47>
  800950:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800953:	39 d0                	cmp    %edx,%eax
  800955:	73 2e                	jae    800985 <memmove+0x47>
		s += n;
		d += n;
  800957:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	09 fe                	or     %edi,%esi
  80095e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800964:	75 13                	jne    800979 <memmove+0x3b>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 0e                	jne    800979 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096b:	83 ef 04             	sub    $0x4,%edi
  80096e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800971:	c1 e9 02             	shr    $0x2,%ecx
  800974:	fd                   	std    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 09                	jmp    800982 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800979:	83 ef 01             	sub    $0x1,%edi
  80097c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097f:	fd                   	std    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800982:	fc                   	cld    
  800983:	eb 1d                	jmp    8009a2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	89 f2                	mov    %esi,%edx
  800987:	09 c2                	or     %eax,%edx
  800989:	f6 c2 03             	test   $0x3,%dl
  80098c:	75 0f                	jne    80099d <memmove+0x5f>
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 0a                	jne    80099d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800993:	c1 e9 02             	shr    $0x2,%ecx
  800996:	89 c7                	mov    %eax,%edi
  800998:	fc                   	cld    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 05                	jmp    8009a2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a9:	ff 75 10             	pushl  0x10(%ebp)
  8009ac:	ff 75 0c             	pushl  0xc(%ebp)
  8009af:	ff 75 08             	pushl  0x8(%ebp)
  8009b2:	e8 87 ff ff ff       	call   80093e <memmove>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	89 c6                	mov    %eax,%esi
  8009c6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c9:	eb 1a                	jmp    8009e5 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cb:	0f b6 08             	movzbl (%eax),%ecx
  8009ce:	0f b6 1a             	movzbl (%edx),%ebx
  8009d1:	38 d9                	cmp    %bl,%cl
  8009d3:	74 0a                	je     8009df <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d5:	0f b6 c1             	movzbl %cl,%eax
  8009d8:	0f b6 db             	movzbl %bl,%ebx
  8009db:	29 d8                	sub    %ebx,%eax
  8009dd:	eb 0f                	jmp    8009ee <memcmp+0x35>
		s1++, s2++;
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e5:	39 f0                	cmp    %esi,%eax
  8009e7:	75 e2                	jne    8009cb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f9:	89 c1                	mov    %eax,%ecx
  8009fb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fe:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a02:	eb 0a                	jmp    800a0e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a04:	0f b6 10             	movzbl (%eax),%edx
  800a07:	39 da                	cmp    %ebx,%edx
  800a09:	74 07                	je     800a12 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	39 c8                	cmp    %ecx,%eax
  800a10:	72 f2                	jb     800a04 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a12:	5b                   	pop    %ebx
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	57                   	push   %edi
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a21:	eb 03                	jmp    800a26 <strtol+0x11>
		s++;
  800a23:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a26:	0f b6 01             	movzbl (%ecx),%eax
  800a29:	3c 20                	cmp    $0x20,%al
  800a2b:	74 f6                	je     800a23 <strtol+0xe>
  800a2d:	3c 09                	cmp    $0x9,%al
  800a2f:	74 f2                	je     800a23 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a31:	3c 2b                	cmp    $0x2b,%al
  800a33:	75 0a                	jne    800a3f <strtol+0x2a>
		s++;
  800a35:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3d:	eb 11                	jmp    800a50 <strtol+0x3b>
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a44:	3c 2d                	cmp    $0x2d,%al
  800a46:	75 08                	jne    800a50 <strtol+0x3b>
		s++, neg = 1;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a50:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a56:	75 15                	jne    800a6d <strtol+0x58>
  800a58:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5b:	75 10                	jne    800a6d <strtol+0x58>
  800a5d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a61:	75 7c                	jne    800adf <strtol+0xca>
		s += 2, base = 16;
  800a63:	83 c1 02             	add    $0x2,%ecx
  800a66:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6b:	eb 16                	jmp    800a83 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6d:	85 db                	test   %ebx,%ebx
  800a6f:	75 12                	jne    800a83 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a71:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a76:	80 39 30             	cmpb   $0x30,(%ecx)
  800a79:	75 08                	jne    800a83 <strtol+0x6e>
		s++, base = 8;
  800a7b:	83 c1 01             	add    $0x1,%ecx
  800a7e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8b:	0f b6 11             	movzbl (%ecx),%edx
  800a8e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 09             	cmp    $0x9,%bl
  800a96:	77 08                	ja     800aa0 <strtol+0x8b>
			dig = *s - '0';
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 30             	sub    $0x30,%edx
  800a9e:	eb 22                	jmp    800ac2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 08                	ja     800ab2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 57             	sub    $0x57,%edx
  800ab0:	eb 10                	jmp    800ac2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 16                	ja     800ad2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac5:	7d 0b                	jge    800ad2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac7:	83 c1 01             	add    $0x1,%ecx
  800aca:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ace:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad0:	eb b9                	jmp    800a8b <strtol+0x76>

	if (endptr)
  800ad2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad6:	74 0d                	je     800ae5 <strtol+0xd0>
		*endptr = (char *) s;
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	89 0e                	mov    %ecx,(%esi)
  800add:	eb 06                	jmp    800ae5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	74 98                	je     800a7b <strtol+0x66>
  800ae3:	eb 9e                	jmp    800a83 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	f7 da                	neg    %edx
  800ae9:	85 ff                	test   %edi,%edi
  800aeb:	0f 45 c2             	cmovne %edx,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b01:	8b 55 08             	mov    0x8(%ebp),%edx
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	89 c6                	mov    %eax,%esi
  800b0a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	89 cb                	mov    %ecx,%ebx
  800b48:	89 cf                	mov    %ecx,%edi
  800b4a:	89 ce                	mov    %ecx,%esi
  800b4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	7e 17                	jle    800b69 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	50                   	push   %eax
  800b56:	6a 03                	push   $0x3
  800b58:	68 ff 25 80 00       	push   $0x8025ff
  800b5d:	6a 23                	push   $0x23
  800b5f:	68 1c 26 80 00       	push   $0x80261c
  800b64:	e8 1f 12 00 00       	call   801d88 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b81:	89 d1                	mov    %edx,%ecx
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	89 d7                	mov    %edx,%edi
  800b87:	89 d6                	mov    %edx,%esi
  800b89:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_yield>:

void
sys_yield(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	be 00 00 00 00       	mov    $0x0,%esi
  800bbd:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcb:	89 f7                	mov    %esi,%edi
  800bcd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 17                	jle    800bea <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 04                	push   $0x4
  800bd9:	68 ff 25 80 00       	push   $0x8025ff
  800bde:	6a 23                	push   $0x23
  800be0:	68 1c 26 80 00       	push   $0x80261c
  800be5:	e8 9e 11 00 00       	call   801d88 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	b8 05 00 00 00       	mov    $0x5,%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c09:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 17                	jle    800c2c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 05                	push   $0x5
  800c1b:	68 ff 25 80 00       	push   $0x8025ff
  800c20:	6a 23                	push   $0x23
  800c22:	68 1c 26 80 00       	push   $0x80261c
  800c27:	e8 5c 11 00 00       	call   801d88 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	b8 06 00 00 00       	mov    $0x6,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 17                	jle    800c6e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 06                	push   $0x6
  800c5d:	68 ff 25 80 00       	push   $0x8025ff
  800c62:	6a 23                	push   $0x23
  800c64:	68 1c 26 80 00       	push   $0x80261c
  800c69:	e8 1a 11 00 00       	call   801d88 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c84:	b8 08 00 00 00       	mov    $0x8,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7e 17                	jle    800cb0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	50                   	push   %eax
  800c9d:	6a 08                	push   $0x8
  800c9f:	68 ff 25 80 00       	push   $0x8025ff
  800ca4:	6a 23                	push   $0x23
  800ca6:	68 1c 26 80 00       	push   $0x80261c
  800cab:	e8 d8 10 00 00       	call   801d88 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  800cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc6:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 17                	jle    800cf2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 09                	push   $0x9
  800ce1:	68 ff 25 80 00       	push   $0x8025ff
  800ce6:	6a 23                	push   $0x23
  800ce8:	68 1c 26 80 00       	push   $0x80261c
  800ced:	e8 96 10 00 00       	call   801d88 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 0a                	push   $0xa
  800d23:	68 ff 25 80 00       	push   $0x8025ff
  800d28:	6a 23                	push   $0x23
  800d2a:	68 1c 26 80 00       	push   $0x80261c
  800d2f:	e8 54 10 00 00       	call   801d88 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	be 00 00 00 00       	mov    $0x0,%esi
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d58:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 cb                	mov    %ecx,%ebx
  800d77:	89 cf                	mov    %ecx,%edi
  800d79:	89 ce                	mov    %ecx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 0d                	push   $0xd
  800d87:	68 ff 25 80 00       	push   $0x8025ff
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 1c 26 80 00       	push   $0x80261c
  800d93:	e8 f0 0f 00 00       	call   801d88 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <pgfault>:
// map in our own private writable copy.
// 进程页错误处理函数 -- 复制一份需要写的页出来写
// 分配一个物理页，将要写的物理页拷贝到新的物理页，映射原虚拟地址到新的物理页(交换)
static void
pgfault(struct UTrapframe *utf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
    int r;
    // 发生页错误的地址
    void *addr = (void *) utf->utf_fault_va;
  800da8:	8b 18                	mov    (%eax),%ebx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	// 检查页错误是否写错误以及需要写的页是否是COW页
	if ((err & FEC_WR) == 0 || (uvpt[PGNUM(addr)] & PTE_COW) == 0)
  800daa:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dae:	74 11                	je     800dc1 <pgfault+0x21>
  800db0:	89 d8                	mov    %ebx,%eax
  800db2:	c1 e8 0c             	shr    $0xc,%eax
  800db5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dbc:	f6 c4 08             	test   $0x8,%ah
  800dbf:	75 14                	jne    800dd5 <pgfault+0x35>
		panic("pgfault: it's not writable or attempt to access a non-cow page!");
  800dc1:	83 ec 04             	sub    $0x4,%esp
  800dc4:	68 2c 26 80 00       	push   $0x80262c
  800dc9:	6a 1f                	push   $0x1f
  800dcb:	68 8f 26 80 00       	push   $0x80268f
  800dd0:	e8 b3 0f 00 00       	call   801d88 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	envid_t envid = sys_getenvid();
  800dd5:	e8 97 fd ff ff       	call   800b71 <sys_getenvid>
  800dda:	89 c6                	mov    %eax,%esi
	
    // 分配一个物理页，并映射到临时虚拟地址PFTEMP
    if ((r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800ddc:	83 ec 04             	sub    $0x4,%esp
  800ddf:	6a 07                	push   $0x7
  800de1:	68 00 f0 7f 00       	push   $0x7ff000
  800de6:	50                   	push   %eax
  800de7:	e8 c3 fd ff ff       	call   800baf <sys_page_alloc>
  800dec:	83 c4 10             	add    $0x10,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	79 12                	jns    800e05 <pgfault+0x65>
        panic("pgfault: page allocation failed %e", r);
  800df3:	50                   	push   %eax
  800df4:	68 6c 26 80 00       	push   $0x80266c
  800df9:	6a 2c                	push   $0x2c
  800dfb:	68 8f 26 80 00       	push   $0x80268f
  800e00:	e8 83 0f 00 00       	call   801d88 <_panic>
    
    addr = ROUNDDOWN(addr, PGSIZE);
  800e05:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
    memmove(PFTEMP, addr, PGSIZE);
  800e0b:	83 ec 04             	sub    $0x4,%esp
  800e0e:	68 00 10 00 00       	push   $0x1000
  800e13:	53                   	push   %ebx
  800e14:	68 00 f0 7f 00       	push   $0x7ff000
  800e19:	e8 20 fb ff ff       	call   80093e <memmove>
    // 解除虚拟地址的映射
    if ((r = sys_page_unmap(envid, addr)) < 0)
  800e1e:	83 c4 08             	add    $0x8,%esp
  800e21:	53                   	push   %ebx
  800e22:	56                   	push   %esi
  800e23:	e8 0c fe ff ff       	call   800c34 <sys_page_unmap>
  800e28:	83 c4 10             	add    $0x10,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	79 12                	jns    800e41 <pgfault+0xa1>
        panic("pgfault: page unmap failed %e", r);
  800e2f:	50                   	push   %eax
  800e30:	68 9a 26 80 00       	push   $0x80269a
  800e35:	6a 32                	push   $0x32
  800e37:	68 8f 26 80 00       	push   $0x80268f
  800e3c:	e8 47 0f 00 00       	call   801d88 <_panic>
    // 将虚拟地址映射到新的物理页
    if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e41:	83 ec 0c             	sub    $0xc,%esp
  800e44:	6a 07                	push   $0x7
  800e46:	53                   	push   %ebx
  800e47:	56                   	push   %esi
  800e48:	68 00 f0 7f 00       	push   $0x7ff000
  800e4d:	56                   	push   %esi
  800e4e:	e8 9f fd ff ff       	call   800bf2 <sys_page_map>
  800e53:	83 c4 20             	add    $0x20,%esp
  800e56:	85 c0                	test   %eax,%eax
  800e58:	79 12                	jns    800e6c <pgfault+0xcc>
        panic("pgfault: page map failed %e", r);
  800e5a:	50                   	push   %eax
  800e5b:	68 b8 26 80 00       	push   $0x8026b8
  800e60:	6a 35                	push   $0x35
  800e62:	68 8f 26 80 00       	push   $0x80268f
  800e67:	e8 1c 0f 00 00       	call   801d88 <_panic>
    // 解除 PFTEMP 的映射
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e6c:	83 ec 08             	sub    $0x8,%esp
  800e6f:	68 00 f0 7f 00       	push   $0x7ff000
  800e74:	56                   	push   %esi
  800e75:	e8 ba fd ff ff       	call   800c34 <sys_page_unmap>
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	85 c0                	test   %eax,%eax
  800e7f:	79 12                	jns    800e93 <pgfault+0xf3>
        panic("pgfault: page unmap failed %e", r);
  800e81:	50                   	push   %eax
  800e82:	68 9a 26 80 00       	push   $0x80269a
  800e87:	6a 38                	push   $0x38
  800e89:	68 8f 26 80 00       	push   $0x80268f
  800e8e:	e8 f5 0e 00 00       	call   801d88 <_panic>
	//panic("pgfault not implemented");
}
  800e93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//   
envid_t
fork(void)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	57                   	push   %edi
  800e9e:	56                   	push   %esi
  800e9f:	53                   	push   %ebx
  800ea0:	83 ec 28             	sub    $0x28,%esp
	envid_t envid;
	uint8_t *addr, *end_addr;
	int ret;
	
	// 注册pgfault函数(生成页错误处理函数)
	set_pgfault_handler(&pgfault);
  800ea3:	68 a0 0d 80 00       	push   $0x800da0
  800ea8:	e8 21 0f 00 00       	call   801dce <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ead:	b8 07 00 00 00       	mov    $0x7,%eax
  800eb2:	cd 30                	int    $0x30
  800eb4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	0f 88 38 01 00 00    	js     800ffa <fork+0x160>
  800ec2:	89 c7                	mov    %eax,%edi
  800ec4:	bb 00 00 00 00       	mov    $0x0,%ebx
		return envid;
	if (envid == 0) {
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	75 21                	jne    800eee <fork+0x54>
		// We are the child
		thisenv = &envs[ENVX(sys_getenvid())];
  800ecd:	e8 9f fc ff ff       	call   800b71 <sys_getenvid>
  800ed2:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800eda:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800edf:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800ee4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee9:	e9 86 01 00 00       	jmp    801074 <fork+0x1da>
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
  800eee:	89 d8                	mov    %ebx,%eax
  800ef0:	c1 e8 16             	shr    $0x16,%eax
  800ef3:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800efa:	a8 01                	test   $0x1,%al
  800efc:	0f 84 90 00 00 00    	je     800f92 <fork+0xf8>
  800f02:	89 d8                	mov    %ebx,%eax
  800f04:	c1 e8 0c             	shr    $0xc,%eax
  800f07:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f0e:	f6 c2 01             	test   $0x1,%dl
  800f11:	74 7f                	je     800f92 <fork+0xf8>
static int
duppage(envid_t envid, unsigned pn)
{
	int r;
	// 求第 pn 页对应的虚拟地址
	void *addr = (void *) (pn * PGSIZE);
  800f13:	89 c6                	mov    %eax,%esi
  800f15:	c1 e6 0c             	shl    $0xc,%esi
	uint32_t perm = PTE_U | PTE_P;

	if (uvpt[pn] & PTE_SHARE) {  // Lab 5
  800f18:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f1f:	f6 c6 04             	test   $0x4,%dh
  800f22:	74 33                	je     800f57 <fork+0xbd>
        perm = uvpt[pn] & PTE_SYSCALL;
  800f24:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
    	if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  800f2b:	83 ec 0c             	sub    $0xc,%esp
  800f2e:	25 07 0e 00 00       	and    $0xe07,%eax
  800f33:	50                   	push   %eax
  800f34:	56                   	push   %esi
  800f35:	57                   	push   %edi
  800f36:	56                   	push   %esi
  800f37:	6a 00                	push   $0x0
  800f39:	e8 b4 fc ff ff       	call   800bf2 <sys_page_map>
  800f3e:	83 c4 20             	add    $0x20,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	79 4d                	jns    800f92 <fork+0xf8>
		    panic("sys_page_map: %e", r);
  800f45:	50                   	push   %eax
  800f46:	68 d4 26 80 00       	push   $0x8026d4
  800f4b:	6a 54                	push   $0x54
  800f4d:	68 8f 26 80 00       	push   $0x80268f
  800f52:	e8 31 0e 00 00       	call   801d88 <_panic>
        return 0;
    }
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
  800f57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f5e:	a9 02 08 00 00       	test   $0x802,%eax
  800f63:	0f 85 c6 00 00 00    	jne    80102f <fork+0x195>
  800f69:	e9 e3 00 00 00       	jmp    801051 <fork+0x1b7>
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800f6e:	50                   	push   %eax
  800f6f:	68 d4 26 80 00       	push   $0x8026d4
  800f74:	6a 5d                	push   $0x5d
  800f76:	68 8f 26 80 00       	push   $0x80268f
  800f7b:	e8 08 0e 00 00       	call   801d88 <_panic>
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
		panic("sys_page_map: %e", r);
  800f80:	50                   	push   %eax
  800f81:	68 d4 26 80 00       	push   $0x8026d4
  800f86:	6a 64                	push   $0x64
  800f88:	68 8f 26 80 00       	push   $0x80268f
  800f8d:	e8 f6 0d 00 00       	call   801d88 <_panic>
		return 0;
	}
	
	// 一一映射页表
	end_addr = (uint8_t *) (UXSTACKTOP - PGSIZE);
	for (addr = 0; addr < end_addr; addr += PGSIZE) {	
  800f92:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f98:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  800f9e:	0f 85 4a ff ff ff    	jne    800eee <fork+0x54>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P))
			duppage(envid, PGNUM(addr));
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
  800fa4:	83 ec 04             	sub    $0x4,%esp
  800fa7:	6a 07                	push   $0x7
  800fa9:	68 00 f0 bf ee       	push   $0xeebff000
  800fae:	8b 7d e0             	mov    -0x20(%ebp),%edi
  800fb1:	57                   	push   %edi
  800fb2:	e8 f8 fb ff ff       	call   800baf <sys_page_alloc>
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800fb7:	83 c4 10             	add    $0x10,%esp
		return ret;
  800fba:	89 c2                	mov    %eax,%edx
	}

	//为子进程分配异常栈
	ret = sys_page_alloc(envid, 
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	0f 88 b0 00 00 00    	js     801074 <fork+0x1da>
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800fc4:	a1 04 40 80 00       	mov    0x804004,%eax
  800fc9:	8b 40 64             	mov    0x64(%eax),%eax
  800fcc:	83 ec 08             	sub    $0x8,%esp
  800fcf:	50                   	push   %eax
  800fd0:	57                   	push   %edi
  800fd1:	e8 24 fd ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
  800fd6:	83 c4 10             	add    $0x10,%esp
		return ret;
  800fd9:	89 c2                	mov    %eax,%edx
		(void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P); 
	if (ret < 0)
		return ret;
	
	// 为子进程设置页错误处理句柄
	if ((ret = sys_env_set_pgfault_upcall(envid, thisenv->env_pgfault_upcall)) < 0)
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	0f 88 91 00 00 00    	js     801074 <fork+0x1da>
		return ret;
	
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800fe3:	83 ec 08             	sub    $0x8,%esp
  800fe6:	6a 02                	push   $0x2
  800fe8:	57                   	push   %edi
  800fe9:	e8 88 fc ff ff       	call   800c76 <sys_env_set_status>
  800fee:	83 c4 10             	add    $0x10,%esp
		return ret;

	return envid;
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	89 fa                	mov    %edi,%edx
  800ff5:	0f 48 d0             	cmovs  %eax,%edx
  800ff8:	eb 7a                	jmp    801074 <fork+0x1da>
	set_pgfault_handler(&pgfault);
	
	//系统调用 -- 创建一个新的进程
	envid = sys_exofork();
	if (envid < 0) 
		return envid;
  800ffa:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ffd:	eb 75                	jmp    801074 <fork+0x1da>
	
	if (!(perm & PTE_COW))
		return 0;
	
	//父进程也修改权限(这里重新映射一遍达到权限修改的目的)
	if ((r = sys_page_map(sys_getenvid(), addr, sys_getenvid(), addr, perm)) < 0)
  800fff:	e8 6d fb ff ff       	call   800b71 <sys_getenvid>
  801004:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801007:	e8 65 fb ff ff       	call   800b71 <sys_getenvid>
  80100c:	83 ec 0c             	sub    $0xc,%esp
  80100f:	68 05 08 00 00       	push   $0x805
  801014:	56                   	push   %esi
  801015:	ff 75 e4             	pushl  -0x1c(%ebp)
  801018:	56                   	push   %esi
  801019:	50                   	push   %eax
  80101a:	e8 d3 fb ff ff       	call   800bf2 <sys_page_map>
  80101f:	83 c4 20             	add    $0x20,%esp
  801022:	85 c0                	test   %eax,%eax
  801024:	0f 89 68 ff ff ff    	jns    800f92 <fork+0xf8>
  80102a:	e9 51 ff ff ff       	jmp    800f80 <fork+0xe6>
	// LAB 4: Your code here.
	if (uvpt[pn] & (PTE_W | PTE_COW)) 
		perm |= PTE_COW;
	
	// 映射到子进程
	if ((r = sys_page_map(sys_getenvid(), addr, envid, addr, perm)) < 0)
  80102f:	e8 3d fb ff ff       	call   800b71 <sys_getenvid>
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	68 05 08 00 00       	push   $0x805
  80103c:	56                   	push   %esi
  80103d:	57                   	push   %edi
  80103e:	56                   	push   %esi
  80103f:	50                   	push   %eax
  801040:	e8 ad fb ff ff       	call   800bf2 <sys_page_map>
  801045:	83 c4 20             	add    $0x20,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	79 b3                	jns    800fff <fork+0x165>
  80104c:	e9 1d ff ff ff       	jmp    800f6e <fork+0xd4>
  801051:	e8 1b fb ff ff       	call   800b71 <sys_getenvid>
  801056:	83 ec 0c             	sub    $0xc,%esp
  801059:	6a 05                	push   $0x5
  80105b:	56                   	push   %esi
  80105c:	57                   	push   %edi
  80105d:	56                   	push   %esi
  80105e:	50                   	push   %eax
  80105f:	e8 8e fb ff ff       	call   800bf2 <sys_page_map>
  801064:	83 c4 20             	add    $0x20,%esp
  801067:	85 c0                	test   %eax,%eax
  801069:	0f 89 23 ff ff ff    	jns    800f92 <fork+0xf8>
  80106f:	e9 fa fe ff ff       	jmp    800f6e <fork+0xd4>
	// 标记子进程为runable
	if ((ret = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
		return ret;

	return envid;
}
  801074:	89 d0                	mov    %edx,%eax
  801076:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801079:	5b                   	pop    %ebx
  80107a:	5e                   	pop    %esi
  80107b:	5f                   	pop    %edi
  80107c:	5d                   	pop    %ebp
  80107d:	c3                   	ret    

0080107e <sfork>:

// Challenge!
int
sfork(void)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801084:	68 e5 26 80 00       	push   $0x8026e5
  801089:	68 ac 00 00 00       	push   $0xac
  80108e:	68 8f 26 80 00       	push   $0x80268f
  801093:	e8 f0 0c 00 00       	call   801d88 <_panic>

00801098 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80109b:	8b 45 08             	mov    0x8(%ebp),%eax
  80109e:	05 00 00 00 30       	add    $0x30000000,%eax
  8010a3:	c1 e8 0c             	shr    $0xc,%eax
}
  8010a6:	5d                   	pop    %ebp
  8010a7:	c3                   	ret    

008010a8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010a8:	55                   	push   %ebp
  8010a9:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8010ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8010b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010b8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    

008010bf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ca:	89 c2                	mov    %eax,%edx
  8010cc:	c1 ea 16             	shr    $0x16,%edx
  8010cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d6:	f6 c2 01             	test   $0x1,%dl
  8010d9:	74 11                	je     8010ec <fd_alloc+0x2d>
  8010db:	89 c2                	mov    %eax,%edx
  8010dd:	c1 ea 0c             	shr    $0xc,%edx
  8010e0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e7:	f6 c2 01             	test   $0x1,%dl
  8010ea:	75 09                	jne    8010f5 <fd_alloc+0x36>
			*fd_store = fd;
  8010ec:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f3:	eb 17                	jmp    80110c <fd_alloc+0x4d>
  8010f5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010fa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ff:	75 c9                	jne    8010ca <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801101:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801107:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801114:	83 f8 1f             	cmp    $0x1f,%eax
  801117:	77 36                	ja     80114f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801119:	c1 e0 0c             	shl    $0xc,%eax
  80111c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801121:	89 c2                	mov    %eax,%edx
  801123:	c1 ea 16             	shr    $0x16,%edx
  801126:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112d:	f6 c2 01             	test   $0x1,%dl
  801130:	74 24                	je     801156 <fd_lookup+0x48>
  801132:	89 c2                	mov    %eax,%edx
  801134:	c1 ea 0c             	shr    $0xc,%edx
  801137:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113e:	f6 c2 01             	test   $0x1,%dl
  801141:	74 1a                	je     80115d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801143:	8b 55 0c             	mov    0xc(%ebp),%edx
  801146:	89 02                	mov    %eax,(%edx)
	return 0;
  801148:	b8 00 00 00 00       	mov    $0x0,%eax
  80114d:	eb 13                	jmp    801162 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80114f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801154:	eb 0c                	jmp    801162 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801156:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80115b:	eb 05                	jmp    801162 <fd_lookup+0x54>
  80115d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	83 ec 08             	sub    $0x8,%esp
  80116a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116d:	ba 78 27 80 00       	mov    $0x802778,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801172:	eb 13                	jmp    801187 <dev_lookup+0x23>
  801174:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801177:	39 08                	cmp    %ecx,(%eax)
  801179:	75 0c                	jne    801187 <dev_lookup+0x23>
			*dev = devtab[i];
  80117b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801180:	b8 00 00 00 00       	mov    $0x0,%eax
  801185:	eb 2e                	jmp    8011b5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801187:	8b 02                	mov    (%edx),%eax
  801189:	85 c0                	test   %eax,%eax
  80118b:	75 e7                	jne    801174 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80118d:	a1 04 40 80 00       	mov    0x804004,%eax
  801192:	8b 40 48             	mov    0x48(%eax),%eax
  801195:	83 ec 04             	sub    $0x4,%esp
  801198:	51                   	push   %ecx
  801199:	50                   	push   %eax
  80119a:	68 fc 26 80 00       	push   $0x8026fc
  80119f:	e8 04 f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  8011a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011a7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8011ad:	83 c4 10             	add    $0x10,%esp
  8011b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011b5:	c9                   	leave  
  8011b6:	c3                   	ret    

008011b7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 10             	sub    $0x10,%esp
  8011bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011cf:	c1 e8 0c             	shr    $0xc,%eax
  8011d2:	50                   	push   %eax
  8011d3:	e8 36 ff ff ff       	call   80110e <fd_lookup>
  8011d8:	83 c4 08             	add    $0x8,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	78 05                	js     8011e4 <fd_close+0x2d>
	    || fd != fd2)
  8011df:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011e2:	74 0c                	je     8011f0 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011e4:	84 db                	test   %bl,%bl
  8011e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011eb:	0f 44 c2             	cmove  %edx,%eax
  8011ee:	eb 41                	jmp    801231 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011f0:	83 ec 08             	sub    $0x8,%esp
  8011f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f6:	50                   	push   %eax
  8011f7:	ff 36                	pushl  (%esi)
  8011f9:	e8 66 ff ff ff       	call   801164 <dev_lookup>
  8011fe:	89 c3                	mov    %eax,%ebx
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	85 c0                	test   %eax,%eax
  801205:	78 1a                	js     801221 <fd_close+0x6a>
		if (dev->dev_close)
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80120d:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801212:	85 c0                	test   %eax,%eax
  801214:	74 0b                	je     801221 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	56                   	push   %esi
  80121a:	ff d0                	call   *%eax
  80121c:	89 c3                	mov    %eax,%ebx
  80121e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801221:	83 ec 08             	sub    $0x8,%esp
  801224:	56                   	push   %esi
  801225:	6a 00                	push   $0x0
  801227:	e8 08 fa ff ff       	call   800c34 <sys_page_unmap>
	return r;
  80122c:	83 c4 10             	add    $0x10,%esp
  80122f:	89 d8                	mov    %ebx,%eax
}
  801231:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801234:	5b                   	pop    %ebx
  801235:	5e                   	pop    %esi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801241:	50                   	push   %eax
  801242:	ff 75 08             	pushl  0x8(%ebp)
  801245:	e8 c4 fe ff ff       	call   80110e <fd_lookup>
  80124a:	83 c4 08             	add    $0x8,%esp
  80124d:	85 c0                	test   %eax,%eax
  80124f:	78 10                	js     801261 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801251:	83 ec 08             	sub    $0x8,%esp
  801254:	6a 01                	push   $0x1
  801256:	ff 75 f4             	pushl  -0xc(%ebp)
  801259:	e8 59 ff ff ff       	call   8011b7 <fd_close>
  80125e:	83 c4 10             	add    $0x10,%esp
}
  801261:	c9                   	leave  
  801262:	c3                   	ret    

00801263 <close_all>:

void
close_all(void)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	53                   	push   %ebx
  801267:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80126a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80126f:	83 ec 0c             	sub    $0xc,%esp
  801272:	53                   	push   %ebx
  801273:	e8 c0 ff ff ff       	call   801238 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801278:	83 c3 01             	add    $0x1,%ebx
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	83 fb 20             	cmp    $0x20,%ebx
  801281:	75 ec                	jne    80126f <close_all+0xc>
		close(i);
}
  801283:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801286:	c9                   	leave  
  801287:	c3                   	ret    

00801288 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801288:	55                   	push   %ebp
  801289:	89 e5                	mov    %esp,%ebp
  80128b:	57                   	push   %edi
  80128c:	56                   	push   %esi
  80128d:	53                   	push   %ebx
  80128e:	83 ec 2c             	sub    $0x2c,%esp
  801291:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801294:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801297:	50                   	push   %eax
  801298:	ff 75 08             	pushl  0x8(%ebp)
  80129b:	e8 6e fe ff ff       	call   80110e <fd_lookup>
  8012a0:	83 c4 08             	add    $0x8,%esp
  8012a3:	85 c0                	test   %eax,%eax
  8012a5:	0f 88 c1 00 00 00    	js     80136c <dup+0xe4>
		return r;
	close(newfdnum);
  8012ab:	83 ec 0c             	sub    $0xc,%esp
  8012ae:	56                   	push   %esi
  8012af:	e8 84 ff ff ff       	call   801238 <close>

	newfd = INDEX2FD(newfdnum);
  8012b4:	89 f3                	mov    %esi,%ebx
  8012b6:	c1 e3 0c             	shl    $0xc,%ebx
  8012b9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012bf:	83 c4 04             	add    $0x4,%esp
  8012c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012c5:	e8 de fd ff ff       	call   8010a8 <fd2data>
  8012ca:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012cc:	89 1c 24             	mov    %ebx,(%esp)
  8012cf:	e8 d4 fd ff ff       	call   8010a8 <fd2data>
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012da:	89 f8                	mov    %edi,%eax
  8012dc:	c1 e8 16             	shr    $0x16,%eax
  8012df:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012e6:	a8 01                	test   $0x1,%al
  8012e8:	74 37                	je     801321 <dup+0x99>
  8012ea:	89 f8                	mov    %edi,%eax
  8012ec:	c1 e8 0c             	shr    $0xc,%eax
  8012ef:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012f6:	f6 c2 01             	test   $0x1,%dl
  8012f9:	74 26                	je     801321 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012fb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801302:	83 ec 0c             	sub    $0xc,%esp
  801305:	25 07 0e 00 00       	and    $0xe07,%eax
  80130a:	50                   	push   %eax
  80130b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80130e:	6a 00                	push   $0x0
  801310:	57                   	push   %edi
  801311:	6a 00                	push   $0x0
  801313:	e8 da f8 ff ff       	call   800bf2 <sys_page_map>
  801318:	89 c7                	mov    %eax,%edi
  80131a:	83 c4 20             	add    $0x20,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 2e                	js     80134f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801321:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801324:	89 d0                	mov    %edx,%eax
  801326:	c1 e8 0c             	shr    $0xc,%eax
  801329:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801330:	83 ec 0c             	sub    $0xc,%esp
  801333:	25 07 0e 00 00       	and    $0xe07,%eax
  801338:	50                   	push   %eax
  801339:	53                   	push   %ebx
  80133a:	6a 00                	push   $0x0
  80133c:	52                   	push   %edx
  80133d:	6a 00                	push   $0x0
  80133f:	e8 ae f8 ff ff       	call   800bf2 <sys_page_map>
  801344:	89 c7                	mov    %eax,%edi
  801346:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801349:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80134b:	85 ff                	test   %edi,%edi
  80134d:	79 1d                	jns    80136c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	53                   	push   %ebx
  801353:	6a 00                	push   $0x0
  801355:	e8 da f8 ff ff       	call   800c34 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80135a:	83 c4 08             	add    $0x8,%esp
  80135d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801360:	6a 00                	push   $0x0
  801362:	e8 cd f8 ff ff       	call   800c34 <sys_page_unmap>
	return r;
  801367:	83 c4 10             	add    $0x10,%esp
  80136a:	89 f8                	mov    %edi,%eax
}
  80136c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80136f:	5b                   	pop    %ebx
  801370:	5e                   	pop    %esi
  801371:	5f                   	pop    %edi
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    

00801374 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801374:	55                   	push   %ebp
  801375:	89 e5                	mov    %esp,%ebp
  801377:	53                   	push   %ebx
  801378:	83 ec 14             	sub    $0x14,%esp
  80137b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801381:	50                   	push   %eax
  801382:	53                   	push   %ebx
  801383:	e8 86 fd ff ff       	call   80110e <fd_lookup>
  801388:	83 c4 08             	add    $0x8,%esp
  80138b:	89 c2                	mov    %eax,%edx
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 6d                	js     8013fe <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801391:	83 ec 08             	sub    $0x8,%esp
  801394:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801397:	50                   	push   %eax
  801398:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139b:	ff 30                	pushl  (%eax)
  80139d:	e8 c2 fd ff ff       	call   801164 <dev_lookup>
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 4c                	js     8013f5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013ac:	8b 42 08             	mov    0x8(%edx),%eax
  8013af:	83 e0 03             	and    $0x3,%eax
  8013b2:	83 f8 01             	cmp    $0x1,%eax
  8013b5:	75 21                	jne    8013d8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013b7:	a1 04 40 80 00       	mov    0x804004,%eax
  8013bc:	8b 40 48             	mov    0x48(%eax),%eax
  8013bf:	83 ec 04             	sub    $0x4,%esp
  8013c2:	53                   	push   %ebx
  8013c3:	50                   	push   %eax
  8013c4:	68 3d 27 80 00       	push   $0x80273d
  8013c9:	e8 da ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8013ce:	83 c4 10             	add    $0x10,%esp
  8013d1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013d6:	eb 26                	jmp    8013fe <read+0x8a>
	}
	if (!dev->dev_read)
  8013d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013db:	8b 40 08             	mov    0x8(%eax),%eax
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	74 17                	je     8013f9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013e2:	83 ec 04             	sub    $0x4,%esp
  8013e5:	ff 75 10             	pushl  0x10(%ebp)
  8013e8:	ff 75 0c             	pushl  0xc(%ebp)
  8013eb:	52                   	push   %edx
  8013ec:	ff d0                	call   *%eax
  8013ee:	89 c2                	mov    %eax,%edx
  8013f0:	83 c4 10             	add    $0x10,%esp
  8013f3:	eb 09                	jmp    8013fe <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	89 c2                	mov    %eax,%edx
  8013f7:	eb 05                	jmp    8013fe <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013fe:	89 d0                	mov    %edx,%eax
  801400:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801405:	55                   	push   %ebp
  801406:	89 e5                	mov    %esp,%ebp
  801408:	57                   	push   %edi
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
  80140b:	83 ec 0c             	sub    $0xc,%esp
  80140e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801411:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801414:	bb 00 00 00 00       	mov    $0x0,%ebx
  801419:	eb 21                	jmp    80143c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	89 f0                	mov    %esi,%eax
  801420:	29 d8                	sub    %ebx,%eax
  801422:	50                   	push   %eax
  801423:	89 d8                	mov    %ebx,%eax
  801425:	03 45 0c             	add    0xc(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	57                   	push   %edi
  80142a:	e8 45 ff ff ff       	call   801374 <read>
		if (m < 0)
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 c0                	test   %eax,%eax
  801434:	78 10                	js     801446 <readn+0x41>
			return m;
		if (m == 0)
  801436:	85 c0                	test   %eax,%eax
  801438:	74 0a                	je     801444 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80143a:	01 c3                	add    %eax,%ebx
  80143c:	39 f3                	cmp    %esi,%ebx
  80143e:	72 db                	jb     80141b <readn+0x16>
  801440:	89 d8                	mov    %ebx,%eax
  801442:	eb 02                	jmp    801446 <readn+0x41>
  801444:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801446:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801449:	5b                   	pop    %ebx
  80144a:	5e                   	pop    %esi
  80144b:	5f                   	pop    %edi
  80144c:	5d                   	pop    %ebp
  80144d:	c3                   	ret    

0080144e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80144e:	55                   	push   %ebp
  80144f:	89 e5                	mov    %esp,%ebp
  801451:	53                   	push   %ebx
  801452:	83 ec 14             	sub    $0x14,%esp
  801455:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801458:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145b:	50                   	push   %eax
  80145c:	53                   	push   %ebx
  80145d:	e8 ac fc ff ff       	call   80110e <fd_lookup>
  801462:	83 c4 08             	add    $0x8,%esp
  801465:	89 c2                	mov    %eax,%edx
  801467:	85 c0                	test   %eax,%eax
  801469:	78 68                	js     8014d3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801471:	50                   	push   %eax
  801472:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801475:	ff 30                	pushl  (%eax)
  801477:	e8 e8 fc ff ff       	call   801164 <dev_lookup>
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	85 c0                	test   %eax,%eax
  801481:	78 47                	js     8014ca <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801483:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801486:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80148a:	75 21                	jne    8014ad <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80148c:	a1 04 40 80 00       	mov    0x804004,%eax
  801491:	8b 40 48             	mov    0x48(%eax),%eax
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	53                   	push   %ebx
  801498:	50                   	push   %eax
  801499:	68 59 27 80 00       	push   $0x802759
  80149e:	e8 05 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014ab:	eb 26                	jmp    8014d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014b0:	8b 52 0c             	mov    0xc(%edx),%edx
  8014b3:	85 d2                	test   %edx,%edx
  8014b5:	74 17                	je     8014ce <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014b7:	83 ec 04             	sub    $0x4,%esp
  8014ba:	ff 75 10             	pushl  0x10(%ebp)
  8014bd:	ff 75 0c             	pushl  0xc(%ebp)
  8014c0:	50                   	push   %eax
  8014c1:	ff d2                	call   *%edx
  8014c3:	89 c2                	mov    %eax,%edx
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	eb 09                	jmp    8014d3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ca:	89 c2                	mov    %eax,%edx
  8014cc:	eb 05                	jmp    8014d3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014d3:	89 d0                	mov    %edx,%eax
  8014d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d8:	c9                   	leave  
  8014d9:	c3                   	ret    

008014da <seek>:

int
seek(int fdnum, off_t offset)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014e3:	50                   	push   %eax
  8014e4:	ff 75 08             	pushl  0x8(%ebp)
  8014e7:	e8 22 fc ff ff       	call   80110e <fd_lookup>
  8014ec:	83 c4 08             	add    $0x8,%esp
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 0e                	js     801501 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014f9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801501:	c9                   	leave  
  801502:	c3                   	ret    

00801503 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801503:	55                   	push   %ebp
  801504:	89 e5                	mov    %esp,%ebp
  801506:	53                   	push   %ebx
  801507:	83 ec 14             	sub    $0x14,%esp
  80150a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80150d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801510:	50                   	push   %eax
  801511:	53                   	push   %ebx
  801512:	e8 f7 fb ff ff       	call   80110e <fd_lookup>
  801517:	83 c4 08             	add    $0x8,%esp
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 65                	js     801585 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801526:	50                   	push   %eax
  801527:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80152a:	ff 30                	pushl  (%eax)
  80152c:	e8 33 fc ff ff       	call   801164 <dev_lookup>
  801531:	83 c4 10             	add    $0x10,%esp
  801534:	85 c0                	test   %eax,%eax
  801536:	78 44                	js     80157c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801538:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80153f:	75 21                	jne    801562 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801541:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801546:	8b 40 48             	mov    0x48(%eax),%eax
  801549:	83 ec 04             	sub    $0x4,%esp
  80154c:	53                   	push   %ebx
  80154d:	50                   	push   %eax
  80154e:	68 1c 27 80 00       	push   $0x80271c
  801553:	e8 50 ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801558:	83 c4 10             	add    $0x10,%esp
  80155b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801560:	eb 23                	jmp    801585 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801562:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801565:	8b 52 18             	mov    0x18(%edx),%edx
  801568:	85 d2                	test   %edx,%edx
  80156a:	74 14                	je     801580 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	ff 75 0c             	pushl  0xc(%ebp)
  801572:	50                   	push   %eax
  801573:	ff d2                	call   *%edx
  801575:	89 c2                	mov    %eax,%edx
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	eb 09                	jmp    801585 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157c:	89 c2                	mov    %eax,%edx
  80157e:	eb 05                	jmp    801585 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801580:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801585:	89 d0                	mov    %edx,%eax
  801587:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	53                   	push   %ebx
  801590:	83 ec 14             	sub    $0x14,%esp
  801593:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801596:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801599:	50                   	push   %eax
  80159a:	ff 75 08             	pushl  0x8(%ebp)
  80159d:	e8 6c fb ff ff       	call   80110e <fd_lookup>
  8015a2:	83 c4 08             	add    $0x8,%esp
  8015a5:	89 c2                	mov    %eax,%edx
  8015a7:	85 c0                	test   %eax,%eax
  8015a9:	78 58                	js     801603 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015ab:	83 ec 08             	sub    $0x8,%esp
  8015ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015b5:	ff 30                	pushl  (%eax)
  8015b7:	e8 a8 fb ff ff       	call   801164 <dev_lookup>
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 37                	js     8015fa <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015ca:	74 32                	je     8015fe <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015cc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015cf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015d6:	00 00 00 
	stat->st_isdir = 0;
  8015d9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015e0:	00 00 00 
	stat->st_dev = dev;
  8015e3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015e9:	83 ec 08             	sub    $0x8,%esp
  8015ec:	53                   	push   %ebx
  8015ed:	ff 75 f0             	pushl  -0x10(%ebp)
  8015f0:	ff 50 14             	call   *0x14(%eax)
  8015f3:	89 c2                	mov    %eax,%edx
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	eb 09                	jmp    801603 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	eb 05                	jmp    801603 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015fe:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801603:	89 d0                	mov    %edx,%eax
  801605:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801608:	c9                   	leave  
  801609:	c3                   	ret    

0080160a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	6a 00                	push   $0x0
  801614:	ff 75 08             	pushl  0x8(%ebp)
  801617:	e8 e9 01 00 00       	call   801805 <open>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	85 c0                	test   %eax,%eax
  801623:	78 1b                	js     801640 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	ff 75 0c             	pushl  0xc(%ebp)
  80162b:	50                   	push   %eax
  80162c:	e8 5b ff ff ff       	call   80158c <fstat>
  801631:	89 c6                	mov    %eax,%esi
	close(fd);
  801633:	89 1c 24             	mov    %ebx,(%esp)
  801636:	e8 fd fb ff ff       	call   801238 <close>
	return r;
  80163b:	83 c4 10             	add    $0x10,%esp
  80163e:	89 f0                	mov    %esi,%eax
}
  801640:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801643:	5b                   	pop    %ebx
  801644:	5e                   	pop    %esi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
  80164c:	89 c6                	mov    %eax,%esi
  80164e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801650:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801657:	75 12                	jne    80166b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801659:	83 ec 0c             	sub    $0xc,%esp
  80165c:	6a 01                	push   $0x1
  80165e:	e8 db 08 00 00       	call   801f3e <ipc_find_env>
  801663:	a3 00 40 80 00       	mov    %eax,0x804000
  801668:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80166b:	6a 07                	push   $0x7
  80166d:	68 00 50 80 00       	push   $0x805000
  801672:	56                   	push   %esi
  801673:	ff 35 00 40 80 00    	pushl  0x804000
  801679:	e8 6c 08 00 00       	call   801eea <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  80167e:	83 c4 0c             	add    $0xc,%esp
  801681:	6a 00                	push   $0x0
  801683:	53                   	push   %ebx
  801684:	6a 00                	push   $0x0
  801686:	e8 dd 07 00 00       	call   801e68 <ipc_recv>
}
  80168b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80168e:	5b                   	pop    %ebx
  80168f:	5e                   	pop    %esi
  801690:	5d                   	pop    %ebp
  801691:	c3                   	ret    

00801692 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801698:	8b 45 08             	mov    0x8(%ebp),%eax
  80169b:	8b 40 0c             	mov    0xc(%eax),%eax
  80169e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8016b5:	e8 8d ff ff ff       	call   801647 <fsipc>
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8016d7:	e8 6b ff ff ff       	call   801647 <fsipc>
}
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	53                   	push   %ebx
  8016e2:	83 ec 04             	sub    $0x4,%esp
  8016e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ee:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8016fd:	e8 45 ff ff ff       	call   801647 <fsipc>
  801702:	85 c0                	test   %eax,%eax
  801704:	78 2c                	js     801732 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801706:	83 ec 08             	sub    $0x8,%esp
  801709:	68 00 50 80 00       	push   $0x805000
  80170e:	53                   	push   %ebx
  80170f:	e8 98 f0 ff ff       	call   8007ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801714:	a1 80 50 80 00       	mov    0x805080,%eax
  801719:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80171f:	a1 84 50 80 00       	mov    0x805084,%eax
  801724:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	83 ec 0c             	sub    $0xc,%esp
  80173d:	8b 45 10             	mov    0x10(%ebp),%eax
  801740:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801745:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80174a:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  80174d:	8b 55 08             	mov    0x8(%ebp),%edx
  801750:	8b 52 0c             	mov    0xc(%edx),%edx
  801753:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  801759:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  80175e:	50                   	push   %eax
  80175f:	ff 75 0c             	pushl  0xc(%ebp)
  801762:	68 08 50 80 00       	push   $0x805008
  801767:	e8 d2 f1 ff ff       	call   80093e <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  80176c:	ba 00 00 00 00       	mov    $0x0,%edx
  801771:	b8 04 00 00 00       	mov    $0x4,%eax
  801776:	e8 cc fe ff ff       	call   801647 <fsipc>
            return r;

    return r;
}
  80177b:	c9                   	leave  
  80177c:	c3                   	ret    

0080177d <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	56                   	push   %esi
  801781:	53                   	push   %ebx
  801782:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801790:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801796:	ba 00 00 00 00       	mov    $0x0,%edx
  80179b:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a0:	e8 a2 fe ff ff       	call   801647 <fsipc>
  8017a5:	89 c3                	mov    %eax,%ebx
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 51                	js     8017fc <devfile_read+0x7f>
		return r;
	assert(r <= n);
  8017ab:	39 c6                	cmp    %eax,%esi
  8017ad:	73 19                	jae    8017c8 <devfile_read+0x4b>
  8017af:	68 88 27 80 00       	push   $0x802788
  8017b4:	68 8f 27 80 00       	push   $0x80278f
  8017b9:	68 82 00 00 00       	push   $0x82
  8017be:	68 a4 27 80 00       	push   $0x8027a4
  8017c3:	e8 c0 05 00 00       	call   801d88 <_panic>
	assert(r <= PGSIZE);
  8017c8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017cd:	7e 19                	jle    8017e8 <devfile_read+0x6b>
  8017cf:	68 af 27 80 00       	push   $0x8027af
  8017d4:	68 8f 27 80 00       	push   $0x80278f
  8017d9:	68 83 00 00 00       	push   $0x83
  8017de:	68 a4 27 80 00       	push   $0x8027a4
  8017e3:	e8 a0 05 00 00       	call   801d88 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017e8:	83 ec 04             	sub    $0x4,%esp
  8017eb:	50                   	push   %eax
  8017ec:	68 00 50 80 00       	push   $0x805000
  8017f1:	ff 75 0c             	pushl  0xc(%ebp)
  8017f4:	e8 45 f1 ff ff       	call   80093e <memmove>
	return r;
  8017f9:	83 c4 10             	add    $0x10,%esp
}
  8017fc:	89 d8                	mov    %ebx,%eax
  8017fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801801:	5b                   	pop    %ebx
  801802:	5e                   	pop    %esi
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	53                   	push   %ebx
  801809:	83 ec 20             	sub    $0x20,%esp
  80180c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80180f:	53                   	push   %ebx
  801810:	e8 5e ef ff ff       	call   800773 <strlen>
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80181d:	7f 67                	jg     801886 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801825:	50                   	push   %eax
  801826:	e8 94 f8 ff ff       	call   8010bf <fd_alloc>
  80182b:	83 c4 10             	add    $0x10,%esp
		return r;
  80182e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801830:	85 c0                	test   %eax,%eax
  801832:	78 57                	js     80188b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801834:	83 ec 08             	sub    $0x8,%esp
  801837:	53                   	push   %ebx
  801838:	68 00 50 80 00       	push   $0x805000
  80183d:	e8 6a ef ff ff       	call   8007ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  801842:	8b 45 0c             	mov    0xc(%ebp),%eax
  801845:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80184a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80184d:	b8 01 00 00 00       	mov    $0x1,%eax
  801852:	e8 f0 fd ff ff       	call   801647 <fsipc>
  801857:	89 c3                	mov    %eax,%ebx
  801859:	83 c4 10             	add    $0x10,%esp
  80185c:	85 c0                	test   %eax,%eax
  80185e:	79 14                	jns    801874 <open+0x6f>
		fd_close(fd, 0);
  801860:	83 ec 08             	sub    $0x8,%esp
  801863:	6a 00                	push   $0x0
  801865:	ff 75 f4             	pushl  -0xc(%ebp)
  801868:	e8 4a f9 ff ff       	call   8011b7 <fd_close>
		return r;
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	89 da                	mov    %ebx,%edx
  801872:	eb 17                	jmp    80188b <open+0x86>
	}

	return fd2num(fd);
  801874:	83 ec 0c             	sub    $0xc,%esp
  801877:	ff 75 f4             	pushl  -0xc(%ebp)
  80187a:	e8 19 f8 ff ff       	call   801098 <fd2num>
  80187f:	89 c2                	mov    %eax,%edx
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	eb 05                	jmp    80188b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801886:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80188b:	89 d0                	mov    %edx,%eax
  80188d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	b8 08 00 00 00       	mov    $0x8,%eax
  8018a2:	e8 a0 fd ff ff       	call   801647 <fsipc>
}
  8018a7:	c9                   	leave  
  8018a8:	c3                   	ret    

008018a9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	56                   	push   %esi
  8018ad:	53                   	push   %ebx
  8018ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8018b1:	83 ec 0c             	sub    $0xc,%esp
  8018b4:	ff 75 08             	pushl  0x8(%ebp)
  8018b7:	e8 ec f7 ff ff       	call   8010a8 <fd2data>
  8018bc:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8018be:	83 c4 08             	add    $0x8,%esp
  8018c1:	68 bb 27 80 00       	push   $0x8027bb
  8018c6:	53                   	push   %ebx
  8018c7:	e8 e0 ee ff ff       	call   8007ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8018cc:	8b 46 04             	mov    0x4(%esi),%eax
  8018cf:	2b 06                	sub    (%esi),%eax
  8018d1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8018d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018de:	00 00 00 
	stat->st_dev = &devpipe;
  8018e1:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8018e8:	30 80 00 
	return 0;
}
  8018eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8018f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f3:	5b                   	pop    %ebx
  8018f4:	5e                   	pop    %esi
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	53                   	push   %ebx
  8018fb:	83 ec 0c             	sub    $0xc,%esp
  8018fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801901:	53                   	push   %ebx
  801902:	6a 00                	push   $0x0
  801904:	e8 2b f3 ff ff       	call   800c34 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801909:	89 1c 24             	mov    %ebx,(%esp)
  80190c:	e8 97 f7 ff ff       	call   8010a8 <fd2data>
  801911:	83 c4 08             	add    $0x8,%esp
  801914:	50                   	push   %eax
  801915:	6a 00                	push   $0x0
  801917:	e8 18 f3 ff ff       	call   800c34 <sys_page_unmap>
}
  80191c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	57                   	push   %edi
  801925:	56                   	push   %esi
  801926:	53                   	push   %ebx
  801927:	83 ec 1c             	sub    $0x1c,%esp
  80192a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80192d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80192f:	a1 04 40 80 00       	mov    0x804004,%eax
  801934:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801937:	83 ec 0c             	sub    $0xc,%esp
  80193a:	ff 75 e0             	pushl  -0x20(%ebp)
  80193d:	e8 35 06 00 00       	call   801f77 <pageref>
  801942:	89 c3                	mov    %eax,%ebx
  801944:	89 3c 24             	mov    %edi,(%esp)
  801947:	e8 2b 06 00 00       	call   801f77 <pageref>
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	39 c3                	cmp    %eax,%ebx
  801951:	0f 94 c1             	sete   %cl
  801954:	0f b6 c9             	movzbl %cl,%ecx
  801957:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  80195a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801960:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801963:	39 ce                	cmp    %ecx,%esi
  801965:	74 1b                	je     801982 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801967:	39 c3                	cmp    %eax,%ebx
  801969:	75 c4                	jne    80192f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80196b:	8b 42 58             	mov    0x58(%edx),%eax
  80196e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801971:	50                   	push   %eax
  801972:	56                   	push   %esi
  801973:	68 c2 27 80 00       	push   $0x8027c2
  801978:	e8 2b e8 ff ff       	call   8001a8 <cprintf>
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	eb ad                	jmp    80192f <_pipeisclosed+0xe>
	}
}
  801982:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801985:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801988:	5b                   	pop    %ebx
  801989:	5e                   	pop    %esi
  80198a:	5f                   	pop    %edi
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    

0080198d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	57                   	push   %edi
  801991:	56                   	push   %esi
  801992:	53                   	push   %ebx
  801993:	83 ec 28             	sub    $0x28,%esp
  801996:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801999:	56                   	push   %esi
  80199a:	e8 09 f7 ff ff       	call   8010a8 <fd2data>
  80199f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8019a9:	eb 4b                	jmp    8019f6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8019ab:	89 da                	mov    %ebx,%edx
  8019ad:	89 f0                	mov    %esi,%eax
  8019af:	e8 6d ff ff ff       	call   801921 <_pipeisclosed>
  8019b4:	85 c0                	test   %eax,%eax
  8019b6:	75 48                	jne    801a00 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8019b8:	e8 d3 f1 ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8019bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8019c0:	8b 0b                	mov    (%ebx),%ecx
  8019c2:	8d 51 20             	lea    0x20(%ecx),%edx
  8019c5:	39 d0                	cmp    %edx,%eax
  8019c7:	73 e2                	jae    8019ab <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8019c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019cc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8019d0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8019d3:	89 c2                	mov    %eax,%edx
  8019d5:	c1 fa 1f             	sar    $0x1f,%edx
  8019d8:	89 d1                	mov    %edx,%ecx
  8019da:	c1 e9 1b             	shr    $0x1b,%ecx
  8019dd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8019e0:	83 e2 1f             	and    $0x1f,%edx
  8019e3:	29 ca                	sub    %ecx,%edx
  8019e5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8019e9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8019ed:	83 c0 01             	add    $0x1,%eax
  8019f0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019f3:	83 c7 01             	add    $0x1,%edi
  8019f6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8019f9:	75 c2                	jne    8019bd <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8019fb:	8b 45 10             	mov    0x10(%ebp),%eax
  8019fe:	eb 05                	jmp    801a05 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a00:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801a05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5f                   	pop    %edi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a0d:	55                   	push   %ebp
  801a0e:	89 e5                	mov    %esp,%ebp
  801a10:	57                   	push   %edi
  801a11:	56                   	push   %esi
  801a12:	53                   	push   %ebx
  801a13:	83 ec 18             	sub    $0x18,%esp
  801a16:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801a19:	57                   	push   %edi
  801a1a:	e8 89 f6 ff ff       	call   8010a8 <fd2data>
  801a1f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a21:	83 c4 10             	add    $0x10,%esp
  801a24:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a29:	eb 3d                	jmp    801a68 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801a2b:	85 db                	test   %ebx,%ebx
  801a2d:	74 04                	je     801a33 <devpipe_read+0x26>
				return i;
  801a2f:	89 d8                	mov    %ebx,%eax
  801a31:	eb 44                	jmp    801a77 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801a33:	89 f2                	mov    %esi,%edx
  801a35:	89 f8                	mov    %edi,%eax
  801a37:	e8 e5 fe ff ff       	call   801921 <_pipeisclosed>
  801a3c:	85 c0                	test   %eax,%eax
  801a3e:	75 32                	jne    801a72 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801a40:	e8 4b f1 ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801a45:	8b 06                	mov    (%esi),%eax
  801a47:	3b 46 04             	cmp    0x4(%esi),%eax
  801a4a:	74 df                	je     801a2b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801a4c:	99                   	cltd   
  801a4d:	c1 ea 1b             	shr    $0x1b,%edx
  801a50:	01 d0                	add    %edx,%eax
  801a52:	83 e0 1f             	and    $0x1f,%eax
  801a55:	29 d0                	sub    %edx,%eax
  801a57:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801a5c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a5f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a62:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a65:	83 c3 01             	add    $0x1,%ebx
  801a68:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a6b:	75 d8                	jne    801a45 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a70:	eb 05                	jmp    801a77 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a72:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5f                   	pop    %edi
  801a7d:	5d                   	pop    %ebp
  801a7e:	c3                   	ret    

00801a7f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8a:	50                   	push   %eax
  801a8b:	e8 2f f6 ff ff       	call   8010bf <fd_alloc>
  801a90:	83 c4 10             	add    $0x10,%esp
  801a93:	89 c2                	mov    %eax,%edx
  801a95:	85 c0                	test   %eax,%eax
  801a97:	0f 88 2c 01 00 00    	js     801bc9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a9d:	83 ec 04             	sub    $0x4,%esp
  801aa0:	68 07 04 00 00       	push   $0x407
  801aa5:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa8:	6a 00                	push   $0x0
  801aaa:	e8 00 f1 ff ff       	call   800baf <sys_page_alloc>
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	89 c2                	mov    %eax,%edx
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	0f 88 0d 01 00 00    	js     801bc9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801abc:	83 ec 0c             	sub    $0xc,%esp
  801abf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ac2:	50                   	push   %eax
  801ac3:	e8 f7 f5 ff ff       	call   8010bf <fd_alloc>
  801ac8:	89 c3                	mov    %eax,%ebx
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	85 c0                	test   %eax,%eax
  801acf:	0f 88 e2 00 00 00    	js     801bb7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ad5:	83 ec 04             	sub    $0x4,%esp
  801ad8:	68 07 04 00 00       	push   $0x407
  801add:	ff 75 f0             	pushl  -0x10(%ebp)
  801ae0:	6a 00                	push   $0x0
  801ae2:	e8 c8 f0 ff ff       	call   800baf <sys_page_alloc>
  801ae7:	89 c3                	mov    %eax,%ebx
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	85 c0                	test   %eax,%eax
  801aee:	0f 88 c3 00 00 00    	js     801bb7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801af4:	83 ec 0c             	sub    $0xc,%esp
  801af7:	ff 75 f4             	pushl  -0xc(%ebp)
  801afa:	e8 a9 f5 ff ff       	call   8010a8 <fd2data>
  801aff:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b01:	83 c4 0c             	add    $0xc,%esp
  801b04:	68 07 04 00 00       	push   $0x407
  801b09:	50                   	push   %eax
  801b0a:	6a 00                	push   $0x0
  801b0c:	e8 9e f0 ff ff       	call   800baf <sys_page_alloc>
  801b11:	89 c3                	mov    %eax,%ebx
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	0f 88 89 00 00 00    	js     801ba7 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	ff 75 f0             	pushl  -0x10(%ebp)
  801b24:	e8 7f f5 ff ff       	call   8010a8 <fd2data>
  801b29:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b30:	50                   	push   %eax
  801b31:	6a 00                	push   $0x0
  801b33:	56                   	push   %esi
  801b34:	6a 00                	push   $0x0
  801b36:	e8 b7 f0 ff ff       	call   800bf2 <sys_page_map>
  801b3b:	89 c3                	mov    %eax,%ebx
  801b3d:	83 c4 20             	add    $0x20,%esp
  801b40:	85 c0                	test   %eax,%eax
  801b42:	78 55                	js     801b99 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801b44:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b52:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801b59:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b62:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b64:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b67:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b6e:	83 ec 0c             	sub    $0xc,%esp
  801b71:	ff 75 f4             	pushl  -0xc(%ebp)
  801b74:	e8 1f f5 ff ff       	call   801098 <fd2num>
  801b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b7c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b7e:	83 c4 04             	add    $0x4,%esp
  801b81:	ff 75 f0             	pushl  -0x10(%ebp)
  801b84:	e8 0f f5 ff ff       	call   801098 <fd2num>
  801b89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b8c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	ba 00 00 00 00       	mov    $0x0,%edx
  801b97:	eb 30                	jmp    801bc9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b99:	83 ec 08             	sub    $0x8,%esp
  801b9c:	56                   	push   %esi
  801b9d:	6a 00                	push   $0x0
  801b9f:	e8 90 f0 ff ff       	call   800c34 <sys_page_unmap>
  801ba4:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ba7:	83 ec 08             	sub    $0x8,%esp
  801baa:	ff 75 f0             	pushl  -0x10(%ebp)
  801bad:	6a 00                	push   $0x0
  801baf:	e8 80 f0 ff ff       	call   800c34 <sys_page_unmap>
  801bb4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801bb7:	83 ec 08             	sub    $0x8,%esp
  801bba:	ff 75 f4             	pushl  -0xc(%ebp)
  801bbd:	6a 00                	push   $0x0
  801bbf:	e8 70 f0 ff ff       	call   800c34 <sys_page_unmap>
  801bc4:	83 c4 10             	add    $0x10,%esp
  801bc7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801bc9:	89 d0                	mov    %edx,%eax
  801bcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bce:	5b                   	pop    %ebx
  801bcf:	5e                   	pop    %esi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801bd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	ff 75 08             	pushl  0x8(%ebp)
  801bdf:	e8 2a f5 ff ff       	call   80110e <fd_lookup>
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 18                	js     801c03 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801beb:	83 ec 0c             	sub    $0xc,%esp
  801bee:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf1:	e8 b2 f4 ff ff       	call   8010a8 <fd2data>
	return _pipeisclosed(fd, p);
  801bf6:	89 c2                	mov    %eax,%edx
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	e8 21 fd ff ff       	call   801921 <_pipeisclosed>
  801c00:	83 c4 10             	add    $0x10,%esp
}
  801c03:	c9                   	leave  
  801c04:	c3                   	ret    

00801c05 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801c05:	55                   	push   %ebp
  801c06:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801c08:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c15:	68 da 27 80 00       	push   $0x8027da
  801c1a:	ff 75 0c             	pushl  0xc(%ebp)
  801c1d:	e8 8a eb ff ff       	call   8007ac <strcpy>
	return 0;
}
  801c22:	b8 00 00 00 00       	mov    $0x0,%eax
  801c27:	c9                   	leave  
  801c28:	c3                   	ret    

00801c29 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	57                   	push   %edi
  801c2d:	56                   	push   %esi
  801c2e:	53                   	push   %ebx
  801c2f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c35:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c3a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c40:	eb 2d                	jmp    801c6f <devcons_write+0x46>
		m = n - tot;
  801c42:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c45:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801c47:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801c4a:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801c4f:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801c52:	83 ec 04             	sub    $0x4,%esp
  801c55:	53                   	push   %ebx
  801c56:	03 45 0c             	add    0xc(%ebp),%eax
  801c59:	50                   	push   %eax
  801c5a:	57                   	push   %edi
  801c5b:	e8 de ec ff ff       	call   80093e <memmove>
		sys_cputs(buf, m);
  801c60:	83 c4 08             	add    $0x8,%esp
  801c63:	53                   	push   %ebx
  801c64:	57                   	push   %edi
  801c65:	e8 89 ee ff ff       	call   800af3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c6a:	01 de                	add    %ebx,%esi
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	89 f0                	mov    %esi,%eax
  801c71:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c74:	72 cc                	jb     801c42 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c79:	5b                   	pop    %ebx
  801c7a:	5e                   	pop    %esi
  801c7b:	5f                   	pop    %edi
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	83 ec 08             	sub    $0x8,%esp
  801c84:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c8d:	74 2a                	je     801cb9 <devcons_read+0x3b>
  801c8f:	eb 05                	jmp    801c96 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c91:	e8 fa ee ff ff       	call   800b90 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c96:	e8 76 ee ff ff       	call   800b11 <sys_cgetc>
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	74 f2                	je     801c91 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c9f:	85 c0                	test   %eax,%eax
  801ca1:	78 16                	js     801cb9 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ca3:	83 f8 04             	cmp    $0x4,%eax
  801ca6:	74 0c                	je     801cb4 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ca8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cab:	88 02                	mov    %al,(%edx)
	return 1;
  801cad:	b8 01 00 00 00       	mov    $0x1,%eax
  801cb2:	eb 05                	jmp    801cb9 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801cb4:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801cb9:	c9                   	leave  
  801cba:	c3                   	ret    

00801cbb <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801cbb:	55                   	push   %ebp
  801cbc:	89 e5                	mov    %esp,%ebp
  801cbe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc4:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801cc7:	6a 01                	push   $0x1
  801cc9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ccc:	50                   	push   %eax
  801ccd:	e8 21 ee ff ff       	call   800af3 <sys_cputs>
}
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <getchar>:

int
getchar(void)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801cdd:	6a 01                	push   $0x1
  801cdf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ce2:	50                   	push   %eax
  801ce3:	6a 00                	push   $0x0
  801ce5:	e8 8a f6 ff ff       	call   801374 <read>
	if (r < 0)
  801cea:	83 c4 10             	add    $0x10,%esp
  801ced:	85 c0                	test   %eax,%eax
  801cef:	78 0f                	js     801d00 <getchar+0x29>
		return r;
	if (r < 1)
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	7e 06                	jle    801cfb <getchar+0x24>
		return -E_EOF;
	return c;
  801cf5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801cf9:	eb 05                	jmp    801d00 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801cfb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d08:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d0b:	50                   	push   %eax
  801d0c:	ff 75 08             	pushl  0x8(%ebp)
  801d0f:	e8 fa f3 ff ff       	call   80110e <fd_lookup>
  801d14:	83 c4 10             	add    $0x10,%esp
  801d17:	85 c0                	test   %eax,%eax
  801d19:	78 11                	js     801d2c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d1e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d24:	39 10                	cmp    %edx,(%eax)
  801d26:	0f 94 c0             	sete   %al
  801d29:	0f b6 c0             	movzbl %al,%eax
}
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <opencons>:

int
opencons(void)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d37:	50                   	push   %eax
  801d38:	e8 82 f3 ff ff       	call   8010bf <fd_alloc>
  801d3d:	83 c4 10             	add    $0x10,%esp
		return r;
  801d40:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801d42:	85 c0                	test   %eax,%eax
  801d44:	78 3e                	js     801d84 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d46:	83 ec 04             	sub    $0x4,%esp
  801d49:	68 07 04 00 00       	push   $0x407
  801d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d51:	6a 00                	push   $0x0
  801d53:	e8 57 ee ff ff       	call   800baf <sys_page_alloc>
  801d58:	83 c4 10             	add    $0x10,%esp
		return r;
  801d5b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d5d:	85 c0                	test   %eax,%eax
  801d5f:	78 23                	js     801d84 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d61:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d67:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d6f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d76:	83 ec 0c             	sub    $0xc,%esp
  801d79:	50                   	push   %eax
  801d7a:	e8 19 f3 ff ff       	call   801098 <fd2num>
  801d7f:	89 c2                	mov    %eax,%edx
  801d81:	83 c4 10             	add    $0x10,%esp
}
  801d84:	89 d0                	mov    %edx,%eax
  801d86:	c9                   	leave  
  801d87:	c3                   	ret    

00801d88 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	56                   	push   %esi
  801d8c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d8d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d90:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d96:	e8 d6 ed ff ff       	call   800b71 <sys_getenvid>
  801d9b:	83 ec 0c             	sub    $0xc,%esp
  801d9e:	ff 75 0c             	pushl  0xc(%ebp)
  801da1:	ff 75 08             	pushl  0x8(%ebp)
  801da4:	56                   	push   %esi
  801da5:	50                   	push   %eax
  801da6:	68 e8 27 80 00       	push   $0x8027e8
  801dab:	e8 f8 e3 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801db0:	83 c4 18             	add    $0x18,%esp
  801db3:	53                   	push   %ebx
  801db4:	ff 75 10             	pushl  0x10(%ebp)
  801db7:	e8 9b e3 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801dbc:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  801dc3:	e8 e0 e3 ff ff       	call   8001a8 <cprintf>
  801dc8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801dcb:	cc                   	int3   
  801dcc:	eb fd                	jmp    801dcb <_panic+0x43>

00801dce <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	53                   	push   %ebx
  801dd2:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  801dd5:	e8 97 ed ff ff       	call   800b71 <sys_getenvid>
  801dda:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  801ddc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801de3:	75 29                	jne    801e0e <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  801de5:	83 ec 04             	sub    $0x4,%esp
  801de8:	6a 07                	push   $0x7
  801dea:	68 00 f0 bf ee       	push   $0xeebff000
  801def:	50                   	push   %eax
  801df0:	e8 ba ed ff ff       	call   800baf <sys_page_alloc>
  801df5:	83 c4 10             	add    $0x10,%esp
  801df8:	85 c0                	test   %eax,%eax
  801dfa:	79 12                	jns    801e0e <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  801dfc:	50                   	push   %eax
  801dfd:	68 0c 28 80 00       	push   $0x80280c
  801e02:	6a 24                	push   $0x24
  801e04:	68 25 28 80 00       	push   $0x802825
  801e09:	e8 7a ff ff ff       	call   801d88 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  801e0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e11:	a3 00 60 80 00       	mov    %eax,0x806000
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  801e16:	83 ec 08             	sub    $0x8,%esp
  801e19:	68 42 1e 80 00       	push   $0x801e42
  801e1e:	53                   	push   %ebx
  801e1f:	e8 d6 ee ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
  801e24:	83 c4 10             	add    $0x10,%esp
  801e27:	85 c0                	test   %eax,%eax
  801e29:	79 12                	jns    801e3d <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  801e2b:	50                   	push   %eax
  801e2c:	68 0c 28 80 00       	push   $0x80280c
  801e31:	6a 2e                	push   $0x2e
  801e33:	68 25 28 80 00       	push   $0x802825
  801e38:	e8 4b ff ff ff       	call   801d88 <_panic>
}
  801e3d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e40:	c9                   	leave  
  801e41:	c3                   	ret    

00801e42 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e42:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e43:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e48:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e4a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  801e4d:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  801e51:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  801e54:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801e58:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  801e5a:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  801e5e:	83 c4 08             	add    $0x8,%esp
	popal
  801e61:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  801e62:	83 c4 04             	add    $0x4,%esp
	popfl
  801e65:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  801e66:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e67:	c3                   	ret    

00801e68 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801e68:	55                   	push   %ebp
  801e69:	89 e5                	mov    %esp,%ebp
  801e6b:	57                   	push   %edi
  801e6c:	56                   	push   %esi
  801e6d:	53                   	push   %ebx
  801e6e:	83 ec 0c             	sub    $0xc,%esp
  801e71:	8b 75 08             	mov    0x8(%ebp),%esi
  801e74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801e7a:	85 f6                	test   %esi,%esi
  801e7c:	74 06                	je     801e84 <ipc_recv+0x1c>
		*from_env_store = 0;
  801e7e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801e84:	85 db                	test   %ebx,%ebx
  801e86:	74 06                	je     801e8e <ipc_recv+0x26>
		*perm_store = 0;
  801e88:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801e8e:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801e90:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801e95:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801e98:	83 ec 0c             	sub    $0xc,%esp
  801e9b:	50                   	push   %eax
  801e9c:	e8 be ee ff ff       	call   800d5f <sys_ipc_recv>
  801ea1:	89 c7                	mov    %eax,%edi
  801ea3:	83 c4 10             	add    $0x10,%esp
  801ea6:	85 c0                	test   %eax,%eax
  801ea8:	79 14                	jns    801ebe <ipc_recv+0x56>
		cprintf("im dead");
  801eaa:	83 ec 0c             	sub    $0xc,%esp
  801ead:	68 33 28 80 00       	push   $0x802833
  801eb2:	e8 f1 e2 ff ff       	call   8001a8 <cprintf>
		return r;
  801eb7:	83 c4 10             	add    $0x10,%esp
  801eba:	89 f8                	mov    %edi,%eax
  801ebc:	eb 24                	jmp    801ee2 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801ebe:	85 f6                	test   %esi,%esi
  801ec0:	74 0a                	je     801ecc <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801ec2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ec7:	8b 40 74             	mov    0x74(%eax),%eax
  801eca:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801ecc:	85 db                	test   %ebx,%ebx
  801ece:	74 0a                	je     801eda <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ed0:	a1 04 40 80 00       	mov    0x804004,%eax
  801ed5:	8b 40 78             	mov    0x78(%eax),%eax
  801ed8:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801eda:	a1 04 40 80 00       	mov    0x804004,%eax
  801edf:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ee5:	5b                   	pop    %ebx
  801ee6:	5e                   	pop    %esi
  801ee7:	5f                   	pop    %edi
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	57                   	push   %edi
  801eee:	56                   	push   %esi
  801eef:	53                   	push   %ebx
  801ef0:	83 ec 0c             	sub    $0xc,%esp
  801ef3:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ef6:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801efc:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801efe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801f03:	0f 44 d8             	cmove  %eax,%ebx
  801f06:	eb 1c                	jmp    801f24 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801f08:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f0b:	74 12                	je     801f1f <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801f0d:	50                   	push   %eax
  801f0e:	68 3b 28 80 00       	push   $0x80283b
  801f13:	6a 4e                	push   $0x4e
  801f15:	68 48 28 80 00       	push   $0x802848
  801f1a:	e8 69 fe ff ff       	call   801d88 <_panic>
		sys_yield();
  801f1f:	e8 6c ec ff ff       	call   800b90 <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801f24:	ff 75 14             	pushl  0x14(%ebp)
  801f27:	53                   	push   %ebx
  801f28:	56                   	push   %esi
  801f29:	57                   	push   %edi
  801f2a:	e8 0d ee ff ff       	call   800d3c <sys_ipc_try_send>
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	78 d2                	js     801f08 <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801f36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5e                   	pop    %esi
  801f3b:	5f                   	pop    %edi
  801f3c:	5d                   	pop    %ebp
  801f3d:	c3                   	ret    

00801f3e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f49:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f4c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f52:	8b 52 50             	mov    0x50(%edx),%edx
  801f55:	39 ca                	cmp    %ecx,%edx
  801f57:	75 0d                	jne    801f66 <ipc_find_env+0x28>
			return envs[i].env_id;
  801f59:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f5c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f61:	8b 40 48             	mov    0x48(%eax),%eax
  801f64:	eb 0f                	jmp    801f75 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801f66:	83 c0 01             	add    $0x1,%eax
  801f69:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f6e:	75 d9                	jne    801f49 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801f70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f75:	5d                   	pop    %ebp
  801f76:	c3                   	ret    

00801f77 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f77:	55                   	push   %ebp
  801f78:	89 e5                	mov    %esp,%ebp
  801f7a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f7d:	89 d0                	mov    %edx,%eax
  801f7f:	c1 e8 16             	shr    $0x16,%eax
  801f82:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801f89:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f8e:	f6 c1 01             	test   $0x1,%cl
  801f91:	74 1d                	je     801fb0 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f93:	c1 ea 0c             	shr    $0xc,%edx
  801f96:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f9d:	f6 c2 01             	test   $0x1,%dl
  801fa0:	74 0e                	je     801fb0 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fa2:	c1 ea 0c             	shr    $0xc,%edx
  801fa5:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801fac:	ef 
  801fad:	0f b7 c0             	movzwl %ax,%eax
}
  801fb0:	5d                   	pop    %ebp
  801fb1:	c3                   	ret    
  801fb2:	66 90                	xchg   %ax,%ax
  801fb4:	66 90                	xchg   %ax,%ax
  801fb6:	66 90                	xchg   %ax,%ax
  801fb8:	66 90                	xchg   %ax,%ax
  801fba:	66 90                	xchg   %ax,%ax
  801fbc:	66 90                	xchg   %ax,%ax
  801fbe:	66 90                	xchg   %ax,%ax

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
