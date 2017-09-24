
obj/user/faultdie.debug:     file format elf32-i386


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
  800045:	68 20 1f 80 00       	push   $0x801f20
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 e8 0a 00 00       	call   800b3c <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 9f 0a 00 00       	call   800afb <sys_env_destroy>
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
  80006c:	e8 fa 0c 00 00       	call   800d6b <set_pgfault_handler>
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
  80008b:	e8 ac 0a 00 00       	call   800b3c <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
		binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 ff 0e 00 00       	call   800fd0 <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 20 0a 00 00       	call   800afb <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 ae 09 00 00       	call   800abe <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 1a 01 00 00       	call   800270 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 53 09 00 00       	call   800abe <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 b5 1a 00 00       	call   801c90 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 a2 1b 00 00       	call   801dc0 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 46 1f 80 00 	movsbl 0x801f46(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800240:	8b 10                	mov    (%eax),%edx
  800242:	3b 50 04             	cmp    0x4(%eax),%edx
  800245:	73 0a                	jae    800251 <sprintputch+0x1b>
		*b->buf++ = ch;
  800247:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800259:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	e8 05 00 00 00       	call   800270 <vprintfmt>
	va_end(ap);
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 2c             	sub    $0x2c,%esp
  800279:	8b 75 08             	mov    0x8(%ebp),%esi
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800282:	eb 12                	jmp    800296 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800284:	85 c0                	test   %eax,%eax
  800286:	0f 84 42 04 00 00    	je     8006ce <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	ff d6                	call   *%esi
  800293:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800296:	83 c7 01             	add    $0x1,%edi
  800299:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029d:	83 f8 25             	cmp    $0x25,%eax
  8002a0:	75 e2                	jne    800284 <vprintfmt+0x14>
  8002a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c0:	eb 07                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c9:	8d 47 01             	lea    0x1(%edi),%eax
  8002cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cf:	0f b6 07             	movzbl (%edi),%eax
  8002d2:	0f b6 d0             	movzbl %al,%edx
  8002d5:	83 e8 23             	sub    $0x23,%eax
  8002d8:	3c 55                	cmp    $0x55,%al
  8002da:	0f 87 d3 03 00 00    	ja     8006b3 <vprintfmt+0x443>
  8002e0:	0f b6 c0             	movzbl %al,%eax
  8002e3:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8002ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f1:	eb d6                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800301:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800305:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800308:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030b:	83 f9 09             	cmp    $0x9,%ecx
  80030e:	77 3f                	ja     80034f <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800310:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800313:	eb e9                	jmp    8002fe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8b 00                	mov    (%eax),%eax
  80031a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 40 04             	lea    0x4(%eax),%eax
  800323:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800329:	eb 2a                	jmp    800355 <vprintfmt+0xe5>
  80032b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032e:	85 c0                	test   %eax,%eax
  800330:	ba 00 00 00 00       	mov    $0x0,%edx
  800335:	0f 49 d0             	cmovns %eax,%edx
  800338:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033e:	eb 89                	jmp    8002c9 <vprintfmt+0x59>
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800343:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034a:	e9 7a ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
  80034f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800352:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800355:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800359:	0f 89 6a ff ff ff    	jns    8002c9 <vprintfmt+0x59>
				width = precision, precision = -1;
  80035f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800362:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	e9 58 ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800371:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800377:	e9 4d ff ff ff       	jmp    8002c9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 78 04             	lea    0x4(%eax),%edi
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	53                   	push   %ebx
  800386:	ff 30                	pushl  (%eax)
  800388:	ff d6                	call   *%esi
			break;
  80038a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800393:	e9 fe fe ff ff       	jmp    800296 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 78 04             	lea    0x4(%eax),%edi
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	99                   	cltd   
  8003a1:	31 d0                	xor    %edx,%eax
  8003a3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a5:	83 f8 0f             	cmp    $0xf,%eax
  8003a8:	7f 0b                	jg     8003b5 <vprintfmt+0x145>
  8003aa:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8003b1:	85 d2                	test   %edx,%edx
  8003b3:	75 1b                	jne    8003d0 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003b5:	50                   	push   %eax
  8003b6:	68 5e 1f 80 00       	push   $0x801f5e
  8003bb:	53                   	push   %ebx
  8003bc:	56                   	push   %esi
  8003bd:	e8 91 fe ff ff       	call   800253 <printfmt>
  8003c2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cb:	e9 c6 fe ff ff       	jmp    800296 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d0:	52                   	push   %edx
  8003d1:	68 39 23 80 00       	push   $0x802339
  8003d6:	53                   	push   %ebx
  8003d7:	56                   	push   %esi
  8003d8:	e8 76 fe ff ff       	call   800253 <printfmt>
  8003dd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	e9 ab fe ff ff       	jmp    800296 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	83 c0 04             	add    $0x4,%eax
  8003f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f9:	85 ff                	test   %edi,%edi
  8003fb:	b8 57 1f 80 00       	mov    $0x801f57,%eax
  800400:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800403:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800407:	0f 8e 94 00 00 00    	jle    8004a1 <vprintfmt+0x231>
  80040d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800411:	0f 84 98 00 00 00    	je     8004af <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	ff 75 d0             	pushl  -0x30(%ebp)
  80041d:	57                   	push   %edi
  80041e:	e8 33 03 00 00       	call   800756 <strnlen>
  800423:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800426:	29 c1                	sub    %eax,%ecx
  800428:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80042b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800435:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800438:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043a:	eb 0f                	jmp    80044b <vprintfmt+0x1db>
					putch(padc, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ef 01             	sub    $0x1,%edi
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	85 ff                	test   %edi,%edi
  80044d:	7f ed                	jg     80043c <vprintfmt+0x1cc>
  80044f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800452:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800455:	85 c9                	test   %ecx,%ecx
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
  80045c:	0f 49 c1             	cmovns %ecx,%eax
  80045f:	29 c1                	sub    %eax,%ecx
  800461:	89 75 08             	mov    %esi,0x8(%ebp)
  800464:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800467:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046a:	89 cb                	mov    %ecx,%ebx
  80046c:	eb 4d                	jmp    8004bb <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800472:	74 1b                	je     80048f <vprintfmt+0x21f>
  800474:	0f be c0             	movsbl %al,%eax
  800477:	83 e8 20             	sub    $0x20,%eax
  80047a:	83 f8 5e             	cmp    $0x5e,%eax
  80047d:	76 10                	jbe    80048f <vprintfmt+0x21f>
					putch('?', putdat);
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	ff 75 0c             	pushl  0xc(%ebp)
  800485:	6a 3f                	push   $0x3f
  800487:	ff 55 08             	call   *0x8(%ebp)
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	eb 0d                	jmp    80049c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	52                   	push   %edx
  800496:	ff 55 08             	call   *0x8(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049c:	83 eb 01             	sub    $0x1,%ebx
  80049f:	eb 1a                	jmp    8004bb <vprintfmt+0x24b>
  8004a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ad:	eb 0c                	jmp    8004bb <vprintfmt+0x24b>
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bb:	83 c7 01             	add    $0x1,%edi
  8004be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c2:	0f be d0             	movsbl %al,%edx
  8004c5:	85 d2                	test   %edx,%edx
  8004c7:	74 23                	je     8004ec <vprintfmt+0x27c>
  8004c9:	85 f6                	test   %esi,%esi
  8004cb:	78 a1                	js     80046e <vprintfmt+0x1fe>
  8004cd:	83 ee 01             	sub    $0x1,%esi
  8004d0:	79 9c                	jns    80046e <vprintfmt+0x1fe>
  8004d2:	89 df                	mov    %ebx,%edi
  8004d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	eb 18                	jmp    8004f4 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	6a 20                	push   $0x20
  8004e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e4:	83 ef 01             	sub    $0x1,%edi
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	eb 08                	jmp    8004f4 <vprintfmt+0x284>
  8004ec:	89 df                	mov    %ebx,%edi
  8004ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f e4                	jg     8004dc <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	e9 90 fd ff ff       	jmp    800296 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800506:	83 f9 01             	cmp    $0x1,%ecx
  800509:	7e 19                	jle    800524 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 50 04             	mov    0x4(%eax),%edx
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 08             	lea    0x8(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
  800522:	eb 38                	jmp    80055c <vprintfmt+0x2ec>
	else if (lflag)
  800524:	85 c9                	test   %ecx,%ecx
  800526:	74 1b                	je     800543 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800530:	89 c1                	mov    %eax,%ecx
  800532:	c1 f9 1f             	sar    $0x1f,%ecx
  800535:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 40 04             	lea    0x4(%eax),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
  800541:	eb 19                	jmp    80055c <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 c1                	mov    %eax,%ecx
  80054d:	c1 f9 1f             	sar    $0x1f,%ecx
  800550:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 40 04             	lea    0x4(%eax),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800567:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056b:	0f 89 0e 01 00 00    	jns    80067f <vprintfmt+0x40f>
				putch('-', putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	53                   	push   %ebx
  800575:	6a 2d                	push   $0x2d
  800577:	ff d6                	call   *%esi
				num = -(long long) num;
  800579:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80057f:	f7 da                	neg    %edx
  800581:	83 d1 00             	adc    $0x0,%ecx
  800584:	f7 d9                	neg    %ecx
  800586:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058e:	e9 ec 00 00 00       	jmp    80067f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800593:	83 f9 01             	cmp    $0x1,%ecx
  800596:	7e 18                	jle    8005b0 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 10                	mov    (%eax),%edx
  80059d:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a0:	8d 40 08             	lea    0x8(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 cf 00 00 00       	jmp    80067f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005b0:	85 c9                	test   %ecx,%ecx
  8005b2:	74 1a                	je     8005ce <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c9:	e9 b1 00 00 00       	jmp    80067f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d8:	8d 40 04             	lea    0x4(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 97 00 00 00       	jmp    80067f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	6a 58                	push   $0x58
  8005ee:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f0:	83 c4 08             	add    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 58                	push   $0x58
  8005f6:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f8:	83 c4 08             	add    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	6a 58                	push   $0x58
  8005fe:	ff d6                	call   *%esi
			break;
  800600:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800606:	e9 8b fc ff ff       	jmp    800296 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 30                	push   $0x30
  800611:	ff d6                	call   *%esi
			putch('x', putdat);
  800613:	83 c4 08             	add    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 78                	push   $0x78
  800619:	ff d6                	call   *%esi
			num = (unsigned long long)
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800625:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800628:	8d 40 04             	lea    0x4(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800633:	eb 4a                	jmp    80067f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 15                	jle    80064f <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	8b 48 04             	mov    0x4(%eax),%ecx
  800642:	8d 40 08             	lea    0x8(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800648:	b8 10 00 00 00       	mov    $0x10,%eax
  80064d:	eb 30                	jmp    80067f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80064f:	85 c9                	test   %ecx,%ecx
  800651:	74 17                	je     80066a <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800663:	b8 10 00 00 00       	mov    $0x10,%eax
  800668:	eb 15                	jmp    80067f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067f:	83 ec 0c             	sub    $0xc,%esp
  800682:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800686:	57                   	push   %edi
  800687:	ff 75 e0             	pushl  -0x20(%ebp)
  80068a:	50                   	push   %eax
  80068b:	51                   	push   %ecx
  80068c:	52                   	push   %edx
  80068d:	89 da                	mov    %ebx,%edx
  80068f:	89 f0                	mov    %esi,%eax
  800691:	e8 f1 fa ff ff       	call   800187 <printnum>
			break;
  800696:	83 c4 20             	add    $0x20,%esp
  800699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069c:	e9 f5 fb ff ff       	jmp    800296 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	52                   	push   %edx
  8006a6:	ff d6                	call   *%esi
			break;
  8006a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ae:	e9 e3 fb ff ff       	jmp    800296 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 25                	push   $0x25
  8006b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	eb 03                	jmp    8006c3 <vprintfmt+0x453>
  8006c0:	83 ef 01             	sub    $0x1,%edi
  8006c3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c7:	75 f7                	jne    8006c0 <vprintfmt+0x450>
  8006c9:	e9 c8 fb ff ff       	jmp    800296 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5f                   	pop    %edi
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	83 ec 18             	sub    $0x18,%esp
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 26                	je     80071d <vsnprintf+0x47>
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	7e 22                	jle    80071d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fb:	ff 75 14             	pushl  0x14(%ebp)
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	68 36 02 80 00       	push   $0x800236
  80070a:	e8 61 fb ff ff       	call   800270 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800712:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb 05                	jmp    800722 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072d:	50                   	push   %eax
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	ff 75 08             	pushl  0x8(%ebp)
  800737:	e8 9a ff ff ff       	call   8006d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	eb 03                	jmp    80074e <strlen+0x10>
		n++;
  80074b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800752:	75 f7                	jne    80074b <strlen+0xd>
		n++;
	return n;
}
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	ba 00 00 00 00       	mov    $0x0,%edx
  800764:	eb 03                	jmp    800769 <strnlen+0x13>
		n++;
  800766:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800769:	39 c2                	cmp    %eax,%edx
  80076b:	74 08                	je     800775 <strnlen+0x1f>
  80076d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800771:	75 f3                	jne    800766 <strnlen+0x10>
  800773:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	89 c2                	mov    %eax,%edx
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800790:	84 db                	test   %bl,%bl
  800792:	75 ef                	jne    800783 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079e:	53                   	push   %ebx
  80079f:	e8 9a ff ff ff       	call   80073e <strlen>
  8007a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a7:	ff 75 0c             	pushl  0xc(%ebp)
  8007aa:	01 d8                	add    %ebx,%eax
  8007ac:	50                   	push   %eax
  8007ad:	e8 c5 ff ff ff       	call   800777 <strcpy>
	return dst;
}
  8007b2:	89 d8                	mov    %ebx,%eax
  8007b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	56                   	push   %esi
  8007bd:	53                   	push   %ebx
  8007be:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c4:	89 f3                	mov    %esi,%ebx
  8007c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	89 f2                	mov    %esi,%edx
  8007cb:	eb 0f                	jmp    8007dc <strncpy+0x23>
		*dst++ = *src;
  8007cd:	83 c2 01             	add    $0x1,%edx
  8007d0:	0f b6 01             	movzbl (%ecx),%eax
  8007d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dc:	39 da                	cmp    %ebx,%edx
  8007de:	75 ed                	jne    8007cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 21                	je     80081b <strlcpy+0x35>
  8007fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 09                	jmp    80080b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	83 c1 01             	add    $0x1,%ecx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080b:	39 c2                	cmp    %eax,%edx
  80080d:	74 09                	je     800818 <strlcpy+0x32>
  80080f:	0f b6 19             	movzbl (%ecx),%ebx
  800812:	84 db                	test   %bl,%bl
  800814:	75 ec                	jne    800802 <strlcpy+0x1c>
  800816:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800818:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081b:	29 f0                	sub    %esi,%eax
}
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082a:	eb 06                	jmp    800832 <strcmp+0x11>
		p++, q++;
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800832:	0f b6 01             	movzbl (%ecx),%eax
  800835:	84 c0                	test   %al,%al
  800837:	74 04                	je     80083d <strcmp+0x1c>
  800839:	3a 02                	cmp    (%edx),%al
  80083b:	74 ef                	je     80082c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	0f b6 12             	movzbl (%edx),%edx
  800843:	29 d0                	sub    %edx,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	89 c3                	mov    %eax,%ebx
  800853:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800856:	eb 06                	jmp    80085e <strncmp+0x17>
		n--, p++, q++;
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085e:	39 d8                	cmp    %ebx,%eax
  800860:	74 15                	je     800877 <strncmp+0x30>
  800862:	0f b6 08             	movzbl (%eax),%ecx
  800865:	84 c9                	test   %cl,%cl
  800867:	74 04                	je     80086d <strncmp+0x26>
  800869:	3a 0a                	cmp    (%edx),%cl
  80086b:	74 eb                	je     800858 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 00             	movzbl (%eax),%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
  800875:	eb 05                	jmp    80087c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087c:	5b                   	pop    %ebx
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800889:	eb 07                	jmp    800892 <strchr+0x13>
		if (*s == c)
  80088b:	38 ca                	cmp    %cl,%dl
  80088d:	74 0f                	je     80089e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	0f b6 10             	movzbl (%eax),%edx
  800895:	84 d2                	test   %dl,%dl
  800897:	75 f2                	jne    80088b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	eb 03                	jmp    8008af <strfind+0xf>
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	74 04                	je     8008ba <strfind+0x1a>
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	75 f2                	jne    8008ac <strfind+0xc>
			break;
	return (char *) s;
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c8:	85 c9                	test   %ecx,%ecx
  8008ca:	74 36                	je     800902 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d2:	75 28                	jne    8008fc <memset+0x40>
  8008d4:	f6 c1 03             	test   $0x3,%cl
  8008d7:	75 23                	jne    8008fc <memset+0x40>
		c &= 0xFF;
  8008d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dd:	89 d3                	mov    %edx,%ebx
  8008df:	c1 e3 08             	shl    $0x8,%ebx
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	c1 e6 18             	shl    $0x18,%esi
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	c1 e0 10             	shl    $0x10,%eax
  8008ec:	09 f0                	or     %esi,%eax
  8008ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	09 d0                	or     %edx,%eax
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
  8008f7:	fc                   	cld    
  8008f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fa:	eb 06                	jmp    800902 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	fc                   	cld    
  800900:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800902:	89 f8                	mov    %edi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5f                   	pop    %edi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	57                   	push   %edi
  80090d:	56                   	push   %esi
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 75 0c             	mov    0xc(%ebp),%esi
  800914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800917:	39 c6                	cmp    %eax,%esi
  800919:	73 35                	jae    800950 <memmove+0x47>
  80091b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091e:	39 d0                	cmp    %edx,%eax
  800920:	73 2e                	jae    800950 <memmove+0x47>
		s += n;
		d += n;
  800922:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	89 d6                	mov    %edx,%esi
  800927:	09 fe                	or     %edi,%esi
  800929:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092f:	75 13                	jne    800944 <memmove+0x3b>
  800931:	f6 c1 03             	test   $0x3,%cl
  800934:	75 0e                	jne    800944 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800936:	83 ef 04             	sub    $0x4,%edi
  800939:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093c:	c1 e9 02             	shr    $0x2,%ecx
  80093f:	fd                   	std    
  800940:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800942:	eb 09                	jmp    80094d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800944:	83 ef 01             	sub    $0x1,%edi
  800947:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094a:	fd                   	std    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094d:	fc                   	cld    
  80094e:	eb 1d                	jmp    80096d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800950:	89 f2                	mov    %esi,%edx
  800952:	09 c2                	or     %eax,%edx
  800954:	f6 c2 03             	test   $0x3,%dl
  800957:	75 0f                	jne    800968 <memmove+0x5f>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 0a                	jne    800968 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095e:	c1 e9 02             	shr    $0x2,%ecx
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 05                	jmp    80096d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800968:	89 c7                	mov    %eax,%edi
  80096a:	fc                   	cld    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800974:	ff 75 10             	pushl  0x10(%ebp)
  800977:	ff 75 0c             	pushl  0xc(%ebp)
  80097a:	ff 75 08             	pushl  0x8(%ebp)
  80097d:	e8 87 ff ff ff       	call   800909 <memmove>
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 c6                	mov    %eax,%esi
  800991:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800994:	eb 1a                	jmp    8009b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800996:	0f b6 08             	movzbl (%eax),%ecx
  800999:	0f b6 1a             	movzbl (%edx),%ebx
  80099c:	38 d9                	cmp    %bl,%cl
  80099e:	74 0a                	je     8009aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a0:	0f b6 c1             	movzbl %cl,%eax
  8009a3:	0f b6 db             	movzbl %bl,%ebx
  8009a6:	29 d8                	sub    %ebx,%eax
  8009a8:	eb 0f                	jmp    8009b9 <memcmp+0x35>
		s1++, s2++;
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b0:	39 f0                	cmp    %esi,%eax
  8009b2:	75 e2                	jne    800996 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	53                   	push   %ebx
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c4:	89 c1                	mov    %eax,%ecx
  8009c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cd:	eb 0a                	jmp    8009d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cf:	0f b6 10             	movzbl (%eax),%edx
  8009d2:	39 da                	cmp    %ebx,%edx
  8009d4:	74 07                	je     8009dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	39 c8                	cmp    %ecx,%eax
  8009db:	72 f2                	jb     8009cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ec:	eb 03                	jmp    8009f1 <strtol+0x11>
		s++;
  8009ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f1:	0f b6 01             	movzbl (%ecx),%eax
  8009f4:	3c 20                	cmp    $0x20,%al
  8009f6:	74 f6                	je     8009ee <strtol+0xe>
  8009f8:	3c 09                	cmp    $0x9,%al
  8009fa:	74 f2                	je     8009ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fc:	3c 2b                	cmp    $0x2b,%al
  8009fe:	75 0a                	jne    800a0a <strtol+0x2a>
		s++;
  800a00:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
  800a08:	eb 11                	jmp    800a1b <strtol+0x3b>
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0f:	3c 2d                	cmp    $0x2d,%al
  800a11:	75 08                	jne    800a1b <strtol+0x3b>
		s++, neg = 1;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a21:	75 15                	jne    800a38 <strtol+0x58>
  800a23:	80 39 30             	cmpb   $0x30,(%ecx)
  800a26:	75 10                	jne    800a38 <strtol+0x58>
  800a28:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2c:	75 7c                	jne    800aaa <strtol+0xca>
		s += 2, base = 16;
  800a2e:	83 c1 02             	add    $0x2,%ecx
  800a31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a36:	eb 16                	jmp    800a4e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	75 12                	jne    800a4e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	75 08                	jne    800a4e <strtol+0x6e>
		s++, base = 8;
  800a46:	83 c1 01             	add    $0x1,%ecx
  800a49:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5c:	89 f3                	mov    %esi,%ebx
  800a5e:	80 fb 09             	cmp    $0x9,%bl
  800a61:	77 08                	ja     800a6b <strtol+0x8b>
			dig = *s - '0';
  800a63:	0f be d2             	movsbl %dl,%edx
  800a66:	83 ea 30             	sub    $0x30,%edx
  800a69:	eb 22                	jmp    800a8d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	80 fb 19             	cmp    $0x19,%bl
  800a73:	77 08                	ja     800a7d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 57             	sub    $0x57,%edx
  800a7b:	eb 10                	jmp    800a8d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 16                	ja     800a9d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a90:	7d 0b                	jge    800a9d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a99:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9b:	eb b9                	jmp    800a56 <strtol+0x76>

	if (endptr)
  800a9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa1:	74 0d                	je     800ab0 <strtol+0xd0>
		*endptr = (char *) s;
  800aa3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa6:	89 0e                	mov    %ecx,(%esi)
  800aa8:	eb 06                	jmp    800ab0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	74 98                	je     800a46 <strtol+0x66>
  800aae:	eb 9e                	jmp    800a4e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab0:	89 c2                	mov    %eax,%edx
  800ab2:	f7 da                	neg    %edx
  800ab4:	85 ff                	test   %edi,%edi
  800ab6:	0f 45 c2             	cmovne %edx,%eax
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	89 c3                	mov    %eax,%ebx
  800ad1:	89 c7                	mov    %eax,%edi
  800ad3:	89 c6                	mov    %eax,%esi
  800ad5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_cgetc>:

int
sys_cgetc(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 01 00 00 00       	mov    $0x1,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b09:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	89 cb                	mov    %ecx,%ebx
  800b13:	89 cf                	mov    %ecx,%edi
  800b15:	89 ce                	mov    %ecx,%esi
  800b17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	7e 17                	jle    800b34 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	50                   	push   %eax
  800b21:	6a 03                	push   $0x3
  800b23:	68 3f 22 80 00       	push   $0x80223f
  800b28:	6a 23                	push   $0x23
  800b2a:	68 5c 22 80 00       	push   $0x80225c
  800b2f:	e8 c1 0f 00 00       	call   801af5 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4c:	89 d1                	mov    %edx,%ecx
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	89 d7                	mov    %edx,%edi
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_yield>:

void
sys_yield(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	be 00 00 00 00       	mov    $0x0,%esi
  800b88:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b96:	89 f7                	mov    %esi,%edi
  800b98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 17                	jle    800bb5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 04                	push   $0x4
  800ba4:	68 3f 22 80 00       	push   $0x80223f
  800ba9:	6a 23                	push   $0x23
  800bab:	68 5c 22 80 00       	push   $0x80225c
  800bb0:	e8 40 0f 00 00       	call   801af5 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 05                	push   $0x5
  800be6:	68 3f 22 80 00       	push   $0x80223f
  800beb:	6a 23                	push   $0x23
  800bed:	68 5c 22 80 00       	push   $0x80225c
  800bf2:	e8 fe 0e 00 00       	call   801af5 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 df                	mov    %ebx,%edi
  800c1a:	89 de                	mov    %ebx,%esi
  800c1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 06                	push   $0x6
  800c28:	68 3f 22 80 00       	push   $0x80223f
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 5c 22 80 00       	push   $0x80225c
  800c34:	e8 bc 0e 00 00       	call   801af5 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	89 de                	mov    %ebx,%esi
  800c5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 08                	push   $0x8
  800c6a:	68 3f 22 80 00       	push   $0x80223f
  800c6f:	6a 23                	push   $0x23
  800c71:	68 5c 22 80 00       	push   $0x80225c
  800c76:	e8 7a 0e 00 00       	call   801af5 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 09 00 00 00       	mov    $0x9,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 09                	push   $0x9
  800cac:	68 3f 22 80 00       	push   $0x80223f
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 5c 22 80 00       	push   $0x80225c
  800cb8:	e8 38 0e 00 00       	call   801af5 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 df                	mov    %ebx,%edi
  800ce0:	89 de                	mov    %ebx,%esi
  800ce2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 0a                	push   $0xa
  800cee:	68 3f 22 80 00       	push   $0x80223f
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 5c 22 80 00       	push   $0x80225c
  800cfa:	e8 f6 0d 00 00       	call   801af5 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	be 00 00 00 00       	mov    $0x0,%esi
  800d12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d23:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d38:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 cb                	mov    %ecx,%ebx
  800d42:	89 cf                	mov    %ecx,%edi
  800d44:	89 ce                	mov    %ecx,%esi
  800d46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7e 17                	jle    800d63 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 0d                	push   $0xd
  800d52:	68 3f 22 80 00       	push   $0x80223f
  800d57:	6a 23                	push   $0x23
  800d59:	68 5c 22 80 00       	push   $0x80225c
  800d5e:	e8 92 0d 00 00       	call   801af5 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
// 页错误处理函数的设置函数
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 04             	sub    $0x4,%esp
	int r;
	int envid=sys_getenvid();
  800d72:	e8 c5 fd ff ff       	call   800b3c <sys_getenvid>
  800d77:	89 c3                	mov    %eax,%ebx
	if (_pgfault_handler == 0) {
  800d79:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d80:	75 29                	jne    800dab <set_pgfault_handler+0x40>
		// First time through!
		// LAB 4: Your code here.
		// panic("set_pgfault_handler not implemented"); 
		// 分配异常栈
		if ((r = sys_page_alloc(envid, (void *) (UXSTACKTOP-PGSIZE), 
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	6a 07                	push   $0x7
  800d87:	68 00 f0 bf ee       	push   $0xeebff000
  800d8c:	50                   	push   %eax
  800d8d:	e8 e8 fd ff ff       	call   800b7a <sys_page_alloc>
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	79 12                	jns    800dab <set_pgfault_handler+0x40>
				PTE_W | PTE_U | PTE_P)) < 0)
			panic("set_pgfault_handler: %e\n", r);
  800d99:	50                   	push   %eax
  800d9a:	68 6a 22 80 00       	push   $0x80226a
  800d9f:	6a 24                	push   $0x24
  800da1:	68 83 22 80 00       	push   $0x802283
  800da6:	e8 4a 0d 00 00       	call   801af5 <_panic>
	}

	// Save handler pointer for assembly to call.
	// 将用户自定义的页错误处理函数注册到_pgfault_upcall
	// _pgfault_handler是_pgfault_upcall里会调用的一个函数
	_pgfault_handler = handler;
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	a3 08 40 80 00       	mov    %eax,0x804008
	
	// 注册页错误处理到进程结构
	if ((r = sys_env_set_pgfault_upcall(envid, _pgfault_upcall)) < 0)
  800db3:	83 ec 08             	sub    $0x8,%esp
  800db6:	68 df 0d 80 00       	push   $0x800ddf
  800dbb:	53                   	push   %ebx
  800dbc:	e8 04 ff ff ff       	call   800cc5 <sys_env_set_pgfault_upcall>
  800dc1:	83 c4 10             	add    $0x10,%esp
  800dc4:	85 c0                	test   %eax,%eax
  800dc6:	79 12                	jns    800dda <set_pgfault_handler+0x6f>
		panic("set_pgfault_handler: %e\n", r);
  800dc8:	50                   	push   %eax
  800dc9:	68 6a 22 80 00       	push   $0x80226a
  800dce:	6a 2e                	push   $0x2e
  800dd0:	68 83 22 80 00       	push   $0x802283
  800dd5:	e8 1b 0d 00 00       	call   801af5 <_panic>
}
  800dda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ddd:	c9                   	leave  
  800dde:	c3                   	ret    

00800ddf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800ddf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800de0:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800de5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800de7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 48(%esp), %eax
  800dea:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  800dee:	83 e8 04             	sub    $0x4,%eax
	movl 40(%esp), %edx
  800df1:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800df5:	89 10                	mov    %edx,(%eax)
	movl %eax, 48(%esp)
  800df7:	89 44 24 30          	mov    %eax,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800dfb:	83 c4 08             	add    $0x8,%esp
	popal
  800dfe:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800dff:	83 c4 04             	add    $0x4,%esp
	popfl
  800e02:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	// 恢复错误现场运行堆栈
	popl %esp
  800e03:	5c                   	pop    %esp

	// 返回错误现场继续执行
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  800e04:	c3                   	ret    

00800e05 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e10:	c1 e8 0c             	shr    $0xc,%eax
}
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    

00800e15 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e18:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1b:	05 00 00 00 30       	add    $0x30000000,%eax
  800e20:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e25:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e2a:	5d                   	pop    %ebp
  800e2b:	c3                   	ret    

00800e2c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e2c:	55                   	push   %ebp
  800e2d:	89 e5                	mov    %esp,%ebp
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e37:	89 c2                	mov    %eax,%edx
  800e39:	c1 ea 16             	shr    $0x16,%edx
  800e3c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e43:	f6 c2 01             	test   $0x1,%dl
  800e46:	74 11                	je     800e59 <fd_alloc+0x2d>
  800e48:	89 c2                	mov    %eax,%edx
  800e4a:	c1 ea 0c             	shr    $0xc,%edx
  800e4d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e54:	f6 c2 01             	test   $0x1,%dl
  800e57:	75 09                	jne    800e62 <fd_alloc+0x36>
			*fd_store = fd;
  800e59:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e5b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e60:	eb 17                	jmp    800e79 <fd_alloc+0x4d>
  800e62:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e67:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e6c:	75 c9                	jne    800e37 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e6e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e74:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e79:	5d                   	pop    %ebp
  800e7a:	c3                   	ret    

00800e7b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e7b:	55                   	push   %ebp
  800e7c:	89 e5                	mov    %esp,%ebp
  800e7e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e81:	83 f8 1f             	cmp    $0x1f,%eax
  800e84:	77 36                	ja     800ebc <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e86:	c1 e0 0c             	shl    $0xc,%eax
  800e89:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e8e:	89 c2                	mov    %eax,%edx
  800e90:	c1 ea 16             	shr    $0x16,%edx
  800e93:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e9a:	f6 c2 01             	test   $0x1,%dl
  800e9d:	74 24                	je     800ec3 <fd_lookup+0x48>
  800e9f:	89 c2                	mov    %eax,%edx
  800ea1:	c1 ea 0c             	shr    $0xc,%edx
  800ea4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800eab:	f6 c2 01             	test   $0x1,%dl
  800eae:	74 1a                	je     800eca <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800eb0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eb3:	89 02                	mov    %eax,(%edx)
	return 0;
  800eb5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eba:	eb 13                	jmp    800ecf <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ebc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec1:	eb 0c                	jmp    800ecf <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ec3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ec8:	eb 05                	jmp    800ecf <fd_lookup+0x54>
  800eca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eda:	ba 10 23 80 00       	mov    $0x802310,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800edf:	eb 13                	jmp    800ef4 <dev_lookup+0x23>
  800ee1:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ee4:	39 08                	cmp    %ecx,(%eax)
  800ee6:	75 0c                	jne    800ef4 <dev_lookup+0x23>
			*dev = devtab[i];
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eed:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef2:	eb 2e                	jmp    800f22 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ef4:	8b 02                	mov    (%edx),%eax
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	75 e7                	jne    800ee1 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800efa:	a1 04 40 80 00       	mov    0x804004,%eax
  800eff:	8b 40 48             	mov    0x48(%eax),%eax
  800f02:	83 ec 04             	sub    $0x4,%esp
  800f05:	51                   	push   %ecx
  800f06:	50                   	push   %eax
  800f07:	68 94 22 80 00       	push   $0x802294
  800f0c:	e8 62 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800f11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f14:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f1a:	83 c4 10             	add    $0x10,%esp
  800f1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f22:	c9                   	leave  
  800f23:	c3                   	ret    

00800f24 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	56                   	push   %esi
  800f28:	53                   	push   %ebx
  800f29:	83 ec 10             	sub    $0x10,%esp
  800f2c:	8b 75 08             	mov    0x8(%ebp),%esi
  800f2f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f35:	50                   	push   %eax
  800f36:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f3c:	c1 e8 0c             	shr    $0xc,%eax
  800f3f:	50                   	push   %eax
  800f40:	e8 36 ff ff ff       	call   800e7b <fd_lookup>
  800f45:	83 c4 08             	add    $0x8,%esp
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	78 05                	js     800f51 <fd_close+0x2d>
	    || fd != fd2)
  800f4c:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f4f:	74 0c                	je     800f5d <fd_close+0x39>
		return (must_exist ? r : 0);
  800f51:	84 db                	test   %bl,%bl
  800f53:	ba 00 00 00 00       	mov    $0x0,%edx
  800f58:	0f 44 c2             	cmove  %edx,%eax
  800f5b:	eb 41                	jmp    800f9e <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f5d:	83 ec 08             	sub    $0x8,%esp
  800f60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f63:	50                   	push   %eax
  800f64:	ff 36                	pushl  (%esi)
  800f66:	e8 66 ff ff ff       	call   800ed1 <dev_lookup>
  800f6b:	89 c3                	mov    %eax,%ebx
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	85 c0                	test   %eax,%eax
  800f72:	78 1a                	js     800f8e <fd_close+0x6a>
		if (dev->dev_close)
  800f74:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f77:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f7a:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f7f:	85 c0                	test   %eax,%eax
  800f81:	74 0b                	je     800f8e <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f83:	83 ec 0c             	sub    $0xc,%esp
  800f86:	56                   	push   %esi
  800f87:	ff d0                	call   *%eax
  800f89:	89 c3                	mov    %eax,%ebx
  800f8b:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f8e:	83 ec 08             	sub    $0x8,%esp
  800f91:	56                   	push   %esi
  800f92:	6a 00                	push   $0x0
  800f94:	e8 66 fc ff ff       	call   800bff <sys_page_unmap>
	return r;
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	89 d8                	mov    %ebx,%eax
}
  800f9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fa1:	5b                   	pop    %ebx
  800fa2:	5e                   	pop    %esi
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fae:	50                   	push   %eax
  800faf:	ff 75 08             	pushl  0x8(%ebp)
  800fb2:	e8 c4 fe ff ff       	call   800e7b <fd_lookup>
  800fb7:	83 c4 08             	add    $0x8,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	78 10                	js     800fce <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fbe:	83 ec 08             	sub    $0x8,%esp
  800fc1:	6a 01                	push   $0x1
  800fc3:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc6:	e8 59 ff ff ff       	call   800f24 <fd_close>
  800fcb:	83 c4 10             	add    $0x10,%esp
}
  800fce:	c9                   	leave  
  800fcf:	c3                   	ret    

00800fd0 <close_all>:

void
close_all(void)
{
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	53                   	push   %ebx
  800fd4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fdc:	83 ec 0c             	sub    $0xc,%esp
  800fdf:	53                   	push   %ebx
  800fe0:	e8 c0 ff ff ff       	call   800fa5 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fe5:	83 c3 01             	add    $0x1,%ebx
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	83 fb 20             	cmp    $0x20,%ebx
  800fee:	75 ec                	jne    800fdc <close_all+0xc>
		close(i);
}
  800ff0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	57                   	push   %edi
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	83 ec 2c             	sub    $0x2c,%esp
  800ffe:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801001:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	ff 75 08             	pushl  0x8(%ebp)
  801008:	e8 6e fe ff ff       	call   800e7b <fd_lookup>
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	85 c0                	test   %eax,%eax
  801012:	0f 88 c1 00 00 00    	js     8010d9 <dup+0xe4>
		return r;
	close(newfdnum);
  801018:	83 ec 0c             	sub    $0xc,%esp
  80101b:	56                   	push   %esi
  80101c:	e8 84 ff ff ff       	call   800fa5 <close>

	newfd = INDEX2FD(newfdnum);
  801021:	89 f3                	mov    %esi,%ebx
  801023:	c1 e3 0c             	shl    $0xc,%ebx
  801026:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80102c:	83 c4 04             	add    $0x4,%esp
  80102f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801032:	e8 de fd ff ff       	call   800e15 <fd2data>
  801037:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801039:	89 1c 24             	mov    %ebx,(%esp)
  80103c:	e8 d4 fd ff ff       	call   800e15 <fd2data>
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801047:	89 f8                	mov    %edi,%eax
  801049:	c1 e8 16             	shr    $0x16,%eax
  80104c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801053:	a8 01                	test   $0x1,%al
  801055:	74 37                	je     80108e <dup+0x99>
  801057:	89 f8                	mov    %edi,%eax
  801059:	c1 e8 0c             	shr    $0xc,%eax
  80105c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801063:	f6 c2 01             	test   $0x1,%dl
  801066:	74 26                	je     80108e <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801068:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	25 07 0e 00 00       	and    $0xe07,%eax
  801077:	50                   	push   %eax
  801078:	ff 75 d4             	pushl  -0x2c(%ebp)
  80107b:	6a 00                	push   $0x0
  80107d:	57                   	push   %edi
  80107e:	6a 00                	push   $0x0
  801080:	e8 38 fb ff ff       	call   800bbd <sys_page_map>
  801085:	89 c7                	mov    %eax,%edi
  801087:	83 c4 20             	add    $0x20,%esp
  80108a:	85 c0                	test   %eax,%eax
  80108c:	78 2e                	js     8010bc <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80108e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801091:	89 d0                	mov    %edx,%eax
  801093:	c1 e8 0c             	shr    $0xc,%eax
  801096:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109d:	83 ec 0c             	sub    $0xc,%esp
  8010a0:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a5:	50                   	push   %eax
  8010a6:	53                   	push   %ebx
  8010a7:	6a 00                	push   $0x0
  8010a9:	52                   	push   %edx
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 0c fb ff ff       	call   800bbd <sys_page_map>
  8010b1:	89 c7                	mov    %eax,%edi
  8010b3:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010b6:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010b8:	85 ff                	test   %edi,%edi
  8010ba:	79 1d                	jns    8010d9 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010bc:	83 ec 08             	sub    $0x8,%esp
  8010bf:	53                   	push   %ebx
  8010c0:	6a 00                	push   $0x0
  8010c2:	e8 38 fb ff ff       	call   800bff <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010c7:	83 c4 08             	add    $0x8,%esp
  8010ca:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010cd:	6a 00                	push   $0x0
  8010cf:	e8 2b fb ff ff       	call   800bff <sys_page_unmap>
	return r;
  8010d4:	83 c4 10             	add    $0x10,%esp
  8010d7:	89 f8                	mov    %edi,%eax
}
  8010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010dc:	5b                   	pop    %ebx
  8010dd:	5e                   	pop    %esi
  8010de:	5f                   	pop    %edi
  8010df:	5d                   	pop    %ebp
  8010e0:	c3                   	ret    

008010e1 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e1:	55                   	push   %ebp
  8010e2:	89 e5                	mov    %esp,%ebp
  8010e4:	53                   	push   %ebx
  8010e5:	83 ec 14             	sub    $0x14,%esp
  8010e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010ee:	50                   	push   %eax
  8010ef:	53                   	push   %ebx
  8010f0:	e8 86 fd ff ff       	call   800e7b <fd_lookup>
  8010f5:	83 c4 08             	add    $0x8,%esp
  8010f8:	89 c2                	mov    %eax,%edx
  8010fa:	85 c0                	test   %eax,%eax
  8010fc:	78 6d                	js     80116b <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010fe:	83 ec 08             	sub    $0x8,%esp
  801101:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801108:	ff 30                	pushl  (%eax)
  80110a:	e8 c2 fd ff ff       	call   800ed1 <dev_lookup>
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 4c                	js     801162 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801116:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801119:	8b 42 08             	mov    0x8(%edx),%eax
  80111c:	83 e0 03             	and    $0x3,%eax
  80111f:	83 f8 01             	cmp    $0x1,%eax
  801122:	75 21                	jne    801145 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801124:	a1 04 40 80 00       	mov    0x804004,%eax
  801129:	8b 40 48             	mov    0x48(%eax),%eax
  80112c:	83 ec 04             	sub    $0x4,%esp
  80112f:	53                   	push   %ebx
  801130:	50                   	push   %eax
  801131:	68 d5 22 80 00       	push   $0x8022d5
  801136:	e8 38 f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801143:	eb 26                	jmp    80116b <read+0x8a>
	}
	if (!dev->dev_read)
  801145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801148:	8b 40 08             	mov    0x8(%eax),%eax
  80114b:	85 c0                	test   %eax,%eax
  80114d:	74 17                	je     801166 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	ff 75 10             	pushl  0x10(%ebp)
  801155:	ff 75 0c             	pushl  0xc(%ebp)
  801158:	52                   	push   %edx
  801159:	ff d0                	call   *%eax
  80115b:	89 c2                	mov    %eax,%edx
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	eb 09                	jmp    80116b <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801162:	89 c2                	mov    %eax,%edx
  801164:	eb 05                	jmp    80116b <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801166:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  80116b:	89 d0                	mov    %edx,%eax
  80116d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801170:	c9                   	leave  
  801171:	c3                   	ret    

00801172 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 0c             	sub    $0xc,%esp
  80117b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801181:	bb 00 00 00 00       	mov    $0x0,%ebx
  801186:	eb 21                	jmp    8011a9 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801188:	83 ec 04             	sub    $0x4,%esp
  80118b:	89 f0                	mov    %esi,%eax
  80118d:	29 d8                	sub    %ebx,%eax
  80118f:	50                   	push   %eax
  801190:	89 d8                	mov    %ebx,%eax
  801192:	03 45 0c             	add    0xc(%ebp),%eax
  801195:	50                   	push   %eax
  801196:	57                   	push   %edi
  801197:	e8 45 ff ff ff       	call   8010e1 <read>
		if (m < 0)
  80119c:	83 c4 10             	add    $0x10,%esp
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	78 10                	js     8011b3 <readn+0x41>
			return m;
		if (m == 0)
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	74 0a                	je     8011b1 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011a7:	01 c3                	add    %eax,%ebx
  8011a9:	39 f3                	cmp    %esi,%ebx
  8011ab:	72 db                	jb     801188 <readn+0x16>
  8011ad:	89 d8                	mov    %ebx,%eax
  8011af:	eb 02                	jmp    8011b3 <readn+0x41>
  8011b1:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b6:	5b                   	pop    %ebx
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    

008011bb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011bb:	55                   	push   %ebp
  8011bc:	89 e5                	mov    %esp,%ebp
  8011be:	53                   	push   %ebx
  8011bf:	83 ec 14             	sub    $0x14,%esp
  8011c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	53                   	push   %ebx
  8011ca:	e8 ac fc ff ff       	call   800e7b <fd_lookup>
  8011cf:	83 c4 08             	add    $0x8,%esp
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 68                	js     801240 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	ff 30                	pushl  (%eax)
  8011e4:	e8 e8 fc ff ff       	call   800ed1 <dev_lookup>
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 47                	js     801237 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f7:	75 21                	jne    80121a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f9:	a1 04 40 80 00       	mov    0x804004,%eax
  8011fe:	8b 40 48             	mov    0x48(%eax),%eax
  801201:	83 ec 04             	sub    $0x4,%esp
  801204:	53                   	push   %ebx
  801205:	50                   	push   %eax
  801206:	68 f1 22 80 00       	push   $0x8022f1
  80120b:	e8 63 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801210:	83 c4 10             	add    $0x10,%esp
  801213:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801218:	eb 26                	jmp    801240 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80121a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121d:	8b 52 0c             	mov    0xc(%edx),%edx
  801220:	85 d2                	test   %edx,%edx
  801222:	74 17                	je     80123b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801224:	83 ec 04             	sub    $0x4,%esp
  801227:	ff 75 10             	pushl  0x10(%ebp)
  80122a:	ff 75 0c             	pushl  0xc(%ebp)
  80122d:	50                   	push   %eax
  80122e:	ff d2                	call   *%edx
  801230:	89 c2                	mov    %eax,%edx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	eb 09                	jmp    801240 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801237:	89 c2                	mov    %eax,%edx
  801239:	eb 05                	jmp    801240 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80123b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801240:	89 d0                	mov    %edx,%eax
  801242:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <seek>:

int
seek(int fdnum, off_t offset)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80124d:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801250:	50                   	push   %eax
  801251:	ff 75 08             	pushl  0x8(%ebp)
  801254:	e8 22 fc ff ff       	call   800e7b <fd_lookup>
  801259:	83 c4 08             	add    $0x8,%esp
  80125c:	85 c0                	test   %eax,%eax
  80125e:	78 0e                	js     80126e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801260:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801263:	8b 55 0c             	mov    0xc(%ebp),%edx
  801266:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801269:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126e:	c9                   	leave  
  80126f:	c3                   	ret    

00801270 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	53                   	push   %ebx
  801274:	83 ec 14             	sub    $0x14,%esp
  801277:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	53                   	push   %ebx
  80127f:	e8 f7 fb ff ff       	call   800e7b <fd_lookup>
  801284:	83 c4 08             	add    $0x8,%esp
  801287:	89 c2                	mov    %eax,%edx
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 65                	js     8012f2 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128d:	83 ec 08             	sub    $0x8,%esp
  801290:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801293:	50                   	push   %eax
  801294:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801297:	ff 30                	pushl  (%eax)
  801299:	e8 33 fc ff ff       	call   800ed1 <dev_lookup>
  80129e:	83 c4 10             	add    $0x10,%esp
  8012a1:	85 c0                	test   %eax,%eax
  8012a3:	78 44                	js     8012e9 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012ac:	75 21                	jne    8012cf <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012ae:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b3:	8b 40 48             	mov    0x48(%eax),%eax
  8012b6:	83 ec 04             	sub    $0x4,%esp
  8012b9:	53                   	push   %ebx
  8012ba:	50                   	push   %eax
  8012bb:	68 b4 22 80 00       	push   $0x8022b4
  8012c0:	e8 ae ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012cd:	eb 23                	jmp    8012f2 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d2:	8b 52 18             	mov    0x18(%edx),%edx
  8012d5:	85 d2                	test   %edx,%edx
  8012d7:	74 14                	je     8012ed <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	ff 75 0c             	pushl  0xc(%ebp)
  8012df:	50                   	push   %eax
  8012e0:	ff d2                	call   *%edx
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	eb 09                	jmp    8012f2 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	eb 05                	jmp    8012f2 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012ed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012f2:	89 d0                	mov    %edx,%eax
  8012f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f7:	c9                   	leave  
  8012f8:	c3                   	ret    

008012f9 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 14             	sub    $0x14,%esp
  801300:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	ff 75 08             	pushl  0x8(%ebp)
  80130a:	e8 6c fb ff ff       	call   800e7b <fd_lookup>
  80130f:	83 c4 08             	add    $0x8,%esp
  801312:	89 c2                	mov    %eax,%edx
  801314:	85 c0                	test   %eax,%eax
  801316:	78 58                	js     801370 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131e:	50                   	push   %eax
  80131f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801322:	ff 30                	pushl  (%eax)
  801324:	e8 a8 fb ff ff       	call   800ed1 <dev_lookup>
  801329:	83 c4 10             	add    $0x10,%esp
  80132c:	85 c0                	test   %eax,%eax
  80132e:	78 37                	js     801367 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801330:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801333:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801337:	74 32                	je     80136b <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801339:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80133c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801343:	00 00 00 
	stat->st_isdir = 0;
  801346:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80134d:	00 00 00 
	stat->st_dev = dev;
  801350:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	53                   	push   %ebx
  80135a:	ff 75 f0             	pushl  -0x10(%ebp)
  80135d:	ff 50 14             	call   *0x14(%eax)
  801360:	89 c2                	mov    %eax,%edx
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	eb 09                	jmp    801370 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801367:	89 c2                	mov    %eax,%edx
  801369:	eb 05                	jmp    801370 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80136b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801370:	89 d0                	mov    %edx,%eax
  801372:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801375:	c9                   	leave  
  801376:	c3                   	ret    

00801377 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801377:	55                   	push   %ebp
  801378:	89 e5                	mov    %esp,%ebp
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80137c:	83 ec 08             	sub    $0x8,%esp
  80137f:	6a 00                	push   $0x0
  801381:	ff 75 08             	pushl  0x8(%ebp)
  801384:	e8 e9 01 00 00       	call   801572 <open>
  801389:	89 c3                	mov    %eax,%ebx
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 1b                	js     8013ad <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801392:	83 ec 08             	sub    $0x8,%esp
  801395:	ff 75 0c             	pushl  0xc(%ebp)
  801398:	50                   	push   %eax
  801399:	e8 5b ff ff ff       	call   8012f9 <fstat>
  80139e:	89 c6                	mov    %eax,%esi
	close(fd);
  8013a0:	89 1c 24             	mov    %ebx,(%esp)
  8013a3:	e8 fd fb ff ff       	call   800fa5 <close>
	return r;
  8013a8:	83 c4 10             	add    $0x10,%esp
  8013ab:	89 f0                	mov    %esi,%eax
}
  8013ad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	56                   	push   %esi
  8013b8:	53                   	push   %ebx
  8013b9:	89 c6                	mov    %eax,%esi
  8013bb:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013bd:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013c4:	75 12                	jne    8013d8 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	6a 01                	push   $0x1
  8013cb:	e8 41 08 00 00       	call   801c11 <ipc_find_env>
  8013d0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d5:	83 c4 10             	add    $0x10,%esp
	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	// xiang wen jian jing cheng fa song yi ge xiao xi qing  qingqiu du 
	// fa song cao zuo qing qing qiu
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013d8:	6a 07                	push   $0x7
  8013da:	68 00 50 80 00       	push   $0x805000
  8013df:	56                   	push   %esi
  8013e0:	ff 35 00 40 80 00    	pushl  0x804000
  8013e6:	e8 d2 07 00 00       	call   801bbd <ipc_send>
	// deng dai fa hui jie guo 
	return ipc_recv(NULL, dstva, NULL);
  8013eb:	83 c4 0c             	add    $0xc,%esp
  8013ee:	6a 00                	push   $0x0
  8013f0:	53                   	push   %ebx
  8013f1:	6a 00                	push   $0x0
  8013f3:	e8 43 07 00 00       	call   801b3b <ipc_recv>
}
  8013f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fb:	5b                   	pop    %ebx
  8013fc:	5e                   	pop    %esi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    

008013ff <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	8b 40 0c             	mov    0xc(%eax),%eax
  80140b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801410:	8b 45 0c             	mov    0xc(%ebp),%eax
  801413:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801418:	ba 00 00 00 00       	mov    $0x0,%edx
  80141d:	b8 02 00 00 00       	mov    $0x2,%eax
  801422:	e8 8d ff ff ff       	call   8013b4 <fsipc>
}
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	8b 40 0c             	mov    0xc(%eax),%eax
  801435:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80143a:	ba 00 00 00 00       	mov    $0x0,%edx
  80143f:	b8 06 00 00 00       	mov    $0x6,%eax
  801444:	e8 6b ff ff ff       	call   8013b4 <fsipc>
}
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <devfile_stat>:
    return r;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80144b:	55                   	push   %ebp
  80144c:	89 e5                	mov    %esp,%ebp
  80144e:	53                   	push   %ebx
  80144f:	83 ec 04             	sub    $0x4,%esp
  801452:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801455:	8b 45 08             	mov    0x8(%ebp),%eax
  801458:	8b 40 0c             	mov    0xc(%eax),%eax
  80145b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801460:	ba 00 00 00 00       	mov    $0x0,%edx
  801465:	b8 05 00 00 00       	mov    $0x5,%eax
  80146a:	e8 45 ff ff ff       	call   8013b4 <fsipc>
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 2c                	js     80149f <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	68 00 50 80 00       	push   $0x805000
  80147b:	53                   	push   %ebx
  80147c:	e8 f6 f2 ff ff       	call   800777 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801481:	a1 80 50 80 00       	mov    0x805080,%eax
  801486:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80148c:	a1 84 50 80 00       	mov    0x805084,%eax
  801491:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801497:	83 c4 10             	add    $0x10,%esp
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <devfile_write>:
//	 The number of bytes successfully written.
//	 < 0 on error.
// 用户态写文件
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 0c             	sub    $0xc,%esp
  8014aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8014ad:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014b2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014b7:	0f 47 c2             	cmova  %edx,%eax
    int r;

    // 构造数据页
    if (n > sizeof(fsipcbuf.write.req_buf))
            n = sizeof(fsipcbuf.write.req_buf);
    fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8014bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8014c0:	89 15 00 50 80 00    	mov    %edx,0x805000
    fsipcbuf.write.req_n = n;
  8014c6:	a3 04 50 80 00       	mov    %eax,0x805004
    // 将 buf 的内容写到 fsipcbuf，fsipcbuf只是临时存储,一个中介
    memmove(fsipcbuf.write.req_buf, buf, n);
  8014cb:	50                   	push   %eax
  8014cc:	ff 75 0c             	pushl  0xc(%ebp)
  8014cf:	68 08 50 80 00       	push   $0x805008
  8014d4:	e8 30 f4 ff ff       	call   800909 <memmove>
    // 发送文件操作请求
    if ((r = fsipc(FSREQ_WRITE, NULL)) < 0)
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	b8 04 00 00 00       	mov    $0x4,%eax
  8014e3:	e8 cc fe ff ff       	call   8013b4 <fsipc>
            return r;

    return r;
}
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <devfile_read>:
// 	The number of bytes successfully read.
// 	< 0 on error.
// 用户态读文件
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	56                   	push   %esi
  8014ee:	53                   	push   %ebx
  8014ef:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;
        // 构造请求数据页
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8014f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014fd:	89 35 04 50 80 00    	mov    %esi,0x805004
	// du wen jian
	// 发送请求
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801503:	ba 00 00 00 00       	mov    $0x0,%edx
  801508:	b8 03 00 00 00       	mov    $0x3,%eax
  80150d:	e8 a2 fe ff ff       	call   8013b4 <fsipc>
  801512:	89 c3                	mov    %eax,%ebx
  801514:	85 c0                	test   %eax,%eax
  801516:	78 51                	js     801569 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  801518:	39 c6                	cmp    %eax,%esi
  80151a:	73 19                	jae    801535 <devfile_read+0x4b>
  80151c:	68 20 23 80 00       	push   $0x802320
  801521:	68 27 23 80 00       	push   $0x802327
  801526:	68 82 00 00 00       	push   $0x82
  80152b:	68 3c 23 80 00       	push   $0x80233c
  801530:	e8 c0 05 00 00       	call   801af5 <_panic>
	assert(r <= PGSIZE);
  801535:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80153a:	7e 19                	jle    801555 <devfile_read+0x6b>
  80153c:	68 47 23 80 00       	push   $0x802347
  801541:	68 27 23 80 00       	push   $0x802327
  801546:	68 83 00 00 00       	push   $0x83
  80154b:	68 3c 23 80 00       	push   $0x80233c
  801550:	e8 a0 05 00 00       	call   801af5 <_panic>
	// 将fsipcbuf的内容写到buf
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801555:	83 ec 04             	sub    $0x4,%esp
  801558:	50                   	push   %eax
  801559:	68 00 50 80 00       	push   $0x805000
  80155e:	ff 75 0c             	pushl  0xc(%ebp)
  801561:	e8 a3 f3 ff ff       	call   800909 <memmove>
	return r;
  801566:	83 c4 10             	add    $0x10,%esp
}
  801569:	89 d8                	mov    %ebx,%eax
  80156b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80156e:	5b                   	pop    %ebx
  80156f:	5e                   	pop    %esi
  801570:	5d                   	pop    %ebp
  801571:	c3                   	ret    

00801572 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	53                   	push   %ebx
  801576:	83 ec 20             	sub    $0x20,%esp
  801579:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80157c:	53                   	push   %ebx
  80157d:	e8 bc f1 ff ff       	call   80073e <strlen>
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80158a:	7f 67                	jg     8015f3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80158c:	83 ec 0c             	sub    $0xc,%esp
  80158f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801592:	50                   	push   %eax
  801593:	e8 94 f8 ff ff       	call   800e2c <fd_alloc>
  801598:	83 c4 10             	add    $0x10,%esp
		return r;
  80159b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 57                	js     8015f8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	53                   	push   %ebx
  8015a5:	68 00 50 80 00       	push   $0x805000
  8015aa:	e8 c8 f1 ff ff       	call   800777 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8015bf:	e8 f0 fd ff ff       	call   8013b4 <fsipc>
  8015c4:	89 c3                	mov    %eax,%ebx
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	79 14                	jns    8015e1 <open+0x6f>
		fd_close(fd, 0);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	6a 00                	push   $0x0
  8015d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d5:	e8 4a f9 ff ff       	call   800f24 <fd_close>
		return r;
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	89 da                	mov    %ebx,%edx
  8015df:	eb 17                	jmp    8015f8 <open+0x86>
	}

	return fd2num(fd);
  8015e1:	83 ec 0c             	sub    $0xc,%esp
  8015e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e7:	e8 19 f8 ff ff       	call   800e05 <fd2num>
  8015ec:	89 c2                	mov    %eax,%edx
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	eb 05                	jmp    8015f8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015f3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015f8:	89 d0                	mov    %edx,%eax
  8015fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fd:	c9                   	leave  
  8015fe:	c3                   	ret    

008015ff <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ff:	55                   	push   %ebp
  801600:	89 e5                	mov    %esp,%ebp
  801602:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801605:	ba 00 00 00 00       	mov    $0x0,%edx
  80160a:	b8 08 00 00 00       	mov    $0x8,%eax
  80160f:	e8 a0 fd ff ff       	call   8013b4 <fsipc>
}
  801614:	c9                   	leave  
  801615:	c3                   	ret    

00801616 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801616:	55                   	push   %ebp
  801617:	89 e5                	mov    %esp,%ebp
  801619:	56                   	push   %esi
  80161a:	53                   	push   %ebx
  80161b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	ff 75 08             	pushl  0x8(%ebp)
  801624:	e8 ec f7 ff ff       	call   800e15 <fd2data>
  801629:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80162b:	83 c4 08             	add    $0x8,%esp
  80162e:	68 53 23 80 00       	push   $0x802353
  801633:	53                   	push   %ebx
  801634:	e8 3e f1 ff ff       	call   800777 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801639:	8b 46 04             	mov    0x4(%esi),%eax
  80163c:	2b 06                	sub    (%esi),%eax
  80163e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801644:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80164b:	00 00 00 
	stat->st_dev = &devpipe;
  80164e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801655:	30 80 00 
	return 0;
}
  801658:	b8 00 00 00 00       	mov    $0x0,%eax
  80165d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801660:	5b                   	pop    %ebx
  801661:	5e                   	pop    %esi
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    

00801664 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	53                   	push   %ebx
  801668:	83 ec 0c             	sub    $0xc,%esp
  80166b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80166e:	53                   	push   %ebx
  80166f:	6a 00                	push   $0x0
  801671:	e8 89 f5 ff ff       	call   800bff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801676:	89 1c 24             	mov    %ebx,(%esp)
  801679:	e8 97 f7 ff ff       	call   800e15 <fd2data>
  80167e:	83 c4 08             	add    $0x8,%esp
  801681:	50                   	push   %eax
  801682:	6a 00                	push   $0x0
  801684:	e8 76 f5 ff ff       	call   800bff <sys_page_unmap>
}
  801689:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168c:	c9                   	leave  
  80168d:	c3                   	ret    

0080168e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	57                   	push   %edi
  801692:	56                   	push   %esi
  801693:	53                   	push   %ebx
  801694:	83 ec 1c             	sub    $0x1c,%esp
  801697:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80169a:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80169c:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8016a4:	83 ec 0c             	sub    $0xc,%esp
  8016a7:	ff 75 e0             	pushl  -0x20(%ebp)
  8016aa:	e8 9b 05 00 00       	call   801c4a <pageref>
  8016af:	89 c3                	mov    %eax,%ebx
  8016b1:	89 3c 24             	mov    %edi,(%esp)
  8016b4:	e8 91 05 00 00       	call   801c4a <pageref>
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	39 c3                	cmp    %eax,%ebx
  8016be:	0f 94 c1             	sete   %cl
  8016c1:	0f b6 c9             	movzbl %cl,%ecx
  8016c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016c7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016cd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016d0:	39 ce                	cmp    %ecx,%esi
  8016d2:	74 1b                	je     8016ef <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016d4:	39 c3                	cmp    %eax,%ebx
  8016d6:	75 c4                	jne    80169c <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016d8:	8b 42 58             	mov    0x58(%edx),%eax
  8016db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016de:	50                   	push   %eax
  8016df:	56                   	push   %esi
  8016e0:	68 5a 23 80 00       	push   $0x80235a
  8016e5:	e8 89 ea ff ff       	call   800173 <cprintf>
  8016ea:	83 c4 10             	add    $0x10,%esp
  8016ed:	eb ad                	jmp    80169c <_pipeisclosed+0xe>
	}
}
  8016ef:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f5:	5b                   	pop    %ebx
  8016f6:	5e                   	pop    %esi
  8016f7:	5f                   	pop    %edi
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	57                   	push   %edi
  8016fe:	56                   	push   %esi
  8016ff:	53                   	push   %ebx
  801700:	83 ec 28             	sub    $0x28,%esp
  801703:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801706:	56                   	push   %esi
  801707:	e8 09 f7 ff ff       	call   800e15 <fd2data>
  80170c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80170e:	83 c4 10             	add    $0x10,%esp
  801711:	bf 00 00 00 00       	mov    $0x0,%edi
  801716:	eb 4b                	jmp    801763 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801718:	89 da                	mov    %ebx,%edx
  80171a:	89 f0                	mov    %esi,%eax
  80171c:	e8 6d ff ff ff       	call   80168e <_pipeisclosed>
  801721:	85 c0                	test   %eax,%eax
  801723:	75 48                	jne    80176d <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801725:	e8 31 f4 ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80172a:	8b 43 04             	mov    0x4(%ebx),%eax
  80172d:	8b 0b                	mov    (%ebx),%ecx
  80172f:	8d 51 20             	lea    0x20(%ecx),%edx
  801732:	39 d0                	cmp    %edx,%eax
  801734:	73 e2                	jae    801718 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801736:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801739:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80173d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801740:	89 c2                	mov    %eax,%edx
  801742:	c1 fa 1f             	sar    $0x1f,%edx
  801745:	89 d1                	mov    %edx,%ecx
  801747:	c1 e9 1b             	shr    $0x1b,%ecx
  80174a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80174d:	83 e2 1f             	and    $0x1f,%edx
  801750:	29 ca                	sub    %ecx,%edx
  801752:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801756:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80175a:	83 c0 01             	add    $0x1,%eax
  80175d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801760:	83 c7 01             	add    $0x1,%edi
  801763:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801766:	75 c2                	jne    80172a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801768:	8b 45 10             	mov    0x10(%ebp),%eax
  80176b:	eb 05                	jmp    801772 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80176d:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801772:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5f                   	pop    %edi
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80177a:	55                   	push   %ebp
  80177b:	89 e5                	mov    %esp,%ebp
  80177d:	57                   	push   %edi
  80177e:	56                   	push   %esi
  80177f:	53                   	push   %ebx
  801780:	83 ec 18             	sub    $0x18,%esp
  801783:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801786:	57                   	push   %edi
  801787:	e8 89 f6 ff ff       	call   800e15 <fd2data>
  80178c:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80178e:	83 c4 10             	add    $0x10,%esp
  801791:	bb 00 00 00 00       	mov    $0x0,%ebx
  801796:	eb 3d                	jmp    8017d5 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801798:	85 db                	test   %ebx,%ebx
  80179a:	74 04                	je     8017a0 <devpipe_read+0x26>
				return i;
  80179c:	89 d8                	mov    %ebx,%eax
  80179e:	eb 44                	jmp    8017e4 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8017a0:	89 f2                	mov    %esi,%edx
  8017a2:	89 f8                	mov    %edi,%eax
  8017a4:	e8 e5 fe ff ff       	call   80168e <_pipeisclosed>
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	75 32                	jne    8017df <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8017ad:	e8 a9 f3 ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8017b2:	8b 06                	mov    (%esi),%eax
  8017b4:	3b 46 04             	cmp    0x4(%esi),%eax
  8017b7:	74 df                	je     801798 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017b9:	99                   	cltd   
  8017ba:	c1 ea 1b             	shr    $0x1b,%edx
  8017bd:	01 d0                	add    %edx,%eax
  8017bf:	83 e0 1f             	and    $0x1f,%eax
  8017c2:	29 d0                	sub    %edx,%eax
  8017c4:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017cc:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017cf:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017d2:	83 c3 01             	add    $0x1,%ebx
  8017d5:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017d8:	75 d8                	jne    8017b2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017da:	8b 45 10             	mov    0x10(%ebp),%eax
  8017dd:	eb 05                	jmp    8017e4 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017df:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017e7:	5b                   	pop    %ebx
  8017e8:	5e                   	pop    %esi
  8017e9:	5f                   	pop    %edi
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
  8017f1:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017f7:	50                   	push   %eax
  8017f8:	e8 2f f6 ff ff       	call   800e2c <fd_alloc>
  8017fd:	83 c4 10             	add    $0x10,%esp
  801800:	89 c2                	mov    %eax,%edx
  801802:	85 c0                	test   %eax,%eax
  801804:	0f 88 2c 01 00 00    	js     801936 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80180a:	83 ec 04             	sub    $0x4,%esp
  80180d:	68 07 04 00 00       	push   $0x407
  801812:	ff 75 f4             	pushl  -0xc(%ebp)
  801815:	6a 00                	push   $0x0
  801817:	e8 5e f3 ff ff       	call   800b7a <sys_page_alloc>
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	89 c2                	mov    %eax,%edx
  801821:	85 c0                	test   %eax,%eax
  801823:	0f 88 0d 01 00 00    	js     801936 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801829:	83 ec 0c             	sub    $0xc,%esp
  80182c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80182f:	50                   	push   %eax
  801830:	e8 f7 f5 ff ff       	call   800e2c <fd_alloc>
  801835:	89 c3                	mov    %eax,%ebx
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	85 c0                	test   %eax,%eax
  80183c:	0f 88 e2 00 00 00    	js     801924 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801842:	83 ec 04             	sub    $0x4,%esp
  801845:	68 07 04 00 00       	push   $0x407
  80184a:	ff 75 f0             	pushl  -0x10(%ebp)
  80184d:	6a 00                	push   $0x0
  80184f:	e8 26 f3 ff ff       	call   800b7a <sys_page_alloc>
  801854:	89 c3                	mov    %eax,%ebx
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	85 c0                	test   %eax,%eax
  80185b:	0f 88 c3 00 00 00    	js     801924 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801861:	83 ec 0c             	sub    $0xc,%esp
  801864:	ff 75 f4             	pushl  -0xc(%ebp)
  801867:	e8 a9 f5 ff ff       	call   800e15 <fd2data>
  80186c:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80186e:	83 c4 0c             	add    $0xc,%esp
  801871:	68 07 04 00 00       	push   $0x407
  801876:	50                   	push   %eax
  801877:	6a 00                	push   $0x0
  801879:	e8 fc f2 ff ff       	call   800b7a <sys_page_alloc>
  80187e:	89 c3                	mov    %eax,%ebx
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	85 c0                	test   %eax,%eax
  801885:	0f 88 89 00 00 00    	js     801914 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188b:	83 ec 0c             	sub    $0xc,%esp
  80188e:	ff 75 f0             	pushl  -0x10(%ebp)
  801891:	e8 7f f5 ff ff       	call   800e15 <fd2data>
  801896:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80189d:	50                   	push   %eax
  80189e:	6a 00                	push   $0x0
  8018a0:	56                   	push   %esi
  8018a1:	6a 00                	push   $0x0
  8018a3:	e8 15 f3 ff ff       	call   800bbd <sys_page_map>
  8018a8:	89 c3                	mov    %eax,%ebx
  8018aa:	83 c4 20             	add    $0x20,%esp
  8018ad:	85 c0                	test   %eax,%eax
  8018af:	78 55                	js     801906 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8018b1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ba:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bf:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018c6:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cf:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018db:	83 ec 0c             	sub    $0xc,%esp
  8018de:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e1:	e8 1f f5 ff ff       	call   800e05 <fd2num>
  8018e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018eb:	83 c4 04             	add    $0x4,%esp
  8018ee:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f1:	e8 0f f5 ff ff       	call   800e05 <fd2num>
  8018f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018f9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801904:	eb 30                	jmp    801936 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	56                   	push   %esi
  80190a:	6a 00                	push   $0x0
  80190c:	e8 ee f2 ff ff       	call   800bff <sys_page_unmap>
  801911:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801914:	83 ec 08             	sub    $0x8,%esp
  801917:	ff 75 f0             	pushl  -0x10(%ebp)
  80191a:	6a 00                	push   $0x0
  80191c:	e8 de f2 ff ff       	call   800bff <sys_page_unmap>
  801921:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801924:	83 ec 08             	sub    $0x8,%esp
  801927:	ff 75 f4             	pushl  -0xc(%ebp)
  80192a:	6a 00                	push   $0x0
  80192c:	e8 ce f2 ff ff       	call   800bff <sys_page_unmap>
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801936:	89 d0                	mov    %edx,%eax
  801938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193b:	5b                   	pop    %ebx
  80193c:	5e                   	pop    %esi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801945:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801948:	50                   	push   %eax
  801949:	ff 75 08             	pushl  0x8(%ebp)
  80194c:	e8 2a f5 ff ff       	call   800e7b <fd_lookup>
  801951:	83 c4 10             	add    $0x10,%esp
  801954:	85 c0                	test   %eax,%eax
  801956:	78 18                	js     801970 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801958:	83 ec 0c             	sub    $0xc,%esp
  80195b:	ff 75 f4             	pushl  -0xc(%ebp)
  80195e:	e8 b2 f4 ff ff       	call   800e15 <fd2data>
	return _pipeisclosed(fd, p);
  801963:	89 c2                	mov    %eax,%edx
  801965:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801968:	e8 21 fd ff ff       	call   80168e <_pipeisclosed>
  80196d:	83 c4 10             	add    $0x10,%esp
}
  801970:	c9                   	leave  
  801971:	c3                   	ret    

00801972 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801975:	b8 00 00 00 00       	mov    $0x0,%eax
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801982:	68 72 23 80 00       	push   $0x802372
  801987:	ff 75 0c             	pushl  0xc(%ebp)
  80198a:	e8 e8 ed ff ff       	call   800777 <strcpy>
	return 0;
}
  80198f:	b8 00 00 00 00       	mov    $0x0,%eax
  801994:	c9                   	leave  
  801995:	c3                   	ret    

00801996 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801996:	55                   	push   %ebp
  801997:	89 e5                	mov    %esp,%ebp
  801999:	57                   	push   %edi
  80199a:	56                   	push   %esi
  80199b:	53                   	push   %ebx
  80199c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019a2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019ad:	eb 2d                	jmp    8019dc <devcons_write+0x46>
		m = n - tot;
  8019af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019b2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8019b4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8019b7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019bc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019bf:	83 ec 04             	sub    $0x4,%esp
  8019c2:	53                   	push   %ebx
  8019c3:	03 45 0c             	add    0xc(%ebp),%eax
  8019c6:	50                   	push   %eax
  8019c7:	57                   	push   %edi
  8019c8:	e8 3c ef ff ff       	call   800909 <memmove>
		sys_cputs(buf, m);
  8019cd:	83 c4 08             	add    $0x8,%esp
  8019d0:	53                   	push   %ebx
  8019d1:	57                   	push   %edi
  8019d2:	e8 e7 f0 ff ff       	call   800abe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019d7:	01 de                	add    %ebx,%esi
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	89 f0                	mov    %esi,%eax
  8019de:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019e1:	72 cc                	jb     8019af <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019e6:	5b                   	pop    %ebx
  8019e7:	5e                   	pop    %esi
  8019e8:	5f                   	pop    %edi
  8019e9:	5d                   	pop    %ebp
  8019ea:	c3                   	ret    

008019eb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019eb:	55                   	push   %ebp
  8019ec:	89 e5                	mov    %esp,%ebp
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019f6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019fa:	74 2a                	je     801a26 <devcons_read+0x3b>
  8019fc:	eb 05                	jmp    801a03 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019fe:	e8 58 f1 ff ff       	call   800b5b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a03:	e8 d4 f0 ff ff       	call   800adc <sys_cgetc>
  801a08:	85 c0                	test   %eax,%eax
  801a0a:	74 f2                	je     8019fe <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801a0c:	85 c0                	test   %eax,%eax
  801a0e:	78 16                	js     801a26 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801a10:	83 f8 04             	cmp    $0x4,%eax
  801a13:	74 0c                	je     801a21 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801a15:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a18:	88 02                	mov    %al,(%edx)
	return 1;
  801a1a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a1f:	eb 05                	jmp    801a26 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a21:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a26:	c9                   	leave  
  801a27:	c3                   	ret    

00801a28 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801a28:	55                   	push   %ebp
  801a29:	89 e5                	mov    %esp,%ebp
  801a2b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a31:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a34:	6a 01                	push   $0x1
  801a36:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a39:	50                   	push   %eax
  801a3a:	e8 7f f0 ff ff       	call   800abe <sys_cputs>
}
  801a3f:	83 c4 10             	add    $0x10,%esp
  801a42:	c9                   	leave  
  801a43:	c3                   	ret    

00801a44 <getchar>:

int
getchar(void)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a4a:	6a 01                	push   $0x1
  801a4c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a4f:	50                   	push   %eax
  801a50:	6a 00                	push   $0x0
  801a52:	e8 8a f6 ff ff       	call   8010e1 <read>
	if (r < 0)
  801a57:	83 c4 10             	add    $0x10,%esp
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 0f                	js     801a6d <getchar+0x29>
		return r;
	if (r < 1)
  801a5e:	85 c0                	test   %eax,%eax
  801a60:	7e 06                	jle    801a68 <getchar+0x24>
		return -E_EOF;
	return c;
  801a62:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a66:	eb 05                	jmp    801a6d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a68:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a6d:	c9                   	leave  
  801a6e:	c3                   	ret    

00801a6f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a78:	50                   	push   %eax
  801a79:	ff 75 08             	pushl  0x8(%ebp)
  801a7c:	e8 fa f3 ff ff       	call   800e7b <fd_lookup>
  801a81:	83 c4 10             	add    $0x10,%esp
  801a84:	85 c0                	test   %eax,%eax
  801a86:	78 11                	js     801a99 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a88:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a91:	39 10                	cmp    %edx,(%eax)
  801a93:	0f 94 c0             	sete   %al
  801a96:	0f b6 c0             	movzbl %al,%eax
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <opencons>:

int
opencons(void)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aa1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa4:	50                   	push   %eax
  801aa5:	e8 82 f3 ff ff       	call   800e2c <fd_alloc>
  801aaa:	83 c4 10             	add    $0x10,%esp
		return r;
  801aad:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801aaf:	85 c0                	test   %eax,%eax
  801ab1:	78 3e                	js     801af1 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab3:	83 ec 04             	sub    $0x4,%esp
  801ab6:	68 07 04 00 00       	push   $0x407
  801abb:	ff 75 f4             	pushl  -0xc(%ebp)
  801abe:	6a 00                	push   $0x0
  801ac0:	e8 b5 f0 ff ff       	call   800b7a <sys_page_alloc>
  801ac5:	83 c4 10             	add    $0x10,%esp
		return r;
  801ac8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801aca:	85 c0                	test   %eax,%eax
  801acc:	78 23                	js     801af1 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ace:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ad9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801adc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ae3:	83 ec 0c             	sub    $0xc,%esp
  801ae6:	50                   	push   %eax
  801ae7:	e8 19 f3 ff ff       	call   800e05 <fd2num>
  801aec:	89 c2                	mov    %eax,%edx
  801aee:	83 c4 10             	add    $0x10,%esp
}
  801af1:	89 d0                	mov    %edx,%eax
  801af3:	c9                   	leave  
  801af4:	c3                   	ret    

00801af5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	56                   	push   %esi
  801af9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801afa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801afd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801b03:	e8 34 f0 ff ff       	call   800b3c <sys_getenvid>
  801b08:	83 ec 0c             	sub    $0xc,%esp
  801b0b:	ff 75 0c             	pushl  0xc(%ebp)
  801b0e:	ff 75 08             	pushl  0x8(%ebp)
  801b11:	56                   	push   %esi
  801b12:	50                   	push   %eax
  801b13:	68 80 23 80 00       	push   $0x802380
  801b18:	e8 56 e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b1d:	83 c4 18             	add    $0x18,%esp
  801b20:	53                   	push   %ebx
  801b21:	ff 75 10             	pushl  0x10(%ebp)
  801b24:	e8 f9 e5 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801b29:	c7 04 24 6b 23 80 00 	movl   $0x80236b,(%esp)
  801b30:	e8 3e e6 ff ff       	call   800173 <cprintf>
  801b35:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b38:	cc                   	int3   
  801b39:	eb fd                	jmp    801b38 <_panic+0x43>

00801b3b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b3b:	55                   	push   %ebp
  801b3c:	89 e5                	mov    %esp,%ebp
  801b3e:	57                   	push   %edi
  801b3f:	56                   	push   %esi
  801b40:	53                   	push   %ebx
  801b41:	83 ec 0c             	sub    $0xc,%esp
  801b44:	8b 75 08             	mov    0x8(%ebp),%esi
  801b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_recv not implemented");

	int r;

	if (from_env_store)
  801b4d:	85 f6                	test   %esi,%esi
  801b4f:	74 06                	je     801b57 <ipc_recv+0x1c>
		*from_env_store = 0;
  801b51:	c7 06 00 00 00 00    	movl   $0x0,(%esi)

	if (perm_store)
  801b57:	85 db                	test   %ebx,%ebx
  801b59:	74 06                	je     801b61 <ipc_recv+0x26>
		*perm_store = 0;
  801b5b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)

	if (!pg)
  801b61:	85 c0                	test   %eax,%eax
		pg = (void *) -1;
  801b63:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801b68:	0f 44 c2             	cmove  %edx,%eax

	// 系统调用
	if ((r = sys_ipc_recv(pg)) < 0) {
  801b6b:	83 ec 0c             	sub    $0xc,%esp
  801b6e:	50                   	push   %eax
  801b6f:	e8 b6 f1 ff ff       	call   800d2a <sys_ipc_recv>
  801b74:	89 c7                	mov    %eax,%edi
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	85 c0                	test   %eax,%eax
  801b7b:	79 14                	jns    801b91 <ipc_recv+0x56>
		cprintf("im dead");
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	68 a4 23 80 00       	push   $0x8023a4
  801b85:	e8 e9 e5 ff ff       	call   800173 <cprintf>
		return r;
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	89 f8                	mov    %edi,%eax
  801b8f:	eb 24                	jmp    801bb5 <ipc_recv+0x7a>
	}
	
	// 存储发送者id
	if (from_env_store)
  801b91:	85 f6                	test   %esi,%esi
  801b93:	74 0a                	je     801b9f <ipc_recv+0x64>
		*from_env_store = thisenv->env_ipc_from;
  801b95:	a1 04 40 80 00       	mov    0x804004,%eax
  801b9a:	8b 40 74             	mov    0x74(%eax),%eax
  801b9d:	89 06                	mov    %eax,(%esi)
	
	// 存储权限
	if (perm_store)
  801b9f:	85 db                	test   %ebx,%ebx
  801ba1:	74 0a                	je     801bad <ipc_recv+0x72>
		*perm_store = thisenv->env_ipc_perm;
  801ba3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ba8:	8b 40 78             	mov    0x78(%eax),%eax
  801bab:	89 03                	mov    %eax,(%ebx)
	
	// 返回接受到的值
	return thisenv->env_ipc_value;
  801bad:	a1 04 40 80 00       	mov    0x804004,%eax
  801bb2:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bb8:	5b                   	pop    %ebx
  801bb9:	5e                   	pop    %esi
  801bba:	5f                   	pop    %edi
  801bbb:	5d                   	pop    %ebp
  801bbc:	c3                   	ret    

00801bbd <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	57                   	push   %edi
  801bc1:	56                   	push   %esi
  801bc2:	53                   	push   %ebx
  801bc3:	83 ec 0c             	sub    $0xc,%esp
  801bc6:	8b 7d 08             	mov    0x8(%ebp),%edi
  801bc9:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bcc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// panic("ipc_send not implemented");
	int r;

	//she zhi wei gao wei
	if (!pg)
  801bcf:	85 db                	test   %ebx,%ebx
		pg = (void *) -1;
  801bd1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801bd6:	0f 44 d8             	cmove  %eax,%ebx
  801bd9:	eb 1c                	jmp    801bf7 <ipc_send+0x3a>
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
		if (r != -E_IPC_NOT_RECV)
  801bdb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bde:	74 12                	je     801bf2 <ipc_send+0x35>
			panic("ipc_send: %e", r);
  801be0:	50                   	push   %eax
  801be1:	68 ac 23 80 00       	push   $0x8023ac
  801be6:	6a 4e                	push   $0x4e
  801be8:	68 b9 23 80 00       	push   $0x8023b9
  801bed:	e8 03 ff ff ff       	call   801af5 <_panic>
		sys_yield();
  801bf2:	e8 64 ef ff ff       	call   800b5b <sys_yield>

	//she zhi wei gao wei
	if (!pg)
		pg = (void *) -1;
	// 不断发送，知道发送成功
	while ((r = sys_ipc_try_send(to_env, val, pg, perm)) < 0) {
  801bf7:	ff 75 14             	pushl  0x14(%ebp)
  801bfa:	53                   	push   %ebx
  801bfb:	56                   	push   %esi
  801bfc:	57                   	push   %edi
  801bfd:	e8 05 f1 ff ff       	call   800d07 <sys_ipc_try_send>
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	85 c0                	test   %eax,%eax
  801c07:	78 d2                	js     801bdb <ipc_send+0x1e>
		if (r != -E_IPC_NOT_RECV)
			panic("ipc_send: %e", r);
		sys_yield();
	}
}
  801c09:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5f                   	pop    %edi
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c17:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c1c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c1f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c25:	8b 52 50             	mov    0x50(%edx),%edx
  801c28:	39 ca                	cmp    %ecx,%edx
  801c2a:	75 0d                	jne    801c39 <ipc_find_env+0x28>
			return envs[i].env_id;
  801c2c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c2f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c34:	8b 40 48             	mov    0x48(%eax),%eax
  801c37:	eb 0f                	jmp    801c48 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c39:	83 c0 01             	add    $0x1,%eax
  801c3c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c41:	75 d9                	jne    801c1c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c50:	89 d0                	mov    %edx,%eax
  801c52:	c1 e8 16             	shr    $0x16,%eax
  801c55:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c5c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c61:	f6 c1 01             	test   $0x1,%cl
  801c64:	74 1d                	je     801c83 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c66:	c1 ea 0c             	shr    $0xc,%edx
  801c69:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c70:	f6 c2 01             	test   $0x1,%dl
  801c73:	74 0e                	je     801c83 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c75:	c1 ea 0c             	shr    $0xc,%edx
  801c78:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c7f:	ef 
  801c80:	0f b7 c0             	movzwl %ax,%eax
}
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
  801c85:	66 90                	xchg   %ax,%ax
  801c87:	66 90                	xchg   %ax,%ax
  801c89:	66 90                	xchg   %ax,%ax
  801c8b:	66 90                	xchg   %ax,%ax
  801c8d:	66 90                	xchg   %ax,%ax
  801c8f:	90                   	nop

00801c90 <__udivdi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c9b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c9f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 f6                	test   %esi,%esi
  801ca9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cad:	89 ca                	mov    %ecx,%edx
  801caf:	89 f8                	mov    %edi,%eax
  801cb1:	75 3d                	jne    801cf0 <__udivdi3+0x60>
  801cb3:	39 cf                	cmp    %ecx,%edi
  801cb5:	0f 87 c5 00 00 00    	ja     801d80 <__udivdi3+0xf0>
  801cbb:	85 ff                	test   %edi,%edi
  801cbd:	89 fd                	mov    %edi,%ebp
  801cbf:	75 0b                	jne    801ccc <__udivdi3+0x3c>
  801cc1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc6:	31 d2                	xor    %edx,%edx
  801cc8:	f7 f7                	div    %edi
  801cca:	89 c5                	mov    %eax,%ebp
  801ccc:	89 c8                	mov    %ecx,%eax
  801cce:	31 d2                	xor    %edx,%edx
  801cd0:	f7 f5                	div    %ebp
  801cd2:	89 c1                	mov    %eax,%ecx
  801cd4:	89 d8                	mov    %ebx,%eax
  801cd6:	89 cf                	mov    %ecx,%edi
  801cd8:	f7 f5                	div    %ebp
  801cda:	89 c3                	mov    %eax,%ebx
  801cdc:	89 d8                	mov    %ebx,%eax
  801cde:	89 fa                	mov    %edi,%edx
  801ce0:	83 c4 1c             	add    $0x1c,%esp
  801ce3:	5b                   	pop    %ebx
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
  801ce8:	90                   	nop
  801ce9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	39 ce                	cmp    %ecx,%esi
  801cf2:	77 74                	ja     801d68 <__udivdi3+0xd8>
  801cf4:	0f bd fe             	bsr    %esi,%edi
  801cf7:	83 f7 1f             	xor    $0x1f,%edi
  801cfa:	0f 84 98 00 00 00    	je     801d98 <__udivdi3+0x108>
  801d00:	bb 20 00 00 00       	mov    $0x20,%ebx
  801d05:	89 f9                	mov    %edi,%ecx
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	29 fb                	sub    %edi,%ebx
  801d0b:	d3 e6                	shl    %cl,%esi
  801d0d:	89 d9                	mov    %ebx,%ecx
  801d0f:	d3 ed                	shr    %cl,%ebp
  801d11:	89 f9                	mov    %edi,%ecx
  801d13:	d3 e0                	shl    %cl,%eax
  801d15:	09 ee                	or     %ebp,%esi
  801d17:	89 d9                	mov    %ebx,%ecx
  801d19:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d1d:	89 d5                	mov    %edx,%ebp
  801d1f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d23:	d3 ed                	shr    %cl,%ebp
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	d3 e2                	shl    %cl,%edx
  801d29:	89 d9                	mov    %ebx,%ecx
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	09 c2                	or     %eax,%edx
  801d2f:	89 d0                	mov    %edx,%eax
  801d31:	89 ea                	mov    %ebp,%edx
  801d33:	f7 f6                	div    %esi
  801d35:	89 d5                	mov    %edx,%ebp
  801d37:	89 c3                	mov    %eax,%ebx
  801d39:	f7 64 24 0c          	mull   0xc(%esp)
  801d3d:	39 d5                	cmp    %edx,%ebp
  801d3f:	72 10                	jb     801d51 <__udivdi3+0xc1>
  801d41:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e6                	shl    %cl,%esi
  801d49:	39 c6                	cmp    %eax,%esi
  801d4b:	73 07                	jae    801d54 <__udivdi3+0xc4>
  801d4d:	39 d5                	cmp    %edx,%ebp
  801d4f:	75 03                	jne    801d54 <__udivdi3+0xc4>
  801d51:	83 eb 01             	sub    $0x1,%ebx
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 d8                	mov    %ebx,%eax
  801d58:	89 fa                	mov    %edi,%edx
  801d5a:	83 c4 1c             	add    $0x1c,%esp
  801d5d:	5b                   	pop    %ebx
  801d5e:	5e                   	pop    %esi
  801d5f:	5f                   	pop    %edi
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    
  801d62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d68:	31 ff                	xor    %edi,%edi
  801d6a:	31 db                	xor    %ebx,%ebx
  801d6c:	89 d8                	mov    %ebx,%eax
  801d6e:	89 fa                	mov    %edi,%edx
  801d70:	83 c4 1c             	add    $0x1c,%esp
  801d73:	5b                   	pop    %ebx
  801d74:	5e                   	pop    %esi
  801d75:	5f                   	pop    %edi
  801d76:	5d                   	pop    %ebp
  801d77:	c3                   	ret    
  801d78:	90                   	nop
  801d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	f7 f7                	div    %edi
  801d84:	31 ff                	xor    %edi,%edi
  801d86:	89 c3                	mov    %eax,%ebx
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	89 fa                	mov    %edi,%edx
  801d8c:	83 c4 1c             	add    $0x1c,%esp
  801d8f:	5b                   	pop    %ebx
  801d90:	5e                   	pop    %esi
  801d91:	5f                   	pop    %edi
  801d92:	5d                   	pop    %ebp
  801d93:	c3                   	ret    
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	39 ce                	cmp    %ecx,%esi
  801d9a:	72 0c                	jb     801da8 <__udivdi3+0x118>
  801d9c:	31 db                	xor    %ebx,%ebx
  801d9e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801da2:	0f 87 34 ff ff ff    	ja     801cdc <__udivdi3+0x4c>
  801da8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801dad:	e9 2a ff ff ff       	jmp    801cdc <__udivdi3+0x4c>
  801db2:	66 90                	xchg   %ax,%ax
  801db4:	66 90                	xchg   %ax,%ax
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__umoddi3>:
  801dc0:	55                   	push   %ebp
  801dc1:	57                   	push   %edi
  801dc2:	56                   	push   %esi
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 1c             	sub    $0x1c,%esp
  801dc7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801dcb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dcf:	8b 74 24 34          	mov    0x34(%esp),%esi
  801dd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801dd7:	85 d2                	test   %edx,%edx
  801dd9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801de1:	89 f3                	mov    %esi,%ebx
  801de3:	89 3c 24             	mov    %edi,(%esp)
  801de6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dea:	75 1c                	jne    801e08 <__umoddi3+0x48>
  801dec:	39 f7                	cmp    %esi,%edi
  801dee:	76 50                	jbe    801e40 <__umoddi3+0x80>
  801df0:	89 c8                	mov    %ecx,%eax
  801df2:	89 f2                	mov    %esi,%edx
  801df4:	f7 f7                	div    %edi
  801df6:	89 d0                	mov    %edx,%eax
  801df8:	31 d2                	xor    %edx,%edx
  801dfa:	83 c4 1c             	add    $0x1c,%esp
  801dfd:	5b                   	pop    %ebx
  801dfe:	5e                   	pop    %esi
  801dff:	5f                   	pop    %edi
  801e00:	5d                   	pop    %ebp
  801e01:	c3                   	ret    
  801e02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e08:	39 f2                	cmp    %esi,%edx
  801e0a:	89 d0                	mov    %edx,%eax
  801e0c:	77 52                	ja     801e60 <__umoddi3+0xa0>
  801e0e:	0f bd ea             	bsr    %edx,%ebp
  801e11:	83 f5 1f             	xor    $0x1f,%ebp
  801e14:	75 5a                	jne    801e70 <__umoddi3+0xb0>
  801e16:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801e1a:	0f 82 e0 00 00 00    	jb     801f00 <__umoddi3+0x140>
  801e20:	39 0c 24             	cmp    %ecx,(%esp)
  801e23:	0f 86 d7 00 00 00    	jbe    801f00 <__umoddi3+0x140>
  801e29:	8b 44 24 08          	mov    0x8(%esp),%eax
  801e2d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e31:	83 c4 1c             	add    $0x1c,%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5f                   	pop    %edi
  801e37:	5d                   	pop    %ebp
  801e38:	c3                   	ret    
  801e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e40:	85 ff                	test   %edi,%edi
  801e42:	89 fd                	mov    %edi,%ebp
  801e44:	75 0b                	jne    801e51 <__umoddi3+0x91>
  801e46:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4b:	31 d2                	xor    %edx,%edx
  801e4d:	f7 f7                	div    %edi
  801e4f:	89 c5                	mov    %eax,%ebp
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	31 d2                	xor    %edx,%edx
  801e55:	f7 f5                	div    %ebp
  801e57:	89 c8                	mov    %ecx,%eax
  801e59:	f7 f5                	div    %ebp
  801e5b:	89 d0                	mov    %edx,%eax
  801e5d:	eb 99                	jmp    801df8 <__umoddi3+0x38>
  801e5f:	90                   	nop
  801e60:	89 c8                	mov    %ecx,%eax
  801e62:	89 f2                	mov    %esi,%edx
  801e64:	83 c4 1c             	add    $0x1c,%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5f                   	pop    %edi
  801e6a:	5d                   	pop    %ebp
  801e6b:	c3                   	ret    
  801e6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e70:	8b 34 24             	mov    (%esp),%esi
  801e73:	bf 20 00 00 00       	mov    $0x20,%edi
  801e78:	89 e9                	mov    %ebp,%ecx
  801e7a:	29 ef                	sub    %ebp,%edi
  801e7c:	d3 e0                	shl    %cl,%eax
  801e7e:	89 f9                	mov    %edi,%ecx
  801e80:	89 f2                	mov    %esi,%edx
  801e82:	d3 ea                	shr    %cl,%edx
  801e84:	89 e9                	mov    %ebp,%ecx
  801e86:	09 c2                	or     %eax,%edx
  801e88:	89 d8                	mov    %ebx,%eax
  801e8a:	89 14 24             	mov    %edx,(%esp)
  801e8d:	89 f2                	mov    %esi,%edx
  801e8f:	d3 e2                	shl    %cl,%edx
  801e91:	89 f9                	mov    %edi,%ecx
  801e93:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e97:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e9b:	d3 e8                	shr    %cl,%eax
  801e9d:	89 e9                	mov    %ebp,%ecx
  801e9f:	89 c6                	mov    %eax,%esi
  801ea1:	d3 e3                	shl    %cl,%ebx
  801ea3:	89 f9                	mov    %edi,%ecx
  801ea5:	89 d0                	mov    %edx,%eax
  801ea7:	d3 e8                	shr    %cl,%eax
  801ea9:	89 e9                	mov    %ebp,%ecx
  801eab:	09 d8                	or     %ebx,%eax
  801ead:	89 d3                	mov    %edx,%ebx
  801eaf:	89 f2                	mov    %esi,%edx
  801eb1:	f7 34 24             	divl   (%esp)
  801eb4:	89 d6                	mov    %edx,%esi
  801eb6:	d3 e3                	shl    %cl,%ebx
  801eb8:	f7 64 24 04          	mull   0x4(%esp)
  801ebc:	39 d6                	cmp    %edx,%esi
  801ebe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ec2:	89 d1                	mov    %edx,%ecx
  801ec4:	89 c3                	mov    %eax,%ebx
  801ec6:	72 08                	jb     801ed0 <__umoddi3+0x110>
  801ec8:	75 11                	jne    801edb <__umoddi3+0x11b>
  801eca:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801ece:	73 0b                	jae    801edb <__umoddi3+0x11b>
  801ed0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ed4:	1b 14 24             	sbb    (%esp),%edx
  801ed7:	89 d1                	mov    %edx,%ecx
  801ed9:	89 c3                	mov    %eax,%ebx
  801edb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801edf:	29 da                	sub    %ebx,%edx
  801ee1:	19 ce                	sbb    %ecx,%esi
  801ee3:	89 f9                	mov    %edi,%ecx
  801ee5:	89 f0                	mov    %esi,%eax
  801ee7:	d3 e0                	shl    %cl,%eax
  801ee9:	89 e9                	mov    %ebp,%ecx
  801eeb:	d3 ea                	shr    %cl,%edx
  801eed:	89 e9                	mov    %ebp,%ecx
  801eef:	d3 ee                	shr    %cl,%esi
  801ef1:	09 d0                	or     %edx,%eax
  801ef3:	89 f2                	mov    %esi,%edx
  801ef5:	83 c4 1c             	add    $0x1c,%esp
  801ef8:	5b                   	pop    %ebx
  801ef9:	5e                   	pop    %esi
  801efa:	5f                   	pop    %edi
  801efb:	5d                   	pop    %ebp
  801efc:	c3                   	ret    
  801efd:	8d 76 00             	lea    0x0(%esi),%esi
  801f00:	29 f9                	sub    %edi,%ecx
  801f02:	19 d6                	sbb    %edx,%esi
  801f04:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f08:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f0c:	e9 18 ff ff ff       	jmp    801e29 <__umoddi3+0x69>
